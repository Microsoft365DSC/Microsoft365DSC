<#
.SYNOPSIS
    Measures how the generated class layout affects module load and DSC discovery times.

.DESCRIPTION
    Rebuilds the module for every combination of -BucketCount, -TypeBucketCount and -BalanceBy
    inside a throwaway copy of the repository and, for each of them, times:

        Import-Module        on PowerShell 7 and on Windows PowerShell 5.1, fresh process
        Import-Module        in a second runspace of the same process, which is what an LCM or a
                             relay session pays for every runspace it opens
        using module         on the manifest in a fresh runspace
        Get-DscResourceV2    on PowerShell 7, against a staged copy on PSModulePath
        Parser::ParseFile    over the generated Classes/*.psm1, as the parse-only floor

    Every timing runs in a fresh process, because PowerShell caches created class types for the
    lifetime of a runspace and a second import in the same runspace is close to free.

    The working copy is never touched: the module and Utilities are copied to a temp workspace and
    the build runs there.

.PARAMETER RepositoryRoot
    Root of the Microsoft365DSC repository. Defaults to the parent of this script's folder.

.PARAMETER BucketCount
    The -BucketCount values to measure.

.PARAMETER TypeBucketCount
    The -TypeBucketCount values to measure.

.PARAMETER BalanceBy
    The -BalanceBy values to measure.

.PARAMETER Repetition
    Timed runs per data point. The median is reported. One extra warm-up run per data point is
    always discarded.

.PARAMETER DscParserPath
    Manifest of the DSCParser build to measure against. Defaults to the highest installed version.
    Point this at a working copy to measure a parser change alongside a module change.

.PARAMETER SkipDiscovery
    Skip the Get-DscResourceV2 measurement, which is the slowest part of the sweep.

.PARAMETER SkipWindowsPowerShell
    Skip the Windows PowerShell 5.1 measurements.

.PARAMETER SkipRunspace
    Skip the second-runspace and using-module measurements.

.PARAMETER OutputPath
    Optional CSV to write the results to, on top of returning them.

.EXAMPLE
    .\Measure-M365DSCLoadPerformance.ps1

.EXAMPLE
    .\Measure-M365DSCLoadPerformance.ps1 -BucketCount 8, 16, 32 -TypeBucketCount 4, 8, 16 -Repetition 5 -OutputPath .\sweep.csv

.OUTPUTS
    System.Management.Automation.PSCustomObject
#>
[CmdletBinding()]
[OutputType([System.Management.Automation.PSCustomObject])]
param
(
    [Parameter()]
    [System.String]
    $RepositoryRoot = (Split-Path -Path $PSScriptRoot -Parent),

    [Parameter()]
    [ValidateRange(1, 64)]
    [System.Int32[]]
    $BucketCount = @(1, 2, 4, 8, 12, 16, 24, 32, 48),

    [Parameter()]
    [ValidateRange(1, 64)]
    [System.Int32[]]
    $TypeBucketCount = @(8),

    [Parameter()]
    [ValidateSet('Count', 'Bytes')]
    [System.String[]]
    $BalanceBy = @('Count'),

    [Parameter()]
    [ValidateRange(1, 25)]
    [System.Int32]
    $Repetition = 3,

    [Parameter()]
    [System.String]
    $DscParserPath,

    [Parameter()]
    [Switch]
    $SkipDiscovery,

    [Parameter()]
    [Switch]
    $SkipWindowsPowerShell,

    [Parameter()]
    [Switch]
    $SkipRunspace,

    [Parameter()]
    [System.String]
    $OutputPath
)

$ErrorActionPreference = 'Stop'

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'M365DSCBuildHelpers.psm1') -Force

#region Workspace

$workspace = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('M365DSCPerf_' + [Guid]::NewGuid().ToString('N'))
$workModuleRoot = Join-Path -Path $workspace -ChildPath 'Modules/Microsoft365DSC'
$workUtilities = Join-Path -Path $workspace -ChildPath 'Utilities'
$workManifest = Join-Path -Path $workModuleRoot -ChildPath 'Microsoft365DSC.psd1'
$workClassRoot = Join-Path -Path $workModuleRoot -ChildPath 'Classes'

Write-MeasureLog "Repository : $RepositoryRoot"
Write-MeasureLog "Workspace  : $workspace"
Write-MeasureLog 'Copying the module into the workspace...'

$null = New-Item -Path (Join-Path -Path $workspace -ChildPath 'Modules') -ItemType Directory -Force
Copy-Item -Path (Join-Path -Path $RepositoryRoot -ChildPath 'Modules/Microsoft365DSC') -Destination $workModuleRoot -Recurse -Force
Copy-Item -Path (Join-Path -Path $RepositoryRoot -ChildPath 'Utilities') -Destination $workUtilities -Recurse -Force

$results = [System.Collections.Generic.List[Object]]::new()

$importScript = @"
`$sw = [System.Diagnostics.Stopwatch]::StartNew()
Import-Module -Name '$workManifest' -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
`$sw.Stop()
[System.Int32] `$sw.ElapsedMilliseconds
"@

$runspaceScript = @"
Import-Module -Name '$workManifest' -Force -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
`$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
`$runspace.Open()
`$shell = [System.Management.Automation.PowerShell]::Create()
`$shell.Runspace = `$runspace
`$null = `$shell.AddScript("Import-Module -Name '$workManifest' -WarningAction SilentlyContinue -ErrorAction SilentlyContinue")
`$sw = [System.Diagnostics.Stopwatch]::StartNew()
`$null = `$shell.Invoke()
`$sw.Stop()
`$shell.Dispose()
`$runspace.Dispose()
[System.Int32] `$sw.ElapsedMilliseconds
"@

$usingScript = @"
`$runspace = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
`$runspace.Open()
`$shell = [System.Management.Automation.PowerShell]::Create()
`$shell.Runspace = `$runspace
`$null = `$shell.AddScript("using module '$workManifest'`n[M365DSCResourceBase]::GetRegisteredNames().Count")
`$sw = [System.Diagnostics.Stopwatch]::StartNew()
`$null = `$shell.Invoke()
`$sw.Stop()
`$shell.Dispose()
`$runspace.Dispose()
[System.Int32] `$sw.ElapsedMilliseconds
"@

$parseScript = @"
`$sw = [System.Diagnostics.Stopwatch]::StartNew()
foreach (`$file in Get-ChildItem -Path '$workClassRoot' -Filter '*.psm1')
{
    `$tokens = `$null
    `$errors = `$null
    `$null = [System.Management.Automation.Language.Parser]::ParseFile(`$file.FullName, [ref] `$tokens, [ref] `$errors)
}
`$sw.Stop()
[System.Int32] `$sw.ElapsedMilliseconds
"@

try
{
    foreach ($balance in $BalanceBy)
    {
        foreach ($typeBuckets in $TypeBucketCount)
        {
            foreach ($buckets in $BucketCount)
            {
                $label = "BucketCount $buckets / TypeBucketCount $typeBuckets / $balance"
                Write-MeasureLog "$label - building..."

                $buildOutput = & (Join-Path -Path $workUtilities -ChildPath 'Build-Microsoft365DSC.ps1') `
                    -RepositoryRoot $workspace -BucketCount $buckets -TypeBucketCount $typeBuckets -BalanceBy $balance `
                    -SkipSchema -SkipSchemaCache -SkipResourcePermissions -SkipValidation 2>&1

                $failed = @($buildOutput | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] })
                if ($failed.Count -gt 0)
                {
                    throw "Build failed at ${label}: $($failed[0])"
                }

                $classFiles = @(Get-ChildItem -Path $workClassRoot -Filter '*.psm1')
                $totalBytes = ($classFiles | Measure-Object -Property Length -Sum).Sum
                $largestBytes = ($classFiles | Measure-Object -Property Length -Maximum).Maximum

                Write-MeasureLog "$label - timing import (pwsh)..." -Level Detail
                $importCore = Measure-Median -Executable 'pwsh' -Script $importScript -Count $Repetition

                $importDesktop = $null
                $runspaceDesktop = $null
                if (-not $SkipWindowsPowerShell)
                {
                    Write-MeasureLog "$label - timing import (powershell 5.1)..." -Level Detail
                    $importDesktop = Measure-Median -Executable 'powershell' -Script $importScript -Count $Repetition
                }

                $runspaceCore = $null
                $usingCore = $null
                $usingDesktop = $null
                if (-not $SkipRunspace)
                {
                    Write-MeasureLog "$label - timing second runspace and using module..." -Level Detail
                    $runspaceCore = Measure-Median -Executable 'pwsh' -Script $runspaceScript -Count $Repetition
                    $usingCore = Measure-Median -Executable 'pwsh' -Script $usingScript -Count $Repetition
                    if (-not $SkipWindowsPowerShell)
                    {
                        $runspaceDesktop = Measure-Median -Executable 'powershell' -Script $runspaceScript -Count $Repetition
                        $usingDesktop = Measure-Median -Executable 'powershell' -Script $usingScript -Count $Repetition
                    }
                }

                Write-MeasureLog "$label - timing parse..." -Level Detail
                $parseMs = Measure-Median -Executable 'pwsh' -Script $parseScript -Count $Repetition

                $discoveryMs = $null
                $discoveryTotal = $null
                $discoveryClassBased = $null

                if (-not $SkipDiscovery)
                {
                    Write-MeasureLog "$label - timing Get-DscResourceV2..." -Level Detail

                    $version = ([Version] (Import-PowerShellDataFile -Path $workManifest).ModuleVersion).ToString()
                    $stage = New-M365DSCProbeStage -ModuleRoot $workModuleRoot -Version $version

                    try
                    {
                        $stageRoot = $stage.Root.Replace("'", "''")
                        $discoveryScript = @"
`$parserPath = '$($DscParserPath -replace "'", "''")'
if ([System.String]::IsNullOrEmpty(`$parserPath))
{
    `$parser = @(Get-Module -ListAvailable -Name 'DSCParser' | Sort-Object Version -Descending)[0]
    if (`$null -eq `$parser)
    {
        throw 'DSCParser is not installed; Get-DscResourceV2 is unavailable.'
    }

    `$parserPath = `$parser.Path
}

`$entries = @(`$env:PSModulePath -split [System.IO.Path]::PathSeparator |
    Where-Object { `$_ -and -not (Test-Path -Path (Join-Path -Path `$_ -ChildPath 'Microsoft365DSC')) })
`$env:PSModulePath = (@('$stageRoot') + `$entries) -join [System.IO.Path]::PathSeparator

Import-Module -Name `$parserPath -Force -WarningAction SilentlyContinue

`$sw = [System.Diagnostics.Stopwatch]::StartNew()
`$found = @(Get-DscResourceV2 -Module 'Microsoft365DSC' -ErrorAction SilentlyContinue)
`$sw.Stop()

'COUNT:{0}:{1}' -f `$found.Count, @(`$found | Where-Object { `$_.ImplementationDetail -eq 'ClassBased' }).Count
[System.Int32] `$sw.ElapsedMilliseconds
"@

                        $discoveryMs = Measure-Median -Executable 'pwsh' -Script $discoveryScript -Count $Repetition

                        $countLine = @(Invoke-InFreshProcess -Executable 'pwsh' -Script $discoveryScript |
                                Where-Object { $_ -match '^COUNT:(\d+):(\d+)$' })
                        if ($countLine.Count -gt 0 -and $countLine[0] -match '^COUNT:(\d+):(\d+)$')
                        {
                            $discoveryTotal = [System.Int32] $Matches[1]
                            $discoveryClassBased = [System.Int32] $Matches[2]
                        }
                    }
                    finally
                    {
                        Remove-M365DSCProbeStage -Stage $stage
                    }
                }

                $entry = [PSCustomObject] @{
                    BucketCount          = $buckets
                    TypeBucketCount      = $typeBuckets
                    BalanceBy            = $balance
                    ClassFiles           = $classFiles.Count
                    TotalClassKB         = [System.Math]::Round($totalBytes / 1KB)
                    LargestClassKB       = [System.Math]::Round($largestBytes / 1KB)
                    ImportCoreMs         = $importCore
                    ImportDesktopMs      = $importDesktop
                    Runspace2CoreMs      = $runspaceCore
                    Runspace2DesktopMs   = $runspaceDesktop
                    UsingModuleCoreMs    = $usingCore
                    UsingModuleDesktopMs = $usingDesktop
                    ParseOnlyMs          = $parseMs
                    DiscoveryMs          = $discoveryMs
                    DiscoveryTotal       = $discoveryTotal
                    DiscoveryClassBased  = $discoveryClassBased
                }

                $results.Add($entry)
                Write-MeasureLog ("{0}: import {1} ms (core) / {2} ms (desktop), runspace2 {3} / {4}, using {5} / {6}, parse {7} ms, discovery {8} ms" -f
                    $label, $importCore, $importDesktop, $runspaceCore, $runspaceDesktop, $usingCore, $usingDesktop, $parseMs, $discoveryMs) -Level Success
            }
        }
    }
}
finally
{
    Remove-Item -Path $workspace -Recurse -Force -ErrorAction SilentlyContinue
}

#endregion

if ($PSBoundParameters.ContainsKey('OutputPath'))
{
    $results | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-MeasureLog "Wrote $OutputPath"
}

return $results.ToArray()
