<#
.SYNOPSIS
    Renders the [DscProperty] declarations of a resource class from its property models.

.PARAMETER Properties
    Specifies the property models, in emission order.

.PARAMETER IndentCount
    Specifies the indentation of each declaration, 4 for resource classes.
#>
function New-M365DSCClassPropertyBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Properties,

        [Parameter()]
        [System.Int32]
        $IndentCount = 4
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()
    $first = $true

    foreach ($property in $Properties)
    {
        if (-not $first)
        {
            $null = $builder.AppendLine('')
        }
        $first = $false

        $attribute = '[DscProperty()]'
        if ($property.IsKey)
        {
            $attribute = '[DscProperty(Key)]'
        }
        elseif ($property.IsMandatory)
        {
            $attribute = '[DscProperty(Mandatory)]'
        }

        $null = $builder.AppendLine("$indent$attribute")

        if (-not [System.String]::IsNullOrEmpty($property.Description))
        {
            $escapedDescription = $property.Description.Replace("'", "''")
            $null = $builder.AppendLine("$indent[System.ComponentModel.Description('$escapedDescription')]")
        }

        $validationAttribute = ''
        if ($null -ne $property.PSObject.Properties['ValidationAttribute'])
        {
            $validationAttribute = $property.ValidationAttribute
        }

        if (-not [System.String]::IsNullOrEmpty($validationAttribute))
        {
            $null = $builder.AppendLine("$indent$validationAttribute")
        }
        elseif ($property.IsEnum)
        {
            $enumList = "'" + ($property.EnumValues -join "', '") + "'"
            $null = $builder.AppendLine("$indent[ValidateSet($enumList)]")
        }

        $clrType = $property.ClrType
        if ($property.IsComplex)
        {
            $clrType = $property.CimClassName
            if ($property.IsArray)
            {
                $clrType += '[]'
            }
        }
        elseif ($property.IsEnum -and $property.IsArray)
        {
            $clrType = 'System.String[]'
        }

        $null = $builder.AppendLine("$indent[$clrType] `$$($property.Name)")
    }

    return $builder.ToString().TrimEnd()
}
