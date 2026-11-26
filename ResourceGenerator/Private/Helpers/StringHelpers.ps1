<#
.SYNOPSIS
    Returns the value with its first character upper-cased.
#>
function Get-StringFirstCharacterToUpper
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    return $Value.Substring(0, 1).ToUpper() + $Value.Substring(1)
}

<#
.SYNOPSIS
    Returns the value with its first character lower-cased.
#>
function Get-StringFirstCharacterToLower
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    return $Value.Substring(0, 1).ToLower() + $Value.Substring(1)
}

<#
.SYNOPSIS
    Splits an identifier into its camelCase / PascalCase word tokens.

.DESCRIPTION
    Used by the type auto-pick scoring to compare identifiers word-by-word.
    'IntuneDeviceCompliancePolicyWindows10' -> @('intune','device','compliance','policy','windows','10').
#>
function Split-M365DSCIdentifierToken
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Value
    )

    $tokens = [regex]::Matches($Value, '([A-Z]+(?![a-z]))|([A-Z]?[a-z]+)|(\d+)') |
        ForEach-Object { $_.Value.ToLowerInvariant() }

    return [System.String[]] @($tokens)
}
