<#
.SYNOPSIS
    Measures the compare and converter engines of the compiled Microsoft365DSC assemblies.

.DESCRIPTION
    Parses two exported configurations once per fresh process and times, in that process:

        ConfigurationComparer.Compare     source against destination, and destination against itself
        ResourceComparer.Compare          every destination instance against a clone of itself
        ComplexObjectConverter.ToDscString every complex property of the destination
        HashtableConverter.ConvertToString every destination instance
        New-M365DSCDeltaReport            end to end, HTML

    Parsing happens outside the timed regions. Each timed region runs once as a warm-up and then
    -Repetition times; the minimum and the median are reported together with the bytes allocated
    and the number of gen0 collections of the median run.

    A rebuilt assembly is only picked up by a new process, so every scenario runs in a fresh host.
    Do not load the module in the process that runs this script.

.PARAMETER SourcePath
    The exported configuration used as the source.

.PARAMETER DestinationPath
    The exported configuration used as the destination.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER Scenario
    Which timed regions to run. Defaults to all of them.

.PARAMETER Repetition
    Timed runs per region after the warm-up.

.PARAMETER Executable
    Host to measure in.

.PARAMETER OutputPath
    Optional CSV to write the results to, on top of returning them.

.EXAMPLE
    .\Measure-M365DSCComparePerformance.ps1 -SourcePath .\old.ps1 -DestinationPath .\new.ps1

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
[CmdletBinding()]
[OutputType([System.Management.Automation.PSCustomObject])]
param
(
    [Parameter(Mandatory = $true)]
    [System.String]
    $SourcePath,

    [Parameter(Mandatory = $true)]
    [System.String]
    $DestinationPath,

    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [ValidateSet('Compare', 'TestTargetResource', 'Converter', 'DeltaReport')]
    [System.String[]]
    $Scenario = @('Compare', 'TestTargetResource', 'Converter', 'DeltaReport'),

    [Parameter()]
    [ValidateRange(1, 25)]
    [System.Int32]
    $Repetition = 3,

    [Parameter()]
    [ValidateSet('pwsh', 'powershell')]
    [System.String]
    $Executable = 'pwsh',

    [Parameter()]
    [System.String]
    $OutputPath
)

$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCBuildHelpers.psm1') -Force

$sourcePath = (Resolve-Path -Path $SourcePath).Path
$destinationPath = (Resolve-Path -Path $DestinationPath).Path
$manifest = Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC/Microsoft365DSC.psd1'

if (-not (Test-Path -Path $manifest))
{
    throw "Module manifest not found at '$manifest'."
}

$scenarioList = ($Scenario | ForEach-Object -Process { "'$_'" }) -join ', '

$script = @"
`$ErrorActionPreference = 'Stop'
`$Global:M365DSCSkipDependenciesValidation = `$true
Import-Module -Name '$manifest' -Force -WarningAction SilentlyContinue
`$module = Get-Module -Name Microsoft365DSC
`$reportModule = `$module.NestedModules | Where-Object -FilterScript { `$_.Name -eq 'M365DSCReport' } | Select-Object -First 1
& `$reportModule {
    Initialize-M365DSCDllLoader -ErrorAction Stop
    Initialize-M365DSCSchemaCache
    if (`$null -eq `$Script:DscResourceInfo) { `$Script:DscResourceInfo = Get-M365DSCResourceSchema }
}

function Read-Configuration
{
    param([System.String] `$Path)

    return & `$reportModule { param(`$p) [Array](Initialize-M365DSCReporting -ConfigurationPath `$p -DscResourceInfo `$Script:DscResourceInfo) } `$Path 3>`$null
}

function Measure-Region
{
    param([System.String] `$Stage, [System.Int32] `$Count, [System.Int32] `$Resources, [System.Management.Automation.ScriptBlock] `$Setup, [System.Management.Automation.ScriptBlock] `$Body)

    `$samples = [System.Collections.Generic.List[object]]::new()
    for (`$i = 0; `$i -le `$Count; `$i++)
    {
        `$state = & `$Setup
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        [System.GC]::Collect()
        `$allocatedBefore = [System.GC]::GetTotalAllocatedBytes(`$true)
        `$gen0Before = [System.GC]::CollectionCount(0)
        `$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        `$value = & `$Body `$state
        `$stopwatch.Stop()
        if (`$i -eq 0) { continue }
        `$samples.Add([PSCustomObject]@{
            Ms      = [System.Math]::Round(`$stopwatch.Elapsed.TotalMilliseconds, 2)
            AllocMB = [System.Math]::Round(([System.GC]::GetTotalAllocatedBytes(`$true) - `$allocatedBefore) / 1MB, 2)
            Gen0    = [System.GC]::CollectionCount(0) - `$gen0Before
            Count   = @(`$value).Count
        })
    }

    `$sorted = @(`$samples | Sort-Object -Property Ms)
    `$median = `$sorted[[System.Math]::Floor(`$sorted.Count / 2)]
    [PSCustomObject]@{
        Stage     = `$Stage
        Resources = `$Resources
        MinMs     = `$sorted[0].Ms
        MedianMs  = `$median.Ms
        AllocMB   = `$median.AllocMB
        Gen0      = `$median.Gen0
        Count     = `$median.Count
    } | ConvertTo-Json -Compress
}

`$source = Read-Configuration -Path '$sourcePath'
`$destination = Read-Configuration -Path '$destinationPath'
`$schema = [Microsoft365DSC.Cache.CacheManager]::Schema
`$excluded = [System.String[]]@('ResourceInstanceName', 'Credential', 'ManagedIdentity', 'ApplicationId', 'TenantId', 'CertificatePath', 'CertificatePassword', 'CertificateThumbprint', 'ApplicationSecret')
`$scenarios = @($scenarioList)
`$repetition = $Repetition

`$compareParameters = & `$reportModule {
    param(`$names)
    `$map = [System.Collections.Generic.Dictionary[System.String, Microsoft365DSC.Compare.ResourceCompareParameters]]::new()
    foreach (`$name in `$names)
    {
        `$custom = Get-M365DSCResourceComparisonParameters -ResourceName `$name
        if (`$null -eq `$custom -or `$custom.Count -eq 0) { continue }
        `$parameters = [Microsoft365DSC.Compare.ResourceCompareParameters]::new()
        `$parameters.ExcludedProperties = [System.String[]] `$custom.ExcludedProperties
        `$parameters.IncludedProperties = [System.String[]] `$custom.IncludedProperties
        `$parameters.PostProcessing = `$custom.PostProcessing
        `$existingArgs = @()
        if (`$null -ne `$custom.PostProcessingArgs) { `$existingArgs = @(`$custom.PostProcessingArgs) }
        `$parameters.PostProcessingArgs = [System.Object[]] (`$existingArgs + @{ IsReport = `$true })
        `$map.Add(`$name, `$parameters)
    }
    `$map
} (@(`$source.ResourceName) + @(`$destination.ResourceName) | Select-Object -Unique)

if (`$scenarios -contains 'Compare')
{
    Measure-Region -Stage 'ConfigurationComparer source->destination' -Count `$repetition -Resources `$destination.Count -Setup {
        @{ Source = (Read-Configuration -Path '$sourcePath'); Destination = (Read-Configuration -Path '$destinationPath') }
    } -Body {
        param(`$state)
        [Microsoft365DSC.Compare.ConfigurationComparer]::Compare(`$state.Source, `$state.Destination, `$schema, `$excluded, `$null, `$compareParameters)
    }

    Measure-Region -Stage 'ConfigurationComparer destination->destination' -Count `$repetition -Resources `$destination.Count -Setup {
        @{ Source = (Read-Configuration -Path '$destinationPath'); Destination = (Read-Configuration -Path '$destinationPath') }
    } -Body {
        param(`$state)
        [Microsoft365DSC.Compare.ConfigurationComparer]::Compare(`$state.Source, `$state.Destination, `$schema, `$excluded, `$null, `$compareParameters)
    }
}

if (`$scenarios -contains 'TestTargetResource')
{
    Measure-Region -Stage 'ResourceComparer per instance' -Count `$repetition -Resources `$destination.Count -Setup { `$destination } -Body {
        param(`$state)
        `$drifted = 0
        foreach (`$resource in `$state)
        {
            `$result = [Microsoft365DSC.Compare.ResourceComparer]::Compare(`$resource, `$resource.Clone(), `$resource, `$schema, `$resource.ResourceName, `$excluded, `$null)
            if (-not `$result.TestResult) { `$drifted++ }
        }
        `$drifted
    }
}

if (`$scenarios -contains 'Converter')
{
    `$complexProperties = [System.Collections.Generic.List[object]]::new()
    foreach (`$resource in `$destination)
    {
        foreach (`$key in @(`$resource.Keys))
        {
            `$value = `$resource[`$key]
            if (`$value -is [System.Collections.Hashtable] -or (`$value -is [System.Array] -and `$value.Count -gt 0 -and `$value[0] -is [System.Collections.Hashtable]))
            {
                `$complexProperties.Add(`$value)
            }
        }
    }
    `$mapping = [System.Collections.Generic.List[Microsoft365DSC.Converter.ComplexTypeMapping]]::new()

    Measure-Region -Stage 'ComplexObjectConverter.ToDscString' -Count `$repetition -Resources `$complexProperties.Count -Setup { `$complexProperties } -Body {
        param(`$state)
        foreach (`$value in `$state) { `$null = [Microsoft365DSC.Converter.ComplexObjectConverter]::ToDscString(`$value, 'MSFT_Benchmark', `$mapping, '', 3, `$false) }
        `$state.Count
    }

    Measure-Region -Stage 'ObjectNormalizer.Normalize' -Count `$repetition -Resources `$complexProperties.Count -Setup { `$complexProperties } -Body {
        param(`$state)
        foreach (`$value in `$state) { `$null = [Microsoft365DSC.Converter.ObjectNormalizer]::Normalize(`$value) }
        `$state.Count
    }

    Measure-Region -Stage 'HashtableConverter.ConvertToString' -Count `$repetition -Resources `$destination.Count -Setup { `$destination } -Body {
        param(`$state)
        foreach (`$resource in `$state) { `$null = [Microsoft365DSC.Converter.HashtableConverter]::ConvertToString(`$resource) }
        `$state.Count
    }
}

if (`$scenarios -contains 'DeltaReport')
{
    `$outputPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('M365DSCCompareBenchmark_' + [System.Guid]::NewGuid().ToString('N') + '.html')
    `$null = New-M365DSCDeltaReport -Source '$sourcePath' -Destination '$destinationPath' -OutputPath `$outputPath -Type HTML -Delta @() -WarningAction SilentlyContinue
    Measure-Region -Stage 'New-M365DSCDeltaReport HTML' -Count `$repetition -Resources `$destination.Count -Setup { `$null } -Body {
        param(`$state)
        New-M365DSCDeltaReport -Source '$sourcePath' -Destination '$destinationPath' -OutputPath `$outputPath -Type HTML -WarningAction SilentlyContinue
        1
    }
    Remove-Item -Path `$outputPath -Force -ErrorAction SilentlyContinue
}
"@

Write-MeasureLog "Source      : $sourcePath"
Write-MeasureLog "Destination : $destinationPath"
Write-MeasureLog "Scenarios   : $($Scenario -join ', ')"

$lines = @(Invoke-InFreshProcess -Executable $Executable -Script $script)
$results = [System.Collections.Generic.List[object]]::new()
foreach ($line in $lines)
{
    if (-not $line.StartsWith('{'))
    {
        continue
    }

    $entry = $line | ConvertFrom-Json
    $results.Add([PSCustomObject]@{
            Source      = [System.IO.Path]::GetFileName($sourcePath)
            Destination = [System.IO.Path]::GetFileName($destinationPath)
            Stage       = $entry.Stage
            Resources   = $entry.Resources
            MinMs       = $entry.MinMs
            MedianMs    = $entry.MedianMs
            AllocMB     = $entry.AllocMB
            Gen0        = $entry.Gen0
            Count       = $entry.Count
        })
}

if ($results.Count -eq 0)
{
    Write-MeasureLog 'No samples were produced. Run the generated script with -Verbose to see the host output.' -Level Warning
    Write-Verbose -Message ($lines -join [System.Environment]::NewLine)
}

if (-not [System.String]::IsNullOrEmpty($OutputPath))
{
    $results | Export-Csv -Path $OutputPath -NoTypeInformation -Force
    Write-MeasureLog "Results written to $OutputPath" -Level Success
}

return $results
