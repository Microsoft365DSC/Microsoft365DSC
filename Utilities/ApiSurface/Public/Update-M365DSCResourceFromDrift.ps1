<#
.SYNOPSIS
    Applies one drift finding to the resource it names, verifies it, and reverts it on failure.

.DESCRIPTION
    The original bytes are held for the whole call. A failed verification restores the file
    exactly. A removal marks the property deprecated rather than deleting it. The unit test gate
    reads the built classes under Modules/Microsoft365DSC/Classes, not the source edited here.

.PARAMETER Finding
    Specifies one finding from api-drift.json.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.PARAMETER ResourcePath
    Specifies the folder holding the MSFT_<Name> resource folders.

.PARAMETER TestRoot
    Specifies the folder holding the resource unit tests.

.PARAMETER AllowNonAutomatic
    Indicates that the manual categories are unlocked. Local only, never in CI.

.PARAMETER SkipUnitTest
    Indicates that the unit test gate is skipped. For a caller that batches the tests itself.

.EXAMPLE
    Update-M365DSCResourceFromDrift -Finding $finding

.OUTPUTS
    An ordered dictionary with the finding id, whether it was applied, and why.
#>
function Update-M365DSCResourceFromDrift
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Finding,

        [Parameter()]
        [System.String]
        $RepositoryRoot = (Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve),

        [Parameter()]
        [System.String]
        $ResourcePath,

        [Parameter()]
        [System.String]
        $TestRoot,

        [Parameter()]
        [switch]
        $AllowNonAutomatic,

        [Parameter()]
        [switch]
        $SkipUnitTest
    )

    if ($AllowNonAutomatic -and -not [System.String]::IsNullOrEmpty($env:GITHUB_ACTIONS))
    {
        throw ('-AllowNonAutomatic is a local-only switch and cannot be used in CI. ' +
            'Run it from a working copy and review the scaffold by hand.')
    }

    if ([System.String]::IsNullOrEmpty($ResourcePath))
    {
        $ResourcePath = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/DscResources'
    }

    if ([System.String]::IsNullOrEmpty($TestRoot))
    {
        $TestRoot = Join-Path -Path $RepositoryRoot -ChildPath 'Tests/Unit/Microsoft365DSC'
    }

    $code = [System.String] $Finding.code
    $resource = [System.String] $Finding.resource

    if ($code.StartsWith('CAT-', [System.StringComparison]::Ordinal))
    {
        throw ("'$code' is never applied by the splicer. Regenerate the resource with " +
            "New-M365DSCResource -ResourceName $resource -Workload Intune -SettingsCatalogTemplateId '<id>'.")
    }

    if ([System.String]::IsNullOrEmpty($resource))
    {
        return New-ApplyResult -Finding $Finding -Applied $false -Reason "'$code' names no resource."
    }

    if (-not (Test-ApplyAllowed -Code $code -Finding $Finding -AllowNonAutomatic:$AllowNonAutomatic))
    {
        return New-ApplyResult -Finding $Finding -Applied $false `
            -Reason "'$code' is not applied unattended. Rerun with -AllowNonAutomatic from a working copy."
    }

    $modulePath = Join-Path -Path $ResourcePath -ChildPath "MSFT_$resource/MSFT_$resource.psm1"
    if (-not (Test-Path -Path $modulePath))
    {
        return New-ApplyResult -Finding $Finding -Applied $false -Reason "'$modulePath' does not exist."
    }

    $original = [System.IO.File]::ReadAllText($modulePath)
    $classEdit = Get-ResourceClassEdit -Path $modulePath
    $generator = Get-M365DSCApiSurfaceGenerator -RepositoryRoot $RepositoryRoot

    $requireResultEntry = $false
    try
    {
        switch ($code)
        {
            'RES-ENUM-STALE'
            {
                $edits = @(Update-ValidateSet -ClassEdit $classEdit `
                        -PropertyName ([System.String] $Finding.property) `
                        -Member ([System.String[]] @($Finding.to.added)) `
                        -Generator $generator)
            }
            'VND-ENUM-MEMBER-ADDED'
            {
                $edits = @(Update-ValidateSet -ClassEdit $classEdit `
                        -PropertyName ([System.String] $Finding.property) `
                        -Member ([System.String[]] @($Finding.to.added)) `
                        -Generator $generator)
            }
            'RES-PROP-MISSING'
            {
                $requireResultEntry = $true
                $origin = Get-ResourceGeneratedFrom -ResourcePath $ResourcePath -Resource $resource
                $edits = @(Add-ClassProperty -ClassEdit $classEdit `
                        -Finding $Finding `
                        -Generator $generator `
                        -Origin $origin)
            }
            'RES-PROP-ORPHANED'
            {
                $edits = @(Set-PropertyDeprecated -ClassEdit $classEdit -Finding $Finding)
            }
            'RES-TYPE-MISMATCH'
            {
                $origin = Get-ResourceGeneratedFrom -ResourcePath $ResourcePath -Resource $resource
                $edits = @(Update-PropertyType -ClassEdit $classEdit `
                        -Finding $Finding `
                        -Generator $generator `
                        -Origin $origin)
            }
            default
            {
                return New-ApplyResult -Finding $Finding -Applied $false -Reason "No applier handles '$code'."
            }
        }
    }
    catch
    {
        return New-ApplyResult -Finding $Finding -Applied $false -Reason $_.Exception.Message
    }

    if ($edits.Count -eq 0)
    {
        return New-ApplyResult -Finding $Finding -Applied $false -Reason 'The resource already carries the change.'
    }

    if (-not $PSCmdlet.ShouldProcess($modulePath, "Apply $($Finding.id)"))
    {
        return New-ApplyResult -Finding $Finding -Applied $false -Reason 'Skipped by ShouldProcess.'
    }

    $null = Write-ResourceEdit -Path $modulePath -Text $classEdit.Text -Edit $edits -Confirm:$false

    $testPath = ''
    if (-not $SkipUnitTest)
    {
        $testPath = Join-Path -Path $TestRoot -ChildPath "Microsoft365DSC.$resource.Tests.ps1"
    }

    $verified = Test-AppliedChange -Path $modulePath `
        -PropertyName ([System.String] $Finding.property) `
        -RequireResultEntry:$requireResultEntry `
        -TestPath $testPath

    if (-not $verified.Passed)
    {
        [System.IO.File]::WriteAllText($modulePath, $original, [System.Text.UTF8Encoding]::new($false))
        return New-ApplyResult -Finding $Finding -Applied $false -Reason "Reverted. $($verified.Reason)" -Reverted
    }

    return New-ApplyResult -Finding $Finding -Applied $true -Reason $verified.Reason -Edit $edits -Path $modulePath
}

<#
.SYNOPSIS
    Reads the generatedFrom block of a resource.

.PARAMETER ResourcePath
    Specifies the folder holding the MSFT_<Name> resource folders.

.PARAMETER Resource
    Specifies the resource name without the MSFT_ prefix.

.OUTPUTS
    The generatedFrom block.
#>
function Get-ResourceGeneratedFrom
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourcePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Resource
    )

    $settingsPath = Join-Path -Path $ResourcePath -ChildPath "MSFT_$Resource/settings.json"
    if (-not (Test-Path -Path $settingsPath))
    {
        throw "'$settingsPath' does not exist."
    }

    $origin = (Get-Content -Path $settingsPath -Raw | ConvertFrom-Json).generatedFrom
    if ($null -eq $origin)
    {
        throw "'$Resource' carries no generatedFrom block."
    }

    return $origin
}

<#
.SYNOPSIS
    Decides whether a finding may be applied.

.PARAMETER Code
    Specifies the finding code.

.PARAMETER Finding
    Specifies the finding.

.PARAMETER AllowNonAutomatic
    Indicates that the manual categories are unlocked.

.OUTPUTS
    True when an applier may run.
#>
function Test-ApplyAllowed
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Code,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Finding,

        [Parameter()]
        [switch]
        $AllowNonAutomatic
    )

    # A cmdlet removal or a reroute is resource level rework. A scaffold cannot help with it.
    if ($Code -in @('VND-CMDLET-REMOVED', 'VND-CMDLET-REROUTED') -or
        $Code.StartsWith('CAT-', [System.StringComparison]::Ordinal))
    {
        return $false
    }

    if ([System.Boolean] $Finding.autoFixable)
    {
        return $true
    }

    return [System.Boolean] $AllowNonAutomatic
}

<#
.SYNOPSIS
    Builds the result of one apply attempt.

.PARAMETER Finding
    Specifies the finding.

.PARAMETER Applied
    Indicates that the change stayed on disk.

.PARAMETER Reason
    Specifies what happened.

.PARAMETER Reverted
    Indicates that an applied change was rolled back.

.PARAMETER Edit
    Specifies the edits that were made.

.PARAMETER Path
    Specifies the file that changed.

.OUTPUTS
    An ordered dictionary describing the attempt.
#>
function New-ApplyResult
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Finding,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Applied,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Reason,

        [Parameter()]
        [switch]
        $Reverted,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Edit = @(),

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Path
    )

    return [ordered]@{
        Id       = [System.String] $Finding.id
        Code     = [System.String] $Finding.code
        Resource = [System.String] $Finding.resource
        Property = [System.String] $Finding.property
        Applied  = $Applied
        Reverted = [System.Boolean] $Reverted
        Reason   = $Reason
        Edit     = @($Edit | ForEach-Object -Process { $_.Reason })
        Path     = $Path
    }
}
