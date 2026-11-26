---
date: 2026-10-04
---

# Microsoft365DSC – October 2026 Major Release (version 2.26.1007.1)

<img src="../images/FabienTschanz.jpg" style="width:75px;border-radius:50%;border:3px solid black;float:left;" />
<div style="position:inherit;padding-top:15px;"><span style="float:left;padding-left:15px;"><b>by <a href="https://www.linkedin.com/in/fabien-tschanz">Fabien Tschanz</a><br />
October 4th, 2026</b></span></div>

<br/>
<br/>

As defined by our [Breaking Changes Policy](https://microsoft365dsc.com/concepts/breaking-changes/), twice a year we allow for breaking changes to be deployed as part of a release. Our next major release, scheduled to go out on October 7th 2026, will include several breaking changes and will be labeled version 2.26.1007.1. This article provides details on the breaking changes and other important updates that will be included as part of our October 2026 Major release.

The October 2026 release is the largest one so far. Every resource is now a class-based DSC resource, the module requires PowerShell 7.6, and a long list of property names was aligned with the names Microsoft Graph uses. If you'd rather not edit an existing configuration by hand, take a new snapshot with `Export-M365DSCConfiguration` after the update. The export already writes the new shape.

## Table of Contents

1. [PowerShell 7.6 and Class-Based Resources](#powershell-76-and-class-based-resources-7445)
2. [Compile Configurations with Invoke-M365DSCConfigurationBuild](#compile-configurations-with-invoke-m365dscconfigurationbuild-7445)
3. [New Permissions](#new-permissions-7445-7496)
4. [Failed Changes Now Fail the Configuration](#failed-changes-now-fail-the-configuration-7470)
5. [Exported Instance Names Use Underscores](#exported-instance-names-use-underscores-7447)
6. [Intune Role Scope Tags Use Display Names](#intune-role-scope-tags-use-display-names-7447)
7. [Removed Resources](#removed-resources-7445)
8. [Intune Resources Lose Their V2 Suffix](#intune-resources-lose-their-v2-suffix-7445-7513)
9. [AADUser - Renamed Properties to Match Microsoft Graph](#aaduser-renamed-properties-to-match-microsoft-graph-7445)
10. [AADAuthorizationPolicy - New DefaultUserRolePermissions Property](#aadauthorizationpolicy-new-defaultuserrolepermissions-property-7445)
11. [AADIdentityAPIConnector - New AuthenticationConfiguration Property](#aadidentityapiconnector-new-authenticationconfiguration-property-7445)
12. [AADDeviceRegistrationPolicy - MultiFactorAuthConfiguration and Unset Properties](#aaddeviceregistrationpolicy-multifactorauthconfiguration-and-unset-properties-7445-7498)
13. [AADServicePrincipal - Swapped Group Filter Values](#aadserviceprincipal-swapped-group-filter-values-7445)
14. [AADPIMGroupSetting - Export Limited to PIM-Enabled Groups](#aadpimgroupsetting-export-limited-to-pim-enabled-groups-7495)
15. [Windows Autopilot Deployment Profiles - Graph Property Names](#windows-autopilot-deployment-profiles-graph-property-names-7445)
16. [Intune App Assignments and Targeted Apps - New Class Types](#intune-app-assignments-and-targeted-apps-new-class-types-7445)
17. [SCRetentionCompliancePolicy - Adaptive Scopes](#scretentioncompliancepolicy-adaptive-scopes-7484)
18. [TeamsChannelTab - New Configuration Property](#teamschanneltab-new-configuration-property-7445)
19. [SCInsiderRiskPolicy - Tenant Settings Policy](#scinsiderriskpolicy-tenant-settings-policy)
20. [EXOPhishSimOverrideRule and EXOSecOpsOverrideRule - Single Instance Resources](#exophishsimoverriderule-and-exosecopsoverriderule-single-instance-resources)
21. [Renamed Properties](#renamed-properties)
22. [Removed Properties](#removed-properties)
23. [Changed Types and Accepted Values](#changed-types-and-accepted-values)
24. [Renamed Embedded Classes](#renamed-embedded-classes-7487)

## PowerShell 7.6 and Class-Based Resources ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

All 530+ resources moved from script-based to class-based DSC resources. There is no change to the resource names, and already existing configurations compile to the same MOF file.

The PowerShell requirement however does change. Microsoft365DSC now requires PowerShell 7.6 or higher on every machine that runs it, and you run `Export-M365DSCConfiguration` and every other cmdlet of the module from a PowerShell 7 console. The Local Configuration Manager (LCM, used when applying or testing a configuration using `Start-DscConfiguration`) still runs on Windows PowerShell 5.1, but it hands each resource call over to a PowerShell 7 session on the same machine. For that relay to work, you need two things:

* Register the `PowerShell.7` remoting endpoint by running `Enable-PSRemoting -Force -SkipNetworkProfileCheck` from an elevated PowerShell 7 console.
* Install Microsoft365DSC for all users in Windows PowerShell.

After the update, run `Update-M365DSCDependencies` from both consoles. The release adds two new dependencies, `M365DSC.Mgx` and `M365DSC.PSDesiredStateConfiguration`, and updates `MicrosoftTeams` to 8.0.0 and `PnP.PowerShell` to 3.4.1. The [PowerShell 7+ support](../user-guide/get-started/powershell7-support.md) page contains additional details.

## Compile Configurations with Invoke-M365DSCConfigurationBuild ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

Until now, a DSC configuration was compiled by running the exported script, for example `.\M365TenantConfig.ps1`. This still works, but because of the move to class-based resources, it has become a lot slower. This is because PowerShell creates a .NET type for every class in the Microsoft365DSC module before it reads the first resource, which means that even a configuration with a single resource may take 30 to 90 seconds to compile.

The new `Invoke-M365DSCConfigurationBuild` function replaces the standard compilation process:

```powershell
# Before
.\M365TenantConfig.ps1

# After
Invoke-M365DSCConfigurationBuild -Path .\M365TenantConfig.ps1
```

The cmdlet picks up the `ConfigurationData.psd1` next to the script automatically. If you require custom input or parameters, you can pass them to the function, which forwards `-Credential`, `-CertificatePassword` and any value of `-Parameters` to the configuration.

Update your scripts and deployment pipelines to call `Invoke-M365DSCConfigurationBuild` instead of running the configuration script directly. Part 3 of the [class-based resources series](./2026/class-based-resources/class-based-resources-part-3.md) explains how the new compilation works.

## New Permissions ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445), [#7496](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7496))

Several resources need new permissions. Without them, the export and the apply of these resources fail with an authorization error.

* Every Intune resource with a `RoleScopeTagIds` property now needs `DeviceManagementRBAC.Read.All`, for both read and update. The resources use it to translate role scope tags between IDs and display names.
* `AADPIMGroupSetting`, `AADGroupEligibilitySchedule` and `AADGroupEligibilityScheduleSettings` need `PrivilegedAccess.Read.AzureADGroup`. `AADPIMGroupSetting` also needs `AuthenticationContext.Read.All`.
* `AADPIMGroupSetting` and `AADGroupEligibilityScheduleSettings` now use `GroupMember.Read.All` in place of `Group.Read.All`.

The PIM permissions come from an API change: `AADGroupEligibilityScheduleSettings` moved off the `/beta/privilegedAccess/aadGroups/resources` API, which stops returning data on October 28th, 2026.

To fix your app registration, add these permissions in Entra ID or with `Update-M365DSCAzureAdApplication`, and grant admin consent. `Get-M365DSCCompiledPermissionList -ResourceNameList @('AADPIMGroupSetting')` lists every permission a resource needs.

## Failed Changes Now Fail the Configuration ([#7470](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7470))

Some resources caught errors during a change, wrote them to the verbose output or the event log, and returned without an error. The LCM then reported a successful apply, although the change never reached the tenant. These resources now all throw an error:

`AADApplication`, `AADGroup`, `AADUser`, `EXOAvailabilityAddressSpace`, `EXOSafeAttachmentPolicy`, `EXOSmtpDaneInbound`, `IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10`, `IntuneDeviceEnrollmentStatusPageWindows10`, `O365AdminAuditLogConfig`, `O365OrgSettings`, `O365SearchAndIntelligenceConfigurations`, `SPOSiteScript`, `TeamsDialInConferencingTenantSettings`, `TeamsOnlineVoicemailUserSettings` and `TeamsUserCallingSettings`.

You don't have to change anything in your configuration. However, your deployment pipeline may start failing on errors that went unnoticed before.

## Exported Instance Names Use Underscores ([#7447](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7447))

The export builds the name of each instance from the resource name and a property such as the display name. Until now, it kept the characters of that property as they were and only escaped a few typographic quotes. Starting with this release, the export replaces the following characters with an underscore: `< > : " / \ | ? * ' [ ] ( ) $`, the backtick, the space and the typographic quotes. An instance the export used to write as `AADGroup-Sales Team` now comes out as `AADGroup-Sales_Team`.

Your existing configurations keep compiling, because DSC doesn't care how you name an instance. You'll notice the change if you keep exports in source control, since every instance with one of those characters gets a new name. If you built tooling on top of the exported instance names, update it to the new format.

The `Update-M365DSCSpecialCharacters` function was removed as well. If you call it in your own scripts, use `Remove-M365DSCSpecialCharacters` instead.

## Intune Role Scope Tags Use Display Names ([#7447](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7447))

The `RoleScopeTagIds` property of the Intune resources used to contain the IDs of the role scope tags, for example `0` or `3`. The export now writes the display names of the tags instead, such as `Default` or `<Location> Members`. This lets you move a configuration to another tenant without looking up the tag IDs there, as long as the tags have the same names.

Configurations that still use IDs keep working. On apply, the resource first looks for a tag with that display name and then falls back to the ID. If a value matches neither, the resource writes a warning and skips that tag. For the lookup, the resource needs the `DeviceManagementRBAC.Read.All` permission from [New Permissions](#new-permissions-7445-7496). Without it, the resource uses the values as they are.

## Removed Resources ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

Five resources were removed. The first three have a replacement that covers the same settings:

| Removed resource | Use instead |
| --- | --- |
| `AADIdentityGovernanceProgram` | `AADAccessReviewDefinition` and `AADAccessReviewPolicy` |
| `IntuneApplicationControlPolicyWindows10` | `IntuneDeviceConfigurationEndpointProtectionPolicyWindows10` |
| `IntuneDiskEncryptionMacOS` | `IntuneDiskEncryptionFileVaultPolicyMacOS` |
| `SCSupervisoryReviewPolicy` | none |
| `SCSupervisoryReviewRule` | none |

The replacements don't share the schema of the removed resources, which means that you cannot simply rename the instances. The fastest way to get there is to export the replacement resource from your tenant with `Export-M365DSCConfiguration -Components @('IntuneDiskEncryptionFileVaultPolicyMacOS')` and swap the old instances in your configuration for the exported ones.

Microsoft retired supervision in the Security & Compliance Center in favor of Communication Compliance, and the service now rejects new supervisory review policies with `LegacySupervisionPolicyCreationException`. Remove the `SCSupervisoryReviewPolicy` and `SCSupervisoryReviewRule` instances from your configuration and manage these policies in Communication Compliance instead.

## Intune Resources Lose Their V2 Suffix ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445), [#7513](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7513))

Three Intune resources had a `V2` version. The old, already deprecated versions of the App Control for Business and the Delivery Optimization resources were removed, and all three `V2` resources were renamed to their name without the suffix:

| Old V2 name | New name |
| --- | --- |
| `IntuneAppControlForBusinessPolicyWindows10V2` | `IntuneAppControlForBusinessPolicyWindows10` |
| `IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10V2` | `IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10` |
| `IntuneDeviceCleanupRuleV2` | `IntuneDeviceCleanupRule` |

If your configuration uses one of the `V2` names, remove the `V2` suffix from the resource name. The properties stay the same.

If your configuration still uses the old `IntuneAppControlForBusinessPolicyWindows10` or `IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10` resource, the name stays the same, but the schema changed. The App Control for Business resource now uses a newer settings catalog template, and the Delivery Optimization resource moved from the legacy device configuration to the settings catalog with its `DO*` settings. Export these policies from your tenant and replace the old instances with the exported ones.

## AADUser - Renamed Properties to Match Microsoft Graph ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

Five properties of the AADUser resource were renamed, so they now carry the same name as in Microsoft Graph:

| Old name | New name |
| --- | --- |
| `Fax` | `FaxNumber` |
| `FirstName` | `GivenName` |
| `LastName` | `Surname` |
| `Office` | `OfficeLocation` |
| `Title` | `JobTitle` |

The deprecated `PasswordNeverExpires` property was removed as well. To fix your configurations, search for AADUser instances and rename the properties from the table. If an instance sets `PasswordNeverExpires = $true`, replace it with `PasswordPolicies = 'DisablePasswordExpiration'`.

## AADAuthorizationPolicy - New DefaultUserRolePermissions Property ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

The five `DefaultUserRole*` properties moved into the new `DefaultUserRolePermissions` complex property, matching the structure of Microsoft Graph. The members drop the `DefaultUserRole` prefix:

```powershell
# Before
DefaultUserRoleAllowedToCreateApps                      = $true
DefaultUserRoleAllowedToCreateSecurityGroups            = $true
DefaultUserRoleAllowedToCreateTenants                   = $false
DefaultUserRoleAllowedToReadBitlockerKeysForOwnedDevice = $true
DefaultUserRoleAllowedToReadOtherUsers                  = $true

# After
DefaultUserRolePermissions = MSFT_DefaultUserRolePermissions {
    AllowedToCreateApps                      = $true
    AllowedToCreateSecurityGroups            = $true
    AllowedToCreateTenants                   = $false
    AllowedToReadBitlockerKeysForOwnedDevice = $true
    AllowedToReadOtherUsers                  = $true
}
```

## AADIdentityAPIConnector - New AuthenticationConfiguration Property ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

The `Username`, `Password` and `Certificates` properties moved into the new `AuthenticationConfiguration` complex property. Its `dataType` member defines the authentication type of the connector. Additionally, `Certificates` is now called `CertificateList`:

```powershell
# Basic authentication
AuthenticationConfiguration = MSFT_MicrosoftGraphApiAuthenticationConfigurationBase {
    dataType = '#microsoft.graph.basicAuthentication'
    Username = 'api-user'
    Password = $ConnectorCredential
}

# Certificate authentication
AuthenticationConfiguration = MSFT_MicrosoftGraphApiAuthenticationConfigurationBase {
    dataType        = '#microsoft.graph.pkcs12Certificate'
    CertificateList = @(
        MSFT_AADIdentityAPIConnectionCertificate {
            Thumbprint  = 'A1B2C3D4E5F6...'
            Pkcs12Value = $CertificateContent
            Password    = $CertificatePassword
            IsActive    = $true
        }
    )
}
```

To fix your configurations, move the three properties into `AuthenticationConfiguration` and set `dataType` to the matching value. Exactly one certificate in `CertificateList` has to be active.

## AADDeviceRegistrationPolicy - MultiFactorAuthConfiguration and Unset Properties ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445), [#7498](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7498))

`MultiFactorAuthConfiguration` changed from a boolean to the values Microsoft Graph defines. Replace `$true` with `'required'` and `$false` with `'notRequired'`.

The resource also changed how it handles properties you leave out of the configuration. Before, it reset them to their initial value, which meant that a configuration without `UserDeviceQuota` set the quota to 0. Now the resource keeps the current value of the tenant. If you relied on the old behavior to reset a setting, add the property with the value you want.

## AADServicePrincipal - Swapped Group Filter Values ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

The allowed values of the `type` and `matchOn` members of `MSFT_AADServicePrincipalClaimsPolicyGroupFilter` were mixed up. This caused a configuration with values Microsoft Graph accepts to fail to compile. The values were swapped:

| Member | Before | Now |
| --- | --- | --- |
| `type` | `displayName`, `samAccountName` | `prefix`, `suffix`, `contains` |
| `matchOn` | `prefix`, `suffix`, `contains` | `displayName`, `samAccountName` |

To fix your configuration, swap the values of the two members in every group filter.

## AADPIMGroupSetting - Export Limited to PIM-Enabled Groups ([#7495](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7495))

The export of AADPIMGroupSetting used to write the default policies of every group in the tenant, including groups that aren't enabled in PIM for Groups. It now exports only the groups enabled in PIM. Your configurations keep working, but a new export contains fewer instances than an old one. The export needs the `PrivilegedAccess.Read.AzureADGroup` permission from [New Permissions](#new-permissions-7445-7496).

## Windows Autopilot Deployment Profiles - Graph Property Names ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

`IntuneWindowsAutopilotDeploymentProfileAzureADJoined` and `IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined` used properties that Microsoft Graph deprecated. They were replaced with their successors:

| Old property | New property |
| --- | --- |
| `EnableWhiteGlove` | `PreprovisioningAllowed` |
| `ExtractHardwareHash` | `HardwareHashExtractionEnabled` |
| `Language` | `Locale` |
| `OutOfBoxExperienceSettings` | `OutOfBoxExperienceSetting` |

The new `OutOfBoxExperienceSetting` property uses the class `MSFT_MicrosoftGraphoutOfBoxExperienceSetting`, and four of its members got new names:

```powershell
# Before
OutOfBoxExperienceSettings = MSFT_MicrosoftGraphoutOfBoxExperienceSettings1 {
    HideEULA                  = $false
    HideEscapeLink            = $true
    HidePrivacySettings       = $true
    SkipKeyboardSelectionPage = $true
    DeviceUsageType           = 'singleUser'
    UserType                  = 'administrator'
}

# After
OutOfBoxExperienceSetting = MSFT_MicrosoftGraphoutOfBoxExperienceSetting {
    EulaHidden                   = $false
    EscapeLinkHidden             = $true
    PrivacySettingsHidden        = $true
    KeyboardSelectionPageSkipped = $true
    DeviceUsageType              = 'singleUser'
    UserType                     = 'administrator'
}
```

In the hybrid joined resource, the old class was called `MSFT_MicrosoftGraphoutOfBoxExperienceSettings`, without the `1`. In the Azure AD joined resource, the suffix was also removed from the class of `EnrollmentStatusScreenSettings`, which is now `MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings`.

## Intune App Assignments and Targeted Apps - New Class Types ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

Two app resources now use their own assignment class, which adds the `assignmentSettings` member for the settings of the app type. The other members stay the same, so you only rename the class:

| Resource | Old class | New class |
| --- | --- | --- |
| `IntuneMobileAppsLobAppWindows10` | `MSFT_DeviceManagementMobileAppAssignment` | `MSFT_DeviceManagementAppxMobileAppAssignment` |
| `IntuneMobileAppsSystemAppAndroid` | `MSFT_DeviceManagementMobileAppAssignment` | `MSFT_DeviceManagementSystemMobileAppAssignment` |

The schema of `IntuneVPNConfigurationPolicyIOS` declared `targetedMobileApps` as a list of strings, while the export wrote complex objects. The property was updated to use the `MSFT_targetedMobileApps` class, with `appId` as its mandatory member:

```powershell
targetedMobileApps = @(
    MSFT_targetedMobileApps {
        appId       = 'com.contoso.app'
        name        = 'Contoso'
        publisher   = 'Contoso Ltd.'
        appStoreUrl = 'https://apps.apple.com/app/id000000000'
    }
)
```

## SCRetentionCompliancePolicy - Adaptive Scopes ([#7484](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7484))

The resource had a `DynamicScopeLocation` property that it never applied. It was replaced with `AdaptiveScopeLocation`, which takes the names of Purview adaptive scopes. You can manage those scopes with the new `SCAdaptiveScope` resource. For user and group scopes, set the new `Applications` property as well, for example `'User:Exchange,OneDriveForBusiness'`.

A policy uses either adaptive scopes or static locations. The resource throws an error if you combine them or switch an existing policy from one to the other. The example `4-AdaptiveScopes.ps1` of the resource shows a working configuration.

## TeamsChannelTab - New Configuration Property ([#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445))

The `ContentUrl`, `EntityId`, `RemoveUrl` and `WebSiteUrl` properties moved into the new `Configuration` complex property:

```powershell
# Before
ContentUrl = 'https://contoso.com/tab'
WebSiteUrl = 'https://contoso.com'

# After
Configuration = MSFT_MicrosoftGraphTeamsTabConfiguration {
    ContentUrl = 'https://contoso.com/tab'
    WebsiteUrl = 'https://contoso.com'
}
```

`SortOrderIndex` is now a string, matching Microsoft Graph. A number in an existing configuration keeps working.

## SCInsiderRiskPolicy - Tenant Settings Policy

An instance with `InsiderRiskScenario = 'TenantSetting'` manages the tenant settings policy of Insider Risk Management. The service creates that policy when you turn on Insider Risk Management and allows only one per tenant. The resource used to create and remove it like any other policy. Now it only updates the existing tenant settings policy, whatever its name, and throws an error for `Ensure = 'Absent'` or when Insider Risk Management isn't turned on.

If one of your instances removes the tenant settings policy, set it to `Ensure = 'Present'` or remove the instance. `InsiderRiskScenario` also accepts only the scenario names the service defines now, see [Changed Types and Accepted Values](#changed-types-and-accepted-values).

## EXOPhishSimOverrideRule and EXOSecOpsOverrideRule - Single Instance Resources

A tenant has one phishing simulation override and one SecOps mailbox override. Each consists of a policy and a rule, where the backend service generates their names. The two resources used `Identity` and `Policy` as their key and always reported the rule as absent. Both are now single instance resources with the key `IsSingleInstance = 'Yes'`. The `Identity` and `Policy` properties were removed.

EXOSecOpsOverrideRule manages the SecOps mailboxes through the new `SentTo` property, which needs at least one mailbox. `Ensure = 'Absent'` removes the rule and the SecOps mailboxes, the same as removing all entries in the Microsoft Defender portal. For EXOPhishSimOverrideRule, `Ensure = 'Absent'` removes the rule and keeps the policy.

```powershell
# Before
EXOSecOpsOverrideRule 'SecOpsOverride'
{
    Identity = '_Exe:SecOpsOverrid:ca3c51ac-925c-49f4-af42-43e26b874245'
    Policy   = '40528418-717d-4368-a1ae-7912918f8a1f'
    Comment  = 'Delivers unfiltered mail to the security operations mailbox'
    Ensure   = 'Present'
}

# After
EXOSecOpsOverrideRule 'SecOpsOverride'
{
    IsSingleInstance = 'Yes'
    SentTo           = @('secops@contoso.com')
    Comment          = 'Delivers unfiltered mail to the security operations mailbox'
    Ensure           = 'Present'
}
```

To fix your configuration, replace `Identity` and `Policy` with `IsSingleInstance = 'Yes'`. For EXOSecOpsOverrideRule, add the SecOps mailboxes in `SentTo`.

## Renamed Properties

Most of these renames align a property with the name Microsoft Graph or the underlying cmdlet uses. To fix your configuration, rename the property and keep its value.

| Resource | Old name | New name | PR |
| --- | --- | --- | --- |
| `AADAccessReviewDefinition` | `SettingsValue` | `Settings` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADApplication` | `Permissions` | `RequiredResourceAccess` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADCustomAuthenticationExtension` | `ClientConfigurationTimeoutMilliseconds` | `ClientConfigurationTimeoutInMilliseconds` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADEntitlementManagementAccessPackageAssignmentPolicy` | `Sequence` in `MSFT_MicrosoftGraphaccesspackagequestion` | `SequencePosition` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADEntitlementManagementAccessPackageCatalogResource` | `Sequence` in `MSFT_MicrosoftGraphaccessPackageResourceAttributeQuestion` | `SequencePosition` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneAppleMDMPushNotificationCertificate` | `DataSharingConsetGranted` | `DataSharingConsentGranted` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneAppProtectionPolicyiOS` | `Identity` | `Id` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneAzureNetworkConnectionWindows365` | `RoleScopeTagIds` | `ScopeIds` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneCloudProvisioningPolicyWindows365` | `RoleScopeTagIds` | `ScopeIds` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneDeviceAndAppManagementAssignmentFilter` | `Identity` | `Id` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneDeviceConfigurationVpnPolicyWindows10` | `ServerCollection` | `Servers` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneDeviceEnrollmentPlatformRestriction` | `Identity` (key) | `Id` (key) | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `O365OrgCustomizationSetting` | `Ensure` | `State` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `PlannerBucket` | `BucketId` | `Id` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `PlannerTask` | `AssignedUsers`, `Bucket`, `Notes`, `TaskId` | `Assignments`, `BucketId`, `Description`, `Id` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `TeamsFederationConfiguration` | `DomainBlockingForMDOAdminsInTeams` | `SecurityTeamAllowBlockListDelegation` | [#7516](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7516) |

The `Sequence` sub-properties clashed with a reserved PowerShell keyword, and `DataSharingConsetGranted` had a typo in its name.

## Removed Properties

To fix your configuration, remove these properties from the instances of the resource. Where a replacement exists, the third column names it.

| Resource | Removed properties | Replacement | PR |
| --- | --- | --- | --- |
| `AADAgreement` | `AcceptanceStatement` | none, Microsoft Graph doesn't define it | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADClaimsMappingPolicy` | `Description` | none, Microsoft Graph doesn't store it | |
| `AADHomeRealmDiscoveryPolicy` | `Description` | none, Microsoft Graph doesn't store it | |
| `AADRoleAssignmentScheduleRequest` | `Action`, `IsValidationOnly`, `TicketInfo` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADRoleEligibilityScheduleRequest` | `Action`, `IsValidationOnly` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `AADTokenIssuancePolicy` | `Description` | none, Microsoft Graph doesn't store it | |
| `AADTokenLifetimePolicy` | `Description` | none, Microsoft Graph doesn't store it | |
| `AADUser` | `PasswordNeverExpires` | `PasswordPolicies = 'DisablePasswordExpiration'` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `EXOActiveSyncMailboxPolicy` | `IsDefaultPolicy` | `IsDefault` | |
| `EXOAtpPolicyForO365` | `Identity` | none, the resource has a single instance | [#7508](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7508) |
| `EXODistributionGroup` | `Notes` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `EXOIRMConfiguration` | `EnablePortalTrackingLogs` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `EXOMigration` | `BadItemLimit`, `LargeItemLimit` | none, Exchange Online no longer offers them | |
| `EXOPlace` | `Desks` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `EXOTenantAllowBlockListItems` | `AppliationSecret` | `ApplicationSecret` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneAppProtectionPolicyiOS` | `DeployedAppCount` | none, the value is read-only | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneDeviceCompliancePolicyAndroidWorkProfile` | `RestrictedApps`, `SecurityBlockDeviceAdministratorManagedDevices` | none, Microsoft Graph doesn't define them for this policy type | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneSecurityBaselineMicrosoft365AppsForEnterprise` | `MicrosoftAccess_Security_TrustCenter_L_RequirethatApplicationExtensionsaresigned` | none, the v2512 baseline removed it | [#7448](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7448) |
| `IntuneSecurityBaselineMicrosoftEdge` | `WebSQLAccess`, `EdgeEnhanceImagesEnabled` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneSecurityBaselineWindows10` | `Pol_SecGuide_0202_WDigestAuthn`, `Scan_DisablePackedExeScanning` | none, the 25H2 baseline removed them | [#7448](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7448) |
| `SPOSearchResultSource` | `ShowPartialSearch` | none, SharePoint Online never applied it |  |
| `SPOTenantSettings` | `OneDriveSharingCapability` | `MySiteSharingCapability` in `SPOSharingSettings` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `TeamsCallingPolicy` | `SafeTransferEnabled` | none, MicrosoftTeams 8.0.0 removed it | [#7516](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7516) |
| `TeamsGuestMessagingConfiguration` | `UsersCanDeleteBotMessages` | `UsersCanDeleteBotMessages` in `TeamsMessagingPolicy` | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `TeamsMessagingPolicy` | `AllowExtendedWorkInfoInSearch` | `ExtendedWorkInfoInPeopleSearch` in `TeamsClientConfiguration` | |
| `TeamsOnlineVoicemailUserSettings` | `OofGreetingFollowCalendarEnabled` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `TeamsTenantNetworkSite` | `SiteAddress` | none | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |

Removed the `Ensure` property from the following resources. Their settings always exist and can't be removed. Remove `Ensure` from their instances to make them work again:

`AADB2CAuthenticationMethodsPolicy`, `AADMultiTenantOrganizationIdentitySyncPolicyTemplate`, `AADSecurityDefaults`, `EXOIRMConfiguration`, `EXOPerimeterConfiguration`, `EXOResourceConfiguration`, `ODSettings`, `SPOAccessControlSettings`, `SPOSharingSettings` and `SPOTenantSettings`.

## Changed Types and Accepted Values

| Resource | Property | Change | What to do | PR |
| --- | --- | --- | --- | --- |
| `AADConditionalAccessPolicy` | `TermsOfUse` | `String` to `String[]` | Wrap the value in `@()`. A policy can now require more than one agreement. | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `EXODynamicDistributionGroup` | `IncludedRecipients` | value `MailboxContacts` to `MailContacts` | Replace `MailboxContacts` with `MailContacts`. Exchange Online never accepted the old value. | |
| `EXOQuarantinePolicy` | `QuarantinePolicyType` | accepts only `PolicyQuarantineTag` and `GlobalQuarantineTag` | Replace `QuarantinePolicy` with `PolicyQuarantineTag` and `GlobalQuarantinePolicy` with `GlobalQuarantineTag`, the values Exchange Online returns. | |
| `EXOSweepRule` | `Mailbox` | now a key property | Set `Mailbox` on every instance. A sweep rule is identified by its name and its mailbox. | |
| `IntuneMobileAppsBundleMacOS` | `PackageFileType` | now mandatory | Add `PackageFileType = 'Dmg'` or `'Pkg'`. Intune rejected a policy without it. | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |
| `IntuneSecurityBaselineMicrosoft365AppsForEnterprise` | `Pol_SecGuide_Block_Flash` | lowercase values to `Block all Flash activation`, `Block embedded Flash activation only` and `Allow all Flash activation` | Update the casing of the value. | [#7448](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7448) |
| `IntuneSecurityBaselineWindows10` | `EnableSmartScreenDropdown` | `block` and `warn` to `Block` and `Warn` | Update the casing of the value. | [#7448](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7448) |
| `SCAutoSensitivityLabelRule` | `ExceptIfHeaderMatchesPatterns` | `String[]` to `MSFT_SCHeaderPattern` | Use the same class as `HeaderMatchesPatterns`, with the header in `Name` and the pattern in `Value`. | |
| `SCAutoSensitivityLabelRule` | `Values` in `MSFT_SCHeaderPattern` | `String[]` to a single `String` named `Value` | Rename `Values` to `Value`. It holds a single pattern. | |
| `SCDeviceConditionalAccessRule`, `SCDeviceConfigurationRule` | `FirewallStatus` | `Boolean` to `String`, only `Required` | Replace `$true` with `'Required'`. Remove the property where it was `$false`. | |
| `SCDeviceConditionalAccessRule`, `SCDeviceConfigurationRule` | `MaxPasswordGracePeriod` | `UInt32` to a time span `String` | Write the value as `dd.hh:mm:ss`, for example `'5.00:00:00'`. | |
| `SCInsiderRiskPolicy` | `InsiderRiskScenario` | free text to the scenario names the service defines | Check that the value is one of the names the resource lists, for example `LeakOfInformation` or `TenantSetting`. | |
| `SPOSearchResultSource` | `Protocol` | values `Remote` and `OpenSearch` removed | Remove the result sources that use them. Microsoft retired both protocols in September 2024, and they don't return any results. |  |
| `TeamsAudioConferencingPolicy` | `MeetingInvitePhoneNumbers` | comma-separated `String` to `String[]` | Split the value into an array, for example `@('+41441234567', '+41447654321')`. A comma-separated string keeps reporting drift. | [#7445](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7445) |

## Renamed Embedded Classes ([#7487](https://github.com/Microsoft365DSC/Microsoft365DSC/pull/7487))

A few complex types had a number at the end of their class name. They were renamed to match the type names of Microsoft Graph. Where two resources use the same Microsoft Graph type with different allowed values, the class got a distinct name instead. Since your configuration uses the class name for every complex property, you have to rename them as well:

| Resource | Old class | New class |
| --- | --- | --- |
| `AADGroupEligibilitySchedule` | `MSFT_MicrosoftGraphPatternedRecurrence1` | `MSFT_MicrosoftGraphPrivilegedAccessPatternedRecurrence` |
| `AADGroupEligibilitySchedule` | `MSFT_MicrosoftGraphRecurrencePattern1` | `MSFT_MicrosoftGraphPrivilegedAccessRecurrencePattern` |
| `AADGroupEligibilitySchedule` | `MSFT_MicrosoftGraphRecurrenceRange1` | `MSFT_MicrosoftGraphRecurrenceRange` |
| `IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10` | `MSFT_MicrosoftGraphIpRange1` | `MSFT_MicrosoftGraphIpRange` |
| `IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10` | `MSFT_MicrosoftGraphProxiedDomain1` | `MSFT_MicrosoftGraphProxiedDomain` |
| `IntuneDeviceConfigurationPolicyWindows10` | `MSFT_MicrosoftGraphdefenderDetectedMalwareActions1` | `MSFT_MicrosoftGraphdefenderDetectedMalwareActions` |
| `IntuneWindowsAutopilotDeploymentProfileAzureADJoined` | `MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings1` | `MSFT_MicrosoftGraphwindowsEnrollmentStatusScreenSettings` |

A search and replace on the old class name fixes your configuration.
