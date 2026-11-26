<#
.SYNOPSIS
    Compares two API surface snapshots and the resource surface, and returns findings.

.DESCRIPTION
    Reads no file, opens no connection, imports no module. Invoke-M365DSCApiSurfaceCheck does the
    I/O. A finding id is built from the code, the subject and the property alone. It is the
    approval token a maintainer ticks and the apply run filters on.

.PARAMETER Baseline
    Specifies the previous snapshot.

.PARAMETER Current
    Specifies the snapshot just taken.

.PARAMETER Origin
    Specifies the resource rows from Get-ResourceOriginSurface.

.PARAMETER SchemaKeyword
    Specifies the DscSchemaCache keyword map, keyed by resource name.

.PARAMETER Exclusion
    Specifies the parsed exclusions.json.

.PARAMETER ExcludedProperty
    Specifies a map of resource name to its settings.json excludedProperties array.

.PARAMETER PreviousFinding
    Specifies the findings of the previous run, for carrying firstSeen forward.

.PARAMETER CoverageCandidate
    Specifies the ranked coverage candidates from Find-CoverageGap.

.PARAMETER CoverageBaselineNoun
    Specifies the candidate nouns the committed coverage file holds.

.PARAMETER SubtypeCandidate
    Specifies the ranked OData subtype candidates from Find-SubtypeGap.

.PARAMETER SubtypeBaseline
    Specifies the candidate subtypes the committed coverage file holds.

.PARAMETER TemplateBinding
    Specifies the Resource and TemplateId rows from Get-M365DSCIntuneTemplateBinding.

.PARAMETER DeclaredProperty
    Specifies a map of resource name to the DSC property names it declares.

.PARAMETER RunDate
    Specifies the date stamped on a finding seen for the first time.

.EXAMPLE
    Compare-M365DSCApiSurface -Baseline $before -Current $after

.OUTPUTS
    An ordered dictionary with Findings, Coverage, Backlog and Summary.
#>
function Compare-M365DSCApiSurface
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Baseline,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Current,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $SchemaKeyword = @{},

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Exclusion,

        [Parameter()]
        [System.Collections.IDictionary]
        $ExcludedProperty = @{},

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $PreviousFinding = @(),

        [Parameter()]
        [System.String]
        $RunDate,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $CoverageCandidate = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $CoverageBaselineNoun = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $SubtypeCandidate = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.String[]]
        $SubtypeBaseline = @(),

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $TemplateBinding = @(),

        [Parameter()]
        [System.Collections.IDictionary]
        $DeclaredProperty = @{}
    )

    $findings = [System.Collections.Generic.List[System.Object]]::new()

    $findings.AddRange([System.Object[]] @(Compare-VendorSurface -Baseline $Baseline -Current $Current -Origin $Origin))
    $findings.AddRange([System.Object[]] @(Compare-Shim -Current $Current -Origin $Origin -Exclusion $Exclusion))
    $findings.AddRange([System.Object[]] @(Compare-Coverage -Candidate $CoverageCandidate -BaselineNoun $CoverageBaselineNoun))
    $findings.AddRange([System.Object[]] @(Compare-Subtype -Candidate $SubtypeCandidate -BaselineSubtype $SubtypeBaseline))
    $findings.AddRange([System.Object[]] @(Compare-DependencyVersion -Current $Current))
    $findings.AddRange([System.Object[]] @(Compare-SettingsCatalog -Baseline $Baseline `
                -Current $Current `
                -Binding $TemplateBinding `
                -DeclaredProperty $DeclaredProperty))

    $resource = Compare-ResourceSurface -Baseline $Baseline `
        -Current $Current `
        -Origin $Origin `
        -SchemaKeyword $SchemaKeyword `
        -Exclusion $Exclusion `
        -ExcludedProperty $ExcludedProperty

    $findings.AddRange([System.Object[]] @($resource.Findings))

    $seen = @{}
    foreach ($previous in $PreviousFinding)
    {
        if ($null -ne $previous -and -not [System.String]::IsNullOrEmpty($previous.id))
        {
            $seen[[System.String] $previous.id] = [System.String] $previous.firstSeen
        }
    }

    foreach ($finding in $findings)
    {
        $carried = $seen[[System.String] $finding.id]
        if (-not [System.String]::IsNullOrEmpty($carried))
        {
            $finding.firstSeen = $carried
            continue
        }

        $finding.firstSeen = $RunDate
    }

    $ordered = @($findings | Sort-Object -Property @{ Expression = { $_.id }; Ascending = $true })

    $byCode = @{}
    foreach ($finding in $ordered)
    {
        $byCode[[System.String] $finding.code] = 1 + $byCode[[System.String] $finding.code]
    }

    $compared = @($resource.Coverage | Where-Object -FilterScript { $_.compared })

    return [ordered]@{
        Findings = $ordered
        Coverage = $resource.Coverage
        Backlog  = $resource.Backlog
        Summary  = [ordered]@{
            total    = $ordered.Count
            byCode   = ConvertTo-M365DSCOrderedMap -Map $byCode
            compared = $compared.Count
            skipped  = @($resource.Coverage).Count - $compared.Count
            backlog  = $resource.Backlog
        }
    }
}
