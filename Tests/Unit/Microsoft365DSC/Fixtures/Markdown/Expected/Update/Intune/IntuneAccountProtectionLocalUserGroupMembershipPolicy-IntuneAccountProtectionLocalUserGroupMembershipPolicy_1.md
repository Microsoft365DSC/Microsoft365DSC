# IntuneAccountProtectionLocalUserGroupMembershipPolicy-IntuneAccountProtectionLocalUserGroupMembershipPolicy_1

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **Identity** | Write | String | Identity of the account protection policy. | | 2e465409-0054-4ac5-bbed-8f3d3b9adde4 |
| **DisplayName** | Key | String | Display name of the account protection rules policy. | | IntuneAccountProtectionLocalUserGroupMembershipPolicy_1 |
| **Description** | Write | String | Description of the account protection rules policy. | | IntuneAccountProtectionLocalUserGroupMembershipPolicy_1 |
| **RoleScopeTagIds** | Write | String[] | List of Scope Tags for this Entity instance. | | 0 |
| **Assignments** | Write | MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments[] | Assignments of the Intune Policy. | | MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments_1,MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments_2 |
| **AccessGroup** | Write | MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup[] | Local User Group Collections of the Intune Policy. | | MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup_1 |
| **Ensure** | Write | String | Present ensures the site collection exists, absent ensures it is removed | `Present`, `Absent` | Present |

### MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **dataType** | Required | String | The type of the target assignment. | `#microsoft.graph.groupAssignmentTarget`, `#microsoft.graph.allLicensedUsersAssignmentTarget`, `#microsoft.graph.allDevicesAssignmentTarget`, `#microsoft.graph.exclusionGroupAssignmentTarget`, `#microsoft.graph.configurationManagerCollectionAssignmentTarget` | #microsoft.graph.exclusionGroupAssignmentTarget |
| **deviceAndAppManagementAssignmentFilterType** | Write | String | The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude. | `none`, `include`, `exclude` | none |
| **deviceAndAppManagementAssignmentFilterId** | Write | String | The Id of the filter for the target assignment. | | |
| **deviceAndAppManagementAssignmentFilterDisplayName** | Write | String | The display name of the filter for the target assignment. | | |
| **groupId** | Write | String | The group Id that is the target of the assignment. | | 053dc89a-be83-411a-bad3-909904b7239e |
| **groupDisplayName** | Write | String | The group Display Name that is the target of the assignment. | | DummyGroupExclude |
| **collectionId** | Write | String | The collection Id that is the target of the assignment.(ConfigMgr) | | |

### MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments_2

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **dataType** | Required | String | The type of the target assignment. | `#microsoft.graph.groupAssignmentTarget`, `#microsoft.graph.allLicensedUsersAssignmentTarget`, `#microsoft.graph.allDevicesAssignmentTarget`, `#microsoft.graph.exclusionGroupAssignmentTarget`, `#microsoft.graph.configurationManagerCollectionAssignmentTarget` | #microsoft.graph.groupAssignmentTarget |
| **deviceAndAppManagementAssignmentFilterType** | Write | String | The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude. | `none`, `include`, `exclude` | none |
| **deviceAndAppManagementAssignmentFilterId** | Write | String | The Id of the filter for the target assignment. | | |
| **deviceAndAppManagementAssignmentFilterDisplayName** | Write | String | The display name of the filter for the target assignment. | | |
| **groupId** | Write | String | The group Id that is the target of the assignment. | | b0b8fd3f-af2a-453b-be57-80182d599f02 |
| **groupDisplayName** | Write | String | The group Display Name that is the target of the assignment. | | DummyGroupInclude |
| **collectionId** | Write | String | The collection Id that is the target of the assignment.(ConfigMgr) | | |

### MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup_1

#### Parameters

| Parameter | Attribute | DataType | Description | Allowed Values | Value |
| --- | --- | --- | --- | --- | --- |
| **action** | Write | String | The action to use for adding / removing members. Possible values: Add (AddUpdate), Remove (RemoveUpdate), Replace (AddRestrict). Add and Remove do not update unspecified members, whereas Replace will replace all members with the ones specified. | `AddUpdate`, `RemoveUpdate`, `AddRestrict` | AddUpdate |
| **desc** | Write | String[] | The local groups to add / remove the members to / from. List of the following values: `administrators`, `users`, `guests`, `powerusers`, `remotedesktopusers`, `remotemanagementusers` | `administrators`, `users`, `guests`, `powerusers`, `remotedesktopusers`, `remotemanagementusers` | administrators |
| **member** | Write | String[] | The members to add / remove to / from the group. For AzureAD Users, use the format `AzureAD\\&lt;UserPrincipalName&gt;`. For groups, use the security identifier (SID). | | AzureAD\test1@contoso.com |
| **userselectiontype** | Write | String | The type of the selection. Either users / groups from AzureAD, or by manual identifier. | `users`, `manual` | users |

## Description

This resource configures a Intune Account Protection Local User Group Membership policy.

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
