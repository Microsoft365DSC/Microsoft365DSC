<#
.SYNOPSIS
    Emits the three example configurations of a resource: 1-Create, 2-Update and 3-Remove.

.DESCRIPTION
    Unlike the old generator - which wrote the same placeholder into all three files - the
    examples are genuinely distinct: Create uses the desired-state values, Update drifts exactly
    one of them and marks the line with '# Updated Property', and Remove keeps the keys and the
    mandatory properties with Ensure = 'Absent'. Complex properties render as DSC CIM instance
    blocks (MSFT_Xyz { ... }).

.PARAMETER ResourceModel
    Specifies the resource model.

.PARAMETER DestinationFolder
    Specifies the folder receiving 1-Create.ps1, 2-Update.ps1 and 3-Remove.ps1.
#>
function New-M365DSCExampleFile
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DestinationFolder
    )

    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Templates\Example.Template.ps1'

    $examples = @(
        @{ FileName = '1-Create.ps1'; Drift = $false; Ensure = 'Present'; KeysOnly = $false }
        @{ FileName = '2-Update.ps1'; Drift = $true; Ensure = 'Present'; KeysOnly = $false }
        @{ FileName = '3-Remove.ps1'; Drift = $false; Ensure = 'Absent'; KeysOnly = $true }
    )

    foreach ($example in $examples)
    {
        $valueBlock = New-M365DSCExampleValueBlock -ResourceModel $ResourceModel `
            -Drift $example.Drift `
            -Ensure $example.Ensure `
            -KeysOnly $example.KeysOnly

        $tokens = @{
            ResourceName = $ResourceModel.ResourceName
            FakeValues   = $valueBlock
        }

        $destination = Join-Path -Path $DestinationFolder -ChildPath $example.FileName
        Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens -DestinationPath $destination
    }
}

<#
.SYNOPSIS
    Turns the generic string placeholder into one that names the property it belongs to.

.DESCRIPTION
    Recurses into arrays and into the members of a complex value.

.PARAMETER Property
    Specifies the property model the value belongs to.

.PARAMETER Value
    Specifies the value produced by Get-M365DSCFakeValue.
#>
function ConvertTo-M365DSCExampleStringValue
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter()]
        [System.Object]
        $Value
    )

    if ($Value -is [System.Collections.IDictionary])
    {
        $result = @{}
        foreach ($key in @($Value.Keys))
        {
            $member = $Property.Members | Where-Object -FilterScript { $_.Name -eq $key } | Select-Object -First 1
            $result[$key] = if ($null -eq $member)
            {
                $Value[$key]
            }
            else
            {
                ConvertTo-M365DSCExampleStringValue -Property $member -Value $Value[$key]
            }
        }

        return $result
    }

    if ($Value -is [System.Array])
    {
        return @($Value | ForEach-Object { ConvertTo-M365DSCExampleStringValue -Property $Property -Value $_ })
    }

    if ($Value -isnot [System.String])
    {
        return $Value
    }

    if ($Value -match '^FakeString(Array)?Value(?<drift>Drift)?(?<index>\d*)$')
    {
        $suffix = ''
        if ($Matches['drift'])
        {
            $suffix = '-Updated'
        }

        return "M365DSC-$($Property.Name)$suffix$($Matches['index'])"
    }

    return $Value
}

<#
.SYNOPSIS
    Renders the property assignments of one example resource block.
#>
function New-M365DSCExampleValueBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.Boolean]
        $Drift = $false,

        [Parameter()]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Boolean]
        $KeysOnly = $false
    )

    $indent = ' ' * 12
    $entries = [ordered]@{}

    $driftedName = $null
    if ($Drift)
    {
        $candidates = @($ResourceModel.SchemaProperties | Where-Object -FilterScript {
                -not $_.IsKey -and -not $_.IsMandatory -and -not $_.IsComplex -and
                $_.Name -ne $ResourceModel.AlternativeKey -and $null -ne $_.DriftValue -and
                -not (Test-M365DSCExampleIdentifier -Property $_ -ResourceModel $ResourceModel)
            })

        $drifted = $candidates | Where-Object -FilterScript { $_.FakeKind -eq 'String' -and -not $_.IsArray } | Select-Object -First 1
        if ($null -eq $drifted)
        {
            $drifted = $candidates | Where-Object -FilterScript { -not $_.IsArray } | Select-Object -First 1
        }
        if ($null -eq $drifted)
        {
            $drifted = $candidates | Select-Object -First 1
        }

        if ($null -ne $drifted)
        {
            $driftedName = $drifted.Name
        }
    }

    foreach ($property in $ResourceModel.SchemaProperties)
    {
        if (Test-M365DSCExampleIdentifier -Property $property -ResourceModel $ResourceModel)
        {
            continue
        }

        # Mandatory becomes Required in the MOF, but a keys-only remove example does not compile.
        if ($KeysOnly -and -not $property.IsKey -and -not $property.IsMandatory -and
            $property.Name -ne $ResourceModel.AlternativeKey)
        {
            continue
        }

        $value = $property.FakeValue
        if ($property.Name -eq $driftedName)
        {
            $value = $property.DriftValue
        }

        if ($null -eq $value)
        {
            continue
        }

        $value = ConvertTo-M365DSCExampleStringValue -Property $property -Value $value
        $entries[$property.Name] = ConvertTo-M365DSCExampleValue -Property $property -Value $value -IndentCount 12
    }

    if (-not $ResourceModel.IsSingleInstance)
    {
        $entries['Ensure'] = "`"$Ensure`""
    }
    else
    {
        $reordered = [ordered]@{ IsSingleInstance = '"Yes"' }
        foreach ($entryName in $entries.Keys)
        {
            $reordered[$entryName] = $entries[$entryName]
        }

        $entries = $reordered
    }

    $entries['ApplicationId'] = '$ApplicationId'
    $entries['TenantId'] = '$TenantId'
    $entries['CertificateThumbprint'] = '$CertificateThumbprint'

    $longestName = ($entries.Keys | Measure-Object -Property Length -Maximum).Maximum
    $builder = [System.Text.StringBuilder]::new()
    foreach ($entryName in $entries.Keys)
    {
        $padding = ' ' * ($longestName - $entryName.Length)
        $null = $builder.AppendLine('')
        # Every property line ends with a semicolon - including the closing line of a CIM
        # instance value, but never the lines inside one.
        $null = $builder.Append("$indent$entryName$padding = $($entries[$entryName]);")

        if ($entryName -eq $driftedName)
        {
            $null = $builder.Append(' # Updated Property')
        }
    }

    return $builder.ToString()
}

<#
.SYNOPSIS
    Renders one example value; complex properties become DSC CIM instance blocks.
#>
function ConvertTo-M365DSCExampleValue
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $Value,

        [Parameter()]
        [System.Int32]
        $IndentCount = 12
    )

    if (-not $Property.IsComplex)
    {
        return (ConvertTo-M365DSCPSLiteral -Value $Value -IndentCount $IndentCount -DoubleQuoteStrings)
    }

    $indent = ' ' * $IndentCount
    $childIndent = ' ' * ($IndentCount + 4)
    $grandChildIndent = ' ' * ($IndentCount + 8)

    $instances = @($Value)
    $builder = [System.Text.StringBuilder]::new()

    if ($Property.IsArray)
    {
        $null = $builder.AppendLine('@(')
    }

    foreach ($instance in $instances)
    {
        $instanceIndent = $indent
        $memberIndent = $childIndent
        if ($Property.IsArray)
        {
            $instanceIndent = $childIndent
            $memberIndent = $grandChildIndent
            $null = $builder.AppendLine("$instanceIndent$($Property.CimClassName){")
        }
        else
        {
            # Single instance: the class name continues the '<Name> = ' line, so no leading
            # indent, and the opening brace sits directly against the class name.
            $null = $builder.AppendLine("$($Property.CimClassName){")
        }

        $memberEntries = [ordered]@{}
        foreach ($member in $Property.Members)
        {
            if ($instance -is [System.Collections.IDictionary] -and $instance.Contains($member.Name) -and $null -ne $instance[$member.Name])
            {
                $memberEntries[$member.Name] = ConvertTo-M365DSCExampleValue -Property $member -Value $instance[$member.Name] -IndentCount ($IndentCount + 8)
            }
        }

        $longestName = 1
        if ($memberEntries.Count -gt 0)
        {
            $longestName = ($memberEntries.Keys | Measure-Object -Property Length -Maximum).Maximum
        }

        foreach ($memberName in $memberEntries.Keys)
        {
            $padding = ' ' * ($longestName - $memberName.Length)
            $null = $builder.AppendLine("$memberIndent$memberName$padding = $($memberEntries[$memberName])")
        }

        $null = $builder.AppendLine("$instanceIndent}")
    }

    if ($Property.IsArray)
    {
        $null = $builder.Append("$indent)")
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Tells whether a property is the service generated identifier rather than a setting.

.PARAMETER Property
    Specifies the property model.

.PARAMETER ResourceModel
    Specifies the resource model.

.OUTPUTS
    True when the property is the identifier and the resource keys on something else.
#>
function Test-M365DSCExampleIdentifier
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    return (-not $Property.IsKey -and
        $Property.Name -eq $ResourceModel.PrimaryKey -and
        $null -ne $ResourceModel.AlternativeKey)
}
