<#
.SYNOPSIS
    Builds the edit that re-declares a property with the type the vendor offers.

.DESCRIPTION
    The whole declaration is re-rendered from the generator's model, which overwrites a hand tuned
    description. A type change is breaking. A configuration that assigns the old type stops
    compiling.

.PARAMETER ClassEdit
    Specifies the parsed resource from Get-ResourceClassEdit.

.PARAMETER Finding
    Specifies the RES-TYPE-MISMATCH finding.

.PARAMETER Generator
    Specifies the resource generator module.

.PARAMETER Origin
    Specifies the generatedFrom block of the resource.

.OUTPUTS
    The edit record, or nothing when the render matches the declaration.
#>
function Update-PropertyType
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
    if (-not $ClassEdit.Property.Contains($name))
    {
        throw "'$($ClassEdit.ClassName)' does not declare '$name'."
    }

    $declaration = $ClassEdit.Property[$name]
    $model = Get-VendorPropertyModel -Name $name -Origin $Origin -Generator $Generator

    if ($model.IsComplex)
    {
        throw "'$name' is a complex type on the vendor side. A CIM class has to be written by hand."
    }

    # Key and Mandatory live on the resource, not on the vendor type.
    $dscProperty = @($declaration.Attributes | Where-Object -FilterScript { $_.TypeName.Name -eq 'DscProperty' })[0]
    $isKey = $dscProperty.Extent.Text -like '*Key*'
    $isMandatory = $dscProperty.Extent.Text -like '*Mandatory*'

    $rendered = & $Generator {
        param ($Model, $IsKey, $IsMandatory)

        $Model.IsKey = $IsKey
        $Model.IsMandatory = $IsMandatory
        return New-M365DSCClassPropertyBlock -Properties @($Model)
    } $model $isKey $isMandatory

    if ($rendered.Trim() -ceq $declaration.Extent.Text.Trim())
    {
        return @()
    }

    return @(New-ResourceEdit -Offset $declaration.Extent.StartOffset `
            -Length ($declaration.Extent.EndOffset - $declaration.Extent.StartOffset) `
            -Text $rendered.Trim() `
            -Reason "Declaration of $($ClassEdit.ClassName).$name re-rendered from the vendor type")
}
