function New-M365DscUnitTestHelper
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $StubModule,

        [Parameter(Mandatory = $true, ParameterSetName = 'DscResource')]
        [String]
        $DscResource,

        [Parameter(Mandatory = $true, ParameterSetName = 'SubModule')]
        [String]
        $SubModulePath,

        [Parameter()]
        [Switch]
        $ExcludeInvokeHelper,

        [Parameter()]
        [System.String]
        $GenericStubModule
    )

    $repoRoot = Join-Path -Path $PSScriptRoot -ChildPath "../../" -Resolve
    $moduleRoot = Join-Path -Path $repoRoot -ChildPath "Modules/Microsoft365DSC"

    $mainModule = Join-Path -Path $moduleRoot -ChildPath "Microsoft365DSC.psd1"
    Remove-Module -Name "AzureAD" -Force -ErrorAction SilentlyContinue
    Import-Module -Name $mainModule -Global
    if ($null -ne ('Microsoft365DSC.Intune.SettingTemplateCache' -as [System.Type]))
    {
        [Microsoft365DSC.Intune.SettingTemplateCache]::Reset()
    }

    if ($PSBoundParameters.ContainsKey("SubModulePath") -eq $true)
    {
        $describeHeader = "Sub-module '$SubModulePath'"
        $moduleToLoad = Join-Path -Path $moduleRoot -ChildPath $SubModulePath
        $moduleName = (Get-Item -Path $moduleToLoad).BaseName
    }

    if ($PSBoundParameters.ContainsKey("DscResource") -eq $true)
    {
        $describeHeader = "DSC Resource '$DscResource'"
        $moduleName = Get-M365DSCResourceModuleName -ResourceName $DscResource

        if ([System.String]::IsNullOrEmpty($moduleName))
        {
            throw ("Could not resolve the class module for resource '$DscResource'. " +
                'Confirm the module was built (Utilities/Build-Microsoft365DSC.ps1) and that the ' +
                'resource is registered by one of the Classes/Part*.psm1 files.')
        }

        $moduleToLoad = $null
    }

    $Global:IsTestEnvironment = $true

    # Only the sub-module case has a file of its own to load; a DSC resource is already in memory.
    if (-not [System.String]::IsNullOrEmpty($moduleToLoad))
    {
        Import-Module -Name $moduleToLoad -Global -Force
    }

    $resourceImport = ''
    if (-not [System.String]::IsNullOrEmpty($moduleToLoad))
    {
        $resourceImport = "Import-Module -Name `"$moduleToLoad`""
    }

    $initScript = @"
            Remove-Module -Name "AzureAD" -Force -ErrorAction SilentlyContinue
            Import-Module -Name "$StubModule" -WarningAction SilentlyContinue -Global
            Import-Module -Name "$GenericStubModule" -WarningAction SilentlyContinue
            $resourceImport
"@

    return @{
        DescribeHeader = $describeHeader
        ModuleName = $moduleName
        CurrentStubModulePath = $StubModule
        InitializeScript = [ScriptBlock]::Create($initScript)
        InvokeCompareRules = ${function:Invoke-M365DSCCompareRules}
        InvokeDeltaCompare = ${function:Invoke-M365DSCDeltaCompare}
        RepoRoot = $repoRoot
        CleanupScript = [ScriptBlock]::Create(@"
            `$global:DSCMachineStatus = 0
"@)
    }
}

function Invoke-M365DSCCompareRules
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $CompareRules,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DesiredValues,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $CurrentValues
    )

    $messages = [System.Collections.Generic.List[System.String]]::new()
    $logDrift = [System.Action[System.String]] {
        param($Message)
        $messages.Add($Message)
    }
    $rewritten = [Microsoft365DSC.Compare.CompareRule]::ApplyAll(
        [Microsoft365DSC.Compare.CompareRule]::ParseAll($CompareRules),
        $DesiredValues,
        $CurrentValues,
        $DesiredValues.Clone(),
        [System.Object[]] @(),
        'Test',
        $logDrift)

    return @{
        Desired       = $rewritten.Item1
        Current       = $rewritten.Item2
        ValuesToCheck = $rewritten.Item3
        Messages      = $messages
    }
}

<#
.SYNOPSIS
    Compares two parsed configurations of one resource the way New-M365DSCDeltaReport does.

.PARAMETER ReportParameters
    A GetCompareParameters() result passed to the comparer with IsReport appended to its
    PostProcessingArgs. Without it the comparer reads the CompareParameters of SchemaDefinition.json.

.OUTPUTS
    The parameter name of every delta.
#>
function Invoke-M365DSCDeltaCompare
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Source,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Destination,

        [Parameter()]
        [System.Collections.Hashtable]
        $ReportParameters
    )

    Initialize-M365DSCDllLoader
    if (-not [Microsoft365DSC.Cache.CacheManager]::IsSchemaLoaded)
    {
        $schemaPath = Join-Path -Path $PSScriptRoot -ChildPath '../../Modules/Microsoft365DSC/SchemaDefinition.json'
        [Microsoft365DSC.Cache.CacheManager]::LoadSchema(([System.IO.File]::ReadAllText($schemaPath) | ConvertFrom-Json))
    }

    $compareParameters = [System.Collections.Generic.Dictionary[System.String, Microsoft365DSC.Compare.ResourceCompareParameters]]::new()
    if ($PSBoundParameters.ContainsKey('ReportParameters'))
    {
        $parameters = [Microsoft365DSC.Compare.ResourceCompareParameters]::new()
        $parameters.ExcludedProperties = [System.String[]] $ReportParameters.ExcludedProperties
        $parameters.IncludedProperties = [System.String[]] $ReportParameters.IncludedProperties
        $parameters.PostProcessing = $ReportParameters.PostProcessing
        $parameters.Rules = [Microsoft365DSC.Compare.CompareRule]::ParseAll($ReportParameters.CompareRules)
        $existingArgs = @()
        if ($null -ne $ReportParameters.PostProcessingArgs)
        {
            $existingArgs = @($ReportParameters.PostProcessingArgs)
        }
        $parameters.PostProcessingArgs = [System.Object[]] ($existingArgs + @{ IsReport = $true })
        $compareParameters.Add($ResourceName, $parameters)
    }

    $sides = @()
    foreach ($values in @($Source, $Destination))
    {
        $resource = $values.Clone()
        $resource['ResourceName'] = $ResourceName
        $resource['ResourceInstanceName'] = 'Instance'
        $sides += $resource
    }

    $deltas = [Microsoft365DSC.Compare.ConfigurationComparer]::Compare(
        [System.Object[]] @($sides[0]),
        [System.Object[]] @($sides[1]),
        [Microsoft365DSC.Cache.CacheManager]::Schema,
        $null,
        $null,
        $compareParameters)

    $deltas = $deltas | ForEach-Object -Process { $_.Properties[0].ParameterName }
    return Get-M365DSCArrayFromProperty -PropertyValue $deltas -ElementType ([System.String])
}
