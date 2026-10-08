<#
    Get()-side conversion: turns what the workload cmdlet returned into the hashtable a class
    resource builds its result from. Three pieces, all driven by the property models:

      - New-M365DSCComplexConversionBlock: the lines inside Get() that convert complex, enum and
        date properties into local variables.
      - New-M365DSCHashtableMappingBlock: the $result = @{ ... } body.
      - New-M365DSCInlineComplexBlock: the inline conversion of one complex property, nested
        members included, so Get() carries the whole conversion.
#>

<#
.SYNOPSIS
    Returns the Get()-side access path of a property on the cmdlet output object.
#>
function Get-M365DSCPropertyAccessPath
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter()]
        [System.String]
        $ObjectVariable = '$getValue'
    )

    if ($Property.IsFromAdditionalProperties)
    {
        if ($Property.GraphName -match '[^\w]')
        {
            return "$ObjectVariable.'$($Property.GraphName)'"
        }

        return "$ObjectVariable.$($Property.GraphName)"
    }

    return "$ObjectVariable.$($Property.Name)"
}

<#
.SYNOPSIS
    Renders the conversion statements that precede the $result hashtable in Get().

.PARAMETER ResourceModel
    Specifies the resource model.

.PARAMETER IndentCount
    Specifies the indentation of the rendered statements.

.OUTPUTS
    The block, with every complex property converted inline.
#>
function New-M365DSCComplexConversionBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.Int32]
        $IndentCount = 12
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()
    $isGraph = Test-M365DSCGraphWorkload -ResourceModel $ResourceModel

    foreach ($property in $ResourceModel.SchemaProperties)
    {
        if (Test-M365DSCAssignmentProperty -Property $property)
        {
            # Assignments convert through their own block, after the result hashtable.
            continue
        }

        $path = Get-M365DSCPropertyAccessPath -Property $property
        $name = $property.Name

        if ($property.IsComplex)
        {
            $null = $builder.AppendLine((New-M365DSCInlineComplexBlock -Property $property `
                        -SourcePath $path `
                        -TargetVariable "complex$name" `
                        -IndentCount $IndentCount `
                        -IsGraph:$isGraph))
            $null = $builder.AppendLine('')
        }
        elseif ($property.IsEnum -and $property.Name -ne 'Ensure' -and -not $isGraph)
        {
            if ($property.IsArray)
            {
                $null = $builder.AppendLine("$indent`$enum$name = [System.String[]]@($path | ForEach-Object { `$_.ToString() })")
            }
            else
            {
                $null = $builder.AppendLine("$indent`$enum$name = `$null")
                $null = $builder.AppendLine("${indent}if (`$null -ne $path)")
                $null = $builder.AppendLine("$indent{")
                $null = $builder.AppendLine("$indent    `$enum$name = $path.ToString()")
                $null = $builder.AppendLine("$indent}")
            }
            $null = $builder.AppendLine('')
        }
        elseif ($property.FakeKind -in @('DateTime', 'Time'))
        {
            $toString = ".ToUniversalTime().ToString('o')"
            if ($property.FakeKind -eq 'Time')
            {
                $toString = '.ToString()'
            }

            $null = $builder.AppendLine("$indent`$date$name = `$null")
            $null = $builder.AppendLine("${indent}if (`$null -ne $path)")
            $null = $builder.AppendLine("$indent{")
            $null = $builder.AppendLine("$indent    `$date$name = $path$toString")
            $null = $builder.AppendLine("$indent}")
            $null = $builder.AppendLine('')
        }
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Renders the body of the $result hashtable in Get().
#>
function New-M365DSCHashtableMappingBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.Int32]
        $IndentCount = 16
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()

    $longestName = ($ResourceModel.Properties | Measure-Object -Maximum { $_.Name.Length }).Maximum

    foreach ($property in $ResourceModel.Properties)
    {
        if (Test-M365DSCAssignmentProperty -Property $property)
        {
            # Added to the result after the hashtable, by the assignments Get block.
            continue
        }

        $name = $property.Name
        $padding = ' ' * ($longestName - $name.Length)

        if ($property.IsAuth -or ($null -ne $property.PSObject.Properties['IsPathKey'] -and $property.IsPathKey))
        {
            $value = "`$this.$name"
        }
        elseif ($name -eq 'Ensure')
        {
            $value = "'Present'"
        }
        elseif ($name -eq 'IsSingleInstance')
        {
            $value = "'Yes'"
        }
        elseif ($property.IsComplex)
        {
            $value = "`$complex$name"
            if ($property.IsArray)
            {
                $value = "[Array]`$complex$name"
            }
        }
        elseif ($property.IsEnum)
        {
            $value = "`$enum$name"
            if (Test-M365DSCGraphWorkload -ResourceModel $ResourceModel)
            {
                $value = Get-M365DSCPropertyAccessPath -Property $property
            }
        }
        elseif ($property.FakeKind -in @('DateTime', 'Time'))
        {
            $value = "`$date$name"
        }
        elseif ($name -in @($ResourceModel.TextPayloadProperties))
        {
            $value = "`$this.DecodeTextPayload($(Get-M365DSCPropertyAccessPath -Property $property))"
        }
        elseif ($name -eq 'RoleScopeTagIds')
        {
            $value = "Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $(Get-M365DSCPropertyAccessPath -Property $property) -DesiredValues `$this.RoleScopeTagIds"
        }
        else
        {
            $value = Get-M365DSCPropertyAccessPath -Property $property
        }

        $null = $builder.AppendLine("$indent$name$padding = $value")
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Tells whether the resource reads its data through the Graph shim.

.PARAMETER ResourceModel
    Specifies the resource model.

.OUTPUTS
    True for the Graph workloads, whose shim returns strings rather than typed enums.
#>
function Test-M365DSCGraphWorkload
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    return ($ResourceModel.Workload -in @('MicrosoftGraph', 'Intune'))
}

<#
.SYNOPSIS
    Renders the inline conversion of one complex property into an ordered hashtable.

.PARAMETER Property
    Specifies the complex property model.

.PARAMETER SourcePath
    Specifies the expression that holds the value the workload returned.

.PARAMETER TargetVariable
    Specifies the variable name that receives the hashtable, without the sigil.

.PARAMETER IndentCount
    Specifies the indentation of the rendered statements.

.PARAMETER IsGraph
    Renders enum members without a ToString call, which the Graph shim makes unnecessary.

.OUTPUTS
    The block, with every nested complex member converted in place.
#>
function New-M365DSCInlineComplexBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TargetVariable,

        [Parameter()]
        [System.Int32]
        $IndentCount = 12,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsGraph
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()
    $name = $Property.Name

    if ($Property.IsArray)
    {
        $itemVariable = "my$name"
        $null = $builder.AppendLine("$indent`$$TargetVariable = @()")
        $null = $builder.AppendLine("${indent}foreach (`$current$name in $SourcePath)")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$$itemVariable = [ordered]@{}")

        foreach ($member in $Property.Members)
        {
            $null = $builder.Append((New-M365DSCInlineComplexMemberBlock -Member $member `
                        -SourcePath "`$current$name" `
                        -TargetVariable $itemVariable `
                        -IndentCount ($IndentCount + 4) `
                        -IsGraph:$IsGraph))
        }

        $null = $builder.AppendLine("$indent    if (`$$itemVariable.values.Where({ `$null -ne `$_ }).Count -gt 0)")
        $null = $builder.AppendLine("$indent    {")
        $null = $builder.AppendLine("$indent        `$$TargetVariable += `$$itemVariable")
        $null = $builder.AppendLine("$indent    }")
        $null = $builder.Append("$indent}")

        return $builder.ToString()
    }

    $null = $builder.AppendLine("$indent`$$TargetVariable = [ordered]@{}")

    foreach ($member in $Property.Members)
    {
        $null = $builder.Append((New-M365DSCInlineComplexMemberBlock -Member $member `
                    -SourcePath $SourcePath `
                    -TargetVariable $TargetVariable `
                    -IndentCount $IndentCount `
                    -IsGraph:$IsGraph))
    }

    $null = $builder.AppendLine("${indent}if (`$$TargetVariable.values.Where({ `$null -ne `$_ }).Count -eq 0)")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    `$$TargetVariable = `$null")
    $null = $builder.Append("$indent}")

    return $builder.ToString()
}

<#
.SYNOPSIS
    Renders the inline conversion of one member of a complex property.

.PARAMETER Member
    Specifies the member property model.

.PARAMETER SourcePath
    Specifies the expression that holds the complex value the workload returned.

.PARAMETER TargetVariable
    Specifies the hashtable variable that receives the member, without the sigil.

.PARAMETER IndentCount
    Specifies the indentation of the rendered statements.

.PARAMETER IsGraph
    Renders enum members without a ToString call, which the Graph shim makes unnecessary.

.OUTPUTS
    The block.
#>
function New-M365DSCInlineComplexMemberBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Member,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SourcePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $TargetVariable,

        [Parameter()]
        [System.Int32]
        $IndentCount = 12,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IsGraph
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()
    $memberName = $Member.Name

    if ($Member.GraphName -eq '@odata.type')
    {
        $null = $builder.AppendLine("${indent}if (`$null -ne $SourcePath.'@odata.type')")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$$TargetVariable.Add('$memberName', $SourcePath.'@odata.type')")
        $null = $builder.AppendLine("$indent}")

        return $builder.ToString()
    }

    $memberPath = "$SourcePath.$($Member.GraphName)"

    if ($Member.IsComplex)
    {
        $nestedVariable = "complex$memberName"
        $null = $builder.AppendLine((New-M365DSCInlineComplexBlock -Property $Member `
                    -SourcePath $memberPath `
                    -TargetVariable $nestedVariable `
                    -IndentCount $IndentCount `
                    -IsGraph:$IsGraph))
        $null = $builder.AppendLine("$indent`$$TargetVariable.Add('$memberName', `$$nestedVariable)")

        return $builder.ToString()
    }

    if ($Member.FakeKind -in @('DateTime', 'Time'))
    {
        $toString = ".ToUniversalTime().ToString('o')"
        if ($Member.FakeKind -eq 'Time')
        {
            $toString = '.ToString()'
        }

        $null = $builder.AppendLine("${indent}if (`$null -ne $memberPath)")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$$TargetVariable.Add('$memberName', $memberPath$toString)")
        $null = $builder.AppendLine("$indent}")

        return $builder.ToString()
    }

    $valueExpression = $memberPath
    if ($Member.IsEnum -and -not $IsGraph)
    {
        $valueExpression = "$memberPath.ToString()"
        if ($Member.IsArray)
        {
            $valueExpression = "[System.String[]]@($memberPath | ForEach-Object { `$_.ToString() })"
        }
    }
    elseif ($Member.IsArray)
    {
        $valueExpression = "[Array]$memberPath"
    }

    $null = $builder.AppendLine("$indent`$$TargetVariable.Add('$memberName', $valueExpression)")

    return $builder.ToString()
}
