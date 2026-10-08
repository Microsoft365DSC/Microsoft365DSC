<#
.SYNOPSIS
    Renders the coverage candidates as a roadmap document.

.DESCRIPTION
    A roadmap rather than a drift report. No global coverage percentage is published. Workloads
    whose cmdlets only exist after a connection cannot be counted the same way.

.PARAMETER Candidate
    Specifies the ranked candidates from Find-CoverageGap.

.PARAMETER Source
    Specifies the inventory source block.

.PARAMETER Subtype
    Specifies the ranked OData subtype candidates from Find-SubtypeGap.

.PARAMETER RenderedCount
    Specifies how many candidates are rendered as commands.

.OUTPUTS
    The Markdown text.
#>
function Format-CoverageMarkdown
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Candidate = @(),

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Source,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Subtype = @(),

        [Parameter()]
        [System.Int32]
        $RenderedCount = 40
    )

    $lines = [System.Collections.Generic.List[System.String]]::new()

    $lines.Add('# Graph coverage')
    $lines.Add('')
    $lines.Add("$($Candidate.Count) Graph cmdlet nouns offer a create, a read, an update and a delete, and no resource covers them.")
    $lines.Add('')
    $lines.Add('Ranked, never filtered on a guess. Only a claim by name and an entry in `coverage-ignore.json` remove a candidate. Everything else moves its score, and every component that fired is listed beside it.')
    $lines.Add('')

    if ($null -ne $Source)
    {
        $lines.Add("Inventory: $($Source.module) $($Source.version) ($($Source.versionSource)).")
        $lines.Add('')
    }

    $lines.Add("## Highest ranked  ($([System.Math]::Min($RenderedCount, $Candidate.Count)))")
    $lines.Add('')

    foreach ($item in ($Candidate | Select-Object -First $RenderedCount))
    {
        $version = 'beta'
        $prefix = 'MgBeta'
        if (@($item.apiVersions) -contains 'v1.0')
        {
            $version = 'v1.0'
            $prefix = 'Mg'
        }

        $lines.Add("### $($item.noun)  (score $($item.score))")
        $lines.Add('')
        $lines.Add("``$($item.uri)``, $(@($item.modules) -join ', ')")
        $lines.Add('')
        $lines.Add('```powershell')
        $lines.Add("New-M365DSCResource -ResourceName <Suggested> -Workload MicrosoftGraph ``")
        $lines.Add("    -CmdLetNoun $prefix$($item.noun) -APIVersion $version")
        $lines.Add('```')
        $lines.Add('')
        $reasons = @($item.reasons | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
        if ($reasons.Count -gt 0)
        {
            $lines.Add("Score: $($reasons -join '; ').")
        }
        else
        {
            $lines.Add('Score: no component fired.')
        }
        $lines.Add('')
    }

    $rest = @($Candidate | Select-Object -Skip $RenderedCount)
    $lines.Add("## The rest  ($($rest.Count))")
    $lines.Add('')

    if ($rest.Count -eq 0)
    {
        $lines.Add('None.')
    }
    else
    {
        $lines.Add('| Noun | Score | Modules | Route |')
        $lines.Add('| --- | --- | --- | --- |')
        foreach ($item in $rest)
        {
            $lines.Add("| $($item.noun) | $($item.score) | $(@($item.modules) -join ', ') | ``$($item.uri)`` |")
        }
    }

    $lines.Add('')
    $lines.Add("## OData subtypes  ($($Subtype.Count))")
    $lines.Add('')
    $lines.Add('Concrete subtypes of an entity type a resource already models, with one resource per subtype.')
    $lines.Add('')

    if ($Subtype.Count -eq 0)
    {
        $lines.Add('None.')
    }
    else
    {
        $lines.Add('| Subtype | Score | Entity type | API version |')
        $lines.Add('| --- | --- | --- | --- |')
        foreach ($item in $Subtype)
        {
            $lines.Add("| $($item.subtype) | $($item.score) | $($item.entityType) | $($item.apiVersion) |")
        }
    }

    return ($lines -join "`n").TrimEnd() + "`n"
}
