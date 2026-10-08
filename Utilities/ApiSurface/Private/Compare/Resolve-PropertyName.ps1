<#
.SYNOPSIS
    Matches a DSC property name against the vendor property set.

.DESCRIPTION
    A resource that flattens a complex type concatenates the path into one name, and it drops
    the containers it does not need. 'SignInFrequencyIsEnabled' is
    'sessionControls.signInFrequency.isEnabled', which is why a suffix of the path counts as a
    match. VendorName is the full path, the key into the vendor property set.

.PARAMETER Name
    Specifies the declared DSC property name.

.PARAMETER VendorProperty
    Specifies the expanded vendor property set from Expand-VendorPropertySet, keyed by path.

.PARAMETER LeafIndex
    Specifies the paths carrying each leaf name. Derived from VendorProperty when omitted.

.OUTPUTS
    An ordered dictionary with Matched, VendorName and Rule.
#>
function Resolve-PropertyName
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $VendorProperty,

        [Parameter()]
        [AllowNull()]
        [System.Collections.IDictionary]
        $LeafIndex
    )

    $leafIndex = $LeafIndex
    if ($null -eq $leafIndex -or $leafIndex.Count -eq 0)
    {
        $leafIndex = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
        foreach ($key in $VendorProperty.Keys)
        {
            $leaf = [System.String] $VendorProperty[$key].Name
            if ([System.String]::IsNullOrEmpty($leaf))
            {
                $leaf = $key
            }

            if (-not $leafIndex.Contains($leaf))
            {
                $leafIndex[$leaf] = [System.Collections.Generic.List[System.String]]::new()
            }

            $leafIndex[$leaf].Add($key)
        }
    }

    foreach ($candidate in (Get-PropertyNameCandidate -Name $Name))
    {
        $best = Select-VendorPropertyPath -VendorProperty $VendorProperty -Path $leafIndex[$candidate.Value]
        if (-not [System.String]::IsNullOrEmpty($best))
        {
            return [ordered]@{
                Matched    = $true
                VendorName = $best
                Rule       = $candidate.Rule
            }
        }
    }

    $lowered = $Name.ToLowerInvariant()
    $insensitive = [System.Collections.Generic.List[System.String]]::new()
    foreach ($leaf in $leafIndex.Keys)
    {
        if ($leaf.ToLowerInvariant() -eq $lowered)
        {
            $insensitive.AddRange([System.String[]] @($leafIndex[$leaf]))
        }
    }

    $best = Select-VendorPropertyPath -VendorProperty $VendorProperty -Path $insensitive
    if (-not [System.String]::IsNullOrEmpty($best))
    {
        return [ordered]@{
            Matched    = $true
            VendorName = $best
            Rule       = 'CaseInsensitive'
        }
    }

    foreach ($rule in @('FlattenedPath', 'FlattenedPathSingular'))
    {
        $matched = [System.Collections.Generic.List[System.String]]::new()
        foreach ($vendorName in $VendorProperty.Keys)
        {
            $path = $VendorProperty[$vendorName].Path
            if ([System.String]::IsNullOrEmpty($path))
            {
                continue
            }

            foreach ($suffix in (Get-PropertyPathSuffix -Path $path -Singular ($rule -eq 'FlattenedPathSingular')))
            {
                if ($suffix -eq $lowered)
                {
                    $matched.Add($vendorName)
                    break
                }
            }
        }

        $best = Select-VendorPropertyPath -VendorProperty $VendorProperty -Path $matched
        if (-not [System.String]::IsNullOrEmpty($best))
        {
            return [ordered]@{
                Matched    = $true
                VendorName = $best
                Rule       = $rule
            }
        }
    }

    return [ordered]@{
        Matched    = $false
        VendorName = $null
        Rule       = 'None'
    }
}

<#
.SYNOPSIS
    Lists the concatenated suffixes of a vendor property path, lower case.

.DESCRIPTION
    A resource drops the containers it does not need, so every suffix counts.
    'sessionControls.signInFrequency.isEnabled' offers 'signinfrequencyisenabled' and
    'isenabled' as well as the whole path.

.PARAMETER Path
    Specifies the vendor property path.

.PARAMETER Singular
    Indicates that each segment also drops a trailing s.

.OUTPUTS
    The suffixes, longest first.
#>
function Get-PropertyPathSuffix
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.Boolean]
        $Singular = $false
    )

    $segments = @($Path -split '\.')
    if ($Singular)
    {
        $segments = @($segments | ForEach-Object -Process { $_ -replace 's$', '' })
    }

    $suffixes = [System.Collections.Generic.List[System.String]]::new()
    for ($start = 0; $start -lt $segments.Count; $start++)
    {
        $suffixes.Add((($segments[$start..($segments.Count - 1)] -join '')).ToLowerInvariant())
    }

    return [System.String[]] $suffixes
}

<#
.SYNOPSIS
    Picks one vendor path out of several candidates.

.DESCRIPTION
    The shallowest path wins, then the order the walk recorded it. Without a rule the choice
    would follow the walk order alone, which reads as arbitrary when a leaf repeats.

.PARAMETER VendorProperty
    Specifies the expanded vendor property set.

.PARAMETER Path
    Specifies the candidate paths.

.OUTPUTS
    The winning path, or an empty string.
#>
function Select-VendorPropertyPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $VendorProperty,

        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Path
    )

    $candidates = @(@($Path) | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
    if ($candidates.Count -eq 0)
    {
        return ''
    }

    $best = ''
    $bestLevel = [System.Int32]::MaxValue
    foreach ($candidate in $candidates)
    {
        if (-not $VendorProperty.Contains($candidate))
        {
            continue
        }

        $level = [System.Int32] $VendorProperty[$candidate].Level
        if ($level -lt $bestLevel)
        {
            $best = $candidate
            $bestLevel = $level
        }
    }

    return $best
}

<#
.SYNOPSIS
    Lists the vendor spellings a DSC property name can take, most exact first.

.PARAMETER Name
    Specifies the declared DSC property name.

.OUTPUTS
    Objects with Value and Rule.
#>
function Get-PropertyNameCandidate
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $candidates = [System.Collections.Generic.List[System.Object]]::new()
    $candidates.Add([PSCustomObject]@{ Value = $Name; Rule = 'Exact' })

    $camel = $Name.Substring(0, 1).ToLowerInvariant() + $Name.Substring(1)
    $candidates.Add([PSCustomObject]@{ Value = $camel; Rule = 'Camel' })

    if ($Name -eq 'ODataType')
    {
        $candidates.Add([PSCustomObject]@{ Value = '@odata.type'; Rule = 'ODataType' })
    }

    if ($Name -cmatch '^([A-Z]{2,})(?=[A-Z][a-z]|$)')
    {
        $acronym = $Matches[1]
        $candidates.Add([PSCustomObject]@{
                Value = $acronym.ToLowerInvariant() + $Name.Substring($acronym.Length)
                Rule  = 'Acronym'
            })
    }

    $plural = Get-PluralName -Name $Name
    if ($plural -ne $Name)
    {
        $candidates.Add([PSCustomObject]@{ Value = $plural; Rule = 'Plural' })
        $candidates.Add([PSCustomObject]@{
                Value = $plural.Substring(0, 1).ToLowerInvariant() + $plural.Substring(1)
                Rule  = 'Plural'
            })
    }

    return $candidates.ToArray()
}

<#
.SYNOPSIS
    Returns the English plural of a property name.

.DESCRIPTION
    A resource often names a collection in the singular where the vendor uses the plural.
    AADApplication declares TokenLifetimePolicy against tokenLifetimePolicies.

.PARAMETER Name
    Specifies the property name.

.OUTPUTS
    The plural, or the name unchanged when it already looks plural.
#>
function Get-PluralName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($Name -match '(s|x|z|ch|sh)$')
    {
        return $Name
    }

    if ($Name -cmatch '[^aeiouAEIOU]y$')
    {
        return $Name.Substring(0, $Name.Length - 1) + 'ies'
    }

    return $Name + 's'
}

<#
.SYNOPSIS
    Turns a vendor property name into the DSC spelling a resource would declare.

.PARAMETER Name
    Specifies the vendor property name.

.OUTPUTS
    The PascalCase name.
#>
function ConvertTo-DscPropertyName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($Name -eq '@odata.type')
    {
        return 'ODataType'
    }

    return $Name.Substring(0, 1).ToUpperInvariant() + $Name.Substring(1)
}
