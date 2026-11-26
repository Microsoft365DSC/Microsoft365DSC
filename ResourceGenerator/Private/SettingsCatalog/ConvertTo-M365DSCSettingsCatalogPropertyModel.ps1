<#
.SYNOPSIS
    Projects a parsed settings catalog setting tree into property models.

.DESCRIPTION
    Replaces the old generator's direct parameter text generation: every setting becomes an
    ordinary property model, so the class, fake values, unit test and example emitters need
    no settings-catalog-specific code for the property surface. Property names keep the casing
    produced by Get-SettingsCatalogSettingName with an upper-cased first letter (the class
    property), while GraphName keeps the raw setting name (the key used by
    Export-IntuneSettingCatalogPolicySettings hashtables).

    A GroupCollection setting whose instance name is the generic
    'MSFT_MicrosoftGraphIntuneSettingsCatalog' is a transparent container: its children are
    promoted to the current level, matching the old behavior.
#>
function ConvertTo-M365DSCSettingsCatalogPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $TemplateSetting
    )

    $baseInstanceName = 'MSFT_MicrosoftGraphIntuneSettingsCatalog'

    $isGroup = $TemplateSetting.Type -like 'GroupCollection*'

    if ($isGroup -and $TemplateSetting.InstanceName -eq $baseInstanceName)
    {
        # Transparent container: promote the children.
        $models = @()
        foreach ($childSetting in $TemplateSetting.ChildSettings)
        {
            $models += ConvertTo-M365DSCSettingsCatalogPropertyModel -TemplateSetting $childSetting
        }
        return $models
    }

    $description = ''
    if (-not [System.String]::IsNullOrEmpty($TemplateSetting.DisplayName))
    {
        $description = ($TemplateSetting.DisplayName -replace "`r`n", '' -replace '\s+', ' ').Trim()
    }
    if ($null -ne $TemplateSetting.Options -and $TemplateSetting.Options.Count -gt 0)
    {
        $optionTexts = @($TemplateSetting.Options | ForEach-Object { "$($_.Id): $($_.Name -replace '"', "'")" })
        $description += ' (' + ($optionTexts -join ', ') + ')'
    }
    if ($null -ne $TemplateSetting.ValueRestriction -and -not [System.String]::IsNullOrEmpty($TemplateSetting.ValueRestriction.Description))
    {
        $description += ' ' + $TemplateSetting.ValueRestriction.Description
    }

    $name = Get-StringFirstCharacterToUpper -Value $TemplateSetting.Name

    if ($isGroup)
    {
        $members = @()
        foreach ($childSetting in $TemplateSetting.ChildSettings)
        {
            $members += ConvertTo-M365DSCSettingsCatalogPropertyModel -TemplateSetting $childSetting
        }

        $model = New-M365DSCSettingsCatalogBaseModel -Name $name -GraphName $TemplateSetting.Name -Description $description
        $model.ClrType = $TemplateSetting.InstanceName
        $model.CimClassName = $TemplateSetting.InstanceName
        $model.IsComplex = $true
        $model.FakeKind = 'Complex'
        $model.IsArray = ($TemplateSetting.Type -eq 'GroupCollectionCollection')
        if ($model.IsArray)
        {
            $model.ClrType += '[]'
        }
        $model.Members = $members
        $model.FakeValue = Get-M365DSCFakeValue -PropertyModel $model
        $model.DriftValue = Get-M365DSCFakeValue -PropertyModel $model -Drift
        return @($model)
    }

    $model = New-M365DSCSettingsCatalogBaseModel -Name $name -GraphName $TemplateSetting.Name -Description $description
    $model.IsArray = $TemplateSetting.Type -like '*Collection'

    $isInteger = $TemplateSetting.Type -like '*Integer*'
    $isChoice = $TemplateSetting.Type -like 'Choice*'

    if ($isInteger)
    {
        $model.RawType = 'Edm.Int32'
        $model.ClrType = 'System.Int32'
        $model.FakeKind = 'Int'
    }
    elseif ($TemplateSetting.Type -eq 'Boolean')
    {
        $model.RawType = 'Edm.Boolean'
        $model.ClrType = 'System.Boolean'
        $model.FakeKind = 'Boolean'
    }

    if ($isChoice -and $null -ne $TemplateSetting.Options -and $TemplateSetting.Options.Count -gt 0)
    {
        $model.IsEnum = $true
        $model.EnumValues = [System.String[]] @($TemplateSetting.Options.Id | ForEach-Object { [System.String] $_ })

        if ($isInteger)
        {
            # Integer choice settings stay SInt32; the class needs an unquoted ValidateSet.
            $model.FakeKind = 'IntEnum'
            $model.ValidationAttribute = "[ValidateSet($($TemplateSetting.Options.Id -join ', '))]"
        }
        else
        {
            $model.ClrType = 'System.String'
            $model.FakeKind = 'Enum'
        }
    }
    elseif ($null -ne $TemplateSetting.ValueRestriction)
    {
        if ($TemplateSetting.ValueRestriction.Type -like '*String')
        {
            $model.ValidationAttribute = "[ValidateLength($($TemplateSetting.ValueRestriction.Min), $($TemplateSetting.ValueRestriction.Max))]"
        }
        elseif ($TemplateSetting.ValueRestriction.Type -like '*Integer')
        {
            $model.ValidationAttribute = "[ValidateRange($($TemplateSetting.ValueRestriction.Min), $($TemplateSetting.ValueRestriction.Max))]"
        }
    }

    if ($model.IsArray)
    {
        $model.ClrType += '[]'
    }
    elseif ($model.ClrType -in @('System.Boolean', 'System.Int32'))
    {
        $model.ClrType = "System.Nullable[$($model.ClrType)]"
    }

    $model.FakeValue = Get-M365DSCFakeValue -PropertyModel $model
    $model.DriftValue = Get-M365DSCFakeValue -PropertyModel $model -Drift

    return @($model)
}

<#
.SYNOPSIS
    Builds the DeviceSettings/UserSettings wrapper property model of a split template.

.DESCRIPTION
    Templates mixing device_ and user_ scoped settings surface each scope as one single
    (non-array) complex property whose CIM class is suffixed with the resource name, matching
    shipped resources like MSFT_IntuneAccountProtectionPolicyWindows10.
#>
function New-M365DSCSettingsWrapperPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('DeviceSettings', 'UserSettings')]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ResourceName,

        [Parameter()]
        [System.Object[]]
        $Members = @()
    )

    $cimClassName = "MSFT_MicrosoftGraphIntuneSettingsCatalog$Name`_$ResourceName"
    $scope = $Name.Replace('Settings', '').ToLowerInvariant()

    $model = New-M365DSCSettingsCatalogBaseModel -Name $Name -GraphName $Name `
        -Description "The $scope scoped settings of this policy."
    $model.ClrType = $cimClassName
    $model.CimClassName = $cimClassName
    $model.IsComplex = $true
    $model.FakeKind = 'Complex'
    $model.IsArray = $false
    $model.Members = @($Members | Sort-Object -Property Name)
    $model.FakeValue = Get-M365DSCFakeValue -PropertyModel $model
    $model.DriftValue = Get-M365DSCFakeValue -PropertyModel $model -Drift

    return $model
}

<#
.SYNOPSIS
    Builds the empty scaffold of a settings catalog property model.
#>
function New-M365DSCSettingsCatalogBaseModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        $GraphName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $Description = ''
    )

    $model = [PSCustomObject]@{
        Name                       = $Name
        GraphName                  = $GraphName
        RawType                    = 'Edm.String'
        ClrType                    = 'System.String'
        CimClassName               = $null
        FakeKind                   = 'String'
        IsArray                    = $false
        IsKey                      = $false
        IsMandatory                = $false
        IsComplex                  = $false
        IsEnum                     = $false
        IsAuth                     = $false
        IsFromAdditionalProperties = $false
        EnumValues                 = @()
        Description                = $Description
        Members                    = @()
        FakeValue                  = $null
        DriftValue                 = $null
    }

    $model | Add-Member -MemberType NoteProperty -Name 'ValidationAttribute' -Value ''
    $model | Add-Member -MemberType NoteProperty -Name 'IsSettingsCatalogSetting' -Value $true

    return $model
}
