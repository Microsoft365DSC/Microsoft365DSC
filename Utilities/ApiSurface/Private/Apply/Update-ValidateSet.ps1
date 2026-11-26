<#
.SYNOPSIS
    Builds the edit that appends the vendor members a RES-ENUM-STALE finding names.

.DESCRIPTION
    Append only. Every declared member keeps its place and its casing. A resource may declare a
    member the vendor has dropped, and replacing the set would reject configurations that work
    today.

.PARAMETER ClassEdit
    Specifies the parsed resource from Get-ResourceClassEdit.

.PARAMETER PropertyName
    Specifies the declared property.

.PARAMETER Member
    Specifies the members to append, in the order the finding lists them.

.PARAMETER Generator
    Specifies the resource generator module, which owns the rendering.

.OUTPUTS
    An edit record, or nothing when every member is already declared.
#>
function Update-ValidateSet
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
        $PropertyName,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Member,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Generator
    )

    if (-not $ClassEdit.Property.Contains($PropertyName))
    {
        throw "'$($ClassEdit.ClassName)' does not declare '$PropertyName'."
    }

    $declaration = $ClassEdit.Property[$PropertyName]
    $attribute = Get-ValidateSetAttribute -Member $declaration
    if ($null -eq $attribute)
    {
        throw "'$($ClassEdit.ClassName).$PropertyName' carries no ValidateSet."
    }

    $existing = [System.String[]] @($attribute.PositionalArguments | ForEach-Object -Process { $_.Value })
    $known = [System.Collections.Generic.HashSet[System.String]]::new(
        $existing, [System.StringComparer]::OrdinalIgnoreCase)

    $merged = [System.Collections.Generic.List[System.String]]::new($existing)
    foreach ($name in $Member)
    {
        if ($known.Add($name))
        {
            $merged.Add($name)
        }
    }

    if ($merged.Count -eq $existing.Count)
    {
        return @()
    }

    $rendered = Get-ValidateSetLine -Member ([System.String[]] $merged) -Generator $Generator

    return @(New-ResourceEdit -Offset $attribute.Extent.StartOffset `
            -Length ($attribute.Extent.EndOffset - $attribute.Extent.StartOffset) `
            -Text $rendered `
            -Reason "ValidateSet on $($ClassEdit.ClassName).$PropertyName")
}

<#
.SYNOPSIS
    Renders a ValidateSet attribute through the resource generator.

.DESCRIPTION
    New-M365DSCClassPropertyBlock owns the quoting and the separator. A second renderer here would
    drift from it.

.PARAMETER Member
    Specifies the members.

.PARAMETER Generator
    Specifies the resource generator module.

.OUTPUTS
    The attribute text.
#>
function Get-ValidateSetLine
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String[]]
        $Member,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Generator
    )

    $block = & $Generator {
        param ($Values)

        $model = New-M365DSCPropertyModel -Name 'Placeholder' -Type 'Edm.String' -EnumValues $Values
        return New-M365DSCClassPropertyBlock -Properties @($model)
    } $Member

    $line = @($block -split "`r?`n" | Where-Object -FilterScript { $_.TrimStart().StartsWith('[ValidateSet(') })[0]
    if ([System.String]::IsNullOrEmpty($line))
    {
        throw 'The generator rendered no ValidateSet for the merged member list.'
    }

    return $line.Trim()
}
