# Change log for Microsoft365DSC

* IntuneDeviceConfigurationSCEPCertificatePolicyWindows10
  * Fixed an issue when paramete RootCertificateId is empty the falback on RootCertificateDisplayName not work

# 1.26.909.1

* MISC
  * Refreshed Microsoft Graph shim module.

# 1.26.902.1

* AADApplicationFederatedIdentityCredential
  * Fixed an issue where an incorrect count check resulted in a single object
    being detected as multiple objects.
* IntuneDeviceConfigurationPlatformScriptMacOS
  * Fixed an issue where the `scriptContent` property was incorrectly converted
    to a binary array during Set.
* IntuneDeviceConfigurationPlatformScriptWindows10
  * Fixed an issue where the `scriptContent` property was incorrectly converted
    to a binary array during Set.
    FIXES [#7431](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7431)
* IntuneDeviceRemediation
  * Fixed an issue where the `DetectionScriptContent` and `RemediationScriptContent`
    properties were incorrectly converted to a binary array during Set.
* SCDLPComplianceRule
  * Updated the `GenerateAlert` property to always export as an array without
    being omitted from the export.
    FIXES [#7434](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7434)
* M365DSCGraphShim
  * Changed how an object is returned from Graph if both `value` and
    `presentation` properties are present. This fixes an issue with the resource
    `IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10`.
* MISC
  * Fixed an issue when building the Windows docker image.

# 1.26.826.1

* AADRoleAssignmentScheduleRequest
  * Added `agentUser` to `PrincipalType` to support the new agent user capability in Entra.
* AADRoleEligibilityScheduleRequest
  * Added `agentUser` to `PrincipalType` to support the new agent user capability in Entra.
* EXOIntraOrganizationConnector
  * Fixed an issue where `DiscoveryEndpoint` did not end with a trailing slash `/`.
  * Fixed a regression regarding Url to String conversion.
    FIXES [#7425](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7425)
* SPOSite
  * Fixed an issue where a site collection that could not be retrieved aborted the entire export.
* M365DSCReverse
  * Fixed issue where variable `$organization` would be empty if connecting
    using access tokens.
* DEPENDENCIES
  * Updated `DSCParser` to version 3.1.0.3.
  * Updated `MSCloudLoginAssistant` to version 1.2.4.
  * Updated `ReverseDSC` to version 2.0.0.36.
* MISC
  * Fixed build of Linux docker images by updating nano to latest version.
  * Changed both Windows and Linux docker images to install some packages
    directly in the dockerfiles, this way those installations get cached.
  * Fixed issue with Linux docker dev image where the path for PowerShell has
    changed.
  * Updated PowerShell LTS version to be installed in Linux docker image to
    `7.6.5`.
  * Simplified installation of `Microsoft365Dsc` by removing support to run
    Docker release images with older versions.

# 1.26.819.1

* AADAuthenticationMethodPolicy
  * Added additional support for Passkeys (FIDO2) as the target of a registrationcampaign.
    `TargetedAuthenticationMethod` can now contain `microsoftAuthenticator` *or* `fido2`.
* AADCertificateBasedApplicationConfiguration
  * Fixed an issue where the target address for the POST request was incorrect.
    FIXES [#7405](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7405)
* AADConditionalAccessPolicy
  * Added missing `-All` switch when fetching policies with a filter.
    FIXES [#7350](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7350)
* AADUser
  * Add support for `CustomSecurityAttributes`
    FIXES [#7399](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7399)
* EXOIntraOrganizationConnector
  * Fixed an issue where `TargetSharingEpr` could fail with a null-reference exception.
    FIXES [#7413](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7413)
* EXOOrganizationConfig
  * Added support for `EwsAllowedAppIDs` when `EwsEnabled` is set to true.
* EXOOwaMailboxPolicy
  * Added new properties `AllowedOrganizationAccountDomains`, `AttachmentsOfflineEnabledWin`,
    `BizBarEnabled`, `BookingsMailboxDomain`, `DefaultClientLanguage`, `EmptyStateEnabled`,
	`HideClassicOutlookToggleOut`, `LinkedInEnabled`, `MonthlyUpdatesEnabled`,
	`OfflineEnabledWeb`, `OfflineEnabledWin`, `OneDriveAttachmentsEnabled`, `OutlookDataFile`,
	`OutlookNewslettersAccessLevel`, `OutlookNewslettersReactions`, `OutlookNewslettersShowMore`,
	`PersonalBookingsDisabled`, `SMimeSuppressNameChecksEnabled`, `SpellCheckerEnabled`, `TasksEnabled`.
* M365DSCReverse
  * Fixed an issue where exporting the Intune workload against a tenant with no
    matching Settings Catalog configuration policies aborted the entire export.
    FIXES [#7396](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7396)
  * Fixed an issue where using multiple Filters passed through empty filters to
    other exported resources.
* SCDLPComplianceRule
  * Fixed an issue where testing a missing rule with an advanced rule containing
    ML model classifiers could fail before reporting drift.
    FIXES [#7403](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7403)
* MISC
  * Updated import warning that **PowerShell 7.6** is going to be required starting October 2026.

# 1.26.812.1

* M365DSCTenantInfo
  * Added support for Bleu and Delos sovereign cloud.
* DEPENDENCIES
  * Updated `DSCParser` to version 3.1.0.2.
  * Updated `MSCloudLoginAssistant` to version 1.2.2.
  * Updated `ReverseDSC` to version 2.0.0.35.

# 1.26.805.1

* AADApplicationFederatedIdentityCredential
  * Initial release.
* AADEntitlementManagementAccessPackage
  * Fixed an issue where a resource role scope whose `AccessPackageResourceOriginId`
    is specified as the object GUID was removed and re-added on every Set,
    eventually leaving the access package with no resource roles. The desired
    OriginId is now resolved to the same value that Get-TargetResource returns
    before comparison.
    FIXES [#7386](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7386)
* AADApplicationFederatedIdentityCredential
  * Added resource to manage federated identity credentials for Azure AD applications.
* IntuneCloudProvisioningPolicyWindows365
  * Added missing geographic location `australiaNewZealand`
* IntuneDeviceFeaturesConfigurationPolicyIOS
  * Demoted property `bookmarkFolder` from Required to Write.
* M365DSCConnection
  * Fixed an issue with client secret authentication.
* M365DSCReverse
  * Fixed an issue where filtering was not applied correctly.

# 1.26.729.2

* M365DSCConnection
  * Fixed issue connecting to a workload using `New-M365DSCConnection`.

# 1.26.729.1

* AADApplication
  * Added new properties `DefaultRedirectUri`, `Info`, `Logo` and
    `ServiceManagementReference`.
    FIXES [#4321](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4321)
* AADConditionalAccessPolicy
  * Added requirement to specify `ExcludeExternalTenantsMembershipKind` if
    `ExcludeExternalTenantsMembers` is specified during apply.
  * Assigned the value `All` as default for `ExcludeExternalTenantsMembershipKind`
    during apply.
    FIXES [#6163](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6163)
* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Fixed an issue where lookup by `DisplayName` returned all results.
    FIXES [#7374](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7374)
* AADEntitlementManagementAccessPackageCatalogResource
  * Fixed an issue where a non-existing Service Principal or Group would
    throw an error during the export instead of continuing.
* EXOManagementRole
  * Added retry and logging when `Get-ManagementRole` returns no results.
* IntuneAppConfigurationPolicy
  * Added information about no support for Settings catalog policy entries due to
    delegated authentication requirements.
    FIXES [#5672](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5672)
* IntuneDeviceManagementDeviceDiagnosticSettings
  * Initial release.
    FIXES [#4154](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4154)
* IntuneWindowsDataProcessingSettings
  * Initial release.
    FIXES [#4154](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4154)
* M365DSCConnection
  * Fixed an issue where `ApplicationSecret` was not converted to a secure string.
* SentinelAlertRule
  * Added `SubscriptionId` parameter to `Export-TargetResource`.
  * Fixed an issue where non-Sentinel Log Analytics Workspaces were exported.
* SentinelSetting
  * Added `SubscriptionId` parameter to `Export-TargetResource`.
  * Fixed an issue where non-Sentinel Log Analytics Workspaces were exported.
* SentinelThreatIntelligenceIndicator
  * Added `SubscriptionId` parameter to `Export-TargetResource`.
  * Fixed an issue where non-Sentinel Log Analytics Workspaces were exported.
* SentinelWatchlist
  * Added `SubscriptionId` parameter to `Export-TargetResource`.
  * Fixed an issue where non-Sentinel Log Analytics Workspaces were exported.
* M365DSCDocGenerator
  * Fixed an issue where not all permissions were shown on the resource docs page.
* M365DSCExportUtil
  * Removed validation from `SubscriptionId` parameter.
* M365DSCReverse
  * Updated `SubscriptionId` handling to pass to all export functions that define it.
* M365DSCUtil
  * Added the function `Update-M365DSCAuthenticationConfiguration` to update a
    configuration to use a different authentication mode and save it to a new file.
    FIXES [#3205](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/3205)
* MISC
  * Updated documentation for the `Update-M365DSCAzureAdApplication` function.
    FIXES [#5399](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5399)
  * Updated required permissions and documentation for Azure resources.
    FIXES [#6960](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6960)
  * Added support to run Docker release images with older Microsoft365DSC versions
* DEPENDENCIES
  * Updated `MSCloudLoginAssistant` to version 1.1.72.
    FIXES [#7371](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7371)

# 1.26.722.1

* O365OrgCustomizationSetting
  * Removed unused backtick in hashtable.
* O365OrgSettings
  * Added missing workload connections.
* O365SearchAndIntelligenceConfigurations
  * Added missing workload connection.
* SCDLPComplianceRule
  * Fixed an issue where trainable classifier ids in `AdvancedRule` could cause drift.
    FIXES [#7352](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7352)
* M365DSCExportUtil
  * Added auto completion for `-Components` in `Export-M365DSCConfiguration`.
  * Since `M365DSCStringReplacementMap` is now being sent in parallel exports
    as global variable we need to set it as script scope based to be able to
    inspect it.
* M365DSCReverse
  * Fixed an issue where parallel exports for EXO, O365 and SC could fail
    if combined with resources that use Microsoft Graph.
  * Fixed an issue where parallel exports were not being sent with the variable
    `M365DSCStringReplacementMap` and therefore mappings were not working and
    creating drifts.
  * Reduced the number of calls to `Get-M365DSCAllResources` if `-Components`
    was specified.
  * Reduced the number of calls to `Get-M365DSCAllResources` by caching its
    results.
* M365DSCUtil
  * Added new helper function `Get-M365DSCAllResourcesPath`
* DEPENDENCIES
  * Updated `MSCloudLoginAssistant` to version 1.1.71.
* MISC
  * Reduced time to export Intune policies by up to 50%.
  * Updated function help descriptions and added / removed parameters.

# 1.26.715.1

* AADConditionalAccessPolicy
  * Updated the code to return a GUID for `IncludeApplications` and
    `ExcludeApplications` if the input already contains that GUID.
    FIXES [#7118](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7118)
* AADIdentityGovernanceProgram
  * Deprecated resource. It is superseded by the access review resources.
* AADServicePrincipal
  * Fixed an issue where attempting to resolve 3rd-party SPNs would fail.
  * Fixed several issues when creating or updating an SPN.
* AADUser
  * Deprecate property `PasswordNeverExpires`
    FIXES [#7339](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7339)
  * Fixed issue with how `BusinessPhones` property was being sent when trying to
    set that value
* AzureBillingAccountPolicy
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureBillingAccountsAssociatedTenant
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureBillingAccountScheduledAction
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureBillingAccountsRoleAssignment
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureDiagnosticSettings
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureDiagnosticSettingsCustomSecurityAttribute
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureRoleAssignmentScheduleRequest
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureRoleAssignmentScheduleRequest
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureRoleDefinition
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
    FIXES [#7321](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7321)
* AzureRoleEligibilityScheduleRequest
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* AzureRoleEligibilityScheduleSettings
  * Added `SubscriptionId` parameter to specify the Azure subscription
    that is used to connect to.
* EXOAvailabilityAddressSpace
  * Fixed an issue where the `Credentials` property had the correct
    parameter type in its definition.
* EXODistributionGroup
  * Deprecate property `Notes`
* EXOIRMConfiguration
  * Deprecate property `EnablePortalTrackingLogs`
* EXOManagementRoleEntry
  * Deprecate property `Type`
* EXOMigration
  * Fixed unit-tests so datetimes are parsed in US-format
* EXOPlace
  * Deprecate property `Desks`
* IntuneDeviceEnrollmentScopeConfigurationMam
  * Fixed issue where function `Get-CompareParameters` was not being exported
* IntuneDeviceEnrollmentScopeConfigurationMdm
  * Fixed issue where function `Get-CompareParameters` was not being exported
* IntuneWifiConfigurationPolicyIOS
  * Added `wpa3Personal` to the `WifiSecurityType` property.
* SCDLPComplianceRule
  * Added support for the `EndpointDlpRestrictions` property.
* SettingsCatalogHelper
  * Fixed an issue where complex administrative template names
    were not handled correctly.
* Teams
  * Updated resource settings to use the Teams Reader role and remove Graph
    permissions from resources that do not require Microsoft Graph modules.
* TeamsCallQueue
  * Added new properties `AutoRecordingTemplateId`, `CallbackEmailNotificationTarget`,
    `CallbackOfferAudioFilePromptResourceId`, `CallbackOfferTextToSpeechPrompt`,
    `CallbackRequestDtmf`, `CallToAgentRatioThresholdBeforeOfferingCallback`,
    `ComplianceRecordingForCallQueueTemplateId`, `CustomAudioFileAnnouncementForCR`,
    `CustomAudioFileAnnouncementForCRFailure`, `EnableNoAgentSharedVoicemailSystemPromptSuppression`,
    `EnableNoAgentSharedVoicemailTranscription`, `EnableOverflowSharedVoicemailSystemPromptSuppression`,
    `EnableTimeoutSharedVoicemailSystemPromptSuppression`, `IsCallbackEnabled`, `NoAgentAction`,
    `NoAgentActionCallPriority`, `NoAgentActionTarget`, `NoAgentApplyTo`,
    `NoAgentDisconnectAudioFilePrompt`, `NoAgentDisconnectTextToSpeechPrompt`,
    `NoAgentRedirectPersonAudioFilePrompt`, `NoAgentRedirectPersonTextToSpeechPrompt`,
    `NoAgentRedirectPhoneNumberAudioFilePrompt`, `NoAgentRedirectPhoneNumberTextToSpeechPrompt`,
    `NoAgentRedirectVoiceAppAudioFilePrompt`, `NoAgentRedirectVoiceAppTextToSpeechPrompt`,
    `NoAgentRedirectVoicemailAudioFilePrompt`, `NoAgentRedirectVoicemailTextToSpeechPrompt`,
    `NoAgentSharedVoicemailAudioFilePrompt`, `NoAgentSharedVoicemailTextToSpeechPrompt`,
    `NumberOfCallsInQueueBeforeOfferingCallback`, `OverflowActionCallPriority`,
    `ServiceLevelThresholdResponseTimeInSecond`, `SharedCallQueueHistoryTemplateId`,
    `ShiftsSchedulingGroupId`, `ShiftsTeamId`,
    `ShouldOverwriteCallableChannelProperty`, `TimeoutActionCallPriority`,
    `WaitTimeBeforeOfferingCallbackInSecond`, `WelcomeTextToSpeechPrompt`
* TeamsGuestMessagingConfiguration
  * Deprecated property `UsersCanDeleteBotMessages`
* TeamsOnlineVoicemailUserSettings
  * Deprecated property `OofGreetingFollowCalendarEnabled`
* TeamsTenantNetworkSite
  * Deprecated property `SiteAddress`
* M365DSCCheckProperties
  * Fixed an issue with function `Get-PropertyReport` where it wasn't working
    because the `Teams` module was being loaded last and causing conflicts
  * Added authentication methods `ApplicationSecret`, `AccesstTokens` and
    `ManagedIdentity` as internal M365DSC properties that should to be ignored
* M365DSCDllLoader
  * Fixed an issue when trying to load assemblies that were already loaded.
* M365DSCDocGenerator
  * Moved function `Get-TemporaryPath` to `M365DSCUtil` and use `$env:TEMP`
    directly instead of the function's output
* M365DSCErrorHandler
  * Fixed an issue when writing in parallel to the same export file.
* M365DSCExportUtil
  * Fixed a formatting issue with `CertificatePassword` during export.
  * Removed usage of function `Resolve-Credentials` and instead just use the
    appropriate hardcoded strings
* M365DSCModuleMgmt
  * Fixed invalid arg used in Confirm-M365DSCLoadedModule when run in Windows Powershell 5.1
* M365DSCReverse
  * Fixed an issue with `Credential` and `CertificatePassword` parameters.
  * Fixed an issue generating the blueprint if using Azure Automation with
    `Credential` parameter.
  * Fixed an issue when exporting resources in parallel.
  * Removed usage of function `Save-Credentials` since it's not required any
    longer.
* M365DSCUtil
  * Added function `Get-TemporaryPath` taken from `M365DSCDocGenerator` and use
    its output to assign `$env:TEMP` variable
  * Enabled parallel export on `Assert-M365DSCBlueprint`
* DEPENDENCIES
  * Updated `MSCloudLoginAssistant` to version `1.1.69`.
* MISC
  * Added Docker image publishing for Windows and Linux platforms.
  * Updated workflow triggers for GitHub Actions.
  * Stopped pinning Pester dependency to `5.7.1` on Docker images since all
    tests were made compatible in previous release with version `6.x`
* Added `License Requirements` section to README.md documenting Microsoft
    365 E5 / Defender for Office 365 Plan 2 licensing requirements for EXO
    Defender resources.


# 1.26.708.1

* AADAdministrativeUnit
  * Added test for duplicated DisplayName across AUs
  * Fixed an issue that made unit tests under Windows PowerShell fail.
* AADCustomSecurityAttributeDefinition
  * Fixed an issue where missing allowed values were not added to existing
    custom security attribute definitions.
    FIXES [#7305](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7305)
* AADEntitlementManagementAccessPackageCatalog
  * Fixed an issue that made unit tests under Windows PowerShell fail.
* AADGroup
  * Fixed an issue where `GroupTypes` would be returned as a null object.
    FIXES [#7253](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7253)
* AADTenantAppManagementPolicy
  * Fixed an issue where the `RestrictForAppsCreatedAfterDateTime` timestamp
    was incorrectly converted to a DateTime object.
    FIXES [#7291](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7291)
* AzureBillingAccountScheduledAction
  * Fixed an issue that made unit tests under Windows PowerShell fail.
* IntuneDeviceCompliancePolicyMacOS
  * Fixed an issue where `ScheduledActionsForRule` was not compared correctly.
* M365DSCExportUtil
  * Updated the export to use the Microsoft365DSC module path as base for the
    resource import.
* M365DSCReport
  * Removed check for PowerShell remoting.
* M365DSCTelemetryEngine
  * Removed the output when connecting to Microsoft Graph for telemetry.
    FIXES [#7302](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7302)
* M365DSCUtil
  * Added `ApplicationSecret`, `ManagedIdentity` `AccessTokens` to the
    `Assert-M365DSCBlueprint` function.
  * Fixed an issue with the foreground color when run under Linux.
  * Fixed an issue where `$env:TEMP` was not defined when run under Linux.
* MISC
  * Added Dockerfile and an ancillary script which is used to install
    Microsoft365DSC module and its dependencies on that Windows docker image.
  * Fixed an issue where assignments through a policy set were exported for
    resources that were not of the `IntunePolicySets` type.
  * Fixed unit tests so that they all pass under both Windows PowerShell and
    PowerShell 7.
  * Updated all unit tests for Pester v6.0.0.
  * Updated the drift event to mask authentication parameters in the message.
# 1.26.701.1

* AADCrossTenantAccessPolicyConfigurationPartner
  * Fixed an issue when updating the policy with invalid property names.
    FIXES [#7272](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7272)
* AADDomain
  * Fixed an issue with invalid casing of properties.
    FIXES [#7285](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7285)
* AADGroup
  * Fixed an issue where empty `Members` or `GroupAsMembers` arrays triggered a full
    group membership enumeration during `Get-TargetResource`.
    FIXES [#7274](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7274)
* EXOEmailAddressPolicy
  * Fixed an issue when updating the default policy.
    FIXES [#7271](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7271)
* EXOOrganizationConfig
  * Fixed an issue where processing would fail if any of the properties
    `DelayedDelicensingEnabledState`, `EndUserMailNotificationForDelayedDelicensingState`
    or `TenantAdminNotificationForDelayedDelicensingState` were null.
    FIXES [#7248](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7248)
* IntuneAntivirusPolicyLinux
  * Added support for the properties `offlinedefinitionupdatefallbacktocloud`,
    `offlinedefinitionupdateurl`, `scheduledScan_dailyConfiguration_timeOfDay`,
    `scheduledScan_interval`, `scheduledScan_runScanWhenIdle` and
    `scheduledScan_weeklyConfiguration_timeOfDay`.
    FIXES [#7267](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7267)
* IntuneDiagnosticSettings
  * Initial release.
    FIXES [#7282](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7282)
* IntuneEpmElevationSettingsPolicyWindows10
  * Fixed an issue where property `DefaultBehaviorValidation` didn't have the
    correct validate set which could result in failing the compilation to MOF
    FIXES [#7256](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7256)
* IntuneRoleAssignment
  * Fixed an issue where creating or updating a resource failed if the property
    `ResourceScopes` was omitted.
    FIXES [#7247](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7247)
* IntuneSettingCatalogCustomPolicyWindows10
  * Fixed an issue where simple settings with whitespaces were not exported correctly.
    FIXES [#7207](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7207)
* IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Fixed an issue where updating assignments could include assignments through Policy Sets.
* IntuneWindowsAutopilotDevicePreparationAutomaticPolicy
  * Initial release.
    FIXES [#7259](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7259)
* IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy
  * Initial release.
    FIXES [#7259](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7259)
* SCLabelPolicy
  * Added support for handling `ModernGroupLocation` and `ExchangeLocation`
    during apply of the resource.
  * Fixed an issue with drift detection.
    FIXES [#7276](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7276)
* SentinelAlertRule
  * Fixed an issue where creating a new rule fails due to $null type coercion
    FIXES [#7265](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7265)
* SPOSharingSettings
  * Improved host site look from O(n) to O(1) with fallback logic.
* IntunePolicyAssignmentComparer
  * Fixed an issue where comparing assignments would skip assignments
    if the `groupId` property was omitted.
    FIXES [#7254](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7254)
* M365DSCExportUtil
  * **PREVIEW**: Added the parameter `-IncludeDependencies` to `Export-M365DSCConfiguration`
    to automatically export resources that are referenced by other resources.
    FIXES [#597](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/597)
* M365DSCGraphShim
  * Added error handling for Multi Admin Approval in Intune.
* M365DSCTelemetryEngine
  * Fixed an issue where connection setup to Microsoft Graph would fail for
    non-public clouds.
    FIXES [#7255](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7255)
* M365DSCUtil
  * Added support for sending push notifications through new function
    `Send-M365DSCPushNotification`, currently it's only called after finishing
    an export
* DEPENDENCIES
  * Updated `MSCloudLoginAssistant` to version `1.1.68`.
* MISC
  * Added Viva selector to the web-based GUI.

# 1.26.617.1

* AADAdministrativeUnit
  * Fixed validation of scoped role members' uniqueness
* AADApplication
  * Fixed an issue where the delegated permissions were not returned as an array.
    FIXES [#7190] (https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7190)
* AADConditionalAccessPolicy
  * Fixed an issue where an empty `Id` would result in all policies being returned.
    FIXES [#7225](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7225)
* AADCrossTenantAccessPolicyConfigurationPartner
  * Fixed an issue where not all properties were exported.
    FIXES [#7203](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7203)
* AADCustomSecurityAttributeDefinition
  * Fixed an issue when adding a new value to an existing definition.
    FIXES [#7191](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7191)
* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Fixed comparison in New-M365DSCDeltaReport.
  * Fixed an issue where a `description` property was exported within a reviewer.
* AADEntitlementManagementRoleAssignment
  * Fixed an issue when resolving a user principal during the Set operation.
    FIXES [#7223](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7223)
* AADGroup
  * Various timing-related fixes for new group
  * Fixed an issue with invalid casing of properties.
    FIXES [#7224](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7224)
  * Fixed an issue when updating the `MemberOf` property.
  * Fixed an issue where an empty `Id` would result in all groups being returned.
    FIXES [#7225](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7225)
  * Fixed an issue where `MemberOf` and `GroupAsMembers` could not be set if both
    properties were set to an empty array.
* AADGroupsSettings
  * Fixed issue with handling of existing DirectorySetting-object during update
* AADServicePrincipal
  * Fixed and issue where Custom SecurityAttributes were not handled properly.
    FIXES [#7192](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7192)
  * Fixed an issue where adding `AppRoleAssignedTo` assignments could send a null app role id.
    FIXES [#7235](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7235)
* AADTenantAppManagementPolicy
  * Fixed an issue when updating the resource.
    FIXES [#7201](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7201)
* AADUser
  * Fixed issues for timing-related new user
  * Fixed an issue where Administrative Units were exported in the `MemberOf` collection.
    FIXES [#7198](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7198)
* EXOHostedContentFilterPolicy
  * Fixed export of AllowedSenderDomains, AllowedSenders, BlockedSenderDomains, BlockedSenders
* IntuneAntivirusPolicyLinux
  * Added support for new properties and fixed an issue where values were not exported correctly.
    FIXES [#7185](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7185)
* IntuneAntivirusPolicyMacOS
  * Added support for new properties and fixed an issue where values were not exported correctly.
    FIXES [#7218](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7218)
* IntuneDeviceCompliancePolicyMacOS
  * Fixed an issue where `ScheduledActionsForRule` was exported as a String array.
    FIXES [#7220](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7220)
* IntuneDeviceConfigurationPlatformScriptMacOS
  * Removed `Id` as being a mandatory parameter
    FIXES [#7243](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7243)
* IntuneDeviceConfigurationPlatformScriptWindows
  * Removed `Id` as being a mandatory parameter
    FIXES [#7243](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7243)
* IntuneDeviceConfigurationPolicyAndroidDeviceOwner
  * Fixed an issue where a wrong instance name was used for `KioskModeAppPositions`.
    FIXES [#7186](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7186)
* O365OrgSettings
  * Fixed intermittent exception comparing install-options
* SCDLPCompliancePolicy
  * Fixed a parameter binding issue when resolving groups.
    FIXES [#7209](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7209)
* SPOTenantSettings
  * Improved handling of parameters when updating settings.
  * Fixed an issue where Graph parameters were skipped.
    FIXES [#7227](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7227)
* M365DSCGraphShim
  * Fixed an issue where uris with a # were not resolved properly.
* M365DSCPermissions
  * Fixed an issue when updating app certificates.
    FIXES [#7205](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7205)
* SettingsCatalogHelper - C#
  * Added forward slash character replacement in property names.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.67.
* MISC
  * Fixed an issue where `CertificatePath` and `CertificatePassword` parameters
    were omitted during export of several resources.
    FIXES [#7208](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7208)
  * Fixed an issue where `-Force` was not used for `Set-PnPTenant`.
    FIXES [#7226](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7226)

# 1.26.603.1

* AADConditionalAccessPolicy
  * Improved handling of multiple custom security attributes instead of just one
    in `ServicePrincipalFilterRule`.
* AADFilteringPolicyRule
  * Fixed an issue where an incorrect number of instances to export was shown.
* AADOrganizationCertificateBasedAuthConfiguration
  * Fixed an issue where the `Certificate` property was incorrectly converted using `ToBase64String`
    when the Graph SDK already returns it as a Base64 string.
    FIXES [#7193](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7193)
* AzureRoleDefinition
  * Initial Release
    FIXES [#7077](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7077)
* EXOReportSubmissionPolicy
  * Removed export line for the configuration because it is single instance.
* IntuneDeviceCompliancePolicyiOS
  * Fixed an issue when omitting `ScheduledActionsForRule` during creation.
* IntuneDeviceCompliancePolicyMacOS
  * Fixed an issue when omitting `ScheduledActionsForRule` during creation.
* IntuneDeviceConfigurationPolicyAndroidOpenSourceProject
  * Fixed an issue when updating an instance of the resource.
* IntuneRoleDefinition
  * Fixed an issue when omitting `notAllowedResourceActions`.
* O365OrgSettings
  * Fixed an issue when updating the `Office Online Unused API` service principal.
    FIXES [#7175](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7175)
* M365DSCPermissions
  * Fixed an issue when updating app permissions.
    FIXES [#7182](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7182)
* M365DSCReverse
  * Fixed an issue where the number of resources to export could be wrong.
* MISC
  * Fixed an issue where `Az.Accounts` failed to import.

# 1.26.527.1

* AADAccessReviewDefinition
  * Added new properties `AdditionalNotificationRecipients` and `InstanceEnumerationScope`.
  * Fixed issues when creating and updating instances of this resource.
* AADAuthenticationRequirement
  * Changed resource type from `Configuration` to `Data`.
* AADCustomAuthenticationExtension
  * Added missing application update permission `CustomAuthenticationExtension.ReadWrite.All`.
* AADEntitlementManagementConnectedOrganization
  * Removed required value `ExternalTenantId`.
    FIXES [#7102](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7102)
* AADEntitlementManagementAccessPackageCatalogResource
  * Changed properties `CatalogId` and `OriginId` to their display name equivalent.
* AADGroup
  * Added pause / wait after creating or restoring a group until group is provisioned.
  * Removed a duplicate update call if a group was newly created.
* AADPIMGroupSetting
  * Changed resource type from `Configuration` to `Data`.
* AADServicePrincipal
  * Added additional schema definitions for more claims information.
  * Added support for `groupFilter` in the claims policy.
    FIXES [#7102](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7102)
* AADTenantAppManagementPolicy
  * Changed the `MaxLifetime` property in application + service principal restrictions
    --> key and password credentials to only include necessary date and time information.
* EXOCASMailboxSettings
  * Changed resource type from `Configuration` to `Data`.
* EXOMailboxCalendarConfiguration
  * Changed resource type from `Configuration` to `Data`.
* EXOMailboxIRMAccess
  * Changed resource type from `Configuration` to `Data`.
* EXORecipientPermission
  * Changed resource type from `Configuration` to `Data`.
* EXOSharedMailbox
  * Changed resource type from `Configuration` to `Data`.
* EXOSweepRule
  * Changed resource type from `Configuration` to `Data`.
* IntuneAndroidManagedStoreAppConfiguration
  * Changed property `targetedMobileApps` to use display name instead of app id.
* IntuneDeviceCompliancePolicyAndroidWorkProfile
  * Added support for the property `RoleScopeTagIds`.
* IntuneDeviceCompliancePolicyiOs
  * Added support for the property `ScheduledActionsForRule`.
* IntuneDeviceConfigurationPolicyMacOS
  * Fixed an issue where profiles that didn't match the filter were being exported.
* IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile
  * Standardized time format of `TokenExpirationDateTime` and excluded it from comparison.
* IntunePolicySets
  * Updated resource to work with multitenants.
* O365OrgSettings
  * Fixed handling of Office on the Web SPN in new tenants
* SCDLPComplianceRule
  * Fixed an issue where an attempt was made to resolve trainable classifiers with a null Id.
    FIXES [#7156](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7156)
* SCDLPSensitiveInformationType
  * Removed the parameter verbose output to prevent screen cluttering.
    FIXES [#7145](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7145)
  * Removed exporting instances that belong to the `SCDLPSensitiveInformationTypeRulePackage`
    resource type.
    FIXES [#7144](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7144)
* SCDLPSensitiveInformationTypeRulePackage
  * Initial release.
    FIXES [#7144](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7144)
* SCInsiderRiskPolicy
  * Fixed an issue where notification values were tried to be set
    even though the feature was neither configured nor enabled.
    FIXES [#7162](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7162)
* SPOStorageEntity
  * Fixed an issue where applying entries to a protected app catalog failed.
    FIXES [#6895](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6895)
* SPOTenantCdnPolicy
  * Fixed an issue where property values were not being returned.
* TeamsAIPolicy
  * Added property `PassiveVoiceEnrollment`.
* TeamsCallQueue
  * Added properties `TextAnnouncementForCR`, `TextAnnouncementForCRFailure`
    and `HideAuthorizedUsers`.
* TeamsCallingPolicy
  * Added property `ReportCall`.
* TeamsClientConfiguration
  * Added properties `ExtendedWorkInfoInPeopleSearch` and `UseUnifiedDomain`.
* TeamsEventsPolicy
  * Added properties `BackroomChat`, `ExternalPresenterJoinVerification`, `Registration`
    and `TownhallMaxResolution`.
* TeamsFederationConfiguration
  * Added properties `AllowedTrialTenantDomains` and `BlockAllSubdomains`.
* TeamsFilesPolicy
  * Fixed an issue where `DefaultFileUploadAppId` was not exported.
* TeamsGuestMeetingConfiguration
  * Added property `AllowMultipleScreenshare`.
* TeamsMeetingPolicy
  * Added properties `AllowMultipleScreenshare`, `BackroomChat`, `PasscodeComplexity`
    and `SetRecordingAndTranscriptOwnership`.
* TeamsMobilityPolicy
  * Added property `LinksInTeams`.
* TeamsNotificationAndFeedsPolicy
  * Initial release.
* TeamsTargetingPolicy
  * Initial release.
* M365DSCDllLoader
  * Fixed an issue where an attempt was made to read the `HKLM:` drive on non-Windows systems.
    FIXES [#7157](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7157)
* M365DSCReverse
  * Added functionality to use wildcards in the `-Components` parameter when exporting.
  * Fixed an issue where the resources to export counter did not match the actual value.
* C# - SettingCatalogPolicySettingBuilder
  * Fixed an issue if a setting definition appears multiple times in the same instance template.
* MISC
  * Introduced Microsoft Graph shim layer.
  * Refactored filters on Graph calls to be done on the server side instead of locally.
  * Streamlined authentication parameters across all resources and added `CertificatePath`
    and `CertificatePassword` to supported resources.
    FIXES [#7147](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7147)
* Dependencies
  * Removed all `Microsoft.Graph.*` dependencies except for `Microsoft.Graph.Authentication`.
  * Updated `MSCloudLoginAssistant` to version 1.1.66.
    FIXES [#7154](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7154)
  * Updated `Az.Accounts` to version 5.3.2.
    FIXES [#7143](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7143)
  * Updated `Az.Resources` to version 9.0.1.
  * Updated `Az.Security` to version 1.8.0.
  * Updated `Az.SecurityInsights` to version 3.2.1.

# 1.26.520.1

* AADConditionalAccessPolicy
  * Added the new property `ContinuousAccessEvaluationMode`.
    FIXES [#7132](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7132)
  * Fixed an issue where a `SessionControl` object with all null values
    was used in combination with `ProtocolFlows`.
    FIXES [#7119](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7119)
* EXODynamicDistributionGroup
  * Initial release.
* EXOManagementRole
  * Added error handler when fetching resource information.
    FIXES [#7124](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7124)
* EXOOrganizationConfig
  * Added the new property `DLPViaDcsEnabled`.
    FIXES [#7138](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7138)
* IntuneAppControlForBusinessPolicyWindows10
  * Deprecated resource.
* IntuneAppControlForBusinessPolicyWindows10V2
  * Initial release. Supersedes `IntuneAppControlForBusinessPolicyWindows10`.
    FIXES [#7129](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7129)
* IntuneAppProtectionPolicyAndroid
  * Fixed an issue where configuring `ExemptedAppPackages` would fail.
    FIXES [#7135](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7135)
* SCDLPCompliancePolicy
  * Added new parameters `OneDriveSharedBy`, `OneDriveSharedByMemberOf`,
    `ExceptIfOneDriveSharedBy` and `ExceptIfOneDriveSharedByMemberOf`.
    FIXES [#7123](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7123)
* SCInsiderRiskPolicy
  * Added new parameters `AIAppRiskyPrompt`, `EmailSignatureExclusionSettingsEnabled`,
    `UserAnalyticsSettingsEnabled`, `CCPromptShields`, `CCProtectedMaterialDetection`,
    `CCSensitiveInformationType`, `CCSupervisionRuleMatch`, `CompromisedSignInAlerts`,
    `CompromisedUserAlerts`, `ConnectedAIAppRiskyPrompt`, `ConnectedAIAppSensitiveResponse`,
    `CopilotRiskyPrompt`, `CopilotSensitiveResponse`, `FabricExternalDataSharingSwitchEnabled`,
    `HighSeverityDlpRuleMatch`, `LakehouseArtifactDeleted`, `LakehouseExternalDataShareCreated`,
    `LakehouseFileOrBlobDeleted`, `LakehouseSensitivityLabelDowngraded`,
    `LakehouseSensitivityLabelRemoved`, `NetworkDownloadFile`, `NetworkDownloadText`,
    `NetworkUploadFile` and `NetworkUploadText`.
  * Fixed an issue when applying the policy.
* VivaEngagementRoleMember
  * Added missing permission `User.ReadBasic.All` to the resource.
    FIXES [#7133](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7133)
* M365DSCDocGenerator
  * Fixed an issue where the directory for the generated documentation
    was not found at the intended location.
    FIXES [#7128](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7128)
* M365DSCErrorHandler
  * Updated temporary export save operation to use file stream writer
    to reduce I/O usage.
* M365DSCExportUtil
  * Added the `VIVA` workload to the list of supported workloads to export.
  * Fixed an issue where the organization name was not
    replaced with `$OrganizationName` during configuration export.
* M365DSCReport
  * Added the option to use variable substitution during report generation
    with `New-M365DSCDeltaReport`. Please refer to the function documentation
    page for guidance on how to use this new functionality.
* M365DSCReverse
  * Updated the parallel export to use `ConcurrentDictionary` instead of
    a synchronized hashtable to improve parallel performance.
* M365DSCTelemetryEngine
  * Reduced number of calls to resolve assignments and role definitions.
* MISC
  * Bump GitHub Action dependencies.
  * Code cleanup in export functions.
  * Improved export of some resources.
  * Improved ordered instance logging for parallel export.
  * Reduced string memory allocations during export.
  * Updated Guid parsing with a reference to the empty Guid instance.
* DEPENDENCIES
  * Updated `DSCParser` to version 3.0.0.5.
    FIXES [#7122](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7122)

# 1.26.506.2

* AADEntitlementManagementConnectedOrganization
  * Fixed an issue where internal and external sponsors that are group were
    not resolved correctly and omitted during the export.
* ComplexObjectConverter
  * Fixed an issue where `ToDscString` was not handling ArrayList correctly.
    FIXES [#7103](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7103)
* IntuneDeviceConfigurationKioskPolicyWindows10
  * Fixed an issue where `odataType` was required for elements of type
    `MSFT_MicrosoftGraphWindowsKioskWin32App` that don't need to have it specified.
* IntuneDeviceConfigurationPolicyAndroidDeviceOwner
  * Fixed an issue where not all properties were exported in elements of `KioskModeApps`.
    FIXES [#7102](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7102)
* IntuneDeviceEnrollmentPlatformRestriction
  * Added the new properties `TvosRestriction` and `VisionOSRestriction`.
* SCDLPComplianceRule
  * Fixed an issue where `ContentContainsSensitiveInformation` was not defined as array.
* M365DSCUtil
  * Reverted a change to array return values with `-NoEnumerate`.
    FIXES [#7105](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7105)

# 1.26.506.1

* AADServicePrincipal
  * Fixed an issue where service principal as owners for other service principals
    were not exported or applied correctly.
    FIXES [#5939](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5939)
* EXOServicePrincipal
  * Fixed an issue where the export was not possible for service principals with
    a missing `AppDisplayName` in their object.
    FIXES [#7086](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7086)
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Fixed an issue where an empty `Value` property was exported.
    FIXES [#7085](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7085)
* O365ExternalConnection
  * Fixed an issue where resolving multi-tenant applications from other tenants failed.
    FIXES [#5156](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5156)
* O365OrgSettings
  * Updated the resource to skip Viva Insights settings if not all permissions are given.
    FIXES [#4146](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4146)
* SentinelAlertRule
  * Fixed an issue where the create failed when sending an empty EntityMapping property.
    FIXES [#7088](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7088)
* M365DSCPermissions
  * Added the parameter `-GroupByResourceName` to allow grouping of permissions to resources.
    FIXES [#3665](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/3665)
  * Fixed documentation and dependency check issues in `Update-M365DSCAzureADApplication`.
    FIXES [#5694](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/5694)
* M365DSCReport
  * Improved drift visibility for arrays with many elements using `Delta` bullet points.
    FIXES [#4469](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4469)
* M365DSCUtil
  * Added the new function `Get-M365DSCResourceDifferences`, which returns newly
    added or removed resources between different module versions.
    FIXES [#4416](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/4416)
* MISC
  * Changed the directory path separator from backslash (\\) to forward slash (/)
    to ensure cross-platform compatibility.
    FIXES [#7097](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7097)
* DEPENDENCIES
  * Rolled back the `Microsoft.Graph.*` dependencies to version 2.35.1 to avoid
    conflict with the `ExchangeOnlineManagement` dependency.
    FIXES [#7095](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7095)
    FIXES [#7091](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7091)

# 1.26.422.1

* AADApplication
  * Fixed an issue where the value of `Value` in `MSFT_MicrosoftGraphAppRole` was missing.
    FIXES [#7064](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7064)
* AADB2BManagementPolicy
  * Initial release.
* AADConditionalAccessPolicy
  * Fixes an issue when applying a configuration where some settings are not specified to an existing policy
* AADPasswordRuleSettings
  * Fixed an issue where invalid condition checks were in-place.
* AADPermissionsGrantPolicy
  * Fixed an issue when comparing `AADPermissionGrantConditionSet` instances.
    FIXES [#7062](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7062)
* AADServicePrincipal
  * Fixed an issue where `odataType` and `userType` were missing from the
    `MSFT_AADServicePrincipalCustomClaimCondition` instances.
* EXOCASMailboxPlan
  * Fixed an issue where `Identity` was missing in the export.
* EXODataEncryptionPolicy
  * Fixed an issue when comparing `AzureKeyIDs` elements.
    FIXES [#7069](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7069)
* TeamsTenantDialPlan
  * Fixed issue so that `NormalizationRules` are always exported as an array even
    when they only contain one entry
* TeamsOnlineVoicemailPolicy
  * Fixed `MaximumRecordingLength` handling by aligning type to `Int32` and
    converting values to `TimeSpan` seconds for Teams cmdlets.
    FIXES [#7054](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7054)
* M365DSCModuleMgmt
  * Fixed an issue when updating the module from a custom import.
* M365DSCIntuneUtil
  * Fixed an issue where a settings array was returned as a single element.
    FIXES [#7055](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7055)
* M365DSCUtil
  * Added retry logic for too many requests when invoking batch requests.
* Dependencies
  * Updated `DSCParser` to version 3.0.0.4.
    FIXES [#7056](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7056)

# 1.26.408.1

* AADAccessReviewDefinition
  * [BREAKING CHANGE] Fixed the type definition of the `ScopeValue` property.
  * Changed the export type from `Configuration` to `Data`. It now only appears in
    the export file during a `Full` export.
* AADApplication
  * Added name resolution for `AppId` and `PermissionIds` in preauthorized applications.
* AADAuthenticationMethodPolicy
  * [BREAKING CHANGE] Added `IsSingleInstance` parameter.
    Removed `Ensure`, `DisplayName`, `Description`, `Id` and `PolicyVersion`
  * Fixed error in parameters.
* AADAuthenticationMethodPolicy*
  * Streamlined group resolution during update operation.
  * Streamlined Target name resolution for all authentication resources.
* AADConditionalAccessPolicy
  * Added application name resolution and fix warning messages.
    FIXES [#6902](https://github.com/microsoft/Microsoft365DSC/issues/6902)
* AADCrossTenantAccessPolicyConfigurationPartner
  * Fixed an issue where the schema was incorrect.
    FIXES [#6998](https://github.com/microsoft/Microsoft365DSC/issues/6998)
* AADDomainFederation
  * Initial Release
    FIXES [#6995](https://github.com/microsoft/Microsoft365DSC/issues/6995)
* AADGroupEligibilityScheduleSettings
  * Added the missing permission `RoleManagementPolicy.ReadWrite.AzureADGroup`.
* AADNetworkAccessForwardingPolicy
  * Fixed an issue with a property type declaration in the schema file.
* AADPIMGroupSetting
  * [BREAKING CHANGE] Fix typo in use of Elegibility -> Eligibility
    FIXES [#7021](https://github.com/microsoft/Microsoft365DSC/issues/7021)
  * Updated the export to be in sequential Entra group order to minimize Git changes.
* AADRoleSetting
  * [BREAKING CHANGE] Fix typo in use of Elegibility -> Eligibility
    FIXES [#7021](https://github.com/microsoft/Microsoft365DSC/issues/7021)
* AADServicePrincipal
  * Added the property `ClaimsPolicy` to the resource.
    FIXES [#6448](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6448)
  * Fixed an issue when updating the policy.
* AADTenantAppManagementPolicy
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Ensure` parameter.
* AADTokenLifetimePolicy
  * Fixed an issue where `Definition` could contain multiple escaped characters.
* EXOActiveSyncMailboxPolicy
  * Changed cmdlets from `*-ActiveSyncMailboxPolicy` to `*-MobileDeviceMailboxPolicy`.
  * [BREAKING CHANGE] Updated property names to match newly returned values and parameters.
    Added new properties `AllowGooglePushNotifications` and `AllowMicrosoftPushNotifications`.
* EXOAvailabilityConfig
  * [BREAKING CHANGE] Updated resource to be `IsSingleInstance`.
  * Added support for `AllowedTenantIds`.
* EXODkimSigningConfig
  * Fixed an issue to create new DkimSigningConfig
    FIXES [#6982](https://github.com/microsoft/Microsoft365DSC/issues/6982)
* EXOIRMConfiguration
  * Added support for EnablePortalTrackingLogs
    FIXES [#6992](https://github.com/microsoft/Microsoft365DSC/issues/6992)
  * Changed the parameters `LicensingLocation` and `RMSOnlineKeySharingLocation`
    to `System.String` instead of an implicit conversion to `System.Uri`.
* EXOMigration
  * Fixed an issue where `UserEmails` could contain empty strings.
* EXORoleGroup
  * Fixed an issue where multiple role groups with the same Identity were checked.
* EXOSharedMailbox
  * Added support for properties `MessageCopyForSendOnBehalfEnabled` and
    `MessageCopyForSentAsEnabled` and while here fixed several issues with this
    resource
* EXOTenantAllowBlockListItems
  * [BREAKING CHANGE] Removed the Microsoft reserved `SubmissionID` parameter.
  * [BREAKING CHANGE] Updated the property `Action` to be Required instead of Key.
* IntuneAppAndBrowserIsolationPolicyWindows10
  * Updated several parameter types from String to Integer.
* IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr
  * Updated several parameter types from String to Integer.
* IntuneAppleMDMPushNotificationCertificate
  * [BREAKING CHANGE] Removed the `Id` parameter because it is random.
* IntuneDerivedCredential
  * Added support for `xTec` as an issuer.
* IntuneDeviceCompliancePolicyAndroidWorkProfile
  * Updated the resource to use display names for `NotificationTemplateId`
    and `NotificationMessageCCList`.
  * Updated the resource to omit `NotificationTemplateId` if it is set to
    `00000000-0000-0000-0000-000000000000`.
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Updated the resource to use display names for `NotificationTemplateId`
    and `NotificationMessageCCList`.
  * Updated the resource to omit `NotificationTemplateId` if it is set to
    `00000000-0000-0000-0000-000000000000`.
* IntuneDeviceCompliancePolicyWindows10
  * Fixed an issue where `NotificationMessageCCList` would be exported
    without quotes around the group names.
* IntuneDeviceConfigurationDefenderForEndpointOnboardingPolicyWindows10
  * [BREAKING CHANGE] Renamed resource to
    `IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10`.
    FIXES [#6559](https://github.com/microsoft/Microsoft365DSC/issues/6559)
* IntuneDeviceConfigurationHealthMonitoringConfigurationPolicyWindows10
  * [BREAKING CHANGE] Renamed resource to
    `IntuneDeviceConfigurationHealthMonitoringPolicyWindows10`.
    FIXES [#6559](https://github.com/microsoft/Microsoft365DSC/issues/6559)
* IntuneDeviceConfigurationKioskPolicyWindows10
  * [BREAKING CHANGE] Removed property `ProfileId` from the
    `MSFT_MicrosoftGraphWindowsKioskProfile` instance.
* IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10
  * [BREAKING CHANGE] Removed the property `CidrAddress` from `MicrosoftGraphIpRange1`
    and removed the `#microsoft.graph.iPv4/6CidrRange` values from `odataType`.
    Only IPv4/v6 ranges are supported in the UI.
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fixed an issue where `SelectedMobileAppNames` could contain empty strings
    during the execution of `Test-TargetResoure`.
* IntuneDiskEncryptionPDEPolicyWindows10
  * Updated several parameter types from String to Integer.
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Updated the `SampleSharing` parameter from String to Integer.
* IntuneExploitProtectionPolicyWindows10SettingCatalog
  * Updated the `DisallowExploitProtectionOverride` parameter from String to Integer.
* IntuneMobileAppsMacOSLobApp
  * [BREAKING CHANGE] Updated the `Assignments` parameter type to allow settings.
* IntuneMobileAppsBuiltInStoreApp
  * [BREAKING CHANGE] Updated the `Assignments` parameter type to allow settings.
  * Renamed CIM class for assignments from `MSFT_DeviceManagementMobileAppAssignment`
    to `MSFT_DeviceManagementBuiltInStoreAppAssignment`.
* IntuneMobileAppsLobAppiOS
  * [BREAKING CHANGE] Updated the `Assignments` parameter type to allow settings.
  * Renamed CIM class for assignments from `MSFT_DeviceManagementMobileAppAssignment`
    to `MSFT_DeviceManagementLobAppiOSAssignment`.
* IntuneMobileAppsMacOSLobApp
  * Renamed CIM class for assignments from `MSFT_DeviceManagementMobileAppAssignment`
    to `MSFT_DeviceManagementMacOSLobAppAssignment`.
* IntuneMobileAppsManagedGooglePlayApp
  * [BREAKING CHANGE] Updated the `Assignments` parameter type to allow settings.
  * Added support for `androidManagedStoreAppTrackIds` in the assignment settings.
  * Renamed CIM class for assignments from `MSFT_DeviceManagementMobileAppAssignment`
    to `MSFT_DeviceManagementManagedGooglePlayMobileAppAssignment`.
* IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled
  * [BREAKING CHANGE] Removed the `*CidrRange` choices from the ipRange type.
* PPTenantSettings
  * Changed type of `EnableDesktopFlowDataPolicyManagement` property from String to
    Boolean to avoid errors or warnings.
    FIXES [#6740](https://github.com/microsoft/Microsoft365DSC/issues/6740)
* SCDLPComplianceRule
  * Added property `Quarantine` to the resource.
    FIXES [#7042](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7042)
* SCPolicyConfig
  * Fixed an issue where `JustificationText` was exported as an array and could
    contain empty strings.
* SCRoleGroupMember
  * [BREAKING CHANGE] Updated the export to use `Alias` for users with email addresses.
    Fallback to `Name` for all other types, e.g. Service Principals.
    FIXES [#6829](https://github.com/microsoft/Microsoft365DSC/issues/6829)
* SCSensitivityLabel
  * Fixed an issue where the CIM definition for `MSFT_LabelSetting` did not match.
    FIXES [#7002](https://github.com/microsoft/Microsoft365DSC/issues/7002)
  * Fixed an issue where creating sensitivity label groups would fail.
    FIXES [#6994](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6994)
* SPOBrowserIdleSignout
  * Updated the timespan comparison to allow a discrepancy of up to 30 seconds
    for the `SignOutAfter` and `WarnAfter` properties.
    FIXES [#7031](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/7031)
* SPOHomeSite
  * Fixed an issue where an empty / non-existant Home Site was exported.
* SPOSharingSettings
  * Fixed an issue in determining the correct MySite.
    FIXES [#6991](https://github.com/Microsoft365DSC/Microsoft365DSC/issues/6991)
* SPOTheme
  * Fixed an issue where `Palette` entries were not correctly compared.
* TeamsClientConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Identity` parameter.
* TeamsFederationConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Ensure` parameter.
* TeamsGuestCallingConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Identity` parameter.
* TeamsGuestMeetingConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Identity` parameter.
* TeamsGuestMessagingConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Identity` parameter.
* TeamsMeetingBroadcastConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Identity` parameter.
* TeamsMeetingConfiguration
  * [BREAKING CHANGE] Added `IsSingleInstance` and removed `Ensure` parameter.
* TeamsMeetingPolicy
  * [BREAKING CHANGE] Removed the obsolete parameter `AllowCarbonSummary`.
    FIXES [#6972](https://github.com/microsoft/Microsoft365DSC/issues/6972)
* TeamsOnlineVoiceMailPolicy
  * [BREAKING CHANGE] Changed the type of `MaximumRecordingLength` from String to Int.
* M365DSCIntuneUtil
  * Removed function `Compare-M365DSCIntunePolicyAssignment`.
* M365DSCModuleMgmt
  * Added the parameter `UsePowerShellGet` to `Update-M365DSCDependencies` as an override
    fallback if `Install-PSResource` is not available or not working.
    FIXES [#7003](https://github.com/microsoft/Microsoft365DSC/issues/7003)
  * Fixed an issue where an in-memory update of the module failed.
* M365DSCPermissions
  * Removed internal function `Update-M365DSCResourcesSettingsJSON`.
* M365DSCReport
  * Fixed an issue where comparing instances of `EXOTenantAllowBlockListItems` would
    use the wrong resource keys.
    FIXES [#6981](https://github.com/microsoft/Microsoft365DSC/issues/6981)
  * Fixed an issue where incorrect resources were compared against each other if
    the resource contains more than three key properties in `New-M365DSCDeltaReport`.
  * Removed the deprecated function `Compare-M365DSCConfigurations`.
    Use `New-M365DSCDeltaReport` as a replacement.
* M365DSCStubsUtility
  * Removed module.
* M365DSCUtil
  * Added `KeepExport` parameter to `Assert-M365DSCBlueprint` function.
* DEPENDENCIES
  * Updated `DSCParser` to version 3.0.0.1.
  * Updated `MSCloudLoginAssistant` to version 1.1.62.
  * Updated `ReverseDSC` to version 2.0.0.34.
* MISC
  * Added CIM information about required properties to all resources where applicable.
  * Added message about requiring PowerShell 7 starting Octoboer 2026.
  * Improved filtering for Intune configuration policies during Export.
  * Improved the accuracy of the comparison engine.
  * Improved the delta report to pinpoint the changes more exactly if multiple
    complex objects were being compared against each other.
  * Refactored module structure to improve maintainability.
  * Removed duplicate complex hashtable conversions.
  * [BREAKING CHANGE] Store error logs in $env:TEMP instead of current working directory.
  * Updated documentation for different group types for AADGroup, EXOGroupSettings
    and EXODistributionGroup.

# 1.26.318.1

* AADAuthenticationMethodPolicyFido2
  * Add PassKeyProfile handling
* AzureRoleAssignmentScheduleRequest
  * Initial Release. [#6945](https://github.com/microsoft/Microsoft365DSC/issues/6945)
* AzureRoleEligibilityScheduleRequest
  * Initial Release. [#694](https://github.com/microsoft/Microsoft365DSC/issues/6945)
* AADCrossTenantAccessPolicyConfigurationDefault
  * Added support for `InvitationRedemptionIdentityProviderConfiguration`
    and `TenantRestrictions`.
* AADCrossTenantAccessPolicyConfigurationPartner
  * Added support for `IdentitySynchronization`.
* AzureRoleEligibilityScheduleSettings
  * Initial Release [#6974](https://github.com/microsoft/Microsoft365DSC/issues/6974)
* EXOMailContact
  * Updated the `Set-TargetResource` logic to use fixed parameters.
* IntuneDeviceConfigurationHealthMonitoringConfigurationPolicyWindows10
  * Fixed an issue with value handling when creating or updating policies.
    FIXES [#6955](https://github.com/microsoft/Microsoft365DSC/issues/6955)
* O365OrgSettings
  * Fixed an issue where the export was empty.
    FIXES [#6987](https://github.com/microsoft/Microsoft365DSC/issues/6987)
* SCLabelPolicy
  * Fixed an issue where setting `AdvancedSettings` failed.
    FIXES [#6973](https://github.com/microsoft/Microsoft365DSC/issues/6973)
* SCSensitivityLabel
  * Fixed an issue where setting `AdvancedSettings` failed.
    FIXES [#6973](https://github.com/microsoft/Microsoft365DSC/issues/6973)
* TeamsEmergencyCallingPolicy
  * Added explicit cast to string for `ExternalLocationLookupMode`.
* M365DSCUtil
  * Removed the internal `Sync-M365DSCParameter` function.
* MISC
  * Fixed an issue where hardcoded Azure urls were used in multiple resources.
    FIXES [#6957](https://github.com/microsoft/Microsoft365DSC/issues/6957)
* M365DSCDocGenerator
  * Fixed an issue where no distinction between read and update
    was done for EXO resources.
    FIXES [#6965](https://github.com/microsoft/Microsoft365DSC/issues/6965)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.36.1.

# 1.26.311.1

* AADAccessReviewDefinition
  * Fixed an issue where the filter for Get was applied incorrectly.
    FIXES [#6947](https://github.com/microsoft/Microsoft365DSC/issues/6947)
* AADAppManagementPolicy
  * Add certificateBasedApplicationConfigurationIds support to AADAppManagementPolicy
    FIXES [6926](https://github.com/microsoft/Microsoft365DSC/issues/6926)
* AADCertificateBasedApplicationConfiguration
  * Initial release. [6839](https://github.com/microsoft/Microsoft365DSC/issues/6839)
* AADConditionalAccessPolicy
  * Fixed an issue where arrays could contain empty strings.
* AADCrossTenantIdentitySyncPolicyPartner
  * Fixed an issue where the export would fail if the secondary tenant does
    not allow reading of the tenant information.
    FIXES [#6843](https://github.com/microsoft/Microsoft365DSC/issues/6843)
* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Added missing sub-property `IsAgenticExperienceEnabled` to
    complex object `AccessReviewSettings` and `ApproverInformationVisibility` to
    `ApprovalStages[]`
    FIXES [#6930](https://github.com/microsoft/Microsoft365DSC/issues/6930)
* AADGroup
  * Added sort by `DisplayName` during export.
  * Fixed an issue where empty GroupAsMember and Members weren`t properly
    returned by the Get-TargetResource function.
* AADGroupEligibilitySchedule
  * Changed resource to `Data` plane.
* AADGroupsNamingPolicy
  * Fixed an issue where arrays could contain empty strings.
  * Fixed an issue where the `StartDateTime` property was not standardized.
    It is now in the ISO 8601 format.
* AADGroupEligibilitySchedule
  * Change resource to `Data` plane
* AADPermissionGrantPolicy
  * Initial Release
    FIXES [#6914](https://github.com/microsoft/Microsoft365DSC/issues/6914)
* AADRoleAssignmentScheduleRequest
  * Fixed multiple issues with fetching role assignments.
    FIXES [#6841](https://github.com/microsoft/Microsoft365DSC/issues/6841)
* AADRoleEligiblityScheduleRequest
  * Fixed multiple issues with fetching role eligiblity.
    FIXES [#6841](https://github.com/microsoft/Microsoft365DSC/issues/6841)
    FIXES [#6459](https://github.com/microsoft/Microsoft365DSC/issues/6459)
    FIXES [#6416](https://github.com/microsoft/Microsoft365DSC/issues/6416)
    FIXES [#5712](https://github.com/microsoft/Microsoft365DSC/issues/5712)
* AADTenantAppManagementPolicy
  * Add certificateBasedApplicationConfigurationIds support to AADTenantAppManagementPolicy
    FIXES [6925](https://github.com/microsoft/Microsoft365DSC/issues/6925)
  * Update format RestrictForAppsCreatedAfterDateTime to match AADAppManagementPolicy
* AADUser
  * Fixed an issue where not specified properties were applied during update.
    FIXES [#6934](https://github.com/microsoft/Microsoft365DSC/issues/6934)
* DefenderRoleDefinition
  * Initial release
* EXODistributionGroup
  * Updated `Get-TargetResource` to use properties with display name.
    FIXES [#6769](https://github.com/microsoft/Microsoft365DSC/issues/6769)
* EXOServicePrincipal
  * Fixed an issue where the permissions were not correctly defined.
* EXOTenantAllowBlockListItems
  * Fixed issue where value `Submission` was missing from the validate
    set from `ListSubType` parameter.
    FIXES [#6918](https://github.com/microsoft/Microsoft365DSC/issues/6918)
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixed an issue where `EnableDnsSinkHole` was exported although
    it is deprecated.
    FIXES [#6937](https://github.com/microsoft/Microsoft365DSC/issues/6937)
* IntuneAppProtectionPolicyWindows10
  * Initial release.
* IntuneCloudProvisioningPolicyWindows365
  * Fixed an issue where deploying the configuration failed because the property
    `GeographicLocationType` was missing.
* IntuneCustomizationBrandingProfile
  * Initial release.
    FIXES [#4155](https://github.com/microsoft/Microsoft365DSC/issues/4155)
* IntuneDeviceConfigurationPolicyMacOS
  * Fixed an issue where arrays could contain empty strings.
* IntuneDeviceEnrollmentScopeConfigurationMam
  * Initial release.
* IntuneDeviceEnrollmentScopeConfigurationMdm
  * Initial release.
* IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile
  * Fixed an issue where unmodifiable profiles were exported.
    FIXES [#6889](https://github.com/microsoft/Microsoft365DSC/issues/6889)
* IntuneRoleAssignmentWindows365
  * Initial release.
* IntuneRoleDefinitionWindows365
  * Initial release.
* IntuneTermsAndConditions
  * Initial release.
* SCDLPSensitiveInformationType
  * Updated test logic to use `Test-M365DSCTargetResource`.
* TeamsOrgWideAppSettings
  * Fixed an issue where updating the settings would fail.
    FIXES [#6900](https://github.com/microsoft/Microsoft365DSC/issues/6900)
* M365DSCDRGUtil
  * Fixed an issue in `Compare-M365DSCComplexObject` where calling it
    directly would throw an exception during drift reporting.
    FIXES [#6922](https://github.com/microsoft/Microsoft365DSC/issues/6922)
* M365DSCPermissions
  * Fixed an issue where granting admin consent was not working with credentials.
* M365DSCReport
  * Fixed an issue when comparing multiple instances with the same key
    properties would result in a RuntimeException.
* M365DSCReverse
  * Fixed an issue where no warning was shown when exporting a single
    resource where the authentication parameters did not match.
  * Removed workload pre-authentication during export.
  * Updated the export logic to start module import during usage
    and not during resource initialization.
* M365DSCUtil
  * Added logic to not always check if a core required module is loaded.
  * Updated the `Export-M365DSCConfiguration` to only disconnect Graph if
    not managed through MSCloudLoginAssistant instead of every time it is called.
* MISC
  * Added filter support across all resources where filtering is applicable.
  * Aligned code formatting across all resources.
  * Aligned markdown documents and description to common standards.
  * Expanded try/catch in `Get-TargetResource` to cover authentication.
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.36.0.

# 1.26.218.1

* Compare-M365DSCConfigurations
  * Fixed an issue where the Get-DSCResource was passed to a function which expected a hashtable which resulted in a type mismatch
* AADConditionalAccessPolicy
  * Fixed an issue where `DisableResilienceDefaultsIsEnabled` was not
    evaluated correctly during `Get`.
    FIXES [#6871](https://github.com/microsoft/Microsoft365DSC/issues/6871)
* AADGroup
  * Fixed an issue where group members were not always returned.
    FIXES [#6854](https://github.com/microsoft/Microsoft365DSC/issues/6854)
* EXOOrganizationConfig
  * Fixed an issue where applying the configuration failed.
* IntuneCorporateDeviceIdentifier
  * Initial release. [#6838](https://github.com/microsoft/Microsoft365DSC/issues/6838)
* TeamsGroupPolicyAssignment
  * Properly throws and error when a failure occurs.
* TeamsTemplatesPolicy
  * Properly throws and error when a failure occurs.
* M365DSCReport
  * Added missing Metadata processing when generating reports.
    FIXES [#6865](https://github.com/microsoft/Microsoft365DSC/issues/6865)
  * Moved custom header in between HTML tags.
* M365DSCUtil
  * Updated the drift information to join array elements with a comma.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.9.2.
  * Updated Microsoft.Graph to version 2.35.1.
  * Updated MicrosoftTeams to version 7.6.0.
  * Updated MSCloudLoginAssistant to version 1.1.59.

# 1.26.211.1

* AADConditionalAccessPolicy
  * Fixed an issue where arrays could contain empty strings.
* AADPasswordRuleSettings
  * Fixed an issue where `BannedPasswordList` could be null.
* AADPIMGroupSetting
  * Fixed an issue where typed variables could lead to an exception.
* AADUser
  * Fixed an export issue where a user was deleted during a long-running job.
    FIXES [#5703](https://github.com/microsoft/Microsoft365DSC/issues/5703)
* IntuneRoleAssignment
  * Fixed an issue where properties were omitted during Set and testing
    did not work with display names.
    FIXES [#6881](https://github.com/microsoft/Microsoft365DSC/issues/6881)
* FabricAdmintenantsettings
  * Refreshed the property list.
    FIXES [#6866](https://github.com/microsoft/Microsoft365DSC/issues/6866)
* O365OrgSettings
  * Changed how errors are handled to fail instead of returning false drifts.
    FIXES [#6787](https://github.com/microsoft/Microsoft365DSC/issues/6787)
* O365SearchAndIntelligenceConfiguration
  * Expanded try/catch logic to cover all code paths in Get.
    FIXES [#6788](https://github.com/microsoft/Microsoft365DSC/issues/6788)
* SPOSearchManagedProperty
  * Fixed an issue when connecting to the SPO AdminUrl.
    FIXES [#6787](https://github.com/microsoft/Microsoft365DSC/issues/6787)
* TeamsDialInConferencingTenantSettings
  * Fixed an issue where the properties `MigrateServiceNumbersOnCrossForestMove`
    and `UseUniqueConferenceIds` were not rendered correctly in the
    documentation
    FIXES [#6890](https://github.com/microsoft/Microsoft365DSC/issues/6890)
* M365DSCUtil
  * Fixed an issue during module update where `Install-PSResource` throws
    an error if the module was installed in Windows PowerShell but the
    update attempt was performed in PowerShell 7.
  * Fixed an issue where `Export-M365DSCConfiguration` would stop
    exporting resources after an error on Azure DevOps & GitHub.
    FIXES [#6862](https://github.com/microsoft/Microsoft365DSC/issues/6862)
* M365DSCPermissions
  * Fixed an issue when selecting a property for the result.
    FIXES [#6882](https://github.com/microsoft/Microsoft365DSC/issues/6882)
* DEPENDENCIES
  * Removed dependency on `PSDesiredStateConfiguration`.
  * Updated MSCloudLoginAssistant to version 1.1.58.

# 1.26.128.1

* EXOMailboxFolderPermission
  * Fixed an issue where `AccessRights` was not exported properly.
* EXOTransportRule
  * Updated logic to properly handle the Enabled property.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixed an issue where the property `TamperProtection` was renamed to
    `ControlledConfiguration` in the Settings Catalog backend.
    FIXES [#6855](https://github.com/microsoft/Microsoft365DSC/issues/6855)
* IntuneCloudProvisioningPolicyWindows365
  * Fixed an issue where `ireland` was not a recognized country.
    FIXES [#6830](https://github.com/microsoft/Microsoft365DSC/issues/6830)
* IntuneDeviceFeaturesConfigurationPolicyIOS
  * Fixed an issue where home screen folders were not configurable.
    FIXES [#6836](https://github.com/microsoft/Microsoft365DSC/issues/6836)
* O365OrgSettings
  * Fixed an issue where comparing empty app installation options failed.
    FIXES [#6812](https://github.com/microsoft/Microsoft365DSC/issues/6812)
* SCSecurityFilter
  * Fixed an issue where connecting to the service was not possible.
    FIXES [#6798](https://github.com/microsoft/Microsoft365DSC/issues/6798)
* SPOTenantSettings
  * Fixing the empty array casting for AllowSelectSGsInODBListInTenant,
    DenySelectSGsInODBListInTenant,DenySelectSecurityGroupsInSPSitesList
    and AllowSelectSecurityGroupsInSPSitesList in Get-TargetResource.
* M365DSCPermissions
  * Fixed an issue where Purview permissions were not in the correct format.
    FIXES [#6822](https://github.com/microsoft/Microsoft365DSC/issues/6822)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.57.
* M365DSCUtil
  * Removed the parameter `SkipModuleReload` from `New-M365DSCConnection`.
* MISC
  * Removed the `SkipModuleReload` logic from all resources.

# 1.26.121.1

* AADGroup
  * Removed caching for the groups role assignments which was causing
    performance issues in the Get-TargetResource.
* AADRoleAssignmentScheduleRequest
  * FIXES [#6810](https://github.com/microsoft/Microsoft365DSC/issues/6810)
* AADRoleEligibilityScheduleRequest
  * FIXES [#6810](https://github.com/microsoft/Microsoft365DSC/issues/6810)
* M365DSCRuleEvaluation
  * Fixes for an issue where the resource was complaining about the `Name`
    parameter missing.
* SPOSiteGroup
  * Fixed a condition mismatch during export resulting in repeated logins.
* M365DSCPermissions
  * Changed the output of `Get-M365DSCCompiledPermissionList` to show the
    required Read and Update permissions for `Roles` and `RoleGroups`.
* M365DSCTelemetryEngine
  * Added a function to test if telemetry is enabled.
* M365DSCUtil
  * Added the output of the drift event to the screen in Verbose mode.
    FIXES [#6666](https://github.com/microsoft/Microsoft365DSC/issues/6666)
  * Added the parameter `-WithStatistics` to `Export-M365DSCConfiguration`.
  * Fixed an issue where the module is not being updated if installed
    with `Install-PSResource` because the filter condition was incorrect.
* MISC
  * Added more performance improvements for hot code paths.
  * Fixed issues with mismatched property types in resource tests.
  * Refactored parts of the core engine with C#.
  * Replaced `Get-(Pwsh)DscResource` with a custom implementation.
  * Updated the structure of all EXO settings.json files that contain the
    `Roles` and `RoleGroups` properties.
* DEPENDENCIES
  * Fixed a case typo in `RequiredVersion` of a dependency.
    FIXES [#6815](https://github.com/microsoft/Microsoft365DSC/issues/6815)
  * Updated ReverseDSC to version 2.0.0.31.

# 1.26.114.1

* AADAuthenticationMethodPolicy
  * Fixed an issue where empty arrays were not exported.
    FIXES [#6759](https://github.com/microsoft/Microsoft365DSC/issues/6759)
* AADConditionalAccessPolicy
  * Added the property `SecureSignInSessionIsEnabled`.
    FIXES [#6777](https://github.com/microsoft/Microsoft365DSC/issues/6777)
  * Fixed an issue where updating a policy would fail.
    FIXES [#6782](https://github.com/microsoft/Microsoft365DSC/issues/6782)
* AADGroup
  * Prevents retrieving all members of a group in the Get-TargetResource if
    the parameter is not specified in the configuration.
* AADNetworkAccessForwardingPolicy
  * Fixed an issue where empty `PolicyRules` would throw an exception during Get.
* EXODistributionGroup
  * Fixes performance issue with the retrieval of managers.
  * Fixes GUID vs UPN evaluation
    FIXES [#6769](https://github.com/microsoft/Microsoft365DSC/issues/6769)
* EXOExternalInOutlook
  * Fixed an issue where the export would fail.
    FIXES [#6753](https://github.com/microsoft/Microsoft365DSC/issues/6753)
* EXOGroupSettings
  * Fixed performance issue evaluating and setting values due to the full
    Recipient list being returned.
* EXOPhishSimOverrideRule
  * Fixed an issue where the export would fail.
    FIXES [#6753](https://github.com/microsoft/Microsoft365DSC/issues/6753)
* EXOPlace
  * Fixes an issue with the export where it was trying to export RoomList.
* EXOSecOpsOverrideRule
  * Fixed an issue where the export would fail.
    FIXES [#6753](https://github.com/microsoft/Microsoft365DSC/issues/6753)
* IntuneAppConfigurationDevicePolicy
  * Added error handling with message if targeted app doesn't exist.
* IntuneAppProtectionPolicyAndroid
  * Fixed several issues when creating and updating the policy.
    FIXES [#6746](https://github.com/microsoft/Microsoft365DSC/issues/6746)
* IntuneAppProtectionPolicyiOS
  * Fixed several issues when creating and updating the policy.
* IntuneAzureNetworkConnectionWindows365
  * Fixed the name of the Azure permission provider.
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Fixed an issue where a JSON serialization warning was outputted
    due to the object depth exceeding two levels.
* IntuneDeviceCompliancePolicyWindows10
  * Fixed an issue where the complex type mapping was defined incorrectly.
* IntuneEpmElevationRulesPolicyWindows10
  * Added a throw condition if the reusable certiticate policy setting is not found.
* IntuneMobileAppsBuiltInStoreApp
  * Fixed an issue where `AssignmentSettings` was not a valid property.
* IntuneMobileAppsLobAppiOS
  * Fixed an issue where `AssignmentSettings` was not a valid property.
* IntuneMobileAppsLobAppMsiWindows10
  * Fixed an issue where `Categories` was exported as a String.
* IntuneMobileAppsMacOSLobApp
  * Fixed an issue where `AssignmentSettings` was not a valid property.
* IntuneMobileAppsManagedGooglePlayApp
  * Fixed an issue where `AssignmentSettings` was not a valid property.
    FIXES [#6785](https://github.com/microsoft/Microsoft365DSC/issues/6785)
* IntuneSettingCatalogCustomPolicyWindows10
  * Fixed the ability to run Get-TargetResource via the LCM (Get-DscConfiguration) and
    it's ability to return complex nested objects.
    FIXES [#6092](https://github.com/microsoft/Microsoft365DSC/issues/6092)
* O365OrgSettings
  * Added `CertificatePath` with `CertificatePassword` as an authentication method.
* SPOSite
  * Fixed an issue about not correctly passing RestrictedToRegion parameter.
    FIXES [#6734](https://github.com/microsoft/Microsoft365DSC/issues/6734)
* PPTenantIsolationSettings
  * Fixed an issue where updating the policy failed because of an unresolved tenant name.
    FIXES [#6778](https://github.com/microsoft/Microsoft365DSC/issues/6778)
* SCAutoSensitivityLabelRule
  * Aligned property formating for improved export processing.
* SCSecurityFilter
  * Added a note that the resource does not support certificate based authentication.
* TeamsChannel
  * Updated required permissions for read / update.
* TeamsEmergencyCallRoutingPolicy
  * Updated required permissions for read / update.
* TeamsMeetingBroadcastConfiguration
  * Fixed an issue where the `SdnApiToken` property was not compared correctly.
* TeamsOrgWideAppSettings
  * Added a note that the resource does not support certificate based authentication.
* TeamsTeam
  * Updated required permissions for read / update.
* TeamsUser
  * Updated required permissions for read / update.
* M365DSCDRGUtil
  * Added missing `UseBasicParsing` because of Windows PowerShell hardening.
  * Fixed an issue in `Get-M365DSCDRGComplexTypeToHashtable` not working with arrays.
    FIXES [#6759](https://github.com/microsoft/Microsoft365DSC/issues/6759)
  * Fixed an issue where `Rename-M365DSCCimInstanceParameter` omitted values.
    FIXES [#6727](https://github.com/microsoft/Microsoft365DSC/issues/6727)
    FIXES [#6779](https://github.com/microsoft/Microsoft365DSC/issues/6779)
* M365DSCLogEngine
  * Replaced deprecated Windows Event PowerShell cmdlets with .NET.
* M365DSCReverse
  * Added logic to clean up temporary files after export.
  * Added `TenantGuid` entry to the `ConfigurationData.psd1` file during export.
    FIXES [#6689](https://github.com/microsoft/Microsoft365DSC/issues/6689)
  * Fixed an issue when attempting to copy non-downloaded `SPOApp` files.
* M365DSCUtil
  * Added functionality to change M365DSC configuration during runtime.
  * Added logic to clean up temporary files assertion.
  * Added missing `UseBasicParsing` because of Windows PowerShell hardening.
  * Fixed an issue where multiple installed Microsoft365DSC versions
    will lead to an error during export.
    FIXES [#6758](https://github.com/microsoft/Microsoft365DSC/issues/6758)
  * Fixed an issue where the export would fail if the name of a resource was not
    the same case as the name in Microsoft365DSC.
  * Improved module installation speed for `Update-M365DSCModule`.
  * Updated the Tenant Guid parsing to not throw but instead use `TryParse`.
* MISC
  * Applied ordering for CIM instances to minimize Git differences.
  * Fixed a couple of misaligned export messages on the console.
  * Fixed an issue where not all required modules were specified in resource settings.
  * Generalized custom comparison handling.
    FIXES [#6765](https://github.com/microsoft/Microsoft365DSC/issues/6765)
    FIXES [#6756](https://github.com/microsoft/Microsoft365DSC/issues/6756)
    FIXES [#6584](https://github.com/microsoft/Microsoft365DSC/issues/6584)
  * Removed verbose output from `Get-TargetResource`.
  * Updated and corrected all EXO and several SC permissions.
  * Updated the error behavior to always throw inside `Get-TargetResource`.

# 1.25.1203.2

* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.56.

# 1.25.1203.1

* AADGroup
  * Fixed an issue where not all manageable Entra groups were exported.
* AADNamedLocationPolicy
  * Fixed an issue where not all properties were exported.
    FIXES [#6704](https://github.com/microsoft/Microsoft365DSC/issues/6704)
* AADRoleAssignmentScheduleRequest
  * Aligned functionality to work the same way as `AADRoleEligibilityScheduleRequest`.
  * Deprecated parameters `Action`, `IsValidationOnly` and `TicketInfo`.
* AADRoleEligibilityScheduleRequest
  * Deprecated parameters `Action` and `IsValidationOnly`.
* AADRoleManagementPolicyRule
  * Reduced export time by 95%.
* EXOGroupSettings
  * Added support for using display names with the following properties:
    `AcceptMessagesOnlyFromSendersOrMembers`, `GrantSendOnBehalfTo`, `ModeratedBy`
    and `RejectMessagesFromSendersOrMembers`.
    FIXES [#6676](https://github.com/microsoft/Microsoft365DSC/issues/6676)
* EXOMessageClassification
  * Fixed issue where the resource would fail during export if it could not
    find it by `DisplayName`, and it needed to be created, by silently
    continuing if that is the case
    FIXES [#6691](https://github.com/microsoft/Microsoft365DSC/issues/6691)
* EXOTenantAllowBlockListItems
  * Deprecated `ApplicationSecret` parameter and added new authentication methods.
* IntuneApplicationControlPolicyWindows10
  * Deprecated resource. Replaced with `IntuneDeviceConfigurationEndpointProtectionPolicyWindows10`.
* IntuneDeviceConfigurationPlatformScriptLinux
  * Initial release.
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fixed an issue where priority was attempted to be set on a newly created policy
    where the priority already matched.
* IntuneDeviceRemediation
  * Updated handling of the `RunRemediationScript` property.
* IntuneDiskEncryptionFileVaultPolicyMacOS
  * Initial release.
* IntuneDiskEncryptionMacOS
  * Deprecated resource. Replaced with `IntuneDiskEncryptionFileVaultPolicyMacOS`.
* O365CopilotSettingsPeopleEnhancedPersonalization
  * New resource
* ODSettings
  * Fixed an issue where the parameter definition was missing.
    FIXES [#6684](https://github.com/microsoft/Microsoft365DSC/issues/6684)
* SPOTenantSettings
  * Fixed an issue where the parameter definition was missing.
    FIXES [#6686](https://github.com/microsoft/Microsoft365DSC/issues/6686)
* TeamsMeetingPolicy
  * Fixed an issue where the schema had an incorrect type assigned.
    FIXES [#6687](https://github.com/microsoft/Microsoft365DSC/issues/6687)
* TeamsOrgWideAppSettings
  * Added SPN support for read-only (monitoring only).
* M365DSCDRGUtil
  * Fixed an issue where a condition check contained a typo.
    FIXES [#6674](https://github.com/microsoft/Microsoft365DSC/issues/6674)
  * Fixed an issue where updating Intune assignments did not include all properties.
    FIXES [#6697](https://github.com/microsoft/Microsoft365DSC/issues/6697)
  * Updated comparison function `Compare-M365DSCComplexObject` to non-recursive.
* M365DSCResourceGenerator
  * Updated example generation to always create examples.
* M365DSCReverse
  * Added handling of custom token replacements.
* M365DSCUtil
  * Added the parameter `TokenReplacement` to the `Export-M365DSCConfiguration` function.
  * Fixed an issue where the connection to Graph in combination with PnP would fail.
    FIXES [#6577](https://github.com/microsoft/Microsoft365DSC/issues/6577)
    FIXES [#6721](https://github.com/microsoft/Microsoft365DSC/issues/6721)
  * Fixed an issue where the test evaluation for `Absent` did not work as expected.
    FIXES [#6701](https://github.com/microsoft/Microsoft365DSC/issues/6701)
  * Replaced complex object comparison function V2 with V3.
* MISC
  * Added and removed mismatches between parameters and their schema.
  * Added quality assurance checks for parameter and schema mismatches.
  * Moved the `Examples` folder to the top of the repository to reduce core module size.
  * Refactored EXO resources to align with the default resource code layout.
  * Refactored module structure.
  * Removed internal module `M365DSCExoResourceUtils`.
  * Removed unused internal functions `Remove-M365DSCCimInstanceTrailingCharacterFromExport`,
    `Update-M365DSCExchangeResourcesSettingsJSON`, `Update-M365DSCSharePointResourcesSettingsJSON`,
    `Split-ArrayByParts`, `Get-SPOUserProfilePropertyInstance` and `Remove-M365DSCEmptyValue`.
  * Streamlined the report generation and added new visual styles.
  * Updated the `SchemaDefinition.json` to a compressed version.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.21.
  * Updated MSCloudLoginAssistant to version 1.1.55.
    FIXES [#6728](https://github.com/microsoft/Microsoft365DSC/issues/6728)

# 1.25.1112.1

* AADActivityBasedTimeoutPolicy
  * Fixed an issue where the `DisplayName` property was not used for create and update.
    FIXES [#6680](https://github.com/microsoft/Microsoft365DSC/issues/6680)
* AADApplication
  * Added support for `TokenLifetimePolicies`.
  * Fixing issue where Set-TargetResource threw an error trying to recreate
    an existing permissions scope when id was not provided.
* AADAuthorizationPolicy
  * Added new property `AllowUserConsentForRiskyApps`.
* AADFeatureRolloutPolicy
  * Added support for `AppliesTo`.
* AADFilteringPolicyRule
  * Fixed issue retrieving existing rule where the Id parameter was incorrectly provided.
* AADGroup
  * Added support for `GroupLifecyclePolicySelectedEnabled`, which indicates
    if a Group has a Group Lifecycle Policy assigned to it.
  * Fixed an issue where using advanced filtering during export failed.
  * Updated the required permissions to match the used cmdlets.
* AADUser
  * Added new permission requirement `User.EnableDisableAccount.All` for enabling / disabling accounts.
* EXOIRMConfiguration
  * Fixed an issue where the `LicensingLocation` property was not exported correctly.
    FIXES [#6644](https://github.com/microsoft/Microsoft365DSC/issues/6644)
* IntuneAlertRuleWindows365
  * Initial release.
* IntuneAppProtectionPolicyAndroid
  * Fixes an issue where Set-TargetResource attempted to create an additional policy
    when two instances with the same name already existed.
* IntuneAppProtectionPolicyiOS
  * Fixes an issue where Set-TargetResource attempted to create an additional policy
    when two instances with the same name already existed.
* IntuneDeviceConfigurationHealthMonitoringConfigurationPolicyWindows10
  * Fixed an issue where the resource failed with `ModelValidationFailure` due to property casing mismatch.
* IntuneDeviceControlPolicySetting
  * Initial release.
* IntuneEpmCertificatePolicySetting
  * Initial release.
* IntuneFirewallPolicySetting
  * Initial release.
* IntuneManagedInstallerPolicyWindows10
  * Initial release.
* IntuneSettingCatalogCustomPolicyWindows10
  * Fixed issue where roleScopeTagIds was sent as null instead of array, causing BadRequest (400) during policy update.
* ODSettings
  * Added new property `DisplayNamesOfFileViewers`.
  * Fixed an issue where exporting `DomainGuids` would throw because it is a GUID type.
    FIXES [#6615](https://github.com/microsoft/Microsoft365DSC/issues/6615)
* SPOSharingSettings
  * Changed from server-side filtering to local because of backend limitations.
    FIXES [#6631](https://github.com/microsoft/Microsoft365DSC/issues/6631)
* SPOTenantSettings
  * Added support for the following properties: `HideSyncButtonOnODB`, `MobileFriendlyUrlEnabledInTenant`,
    `AllowDownloadingNonWebViewableFiles`, `AllowEditing`, `DisableCustomAppAuthentication`,
    `DisabledModernListTemplateIds`, `DisablePersonalListCreation`, `IsLoopEnabled`,
    `IsSharePointNewsfeedEnabled`, `IsSiteCreationEnabled`, `IsSiteCreationUiEnabled`,
    `IsSitePagesCreationEnabled`, `NoAccessRedirectUrl`, `RequireAcceptingAccountMatchInvitedAccount`,
    `SpecialCharactersStateInFileFolderNames`.
* SCDLPSensitiveInformationType
  * Initial release.
* TeamsAIPolicy
  * Initial release.
* TeamsFederationConfiguration
  * Fixed an issue where `AllowedDomains` could not be set.
    FIXES [#6654](https://github.com/microsoft/Microsoft365DSC/issues/6654)
* TeamsMeetingPolicy
  * Added support for new properties.
    FIXES [#6606](https://github.com/microsoft/Microsoft365DSC/issues/6606)
* TeamsMessagingPolicy
  * Fixed an issue where `UseB2BInvitesToAddExternalUsers` was exported with the wrong value.
    FIXES [#6632](https://github.com/microsoft/Microsoft365DSC/issues/6632)
* TeamsUpdateManagementPolicy
  * Fixed an issue where the type for `DisabledInProductMessages` was String instead of a String array.
    FIXES [#6635](https://github.com/microsoft/Microsoft365DSC/issues/6635)
* TeamsVoiceRoutingPolicy
  * Fixed an issue where removing a policy required PSTN usages to exist.
    FIXES [#6449](https://github.com/microsoft/Microsoft365DSC/issues/6649)
* VivaEngagementRoleMember
  * Fixed issue loading the required modules to export this resource.
* M365DSCDRGUtil
  * Added drift event message to Verbose output.
    FIXES [#6666](https://github.com/microsoft/Microsoft365DSC/issues/6666).
  * Fixed issue loading the required modules to export this resource
* M365DSCReverse
  * Fixed an issue where having resources specified in both include and exclude
    during export would result in an exception.
    FIXES [#6630](https://github.com/microsoft/Microsoft365DSC/issues/6630)
* M365DSCUtil
  * Added custom post processing to `Test-M365DSCTargetResource`.
  * Added new function `Split-M365DSCConfiguration`.
  * Improved logging output of `Test-M365DSCTargetResource`.
  * Moved resource initialization into dedicated function.
  * Removed groupId requirement in `ConvertTo-IntuneMobileAppAssignment`.
* MISC
  * Centralized more resource testing to the testing function.
  * Updated single instance information retrieval in EXO resources.
    FIXES [#6643](https://github.com/microsoft/Microsoft365DSC/issues/6643)
  * Improved support for `ErrorAction` during export.
    FIXES [#6610](https://github.com/microsoft/Microsoft365DSC/issues/6610)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.54

# 1.25.1015.1

* AADConditionalAccessPolicy
  * Fixed a typo in variable initialization.
* AADUser
  * Added the property `AccountEnabled` to the export.
    FIXES [#6595](https://github.com/microsoft/Microsoft365DSC/issues/6595)
  * Fixed an issue where the phone and fax number was not exported.
* EXOOrganizationConfig
  * Added support for the DelayedDelicensingEnabled,
    EndUserMailNotificationForDelayedDelicensingEnabled and
    TenantAdminNotificationForDelayedDelicensingEnabled parameters.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixed `DisableCoreServiceECSIntegration` and `DisableCoreServiceTelemetry` to allow multiple values.
    FIXES [#6583](https://github.com/microsoft/Microsoft365DSC/issues/6583)
* IntuneAzureNetworkConnectionWindows365
  * Initial release.
* IntuneCloudProvisioningPolicyWindows365
  * Initial release.
* O365OrgSettings
  * Fix unicode issue in schema, that caused the website to contain
    incorrect characters.
* SentinelAlertRule
  * Fixed the schema and export of the property `groupByAlertDetails`.
    FIXES [#6591](https://github.com/microsoft/Microsoft365DSC/issues/6591)
* SPOTenantSettings
  * Deprecated property `OneDriveSharingCapability` in favor of `MySiteSharingCapability` in SPOSharingSettings.
    FIXES [#6588](https://github.com/microsoft/Microsoft365DSC/issues/6588)
    FIXES [#5933](https://github.com/microsoft/Microsoft365DSC/issues/5933)
* TeamsAppSetupPolicy
  * Added property `PinnedCallingBarApps`.
* TeamsCallingPolicy
  * Added property `ExplicitRecordingConsent`.
* TeamsClientConfiguration
  * Added property `AllowRoleBasedChatPermissions`.
* TeamsComplianceRecordingPolicy
  * Added property `RecordReroutedCalls`.
* TeamsDialInConferencingTenantSettings
  * Added properties `EnableNameRecording`, `MigrateServiceNumbersOnCrossForestMove` and `UseUniqueConferenceIds`.
* TeamsEmergencyCallingPolicy
  * Added property `ExtendedNotifications`.
* TeamsFederationConfiguration
  * Added property `DomainBlockingForMDOAdminsInTeams`.
* TeamsFilesPolicy
  * Added properties `FileSharingInChatswithExternalUsers` and `DefaultFileUploadAppId`.
* TeamsGuestMessagingConfiguration
  * Added property `UsersCanDeleteBotMessages`.
* TeamsMeetingConfiguration
  * Added properties `DisableAppInteractionForAnonymousUsers`, `FeedbackSurveyForAnonymousUsers` and `LimitPresenterRolePermissions`.
* TeamsMessagingConfiguration
  * Initial release.
    FIXES [#6536](https://github.com/microsoft/Microsoft365DSC/issues/6536)
* TeamsMessagingPolicy
  * Added properties `AllowExtendedWorkInfoInSearch`, `AutoShareFilesInExternalChats` and `UseB2BInvitesToAddExternalUsers`.
* TeamsOnlineVoicemailPolicy
  * Added properties `PostambleAudioFile`, `PreambleAudioFile` and `PreamblePostambleMandatory`.
* TeamsTeam
  * Added property `AllowCreatePrivateChannels`.
* TeamsUpdateManagementPolicy
  * Added properties `BlockLegacyAuthorization` and `DisabledInProductMessages`.
* TeamsVoiceRoute
  * Added property `BridgeSourcePhoneNumber`.
* M365DSCAgent
  * Added requirement to regenerate the DSC agent certificate with `-ForceRenew` when
    creating and exporting a PFX certificate using `Set-M365DSCAgentCertificateConfiguration`.
* M365DSCReverse
  * Fixed an issue where the export output path was not correct.
    FIXES [#6580](https://github.com/microsoft/Microsoft365DSC/issues/6580)
* M365DSCUtil
  * Fixed an issue where `Uninstall-M365DSCOutdatedDependencies` removes the wrong version.
    FIXES [#6573](https://github.com/microsoft/Microsoft365DSC/issues/6573)
  * Fixed parameter mapping of the telemetry connection parameters.
* MISC
  * Removed documentation for `IntuneDeviceEnrollmentConfigurationWindows10`.
    FIXES [#6589](https://github.com/microsoft/Microsoft365DSC/issues/6589)
  * Improved function and cmdlet count for module import.
    FIXES [#6544](https://github.com/microsoft/Microsoft365DSC/issues/6544)
  * Removed unnecessary CIM instance conversion checks across all resources.

# 1.25.1001.1

* AADAccessReviewDefinition
  * [BREAKING CHANGE] Removed ID as the key and made DisplayName the new key.

* AADAdministrativeUnit
  * Reduced export time by 20%.
* AADAgreement
  * Fixed creation and update issues by calling the APIs directly.
* AADApplication
  * [BREAKING CHANGE] Removed deprecated parameters `AvailableToOtherTenants`
    and `RequireClientServicePrincipal`.
* AADAppManagementPolicy
  * Updated `RestrictForAppsCreatedAfterDateTime` to "o" format.
* AADAuthenticationMethodPolicy
  * [BREAKING CHANGE] Removed deprecated parameter `PolicyMigrationState`.
* AADAuthenticationMethodPolicyAuthenticator
  * [BREAKING CHANGE] Removed deprecated parameter `NumberMatchingRequiredState`.
* AADConditionalAccessPolicy
  * Fix case evaluation when creating instances or updating properties.
* AADCrossTenantIdentitySyncPolicyPartner
  * Initial release.
* AADCustomSecurityAttributeDefinition
  * [BREAKING CHANGE] Restricted accepted values for `Status` to `Available` and
    `Deprecated`.
* AADDomain
  * Fixed an issue where updating an existing instance failed due to the
    isVerified parameter.
* AADEnrichedAuditLogs
  * [BREAKING CHANGE] Removed deprecated resource.
* AADGroup
  * Fixed multi-tenant Service Principal support for owners and members.
    FIXES [#6498](https://github.com/microsoft/Microsoft365DSC/issues/6498)
  * Fixed an issue where the `SkuId` could contain NBSP characters.
    FIXES [#6476](https://github.com/microsoft/Microsoft365DSC/issues/6476)
  * Fixed an issue where GroupAsMembers not being added during initial group creation.
    FIXES [#6489](https://github.com/microsoft/Microsoft365DSC/issues/6489)
  * Fixed an issue where not all members were exported.
    FIXES [#6545](https://github.com/microsoft/Microsoft365DSC/issues/6545)
* AADGroupEligiblitySchedule
  * Aligned date time format for `Expiration.EndDateTime` with `Expiration.StartDateTime`.
  * [BREAKING CHANGE] Update AADGroupEligiblitySchedule align with
    AADRoleEligibilityScheduleRequest to allow User (UPN), Group (Group Name) as
    Principal
  * Fixed issue where AADGroupEligiblitySchedule didn't correctly work with
    member and owner assignment types
* EXOAtpPolicyForO365
  * [BREAKING CHANGE] Removed `Ensure` property.
* EXOCalendarProcessing
  * Added caching for export.
* EXOClientAccessRule
  * [BREAKING CHANGE] Removed resource.
* EXOFocusedInbox
  * [BREAKING CHANGE] Removed deprecated parameter `FocusedInboxOnLastUpdateTime`.
* EXOGroupSettings
  * Fixed an issue with the retrieval by DisplayName and duplicate Id property
    on update.
  * [BREAKING CHANGE] Renamed the UnifiedGroupWelcomeMessageEnabled parameter to
    WelcomeMessageEnabled.
* EXOIntraOrganizationConnector
  * Fix logic to allow empty string for TargetSharingEpr.
* EXOHostedContentFilterPolicy
  * [BREAKING CHANGE] Remove deprecated properties `DownloadLink`, `EnableEndUserSpamNotifications`,
    `EndUserSpamNotificationCustomSubject`, `EndUserSpamNotificationFrequency`
    and `EndUserSpamNotificationLanguage`.
    FIXES [#4958](https://github.com/microsoft/Microsoft365DSC/issues/4958)
* EXOMailboxAutoReplyConfiguration
  * Added conditional user lookup.
* EXOMailboxCalendarFolder
  * Added conditional user lookup.
* EXOMailContact
  * Added caching for export.
* EXOMailboxPermission
  * Added additional caching for export.
* EXOMailboxSettings
  * Added caching for export.
* EXOMobileDeviceMailboxPolicy
  * [BREAKING CHANGE] Updated properties `MinPasswordComplexCharacters` and
    `PasswordHistory` to integer types.
    FIXES [#6022](https://github.com/microsoft/Microsoft365DSC/issues/6022)
* EXORecipientPermission
  * Added additional caching for export.
* EXOSafeAttachmentPolicy
  * [BREAKING CHANGE] Removed deprecated parameter `ActionOnError`.
* EXOTransportRule
  * [BREAKING CHANGE] Removed deprecated parameters `ExceptIfHasSenderOverride`,
    `MessageContainsDataClassifications`,
    `ExceptIfMessageContainsDataClassifications`, `HasSenderOverride`,
    `NotifySender`, `ApplyOME` and `RemoveOME`.
* IntuneAccountProtectionPolicy
  * [BREAKING CHANGE] Removed deprecated resource.
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * [BREAKING CHANGE] Renamed properties to match their Settings Catalog counterpart.
    FIXES [#6342](https://github.com/microsoft/Microsoft365DSC/issues/6432)
* IntuneAppCategory
  * Added missing authentication properties in examples.
* IntuneAppConfigurationPolicy
  * Fixed an issue with MOF instance parsing.
    FIXES [#6520](https://github.com/microsoft/Microsoft365DSC/issues/6520)
* IntuneAppControlForBusinessPolicyWindows10
  * Initial release.
    FIXES [#4761](https://github.com/microsoft/Microsoft365DSC/issues/4761)
* IntuneAppProtectionPolicyAndroid
  * [BREAKING CHANGE] Combined `ExcludedGroups` with `Assignments`, updated
    time parameters to ISO8601 format, removed `IsAssigned` property.
    FIXES [#5968](https://github.com/microsoft/Microsoft365DSC/issues/5968)
    FIXES [#5808](https://github.com/microsoft/Microsoft365DSC/issues/5808)
    FIXES [#5675](https://github.com/microsoft/Microsoft365DSC/issues/5675)
* IntuneAppConfigurationPolicy
  * Fixed an issue with MOF instance parsing.
    FIXES [#6520](https://github.com/microsoft/Microsoft365DSC/issues/6520)
* IntuneASRRulesPolicyWindows10
  * [BREAKING CHANGE] Removed resource. It was replaced with `IntuneSettingCatalogASRRulesPolicyWindows10`.
* IntuneDeviceCleanupRule
  * [BREAKING CHANGE] Removed resource. It was replaced with `IntuneDeviceCleanupRuleV2`.
* IntuneDeviceCompliancePolicyAndroid
  * [BREAKING CHANGE] Removed resource because the configuration type is not
    supported anymore.
* IntuneDeviceConfigurationPolicyAndroidDeviceAdministrator
  * [BREAKING CHANGE] Removed resource because the configuration type is not
    supported anymore.
* IntuneDeviceRemediation
  * [BREAKING CHANGE] Made Id optional and enabled creation of remediation
    scripts using DisplayName only.
    FIXES [#6445](https://github.com/microsoft/Microsoft365DSC/issues/6445)
* IntuneEpmElevationRulesPolicyWindows10
  * Initial release.
* IntuneEpmElevationSettingsPolicyWindows10
  * Initial release.
* IntuneMobileAppsMacOSLobApp
  * Added filter capability.
* IntuneMobileAppsMicrosoftStoreAppWindows10
  * Initial release.
* IntuneMobileAppsStoreApp
  * Added support for `assignmentSettings` to the assignments.
* IntuneMobileAppsWebLink
  * Fixed an issue where filtering was applied after fetching all apps.
* IntuneMobileAppsWindowsOfficeSuiteApp
  * Added filter capability.
  * Fixed the version in the MOF definition.
* IntuneRoleAssignment
  * Fixed an issue where deleted groups would throw an error during export.
* IntuneTrustedRootCertificateAndroidEnterprise
  * [BREAKING CHANGE] Removed resource because the configuration type is not
    supported anymore.
* IntuneUserSettingsPolicyWindows365
  * Initial release.
* IntuneVPNConfigurationPolicyAndroidEnterprise
  * [BREAKING CHANGE] Removed resource because the configuration type is not
    supported anymore.
* IntuneWifiConfigurationPolicyAndroidDeviceAdministrator
  * [BREAKING CHANGE] Removed resource because the configuration type is not
    supported anymore.
* IntuneWifiConfigurationPolicyAndroidForWork
  * [BREAKING CHANGE] Removed resource because it's not supported anymore.
    Instead, use the `IntuneWifiConfigurationPolicyAndroidEnterpriseWorkProfile`
    resource.
* O365AdminAuditLogConfig
  * [BREAKING CHANGE] Removed `Ensure` parameter because it is a single instance
    object.
* O365OrgSettings
  * [BREAKING CHANGE] Removed deprecated parameter `MicrosoftVivaBriefingEmail`.
* ODSettings
  * [BREAKING CHANGE] Removed deprecated parameter `NotifyOwnersWhenInvitationsAccepted`.
* SPOPropertyBag
  * Reduced export time by 85%.
* SPOSharingSettings
  * [BREAKING CHANGE] Removed deprecated parameter `RequireAcceptingAccountMatchInvitedAccount`.
* SPOSite
  * Added additional caching.
* SPOTenantSettings
  * [BREAKING CHANGE] Removed deprecated parameter `UserVoiceForFeedbackEnabled`.
  * Fixed the retrieval and update of the OneDriveSharingCapability parameter.
* TeamsChannel
  * Reduced export time by up to 75%.
* TeamsChannelTab
  * Reduced export time by up to 85%.
* TeamsFederationConfiguration
  * [BREAKING CHANGE] Removed deprecated parameter `AllowPublicUsers`.
* TeamsMeetingPolicy
  * [BREAKING CHANGE] Removed deprecated parameter `ForceStreamingAttendeeMode`.
* TeamsShiftsPolicy
  * [BREAKING CHANGE] Removed deprecated parameter `EnableShiftPresence`.
* TeamsTenantDialPlan
  * [BREAKING CHANGE] Removed deprecated parameter `OptimizeDeviceDialing` and `ExternalAccessPrefix`.
* MISC
  * Added ordering to hashtables.
  * [BREAKING CHANGE] Changed multiple property values and types in Intune resources.
    Refer to the
    breaking change blog post for more information about the affected resources.
  * Added performance improvements to speed up resource processing.
  * Code cleanup across all Intune resources.
  * Code cleanup across all O365, OD and SPO resources.
  * Code cleanup across all Planner, PP and SC resources.
  * Code cleanup across all Sentinel, SH and Teams resources.
  * Code cleanup across all M365DSC modules.
  * Fixed typo in `ManagedIdentity` property across all resources.
  * Improved module import speed by up to 60%.
  * Reduced repeated logins during export of SPO and Teams resources.
  * [BREAKING CHANGE] Removed the public function `Get-M365DSCConnectedWorkloadList`.
  * Removed unnecessary type casting across all resources.
  * Streamlined test cases.
  * Updated most resource testing to use the new comparison function.
  * Updated required modules for Intune resources doing assignments to groups.
  * [BREAKING CHANGE] Removed `SupportsScopeTags` property from all resources
    because it's read-only.
  * Updated all resource settings files to include a `configuration` or `data` mode.
* M365DSCDRGUtil
  * Changed the way how Settings Catalog properties are exported.
  * Fixed an issue where a null drift would throw an exception.
  * Fixed an issue where group filtering would not find the specified groups.
  * Fixed an issue where 0 requests passed to `Invoke-M365DSCGraphBatchRequests`
    would fail.
    FIXES [#6521](https://github.com/microsoft/Microsoft365DSC/issues/6521)
  * Fixed an issue with applying Intune Settings Catalog policies.
* M365DSCUtil
  * Added parameter `-Parallel` to `Export-M365DSCConfiguration`.
  * Renamed function `Get-M365DSCWorkloadsListFromResourceNames` to `Get-M365DSCConnectedWorkloadList`.
  * Added function `Get-M365DSCWorkloadForResource` to look up the workload of
    a resource.
  * Added function `Get-M365DSCResourcesByExportMode` to determine which
    resources belong to an export mode.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.51.

# 1.25.910.1

* Fixed an issue with `AdminConsentGranted` not being correct if the
    permissions are from multiple source APIs.
* AADCrossTenantAccessPolicyConfigurationDefault
  * Evaluate users and groups by display name to be consistent with
    other resources.
* EXOTransportRule
  * Fixed an issue where deprecated properties were exported.

# 1.25.903.2

* AADEnrichedAuditLogs
  * DEPRECATED resource.
* AADServicePrincipal
  * Change in logic to evaluate instances in Test-TargetResource when
    multiple instances exist with the same display name.
* IntuneWindowsBackupForOrganizationConfiguration
  * Initial release.
* MISC
  * Code cleanup across all EXO, Commerce, Defender and Fabric resources.
* DEPENDENCIES
  * Update ReverseDSC to version 2.0.0.30.

# 1.25.903.1

* AADAccessReviewDefinition
  * Added properties `FallbackReviewers` and `Reviewers`.
    FIXES [#5674](https://github.com/microsoft/Microsoft365DSC/issues/5674)
* AADApplication
  * Fixed an issue where owners would not be set during creation.
    FIXES [#6238](https://github.com/microsoft/Microsoft365DSC/issues/6238)
* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Added support for Groups as well as single users.
    FIXES [#6257](https://github.com/microsoft/Microsoft365DSC/issues/6257)
* AADAuthenticationStrengthPolicy
  * Filter out built-in policies because they cannot be modified.
* AADEntitlementManagementRoleAssignment
  * Added functionality to export groups and service principals.
    Fixed an issue where the export of `Connected organization administrator` assignments would fail.
    FIXES [#5620](https://github.com/microsoft/Microsoft365DSC/issues/5620)
    FIXES [#5618](https://github.com/microsoft/Microsoft365DSC/issues/5618)
* AADServicePrincipal
  * Fixed an issue where assigning members to a Service Principal would throw an error when
    more than one member was assigned.
* ADOPermissionGroupSettings
  * Reduced export time by 90%.
* IntuneAntivirusPolicyWindows10ConfigMgr
  * Initial release.
* IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr
  * Initial release.
    FIXES [#4229](https://github.com/microsoft/Microsoft365DSC/issues/4229)
* IntuneDeviceComplianceNotificationMessageTemplate
  * Initial release.
* IntuneDeviceComplianceScriptLinux
  * Initial release.
* IntuneDeviceManagementComplianceSettings
  * Updated `DeviceComplianceCheckinThresholdDays` to use the default value of 30 days
    if the backend reports 0 as the value.
    FIXES [#6450](https://github.com/microsoft/Microsoft365DSC/issues/6450)
* IntuneDeviceRemediation
  * [BREAKING CHANGE] Made Id optional and enabled creation of remediation scripts using DisplayName only.
    FIXES [#6445](https://github.com/microsoft/Microsoft365DSC/issues/6445)
  * Restricted possible values for `DeviceComplianceCheckinThresholdDays` from 1 to 120.
* IntuneMobileAppsWin32AppWindows10
  * Bump CIM instance version to fix invalid property name.
* IntuneMobileAppsWindowsOfficeSuiteApp
  * Fixes problem with OfficeConfigurationXml.Changed from type byte to type
    String as APi expect a string that is encoded in Base64 format.
* IntuneSecurityBaselineMicrosoftEdge
  * Fixed an issue where the latest policy version was not exported.
    FIXES [#6415](https://github.com/microsoft/Microsoft365DSC/issues/6415)
* IntuneWindowsUpdateForBusinessHotpatchProfileWindows10
  * Initial release.
    FIXES [#6368](https://github.com/microsoft/Microsoft365DSC/issues/6368)
* PPPowerAppsEnvironment
  * Fixed a variable naming conflict for environments provisioned through Microsoft Teams.
    FIXES [#6404](https://github.com/microsoft/Microsoft365DSC/issues/6404)
* SCInsiderRiskPolicy
  * Fixed an issue where an empty `EnableTeam` value would throw during Get operation.
* TeamsCallingPolicy
  * Added 12 new supported properties.
* TeamsMeetingBroadcastConfiguration
  * Fixes an issue where the SdnAPIToken wasn't exported as a string.
* TeamsMessagingPolicy
  * Added support for 12 new properties.
* TeamsTeam
  * Fixed an issue where an invalid search query was invoked.
    FIXES [#5937](https://github.com/microsoft/Microsoft365DSC/issues/5937)
* MISC
  * Code cleanup across all AAD, ADO and Azure resources.
  * Fixing issues connection SPO to sovereign clouds.
  * Fixed an issue across Intune resources using the Settings Catalog which
    were not correctly setting their `RoleScopeTagIds`.
    FIXES [#6434](https://github.com/microsoft/Microsoft365DSC/issues/6434)
  * Fixed issues when connecting SPO to sovereign clouds.
  * Updated settings and formatting of method names across all resources.
  * Updated documentation for configuring workload authentication.
  * Updated permissions for EXO resources.
    FIXES [#3841](https://github.com/microsoft/Microsoft365DSC/issues/3841)
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.9.0.
    FIXES [#6106](https://github.com/microsoft/Microsoft365DSC/issues/6106)
  * Include `Az.Security` module for `Defender` workload.
  * Updated MSCloudLoginAssistant to version 1.1.52.
* M365DSCReverse
  * Switch to output directory during export.
    FIXES [#6427](https://github.com/microsoft/Microsoft365DSC/issues/6427)
* M365DSCTelemetryEngine
  * Changed logic to retrieve the global telemetry authentication parameters.
* M365DSCUtil
  * Changed logic to provide the global telemetry authentication parameters.
  * Moved sizing of batch requests to `Invoke-M365DSCGraphBatchRequest`.
  * Fixed a comparison issue in `Compare-M365DSCComplexObject`.
    Supersedes [#6196](https://github.com/microsoft/Microsoft365DSC/pull/6196).

# 1.25.827.1

* EXODistributionGroup
  * Fixed an error when removing distribution groups.
    FIXES [#6435](https://github.com/microsoft/Microsoft365DSC/issues/6435)
  * Fix regression with distribution group members where RecipientType is 'User'.
    FIXES [#6426](https://github.com/microsoft/Microsoft365DSC/issues/6426)
* EXOIRMCOnfiguration
  * Fixes an export issue where the LicensingLocation parameter wasn't properly
    captured.
* M365DSCGraphAPIRuleEvaluation
  * Initial release.
* PlannerTask
  * Fixed an issue where a task with a deleted user assigned could not be exported.
    FIXES [#6054](https://github.com/microsoft/Microsoft365DSC/issues/6054)
* MISC
  * Modified the drift logging logic to include the MSFT_ prefix
    in the resource name and add back the LCMState parameter.
* DEPENDENCIES
  * Updated MicrosoftTeams to version 7.3.1.

# 1.25.806.1

* AADApplication
  * Fixes an issue where the Get-TargetResource no longer returned
    values for AppRoles.
  * Fixed an issue where not all properties were exported.
* AADAuthenticationMethodPolicyFido2
  * Fixed an issue where the policy was not updated properly.
    FIXES [#6391](https://github.com/microsoft/Microsoft365DSC/issues/6391)
* AADCrossTenantAccessPolicyConfigurationDefault
  * Fixed an issue where the export returns an invalid value for `Targets`.
    FIXES [#6397](https://github.com/microsoft/Microsoft365DSC/issues/6397)
* AADEntitlementManagementAccessPackage
  * Fixed an issue where `AccessPackagesIncompatibleWith` would not be populated with a value.
    FIXES [#5063](https://github.com/microsoft/Microsoft365DSC/issues/5063)
* AADServicePrincipal
  * Fixes for retrieving instance by name.
* AADUser
  * Added support for Mail attribute.
* EXOOrganizationConfig
  * Added support for the RejectDirectSend property.
* FabricAdminTenantSettings
  * Fixed the export of the resource.
    FIXES [#6345](https://github.com/microsoft/Microsoft365DSC/issues/6345)
* IntuneMobileAppsLobAppiOS
  * Initial release.
* IntuneMobileAppsLobAppAndroid
  * Initial release.
* IntuneMobileAppsLobAppWindows10
  * Initial release.
* IntuneMobileAppsLobAppMsiWindows10
  * Initial release.
* IntuneMobileAppsWin32AppWindows10
  * Updated the property name of `autoUpdateSupersededApps` to `autoUpdateSupersededAppsState`.
* SCAutoSensitivityLabelRule
  * Updated supported values for `Workload` property.
    FIXES [#4617](https://github.com/microsoft/Microsoft365DSC/issues/4617)
* SCSensitivityLabel
  * Reduced export time by 90%
* TeamsEventsPolicy
  * Added 7 new properties.
    FIXES [#6403](https://github.com/microsoft/Microsoft365DSC/issues/6403)
* M365DSCResourceGenerator
  * Fixed an issue where duplicate parameters would lead to an error during generation.
    FIXES [#5489](https://github.com/microsoft/Microsoft365DSC/issues/5489)
* DEPENDENCIES
  * Updated Az.Accounts to version 5.0.1.
  * Updated Az.ResourceGraph to version 1.2.1.
  * Updated Az.Resources to version 8.0.0.
  * Updated Az.SecurityInsights to version 3.2.0.
  * Updated ReverseDSC to version 2.0.0.29.

# 1.25.730.1

* AADServicePrincipal
  * Fixed an issue when translating `AppId` to the corresponding `DisplayName` during test.
    FIXES [#6382](https://github.com/microsoft/Microsoft365DSC/issues/6382)

# 1.25.723.2

* AADConditionalAccessPolicy
  * Remove the ValidateSet from the ProtocolFlows property.
* AADCrossTenantAccessPolicyConfigurationDefault
  * Fixed the return values from the Get-TargetResource method.
* AADUser
  * Fixed an issue when fetching a property from an empty array.

# 1.25.723.1

* AADApplication
  * Reduced export time by up to 75%.
* AADConditionalAccessPolicy
  * Added support for the ProtocolFlows property.
* AADGroup
  * Reduced export time by up to 60%.
* AADPIMGroupSettings
  * Reduced export time by 80%.
* AADGroupEligibilitySchedule
  * Reduced export time by 80%.
* AADGroupEligibilityScheduleSettings
  * Reduced export time by 90%.
* AADPasswordRuleSettings
  * Updated creation of new DirectorySetting object to explicitly use default values to avoid exception
* AADRoleEligibilityScheduleRequest
  * Reduced export time by up to 50%.
* AADRoleSetting
  * Reduced export time by 80%.
* AADServicePrincipal
  * Reduced export time by 70%.
* AADUser
  * Reduced export time by 25%.
* IntuneDeviceCleanupRuleV2
  * Initial release.
* IntuneMobileAppsBuiltInStoreApp
  * Initial release.
* IntuneMobileAppsManagedGooglePlayApp
  * Initial release.
* IntuneMobileAppsBundleMacOS
  * Initial release.
* IntuneMobileAppsStoreApp
  * Initial release.
* IntuneMobileAppsSystemAppAndroid
  * Initial release.
* IntuneMobileAppsWin32AppWindows10
  * Initial release.
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Added new options to `EnableControlledFolderAccess` property.
    FIXES [#6353](https://github.com/microsoft/Microsoft365DSC/issues/6353)
* IntuneSettingCatalogCustomPolicyWindows10
  * Add `RoleScopeTagIds` property to functions.
    FIXES [#6348](https://github.com/microsoft/Microsoft365DSC/issues/6348)
* SCSensitivityLabel
  * Fixes issue where AdvancedSettings in MSFT_SCSensitivityLabel was not always exported as an array block. [#6321](https://github.com/microsoft/Microsoft365DSC/issues/6321)
* M365DSCDRGUtil
  * Added new function `Invoke-M365DSCIntuneMobileAppInitialUpload` for initial mobile app content upload.
* MISC
  * Fixed log messages from being out of order for AAD resource

# 1.25.716.1

* AADAdministrativeUnit
  * Add detection/support for not filters as they require additional headers (ConsistencyLevel: Eventual).
* AADGroup
  * Add detection/support for not filters as they require additional headers (ConsistencyLevel: Eventual).
* AADUser
  * Add detection/support for not filters as they require additional headers (ConsistencyLevel: Eventual).
* AADConditionalAccessPolicy
  * Fixed issue with setting empty ExcludePlatform in Target state when current state contains a value
    FIXES [#6298](https://github.com/microsoft/Microsoft365DSC/issues/6298)
  * Fixed incorrect ServicePrincipalRiskLevels parameter type
    FIXES [#6325](https://github.com/microsoft/Microsoft365DSC/issues/6325)
  * Added example for workload identity and dynamic filter based on CustomSecurityAttribute
* EXOTransportRule
  * Changed the update logic to handle empty parameters.
* IntuneMobileAppsDefenderForEndpointMacOS
  * Initial release.
* IntuneMobileAppsMicrosoft365SuiteMacOS
  * Initial release.
* IntuneMobileAppsMicrosoftEdge
  * Initial release.
* O365Group
  * Add detection/support for not filters as they require additional headers (ConsistencyLevel: Eventual).
* MISC
  * Added logging to various resource to improve troubleshooting
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.50.

# 1.25.709.1

* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10SettingCatalog
  * Shortened resource name to `IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10V2`
    because of a path too long exception in Azure Automation.
    FIXES [#6289](https://github.com/microsoft/Microsoft365DSC/issues/6289)
* SCAutoSensitivityLabelRule
  * Fix logic to test actions with apostrophes in the name.
* SCDeviceConfigurationRule
  * Changes in logic retrieving existing rule associated policy.
* SCDLPComplianceRule
  * Fix logic to test actions with apostrophes in the name.
* M365DSCUtil
  * Fixed an issue where `Uninstall-M365DSCOutdatedDependencies` would throw an error during
    checking of the Microsoft.Graph.Authentication module.
    FIXES [#6274](https://github.com/microsoft/Microsoft365DSC/issues/6274)
* MISC
  * Updated CIM version for `MSFT_DeviceManagementConfigurationPolicyAssignments` class.
  * Added benchmarking for Test-TargetResource evaluation.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.20.
  * Updated MicrosoftTeams to version 7.2.0.

# 1.25.702.1

* AADAdministrativeUnit
  * Throw if an unsupported Member or ScopedRoleMember type is returned.
  * Fix verbose logging for assigned memberships, make update calls type-agnostic.
* AADAgreement
  * Initial release.
* AADApplication
  * Fix to properly handle PreAuthorizedApplications in the Set-TargetResource method
    FIXES [#6182](https://github.com/microsoft/Microsoft365DSC/issues/6182)
* AADConditionalAccessPolicy
  * Fix for removing or resetting builtInControls, customAuthenticationFactors,
    authenticationStrength or termsOfUse
    FIXES [#6218](https://github.com/microsoft/Microsoft365DSC/issues/6218)
  * FIXES [#6198] Adds support for ServicePrincipalRiskLevels
  * FIXES [[#6242](https://github.com/microsoft/Microsoft365DSC/issues/6242)]
    Avoids creating or updating a policy with a missing/unknown location.
* AADEntitlementManagementAccessPackage
  * Fix catalogId variables used when adding resource to access package from catalog
* AADGroup
  * Fix for removing Group owner.
* AADGroupElegibilityScheduleSettings
  * New resource AADGroupElegibilityScheduleSettings
* AADIdentityB2XUserFlow
  * Corrected permission in settings.json
* AADRoleAssignmentScheduleRequest
  * FIXES [#5710](https://github.com/microsoft/Microsoft365DSC/issues/5710)
* AADServicePrincipal
  * Fixed an issue where the `AppId` won't be exported.
    FIXES [#6200](https://github.com/microsoft/Microsoft365DSC/issues/6200)
    FIXES [#6181](https://github.com/microsoft/Microsoft365DSC/issues/6181)
    FIXES [#6045](https://github.com/microsoft/Microsoft365DSC/issues/6045)
    FIXES [#5419](https://github.com/microsoft/Microsoft365DSC/issues/5419)
  * Fixed an issue where updating the configuration with `CustomSecurityAttributes`
    would fail.
    FIXES [#6208](https://github.com/microsoft/Microsoft365DSC/issues/6208)
* EXODistributionGroup
  * Always use the retrieved Identity when updating the distribution group
    to ensure correct group is updated when retrieved with PrimarySmtpAddress.
* FabricAdminTenantSettings
  * Fixed an issue where exported titles could contain unescaped string literals.
    FIXES [#6199](https://github.com/microsoft/Microsoft365DSC/issues/6199)
* IntuneDeviceAndAppManagementAssignmentFilter
  * Added property `AssignmentFilterManagementType` to supported properties.
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Added new property `SecurityBlockJailbrokenDevices`.
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Added support for property `RoleScopeTagIds`.
* IntuneDefenderGlobalExclusionsPolicyLinux
  * Initial release.
* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10
  * Deprecated resource.
* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10SettingCatalog
  * Initial release.
* IntuneMobileAppsWebLink
  * Initial release.
* IntuneWindowsHelloForBusinessGlobalPolicy
  * Initial release.
    FIXES [#4561](https://github.com/microsoft/Microsoft365DSC/issues/4561)
* SCComplianceSearchAction
  * Fixed an issue where the export would fail for preview actions.
    FIXES [#6215](https://github.com/microsoft/Microsoft365DSC/issues/6215)
    FIXES [#3534](https://github.com/microsoft/Microsoft365DSC/issues/3534)
* SCDLPComplianceRule
  * Fixed an issue where the export of `SetHeader` is wrongly formatted.
    FIXES [#6140](https://github.com/microsoft/Microsoft365DSC/issues/6140)
  * Fixed an issue where the export of `AdvancedRule` with multiple and nested subconditions
    would throw an error during removal of the sensitive type id.
* SPOSharingSettings
  * Removing calls to deprecated RequireAcceptingAccountMatchInvitedAccount setting
    that prevent SharingDomainRestrictionMode from being set properly.
* TeamsCallQueue
  * Fixed an issue with the export where we can now export more than 100 instances.
* TeamsMeetingPolicy
  * Added missing Parameter 'RoomAttributeUserOverride' to Get-TargetResource's output.
    Fixes [#6183](https://github.com/microsoft/Microsoft365DSC/issues/6183)
* M365DSCPermissions
  * Fixed an issue when accessing permissions from the compiled list returns no permissions.
* M365DSCReverse
  * Fixed an issue where a provided file name with spaces leads to an invalid export config name.
    FIXES [#6247](https://github.com/microsoft/Microsoft365DSC/issues/6247)
* M365DSCUtil
  * Add -ExcludeComponents parameter to `Export-M365DSCConfiguration`to allow
    for easy skipping of certain components.
    FIXES [#6192(https://github.com/microsoft/Microsoft365DSC/issues/6192)]
  * Moved `Get-M365DSCIntuneDeviceConfigurationSettings` function to central location.
* MISC
  * Added `deviceAndAppManagementAssignmentFilterDisplayName` property to Intune assignments.
    FIXES [#4609](https://github.com/microsoft/Microsoft365DSC/issues/4609)
  * Added module pinning.
    FIXES [#6168](https://github.com/microsoft/Microsoft365DSC/issues/6168)
  * Streamlined `Test-TargetResource` for many resources.
  * Streamlined usage of `Get-M365DSCIntuneDeviceConfigurationSettings` in combination with
    updating Intune intent policy type settings.
    FIXES [#6252](https://github.com/microsoft/Microsoft365DSC/issues/6252)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.48.

# 1.25.611.1

* AADAdministrativeUnit
  * Upgrade from beta to v1.0 Microsoft Graph endpoint for Administrative Unit,
    Device, Directory Role and Directory Role Template.
    FIXES [#4438](https://github.com/microsoft/Microsoft365DSC/issues/4438)
  * Remove unnecessary Graph requests when retrieving AU membership.
* AADConditionalAccessPolicy
  * Upgrade from beta to v1.0 Microsoft Graph endpoint for Directory Role Template.
* AADGroup
  * Allow DisplayName to include apostrophes.
  * Upgrade from beta to v1.0 Microsoft Graph endpoint for Device.
* AADPIMGroupSetting
  * [#6117] Initial relase.
* EXODistributionGroup
  * Return PrimarySmtpAddress instead of DisplayName for Members field,
    and ManagedBy and ModeratedBy field, to allow values to be set.
  * Allow ManagedBy and ModeratedBy fields including groups or contacts.
* EXOGroupSettings
  * Use the existing group ID to apply updates instead of DisplayName.
* EXOManagementRoleAssignment
  * Upgrade from beta to v1.0 Microsoft Graph endpoint for Administrative Units.
    FIXES [#4438](https://github.com/microsoft/Microsoft365DSC/issues/4438)
* EXORoleGroup
  * Add offline filter capability to `Export-TargetResource`.
    FIXES [#4286](https://github.com/microsoft/Microsoft365DSC/issues/4286)
* IntuneAppProtectionPolicyiOS
  * [BREAKING CHANGE] Combined `ExcludedGroups` with `Assignments`, updated
    time parameters to ISO8601 format, removed `IsAssigned` property.
    FIXES [#5970](https://github.com/microsoft/Microsoft365DSC/issues/5970)
    FIXES [#5809](https://github.com/microsoft/Microsoft365DSC/issues/5809)
    FIXES [#5689](https://github.com/microsoft/Microsoft365DSC/issues/5689)
    FIXES [#4568](https://github.com/microsoft/Microsoft365DSC/issues/4568)
    FIXES [#3936](https://github.com/microsoft/Microsoft365DSC/issues/3936)
* IntuneDeviceCompliancePolicyWindows10
  * Added support for `Id` and `ScheduledActionsForRule` property.
    FIXES [#6123](https://github.com/microsoft/Microsoft365DSC/issues/6123)
    FIXES [#3563](https://github.com/microsoft/Microsoft365DSC/issues/3563)
* IntuneRoleAssignment
  * Update evaluation of parameters.
    FIXES [#5929](https://github.com/microsoft/Microsoft365DSC/issues/5929)
* DEPENDENCIES
  * Added dependency on Microsoft.Graph.Identity.DirectoryManagement.
  * Added dependency on Microsoft.Graph.Identity.Signins.
  * Updated MSCloudLoginAssistant to version 1.1.45;
* MISC
  * Allow use of apostrophes in DisplayName for all resources types.

# 1.25.604.1

* AADAdministrativeUnit
  * Allow DisplayName to include apostrophes.
* AADApplication
  * Fixed issue where the property AuthenticationBehaviors was incorrectly
    exported as an array.
  * Fixed issue where the AuthenticationBehaviors wasn't processed properly
    and added example how to enforce an empty configuration.
  * Deprecated AuthenticationBehavior\RequireClientServicePrincipal property.
    Trying to set this property will throw an error.
  * Fixed issue where the property Permissions was not exported as an array
* AADCrossTenantAccessPolicyConfigurationPartner
  * Fix export issue where B2B settings are not exported when these are set
    to default settings.
* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Fixing export issue where AccessReviewSettings does not contain correct
    info when access reviews are disabled.
    FIXES [#5941](https://github.com/microsoft/Microsoft365DSC/issues/5941)
* AADGroup
  * Fixed issue where the property Permissions was not exported as an array
* AADRoleAssignmentScheduleRequest
  * Fix export issue where Recurrence settings are not exported when they
    are not configured.
* AADRoleEligibilityScheduleRequest
  * Fix export issue where Recurrence settings are not exported when they
    are not configured.
* EXOMobileDeviceMailboxPolicy
  * Fix export issue where two properties were exported as integer, where
    the schema expects a string.
* EXOQuarantinePolicy
  * Updated the schema to match the parameter value in the code. The schema
    defined this property as a string, where the code expected and integer.
    NOTE: This should not cause any issues, since the export already exported
    this value as an integer.
* IntuneSecurityBaselineMicrosoftEdge
  * Updated to latest template and deprecated `EdgeEnhanceImagesEnabled` as well as `WebSQLAccess`.
* IntuneSecurityBaselineWindows10
  * Updated resource with new 24H2 properties.
* SCDLPComplianceRule
  * Fixed apostrophes in the export method.
* SCSensitivityLabel
  * Fixed issue where the Groups property in AutoLabelingSettings was not
    exported as an array.
  * Fixed issue where the export of AdvancedSettings had a key but no value,
    which caused errors during deployment. Now ignoring setting if no value
    is set.
* SPORetentionLabelsSettings
  * Correcting permissions in settings.json
* TeamsGroupPolicyAssignment
  * Fix export issue where two properties were exported as integer, where
    the schema expects a string.
* TeamsVdiPolicy
  * Added support for `VDI2Optimization` property.
* VivaEngagementRoleMember
  * Initial release.
* MISC
  * Added `RoleScopeTagIds` property across the Intune resources.

# 1.25.528.1

* EXORetentionPolicyTag
  * Fixes an issue where the AgeLimitForRetention  could be added twice in the results
    from Get-TargetResource.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.2.0
  * Updated Microsoft.Graph to version 2.28.0
  * Updated MSCloudLoginAssistant to version 1.1.44

# 1.25.521.1

* AADServicePrincipal
  * Fixed the assignment of AppRoleAssignedTo when creatign a new Service Principal.
  * Adds `-All` to `Get-MgServicePrincipalAppRoleAssignedTo` call to return more than 100 records
* IntuneASRRulesPolicyWindows10
  * Removed newly added template ID, it belongs to `IntuneApplicationControlPolicyWindows10`.
* IntuneDeviceConfigurationSCEPCertificatePolicyWindows10
  * Allow the combination of `sha1,sha2` as a value for `HashAlgorithm`.
* IntuneMobileAppsWindowsOfficeSuiteApp
  * Fixed an issue where the `ExcludedApps` property would be in an invalid format.
* SPOApp
  * Fixed an issue where the export would fail.
    FIXES [#5810](https://github.com/microsoft/Microsoft365DSC/issues/5810)
    FIXES [#4557](https://github.com/microsoft/Microsoft365DSC/issues/4557)
* TeamsMeetingPolicy
  * Added support for the new CaptchaVerificationForMeetingJoin property.
* MISC
  * Updated required permissions for Intune script resources.
  * Added a new LCMState property to drifts in event logging.

# 1.25.514.1

* AADApplication
  * Fixed an issue where the `AdminConsentGranted` property had an incorrect value.
    FIXES [#5027](https://github.com/microsoft/Microsoft365DSC/issues/5027)
* EXORetentionPolicyTag
  * BREAKING - Changed the AgeLimitForRetention property type to UInt32.
* EXOTransportRule
  * Fixed an issue where not specified properties would lead to an exception.
* IntuneASRRulesPolicyWindows10
  * Added filter on additional template ID for both the Export and Get methods.
* IntuneWifiConfigurationPolicyAndroidForWork
  * Fixed an issue where the wrong odata type was used for export and creation.
* TeamsFederationConfiguration
  * DEPRECATED the AllowPublicUsers property.
* DEPENDENCIES
  * Updates DSCParser to version 2.0.0.17.
* MISC
  * Improved export speed for multiple resources.

# 1.25.509.1

* AADAppManagementPolicy
  * Initial release.
* AADAuthenticationFlowPolicy
  * Fixes way argument is passed to `Update-MgBetaPolicyAuthenticationFlowPolicy` to now send as bodyparameter instead of `-SelfServiceSignUp $true/$false`
* AADB2CAuthenticationMethodsPolicy
  * Initial release.
* AADCrossTenantAccessPolicyConfigurationDefault
  * Updated Set-TargetResource to call the REST APIs directly, fixing
    an issue with the cmdlet parameter casing.
* AADMultiTenantOrganizationIdentitySyncPolicyTemplate
  * Initial release.
* AADTenantAppManagementPolicy
  * Initial release.
* AADTokenIssuancePolicy
  * Initial release.
* EXORecipientPermission
  * Ensures the right entry is retrieved from the Get-TargetResource
    method when multiple instances start with the same word pattern.
* EXORetentionPolicyTag
  * Fixes the evaluation of the AgeLimitForRetention property.
* IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner
  * Fixes the template type in the Get-Targetresource.
* IntuneWifiConfigurationPolicyIOS
  * Fixed Test-TargetResource and available properties.
    FIXES [#3973](https://github.com/microsoft/Microsoft365DSC/issues/3973)
* IntuneWifiConfigurationPolicyMacOS
  * Added additional properties to the export.
* IntuneWifiConfigurationPolicyWindows10
  * Added additional properties to the export.
    FIXES [#3963](https://github.com/microsoft/Microsoft365DSC/issues/3963)
* PlannerTask
  * Allow setting of up to 25 categories.
    FIXES [#6052](https://github.com/microsoft/Microsoft365DSC/issues/6052)
* TeamsAppSetupPolicy
  * Fixes evaluation of empty values in Test-TargetResource.
* M365DSCReverse
  * Removed the parameter `MaxProcesses` from the internal `Start-M365DSCConfigurationExtract` function.
* M365DSCUtil
  * Removed the parameter `MaxProcesses` from the public `Export-M365DSCConfiguration` function.
    FIXES [#5982](https://github.com/microsoft/Microsoft365DSC/issues/5982)
  * Fixed an issue where basic arrays would not be compared correctly.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.7.2
  * Updated MicrosoftTeams to version 7.0.0

# 1.25.430.1

* AADServicePrincipal
  * Fixes the evaluation of Enterprise app when AppId is passed in GUID form.
* EXODistributionGroup
  * Changed Get-TargetResource not to throw an error when the instance doesn't exist.
* EXORetentionPolicy
  * Changed Get-TargetResource not to throw an error when the instance doesn't exist.
* EXORoleGroup
  * Changed logic to always evaluate using the email address for both users
    and groups in the Test-TargetResource method.
* M365DSCRuleEvaluation
  * Unload the modules after each exports to help with memory assignment.
* TeamsOnlineVoicemailUserSettings
  * Remove connection to graph to retrieve all users in the export flow.

# 1.25.423.1

* AADEntitlementManagementConnectedOrganization
  * Fixed an issue where an empty display name would result in a parameter binding exception.
    FIXES [#4981](https://github.com/microsoft/Microsoft365DSC/issues/4981)
* EXOHostedContentFilterPolicy
  * Fixed an issue with setting the default value for `IntraOrgFilterState`.
    FIXES [#5031](https://github.com/microsoft/Microsoft365DSC/issues/5031)
* IntuneAppProtectionPolicyiOS
  * Fixed empty array comparison.
    FIXES [#5736](https://github.com/microsoft/Microsoft365DSC/issues/5736)
* IntuneDeviceEnrollmentLimitRestriction
  * Added support for `Assignments`, `Priority` and `RoleScopeTagIds` properties.
    FIXES [#3915](https://github.com/microsoft/Microsoft365DSC/issues/3915)
* IntuneWifiConfigurationPolicyAndroidEnterpriseWorkProfile
  * Fixes the data type for extraction and creation.
* SPOSearchManagedProperty
  * Fixed an issue where the connection url was not the admin url required by the resource.
    FIXES [#5093](https://github.com/microsoft/Microsoft365DSC/issues/5093)
    FIXES [#4538](https://github.com/microsoft/Microsoft365DSC/issues/4538)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.27.0.
  * Updated MSCoudLoginAssistant to version 1.1.43.
* MISC
  * Fixes case sensitivity comparison when updating device configuration policies.

# 1.25.416.1

* EXOResourceConfiguration
  * Added required permissions to settings.json file.
* EXOTenantAllowBlockListItems
  * Inlined function call.
* IntuneDeviceControlPolicyWindows10
  * Added support for `DefaultEnforcement` and `DeviceControlEnabled` properties.
* IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile
  * Fix export and remove read-only properties.
    FIXES [#5969](https://github.com/microsoft/Microsoft365DSC/issues/5969)
* IntuneSecurityBaselineHoloLens2Advanced
  * Initial release.
* IntuneWifiConfigurationPolicyMacOS
  * Fixed an issue where fetching the assignments of a policy that only exists by display name fails.
    FIXES [#5971](https://github.com/microsoft/Microsoft365DSC/issues/5971)
* PlannerTask
  * Update export to use common functions.
    FIXES [#6004](https://github.com/microsoft/Microsoft365DSC/issues/6004)
* M365DSCDRGUtil
  * Removed undefined variable from if statement.
* M365DSCPermissions
  * Add `AdministrativeRoles` and `RequiredRoles` property to export.
* MISC
  * Removed `-Verbose` parameter from multiple commands where it's not necessary.
  * Removed unused functions across several resources.
  * Added export of module functions to several EXO resources.
  * Update export to use common function for multiple resources.
  * Update `requiredrolegroups` property of settings.json file to array.
  * Updated the Write-M365DSCHost function to make the Message parameter
    optional to fix null errors.

# 1.25.409.1

* AADApplication
  * DEPRECATED: Parameter AvailableToOtherTenants.
  * Added direct support for the SignInAudience parameter.
* AADEntitlementManagementAccessPackage
  * Fix incorrect assignment where `$results.CatalogId` was assigned
    `catalog.DisplayName` instead of `catalog.Id`
* EXOSafeAttachmentRule
  * Inlined function calls.
* EXOSafeLinksRule
  * Inlined function calls.
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Add support for automatic account management and other new options.
* IntuneSecurityBaselineHoloLens2Standard
  * Initial release.
* M365DSCPermissions
  * Add `AdministrativeRoles` property to export of `Get-M365DSCCompiledPermissionList`.
  * Removed commented out `Update-M365DSCResourcesSettingsJSON` definition.
* M365DSCUtil
  * Removed numerous EXO functions.
  * Removed additional unnecessary functions.
* MISC
  * Removed clearing of M365DSC authentication parameters from numerous Intune resources.
  * Updated the new Write-M365DSCHost function to only print
    messages when they are not null.

# 1.25.402.1

* AADAdministrativeUnit
  * Fix issue where AdministrativeUnit calls fail with ODATA error on dynamic membership.
    FIXES [#5815](https://github.com/microsoft/Microsoft365DSC/issues/5815)
  * Fix issue where a role is not detected to be deactivated before adding to an Administrative Unit
* AADConditionalAccessPolicy
  * Fixed DisableResilienceDefaultsIsEnabled to allow for nullable boolean
    FIXES [#5940](https://github.com/microsoft/Microsoft365DSC/issues/5940)
* AADUser
  * Added the property `OtherMails` to the managed properties.
    FIXES [#4763](https://github.com/microsoft/Microsoft365DSC/issues/4763)
* AADGroup
  * Fixed `isAssignableToRole` to support for null values returned by graph.
    FIXES [#5959](https://github.com/microsoft/Microsoft365DSC/issues/5959)
* AADPasswordRuleSettings
  * [BREAKING CHANGE] Replace `Enforced` with `Enforce` as a possibility of
    `BannedPasswordCheckOnPremisesMode` to align with updated Graph value.
* EXOArcConfig
  * [BREAKING CHANGE] Removed the `Identity` parameter since it does not
    have any functionality and is not exported by default.
* EXOMailboxSettings
  * Add the AuditEnabled property.
* EXOMailTips
  * [BREAKING CHANGE] Removed resource. Use `EXOOrganizationConfig` instead.
    Fixes [#5647](https://github.com/microsoft/Microsoft365DSC/issues/5647)
* EXOManagementRoleEntry
  * Added the ability to add and remove entries by adding the Ensure property
    to the resource.
* EXORoleGroup
  * Changed the logic to retrieve members email identifier in the Get-TargetResource
    function.
* EXOSharedMailbox
  * Add AuditEnabled property
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * [BREAKING CHANGE] Remove deprecated value `add_replace` from `Action` parameter.
* IntuneAppConfigurationPolicy
  * Changed export logic of CustomSettings to use centralized function.
* IntuneDeviceConfigurationCustomPolicyiOS
  * Initial release, adds support for iOS `Custom` Device Configuration policies.
* IntuneDeviceEnrollmentStatusPageWindows10
  * Use `SelectedMobileAppNames` as the primary source for the apps.
    FIXES [#5913](https://github.com/microsoft/Microsoft365DSC/issues/5913)
* IntuneDeviceFeaturesConfigurationPolicyIOS
  * Initial release
* IntuneSecurityBaselineMicrosoftEdge
  * [BREAKING CHANGE] Remove deprecated parameter `authschemes`.
* IntuneWifiConfigurationPolicyMacOS
  * Fixes a naming issue with the primary key when calling the update assignment
    cmdlet.
* PPPowerAppsEnvironment
  * Added support for the EnvironmentType property and fixed the
    values for EnvironmentSKU.
  * Add support for creating Environment with Dataverse db
* SPOApp
  * Overwrite existing files during app export.
    FIXES [#5953](https://github.com/microsoft/Microsoft365DSC/issues/5953)
* SPOTheme
  * Updated export of `Palette` property to match schema.
    FIXES [#5863](https://github.com/microsoft/Microsoft365DSC/issues/5863)
* M365DSCTelemetryEngine
  * Allow setting the LCM configuration from outside.
* M365DSCUtil
  * Added the new function `Join-M365DSCConfiguration` to merge multiple
    configuration files.
    FIXES [#2359](https://github.com/microsoft/Microsoft365DSC/issues/2359)
  * Added the new function `Test-CodePage`, which outputs a warning message
    if the current ANSI code page is not UTF-8.
    FIXES [#5202](https://github.com/microsoft/Microsoft365DSC/issues/5202)
    FIXES [#5669](https://github.com/microsoft/Microsoft365DSC/issues/5669)
    FIXES [#4824](https://github.com/microsoft/Microsoft365DSC/issues/4824)
  * Add PowerShell 5 to 7 compatibility layer.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.16.
* MISC
  * Fix CSV-report so variable-names are passed correctly in the report
  * Replace `Write-Host` with custom function to support logs in non-interactive
    environments using the verbose stream.
  * [BREAKING CHANGE] Removed the command `Import-M365DSCDependencies`.
* Whitepaper
  * Parallel to this release the code for the whitepaper also implements a
    Breaking Change. Make sure you are using the v3.1 code if you use
    this version of Microsoft365DSC or later.

# 1.25.326.1

* AADApplication
  * Added support for SPA and Public Client Url properties.
* AADServicePrincipal
  * In the translation logic between GUID and display name of the AppId property,
    change the way we are retrieving the application instance to be using a filter
    instead of a direct call to the -ApplicationId parameter.

# 1.25.319.1

* AADServicePrincipal
  * Streamlined logic to translate AppId from a display name.
* IntuneDeviceConfigurationPolicyAndroidDeviceOwner
  * Fixed an issue where empty complex objects result in a broken export.
    FIXES [#5863](https://github.com/microsoft/Microsoft365DSC/issues/5863)
* SCSensitivityLabel
  * Fix an issue where the Priority property was always getting updated for an
    existing label, even if it didn't get updated.
* SHSpaceGroup
  * Initial release.
* SHSpaceUser
  * Initial release.
* TeamsApplicationInstance
  * Initial release.
* M365DSCDRGUtil
  * Made a change in the Intune assignment evaluation logic not to validate that
    the provided group is a valid Entra Id group based on GroupId. The logic
    to validate this will be left to the Set-TargetResource.
* M365DSCUtil
  * Added note about long paths being recommended when installing the Dev branch.
    FIXES [#3158](https://github.com/microsoft/Microsoft365DSC/issues/3158)
* DEPENDENCIES
  * Updated MicrosoftTeams to version 6.9.0.
  * Updated MSCloudLoginAssistant to version 1.1.42.

# 1.25.312.1

* AADApplication
  * Defaulting AuthenticationBehaviors as an empty array from the
    Get-TargetResource function.
* AADAuthenticationStrengthPolicy
  * Added check to ensure the current exported instance names match in
    Get-TargetResource.
* AADDomain
  * Fixed an issue where the test checked a string instead of the variable.
    FIXES [#5886](https://github.com/microsoft/Microsoft365DSC/issues/5886)
* AADRoleSetting
  * Fixed the required permissions.
    FIXES [#3696](https://github.com/microsoft/Microsoft365DSC/issues/3696)
* EXORoleGroup
  * Removed parameter `Roles` when creating a new group if there were
    no roles assigned to it.
    FIXES [#5725](https://github.com/microsoft/Microsoft365DSC/issues/5725)
* IntuneAppleMDMPushNotificationCertificate
  * Hide error message if no certificate was found during export.
    FIXES [#5884](https://github.com/microsoft/Microsoft365DSC/issues/5884)
* IntuneAppProtectionPolicyAndroid
  * Fix export of `ApprovedKeyboards` and `ExemptedAppPackages` properties.
* IntuneDeviceManagementEnrollmentAndroidGooglePlay
  * Changed the resource to be read-only due to the associated APIs not being
    owned by Microsoft.
* O365OrgSettings
  * Add required `Insights Administrator` role for Get and Update.
* SCDLPCompliancePolicy
  * Fixes strange issue with the Get-TargetResource throwing an error
    complaining about a null object.
* SCLabelPolicy
  * Fixed evaluation of CIMInstances in Test-TargetResource.
* SPOSiteScript
  * Fixed an issue where the Get method would fail on fetching a specific script.
    FIXES [#5701](https://github.com/microsoft/Microsoft365DSC/issues/5701)
* M35DSCReport
  * Require Excel to be installed for .xlsx export.
* M365DSCReverse
  * Fixed an issue where specifying a component multiple times in the Export
    would skip the resource altogether.
* DEPENDENCIES
  * Updated ReverseDSC to version 2.0.0.28.
* MISC
  * Added check to ensure the current exported instance names match in
    Get-TargetResource.
* M365DSCLogEngine
  * Fixed an error message appearing if one or more event logs could
    not be accessed while searching the event source.
    FIXES [#3811](https://github.com/microsoft/Microsoft365DSC/issues/3811)

# 1.25.305.1

* AADApplication
  * If both the current and desired values have the Ensure property set
    to absent, ignoring the drift detection and return true from
    the Test-TargetResource function.
* AADAuthenticationMethodPolicyQRCodeImage
  * Initial release.
* AADGroupSettings
  * Filtered EnableMSStandardBlockedWords parameter from the policy results,
    to prevent issues with this deprecated parameter
* AADIdentityAPIConnector
  * Added missing permissions.
    FIXES [#5670](https://github.com/microsoft/Microsoft365DSC/issues/5670)
* AADRoleEligibilityScheduleRequest
  * Updated startdatetime and enddatetime properties to be of type DATETIME.
* AADUser
  * Fixed an issue where the properties with numbers were not exported correctly.
    FIXES [#4526](https://github.com/microsoft/Microsoft365DSC/issues/4526)
* EXOTransportConfig
  * Fixed an issue where `JournalingReportNdrTo` with the default value of `<>`
    would throw an error during apply.
    FIXES [#5606](https://github.com/microsoft/Microsoft365DSC/issues/5606)
* FabricAdminTenantSettings
  * Fixed issue where the export would add double quotes in front of boolean
    variables
* IntuneAppConfigurationPolicy
  * Adds support for targeted managed apps and for testing drift in Apps settings
    FIXES [#5566](https://github.com/microsoft/Microsoft365DSC/issues/5566)
* IntuneDeviceEnrollmentPlatformRestriction
  * Added note that update is no longer possible.
    FIXES [#5127](https://github.com/microsoft/Microsoft365DSC/issues/5127)
* IntuneDeviceRemediation
  * Fixed issue when `Assignment` was set to a non-existent group in the tenant,
    e.g. cloning a script from a source tenant and applying it to another target
    tenant and the latter doesn't have the assignment group created yet, if this
    was the case the deployment would fail
    FIXES [#5856](https://github.com/microsoft/Microsoft365DSC/issues/5856)
* IntuneSecurityBaselineWindows365
  * Initial release.
    FIXES [#3348](https://github.com/microsoft/Microsoft365DSC/issues/3348)
* PPEnvironmentAppsEnvironment
  * Added support for legacy Basic and Standard EnvironmentSKU.
* SCInsiderRiskPolicy
  * Enforced default values when the setting object is undefined.
* SCPolicyConfig
  * Enforced default values when the setting object is undefined.
* SPOSite
  * Fixed an issue where the exported properties were not defined.
    FIXES [#4773](https://github.com/microsoft/Microsoft365DSC/issues/4773)
* TeamsOrgWideAppSettings
  * Added note that only Credentials are supported for the resource.
    FIXES [#3394](https://github.com/microsoft/Microsoft365DSC/issues/3394)
* M365DSCDocGenerator
  * Fixed an issue where open/close tags in descriptions would be considered as HTML.
    FIXES [#4955](https://github.com/microsoft/Microsoft365DSC/issues/4955)
    FIXES [#5761](https://github.com/microsoft/Microsoft365DSC/issues/5761)
* M365DSCDRGUtil
  * Fixes an issue with fancy double quotes being replaced that break the string.
    FIXES [#5775](https://github.com/microsoft/Microsoft365DSC/issues/5775)
    FIXES [#5623](https://github.com/microsoft/Microsoft365DSC/issues/5623)
  * Escape strings in primary key of resource name for export content.
    FIXES [#5865](https://github.com/microsoft/Microsoft365DSC/issues/5865)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.41.

# 1.25.226.1

* AADConditionalAccessPolicy
  * Fixed an issue where `TermsOfUse` was not passed as an array, causing
    failures in GCC-High environments.
    FIXES [#5742](https://github.com/microsoft/Microsoft365DSC/issues/5742)
  * Added verbose to the Get-TargetResource function to print out the retrieved
    policies from calling the cmdlet.
* AADPasswordRuleSettings
  * Updated schema to only accept values 'Enforced' and 'Audit' for parameter BannedPasswordCheckOnPremisesMode
* IntuneDeviceCompliancePolicyWindows10
  * Fixes the handling of the `DeviceCompliancePolicyScript` property.
    FIXES [#5510](https://github.com/microsoft/Microsoft365DSC/issues/5510)
* O365OrgSettings
  * Added support for the AllowPlannerCopilot setting.
* PPTenantSettings
  * Corrected issue in the resource schema. The description was a multi-line
    string, which is not allowed.
* SPOSiteScript
  * Fix error in Get-TargetResource when a site-script is identified by title only
    FIXES [#5821](https://github.com/microsoft/Microsoft365DSC/issues/5821)
* SPOTenantSettings
  * Add EnableAzureADB2BIntegration and OneDriveSharingCapability properties
* TeamsChannel
  * Apply ordering during export.
    FIXES [#5829](https://github.com/microsoft/Microsoft365DSC/issues/5829)
* TeamsTeam
  * Apply ordering during export.
* TeamsUser
  * Apply ordering during export.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.39.

# 1.25.219.3

* AADApplication
  * Fixed an issue where specifying an empty ReplyURLs array would not remove
    the existing entries.
* AADAuthenticationMethodPolicy
  * DEPRECATED - PolicyMigrationState property is now deprecated since it
* AADAuthenticationMethodPolicyFido2
  * Fixed issue where the Set-TargetResource was throwing an internal server
    error.
* AADConditionalAccessPolicy
  * Added check to ensure the cached policy (export) is the current policy when
    evaluating in the Get-TargetResource function.
* EXOCalendarProcessing
  * Changed the Get-TargetResource logic to return UPN instead of id.
* EXODistributionGroup
  * Fixed the ability to set members.
* EXOGroupSettings
  * Removed Id from being evaluated in the Test-TargetResource function.
* EXOMailboxAutoReplyConfiguration
  * Changed the Get-TargetResource logic to return UPN instead of Identity.
* EXOMailboxCalendarFolder
  * Changed the Get-TargetResource logic to return UPN instead of id.
* EXOMailboxPermission
  * Changed the Get-TargetResource logic to return UPN instead of id.
* EXOSweepRule
  * Changed the Get-TargetResource logic to return UPN instead of id.
* IntuneDeviceComplianceScriptWindows10
  * Initial release.
* M365DSCRuleEvaluation
  * Clear the cached instances from the export operation after evaluating the rules.
* Security & Compliance
  * Updated export functions to remove skipping of loading module, to prevent
    missing cmdlet errors that are causing failing exports.
* SCPolicyConfig
  * Handle default values in the Get-TargetResource function.
  * Added support for the FileCopiedToCloudFullUrlEnabled property.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.7.1.
  * Updated Microsoft.Graph to version 2.26.1.
  * Updated MSCloudLoginAssistant to version1 1.1.38.

# 1.25.219.2

* AADAccessReviewPolicy
  * Missing AccessReview permission for Application Read access
    FIXES [#5796](https://github.com/microsoft/Microsoft365DSC/issues/5796)
* AADApplication
  * Test-TargetResource logic updated to skip evaluating CIMArrays that are empty
    when passed as desired values.
* AADDeviceRegistrationPolicy
  * Fixed an issue where the AzureADJoinIsAdminConfigurable was not returned by the
    Get-TargetResource function.
  * Fix issue setting Selected Users and Groups for Entra Join.
    FIXES [#5798](https://github.com/microsoft/Microsoft365DSC/issues/5798)
* AADGroup
  * Returns an empty array for roles and licenses from the Get-TargetResource
    function instead of null when no instances are found.
* AADRoleEligibilityScheduleRequest
  * Reduce call count when reconciling object type
    FIXES [#5621](https://github.com/microsoft/Microsoft365DSC/issues/5621)
  * Add check if object lookup fails
    FIXES [#5801](https://github.com/microsoft/Microsoft365DSC/issues/5801)
* AADServicePrincipal
  * Evaluating assigned users based on UPN and not just on DisplayName.
  * FIXES [#5359](https://github.com/microsoft/Microsoft365DSC/issues/5359) AADServicePrincipal fails on Managed Identities when DelegatedPermissions returns 500 response
* ADOSecurityPolicy
  * Fixes an issue where the resource threw an error trying to parse the default
    values.
* EXODistributionGroup
  * Changed logic to retrieve existing members by UserPrincipalName.
* EXOReportSubmissionPolicy
  * Add ReportChatMessageEnabled, ReportChatMessageToCustomizedAddressEnabled
* EXORoleGroup
  * Evaluating assigned users based on UPN and not just on DisplayName if they
    have an associated mailbox.
* IntuneDeviceManagementEnrollmentAndroidGooglePlay
  * Marked the Id property as mandatory in the resource.
* M365DSCRuleEvaluation
  * Added support for specifying a Filter property.
* M365DSCUtil
  * Add M365DSC prefix to `Remove-EmptyValue`.
  * Fixes an issue with `Credential` property being escaped and indentation.
  * Adds the possibility to allow variables in strings and no authentication
    results update during conversion to final export.
    FIXES [#3861](https://github.com/microsoft/Microsoft365DSC/issues/3861)
* SCInsiderRiskPolicy
  * Enforces the MDATPTriageStatus to be a string array.
* SCSensitivityLabel
  * Fixes invalid accepted content type values.
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Adds support for Scheduled Actions and other missing properties
    FIXES [#5593] (https://github.com/microsoft/Microsoft365DSC/issues/5593)
* IntuneDeviceCompliancePolicyAndroidWorkProfile
  * Adds support for Scheduled Actions and other missing properties
    FIXES [#5593] (https://github.com/microsoft/Microsoft365DSC/issues/5592)
* TeamsAppPermissionPolicy
  * Updated correct Typecasting for AppPresetMeeting and PinnedMessagebarApps
    before adding them to the policy
* TeamsAppSetupPolicy
  * FIXES [[#5752](https://github.com/microsoft/Microsoft365DSC/issues/5752)
* TeamsM365App
  * Remove `Ensure` property from being exported.
    FIXES [#5781](https://github.com/microsoft/Microsoft365DSC/issues/5781)
* AADGroupEligibilitySchedule
  * FIXES [#5792](https://github.com/microsoft/Microsoft365DSC/issues/5792) issue where complete DSC isn't exported after generated
  * FIXES [#5793](https://github.com/microsoft/Microsoft365DSC/issues/5793) issue where PrincipalType isn't correctly captured in AzureGov
* DEPENDENCIES
  * Updated ReverseDSC to version 2.0.0.27

# 1.25.212.2

* MISC
  * Fixing connection errors in Power Platforms resources.

# 1.25.212.1

* AADApplication
  * Changing the AuthenticationBehaviors parameters to string to allow
    for null values.
* AADCrossTenantAccessPolicyConfigurationDefault
  * Fixes an issue with CIM class export.
* AADCrossTenantAccessPolicyConfigurationPartner
  * Fixes an issue with CIM class export.
    FIXES [#5711](https://github.com/microsoft/Microsoft365DSC/issues/5711)
* AADGroupEligibilitySchedule
  * FIXES [#5741] Missing -All variable which prevented enumeration of more than 100 Groups
* EXORetentionPolicyTag
  * Initial release.
* EXOSmtpDaneInbound
  * Updated authentication properties to align with MOF definition.
    FIXES [#5709](https://github.com/microsoft/Microsoft365DSC/issues/5709)
* MISC
  * PowerPlatform resource revamp to use direct REST API calls.
  * Simplify export behavior for all resources and complex objects.
* DEPENDENCIES
  * Removed dependency on Microsoft.PowerApps.Administration.PowerShell.
  * Updated DSCParser to version 2.0.0.15.
  * Updated MSCloudLoginAssistant to version 1.1.37.
  * Updated ReverseDSC to version 2.0.0.25.

# 1.25.205.1

* AADApplication
  * Refactored logic for CIM Instance evaluation in Test-TargetResource.
* AADConditionalAccessPolicy
  * Changed the InsiderRiskTypes property to a string array.
* AADConnectorGroupApplicationProxy
  * Fixes an issue where the Get-TargetResource was not able to retrieve
    instances by names.
  * Refactored logic for CIM Instance evaluation in Test-TargetResource.
* AADServicePrincipal
  * Fixes comparison of assigned roles for null values.
    FIXES [#5717](https://github.com/microsoft/Microsoft365DSC/issues/5717)
* CommerceSelfServicePurchase
  * Initial release.
* SCPolicyConfig
  * Fixes and issue where Get-TargetResource was returning an empty array
    instead of a null value when no values were defined.
* SCRoleGroupMember
  * Error handling if the Members parameter is omitted.
* MISC
  * Changed the CIMInstance logic of various resources to us common logic.
  * Added support for specifying a proxy in Update-M365DSCModule.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.36.

# 1.25.129.3

* EXOMigrationEndpoint
  * Added support for EntpointType value of ExchangeRemoteMove.
* M365DSCRuleEvaluation
  * Changed logic to evaluate cases where the rule results in no results.
* SPDLPComplianceRule
  * Fix for the SensitiveInfoType ID cleaning logic in Get-TargetResource.
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.205.
  * Updated MicrosoftTeams to version 6.8.0.
  * Updated MSCloudLoginAssistant to version 1.1.35.

# 1.25.129.2

* M365DSCRuleEvaluation
  * Only provide the ManagedIdentity parameter for resources which supports it.
* SCDLPComplianceRule
  * Added the comments property on creation.
* SCPolicyConfig
  * Changed parsing logic to account for $null or missing properties in the
    API response.

# 1.25.129.1

* AADGroup
  * Added functionality to add & check on Devices in AAD groups.
* AADRoleEligibilityScheduleRequest
  * Changed the mapping logic to find Id of a custom role.
* AADServicePrincipal
  * Fixes a regression issue when trying to export instances, the authentication
    parameters were no longer returned by the Get-TargetResource function.
* IntuneDeviceConfigurationPolicyiOS
  * Fixes [#5594] https://github.com/microsoft/Microsoft365DSC/issues/5594
* MISC
  * AAD Workload
    * Improved performance of various resources during export.

# 1.25.122.2

* AADAdminConsentRequestPolicy
  * Refactored the export to use a common CIMInstance function.
* AADCrossTenantAccessPolicyConfigurationDefault
  * Refactored the export to use a common CIMInstance function.
* AADCrossTenantAccessPolicyConfigurationPartner
  * Refactored the export to use a common CIMInstance function.
* AADGroup
  * Refactored the export to use a common CIMInstance function.
* AADHomeRealmDiscoveryPolicy
  * Refactored the export to use a common CIMInstance function.
* AADIdentityGovernanceLifecycleWorkflow
  * Refactored the export to use a common CIMInstance function.
* AADNetworkAccessForwardingPolicy
  * Refactored the export to use a common CIMInstance function.
* AADNetworkAccessForwardingProfile
  * Refactored the export to use a common CIMInstance function.
* AADRemoteNetwork
  * Refactored the export to use a common CIMInstance function.
* AADRoleAssignmentScheduleRequest
  * Refactored the export to use a common CIMInstance function.
* AADRoleEligibilityScheduleRequest
  * Fixed overall logic to prevent errors complaining about existing permissions.
  * Refactored the export to use a common CIMInstance function.
* FabricAdminTenantSettings
  * Fix titles that have a zero length whitespace character.
* IntuneAppProtectionPolicyAndroid
  * Fixes an error retrieving the group id for assignment which resulted
    in a 500 error when creating or updating an instance.
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * Fixes an issue where not all details were exported.
* IntuneAccountProtectionPolicy
  * Fixes an issue where not all details were exported.
* IntuneAppConfigurationPolicy
  * Fixes an issue with fetching a policy that does not exist.
    FIXES [#5666](https://github.com/microsoft/Microsoft365DSC/issues/5666)
* IntuneApplicationControlPolicyWindows10
  * Fixes an issue with fetching a policy that does not exist.
* IntuneAppProtectionPolicyAndroid
  * Fixes an issue with fetching a policy that does not exist.
  * Added support for additional App Protection policies
    FIXES [#5590](https://github.com/microsoft/Microsoft365DSC/issues/5590)
* IntuneDeviceEnrollmentPlatformRestriction
  * Fixes an issue with fetching a policy that does not exist.
* M365DSCReverse
  * Only fetch tenant name if not in correct format.
* O365SearchAndIntelligenceConfigurations
  * Added support for Meeting Insights settings.
  * Added support for Service Principal authentication.
* SCInsiderRiskEntityList
  * Fixed trailing whitespaces in the name of some properties when attempting
    to set values.
* TeamsEmergencyCallRoutingPolicy
  * Refactored the export to use a common CIMInstance function.
* TeamsTenantDialPlan
  * Refactored the export to use a common CIMInstance function.

# 1.25.122.1

* AADConditionalAccessPolicy
  * Fixes CA policy deployment errors when deploying policies based for workload identities.
  * Fixed DisableResilienceDefaults result
  * Add DisableResilienceDefaults false szenario
* AADDeviceRegistrationPolicy
  * Fixes an error when trying to disable AAD join.
* AADGroupsNamingPolicy
  * Use correct parameter `DesiredValues` given to `Test-M365DSCParameterState`,
    contrary to `EXOTenantAllowBlockListItems` these resources are not affected
    but we still should use the correct parameter
* AADRoleSetting
  * Fixed issue where missing settings object for a role caused errors.
    FIXES [#5602](https://github.com/microsoft/Microsoft365DSC/issues/5602)
* AADServicePrincipal
  * FIXES [#5549](https://github.com/microsoft/Microsoft365DSC/issues/5549)
* EXOAvailabilityConfig
  * Removed dependency on Microsoft Graph to retrieve user information.
* EXODistributionGroup
  * Removed dependency on Microsoft Graph to retrieve user information.
* EXOHostedContentFilterPolicy
  * Use correct parameter `DesiredValues` given to `Test-M365DSCParameterState`,
    contrary to `EXOTenantAllowBlockListItems` these resources are not affected
    but we still should use the correct parameter
* EXOTenantAllowBlockListItems
  * Fixed `Test-TargetResource` by using the correct parameter `DesiredValues`
    given to `Test-M365DSCParameterState`
* EXOTransportRule
  * Fix type of `SenderInRecipientList` in schema
* FabricAdminTenantSettings
  * Added support for the AllowGetOneLakeUDK, AllowMountDfCreation, AllowOneLakeUDK,
    ArtifactOrgAppPreview properties.
  * Fix values that have a zero length whitespace character.
* IntuneAppProtectionPolicyiOS
  * Fixes [#5589] https://github.com/microsoft/Microsoft365DSC/issues/5589
* SCAutoSensitivityLabelPolicy
  * Use correct parameter `DesiredValues` given to `Test-M365DSCParameterState`,
    contrary to `EXOTenantAllowBlockListItems` these resources are not affected
    but we still should use the correct parameter
* SCLabelPolicy
  * Use correct parameter `DesiredValues` given to `Test-M365DSCParameterState`,
    contrary to `EXOTenantAllowBlockListItems` these resources are not affected
    but we still should use the correct parameter
* SCSecurityFilter
  * Use correct parameter `DesiredValues` given to `Test-M365DSCParameterState`,
    contrary to `EXOTenantAllowBlockListItems` these resources are not affected
    but we still should use the correct parameter
* SPOSPOBrowserIdleSignout
  * Corrected export types where the schema expected a String, but received a different type
    FIXES [#5648](https://github.com/microsoft/Microsoft365DSC/issues/5648)
* SPOSharingSettings
  * Corrected export types where the schema expected a String, but received a different type
    FIXES [#5648](https://github.com/microsoft/Microsoft365DSC/issues/5648)
* M365DSCReport
  * Fix missing delimiter when called without the parameter.
    FIXES [#5634](https://github.com/microsoft/Microsoft365DSC/issues/5634)
  * Add configuration validation to inform about comparisons against empty or invalid configurations.
    FIXES [#5658](https://github.com/microsoft/Microsoft365DSC/issues/5658)
* M365DSCTelemetryEngine
  * Report LCM details only if running as administrator.
* M365DSCUtil
  * In `Test-M365DSCParameterState` try to replace the line endings before
    making the comparison otherwise it may fail as it did for a few resources
    FIXES [#5648](https://github.com/microsoft/Microsoft365DSC/issues/5648)
* MISC
  * Modified 100+ Test-TargetResource logic to prevent returning $false when
    the Ensure parameter doesn't match the desired value. While this could introduce
    a very small performance gain in some cases, it resulted in a lot of drifts being
    detected without proper logging. All evaluation, including of the Ensure property,
    is now being handled by the Test-M365DSCParameterState function.
  * Export Performance Improvements
    Implements the changes described in [#5615](https://github.com/microsoft/Microsoft365DSC/issues/5615)
    Improved resource caching behavior across Intune resources.

# 1.25.115.1

* AADAuthenticationRequirement
  * Filtered guests from the export, to prevent errors during export
    FIXES [#5625](https://github.com/microsoft/Microsoft365DSC/issues/5625)
* AADCustomAuthenticationExtension
  * Fixes an issue extracting instances due to the OrganizationName being null.
* AADGroup
  * Only get Members & GroupAsMembers when a static group is defined.
* AADGroupEligibilitySchedule
  * New resource for Privileged Identity Management (PIM) for Groups
* AADNamingLocationPolicy
  * Improved logging and fixed issue that caused creation of duplicate
    locations with same name.
* EXOSmtpDaneInbound
  * Initial release
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneAccountProtectionPolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneAntivirusPolicyLinux
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneAntivirusPolicyMacOS
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneAppAndBrowserIsolationPolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneDeviceControlPolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneDiskEncryptionMacOS
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneDiskEncryptionWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneEndpointDetectionAndResponsePolicyLinux
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneEndpointDetectionAndResponsePolicyMacOS
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneFirewallPolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Fixed creation of policy while it was found by name, now it updates existing policies correctly.
* IntuneVPNConfigurationPolicyAndroidWork
  * Initial release
* M365DSCRuleEvaluation
  * Making RuleDefinition a key of the resource to allow multiple
    rules for the same resource type to be provided in the same config.
  * Adding a new RuleName parameter to make it easier to understand
    the results in the event logs.
* TeamsGroupPolicyAssignment
  * FIXES [[#5527](https://github.com/microsoft/Microsoft365DSC/issues/5527)]
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.203.
  * Updated MSCloudLoginAssistant to version 1.1.34.

# 1.25.108.1

* AADAuthenticationRequirement
  * Changed Export logic to extract instances from all users.
* AADConditionalAccessPolicy
  * Add disableResilienceDefaults
* AADOrganizationCertificateBasedAuthConfiguration
  * Fixed the primary key of the resource.
    FIXES [#5523](https://github.com/microsoft/Microsoft365DSC/issues/5523)
* AADRoleEligibilityScheduleRequest
  * Fixed error when extracting an entry with a deleted principal.
* DefenderDeviceAuthenticatedScanDefinition
  * Fixed the Data Type export.
* IntuneTrustedRootCertificateAndroidWork
  * Initial Release
* MISC
  * DEFENDER
    * Added support for the UseBasicParsing paramter for REST calls.
  * Added check to `New-M365DSCReportFromConfiguration` to make sure Windows
    Remoting is enabled, which is required to convert the DSC config.
  * Defender
    * Added support for the UseBasicParsing parameter for REST calls.

# 1.24.1218.1

* AADApplication
  * Added support for Oauth2PermissionScopes.
  * Fixes comparison issue for permissions.
* EXOTransportRule
  * Fixes issue extracting arrays in Get-TargetResource.
    FIXES [#5575](https://github.com/microsoft/Microsoft365DSC/issues/5575)
* TeamsMeetingPolicy
  * Adds support for additional Copilot setting value.
    FIXES [#5573](https://github.com/microsoft/Microsoft365DSC/issues/5573)
    FIXES [#5550](https://github.com/microsoft/Microsoft365DSC/issues/5550)
* MISC
  * Fixed the Fabric web request to use basic parsing.
  * Reset only necessary authentication context.
* M365DSCUtil
  * Update `Get-M365DSCWorkloadsListFromResourceNames` function for more input types.
    FIXES [#5525](https://github.com/microsoft/Microsoft365DSC/issues/5525)
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.202.
  * Updated MSCloudLoginAssistant to version 1.1.31.

# 1.24.1211.1

* AADApplication
  * Changed logic to remove all permissions when an empty array is specified.
    FIXES [#5534](https://github.com/microsoft/Microsoft365DSC/issues/5534)
  * Changed logic to update AppRoles by first disabling the entry.
    FIXES [#5524](https://github.com/microsoft/Microsoft365DSC/issues/5524)
* AADFeatureRolloutPolicy
  * Fixed policy retrieval
    FIXES [#5521](https://github.com/microsoft/Microsoft365DSC/issues/5521)
* AADRoleEligibilityScheduleRequest
  * Changed logic to retrieve instance by Service Principal with custom role.
    FIXES [#5532](https://github.com/microsoft/Microsoft365DSC/issues/5532)
* IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile
  * Fixing issue with the way the QrCodeImage property was exported and handled.
* IntuneFirewallPolicyWindows10
  * Fix export of properties that appear multiple times in subsections.
* IntuneSecurityBaselineWindows10
  * Initial release.
* M365DSCDRGUtil
  * Improve settings catalog handling for nested objects.
* M365DSCResourceGenerator
  * Fixes an issue with nested object creation.
* MISC
  * Migrate `MSCloudLoginAssistant` authentication context access to cmdlets.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.29.

# 1.24.1204.1

* All resources
  * Applying project default formatting on all files, to improve
    reading and troubleshooting.
* AADAccessReviewDefinition
  * Added support for #microsoft.graph.accessReviewInactiveUsersQueryScope in odatatype.
* AADActivityBasedTimeoutPolicy
  * Added support for AccessTokens.
* AADClaimsMappingPolicy
  * Fixed policy retrieval
    FIXES [#5505](https://github.com/microsoft/Microsoft365DSC/issues/5505)
* AADIdentityAPIConnector
  * Changed the export logic to export passwords as credential objects instead of string.
* AADRoleManagementPolicyRule
  * Added the logic to handle filters in the Export logic flow.
* EXOAuthenticationPolicyAssignment
  * Added $confirm flag to the Set-TargetResource function for PowerShell 7 compatibility.
* EXOClientAccessRule
  * Added $confirm flag to the Set-TargetResource function for PowerShell 7 compatibility.
* EXOManagementRoleAssignment
  * Changed logic to detect drift.
* EXOServicePrincipal
  * Removed ObjectID from the return of the Get-TargetResource method.
* EXOTeamsProtectionPolicy
  * Initial release
    FIXES [#5296](https://github.com/microsoft/Microsoft365DSC/issues/5296)
* EXOTransportRule
  * Fixed conditional logic for creation and update.
* PPPowerAppsEnvironmant
  * Fixed [[#5508](https://github.com/microsoft/Microsoft365DSC/issues/5508)]
* IntuneTrustedRootCertificateIOS
  * Initial release
* IntuneVPNConfigurationPolicyAndroidDeviceOwner
  * Initial release
* IntuneVPNConfigurationPolicyAndroidEnterprise
  * Initial release
* IntuneVPNConfigurationPolicyIOS
  * Initial release.
* M365DSCRuleEvaluation
  * Only attempt to pass AccessTokens if specified.
* SPORetentionLabelsSettings
  * Initial release.
* MISC
  * M365DSCDRGUtil
    * Add separate check for strings with ordinal comparison and standardized line breaks.
  * M365DSCReport
    * Add support for creating report in CSV-format

# 1.24.1127.1

* AAD
  * Added ApplicationSecret auth method to multiple resources
* AADFilteringPolicyRule
  * Fixed an issue with the export of the Destinations property where
    the CIMInstance array object was malformed.
* EXOEOPProtectionPolicyRule
  * Added support for AccessTokens.
* EXOExternalInOutlook
  * Added support for AccessTokens.
* EXOMailContact
  * Changed how empty arrays are returned.
* EXOPlace
  * Changed how empty arrays are returned.
* EXORecipientPermission
  * Added logic to update an existing recipients permissions.
* EXOTransportRule
  * Changed how empty arrays are returned.
* INTUNE
  * Add parameter `-All` to Graph requests to fetch all policies on Get.
* IntuneAndroidManagedStoreAppConfiguration
  * Initial release.
* IntuneAppConfigurationPolicy
  * Fixes an issue where assignment was not properly set if the
    groupId was null.
    FIXES [#5430](https://github.com/microsoft/Microsoft365DSC/issues/5430)
* IntuneMobileAppConfigurationPolicyIOS
  * Removing resource. Already possible with IntuneAppConfigurationDevicePolicy
* IntuneMobileThreatDefenseConnector
  * Fixes a NotFound error when the resource does not exist and remove
    `LastHeartbeatDateTime` from comparison.
* IntuneRoleAssignment
  * Improve verbose output and fix copy-pasted variables.
* IntuneRoleScopeTag
  * Initial release.
* IntuneTrustedRootCertificateAndroidDeviceOwner
  * Initial release.
* IntuneTrustedRootCertificateAndroidEnterprise
  * Initial release.
* TeamsUserPolicyAssignment
  * Added support for the Global policies.
* TeamsUpgradePolicy
  * DEPRECATED: Users properties. Use the TeamsUserPolicyAssignment resource
    instead.
* M365DSCUtil
  * Add default Ensure value `Present` if not specified.
    FIXES [#5085](https://github.com/microsoft/Microsoft365DSC/issues/5085)
  * When exporting generate the instance names of resources with their mandatory
    keys instead of random GUIDs , this makes exports idempotent again
    FIXES [#5469](https://github.com/microsoft/Microsoft365DSC/issues/5469)
* MISC
  * Removed hardcoded Graph urls and replaced by MSCloudLoginAssistant values.
  * Add separate module handling for PowerShell Core.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.14.
  * Updated Microsoft.Graph to version 2.25.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.200.
  * Updated MicrosoftTeams to version 6.7.0.

# 1.24.1120.1

* AADAdminConsentRequestPolicy
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyAuthenticator
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyEmail
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyExternal
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyFido2
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyHardware
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicySms
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicySoftware
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyTemporary
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyVoice
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADAuthenticationMethodPolicyX509
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADConditionalAccessPolicy
  * Fixed bug where a null value was passed in the request for the
    excludePlatforms parameter when just values were assigned to includePlatforms, which throws an error.
  * Fixed bug where a null value was passed in the request for the
    sessionControl parameter when there are no session controls, which throws an error.
  * Fixed bug where a null value was passed in the request for the
    applicationEnforcedRestrictions parameter when value was set to false, which throws an error.
* AADDeviceRegistrationPolicy
  * Added error handling to Group display name retrieval to prevent errors
    when an assigned group no longer exists.
* AADRoleAssignmentScheduleRequest
  * Initial release.
* AADRoleEligibilityScheduleRequest
  * Adds support for custom role assignments at app scope.
* AADRoleSettings
  * Fixing issue where the ActivateApprover parameter is not processed correctly
    when an approver does not exist.
    FIXES [#5423](https://github.com/microsoft/Microsoft365DSC/issues/5423)
    FIXES [#5415](https://github.com/microsoft/Microsoft365DSC/issues/5415)
* ADOSecurityPolicy
  * Fixed an error in the export when using a Service Principal to authenticate.
* AzureBillingAccountPolicy
  * Initial release.
* IntuneDeviceConfigurationPolicyAndroidDeviceOwner
  * Fixed issue when properties `DetailedHelpText`,
    `DeviceOwnerLockScreenMessage` or `ShortHelpText` were defined but the
    request was not being sent correctly
    FIXES [#5411](https://github.com/microsoft/Microsoft365DSC/issues/5411)
* IntuneDiskEncryptionPDEPolicyWindows10
  * Initial release.
* IntuneFirewallRulesHyperVPolicyWindows10
  * Initial release.
* IntuneFirewallRulesPolicyWindows10ConfigMgr
  * Initial release.
* IntuneMobileAppConfigurationPolicyIOS
  * Initial release.
* SCPolicyConfig
  * Fixed an issue extracting empty groups properties.
* TeamsMeetingPolicy
  * FIXES #5442(https://github.com/microsoft/Microsoft365DSC/issues/5442)
* TeamsUpdateManagementPolicy
  * Added conversion of the UpdateTimeOfDay parameter to the local culture format
    so that the comparison will work consistently.
    FIXES [#5424](https://github.com/microsoft/Microsoft365DSC/issues/5424)
* M365DSCDRGUtil
  * Improve CIM instance detection for specific Intune resources.
* AADUser
  * Fixed issue updating user group membership when looking for the group by DisplayName.
  * Fixed missing User Id when changing  group membership in Set-TargetResource function.

# 1.24.1113.1

* AADConditionalAccessPolicy
  * Fixed bug where an empty value was passed in the request for the
    insiderRiskLevels parameter, which throws an error.
    FIXES [#5389](https://github.com/microsoft/Microsoft365DSC/issues/5389)
  * Fixes a bug where 3P apps could not be assigned by DisplayName for both
    IncludeApplications and ExcludeApplications
    FIXES [#5390](https://github.com/microsoft/Microsoft365DSC/issues/5390)
* AADRoleEligibilityScheduleRequest
  * FIXES [#3787](https://github.com/microsoft/Microsoft365DSC/issues/3787)
  * FIXES [#5089](https://github.com/microsoft/Microsoft365DSC/issues/5089)
* EXOATPBuiltInProtectionRule, EXOEOPProtectionRule
  * Fixed issue where empty arrays were being compared incorrectly to null
    strings
    FIXES [#5394](https://github.com/microsoft/Microsoft365DSC/issues/5394)
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Update property `PasswordAgeDays_AAD` to be lower-case.
    FIXES [#5378](https://github.com/microsoft/Microsoft365DSC/issues/5378) (1/2)
* IntuneAntivirusExclusionsPolicyMacOS
  * Initial release.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Update properties to be upper-case.
    Fixes [#5373](https://github.com/microsoft/Microsoft365DSC/issues/5373)
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Fixed issue where `Value`, from `OmaSettings`, could not be compared
    correctly if it was boolean and set to `$False`
    FIXES [#5384](https://github.com/microsoft/Microsoft365DSC/issues/5384)
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Remove changed property name from export.
  FIXES [#5300](https://github.com/microsoft/Microsoft365DSC/issues/5300)
* IntuneSecurityBaselineMicrosoftEdge
  * Deprecate property `authschemes` and replace with `AuthSchemes_AuthSchemes`
* M365DSCDRGUtil
  * Restrict CIM instance access to properties that appear multiple times.
  * Switch log type for not found Intune assignments to `Warning`.
* M365DSCIntuneSettingsCatalogUtil
  * Add ADMX handling for `edge~httpauthentication_`.
    FIXES [#5378](https://github.com/microsoft/Microsoft365DSC/issues/5378) (2/2)
* TeamsUpgradePolicy
  * Changes to how we are retrieving the users to improve performance.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.12.
  * Updated MSCloudLoginAssistant to version 1.1.28.

# 1.24.1106.3

* AzureBillingAccountScheduledAction
  * Initial release.
* AzureSubscription
  * Added the ability to delete subscriptions.
* EXODataAtRestEncryptionPolicyAssignment
  * Initial release.
* EXODataAtRestEncryptionPolicy
  * Initial release.
* IntuneAntivirusPolicyMacOS
  * Initial release.
* IntuneAntivirusExclusionsPolicyLinux
  * Initial release.
* IntuneFirewallRulesPolicyWindows10
  * Initial release.
* MISC
  * Fixed issues with API Url's parsing.

# 1.24.1106.1

* AADAccessReviewDefinition
  * Initial release.
* AADAccessReviewPolicy
  * Initial release.
* AADAuthenticationMethodPolicyExternal
  * Initial release.
* AADClaimsMappingPolicy
  * Initial release.
* AADConditionalAccessPolicy
  * FIXES [#5282](https://github.com/microsoft/Microsoft365DSC/issues/5282)
  * Added support for InsiderRiskLevels.
* AADCustomSecurityAttributeDefinition
  * Fixed missing permissions in settings.json
* AADEnrichedAuditLogs
  * Initial release.
* AADFederationConfiguration
  * Initial release.
* AADFilteringPolicy
  * Initial release.
* AADFilteringPolicyRule
  * Initial release.
* AADFilteringProfile
  * Initial release.
* AADGroup
  * Added support for custom roles assignment.
    FIXES [#5322](https://github.com/microsoft/Microsoft365DSC/issues/5322)
* AADHomeRealmDiscoveryPolicy
  * Initial Release
* AADIdentityAPIConnector
  * Initial release.
* AADIdentityB2XUserFlow
  * Initial release.
* AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension
  * Initial release.
* AADIdentityGovernanceProgram
  * Initial release.
* AADIdentityProtectionPolicySettings
  * Initial release.
* AADNamedLocationPolicy
  * Fixed issue where duplicate names were not detected correctly.
* AADNetworkAccessForwardingPolicy
  * Initial release.
* AADNetworkAccessForwardingProfile
  * Initial release.
* AADNetworkAccessSettingConditionalAccess
  * Initial release.
* AADNetworkAccessSettingCrossTenantAccess
  * Initial release.
* AADOnPremisesPublishingProfilesSettings
  * Initial release.
* AADOrganizationCertificateBasedAuthConfiguration
  * Initial release.
* AADRemoteNetwork
  * Initial release.
* AADRoleEligibilityScheduleRequest
  * Fixes for Custom roles.
    FIXES [#5330](https://github.com/microsoft/Microsoft365DSC/issues/5330)
  * Fixes to remove elegibility schedule for custom roles.
    FIXES [#5331](https://github.com/microsoft/Microsoft365DSC/issues/5331)
* AADRoleManagementPolicyRule
  * Initial release.
* AADServicePrincipal
  * Added the notes field.
    FIXES [#5312](https://github.com/microsoft/Microsoft365DSC/issues/5312)
  * Added support for KeyCredentials and PasswordCredentials.
  * Added support for SAML.
  * Fixed issue with Owners.
* AADSocialIdentityProvider
  * Fixed missing permissions in settings.json
* AADUserFlowAttribute
  * Initial Release
* AADVerifiedIdAuthority
  * Initial release.
* AADVerifiedIdAuthorityContract
  * Initial release.
* AzureBillingAccountsAssociatedTenant
  * Initial release.
* AzureBillingAccountsRoleAssignment
  * Initial release.
* AzureDiagnosticSettings
  * Initial release.
* AzureDiagnosticSettingsCustomSecurityAttribute
  * Initial release.
* AzureSubscription
  * Renamed parameters and added logic flow to create new subscriptions.
* AzureVerifiedIdFaceCheck
  * Initial release.
* DefenderDeviceAuthenticatedScanDefinition
  * Initial release.
* EXOActiveSyncMailboxPolicy
  * Initial release.
* EXOArcConfig
  * Fixed `Test-TargetResource` to correctly check property `ArcTrustedSealers`
    when it has an array
* EXOMailboxAuditBypassAssociation
  * Initial release.
* EXOMailboxSettings
  * Added support for AddressBookPolicy, RetentionPolicy, RoleAssignmentPolicy
    and SharingPolicy.
* EXOMigration
  * Initial release.
* EXOServicePrincipal
  * Initial release.
* EXOTenantAllowBlockListItems
  * Fixed `Test-TargetResource` to correctly mark when this resource is removed
* EXOTenantAllowBlockListSpoofItems
  * Initial release.
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * Updates values in `UserSelectionType`.
    FIXES [#5318](https://github.com/microsoft/Microsoft365DSC/issues/5318)
* IntuneAntivirusPolicyLinux
  * Initial release.
* IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr
  * Initial release.
* IntuneAppCategory
  * Fixed retrieval of resource which could then result in multiple categories
    being created with same name.
* IntuneAppleMDMPushNotificationCertificate
  * Initial release.
* IntuneAppProtectionPolicyiOS
  * Fixes an issue that could cause multiple instances to be created when multiple
    instances with the same display name exist.
* IntuneDerivedCredential
  * Fixed export and deployment when `NotificationType` had more than one option
    selected
  * Fixed retrieval of resource when it cannot be found by `Id`
  * Added a few verbose messages
* IntuneDeviceManagementAndroidDeviceOwnerEnrollmentProfile
  * Initial release.
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Fixes an issue with `AutoFromConnector` as the Configuration package type.
    FIXES [#5246](https://github.com/microsoft/Microsoft365DSC/issues/5246)
* IntuneMobileThreatDefenseConnector
  * Initial release.
* IntuneSecurityBaselineDefenderForEndpoint
  * Initial release.
* IntuneSettingCatalogCustomPolicyWindows10
  * Fixes an issue with limited results when more than 25 results are present.
* Intune workload
  * Fixed missing permissions in settings.json
* M365DSCRuleEvaluation
  * Changed the name of the Key property from ResourceName to ResourceTypeName.
    While this is considered a breaking change, the old property name was
    breaking the DSCParser process. The impact of this breaking the parsing
    process is important enough to justify an out-of-band breaking change of
    this resource.
* ODSettings
  * Deprecated property NotifyOwnersWhenInvitationsAccepted.
    FIXES [#4979](https://github.com/microsoft/Microsoft365DSC/issues/4979)
* PPPowerAppsEnvironment
  * Add ProvisionDatabase attribute
    FIXES [#5207](https://github.com/microsoft/Microsoft365DSC/issues/5207)
* PPTenantSettings
  * Updated to support latest settings.
* SCInsiderRiskPolicy
  * Added support for property MDATPTriageStatus.
  * Added support for GPUUtilizationLimit and CPUUtilizationLimit.
* SCPolicyConfig
  * Initial release.
* SCSensitivityLabel
  * Fixed issue with setting label priority
    FIXES [#5266](https://github.com/microsoft/Microsoft365DSC/issues/5266)
* SentinelAlertRule
  * Initial release.
* SentinelThreatIntelligenceIndicator
  * Initial release.
* SPOSharingSettings
  * Deprecated property RequireAcceptingAccountMatchInvitedAccount.
    FIXES [#4979](https://github.com/microsoft/Microsoft365DSC/issues/4979)
* SPOTenantSettings
  * Added support for AllowSelectSGsInODBListInTenant,
    DenySelectSGsInODBListInTenant, DenySelectSecurityGroupsInSPSitesList,
    AllowSelectSecurityGroupsInSPSitesList,
    ExemptNativeUsersFromTenantLevelRestricedAccessControl properties.
  * TenantDefaultTimezone changed to String instead of Array.
* TeamsMeetingPolicy
  * Added new parameters: AllowExternalNonTrustedMeetingChat, AttendeeIdentityMasking,
    AutomaticallyStartCopilot, AutoRecording, ConnectToMeetingControls,
    ContentSharingInExternalMeetings, Copilot, CopyRestriction,
    DetectSensitiveContentDuringScreenSharing, ExternalMeetingJoin, ParticipantNameChange,
    VoiceIsolation
* TeamsOrgWideAppSettings
  * Fixed an issue where ManagedIdentity wasn't define in the methods' signatures.
    FIXES [#5188](https://github.com/microsoft/Microsoft365DSC/issues/5188)
* M365DSCDRGUtil
  * Fixes an issue where non-unique properties were not combined
    properly with their respective parent setting.
* MISC
  * Fixed references to graph.microsoft.com with dynamic domain name based on target cloud.
    Impacted AADAdminConsentRequestPolicy, AADApplication, AADConditionalAccessPolicy, AADGroup,
    AADNamedLocationPolicy, AADServiePrincipal, IntuneASRRulesPolicyWindows10,
    IntuneAccountProtectionLocalUsersGroupMembershipPolicy, IntuneAccountProtectionPolicy,
    IntuneAppProtectionPolicyiOS,IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10,
    IntuneDeviceConfigurationSCEPCertificatePolicyWindows10, IntuneDeviceConfigurationWiredNetworkPolicyWindows10,
    IntuneDeviceEnrollmentStatusPageWindows10, IntuneDiskEncryptionMacOS, IntunePolicySets,
    IntuneSettingCatalogCustomPolicyWindows10, M365DSCRGUtil
  * Exponential performance improvements by reducing complexity and roundtrips.
  * Changed the logic that appends GUID in the resource name when primary key is not found during an
    export. We will only append a GUID if the IsSingleInstance property is not found on the resource.
  * Add check in AADGroupSettings for NewUnifiedGroupWritebackDefault not existing in Government by default
    FIXES [#5213](https://github.com/microsoft/Microsoft365DSC/issues/5213)
  * Fix static refrences to graph.microsoft.com
    FIXES [#5339](https://github.com/microsoft/Microsoft365DSC/issues/5339)
    AADNetworkAccessForwardingPolicy. AADOrganizationCertificateBasedAuthConfiguration,
    AADAuthenticationMethodPolicyExternal, AADEnrichedAuditLogs
    FIXES [#5340](https://github.com/microsoft/Microsoft365DSC/issues/5340)
    IntuneDeviceManagementEnrollmentAndroidGooglePlay, IntuneAppleMDMPushNotificationCertificate
  * Fixes static OData refrences to graph.microsoft.com
    AADApplication, AADEntitlementManagementAccessPackage, AADEntitlementManagementConnectedOrganization
    AADServicePrincipal
    FIXES [#5342](https://github.com/microsoft/Microsoft365DSC/issues/5342)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.24.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.199.
  * Updated MSCloudLoginAssistant to version 1.1.27
  * Updated MicrosoftTeams to version 6.6.0.

# 1.24.1016.1

* AADAdminConsentRequestPolicy
  * Initial release.
* AADApplication
  * Fixed an issue trying to retrieve the beta instance.
  * Added support for OnPremisesPublishing.
  * Added support for ApplicationTemplate.
  * Fixes an issue where trying to apply permissions complained about
    duplicate entries.
* AADAuthenticationRequirement
  * Initial release.
* AADConnectorGroupApplicationProxy
  * Initial release.
* AADCustomAuthenticationExtension
  * Initial release.
* AADCustomSecurityAttributeDefinition
  * Initial release.
* AADDeviceRegistrationPolicy
  * Initial release.
* AADEntitlementManagementSettings
  * Added support for ApplicationSecret
* AADIdentityGovernanceLifecycleWorkflow
  * Initial release.
* AADLifecycleWorkflowSettings
  * Initial release.
* AADServicePrincipal
  * Added Delegated Permission Classification Property
  * Added Custom Security Attributes Property
* ADOPermissionGroupSettings
  * Initial release.
* EXOATPBuiltInProtectionRule
  * Initial release.
* EXOMigrationEndpoint
  * Initial Release
* IntuneAccountProtectionPolicy
  * Added deprecation notice.
* IntuneAccountProtectionPolicyWindows10
  * Initial Release
    FIXES [#5073](https://github.com/microsoft/Microsoft365DSC/issues/5073)
* IntuneAppAndBrowserIsolationPolicyWindows10
  * Initial release.
    FIXES [#3028](https://github.com/microsoft/Microsoft365DSC/issues/3028)
* IntuneDerivedCredential
  * Initial release.
* IntuneDeviceConfigurationIdentityProtectionPolicyWindows10
  * Added deprecation notice.
* IntuneDeviceManagementEnrollmentAndroidGooglePlay
  * Initial release
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Migrate to new Settings Catalog cmdlets.
* IntuneMobileAppsMacOSLobApp
  * Initial release
* IntuneMobileAppsWindowsOfficeSuiteApp
  * Initial release
* IntuneSecurityBaselineMicrosoft365AppsForEnterprise
  * Initial release
* IntuneSecurityBaselineMicrosoftEdge
  * Initial release
* PPAdminDLPPolicy
  * Initial release.
* PPDLPPolicyConnectorConfigurations
  * Initial release.
* PPPowerAppPolicyUrlPatterns
  * Initial release.
* TeamsClientConfiguration
  * Fixed bug where RestrictedSenderList was always empty in the MSFT_TeamsClientConfiguration resource
    FIXES [#5190](https://github.com/microsoft/Microsoft365DSC/issues/5190)
  * Changed Set-TargetResource to always use semicolon as separator as mentioned in the MS documentation
* TeamsUpgradePolicy
  * Added support for tenant wide changes using the * value for users.
    FIXES [#5174](https://github.com/microsoft/Microsoft365DSC/issues/5174)
* TeamsGroupPolicyAssignments
  * FIXES [#5179](https://github.com/microsoft/Microsoft365DSC/issues/5179)
* M365DSCDRGUtil
  * Fixes an issue for the handling of skipped one-property elements in the
    Settings Catalog. FIXES [#5086](https://github.com/microsoft/Microsoft365DSC/issues/5086)
  * Add Set support for secret Settings Catalog values
  * Removed unused functions
  * Add support for device / user scoped settings.
* ResourceGenerator
  * Add support for device / user scoped settings.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.11
  * Updated ReverseDSC to version 2.0.0.21

# 1.24.1002.1

* AADAdministrativeUnit
  * Added support for property IsMemberManagementRestricted.
* AADApplication
  * Added AppRoles
  * Added AuthenticationBehavior
  * Added KeyCredentials
  * Added OptionalClaims
  * Added PasswordCredentials
  * Added PreAuthorizationApplications
* AADAuthenticationMethodPolicy
  * Added ReportSuspiciousActivitySettings
* AADAuthenticationMethodPolicyHardware
  * Initial release.
* AADEntitlementManagementSettings
  * Initial release.
* AADFeatureRolloutPolicy
  * Initial release
* AADGroup
  * Fixes issue with incorrect removal of assigned license(s)
    FIXES [#5128](https://github.com/microsoft/Microsoft365DSC/issues/5128)
  * Fixes logic to evaluate license assignments and disabled plans.
    FIXES [#5101](https://github.com/microsoft/Microsoft365DSC/issues/5101)
  * Fixes issue with code that is never executed
    FIXES [#5001](https://github.com/microsoft/Microsoft365DSC/issues/5001)
  * Adds support to assign Service Principal as members or owners.
    FIXES [#4972](https://github.com/microsoft/Microsoft365DSC/issues/4972)
* AADPasswordRuleSettings
  * Initial release
* ADOOrganizationOwner
  * Initial release.
* ADOPermissionGroup
  * Initial release.
* ADOSecurityPolicy
  * Initial release.
* AzureSubscription
  * Initial Release.
* DefenderSubscriptionDefenderPlan
  * Initial release.
* EXOAntiPhishPolicy
  * Use correct type integer for variable `PhishThresholdLevel`
* EXOArcConfig
  * Initial Release.
* EXOAuthenticationPolicy
  * If policy needs changes then recreate it to avoid issue with
    `Set-AuthenticationPolicy` cmdlet
    FIXES [#4819](https://github.com/microsoft/Microsoft365DSC/issues/4819)
* EXODnssecForVerifiedDomain
  * Initial Release.
* EXOEmailTenantSettings
  * Initial Release.
* EXOFocusedInbox
  * Initial Release.
* EXOMailboxCalendarConfiguration
  * Initial Release.
* EXOMailboxIRMAccess
  * Initial Release.
* EXOMailboxFolderPermission
  * Initial Release.
* EXOMailboxIRMAccess
  * Initial Release.
* EXOMailTips
  * Remove property `Ensure` since this resource is of type `IsSingleInstance`
* EXOManagementScope
  * Initial Release.
* EXORetentionPolicy
  * Initial Release.
* EXOPhishSimOverrideRule
  * Initial Release.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixes an issue with invalid parameter definition.
    FIXES [#5015](https://github.com/microsoft/Microsoft365DSC/issues/5015)
  * Fixes an issue where the `AccessTokens` parameter was not available.
    FIXES [#5121](https://github.com/microsoft/Microsoft365DSC/issues/5121)
* IntuneAppCategory
  * Initial release.
* IntuneAppProtectionPolicyiOS
  * Improve `TargetedAppManagementLevels` property to specify multiple values.
    FIXES [#5032](https://github.com/microsoft/Microsoft365DSC/issues/5032)
* IntuneDeviceCompliancePolicyWindows10
  * Fixes an issue where the property `ValidOperatingSystemBuildRanges` was
    not exported properly.
    FIXES [#5030](https://github.com/microsoft/Microsoft365DSC/issues/5030)
* IntuneDeviceConfigurationSharedMultiDevicePolicyWindows10
  * Add missing `AccessTokens` parameter to `Export-TargetResource`
    FIXES [#5034](https://github.com/microsoft/Microsoft365DSC/issues/5034)
* IntuneFirewallPolicyWindows10
  * Initial release
    FIXES [#3033](https://github.com/microsoft/Microsoft365DSC/issues/3033)
* IntuneSettingCatalogCustomPolicyWindows10
  * Update export logic to target more specific policy types.
  * Prevent thrown exception to be caught by exception handler.
    FIXES [#5088](https://github.com/microsoft/Microsoft365DSC/issues/5088)
* M365DSCDRGUtil
  * Add support for more complex Intune Settings Catalog properties
  * Update handling of `Update-IntuneDeviceConfigurationPolicy` to throw on error
    FIXES [#5055](https://github.com/microsoft/Microsoft365DSC/issues/5055)
* M365DSCResourceGenerator
  * Update Intune resource generation for the Settings Catalog.
* O365ExternalConnection
  * Initial release.
* SCDeviceConditionalAccessRule
  * Initial release.
* SCDeviceConfigurationRule
  * Initial release.
* SCInsiderRiskEntityList
  * Initial release.
* SCInsiderRiskPolicy
  * Initial release.
* SCRecordReviewNotificationTemplateConfig
  * Initial release.
* SCRoleGroup
  * Fixes an issue with creation without specifying Displayname
  * Fixes an issue with Drifts because of returned Role format
    FIXES [#5036](https://github.com/microsoft/Microsoft365DSC/issues/5036)
* SCAutoSensitivityLabelRule
  * Fixed issue with incorrectly applying HeaderMatchesPatterns, even when
    parameter wasn't specified.
    FIXES [#4641](https://github.com/microsoft/Microsoft365DSC/issues/4641)
* SCSensitivityLabel
  * Added support for Auto Labeling settings
    FIXES [#3784](https://github.com/microsoft/Microsoft365DSC/issues/3784)
* SentinelSetting
  * Initial release.
* SentinelWatchlist
  * Initial release.
* SPOAccessControlSettings
  * Added support for property EnableRestrictedAccessControl.
* M365DSCUtil
  * Fixes an issue where the O365Group workload was not properly detected.
    FIXES [#5095](https://github.com/microsoft/Microsoft365DSC/issues/5095)
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.10.
  * Updated Microsoft.Graph to version 2.23.0.
  * Added dependencies on Az.Accounts, Az.Resources, Az.ResourceGraph
    and Az.SecurityInsights.
  * Updated DSCParser to version 2.0.0.9.
  * Updated MSCloudLoginAssistant to version 1.1.25.
  * Added dependency on Microsoft.Graph.Beta.Search.
  * Removed unnecessary dependency PSDesiredStateConfiguration v1.1

# 1.24.904.1

* EXOOwaMailboxPolicy
  * Add support for AccountTransferEnabled parameter
* EXOSweepRule
  * Initial Release.
* FabricAdminTenantSettings
  * Initial Release.
* IntuneDeviceControlPolicyWindows10
  * Initial Release
* M365DSCDRGUtil
  * Fixes an issue where a Intune settings catalog DSC param was not handled
    correctly when it was not specified.
    FIXES [#5000](https://github.com/microsoft/Microsoft365DSC/issues/5000)
  * Fixes an issue where the exported nested CIM instances had too many line breaks.
  * Fixes an issue where Settings Catalog properties were not correctly handled.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.20.

# 1.24.828.1

* AADAdministrativeUnit
  * Fix Properties for Dynamic Administrative Units in Graph have moved
* AADConditionalAccessPolicy
  * Fixing issue where the resource crashed when trying to retrieve groups
    and users from Entra ID which no longer existed
  * Fixes an issue where the `AuthenticationFlows` property changed in Graph
    and updates on the documentation for the possible values of `TransferMethods`.
    FIXES [#4961](https://github.com/microsoft/Microsoft365DSC/issues/4961)
    FIXES [#4960](https://github.com/microsoft/Microsoft365DSC/issues/4960)
    FIXES [#4734](https://github.com/microsoft/Microsoft365DSC/issues/4734)
    FIXES [#4725](https://github.com/microsoft/Microsoft365DSC/issues/4725)
* AADGroup
  * FIXES [#4994](https://github.com/microsoft/Microsoft365DSC/issues/4994)
* EXOAuthenticationPolicyAssignment
  * Removes the 1000 user limit when exporting authentication policy assignments
    FIXES [#4956](https://github.com/microsoft/Microsoft365DSC/issues/4956)
* EXOHostedContentFilterRule
  * Don't check if associated `EXOHostedContentFilterPolicy` is present
    while removing resource since it's not required
 * EXORoleGroup
    * Fix an issue where roles that have empty members cannot be compared
   FIXES [#4977] (https://github.com/microsoft/Microsoft365DSC/issues/4977)
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Fixed issue if `PasswordComplexity` was set to 5 by allowing that value
    FIXES [#4963](https://github.com/microsoft/Microsoft365DSC/issues/4963)
* IntuneDeviceCompliancePolicyWindows10
  * Fix extraction of property `TpmRequired`
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Change app and delegated permissions for reading to
    DeviceManagementConfiguration.ReadWrite.All to cope with
    getOmaSettingPlainTextValue which is only working if RW is granted
    FIXES [#4412](https://github.com/microsoft/Microsoft365DSC/issues/4412)
* IntuneDeviceRemediation
  * Add export of global remediation scripts.
* O365OrgSettings
  * FIXES [#4741](https://github.com/microsoft/Microsoft365DSC/issues/4741)
* SCAutoSensitivityLabelPolicy
  * Fixes issue where Mode=Enabled is not supported for SP and OD. Changing
    property to TestWithoutNotifications in those instances.
    FIXES [#4990](https://github.com/microsoft/Microsoft365DSC/issues/4990)
* SCAutoSensitivityLabelRule
  * Fixes issue where the export was looping through all possible workloads
    instead of the actually targeted workload
    FIXES [#4989](https://github.com/microsoft/Microsoft365DSC/issues/4989)
* SCSensitivityLabel
  * Corrected issue where ExternalAccess properties were configured inverted
    FIXES [#3782](https://github.com/microsoft/Microsoft365DSC/issues/3782)
* M365DSCDRGUtil
  * Update Intune Settings Catalog Handling.
  * Fixes an issue where the `MSFT_IntuneDeviceRemediationPolicyAssignments`
    type would trigger an incorrect comparison in `Compare-M365DSCComplexObject`.
* M365DSCResourceGenerator
  * Update Intune resource generation for the Settings Catalog.
* M365DSCUtil
  * Fix `Compare-PSCustomObjectArrays` by allowing empty arrays as input
    FIXES [#4952](https://github.com/microsoft/Microsoft365DSC/issues/4952)
* MISC
  * Improve module updates and PowerShell Core support across the DSC
    resources.
    FIXES [#4941](https://github.com/microsoft/Microsoft365DSC/issues/4941)
  * Replace some `Write-Host` occurrences in core engine with
    appropriate alternatives.
    FIXES [#4943](https://github.com/microsoft/Microsoft365DSC/issues/4943)
  * Fixed a typo within M365DSCReport.psm1 related to a .png file
    FIXES [#4983](https://github.com/microsoft/Microsoft365DSC/pull/4983)
* DEPENDENCIES
  * Updated MicrosoftTeams to version 6.5.0.
  * Updated MSCloudLoginAssistant to version 1.1.19.

# 1.24.731.1

* AADAuthenticationMethodPolicyFido2
  * Add missing class identifier to schema.
    FIXES [#4900](https://github.com/microsoft/Microsoft365DSC/issues/4900)
    FIXES [#4079](https://github.com/microsoft/Microsoft365DSC/issues/4079)
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixes an issue where the template reference is not set correctly.
    FIXES [#4925](https://github.com/microsoft/Microsoft365DSC/issues/4925)
* IntuneDeviceConfigurationEndpointProtectionPolicyWindows10
  * Fix compiling if `ProfileTypes` (in `FirewallRules`) is present and contains
    more than one value
    FIXES [#4936](https://github.com/microsoft/Microsoft365DSC/issues/4936)
* IntuneDeviceConfigurationPolicyiOS
  * Fix export of property NetworkUsageRules
    FIXES [#4934](https://github.com/microsoft/Microsoft365DSC/issues/4934)
* MISC
  * M365DSCReport
    * Update key properties for delta report in `AADGroup` resource.
      FIXES [#4921](https://github.com/microsoft/Microsoft365DSC/issues/4921)

# 1.24.724.1

* IntuneAntivirusPolicyWindows10SettingCatalog
  * Migrate to new settings catalog cmdlets.
* IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager
  * Migrate to new settings catalog cmdlets.
    FIXES [#3966](https://github.com/microsoft/Microsoft365DSC/issues/3966)
* IntuneEndpointDetectionAndResponsePolicyLinux
  * Initial release.
* IntuneEndpointDetectionAndResponsePolicyMacOS
  * Initial release.
* IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10
  * Introduces new properties and updates the handling of the
    start and end dates.
    FIXES [#4614](https://github.com/microsoft/Microsoft365DSC/issues/4614)
    FIXES [#3438](https://github.com/microsoft/Microsoft365DSC/issues/3438)
* M365DSCDRGUtil
  * Fixes an issue where only 25 settings catalog templates were fetched with one call.
* SPOSharingSettings
  * Changed approach to MySite filtering.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.8.

# 1.24.717.1

* AADConditionalAccessPolicy
  * Made failures write to the error output instead of just verbose.
* EXOHostedOutboundSpamFilterPolicy
  * Changed the RecipientLimitInternalPerHour, RecipientLimitPerDay, and
    RecipientLimitExternalPerHour parameters to UInt32.
* EXOMessageClassification
  * Fix issue while creating policy for first time
    FIXES [#4877](https://github.com/microsoft/Microsoft365DSC/issues/4877)
* IntuneDeviceConfigurationEmailProfilePolicyWindows10
  * Fix export by fixing some typos and from where values are extracted
    FIXES [#3960](https://github.com/microsoft/Microsoft365DSC/issues/3960)
* IntuneDiskEncryptionWindows10
  * Initial Release
    FIXES [#4050](https://github.com/microsoft/Microsoft365DSC/issues/4050)
* IntuneWindowsUpdateForBusinessQualityUpdateProfileWindows10
  * Initial release.
    FIXES [#2659](https://github.com/microsoft/Microsoft365DSC/issues/2659)
* SPOSharingSettings
  * Improved performance by using -Filter on Get-PnPTenantSite calls.
* M365DSCDRGUtil
  * Fixes an issue with nested and duplicate settings in the settings catalog
  * Add support for converting Intune assignments directly from Graph.
    FIXES [#4875](https://github.com/microsoft/Microsoft365DSC/issues/4875)
* M365DSCResourceGenerator
  * Update Intune resource generation.
* M365DSCReport
  * Changes behaviour to not throw on empty configuration during report generation.
    FIXES [#4559](https://github.com/microsoft/Microsoft365DSC/issues/4559)
    FIXES [#4505](https://github.com/microsoft/Microsoft365DSC/issues/4505)
  * Fixes an issue where the comparison treats empty arrays as an empty string.
    FIXES [#4796](https://github.com/microsoft/Microsoft365DSC/issues/4796)
* Telemetry
  * Added info about operation total execution time.

# 1.24.710.3

* MISC
  * Fixes issue with App Secret Authentication flow.

# 1.24.710.2

* Telemetry
  * Fixed error handling on getting roles.

# 1.24.710.1

* AADApplication
  * Fixes an error where the duplicate error was being trapped,
    which could cause extra instances to be created.
* AADGroup
  * Fixes an error where the duplicate error was being trapped,
    which could cause extra instances to be created.
* EXOAntiPhishRule
  * Don't check if associated `EXOAntiPhishPolicy` is present while removing
    resource since it's not required
    FIXES [#4846](https://github.com/microsoft/Microsoft365DSC/issues/4846)
* EXOHostedOutboundSpamFilterRule
  * Don't check if associated `EXOHostedOutboundSpamFilterPolicy` is present
    while removing resource since it's not required
    FIXES [#4847](https://github.com/microsoft/Microsoft365DSC/issues/4847)
* IntuneDeviceConfigurationPlatformScriptMacOS
  * Fixes an issue where the assignments are missing if filtered by display name.
* M365DSCDRGUtil
  * Fixes an issue where the return value was changed to a single object
    instead of an array.
    FIXES [#4844](https://github.com/microsoft/Microsoft365DSC/issues/4844)
  * Fixes an issue where Graph models were not treated properly as a complex object.
* TELEMETRY
  * Added instance count.
  * Added roles scopes info.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.7.
  * Updated Microsoft.Graph to version 2.20.0
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.191

# 1.24.703.1

* EXOCASMailboxPlan
  * Remove `DisplayName` from set parameters
    FIXES [#4814](https://github.com/microsoft/Microsoft365DSC/issues/4814)
* EXODkimSigningConfig
  * Add support for 2048 key size;
  * Remove authentication parameters before changing the resources
    FIXES [#4821](https://github.com/microsoft/Microsoft365DSC/issues/4821)
  FIXES [#4805](https://github.com/microsoft/Microsoft365DSC/issues/4805)
* EXOGroupSettings
  * Export unlimited number of groups
    FIXES [#4800](https://github.com/microsoft/Microsoft365DSC/issues/4800)
* EXOHostedContentFilterRule
  * When updating the resource assign property `Identity` to the correct value
    FIXES [#4836](https://github.com/microsoft/Microsoft365DSC/issues/4836)
* EXOMailboxPlan
  * Remove `DisplayName` from set parameters
    FIXES [#4817](https://github.com/microsoft/Microsoft365DSC/issues/4817)
* EXOHostedOutboundSpamFilterRule
  * Fix `if` clause on update scenario, remove property `Enabled` from being set
    while updating the resource and ensure that also while updating the resource
    the property `HostedOutboundSpamFilterPolicy` is only sent if it differs
    from what the resource already has currently assigned
    FIXES [#4838](https://github.com/microsoft/Microsoft365DSC/issues/4838)
* IntuneExploitProtectionPolicyWindows10SettingCatalog
  * Migrate to new settings catalog cmdlets.
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Migrate to new settings catalog cmdlets.
* TeamsFederationConfiguration
  * Add missing property `ExternalAccessWithTrialTenants`
    FIXES [#4829](https://github.com/microsoft/Microsoft365DSC/issues/4829)
* M365DSCDRGUtil
  * Added Microsoft Graph filter functions.
  * Force array as parameter in `Compare-M365DSCIntunePolicyAssignment`.
  * Fixed an issue when comparing Intune policy assignments.
    FIXES [#4830](https://github.com/microsoft/Microsoft365DSC/issues/4830)
  * Fixed an issue when comparing complex objects where the key to compare is available as a
    instance property on the class.
* MISC
  * Added support for `startswith`, `endswith` and `contains` filter methods to Intune resources
    that did not support it previously.
    FIXES [#4597](https://github.com/microsoft/Microsoft365DSC/issues/4597)
  * Fixes issues with values of type `groupSettingCollection` and `choiceSetting`
    when creating the settings catalog policy settings body.
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.6

# 1.24.626.1

* AADGroup
  * FIXES [#4782](https://github.com/microsoft/Microsoft365DSC/issues/4782)
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Migrate to new settings catalog cmdlets.
* M365DSCDRGUtil
  * Fixes an issue with the settings catalog property generation.
  * Add `collectionId` export to `ConvertFrom-IntunePolicyAssignment`
  * Add handling for Intune assignments in `Compare-M365DSCComplexObject`
  * Fix issue with target handling in `Update-DeviceConfigurationPolicyAssignment`
* M365DSCUtil
  * Fixes an issue where the comparison with null-valued desired value throws an error.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.18
* M365DSCResourceGenerator
  * Update CimInstance comparison template
* MISC
  * Add group display name export and update assignment comparison across Intune
    resources.

# 1.24.619.1

* SCDLPComplianceRule
  * Fix #4259 and #3845
* TeamsM365App
  * Initial release.
* DEPENDENCIES
  * Updated MicrosoftTeams to version 6.4.0.
* MISC
  * Improved telemetry around Export sizes.

# 1.24.612.1

* IntuneAppConfigurationDevicePolicy
  * Add conversion from `payloadJson` to actual JSON.
* SPOTenantSettings
  * Connect to Graph before Sharepoint Online.
    FIXES [#4746](https://github.com/microsoft/Microsoft365DSC/issues/4746)
* TeamsMeetingPolicy
  * Updated the allowed values for the TeamsCameraFarEndTPTXZmode property.
* M365DSCResourceGenerator
  * Fix formatting and missing escape character in Resource Generator.

# 1.24.605.1

* AADAuthenticationFlowPolicy
  * Initial Release.
* AADEntitlementManagementRoleAssignment
  * Initial Release.
* IntuneAppConfigurationDevicePolicy
  * Add assignment group display name and fix compilation
    FIXES [#4724](https://github.com/microsoft/Microsoft365DSC/issues/4724)
* M365DSCResourceGenerator
  * Add support for generating Intune settings catalog policies.
* M365DSCDRGUtil
  * Add multiple commands for Intune policies that use the settings catalog.
  * Improve comparison of Intune assignments in `Compare-M365DSCIntunePolicyAssignment`
* TeamsMeetingPolicy
  * Updated the allowed values for the TeamsCameraFarEndTPTXZmode property.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.17.
  * Updated ReverseDSC to version 2.0.0.20.

# 1.24.529.1

* AADAdministrativeUnit
  * Implemented advanced query based on
    https://learn.microsoft.com/en-us/graph/aad-advanced-queries?tabs=http#administrative-unit-properties
* AADAuthenticationMethodPolicy
  * Add support for disabled policies
* AADConditionalAccessPolicy
  * Fix get method if value is null instead of false
* IntuneAppConfigurationDevicePolicy
  * Initial release
* IntuneDeviceRemediation
  * Added support for Access Tokens
* IntuneDiskEncryptionMacOS
  * Initial Release
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Add missing properties
    FIXES [#4713](https://github.com/microsoft/Microsoft365DSC/issues/4713)
* O365AdminAuditLogConfig
  * Fix logging of exception if Set-AdminAuditLogConfig fails
    FIXES [#4645](https://github.com/microsoft/Microsoft365DSC/issues/4645)
* ResourceGenerator
  * Added `AccessTokens` parameter to PS1 and MOF template
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.5.
  * Rolling back ExchangeOnlineManagement to version 3.4.0.

# 1.24.522.1

* IntuneDeviceConfigurationPlatformScriptWindows
  * Initial Release
    FIXES [#4157](https://github.com/microsoft/Microsoft365DSC/issues/4157)
* IntuneDeviceConfigurationPlatformScriptMacOS
  * Initial Release
    FIXES [#4157](https://github.com/microsoft/Microsoft365DSC/issues/4157)
* IntuneDeviceEnrollmentPlatformRestriction
  * Fix missing export of the default policy
    FIXES [#4694](https://github.com/microsoft/Microsoft365DSC/issues/4694)
* IntuneDeviceEnrollmentStatusPageWindows10
  * Return all authentication methods when retrieving the policies otherwise
    it may fail deducing the OrganizationName via TenantId
* IntuneDeviceRemediation
  * Initial Release
    FIXES [#4159](https://github.com/microsoft/Microsoft365DSC/issues/4159)
* IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10
  * Initial Release
    FIXES [#3747](https://github.com/microsoft/Microsoft365DSC/issues/3747)
* SPOTenantCdnPolicy
  * If properties in the tenant are empty then export them as empty arrays
    instead of null strings, missed while fixing #4658
* SPOTenantSettings
  * Remove property UserVoiceForFeedbackEnabled when setting the resource since
    it has been deprecated
* M365DSCUtil
  * Fixed an issue in `Assert-M365DSCBlueprint` where the clone and export
    of a blueprint with a GUID could lead to configuration name starting
    with a digit instead of a letter.
    Partially fixes [#4681](https://github.com/microsoft/Microsoft365DSC/issues/4681)
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.5.0
  * Updated MicrosoftTeams to version 6.2.0

# 1.24.515.2

* EXOManagementRoleEntry
  * Added support for the WebSite type.

# 1.24.515.1

* AADActivityBasedTimeoutPolicy
  * Initial release, set the azure portal and default Timeout.
* AADGroup
  * Fixes #4596
* AADConditionalAccessPolicy
  * Fix ExcludeGuestOrExternalUserTypes and IncludeGuestOrExternalUserTypes parameters
    FIXES [#4630]
  * Added support for Authentication Flow TransferMethod
    FIXES [#4472]
* AADGroupSettings
  * Added support for parameter NewUnifiedGroupWritebackDefault
* EXOManagementRoleEntry
  * Initial Rrelease
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Add missing properties from templates
  * Update setting handling so that the value is reverted to default when unset
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Fixed an issue where the payload of xml files was not encoded as base64.
* IntuneDeviceConfigurationDefenderForEndpointOnboardingPolicyWindows10
  * Fixed a creation and update issue when the exported policy contains a
    onboarding blob and the tenant is connected to Defender for Endpoint Service.
* SCAutoSensitivityLabelPolicy
  * Fix incorrect mandatory Credential parameter in Set and Test methods
    FIXES [#4283](https://github.com/microsoft/Microsoft365DSC/issues/4283)
* SPOSharingSettings
  * Remove properties from being tested in certain conditions
    FIXES [#4649](https://github.com/microsoft/Microsoft365DSC/issues/4649)
  * Changed logic to retrieve my site for sovereign clouds.
* SPOTenantCdnPolicy
  * Fixed an issue when both IncludeFileExtensions and
    ExcludeRestrictedSiteClassifications needed to be changed but the latter got
    the value of the former instead of the correct one
    FIXES [#4658](https://github.com/microsoft/Microsoft365DSC/issues/4658)
* TeamsAudioConferencingPolicy
  * Fix export and creation/set of this resource by converting a string array
    into a comma-separated string and a comma-separated string into a string
    array respectively
    FIXES [#4655](https://github.com/microsoft/Microsoft365DSC/issues/4655)
* TeamsMeetingPolicy
  * Fix creation and set of resource when cloud recording is set to false (off)
    FIXES [#4653](https://github.com/microsoft/Microsoft365DSC/issues/4653)
  * Fixed issue with property MeetingChatEnabledType by allowing the value
    EnabledExceptAnonymous to be selected
    FIXES [#4667](https://github.com/microsoft/Microsoft365DSC/issues/4667)
* TeamsGroupPolicyAssignment
  * Add missing policy type TeamsVerticalPackagePolicy
    FIXES [#4647](https://github.com/microsoft/Microsoft365DSC/issues/4647)
* TeamsUpdateManagementPolicy
  * Remove unnecessary parameters from PSBoundParameters such as authentication
    methods, Ensure and Verbose by calling Remove-M365DSCAuthenticationParameter
    FIXES [#4651](https://github.com/microsoft/Microsoft365DSC/issues/4651)
* M365DSCUtil
  * Fixed an issue where one could not pass empty arrays to the
    `Compare-PSCustomObjectArrays` function.
  * Fixed an issue with how the ResourceInstanceName was being assigned for
    resource SPOTenantCdnPolicy by adding its primary key CDNType to the
    heuristics
    FIXES [#4658](https://github.com/microsoft/Microsoft365DSC/issues/4658)
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.4.
  * Updated Microsoft.Graph to version 2.19.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.187.
* MISC
  * Added support for Access Tokens across AAD resources.
  * Added support for Access Tokens across SC resources.
  * Added support for Access Tokens across SPO resources.
  * Added support for Access Tokens across Teams resources.
  * Fixing fake passwords in Unit Tests.
  * Added ability to configure Telemetry client by ConnectionString.

# 1.24.424.1

* EXORecipientPermission
  * Ensures we only return 1 Trustee per entry.
* EXOManagementRoleAssignment
  * Removed logic to use Graph for Adminitrative Unit.
* IntuneDeviceConfigurationDefenderForEndpointOnboardingPolicyWindows10
  * Fixed a comparison issue when Defender for Endpoint is connected to Intune and the
    onboarding blob is generated by the Defender for Endpoint service.
* IntuneDeviceConfigurationPolicyMacOS
  * Fixed an issue where the update policy setting was not handled properly.
* IntuneDeviceConfigurationWiredNetworkPolicyWindows10
  * Added functionality for specifying the certificates with a display name since their
    ids in the blueprint might be from a different source tenant.
    FIXES [#4582](https://github.com/microsoft/Microsoft365DSC/issues/4582)
* MISC
  * Added support for AccessTokens in EXO resources.
  * Updated MSCloudLoginAssistant dependencies to version 1.1.16.
  * Added Filter support to Intune resources.

# 1.24.417.1

* AADAdministrativeUnit
  * Fixed an issue when assigning a directory role which is not yet enabled.
  * Fixed a potential issue if the total directory roles increases in future.
* AADConditionalAccessPolicy
  * Fixed a potential issue if the total directory roles increases in future.
* AADGroup
  * Fixed a potential issue if the total directory roles increases in future.
* AADAdministrativeUnit, AADApplication,
  AADEntitlementManagementConnectedOrganization, AADGroup, AADUser
  * Replace old cmdlet and deprecated Remove-Mg\*ByRef with equivalent
    Remove-Mg\*DirectoryObjectByRef which is available in Graph 2.17.0
* AADRoleEligibilitySecheduleRquest
  * Cleaned Export logic.
* EXOActiveSyncDeviceAccessRule
  * Retrieve instance by Identity if not found by characteristic.
* EXOMailboxSettings
  * Simplifyied the Setlogic and removed Timezone validation to remove checks
    to regstry key which caused issues in Linux.
* M365DSCRuleEvaluation
  * Changed logic to retrieve resource information.
* SCRoleGroup
  * Initial Release.
* SCRoleGroupMember
  * Initial Release.
* SPOTenantSettings
  * Add property TenantDefaultTimezone
    Implements [#4189](https://github.com/microsoft/Microsoft365DSC/issues/4189)
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 2.17.0.
  * Updated MSCloudLoginAssistant dependencies to version 1.1.15.
  * Updated MicrosoftTeams to version 6.1.0.
* MISC
  * Provided the ability to force reload the EXO or SC modules to prevent
    calling the wrong cmdlet where the same names are defined (e.g. Get-RoleGroup).
  * Telemetry
    * Get operating system using faster method to speed up telemetry calls.

# 1.24.403.1

* AADAdministrativeUnit
  * Fix issue with deploying/creating a new AU with members and/or adding members
    to an existing AU
    FIXES [#4404](https://github.com/microsoft/Microsoft365DSC/issues/4404)
  * Updated examples to include setting Visibility and ScopedRoleMembers
  * Fix issue with Set-TargetResource was failing to apply when Verbose is set
    FIXES [#4497](https://github.com/microsoft/Microsoft365DSC/issues/4497)
* All resources
  * Fix issue where Ensure cannot be left as default 'Present'
* AADAdministrativeUnit
  * Fix issue with omitted Ensure and/or Id
    FIXES [#4437](https://github.com/microsoft/Microsoft365DSC/issues/4437)
* AADConditionalAccessPolicy
  * Fixed schema file
* EXOCalendarProcessing
  * Fixed schema file
* EXOGroupSettings
  * Fixed schema file
* EXOMailTips
  * [BREAKING CHANGE] Replaced the Organization parameter with IsSingleInstance
    FIXES [#4117](https://github.com/microsoft/Microsoft365DSC/issues/4117)
* EXOMessageClassification
  * Fixed schema file
* EXOOMEConfiguration
  * Fixed schema file
* EXOTransportRule
  * [BREAKING CHANGE] Change data type of Priority from String to Int
    FIXES [[#4136](https://github.com/microsoft/Microsoft365DSC/issues/4136)]
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Add missing properties
* IntuneAppConfigurationPolicy
  * Fix comparison in Test-TargetResource
    FIXES [#4451](https://github.com/microsoft/Microsoft365DSC/issues/4451)
* IntuneDeviceCompliancePolicyWindows10
  * Fix group assignment by using the corrected function
    Update-DeviceConfigurationPolicyAssignment from module M365DSCDRGUtil
    FIXES [#4467](https://github.com/microsoft/Microsoft365DSC/issues/4467)
* IntuneDeviceEnrollmentPlatformRestriction
  * Fixed an issue where nested settings would throw a conflict
    FIXES [#4082](https://github.com/microsoft/Microsoft365DSC/issues/4082)
* IntuneDeviceEnrollmentStatusPageWindows10
  * Added support for specifying SelectedMobileAppNames in addition to SelectedMobileAppIds,
    which are different for each tenant.
    FIXES [#4494](https://github.com/microsoft/Microsoft365DSC/issues/4494)
* M365DSCRuleEvaluation
  * Log both matching and not matching resources and in XML format
* O365OrgSettings
  * Fixed missing permissions in settings.json
* SCRoleGroupMember
  * Initial release
* SPOAccessControlSettings
  * [BREAKING CHANGE] Removed CommentsOnSitePagesDisabled parameter, because of
    duplication in SPOTenantSettings
    FIXES [#3576](https://github.com/microsoft/Microsoft365DSC/issues/3576)
  * [BREAKING CHANGE] Moved SocialBarOnSitePagesDisabled parameter to SPOTenantSettings,
    because it makes more sense there. This has nothing to do with Access Control.
* SPOTenantSettings
  * [BREAKING CHANGE] Removed ConditionalAccessPolicy parameter, because of
    duplication in SPOAccessControlSettings
    FIXES [#3576](https://github.com/microsoft/Microsoft365DSC/issues/3576)
  * Added SocialBarOnSitePagesDisabled parameter, moved from SPOAccessControlSettings.
  * Added EnableAIPIntegration.
* TeamsChannelTab
  * Fixed schema file
* TeamsComplianceRecordingPolicy
  * FIXES [[#3712](https://github.com/microsoft/Microsoft365DSC/issues/3712)]
* TeamsGroupPolicyAssignment
  * Skip assignments that have orphaned/deleted groups or without display name
    instead of throwing an error
    FIXES [#4407](https://github.com/microsoft/Microsoft365DSC/issues/4407)
* TeamsTenantDialPlan
  * Fix output of property NormalizationRules as a string to the blueprint
    FIXES [#4428](https://github.com/microsoft/Microsoft365DSC/issues/4428)
  * Fix creation, update and deletion of resource
* TeamsUpdateManagementPolicy
  * Adds support for the NewTeamsOnly value or the UseNewTeamsClient property.
    FIXES [#4496](https://github.com/microsoft/Microsoft365DSC/issues/4496)
* DEPENDENCIES
  * Updated DSCParser to version 2.0.0.3.
* MISC
  * Initial release of Get-M365DSCEvaluationRulesForConfiguration
  * M365DSCDRGUtil
    Fix Update-DeviceConfigurationPolicyAssignment so that if the group cannot
    be found by its Id it tries to search it by display name
    FIXES [#4467](https://github.com/microsoft/Microsoft365DSC/issues/4467)
  * M365DSCReport
    Fix issue when asserting resources not covered by current conditions in
    Get-M365DSCResourceKey by always returning all their mandatory parameters
    FIXES [#4502](https://github.com/microsoft/Microsoft365DSC/issues/4502)
  * Fix broken links to integration tests in README.md
  * Changing logic to retrieve DSC Resources properties not to use DSC
    specific cmdlets.

# 1.24.313.1

* AADAuthenticationStrengthPolicy
  * Removed the Id paremeter from being checked in the Test-TargetResource.
* AADGroup
  * Fixed issue when filtering groups by display name
    FIXES [#4394](https://github.com/microsoft/Microsoft365DSC/issues/4394)
  * Fixed issue where group owners were removed from existing groups when unspecified in the config
    FIXES [#4390](https://github.com/microsoft/Microsoft365DSC/issues/4390)
* EXOAcceptedDomain
  * Update regular expression to support domains with digits
    FIXES [#4446](https://github.com/microsoft/Microsoft365DSC/issues/4446)
* EXOHostedContentFilterPolicy
  * Add support for IntraOrgFilterState parameter
  FIXES [#4424](https://github.com/microsoft/Microsoft365DSC/issues/4424)
* EXOHostedContentFilterRule
  * Fixed issue in case of different names of filter rule and filter policy
  FIXES [#4401](https://github.com/microsoft/Microsoft365DSC/issues/4401)
* EXOIntraOrganizationConnector
  * Fixed issue with TargetSharingEpr
    FIXES [#4381](https://github.com/microsoft/Microsoft365DSC/issues/4381)
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneAccountProtectionPolicy
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneAppConfigurationPolicy
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneApplicationControlPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneASRRulesPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyAndroid
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyAndroidWorkProfile
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyiOs
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyMacOS
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceCompliancePolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationDefenderForEndpointOnboardingPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationDomainJoinPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationEmailProfilePolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
* IntuneDeviceConfigurationEndpointProtectionPolicyWindows10
  * Added support for assignment GroupDisplayName and improve error handling from
    Get-TargetResource
  * Fixed an issue with the parameter InterfaceTypes from firewallrules defined
    as a string instead of string[]
* IntuneDeviceConfigurationSCEPCertificatePolicyWindows10
  * Add property RootCertificateDisplayName in order to support assigning root
    certificates by display name since their Ids in a blueprint might be from a
    different source tenant
    FIXES [#3965](https://github.com/microsoft/Microsoft365DSC/issues/3965)
* IntuneDeviceConfigurationPolicyAndroidDeviceAdministrator
  * Fixed policy assignment retrieval when Id is from other tenant, bogus or
    null
    FIXES [#3970](https://github.com/microsoft/Microsoft365DSC/issues/3970)
* IntuneDeviceConfigurationPolicyAndroidOpenSourceProject
  * Fixed policy assignment retrieval when Id is from other tenant, bogus or
    null
    FIXES [#3971](https://github.com/microsoft/Microsoft365DSC/issues/3971)
  * Fixed compare logic for CIM instances in Test-TargetResource
* IntuneWindowsUpdateForBusinessQualityUpdateProfileWindows10
  * Fixed an issue with parsing the returned DateTime value object.
* M365DSCRuleEvaluation
  * Fix issue when it didn't find any matching resources and it tried to make a
    comparison
* O365OrgSettings
  * Add read permission for extracting M365 apps installation settings instead
    of extracting them only with read/write permissions
    FIXES [#4418](https://github.com/microsoft/Microsoft365DSC/issues/4418)
* TeamsTeam
  * Add error handling for teams without displayname during export
  FIXES [#4406](https://github.com/microsoft/Microsoft365DSC/issues/4406)
* TeamsVoiceRoute
  * Fix policy removal and also comparison in Test-TargetResource
* DEPENDENCIES
  * Updated DSCParser to version 1.4.0.4.
  * Updated Microsoft.Graph to version 2.15.0.
  * Updated MicrosoftTeams to version 6.0.0.
* MISC
  * Enhancement to obfuscate password from verbose logging and avoid empty lines
    FIXES [#4392](https://github.com/microsoft/Microsoft365DSC/issues/4392)
  * Fix example in documentation for Update-M365DSCAzureAdApplication
  * Added support for groupDisplayName to all devices and all users groups

# 1.24.228.1

* AADApplication
  * Show current values of resource in Test-TargetResource
* AADAuthorizationPolicy
  * Show current values of resource in Test-TargetResource
* AADConditionalAccessPolicy
  * Improved verbose logging to show that items are being skipped.
  * Show current values of resource in Test-TargetResource
* AADExternalIdentityPolicy
  * Show current values of resource in Test-TargetResource
* AADGroup
  * Fixed issue with single quotes in the display name.
    FIXES [#4358](https://github.com/microsoft/Microsoft365DSC/issues/4358)
  * Show current values of resource in Test-TargetResource
* AADGroupLifecyclePolicy
  * Show current values of resource in Test-TargetResource
* AADGroupsNamingPolicy
  * Show current values of resource in Test-TargetResource
* AADGroupsSettings
  * Show current values of resource in Test-TargetResource
* AADNamedLocationPolicy
  * Show current values of resource in Test-TargetResource
* AADRoleDefinition
  * Show current values of resource in Test-TargetResource
* AADRoleSetting
  * Show current values of resource in Test-TargetResource
* AADSecurityDefaults
  * Show current values of resource in Test-TargetResource
* AADServicePrincipal
  * Show current values of resource in Test-TargetResource
* AADTenantDetails
  * Show current values of resource in Test-TargetResource
* AADTokenLifetimePolicy
  * Show current values of resource in Test-TargetResource
* EXOActiveSyncDeviceAccessRule
  * Remove extra property GUID that is stopping EXO integration tests from
    running
* IntuneDeviceConfigurationScepCertificatePolicyWindows10
  * Fixes an issue where the keyUsage property format was not correctly handled
* IntuneExploitProtectionPolicyWindows10SettingCatalog
  * Fix update and removal of resource when Identity is from another tenant
    FIXES [#3962](https://github.com/microsoft/Microsoft365DSC/issues/3962)
* SPOAccessControlSettings
  * Added support for the ConditionalAccessPolicy parameter based on the PNP Module
* Teams resources
  * Updated required application permissions to support [Application Based Authentication](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-application-authentication)
* TeamsCallQueue
  * Reduce the number of Calls for Export using new cache pattern
    FIXES [[#4191](https://github.com/microsoft/Microsoft365DSC/issues/4192)]
* TeamsGuestMeetingConfiguration
  * Added the missing parameter AllowTranscription.
    FIXES [#4363](https://github.com/microsoft/Microsoft365DSC/issues/4363)
* TeamsTeam
  * Corrected Parameters for Graph Commands when creating a new Team
    FIXES [#4383](https://github.com/microsoft/Microsoft365DSC/issues/4383)
* MISC
  * M365DSCDRGUtil
    Add new parameter for customizable assignment identifier
  * M365DSCUtil
    Change heuristics on how to find the mandatory key of the resources to
    include them as part of the ResourceInstanceName during their export
    FIXES [#4333](https://github.com/microsoft/Microsoft365DSC/issues/4333)

# 1.24.221.1

* AADApplication
  * Expose the description field in the resource.
* AADConditionalAccessPolicy
  * Fixing issue where Membership kinds no longer accepted empty values.
    ROLLING BACK [#4344](https://github.com/microsoft/Microsoft365DSC/issues/4344)
    FIXES [#4347](https://github.com/microsoft/Microsoft365DSC/issues/4347)
  * Throws an error if role, user or group was not found in the Set method.
    FIXES [#4342](https://github.com/microsoft/Microsoft365DSC/issues/4342)
* EXOAuthenticationPolicyAssignment
  * Improved performance by using a filter to retrieve assignments.
  * Export now retrieves the user principal name instead of the user id.
* EXOAvailabilityConfig
  * Export now retrieves the user principal name instead of the user id.
* EXOCASMailboxPlan
  * Added the DisplayName property.
* EXODataClassification
  * Added logic to retrieve by name in the GET method if no match found by id.
* EXOMailboxAutoReplyConfiguration
  * Added the owner property.
* EXOMailboxPlan
  * Added the DisplayName property.
* EXOMailboxSettings
  * Export now retrieves instances by User Principal Name instead of GUID.
* EXOPlace
  * Added the DisplayName property.
* EXORecipientPermission
  * Export now retrieves instances by User Principal Name instead of GUID.
* EXOSharedMailbox
  * Added the Identity parameter.
* MISC
  * Uninstall-M365DSCOutdatedDependencies
    * Outdated Microsoft365DSC-modules are now removed in their entirety

# 1.24.214.3

* AADAuthenticationMethodPolicy
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyAuthenticator
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyEmail
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyFido2
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicySms
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicySoftware
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyTemporary
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyVoice
  * Fixed an error where the Export method would loop through the response header.
* AADAuthenticationMethodPolicyX509
  * Fixed an error where the Export method would loop through the response header.
* IntuneAppConfigurationPolicy
  * Fixed an error in the export on the Settings property.
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fixed an error where the Export method would loop through the response header.
* IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Fixed an error where the Export method would loop through the response header.
* SCDLPComplianceRule
  * Fixed the NotifyEmailCustomText and NotifyPolicyTipCustomText to escape fancy
    quotes.
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.14.1.

# 1.24.214.2

* AADConditionalAccessPolicy
  * Removed invalid empty string value that was added to the validate set
    of two parameters.
  * Updated permission reference for app-only authentication.
    FIXES [#3329](https://github.com/microsoft/Microsoft365DSC/issues/3329)
* AADRoleEligibilityScheduleRequest
  * Fixed an issue where an error was thrown if no requests were found instead
    of simply returning the Null object.
* AADRoleSetting
  * Fix handling of DisplayName property in comparison
    FIXES [#4019](https://github.com/microsoft/Microsoft365DSC/issues/4019)
* AADUser
  * Fixed and issue where an user would be created even if the resource was set
    to absent.
    FIXES [#4265](https://github.com/microsoft/Microsoft365DSC/issues/4265)
* EXOMobileDeviceMailboxPolicy
  * Fixes an issue where an empty MinPasswordLength value was always passed down
    to the update logic flow.
* IntuneAppConfigurationPolicy
  * Added parameter Id to avoid having to retrieve the same policy multiple
    times
  * Fixed tests in Test-TargetResource to ensure the resource reports its
    correct state
    FIXES [#3542](https://github.com/microsoft/Microsoft365DSC/issues/3542)
* IntuneDeviceAndAppManagementAssignmentFilter
  * Fixed Test-TargetResource to ensure that resource reports its correct state
    FIXES [#3959](https://github.com/microsoft/Microsoft365DSC/issues/3959)
* IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10
  * Fixed Test-TargetResource by removing Id from being tested and also used
    correct filter while retrieving the policy otherwise it could not be found
    FIXES [#3964](https://github.com/microsoft/Microsoft365DSC/issues/3964)
* IntuneDeviceConfigurationPolicyAndroidWorkProfile
  * Fix typo in variable which made it export incorrectly and report that
    resource was not in correct state due to testing an incorrect value
    FIXES [#3972](https://github.com/microsoft/Microsoft365DSC/issues/3972)
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Fix removal of resource if Identity comes from another tenant or is not
    present in blueprint
  * Fix Test-TargetResource by not comparing Identity since it might be from
    another tenant or not present in blueprint
  FIXES [#4302](https://github.com/microsoft/Microsoft365DSC/issues/4302)
* SCDPLPCompianceRule
  * Added support for multiple additional parameters.
* SPOSharingSettings
  * Fixed an issue where the resource would return multiple sites.
    FIXES [#2759](https://github.com/microsoft/Microsoft365DSC/issues/2759)
* DEPENDENCIES
  * Updated DSCParser to version 1.4.0.2.
  * Updated Microsoft.Graph dependencies to version 2.13.1.
  * Updated MSCloudLoginAssistant to version 1.1.13.
* MISC
  * M365DSCReport
    * Fix nested change detection for CIMInstances
    * Fix IntuneDeviceEnrolllmentPlatformRestriction comparison in report
      FIXES [#4291](https://github.com/microsoft/Microsoft365DSC/issues/4291)
  * Added new QA test to check for missing description in resource schema
  * Added new QA test to check for falsely assigned write-premissions in settings.json

# 1.24.207.2

* TeamsAppSetupPolicy
  * Changed the logic to retrieve arrays of Ids in the Get method.
* MISC
  * Drift Logging
    * Now includes the full list of parameters for the current values.
  * Telemetry
    * Added a new M365DSCTelemetryEventId parameter to track duplication of events.

# 1.24.207.1

* IntuneDeviceEnrollmentPlatformRestriction
  * Added Priority parameter
    FIXES [#4081](https://github.com/microsoft/Microsoft365DSC/issues/4081)
* SCDLPComplianceRule
  * Properly escapes fancy quotes in the Get method.
* TeamsMeetingPolicy
  * Ignore the AllowUserToJoinExternalMeeting  parameter for drift evaluation
    since it doesn't do anything based on official documentation.
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.180.
  * Updated MSCloudLoginAssistant to version 1.1.11
  * Updated ReverseDSC to version 2.0.0.19

# 1.24.131.2

* TeamsMeetingPolicy
  * Fixed issue with missing ManagedIdentity parameter in Test signature.
* TeamsUpdateManagementPolicy
  * Fixed issue with missing ManagedIdentity parameter in Set signature.

# 1.24.131.1

* EXOAvailabilityAddressSpace
  * Added support for the TargetServiceEpr and TargetTenantId parameters.
  * Fixed the logic to retrieve existing instance by Forest Name.
* EXODistributionGroup
  * The Get function now retrieves the ModeratedBy and ManagedBy properties
    by the users' UPN instead of their GUID.
* EXOHostedContentFilterRule
  * Changed logic to retrieve the Rules by name. Using the Policy's name instead.
* EXOIntraOrganizationConnector
  * Fixes the DiscoveryEndpoint value from the Get method to include trailing
    forward slash.
* EXOMalwareFilterRule
  * Fixed an issue retrieving the right value for the Enabled property
* EXOOMEConfiguration
  * Fixes an error in the Get method where the ExternalMailExpiryInDays property
    wasn't properly returned.
* EXOSafeLinksPolicy
  * Deprecated the UseTranslatedNotificationText property
* IntuneDeviceConfigurationPolicyAndroidOpenSourceProject,
  IntuneExploitProtectionPolicyWindows10SettingCatalog, IntuneRoleAssignment,
  IntuneRoleDefinition, IntuneSettingCatalogASRRulesPolicyWindows10,
  IntuneWiFiConfigurationPolicyAndroidDeviceAdministrator,
  IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner,
  IntuneWifiConfigurationPolicyAndroidEnterpriseWorkProfile,
  IntuneWifiConfigurationPolicyAndroidForWork,
  IntuneWifiConfigurationPolicyAndroidOpenSourceProject,
  IntuneWifiConfigurationPolicyIOS, IntuneWifiConfigurationPolicyMacOS,
  IntuneWifiConfigurationPolicyWindows10, TeamsCallParkPolicy
  * Fix condition in Test-TargetResource when resource is absent
    FIXES [#3897](https://github.com/microsoft/Microsoft365DSC/issues/3897)
    FIXES [#4256](https://github.com/microsoft/Microsoft365DSC/issues/4256)
* TeamsFilesPolicy
  * Add default value ('Present') to parameter Ensure
* TeamsEmergencyCallRoutingPolicy
  * Fix deletion of resource
    FIXES [#4261](https://github.com/microsoft/Microsoft365DSC/issues/4261)
* TeamsUserCallingSettings
  * Added support for Certificate Authentication
    FIXES [#3180](https://github.com/microsoft/Microsoft365DSC/issues/3180)
* TEAMS
  * Added support for ManagedIdentity Authentication across Teams resources.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant dependencies to version 1.1.10.
* MISC
  * Change the way to Export encoding is done so that it no longer relies
    on the Get-DSCResource function.

# 1.24.124.1

* AADAuthenticationMethodPolicyAuthenticator
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicyEmail
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicyFido2
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicySms
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicySoftware
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicyTemporary
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicyVoice
  * Remove the logic path to create a new instance in favor of the update flow.
* AADAuthenticationMethodPolicyX509
  * Remove the logic path to create a new instance in favor of the update flow.
* AADConditionalAccessPolicy
  * Fix issue when not all parameters are specified
    FIXES [#4202](https://github.com/microsoft/Microsoft365DSC/issues/4202)
* AADCrossTenantAccessPolicy
  * Removed the ability to specify a value of Absent for the Ensure property.
* AADCrossTenantAccessPolicyCOnfigurationDefault
  * Removed the ability to specify a value of Absent for the Ensure property.
* AADGroup
  * Changed Set logic to restore groups from the deleted list if a match by
    DisplayName is found.
* EXOActiveSyncDeviceAccessRule
  * Changed the way Identity is determined by using a combination of the
    QueryString and Characteristic parameters.
* EXOAddressList
  * Fixed an issue trying to create a new instance when DisplayName is empty.
* EXOApplicationAccessPolicy
  * Changed the logic to retrieve existing instances based on Scope.
* EXODataClassification
  * DEPRECATED Resource.
* SCAutoSensitivityLabelRule
  * Correct export indentation, which caused an issue with report conversion to JSON.
    FIXES [#4240](https://github.com/microsoft/Microsoft365DSC/issues/4240)
* SPOSharingSettings
  * Fixed an Issue where the MySiteSharingCapability could be returned as an
    empty string instead of a null value from the Get method.
* TeamsAppPermissionPolicy, TeamsAppSetupPolicy, TeamsCallHoldPolicy,
  TeamsIPPhonePolicy, TeamsMobilityPolicy, TeamsNetworkRoamingPolicy,
  TeamsShiftsPolicy, TeamsTenantNetworkRegion, TeamsTenantNetworkSite,
  TeamsTenantNetworkSubnet, TeamsTenantTrustedIPAddress, TeamsTranslationRule,
  TeamsUnassignedNumberTreatment, TeamsVdiPolicy, TeamsWorkloadPolicy
  * Fix condition when resource is absent
    FIXES [#4227](https://github.com/microsoft/Microsoft365DSC/issues/4227)
* TeamsAudioConferencingPolicy
  * Fix condition in Test-TargetResource when resource is absent
    FIXES [#4215](https://github.com/microsoft/Microsoft365DSC/issues/4215)
* TeamsCallParkPolicy
  * Fix condition in Test-TargetResource when resource is absent
    FIXES [#4210](https://github.com/microsoft/Microsoft365DSC/issues/4210)
* TeamsCallQueue
  * Optimize performances by doing 1 request instead of n+1
  FIXES [[#4192](https://github.com/microsoft/Microsoft365DSC/issues/4192)]
* TeamsComplianceRecordingPolicy
  * Fix condition in Test-TargetResource when resource is absent
    FIXES [#4212](https://github.com/microsoft/Microsoft365DSC/issues/4212)
* TeamsCortanaPolicy
  * Fix condition in Test-TargetResource when resource is absent
    FIXES [#4208](https://github.com/microsoft/Microsoft365DSC/issues/4208)
* TeamsEnhancedEncryptionPolicy
  * Fix condition when resource is absent
    FIXES [#4221](https://github.com/microsoft/Microsoft365DSC/issues/4221)
* TeamsEventsPolicy
  * Add missing attributes
    FIXES [#4242](https://github.com/microsoft/Microsoft365DSC/issues/4242)
* TeamsFeedbackPolicy
  * Fix condition when resource is absent
    FIXES [#4223](https://github.com/microsoft/Microsoft365DSC/issues/4223)
* TeamsFilesPolicy
  * Fix condition when resource is absent
    FIXES [#4225](https://github.com/microsoft/Microsoft365DSC/issues/4225)
* TeamsGroupPolicyAssignment
  * Ensure assignment can still be created if GroupId is not found by trying to
    search by DisplayName afterwards
    FIXES [#4248](https://github.com/microsoft/Microsoft365DSC/issues/4248)
* TeamsMeetingBroadcastPolicy
  * Fix deletion of resource
    FIXES [#4231](https://github.com/microsoft/Microsoft365DSC/issues/4231)
* TeamsMobilityPolicy
  * Validate string set on parameter MobileDialerPreference
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 2.12.0.
  * Updated MicrosoftTeams dependencies to version 5.9.0.

# 1.24.117.1

* AADAdministrativeUnit
  * Used generic Graph API URL from MSCloudLoginConnectionProfile.
* AADApplication
  * Ignore Permissions in tests if not passed. Preventing null comparison errors.
* AADAttributeSet
  * Removed the ability to specify a value of Absent for the Ensure property.
* AADConditionalAccessPolicy
  * Fixes an error where the ApplicationEnforcedRestrictionsIsEnabled parameter
    was always set to false in scenarios where it should have been null.
* AADAuthenticationMethodPolicy
  * Removed the ability to specify a value of Absent for the Ensure property.
* AADAuthenticationMethodPolicyX509
  * Fix the way we returned an empty rule set from the Get method. This caused
    the Test-TargetResource method to return true even when instances matched.
* AADRoleSetting
  * Removed the ability to specify a value of Absent for the Ensure property.
* EXOAntiPhishPolicy
  * Add support for HonorDmarcPolicy parameter
    FIXES [#4138](https://github.com/microsoft/Microsoft365DSC/issues/4138)
* IntuneDeviceConfigurationPolicyMacOS
  * Fix CIM instances comparison in Test-TargetResource and export
    CompliantAppsList with the correct type
    FIXES [#4144](https://github.com/microsoft/Microsoft365DSC/issues/4144)
* TeamsEmergencyCallRoutingPolicy
  * Fix deletion of resource
    FIXES [#4219](https://github.com/microsoft/Microsoft365DSC/issues/4219)
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.178.
  * Updated MSCloudLoginAssistant to version 1.1.7.

# 1.24.110.1

* AADAdministrativeUnit
  * Fix the Update logic flow to get around a bug in Microsoft.Graph 2.11.1.
* AADAuthenticationMethodPolicyX509
  * Added support for the  property for include targets
* AADConditionalAccessPolicy
  * Added support for application filters in the conditions.
  * Implement Fix #3885. Manage Exclude Application.
    FIXES [#3885](https://github.com/microsoft/Microsoft365DSC/issues/3885)
* EXOHostedContentFilterPolicy
  * Fix issue on parameters AllowedSenders, AllowedSenderDomains, BlockedSenders,
    BlockSenderDomains if desired state is empty but current state is not empty.
    FIXES [#4124](https://github.com/microsoft/Microsoft365DSC/issues/4124)
* EXOMailContact
  * Added support for Custom Attributes and Extension Custom Attributes.
* IntuneDeviceConfigurationPolicyMacOS
  * Fix workaround added on PR #4099 in order to be able to use this resource
    for deployments
    FIXES [#4105](https://github.com/microsoft/Microsoft365DSC/issues/4105)
* SCDLPComplianceRule
  * Fix type of AccessScope
    FIXES [#3463](https://github.com/microsoft/Microsoft365DSC/issues/3463)
* TeamsTenantDialPlan
  * FIXES [#3767](https://github.com/microsoft/Microsoft365DSC/issues/3767)

# 1.24.103.1

* AADConditionalAccessPolicy
  * Fix Get-TargetResource when the parameter Id is not present
    FIXES [#4029](https://github.com/microsoft/Microsoft365DSC/issues/4003)
* EXOInboundConnector
  * Corrected parameter descriptions, so the documentation on microsoft365dsc.com is generated correctly.
* EXOMailTips
  * Added parameter descriptions for better documentation
* EXOOutboundConnector
  * Corrected parameter descriptions, so the documentation on microsoft365dsc.com is generated correctly.
* EXOReportSubmissionPolicy
  * Initial release
    FIXES [#3690](https://github.com/microsoft/Microsoft365DSC/issues/3690)
* EXOReportSubmissionRule
  * Initial release
    FIXES [#3690](https://github.com/microsoft/Microsoft365DSC/issues/3690)
* EXOTransportRule
  * Stop supporting DLP-related rules, conditions, and actions (https://techcommunity.microsoft.com/t5/exchange-team-blog/exchange-online-mail-flow-rules-to-stop-supporting-dlp-related/ba-p/3959870)
    FIXES [#3929](https://github.com/microsoft/Microsoft365DSC/issues/3929)
* IntuneDeviceConfigurationPolicyMacOS
  * Added parameter descriptions for better documentation
* IntuneSettingCatalogCustomPolicyWindows10
  * Fix Get-TargetResource when the parameter Id is not present
    FIXES [#4029](https://github.com/microsoft/Microsoft365DSC/issues/4003)
* SPOTenantSettings
  * Added parameter descriptions for better documentation
* TeamsChannel
  * Add error handling if GroupId of a team is null
    FIXES [#3943](https://github.com/microsoft/Microsoft365DSC/issues/3943)
* TeamsFeedbackPolicy
  * Added parameter descriptions for better documentation
* TeamsMobilityPolicy
  * Added parameter descriptions for better documentation
* TeamsNetworkRoamingPolicy
  * Added parameter descriptions for better documentation

# 1.23.1227.1

* EXOAntiPhishPolicy
  * Add support for TargetedDomainProtectionAction
    FIXES [#3910](https://github.com/microsoft/Microsoft365DSC/issues/3910)
* EXOMailboxCalendarFolder
  * Add support for non-English calendar folder names during export
    FIXES [#4056](https://github.com/microsoft/Microsoft365DSC/issues/4056)
* EXOMailboxPermission
  * Ignore SendAs permissions during export
    FIXES [#3942](https://github.com/microsoft/Microsoft365DSC/issues/3942)
* EXOTransportRule
  * Fix export of enabled state
    FIXES [#3932](https://github.com/microsoft/Microsoft365DSC/issues/3932)
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Fix issue deploying decrypted OmaSettings to another tenant
    FIXES [#4083](https://github.com/microsoft/Microsoft365DSC/issues/4083)
* IntuneDeviceConfigurationPolicyMacOS
  * Fix resource deployment
    FIXES [#3539](https://github.com/microsoft/Microsoft365DSC/issues/3539)
  * Ensure resource can cope with Id being empty since it's not mandatory
* O365OrgSettings
  * Deprecated the MicrosoftVivaBriefingEmail property
    FIXES [#4097](https://github.com/microsoft/Microsoft365DSC/issues/4097)
    FIXES [#4080](https://github.com/microsoft/Microsoft365DSC/issues/4080)
* SPOTenantSettings
  * Fix bug for DisabledWebPartIds type, should be an array instead of a string
    FIXES [#4086](https://github.com/microsoft/Microsoft365DSC/issues/4086)
* TeamsMeetingPolicy
  * Allow -1 for NewMeetingRecordingExpirationDays parameter (never expire)
    FIXES [#4090](https://github.com/microsoft/Microsoft365DSC/issues/4090)
* TeamsMessagingPolicy
  * Added support for property 'AllowVideoMessages'
    FIXES [#4021](https://github.com/microsoft/Microsoft365DSC/issues/4021)

# 1.23.1220.1

* AADEntitlementManagementAccessPackage
  * Retrieve catalog by name instead of id.
* IntuneDeviceAndAppManagementAssignmentFilter
  * Add support for remaining platforms supported by this policy
    FIXES [#4065](https://github.com/microsoft/Microsoft365DSC/issues/4065)
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Add support to decrypt encrypted OmaSettings and export them in plaintext
    FIXES [#3655](https://github.com/microsoft/Microsoft365DSC/issues/3655)
* IntuneDeviceEnrollmentPlatformRestriction
  * Fix Set-TargetResource due to an issue were the bodyparameter not cast correctly
    FIXES [#3730](https://github.com/microsoft/Microsoft365DSC/issues/3730)
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Fix issue when trying to remove policy and Identity is set to a random GUID
    or from another tenant
    FIXES [#4041](https://github.com/microsoft/Microsoft365DSC/issues/4041)
* IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled
  * Added Assignments
    FIXES [#2932](https://github.com/microsoft/Microsoft365DSC/issues/2932)
* SCAutoSensitivieyLabelPolicy
    FIXES [#4036] Don't see any limits on our docs for priority
* M365DSCDRGUtil
  * Fix empty BaseUrl since MSCloudLoginAssistant removed Intune workload
    FIXES [#4057](https://github.com/microsoft/Microsoft365DSC/issues/4057)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.4.

# 1.23.1213.1

* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Fix issue with assignments
    FIXES [#3904](https://github.com/microsoft/Microsoft365DSC/issues/3904)
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fix issue with Set-TargetResource when retrieving a policy from displayName
    FIXES [#4003](https://github.com/microsoft/Microsoft365DSC/issues/4003)
* IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10
  * Fix parameter name in assignment cmdlet
    FIXES [#4007](https://github.com/microsoft/Microsoft365DSC/issues/4007)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.11.1.
  * Updated MSCloudLoginAssistant to version 1.1.3.

# 1.23.1206.1

* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fix condition in Test-TargetResource to check if resource was removed or not
    FIXES [#3958](https://github.com/microsoft/Microsoft365DSC/issues/3958)
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Fixed Schema Validation
  * Fixed Import with unknown ID of Policy and Assignments by using DisplayName
  FIXES [#3961](https://github.com/microsoft/Microsoft365DSC/issues/3961)
* IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10
  * Fix typo in assignment cmdlet
    FIXES [#3996](https://github.com/microsoft/Microsoft365DSC/issues/3996)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.1.2.
* MISC
  * Fix Compare-M365DSCConfigurations to exclude resources correctly
    FIXES [#4000](https://github.com/microsoft/Microsoft365DSC/issues/4000)

# 1.23.1129.1

* AADRoleSetting
  * Export sorted by DisplayName for better comparison
  * Enable Filter property to be used on export
    FIXES [#3919](https://github.com/microsoft/Microsoft365DSC/issues/3919)
* AADUser
  * Added the MemberOf Property.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Skipped settingValueTemplateReference and settingInstanceTemplateReference
    for severethreats, highseveritythreats, moderateseveritythreats,
    lowseveritythreats as per API requirements observed in the Intune portal.
    FIXES [#3818](https://github.com/microsoft/Microsoft365DSC/issues/3818)
    FIXES [#3955](https://github.com/microsoft/Microsoft365DSC/issues/3955)
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy,
  IntuneAccountProtectionLocalUserGroupMembershipPolicy,
  IntuneAccountProtectionPolicy,
  * Fixes export if Assignments is set on existing policies
    FIXES [3913](https://github.com/microsoft/Microsoft365DSC/issues/3913)
  * Add groupDisplayName to Assignments embedded instance
* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10,
  IntuneDeviceConfigurationHealthMonitoringConfigurationPolicyWindows10,
  IntuneDeviceConfigurationIdentityProtectionPolicyWindows10,
  IntuneDeviceConfigurationEndpointProtectionPolicyWindows10,
  IntuneDeviceEnrollmentStatusPageWindows10,
  IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined,
  IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Removed Id and all authentication parameters from PSBoundParameters in Test-TargetResource
    FIXES [#3888](https://github.com/microsoft/Microsoft365DSC/issues/3888)
* IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Modified assigned to use sdk instead of API call and added logic to use groupDisplayName in assignment
    FIXES [#3921](https://github.com/microsoft/Microsoft365DSC/issues/3921)
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fixed assignments using API call
    FIXES [#3921](https://github.com/microsoft/Microsoft365DSC/issues/3921)
* IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined
  * Modified assigned to use sdk instead of API call and added logic to use groupDisplayName in assignment
    FIXES [#3892](https://github.com/microsoft/Microsoft365DSC/issues/3892)
* IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Modified assigned to use sdk instead of API call and added logic to use groupDisplayName in assignment
    FIXES [#3892](https://github.com/microsoft/Microsoft365DSC/issues/3892)
* IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10
  * Modified assigned to use sdk instead of API call and added logic to use groupDisplayName in assignment
* IntuneDeviceConfigurationPolicyWindows10
    FIXES [#3921](https://github.com/microsoft/Microsoft365DSC/issues/3921)
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fixed assignments using API call
    FIXES [#3921](https://github.com/microsoft/Microsoft365DSC/issues/3921)
* TeamsMessagingPolicy
  * Added support for properties AllowCommunicationComplianceEndUserReporting,
    AllowFluidCollaborate and AllowSecurityEndUserReporting.
    FIXES [#3968](https://github.com/microsoft/Microsoft365DSC/issues/3968)
* TeamsTeam
  * Fixes incompatible type for ComplianceRecordingApplications, expected string[] but receive object[]
    FIXES: [#3890](https://github.com/microsoft/Microsoft365DSC/issues/3890)
* DEPENDENCIES
  * Updated DSCParser to version 1.4.0.1.
  * Updated Microsoft.Graph to version 2.10.0.
  * Updated MSCloudLoginAssistant to version 1.1.0.
* MISC
  * M365DSCDRGUtil
    * Added ConvertFrom-IntunePolicyAssignment and ConvertTo-IntunePolicyAssignment
      FIXES [#3892](https://github.com/microsoft/Microsoft365DSC/issues/3892)
  * Support for Multi-Tenancy (Credentials + TenantId).

# 1.23.1122.1

* SPOSharingSettings
  * Fixes typo to re-enable export of ExternalUserExpireInDays and
    ExternalUserExpirationRequired.
* DEPENDENCIES
  * Updated DSCParser to version 1.4.0.0.
  * Updated Microsoft.Graph to version 2.9.1.
  * Updated MicrosoftTeams to version 5.8.0.

# 1.23.1115.1

* AADApplication
  * Added support for the IsFallbackPublicClient property.
    FIXES [#3906](https://github.com/microsoft/Microsoft365DSC/issues/3906)
* AADServicePrincipal
  * Added support to define members.
    FIXES [#3902](https://github.com/microsoft/Microsoft365DSC/issues/3902)
* EXOCASMailboxPlan
  * Fixes an issue where we are not able to set the settings of a CAS
    Mailbox Plan by specifying the Identity without the GUID in the name.
    FIXES [#3900](https://github.com/microsoft/Microsoft365DSC/issues/3900)

# 1.23.1108.3

* AADRoleEligibilityScheduleRequest
  * Fixed incorrect subclass MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrenceRange
    for range property
    FIXES [#3847](https://github.com/microsoft/Microsoft365DSC/issues/3847)
  * Fixes issue where creating an entry that was previously removed threw an error
    complaining that the role eligibility already existed.
* IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy
  * Initial release
    FIXES [#3034](https://github.com/microsoft/Microsoft365DSC/issues/3034) 3/3
* IntuneAccountProtectionLocalUserGroupMembershipPolicy
  * Initial release
    FIXES [#3034](https://github.com/microsoft/Microsoft365DSC/issues/3034) 2/3
* IntuneAccountProtectionPolicy
  * Initial release
    FIXES [#3034](https://github.com/microsoft/Microsoft365DSC/issues/3034) 1/3
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Fixes typo in Get-TargetResource
    FIXES [#3869](https://github.com/microsoft/Microsoft365DSC/issues/3869)
* IntuneDeviceConfigurationEndpointProtectionPolicyWindows10
  * Fix an issue where the firewall settings were not populate correctly
  FIXES [#3851](https://github.com/microsoft/Microsoft365DSC/issues/3851)
* IntuneDeviceEnrollmentStatusPageWindows10
  * Fix typo in the catch of Update-DeviceEnrollmentConfigurationPriority
    FIXES [#3442](https://github.com/microsoft/Microsoft365DSC/issues/3442)
* M365DSCDRGUTIL
  * Fix an issue where temporary parameters were not renamed during recursive call causing a Model Validation
    error during creation or update of a Graph resource
    FIXES [#3582](https://github.com/microsoft/Microsoft365DSC/issues/3582)
* MISC
  * Added a QA check to test if all used subclasses actually exist in the MOF schema.
* DEPENDENCIES
  * Updated Microsoft. Graph dependencies to version 2.9.0.

# 1.23.1108.1

* AADExternalIdentityPolicy
  * Initial release.
* O365OrgSettings
  * Force register the Office on the Web ServicePrincipal is it is not present.
    FIXES [#3842](https://github.com/microsoft/Microsoft365DSC/issues/3842)
* TeamsTeam
  * Fixes incomplete import due to error "Cannot index into a null array"
    FIXES: [#3759](https://github.com/microsoft/Microsoft365DSC/issues/3759)

# 1.23.1101.1

* AADRoleEligibilityScheduleRequest
  * Fixes how the Get method retrieves existing instances for Groups.
    FIXES [#3787](https://github.com/microsoft/Microsoft365DSC/issues/3787)
* SCSecurityFilter
  * Fixes an issue because Region could be empty
  FIXES: [#3854](https://github.com/microsoft/Microsoft365DSC/issues/3854)
* SPOSharingSettings
  * Fixes parameter validation of ExternalUserExpireInDays and ExternalUserExpirationRequired.
    FIXES [#3856](https://github.com/microsoft/Microsoft365DSC/issues/3856)
* TeamsComplianceRecordingPolicy
  * Fix an issue where the Compliance Application ID wasn't properly retrieved.
  FIXES [#3848](https://github.com/microsoft/Microsoft365DSC/issues/3848)

# 1.23.1025.1

* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Fixes an issue where reviewers were not properly exported
* M365DSCDRGUTIL
  * Fixes an issue with Get-M365DSCDRGComplexTypeToHashtable where Beta cmdlet were not recognized for recursive calls
  FIXES [#3448](https://github.com/microsoft/Microsoft365DSC/issues/3448)
* AADApplication
  * Changes to how permissions drifts are logged.
    FIXES [#3830](https://github.com/microsoft/Microsoft365DSC/issues/3830)
* AADAttributeSet
  * Initial Release.
* AADAuthenticationContext
  * Initial Release.
* AADConditionalAccessPolicy
  * Adds support for Authentication Context.
    FIXES [#3813](https://github.com/microsoft/Microsoft365DSC/issues/3813)
* AADSocialIdentityProvider
  * Initial release.
* TeamsComplianceRecordingPolicy
  * Fixes an issue where the Compliance Application ID wasn't properly retrieved.
    FIXES [#3712](https://github.com/microsoft/Microsoft365DSC/issues/3712)
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 2.8.0.
  * Updated MicrosoftTeams dependency to version 5.7.1.

# 1.23.1018.1

* AADAuthenticationMethodPolicyAuthenticator
  * Fixes an issue with the Get method when an assigned group
    was deleted.
* AADConditionalAccessPolicy
  * Added support for the SigninFrequencyInterval parameter.
* EXODistributionGroup
  * Changes the export logic to use PrimarySMTPAddress if provided.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Added "-All" parameter to retrieve all settings from a template.
  FIXES [#3722](https://github.com/microsoft/Microsoft365DSC/issues/3722)
* IntuneDeviceCleanupRule
  * Initial release.
    FIXES [#3599](https://github.com/microsoft/Microsoft365DSC/issues/3599)
* TeamsGroupPolicyAssignment
  * Fixes the export of CsGroup, when the display name of a group is included in
    another display name.
  FIXES [#3736](https://github.com/microsoft/Microsoft365DSC/issues/3736)
* TeamsUserPolicyAssignment
  * Initial release.
  FIXES [#3777](https://github.com/microsoft/Microsoft365DSC/issues/3777)
* MISC
  * Fixes fancy quotes in complex objects for extraction.
* SCSecurityFilter
  * Initial release
  FIXES: [#3796](https://github.com/microsoft/Microsoft365DSC/issues/3796)

# 1.23.1011.1

* AADRoleEligibilityScheduleRequest
  * Added support for groups assignment.
    FIXES [#3744](https://github.com/microsoft/Microsoft365DSC/issues/3744)
* EXOCalendarProcessing
  * Added support for retrieved groups as calendar delegates.
* EXODistributionGroup
  * Fixes the export of group membership to use Identity.
* IntuneDeviceConfigurationPolicyWindows10
  * Support setting assignment groups by display name
* TeamsUpdateManagementPolicy
  * Add support for the new acceptable value for UseNewTeamsClient
    (NewTeamsAsDefault).
* MISC
  * M365DSCReport: Also define property dataType, if present, as being primary
     key on CIM instances.
* TeamsUpgradeConfiguration
  * Fixes an issue where the SfBMeetingJoinUx property wasn't properly updated.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.4.0.
  * Updated Microsoft.Graph dependencies to version 2.7.0.

# 1.23.1004.1

* AADEntitlementManagementAccessPackageAssignmentPolicy
  * [BREAKING CHANGE] Fixes customExtension property where the schema and assignement
    were not managed correctly.
    FIXES [#3639](https://github.com/microsoft/Microsoft365DSC/issues/3639)
* AADEntitlementManagementConnectedOrganization
  * FIXES [[#3738](https://github.com/microsoft/Microsoft365DSC/issues/3738)]
* EXOCalendarProcessing
  * Initial release.
* EXODistributionGroup
  * [BREAKING CHANGE] Identity is now a primary key.
    FIXES [#3741](https://github.com/microsoft/Microsoft365DSC/issues/3741)
  * Added support for multiple new properties to align with supporting cmdlet.
* EXOMailboxAutoReplyConfiguration
  * Initial release.
* EXOMailboxCalendarFolder
  * Initial release.
* EXOMailboxPermission
  * Initial release.
* EXOPlace
  * Initial release.
* IntunePolicySets
  * New Configuration for Intune Policy Sets
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.121.
* MISC
  * TestHarness.psm1
    * Added code around DscTestsPath parameter to target a single test file
      during development

# 1.23.927.1

* AADApplication
  * Added support for restoring soft deleted instances.
* AADRoleSetting
  * Fixed issue with export where ApplicationSecret was not returned.
    FIXES [#3695](https://github.com/microsoft/Microsoft365DSC/issues/3695)
* M365DSCRuleEvaluation
  * Improvements to how rules are evaluated and how drifts are logged.
* O365OrgSettings
  * Changes to how ToDo discrepencies are being fixed in the SET method.
* M365DSCDRGUtil
  * Added support for Intune URIs to be dynamic based on target
    cloud instance (Commercial, GCC-H..etc)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.6.1.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.117.
* MISC
  * Fixed handling of Graph connection in Update-M365DSCAllowedGraphScopes

# 1.23.920.2

* DEPENDENCIES
  * Rolled back Microsoft.Graph to version 2.5.0.
* MISC
  * M365DSCDRGUtil: Write properties properly indented and in new line
    FIXES [#3634](https://github.com/microsoft/Microsoft365DSC/issues/3634)

# 1.23.920.1

* O365OrgSettings
  * Fixes and issue where a the wrong url was being used in some of the API
    calls, resulting in null returns for some properties in the Get method.
* SPOSharingSettings
  * Changes verbose prompts to warnings.
* TeamsGroupPolicyAssignment
  * Changes to how Group IDs are retrieved and evaluated.
* TeamsAppPermissionPolicy
  * Fixes to the Test-TargetResource evaluation of empty arrays.
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.6.0.
  * Updated MicrosoftTeams to version 5.6.0.
    FIXES [#3671](https://github.com/microsoft/Microsoft365DSC/issues/3671)
* MISC
  * M365DSCUtil: Fix problem naming similar resources
    FIXES [#3700](https://github.com/microsoft/Microsoft365DSC/issues/3700)

# 1.23.913.2

* MISC
  * Fixed a merge conflict in the Uninstall-M365DSCOutdatedDependencies
    function.
    FIXES [#3685](https://github.com/microsoft/Microsoft365DSC/issues/3685)

# 1.23.913.1

* AADNamedLocationPolicy
  * Set default value for CountryLookupMethod and removed unwanted properties
    FIXES [#3656](https://github.com/microsoft/Microsoft365DSC/issues/3656)
  * Added support for compliantNetworkNamedLocation.
    FIXES [#3422](https://github.com/microsoft/Microsoft365DSC/issues/3422)
* IntuneAppProtectionPolicyAndroid
  * Added support for 'RequireClass3Biometrics' parameter
  * Added support for 'RequirePinAfterBiometricChange' parameter
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Added support for 'engineupdateschannel' parameter
  * Added support for 'platformupdateschannel' parameter
  * Added support for 'securityintelligenceupdateschannel' parameter
* M365DSCRuleEvaluation
  * Initial Release.
* O365OrgSettings
  * Fixes an issue where the wrong Graph URLs were being called for sovereign
    clouds.
    FIXES [#3673](https://github.com/microsoft/Microsoft365DSC/issues/3673)
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.3.0.
  * Updated Microsoft.Graph modules to version 2.5.0.
  * Added dependency on Microsoft.Graph.Beta.Reports.
* MISC
  * Improved error logging for methods installing or updating modules.
    FIXES [#3660](https://github.com/microsoft/Microsoft365DSC/issues/3660)
  * Removed Id as a mandatory parameter for most AAD resources.
    FIXES [#3344](https://github.com/microsoft/Microsoft365DSC/issues/3344)
  * Single quotes handling in Export for complex CIMInstances
    FIXES [#3479](https://github.com/microsoft/Microsoft365DSC/issues/3479)

# 1.23.906.1

* AADAuthenticationMethodPolicyAuthenticator
  * Fixes issues with the export missing a line return.
    FIXES [#3645](https://github.com/microsoft/Microsoft365DSC/issues/3645)
* AADAuthorizationPolicy
  * Fix issues with the Set method, which did not check an array properly.
* AADGroup
  * Fixed Get-TargetResource not to use the parameters that should be set,
    preventing an empty delta on Set-TargetResource
    FIXES [#3629](https://github.com/microsoft/Microsoft365DSC/issues/3629)
* AADRoleEligibilityScheduleRequest
  * Initial Release.
* EXOIRMConfiguration
  * Corrected type in schema for parameter TransportDecryptionSetting
* EXORemoteDomain
  * Implemented a wait/retry mecanism between the New-RemoteDomain and
    Set-RemoteDomain to avoid timeout.
    FIXES [#3628](https://github.com/microsoft/Microsoft365DSC/issues/3628)
* IntuneSettingCatalogASRRulesPolicyWindows10
  * Added support for ASR rule BlockWebShellCreationForServers.
* DEPENDENCIES
  * Updated Install-M365DSCDevBranch, Update-M365DSCDependencies and
    Update-M365DSCModule to be usable with -Scope, allowing
    the user to install/update the module dependencies without admin rights,
    using current user scope. Confirm-M365DSCDependencies
    error message changed to reflect this change.
    FIXES [#3621](https://github.com/microsoft/Microsoft365DSC/issues/3621)
  * Updated MSCloudLoginAssitant to version 1.0.120
* MISC
  * Fix in Update-M365DSCAzureAdApplication to prevent issue with uploading certificate.
    EndDate parameter was incorrect and not necessary.
  * Fixed issue in documentation generation
    FIXES [#3635](https://github.com/microsoft/Microsoft365DSC/issues/3635)
  * M365DscReport: Fix typo in var name in Compare-M365DSCConfigurations cmdlet
    FIXES [#3632](https://github.com/microsoft/Microsoft365DSC/issues/3632)

# 1.23.830.1

* O365SearchAndintelligenceConfigurations
  * Removed support for Service Principal Auth, which the cmdlet never supported.
* SPOHomeSite
  * Fixes an issue if no home site exists
    FIXES [#3577](https://github.com/microsoft/Microsoft365DSC/issues/3577)
* DEPENDENCIES
  * Updated Microsoft.Graph to version 2.4.0.
  * Updated ReverseDSC to version 2.0.0.18
* MISC
  * Fixes an issue with the generic export CIM Instance logic.
    FIXES [#3610](https://github.com/microsoft/Microsoft365DSC/issues/3610)

# 1.23.823.1

* AADAuthorizationPolicy
  * Fix issue with property PermissionGrantPolicyIdsAssignedToDefaultUserRole
    FIXES [#3594](https://github.com/microsoft/Microsoft365DSC/issues/3594)
* AADGroupsSettings
  * Add support for enabling sensitivity labels in M365-groups
* EXOSafeAttachmentPolicy
  * Deprecated ActionOnError Parameter
    FIXES [#3579](https://github.com/microsoft/Microsoft365DSC/issues/3579)
* IntuneEndpointDetectionAndResponsePolicyWindows10
  * Initial release
    FIXES [#3349](https://github.com/microsoft/Microsoft365DSC/issues/3349)
* O365OrgSettings
  * Updated logic of the Get to return null if permissions are not granted for
    a given API.
  * Updated the list of required permissions.
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 2.3.0
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.174.

# 1.23.809.1

* AADAuthorizationPolicy
  * Added support for the AllowedToCreateTenants &
    AllowedToReadBitlockerKeysForOwnedDevice properties.
    FIXES [#3492](https://github.com/microsoft/Microsoft365DSC/issues/3492)
* AADGroup, AADUser and O365Group
  * Add support to use function endsWith as filter
    FIXES [#3518](https://github.com/microsoft/Microsoft365DSC/issues/3518)
* O365OrgSettings
  * Added error handling for the Viva settings to handle task cancellation errors.
  * Added improvements for the set to only call into APIs that need a PATCH request.
* SCComplianceSearch
  * Fixed an issue with the export when using CertificateThumbprint.
    FIXES [#3499](https://github.com/microsoft/Microsoft365DSC/issues/3499)
* SCComplianceSearchAction
  * Adds support for the Preview action type.
    FIXES [#3498](https://github.com/microsoft/Microsoft365DSC/issues/3498)
* SCRetentionCompliancePolicy
  * Fixes an issue where SPN auth parameters weren't returned from the Get-TargetResource
    function.
    FIXES [#3500](https://github.com/microsoft/Microsoft365DSC/issues/3500)
* SPOTenantSettings
  * Add support for new parameter HideSyncButtonOnTeamSite
* TeamsGroupPolicyAssignment
  * FIXES [#3559](https://github.com/microsoft/Microsoft365DSC/issues/3559)
* TeamsShiftPolicy
  * Deprecated the EnableShiftPresence parameter.
* TeamsTemplatesPolicy
  * Initial release.
* MISC
  * M365DscReverse: Fix exporting when $Filter var exists locally
    FIXES [#3515](https://github.com/microsoft/Microsoft365DSC/issues/3515)
  * Fix for the delta report function to handle deep nested CIM Instances.
    FIXES [#3478](https://github.com/microsoft/Microsoft365DSC/issues/3478)
* DEPENDENCIES
  * Updated Microsoft.Graph.* dependencies to version 2.2.0.
  * Updated MSCloudLoginAssistant to version 1.0.119.
  * Updated dependency Microsoft.PowerApps.Administration.PowerShell to version 2.0.170.

# 1.23.726.1

* AADGroup
  * Fix issue setting MemberOf property.
    FIXES [#3496](https://github.com/microsoft/Microsoft365DSC/issues/3496)
* TeamsOrgWideAppSettings
  * Removed support for app authentication since the underlying cmdlets aren't
    supporting it yet.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.118.
* MISC
  * Improved Update-M365DSCDependencies function to properly install all Microsoft.Graph.* modules.
    FIXES [#3454](https://github.com/microsoft/Microsoft365DSC/issues/3454)

# 1.23.719.1

* AADCrossTenant
  * Added Automatic Consent for inbound and Outbound trust settings
* EXOSharedMailbox
  * Added capability to change the PrimarySMTPAddress of a Shared Mailbox
* SPOExternalUserExpireInDays
  * Added the External User Expiration setting in the config.
* MISC
  * Updated AAD, EXO and Teams settings file to describe required roles.
  * Added a new personas documentation page to describe the targeted personas
    for the project.
  * Added a more meaningful exception message to Update-M365DSCDependencies if
    the module is not installed or imported successfully
  * Fixes an issue with the reporting where the wrong key parameter was sometimes
    used when a component was missing in the source tenant.
* DEPENDENCIES
  * Updated the Microsoft.Graph.* dependencies to version 2.1.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.168.
  * Updated MicrosoftTeams to version 5.4.0.
  * Updated MSCloudLoginAssistant to version 1.0.117.

# 1.23.712.1

* IntuneDeviceConfigurationPolicyAndroidDeviceAdministrator
  * Fixes an issue where the Get-TargetResource function was defining the parameter as Identity and all othe methods and schema had it defined to Id.
* O365OrgSettings
  * Introduced a workaround to fix an issue with the ExchangeOnlineManagement module where if connected to Security and Compliance center
    an error about an invalid token would get thrown when calling the Get-DefaultTenantMyAnalyticsFeatureConfig cmdlet.
* SPOApp
  * Fixes an issue where the extraction was complaining about op_addition failing.
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.167.
* DRG
  * General cleanup from generated resources from DRG
    * Added module M365DSCDRGUtil.psm1
    * Fix issues on several resources
    * Fix assignment from several resources
    * Fix unit test on several resources
    * Removed helper resources centralized in M365DSCDRGUtil from all resources
      FIXES [#3309](https://github.com/microsoft/Microsoft365DSC/issues/3309)
* MISC
  * Fixes cmdlet to use Get-MgBetaOrganization in the Get-M365DSCTenantDomain function.
    FIXES [#3449](https://github.com/microsoft/Microsoft365DSC/issues/3449)

# 1.23.705.1

* EXOAddressList
  * Improved export performance.
* EXOCASMailboxSettings
  * Improved export performance.
* EXODataClassification
  * Improved export performance.
* EXODistributionGroup
  * Improved export performance.
* EXOGroupSettings
  * Improved export performance.
* EXOMailboxPlan
  * Support comparing instances without the GUID in the name.
    FIXES [#3314](https://github.com/microsoft/Microsoft365DSC/issues/3314)
* EXOManagementRole
  * Improved export performance.
* EXOManagementRoleAssignment
  * Improved export performance.
* EXORoleGroup
  * Improved export performance.
* DEPENDENCIES
  * Updated all Microsoft.Graph modules to version 2.0.0.
  * Updated all MSCloudLoginAssistant modules to version 1.0.116.
* MISC
  * Updated QA tests to dynamically retrieve the permission list.
* IntuneASRRulesPolicyWindows10
  * Fix possible values for several properties both in the module and its schema
    FIXES [#3434](https://github.com/microsoft/Microsoft365DSC/issues/3434)

# 1.23.628.1

* AADAdministrativeUnit
  * Improved export performance.
* AADApplication
  * Updated the Set and Test function to ignore the AppId parameter.
    FIXES [#3390](https://github.com/microsoft/Microsoft365DSC/issues/3390)
  * Improved export performance.
* AADAuthenticationMethodPolicyAuthenticator
  * Deprecated the NumberMatchingRequiredState Feature Setting.
    FIXES [#3406](https://github.com/microsoft/Microsoft365DSC/issues/3406)
* AADRoleDefinition
  * Improved export performance.
* AADRoleSetting
  * Improved export performance.
* AADServicePrincipal
  * Updated the Set and Test function to ignore the AppId parameter.
    FIXES [#3390](https://github.com/microsoft/Microsoft365DSC/issues/3390)
  * Improved export performance.
* EXOAvailabilityConfig
  * Fixes an error where an error was thrown when the OrgWideAccount wasn't set.
    FIXES [#3402](https://github.com/microsoft/Microsoft365DSC/issues/3402)
* IntuneDeviceEnrollmentPlatformRestriction
  * Fixes an error where the WindowsMobileRestriction property was still being assessed dispite it being deprecated.
    FIXES [#3407](https://github.com/microsoft/Microsoft365DSC/issues/3407)
* O365OrgSettings
  * Added support for Forms, Dynamics Customer Voice, To Do and Apps & Services settings.
* TeamsCallQueue
  * Initial release.
* Teams resources
  * Added required application permissions to support [Application Based Authentication](https://learn.microsoft.com/en-us/microsoftteams/teams-powershell-application-authentication)
* MISC
  * Added API to the Organization.Read.All permission in the Get-M365DSCCompiledPermisisonList cmdlet
  * Fixes an issue with Update-M365DSCAzureAdApplication where it was throwing an error complaining about duplicate keys.
    FIXES #3417
  * Update-M365DSCModule now forces a reload of the latest version of the Microsoft365DSC module.
    FIXES [#3326](https://github.com/microsoft/Microsoft365DSC/issues/3326)
  * Update-M365DSCAzureADApplication
    Added retry logic to catch the "Key credential end date is invalid" error when updating the application certificate.
    FIXES [#3426](https://github.com/microsoft/Microsoft365DSC/issues/3426)
* DEPENDENCIES
  * Updated ReverseDSC to version 2.0.0.16.

# 1.23.621.1

* AADAdministrativeUnit
  * Fixes an issue where the domain part of the user name was handled as a string when using credentials to authenticate.
* EXORoleGroup
  * Fixes an issue where the role group wasn't getting created when members were null.
    FIXES [#3217](https://github.com/microsoft/Microsoft365DSC/issues/3217)
* O365OrgSettings
  * Added support for the PlannerAllowCalendarSharing property for Planner.
  * Added support for the Microsoft 365 installation options.
  * Added support for the Viva Insights and Briefing email settings.
* PPTenantIsolationSettings & PPTenantSettings
  * Handles the case where required permissions are not provided when using SPN authentication.
    FIXES [#3179](https://github.com/microsoft/Microsoft365DSC/issues/3179)
* SCProtectionAlert
  * Prevents extracting system rules.
    FIXES [#3224](https://github.com/microsoft/Microsoft365DSC/issues/3224)
* MISC
  * Fixes the display of arrays as property values for Excel based reports from New-M365DSCReportFromConfiguration.
    FIXES [#3173](https://github.com/microsoft/Microsoft365DSC/issues/3173)
  * Added the Organization.Read.All permission by default in the Get-M365DSCCompiledPermisisonList cmdlet return values.
    FIXES [#3292](https://github.com/microsoft/Microsoft365DSC/issues/3292)
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.2.0.
  * Updated MicrosoftTeams to version 5.3.0.
  * Updated MSCloudLoginAssistant to version 1.0.114.

# 1.23.614.1

* AADApplication
  * Adds support for specifying permissions by names or GUID.
* AADNamedLocationPolicy
  * Added support forthe CountryLookupMethod property
    FIXES [#3345](https://github.com/microsoft/Microsoft365DSC/issues/3345)
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Fixes an issue with Set-TargetResource when an array is empty
  * Fixes presentationValue updates
    FIXES [#3355](https://github.com/microsoft/Microsoft365DSC/issues/3355)
* TeamsAppPermissionPolicy
  * Fixes an issue where the wrong app types were trying to get assigned.
    FIXES [#3373](https://github.com/microsoft/Microsoft365DSC/issues/3373)
* MISC
  * Removed dependency on the Az.Accounts module from the Update-M365DSCAzureAdApplication function.
* DEPENDENCIES
  * Updated DSCParser to version 1.3.0.10.
  * Updated Microsoft.Graph dependencies to version 1.28.0.
  * Updated MSCloudLoginAssistant to version 1.0.112.

# 1.23.607.1

* AADAuthenticationStrengthPolicy
  * Removed the ValidateSet from the AllowedCombinations property due to incomplete full list of possible values.
* EXOQuarantinePolicy
  * Fixes an issue where GlobalQurantinePolicy properties can't be updated.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Fixes an issue for policies with template endpointSecurityAntivirus that had a templateId not expected by the code
    FIXES [#3360](https://github.com/microsoft/Microsoft365DSC/issues/3360)
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Fixes an issue with Set-TargetResource when an array is empty
    FIXES [#3355](https://github.com/microsoft/Microsoft365DSC/issues/3355)
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.166.

# 1.23.524.1

* AADGroup
  * Performance Improvements for export.
* AADUser
  * Performance improvements for export.
* O365OrgSettings
  * Added support for the AdminCenterReportDisplayConcealedNames property.
* SCAutoSensitivityLabelRule
  * Fixes an issue with the HeaderMatchesPatterns property not compiling when empty.
* TeamsOrgWideAppSettings
  * Initial release.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.111
  * Updated ReverseDSC to version 2.0.0.15

# 1.23.517.1

* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Fixes an issue where Reviewers and requestors weren't properly extracted.
    FIXES [#3255](https://github.com/microsoft/Microsoft365DSC/issues/3255)
* IntuneDeviceEnrollmentPlatformRestriction
  * Ensure that Windows Mobile platform cannot be unblocked
    FIXES [#3303](https://github.com/microsoft/Microsoft365DSC/issues/3303)
* IntuneSettingCatalogCustomPolicyWindows10
  * Add missing properties to schema
    FIXES [#3300](https://github.com/microsoft/Microsoft365DSC/issues/3300)
* SCAutoSensitivityLabelRule
  * Fixes an issue with the HeaderMatchesPatterns property not working as expected.
    FIXES [#3315](https://github.com/microsoft/Microsoft365DSC/issues/3315)
* SPOUserProfileProperty
  * Fixes and issue where the properties weren't properly set.
    FIXES [#3226](https://github.com/microsoft/Microsoft365DSC/issues/3226)
* TeamsAppPermissionPolicy
  * Initial release
* TeamsAppSetupPolicy
  * Initial release.
* EXOQuarantinePolicy
  * Support exporting and importing global quarantine policy
    FIXES [#3285](https://github.com/microsoft/Microsoft365DSC/issues/3285)
* DEPENDENCIES
  * Updated MicrosoftTeams to version 5.2.0
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.165
* MISC
  * Major performance improvements for the New-M365DSCDeltaReport cmdlet.
    FIXES [#3016](https://github.com/microsoft/Microsoft365DSC/issues/3016)
  * M365DSCUtil: Fix typo in order to obfuscate cert thumbprint

# 1.23.510.1

* AADAuthenticationStrengthPolicy
  * Initial release
* AADConditionalAccessPolicy
  * Added support for the AuthenticationStrength parameter.
* AADCrossTenantAccessPolicy
  * Initial release
    FIXES [#3251](https://github.com/microsoft/Microsoft365DSC/issues/3251)
* AADCrossTenantAccessPolicyConfigurationDefault
  * Initial release
    FIXES [#3252](https://github.com/microsoft/Microsoft365DSC/issues/3252)
* AADCrossTenantAccessPolicyConfigurationPartner
  * Initial release
    FIXES [#3253](https://github.com/microsoft/Microsoft365DSC/issues/3253)
* IntuneSettingCatalogCustomPolicyWindows10
  * Initial release
  FIXES [#2692](https://github.com/microsoft/Microsoft365DSC/issues/2692),
  FIXES [#2976](https://github.com/microsoft/Microsoft365DSC/issues/2976),
  FIXES [#3070](https://github.com/microsoft/Microsoft365DSC/issues/3070),
  FIXES [#3071](https://github.com/microsoft/Microsoft365DSC/issues/3071),
  FIXES [#3156](https://github.com/microsoft/Microsoft365DSC/issues/3156)
* TeamsMessagingPolicy
  * Add support for new parameters: AllowSmartCompose, AllowSmartReply, AllowUserDeleteChat
* TeamsGuestMessagingConfiguration
  * Add support for AllowUserDeleteChat parameter
* TeamsGuestMeetingConfiguration
  * Add support for LiveCaptionsEnabledType parameter
* TeamsTeam
  * Fix group creation
* DEPENDENCIES
  * Updated DSCParser to version 1.0.9.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.1623.
  * Updated MSCloudLoginAssistant to version 1.0.110.
* MISC
  * Added a new Get-M365DSCConfigurationConflict cmdlet to help validate configurations and added
    the -Validate switch to the Export-M365DSCConfiguration cmdlet.

# 1.23.503.1

* IntuneDeviceConfigurationImportedPfxCertificatePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationPkcsCertificatePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationScepCertificatePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationSecureAssessmentPolicyWindows10
  * Initial release
* IntuneDeviceConfigurationSharedMultiDevicePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationTrustedCertificatePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationVpnPolicyWindows10
  * Initial release
* IntuneDeviceConfigurationWiredNetworkPolicyWindows10
  * Initial release
* DRG
  * Fix issue with abstract type and additionalProperties
* MISC
  * Intune: changed the display or instances to show the display name instead of Id during extraction.
  * M365DSCUtil: Fixed an issue on function Get-M365DSCExportContentForResource if ConnectionMode was set to anything but "Credentials*"
  * Assert-M365DSCBlueprint, New-M365DSCDeltaReport, Compare-M365DSCConfigurations: Add support to exclude resources from being compared
  * EXPORT: Multiple fixes for display and handling of invalid licenses.
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.109.

# 1.23.426.3

* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.108.
  * Updated Microsoft.Graph dependencies to version 1.27.0.
* MISC
  * If an error occurs during the export process, we now throw an error instead of simply writing the error
    back to the host via Write-Host.

# 1.23.426.2

* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.107.
    FIXES #3231

# 1.23.426.1

* AADConditionalAccessPolicy
  * Fix Couldn't find Location 00000000-0000-0000-0000-000000000000
    FIXES[#2974](https://github.com/microsoft/Microsoft365DSC/issues/2974)
* AADAuthenticationMethodPolicy
  * Initial release. Configure Authentication policy settings
* AADAuthenticationMethodPolicyAuthenticator
  * Initial release. Configure Authentication settings related to MicrosoftAuthenticator
* AADAuthenticationMethodPolicyEmail
  * Initial release. Configure Authentication settings related to Email
* AADAuthenticationMethodPolicyFido2
  * Initial release. Configure Authentication settings related to Fido2
* AADAuthenticationMethodPolicySms
  * Initial release. Configure Authentication settings related to Sms
* AADAuthenticationMethodPolicySoftware
  * Initial release. Configure Authentication settings related to SoftwareOath
* AADAuthenticationMethodPolicyTemporary
  * Initial release. Configure Authentication settings related to TemporaryAccessPass
* AADAuthenticationMethodPolicyVoice
  * Initial release. Configure Authentication settings related to Voice
* AADAuthenticationMethodPolicyX509
  * Initial release. Configure Authentication settings related to X509Certificate
* AADAdministrativeUnit
  * Fix issue incorrectly removing existing Members and ScopedRoleMembers
    FIXES [#3194](https://github.com/microsoft/Microsoft365DSC/issues/3194)
  * Fix issue creating ScopedRoleMembers of Type Group or ServicePrincipal
    FIXES [#3189](https://github.com/microsoft/Microsoft365DSC/issues/3189)
* SCLabelPolicy
  * Fixed issue where the Labels parameter isn't handled properly for existing
    policies
    FIXES [#3216](https://github.com/microsoft/Microsoft365DSC/issues/3216)
* SCSensitivityLabel
  * Remove property Disabled from schema
    FIXES [#3193](https://github.com/microsoft/Microsoft365DSC/issues/3193)
  * Corrected issue where SiteAndGroupExternalSharingControlType wasn't
    applied correctly with existing labels
    FIXES [#3210](https://github.com/microsoft/Microsoft365DSC/issues/3210)
* TeamsTeam
  * Fixes an error when trying to extract teams using a Service Principal.
    FIXES [#3183](https://github.com/microsoft/Microsoft365DSC/issues/3183)
* DEPENDENCIES
  * Updated DSCParser dependencies to version 1.3.0.7.
  * Updated Microsoft.Graph dependencies to version 1.26.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.160.
  * Updated MSCloudLoginAssistant to version 1.0.106.

# 1.23.419.1

* IntuneDeviceConfigurationDefenderForEndpointOnboardingPolicyWindows10
  * Initial release
* IntuneDeviceConfigurationEmailProfilePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationKioskPolicyWindows10
  * Initial release
* EXOManagementRoleAssignment
  * Fixed issue with incorrect Microsoft Graph cmdlets used to retrieve Administrative Units.
    FIXES [#3185](https://github.com/microsoft/Microsoft365DSC/issues/3185)
* SCLabelPolicy
  * If label policy is set to None don't get its label display name since it's not required
    FIXES [#3104](https://github.com/microsoft/Microsoft365DSC/issues/3104)
* DRG
  * Fixed issue retrieving the cmdlet definition when the resource type is derived from an abstract type
  * Fixed issue with UnitTest and complex properties with AdditionalProperties
  * Fixed issue with Complex constructor and complex properties with AdditionalProperties
* MISC
  * Reports will now exclude the authentication parameters (e.g., CertificateThumbprint, Credential, etc.).
  * Changed the Encoding helper's logic to ensure titled quotes and apostrophes are correctly evaluated.
    FIXES [#3165](https://github.com/microsoft/Microsoft365DSC/issues/3165)
  * Fixes an issue where the new resource name extraction could still have duplicates.

# 1.23.412.1

* AADUser
  * Password property will only used with New-MgUser and ignored for updates
    FIXES [#3093](https://github.com/microsoft/Microsoft365DSC/issues/3093)
* IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10
  * Initial release
    FIXES [#2833](https://github.com/microsoft/Microsoft365DSC/issues/2833)
* IntuneDeviceConfigurationCustomPolicyWindows10
  * Initial Release
      FIXES [#3068](https://github.com/microsoft/Microsoft365DSC/issues/3068)
* IntuneDeviceConfigurationDomainJoinPolicyWindows10
  * Initial release
* IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10
  * Initial release
* IntuneDeviceConfigurationWindowsTeamPolicyWindows10
  * Initial release
* O365SearchAndIntelligenceConfigurations
  * Initial release.
* TeamsUpdateManagementPolicy
  * Added support for the Forced value for the AllowPublicPreview property.
* DRG
  * Fixed layout and display issues in module file
* MISC
  * Changed Get-MgDeviceManagementDeviceConfiguration to use the cmdlet switches rather than filtering output once returned.
    Fixes #3082
  * M365DSCUtil: Fixed an issue when calling Assert-M365DSCBlueprint with App credentials
    FIXES [#3153](https://github.com/microsoft/Microsoft365DSC/issues/3153)
  * Added check to validate that the Release Notes in the module manifest are not longer than
    10,000 characters, which will prevent publishing the module to the PowerShell Gallery
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell dependencies to version 2.0.159.

# 1.23.405.1

* AADAdministrativeUnit
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * Fixes extraction of the Members property.
  * Fixes extraction of the ScopedRoleMembers property.
* AADApplication
  * [BREAKING CHANGE] Remove deprecated parameter Oauth2RequirePostResponse
* AADAuthorizationPolicy
  * Fixes an error where the authentication method wasn't recognized when doing an export using app secret.
    FIXES [#3056](https://github.com/microsoft/Microsoft365DSC/issues/3056)
* AADConditionalAccessPolicy
  * Add condition for empty External Guest/User include/exclude
    FIXES [#3108](https://github.com/microsoft/Microsoft365DSC/issues/3108)
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * [BREAKING CHANGE] Remove deprecated parameters IncludeDevices and ExcludeDevices
* AADEntitlementManagementAccessPackage, AADEntitlementManagementAccessPackageAssignmentPolicy,
  AADEntitlementManagementAccessPackageCatalog, AADEntitlementManagementAccessPackageCatalogResource,
  AADEntitlementManagementAccessPackageCatalogResource, AADEntitlementManagementConnectedOrganization,
  AADRoleSetting
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
* AADGroup
  * Changed the SecurityEnabled and MailEnabled parameters to become mandatory.
    FIXES [#3072](https://github.com/microsoft/Microsoft365DSC/issues/3072)
  * Stopped GroupTypes defaulting to 'Unified' to allow creation of Security groups.
    FIXES [#3073](https://github.com/microsoft/Microsoft365DSC/issues/3073)
* AADUser
  * [BREAKING CHANGE] Remove deprecated parameter PreferredDataLocation* EXOAntiPhishPolicy
  * [BREAKING CHANGE] Remove deprecated parameters EnableAntispoofEnforcement and
    TargetedDomainProtectionAction
* EXOGroupSettings
  * Initial Release
    FIXES [#3089](https://github.com/microsoft/Microsoft365DSC/issues/3089)
* EXOHostedContentFilterPolicy
  * [BREAKING CHANGE] Remove deprecated parameters EndUserSpamNotificationCustomFromAddress
    and EndUserSpamNotificationCustomFromName
* EXOIRMConfiguration
  * [BREAKING CHANGE] Renamed unused Identity parameter to IsSingleInstance
    FIXES [#2969](https://github.com/microsoft/Microsoft365DSC/issues/2969)
* EXOMalwareFilterPolicy
  * [BREAKING CHANGE] Remove deprecated parameters Action, CustomAlertText,
    EnableExternalSenderNotifications and EnableInternalSenderNotifications
* EXOManagementRoleAssignment
  * Use Microsoft Graph to retrieve administrative units. This fixes the issue where a soft
    deleted AU was present while a new one got created with the same name.
    FIXES [#3064](https://github.com/microsoft/Microsoft365DSC/issues/3064)
* EXOOrganizationConfig
  * [BREAKING CHANGE] Remove deprecated parameters AllowPlusAddressInRecipients
  * [BREAKING CHANGE] Renamed unused Identity parameter to IsSingleInstance
    FIXES [#2969](https://github.com/microsoft/Microsoft365DSC/issues/2969)
* EXOPerimeterConfiguration
  * [BREAKING CHANGE] Renamed unused Identity parameter to IsSingleInstance
    FIXES [#2969](https://github.com/microsoft/Microsoft365DSC/issues/2969)
* EXOResourceConfiguration
  * [BREAKING CHANGE] Renamed unused Identity parameter to IsSingleInstance
    FIXES [#2969](https://github.com/microsoft/Microsoft365DSC/issues/2969)
* EXOSaveLinksPolicy
  * [BREAKING CHANGE] Remove deprecated parameters DoNotAllowClickThrough,
    DoNotTrackUserClicks and IsEnabled
* EXOSharedMailbox
  * [BREAKING CHANGE] Remove deprecated parameter Aliases
* EXOTransportRule
  * [BREAKING CHANGE] Remove deprecated parameter ExceptIfMessageContainsAllDataClassifications,
    IncidentReportOriginalMail and MessageContainsAllDataClassifications
* IntuneAntivirusPolicyWindows10SettingCatalog, IntuneASRRulesPolicyWindows10,
  IntuneAppProtectionPolicyiOS, IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager,
  IntuneSettingCatalogASRRulesPolicyWindows10
  * [BREAKING CHANGE] Setting Identity as Key parameter and DisplayName as Required
* IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager
  * [BREAKING CHANGE] Fix resource
* IntuneDeviceConfigurationHealthMonitoringConfigurationPolicyWindows10
  * Initial Release
    FIXES [#2830](https://github.com/microsoft/Microsoft365DSC/issues/2830)
* IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10
  * Initial release
* IntuneDeviceConfigurationPolicyAndroidDeviceAdministrator, IntuneDeviceConfigurationPolicyAndroidDeviceOwner,
  IntuneDeviceConfigurationPolicyAndroidOpenSourceProject, IntuneDeviceConfigurationPolicyMacOS,
  IntuneDeviceConfigurationPolicyiOS, IntuneExploitProtectionPolicyWindows10SettingCatalog,
  IntuneWifiConfigurationPolicyAndroidDeviceAdministrator, IntuneWifiConfigurationPolicyAndroidForWork,
  IntuneWifiConfigurationPolicyAndroidOpenSourceProject, IntuneWifiConfigurationPolicyIOS,
  IntuneWifiConfigurationPolicyMacOS, IntuneWifiConfigurationPolicyWindows10,
  IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled, IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * Properly escapes single quotes from CIMInstances string values.
    FIXES [#3117](https://github.com/microsoft/Microsoft365DSC/issues/3117)
* IntuneDeviceConfigurationPolicyWindows10
  * [BREAKING CHANGE] Added complex parameters as embedded CIM (DefenderDetectedMalwareActions, EdgeHomeButtonConfiguration, EdgeSearchEngine, NetworkProxyServer, Windows10AppsForceUpdateSchedule)
  * Resource regenerated with DRG
    FIXES[#2867](https://github.com/microsoft/Microsoft365DSC/issues/2867)
    FIXES[#2868](https://github.com/microsoft/Microsoft365DSC/issues/2868)
* IntuneDeviceEnrollmentPlatformRestriction
  * [BREAKING CHANGE] Updated resource to manage single and default platform restriction policies
    FIXES [#2347](https://github.com/microsoft/Microsoft365DSC/issues/2347)
* IntuneDeviceEnrollmentStatusPageWindows10
  * [BREAKING CHANGE] Renamed resource IntuneDeviceEnrollmentConfigurationWindows10 to IntuneDeviceEnrollmentStatusPageWindows10
  * Added support for property Assignments.
  * Added support for property Priority
    FIXES [#2933](https://github.com/microsoft/Microsoft365DSC/issues/2933)
* IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * [BREAKING CHANGE] Corrected typo in resource name (Entreprise to Enterprise)
    FIXES [#3024](https://github.com/microsoft/Microsoft365DSC/issues/3024)
* IntuneWifiConfigurationPolicyAndroidEnterpriseWorkProfile
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * [BREAKING CHANGE] Corrected typo in resource name (Entreprise to Enterprise)
    FIXES [#3024](https://github.com/microsoft/Microsoft365DSC/issues/3024)
* IntuneWindowsAutopilotDeploymentProfileAzureADJoined
  * Initial release
    FIXES [#2605](https://github.com/microsoft/Microsoft365DSC/issues/2605)
* IntuneWindowsAutopilotDeploymentProfileAzureADHybridJoined
  * Initial release
    FIXES [#2605](https://github.com/microsoft/Microsoft365DSC/issues/2605)
* IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10
  * [BREAKING CHANGE] Setting Id as Key parameter and DisplayName as Required
  * [BREAKING CHANGE] Corrected typo in resource name (Window to Windows)
    FIXES [#3024](https://github.com/microsoft/Microsoft365DSC/issues/3024)
* SCAuditConfigurationPolicy, SCAutoSensitivityLabelPolicy, SCCaseHoldPolicy, SCCaseHoldRule,
  SCComplianceCase, SCComplianceSearch, SCComplianceSearchAction, SCComplianceTag,
  SCDeviceConditionalAccessPolicy, SCDeviceConfigurationPolicy, SCDLPComplianceRule,
  SCFilePlanPropertyAuthority, SCFilePlanPropertyCategory, SCFilePlanPropertyCitation,
  SCFilePlanPropertyDepartment, SCFilePlanPropertyReferenceId, SCFilePlanPropertySubCategory,
  SCLabelPolicy, SCProtectionAlert, SCRetentionCompliancePolicy, SCRetentionComplianceRule,
  SCRetentionEventType, SCSupervisoryReviewPolicy, SCSupervisoryReviewRule
  * Fixed the collection of new and set parameters to ensure the correct values are passed to the New/Set cmdlets.
    FIXES [#3075](https://github.com/microsoft/Microsoft365DSC/issues/3075)
* SCSensitivityLabel
  * [BREAKING CHANGE] Remove deprecated parameters Disabled, ApplyContentMarkingFooterFontName,
    ApplyContentMarkingHeaderFontName, ApplyWaterMarkingFontName and EncryptionAipTemplateScopes
* SPOApp
  * Fixed issue in the Export where an error was displayed in Verbose mode when Credentials were specified
    and the apps were not exported.
* SPOTenantSettings
  * Fixes how we are extracting the DisabledWebPartIds parameter.
    FIXES [#3066](https://github.com/microsoft/Microsoft365DSC/issues/3066)
  * [BREAKING CHANGE] Remove deprecated parameter RequireAcceptingAccountMatchInvitedAccount
* TeamsMeetingPolicy
  * [BREAKING CHANGE] Remove deprecated parameter RecordingStorageMode
* TeamsUpdateManagementPolicy
  * Added support for the new UseNewTeamsClient parameter.
    FIXES [#3062](https://github.com/microsoft/Microsoft365DSC/issues/3062)
* DRG
  * Various fixes
    * Cleanup generated code
    * Fix AdditionalProperties complex constructor
    * Fix Read privileges in settings file
* MISC
  * Fixed an issue `New-M365DSCReportFromConfiguration` where a non existing parameter was used to retrieve the configuration.
  * Improved unit test performance
  * Added a QA check to test for the presence of a Key parameter and fixes
    resources where this was not the case.
    FIXES [#2925](https://github.com/microsoft/Microsoft365DSC/issues/2925)
  * Major changes to the export process where resource instances will now be assigned a meaningful name
    that will follow the ResourceName-PrimaryKey convention.
  * Added a fix making sure that the progress bar "Scanning dependencies" is no longer displayed after the operation is completed.
  * Added a new Set-M365DSCLoggingOption function to enable logging information about non-drifted resources in Event Viewer.
    FIXES [#2981](https://github.com/microsoft/Microsoft365DSC/issues/2981)
  * Updated the Update-M365DSCModule to unload dependencies before updating them and then to reload the new versions.
    FIXES [#3097](https://github.com/microsoft/Microsoft365DSC/issues/3097)
  * Added a new internal function to remove the authentication parameters from the bound paramters. `Remove-M365DSCAuthenticationParameter`
  * Enforcing tenant ID to be in the tenant.onmicrosoft.com form.
    FIXES [#3046](https://github.com/microsoft/Microsoft365DSC/issues/3046)
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 1.25.0.
  * Updated MicrosoftTeams dependency to version 5.1.0.

# 1.23.322.1

* AADRoleSetting
  * Added CertificateThumbPrint and ApplicationId to the output of the Get method
* EXODistributionGroup
  * Fixed an error where the name wasn't properly escaped in the Filter
  FIXES [#3044](https://github.com/microsoft/Microsoft365DSC/issues/3044)
* EXORoleAssignmentPolicy
  * Fix issue with IsDefault parameter
    FIXES [#2977](https://github.com/microsoft/Microsoft365DSC/issues/2977)
* IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10
  * Initial Release
    FIXES [#2832](https://github.com/microsoft/Microsoft365DSC/issues/2832)
* IntuneDeviceConfigurationEndpointProtectionPolicyWindows10
  * Initial release
    FIXES [#2834](https://github.com/microsoft/Microsoft365DSC/issues/2834)
* IntuneDeviceConfigurationIdentityProtectionPolicyWindows10
  * Initial release
    FIXES [#2831](https://github.com/microsoft/Microsoft365DSC/issues/2831)
* SCDLPCompliancePolicy
  * Added support or Endpoint, On-Premises, PowerBI and ThirdPartyApps locations and exceptions.
    FIXES [#3023](https://github.com/microsoft/Microsoft365DSC/issues/3023)
* SCSensitivityLabel
  * Added ContentType parameter, so you can specify where to apply the label.
    FIXES [#2992](https://github.com/microsoft/Microsoft365DSC/issues/2992)
  * Updated the resource to use and apply the correct parameters from the LabelActions
    property.
    FIXES [#3035](https://github.com/microsoft/Microsoft365DSC/issues/3035)
  * Deprecated all FontName properties, since these are no longer configurable.
    FIXES [#3035](https://github.com/microsoft/Microsoft365DSC/issues/3035)
  * Fixed the collection of new and set parameters to ensure the correct values are passed to the New/Set cmdlets.
    FIXES [#3050](https://github.com/microsoft/Microsoft365DSC/issues/3050)
* MISC
  * Added QA test that checks for existence of an example for each resource.
  * Amended output for Convert-M365DscHashtableToString to show each value on a new line
    Fixes[#2980](https://github.com/microsoft/Microsoft365DSC/issues/2980)
* DRG
  * Various fixes:
    * Remove invalid character from description in schema.mof
    * Add Id as key in schema.mof
    * Add DisplayName as Required in schema.mof
    * Fix issue with nested CIM array from test unit
    * Remove Select-MgProfile from module
    * Add DisplayName as Mandatory in module
    * Fix issue with AdditionalProperties for nested objects from module
    * Fix Ensure default value

# 1.23.315.2

* EXORoleGroup
  * Fixes an issue with the Export process where the name of the role wasn't properly set causing errors.

# 1.23.315.1

* AADConditionalAccessPolicy
  * Handle Named Location "Multifactor authentication trusted IPs"
    Fixed [#2974](https://github.com/microsoft/Microsoft365DSC/issues/2974)
  * Export and handle guest and external users.
    Fixed [#2965](https://github.com/microsoft/Microsoft365DSC/issues/2965)
* AADEntitlementManagementConnectedOrganization
  * Initial release
* EXOOrganizationConfig
  * Add support for the MessageRecallEnabled parameter.
    FIXES [#2978](https://github.com/microsoft/Microsoft365DSC/issues/2978)
* EXORoleAssignmentPolicy
  * Allow description and role change at the same time.
    FIXES [#2977](https://github.com/microsoft/Microsoft365DSC/issues/2977)
* EXORoleGroup
  * Initial release
* EXOTransportConfig
  * Ensures the ExternalDsnDefaultLanguage property is correctly escaped.
    FIXES [#2970](https://github.com/microsoft/Microsoft365DSC/issues/2970)
* IntuneAppProtectionPolicyiOS
  * Amended MinimumWipeOSVersion case
    FIXES [#3000](https://github.com/microsoft/Microsoft365DSC/issues/3000)
* PPTenantIsolationSettings
  * Fixes the export of the Rules block which wasn't properly formatted.
    FIXES [#2979](https://github.com/microsoft/Microsoft365DSC/issues/2979)
* SPOTenantSettings
  * Add support for the CommentsOnSitePagesDisabled parameter.
* MISC
  * Added checks in New-M365DSCConnection to ensure beta MSGraph profile is correctly set when requested
    FIXES [#2942](https://github.com/microsoft/Microsoft365DSC/issues/2942)
  * Added all Certificate related property to the returned values of the Get-TargetResource function
    across all Security & Compliance resources.
    FIXES [#2989](https://github.com/microsoft/Microsoft365DSC/issues/2989)
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 1.23.0.
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.156.

# 1.23.308.1

* AADAdministrativeUnit
  * Fixed general issues caused by improper handling of nested CIMInstances
    FIXES #2775, #2776, #2786
  * Updated validation of properties in schema to assist usage
* AADServicePrincipal
  * Change Write-Error to Write-Verbose to make sure the Test method will continue
    FIXES [#2961](https://github.com/microsoft/Microsoft365DSC/issues/2961)
* EXOManagementRoleAssignment
  * Added delays before disconnecting from EXO to ensure new permissions are applied.
    FIXES [#2523](https://github.com/microsoft/Microsoft365DSC/issues/2523)
* O365AdminAuditLogConfig
  * Added support for ManagedIdentity.
  * Fixed the Get-TargetResource method to return all authentication parameters.
* DRG
  * Fixed the default settings for the Ensure parameter.
* MISC
  * Updated logic for drift detection to be case insensitive.
    FIXES [#2873](https://github.com/microsoft/Microsoft365DSC/issues/2873)
  * Changed the -Platform parameter for Connect-M365Tenant to -Workload in 2 remaining places.
    FIXES [#2921](https://github.com/microsoft/Microsoft365DSC/issues/2921)
  * Added QA test to validate if used permissions in Settings.json files
    actually exist.
  * Added application credential support to Assert-M365DSCBlueprint
    FIXES [#1792](https://github.com/microsoft/Microsoft365DSC/pull/1792)
  * Updated/added various examples
* DEPENDENCIES
  * Updated MicrosoftTeams to version 5.0.0

# 1.23.301.1

* IntuneDeviceEnrollmentConfigurationWindows10
  * Fix settings.json
    FIXES [#2930](https://github.com/microsoft/Microsoft365DSC/issues/2930)
* O365OrgSettings
  * Adds support for Cortana enabling.
* SCLabelPolicy
  * Added more detailed logging
  * Converting the GUIDs of all defaultlabel settings in the AdvancedSettings
    parameters to the actual label name, since the GUID is different per
    environment
    FIXES [#2840](https://github.com/microsoft/Microsoft365DSC/issues/2840)
  * Fixed issue where the Test method resulted in False on any existing policy
    FIXES [#2948](https://github.com/microsoft/Microsoft365DSC/issues/2948)
* SCSensitivityLabel
  * Added more detailed logging
  * Fixed issue where the Test method always tested false when the LocaleSettings
    property was used
    FIXES [#2949](https://github.com/microsoft/Microsoft365DSC/issues/2949)
  * Fixes issues around Test-TargetResource always returning False when encryption parameters are used.
    FIXES [#2683](https://github.com/microsoft/Microsoft365DSC/issues/2683)
* SPOUserProfileProperty
  * Fixes the required API permissions in the documentation.
    FIXES [#2798](https://github.com/microsoft/Microsoft365DSC/issues/2798)
* TeamsOnlineVoiceUser
  * Fix issue where the cmdlet Get-CsOnlineVoiceUser is now deprecated.
* MISC
  * Updated unit tests
  * Added quality check tests
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.22.0
  * Updated MSCloudLoginAssistant to version 1.0.105
  * Updated ReverseDSC to version 2.0.0.14

# 1.23.222.1

* AADEntitlementManagementAccessPackageAssignmentPolicy
  * Initial release
* IntuneDeviceEnrollmentConfigurationWindows10
  * Initial release
    FIXES [#2829](https://github.com/microsoft/Microsoft365DSC/issues/2829)
* IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10
  * Initial release.
    FIXES [#2658](https://github.com/microsoft/Microsoft365DSC/issues/2658)
* IntuneWindowUpdateForBusinessRingUpdateProfileWindows10
  * Initial release.
    FIXES [#2657](https://github.com/microsoft/Microsoft365DSC/issues/2657)
* PPPowerAppsEnvironment
  * Added all the latest location return from Get-AdminPowerAppEnvironmentLocations
* TeamsChannelTab
  * Updated key parameters to prevent detected duplicates
    FIXES [#2897](https://github.com/microsoft/Microsoft365DSC/issues/2897)
* DRG
  * Various fixes
* MISC
  * Updated Tasks.Read and Tasks.ReadWrite Permissions for Planner Plans and Planner Buckets
    FIXES [#2866](https://github.com/microsoft/Microsoft365DSC/issues/2866)
  * Fixed Permissions Scopes for AADAuthorizationPolicy and AADSecurityDefaults

# 1.23.215.1

* EXOIRMConfiguration
  * Fixed issue where the export did not the correct type for RMSOnlineKeySharingLocation
    FIXES [#2890](https://github.com/microsoft/Microsoft365DSC/issues/2890)
* IntuneRoleAssignment
  * Fixed issue where the export did not the correct type for ScopeType
    FIXES [#2889](https://github.com/microsoft/Microsoft365DSC/issues/2889)
* O365OrgSettings
  * Initial Release.
* TeamsChannelTab
  * Updated key parameters to prevent detected duplicates
    FIXES [#2897](https://github.com/microsoft/Microsoft365DSC/issues/2897)
* MISC
  * Updated required permissions of several resources
    FIXES [#2866](https://github.com/microsoft/Microsoft365DSC/issues/2866)
  * Added filter to Update-M365DSCAzureAdApplication to be more specific.
    FIXES [2565](https://github.com/microsoft/Microsoft365DSC/issues/2565)
  * Fixed the JSON conversion depth for the New-M365DSCConfigurationToJSON cmdlet.
    FIXES [#2891](https://github.com/microsoft/Microsoft365DSC/issues/2891)
  * Added new ParameterSet for Export-M365DSConfiguration
    FIXES [[#2802](https://github.com/microsoft/Microsoft365DSC/issues/2802)]

# 1.23.208.1

* TeamsTenantTrustedIPAddress
  * Initial Release.

# 1.23.201.1

* IntuneDeviceCompliancePolicyWindows10
  * Updated example
* IntuneDeviceConfigurationPolicyWindows10
  * Updated example
* PlannerTask
  * Fixed issue where Attachments Uri weren't properly exiting single quotes.
    FIXES [#2822](https://github.com/microsoft/Microsoft365DSC/issues/2822)
* PPPowerAppsEnvironment
  * Adds support for Developer SKU and fix for Teams SKU
    FIXES [#2821](https://github.com/microsoft/Microsoft365DSC/issues/2821)
* SCProtectionAlert
  * Support for certificate based auth
  * Fix removal of alert
  * Added additional supported values for ThreatType, Severity & AggregationType
    FIXES [#2793](https://github.com/microsoft/Microsoft365DSC/issues/2793)
* TeamsTenantNetworkRegion
  * Initial Release.
* TeamsTenantNetworkSite
  * Initial Release.
* TeamsTenantNetworkSubnet
  * Initial Release.
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.21.0
  * Updated MicrosoftTeams to version 4.9.3
* MISC
  * Corrected Ensure parameter logic for many resources.
    Removed requirement for Ensure=Present only.
    FIXES [#2718](https://github.com/microsoft/Microsoft365DSC/issues/2718)
  * Updated documentation to reflect new authentication possibilities
    FIXES [#2863](https://github.com/microsoft/Microsoft365DSC/issues/2863)

# 1.23.125.1

* TeamsAudioConferencingPolicy
  * Initial Release.
* TeamsCallHoldPolicy
  * Initial Release.
* TeamsCallParkPolicy
  * Initial Release.
* TeamsComplianceRecordingPolicy
  * Initial Release.
* TeamsCortanaPolicy
  * Initial Release.
* TeamsEnhancedEncryptionPolicy
  * Initial Release.
* TeamsMobilityPolicy
  * Initial Release.
* TeamsNetworkRoamingPolicy
  * Initial Release.
* TeamsTranslationRule
  * Initial Release.
* TeamsUnassignedNumberTreatment
  * Initial Release.
* TeamsVDIPolicy
  * Initial Release.
* TeamsWorkloadPolicy
  * Initial Release.
* DRG
  * Added CIM constructor in Get-TargetResource
  * Improved management of AdditionalProperties
  * Improved datetime and dateoffset management
  * Fixed UnitTest
  * Generate Stubs if required
  * Fixes #2819
* IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled
  * Initial Release
  * Fixes #2604
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.155.
* Planner
  * Fixed api-permissions on PlannerBucket and PlannerPlan.
    FIXES [#2843](https://github.com/microsoft/Microsoft365DSC/issues/2843)

# 1.23.118.1

* IntuneAppConfigurationPolicy
  * Fixes issue where the Test method fails when the policy does not exist yet
    and the Assignments parameter is used.
    FIXES [#2768](https://github.com/microsoft/Microsoft365DSC/issues/2768)
* IntuneDeviceAndAppManagementAssignmentFilter
  * Fixes issue where the code did not check for the DisplayName when the ID could not
    be found.
    FIXES [#2788](https://github.com/microsoft/Microsoft365DSC/issues/2788)
* IntuneDeviceConfigurationPolicyMacOS
  * Corrected copy/paste issue while implementing previous fix.
    FIXES [#2731](https://github.com/microsoft/Microsoft365DSC/issues/2731)
* IntuneRoleDefinition
  * Fixes issue where the code did not check for the DisplayName when the ID could not
    be found.
    FIXES [#2771](https://github.com/microsoft/Microsoft365DSC/issues/2771)
  * Updated logging logic to include more details and add Current/Target values in the
    Test method.
* PlannerTask
  * Refactored to leverage the official cmdlets instead of using the legacy GraphHandlers.
    FIXES [#2767](https://github.com/microsoft/Microsoft365DSC/issues/2767)
  * Changed Export-TargetResource to call Get-M365DSCExportContentForResource
    to simplify/conform + variables for authentication are added correctly
    FIXES [#2784](https://github.com/microsoft/Microsoft365DSC/issues/2784)
* SCRetentionCompliancePolicy
  * Fixes an issue where the SkypeLocation was trying to be converted to a string when it was an array.
    FIXES [#2789](https://github.com/microsoft/Microsoft365DSC/issues/2789)
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.20.0
  * Updated MSCloudLoginAssistant to version 1.0.103

# 1.23.111.1

* AADAdministrativeUnit
  * Marks DisplayName as a mandatory key and removed the visibility parameter from being evaluated since it is always returned as null.
  FIXES [#2704](https://github.com/microsoft/Microsoft365DSC/issues/2704)
* AADConditionalAccessPolicy
  * Removed the extra Microsoft Graph profile switching call which was causing performance issue.
    FIXES [#2688](https://github.com/microsoft/Microsoft365DSC/issues/2688)
* TeamsFederationConfiguration
  * Add parameters: TreatDiscoveredPartnersAsUnverified, SharedSipAddressSpace, RestrictTeamsConsumerToExternalUserProfiles.
* TeamsFeedbackPolicy
  * Initial Release
* TeamsGroupPolicyAssignment
  * Initial Release
* MISC
  * Adds Service Principal (Thumbprint and Secret) support to the Power Apps workload.
  * Refactored the way we are switching Microsoft Graph Profiles across all resources.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 3.1.0
  * Updated MSCloudLoginAssistant to version 1.0.102

# 1.23.104.1

* EXODistributionGroup
  * Changed the logic retrieving the group Type in the Get-TargetResource.
    FIXES [#2709](https://github.com/microsoft/Microsoft365DSC/issues/2709)
* EXOManagementRoleAssignment
  * Modified logic to handle the RecipientOrganizationUnitScope parameter by display name.
    FIXES [#2708](https://github.com/microsoft/Microsoft365DSC/issues/2708)
* IntuneASRRulesPolicyWindows10
  * Corrects possible values for parameter OfficeCommunicationAppsLaunchChildProcess
    FIXES [#2730](https://github.com/microsoft/Microsoft365DSC/issues/2730)
* IntuneDeviceConfigurationPolicyMacOS
  * Fixes issue where parameter UpdateDelayPolicy wasn't handled as an array
    FIXES [#2731](https://github.com/microsoft/Microsoft365DSC/issues/2731)
* IntuneDeviceConfigurationPolicyWindows10
  * Fixed incorrect type of EdgeEnterpriseModeSiteListLocation parameter in the
    resource schema definition
    FIXES [#2732](https://github.com/microsoft/Microsoft365DSC/issues/2732)
* SCRetentionCompliancePolicy
  * Forces changes to existing policies to be applied.
    FIXES [#2719](https://github.com/microsoft/Microsoft365DSC/issues/2719)
  * Handles wait when the associated policy has pending changes.
    FIXES [#2728](https://github.com/microsoft/Microsoft365DSC/issues/2728)
* SCRetentionComplianceRule
  * Handles wait when the associated policy has pending changes.
    FIXES [#2728](https://github.com/microsoft/Microsoft365DSC/issues/2728)
* TeamsEmergencyCallingPolicy
  * Fixes issue where CertificateThumbprint wasn't working because Credential was set to mandatory by the Test-TargetResource function.
    FIXES [#2710](https://github.com/microsoft/Microsoft365DSC/issues/2710)
* TeamsEmergencyCallingRoutingPolicy
  * Fixes issue where CertificateThumbprint wasn't working because Credential was set to mandatory by the Test-TargetResource function.
    FIXES [#2710](https://github.com/microsoft/Microsoft365DSC/issues/2710)
* TeamsIPPhonePolicy
  * Added descriptions to the resource parameters
  * Limited possible parameter values where required
    FIXES [#2722](https://github.com/microsoft/Microsoft365DSC/issues/2722)
* TeamsMeetingPolicy
  * Deprecating RecordingStorageMode parameter, which is no longer available.
    FIXES [#2723](https://github.com/microsoft/Microsoft365DSC/issues/2723)
* TeamsShiftsPolicy
  * Added descriptions to the resource parameters
  * Limited possible parameter values where required
    FIXES [#2722](https://github.com/microsoft/Microsoft365DSC/issues/2722)
* TeamsFilesPolicy
  * Added descriptions to the resource parameters
  * Limited possible parameter values where required
    FIXES [#2722](https://github.com/microsoft/Microsoft365DSC/issues/2722)
* DRG
  * Various fixes for Graph and Intune resources automation
  * Migrated to new schema including description
  * Added support to generate parameter descriptions automatically from schema
    FIXES [#2720](https://github.com/microsoft/Microsoft365DSC/issues/2720)
* MISC
  * Fixes an issue where OrderedDictionary values weren't properly expanded in a delta report
    FIXES [#2715](https://github.com/microsoft/Microsoft365DSC/issues/2715)
  * Updated website generation code to checkout correct commit

# 1.22.1221.1

* AADGroup
  * Extraction no longer exports Distribution List or mail enabled security list since these are not supported by the Microsoft Graph API.
    FIXES [#2587](https://github.com/microsoft/Microsoft365DSC/issues/2587)
* EXOMailContact
  * Ensures all results are returned from the Export scenario. Currently limited at 1,000 results.
    FIXES [#2672](https://github.com/microsoft/Microsoft365DSC/issues/2672)
    FIXES [#2673](https://github.com/microsoft/Microsoft365DSC/issues/2672)
* EXOManagementRoleAssignment
  * Force refresh permissions after the Set-TargetResource is called to ensure the correct cmdlets are loaded in the session.
    FIXES [#2523](https://github.com/microsoft/Microsoft365DSC/issues/2523)
* SCSensitivityLabel
  * Removed the EncryptionAipTemplateScopes parameter from being evaluated in the Test and removed it from the update scenario in the Set.
    FIXES [#2205](https://github.com/microsoft/Microsoft365DSC/issues/2205)
* SCProtectionAlert
  * Initial Release
* TeamsFilesPolicy
  * Initial Release
* TeamsIPPhonePolicy
  * Initial Release
* TeamsShiftsPolicy
  * Initial Release
* MISC
  * Fixed a typo in the reporting logic that caused issue evaluating certain resources in the NEw-M365DSCDelaaReport function
    FIXES [#2685](https://github.com/microsoft/Microsoft365DSC/issues/2685)
  * Added support for the ExcludedProperties parameter in the Assert-M365DSCBlueprint function.
    FIXES [#2671](https://github.com/microsoft/Microsoft365DSC/issues/2671)
  * Updated Get-M365DSCCompiledPermissionList to output all permissions consistently.
    It can now also be used as input for Update-M365DscAzureAdApplication.
  * Fixes issue where the wrong parameter is being passed to the Erro log function.
    FIXES [#2682](https://github.com/microsoft/Microsoft365DSC/issues/2682)
  * Updated automatic website documentation generation
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.19.0;
  * Updated MSCloudLoginAssistant to version 1.0.101;

# 1.22.1214.1

* AADEntitlementManagementAccessPackageCatalogResource
  * Fixes an issue where if no access resource were defined, an error was thrown trying to save the partial content.
    FIXES [#2654](https://github.com/microsoft/Microsoft365DSC/issues/2654)
* AADGroup
  * Fixes an issue where licenses aren't properly assigned when no existing licenses exist.
    FIXES [#2597](https://github.com/microsoft/Microsoft365DSC/issues/2597)
  * Fixes an issue where if a dirft is detected and the Members parameter was omitted, all existing members were removed.
    FIXES [#2481](https://github.com/microsoft/Microsoft365DSC/issues/2481)
* AADServicePrincipal
  * Fixes an issue where the service principals weren't created or updated when using ApplicationSecret to authenticate.
    FIXES [#2615](https://github.com/microsoft/Microsoft365DSC/issues/2615)
* AADUser
  * Fixes an issue where provided password wa never honored.
    FIXES [#2599](https://github.com/microsoft/Microsoft365DSC/issues/2599)
  * Added support for the PasswordPolicies property.
    FIXES [#2598](https://github.com/microsoft/Microsoft365DSC/issues/2598)
* PlannerBucket & PlannerPlan
  * Changed invalid permissions in the setting.json files.
    FIXES [#2629](https://github.com/microsoft/Microsoft365DSC/issues/2629)
* SCRetentionComplianceRule
  * Fixed an Issue where properties weren't properly set at creation, causing drifts to be detected.
    FIXES [#2471](https://github.com/microsoft/Microsoft365DSC/issues/2471)
* SCSensitivityLabel
  * Adds the -IncludeDetailed LAbelActions switch when retrieving instances to get all advanced parameters from the Get-TargetResource function.
* SPOTenantCdnEnabled
  * Fixed an issue where the export wasn't returning anything if the CDN was not enabled.
    FIXES [#2466](https://github.com/microsoft/Microsoft365DSC/issues/2466)
* SPOUserProfileProperty
  * Removed multi-threading to align with other resources.
  * Fixed an issue where we were contacting Microsoft Graph to retrieve users without authenticating to it.
    FIXES [#2643](https://github.com/microsoft/Microsoft365DSC/issues/2643)
* TeamsChannel
  * Fixes an issue where channels weren't created if a non-existing GroupId was specified.
    FIXES [#2622](https://github.com/microsoft/Microsoft365DSC/issues/2622)
* TeamsUpdateManagementPolicy
  * Fixed error with the export that wasn't properly returning the UpdateTimeOfDay if not in short time string format.
    FIXES [#2639](https://github.com/microsoft/Microsoft365DSC/issues/2639)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.100;
    FIXES [#2484](https://github.com/microsoft/Microsoft365DSC/issues/2484)
* MISC
  * Added support for the ExcludedProperties parameter in the New-M365DSCDeltaReport function.
    FIXES [#2444](https://github.com/microsoft/Microsoft365DSC/issues/2444)

# 1.22.1207.1

* IntuneRoleAssignment
  * Add support for ScopeType enabling the use of AllLicensedUser/AllDevice as Scope
* TeamsChannelsPolicy
  * Renamed the AllowPrivateTeamsDiscovery parameter to EnablePrivateTeamDiscovery.
* TeamsChannelTab
  * Added support for Credential and refactored to call into the Microsoft Graph PowerShell SDK directly.
* TeamsMeetingPolicy
  * Added support for several new properties:
    * AllowAnnotations
    * AllowAnonymousUsersToJoinMeeting
    * AllowMeetingCoach
    * AllowMeetingRegistration
    * AllowNetworkConfigurationSettingsLookup
    * AllowWatermarkForCameraVideo
    * AllowWatermarkForScreenSharing
    * NewMeetingRecordingExpirationDays
    * AllowCartCaptionsScheduling
    * AllowDocumentCollaboration
    * AllowedStreamingMediaInput
    * BlockedAnonymousJoinClientTypes
    * ChannelRecordingDownload
    * ExplicitRecordingConsent
    * ForceStreamingAttendeeMode
    * InfoShownInReportMode
    * LiveInterpretationEnabledType
    * LiveStreamingMode
    * MeetingInviteLanguages
    * QnAEngagementMode
    * RoomPeopleNameUserOverride
* SPOBrowserIdleSignout
  * Fixed incorrect Ensure parameter being added to the Export
    FIXES [#2619](https://github.com/microsoft/Microsoft365DSC/issues/2619)
* SPOSiteAuditSettings
  * Fixed incorrect Ensure parameter being added to the Export
    FIXES [#2619](https://github.com/microsoft/Microsoft365DSC/issues/2619)
* MISC
  * Standardized and improved logging across all resources.
  * Improved error handling in creating output when permissions are not correct.
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.18.0;

# 1.22.1130.1

* SCRetentionCompliancePolicy
  * Fixed an issue with the Update logic in the Set-TargetResource
    FIXES [#2600](https://github.com/microsoft/Microsoft365DSC/issues/2600)

# 1.22.1123.1

* IntuneDeviceConfigurationPolicyWindows10
  * Fixed issue when creating this resource if property DefenderDetectedMalwareActions was not present, it'd still be created but with errors.
    FIXES [#2581](https://github.com/microsoft/Microsoft365DSC/issues/2581)
* AADUser
  * Fixed issue with license assignment
    FIXES [#2556](https://github.com/microsoft/Microsoft365DSC/issues/2556)
* EXOOrganizationRelationship
  * Add 'None' as supported value for MailboxMoveCapability
    FIXES [#2570](https://github.com/microsoft/Microsoft365DSC/issues/2570)
* IntuneRoleDefinition
  * Initial Release
  * Manage Intune Role definition
* IntuneRoleAssignment
  * Initial Release
  * Manage Intune Role assignment
* O365AdminAuditLogConfig
  * Updated settings.json to include permissions.
    FIXES [#2517](https://github.com/microsoft/Microsoft365DSC/issues/2517)
* O365OrgCustomizationSetting
  * Updated settings.json to include permissions.
    FIXES [#2517](https://github.com/microsoft/Microsoft365DSC/issues/2517)
* SCDLPCompliancePolicy
  * Fixes an issue where the Exchange Location and Exception where not sent back in a correct format during Export.
    FIXES [#2545](https://github.com/microsoft/Microsoft365DSC/issues/2545)
* SCRetentionCompliancePolicy
  * Fixes issue with the TeamsChannelLocation and TeamsChatsLocation parameters that were improperly returned by the Get- function.
    FIXES [#2472](https://github.com/microsoft/Microsoft365DSC/issues/2472)
* SCRetentionComplianceRule
  * Fixes issue with Teams Policy where the RetentionDurationDisplayHint and ExpirationDateOption parameters weren't returned by the Get- function.
    FIXES [#2472](https://github.com/microsoft/Microsoft365DSC/issues/2472)
* TeamsFederationConfiguration
  * Fixes an issue where the extraction of allowed domain and blocked domain wasn't in the proper format.
    FIXES [#2576](https://github.com/microsoft/Microsoft365DSC/issues/2576)
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.17.0;
  * Updated MSCloudLoginAssistant to version 1.0.98;
* MISC
  * Removed Test-M365DSCDependenciesForNewVersions from export functions. This will improve export speed.
  * New Parameter `ValidateOnly` for Update-M365DSCDependencies to check if all dependencies are installed.
    FIXES [2519](https://github.com/microsoft/Microsoft365DSC/issues/2519)
  * Fixed incorrect usage of Write-Information cmdLet
  * Fixed typos for permissions in settings.json
    FIXES [2553](https://github.com/microsoft/Microsoft365DSC/issues/2553)

# 1.22.1116.1

* AADApplication
  * Deprecated the Oauth2RequirePostResponse parameter as it was causing issues for the New function.
    FIXES [#2276](https://github.com/microsoft/Microsoft365DSC/issues/2276)
* AADEntitlementManagementAccessPackage
  * Initial Release.
* EXOManagementRoleAssignment
  * Added support for RoleGroup Role Assignees
    Fixes [#2524](https://github.com/microsoft/Microsoft365DSC/issues/2524)
* SCRetentionCompliancePolicy
  * Fixes the Location parameters to be a string array instead of an object array.
    FIXES [#2503](https://github.com/microsoft/Microsoft365DSC/issues/2503)
* MISC
  * Added Application based authentication to Microsoft Teams resources;
  * Added support for Service Principal Auth for the Planner resources;
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.16.0;
  * Updated Microsoft.Teams to version 4.9.1;
  * Updated PnP.PowerShell to version 1.12.0;

# 1.22.1109.1

* EXODataClassification
  * FIXES [#2487](https://github.com/microsoft/Microsoft365DSC/issues/2487)
* EXOHostedOutboundSpamFilterPolicy
  * Add support to create and remove Hosted Outbound Spam Filter Policies
  * FIXES [#2492](https://github.com/microsoft/Microsoft365DSC/issues/2492)
* IntuneAntivirusPolicyWindows10SettingCatalog
  * FIXES [#2463](https://github.com/microsoft/Microsoft365DSC/issues/2463)
  * Returns all type of policies from the template family: endpointSecurityAntivirus
* MISC
  * Fixes and issue with ManagedIdentity Parameter not being not removed correctly in a parameterset.
    * FIXES [#2464](https://github.com/microsoft/Microsoft365DSC/issues/2464)
* DEPENDENCIES
  * Updated Microsoft.Graph.* to version 1.15.0;

# 1.22.1102.1

* AADAdministrativeUnit
  * Initial Release.
* AADEntitlementManagementAccessPackageCatalogResource
  * Initial release;
* DEPENDENCIES
  * Updated MicrosoftTeams to version 4.9.0;
  * Updated MSCloudLoginAssistant to version 1.0.97;

# 1.22.1026.2

* MISC
  * Fixes an issue with the export where the ApplicationSecret was throwing an empty string error when trying to authenticate with Certificate thumbprint.
    * FIXES [#2455](https://github.com/microsoft/Microsoft365DSC/issues/2455)

# 1.22.1026.1

* AADEntitlementManagementAccessPackageCatalog
  * Initial release;
* EXOIntraOrganizationConnector
  * Add TargetSharingEpr parameter
* EXOOwaMailboxPolicy
  * Add 10 new parameters
* EXOTransportRule
  * Add new parmeters: ApplyRightsProtectionCustomizationTemplate, Quarantine, RecipientAddressType, RemoveRMSAttachmentEncryption
  * Deprecated parameters: ExceptIfMessageContainsAllDataClassifications, IncidentReportOriginalMail,MessageContainsAllDataClassifications
* TeamsDialInConferencingTenantSettings
  * Initial release;
    Fixes [#2426](https://github.com/microsoft/Microsoft365DSC/issues/2426)
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.96;
* MISC
  * Add support for ManagedIdentity to the SPO and OD resources.
  * Fixed and issue with Export and ApplicationSecret where it wasn't properly converting to a PSCredential.
    * FIXES [#2447](https://github.com/microsoft/Microsoft365DSC/issues/2447)

# 1.22.1019.1

* AADConditionalAccessPolicy
  * Fixed issue where if ExcludePlatforms was specified and the IncludePlatforms is empty, we need to set the latest to 'all';
  FIXES [#2337](https://github.com/microsoft/Microsoft365DSC/issues/2337)
* EXOAntiPhishPolicy
  * Add new parameters: MailboxIntelligenceQuarantineTag, SpoofQuarantineTag, TargetedDomainQuarantineTag, TargetedUserQuarantine
* EXOHostedContentFilterPolicy
  * Add support for quarantine tags
* EXOOrganizationRelationship
  * Add support for new cross-tenant mailbox migration parameters: MailboxMoveCapability, MailboxMovePublishedScopes, OauthApplicationId
* EXOOutboundConnector
  * Add support for SenderRewritingEnabled parameter
* EXORemoteDomain
  * Add NDREnabled parameter
* EXOSafeAttachmentPolicy
  * Add support for QuarantineTag
* EXOSafeLinksPolicy
  * Add new parameters: AllowClickThrough, EnableSafeLinksForOffice, TrackClicks
* TeamsCallingPolicy
  * Add new parameters: AllowCallRedirect, AllowSIPDevicesCalling, CallRecordingExpirationDays
* TeamsEmergencyCallingPolicy
  * Add new parameters: EnhancedEmergencyServiceDisclaimer, ExternalLocationLookupMode
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.154.
* MISC
  * Added support to register, list and remove custom notification endpoints.
  * Fixes issue with delta report where wrong primary key was detected.
    FIXES [#2008](https://github.com/microsoft/Microsoft365DSC/issues/2008)
  * Fixed an issue where the log engine was throwing an error when trying to write to the event log from an Azure runbook.
    FIXES [#2236](https://github.com/microsoft/Microsoft365DSC/issues/2236)
  * Standardizing the functions to test versions of the module and dependencies.
    FIXES [#2232](https://github.com/microsoft/Microsoft365DSC/issues/2232)
  * Remove the Assert-M365DSCTemplate cmdlet that has been deprecated for several releases.
  * Added support to generate report in JSON format for the New-M365DSCDeltaReport and Assert-M365DSCBlueprint cmdlets.
    FIXES [#2345](https://github.com/microsoft/Microsoft365DSC/issues/2345)
  * Changed the default behavior of the New-M365DSCDeltaReport cmdlet not to automatically open the file when OutputPath is provided

# 1.22.1012.1

* EXOManagementRoleAssignment
  * Initial Release
  FIXES [#2355](https://github.com/microsoft/Microsoft365DSC/issues/2355)
  FIXES [#2356](https://github.com/microsoft/Microsoft365DSC/issues/2356)
* SCRetentionCompliancePolicy
  * Fixed issue where the locations weren't properly returned.
  FIXES [#2338](https://github.com/microsoft/Microsoft365DSC/issues/2338)
  FIXES [#2339](https://github.com/microsoft/Microsoft365DSC/issues/2339)
* TeamsOnlineVoicemailPolicy
  * Initial Release
* TeamsOnlineVoicemailUserSettings
  * Initial Release
* TeamsOnlineVoiceUser
  * Initial Release
* TeamsUserCallingSettings
  * InitialRelease
* EXOOrganizationConfig
  * Added 35 new parameters.
  * Set AllowPlusAddressInRecipients parameter to deprecated. Use DisablePlusAddressInRecipients instead.
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 1.13.0.
  * Updates MicrosoftTeams to version 4.8.0;
  * Updated ReverseDSC to version 2.0.0.13;
  FIXES [#2270](https://github.com/microsoft/Microsoft365DSC/issues/2270)
* MISC
  * EXO Workload
    * Add support for Managed Identity authentication
  * Fixed an issue in in Export-M365DSCConfiguration when used with Service Principal
    FIXES [2374](https://github.com/microsoft/Microsoft365DSC/issues/2374)
    FIXES [2379](https://github.com/microsoft/Microsoft365DSC/issues/2379)
  * Added support for Exchange to the Update-M365DSCAzureAdApplication cmdlet
  * Fixes an issue where filters were ignored on export when specifying the Workloads parameter.

# 1.22.1005.1

* AADUser
  * Renamed from O365User
  * Added support for Roles.
    FIXES [#2288](https://github.com/microsoft/Microsoft365DSC/issues/2288)
* AADGroup
  * Added properties MemberOf and AssignedToRole
    Implements [#2301](https://github.com/microsoft/Microsoft365DSC/issues/2301)
* AADTenantDetails
  * Fixed an issue where ApplicationSecret was send to Update-MgOrganization
  * FIXES [[#2340](https://github.com/microsoft/Microsoft365DSC/issues/2340)]
* EXOATPPolicyForO365
  * [BREAKING] Removed the deprecated BlockURLs, AllowClickThrough, EnableSafeLinksForO365Clients and TrackClicks parameters.
* EXOMailContact
  * Initial Release.
* EXOMailTips
  * Fixes an issue where MailTips weren't extracted when using CertificateThumbprint to authenticate.
    FIXES [#2235](https://github.com/microsoft/Microsoft365DSC/issues/2235)
* O365User
  * [BREAKING] Resource was renamed to AADUser.
    FIXES [#2204](https://github.com/microsoft/Microsoft365DSC/issues/2204)
* IntuneDeviceConfigurationPolicyiOS
  * [Breaking] Changed all the MediaContentRating properties to be CIMInstances.
    FIXES [#1871](https://github.com/microsoft/Microsoft365DSC/issues/1871)
* SCSensitivityLabel
  [BREAKING] Changed Setting attribute in MSFT_SCLabelLocaleSettings to LabelSetting since its resevered word and breaking reporting.
    FIXES #2314
* MISC
  * [BREAKING] Authentication property ApplicationSecret has been changed across all resources to be of type
    PSCredential instead of string. This will ensure that the secrets get encrypted in MOF files
    when compiling with an encryption certificated instead of being exposed as plaintext.
    FIXES [#1714](https://github.com/microsoft/Microsoft365DSC/issues/1714)
  * Fixes issue with DSCParser non-existing resources on one tenant weren't properly captured.
* DEPENDENCIES
  * Updated Microsoft.Graph dependencies to version 1.12.3.
  * Updated MSCloudLoginAssistant dependency to version 1.0.94.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.153.
  * Added new dependency on Microsoft.Graph.Users.Actions.

# 1.22.921.1

* AADRoleSetting
  * Fixed an issue if the P2 License is not present on the tenant the Export stop working
    FIXES [#2227](https://github.com/microsoft/Microsoft365DSC/issues/2227)
  * Fixed an issue with approver can be a group
    FIXES [#2283](https://github.com/microsoft/Microsoft365DSC/issues/2283)
* AADConditionalAccessPolicy
  * Added support for the CustomAuthenticationFactors parameter.
  FIXES [#2292](https://github.com/microsoft/Microsoft365DSC/issues/2292)
* O365User
  * Improved extraction performance by leveraging StringBuilder instead of re-assigning string.
* SCAutoSensitivityLabelPolicy
  * Initial Release.
* SCAutoSensitivityLabelRule
  * Initial Release.
* DEPENDENCIES
  * Updated the ExchangeOnlineManagement dependency to version 3.0.0.
  * Updated the MSCloudLoginAssistant dependency to version 1.0.89.

# 1.22.914.1

* AADGroup
  * Changed behavior where if a group has a dynamic membership rule that is active,
    we no longer process members from the export, Get and Set functions.
    FIXES [#2190](https://github.com/microsoft/Microsoft365DSC/issues/2190)
  * Fixed an issue where if the licenses parameter was omitted and another parameter caused
    a drift, that the licenses would get stripped from the group.
    FIXES [#2191](https://github.com/microsoft/Microsoft365DSC/issues/2191)
* AADRoleSetting
  * Fixed an issue where the export wasn't properly passing credential to the Get function.
* TeamsCallingPolicy
  * Added UserOverride as an accepted value for the BusyOnBusyEnabledType parameter.
  FIXES [#2271](https://github.com/microsoft/Microsoft365DSC/issues/2271)

# 1.22.907.1

* EXODistributionGroup
  * Fixes warning issue regarding OrganizationalUnit property
    FIXES [#2252]
* SCRetentionCompliancePolicy
  * Fixes an issue where the TeamsChatLocation, TeamsChatLocationException, TeamsChannelLocation
    and TeamsChannelLocationException properties were not properly set on Update.
    FIXES #2173
* SCRetentionComplianceRule
  * Fixes an issue when trying to create new compliance rule for Teams based policies where invalid
    parameters were passed.
    FIXES #2181
* DEPENDENCIES
  * Updated MicrosoftTeams dependency to version 4.7.0.
* MISC
  * Update settings.json for all SharePoint resources to add SharePoint specific permissions
    FIXES [#2240]
  * Updated website pages with new information (cmdlet and resource documentation)

# 1.22.831.1

* EXOAddressList
  * Ignore precanned filters if recipient filter is used. Precanned filters and recipient filter cannot be used at the same time.
    FIXES [#2194](https://github.com/microsoft/Microsoft365DSC/issues/2194)
* EXOSafeLinksPolicy
  * Add Support for EnableSafeLinksForEmail and DisableUrlRewrite
* EXOInboundConnector
  * Add support for different syntax of SenderDomains parameter
  FIXES [#2180](https://github.com/microsoft/Microsoft365DSC/issues/2180)
* IntuneDeviceConfigurationPolicyAndroidDeviceAdministrator
  * Don't export all policies if none match the type
* IntuneDeviceConfigurationPolicyAndroidOpenSourceProject
  * Don't export all policies if none match the type
  FIXES [#2228](https://github.com/microsoft/Microsoft365DSC/issues/2228)
* PlannerBucket
  * Changed authentication method to Credentials only, since the Planner Graph API
    does not support anything else
  FIXES [#1979](https://github.com/microsoft/Microsoft365DSC/issues/1979)
  * Fixes issue with generating Export output
  FIXES [#2032](https://github.com/microsoft/Microsoft365DSC/issues/2032)
* PlannerPlan
  * Fix export issue where the export wasn't created correctly because of the
    use of an incorrect property name.
  * Changed authentication method to Credentials only, since the Planner Graph API
    does not support anything else
  FIXES [#1979](https://github.com/microsoft/Microsoft365DSC/issues/1979)
* PlannerTask
  * Changed authentication method to Credentials only, since the Planner Graph API
    does not support anything else
  FIXES [#1979](https://github.com/microsoft/Microsoft365DSC/issues/1979)
* TeamsMeetingBroadcastConfiguration
  * Fixing export issue where SdnApiToken is exported as a string instead of
    a variable
  FIXES [#2056](https://github.com/microsoft/Microsoft365DSC/issues/2056)
* MISC
  * Updated Export functionality to only export the LCM settings when the
    executed as Administrator
  FIXES [#2037](https://github.com/microsoft/Microsoft365DSC/issues/2037)
  * Added support for multiple authentication methods to the Export functionality.
    The code now uses the most secure method that is provided in the command line
    and that supported by the specified resources in the following order:
    Certificate Thumbprint, Certificate Path, Application Secret, Credential
  FIXES [#1759](https://github.com/microsoft/Microsoft365DSC/issues/1759)
* MISC
  * Fix issue of running Export-M365DSCConfiguration within Azure Run Book. FIXES [#2233](https://github.com/microsoft/Microsoft365DSC/issues/2233)
  * Fix issue within M365DSCTelemetryEngine when used with ApplicationId. FIXES [#2237](https://github.com/microsoft/Microsoft365DSC/issues/2237)

# 1.22.824.1

* AADApplication
  * Fixed issue where Update-MgApplication could be called with parameter ReplyURLs which is invalid.
  * Added support to export/import app owners.
* AADConditionalAccessPolicy
  * DEPRECATED then IncludeDevices and ExcludeDevices parameters.
  * Fixed issue extracting a policy that had invalid users or groups (deleted from AAD).
    FIXES [#2151](https://github.com/microsoft/Microsoft365DSC/issues/2151)
* EXOTransportRule
  * Fix issue setting IncidentReportContent
    FIXES [#2196](https://github.com/microsoft/Microsoft365DSC/issues/2196)
* O365User
  * Optimize, call Get-MgSubscribedSku only once instead of inside of two loops per each user/license.
* SPOSiteGroup
  * Avoid redefining SiteGroupSettings always to the same value, just define it once, and call it as is on Set-PnPGroup.
  * To keep the same order of updating the group and then its permissions check on which conditions it needs to be updated and at the end call Set-PnPGroup then Set-PnPGroupPermissions.
  * Fix typo in variable, not an issue right now but the group would always be updated even if name and owner were already correct.
* TeamsEventsPolicy
  * Initial release.
* DEPENDENCIES
  * Updated DSCParser dependency to version 1.3.0.6.
  * Updated Microsoft.Graph dependencies to version 1.11.1.
  * Updated ReverseDSC dependency to version 2.0.0.12.
* MISC
  * Fixed issue with Export-M365DSCConfiguration if all components were invalid or if resource files were not found.
  * Updated MicrosoftTeams to version 4.6.0.
* AADRoleSetting
  * New Resource, configure Azure PIM Role like in the UI

# 1.22.727.1

* EXOTransportRule
  * Fixed issue where the MessageContainsDataClassifications property was not properly extracted due to single quote exiting.
    FIXES [#1820](https://github.com/microsoft/Microsoft365DSC/issues/1820)
* IntuneAppProtectionPolicyAndroid
  * Added Configuration Parameters:
    ManagedBrowser
    MinimumRequiredAppVersion
    MinimumRequiredOSVersion
    MinimumRequiredPatchVersion
    MinimumWarningAppVersion
    MinimumWarningOSVersion
    MinimumWarningPatchVersion
    AppGroupType
    IsAssigned
    FIXES [#1955](https://github.com/microsoft/Microsoft365DSC/issues/1955)
* IntuneDeviceConfigurationPolicyWindows10
  * Fixed issue where the edgeSearchEngine value was not properly retrieved.
    FIXES [#1783](https://github.com/microsoft/Microsoft365DSC/issues/1783)
* SCSensitivityLabel
  * Fixed an issue where '$' in the custom wordmark test would cause issue.
    FIXES [#2067](https://github.com/microsoft/Microsoft365DSC/issues/2067)
* SPOSite
  * Fixed owner value for root site.
    FIXES [#2035](https://github.com/microsoft/Microsoft365DSC/issues/2035)
* TeamsUser
  * Fixed the extraction process and removed the multi-threading from the resource.
    FIXES #1883
* MISC
  * Added support for filtering resources instances at extraction time.
    FIXES [#1691](https://github.com/microsoft/Microsoft365DSC/issues/1691)
  * REPORT: Fixed an issue where if the ModuleVersion was not specified, that the file would fail to properly get parsed.
    FIXES [#1970](https://github.com/microsoft/Microsoft365DSC/issues/1970)
  * Resources implementing the Ensure parameter now defaults its value to $true.
    FIXES [#1738](https://github.com/microsoft/Microsoft365DSC/issues/1738)

# 1.22.720.1

* AADAuthorizationPolicy
  * Fixed issue with the DefaultUserRolePermissionGrantPoliciesAssigned property.
* AADGroup
  * Added support for Group Licensing by adding the AssignedLicenses property.
  * Added support for members and owners.
  FIXES [#1066](https://github.com/microsoft/Microsoft365DSC/issues/1066)
* EXOCASMailboxSettings
  * Fixed issue if there are mailboxes with the same name
  FIXES [#2117](https://github.com/microsoft/Microsoft365DSC/issues/2117)
* EXODistributionGroup
  * Initial release.
  FIXES [#1802](https://github.com/microsoft/Microsoft365DSC/issues/1802)
* EXOMalwareFilterPolicy
  * DEPRECATED parameter CustomAlertText.
* IntuneAntivirusPolicyWindows10SettingCatalog
  * Initial release.
* IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager
  * Initial release.
* IntuneDeviceCompliancePolicyWindows10
  * Switched to using the beta profile in order to aapture all parameters.
  FIXES [#1998](https://github.com/microsoft/Microsoft365DSC/issues/1998)
* IntuneDeviceConfigurationPolicyWindows10
  * Fixed issue where the value for the DefenderDetectedMalwareActions property wasn't properly handled.
  FIXES [#1479](https://github.com/microsoft/Microsoft365DSC/issues/1479)
* IntuneExploitProtectionPolicyWindows10SettingCatalog
  * Initial release.
* O365OrgCustomizationSetting
  * Added a warning to let users know the changes can take up to 24 hours to be reflected
  FIXES [#1599](https://github.com/microsoft/Microsoft365DSC/issues/1599)
* PPTenantSettings
  * Fixed the way parameters are passed to the Set-TenantSettings cmdlet.
  FIXES [#1914](https://github.com/microsoft/Microsoft365DSC/issues/1914)
* TeamsTenantDialPlan
  * Fixed an issue where the Normalization Rules strings were not properly exited.
    FIXES [#2096](https://github.com/microsoft/Microsoft365DSC/issues/2096)
* TeamsUpdateManagementPolicy
  * Changed the format of the UpdateTimeOfDay parameter to not include date as part of an export.
    FIXES [#2062](https://github.com/microsoft/Microsoft365DSC/issues/2062)
* MISC
  * PowerPlatform: Standardized authentication on Credential and dropped support for Service Principal across resources.
  FIXES [#1979](https://github.com/microsoft/Microsoft365DSC/issues/1979)
  * EXPORT: Changed the way resources' modules are imported to improve startup performance.
  FIXES [#1745](https://github.com/microsoft/Microsoft365DSC/issues/1745)
  * Added a new Test-M365DSCModuleValidity cmdlet.
  * Updated the Uninstall-M365DSCOutdatedDependencies cmdlet to delete module files.

# 1.22.713.1

* AADAuthorizationPolicy
  * Initial release.
* AADConditionalAccessPolicy
  * Fixed issue for Included and Excluded properties where the last instance couldn't be removed.
    FIXES [#2058](https://github.com/microsoft/Microsoft365DSC/issues/2058) & [#2079](https://github.com/microsoft/Microsoft365DSC/issues/2079)
* EXOATPPolicyForO365
  * Deprecated properties AllowClickThrough, EnableSafeLinksForO365Clients & TrackClicks.
* EXOAuthenticationPolicyAssignment
  * Initial release.
* EXOCASMailboxSettings
  * New resource to configure Exchange Online CAS Mailbox settings.
* EXOSafeLinksPolicy
  * Deprecated properties DoNotAllowClickThrough, DoNotTrackUserClicks & IsEnabled.
* IntuneAppProtectionPolicyiOS
  * Fixed issue with creation a new policies where it was complaining about invalid minimum versions.
  * Fixed issues where creating new policies threw an error complaining about an invalid duration format.
     FIXES [#2019](https://github.com/microsoft/Microsoft365DSC/issues/2019)
  * Added the CustomBrowserProtocol parameters.
     FIXES [#2009](https://github.com/microsoft/Microsoft365DSC/issues/2009)
* IntuneDeviceAndAppManagementAssignmentFilter
  * Initial release.
* SCComplianceTag
  * Fixed issue where FilePlanProperty was not properly applied unless another child property was also modified.
* SPOSharingSettings
  * Updated code to remove None as valid value for DefaultLinkPermission. If value is set to None default to Edit.
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.150.
  * Updated MSCloudLoginAssistant to version 1.0.87.
* MISC
  * Made the Compare-M365DSCConfigurations cmdlet public.

# 1.22.706.1

* AADSecurityDefaults
  * Initial release.
* TeamsFederationConfiguration
  * Added support for the AllowedDomains and BlockedDomains properties.
* TeamsVoiceRoutingPolicy
  * Remove unsupported Confirm parameter from Remove-CsOnlineVoiceRoutingPolicy cmdlet (Confirm parameter is no longer available for MicrosoftTeams PowerShell module 4.4.1+).
    FIXES #2055
* DEPENDENCIES
  * Updated MicrosoftTeams to version 4.5.0.
  * Updated Pnp.PowerShell to version 1.11.0.

# 1.22.629.1

* EXOMalwareFilterPolicy
  * Parameters Action, EnableExternalSenderNotifications and EnableInternalSenderNotifications are deprecated and will be removed in future. These parameters are no longer available in EXO, only in onprem Exchange. Please remove these parameters from your configuration.
  FIXES #2025
  * Added support for FileTypeAction parameter.
* EXOSharedMailbox
  * Fix using umlauts in displayname by allowing to set alias.
    FIXES #1921
  * Rename parameter Aliases to EmailAddresses. Aliases is now deprecated.
* DEPENDENCIES
  * Updated DSCParser to version 1.3.0.5
  * Updated Microsoft.Graph.* modules to version 1.10.0.
  * Updated MSCloudLoginAssistant to version 1.0.86.
    Fixes two authentication issues: #2000 and #2007
* MISC
  * New Delta Report: removed mandatory restrictions on the OutputPath parameter.
    FIXES #2029

# 1.22.622.1

* TeamsMessagingPolicy
  * Removed the -force deprecated parameter on New/Set/Remove
* MISC
  * Modified the dependency installation functions to for the AllUsers scope.

# 1.22.615.1

* EXODataClassification
  * Added example
* EXODataEncryptionPolicy
  * Added example
* MISC
  * Added cmdlet (Update-M365DSCAzureAdApplication) to create and manage a
    custom service principal which can be used within Microsoft365DSC
    configurations
  * Extended the permissions in the settings.json file to include delegated,
    application and Exchange permissions
  * Updated Get-M365DSCCompiledPermissionList to include the new permissions in the
    settings.json file
  * Added cmdlet to generate the resource pages on the microsoft365dsc.com website
  * Checked and updated the readme.md files of all resources to make them consistent
    and usable by the new documentation cmdlet
  * Corrected documentation issues on the microsoft365dsc.com website
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.148;

# 1.22.608.1

* AADConditionalAccessPolicy
  * Updated settings.json with missing permissions
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to 1.0.85;
* MISC
  * Updated permissions for SharePoint and OneDrive in settings.json files.

# 1.22.601.1

* DEPENDENCIES
  * Updated MicrosoftTeams to version 4.4.1

# 1.22.525.1

* IntuneASRRulesPolicyWindows10
  * Initial release;
* PPowerAppsEnvironment
  * Fixed issue on export to exclude EnvironmentTypes of Notspecified and Developer
  * Updated validation set of EnvironmentTypes to latest values
* DEPENDENCIES
  * Updated MSCloudLoginAssistant module to version 1.0.84.
* MISC
  * Fixed issue in generating a Delta report, where the Resource names were also
    compared, which in case of an export are generated GUIDs.
  * Fixed issue where empty strings or arrays would result in a Delta reports
    with drifted parameters, even though both configs are empty.
  * Added logic to New-M365DSCDeltaReport to check if the files specified in the
    Source, Destination and HeaderFilePath parameters actually exist.
  * Fixed issue where Excel wasn't closed after creating the report.

# 1.22.518.1

* AADConditionalAccessPolicy
  * Fixed export to remove the DeviceFilterMode property
    when empty.
* EXODataClassification
  * Initial release
* EXODataEncryptionPolicy
  * Initial release
* PPTenantIsolationSettings
  * Fixed an issue where credentials weren't passed properly
    during the export.
* SPOSharingSettings
  * Decoupling from SPOSharingSettings: add SharingCapability for "-my sites" aka: OneDrive

# 1.22.511.1

* AADNamedLocationPolicy
  * Added error handling in the Get-TargetResource function.
* EXOIRMConfiguration
  * Initial release.
* EXOMessageClassification
  * Initial release.
* EXOOMEConfiguration
  * Initial release.
* EXOOwaMailboxPolicy
  * Fix where the update scenario was not setting the proper
    values. (FIXES #1868)
* EXOPerimeterConfiguration
  * Initial release.
* EXOResourceConfiguration
  * Initial release.
* IntuneApplicationControlPolicyWindows10
  * Initial release.
* TeamsUpdateManagementPolicy
  * Initial release.
* DEPENDENCIES
  * Updated Microsoft.Graph.* modules to version 1.9.6.
  * Updated ReverseDSC to version 2.0.0.11.
* MISC
  * Updated permissions for SharePoint in settings.json files.
  * Added links to documentation to Teams Readme files
  * Added and corrected some Exchange examples
  * Added progress indicator to the Report generation

# 1.22.504.1

* EXOInboundConnector
  * Added support for EFSkipIPs, EFSkipLastIP and EFUsers properties. (FIXES #1917)
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.147.
  * Updated MicrosoftTeams to version 4.3.0.

# 1.22.427.1

* AADApplication
  * Fix for Permissions with 'Role,Scope' types.
* EXOAuthenticationPolicy
  * Fix schema.mof file (FIXES #1896)
* IntuneAppProtectionPolicyAndroid
  * New resource - (fixes issue #1900 and #1432)
* IntuneAppProtectionPolicyiOS
  * Fixes #1877
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.146.
* MISC
  * Performance updates when doing exports (using StringBuilder over
    appending to string).

# 1.22.420.1

* EXOOutboundConnector
  * Added support for test mode connectors.

# 1.22.413.1

* EXOAuthenticationPolicy
  * Fix typo in AllowBasicAuthOfflineAddressBook (FIXES #1876)
* EXOQuarantinePolicy
  * New resource
* O365Groups
  * Fixed issue on export of O365Groups resource.
* DEPENDENCIES
  * Updated Microsoft.Graph.* to 1.9.5.
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.145.
  * Updated MicrosoftTeams to 4.2.0.

# 1.22.406.1

* EXOMalwareFilterPolicy
  * Add support for property QuarantineTag
* PPTenantIsolationSettings
  * New resource
* MISC
  * Updated Convert-M365DscHashtableToString function to also convert
    Arrays and CimInstances to string.
  * Updated permissions in settings.json files.
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.144.
  * Updated MicrosoftTeams to 4.1.0.
  * Updated PnP.PowerShell to 1.10.0.

# 1.22.323.1

* EXOAuthenticationPolicy
  * Initial release;
* EXOOrganizationConfig
  * Added support for CustomerLockboxEnabled and DisablePlusAddressInRecipients parameters.
    FIXES #1831

# 1.22.316.1

* EXOCASMailboxPlan
  * Add support for DisplayName as identifier for CAS mailbox plan.
* EXOTransportSettings
  * New resource for Exchange Online transport configuration.
* IntuneAppProtectionPolicyiOS
  * Add 7 additional parameters to the resource and added parameter
    descriptions.
* DEPENDENCIES
  * Updated DSCParser to 1.3.0.4.
  * Updated Microsoft.Graph.* to 1.9.3.

# 1.22.309.1

* EXOAcceptedDomain
  * Fixes an issue where True was never accepted as a value for parameters
    MatchSubDomains or OutboundOnly.
    FIXES #1779
* EXOMailboxPlan
  * New resource for Exchange Online Mailbox Plans.
* EXOOrganizationConfig
  * Fixes an issue where AutoExpandingArchiveEnabled returned always False.
    FIXES #1789
* IntuneDeviceConfigurationPolicyAndroidDeviceOwner
  * Initial release.
* O365Group
  * Revamped to use Microsoft Graph in the Set;
* TeamsChannel
  * Fix to retrieve the team name without URL encoding.
* TeamsFederationConfiguration
  * New resource for Teams Federation Configuration.
* TeamsTeam
  * Fixed issue where teams were not created when no owners were specified.
    If credentials are used, then the user will be used as owner.
* DEPENDENCIES
  * Updated DSCParser to version 1.3.0.3.
  * Updated MicrosoftTeams to version 4.0.0.
* MISC
  * Added a function to uninstall all outdated dependencies
    and older versions of Microsoft365DSC;
  * M365DSCReport: Adds JSON as an export option.

# 1.22.216.1

* DEPENDENCIES
  * Updated ReverseDSC to version 2.0.0.10.
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.142.

# 1.22.209.1

* TeamsChannel
  * Fix to allow channels to be extracted properly when two Teams
    have the same name.
    FIXES #1746
* DEPENDENCIES
  * Updated MicrosoftTeams to version 3.1.1;
* MISC
  * Fixed an issue with the Export where the Configuration Data file
    always referenced a certificate file even when none were configured.
    FIXES #1724

# 1.22.202.1

* IntuneAppProtectionPolicyiOS
  * Fixes an issue where an error was thrown when no ExcludedGroups
    were specified.
    FIXES #1719
* MISC
  * Documentation updates

# 1.22.126.1

* TeamsTenantDialPlan
  * Fixed an issue where the Export only extracted the first
    normalization rule.
    FIXES #1695
* DEPENDENCIES
  * Updated all Microsoft.Graph * to 1.9.2;
  * Updated Microsoft.Teams to version 3.1.0;
* MISC
  * Update automatic cmdlet documentation generation functions and prereqs.
  * Adding cmdlet documentation to website
  * Fixed an issue with the Export-M365DSCConfiguration cmdlet where it
    would throw an error if no parameters were passed.

# 1.22.119.2

* EXOOrganizationConfig
  * Fixed issue where the name of the parameter in the module and
    in the schema differed;
    FIXES #1689

# 1.22.119.1

* EXOOrganizationConfig
  * Added support for the new SendFromAliasEnabled parameter;
* EXORoleAssignmentPolicy
  * Fixed logic to update roles assigned to an existing policy;
    FIXES #1538
MISC
  * Updated logic for Report generation so that it no longer requires the
    same module version as defined in the configuration installed on the
    system where the report is being generated from.

# 1.22.112.1

* TeamsMeetingPolicy
  * Added support for property WhoCanRegister;
    FIXES #1483
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to 1.0.83;

# 1.22.105.1

* AADNamedLocationPolicy
  * Throw meaningful error if multiple policies with the same name were retrieved.
* EXOMalwareFilterPolicy
  * Fix for the MakeDefault property where it wasn't properly setting existing
    policies to default.
    FIXES #1648
* IntuneDeviceConfigurationPolicyWindows10
  * Fixed mismatch in property types between the PasswordBlockSimple and
    PasswordSignInFailureCountBeforeFactoryReset properties.
    FIXES #1525
* O365Group
  * Removed support for invalid CertificatePassword and CertificatePath parameters
    and added support for ApplicationSecret;
* O365User
  * Removed support for invalid CertificatePassword and CertificatePath parameters
    and added support for ApplicationSecret;
* TeamsChannel
  * Fixed an issue where special symbols in Teams names would cause the
    Get-TeamByName cmdlet to fail.
    ISSUE #1578
* MISC
  * Error Handling in Delta Report and removal of Authentication mechanism comparison;
    FIXES #1548, #1541
  * Added automatic cmdlet documentation generation functions and prereqs.

# 1.21.1229.1

* DEPENDENCIES
  * Updated all PnP.PowerShell dependencies to version 1.9.0;

# 1.21.1222.1

* AADGroup
  * Default to Unified type if no GroupTypes are provided;
    FIXES #850
* EXOAntiPhishPolicy
  * Deprecated the EnableAntispoofEnforcement and TargetDomainProtectionAction parameters;
    FIXES #1018
* EXOHostedCOntentFilterPolicy
  * Fix for the MakeDefault property where it wasn't properly setting existing
    policies to default.
    FIXES #1635
* SPOSearchManagedProperty
  * Fixed an issue with the Aliases retrieval;
* SPOUserProfileProperty
  * Removed the Required key from the schema.mof file for Credential;
    ISSUE #1632
* DEPENDENCIES
  * Updated all Microsoft.Graph.* dependencies to version 1.9.1;
* MISC
  * Fixed issue where running Export-M365DSCConfiguration with the -LaunchWebUI
    parameter would prompt for credentials;
  * Added warning message when ApplicationSecret is used while attempting
    to export resources for Exchange Online;
    Fixes #1629

# 1.21.1215.1

* AADConditionalAccessPolicy
  * Switched to the beta endpoint to allow the export to capture policies
    with device compliance conditions configured;
* EXOAntiphishPolicy
  * Fixed an issue where trying to create a new policy would result in its
    Identity being set to System.Collections.Hashtable;
    FIXES #1620
  * Fix for the MakeDefault property where it wasn't properly setting existing
    policies to default.
    FIXES #1582
* O365User
  * Fixed issue where the extraction wasn't properly formatting the temporary
    password for a user;
* TeamsChannelPolicy
  * Added support for Shared Channels;
* TeamsMeetingPolicy
  * Added support for value 'EveryoneInCompanyExcludingGuests' for the
    AutoAdmittedUsers property;
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to 1.0.82;

# 1.21.1208.1

* AADConditionalAccessPolicy
  * Added support for Terms of Use;
* AADGroup
  * Fixed issue where not all groups were exported;
* TeamsTeam
  * Fix issue where Credentials weren't extracted as a variable;
* TeamChannel
  * Fixed issue where the exported Team Channel content was empty if
    Credentials were used to authenticate;
* MISC
  * Removed RequiredModules in favor of a new custom dependency manifest;
* DEPENDENCIES
  * Updated MicrosoftTeams to 3.0.0;
  * Updated MSCloudLoginAssistant to 1.0.80;

# 1.21.1124.2

* DEPENDENCIES
  * Updated ReverseDSC to 2.0.0.9;

# 1.21.1124.1

* IntuneAppProtectionPolicyiOS
  * Fixes to the Invoke-MgGraphRequest cmdlets parameters;
* MISC
  * Removed the Quiet switch from the Assert Blueprint cmdlet;
    ISSUE #1563
* DEPENDENCIES
  * Updated Microsoft.Graph.Applications to 1.9.0;
  * Updated Microsoft.Graph.Authentication to 1.9.0;
  * Updated Microsoft.Graph.DeviceManagement to 1.9.0;
  * Updated Microsoft.Graph.DeviceManagement.Administration to 1.9.0;
  * Updated Microsoft.Graph.DeviceManagement.Enrolment to 1.9.0;
  * Updated Microsoft.Graph.Devices.CorporateManagement to 1.9.0;
  * Updated Microsoft.Graph.Groups to 1.9.0;
  * Updated Microsoft.Graph.Identity.DirectoryManagement to 1.9.0;
  * Updated Microsoft.Graph.Identity.SignIns to 1.9.0;
  * Updated Microsoft.Graph.Planner to 1.9.0;
  * Updated Microsoft.Graph.Teams to 1.9.0;
  * Updated Microsoft.Graph.Users to 1.9.0;
  * Updated MSCloudLoginAssistant to 1.0.79;
  * Updated ReverseDSC to 2.0.0.8;

# 1.21.1117.2

* MISC
  * Fixes old Intune Graph Request cmdlet name;

# 1.21.1117.1

* EXOTransportRule
  * Fixed issues with invalid State property and missing Enabled one;
    ISSUE #1554;
* IntuneDeviceCompliancePolicyAndroidDeviceOwner
  * Initial release;
* DEPENDENCIES
  * Updated DSCParser to version 1.3.0.2;
  * Updated MSCloudLoginAssistant to version 1.0.78;

# 1.21.1110.1

* MISC
  * Standardized examples
  * Added missing examples
  * Added settings.json generator cmdlet (Update-M365DSCResourcesSettingsJSON)
  * Added cmdlet to configure delegated permissions to Graph app based on
    settings.json file (Update-M365DSCAllowedGraphScopes)
  * Preparation to run integration tests dynamically using the resource examples
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.76;

# 1.21.1103.1

* TeamsCallingPolicy
  * Added support for value 'Unanswered' for property
    BudyOnBusyEnabledType.
    Fix Issue #1514
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to
    2.0.139;
  * Updated MSCloudLoginAssistant to version 1.0.75;

# 1.21.1027.1

* DEPENDENCIES
  * Updated Microsoft.Graph.Applications to 1.8.0;
  * Updated Microsoft.Graph.Authentication to 1.8.0;
  * Updated Microsoft.Graph.DeviceManagement to 1.8.0;
  * Updated Microsoft.Graph.DeviceManagement.Administration to 1.8.0;
  * Updated Microsoft.Graph.DeviceManagement.Enrolment to 1.8.0;
  * Updated Microsoft.Graph.Devices.CorporateManagement to 1.8.0;
  * Updated Microsoft.Graph.Groups to 1.8.0;
  * Updated Microsoft.Graph.Identity.DirectoryManagement to 1.8.0;
  * Updated Microsoft.Graph.Identity.SignIns to 1.8.0;
  * Updated Microsoft.Graph.Planner to 1.8.0;
  * Updated Microsoft.Graph.Teams to 1.8.0;
  * Updated Microsoft.Graph.Users to 1.8.0;
  * Updated MSCloudLoginAssistant to version 1.0.74;
* MISC
  * Fixed issue generating delta report containing EXOAvailabilityConfig
    resources;

# 1.21.1013.1

* Obfuscating Authentication Secrets from the Verbose output;

# 1.21.1006.3

* BREAKING CHANGES

* AADApplication
  * Removed support for the Oauth2AllowImplicitFlow, SamlMetadataUrl and
    Oauth2AllowUrlPathMatching properties;
* AADMSGroup
  * Renamed resource to AADGroup;
* AADMSGroupLifecyclePolicy
  * Renamed resource to AADGroupLifecyclePolicy;
* AADPolicy
  * Replaced resource by the new AADTokenLifetimePolicy one;
* DEPENDENCIES
  * Added dependency on Microsoft.Graph.Applications;
  * Added dependency on Microsoft.Graph.Groups;
  * Added dependency on Microsoft.Graph.Identity.DirectoryManagement;
  * Added dependency on Microsoft.Graph.Identity.SignIns;
  * Removing dependency on AzureADPreview;
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.137;
  * Updated MicrosoftTeams to version 2.6.0;
  * Updated MSCloudLoginAssistant to version 1.0.72;
* MISC
  * Renamed the GlobalAdminAccount parameter to Credential across all resources;
  * Revamped entire Azure AD Workload to leverage Microsoft Graph;
  * New -LaunchWebUI switch for Export-M365DSCConfiguration will launch the
    new web-based UI. The old GUI has been removed.
  * Removal of the -Quiet switch for the Export-M365DSCConfiguration cmdlet;
  * Renaming the ComponentsToExtract property from the Export-M365DSCConfiguration
    cmdlet to Components;

# 1.21.922.1

* AADApplication
  * Fix issue where export will only export 100 apps

* EXOSafeLinksPolicy
  * Added support for CustomNotificationText, EnableOrganizationBranding, and
    UseTranslatedNotificationText properties;
* SPOSite
  * Fixed issue when deleting site and confirm parameter
* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.68;

# 1.21.915.1

* EXOAntiPhishPolicy
  * Added support for EnableFirstContactSafetyTips & EnableViaTag;
* EXOAtpPolicyForO365
  * Added support for AllowSafeDocsOpen;
* EXOHostedContentFilterPolicy
  * Added support for HighConfidencePhishAction;
* EXOHostedOutboundSpamFilterPolicy
  Added support for RecipientLimitInternalPerHour, RecipientLimitPerDay,
  RecipientLimitExternalPerHour, ActionWhenThresholdReached & AutoForwardingMode;
* EXOHostedOutboundSpamFilterRule
  Initial release;
* IntuneAppConfigurationPolicy
  * Added support for the CustomSettings property;
* IntuneDeviceCompliancePolicyWindows10
  * Removed the App Secret and Application ID from the output;
  * Added DefenderEnabled to the Resource;
* IntuneDeviceConfigurationWindows10
  * Initial release;
* DEPENDENCIES;
  * Updated Microsoft.Graph.Authentication to version 1.7.0;
  * Added dependency on Microsoft.Graph.DeviceManagement;
  * Added dependency on Microsoft.Graph.DeviceManagement.Administration;
  * Added dependency on Microsoft.Graph.DeviceManagement.Enrolment;
  * Added dependency on Microsoft.Graph.Devices.CorporateManagement;
  * Updated Microsoft.Graph.Planner to version 1.7.0;
  * Updated Microsoft.Graph.Teams to version 1.7.0;
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.136;
  * Updated MSCloudLoginAssistant to version 1.0.67;

# 1.21.908.1

* PPTenantSettings
  * Initial Release;
* DEPENDENCIES;
  * Updated MSCloudLoginAssistant to version 1.0.64;
* MISC
  * Fixing duplicate teams names in reports;

# 1.21.901.1

* DEPENDENCIES;
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.133;
  * Updated MicrosoftTeams to version 2.5.1;
* MISC
  * Additional display alignment fixes for Export;

# 1.21.825.1

* SPOTenantSettings
  * Added the DisabledWebpartIds & ConditionalAccessPolicy properties;
* DEPENDENCIES;
  * Updated AzureADPreview to version 2.0.2.138;
  * Updated Microsoft.PowerApps.Administration.PowerShell to version 2.0.131;
  * Updated Microsoft.Teams to version 2.5.0;
* MISC
  * Additional display alignment fixes for Export;

# 1.21.804.1

* SCDLPComplianceRule
  * Fixed issue where SCDLPCompliance rule failed when using sensitivity labels;
* DEPENDENCIES;
  * Updated MSCloudLoginAssistant to version 1.0.62;
* MISC
  * Added support for ApplicationSecret in SPO resources;
  * Revamped the entire display from an Export;

# 1.21.728.1

* DEPENDENCIES;
  * Updated MSCloudLoginAssistant to version 1.0.59;
  * Updated PnP.PowerShell to version 1.7.0;
* MISC
  * Added support for Service Principal Authentication for all Intune resources;
  * Deprecated GUI and added reference to new Web based GUI;

# 1.21.721.1

* AADMSGroup
  * Fixed an issue where the Visibility parameter was never properly returned
    which always threw a detected drift when used.
* EXOJournalRule
  * Initial Release.
* SPOSite
  * Fixed the StorageQuotaWarningLevel value returned by the Get-TargetResource
    function.

# 1.21.714.1

* EXOHostedContentFilterPolicy
  * Fixed issues with null values falsely detected as drifts;
    ISSUE #1165
* DEPENDENCIES
  * Removed dependency on Microsoft.Graph.Groups.Planner;
  * Updated Microsoft.Graph.Teams to version 1.6.1;
  * Updated MSCloudLoginAssistant to version 1.0.54;
* MISC
  * Allowed for Desired and Current values to be captured by the Telemetry engine
    if an organization is using a custom App Insights account;
    ISSUE #1222

# 1.21.707.1

* EXODkimSigningConfig
  * Change the logic to remove an entry to disable it instead since the
    cmdlet didn't exist to remove it.
    ISSUE #1253
* EXOHostedContentFilterPolicy
  * Fixed the value type for the senders addresses, regions and domains;
    ISSUE #1165
* EXOOutboundConnector
  * Fixed the creation logic to include ValidationRecipients;
    ISSUE #1165
* EXOSharedMailbox
  * Improved speed of extraction and removed warning about maximum 1,000
    items retrieved;
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.127;
* MISC
  * Delta Report - Fixes to compare null arrays properly and report as
    a discrepancy.
    ISSUES #1178 & #1249

# 1.21.630.1

* O365User
  * Fix where export was throwing an error about an empty DSCBlock
    ISSUE #1275;
* SPOTenantSettings
  * Added support for specifying MarkNewFilesSensitiveByDefault

# 1.21.616.1

* SPOSiteAuditSettings
  * Fixed issue with Export where property Ensure was added
    when an access forbidden error was encountered;
* DEPENDENCIES
  * Updated Microsoft.Graph.Authentication to version 1.6.0;
  * Updated Microsoft.Graph.Planner to version 1.6.0;
  * Updated Microsoft.Graph.Teams to version 1.6.0;

# 1.21.609.2

* Fixed dependency on Microsoft.Graph.Authentication for
  version 1.5.0.

# 1.21.609.1

* TeamsUpgradePolicy
  * Fixes to how we are retrieving users assigned to the
    Global Upgrade Policy.
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to version 2.0.5;
  * Updated Microsoft.Graph.Planner to version 1.5.0;
  * Updated Microsoft.Graph.Teams to version 1.5.0;
  * Updated Microsoft.PowerApps.Administration.PowerShell
    to version 2.0.126;
  * Updated PnP.PowerShell to version 1.6.0;

# 1.21.602.1

* AADMSGroups
  * Fix for the export where the MailNickName was being prompted;
* EXOManagementRole
  * BREAKING: Now requires the Parent property as Mandatory;
* TeamsChannel
  * Fixed an issue where content was dedup and boolean
    values were appended to the exported content;
* TeamsUpgradePolicy
  * Improved performance retrieving users assigned to policy;
* MISC
  * Fix for Teams authentication. Improvements on session
    reuse.

# 1.21.526.2

* EXOSafeAttachmentRule
  * Fixed issue #1213 Policy X already has rule Y associated with it
    if rule exists already
* MSFT_IntuneDeviceCompliancePolicyAndroid
  * New resource
* MSFT_IntuneDeviceCompliancePolicyAndroidWorkProfile
  * New resource
* MSFT_IntuneDeviceCompliancePolicyMacOS
  * New resource
* MSFT_IntuneDeviceCompliancePolicyiOs
  * New resource
* EXOTransportRule
  * Fix #1230 Changed ExceptIfSenderInRecipientList to array

# 1.21.519.2

* AzureADRoleDefinition
  * Fix an issue where deprecated roles were not increasing
    the index which resulted in an incorrect count being
    displayed during the extraction.
* EXORoleAssignmentPolicy
  * Added missing ErrorAction value in the Export;
* TeamsTenantDialPlan
  * Fixed issue around normalization rules export;
* SPOTenantSettings
  * Fix issue with typo and dup property issue #1219
* MISC
  * Forces a Global load of the new MicrosoftTeams module for
    Teams resources;

# 1.21.519.1

* TeamsClientConfiguration
  * Fixed an issue where the RestrictedSenderList was not properly
    being converted to a comma separated string.
    Issue #1191
* DEPENDENCIES
  * Updated AzureADPreview to version 2.0.2.136;

# 1.21.512.1

* EXOOfflineAddressBook
  * Fixed issue in Set-TargetResource where ConfiguredAttributes
    was passed and resulted in an error.
* SCDLPComplianceRule
  * Added several new parameters
  * Fixed several bugs on extract

# 1.21.505.1

* EXOTransportRule
  * Adding ExceptIfSCLOver and SCLOver.
  * Fixes SubjectOrBodyContainsWords parameter not being an array.
  * Fixes DateTime formatting on ExpiryDate and ActivationDate

# 1.21.428.2

* EXOTransportRule
  * Fixed typo in accepted value for ApplyHtmlDisclaimerLocation;
* IntuneAppConfigurationPolicy
  * Revamp of Telemetry;
  * Using shorter cmdlets names;
* IntuneDeviceCompliancePolicyAndroid
  * Initial Release;
* IntuneDeviceCompliancePolicyAndroidWorkProfile
  * InitialRelease
* IntuneDeviceCompliancePolicyiOs
  * Using shorter cmdlet names;
* IntuneDeviceConfigurationPolicyiOS
  * Using shorter cmdlet names;
* IntuneDeviceEnrollmentPlatformRestriction
  * Revamp of Telemetry;
  * Using Shorter cmdlet names;

# 1.21.421.2

* MISC
  * Updated the SkipModuleReload logic for a dozen of EXO modules
    which were failing authentication;

# 1.21.421.1

* AADConditionalAccessPolicy
  * Fix to allow 'undefined' as a value for multiple parameters;
* EXOTransportRule
  * Fixed schema to support Service Principal Auth;
* TeamsChannelTab
  * Fixed typo in parameter 'TeamId';
* MISC
  * Refactor of all EXO resources to fixes for Set-TargetResource
    functions where Service Principal was used to authenticate;
  * Refactored connections across all resources to help with
    Telemetry regarding what auth method users are leveraging.

# 1.21.414.2

* AADConditionalAccessPolicy
  * Fixed an issue with the default values for device states;
* EXOHostedContentFilterPolicy
  * Fixed issue where EndUserSpamNotificationCustomFromName was
    not properly returned from the Get-TargetResource function;
* EXOTransportRule
  * New resource;
* O365AdminAuditLogConfig
  * Fixed issue where the Set-TargetResource stopped being
    executed if an error was encountered;
* TeamsTeam
  * Fix format issue with owner issue # 1143
* DEPENDENCIES
  * Updated AzureADPreview to version 2.0.2.134;
  * Updated Microsoft.Graph.Authentication to version 1.4.2;
  * Updated Microsoft.Graph.Planner to version 1.4.2;
  * Updated Microsoft.Graph.Teams to version 1.4.2;
  * Updated Microsoft.PowerApps.Administration.PowerShell to version
    2.0.112;
  * Updated MSCloudLoginAssistant to version 1.0.51;
  * Updated PnP.PowerShell to version 1.5.0;

# 1.21.407.1

* AADConditionalAccessPolicy
  * BREAKING: Renamed the 'includeDeviceStates' and 'excludeDeviceStates'
    parameters to 'includeDevices' and 'excludeDevices';
* TeamsMeetingPolicy
  * The Set-CsTeamsMeetingPolicy would fail if recording settings are
    changed while the AllowCloudRecording is set to false;
* MISC
  * Fixed issue in most EXO resources where AzureAD App information
    was not returned by the Get-TargetResource function;

# 1.21.331.1

* AADApplication
  * Added support for API Permissions;
* EXOSharedMailbox
  * Improved how we are retrieving all shared mailboxes in the
    Export-TargetResource function.
* ODSettings
  * Fixed and issue with ExcludedFileExtensions;
* SCDLPComplianceRule
  * Fixed issue where only the first SIT Action was exported;
* SPOSiteDesign
  * Added support for GrouplessTeamSite web template.
* SPOSiteScript
  * Fixed issue where an existing site script could not be updated.
  * Made parameter GlobalAdminAccount in Get-TargetResource
    optional.
* SPOTheme
  * Fixed issue where removal of a theme would throw an error.
  * Corrected variable name to properly show the theme name in verbose message
    when removing a theme.
* MISC
  * Fixed issue with ODSettings and ExcludedFileExtensions

# 1.21.317.1

* DEPENDENCIES
  * Updated Exchange Management to version 2.0.4 (REDO);
  * Updated MSCloudLoginAssistant to version 1.0.50;
* MISC
  * Fixed issue when using CertificatePath and CertificatePassword
    for SPO resource;

# 1.21.224.1

* DEPENDENCIES
  * Rolled-back ExchangeOnlineManagement to 2.0.3;

# 1.21.217.1

* SPOSite
  * Fixed an issue related to new cmdlets in PnP.PowerShell;
* DEPENDENCIES
  * Updated ExchangeOnlineManagement to 2.0.4;
  * Updated PNP.PowerShell to 1.3.0;

# 1.21.203.1

* SPOSiteDesignRights
  * Fixed an issue that was preventing this resource from
    being exported;
* SPOBrowserIdleSignout
  * Initial Release;
* TeamsTenantDialPlan
  * Fixed an issue with the way Voice Normalization Rules were handled;
* MISC
  * Fix to the Delta Report Generator to properly handle TeamsPSTNUsage;
  * Fixed various Export Verbose format issues;
* DEPENDENCIES
  * Updated Microsoft.Graph.Authentication to version 1.3.1;
  * Updated Microsoft.Graph.Planner to version 1.3.1;
  * Updated Microsoft.Graph.Teams to version 1.3.1;
  * Updated MSCloudLoginAssistant to version 1.0.48;

# 1.21.127.1

* AADNamedLocation
  * Initial Release;
* DEPENDENCIES
  * Updated PnP.PowerShell to version 1.2.0;
  * Updated Microsoft.PowerApps.Administration.PowerShell to
    1.0.208;

# 1.21.120.1

* DEPENDENCIES
  * Updated MSCloudLoginAssistant to version 1.0.45;
  * Replaced the SharePointPnPPowerShellOnline dependency by the new
    PnP.PowerShell core module;

# 1.21.113.1

* AADTenantDetails
  * Fixes an issue where the Set would fail if Service Principal
   was used.
   (Issue [#1002](https://github.com/microsoft/Microsoft365DSC/issues/1002))
* AADRoleDefinition
  * Filters out role definitions without any assigned permissions.
    Fixes Issue #1007;
* DEPENDENCIES
  * Updated Microsoft.PowerApps.Administration.PowerShell
    to 2.0.104;

# 1.20.1223.1

* SPOHubSite
  * Changed Export logic to make the url parameterized
  * Updated Get method to prevent throwing an exception
    when the specified site doesn't exist
* SPOSite
  * Updated logic to not process the HubUrl parameter
    when this is equal to the Url parameter.
  * Updated export logic to not export the HubUrl
    parameter when this is equal to the Url parameter.
  * Fixed issue with incorrectly applying the LocaleId
* SPOSiteAuditSettings
  * Changed Export logic to make the url parameterized
* SPOSiteGroup
  * Changed Export logic to make the url parameterized
  * Updated logic to output more explainable troubleshooting
    messages
* M365DscReverse
  * Added the GlobalAccount Parameter to the example
    that is outputted after using the Export GUI

# 1.20.1216.1

* AADConditionalAccessPolicy
  * Initial Release;
* EXOSafeLinksRule
  * Fixed typo in a try/catch clause;
* O365User
  * Added support for removing existing users with
    Ensure = 'Absent';
* TeamsChannelTab
  * Initial Release;

# 1.20.1209.1

* IntuneAppProtectionPolicyiOS
  * Initial Release;
* IntuneDeviceCompliancePolicyiOS
  * Initial Release;
* IntuneDeviceConfigurationPolicyiOS
  * Initial Release;
* IntuneDeviceEnrollmentPlatformRestriction
  * Initial Release;
* IntuneDeviceEnrollmentLimitRestriction
  * Initial Release;
* TeamsTenantDialPlan
  * Performance Improvements: retrieve all Voice Normalization
    Rule at once and then iterated through them instead of
    retrieving them for every instance.
* DEPENDENCIES
  * Upgraded ExchangeOnlineManagement to version 2.0.3;
  * Upgraded Microsoft.Graph.Authentication to version 1.2.0;
  * Upgraded Microsoft.Graph.Planner to version 1.2.0;
  * Upgraded SharePointPnPPowerShellOnline to version
    3.28.2012.0;

## 1.20.1202.1

* EXOOwaMailboxPolicy
  * Fixed an issue trying to remove a policy;
* TeamsMessagingPolicy
  * Added AllowUserEditMessage property.
* TeamsMeetingPolicy
  * Added 'OrganizerOnly' as a support value for property
    AutoAdmittedUsers.
  * Temporarily removed the use of AllowAnonymousUsersToDialOut
    since it is currently disabled on the API side.
* EXPORT
  * Fixed an issue where an Export using the -Workloads
    parameter with a Service Principal did not export
    any resource;
* DEPENDENCIES
  * Upgrade AzureADPreview to version 2.0.2.129;

## 1.20.1125.1

* AADRoleDefinition
  * Initial Release;
* O365User
  * Fixes an issue where only the first O365User instance
    extracted had the PSCredential Password property set
    correctly;
* TeamsMeetingPolicy
  * Added the AllowBreakoutRooms, TeamsCameraFarEndPTZMode
    & AllowMeetingReactions parameters;
* DEPENDENCIES
  * MSCloudLoginAssistant Updated to 1.0.42;
  * Microsoft.PowerApps.Administration.PowerShell Updated
    to 2.0.99;
* MISC
  * Moved the check for new version of module into the
    Export-M365DSCConfiguration function for performance
    improvements;

## 1.20.1118.1

* EXOMalwareFilterPolicy
  * Fix an issue when the CustomFromAddress is empty;
    (Issue #901)
* EXORemoteDomain
  * Fixed an issue where only non-null parameters are
    used in the Set-TargetResource resource;
    (Issue #898)
* SCRetentionEventType
  * Initial Release;
* SPOSiteScript
  * BREAKING CHANGE: Title is now the primary key for the
    resource and Service Principal is now supported for
    authentication.
* MODULES
  * M365DSCStringEncoding
    New resource to handle encoding issues in exported content;
    (Issue #904)
  * M365DSCLogEngine
    Added Export-M365DiagnosticData function to export diagnostic
    information to a Zip file.

## 1.20.1111.1

* AADPolicy
  Initial Release;
* Fixes an issue with SCRetentionCompliancePolicy where
  the wrong parameter sets was being passed for creation.
  (Issue #890)

## 1.20.1104.1

* AADMSGroup
  * Added parameter IsAssignableToRole Issue #879
  * Fixed issue on Set Issue #863
* EXOHostedContentFilterPolicy
  * Deprecated ZapEnabled property and added PhishZapEnabled
    and SpamZapEnabled instead.
* MISC
  * Added checks for mandatory Authentication parameters before
    attempting an Export.
  * Deprecated the Assert-M365DSCTemplate cmdlet;
  * Added Telemetry for version of PowerShell used;
  * Added a timeout on new version check from the
    PowerShell Gallery;
  * Fixed Unit Test stubs;

## 1.20.1028.1

* EXOOutboundConnector
  * Fixed issue #821;
* O365OrgCustomizationSetting
  * Fixes an issue where the resource was not being exported;
* O365User
  * Added additional information in the error log for when
    we try to set an invalid license
* ODSettings
  * Removed AD group guid dependency issue # 862
* SPOTenantSettings
  * Parameter RequireAcceptingAccountMatchInvitedAccount
    is now deprecated (Issue #864)
* SPOSharingSettings
  * Fixed issue # 855
  * Fixed issue # 866 changed domains to array
  * Fixed issue where trying to set anonymous link types if
    sharing not properly configured issue #865
* SPOTheme
  * Fixed issue where Palette was not being properly extracted as
    an array of CIMInstances.
* TeamsTeam
  * Added support for visibility HiddenMembership
* MODULES
  * M365DSCUtil
    * Fixed an issue where function Test-M365DSCObjectHasProperty was missing
    (Issue #861)
  * M365DSCReverse
    * Fixed an issue where passing in the file name and using the GUI for
      extraction did not store the file at the specified location (Issue #810)
    * Fixed and issue where the -GenerateInfo parameter would always generate
      a link to the same resource.
    * Added current version module in the Export file.
* MISC
  * Added Authentication Type used to the Telemetry Engine.
* DEPENDENCIES
  * AzureADPreview Updated to 2.0.2.119
  * DSCParser Updated to 1.3.0.0
  * Microsoft.Graph.Authentication Updated to 1.1.0
  * Microsoft.Graph.Planner Updated to 1.1.0
  * Microsoft.PowerApps.Administration.PowerShell Updated
    to 2.0.96;

## 1.20.1021.1

* AADTenantDetails
  * Fixed issue where IsSingleInstance was not returned from
    the Get-TargetResource method;
* MISC
  * Fix to how Telemetry is retrieving module version;
  * Added additional error troubleshooting information
    to telemetry (dependencies version).

## 1.20.1016.1

* Fixed a permissions issue with the
  Install-M365DSCDevBranch cmdlet (Issue #699 & #826)
* DEPENDENCIES
  * MSCloudLoginAssistant Updated to 1.0.41;
  * SharePointPnPPowerShellOnline Updated to 3.26.2010.0;
* MISC
  * Improved Error log to include StackTrace for additional
    info to help troubleshooting errors.

## 1.20.1014.1

* TeamsVoiceRoute
  * Initial Release

## 1.20.1007.1

* TeamsCallingPolicy
  * Added new supported properties;
* TeamsMeetingPolicy
  * Added new supported properties;
* TeamsTeam
  * Added new supported properties;

## 1.20.930.1

* IntuneAppConfigurationPolicy
  * Initial Release;
* DEPENDENCIES
  * Rolled back ExchangeOnlineManagement to 2.0.1
  * Microsoft.PowerApps.Administration.PowerShell updated
    to 2.0.85;
  * Microsoft.Graph.Authentication updated to 1.0.1;
  * Microsoft.Graph.Groups.Planner updated to 1.0.1;
* MISC
  * Refactored error handling to various EXO resources;
  * Renamed method Test-Microsoft365DSCParameterState to
    Test-M365DSCParameterState to align with naming standard;
  * Fixed issue #777 with export of SCDLPComplianceRule;

## 1.20.923.1

* IntuneDeviceCategory
  * Initial Release;
* SPOSite
  * Fixed an issue where updating a site's properties
    would throw an error complaining about the object
    not being in a correct state.
* DEPENDENCIES
  * AADPreview Updated to 2.0.2.117;
  * ExchangeOnlineManagement Updated to 2.0.3;
  * MSCloudLoginAssistant Updated to 1.0.40;
  * ReverseDSC Updated to 2.0.0.7;
* Misc
  * Removed EncryptionTemplateID from SCSensitivityLabel (Issue #758)
  * Added AzureAD app support SPOSiteDesign
  * Added possibility to provide a custom header to Blueprint
    assessment and delta reports.

## 1.20.916.1

* AADServicePrincipal
  * Initial Release (Issue #492)
* EXOAvailabilityAddressSpace
  * Fixed an issue where if the user didn't have proper permissions
    the entire Export process would stop;
* EXOAvailabilityConfig
  * Fixed an issue where if the user didn't have proper permissions
    the entire Export process would stop;
* EXOEmailAddressPolicy
  * Fixed an issue where if the user didn't have proper permissions
    the entire Export process would stop;
* DEPENDENCIES
  * MicrosoftTeams Updated to 1.1.6;
  * MSCloudLoginAssistant Updated to 1.0.38;
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.81;
* MISC
  * Fixed issue with warning about unsupported resources in the
    Export mode based on authentication selected.
  * Fixes an issue in the Install-M365DSCDevBranch function
    where if the manifest file had a leading 0 in the version
    number (e.g. 1.20.0902.1), it would create the folder as
    a version with the '0' where the Gallery trims it.
    (Issue #685)

## 1.20.909.1

* EXOApplicationAccessPolicy
  * Added some error handling around the
    Get-ApplicationAccessPolicy cmdlet
    (Issue #702);
*EXOSharedMailbox
  * Fixed an issue where Aliases were not properly removed
    (Issue #749);
* TeamsCallingPolicy
  * Added support for the AllowWebPSTNCalling and Description
    properties;
* TeamsChannel
  * Fixed an error in the Export when trying to connect using
    only an Azure AD Application without any credentials
    (Issue #754);
* TeamsClientConfiguration
  * Added support for the AllowEgnyte property
  (Issue #744);
* TeamsUser
  * Fixed an issue where for large tenants the Export could
    failed due to a percentage of completion greater than
    100% for the Write-Progress
    (Issue #722);
* MISC
  * Fixed an issue where the OD checkbox was always disabled
    in the GUI;
  * Changed the logic of the Unselect All button in the GUI
    so that it doesn't unselect the authentication checkboxes;
  * Fixed an issue where SPOHubSite was left selected in the
    Export GUI even when unselecting the entire SPO Workload
    (Issue #735);
  * Fixed an issue where if no Destination Path was provided
    after an export, it would fail. It now defaults to the
    current location
    (Issue #698);
  * Fixed issue SCSensitivityLabel on EncryptionRightsDefinitions parameters
    format (Issue #758)
* DEPENDENCIES
  * MSCloudLoginAssistant Updated to 1.0.34;
  * Microsoft.PowerApps.Administration.PowerShell Updated to 2.0.77;
  * SharePointPnPPowerShellOnline Updated to 3.25.2009.1;

## 1.20.902.1

* O365User
  * Fixed an issue where we were trying to assign an empty
    license to a user if an empty array was passed for
    LicenseAssignment.
* SCComplianceSearchAction
  * Added 'Preview' as a supported value for Action;
* ReverseDSC
  * Fixed an issue where a newline was missing in the
    credentials section when a certificate password was
    specified;
* MISC
  * Added a new Assert-M365DSCBlueprint function to generate
    discrepancy report between export of tenant and a BluePrint;
* Metadata
  * Updated DSCParser Module to version 1.2.0.0;
  * Updated Microsoft.Graph.Authentication Module to version
    0.9.1;
  * Updated Microsoft.Graph.Groups.Planner Module to version
    0.9.1;
  * Updated Microsoft.Graph.Identity.ConditionalAccess Module
    to version 0.9.1;
  * Updated Microsoft.Graph.Planner Module to version
    0.9.1;
  * Updated Microsoft.PowerApps.Administration.PowerShell Module
    to version 0.9.1;
  * Updated SharePointPnPPowerShellOnline Module to version
    3.24.2008.1;

## 1.20.805.1

* EXOAvailabilityConfig
  * Fixed an issue with the Test-TargetResource where if a full
    username (with '@') was specified for the OrgWideAccount, it
    would always return false;
* EXOMobileDeviceMailboxPolicy
  * Fixed an error where if no MinPasswordLength was specified
    the Set-TargetResource threw n error trying to create a new
    policy;
* EXOInboundConnector
  * Fixed an issue where ResourceName was null during the export;
* EXOOutboundConnector
  * Fixed an issue where ResourceName was null during the export;
* ODSettings
  * Fixed an issue where the GrooveBlockOption setting was never
    set properly;
* SCSensitivityLabel
  * Added new parameters

## 1.20.730.2

* AADMSGroup
  * Fixed an issue where if GroupID was not passed, we could end up
    with duplicate teams.
* MISC
  * If a newer version of the module is available in the PowerShell
    Gallery, a notification will be displayed to the user;

## 1.20.730.1

* AADApplication
  * Removed the ObjectId parameter from the list of parameters
    checked in the Test-TargetResource;
* AADGroupsSettings
  * Fixed an issue where the values returned by Get-TargetResource were
    always set to true due to an invalid cast;
* O365User
  * Fixed an issue where no licenses specified resulted in an error;
* Metadata
  * Updated MSCloudLoginAssistant Module to version 1.0.32;

## 1.20.723.1

* MISC
  * Update to the Telemetry engine to capture information about tenant;

## 1.20.722.1

* AADApplication
  * Fix an issue where a new AzureAD Application was not created
    if ObjectId was specified;
* O365User
  * Fixed an issue where the PasswordNeverExpires value returned
    was incorrect;
* SPOAPP
  * Added property Path as a key for the SPOApp resource to
    prevent conflict where two solutions could have the same
    name;
* MISC
  * Renamed the event log to M365DSC to avoid journal conflicts;
* Metadata
  * Updated Microsoft.Graph.Authentication module version to 0.7.1;
  * Updated Microsoft.PowerApps.Administration.PowerShell version to
    2.0.72;
  * Updated SharePointPnPPowerShellOnline version to 3.23.2007.1;

* SPOSiteScript;
  * Initial Release;

## 1.20.716.1

* MISC
  * Added visual indicators for the Export feature;
* EXOMalwareFilterPolicy
  * Fixed an issue where the value for the for the Action
    returned by the Get included 'Text' and should not have;
* EXOOutboundConnector
  * Fixed an issue where the ConnectorSource value returned
    was empty. Now defaulting to Default.
* O365User
  * Fixed issue with PasswordNeverExpires having incorrect value
* PlannerBucket
  * Initial Release;
* PlannerPlan
  * Initial Release;
* PlannerTask
  * Initial Release;
* Metadata
  * Updated ExchangeOnline module version to 1.0.1;
  * Updated Microsoft.Graph module version to 0.7.0;
  * Updated Microsoft.Graph.Identity.ConditionalAccess
    module version to 0.7.0;
  * Updated Microsoft.PowerApps.Administration.PowerShell
    module version to 2.0.70;
  * Updated MSCloudLoginAssistant Module to version 1.0.30;
  * Updated SharePointPnPPowerShellOnline module to version 3.23.2007.0;
  * Updated ReverseDSC module version to 2.0.0.4;
  * Updated SharePointPnPPowerShellOnline module to
    version 3.22.2006.2;
  * Updated all Unit Tests to Pester 5;
  * Added support for Service Principal for PowerPlatforms,
    SPO & OneDrive, Exchange Online and Office 365 resources;

## 1.20.0603.1

* Microsoft365Dsc
  * Improved event log function
* EXOEmailAddressPolicy
  * Converted hardcoded tenant name into variables;
* EXOHostedContentFilterPolicy
  * Added 'NoAction' as a valid input for property BulkSpamAction;
* EXOInboundConnector
  * Fixed an issue where if the connector was created with a source
    of 'AdminUI', we now convert it to 'Default' in the Get function;
* EXOOutboundConnector
  * Fixed an issue where if the connector was created with a source
    of 'AdminUI', we now convert it to 'Default' in the Get function;
* TeamsTenantDialPlan
  * Fixed an issue extraction plans without any normalization rules;
* Modules
  * M365DSCUtil:
    * Fixed an issue in Test-Microsoft365DSCParameterState where
      the same array of object was always being compared;
    * Issue 612 - Fixed an extra '}' in the event log output;

* Metadata
  * Updated AzureADPreview to 2.0.2.102;
  * Updated MSCloudLoginAssistant to 1.0.23;
  * Updated Microsoft.PowerApps.Administration.PowerShell
    to 2.0.64;
  * Updated ReverseDSC to 2.0.0.3;
  * Updated SharePointPnPPowerShellOnline to 3.21.2005.2;
* Misc
  * Azure DevOPS Pipelines and AppVeyor Tests converted to GitHub
    Actions;

## 1.0.5.128

* AADGroupsNamingPolicy
  * Added support for AzureAD Application Authentication;
* AADGroupsSettings
  * Added support for AzureAD Application Authentication;
  * Fixed issue where properties were returned as string instead
    of boolean;
* AADMSGroup
  * Initial Release;
* AADMSGroupLifecyclePolicy
  * Added support for AzureAD Application Authentication;
* TeamsChannel
  * Added support for AzureAD Application Authentication;
* TeamsTeam
  * Added support for AzureAD Application Authentication;
* TeamsTenantDialPlan
  * Initial Release;
* TeamsUser
  * Added support for AzureAD Application Authentication;
* Modules
  * Added M365DSCAgent;
  * Added M365DSCReport;
* Metadata
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.57;
  * Updated MicrosoftTeams to 1.0.6;
  * Updated MSCloudLoginAssistant to 1.0.14;
  * Introduced dependency on the EXchangeOnlineManagement module;
  * Introduced dependency on the Microsoft.Graph.Authentication module;
  * Introduced dependency on the Microsoft.Graph.Identity.ConditionalAccess
    module;
  * Introduced dependency on the DSCParser module;

## 1.0.4.39

* Re-branding to Microsoft365DSC
  * All components re-branded;
* AADMSGroupLifecyclePolicy
  * Initial Release;
* AADGroupsNamingPolicy
  * Initial Release;
* AADGroupsSettings
  * Initial Release;
* AADMSGroupLifecyclePolicy
  * Initial Release;
* SCAuditConfigurationPolicy
  * Fix issue with the Remove scenario;
* SCDLPCompliancePolicy
  * Fix issue with the Remove scenario;
* SCFilePropertyAuthority
  * Fix issue with the Remove scenario;
* SCFilePlanPropertyCategory
  * Fix issue with the Remove scenario;
* SCFilePlanPropertyCitation
  * Fix issue with the Remove scenario;
* SCFilePlanPropertyDepartment
  * Fix issue with the Remove scenario;
* SCFilePlanPropertyReferenceId
  * Fix issue with the Remove scenario;
* SCFilePlanPropertySubCategory
  * Fix issue with the Remove scenario
* SCRetentionCompliancePolicy
  * Fix issue with Teams Policy in the Get;
* SPOPropertyBag
  * Fixed an issue where false positive drifts were being detected;
* SPOSiteAuditSettings
  * Generalized the URL not to capture hardcoded domains;
* SPOSiteGroup
  * Fixed an issue where now, groups with Null owners are not extracted;
  * Generalized the URL not to capture hardcoded domains;
* TeamsCallingPolicy
  * Removed the AllowCalling parameter since it is no longer supported;
  * Fixed an issue with Policies without tags in their name (e.g. Global);
* TeamsMessagingPolicy
  * Fixed and issue where the Global policy was always flagged as having
    a drift;
* TeamsUpgradePolicy
  * Initial Release;
* M365DSCUtil
  * Added the new Assert-M365DSCTemplate cmdlet to assess remote templates;
* ReverseDSC
  * Change to allow ComponentsToExtract without the 'chck' prefix;
  * Introduction of Extraction Modes and Visual Indicators;
  * Major refactoring, having UI dynamic and items displayed by
    Resources' names;
* Metadata
  * Updated Microsoft.PowerApps.Administration.PowerShell to 2.0.56;
  * Updated MicrosoftTeams dependency to 1.0.5;
  * Updated MSCloudLoginAssistant dependency to 1.0.6;
  * Updated SharePointPnPPowerShellOnline dependency to 3.20.2004.0;

## 1.0.3.1723

* EXOHostedOutboundSpamFilterPolicy
  * BREAKING CHANGE: Remove IsSingleInstance and added
    Identity as key;
* SPOSite
  * Refactor to use PnP and expose updated parameters;
* TeamsGuestMessagingConfiguration
  * Added value NoRestriction for GiphyRatingValues;
* Metadata
  * Removed dependency on MSOnline;
  * Updated MSCloudLoginAssistant dependency to 1.0.2;
  * Updated SharePointPnPPowerShellOnline dependency to 3.18.2002.0;
  * Updated Microsoft.PowerApps.Administration.PowerShell
    dependency to 2.0.42;

## 1.0.2.1583

* EXOAcceptedDomain
  * Fixed an issue where the domains were not properly extracted
    if multiple domain matches a similar pattern;
* EXOHostedOutboundSpamFilterPolicy
  * Fixed an error where the resource was not being extracted via
    the Graphical User Interface;
* SCComplianceTag
  * Fix an issue where FilePlanProperty values returned
    from Get-TargetResource where always empty;
* SCDLPComplianceRule
  * Fixed an issue with multiple SensitiveInformation objects;
  * Fixed an issue where extraction failed if the name of the
    Sensitive Information property contained apostrophes;
* SCFilePlanPropertySubCategory
  * Fixed an issue where the Sub-Categories were not properly extracted,
    whenever the parent category is custom;
* TeamsEmergencyCallingPolicy
  * Initial Release;
* TeamsEmergencyCallRoutingPolicy
  * Initial Release;
* TeamsGuestCallingConfiguration
  * Initial Release;
* TeamsGuestMeetingConfiguration
  * Initial Release;
* TeamsGuestMessagingConfiguration
  * Initial Release;
* TeamsMeetingBroadcastPolicy
  * Initial Release;
* ReverseDSC
  * Updated Graphical User Interface with new resources;
  * Streamlined the looping logic to simplify development process
    for new resources;
* Metadata
  * Updated Microsoft.Online.SharePoint.PowerShell to version
    16.0.19515.12000;
  * Updated ReverseDSC dependency to version 2.0.0.2;
  * Updated SharePointPnPPowerShellOnline to version 3.17.2001.2;
* SPOHomeSite
  * Initial Release;

## 1.0.1.1395

* EXOOrganizationConfig
  * Initial Release;
* EXOClientAccessRule
  * Fixed issue with Get-TargetResource not
    returning all values;
* O365OrgCustomizationSetting
  * Inital Release;
* PPPowerAppsEnvironment
  * Initial Release;
* SCAuditConfigurationSettings
  * Initial Release;
* SCComplianceTag
  * Changed ReviewerEmail to type String array;
* SCDLPComplianceRule
  * Fixed issue with the extraction of NotifyAllowOverride;
* SCFilePlanPropertyAuthority
  * Initial Release;
* SCFilePlanPropertyCategory
  * Initial Release;
* SCFilePlanPropertyCitation
  * Initial Release;
* SCFilePlanPropertyDepartment
  * Initial Release;
* SCFilePlanPropertyReferenceID
  * Initial Release;
* SCFilePlanPropertySubCategory
  * Initial Release;
* SPOPropertyBag
  * Added multithreading;
* SPOSiteGroup
  * Initial Release;
* SPOSharingSettings
  * Added ExistingExternalUserSharingOnly as a supported value
    for SharingCapabilities;
* SPOTheme
  * Fixed an issue with the Set-TargetResource
    still using SPO management shell cmdlets instead of PnP;
* SPOUserProfileProperty
  * Introduced Multi-Threading
* TeamsCallingPolicy
  * Initial Release;
* TeamsMeetingBroadcastConfiguration
  * Initial Release;
* TeamsMeetingConfiguration
  * Initial Release;
* TeamsMeetingPolicy
  * Initial Release;
* TeamsMessagingPolicy
  * Initial Release;
* TeamsUpgradeConfiguration
  * Initial Release;
* TeamsUser
  * Introduced Multi-Threading;
  * Fixed an issue with User's Principal Name;
* Metadata
  * Updated MicrosoftTeams dependency to version 1.0.3;
  * Updated MSCloudLoginAssistant dependency to version
    0.8.2;
  * Updated SharePointPnPPowerShellOnline dependency
    to version 3.16.1912.0;
  * Updated ReverseDSC dependency to version 2.0.0.0;
* Misc
  * Added new Telemetry Engine;
  * Added new Dynamic Stubs Generation feature;

## 1.0.0.1048

* SCCaseHoldPolicy
  * New Resource;
* SCComplianceCase
  * New Resource;
* SCComplianceSearch
  * New Resource;
* SCComplianceSearchAction
  * New Resource;
* SCDLPComplianceRule
  * New Resource;
* SPOPropertyBag
  * New Resource;
* SPOSiteAuditSettings
  * New Resource;
* SPOTenantCDNPolicy
  * New Resource;
* Reverse
  * Added workload selectors to the GUI interface;
* Metadata
  * Updated MSCloudLoginAssistant dependency
    to version 0.8.3;
  * Updated ReverseDSC dependency
    to version 1.9.4.6;
  * Updated Microsoft.Online.SharePoint.PowerShell dependency
    to version 16.0.19223.12000;
  * Updated MicrosoftTeams dependency to version 1.0.0.2;
  * Updated SharePointPnPPowerShellOnline dependency
    to version 3.14.1910.0

## 1.0.0.846

* Modules
  * ReverseDSC
    * Added all missing Security and Compliance items;
* EXOATPPolicyForO365
  * Fixed issue where we now extract any policy,
    not just default;
* SCDLPCompliancePolicy
  * New Resource;
* SCRetentionCompliancePolicy
  * Changed logic to update existing Policy;
* Metadata
  * Updated SharePointPnPPowerShellOnline dependency
    to version 3.12.1908.1;
  * Updated MSCloudLoginAssistant dependency to
    version 0.6;

## 1.0.0.776

* BREAKING CHANGES
  * ODSettings
    * IsSingleInstance is now a Mandatory parameter;
    * Removed CentralAdminUrl as a parameter;
  * SPOAccessControlSettings
    * Removed CentralAdminUrl as a parameter;
  * SPOAPP
    * Removed CentralAdminUrl as a parameter;
  * SPOHubSite
    * Removed CentralAdminUrl as a parameter;
  * SPOSearchManagedProperty
    * Removed CentralAdminUrl as a parameter;
  * SPOSearchResultSource
    * Removed CentralAdminUrl as a parameter;
  * SPOSharingSettings
    * Removed CentralAdminUrl as a parameter;
  * SPOSite
    * Removed CentralAdminUrl as a parameter;
  * SPOSiteDesign
    * Removed CentralAdminUrl as a parameter;
  * SPOSiteDesignRights
    * Removed CentralAdminUrl as a parameter;
  * SPOTenantSettings
    * Removed CentralAdminUrl as a parameter;
  * SPOTheme
    * Removed CentralAdminUrl as a parameter;
* Metadata
  * Updated version dependency for MSCloudLoginAssistant
    to 0.5.8;
* Modules
  * ReverseDSC
    * Fixed some issues with the abstraction of tenant name
      when the -Quiet switch is used;
* SPOApp
  * Change logic for detection when no App Catalog exist;

## 1.0.0.744

* GENERAL
  * Updated Dependency on SharePointPnPPowerShellOnline
    to version 3.11.1907.0
* BREAKING CHANGES
  * O365Group
    * ManagedBy is now a mandatory property;
  * SPOSite
    * Owner is now a mandatory property
* Modules
  * Added embedded Log Engine
* SCRetentionCompliancePolicy
  * Initial Release;
* SCRetentionComplianceRule
  * Initial Release
* SCSupervisoryReviewPolicy
  * Initial Release
* SCSupervisoryReviewRule
  * Initial Release
* SPOSite
  * Added default value for Storage Quota;
  * Fixed an issue with site creation that could result in infinite loops;
