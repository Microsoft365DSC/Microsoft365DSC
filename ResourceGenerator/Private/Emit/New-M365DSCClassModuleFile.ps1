<#
.SYNOPSIS
    Emits the MSFT_<ResourceName>.psm1 class module from the resource model.

.DESCRIPTION
    Builds every token of Templates\ClassResource.Template.psm1 - property block, Get() lookup,
    Set() invocations, Export() enumeration, embedded CIM classes and per-resource helper
    functions - and expands the template in a single pass.

.PARAMETER ResourceModel
    Specifies the resource model.

.PARAMETER DestinationPath
    Specifies the .psm1 file to write. When omitted the content is returned as a string.
#>
function New-M365DSCClassModuleFile
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.String]
        $DestinationPath
    )

    $cimClassBlocks = @()
    foreach ($complexClass in $ResourceModel.ComplexTypeClasses)
    {
        $cimClassBlocks += "class $($complexClass.CimClassName)`r`n{`r`n" +
        (New-M365DSCClassPropertyBlock -Properties $complexClass.Members) +
        "`r`n}"
    }

    $tokens = @{
        ResourceName           = $ResourceModel.ResourceName
        ResourceDescription    = $ResourceModel.ResourceDescription
        PrimaryKey             = $ResourceModel.PrimaryKey
        Workload               = Get-M365DSCConnectionWorkload -Workload $ResourceModel.Workload
        HasEnsure              = -not $ResourceModel.IsSingleInstance
        PropertyBlock          = New-M365DSCClassPropertyBlock -Properties $ResourceModel.Properties
        ExportOnlyPropertyBlock = New-M365DSCExportOnlyPropertyBlock -ResourceModel $ResourceModel
        GetInstanceBlock       = New-M365DSCGetInstanceBlock -ResourceModel $ResourceModel
        ComplexConversionBlock = New-M365DSCComplexConversionBlock -ResourceModel $ResourceModel
        HashtableMappingBlock  = New-M365DSCHashtableMappingBlock -ResourceModel $ResourceModel
        SetPreambleBlock       = New-M365DSCSetPreambleBlock -ResourceModel $ResourceModel
        NewInvocationBlock     = New-M365DSCSetInvocationBlock -ResourceModel $ResourceModel -Operation 'New'
        UpdateInvocationBlock  = New-M365DSCSetInvocationBlock -ResourceModel $ResourceModel -Operation 'Update'
        RemoveInvocationBlock  = New-M365DSCSetInvocationBlock -ResourceModel $ResourceModel -Operation 'Remove'
        ExportGetAllBlock      = New-M365DSCExportGetAllBlock -ResourceModel $ResourceModel
        ExportParameterBlock   = New-M365DSCExportParameterBlock -ResourceModel $ResourceModel
        ExportComplexToStringBlock = New-M365DSCExportComplexToStringBlock -ResourceModel $ResourceModel
        ExportedInstanceLabel  = $ResourceModel.PrimaryKey
        AssignmentsGetBlock    = New-M365DSCAssignmentsGetBlock -ResourceModel $ResourceModel
        CompareParametersBlock = New-M365DSCCompareParametersBlock -ResourceModel $ResourceModel
        NoEscapeArgument       = ''
        CimInstanceClassBlock  = ($cimClassBlocks -join "`r`n`r`n")
    }

    if ($null -ne $ResourceModel.AlternativeKey)
    {
        $tokens.ExportedInstanceLabel = $ResourceModel.AlternativeKey
    }

    $complexPropertyNames = @($ResourceModel.SchemaProperties | Where-Object { $_.IsComplex }).Name
    if ($complexPropertyNames.Count -gt 0)
    {
        $quotedNames = "'" + ($complexPropertyNames -join "', '") + "'"
        $tokens.NoEscapeArgument = " ```r`n                    -NoEscape @($quotedNames)"
    }

    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Templates\ClassResource.Template.psm1'

    if ($PSBoundParameters.ContainsKey('DestinationPath'))
    {
        return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens -DestinationPath $DestinationPath)
    }

    return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens)
}

<#
.SYNOPSIS
    Maps a cmdlet key parameter to the $this property that supplies its value.
#>
function Get-M365DSCKeyArgumentString
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter()]
        [System.String[]]
        $Keys = @(),

        [Parameter()]
        [System.String[]]
        $SkipKeys = @(),

        [Parameter()]
        [System.String]
        $ObjectVariable = '$this'
    )

    $arguments = @()
    foreach ($key in $Keys)
    {
        if ($key -in $SkipKeys)
        {
            continue
        }

        $propertyName = $ResourceModel.PrimaryKey

        $matchingProperty = $ResourceModel.SchemaProperties | Where-Object -FilterScript { $_.Name -eq $key } | Select-Object -First 1
        if ($null -ne $matchingProperty)
        {
            $propertyName = $matchingProperty.Name
        }
        elseif ($key -notlike '*Id')
        {
            Write-Warning -Message "Key parameter '$key' has no matching resource property; mapping it to the primary key '$($ResourceModel.PrimaryKey)'. Review the generated code."
        }

        $arguments += "-$key $ObjectVariable.$propertyName"
    }

    return ($arguments -join ' ')
}

<#
.SYNOPSIS
    Renders the primary-key lookup (plus the alternative-key fallback) inside Get().
#>
function New-M365DSCGetInstanceBlock
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
        $IndentCount = 16,

        [Parameter()]
        [System.String]
        $VariableName = 'getValue'
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()
    $cmdlets = $ResourceModel.Cmdlets
    $getCmdlet = $cmdlets.GetCmdlet
    $primaryKey = $ResourceModel.PrimaryKey

    $isGraph = $ResourceModel.Workload -in @('MicrosoftGraph', 'Intune')
    if (-not $isGraph -and $cmdlets.ContainsKey('GetLookup') -and $null -ne $cmdlets.GetLookup)
    {
        return New-M365DSCGenericGetInstanceBlock -ResourceModel $ResourceModel -IndentCount $IndentCount -VariableName $VariableName
    }

    $keyArguments = Get-M365DSCKeyArgumentString -ResourceModel $ResourceModel -Keys $cmdlets.GetKeyParameters
    if ([System.String]::IsNullOrEmpty($keyArguments))
    {
        $keyArguments = "-Identity `$this.$primaryKey"
    }

    # Class methods parse-check variable assignment; $getValue must exist unconditionally.
    $null = $builder.AppendLine("$indent`$getValue = `$null")
    $null = $builder.AppendLine("${indent}if (-not [System.String]::IsNullOrEmpty(`$this.$primaryKey))")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    `$getValue = $getCmdlet $keyArguments ``")
    $null = $builder.AppendLine("$indent        -ErrorAction SilentlyContinue")
    $null = $builder.AppendLine("$indent}")

    # Fallback lookup by the alternative key (usually DisplayName) when the id is unknown.
    if ($null -ne $ResourceModel.AlternativeKey)
    {
        $alternativeKey = $ResourceModel.AlternativeKey
        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("${indent}if (`$null -eq `$getValue -and -not [System.String]::IsNullOrEmpty(`$this.$alternativeKey))")
        $null = $builder.AppendLine("$indent{")

        if ($cmdlets.SupportsFilter)
        {
            $filterExpression = "$alternativeKey eq '`$(`$this.$alternativeKey -replace `"'`", `"''`")'"
            if ($ResourceModel.IsAdditionalProperty)
            {
                $filterExpression += " and isof('microsoft.graph.$($ResourceModel.SelectedODataType)')"
            }

            $null = $builder.AppendLine("$indent    `$getValue = $getCmdlet ``")
            $null = $builder.AppendLine("$indent        -Filter `"$filterExpression`" ``")
            $null = $builder.AppendLine("$indent        -ErrorAction SilentlyContinue | Select-Object -First 1")
        }
        else
        {
            $null = $builder.AppendLine("$indent    `$getValue = $getCmdlet -ErrorAction SilentlyContinue | Where-Object ``")
            $null = $builder.AppendLine("$indent        -FilterScript { `$_.$alternativeKey -eq `$this.$alternativeKey } | Select-Object -First 1")
        }

        $null = $builder.AppendLine("$indent}")
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Renders the Get() lookup of a non-Graph resource according to its lookup mode.

.DESCRIPTION
    Copies the key into a local, because $this does not resolve inside a Where-Object block.

.PARAMETER ResourceModel
    Specifies the resource model.

.PARAMETER IndentCount
    Specifies the indentation of the rendered lines.

.PARAMETER VariableName
    Specifies the variable receiving the service object.
#>
function New-M365DSCGenericGetInstanceBlock
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
        $IndentCount = 16,

        [Parameter()]
        [System.String]
        $VariableName = 'getValue'
    )

    $indent = ' ' * $IndentCount
    $getCmdlet = $ResourceModel.Cmdlets.GetCmdlet
    $primaryKey = $ResourceModel.PrimaryKey
    $lookup = $ResourceModel.Cmdlets.GetLookup
    $keyMatch = "Where-Object -FilterScript { `$_.$primaryKey -eq `$lookupKey } | Select-Object -First 1"

    $lines = @(
        "$indent`$$VariableName = `$null"
        "${indent}if (-not [System.String]::IsNullOrEmpty(`$this.$primaryKey))"
        "$indent{"
    )

    switch ($lookup.Mode)
    {
        'Direct'
        {
            $lines += "$indent    `$$VariableName = $getCmdlet -$($lookup.Parameter) `$this.$primaryKey -ErrorAction SilentlyContinue"
        }
        'NameFilter'
        {
            $lines += "$indent    `$lookupKey = `$this.$primaryKey"
            $lines += "$indent    `$$VariableName = $getCmdlet -NameFilter `$lookupKey -ErrorAction SilentlyContinue |"
            $lines += "$indent        $keyMatch"
        }
        'List'
        {
            $lines += "$indent    `$lookupKey = `$this.$primaryKey"
            $lines += "$indent    `$$VariableName = $getCmdlet -ErrorAction SilentlyContinue |"
            $lines += "$indent        $keyMatch"
        }
        default
        {
            Write-Warning -Message "Cmdlet '$getCmdlet' does not exist; the generated lookup in Get() needs manual attention."
            $lines += "$indent    `$$VariableName = $getCmdlet -ErrorAction SilentlyContinue"
        }
    }

    $lines += "$indent}"

    return ($lines -join "`r`n")
}

<#
.SYNOPSIS
    Renders the body of one Set() branch (create, update or remove).
#>
function New-M365DSCSetInvocationBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel,

        [Parameter(Mandatory = $true)]
        [ValidateSet('New', 'Update', 'Remove')]
        [System.String]
        $Operation
    )

    $indent = ' ' * 16
    $builder = [System.Text.StringBuilder]::new()
    $cmdlets = $ResourceModel.Cmdlets
    $isGraph = $ResourceModel.Workload -in @('MicrosoftGraph', 'Intune')
    $primaryKey = $ResourceModel.PrimaryKey

    $targetVariable = '$this'
    if ($Operation -in @('Update', 'Remove'))
    {
        $targetVariable = '$currentInstance'
    }

    switch ($Operation)
    {
        'Remove'
        {
            if (-not $isGraph -and $cmdlets.ContainsKey('RemoveKeyParameters') -and @($cmdlets.RemoveKeyParameters).Count -gt 0)
            {
                $null = $builder.AppendLine((New-M365DSCGetInstanceBlock -ResourceModel $ResourceModel -IndentCount 16 -VariableName 'instanceToRemove'))
                $null = $builder.AppendLine('')

                $removeArguments = @($cmdlets.RemoveKeyParameters | ForEach-Object -Process { "-$_ `$instanceToRemove.$_" })
                if ($cmdlets.RemoveSupportsConfirm)
                {
                    $removeArguments += '-Confirm:$false'
                }

                $null = $builder.AppendLine("$indent$($cmdlets.RemoveCmdlet) $($removeArguments -join ' ') | Out-Null")
                break
            }

            $keyArguments = Get-M365DSCKeyArgumentString -ResourceModel $ResourceModel -Keys $cmdlets.RemoveKeyParameters -ObjectVariable $targetVariable
            if ([System.String]::IsNullOrEmpty($keyArguments))
            {
                $keyArguments = "-Identity $targetVariable.$primaryKey -Confirm:`$false"
            }

            $null = $builder.AppendLine("$indent$($cmdlets.RemoveCmdlet) $keyArguments | Out-Null")
        }
        'New'
        {
            $variableName = 'createParameters'
            $cmdletName = $cmdlets.NewCmdlet
            $bodyKeys = $cmdlets.NewKeyParameters
        }
        'Update'
        {
            $variableName = 'updateParameters'
            $cmdletName = $cmdlets.UpdateCmdlet
            $bodyKeys = $cmdlets.UpdateKeyParameters
        }
    }

    if ($Operation -eq 'Remove')
    {
        return $builder.ToString().TrimEnd()
    }

    $null = $builder.AppendLine("$indent`$$variableName = `$boundParameters")

    if ($Operation -eq 'Update')
    {
        foreach ($createOnly in @($ResourceModel.CreateOnlyProperties | Sort-Object -Unique))
        {
            if ([System.String]::IsNullOrEmpty($createOnly))
            {
                continue
            }

            $null = $builder.AppendLine("$indent`$$variableName.Remove('$createOnly') | Out-Null")
        }

        $updateParameterNames = @($cmdlets.UpdateParameterNames)
        if (-not $isGraph -and $updateParameterNames.Count -gt 0)
        {
            foreach ($property in $ResourceModel.SchemaProperties)
            {
                if ($property.Name -notin $updateParameterNames -and $property.Name -notin $ResourceModel.CreateOnlyProperties)
                {
                    $null = $builder.AppendLine("$indent`$$variableName.Remove('$($property.Name)') | Out-Null")
                }
            }

            if ($primaryKey -notin $updateParameterNames -and 'Identity' -in $updateParameterNames)
            {
                $null = $builder.AppendLine("$indent`$$variableName.Identity = `$this.$primaryKey")
            }
        }
    }

    if ($isGraph)
    {
        $keyArguments = Get-M365DSCKeyArgumentString -ResourceModel $ResourceModel -Keys $bodyKeys -SkipKeys @('BodyParameter') -ObjectVariable $targetVariable
        $argumentList = @()
        if (-not [System.String]::IsNullOrEmpty($keyArguments))
        {
            $argumentList += $keyArguments
        }
        $argumentList += "-BodyParameter `$$variableName"

        $null = $builder.AppendLine('')

        if ($ResourceModel.HasAssignments -and $Operation -eq 'New')
        {
            $null = $builder.AppendLine("$indent`$createdInstance = $cmdletName $($argumentList -join ' ')")
            $null = $builder.Append((New-M365DSCAssignmentsSetBlock -ResourceModel $ResourceModel -PolicyIdExpression '$createdInstance.Id'))
            $null = $builder.AppendLine('')
        }
        elseif ($ResourceModel.HasAssignments -and $Operation -eq 'Update')
        {
            $null = $builder.AppendLine("$indent$cmdletName $($argumentList -join ' ') | Out-Null")
            $null = $builder.Append((New-M365DSCAssignmentsSetBlock -ResourceModel $ResourceModel -PolicyIdExpression "$targetVariable.$primaryKey"))
            $null = $builder.AppendLine('')
        }
        else
        {
            $null = $builder.AppendLine("$indent$cmdletName $($argumentList -join ' ') | Out-Null")
        }
    }
    else
    {
        if ($Operation -eq 'New')
        {
            # Most New- cmdlets refuse an explicit key when it doubles as the identity.
            $keyProperty = $ResourceModel.SchemaProperties | Where-Object -FilterScript { $_.Name -eq $primaryKey } | Select-Object -First 1
            if ($null -ne $keyProperty -and -not $keyProperty.IsMandatory -and $primaryKey -eq 'Identity')
            {
                $null = $builder.AppendLine("$indent`$$variableName.Remove('$primaryKey') | Out-Null")
            }
        }

        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("$indent$cmdletName @$variableName | Out-Null")
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Renders the export-only property declarations.
#>
function New-M365DSCExportOnlyPropertyBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $declarations = @()

    if ($ResourceModel.Cmdlets.SupportsFilter)
    {
        $declarations += '[System.String] $Filter'
    }

    if (@($ResourceModel.Properties | Where-Object { $_.Name -eq 'ApplicationSecret' }).Count -eq 0)
    {
        $declarations += '[System.Management.Automation.PSCredential] $ApplicationSecret'
    }

    $indent = ' ' * 4
    $blocks = @()
    foreach ($declaration in $declarations)
    {
        $blocks += "$indent# Export-only. Not part of the resource schema.`r`n$indent$declaration"
    }

    return ($blocks -join "`r`n`r`n")
}

<#
.SYNOPSIS
    Renders the enumeration at the top of Export().
#>
function New-M365DSCExportGetAllBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $indent = ' ' * 12
    $cmdlets = $ResourceModel.Cmdlets
    $arguments = @()
    $prelude = ''

    $cachedCollections = @{
        'Get-MgBetaDeviceManagementDeviceConfiguration'           = 'deviceConfigurations'
        'Get-MgBetaDeviceManagementDeviceCompliancePolicy'        = 'deviceCompliancePolicies'
        'Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration' = 'deviceEnrollmentConfigurations'
    }
    if ($ResourceModel.IsAdditionalProperty -and $cachedCollections.ContainsKey($cmdlets.GetCmdlet))
    {
        return "$indent[array] `$exportedInstances = Get-M365DSCExportCachedCollection -Collection '$($cachedCollections[$cmdlets.GetCmdlet])' ``" + "`r`n" +
        "$indent    -ODataType 'microsoft.graph.$($ResourceModel.SelectedODataType)' ``" + "`r`n" +
        "$indent    -Filter `$this.Filter"
    }

    if ($cmdlets.SupportsAll)
    {
        $arguments += '-All'
    }

    if ($ResourceModel.HasAssignments)
    {
        $arguments += "-ExpandProperty 'assignments'"
    }

    if ($cmdlets.SupportsFilter)
    {
        if ($ResourceModel.IsAdditionalProperty)
        {
            $prelude = "$indent`$baseFilter = `"isof('microsoft.graph.$($ResourceModel.SelectedODataType)')`"`r`n" +
            "$indent`$mergedFilter = `$baseFilter`r`n" +
            "$indent" + 'if (-not [System.String]::IsNullOrEmpty($this.Filter))' + "`r`n" +
            "$indent{`r`n" +
            "$indent    `$mergedFilter = `"(`$baseFilter) and (`$(`$this.Filter))`"`r`n" +
            "$indent}`r`n"
            $arguments += '-Filter $mergedFilter'
        }
        else
        {
            $filterParameterName = 'Filter'
            if ($cmdlets.ContainsKey('FilterParameterName') -and -not [System.String]::IsNullOrEmpty($cmdlets.FilterParameterName))
            {
                $filterParameterName = $cmdlets.FilterParameterName
            }

            if ($cmdlets.ContainsKey('SupportsPaging') -and $cmdlets.SupportsPaging)
            {
                return New-M365DSCExportPagedGetAllBlock -GetCmdlet $cmdlets.GetCmdlet -FilterParameterName $filterParameterName
            }

            $arguments += "-$filterParameterName `$this.Filter"
        }
    }
    elseif ($cmdlets.ContainsKey('SupportsPaging') -and $cmdlets.SupportsPaging)
    {
        return New-M365DSCExportPagedGetAllBlock -GetCmdlet $cmdlets.GetCmdlet
    }

    $argumentString = ''
    if ($arguments.Count -gt 0)
    {
        $argumentString = ' ' + ($arguments -join ' ')
    }

    return $prelude + "$indent[array] `$exportedInstances = $($cmdlets.GetCmdlet)$argumentString ``" + "`r`n" +
    "$indent    -ErrorAction Stop"
}

<#
.SYNOPSIS
    Renders an Export() enumeration that pages through a list cmdlet with -First and -Skip.

.PARAMETER GetCmdlet
    Specifies the list cmdlet.

.PARAMETER FilterParameterName
    Specifies the list cmdlet parameter that receives $this.Filter, if any.
#>
function New-M365DSCExportPagedGetAllBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $GetCmdlet,

        [Parameter()]
        [System.String]
        $FilterParameterName
    )

    $indent = ' ' * 12
    $lines = @(
        "$indent`$getParameters = @{"
        "$indent    First       = 100"
        "$indent    ErrorAction = 'Stop'"
        "$indent}"
    )

    if (-not [System.String]::IsNullOrEmpty($FilterParameterName))
    {
        $lines += @(
            "$indent" + 'if (-not [System.String]::IsNullOrEmpty($this.Filter))'
            "$indent{"
            "$indent    `$getParameters.$FilterParameterName = `$this.Filter"
            "$indent}"
        )
    }

    $lines += @(
        ''
        "$indent[array] `$exportedInstances = @()"
        "$indent`$currentBatch = `$null"
        "$indent`$offset = 0"
        "${indent}do"
        "$indent{"
        "$indent    [array] `$currentBatch = $GetCmdlet @getParameters -Skip `$offset"
        "$indent    if (`$null -ne `$currentBatch)"
        "$indent    {"
        "$indent        `$exportedInstances += `$currentBatch"
        "$indent        `$offset += `$currentBatch.Count"
        "$indent    }"
        "$indent} while (`$currentBatch.Count -eq 100)"
    )

    return ($lines -join "`r`n")
}

<#
.SYNOPSIS
    Renders the $Params hashtable inside the Export() loop.
#>
function New-M365DSCExportParameterBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $indent = ' ' * 20
    $builder = [System.Text.StringBuilder]::new()

    $entries = [ordered]@{}
    $entries[$ResourceModel.PrimaryKey] = "`$exportedInstance.$($ResourceModel.PrimaryKey)"
    if ($ResourceModel.IsSingleInstance)
    {
        $entries['IsSingleInstance'] = "'Yes'"
    }
    if ($null -ne $ResourceModel.AlternativeKey)
    {
        $entries[$ResourceModel.AlternativeKey] = "`$exportedInstance.$($ResourceModel.AlternativeKey)"
    }

    foreach ($authProperty in ($ResourceModel.Properties | Where-Object { $_.IsAuth }))
    {
        $entries[$authProperty.Name] = "`$this.$($authProperty.Name)"
    }

    $longestName = ($entries.Keys | Measure-Object -Property Length -Maximum).Maximum
    foreach ($entryName in $entries.Keys)
    {
        $padding = ' ' * ($longestName - $entryName.Length)
        $null = $builder.AppendLine("$indent$entryName$padding = $($entries[$entryName])")
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Renders the complex-property to string conversions inside the Export() loop.
#>
function New-M365DSCExportComplexToStringBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $indent = ' ' * 16
    $builder = [System.Text.StringBuilder]::new()

    foreach ($property in ($ResourceModel.SchemaProperties | Where-Object { $_.IsComplex }))
    {
        $name = $property.Name
        $null = $builder.AppendLine("${indent}if (`$null -ne `$Results.$name)")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$complexTypeStringResult = Get-M365DSCDRGComplexTypeToString ``")
        $null = $builder.AppendLine("$indent        -ComplexObject `$Results.$name ``")
        $null = $builder.AppendLine("$indent        -CIMInstanceName '$($property.CimClassName)'")
        $null = $builder.AppendLine("$indent    if (-not [System.String]::IsNullOrWhiteSpace(`$complexTypeStringResult))")
        $null = $builder.AppendLine("$indent    {")
        $null = $builder.AppendLine("$indent        `$Results.$name = `$complexTypeStringResult")
        $null = $builder.AppendLine("$indent    }")
        $null = $builder.AppendLine("$indent    else")
        $null = $builder.AppendLine("$indent    {")
        $null = $builder.AppendLine("$indent        `$Results.Remove('$name') | Out-Null")
        $null = $builder.AppendLine("$indent    }")
        $null = $builder.AppendLine("$indent}")
        $null = $builder.AppendLine('')
    }

    return $builder.ToString().TrimEnd()
}

<#
.SYNOPSIS
    Maps a generator workload to the workload New-M365DSCConnection accepts.

.PARAMETER Workload
    Specifies the workload of the resource model.

.OUTPUTS
    The connection workload.
#>
function Get-M365DSCConnectionWorkload
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Workload
    )

    if ($Workload -eq 'Intune')
    {
        return 'MicrosoftGraph'
    }

    return $Workload
}

<#
.SYNOPSIS
    Renders the GetCompareParameters() override that keeps the create-only properties out of Test().

.PARAMETER ResourceModel
    Specifies the resource model.

.OUTPUTS
    The block, or an empty string when the resource has no create-only property.
#>
function New-M365DSCCompareParametersBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $names = @($ResourceModel.CreateOnlyProperties | Where-Object -FilterScript { -not [System.String]::IsNullOrEmpty($_) } | Sort-Object -Unique)
    if ($names.Count -eq 0)
    {
        return ''
    }

    $quoted = "'" + ($names -join "', '") + "'"
    $indent = ' ' * 4
    $builder = [System.Text.StringBuilder]::new()

    $null = $builder.AppendLine("$indent[System.Collections.Hashtable] GetCompareParameters()")
    $null = $builder.AppendLine("$indent{")
    $null = $builder.AppendLine("$indent    return @{")
    $null = $builder.AppendLine("$indent        ExcludedProperties = @($quoted)")
    $null = $builder.AppendLine("$indent    }")
    $null = $builder.Append("$indent}")

    return $builder.ToString()
}

<#
.SYNOPSIS
    Renders the Set() lines that shape $boundParameters for both the create and the update.

.PARAMETER ResourceModel
    Specifies the resource model.

.OUTPUTS
    The block.
#>
function New-M365DSCSetPreambleBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $indent = ' ' * 12
    $builder = [System.Text.StringBuilder]::new()
    $isGraph = $ResourceModel.Workload -in @('MicrosoftGraph', 'Intune')

    $null = $builder.AppendLine("$indent`$boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters `$this.GetBoundParameters()")

    foreach ($payload in @($ResourceModel.TextPayloadProperties | Sort-Object -Unique))
    {
        if ([System.String]::IsNullOrEmpty($payload))
        {
            continue
        }

        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("${indent}if (`$boundParameters.ContainsKey('$payload'))")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$boundParameters.$payload = `$this.EncodeTextPayload(`$this.$payload)")
        $null = $builder.AppendLine("$indent}")
    }

    if (@($ResourceModel.SchemaProperties).Name -contains 'RoleScopeTagIds')
    {
        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("${indent}if (`$boundParameters.ContainsKey('RoleScopeTagIds'))")
        $null = $builder.AppendLine("$indent{")
        $null = $builder.AppendLine("$indent    `$boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds `$this.RoleScopeTagIds")
        $null = $builder.AppendLine("$indent}")
    }

    if ($isGraph)
    {
        $null = $builder.AppendLine('')
        $null = $builder.AppendLine("$indent`$boundParameters = Rename-M365DSCCimInstanceParameter -Properties `$boundParameters")
        $null = $builder.AppendLine("$indent`$boundParameters.Remove('$($ResourceModel.PrimaryKey)') | Out-Null")

        if ($ResourceModel.HasAssignments)
        {
            $null = $builder.AppendLine("$indent`$boundParameters.Remove('Assignments') | Out-Null")
        }

        if ($ResourceModel.IsAdditionalProperty)
        {
            $null = $builder.AppendLine("$indent`$boundParameters.Add('@odata.type', '#microsoft.graph.$($ResourceModel.SelectedODataType)')")
        }
    }

    return $builder.ToString().TrimEnd()
}
