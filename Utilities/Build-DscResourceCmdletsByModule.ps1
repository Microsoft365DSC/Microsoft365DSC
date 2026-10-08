#Requires -Version 7.3

<#
.SYNOPSIS
    Writes the commands and requiredModules sections of every resource's settings.json.

.DESCRIPTION
    Collects every command a resource module invokes through the AST and groups them by the module
    that ships them. Exchange Online and Security and Compliance names are proxies that exist only
    after a connection. They come from the unit test stub file and fill the commands section alone.

.PARAMETER ResourceFilter
    One or more wildcards on the resource module file name, for example 'MSFT_EXO*'.

.PARAMETER StubFilePath
    Path to the unit test stub module used to attribute connect-time proxy cmdlets.

.EXAMPLE
    ./Utilities/Build-DscResourceCmdletsByModule.ps1

.EXAMPLE
    ./Utilities/Build-DscResourceCmdletsByModule.ps1 -ResourceFilter 'MSFT_EXOAcceptedDomain', 'MSFT_Azure*'

.OUTPUTS
    None. The settings.json files are updated in place.
#>
[CmdletBinding()]
param
(
    [Parameter()]
    [System.String[]]
    $ResourceFilter = @('*'),

    [Parameter()]
    [System.String]
    $StubFilePath
)

<#
.SYNOPSIS
    Maps every stub function of the proxy-cmdlet regions to the module that creates the proxy.

.PARAMETER Path
    Specifies the path of the unit test stub module.
#>
function Get-StubCmdletModule
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $regionModuleMap = @{
        'ExchangeOnlineManagement'       = 'ExchangeOnlineManagement'
        'SecurityComplianceCenter'       = 'ExchangeOnlineManagement'
        'M365DataAtRestEncryptionPolicy' = 'ExchangeOnlineManagement'
    }

    $map = @{}
    $currentModule = $null
    foreach ($line in [System.IO.File]::ReadLines($Path))
    {
        if ($line -match '^#region\s+(\S+)')
        {
            $currentModule = $null
            if ($regionModuleMap.ContainsKey($Matches[1]))
            {
                $currentModule = $regionModuleMap[$Matches[1]]
            }
            continue
        }

        if ($line -match '^#endregion')
        {
            $currentModule = $null
            continue
        }

        if ($null -ne $currentModule -and $line -match '^function\s+([A-Za-z]+-[A-Za-z0-9]+)')
        {
            $map[$Matches[1]] = $currentModule
        }
    }

    return $map
}

$MaximumFunctionCount = 32767

$sessionIntruders = @(Get-Module | Where-Object { $_.Name -eq 'M365DSCGraphShim' -or $_.Name -like 'tmpEXO_*' -or $_.Name -like 'tmp_*' })
if ($sessionIntruders.Count -gt 0)
{
    throw "Run this script from a fresh session: the loaded module(s) $($sessionIntruders.Name -join ', ') would shadow the dependency modules in Get-Command."
}

Update-M365DSCDependencies -ValidateOnly -Development
$workingDir = Split-Path -Path $PSScriptRoot -Parent
$m365dscModules = (Import-PowerShellDataFile -Path "$workingDir\Modules\Microsoft365DSC\Dependencies\Manifest.psd1").Dependencies.ModuleName + (Import-PowerShellDataFile -Path "$workingDir\Modules\Microsoft365DSC\Dependencies\DevManifest.psd1").Dependencies.ModuleName

if ([System.String]::IsNullOrEmpty($StubFilePath))
{
    $StubFilePath = Join-Path -Path $workingDir -ChildPath 'Tests\Unit\Stubs\Microsoft365.psm1'
}
$stubModuleByCmdlet = Get-StubCmdletModule -Path $StubFilePath

$resourceFiles = @(foreach ($filter in $ResourceFilter)
    {
        Get-ChildItem -Path "$workingDir\Modules\Microsoft365DSC\DscResources" -Filter "$filter.psm1" -Recurse -File
    }) | Sort-Object -Property FullName -Unique

foreach ($file in $resourceFiles)
{
    Write-Verbose -Message "Processing file: $($file.FullName)"

    $settingsFilePath = Join-Path -Path $file.DirectoryName -ChildPath 'settings.json'
    if (-not (Test-Path -Path $settingsFilePath))
    {
        Write-Verbose -Message "Skipping $($file.Name): no settings.json in its folder."
        continue
    }

    $content = Get-Content -Path $file.FullName -Raw
    $resourceCmdlets = @()

    # These cmdlets are reached through helper functions, which the AST walk does not follow.
    if ($content -like '*Convert*-*Intune*Assignment*')
    {
        $resourceCmdlets += @('Get-MgGroup', 'Get-MgBetaDeviceManagementAssignmentFilter')
    }
    if ($content -like '*Update-DeviceAppManagementAppCategory*')
    {
        $resourceCmdlets += 'Get-MgBetaDeviceAppManagementMobileAppCategory'
    }
    if ($content -like '*Get-IntuneSettingCatalogPolicySetting*')
    {
        $resourceCmdlets += 'Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate'
    }
    if ($content -like '*Get-M365DSCIntuneDeviceConfigurationSettings*')
    {
        $resourceCmdlets += @('Get-MgBetaDeviceManagementTemplateCategory', 'Get-MgBetaDeviceManagementTemplateCategoryRecommendedSetting')
    }
    if ($content -like '*Invoke-M365DSCGraphBatchRequest*')
    {
        $resourceCmdlets += 'Invoke-MgGraphRequest'
    }
    if ($content -like '*Get-M365DSCGroupDisplayNameById*')
    {
        $resourceCmdlets += 'Get-MgGroup'
    }
    if ($content -like "*-Workload 'Azure'*" -or $content -like "*Connect('Azure')*")
    {
        $resourceCmdlets += @('Connect-AzAccount', 'Register-AzModule')
    }

    $ast = [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref] $null, [ref] $null)

    $localFunctions = @($ast.FindAll(
            {
                param($Item)
                return ($Item -is [System.Management.Automation.Language.FunctionDefinitionAst])
            }, $true
        ) | ForEach-Object -Process { $_.Name })

    $resourceCmdlets += @($ast.FindAll(
            {
                param($Item)
                return ($Item -is [System.Management.Automation.Language.CommandAst])
            }, $true
        ) | ForEach-Object -Process { $_.GetCommandName() })

    $resourceCmdlets = @($resourceCmdlets | Where-Object -FilterScript {
            -not [System.String]::IsNullOrEmpty($_) -and
            $_ -match '^[A-Za-z]+-[A-Za-z0-9]+$' -and
            $_ -notin $localFunctions
        } | Sort-Object -Unique)

    $resolvedGroups = @()
    $stubGroups = @()
    if ($resourceCmdlets.Count -gt 0)
    {
        $foundCommands = @(Get-Command -Name $resourceCmdlets -ErrorAction SilentlyContinue)
        $commands = @($foundCommands | Where-Object { $_.ModuleName -in $m365dscModules })
        $commandsNotFunctionOrCmdlet = @($commands | Where-Object { $_.CommandType -ne 'Function' -and $_.CommandType -ne 'Cmdlet' })
        if ($commandsNotFunctionOrCmdlet.Count -gt 0)
        {
            Write-Warning -Message "$($file.Name): the following commands are not functions or cmdlets: $($commandsNotFunctionOrCmdlet.Name -join ', ')"
        }
        $resolvedGroups += @(($commands | Group-Object -Property Source -AsHashTable)?.GetEnumerator() |
                Sort-Object -Property Key |
                ForEach-Object { [ordered]@{ module = $_.Key; cmdlets = @($_.Value.Name | Sort-Object -Unique) } })

        $notFound = @($resourceCmdlets | Where-Object { $_ -notin @($foundCommands.Name) })
        $stubGroups += @($notFound | Where-Object { $stubModuleByCmdlet.ContainsKey($_) } |
                Group-Object -Property { $stubModuleByCmdlet[$_] } |
                Sort-Object -Property Name |
                ForEach-Object { [ordered]@{ module = $_.Name; cmdlets = @($_.Group | Sort-Object -Unique) } })
    }

    $mergedGroups = [ordered]@{}
    foreach ($group in @($resolvedGroups) + @($stubGroups))
    {
        if ($null -eq $group)
        {
            continue
        }
        if (-not $mergedGroups.Contains($group.module))
        {
            $mergedGroups[$group.module] = @()
        }
        $mergedGroups[$group.module] = @(@($mergedGroups[$group.module]) + @($group.cmdlets) | Sort-Object -Unique)
    }
    $resourceCmdletsGrouped = @($mergedGroups.Keys | Sort-Object | ForEach-Object { [ordered]@{ module = $_; cmdlets = @($mergedGroups[$_]) } })

    $settingsRaw = Get-Content -Path $settingsFilePath -Raw
    $settingsJson = $settingsRaw | ConvertFrom-Json -AsHashtable
    if ($resolvedGroups.Count -gt 0)
    {
        $settingsJson['requiredModules'] = @($resolvedGroups.module)
    }
    $settingsJson['commands'] = $resourceCmdletsGrouped
    $fileOutput = (($settingsJson | ConvertTo-Json -Depth 20) -replace "`r?`n", "`r`n") + "`r`n"
    if ($fileOutput -cne $settingsRaw)
    {
        [System.IO.File]::WriteAllText($settingsFilePath, $fileOutput, [System.Text.UTF8Encoding]::new($false))
    }
}

$cmdletsGroupMap = @{}
foreach ($file in (Get-ChildItem -Path "$workingDir\Modules\Microsoft365DSC\Modules" -Filter *.psm1 -Recurse -File))
{
    Write-Verbose -Message "Processing file: $($file.FullName)"
    $content = Get-Content -Path $file.FullName -Raw

    $resourceCmdlets = @()
    $resourceCmdlets += [regex]::Matches($content, '\w+-Mg\w+') | ForEach-Object { $_.Value } | Sort-Object -Unique
    if ($resourceCmdlets.Count -gt 0)
    {
        $commands = Get-Command $resourceCmdlets -ErrorAction SilentlyContinue
        $commandsNotFunctionOrCmdlet = $commands | Where-Object { $_.CommandType -ne 'Function' -and $_.CommandType -ne 'Cmdlet' }
        if ($commandsNotFunctionOrCmdlet.Count -gt 0)
        {
            Write-Warning -Message "$($file.Name): the following commands are not functions or cmdlets: $($commandsNotFunctionOrCmdlet.Name -join ', ')"
        }
        foreach ($cmdlet in $commands)
        {
            if ($cmdlet.CommandType -eq 'Function' -or $cmdlet.CommandType -eq 'Cmdlet')
            {
                if ($cmdletsGroupMap.ContainsKey($cmdlet.Source))
                {
                    $cmdletsGroupMap[$cmdlet.Source] += $cmdlet.Name
                }
                else
                {
                    $cmdletsGroupMap[$cmdlet.Source] = @($cmdlet.Name)
                }
            }
        }
    }
}

$settingsFilePath = Join-Path -Path "$workingDir\Modules\Microsoft365DSC" -ChildPath 'config2.json'
$settingsJson = @{
    requiredModules = @{}
}
foreach ($entry in $cmdletsGroupMap.GetEnumerator())
{
    $settingsJson['requiredModules'].$($entry.Key) = @($entry.Value | Sort-Object -Unique)
}
$fileOutput = $settingsJson | ConvertTo-Json -Depth 5
$fileOutput | Out-File -FilePath $settingsFilePath -Encoding utf8 -Force
