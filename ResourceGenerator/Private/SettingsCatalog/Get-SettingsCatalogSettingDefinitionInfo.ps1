<#
    Settings Catalog setting-definition parsers, ported from the previous generator. They turn
    the raw deviceManagementConfigurationSettingTemplate/settingDefinitions Graph objects into a
    neutral setting tree that ConvertTo-M365DSCSettingsCatalogPropertyModel projects into
    property models. Get-SettingsCatalogSettingName comes from
    Modules\Microsoft365DSC\Modules\M365DSCIntuneSettingsCatalogUtil.psm1 (imported by the
    settings catalog acquisition).
#>

function Get-SettingsCatalogSettingDefinitionValueDefinition
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $SettingDefinition,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingDefinitionOdataTypeBase
    )

    if (-not $SettingDefinition.valueDefinition)
    {
        return $null
    }

    $description = ''
    $max = $null
    $min = $null
    $type = $SettingDefinition.valueDefinition.'@odata.type'.Replace($SettingDefinitionOdataTypeBase, '').Replace('SettingValueDefinition', '')
    switch ($type)
    {
        'String'
        {
            $max = $SettingDefinition.valueDefinition.maximumLength
            $min = $SettingDefinition.valueDefinition.minimumLength
            $description = "Length must be between $min and $max characters."
        }
        'Integer'
        {
            $max = $SettingDefinition.valueDefinition.maximumValue
            $min = $SettingDefinition.valueDefinition.minimumValue
            $description = "Value must be between $min and $max."
        }
    }

    return @{
        Max         = $max
        Min         = $min
        Description = $description
        Type        = $type
    }
}

function Get-SettingsCatalogSettingDefinitionValueOption
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $SettingDefinition,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingDefinitionOdataTypeBase
    )

    $options = @()
    foreach ($option in $SettingDefinition.options)
    {
        $options += @{
            Name        = $option.name
            Id          = $option.optionValue.value
            Type        = $option.optionValue.'@odata.type'.Replace($SettingDefinitionOdataTypeBase, '').Replace('SettingValue', '')
            DisplayName = $option.displayName
        }
    }

    return $options
}

function Get-SettingsCatalogSettingDefinitionDefaultValue
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $SettingDefinition,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingDefinitionOdataTypeBase
    )

    $type = Get-SettingsCatalogSettingDefinitionValueType -SettingDefinition $SettingDefinition -SettingDefinitionOdataTypeBase $SettingDefinitionOdataTypeBase

    # Either they are a "simple" setting or a "choice" setting.
    if ($type -like 'Simple*')
    {
        $value = $SettingDefinition.defaultValue.value
        $nullOrEmpty = [System.String]::IsNullOrEmpty($value)

        switch ($type)
        {
            'String' { if (-not $nullOrEmpty) { return $value } else { return '' } }
            'Integer' { if (-not $nullOrEmpty) { return [System.Int32]::Parse($value) } else { return 0 } }
            # Secret values have no known use case yet.
            'Secret' { if (-not $nullOrEmpty) { return $value } else { return '' } }
            default { return $value }
        }
        return $value
    }
    else
    {
        # For a choice setting the default value is the default option id.
        if (-not [System.String]::IsNullOrEmpty($SettingDefinition.defaultOptionId))
        {
            return $SettingDefinition.defaultOptionId.Split('_')[-1]
        }

        return $null
    }
}

function Get-SettingsCatalogSettingDefinitionValueType
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $SettingDefinition,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingDefinitionOdataTypeBase
    )

    # Type can be Choice, Simple or *Collection.
    $type = $SettingDefinition.'@odata.type'.Replace($SettingDefinitionOdataTypeBase, '').Replace('Setting', '').Replace('Definition', '')
    if ($type -eq 'Choice')
    {
        $type += $SettingDefinition.options[0].optionValue.'@odata.type'.Replace('#microsoft.graph.deviceManagementConfiguration', '').Replace('SettingValue', '')
    }
    elseif ($type -eq 'Simple')
    {
        $type += $SettingDefinition.valueDefinition.'@odata.type'.Replace($SettingDefinitionOdataTypeBase, '').Replace('SettingValueDefinition', '')
    }
    elseif ($type -eq 'SimpleCollection')
    {
        if ($null -ne $SettingDefinition.defaultValue)
        {
            $type = $type.Replace('Collection', $SettingDefinition.defaultValue.'@odata.type'.Replace($SettingDefinitionOdataTypeBase, '').Replace('SettingValue', '') + 'Collection')
        }
        else
        {
            $type = $type.Replace('Collection', 'StringCollection')
        }
    }
    elseif ($type -eq 'ChoiceCollection')
    {
        $valueType = $SettingDefinition.options[0].optionValue.'@odata.type'.Replace('#microsoft.graph.deviceManagementConfiguration', '').Replace('SettingValue', '')
        $type = $type.Replace('Collection', $valueType + 'Collection')
    }
    else
    {
        # GroupCollection has no default value to narrow the type, but the maximum count tells
        # whether it is a collection.
        if ($SettingDefinition.maximumCount -gt 1)
        {
            $type += 'Collection'
        }
    }

    return $type
}

function New-SettingsCatalogSettingDefinitionSettingsFromTemplate
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        $SettingTemplate,

        [Parameter(ParameterSetName = 'ParseRoot')]
        [Parameter(ParameterSetName = 'ParseChild')]
        [System.String]
        $SettingDefinitionIdPrefix,

        [Parameter(ParameterSetName = 'ParseChild')]
        $SettingDefinition,

        [Parameter(ParameterSetName = 'ParseRoot')]
        [System.Array]
        $RootSettingDefinitions,

        [Parameter(ParameterSetName = 'Start')]
        [System.Management.Automation.SwitchParameter]
        $FromRoot,

        [Parameter(Mandatory = $true)]
        [System.Array]
        $AllSettingDefinitions,

        [Parameter(ParameterSetName = 'ParseChild')]
        [System.String]
        $ParentInstanceName,

        [Parameter(ParameterSetName = 'ParseChild')]
        [System.Int32]
        $Level = 0
    )

    $settingDefinitionOdataTypeBase = '#microsoft.graph.deviceManagementConfiguration'
    if ($FromRoot)
    {
        $RootSettingDefinitions = $SettingTemplate.SettingDefinitions | Where-Object -FilterScript {
            $_.Id -eq $SettingTemplate.SettingInstanceTemplate.SettingDefinitionId -and
            ($_.dependentOn.Count -eq 0 -and $_.options.dependentOn.Count -eq 0)
        }
        $settingDefinitionIdPrefix = $SettingTemplate.SettingInstanceTemplate.SettingDefinitionId
        return New-SettingsCatalogSettingDefinitionSettingsFromTemplate `
            -SettingTemplate $SettingTemplate `
            -RootSettingDefinitions $RootSettingDefinitions `
            -SettingDefinitionIdPrefix $settingDefinitionIdPrefix `
            -AllSettingDefinitions $AllSettingDefinitions
    }

    if ($PSCmdlet.ParameterSetName -eq 'ParseRoot')
    {
        $settings = @()
        foreach ($rootSettingDefinition in $RootSettingDefinitions)
        {
            $settings += New-SettingsCatalogSettingDefinitionSettingsFromTemplate `
                -SettingTemplate $SettingTemplate `
                -SettingDefinition $rootSettingDefinition `
                -SettingDefinitionIdPrefix $SettingDefinitionIdPrefix `
                -Level 1 `
                -ParentInstanceName 'MSFT_MicrosoftGraphIntuneSettingsCatalog' `
                -AllSettingDefinitions $AllSettingDefinitions
        }
        return $settings
    }

    $type = Get-SettingsCatalogSettingDefinitionValueType -SettingDefinition $SettingDefinition -SettingDefinitionOdataTypeBase $settingDefinitionOdataTypeBase
    $defaultValue = Get-SettingsCatalogSettingDefinitionDefaultValue -SettingDefinition $SettingDefinition -SettingDefinitionOdataTypeBase $settingDefinitionOdataTypeBase
    $options = Get-SettingsCatalogSettingDefinitionValueOption -SettingDefinition $SettingDefinition -SettingDefinitionOdataTypeBase $settingDefinitionOdataTypeBase
    $valueRestriction = Get-SettingsCatalogSettingDefinitionValueDefinition -SettingDefinition $SettingDefinition -SettingDefinitionOdataTypeBase $settingDefinitionOdataTypeBase

    $settingName = Get-SettingsCatalogSettingName -SettingDefinition $SettingDefinition -AllSettingDefinitions $AllSettingDefinitions

    $childSettings = @()
    $childSettings += $SettingTemplate.SettingDefinitions | Where-Object -FilterScript {
        $_.visibility -notlike '*none*' -and
        (($_.dependentOn.Count -gt 0 -and $_.dependentOn.parentSettingId -contains $SettingDefinition.Id) -or
        ($_.options.dependentOn.Count -gt 0 -and $_.options.dependentOn.parentSettingId -contains $SettingDefinition.Id))
    }

    $instanceName = 'MSFT_MicrosoftGraphIntuneSettingsCatalog'
    if (($Level -gt 1 -and $type -like 'GroupCollection*' -and $childSettings.Count -gt 1) -or
        ($Level -eq 1 -and $type -eq 'GroupCollectionCollection' -and $childSettings.Count -ge 1 -and $childSettings.'@odata.type' -notcontains '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'))
    {
        $instanceName = $ParentInstanceName + $settingName
    }

    $innerChildSettings = @()
    foreach ($childSetting in $childSettings)
    {
        $innerChildSettings += New-SettingsCatalogSettingDefinitionSettingsFromTemplate `
            -SettingTemplate $SettingTemplate `
            -SettingDefinition $childSetting `
            -SettingDefinitionIdPrefix $SettingDefinitionIdPrefix `
            -Level ($Level + 1) `
            -ParentInstanceName $instanceName `
            -AllSettingDefinitions $AllSettingDefinitions
    }

    $setting = [ordered]@{
        Name             = $settingName
        DisplayName      = $SettingDefinition.DisplayName
        Type             = $type
        DefaultValue     = $defaultValue
        Options          = $options
        ValueRestriction = $valueRestriction
        InstanceName     = $instanceName
        ChildSettings    = $innerChildSettings
    }

    if ($type -eq 'GroupCollectionCollection' -and $childSettings.Count -eq 1 -and $SettingDefinition.maximumCount -eq 1)
    {
        # Reset type and make the child setting a collection.
        $setting.Type = 'GroupCollection'
        $setting.ChildSettings[0].Type += 'Collection'
    }

    return $setting
}
