function Invoke-TestHarness
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $TestResultsFile,

        [Parameter()]
        [System.String[]]
        $DscTestsPath,

        [Parameter()]
        [Switch]
        $IgnoreCodeCoverage,

        [Parameter()]
        [System.String[]]
        $CodeCoveragePath,

        [Parameter()]
        [System.String]
        $CodeCoverageOutputPath = 'coverage.xml',

        [Parameter()]
        [System.Int32]
        $ShardIndex = 1,

        [Parameter()]
        [System.Int32]
        $ShardCount = 1
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    $MaximumFunctionCount = 32767
    Write-Host -Object 'Running all Microsoft365DSC Unit Tests'

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '../' -Resolve

    $testCoverageFiles = @()
    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        # Tests load the generated class modules. DscResources is build input and never executes.
        $coverageRoots = $CodeCoveragePath
        if ($null -eq $coverageRoots -or $coverageRoots.Count -eq 0)
        {
            $coverageRoots = @(
                "$repoDir/Modules/Microsoft365DSC/Classes/*.psm1"
                "$repoDir/Modules/Microsoft365DSC/Modules/*.psm1"
            )
        }

        $testCoverageFiles = @(Get-ChildItem -Path $coverageRoots -ErrorAction SilentlyContinue |
            Select-Object -ExpandProperty FullName -Unique)

        if ($testCoverageFiles.Count -eq 0)
        {
            throw ("No code coverage files matched [$($coverageRoots -join ', ')]. Build the module " +
                'with Utilities/Build-Microsoft365DSC.ps1 or pass -IgnoreCodeCoverage.')
        }
    }

    Import-Module -Name "$repoDir/Modules/Microsoft365DSC/Microsoft365DSC.psd1" -Global
    $testsToRun = @()

    # Run Unit Tests
    $versionsPath = Join-Path -Path $repoDir -ChildPath './Tests/Unit/Stubs/'
    # Import the first stub found so that there is a base module loaded before the tests start
    $firstStub = Join-Path -Path $repoDir `
        -ChildPath './Tests/Unit/Stubs/Microsoft365.psm1'
    Import-Module $firstStub -WarningAction SilentlyContinue

    $stubPath = Join-Path -Path $repoDir `
        -ChildPath './Tests/Unit/Stubs/Microsoft365.psm1'

    # DSC Common Tests
    $getChildItemParameters = @{
        Path    = (Join-Path -Path $repoDir -ChildPath './Tests/Unit')
        Recurse = $true
        Filter  = '*.Tests.ps1'
    }

    # Get all tests '*.Tests.ps1'.
    $commonTestFiles = Get-ChildItem @getChildItemParameters

    # Remove DscResource.Tests unit tests.
    $commonTestFiles = $commonTestFiles | Where-Object -FilterScript {
        $_.FullName -notmatch 'DSCResource.Tests[\\/]Tests'
    }

    $testsToRun += @( $commonTestFiles.FullName )

    $filesToExecute = @()
    if ($null -ne $DscTestsPath -and @($DscTestsPath).Count -gt 0)
    {
        $filesToExecute += $DscTestsPath
    }
    else
    {
        foreach ($testToRun in $testsToRun)
        {
            $filesToExecute += $testToRun
        }
    }

    if ($ShardCount -gt 1)
    {
        $ordered = @($filesToExecute | Sort-Object -Property @{
            Expression = { (Get-Item -Path $_).Length }
        } -Descending)
        $filesToExecute = @(for ($i = 0; $i -lt $ordered.Count; $i++)
            {
                if (($i % $ShardCount) -eq ($ShardIndex - 1))
                {
                    $ordered[$i]
                }
            })

        Write-Host -Object "Shard $ShardIndex of ${ShardCount}: $($filesToExecute.Count) of $($ordered.Count) test file(s)"
    }

    $Params = [ordered]@{
        Path = $filesToExecute
    }

    $Container = New-PesterContainer @Params

    $Configuration = [PesterConfiguration]@{
        Run    = @{
            Container = $Container
            PassThru  = $true
        }
        Output = @{
            Verbosity = 'Normal'
        }
        Should = @{
            ErrorAction = 'Continue'
        }
    }

    if ([String]::IsNullOrEmpty($TestResultsFile) -eq $false)
    {
        $Configuration.Output.Enabled = $true
        $Configuration.Output.OutputFormat = 'NUnitXml'
        $Configuration.Output.OutputFile = $TestResultsFile
    }

    if ($IgnoreCodeCoverage.IsPresent -eq $false)
    {
        $Configuration.CodeCoverage.Enabled = $true
        $Configuration.CodeCoverage.Path = $testCoverageFiles
        $Configuration.CodeCoverage.OutputPath = $CodeCoverageOutputPath
        $Configuration.CodeCoverage.OutputFormat = 'JaCoCo'
        $Configuration.CodeCoverage.UseBreakpoints = $false
    }

    $results = Invoke-Pester -Configuration $Configuration

    $message = 'Running the tests took {0} hours, {1} minutes, {2} seconds' -f $sw.Elapsed.Hours, $sw.Elapsed.Minutes, $sw.Elapsed.Seconds
    Write-Host -Object $message

    Write-Host -Object 'Completed running all Microsoft365DSC Unit Tests'

    return $results
}

function Get-M365DSCTestCoverageScope
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String[]]
        $ChangedFile
    )

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '../' -Resolve
    $classRoot = Join-Path -Path $repoDir -ChildPath 'Modules/Microsoft365DSC/Classes'
    $testRoot = Join-Path -Path $repoDir -ChildPath 'Tests/Unit/Microsoft365DSC'

    $comparer = [System.StringComparer]::OrdinalIgnoreCase
    $resourceNames = [System.Collections.Generic.HashSet[System.String]]::new($comparer)
    $sharedFiles = [System.Collections.Generic.HashSet[System.String]]::new($comparer)

    foreach ($file in $ChangedFile)
    {
        $normalized = ($file -replace '\\', '/').Trim()
        if ([System.String]::IsNullOrWhiteSpace($normalized))
        {
            continue
        }

        if ($normalized -match '^Modules/Microsoft365DSC/DscResources/MSFT_([^/]+)/')
        {
            $null = $resourceNames.Add($Matches[1])
        }
        elseif ($normalized -match '^Tests/Unit/Microsoft365DSC/Microsoft365DSC\.(.+)\.Tests\.ps1$')
        {
            $null = $resourceNames.Add($Matches[1])
        }
        elseif ($normalized -match '^Modules/Microsoft365DSC/Modules/.+\.psm1$')
        {
            $full = Join-Path -Path $repoDir -ChildPath $normalized
            if (Test-Path -Path $full)
            {
                $null = $sharedFiles.Add((Resolve-Path -Path $full).Path)
            }
        }
        elseif ($normalized -match '^Modules/Microsoft365DSC/DscResources/_Base/')
        {
            $shared = Join-Path -Path $classRoot -ChildPath '_Shared.psm1'
            if (Test-Path -Path $shared)
            {
                $null = $sharedFiles.Add((Resolve-Path -Path $shared).Path)
            }
        }
    }

    $partFiles = [System.Collections.Generic.HashSet[System.String]]::new($comparer)
    $testFiles = [System.Collections.Generic.HashSet[System.String]]::new($comparer)

    if ($resourceNames.Count -gt 0)
    {
        foreach ($part in (Get-ChildItem -Path (Join-Path -Path $classRoot -ChildPath 'Part*.psm1') -ErrorAction SilentlyContinue))
        {
            $registered = @(Select-String -Path $part.FullName -Pattern 'Register\(\[([^\]]+)\]' -AllMatches |
                ForEach-Object -Process { $_.Matches } |
                ForEach-Object -Process { $_.Groups[1].Value })

            if (-not @($registered | Where-Object -FilterScript { $resourceNames.Contains($_) }))
            {
                continue
            }

            $null = $partFiles.Add($part.FullName)
            foreach ($name in $registered)
            {
                $testFile = Join-Path -Path $testRoot -ChildPath "Microsoft365DSC.$name.Tests.ps1"
                if (Test-Path -Path $testFile)
                {
                    $null = $testFiles.Add((Resolve-Path -Path $testFile).Path)
                }
            }
        }
    }

    $fullSuite = $sharedFiles.Count -gt 0

    return @{
        CoveragePath = @($partFiles) + @($sharedFiles)
        TestPath     = if ($fullSuite) { @() } else { @($testFiles) }
        FullSuite    = $fullSuite
    }
}

function Export-M365DSCCoverageData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $TestResult,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $repoDir = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
    $coverage = $TestResult.CodeCoverage

    $commands = foreach ($command in @($coverage.CommandsExecuted) + @($coverage.CommandsMissed))
    {
        if ($null -eq $command)
        {
            continue
        }

        [ordered]@{
            File        = [System.IO.Path]::GetRelativePath($repoDir, $command.File) -replace '\\', '/'
            Class       = $command.Class
            Function    = $command.Function
            StartLine   = $command.StartLine
            EndLine     = $command.EndLine
            StartColumn = $command.StartColumn
            EndColumn   = $command.EndColumn
            HitCount    = [System.Int32] $command.HitCount
        }
    }

    [ordered]@{
        TotalMilliseconds = [System.Int64] $TestResult.Duration.TotalMilliseconds
        Commands          = @($commands)
    } | ConvertTo-Json -Depth 3 -Compress | Set-Content -Path $Path -Encoding utf8
}

function Merge-M365DSCCoverageData
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Path,

        [Parameter()]
        [System.String]
        $OutputPath = 'coverage.xml'
    )

    $repoDir = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
    $resolvedOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    $merged = [System.Collections.Specialized.OrderedDictionary]::new()
    $totalMilliseconds = 0

    foreach ($file in $Path)
    {
        $data = Get-Content -Path $file -Raw | ConvertFrom-Json
        $totalMilliseconds = [System.Math]::Max($totalMilliseconds, $data.TotalMilliseconds)

        foreach ($command in $data.Commands)
        {
            $key = '{0}:{1}:{2}' -f $command.File, $command.StartLine, $command.StartColumn
            if ($merged.Contains($key))
            {
                $merged[$key].Breakpoint.HitCount += $command.HitCount
                continue
            }

            $merged[$key] = [PSCustomObject]@{
                File        = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($repoDir, $command.File))
                Class       = $command.Class
                Function    = $command.Function
                StartLine   = $command.StartLine
                EndLine     = $command.EndLine
                StartColumn = $command.StartColumn
                EndColumn   = $command.EndColumn
                Command     = ''
                Breakpoint  = @{ HitCount = $command.HitCount }
            }
        }
    }

    # Pester builds the JaCoCo report only at the end of a run. Its internal report functions are the
    # only way to turn command hits from several runs into one report.
    $pester = Get-Module -Name Pester | Sort-Object -Property Version -Descending | Select-Object -First 1
    if ($null -eq $pester)
    {
        $pester = Import-Module -Name Pester -MinimumVersion 6.2.0 -PassThru -ErrorAction Stop
    }

    & $pester {
        param ($CommandCoverage, $TotalMilliseconds, $ReportRoot, $OutputPath)

        $report = Get-CoverageReport -CommandCoverage $CommandCoverage
        $xml = Get-JaCoCoReportXml -CommandCoverage $CommandCoverage -CoverageReport $report `
            -TotalMilliseconds $TotalMilliseconds -ReportRoot $ReportRoot
        ([xml] $xml).Save($OutputPath)

        [PSCustomObject]@{
            CoveragePercent       = $report.CoveragePercent
            CommandsAnalyzedCount = $report.NumberOfCommandsAnalyzed
            CommandsExecutedCount = $report.NumberOfCommandsExecuted
        }
    } @($merged.Values) $totalMilliseconds $repoDir $resolvedOutputPath
}

function Get-M365DSCAllGraphPermissionsList
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param()

    $allModules = Get-module Microsoft.graph.* -ListAvailable
    $allPermissions = @()
    foreach ($module in $allModules)
    {
        $cmds = Get-Command -Module $module.Name
        foreach ($cmd in $cmds)
        {
            $graphInfo = Find-MgGraphCommand -Command $cmd.Name -ErrorAction SilentlyContinue
            if ($null -ne $graphInfo)
            {
                $permissions = $graphInfo.Permissions | Where-Object -FilterScript {$_.PermissionType -eq 'Application'}
                $allPermissions += $permissions.Name
            }
        }
    }

    $allPermissions+= @('OrgSettings-Microsoft365Install.Read.All', `
                        'OrgSettings-Forms.Read.All', `
                        'OrgSettings-Todo.Read.All', `
                        'OrgSettings-AppsAndServices.Read.All', `
                        'OrgSettings-DynamicsVoice.Read.All', `
                        'ReportSettings.Read.All', `
                        'RoleManagementPolicy.Read.Directory', `
                        'RoleEligibilitySchedule.Read.Directory', `
                        'Agreement.Read.All', `
                        'Policy.ReadWrite.ConditionalAccess', `
                        'Policy.Read.ConditionalAccess', `
                        'Policy.ReadWrite.AuthenticationMethod', `
                        'SharePointTenantSettings.Read.All', `
                        'AppCatalog.ReadWrite.All', `
                        'TeamSettings.ReadWrite.All', `
                        'Channel.Delete.All', `
                        'ChannelSettings.ReadWrite.All', `
                        'ChannelMember.ReadWrite.All', `
                        'ChannelSettings.Read.All',
                        'EntitlementManagement.Read.All')
    $roles = $allPermissions | Select-Object -Unique | Sort-Object -Descending:$false
    return $roles
}

function Invoke-QualityChecksHarness
{
    [CmdletBinding()]
    param ()

    $sw = [System.Diagnostics.StopWatch]::StartNew()

    Write-Host -Object 'Running all Quality Check Tests'

    $repoDir = Join-Path -Path $PSScriptRoot -ChildPath '../' -Resolve

    # DSC Common Tests
    $getChildItemParameters = @{
        Path   = (Join-Path -Path $repoDir -ChildPath './Tests/QA')
        Filter = '*.Tests.ps1'
    }

    # Get all tests '*.Tests.ps1'.
    $commonTestFiles = Get-ChildItem @getChildItemParameters

    $testsToRun = @()
    $testsToRun += @( $commonTestFiles.FullName )

    $filesToExecute = @()
    foreach ($testToRun in $testsToRun)
    {
        $filesToExecute += $testToRun
    }

    $Params = [ordered]@{
        Path = $filesToExecute
    }

    $Container = New-PesterContainer @Params

    $Configuration = [PesterConfiguration]@{
        Run    = @{
            Container = $Container
            PassThru  = $true
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        Should = @{
            ErrorAction = 'Continue'
        }
    }

    $results = Invoke-Pester -Configuration $Configuration

    $message = 'Running the tests took {0} hours, {1} minutes, {2} seconds' -f $sw.Elapsed.Hours, $sw.Elapsed.Minutes, $sw.Elapsed.Seconds
    Write-Host -Object $message

    Write-Host -Object 'Completed running all Quality Check Tests'

    return $results
}
