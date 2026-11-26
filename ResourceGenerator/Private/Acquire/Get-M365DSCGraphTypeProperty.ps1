<#
.SYNOPSIS
    Returns the property models of a Graph entity or complex type.

.DESCRIPTION
    Projects the raw property nodes from Get-M365DSCGraphTypeDefinition into property models and
    recurses into complex types. A visited set stops a type that references itself.

.PARAMETER Schema
    Specifies the CSDL schema nodes from Get-M365DSCGraphCsdlMetadata.

.PARAMETER Entity
    Specifies the entity or complex type name, for example 'permissionGrantPolicy'.

.PARAMETER IncludeNavigationProperties
    Indicates that navigation properties (Graph relationships) are included as complex properties.

.PARAMETER ExistingCimClassNames
    Specifies the CIM class names already used by shipped resources, for collision suffixing.

.PARAMETER Visited
    Specifies the set of type names already on the current recursion path.

.PARAMETER Index
    Specifies the schema index from New-M365DSCGraphSchemaIndex. Needed with Qualified.

.PARAMETER Qualified
    Indicates that Entity may carry a sub-namespace. Bare names collide across sub-namespaces.
#>
function Get-M365DSCGraphTypeProperty
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
        $Entity,

        [Parameter()]
        [System.Boolean]
        $IncludeNavigationProperties = $false,

        [Parameter()]
        [System.String[]]
        $ExistingCimClassNames = @(),

        [Parameter()]
        [System.Collections.Generic.HashSet[System.String]]
        $Visited,

        [Parameter()]
        [System.Object]
        $Index,

        [Parameter()]
        [switch]
        $Qualified
    )

    if ($null -eq $Visited)
    {
        $Visited = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
    }

    $null = $Visited.Add($Entity)

    if ($null -eq $Index)
    {
        $Index = New-M365DSCGraphSchemaIndex -Schema $Schema
    }

    $lookup = @{ Schema = $Schema; Entity = $Entity }
    if ($Qualified -and $null -ne $Index)
    {
        $lookup['Index'] = $Index
        $lookup['Qualified'] = $true
    }

    $definition = Get-M365DSCGraphTypeDefinition @lookup
    if ($null -eq $definition)
    {
        Write-Warning -Message "Type '$Entity' was not found in the Graph metadata."
        return @()
    }

    $namespace = $definition.Schema
    $derivedSubtypeNames = $definition.DerivedSubtypeNames

    $rawEntries = @($definition.Properties)
    if ($IncludeNavigationProperties)
    {
        $rawEntries += @($definition.NavigationProperties)
    }

    $models = @()

    foreach ($rawEntry in $rawEntries)
    {
        $rawProperty = $rawEntry.Node
        $isFromAdditionalProperties = -not $rawEntry.IsRoot

        $rawType = $rawProperty.Type
        $isArray = $false
        if ($rawType -like 'Collection(*)')
        {
            $isArray = $true
            $rawType = $rawType.Replace('Collection(', '').Replace(')', '')
        }

        $description = Get-M365DSCGraphPropertyDescription -Schema $Schema `
            -Property $rawProperty `
            -NamespaceName $rawEntry.DeclaringNamespace `
            -TypeName $rawEntry.DeclaringType `
            -Index $Index

        $isReadOnly = $false
        if ($null -ne $Index -and -not [System.String]::IsNullOrEmpty($rawEntry.DeclaringType))
        {
            $isReadOnly = (Get-M365DSCGraphPropertyAccess -Index $Index `
                    -NamespaceName $rawEntry.DeclaringNamespace `
                    -TypeName $rawEntry.DeclaringType `
                    -PropertyName ([System.String] $rawProperty.Name)).IsReadOnly
        }

        if ($rawType -like 'graph.*')
        {
            $typeName = $rawType.Replace('graph.', '')

            $enumType = $namespace.EnumType | Where-Object -FilterScript { $_.Name -eq $typeName }
            if ($null -ne $enumType)
            {
                $models += New-M365DSCPropertyModel -Name $rawProperty.Name `
                    -GraphName $rawProperty.Name `
                    -Description $description `
                    -IsArray $isArray `
                    -EnumValues ([System.String[]] @($enumType.Member.Name)) `
                    -IsFromAdditionalProperties $isFromAdditionalProperties `
                    -IsReadOnly $isReadOnly
                continue
            }

            if ($Visited.Contains($typeName))
            {
                Write-Warning -Message "Skipping property '$($rawProperty.Name)' on '$Entity': type '$typeName' is already part of the current type chain (cycle)."
                continue
            }

            $nestedVisited = [System.Collections.Generic.HashSet[System.String]]::new($Visited, [System.StringComparer]::OrdinalIgnoreCase)
            $members = @(Get-M365DSCGraphTypeProperty -Schema $Schema `
                    -Entity $typeName `
                    -ExistingCimClassNames $ExistingCimClassNames `
                    -Visited $nestedVisited `
                    -Index $Index `
                    -Qualified:($null -ne $Index))

            if ($members.Count -eq 0)
            {
                Write-Warning -Message "Skipping property '$($rawProperty.Name)' on '$Entity': complex type '$typeName' has no usable members."
                continue
            }

            $cimClassName = Get-M365DSCUniqueCimClassName -TypeName $typeName -ExistingCimClassNames $ExistingCimClassNames

            $models += New-M365DSCPropertyModel -Name $rawProperty.Name `
                -GraphName $rawProperty.Name `
                -Description $description `
                -IsArray $isArray `
                -CimClassName $cimClassName `
                -Members $members `
                -IsFromAdditionalProperties $isFromAdditionalProperties `
                -IsReadOnly $isReadOnly
            continue
        }

        $models += New-M365DSCPropertyModel -Name $rawProperty.Name `
            -GraphName $rawProperty.Name `
            -Type $rawType `
            -Description $description `
            -IsArray $isArray `
            -IsFromAdditionalProperties $isFromAdditionalProperties `
            -IsReadOnly $isReadOnly
    }

    $models = @(Merge-M365DSCPropertyModel -Model $models)

    # The @odata.type discriminator names the concrete subtype an instance carries.
    if ($derivedSubtypeNames.Count -gt 0)
    {
        $models += New-M365DSCPropertyModel -Name 'ODataType' `
            -GraphName '@odata.type' `
            -Description 'The type of the entity.' `
            -EnumValues ([System.String[]] @($derivedSubtypeNames | ForEach-Object { "#microsoft.graph.$_" }))
    }

    return $models
}

<#
.SYNOPSIS
    Returns the description of a CSDL property, or the schema level annotation as a fallback.

.PARAMETER Schema
    Specifies the CSDL schema nodes.

.PARAMETER Property
    Specifies the property node.

.PARAMETER NamespaceName
    Specifies the namespace declaring the property, for example 'microsoft.graph.networkaccess'.

.PARAMETER TypeName
    Specifies the declaring type. Defaults to the parent node of the property.

.PARAMETER Index
    Specifies the schema index from New-M365DSCGraphSchemaIndex. Without it the schema-level
    fallback scans every annotation node of the schema, once per property.

.OUTPUTS
    The description, or an empty string.
#>
function Get-M365DSCGraphPropertyDescription
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $NamespaceName = 'microsoft.graph',

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $TypeName,

        [Parameter()]
        [System.Collections.Hashtable]
        $Index
    )

    $description = Get-M365DSCGraphAnnotationDescription -Annotation $Property.Annotation

    if ([System.String]::IsNullOrWhiteSpace($description))
    {
        if ([System.String]::IsNullOrEmpty($NamespaceName))
        {
            $NamespaceName = 'microsoft.graph'
        }

        if ([System.String]::IsNullOrEmpty($TypeName))
        {
            $TypeName = [System.String] $Property.ParentNode.Name
        }

        $target = "$NamespaceName.$TypeName/$($Property.Name)"
        if ($null -ne $Index)
        {
            $annotation = $Index.Annotations[$target]
        }
        else
        {
            $annotation = $Schema.Annotations | Where-Object -FilterScript { $_.Target -like $target }
        }
        $description = Get-M365DSCGraphAnnotationDescription -Annotation $annotation.Annotation
    }

    if ([System.String]::IsNullOrEmpty($description))
    {
        return ''
    }

    $description = $description.Replace('"', "'")
    # MOF Description attributes accept letters, digits and basic punctuation only.
    return ($description -replace '[^\p{L}\p{Nd}/(/}/_ -.,=:)'']', '')
}

<#
.SYNOPSIS
    Returns the Description string out of a set of CSDL annotations.

.DESCRIPTION
    A node can carry several annotations. Reading String off the set yields an array whose
    capability entries are null, which fails on the first string operation.

.PARAMETER Annotation
    Specifies the annotation nodes.

.OUTPUTS
    The description, or an empty string.
#>
function Get-M365DSCGraphAnnotationDescription
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [AllowNull()]
        [System.Object]
        $Annotation
    )

    foreach ($entry in @($Annotation))
    {
        if ($null -eq $entry)
        {
            continue
        }

        if (([System.String] $entry.Term) -eq 'Org.OData.Core.V1.Description')
        {
            return [System.String] $entry.String
        }
    }

    return ''
}

<#
.SYNOPSIS
    Builds the MSFT_MicrosoftGraph CIM class name of a complex type.

.DESCRIPTION
    A name that clashes with a class shipped by another resource gets a counter suffix.

.PARAMETER TypeName
    Specifies the Graph complex type name.

.PARAMETER ExistingCimClassNames
    Specifies the CIM class names already used by shipped resources.
#>
function Get-M365DSCUniqueCimClassName
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $TypeName,

        [Parameter()]
        [System.String[]]
        $ExistingCimClassNames = @()
    )

    $pascalTypeName = Get-StringFirstCharacterToUpper -Value $TypeName
    $cimClassName = "MSFT_MicrosoftGraph$pascalTypeName"

    if ($ExistingCimClassNames -contains $cimClassName)
    {
        $collisionCount = @($ExistingCimClassNames | Where-Object -FilterScript { $_ -like "$cimClassName*" }).Count
        $cimClassName += $collisionCount.ToString()
    }

    return $cimClassName
}

<#
.SYNOPSIS
    Collapses property models that share a name, unioning the members of enum properties.

.PARAMETER Model
    Specifies the property models of one type.

.OUTPUTS
    The models, one per name.
#>
function Merge-M365DSCPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Model = @()
    )

    $merged = [ordered]@{}

    foreach ($property in $Model)
    {
        $name = [System.String] $property.Name
        if (-not $merged.Contains($name))
        {
            $merged[$name] = $property
            continue
        }

        $kept = $merged[$name]
        if (-not $kept.IsEnum -or -not $property.IsEnum)
        {
            continue
        }

        $values = @($kept.EnumValues) + @($property.EnumValues)
        $kept.EnumValues = @($values | Select-Object -Unique)
    }

    return [System.Object[]] @($merged.Values)
}
