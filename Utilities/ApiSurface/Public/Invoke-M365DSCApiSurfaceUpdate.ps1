<#
.SYNOPSIS
    Applies a set of approved drift findings on a branch, tests them, commits and opens the PR.

.DESCRIPTION
    Pester reads the built classes, not the resource sources a run edits. Every finding is applied
    without its unit test, then one rebuild and one test pass cover the whole set. A resource
    whose tests fail is rolled back and the run continues.

.PARAMETER DriftPath
    Specifies api-drift.json.

.PARAMETER FindingId
    Specifies the finding ids to apply.

.PARAMETER FromIssue
    Specifies a file holding the tracking Issue body. Its ticked ids are the approval.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.PARAMETER BaseBranch
    Specifies the branch to start from and target. Defaults to Dev.

.PARAMETER BranchName
    Specifies the branch to create. Defaults to feature/api-drift-<yyyyMMdd>.

.PARAMETER Interactive
    Indicates that each finding is confirmed before it is applied.

.PARAMETER Force
    Indicates that the interactive confirmation is answered yes.

.PARAMETER NoPullRequest
    Indicates that the run stops after the commit and leaves the branch for inspection.

.PARAMETER SkipBuild
    Indicates that the rebuild and the unit tests are skipped. For a caller that has already run
    them, and for tests.

.PARAMETER AllowNonAutomatic
    Indicates that the manual categories are unlocked. Local only, never in CI.

.EXAMPLE
    Invoke-M365DSCApiSurfaceUpdate -FindingId 'RES-ENUM-STALE:AADConditionalAccessPolicy:State'

.EXAMPLE
    Invoke-M365DSCApiSurfaceUpdate -FromIssue ./issue-body.md -NoPullRequest

.OUTPUTS
    An ordered dictionary with the branch, the applied and reverted findings, and the PR result.
#>
function Invoke-M365DSCApiSurfaceUpdate
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter()]
        [System.String]
        $DriftPath,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $FindingId = @(),

        [Parameter()]
        [System.String]
        $FromIssue,

        [Parameter()]
        [System.String]
        $RepositoryRoot = (Join-Path -Path $PSScriptRoot -ChildPath '../../..' -Resolve),

        [Parameter()]
        [System.String]
        $BaseBranch = 'Dev',

        [Parameter()]
        [System.String]
        $BranchName,

        [Parameter()]
        [switch]
        $Interactive,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $NoPullRequest,

        [Parameter()]
        [switch]
        $SkipBuild,

        [Parameter()]
        [switch]
        $AllowNonAutomatic
    )

    if ($AllowNonAutomatic -and -not [System.String]::IsNullOrEmpty($env:GITHUB_ACTIONS))
    {
        throw ('-AllowNonAutomatic is a local-only switch and cannot be used in CI. ' +
            'Run it from a working copy and review the scaffold by hand.')
    }

    if ([System.String]::IsNullOrEmpty($DriftPath))
    {
        $DriftPath = Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/ApiSurface/api-drift.json'
    }

    if (-not (Test-Path -Path $DriftPath))
    {
        throw "'$DriftPath' does not exist. Run Invoke-M365DSCApiSurfaceCheck first."
    }

    $requested = [System.String[]] @($FindingId)
    if (-not [System.String]::IsNullOrEmpty($FromIssue))
    {
        if (-not (Test-Path -Path $FromIssue))
        {
            throw "'$FromIssue' does not exist."
        }

        $requested += [System.String[]] @(Get-DriftIssueTicked -Body ([System.IO.File]::ReadAllText($FromIssue)))
    }

    $requested = [System.String[]] @(Get-M365DSCOrderedName -Value $requested)
    if ($requested.Count -eq 0)
    {
        throw 'No finding was named. Pass -FindingId, or -FromIssue with at least one ticked box.'
    }

    $findings = Select-DriftFinding -DriftPath $DriftPath -Id $requested
    if ($findings.Count -eq 0)
    {
        throw 'None of the named findings is present in the drift report.'
    }

    if ([System.String]::IsNullOrEmpty($BranchName))
    {
        $BranchName = "feature/api-drift-$([System.DateTime]::UtcNow.ToString('yyyyMMdd', [System.Globalization.CultureInfo]::InvariantCulture))"
    }

    $null = Invoke-RepositoryCommand -RepositoryRoot $RepositoryRoot -Argument @('checkout', '-B', $BranchName, $BaseBranch)

    $results = [System.Collections.Generic.List[System.Object]]::new()
    foreach ($finding in $findings)
    {
        if ($Interactive -and -not $Force -and -not $PSCmdlet.ShouldContinue($finding.id, 'Apply this finding?'))
        {
            $results.Add((New-ApplyResult -Finding $finding -Applied $false -Reason 'Declined interactively.'))
            continue
        }

        $results.Add((Update-M365DSCResourceFromDrift -Finding $finding `
                    -RepositoryRoot $RepositoryRoot `
                    -AllowNonAutomatic:$AllowNonAutomatic `
                    -SkipUnitTest `
                    -Confirm:$false))
    }

    if (-not $SkipBuild)
    {
        $null = Test-AppliedResource -RepositoryRoot $RepositoryRoot -Result $results
    }

    $applied = @($results | Where-Object -FilterScript { $_.Applied })
    if ($applied.Count -eq 0)
    {
        return [ordered]@{
            Branch      = $BranchName
            Applied     = @()
            Reverted    = @($results | Where-Object -FilterScript { -not $_.Applied })
            Committed   = $false
            PullRequest = 'Not opened. Nothing was applied.'
        }
    }

    $bodyPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "api-drift-pr-$([System.Guid]::NewGuid().ToString('N')).md"
    [System.IO.File]::WriteAllText($bodyPath, (Format-UpdatePullRequestBody -Result $results), [System.Text.UTF8Encoding]::new($false))

    $committed = $false
    if ($PSCmdlet.ShouldProcess($BranchName, "Commit $($applied.Count) finding(s)"))
    {
        $staged = [System.String[]] @($applied.Path |
                Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty([System.String] $_) } |
                Select-Object -Unique)

        $null = Invoke-RepositoryCommand -RepositoryRoot $RepositoryRoot -Argument (@('add', '--') + $staged)
        $null = Invoke-RepositoryCommand -RepositoryRoot $RepositoryRoot -Argument (@(
                'commit', '-m', "Apply $($applied.Count) API surface drift finding(s)", '--') + $staged)
        $committed = $true
    }

    $pullRequest = 'Not opened. -NoPullRequest was passed.'
    if (-not $NoPullRequest -and $committed -and $PSCmdlet.ShouldProcess($BranchName, 'Open a pull request'))
    {
        $null = Invoke-RepositoryCommand -RepositoryRoot $RepositoryRoot -Argument @(
            'push', '--force-with-lease', '--set-upstream', 'origin', $BranchName)
        $pullRequest = Invoke-GitHubCli -Argument @(
            'pr', 'create',
            '--base', $BaseBranch,
            '--head', $BranchName,
            '--title', "Apply $($applied.Count) API surface drift finding(s)",
            '--body-file', $bodyPath)
    }

    Remove-Item -Path $bodyPath -Force -ErrorAction SilentlyContinue

    return [ordered]@{
        Branch      = $BranchName
        Applied     = $applied
        Reverted    = @($results | Where-Object -FilterScript { -not $_.Applied })
        Committed   = $committed
        PullRequest = $pullRequest
    }
}

<#
.SYNOPSIS
    Picks the named findings out of a drift report, in the report's own order.

.PARAMETER DriftPath
    Specifies api-drift.json.

.PARAMETER Id
    Specifies the finding ids.

.OUTPUTS
    The findings.
#>
function Select-DriftFinding
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DriftPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Id
    )

    $wanted = [System.Collections.Generic.HashSet[System.String]]::new($Id, [System.StringComparer]::Ordinal)
    $findings = @((Get-Content -Path $DriftPath -Raw | ConvertFrom-Json).findings)

    return @($findings | Where-Object -FilterScript { $wanted.Contains([System.String] $_.id) })
}

<#
.SYNOPSIS
    Rebuilds the module and tests every resource a run touched, rolling back the failures.

.DESCRIPTION
    One rebuild and one test pass for the whole set. A test run before the rebuild would pass
    against the code as it was.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.PARAMETER Result
    Specifies the apply results, updated in place when a resource is rolled back.

.OUTPUTS
    The names of the resources that were rolled back.
#>
function Test-AppliedResource
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Result
    )

    $applied = @($Result | Where-Object -FilterScript { $_.Applied })
    if ($applied.Count -eq 0)
    {
        return [System.String[]] @()
    }

    & (Join-Path -Path $RepositoryRoot -ChildPath 'Utilities/Build-Microsoft365DSC.ps1') -SkipSchemaCache | Out-Null

    $rolledBack = [System.Collections.Generic.List[System.String]]::new()

    foreach ($resource in (Get-M365DSCOrderedName -Value ([System.String[]] @($applied.Resource | Select-Object -Unique))))
    {
        $testPath = Join-Path -Path $RepositoryRoot -ChildPath "Tests/Unit/Microsoft365DSC/Microsoft365DSC.$resource.Tests.ps1"
        if (-not (Test-Path -Path $testPath))
        {
            continue
        }

        $pester = Invoke-Pester -Path $testPath -PassThru -Output None
        if ($pester.FailedCount -eq 0)
        {
            continue
        }

        $rolledBack.Add($resource)
        $modulePath = Join-Path -Path $RepositoryRoot -ChildPath "Modules/Microsoft365DSC/DscResources/MSFT_$resource/MSFT_$resource.psm1"
        $null = Invoke-RepositoryCommand -RepositoryRoot $RepositoryRoot -Argument @('checkout', '--', $modulePath)

        foreach ($item in ($Result | Where-Object -FilterScript { $_.Applied -and $_.Resource -eq $resource }))
        {
            $item.Applied = $false
            $item.Reverted = $true
            $item.Reason = "Reverted. $($pester.FailedCount) unit test(s) failed for $resource."
        }
    }

    return [System.String[]] $rolledBack
}

<#
.SYNOPSIS
    Renders the pull request body.

.PARAMETER Result
    Specifies the apply results.

.OUTPUTS
    The body text.
#>
function Format-UpdatePullRequestBody
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Result
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()
    $applied = @($Result | Where-Object -FilterScript { $_.Applied })
    $skipped = @($Result | Where-Object -FilterScript { -not $_.Applied })

    $lines.Add('Applied by the API surface drift tooling from the approved findings.')
    $lines.Add('')
    $lines.Add("## Applied  ($($applied.Count))")
    $lines.Add('')

    if ($applied.Count -eq 0)
    {
        $lines.Add('None.')
    }
    else
    {
        foreach ($item in $applied)
        {
            $lines.Add("- ``$($item.Id)``")
            $lines.Add("      $(@($item.Edit) -join '; ')")
        }
    }

    $lines.Add('')
    $lines.Add("## Attempted and reverted  ($($skipped.Count))")
    $lines.Add('')

    if ($skipped.Count -eq 0)
    {
        $lines.Add('None.')
    }
    else
    {
        foreach ($item in $skipped)
        {
            $lines.Add("- ``$($item.Id)``")
            $lines.Add("      $($item.Reason)")
        }
    }

    return ($lines -join "`n").TrimEnd() + "`n"
}

<#
.SYNOPSIS
    Runs git in the repository.

.PARAMETER RepositoryRoot
    Specifies the root of the Microsoft365DSC repository.

.PARAMETER Argument
    Specifies the git arguments.

.OUTPUTS
    The output of the command.
#>
function Invoke-RepositoryCommand
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Argument
    )

    $output = & git -C $RepositoryRoot @Argument 2>&1
    if ($LASTEXITCODE -ne 0)
    {
        throw "git $($Argument -join ' ') failed with $LASTEXITCODE. $($output -join ' ')"
    }

    return [System.String[]] @($output | ForEach-Object -Process { [System.String] $_ })
}

<#
.SYNOPSIS
    Runs the GitHub CLI.

.PARAMETER Argument
    Specifies the gh arguments.

.OUTPUTS
    The output of the command.
#>
function Invoke-GitHubCli
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Argument
    )

    $output = & gh @Argument 2>&1
    if ($LASTEXITCODE -ne 0)
    {
        throw "gh $($Argument -join ' ') failed with $LASTEXITCODE. $($output -join ' ')"
    }

    return ($output -join "`n")
}
