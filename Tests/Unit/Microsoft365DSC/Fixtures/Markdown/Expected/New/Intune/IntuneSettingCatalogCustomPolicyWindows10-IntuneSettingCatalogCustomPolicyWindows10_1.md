# IntuneSettingCatalogCustomPolicyWindows10-IntuneSettingCatalogCustomPolicyWindows10_1

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **Description** | Write | String | Policy description | | IntuneSettingCatalogCustomPolicyWindows10_1 |
| **Name** | Key | String | Policy name | | IntuneSettingCatalogCustomPolicyWindows10_1 |
| **RoleScopeTagIds** | Write | String[] | List of Scope Tags for this Entity instance. | | 0 |
| **Platforms** | Write | String | Platforms for this policy. Possible values are: none, android, iOS, macOS, windows10X, windows10, linux, unknownFutureValue. | `none`, `android`, `iOS`, `macOS`, `windows10X`, `windows10`, `linux`, `unknownFutureValue` | windows10 |
| **Technologies** | Write | String | Technologies for this policy. Possible values are: none, mdm, windows10XManagement, configManager, appleRemoteManagement, microsoftSense, exchangeOnline, edgeMAM, linuxMdm, enrollment, endpointPrivilegeManagement, unknownFutureValue. | `none`, `mdm`, `windows10XManagement`, `configManager`, `appleRemoteManagement`, `microsoftSense`, `exchangeOnline`, `linuxMdm`, `enrollment`, `endpointPrivilegeManagement`, `unknownFutureValue` | mdm |
| **TemplateReference** | Write | MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference | Template reference information | | |
| **Settings** | Write | MSFT_MicrosoftGraphdeviceManagementConfigurationSetting[] | Policy settings | | MSFT_MicrosoftGraphdeviceManagementConfigurationSetting_1 |
| **Id** | Write | String | The unique identifier for an entity. Read-only. | | 495a239d-4367-474f-86e8-225d9f6bbe11 |
| **Assignments** | Write | MSFT_DeviceManagementConfigurationPolicyAssignments[] | Represents the assignment to the Intune policy. | | MSFT_DeviceManagementConfigurationPolicyAssignments_1,MSFT_DeviceManagementConfigurationPolicyAssignments_2 |
| **Ensure** | Write | String | Present ensures the policy exists, absent ensures it is removed. | `Present`, `Absent` | Present |

### MSFT_DeviceManagementConfigurationPolicyAssignments_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **dataType** | Required | String | The type of the target assignment. | `#microsoft.graph.cloudPcManagementGroupAssignmentTarget`, `#microsoft.graph.groupAssignmentTarget`, `#microsoft.graph.allLicensedUsersAssignmentTarget`, `#microsoft.graph.allDevicesAssignmentTarget`, `#microsoft.graph.exclusionGroupAssignmentTarget`, `#microsoft.graph.configurationManagerCollectionAssignmentTarget` | #microsoft.graph.exclusionGroupAssignmentTarget |
| **deviceAndAppManagementAssignmentFilterType** | Write | String | The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude. | `none`, `include`, `exclude` | none |
| **deviceAndAppManagementAssignmentFilterId** | Write | String | The Id of the filter for the target assignment. | | |
| **deviceAndAppManagementAssignmentFilterDisplayName** | Write | String | The display name of the filter for the target assignment. | | |
| **groupId** | Write | String | The group Id that is the target of the assignment. | | 053dc89a-be83-411a-bad3-909904b7239e |
| **groupDisplayName** | Write | String | The group Display Name that is the target of the assignment. | | DummyGroupExclude |
| **collectionId** | Write | String | The collection Id that is the target of the assignment.(ConfigMgr) | | |

### MSFT_DeviceManagementConfigurationPolicyAssignments_2

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **dataType** | Required | String | The type of the target assignment. | `#microsoft.graph.cloudPcManagementGroupAssignmentTarget`, `#microsoft.graph.groupAssignmentTarget`, `#microsoft.graph.allLicensedUsersAssignmentTarget`, `#microsoft.graph.allDevicesAssignmentTarget`, `#microsoft.graph.exclusionGroupAssignmentTarget`, `#microsoft.graph.configurationManagerCollectionAssignmentTarget` | #microsoft.graph.groupAssignmentTarget |
| **deviceAndAppManagementAssignmentFilterType** | Write | String | The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude. | `none`, `include`, `exclude` | none |
| **deviceAndAppManagementAssignmentFilterId** | Write | String | The Id of the filter for the target assignment. | | |
| **deviceAndAppManagementAssignmentFilterDisplayName** | Write | String | The display name of the filter for the target assignment. | | |
| **groupId** | Write | String | The group Id that is the target of the assignment. | | b0b8fd3f-af2a-453b-be57-80182d599f02 |
| **groupDisplayName** | Write | String | The group Display Name that is the target of the assignment. | | DummyGroupInclude |
| **collectionId** | Write | String | The collection Id that is the target of the assignment.(ConfigMgr) | | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **Children** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[] | Child settings. | | |
| **Value** | Write | String | Choice setting value: an OptionDefinition ItemId. | | device_vendor_msft_policy_config_updatev83diff~policy~cat_edgeupdate~cat_applications_pol_defaultcreatedesktopshortcut_0 |
| **SettingValueTemplateReference** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference | Setting value template reference | | |
| **odataType** | Write | String | The type of the entity. | `#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`, `#microsoft.graph.deviceManagementConfigurationGroupSettingValue`, `#microsoft.graph.deviceManagementConfigurationSimpleSettingValue` | |

### MSFT_MicrosoftGraphdeviceManagementConfigurationSetting_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **SettingInstance** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance | Setting Instance | | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance_1 |
| **Id** | Write | String | The unique identifier for an entity. Read-only. | | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **SettingDefinitionId** | Write | String | Setting Definition Id | | device_vendor_msft_policy_config_updatev83diff~policy~cat_edgeupdate~cat_applications_pol_defaultcreatedesktopshortcut |
| **SettingInstanceTemplateReference** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference | Setting Instance Template Reference | | |
| **ChoiceSettingCollectionValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue[] | Choice setting collection value | | |
| **ChoiceSettingValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue | Choice setting value | | MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue_1 |
| **GroupSettingCollectionValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue[] | A collection of GroupSetting values | | |
| **GroupSettingValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue | GroupSetting value | | |
| **SimpleSettingCollectionValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue[] | Simple setting collection instance value | | |
| **SimpleSettingValue** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue | Simple setting instance value | | |
| **odataType** | Write | String | The type of the entity. | `#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance`, `#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance`, `#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance`, `#microsoft.graph.deviceManagementConfigurationGroupSettingInstance`, `#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionInstance`, `#microsoft.graph.deviceManagementConfigurationSettingGroupInstance`, `#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance`, `#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance` | #microsoft.graph.deviceManagementConfigurationChoiceSettingInstance |

### MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **TemplateDisplayName** | Write | String | Template Display Name of the referenced template. This property is read-only. | | |
| **TemplateDisplayVersion** | Write | String | Template Display Version of the referenced Template. This property is read-only. | | |
| **TemplateFamily** | Write | String | Template Family of the referenced Template. This property is read-only. Possible values are: none, endpointSecurityAntivirus, endpointSecurityDiskEncryption, endpointSecurityFirewall, endpointSecurityEndpointDetectionAndResponse, endpointSecurityAttackSurfaceReduction, endpointSecurityAccountProtection, endpointSecurityApplicationControl, endpointSecurityEndpointPrivilegeManagement, enrollmentConfiguration, appQuietTime, baseline, unknownFutureValue, deviceConfigurationScripts. | `none`, `endpointSecurityAntivirus`, `endpointSecurityDiskEncryption`, `endpointSecurityFirewall`, `endpointSecurityEndpointDetectionAndResponse`, `endpointSecurityAttackSurfaceReduction`, `endpointSecurityAccountProtection`, `endpointSecurityApplicationControl`, `endpointSecurityEndpointPrivilegeManagement`, `enrollmentConfiguration`, `appQuietTime`, `baseline`, `unknownFutureValue`, `deviceConfigurationScripts` | |
| **TemplateId** | Write | String | Template id | | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **SettingInstanceTemplateId** | Write | String | Setting instance template id | | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **Children** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[] | Collection of child setting instances contained within this GroupSetting | | |
| **SettingValueTemplateReference** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference | Setting value template reference | | |
| **Value** | Write | String | Choice setting value: an OptionDefinition ItemId. | | |
| **odataType** | Write | String | The type of the entity. | `#microsoft.graph.deviceManagementConfigurationChoiceSettingValue`, `#microsoft.graph.deviceManagementConfigurationGroupSettingValue`, `#microsoft.graph.deviceManagementConfigurationSimpleSettingValue` | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **IntValue** | Write | UInt32 | Value of the integer setting. | | |
| **StringValue** | Write | String | Value of the string setting. | | |
| **ValueState** | Write | String | Gets or sets a value indicating the encryption state of the Value property. Possible values are: invalid, notEncrypted, encryptedValueToken. | `invalid`, `notEncrypted`, `encryptedValueToken` | |
| **odataType** | Write | String | The type of the entity. | `#microsoft.graph.deviceManagementConfigurationIntegerSettingValue`, `#microsoft.graph.deviceManagementConfigurationStringSettingValue`, `#microsoft.graph.deviceManagementConfigurationSecretSettingValue` | |
| **SettingValueTemplateReference** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference | Setting value template reference | | |
| **Children** | Write | MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[] | Child settings. | | |

### MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **settingValueTemplateId** | Write | String | Setting value template id | | |
| **useTemplateDefault** | Write | Boolean | Indicates whether to update policy setting value to match template setting default value | | |

## Description

Intune Setting Catalog Custom Policy for Windows10

## Permissions

### Graph

To authenticate with the Graph API, this resource requires the following permissions:

#### Delegated permissions

* **Read**
  * GroupMember.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All

* **Update**
  * GroupMember.Read.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementRBAC.Read.All

#### Application permissions

* **Read**
  * GroupMember.Read.All, DeviceManagementConfiguration.Read.All, DeviceManagementRBAC.Read.All

* **Update**
  * GroupMember.Read.All, DeviceManagementConfiguration.ReadWrite.All, DeviceManagementRBAC.Read.All
