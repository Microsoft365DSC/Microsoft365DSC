<#
.SYNOPSIS
    Renders a drift result as a Markdown report.

.DESCRIPTION
    Every section states its count even when empty. Nothing carries a timestamp or a run number.
    Unchanged input renders byte identical.

.PARAMETER Result
    Specifies the output of Compare-M365DSCApiSurface.

.PARAMETER Warning
    Specifies a completeness warning, such as a workload that could not be connected.

.OUTPUTS
    The Markdown text.
#>
function Format-DriftMarkdown
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Result,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Warning
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()
    $findings = @($Result.Findings)

    $lines.Add('# API surface drift')
    $lines.Add('')

    if (-not [System.String]::IsNullOrWhiteSpace($Warning))
    {
        $lines.Add("**Incomplete run.** $Warning")
        $lines.Add('')
    }
    $lines.Add("Resource comparison: $($Result.Summary.compared) compared, $($Result.Summary.skipped) skipped.")
    $lines.Add("Undeclared vendor properties across compared resources: $($Result.Backlog).")
    $lines.Add('')

    foreach ($section in (Get-DriftSection))
    {
        $matched = @($findings | Where-Object -FilterScript { $_.code -in $section.Codes })
        $lines.Add("## $($section.Title)  ($($matched.Count))")
        $lines.Add('')

        if ($matched.Count -eq 0)
        {
            $lines.Add('None.')
            $lines.Add('')
            continue
        }

        if ($section.Name -eq 'Versions')
        {
            $lines.AddRange([System.String[]] @(Format-VersionSection -Finding $matched))
            continue
        }

        if ($section.GroupByResource)
        {
            $lines.AddRange([System.String[]] @(Format-ResourceGroupedSection -Finding $matched))
            continue
        }

        foreach ($finding in $matched)
        {
            $lines.Add("- ``$($finding.id)``")
            $lines.Add("      $(Get-FindingEvidenceLine -Finding $finding)")
        }

        $lines.Add('')
    }

    $lines.Add('## Coverage')
    $lines.Add('')

    $skipped = @($Result.Coverage | Where-Object -FilterScript { -not $_.compared })
    $byReason = @{}
    foreach ($row in $skipped)
    {
        $reason = [System.String] $row.reason
        $byReason[$reason] = 1 + $byReason[$reason]
    }

    foreach ($reason in (Get-M365DSCOrderedName -Value ([System.String[]] @($byReason.Keys))))
    {
        $lines.Add("- $($byReason[$reason]) resources skipped: $reason")
    }

    $lines.Add('')

    $backlog = @($Result.Coverage | Where-Object -FilterScript { $_.compared -and $_.backlog -gt 0 } |
            Sort-Object -Property @{ Expression = { $_.backlog }; Descending = $true }, @{ Expression = { $_.resource }; Ascending = $true })

    if ($backlog.Count -gt 0)
    {
        $lines.Add('Largest gaps between declared and offered properties:')
        $lines.Add('')
        foreach ($row in ($backlog | Select-Object -First 20))
        {
            $lines.Add("- $($row.resource): $($row.declared) of $($row.vendorTop) vendor properties declared")
        }
        $lines.Add('')
    }

    return ($lines -join "`n").TrimEnd() + "`n"
}

<#
.SYNOPSIS
    Renders a section as one subheading per resource, largest first.

.DESCRIPTION
    A section holding hundreds of entries reads as a wall unless the resource that owns each one
    is the heading above it.

.PARAMETER Finding
    Specifies the findings of one section.

.OUTPUTS
    The Markdown lines.
#>
function Format-ResourceGroupedSection
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Finding = @()
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()

    $byResource = @{}
    foreach ($item in $Finding)
    {
        $name = [System.String] $item.resource
        if (-not $byResource.ContainsKey($name))
        {
            $byResource[$name] = [System.Collections.Generic.List[System.Object]]::new()
        }

        $byResource[$name].Add($item)
    }

    $ordered = @(Get-M365DSCOrderedName -Value ([System.String[]] @($byResource.Keys)) |
            Sort-Object -Property @{ Expression = { $byResource[$_].Count }; Descending = $true })

    foreach ($name in $ordered)
    {
        $lines.Add("### $name  ($($byResource[$name].Count))")
        $lines.Add('')
        foreach ($item in $byResource[$name])
        {
            $lines.Add("- ``$($item.property)`` $(Get-FindingEvidenceLine -Finding $item)")
        }

        $lines.Add('')
    }

    return [System.String[]] $lines
}

<#
.SYNOPSIS
    Renders the dependency section grouped by the size of the version jump.

.PARAMETER Finding
    Specifies the VND-NEWER-VERSION findings.

.PARAMETER Limit
    Specifies how many entries to list across all groups. Each heading states its true count.

.OUTPUTS
    The Markdown lines.
#>
function Format-VersionSection
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
    $remaining = [System.Math]::Max($Limit, 0)
    $total = 0

    foreach ($jump in @('Major', 'Minor', 'Patch'))
    {
        $matched = @($Finding | Where-Object -FilterScript { $_.to.jump -eq $jump })
        if ($matched.Count -eq 0)
        {
            continue
        }

        $total += $matched.Count
        $lines.Add("$jump ($($matched.Count))")
        foreach ($item in ($matched | Select-Object -First $remaining))
        {
            $lines.Add("- ``$($item.id)``")
            $lines.Add("      $($item.from.version) -> $($item.to.version)")
        }

        $remaining = [System.Math]::Max($remaining - $matched.Count, 0)
        $lines.Add('')
    }

    foreach ($line in (Get-TruncationLine -Total $total -Limit $Limit))
    {
        $lines.Insert($lines.Count - 1, $line)
    }

    return [System.String[]] $lines
}

<#
.SYNOPSIS
    Returns the report sections and the finding codes each one holds.

.DESCRIPTION
    Order is by how urgently a maintainer has to act. The auto-fixable section comes first and is
    the approval interface Get-DriftIssueTicked reads back. Name is the stable key a renderer
    selects on, Title is display text.

.PARAMETER Since
    Specifies the dependency move the vendor findings are measured from. Empty names the baseline.

.OUTPUTS
    Objects with Name, Title and Codes.
#>
function Get-DriftSection
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Since
    )

    $vendorTitle = 'Vendor changes'
    if ($PSBoundParameters.ContainsKey('Since'))
    {
        $anchor = $Since
        if ([System.String]::IsNullOrWhiteSpace($anchor))
        {
            $anchor = 'the baseline snapshot'
        }

        $vendorTitle = "Vendor changes since $anchor"
    }

    return @(
        [PSCustomObject]@{ Name = 'AutoFixable'; Title = 'Auto-fixable'; Codes = @('RES-ENUM-STALE', 'VND-ENUM-MEMBER-ADDED', 'RES-PROP-MISSING') }
        [PSCustomObject]@{ Name = 'Shim'; Title = 'Graph shim, regenerate to fix'; Codes = @('SHIM-MISSING', 'SHIM-STALE') }
        [PSCustomObject]@{ Name = 'Decision'; Title = 'Needs a decision'; Codes = @('VND-CMDLET-REMOVED', 'VND-CMDLET-REROUTED', 'VND-PARAM-TYPECHANGED', 'RES-PROP-ORPHANED', 'RES-TYPE-MISMATCH') }
        [PSCustomObject]@{ Name = 'SettingsCatalog'; Title = 'Intune settings catalog, regenerate to fix'; Codes = @('CAT-SETTING-ADDED', 'CAT-SETTING-REMOVED', 'CAT-OPTION-ADDED', 'CAT-TEMPLATE-VERSION', 'CAT-TEMPLATE-NEW') }
        [PSCustomObject]@{ Name = 'ReadOnly'; Title = 'Read-only, suggested for no implementation'; Codes = @('RES-PROP-READONLY'); GroupByResource = $true }
        [PSCustomObject]@{ Name = 'Backlog'; Title = 'Writable vendor properties no resource declares'; Codes = @('RES-PROP-BACKLOG'); GroupByResource = $true }
        [PSCustomObject]@{ Name = 'Nested'; Title = 'Members of a container the resource already flattens'; Codes = @('RES-PROP-NESTED'); GroupByResource = $true }
        [PSCustomObject]@{ Name = 'Coverage'; Title = 'Graph nouns with full CRUD and no resource'; Codes = @('COV-NO-RESOURCE') }
        [PSCustomObject]@{ Name = 'Subtype'; Title = 'OData subtypes of a modelled entity with no resource'; Codes = @('COV-NO-SUBTYPE') }
        [PSCustomObject]@{ Name = 'UnusedCmdlet'; Title = 'Cmdlets no resource calls any more'; Codes = @('COV-CMDLET-UNUSED') }
        [PSCustomObject]@{ Name = 'VendorChanges'; Title = $vendorTitle; Codes = @('VND-TYPE-PROP-ADDED', 'VND-PARAM-ADDED') }
        [PSCustomObject]@{ Name = 'Versions'; Title = 'Newer dependency versions available'; Codes = @('VND-NEWER-VERSION') }
    )
}

<#
.SYNOPSIS
    Renders the one evidence line that sits under a finding id.

.PARAMETER Finding
    Specifies the finding.

.OUTPUTS
    The evidence text.
#>
function Get-FindingEvidenceLine
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Finding
    )

    $source = [System.String] $Finding.evidence.source
    if ([System.String]::IsNullOrEmpty($source))
    {
        $source = [System.String] $Finding.code
    }

    switch ([System.String] $Finding.code)
    {
        'VND-CMDLET-REMOVED'
        {
            $callers = @($Finding.evidence.calledBy)
            return "$source, called by $($callers.Count) resource(s): $((Get-M365DSCOrderedName -Value ([System.String[]] $callers)) -join ', ')"
        }
        'COV-CMDLET-UNUSED'
        {
            return "$source, no resource calls it any more, tracked from $([System.String] $Finding.evidence.fromModule)"
        }
        'SHIM-MISSING'
        {
            $callers = @($Finding.evidence.calledBy)
            return "not exported by the shim, called by $($callers.Count) resource(s): $((Get-M365DSCOrderedName -Value ([System.String[]] $callers)) -join ', ')"
        }
        'SHIM-STALE'
        {
            if (([System.String] $Finding.evidence.reason) -eq 'parameters')
            {
                return "$source, the SDK declares parameter(s) the wrapper does not: $(@($Finding.to.added) -join ', ')"
            }

            return "$source, wrapper has $($Finding.from.method) $($Finding.from.uri), the SDK has $(@($Finding.to.variants) -join '; ')"
        }
        'RES-ENUM-STALE'
        {
            return "$source, missing member(s): $(@($Finding.to.added) -join ', ')"
        }
        'VND-ENUM-MEMBER-ADDED'
        {
            return "$source, new member(s): $(@($Finding.to.added) -join ', ')"
        }
        'RES-TYPE-MISMATCH'
        {
            return "$source, declared $($Finding.from.typeConstraint), vendor $($Finding.to.vendorType)"
        }
        'RES-PROP-ORPHANED'
        {
            return "$source, declared $($Finding.from.typeConstraint), not offered by the vendor type"
        }
        'RES-PROP-BACKLOG'
        {
            return "$source, $(Get-VendorShapeLine -To $Finding.to)"
        }
        'RES-PROP-NESTED'
        {
            return "$source, $(Get-VendorShapeLine -To $Finding.to), sibling of a flattened member"
        }
        'RES-PROP-READONLY'
        {
            return "$source, $(Get-VendorShapeLine -To $Finding.to)"
        }
        'RES-PROP-MISSING'
        {
            return "$source, $(Get-VendorShapeLine -To $Finding.to)"
        }
        'VND-PARAM-TYPECHANGED'
        {
            return "$source, $($Finding.from.type) -> $($Finding.to.type)"
        }
        'VND-CMDLET-REROUTED'
        {
            return "$source, $($Finding.from.method) $($Finding.from.uri) is gone"
        }
    }

    return $source
}

<#
.SYNOPSIS
    Describes the vendor shape a property finding carries.

.PARAMETER To
    Specifies the To payload of the finding.

.OUTPUTS
    The description.
#>
function Get-VendorShapeLine
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $To
    )

    if ($null -eq $To)
    {
        return 'shape unknown'
    }

    $shape = [System.String] $To.vendorType
    if ([System.Boolean] $To.isArray)
    {
        $shape = "collection of $shape"
    }

    if ([System.Boolean] $To.isComplex)
    {
        $shape = "$shape, complex"
    }

    $members = @($To.enum | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
    if ($members.Count -gt 0)
    {
        $shape = "$shape, member(s) $($members -join ', ')"
    }

    return $shape
}
