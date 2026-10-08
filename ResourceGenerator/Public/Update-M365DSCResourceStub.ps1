<#
.SYNOPSIS
    Adds unit test stubs for every workload cmdlet a resource module calls.

.DESCRIPTION
    Covers cmdlets added by hand after generation. Import the workload module first, because
    cmdlets missing from the session are skipped.

.PARAMETER ResourceName
    Specifies the name of the resource, e.g. 'TeamsAutoAttendant'.

.PARAMETER Workload
    Specifies the workload of the resource. Defaults to the workload recorded in settings.json.

.PARAMETER Path
    Specifies the folder holding the MSFT_<ResourceName> resource folder.
    Defaults to the repository's DscResources folder.

.PARAMETER StubFilePath
    Specifies the stub file. Defaults to Tests\Unit\Stubs\Microsoft365.psm1 in the repository.

.EXAMPLE
    Import-Module MicrosoftTeams
    Update-M365DSCResourceStub -ResourceName TeamsAutoAttendant
#>
function Update-M365DSCResourceStub
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateSet('ExchangeOnline', 'Intune', 'SecurityComplianceCenter', 'PnP', 'PowerPlatforms', 'MicrosoftTeams', 'MicrosoftGraph')]
        [System.String]
        $Workload,

        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $StubFilePath
    )

    $repositoryRoot = Join-Path -Path $PSScriptRoot -ChildPath '..\..' -Resolve
    if ([System.String]::IsNullOrEmpty($Path))
    {
        $Path = Join-Path -Path $repositoryRoot -ChildPath 'Modules\Microsoft365DSC\DscResources'
    }
    if ([System.String]::IsNullOrEmpty($StubFilePath))
    {
        $StubFilePath = Join-Path -Path $repositoryRoot -ChildPath 'Tests\Unit\Stubs\Microsoft365.psm1'
    }

    $resourceFolder = Join-Path -Path $Path -ChildPath "MSFT_$ResourceName"
    $modulePath = Join-Path -Path $resourceFolder -ChildPath "MSFT_$ResourceName.psm1"
    if (-not (Test-Path -Path $modulePath))
    {
        throw "The resource module '$modulePath' does not exist."
    }

    if ([System.String]::IsNullOrEmpty($Workload))
    {
        $settingsPath = Join-Path -Path $resourceFolder -ChildPath 'settings.json'
        if (Test-Path -Path $settingsPath)
        {
            $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json
            if ($null -ne $settings.generatedFrom -and -not [System.String]::IsNullOrEmpty($settings.generatedFrom.workload))
            {
                $Workload = $settings.generatedFrom.workload
            }
        }
    }

    $regionName = $null
    if (-not [System.String]::IsNullOrEmpty($Workload))
    {
        $regionName = (Get-M365DSCWorkloadDefault -Workload $Workload).StubRegion
    }

    $commands = @(Get-M365DSCResourceCommand -ModulePath $modulePath)
    if ($commands.Count -eq 0)
    {
        Write-Verbose -Message "The resource module '$modulePath' calls no workload cmdlet available in this session."
        return [System.String[]] @()
    }

    $addedNames = @(Add-M365DSCCommandStub -Command $commands -StubFilePath $StubFilePath -RegionName $regionName)
    foreach ($name in $addedNames)
    {
        Write-Verbose -Message "Added a stub for '$name'."
    }

    return [System.String[]] $addedNames
}
