<#
.SYNOPSIS
    Stages a module so DSC discovery can find it.

.DESCRIPTION
    Creates <temp>/<random>/Microsoft365DSC/<Version> pointing at the module root, which is the
    layout Get-DscResourceV2 requires: a PSModulePath entry, a folder named after the module and
    a folder named after its ModuleVersion. Prefers a junction/symlink and falls back to a copy
    when the filesystem or privileges do not allow one.

.PARAMETER ModuleRoot
    Folder holding the module manifest.

.PARAMETER Version
    Module version, used as the leaf folder name. Must match the manifest's ModuleVersion.

.PARAMETER ModuleName
    Module name, used as the parent folder name.

.EXAMPLE
    $stage = New-M365DSCProbeStage -ModuleRoot $moduleRoot -Version '1.26.1007.1'

.OUTPUTS
    System.Collections.Hashtable
#>
function New-M365DSCProbeStage
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ModuleRoot,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Version,

        [Parameter()]
        [System.String]
        $ModuleName = 'Microsoft365DSC'
    )

    $root = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('M365DSCProbe_' + [Guid]::NewGuid().ToString('N'))
    $moduleFolder = Join-Path -Path $root -ChildPath $ModuleName
    $link = Join-Path -Path $moduleFolder -ChildPath $Version

    $null = New-Item -Path $moduleFolder -ItemType Directory -Force

    try
    {
        $onWindows = $PSVersionTable.PSEdition -eq 'Desktop' -or $global:IsWindows
        $linkType = if ($onWindows) { 'Junction' } else { 'SymbolicLink' }

        try
        {
            $null = New-Item -Path $link -ItemType $linkType -Value $ModuleRoot -ErrorAction Stop
            return @{ Root = $root; Link = $link; IsLink = $true }
        }
        catch
        {
            Write-Warning -Message "Could not create a $linkType at '$link' ($($_.Exception.Message)). Falling back to a copy."
        }

        $null = New-Item -Path $link -ItemType Directory -Force
        Copy-Item -Path (Join-Path -Path $ModuleRoot -ChildPath '*') -Destination $link -Recurse -Force

        return @{ Root = $root; Link = $link; IsLink = $false }
    }
    catch
    {
        Remove-Item -Path $root -Recurse -Force -ErrorAction SilentlyContinue
        throw
    }
}

<#
.SYNOPSIS
    Removes a staging folder created by New-M365DSCProbeStage.

.DESCRIPTION
    Deletes the junction itself before the tree, so a recursive delete never follows the link into
    the real module folder.

.PARAMETER Stage
    The hashtable returned by New-M365DSCProbeStage.

.EXAMPLE
    Remove-M365DSCProbeStage -Stage $stage
#>
function Remove-M365DSCProbeStage
{
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Stage
    )

    if (-not $PSCmdlet.ShouldProcess($Stage.Root, 'Remove staging folder'))
    {
        return
    }

    if ($Stage.IsLink -and (Test-Path -Path $Stage.Link))
    {
        [System.IO.Directory]::Delete($Stage.Link, $false)
    }

    Remove-Item -Path $Stage.Root -Recurse -Force -ErrorAction SilentlyContinue
}

function Write-MeasureLog
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateSet('Info', 'Detail', 'Success', 'Warning')]
        [System.String]
        $Level = 'Info'
    )

    $color = switch ($Level)
    {
        'Info' { 'Cyan' }
        'Detail' { 'DarkGray' }
        'Success' { 'Green' }
        'Warning' { 'Yellow' }
    }

    Write-Host "[measure] $Message" -ForegroundColor $color
}

function Invoke-InFreshProcess
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('pwsh', 'powershell')]
        [System.String]
        $Executable,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Script
    )

    $output = & $Executable -NoProfile -NonInteractive -Command $Script 2>$null

    return @($output |
            Where-Object { $_ -is [System.String] -and $_.Trim().Length -gt 0 } |
            ForEach-Object { $_.Trim() })
}

function Measure-Median
{
    [CmdletBinding()]
    [OutputType([System.Nullable[System.Int32]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Executable,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Script,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Count
    )

    $null = Invoke-InFreshProcess -Executable $Executable -Script $Script

    $samples = [System.Collections.Generic.List[System.Int32]]::new()
    for ($i = 0; $i -lt $Count; $i++)
    {
        $lines = @(Invoke-InFreshProcess -Executable $Executable -Script $Script)
        $value = if ($lines.Count -gt 0) { $lines[-1] } else { $null }
        $parsed = 0
        if ([System.Int32]::TryParse($value, [ref] $parsed))
        {
            $samples.Add($parsed)
        }
        else
        {
            Write-MeasureLog "Unusable sample from ${Executable}: '$value'" -Level Warning
        }
    }

    if ($samples.Count -eq 0)
    {
        return $null
    }

    $sorted = @($samples | Sort-Object)
    return $sorted[[System.Math]::Floor($sorted.Count / 2)]
}

<#
.SYNOPSIS
    Compares two compiled MOF documents for equivalence.

.DESCRIPTION
    Both documents are split into their instance blocks. Whitespace, the banner comment, property
    order inside a block, block order, character case and the volatile document properties
    (GenerationDate, GenerationHost, Author, ContentType, ModuleVersion, SourceInfo) do not count.

.PARAMETER ReferencePath
    The reference MOF file.

.PARAMETER CandidatePath
    The MOF file to compare against the reference.

.PARAMETER IgnoreClassPrefix
    Treats a class name with and without the MSFT_ prefix as the same class, which lets a MOF from
    the schema-based module compare against one from the class-based module.

.EXAMPLE
    Compare-M365DSCMofDocument -ReferencePath .\a.mof -CandidatePath .\b.mof

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
function Compare-M365DSCMofDocument
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ReferencePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CandidatePath,

        [Parameter()]
        [Switch]
        $IgnoreClassPrefix
    )

    $reference = Get-M365DSCMofBlock -Path $ReferencePath -IgnoreClassPrefix:$IgnoreClassPrefix
    $candidate = Get-M365DSCMofBlock -Path $CandidatePath -IgnoreClassPrefix:$IgnoreClassPrefix
    $counts = [System.Collections.Generic.Dictionary[System.String, System.Int32]]::new()
    foreach ($block in $candidate)
    {
        if ($counts.ContainsKey($block)) { $counts[$block]++ } else { $counts[$block] = 1 }
    }

    $onlyReference = 0
    foreach ($block in $reference)
    {
        if ($counts.ContainsKey($block) -and $counts[$block] -gt 0) { $counts[$block]-- } else { $onlyReference++ }
    }
    $onlyCandidate = ($counts.Values | Measure-Object -Sum).Sum

    return [PSCustomObject] @{
        Equal          = ($onlyReference -eq 0 -and $onlyCandidate -eq 0)
        ReferenceCount = $reference.Count
        CandidateCount = $candidate.Count
        OnlyReference  = $onlyReference
        OnlyCandidate  = [System.Int32] $onlyCandidate
    }
}

function Get-M365DSCMofBlock
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [Switch]
        $IgnoreClassPrefix
    )

    $text = [System.IO.File]::ReadAllText($Path)
    $text = [regex]::Replace($text, '^\s*/\*.*?\*/', '', 'Singleline')
    $blocks = [regex]::Split($text, '(?=instance of )') | Where-Object { $_ -match '^instance of ' }
    $normalized = foreach ($block in $blocks)
    {
        $collapsed = [regex]::Replace($block, '\s+', ' ').Trim().ToLowerInvariant()
        if ($IgnoreClassPrefix)
        {
            $collapsed = [regex]::Replace($collapsed, 'instance of msft_', 'instance of ')
            $collapsed = [regex]::Replace($collapsed, '\$msft_([a-z0-9_]+ref)', '$$$1')
        }
        $open = $collapsed.IndexOf('{')
        $close = $collapsed.LastIndexOf('}')
        if ($open -lt 0 -or $close -lt $open)
        {
            $collapsed
            continue
        }
        $properties = @(Split-M365DSCMofProperty -Body $collapsed.Substring($open + 1, $close - $open - 1)) |
            Where-Object { $_ -notmatch '^(generationdate|generationhost|author|contenttype|moduleversion|sourceinfo)\s*=' } |
            Sort-Object
        $collapsed.Substring(0, $open).Trim() + ' { ' + ($properties -join '; ') + ' }'
    }

    return @($normalized | Sort-Object)
}

function Split-M365DSCMofProperty
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $Body
    )

    $parts = [System.Collections.Generic.List[System.String]]::new()
    $depth = 0
    $inString = $false
    $start = 0
    for ($i = 0; $i -lt $Body.Length; $i++)
    {
        $character = $Body[$i]
        if ($inString)
        {
            if ($character -eq '\') { $i++ } elseif ($character -eq '"') { $inString = $false }
            continue
        }
        if ($character -eq '"') { $inString = $true }
        elseif ($character -eq '{') { $depth++ }
        elseif ($character -eq '}') { $depth-- }
        elseif ($character -eq ';' -and $depth -eq 0)
        {
            $piece = $Body.Substring($start, $i - $start).Trim()
            if ($piece) { $parts.Add($piece) }
            $start = $i + 1
        }
    }
    $tail = $Body.Substring($start).Trim()
    if ($tail) { $parts.Add($tail) }

    return $parts.ToArray()
}
Export-ModuleMember -Function New-M365DSCProbeStage, Remove-M365DSCProbeStage, Write-MeasureLog, Invoke-InFreshProcess, Measure-Median, Compare-M365DSCMofDocument
