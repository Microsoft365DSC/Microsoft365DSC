<#
.SYNOPSIS
    Lists the concrete OData subtypes of the entity types the resources are built on.

.PARAMETER Generator
    Specifies the resource generator module, which owns the CSDL walking.

.PARAMETER Origin
    Specifies the resource rows from Get-ResourceOriginSurface.

.PARAMETER ResourcePath
    Specifies the DscResources folder, whose sources are read for type literals.

.PARAMETER CsdlPath
    Specifies a map of API version to CSDL file. An absent entry uses the cached download.

.OUTPUTS
    One row per concrete subtype, with its entity type, API version, resource and covered flag.
#>
function Get-ODataSubtypeSurface
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSModuleInfo]
        $Generator,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Origin = @(),

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ResourcePath,

        [Parameter()]
        [System.Collections.IDictionary]
        $CsdlPath = @{}
    )

    $claimed = Get-ODataTypeMentionedInCode -ResourcePath $ResourcePath
    $owner = @{}
    $entities = [ordered]@{}

    foreach ($row in $Origin)
    {
        if ([System.String]::IsNullOrEmpty($row.EntityType))
        {
            continue
        }

        $apiVersion = $row.ApiVersion
        if ([System.String]::IsNullOrEmpty($apiVersion))
        {
            $apiVersion = 'beta'
        }

        $key = "$apiVersion|$($row.EntityType)"
        if (-not $entities.Contains($key))
        {
            $entities[$key] = $true
        }

        foreach ($subtype in @($row.ODataSubtype | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) }))
        {
            $null = $claimed.Add([System.String] $subtype)
            $owner["$apiVersion|$subtype"] = [System.String] $row.Resource
        }
    }

    $schemas = @{}
    $indexes = @{}
    $rows = [System.Collections.Generic.List[System.Object]]::new()
    $seen = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($key in $entities.Keys)
    {
        $apiVersion, $entityType = $key -split '\|', 2

        if (-not $indexes.ContainsKey($apiVersion))
        {
            $schemas[$apiVersion] = Get-GraphCsdlSchema -Generator $Generator -ApiVersion $apiVersion -Path $CsdlPath[$apiVersion]
            $indexes[$apiVersion] = & $Generator { param($Schema) New-M365DSCGraphSchemaIndex -Schema $Schema } $schemas[$apiVersion]
        }

        foreach ($subtype in (Get-ODataDescendant -Schema $schemas[$apiVersion] -EntityType $entityType))
        {
            if (-not $seen.Add("$apiVersion|$($subtype.Name)"))
            {
                continue
            }

            $rows.Add([ordered]@{
                    apiVersion = $apiVersion
                    entityType = $entityType
                    subtype    = $subtype.Name
                    isAbstract = $subtype.IsAbstract
                    resource   = [System.String] $owner["$apiVersion|$($subtype.Name)"]
                    covered    = $claimed.Contains($subtype.Name)
                })
        }
    }

    return [System.Object[]] @($rows)
}

<#
.SYNOPSIS
    Returns every entity type that derives from one entity type, at any depth.

.PARAMETER Schema
    Specifies the CSDL schema nodes.

.PARAMETER EntityType
    Specifies the bare name of the base entity type.

.OUTPUTS
    One row per derived type, with its name and whether it is abstract.
#>
function Get-ODataDescendant
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EntityType
    )

    $byBase = @{}
    foreach ($schemaNode in @($Schema))
    {
        foreach ($typeNode in @($schemaNode.EntityType))
        {
            if ($null -eq $typeNode -or [System.String]::IsNullOrEmpty([System.String] $typeNode.BaseType))
            {
                continue
            }

            # A base type reference carries the namespace alias, which the bare names drop.
            $baseName = [System.String] $typeNode.BaseType -replace '^.*\.', ''
            if (-not $byBase.ContainsKey($baseName))
            {
                $byBase[$baseName] = [System.Collections.Generic.List[System.Object]]::new()
            }

            $byBase[$baseName].Add([PSCustomObject]@{
                    Name       = [System.String] $typeNode.Name
                    IsAbstract = ([System.String] $typeNode.Abstract) -eq 'true'
                })
        }
    }

    $result = [System.Collections.Generic.List[System.Object]]::new()
    $queue = [System.Collections.Generic.Queue[System.String]]::new()
    $queue.Enqueue($EntityType)

    $visited = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $null = $visited.Add($EntityType)

    while ($queue.Count -gt 0)
    {
        $current = $queue.Dequeue()
        foreach ($derived in @($byBase[$current]))
        {
            if ($null -eq $derived -or -not $visited.Add($derived.Name))
            {
                continue
            }

            $result.Add($derived)
            $queue.Enqueue($derived.Name)
        }
    }

    return [System.Object[]] @($result)
}

<#
.SYNOPSIS
    Returns the Graph type names the resource sources name in a type literal.

.PARAMETER ResourcePath
    Specifies the DscResources folder. An empty or missing path returns an empty set.

.OUTPUTS
    A case insensitive set of bare type names.
#>
function Get-ODataTypeMentionedInCode
{
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.HashSet[System.String]])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $ResourcePath
    )

    $mentioned = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)

    if ([System.String]::IsNullOrEmpty($ResourcePath) -or -not (Test-Path -Path $ResourcePath))
    {
        return , $mentioned
    }

    foreach ($file in (Get-ChildItem -Path $ResourcePath -Filter '*.psm1' -Recurse -File))
    {
        foreach ($match in [System.Text.RegularExpressions.Regex]::Matches(
                [System.IO.File]::ReadAllText($file.FullName), '#?microsoft\.graph\.(?<name>[A-Za-z0-9_]+)'))
        {
            $null = $mentioned.Add($match.Groups['name'].Value)
        }
    }

    return , $mentioned
}
