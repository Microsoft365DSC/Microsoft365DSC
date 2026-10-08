<#
.SYNOPSIS
    Returns the property model of the Intune Assignments property.

.DESCRIPTION
    Assignments are not part of the entity's CSDL schema - they are a relationship managed
    through their own cmdlet and the shared ConvertFrom/ConvertTo-IntunePolicyAssignment and
    Update-DeviceConfigurationPolicyAssignment helpers. The property model carries the shipped
    MSFT_DeviceManagementConfigurationPolicyAssignments CIM class (camelCase member names,
    matching every converted Intune resource) and an IsAssignments marker that routes it around
    the generic complex-type conversion emitters.
#>
function Get-M365DSCAssignmentPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [ValidateSet('Policy', 'MobileApp')]
        [System.String]
        $Kind = 'Policy',

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $CimClassName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $SettingsType,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $SettingsCimClassName,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $SettingsMember = @()
    )

    if ($Kind -eq 'MobileApp')
    {
        return (Get-M365DSCMobileAppAssignmentPropertyModel -CimClassName $CimClassName `
                -SettingsType $SettingsType `
                -SettingsCimClassName $SettingsCimClassName `
                -SettingsMember $SettingsMember)
    }

    $assignmentTargetTypes = @(
        '#microsoft.graph.cloudPcManagementGroupAssignmentTarget'
        '#microsoft.graph.groupAssignmentTarget'
        '#microsoft.graph.allLicensedUsersAssignmentTarget'
        '#microsoft.graph.allDevicesAssignmentTarget'
        '#microsoft.graph.exclusionGroupAssignmentTarget'
        '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
    )

    $memberDefinitions = @(
        @{ Name = 'dataType'; Description = 'The type of the target assignment.'; IsMandatory = $true; EnumValues = $assignmentTargetTypes }
        @{ Name = 'deviceAndAppManagementAssignmentFilterType'; Description = 'The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.'; IsMandatory = $false; EnumValues = @('none', 'include', 'exclude') }
        @{ Name = 'deviceAndAppManagementAssignmentFilterId'; Description = 'The Id of the filter for the target assignment.'; IsMandatory = $false }
        @{ Name = 'deviceAndAppManagementAssignmentFilterDisplayName'; Description = 'The display name of the filter for the target assignment.'; IsMandatory = $false }
        @{ Name = 'groupId'; Description = 'The group Id that is the target of the assignment.'; IsMandatory = $false }
        @{ Name = 'groupDisplayName'; Description = 'The group Display Name that is the target of the assignment.'; IsMandatory = $false }
        @{ Name = 'collectionId'; Description = 'The collection Id that is the target of the assignment.(ConfigMgr)'; IsMandatory = $false }
    )

    $members = foreach ($definition in $memberDefinitions)
    {
        $enumValues = @($definition.EnumValues | Where-Object { -not [System.String]::IsNullOrEmpty($_) })

        [PSCustomObject]@{
            Name                       = $definition.Name
            GraphName                  = $definition.Name
            RawType                    = 'Edm.String'
            ClrType                    = 'System.String'
            CimClassName               = $null
            FakeKind                   = 'String'
            IsArray                    = $false
            IsKey                      = $false
            IsMandatory                = $definition.IsMandatory
            IsComplex                  = $false
            IsEnum                     = $enumValues.Count -gt 0
            IsAuth                     = $false
            IsFromAdditionalProperties = $false
            EnumValues                 = $enumValues
            Description                = $definition.Description
            Members                    = @()
            FakeValue                  = $null
            DriftValue                 = $null
        }
    }

    $model = [PSCustomObject]@{
        Name                       = 'Assignments'
        GraphName                  = 'assignments'
        RawType                    = 'Complex'
        ClrType                    = 'MSFT_DeviceManagementConfigurationPolicyAssignments[]'
        CimClassName               = 'MSFT_DeviceManagementConfigurationPolicyAssignments'
        FakeKind                   = 'Complex'
        IsArray                    = $true
        IsKey                      = $false
        IsMandatory                = $false
        IsComplex                  = $true
        IsEnum                     = $false
        IsAuth                     = $false
        IsFromAdditionalProperties = $false
        EnumValues                 = @()
        Description                = 'Represents the assignment to the Intune policy.'
        Members                    = @($members)
        FakeValue                  = @(
            [ordered]@{
                dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                deviceAndAppManagementAssignmentFilterType = 'none'
            }
        )
        DriftValue                 = $null
    }

    $model | Add-Member -MemberType NoteProperty -Name 'IsAssignments' -Value $true

    return $model
}

<#
.SYNOPSIS
    Tests whether a property model is the special Assignments property.
#>
function Test-M365DSCAssignmentProperty
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Property
    )

    return ($null -ne $Property.PSObject.Properties['IsAssignments'] -and $Property.IsAssignments)
}

<#
.SYNOPSIS
    Returns the property model of the Assignments property of a mobile app.

.PARAMETER CimClassName
    Specifies the CIM class name of the assignment. Defaults to MSFT_DeviceManagementMobileAppAssignment.

.PARAMETER SettingsType
    Specifies the Graph assignment settings type, for example 'win32LobAppAssignmentSettings'.

.PARAMETER SettingsCimClassName
    Specifies the CIM class name of the assignment settings.

.PARAMETER SettingsMember
    Specifies the property models of the assignment settings type.

.OUTPUTS
    The property model.
#>
function Get-M365DSCMobileAppAssignmentPropertyModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $CimClassName,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $SettingsType,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $SettingsCimClassName,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $SettingsMember = @()
    )

    if ([System.String]::IsNullOrEmpty($CimClassName))
    {
        $CimClassName = 'MSFT_DeviceManagementMobileAppAssignment'
    }

    $memberDefinitions = @(
        @{ Name = 'dataType'; Description = 'The type of the target assignment.'; EnumValues = @(
                '#microsoft.graph.groupAssignmentTarget'
                '#microsoft.graph.allLicensedUsersAssignmentTarget'
                '#microsoft.graph.allDevicesAssignmentTarget'
                '#microsoft.graph.exclusionGroupAssignmentTarget'
                '#microsoft.graph.mobileAppAssignment'
            )
        }
        @{ Name = 'deviceAndAppManagementAssignmentFilterId'; Description = 'The Id of the filter for the target assignment.' }
        @{ Name = 'deviceAndAppManagementAssignmentFilterDisplayName'; Description = 'The display name of the filter for the target assignment.' }
        @{ Name = 'deviceAndAppManagementAssignmentFilterType'; Description = 'The type of filter of the target assignment i.e. Exclude or Include. Possible values are: none, include, exclude.'; EnumValues = @('none', 'include', 'exclude') }
        @{ Name = 'groupId'; Description = 'The group Id that is the target of the assignment.' }
        @{ Name = 'groupDisplayName'; Description = 'The group Display Name that is the target of the assignment.' }
        @{ Name = 'intent'; Description = 'Possible values for the install intent chosen by the admin.'; EnumValues = @('available', 'required', 'uninstall', 'availableWithoutEnrollment') }
    )

    $members = foreach ($definition in $memberDefinitions)
    {
        $enumValues = @($definition.EnumValues | Where-Object { -not [System.String]::IsNullOrEmpty($_) })

        [PSCustomObject]@{
            Name                       = $definition.Name
            GraphName                  = $definition.Name
            RawType                    = 'Edm.String'
            ClrType                    = 'System.String'
            CimClassName               = $null
            FakeKind                   = 'String'
            IsArray                    = $false
            IsKey                      = $false
            IsMandatory                = $false
            IsComplex                  = $false
            IsEnum                     = $enumValues.Count -gt 0
            IsAuth                     = $false
            IsFromAdditionalProperties = $false
            IsReadOnly                 = $false
            EnumValues                 = $enumValues
            Description                = $definition.Description
            Members                    = @()
            FakeValue                  = $null
            DriftValue                 = $null
        }
    }

    if (@($SettingsMember).Count -gt 0 -and -not [System.String]::IsNullOrEmpty($SettingsCimClassName))
    {
        $members = @($members) + (Get-M365DSCMobileAppAssignmentSettingsModel -SettingsType $SettingsType `
                -CimClassName $SettingsCimClassName `
                -Member $SettingsMember)
    }

    $model = [PSCustomObject]@{
        Name                       = 'Assignments'
        GraphName                  = 'assignments'
        RawType                    = 'Complex'
        ClrType                    = "$CimClassName[]"
        CimClassName               = $CimClassName
        FakeKind                   = 'Complex'
        IsArray                    = $true
        IsKey                      = $false
        IsMandatory                = $false
        IsComplex                  = $true
        IsEnum                     = $false
        IsAuth                     = $false
        IsFromAdditionalProperties = $false
        IsReadOnly                 = $false
        EnumValues                 = @()
        Description                = 'Represents the assignment to the Intune app.'
        Members                    = @($members)
        FakeValue                  = @(
            [ordered]@{
                dataType = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                intent   = 'available'
            }
        )
        DriftValue                 = $null
    }

    $model | Add-Member -MemberType NoteProperty -Name 'IsAssignments' -Value $true
    $model | Add-Member -MemberType NoteProperty -Name 'AssignmentKind' -Value 'MobileApp'

    return $model
}

<#
.SYNOPSIS
    Returns the assignment settings type of a mobile app type, walking its base chain.

.PARAMETER Schema
    Specifies the CSDL schema nodes.

.PARAMETER AppType
    Specifies the concrete app type, for example 'win32CatalogApp'.

.OUTPUTS
    The settings type name, or an empty string when there is none.
#>
function Resolve-M365DSCMobileAppAssignmentSettingsType
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Schema,

        [Parameter()]
        [AllowEmptyString()]
        [System.String]
        $AppType
    )

    if ([System.String]::IsNullOrEmpty($AppType))
    {
        return ''
    }

    $namespace = @($Schema | Where-Object -FilterScript { $_.Namespace -eq 'microsoft.graph' })
    $complexNames = [System.Collections.Generic.HashSet[System.String]]::new(
        [System.String[]] @($namespace.ComplexType.Name), [System.StringComparer]::OrdinalIgnoreCase)

    $current = $AppType
    while (-not [System.String]::IsNullOrEmpty($current))
    {
        $candidate = "$($current)AssignmentSettings"
        if ($complexNames.Contains($candidate))
        {
            return @($namespace.ComplexType | Where-Object -FilterScript { $_.Name -eq $candidate })[0].Name
        }

        $entity = @($namespace.EntityType | Where-Object -FilterScript { $_.Name -eq $current })[0]
        if ($null -eq $entity)
        {
            return ''
        }

        $current = [System.String] $entity.BaseType -replace '^.*\.', ''
    }

    return ''
}

<#
.SYNOPSIS
    Returns the assignmentSettings member of a mobile app assignment, with its odataType member.

.PARAMETER SettingsType
    Specifies the Graph settings type, for example 'win32LobAppAssignmentSettings'.

.PARAMETER CimClassName
    Specifies the CIM class name to declare for the settings.

.PARAMETER Member
    Specifies the property models of the settings type.

.OUTPUTS
    The property model.
#>
function Get-M365DSCMobileAppAssignmentSettingsModel
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingsType,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CimClassName,

        [Parameter()]
        [AllowEmptyCollection()]
        [System.Object[]]
        $Member = @()
    )

    $odataType = [PSCustomObject]@{
        Name                       = 'odataType'
        GraphName                  = 'odataType'
        RawType                    = 'Edm.String'
        ClrType                    = 'System.String'
        CimClassName               = $null
        FakeKind                   = 'String'
        IsArray                    = $false
        IsKey                      = $false
        IsMandatory                = $false
        IsComplex                  = $false
        IsEnum                     = $true
        IsAuth                     = $false
        IsFromAdditionalProperties = $false
        IsReadOnly                 = $false
        EnumValues                 = @("#microsoft.graph.$SettingsType")
        Description                = 'The odata type of the assignment settings.'
        Members                    = @()
        FakeValue                  = $null
        DriftValue                 = $null
    }

    return [PSCustomObject]@{
        Name                       = 'assignmentSettings'
        GraphName                  = 'assignmentSettings'
        RawType                    = 'Complex'
        ClrType                    = $CimClassName
        CimClassName               = $CimClassName
        FakeKind                   = 'Complex'
        IsArray                    = $false
        IsKey                      = $false
        IsMandatory                = $false
        IsComplex                  = $true
        IsEnum                     = $false
        IsAuth                     = $false
        IsFromAdditionalProperties = $false
        IsReadOnly                 = $false
        EnumValues                 = @()
        Description                = 'The settings of the assignment.'
        Members                    = @(@($odataType) + @($Member))
        FakeValue                  = $null
        DriftValue                 = $null
    }
}
