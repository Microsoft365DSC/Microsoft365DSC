<#
.SYNOPSIS
    Builds the edits that mark a property deprecated instead of deleting it.

.DESCRIPTION
    Deleting a property breaks every tenant configuration that sets it. The description gains a
    DEPRECATED prefix and the Get() entry is commented out, following MSFT_TeamsUpgradePolicy.
    Not every orphan is a removal. Some are properties the resource maps under another name.

.PARAMETER ClassEdit
    Specifies the parsed resource from Get-ResourceClassEdit.

.PARAMETER Finding
    Specifies the RES-PROP-ORPHANED finding.

.OUTPUTS
    The edit records.
#>
function Set-PropertyDeprecated
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
        $Finding
    )

    $name = [System.String] $Finding.property
    if (-not $ClassEdit.Property.Contains($name))
    {
        throw "'$($ClassEdit.ClassName)' does not declare '$name'."
    }

    $declaration = $ClassEdit.Property[$name]
    $attribute = @($declaration.Attributes |
            Where-Object -FilterScript { $_.TypeName.Name -eq 'System.ComponentModel.Description' })[0]

    if ($null -eq $attribute)
    {
        throw "'$($ClassEdit.ClassName).$name' carries no Description to mark."
    }

    $text = [System.String] @($attribute.PositionalArguments)[0].Value
    if ($text -like 'DEPRECATED.*')
    {
        return @()
    }

    $marked = "DEPRECATED. Not offered by the vendor type. $text"
    $edits = @(New-ResourceEdit -Offset $attribute.Extent.StartOffset `
            -Length ($attribute.Extent.EndOffset - $attribute.Extent.StartOffset) `
            -Text "[System.ComponentModel.Description('$($marked.Replace("'", "''"))')]" `
            -Reason "Deprecation notice on $($ClassEdit.ClassName).$name")

    $edits += Hide-ResultHashtableEntry -ClassEdit $ClassEdit -Name $name

    return $edits
}

<#
.SYNOPSIS
    Comments out the Get() entry of a deprecated property.

.DESCRIPTION
    The property stays declared and a configuration that sets it still compiles.

.PARAMETER ClassEdit
    Specifies the parsed resource.

.PARAMETER Name
    Specifies the property.

.OUTPUTS
    An edit record, or nothing.
#>
function Hide-ResultHashtableEntry
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
        $Name
    )

    if ($null -eq $ClassEdit.ResultHashtable)
    {
        return @()
    }

    $pair = @($ClassEdit.ResultHashtable.KeyValuePairs |
            Where-Object -FilterScript { $_.Item1.Extent.Text -eq $Name })[0]

    if ($null -eq $pair)
    {
        return @()
    }

    $keyOffset = $pair.Item1.Extent.StartOffset
    $lineStart = $ClassEdit.Text.LastIndexOf("`n", $keyOffset) + 1
    $lineEnd = $pair.Item2.Extent.EndOffset
    $line = $ClassEdit.Text.Substring($lineStart, $lineEnd - $lineStart)
    $indent = $ClassEdit.Text.Substring($lineStart, $keyOffset - $lineStart)

    return @(New-ResourceEdit -Offset $lineStart `
            -Length ($lineEnd - $lineStart) `
            -Text "$indent#DEPRECATED`r`n#$line" `
            -Reason "Get() entry of $($ClassEdit.ClassName).$Name")
}
