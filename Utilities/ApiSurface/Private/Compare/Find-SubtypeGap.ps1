<#
.SYNOPSIS
    Ranks the concrete OData subtypes that no resource models.

.PARAMETER Subtype
    Specifies the rows from Get-ODataSubtypeSurface.

.PARAMETER Ignore
    Specifies the parsed coverage-ignore.json.

.PARAMETER BaselineSubtype
    Specifies the subtype names the committed coverage file holds.

.OUTPUTS
    The candidates, ranked.
#>
function Find-SubtypeGap
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Subtype = @(),

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Ignore,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $BaselineSubtype = @()
    )

    $ignored = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Ignore.odataSubtypes | ForEach-Object -Process { [System.String] $_.odataSubtype }),
        [System.StringComparer]::OrdinalIgnoreCase)

    $baseline = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] $BaselineSubtype, [System.StringComparer]::OrdinalIgnoreCase)

    $coveredEntity = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($row in $Subtype)
    {
        if ($row.covered)
        {
            $null = $coveredEntity.Add([System.String] $row.entityType)
        }
    }

    $candidates = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($row in $Subtype)
    {
        if ($row.covered -or $row.isAbstract -or $ignored.Contains([System.String] $row.subtype))
        {
            continue
        }

        $candidates.Add((New-SubtypeCandidate -Row $row `
                    -HasCoveredSibling $coveredEntity.Contains([System.String] $row.entityType) `
                    -IsNew (-not $baseline.Contains([System.String] $row.subtype))))
    }

    return [System.Object[]] @($candidates |
            Sort-Object -Property @{ Expression = { $_.score }; Descending = $true }, @{ Expression = { $_.subtype }; Ascending = $true })
}

<#
.SYNOPSIS
    Scores one subtype candidate and records every component that fired.

.PARAMETER Row
    Specifies the subtype row.

.PARAMETER HasCoveredSibling
    Indicates that a resource models another subtype of the same entity type.

.PARAMETER IsNew
    Indicates that the baseline does not carry this subtype.

.OUTPUTS
    The candidate.
#>
function New-SubtypeCandidate
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Row,

        [Parameter()]
        [System.Boolean]
        $HasCoveredSibling = $false,

        [Parameter()]
        [System.Boolean]
        $IsNew = $false
    )

    $reasons = [System.Collections.Generic.List[System.String]]::new()
    $score = 0

    if ($IsNew)
    {
        $score += 50
        $reasons.Add('new since the baseline +50')
    }

    if ($HasCoveredSibling)
    {
        $score += 20
        $reasons.Add('the entity type already has a resource +20')
    }

    # A documented retirement belongs in coverage-ignore.json, this is the name guess.
    if ($Row.subtype -match '^(windowsPhone81|windows81|windows10Mobile|windows10X)')
    {
        $score -= 30
        $reasons.Add('platform is retired -30')
    }

    if ($Row.subtype -match '(Status|State|StateSummary|Summary|Overview)$')
    {
        $score -= 30
        $reasons.Add('type reads as telemetry -30')
    }

    return [ordered]@{
        subtype    = [System.String] $Row.subtype
        entityType = [System.String] $Row.entityType
        apiVersion = [System.String] $Row.apiVersion
        score      = $score
        reasons    = @($reasons)
    }
}

<#
.SYNOPSIS
    Turns the subtype candidates the baseline does not carry into COV-NO-SUBTYPE findings.

.PARAMETER Candidate
    Specifies the ranked candidates.

.PARAMETER BaselineSubtype
    Specifies the subtype names the committed coverage file holds.

.OUTPUTS
    The findings.
#>
function Compare-Subtype
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Candidate = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $BaselineSubtype = @()
    )

    if ($Candidate.Count -eq 0 -or $BaselineSubtype.Count -eq 0)
    {
        return [System.Object[]] @()
    }

    $baseline = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] $BaselineSubtype, [System.StringComparer]::OrdinalIgnoreCase)

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($item in $Candidate)
    {
        if ($baseline.Contains([System.String] $item.subtype))
        {
            continue
        }

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'COV-NO-SUBTYPE' `
                    -Subject ([System.String] $item.subtype) `
                    -To ([ordered]@{ entityType = $item.entityType; apiVersion = $item.apiVersion; score = $item.score }) `
                    -Evidence ([ordered]@{ source = "graph:$($item.apiVersion)/$($item.entityType)"; reasons = @($item.reasons) })))
    }

    return [System.Object[]] $findings
}
