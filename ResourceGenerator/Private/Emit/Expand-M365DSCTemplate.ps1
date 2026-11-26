<#
.SYNOPSIS
    Expands a template into a destination file in a single pass.

.DESCRIPTION
    Replaces every <TokenName> occurrence with the corresponding value from the Tokens hashtable,
    resolves IF/ELSE/ENDIF conditional sections (written as comment markers "IF TokenName",
    "ELSE" and "ENDIF TokenName" so the raw template still parses as PowerShell), and throws
    when the result still contains an unreplaced token. Reading and writing happen exactly once.

    Conditional sections keep their content when the named token is truthy ($true, a non-empty
    string, a non-empty collection) and drop it otherwise. Sections must be closed with the same
    token name they were opened with, which is also what allows them to nest.

.PARAMETER TemplatePath
    Specifies the template file to expand.

.PARAMETER Content
    Specifies the template content directly instead of a file.

.PARAMETER DestinationPath
    Specifies the file to write. When omitted, the expanded content is returned as a string.

.PARAMETER Tokens
    Specifies the replacement values, keyed by token name without the angle brackets.
#>
function Expand-M365DSCTemplate
{
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [System.String]
        $TemplatePath,

        [Parameter(Mandatory = $true, ParameterSetName = 'Content')]
        [AllowEmptyString()]
        [System.String]
        $Content,

        [Parameter()]
        [System.String]
        $DestinationPath,

        [Parameter()]
        [System.Collections.Hashtable]
        $Tokens = @{}
    )

    if ($PSCmdlet.ParameterSetName -eq 'Path')
    {
        $Content = Get-Content -Path $TemplatePath -Raw
    }

    # Resolve conditional sections innermost-first so they can nest.
    $conditionalPattern = '(?s)[ \t]*<#IF (?<name>\w+)#>\r?\n(?<body>((?!<#(IF|ELSE|ENDIF)).)*?)(^[ \t]*<#ELSE#>\r?\n(?<else>((?!<#(IF|ELSE|ENDIF)).)*?))?^[ \t]*<#ENDIF \k<name>#>(\r?\n)?'
    $regexOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline
    $evaluator = {
        param($match)

        $name = $match.Groups['name'].Value
        $value = $Tokens[$name]

        $isTruthy = $false
        if ($null -ne $value)
        {
            if ($value -is [System.Boolean])
            {
                $isTruthy = $value
            }
            elseif ($value -is [System.String])
            {
                $isTruthy = -not [System.String]::IsNullOrEmpty($value)
            }
            elseif ($value -is [System.Collections.ICollection])
            {
                $isTruthy = $value.Count -gt 0
            }
            else
            {
                $isTruthy = $true
            }
        }

        if ($isTruthy)
        {
            return $match.Groups['body'].Value
        }

        return $match.Groups['else'].Value
    }

    while ([regex]::IsMatch($Content, $conditionalPattern, $regexOptions))
    {
        $Content = [regex]::Replace($Content, $conditionalPattern, $evaluator, $regexOptions)
    }

    $unknownConditional = [regex]::Match($Content, '<#(IF|ELSE|ENDIF)[^#]*#>')
    if ($unknownConditional.Success)
    {
        throw ("Template expansion failed: unresolved conditional marker '$($unknownConditional.Value)'. " +
            'Every <#IF Name#> needs a matching <#ENDIF Name#>.')
    }

    # Single pass: replaced values are never rescanned, so token-like text inside a value (e.g. a
    # cmdlet help string containing '<blank>') cannot trip the unknown-token check.
    $tokenEvaluator = {
        param($match)

        $name = $match.Groups['name'].Value
        if (-not $Tokens.ContainsKey($name))
        {
            throw ("Template expansion failed: token '<$name>' was not replaced. " +
                'Provide a value for it in -Tokens or remove it from the template.')
        }

        return [System.String] $Tokens[$name]
    }

    $Content = [regex]::Replace($Content, '<(?<name>[A-Za-z][A-Za-z0-9]*)>', $tokenEvaluator)

    if ($PSBoundParameters.ContainsKey('DestinationPath'))
    {
        $destinationFolder = Split-Path -Path $DestinationPath -Parent
        if (-not (Test-Path -Path $destinationFolder))
        {
            $null = New-Item -Path $destinationFolder -ItemType Directory -Force
        }

        Set-Content -Path $DestinationPath -Value $Content -NoNewline -Encoding UTF8
        return $null
    }

    return $Content
}
