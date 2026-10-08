<#
    Settings catalog resource assembly and emission. The archetype differs from standard Graph
    resources (settings expansion through Export-IntuneSettingCatalogPolicySettings, policy body
    through Get-IntuneSettingCatalogPolicySetting, template-filtered export), so it has its own
    template - Templates\SettingsCatalogResource.Template.psm1, modeled on the shipped
    MSFT_IntuneAntivirusExclusionsPolicyLinux - and its own token builders.
#>

<#
.SYNOPSIS
    Assembles the resource model of a settings catalog resource.
#>
function New-M365DSCSettingsCatalogResourceModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $SettingsCatalogInfo
    )

    $resourceDescriptor = Get-M365DSCResourceDescriptor -ResourceName $ResourceName

    $standardProperties = @(
        New-M365DSCPropertyModel -Name 'Description' -Type 'Edm.String' -Description 'Policy description'
        New-M365DSCPropertyModel -Name 'DisplayName' -Type 'Edm.String' -Description 'Policy name' -IsKey $true
        New-M365DSCPropertyModel -Name 'RoleScopeTagIds' -Type 'Edm.String' -IsArray $true -Description 'List of Scope Tags for this Entity instance.'
        New-M365DSCPropertyModel -Name 'Id' -Type 'Edm.String' -Description 'The unique identifier for an entity. Read-only.'
    )

    # Alphabetical for readability; every downstream artifact renders in model order.
    $schemaProperties = @(
        @($standardProperties) + @($SettingsCatalogInfo.Properties) + (Get-M365DSCAssignmentPropertyModel) |
            Sort-Object -Property Name
    )

    $allProperties = @($schemaProperties)
    $allProperties += New-M365DSCPropertyModel -Name 'Ensure' `
        -Description "Present ensures the $($resourceDescriptor.ShortDescriptor) exists, absent ensures it is removed." `
        -EnumValues @('Present', 'Absent')
    $allProperties += Get-M365DSCAuthPropertySet -Workload 'Intune'

    $cmdlets = @{
        APIVersion             = 'beta'
        ActualType             = 'deviceManagementConfigurationPolicy'
        GetCmdlet              = 'Get-MgBetaDeviceManagementConfigurationPolicy'
        NewCmdlet              = 'New-MgBetaDeviceManagementConfigurationPolicy'
        UpdateCmdlet           = 'Update-IntuneDeviceConfigurationPolicy'
        RemoveCmdlet           = 'Remove-MgBetaDeviceManagementConfigurationPolicy'
        GetKeyParameters       = @('DeviceManagementConfigurationPolicyId')
        SupportsAll            = $true
        SupportsFilter         = $true
        HasAssignments         = $true
        AssignmentCmdlet       = 'Get-MgBetaDeviceManagementConfigurationPolicyAssignment'
        AssignmentNoun         = 'MgBetaDeviceManagementConfigurationPolicyAssignment'
        AssignmentKeyParameter = 'DeviceManagementConfigurationPolicyId'
        AssignmentRepository   = 'deviceManagement/configurationPolicies'
    }

    return [PSCustomObject]@{
        ResourceName         = $ResourceName
        Workload             = 'Intune'
        ResourceDescription  = $resourceDescriptor.Description
        ResourceDescriptor   = $resourceDescriptor.ShortDescriptor
        PrimaryKey           = 'DisplayName'
        AlternativeKey       = $null
        SelectedODataType    = $null
        IsAdditionalProperty = $false
        IsSingleInstance     = $false
        Cmdlets              = $cmdlets
        Properties           = $allProperties
        SchemaProperties     = $schemaProperties
        ComplexTypeClasses   = @(Get-M365DSCComplexTypeClass -Properties $schemaProperties)
        HasAssignments       = $true
        SettingsCatalog      = $SettingsCatalogInfo
        CmdLetNoun           = 'MgBetaDeviceManagementConfigurationPolicy'
        CmdLetVerb           = 'New'
        IncludeNavigationProperties = $false
    }
}

<#
.SYNOPSIS
    Emits the settings catalog resource module from its template.
#>
function New-M365DSCSettingsCatalogModuleFile
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

    $complexSettings = @($ResourceModel.SchemaProperties | Where-Object {
            $_.IsComplex -and -not (Test-M365DSCAssignmentProperty -Property $_)
        })

    $noEscapeNames = @($complexSettings.Name) + 'Assignments'

    $containsDeviceAndUserSettingsFlag = ''
    if ($ResourceModel.SettingsCatalog.ContainsDeviceAndUserSettings)
    {
        $containsDeviceAndUserSettingsFlag = ' -ContainsDeviceAndUserSettings'
    }

    $tokens = @{
        ResourceName                = $ResourceModel.ResourceName
        ResourceDescription         = $ResourceModel.ResourceDescription
        PropertyBlock               = New-M365DSCClassPropertyBlock -Properties $ResourceModel.Properties
        TemplateReferenceId         = $ResourceModel.SettingsCatalog.TemplateId
        Platforms                   = $ResourceModel.SettingsCatalog.Platforms
        Technologies                = $ResourceModel.SettingsCatalog.Technologies
        ContainsDeviceAndUserSettingsFlag = $containsDeviceAndUserSettingsFlag
        SettingsConversionBlock     = New-M365DSCSettingsConversionBlock -ComplexSettings $complexSettings
        SettingsComplexMappingBlock = New-M365DSCSettingsComplexMappingBlock -ComplexSettings $complexSettings
        AuthResultBlock             = New-M365DSCSettingsCatalogAuthBlock -ResourceModel $ResourceModel -IndentCount 16
        ExportAuthParameterBlock    = New-M365DSCSettingsCatalogAuthBlock -ResourceModel $ResourceModel -IndentCount 20
        ExportComplexToStringBlock  = New-M365DSCExportComplexToStringBlock -ResourceModel ([PSCustomObject]@{ SchemaProperties = $complexSettings })
        NoEscapeList                = "'" + ($noEscapeNames -join "', '") + "'"
        CimInstanceClassBlock       = ($cimClassBlocks -join "`r`n`r`n")
    }

    $templatePath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Templates\SettingsCatalogResource.Template.psm1'

    if ($PSBoundParameters.ContainsKey('DestinationPath'))
    {
        return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens -DestinationPath $DestinationPath)
    }

    return (Expand-M365DSCTemplate -TemplatePath $templatePath -Tokens $tokens)
}

<#
.SYNOPSIS
    Renders the conversion of complex settings out of the $policySettings hashtable.
#>
function New-M365DSCSettingsConversionBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Object[]]
        $ComplexSettings = @(),

        [Parameter()]
        [System.Int32]
        $IndentCount = 12
    )

    $indent = ' ' * $IndentCount
    $builder = [System.Text.StringBuilder]::new()

    foreach ($setting in $ComplexSettings)
    {
        $name = $setting.Name

        if ($setting.IsArray)
        {
            # Collection setting: one hashtable per instance.
            $null = $builder.AppendLine("$indent`$complex$name = @()")
            $null = $builder.AppendLine("${indent}foreach (`$current$name in `$policySettings.$($setting.GraphName))")
            $null = $builder.AppendLine("$indent{")
            $null = $builder.AppendLine("$indent    `$my$name = [ordered]@{}")

            foreach ($member in $setting.Members)
            {
                if ($member.IsComplex)
                {
                    Write-Warning -Message "Nested complex setting '$($member.Name)' inside '$name' is converted as-is; review the generated Get() conversion."
                }

                $null = $builder.AppendLine("$indent    if (`$null -ne `$current$name.$($member.GraphName))")
                $null = $builder.AppendLine("$indent    {")
                $null = $builder.AppendLine("$indent        `$my$name.Add('$($member.Name)', `$current$name.$($member.GraphName))")
                $null = $builder.AppendLine("$indent    }")
            }

            $null = $builder.AppendLine("$indent    if (`$my$name.values.Where({ `$null -ne `$_ }).Count -gt 0)")
            $null = $builder.AppendLine("$indent    {")
            $null = $builder.AppendLine("$indent        `$complex$name += `$my$name")
            $null = $builder.AppendLine("$indent    }")
            $null = $builder.AppendLine("$indent}")
        }
        else
        {
            # Single instance (e.g. the DeviceSettings/UserSettings wrappers of a split template).
            $null = $builder.AppendLine("$indent`$complex$name = [ordered]@{}")

            foreach ($member in $setting.Members)
            {
                if ($member.IsComplex)
                {
                    Write-Warning -Message "Nested complex setting '$($member.Name)' inside '$name' is converted as-is; review the generated Get() conversion."
                }

                $null = $builder.AppendLine("${indent}if (`$null -ne `$policySettings.$($setting.GraphName).$($member.GraphName))")
                $null = $builder.AppendLine("$indent{")
                $null = $builder.AppendLine("$indent    `$complex$name.Add('$($member.Name)', `$policySettings.$($setting.GraphName).$($member.GraphName))")
                $null = $builder.AppendLine("$indent}")
            }

            $null = $builder.AppendLine("${indent}if (`$complex$name.Values.Where({ `$null -ne `$_ }).Count -eq 0)")
            $null = $builder.AppendLine("$indent{")
            $null = $builder.AppendLine("$indent    `$complex$name = `$null")
            $null = $builder.AppendLine("$indent}")
        }

        $null = $builder.AppendLine("$indent`$policySettings.Remove('$($setting.GraphName)') | Out-Null")
        $null = $builder.AppendLine('')
    }

    return $builder.ToString().TrimEnd("`r", "`n")
}

<#
.SYNOPSIS
    Renders the complex-setting entries of the Get() result hashtable.
#>
function New-M365DSCSettingsComplexMappingBlock
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Object[]]
        $ComplexSettings = @(),

        [Parameter()]
        [System.Int32]
        $IndentCount = 16
    )

    if ($ComplexSettings.Count -eq 0)
    {
        return ''
    }

    $indent = ' ' * $IndentCount
    $lines = foreach ($setting in $ComplexSettings)
    {
        # Aligned with the literal keys in the template (CertificateThumbprint = 21 characters).
        $padding = ' ' * [System.Math]::Max(1, 21 - $setting.Name.Length)
        "$indent$($setting.Name)$padding= `$complex$($setting.Name)"
    }

    return ($lines -join "`r`n")
}

<#
.SYNOPSIS
    Renders the auth-property passthrough entries of a result or export hashtable.
#>
function New-M365DSCSettingsCatalogAuthBlock
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
    $lines = foreach ($authProperty in ($ResourceModel.Properties | Where-Object { $_.IsAuth }))
    {
        $padding = ' ' * [System.Math]::Max(1, 21 - $authProperty.Name.Length)
        "$indent$($authProperty.Name)$padding= `$this.$($authProperty.Name)"
    }

    return ($lines -join "`r`n")
}

<#
.SYNOPSIS
    Builds the unit test tokens specific to the settings catalog archetype.

.DESCRIPTION
    The Get cmdlet mock returns the raw policy object; the settings values come from a mock of
    Export-IntuneSettingCatalogPolicySettings built from the model's fake values. Drift is
    exercised through the policy's Description, which the standard drift context re-mock changes.
#>
function Get-M365DSCSettingsCatalogUnitTestToken
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ResourceModel
    )

    $settingsProperties = @($ResourceModel.SchemaProperties | Where-Object {
            $null -ne $_.PSObject.Properties['IsSettingsCatalogSetting'] -and $_.IsSettingsCatalogSetting
        })

    # The Export-IntuneSettingCatalogPolicySettings mock: graph-named keys with fake values.
    $policySettings = [ordered]@{}
    foreach ($property in $settingsProperties)
    {
        $value = ConvertTo-M365DSCApiShapeValue -Property $property
        if ($null -ne $value)
        {
            $policySettings[$property.GraphName] = $value
        }
    }

    $policyObject = [ordered]@{
        Id              = 'FakeStringValue'
        Name            = 'FakeStringValue'
        Description     = 'FakeStringValue'
        RoleScopeTagIds = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
        settings        = @()
    }
    $driftPolicyObject = [ordered]@{
        Id              = 'FakeStringValue'
        Name            = 'FakeStringValue'
        Description     = 'FakeStringValueDrift'
        RoleScopeTagIds = @('FakeStringArrayValue1', 'FakeStringArrayValue2')
        settings        = @()
    }

    $getMockBody = "                return $(ConvertTo-M365DSCPSLiteral -Value $policyObject -IndentCount 16)"
    $driftGetMockBody = "                    return $(ConvertTo-M365DSCPSLiteral -Value $driftPolicyObject -IndentCount 20)"

    $indent = ' ' * 12
    $mockBuilder = [System.Text.StringBuilder]::new()
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {")
    $null = $mockBuilder.AppendLine("$indent    return @()")
    $null = $mockBuilder.AppendLine("$indent}")
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName Export-IntuneSettingCatalogPolicySettings -MockWith {")
    $null = $mockBuilder.AppendLine("$indent    return $(ConvertTo-M365DSCPSLiteral -Value $policySettings -IndentCount 16)")
    $null = $mockBuilder.AppendLine("$indent}")
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {")
    $null = $mockBuilder.AppendLine("$indent    return @()")
    $null = $mockBuilder.AppendLine("$indent}")
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {")
    $null = $mockBuilder.AppendLine("$indent    return @($(ConvertTo-M365DSCPSLiteral -Value $policyObject -IndentCount 16))")
    $null = $mockBuilder.AppendLine("$indent}")
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName $($ResourceModel.Cmdlets.AssignmentCmdlet) -MockWith {")
    $null = $mockBuilder.AppendLine("$indent}")
    $null = $mockBuilder.AppendLine('')
    $null = $mockBuilder.AppendLine("${indent}Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {")
    $null = $mockBuilder.Append("$indent}")

    return @{
        ResourceName        = $ResourceModel.ResourceName
        HasEnsure           = $true
        GetCmdletName       = $ResourceModel.Cmdlets.GetCmdlet
        NewCmdletName       = $ResourceModel.Cmdlets.NewCmdlet
        SetCmdletName       = $ResourceModel.Cmdlets.UpdateCmdlet
        RemoveCmdletName    = $ResourceModel.Cmdlets.RemoveCmdlet
        GetMockBody         = $getMockBody
        DriftGetMockBody    = $driftGetMockBody
        AdditionalMockBlock = $mockBuilder.ToString()
        TestParamsBlock     = New-M365DSCTestParamsBlock -ResourceModel $ResourceModel
        KeysOnlyParamsBlock = New-M365DSCTestParamsBlock -ResourceModel $ResourceModel -KeysOnly
        PropertyAssertions  = New-M365DSCPropertyAssertionBlock -ResourceModel $ResourceModel
    }
}
