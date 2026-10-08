<#
.SYNOPSIS
    Generates Modules/Microsoft365DSC/DscSchemaCache.json for the fast DSC compile host.

.DESCRIPTION
    Resolves the M365DSC.PSDesiredStateConfiguration-capable DSC engine (PSData tag
    M365DSCFastHost), stages the built Microsoft365DSC module under a
    version folder, and runs Export-DscSchemaCache in a child process so the one-time
    class discovery does not pollute the calling session. The resulting cache ships in
    the module package and lets Invoke-DscFastCompile compile tenant configurations
    without any module parsing.
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [System.String]
    $EnginePath,

    [Parameter()]
    [Switch]
    $WarnOnly
)

$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCBuildHelpers.psm1') -Force

$moduleRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC'
$manifestPath = Join-Path -Path $moduleRoot -ChildPath 'Microsoft365DSC.psd1'
$manifest = Import-PowerShellDataFile -Path $manifestPath
$version = ([Version] $manifest.ModuleVersion).ToString()
$expectedResourceCount = @($manifest.DscResourcesToExport).Count

function Resolve-M365DSCDscEngineManifest
{
    param
    (
        [System.String]
        $ExplicitPath,

        [System.String]
        $RepositoryRoot,

        [System.String]
        $ModuleRoot
    )

    if ($ExplicitPath)
    {
        $candidate = if ([System.IO.Path]::GetExtension($ExplicitPath) -eq '.psd1')
        {
            $ExplicitPath
        }
        else
        {
            Join-Path -Path $ExplicitPath -ChildPath 'M365DSC.PSDesiredStateConfiguration.psd1'
        }
        if (Test-Path -Path $candidate)
        {
            return (Resolve-Path -Path $candidate).ProviderPath
        }
        throw "No engine manifest found at '$ExplicitPath'."
    }

    $installed = Get-Module -ListAvailable -Name M365DSC.PSDesiredStateConfiguration | Where-Object {
        $_.PrivateData.PSData.Tags -contains 'M365DSCFastHost'
    } | Sort-Object -Property Version -Descending | Select-Object -First 1
    if ($installed)
    {
        return $installed.Path
    }

    $sibling = Join-Path -Path (Split-Path -Path $RepositoryRoot -Parent) -ChildPath 'PSDesiredStateConfiguration/M365DSC.PSDesiredStateConfiguration/M365DSC.PSDesiredStateConfiguration.psd1'
    if (Test-Path -Path $sibling)
    {
        return (Resolve-Path -Path $sibling).ProviderPath
    }

    return $null
}

$engineManifest = Resolve-M365DSCDscEngineManifest -ExplicitPath $EnginePath -RepositoryRoot $RepositoryRoot -ModuleRoot $moduleRoot
if (-not $engineManifest)
{
    $message = 'No M365DSCFastHost-capable M365DSC.PSDesiredStateConfiguration engine was found. DscSchemaCache.json was not generated.'
    if ($WarnOnly)
    {
        Write-Warning -Message $message
        return
    }
    throw $message
}

$cachePath = Join-Path -Path $moduleRoot -ChildPath 'DscSchemaCache.json'
$stage = New-M365DSCProbeStage -ModuleRoot $moduleRoot -Version $version

try
{
    $shell = if (Get-Command -Name pwsh -ErrorAction Ignore) { 'pwsh' } else { 'powershell' }
    $stageRoot = $stage.Root.Replace("'", "''")
    $engineManifestEscaped = $engineManifest.Replace("'", "''")
    $cachePathEscaped = $cachePath.Replace("'", "''")

    $child = @"
`$ErrorActionPreference = 'Stop'
`$entries = @(`$env:PSModulePath -split [System.IO.Path]::PathSeparator |
    Where-Object { `$_ -and -not (Test-Path -Path (Join-Path -Path `$_ -ChildPath 'Microsoft365DSC')) })
`$env:PSModulePath = (@('$stageRoot') + `$entries) -join [System.IO.Path]::PathSeparator
Import-Module -Name '$engineManifestEscaped' -Force
`$summary = Export-DscSchemaCache -ModuleName 'Microsoft365DSC' -OutputPath '$cachePathEscaped'
'RESULT:' + (`$summary | ConvertTo-Json -Compress)
"@

    Write-Verbose -Message "Generating DscSchemaCache.json with $shell (engine: $engineManifest)..." -Verbose
    $output = & $shell -NoProfile -NonInteractive -Command $child
    if ($LASTEXITCODE -ne 0)
    {
        throw "Schema cache generation failed (exit $LASTEXITCODE): $($output -join [Environment]::NewLine)"
    }

    $resultLine = @($output | Where-Object { $_ -like 'RESULT:*' }) | Select-Object -First 1
    if (-not $resultLine)
    {
        throw "Schema cache generation produced no result: $($output -join [Environment]::NewLine)"
    }
    $summary = $resultLine.Substring(7) | ConvertFrom-Json

    if ([int]$summary.ResourceCount -ne $expectedResourceCount)
    {
        throw "Schema cache covers $($summary.ResourceCount) resources but the manifest exports $expectedResourceCount."
    }

    Write-Verbose -Message "DscSchemaCache.json: $($summary.ResourceCount) resources, $($summary.KeywordCount) keywords, fingerprint $($summary.Fingerprint)." -Verbose
    Get-Item -Path $cachePath
}
finally
{
    Remove-M365DSCProbeStage -Stage $stage
}
