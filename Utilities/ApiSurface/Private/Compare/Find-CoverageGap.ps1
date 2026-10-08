<#
.SYNOPSIS
    Ranks the Graph cmdlet nouns that offer full CRUD and that no resource covers.

.DESCRIPTION
    A filter removes a candidate only on a claim by name or a written ignore entry. Everything
    else is a weight.

.PARAMETER Inventory
    Specifies the noun map from Get-GraphCommandInventory.

.PARAMETER Claim
    Specifies the claim set from Get-CoverageClaimSet.

.PARAMETER Ignore
    Specifies the parsed coverage-ignore.json.

.PARAMETER BaselineNoun
    Specifies the candidate nouns the committed coverage file holds.

.OUTPUTS
    The candidates, ranked.
#>
function Find-CoverageGap
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Inventory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Claim,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Ignore,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $BaselineNoun = @()
    )

    $ignoredModule = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($Ignore.modules | ForEach-Object -Process { [System.String] $_.module }),
        [System.StringComparer]::OrdinalIgnoreCase)

    $ignoredRoot = @($Ignore.uriRoots | ForEach-Object -Process { [System.String] $_.uriRoot })
    $baseline = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] $BaselineNoun, [System.StringComparer]::OrdinalIgnoreCase)

    $candidates = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($noun in (Get-M365DSCOrderedName -Value ([System.String[]] @($Inventory.Keys))))
    {
        $entry = $Inventory[$noun]

        if (-not (Test-FullCrudNoun -Verb $entry.Verbs))
        {
            continue
        }

        if ($Claim.Noun.Contains($noun))
        {
            continue
        }

        $uri = Get-CandidateUri -Uri $entry.Uris
        if (Test-IgnoredCandidate -Modules $entry.Modules -Uri $uri -IgnoredModule $ignoredModule -IgnoredRoot $ignoredRoot)
        {
            continue
        }

        $candidates.Add((New-CoverageCandidate -Noun $noun `
                    -Entry $entry `
                    -Uri $uri `
                    -Claim $Claim `
                    -Inventory $Inventory `
                    -IsNew (-not $baseline.Contains($noun))))
    }

    return [System.Object[]] @($candidates |
            Sort-Object -Property @{ Expression = { $_.score }; Descending = $true }, @{ Expression = { $_.noun }; Ascending = $true })
}

<#
.SYNOPSIS
    Picks the route that best represents a noun.

.DESCRIPTION
    A route without its trailing placeholder is the collection a resource would be generated
    against.

.PARAMETER Uri
    Specifies the routes the noun carries.

.OUTPUTS
    The route.
#>
function Get-CandidateUri
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Uri
    )

    $routes = @([System.String[]] @($Uri) | ForEach-Object -Process { ($_ -replace '/\{[^}]*\}$', '').TrimEnd('/') } |
            Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })

    if ($routes.Count -eq 0)
    {
        return ''
    }

    return @($routes | Sort-Object -Property @{ Expression = { $_.Length } }, @{ Expression = { $_ } })[0]
}

<#
.SYNOPSIS
    Tells whether a human decided this candidate is out of scope.

.PARAMETER Modules
    Specifies the SDK modules the noun belongs to.

.PARAMETER Uri
    Specifies the candidate route.

.PARAMETER IgnoredModule
    Specifies the ignored module names.

.PARAMETER IgnoredRoot
    Specifies the ignored route prefixes.

.OUTPUTS
    True when the candidate is ignored.
#>
function Test-IgnoredCandidate
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Modules,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $IgnoredModule,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $IgnoredRoot = @()
    )

    foreach ($module in @($Modules))
    {
        if ($IgnoredModule.Contains([System.String] $module))
        {
            return $true
        }
    }

    foreach ($root in $IgnoredRoot)
    {
        if (-not [System.String]::IsNullOrEmpty($root) -and $Uri.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase))
        {
            return $true
        }
    }

    return $false
}

<#
.SYNOPSIS
    Scores one candidate and records why.

.DESCRIPTION
    Every component that fired is named on the candidate. A maintainer can audit a high rank
    rather than trust it.

.PARAMETER Noun
    Specifies the cmdlet noun.

.PARAMETER Entry
    Specifies its inventory entry.

.PARAMETER Uri
    Specifies the candidate route.

.PARAMETER Claim
    Specifies the claim set.

.PARAMETER Inventory
    Specifies the whole noun map.

.PARAMETER IsNew
    Indicates that the baseline does not carry this noun.

.OUTPUTS
    The candidate.
#>
function New-CoverageCandidate
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Noun,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Entry,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Claim,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Inventory,

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

    if (@($Entry.Modules | Where-Object -FilterScript { Test-ClaimedModule -Module $_ -Claim $Claim }).Count -gt 0)
    {
        $score += 20
        $reasons.Add('module already used +20')
    }

    if (Test-ClaimedSibling -Uri $Uri -Claim $Claim)
    {
        $score += 15
        $reasons.Add('sibling under the same route claimed +15')
    }

    if ($Inventory.Contains("$($Noun)Count"))
    {
        $score += 5
        $reasons.Add('has a Count companion +5')
    }

    if (@($Entry.ApiVersions) -contains 'v1.0')
    {
        $score += 5
        $reasons.Add('v1.0 as well as beta +5')
    }

    if (@($Entry.OutputTypes | Where-Object -FilterScript { $Claim.OutputType.Contains([System.String] $_) }).Count -gt 0)
    {
        $score -= 25
        $reasons.Add('shares an output type with a claimed cmdlet -25')
    }

    if (@($Claim.Noun | Where-Object -FilterScript { $Noun.StartsWith($_, [System.StringComparison]::OrdinalIgnoreCase) -and $Noun.Length -gt $_.Length }).Count -gt 0)
    {
        $score -= 20
        $reasons.Add('extends a claimed noun -20')
    }

    $depth = @($Uri -split '/' | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) -and $_ -notlike '{*' }).Count
    if ($depth -ge 5)
    {
        $score -= 20
        $reasons.Add("route is $depth levels deep -20")
    }

    if ($Uri -match '(Statistics|Insight|Insights|Summary|Report|Reports|Status|Health|Activity|Activities)$')
    {
        $score -= 30
        $reasons.Add('route reads as telemetry -30')
    }

    if ($Uri -match '(Instance|Instances|Schedule|Schedules|Approval|Approvals)$')
    {
        $score -= 30
        $reasons.Add('route reads as a projection of a request -30')
    }

    return [ordered]@{
        noun        = $Noun
        modules     = @(Get-M365DSCOrderedName -Value ([System.String[]] @($Entry.Modules)))
        apiVersions = @(Get-M365DSCOrderedName -Value ([System.String[]] @($Entry.ApiVersions)))
        uri         = $Uri
        verbs       = @(Get-M365DSCOrderedName -Value ([System.String[]] @($Entry.Verbs)))
        score       = $score
        reasons     = @($reasons)
    }
}

<#
.SYNOPSIS
    Tells whether any claimed cmdlet comes from an SDK module.

.PARAMETER Module
    Specifies the SDK module name, which is the part after Microsoft.Graph.

.PARAMETER Claim
    Specifies the claim set.

.OUTPUTS
    True when a claimed cmdlet belongs to that module.
#>
function Test-ClaimedModule
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Module,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Claim
    )

    if ([System.String]::IsNullOrEmpty($Module))
    {
        return $false
    }

    return $Claim.ClaimedModule.Contains($Module)
}

<#
.SYNOPSIS
    Tells whether another noun under the same route parent is claimed.

.PARAMETER Uri
    Specifies the candidate route.

.PARAMETER Claim
    Specifies the claim set.

.OUTPUTS
    True when a claimed noun sits under the same parent route.
#>
function Test-ClaimedSibling
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Uri,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Claim
    )

    $parent = $Uri.Substring(0, [System.Math]::Max($Uri.LastIndexOf('/'), 0))
    if ([System.String]::IsNullOrEmpty($parent))
    {
        return $false
    }

    return $Claim.RouteParent.Contains($parent)
}

<#
.SYNOPSIS
    Turns the candidates the baseline does not carry into findings.

.DESCRIPTION
    Delta scoped. The standing list is a roadmap document and never becomes findings. A
    comparison against itself reports nothing.

.PARAMETER Candidate
    Specifies the ranked candidates.

.PARAMETER BaselineNoun
    Specifies the candidate nouns the committed coverage file holds.

.OUTPUTS
    The findings.
#>
function Compare-Coverage
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
        $BaselineNoun = @()
    )

    if ($Candidate.Count -eq 0 -or $BaselineNoun.Count -eq 0)
    {
        return [System.Object[]] @()
    }

    $baseline = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] $BaselineNoun, [System.StringComparer]::OrdinalIgnoreCase)

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    foreach ($item in $Candidate)
    {
        if ($baseline.Contains([System.String] $item.noun))
        {
            continue
        }

        $findings.Add((New-M365DSCApiSurfaceFinding -Code 'COV-NO-RESOURCE' `
                    -Subject ([System.String] $item.noun) `
                    -To ([ordered]@{ uri = $item.uri; modules = @($item.modules); score = $item.score }) `
                    -Evidence ([ordered]@{ source = "graph:$($item.uri)"; reasons = @($item.reasons) })))
    }

    return [System.Object[]] $findings
}
