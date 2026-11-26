<#
.SYNOPSIS
    Picks the best matching type from a list of candidates without user interaction.

.DESCRIPTION
    Used wherever the generator faces ambiguity: several OData subtypes derive from the cmdlet's
    entity type, or a cmdlet declares several output types. Candidates are scored by name
    similarity against the resource name and the cmdlet noun; the top candidate wins when the
    score is confident. Only when scoring stays ambiguous does the function fall back to an
    interactive prompt - and in a non-interactive session it throws with the exact parameter to
    retry with, rather than silently guessing.

.PARAMETER Candidates
    Specifies the candidate type names.

.PARAMETER ResourceName
    Specifies the DSC resource name being generated, e.g. 'IntuneDeviceCompliancePolicyWindows10'.

.PARAMETER CmdLetNoun
    Specifies the cmdlet noun, e.g. 'MgBetaDeviceManagementDeviceCompliancePolicy'.

.PARAMETER Override
    Specifies an explicit choice that always wins. Warns when it is not among the candidates but
    honors it regardless (matching the old -AdditionalPropertiesType behavior).

.PARAMETER PromptCaption
    Specifies the caption used for the interactive fallback prompt.

.PARAMETER AllowPrompt
    Indicates that an interactive prompt is allowed when scoring is not confident.
#>
function Resolve-M365DSCTypeCandidate
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Candidates,

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.String]
        $CmdLetNoun,

        [Parameter()]
        [System.String]
        $Override,

        [Parameter()]
        [System.String]
        $PromptCaption = 'Multiple types found',

        [Parameter()]
        [System.Boolean]
        $AllowPrompt = $true
    )

    if (-not [System.String]::IsNullOrEmpty($Override))
    {
        if ($Candidates -notcontains $Override)
        {
            Write-Warning -Message "The specified type '$Override' is not among the discovered candidates ($($Candidates -join ', ')). Using it anyway."
        }

        return $Override
    }

    if ($Candidates.Count -eq 1)
    {
        return $Candidates[0]
    }

    $scored = foreach ($candidate in $Candidates)
    {
        $resourceScore = Get-M365DSCTypeCandidateScore -Candidate $candidate -Target $ResourceName
        $nounScore = Get-M365DSCTypeCandidateScore -Candidate $candidate -Target $CmdLetNoun

        [PSCustomObject]@{
            Candidate = $candidate
            Score     = [System.Math]::Max($resourceScore, $nounScore)
        }
    }

    $scored = @($scored | Sort-Object -Property Score -Descending)

    Write-Verbose -Message "Type candidate scores against '$ResourceName' / '$CmdLetNoun':"
    foreach ($entry in $scored)
    {
        Write-Verbose -Message ("  {0:N2}  {1}" -f $entry.Score, $entry.Candidate)
    }

    $top = $scored[0]
    $runnerUp = $scored[1]

    if ($top.Score -ge 0.8 -and ($top.Score - $runnerUp.Score) -ge 0.2)
    {
        Write-Verbose -Message "Auto-selected type '$($top.Candidate)' (score $($top.Score.ToString('N2')), runner-up $($runnerUp.Score.ToString('N2')))."
        return $top.Candidate
    }

    $isInteractive = $AllowPrompt -and $null -ne $Host.UI -and [System.Environment]::UserInteractive

    if (-not $isInteractive)
    {
        $candidateList = ($scored | ForEach-Object { $_.Candidate }) -join ', '
        throw ("$PromptCaption, and name matching could not confidently choose between: $candidateList. " +
            "Re-run with -AdditionalPropertiesType '<type>' to select one explicitly.")
    }

    $choices = [System.Management.Automation.Host.ChoiceDescription[]] @(
        $scored | ForEach-Object {
            [System.Management.Automation.Host.ChoiceDescription]::new(
                "&$($_.Candidate)",
                ("Score {0:N2}" -f $_.Score))
        }
    )

    $selection = $Host.UI.PromptForChoice($PromptCaption, 'Please select a type (best match first):', $choices, 0)
    return $scored[$selection].Candidate
}

<#
.SYNOPSIS
    Scores one candidate name against a target identifier. Returns 0..1.
#>
function Get-M365DSCTypeCandidateScore
{
    [CmdletBinding()]
    [OutputType([System.Double])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Candidate,

        [Parameter()]
        [System.String]
        $Target
    )

    if ([System.String]::IsNullOrEmpty($Target))
    {
        return 0.0
    }

    # Strip Graph noise from both sides before tokenizing.
    $normalizedCandidate = $Candidate -replace '^#?microsoft\.graph\.', '' -replace '^IMicrosoftGraph', ''
    # Graph output types sometimes carry a disambiguation '1' suffix (e.g. MicrosoftGraphGroup1).
    $normalizedCandidate = $normalizedCandidate -replace '(?<=[A-Za-z])1$', ''
    $normalizedTarget = $Target -replace '^MgBeta', '' -replace '^Mg', ''

    $candidateTokens = @(Split-M365DSCIdentifierToken -Value $normalizedCandidate)
    $targetTokens = @(Split-M365DSCIdentifierToken -Value $normalizedTarget)

    # Workload prefixes carry no type information.
    $noiseTokens = @('intune', 'aad', 'exo', 'teams', 'sc', 'spo', 'pp', 'o365', 'azure')
    $targetTokens = @($targetTokens | Where-Object { $_ -notin $noiseTokens })

    if ($candidateTokens.Count -eq 0 -or $targetTokens.Count -eq 0)
    {
        return 0.0
    }

    if (($candidateTokens -join '') -eq ($targetTokens -join ''))
    {
        return 1.0
    }

    $candidateSet = @($candidateTokens | Select-Object -Unique)
    $targetSet = @($targetTokens | Select-Object -Unique)
    $shared = @($candidateSet | Where-Object { $_ -in $targetSet })
    $union = @($candidateSet + $targetSet | Select-Object -Unique)
    $jaccard = $shared.Count / [System.Double] $union.Count

    # A candidate fully contained in the target is a strong signal ('windows10CompliancePolicy'
    # inside 'IntuneDeviceCompliancePolicyWindows10'). A candidate that merely CONTAINS the
    # target plus extra words ('unifiedGroup' vs 'group') is much weaker - the extra words are
    # evidence of a different subtype.
    $candidateInTarget = @($candidateSet | Where-Object { $_ -notin $targetSet }).Count -eq 0
    $targetInCandidate = @($targetSet | Where-Object { $_ -notin $candidateSet }).Count -eq 0

    if ($candidateInTarget)
    {
        return [System.Math]::Min(1.0, 0.85 + (0.15 * $jaccard))
    }

    if ($targetInCandidate)
    {
        return 0.6 + (0.15 * $jaccard)
    }

    return $jaccard
}
