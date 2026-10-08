<#
.SYNOPSIS
    Builds the vendor property set one resource is compared against.

.DESCRIPTION
    Resources flatten complex properties into scalars. Admitting the members of every referenced
    complex type keeps those flattened names from reading as orphaned. Navigation targets are
    not in the snapshot and are never followed.

.PARAMETER GraphType
    Specifies the graphTypes section of a snapshot.

.PARAMETER ApiVersion
    Specifies the API version the resource was generated from.

.PARAMETER TypeName
    Specifies the entity type, or the odata subtype when the resource has one.

.PARAMETER IncludeNavigationProperties
    Indicates that the resource mirrors navigation properties.

.PARAMETER MaxDepth
    Specifies how many levels of complex type the walk admits.

.OUTPUTS
    An ordered dictionary with Properties keyed by full path, ByLeaf, the paths carrying each
    leaf name, plus TopLevelCount, Truncated and MaxDepth.
#>
function Expand-VendorPropertySet
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $GraphType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ApiVersion,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $TypeName,

        [Parameter()]
        [System.Boolean]
        $IncludeNavigationProperties = $false,

        [Parameter()]
        [System.Int32]
        $MaxDepth = 3
    )

    $properties = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
    $byLeaf = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)
    $queue = [System.Collections.Generic.Queue[System.Object]]::new()
    $truncated = $false
    $topLevelCount = 0

    foreach ($seedType in @($TypeName | Where-Object { -not [System.String]::IsNullOrEmpty($_) }))
    {
        $queue.Enqueue([PSCustomObject]@{
                Key      = "${ApiVersion}:$seedType"
                Level    = 0
                Path     = ''
                Ancestor = [System.String[]] @("${ApiVersion}:$seedType")
            })
    }

    while ($queue.Count -gt 0)
    {
        $item = $queue.Dequeue()

        $entry = Get-SurfaceMember -Container $GraphType -Name $item.Key
        if ($null -eq $entry)
        {
            continue
        }

        foreach ($member in (Get-SurfaceMemberName -Container $entry.properties))
        {
            $value = Get-SurfaceMember -Container $entry.properties -Name $member
            $isNavigation = [System.Boolean] $value.isNavigation

            if ($isNavigation -and -not $IncludeNavigationProperties)
            {
                continue
            }

            $path = $member
            if (-not [System.String]::IsNullOrEmpty($item.Path))
            {
                $path = "$($item.Path).$member"
            }

            if (-not $properties.Contains($path))
            {
                $properties[$path] = [ordered]@{
                    Name       = $member
                    Path       = $path
                    Level      = $item.Level
                    Type       = [System.String] $value.type
                    IsArray    = [System.Boolean] $value.isArray
                    IsComplex  = [System.Boolean] $value.isComplex
                    IsReadOnly = [System.Boolean] $value.isReadOnly
                    IsFlags    = [System.Boolean] $value.isFlags
                    Enum       = [System.String[]] @(@($value.enum) | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
                }

                if (-not $byLeaf.Contains($member))
                {
                    $byLeaf[$member] = [System.Collections.Generic.List[System.String]]::new()
                }

                $byLeaf[$member].Add($path)

                if ($item.Level -eq 0)
                {
                    $topLevelCount++
                }
            }

            if (-not $value.isComplex)
            {
                continue
            }

            if ($isNavigation -and -not ($IncludeNavigationProperties -and $item.Level -eq 0))
            {
                continue
            }

            $childKey = "${ApiVersion}:$([System.String] $value.type)"
            if ($item.Ancestor -contains $childKey)
            {
                continue
            }

            if ($item.Level -ge $MaxDepth)
            {
                $truncated = $true
                continue
            }

            $queue.Enqueue([PSCustomObject]@{
                    Key      = $childKey
                    Level    = $item.Level + 1
                    Path     = $path
                    Ancestor = [System.String[]] @($item.Ancestor + $childKey)
                })
        }
    }

    return [ordered]@{
        Properties    = $properties
        ByLeaf        = $byLeaf
        TopLevelCount = $topLevelCount
        Truncated     = $truncated
        MaxDepth      = $MaxDepth
    }
}

<#
.SYNOPSIS
    Reads one member of a snapshot section, whether it arrived as a hashtable or as parsed JSON.

.PARAMETER Container
    Specifies the map to read.

.PARAMETER Name
    Specifies the member name.

.OUTPUTS
    The member value, or $null.
#>
function Get-SurfaceMember
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Container,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    if ($null -eq $Container)
    {
        return $null
    }

    if ($Container -is [System.Collections.IDictionary])
    {
        if ($Container.Contains($Name))
        {
            return $Container[$Name]
        }

        return $null
    }

    $property = $Container.PSObject.Properties[$Name]
    if ($null -eq $property)
    {
        return $null
    }

    return $property.Value
}

<#
.SYNOPSIS
    Lists the member names of a snapshot section, whether hashtable or parsed JSON.

.DESCRIPTION
    Reading Name off an empty collection yields a single null.

.PARAMETER Container
    Specifies the map to read.

.OUTPUTS
    The member names.
#>
function Get-SurfaceMemberName
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Container
    )

    if ($null -eq $Container)
    {
        return [System.String[]] @()
    }

    if ($Container -is [System.Collections.IDictionary])
    {
        $names = @($Container.Keys)
    }
    else
    {
        $names = @($Container.PSObject.Properties | ForEach-Object -Process { $_.Name })
    }

    return [System.String[]] @($names | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) })
}
