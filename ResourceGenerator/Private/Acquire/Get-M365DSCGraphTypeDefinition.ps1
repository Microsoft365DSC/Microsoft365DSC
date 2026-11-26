<#
.SYNOPSIS
    Builds a lookup index over the Graph CSDL schema nodes.

.DESCRIPTION
    Types are keyed by their fully qualified name, annotation blocks by their target. Callers that
    resolve many types keep the index instead of scanning the schema on every lookup.

.PARAMETER Schema
    Specifies the CSDL schema nodes from Get-M365DSCGraphCsdlMetadata.

.OUTPUTS
    A hashtable with a Types map and an Annotations map.
#>
function New-M365DSCGraphSchemaIndex
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema
    )

    $types = [System.Collections.Hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)
    $annotations = [System.Collections.Hashtable]::new([System.StringComparer]::OrdinalIgnoreCase)

    foreach ($schemaNode in @($Schema))
    {
        $namespaceName = [System.String] $schemaNode.Namespace
        if ([System.String]::IsNullOrEmpty($namespaceName))
        {
            continue
        }

        foreach ($kind in @('EntityType', 'ComplexType', 'EnumType'))
        {
            foreach ($typeNode in @($schemaNode.$kind))
            {
                if ($null -eq $typeNode)
                {
                    continue
                }

                $key = "$namespaceName.$([System.String] $typeNode.Name)"
                if (-not $types.ContainsKey($key))
                {
                    $types[$key] = [PSCustomObject]@{
                        Node          = $typeNode
                        Kind          = $kind
                        NamespaceName = $namespaceName
                        Name          = [System.String] $typeNode.Name
                        Schema        = $schemaNode
                    }
                }
            }
        }

        foreach ($annotationNode in @($schemaNode.Annotations))
        {
            if ($null -eq $annotationNode -or [System.String]::IsNullOrEmpty($annotationNode.Target))
            {
                continue
            }

            $annotations[[System.String] $annotationNode.Target] = $annotationNode
        }
    }

    return @{
        Types       = $types
        Annotations = $annotations
    }
}

<#
.SYNOPSIS
    Turns a CSDL type reference into the name form the generatedFrom contract uses.

.DESCRIPTION
    Types in the microsoft.graph namespace keep their bare name. Types in a sub-namespace carry it
    in front, for example 'networkaccess.filteringProfile'. Bare names collide across sub-namespaces.

.PARAMETER NamespaceName
    Specifies the declaring namespace, for example 'microsoft.graph.networkaccess'.

.PARAMETER Name
    Specifies the bare type name.

.OUTPUTS
    The qualified type name.
#>
function Get-M365DSCGraphContractTypeName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $NamespaceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    $subNamespace = $NamespaceName -replace '^microsoft\.graph\.?', ''
    if ([System.String]::IsNullOrEmpty($subNamespace))
    {
        return $Name
    }

    return "$subNamespace.$Name"
}

<#
.SYNOPSIS
    Resolves a CSDL type reference against a schema index.

.DESCRIPTION
    Accepts the alias form 'graph.group', the full form 'microsoft.graph.group' and the bare form
    'group' or 'networkaccess.filteringProfile'. The caller strips a Collection(...) wrapper.

.PARAMETER Index
    Specifies the schema index from New-M365DSCGraphSchemaIndex.

.PARAMETER TypeReference
    Specifies the type reference to resolve.

.OUTPUTS
    The index entry, or $null when the type does not exist.
#>
function Resolve-M365DSCGraphTypeReference
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Index,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [System.String]
        $TypeReference
    )

    if ([System.String]::IsNullOrEmpty($TypeReference) -or $TypeReference -like 'Edm.*')
    {
        return $null
    }

    $candidates = @()
    if ($TypeReference -like 'microsoft.graph.*')
    {
        $candidates += $TypeReference
    }
    elseif ($TypeReference -like 'graph.*')
    {
        $candidates += 'microsoft.' + $TypeReference
    }
    else
    {
        $candidates += "microsoft.graph.$TypeReference"
    }

    foreach ($candidate in $candidates)
    {
        if ($Index.Types.ContainsKey($candidate))
        {
            return $Index.Types[$candidate]
        }
    }

    return $null
}

<#
.SYNOPSIS
    Reports whether the service treats a property as read only or as create only.

.DESCRIPTION
    Computed and a Permissions value of Permission/Read both mean the service owns the value.
    Immutable allows a value on create only. Such a property stays configurable and is reported
    separately.

.PARAMETER Index
    Specifies the schema index from New-M365DSCGraphSchemaIndex.

.PARAMETER NamespaceName
    Specifies the declaring namespace of the type.

.PARAMETER TypeName
    Specifies the bare name of the declaring type.

.PARAMETER PropertyName
    Specifies the property name.

.OUTPUTS
    A hashtable with IsReadOnly and IsImmutable.
#>
function Get-M365DSCGraphPropertyAccess
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Index,

        [Parameter(Mandatory = $true)]
        [System.String]
        $NamespaceName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TypeName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyName
    )

    $result = @{
        IsReadOnly  = $false
        IsImmutable = $false
    }

    $annotationNode = $Index.Annotations["$NamespaceName.$TypeName/$PropertyName"]
    if ($null -eq $annotationNode)
    {
        return $result
    }

    foreach ($annotation in @($annotationNode.Annotation))
    {
        if ($null -eq $annotation)
        {
            continue
        }

        switch ([System.String] $annotation.Term)
        {
            'Org.OData.Core.V1.Computed'
            {
                if ([System.String] $annotation.Bool -eq 'true')
                {
                    $result.IsReadOnly = $true
                }
            }
            'Org.OData.Core.V1.Immutable'
            {
                if ([System.String] $annotation.Bool -eq 'true')
                {
                    $result.IsImmutable = $true
                }
            }
            'Org.OData.Core.V1.Permissions'
            {
                if ((@($annotation.EnumMember) -join ';') -match 'Permission/Read$')
                {
                    $result.IsReadOnly = $true
                }
            }
        }
    }

    return $result
}

<#
.SYNOPSIS
    Resolves a Graph CSDL type and flattens its inheritance chain into raw property nodes.

.DESCRIPTION
    An abstract complex type also collects its direct subtype properties, which the service
    surfaces as one union on the wire.

.PARAMETER Schema
    Specifies the CSDL schema nodes from Get-M365DSCGraphCsdlMetadata.

.PARAMETER Entity
    Specifies the type name. Bare in the default mode, optionally sub-namespaced in qualified mode.

.PARAMETER Index
    Specifies the schema index from New-M365DSCGraphSchemaIndex. Mandatory in qualified mode.

.PARAMETER Qualified
    Indicates that Entity may carry a sub-namespace and that base types resolve across namespaces.

.OUTPUTS
    An ordered hashtable describing the type, or $null when the type does not exist.
#>
function Get-M365DSCGraphTypeDefinition
{
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Entity,

        [Parameter()]
        [System.Collections.Hashtable]
        $Index,

        [Parameter()]
        [switch]
        $Qualified
    )

    if ($Qualified)
    {
        if ($null -eq $Index)
        {
            throw 'Get-M365DSCGraphTypeDefinition requires an Index in qualified mode.'
        }

        $seed = Resolve-M365DSCGraphTypeReference -Index $Index -TypeReference $Entity
        if ($null -eq $seed)
        {
            return $null
        }

        $namespace = $seed.Schema
    }
    else
    {
        $namespace = $Schema | Where-Object -FilterScript { $_.EntityType.Name -contains $Entity }
        if ($null -eq $namespace)
        {
            $namespace = $Schema | Where-Object -FilterScript { $_.ComplexType.Name -contains $Entity }
        }

        if ($null -eq $namespace)
        {
            return $null
        }
    }

    $properties = @()
    $navigationProperties = @()
    $derivedSubtypeNames = @()
    $chain = @()
    $seedNode = $null
    $seedKind = $null
    $seedNamespaceName = $null
    $baseTypeName = $Entity

    do
    {
        if ($Qualified)
        {
            $current = Resolve-M365DSCGraphTypeReference -Index $Index -TypeReference $baseTypeName
            if ($null -eq $current)
            {
                break
            }

            $typeNode = $current.Node
            $isComplexType = $current.Kind -eq 'ComplexType'
            $currentNamespace = $current.NamespaceName
            $currentName = $current.Name
            $currentSchema = $current.Schema
        }
        else
        {
            $typeNode = $namespace.EntityType | Where-Object -FilterScript { $_.Name -eq $baseTypeName }
            $isComplexType = $false
            if ($null -eq $typeNode)
            {
                $typeNode = $namespace.ComplexType | Where-Object -FilterScript { $_.Name -eq $baseTypeName }
                $isComplexType = $true
            }

            if ($null -eq $typeNode)
            {
                break
            }

            $currentNamespace = [System.String] ($namespace | Select-Object -First 1).Namespace
            $currentName = [System.String] $typeNode.Name
            $currentSchema = $namespace
        }

        if ($null -eq $seedNode)
        {
            $seedNode = $typeNode
            $seedKind = if ($isComplexType) { 'ComplexType' } else { 'EntityType' }
            $seedNamespaceName = $currentNamespace
        }

        $isRootType = ($typeNode.BaseType -eq 'graph.entity') -or ($typeNode.Name -eq 'entity')

        $chain += [PSCustomObject]@{
            Node          = $typeNode
            NamespaceName = $currentNamespace
            Name          = $currentName
            IsComplexType = $isComplexType
            IsRoot        = $isRootType
            Schema        = $currentSchema
        }

        if ($null -ne $typeNode.Property)
        {
            foreach ($propertyNode in @($typeNode.Property))
            {
                $properties += [PSCustomObject]@{
                    Node                 = $propertyNode
                    IsRoot               = $isRootType
                    DeclaringNamespace   = $currentNamespace
                    DeclaringType        = $currentName
                }
            }
        }

        $isUnionSeed = $isComplexType -and $baseTypeName -eq $Entity -and
            ($null -eq $typeNode.BaseType -or ([System.String] $typeNode.Abstract) -eq 'true')

        if ($isUnionSeed)
        {
            $subtypes = @($currentSchema.ComplexType | Where-Object -FilterScript { $_.BaseType -eq "graph.$currentName" })
            foreach ($subtype in $subtypes)
            {
                $derivedSubtypeNames += $subtype.Name
                foreach ($subtypeProperty in @($subtype.Property))
                {
                    if ($null -eq $subtypeProperty)
                    {
                        continue
                    }

                    # One name can carry a different type on each subtype, as operationType does
                    # on the Win32 rules.
                    $declared = @($properties | Where-Object -FilterScript { $_.Node.Name -eq $subtypeProperty.Name })
                    if (@($declared.Node.Type) -contains [System.String] $subtypeProperty.Type)
                    {
                        continue
                    }

                    $properties += [PSCustomObject]@{
                        Node                 = $subtypeProperty
                        IsRoot               = $false
                        DeclaringNamespace   = $currentNamespace
                        DeclaringType        = [System.String] $subtype.Name
                    }
                }
            }
        }

        if ($null -ne $typeNode.NavigationProperty)
        {
            foreach ($navigationNode in @($typeNode.NavigationProperty))
            {
                $navigationProperties += [PSCustomObject]@{
                    Node                 = $navigationNode
                    IsRoot               = $isRootType
                    DeclaringNamespace   = $currentNamespace
                    DeclaringType        = $currentName
                }
            }
        }

        $baseTypeName = $null
        if ($typeNode.BaseType -is [System.String] -and -not [System.String]::IsNullOrEmpty($typeNode.BaseType))
        {
            if ($Qualified)
            {
                $baseTypeName = $typeNode.BaseType
            }
            else
            {
                $baseTypeName = $typeNode.BaseType.Replace('graph.', '')
            }
        }
    } while ($null -ne $baseTypeName)

    if ($null -eq $seedNode)
    {
        return $null
    }

    $baseTypeReference = $null
    if ($seedNode.BaseType -is [System.String] -and -not [System.String]::IsNullOrEmpty($seedNode.BaseType))
    {
        $baseTypeReference = [System.String] $seedNode.BaseType
    }

    return [ordered]@{
        Name                 = [System.String] $seedNode.Name
        NamespaceName        = $seedNamespaceName
        Kind                 = $seedKind
        Node                 = $seedNode
        Schema               = $namespace
        IsComplexType        = $seedKind -eq 'ComplexType'
        IsAbstract           = ([System.String] $seedNode.Abstract) -eq 'true'
        BaseType             = $baseTypeReference
        Chain                = $chain
        Properties           = $properties
        NavigationProperties = $navigationProperties
        DerivedSubtypeNames  = $derivedSubtypeNames
    }
}
