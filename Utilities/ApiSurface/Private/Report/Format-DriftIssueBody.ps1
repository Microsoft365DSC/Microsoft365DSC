<#
.SYNOPSIS
    Renders a drift result as the body of the weekly tracking Issue.

.DESCRIPTION
    The first section is the approval interface. Each auto-fixable finding is a task list item
    carrying its id in backticks, one per line, and Get-DriftIssueTicked reads exactly those back.
    Nothing carries a timestamp or a run number. Unchanged input renders byte identical.

.PARAMETER Result
    Specifies the output of Compare-M365DSCApiSurface.

.PARAMETER Ticked
    Specifies the finding ids a maintainer already ticked, carried over from the current body.

.PARAMETER Since
    Specifies the dependency move the vendor findings are measured from, for example
    'Microsoft.Graph.Authentication 2.34.0 -> 2.35.1'.

.PARAMETER MaximumLength
    Specifies the character budget. Defaults to the 65536 GitHub allows an Issue body.

.PARAMETER Warning
    Specifies a completeness warning, such as a workload that could not be connected.

.OUTPUTS
    The Issue body text.
#>
function Format-DriftIssueBody
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Result,

        [Parameter()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $Ticked = @(),

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Since,

        [Parameter()]
        [System.Int32]
        $MaximumLength = 65536,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Warning
    )

    $body = New-DriftIssueBody -Result $Result -Ticked $Ticked -Since $Since -Warning $Warning
    if ((Measure-DriftIssueBodyLength -Body $body) -le $MaximumLength)
    {
        return $body
    }

    $itemCount = @($Result.Findings).Count
    $collapsedLimit = Get-FittingItemLimit -Result $Result `
        -Ticked $Ticked `
        -Since $Since `
        -MaximumLength $MaximumLength `
        -UpperBound $itemCount `
        -Warning $Warning

    if ($collapsedLimit -ge 0)
    {
        return New-DriftIssueBody -Result $Result -Ticked $Ticked -Since $Since -Warning $Warning -CollapsedLimit $collapsedLimit
    }

    $approvalLimit = Get-FittingItemLimit -Result $Result `
        -Ticked $Ticked `
        -Since $Since `
        -MaximumLength $MaximumLength `
        -UpperBound $itemCount `
        -Warning $Warning `
        -VaryApprovalList

    return New-DriftIssueBody -Result $Result `
        -Ticked $Ticked `
        -Since $Since `
        -Warning $Warning `
        -AutoFixableLimit ([System.Math]::Max($approvalLimit, 0)) `
        -CollapsedLimit 0
}

<#
.SYNOPSIS
    Renders the Issue body with a cap on how many entries each section lists.

.PARAMETER Result
    Specifies the output of Compare-M365DSCApiSurface.

.PARAMETER Ticked
    Specifies the finding ids a maintainer already ticked.

.PARAMETER Since
    Specifies the dependency move the vendor findings are measured from.

.PARAMETER AutoFixableLimit
    Specifies how many approval entries the first section lists.

.PARAMETER CollapsedLimit
    Specifies how many entries each section inside the details block lists.

.PARAMETER Warning
    Specifies a completeness warning, rendered above the approval list.

.OUTPUTS
    The Issue body text.
#>
function New-DriftIssueBody
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Result,

        [Parameter()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $Ticked = @(),

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Since,

        [Parameter()]
        [System.Int32]
        $AutoFixableLimit = [System.Int32]::MaxValue,

        [Parameter()]
        [System.Int32]
        $CollapsedLimit = [System.Int32]::MaxValue,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Warning
    )

    $tickedSet = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Ticked | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }),
        [System.StringComparer]::Ordinal)

    $findings = @($Result.Findings)
    $lines = [System.Collections.Generic.List[System.String]]::new()

    if (-not [System.String]::IsNullOrWhiteSpace($Warning))
    {
        $lines.Add("> **Incomplete run.** $Warning")
        $lines.Add('')
    }

    $section = @{}
    foreach ($entry in (Get-DriftSection -Since $Since))
    {
        $section[$entry.Name] = $entry
    }

    $autoFixable = @($findings | Where-Object -FilterScript {
            $_.code -in $section['AutoFixable'].Codes -and $_.autoFixable
        })

    $manual = @($findings | Where-Object -FilterScript {
            $_.code -in $section['AutoFixable'].Codes -and -not $_.autoFixable
        })

    $lines.Add("## $($section['AutoFixable'].Title)  (tick, then comment /apply-drift)  ($($autoFixable.Count))")
    $lines.Add('')

    if ($autoFixable.Count -eq 0)
    {
        $lines.Add('None.')
    }
    else
    {
        foreach ($finding in ($autoFixable | Select-Object -First ([System.Math]::Max($AutoFixableLimit, 0))))
        {
            $box = '- [ ]'
            if ($tickedSet.Contains([System.String] $finding.id))
            {
                $box = '- [x]'
            }

            $lines.Add("$box ``$($finding.id)``")
            $lines.Add("      $(Get-FindingEvidenceLine -Finding $finding)")
        }

        $lines.AddRange([System.String[]] @(Get-TruncationLine -Total $autoFixable.Count -Limit $AutoFixableLimit))
    }

    $lines.Add('')
    $lines.Add('<details>')
    $lines.Add('<summary>Everything that is not auto-fixable</summary>')
    $lines.Add('')

    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['Decision'] -Finding $findings -Limit $CollapsedLimit -Extra $manual))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['Shim'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['SettingsCatalog'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['ReadOnly'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-CoverageGapSection -Result $Result))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['Coverage'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['UnusedCmdlet'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['VendorChanges'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-DriftIssueSection -Section $section['Versions'] -Finding $findings -Limit $CollapsedLimit))
    $lines.AddRange([System.String[]] @(Format-BreakingSection -Finding $findings -Limit $CollapsedLimit))

    $lines.Add('</details>')

    return ($lines -join "`n").TrimEnd() + "`n"
}

<#
.SYNOPSIS
    Measures a body the way GitHub counts it.

.DESCRIPTION
    The renderer joins with a line feed and the API stores a carriage return line feed, which adds
    one character per line. Measuring the raw string understates a long body by hundreds.

.PARAMETER Body
    Specifies the Issue body.

.OUTPUTS
    The character count.
#>
function Measure-DriftIssueBodyLength
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Body
    )

    return (($Body -replace "`r`n", "`n") -replace "`n", "`r`n").Length
}

<#
.SYNOPSIS
    Finds the largest per-section entry limit whose render still fits the budget.

.DESCRIPTION
    A smaller limit never renders a longer body.

.PARAMETER Result
    Specifies the output of Compare-M365DSCApiSurface.

.PARAMETER Ticked
    Specifies the finding ids a maintainer already ticked.

.PARAMETER Since
    Specifies the dependency move the vendor findings are measured from.

.PARAMETER MaximumLength
    Specifies the character budget.

.PARAMETER UpperBound
    Specifies the largest limit worth trying.

.PARAMETER Warning
    Specifies a completeness warning, passed through to every trial render.

.PARAMETER VaryApprovalList
    Indicates that the limit applies to the approval list, with the collapsed sections emptied.

.OUTPUTS
    The limit, or -1.
#>
function Get-FittingItemLimit
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Result,

        [Parameter()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [System.String[]]
        $Ticked = @(),

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Since,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $MaximumLength,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $UpperBound,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Warning,

        [Parameter()]
        [switch]
        $VaryApprovalList
    )

    $low = 0
    $high = [System.Math]::Max($UpperBound, 0)
    $best = -1

    while ($low -le $high)
    {
        $middle = $low + [System.Math]::Floor(($high - $low) / 2)

        if ($VaryApprovalList)
        {
            $body = New-DriftIssueBody -Result $Result -Ticked $Ticked -Since $Since -Warning $Warning -AutoFixableLimit $middle -CollapsedLimit 0
        }
        else
        {
            $body = New-DriftIssueBody -Result $Result -Ticked $Ticked -Since $Since -Warning $Warning -CollapsedLimit $middle
        }

        if ((Measure-DriftIssueBodyLength -Body $body) -le $MaximumLength)
        {
            $best = $middle
            $low = $middle + 1
        }
        else
        {
            $high = $middle - 1
        }
    }

    return $best
}

<#
.SYNOPSIS
    Names the entries a section could not list.

.DESCRIPTION
    A cap that says nothing reads as a complete list.

.PARAMETER Total
    Specifies how many entries the section holds.

.PARAMETER Limit
    Specifies how many it listed.

.OUTPUTS
    The line, or nothing.
#>
function Get-TruncationLine
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Total,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Limit
    )

    $dropped = $Total - [System.Math]::Max($Limit, 0)
    if ($dropped -le 0)
    {
        return [System.String[]] @()
    }

    return [System.String[]] @("- ... and $dropped more, listed in full in the api-drift artifact.")
}

<#
.SYNOPSIS
    Renders one code-driven section of the Issue body.

.PARAMETER Section
    Specifies the section from Get-DriftSection.

.PARAMETER Finding
    Specifies every finding in the result.

.PARAMETER Limit
    Specifies how many entries to list. The heading always states the true count.

.PARAMETER Extra
    Specifies findings to list here whose code belongs to another section.

.OUTPUTS
    The section lines.
#>
function Format-DriftIssueSection
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Section,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Finding = @(),

        [Parameter()]
        [System.Int32]
        $Limit = [System.Int32]::MaxValue,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Extra = @()
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()
    $matched = @(@($Finding | Where-Object -FilterScript { $_.code -in $Section.Codes }) + @($Extra))

    $lines.Add("## $($Section.Title)  ($($matched.Count))")
    $lines.Add('')

    if ($matched.Count -eq 0)
    {
        $lines.Add('None.')
        $lines.Add('')
        return [System.String[]] $lines
    }

    if ($Section.Name -eq 'Versions')
    {
        $lines.AddRange([System.String[]] @(Format-VersionSection -Finding $matched -Limit $Limit))
        return [System.String[]] $lines
    }

    foreach ($item in ($matched | Select-Object -First ([System.Math]::Max($Limit, 0))))
    {
        $lines.Add("- ``$($item.id)``")
        $lines.Add("      $(Get-FindingEvidenceLine -Finding $item)")
    }

    $lines.AddRange([System.String[]] @(Get-TruncationLine -Total $matched.Count -Limit $Limit))
    $lines.Add('')
    return [System.String[]] $lines
}

<#
.SYNOPSIS
    Renders the coverage gap section of the Issue body.

.DESCRIPTION
    The heading counts the resources the comparison had to skip. The line under it repeats the
    compared and skipped totals and the backlog of vendor properties no resource declares.

.PARAMETER Result
    Specifies the output of Compare-M365DSCApiSurface.

.OUTPUTS
    The section lines.
#>
function Format-CoverageGapSection
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Result
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()
    $skipped = @($Result.Coverage | Where-Object -FilterScript { -not $_.compared })

    $lines.Add("## Coverage gaps  ($($skipped.Count))")
    $lines.Add('')
    $lines.Add("Resources: $($Result.Summary.compared) compared, $($Result.Summary.skipped) skipped. Undeclared vendor properties: $($Result.Backlog).")
    $lines.Add('')

    return [System.String[]] $lines
}

<#
.SYNOPSIS
    Renders the breaking findings nobody has accepted yet.

.DESCRIPTION
    The heading names the oldest first seen date rather than an age. An age in days changes on
    every weekly run and would rewrite the Issue when nothing upstream moved.

.PARAMETER Finding
    Specifies every finding in the result.

.PARAMETER Limit
    Specifies how many entries to list. The heading always states the true count.

.OUTPUTS
    The section lines.
#>
function Format-BreakingSection
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Finding = @(),

        [Parameter()]
        [System.Int32]
        $Limit = [System.Int32]::MaxValue
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()
    $matched = @($Finding | Where-Object -FilterScript { $_.severity -eq 'breaking' })

    if ($matched.Count -eq 0)
    {
        $lines.Add('## Unaccepted breaking findings  (0)')
        $lines.Add('')
        $lines.Add('None.')
        $lines.Add('')
        return [System.String[]] $lines
    }

    $seen = [System.String[]] @($matched | ForEach-Object -Process { [System.String] $_.firstSeen } |
            Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
    $oldest = @(Get-M365DSCOrderedName -Value $seen)[0]

    $lines.Add("## Unaccepted breaking findings, oldest $oldest  ($($matched.Count))")
    $lines.Add('')

    foreach ($item in ($matched | Select-Object -First ([System.Math]::Max($Limit, 0))))
    {
        $lines.Add("- ``$($item.id)``  first seen $($item.firstSeen)")
    }

    $lines.AddRange([System.String[]] @(Get-TruncationLine -Total $matched.Count -Limit $Limit))
    $lines.Add('')
    return [System.String[]] $lines
}

<#
.SYNOPSIS
    Names the dependency move the vendor findings are measured from.

.DESCRIPTION
    Anchors on Microsoft.Graph.Authentication, which carries the SDK metadata every Graph
    resource depends on, and falls back to the first other pin that moved.

.PARAMETER Baseline
    Specifies the committed snapshot.

.PARAMETER Current
    Specifies the snapshot taken by this run.

.OUTPUTS
    A '<module> <old> -> <new>' string, or an empty string when no pin moved.
#>
function Get-DriftVendorSince
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Baseline,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Current
    )

    $baselineName = @(Get-SurfaceMemberName -Container $Baseline.dependencies)
    $moved = [System.Collections.Generic.List[System.String]]::new()

    foreach ($name in (Get-M365DSCOrderedName -Value ([System.String[]] $baselineName)))
    {
        $old = [System.String] (Get-SurfaceMember -Container $Baseline.dependencies -Name $name).pinned
        $new = [System.String] (Get-SurfaceMember -Container $Current.dependencies -Name $name).pinned

        if (-not [System.String]::IsNullOrEmpty($new) -and $old -cne $new)
        {
            $moved.Add("$name $old -> $new")
        }
    }

    if ($moved.Count -eq 0)
    {
        return ''
    }

    $anchor = @($moved | Where-Object -FilterScript { $_ -like 'Microsoft.Graph.Authentication *' })
    if ($anchor.Count -gt 0)
    {
        return $anchor[0]
    }

    return $moved[0]
}

<#
.SYNOPSIS
    Reads the ticked finding ids back out of an Issue body.

.DESCRIPTION
    The inverse of the task list Format-DriftIssueBody writes. A body and its parse have to round
    trip. Without that, the next rewrite drops a maintainer's approval.

.PARAMETER Body
    Specifies the Issue body.

.OUTPUTS
    The ticked finding ids.
#>
function Get-DriftIssueTicked
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [AllowNull()]
        [System.String]
        $Body
    )

    if ([System.String]::IsNullOrEmpty($Body))
    {
        return [System.String[]] @()
    }

    $ticked = [System.Collections.Generic.List[System.String]]::new()

    foreach ($line in ($Body -split "`r?`n"))
    {
        if ($line -match '^\s*-\s\[[xX]\]\s+`([^`]+)`\s*$')
        {
            $ticked.Add($Matches[1])
        }
    }

    return [System.String[]] $ticked
}
