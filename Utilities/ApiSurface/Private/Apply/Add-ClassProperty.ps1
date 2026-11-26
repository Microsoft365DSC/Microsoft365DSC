<#
.SYNOPSIS
    Builds the edits that declare a new scalar or enum property on a resource.

.DESCRIPTION
    Two edits, both required. A declaration without an entry in the Get() result hashtable exports
    as null forever. The model comes from the generator's CSDL walk of the entity in generatedFrom,
    which carries the description the snapshot omits. Tests and examples are not touched.

.PARAMETER ClassEdit
    Specifies the parsed resource from Get-ResourceClassEdit.

.PARAMETER Finding
    Specifies the RES-PROP-MISSING finding.

.PARAMETER Generator
    Specifies the resource generator module.

.PARAMETER Origin
    Specifies the generatedFrom block of the resource.

.OUTPUTS
    The edit records.
#>
function Add-ClassProperty
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $ClassEdit,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Finding,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Generator,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Origin
    )

    $name = [System.String] $Finding.property
    if ($ClassEdit.Property.Contains($name))
    {
        throw "'$($ClassEdit.ClassName)' already declares '$name'."
    }

    if ($ClassEdit.InsertOffset -lt 0)
    {
        throw "'$($ClassEdit.ClassName)' carries neither an Ensure nor an auth property to anchor on."
    }

    if ($null -eq $ClassEdit.ResultHashtable)
    {
        throw "The Get() result hashtable of '$($ClassEdit.ClassName)' could not be resolved. Apply this one by hand."
    }

    $model = Get-VendorPropertyModel -Name $name -Origin $Origin -Generator $Generator

    $declaration = & $Generator {
        param ($Model)

        return New-M365DSCClassPropertyBlock -Properties @($Model)
    } $model

    $edits = @(New-ResourceEdit -Offset $ClassEdit.InsertOffset `
            -Length 0 `
            -Text ("$($declaration.Trim())`r`n`r`n    ") `
            -Reason "Declaration of $($ClassEdit.ClassName).$name")

    $edits += Add-ResultHashtableEntry -ClassEdit $ClassEdit -Name $model.Name -GraphName $model.GraphName

    return $edits
}

<#
.SYNOPSIS
    Returns the generator's own property model for a vendor property.

.DESCRIPTION
    The generator's walk gives the description, the CLR type, the nullability and the ValidateSet
    New-M365DSCResource would emit. The snapshot carries no descriptions and the class convention
    tests require one.

.PARAMETER Name
    Specifies the declared property name.

.PARAMETER Origin
    Specifies the generatedFrom block, which names the entity type and the API version.

.PARAMETER Generator
    Specifies the resource generator module.

.OUTPUTS
    The property model.
#>
function Get-VendorPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Origin,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Generator
    )

    $entityType = @(@($Origin.odataSubtype) | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    if ($entityType.Count -eq 0)
    {
        $entityType = @([System.String] $Origin.entityType | Where-Object { -not [System.String]::IsNullOrEmpty($_) })
    }

    if ($entityType.Count -eq 0)
    {
        throw 'generatedFrom names no entity type. The vendor description cannot be resolved.'
    }

    $model = $null
    foreach ($candidate in $entityType)
    {
        $models = & $Generator {
            param ($ApiVersion, $Entity, $IncludeNavigation)

            $schema = Get-M365DSCGraphCsdlMetadata -APIVersion $ApiVersion
            $index = New-M365DSCGraphSchemaIndex -Schema $schema
            return @(Get-M365DSCGraphTypeProperty -Schema $schema `
                    -Entity $Entity `
                    -Index $index `
                    -Qualified `
                    -IncludeNavigationProperties $IncludeNavigation)
        } ([System.String] $Origin.apiVersion) $candidate ([System.Boolean] $Origin.includeNavigationProperties)

        $model = @($models | Where-Object -FilterScript { $_.Name -eq $Name })[0]
        if ($null -ne $model)
        {
            break
        }
    }
    if ($null -eq $model)
    {
        throw "'$Name' was not found on the CSDL type '$entityType'."
    }

    return $model
}

<#
.SYNOPSIS
    Builds the edit that adds the property to the Get() result hashtable.

.DESCRIPTION
    The accessor is the one the surrounding entries use, $getValue in a generated resource and
    something else in a hand written one. Alignment follows the column the block already uses.

.PARAMETER ClassEdit
    Specifies the parsed resource.

.PARAMETER Name
    Specifies the declared property name.

.PARAMETER GraphName
    Specifies the vendor property name the accessor reads.

.OUTPUTS
    An edit record.
#>
function Add-ResultHashtableEntry
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $ClassEdit,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GraphName
    )

    $pairs = @($ClassEdit.ResultHashtable.KeyValuePairs)
    $anchor = $null
    foreach ($wanted in @('Ensure', 'Credential', 'ApplicationId', 'AccessTokens'))
    {
        $anchor = @($pairs | Where-Object -FilterScript { $_.Item1.Extent.Text -eq $wanted })[0]
        if ($null -ne $anchor)
        {
            break
        }
    }

    if ($null -eq $anchor)
    {
        throw "The Get() result hashtable of '$($ClassEdit.ClassName)' carries no Ensure or auth entry to anchor on."
    }

    $accessor = Get-ResultAccessorPrefix -Pair $pairs
    if ([System.String]::IsNullOrEmpty($accessor))
    {
        throw "No accessor could be derived from the Get() result hashtable of '$($ClassEdit.ClassName)'."
    }

    $keyOffset = $anchor.Item1.Extent.StartOffset
    $lineStart = $ClassEdit.Text.LastIndexOf("`n", $keyOffset) + 1
    $indent = $ClassEdit.Text.Substring($lineStart, $keyOffset - $lineStart)

    $column = ($anchor.Item2.Extent.StartOffset - $keyOffset) - 2
    $padding = ' ' * [System.Math]::Max($column - $Name.Length, 1)

    return @(New-ResourceEdit -Offset $lineStart `
            -Length 0 `
            -Text "$indent$Name$padding= $accessor$GraphName`r`n" `
            -Reason "Get() entry for $($ClassEdit.ClassName).$Name")
}

<#
.SYNOPSIS
    Returns the accessor prefix the result hashtable already uses, for example '$getValue.'.

.PARAMETER Pair
    Specifies the key value pairs of the hashtable.

.OUTPUTS
    The prefix, or an empty string.
#>
function Get-ResultAccessorPrefix
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Pair
    )

    $counts = [System.Collections.Specialized.OrderedDictionary]::new([System.StringComparer]::Ordinal)

    foreach ($item in $Pair)
    {
        $value = [System.String] $item.Item2.Extent.Text
        if ($value -notmatch '(?<![\w$])(\$[A-Za-z_][A-Za-z0-9_]*\.)[A-Za-z_]')
        {
            continue
        }

        $prefix = $Matches[1]
        if ($prefix -eq '$this.')
        {
            continue
        }

        $counts[$prefix] = 1 + $counts[$prefix]
    }

    $best = ''
    $bestCount = 0
    foreach ($key in (Get-M365DSCOrderedName -Value ([System.String[]] @($counts.Keys))))
    {
        if ($counts[$key] -gt $bestCount)
        {
            $best = $key
            $bestCount = $counts[$key]
        }
    }

    return $best
}
