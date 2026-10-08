using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppProtectionPolicyAndroid : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Android App Protection Policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Android App Protection Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Semicolon separated list of device manufacturers allowed, as a string, for the managed app to work.')]
    [System.String] $AllowedAndroidDeviceManufacturers

    [DscProperty()]
    [System.ComponentModel.Description('List of allowed Android device models.')]
    [System.String[]] $AllowedAndroidDeviceModels

    [DscProperty()]
    [System.ComponentModel.Description('Maximum length of outbound clipboard sharing exceptions.')]
    [System.Nullable[System.UInt32]] $AllowedOutboundClipboardSharingExceptionLength

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether biometric authentication is blocked.')]
    [System.Nullable[System.Boolean]] $BiometricAuthenticationBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Number of days to block access after a company portal update deferral.')]
    [System.Nullable[System.UInt32]] $BlockAfterCompanyPortalUpdateDeferralInDays

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether data ingestion into organization documents is blocked.')]
    [System.Nullable[System.Boolean]] $BlockDataIngestionIntoOrganizationDocuments

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to connect to VPN on launch.')]
    [System.Nullable[System.Boolean]] $ConnectToVpnOnLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the custom dialer app.')]
    [System.String] $CustomDialerAppDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Package ID of the custom dialer app.')]
    [System.String] $CustomDialerAppPackageId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether device lock is required.')]
    [System.Nullable[System.Boolean]] $DeviceLockRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether fingerprint and biometric authentication are enabled.')]
    [System.Nullable[System.Boolean]] $FingerprintAndBiometricEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether keyboards are restricted.')]
    [System.Nullable[System.Boolean]] $KeyboardsRestricted

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the messaging redirect app.')]
    [System.String] $MessagingRedirectAppDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Package ID of the messaging redirect app.')]
    [System.String] $MessagingRedirectAppPackageId

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will wipe the managed app and the associated company data.')]
    [System.String] $MinimumWipeAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum version of the Company portal that must be installed on the device or the company data on the app will be wiped')]
    [System.String] $MinimumWipeCompanyPortalVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will wipe the managed app and the associated company data.')]
    [System.String] $MinimumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum required patch version for wipe.')]
    [System.String] $MinimumWipePatchVersion

    [DscProperty()]
    [System.ComponentModel.Description('Number of previous PIN block counts.')]
    [System.Nullable[System.UInt32]] $PreviousPinBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Number of days to warn after a company portal update deferral.')]
    [System.Nullable[System.UInt32]] $WarnAfterCompanyPortalUpdateDeferralInDays

    [DscProperty()]
    [System.ComponentModel.Description('Number of days to wipe after a company portal update deferral.')]
    [System.Nullable[System.UInt32]] $WipeAfterCompanyPortalUpdateDeferralInDays

    [DscProperty()]
    [System.ComponentModel.Description('Sources from which data is allowed to be transferred.')]
    [System.String[]] $AllowedDataIngestionLocations

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or warn, if the user is clocked out (non-working time). Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAccountIsClockedOut

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, if the specified device manufacturer is not allowed.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAndroidDeviceManufacturerNotAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, if the specified device model is not allowed.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAndroidDeviceModelNotAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either warn or block, if the specified Android App Verification requirement fails.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAndroidSafetyNetAppsVerificationFailed

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either warn or block, if the specified Android SafetyNet Attestation requirement fails.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAndroidSafetyNetDeviceAttestationFailed

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, when the device is either rooted or jailbroken, if DeviceComplianceRequired is set to true.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDeviceComplianceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either warn, block, or wipe, if the screen lock is required on an Android device but is not set.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDeviceLockNotSet

    [DscProperty()]
    [System.ComponentModel.Description('If the device does not have a passcode of high complexity or higher, trigger the stored action. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDevicePasscodeComplexityLessThanHigh

    [DscProperty()]
    [System.ComponentModel.Description('If the device does not have a passcode of low complexity or higher, trigger the stored action. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDevicePasscodeComplexityLessThanLow

    [DscProperty()]
    [System.ComponentModel.Description('If the device does not have a passcode of medium complexity or higher, trigger the stored action. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDevicePasscodeComplexityLessThanMedium

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, based on the maximum number of incorrect pin retry attempts.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfMaximumPinRetriesExceeded

    [DscProperty()]
    [System.ComponentModel.Description('Defines the behavior of a managed app when Samsung Knox Attestation is required. Possible values are null, warn, block & wipe. If the admin does not set this action, the default is null, which indicates this setting is not configured. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfSamsungKnoxAttestationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what action to take in the case where the user is unable to check in because their authentication token is invalid, such as when the user is deleted or disabled in Azure AD.')]
    [ValidateSet('block', 'wipe', 'warn', 'BlockWhenSettingIsSupported')]
    [System.String] $appActionIfUnableToAuthenticateUser

    [DscProperty()]
    [System.ComponentModel.Description('Indicates how to prioritize which Mobile Threat Defense (MTD) partner is enabled for a given platform, when more than one is enabled. An app can only be actively using a single Mobile Threat Defense partner. When NULL, Microsoft Defender will be given preference. Otherwise setting the value to defenderOverThirdPartyPartner or thirdPartyPartnerOverDefender will make explicit which partner to prioritize. Possible values are: null, defenderOverThirdPartyPartner, thirdPartyPartnerOverDefender and unknownFutureValue. Default value is null. Possible values are: defenderOverThirdPartyPartner, thirdPartyPartnerOverDefender, unknownFutureValue.')]
    [ValidateSet('defenderOverThirdPartyPartner', 'thirdPartyPartnerOverDefender')]
    [System.String] $MobileThreatDefensePartnerPriority

    [DscProperty()]
    [System.ComponentModel.Description('Determines what action to take if the mobile threat defense threat threshold isn''t met. Warn isn''t a supported value for this property.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $MobileThreatDefenseRemediationAction

    [DscProperty()]
    [System.ComponentModel.Description('The classes of dialer apps that are allowed to click-to-open a phone number. Inherited from managedAppProtection.')]
    [ValidateSet('allApps', 'managedApps', 'customApp', 'blocked')]
    [System.String] $DialerRestrictionLevel

    [DscProperty()]
    [System.ComponentModel.Description('Maximum allowed device threat level, as reported by the MTD app. Inherited from managedAppProtection.')]
    [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
    [System.String] $MaximumAllowedDeviceThreatLevel

    [DscProperty()]
    [System.ComponentModel.Description('Specify app notification restriction. Inherited from managedAppProtection.')]
    [ValidateSet('allow', 'blockOrganizationalData', 'block')]
    [System.String] $NotificationRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Defines how app messaging redirection is protected by an App Protection Policy. Default is anyApp. Inherited from managedAppProtection.')]
    [ValidateSet('anyApp', 'anyManagedApp', 'specificApps', 'blocked')]
    [System.String] $ProtectedMessagingRedirectAppType

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a Microsoft Purview content evaluation is required. The possible values are: notRequired, requiredWhenOnline, required.')]
    [ValidateSet('notRequired', 'requiredWhenOnline', 'required')]
    [System.String] $PurviewContentEvaluationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Defines the Android SafetyNet Apps Verification requirement for a managed app to work.')]
    [ValidateSet('none', 'enabled')]
    [System.String] $RequiredAndroidSafetyNetAppsVerificationType

    [DscProperty()]
    [System.ComponentModel.Description('Defines the Android SafetyNet Device Attestation requirement for a managed app to work.')]
    [ValidateSet('none', 'basicIntegrity', 'basicIntegrityAndDeviceCertification')]
    [System.String] $RequiredAndroidSafetyNetDeviceAttestationType

    [DscProperty()]
    [System.ComponentModel.Description('Defines the Android SafetyNet evaluation type requirement for a managed app to work.')]
    [ValidateSet('basic', 'hardwareBacked')]
    [System.String] $RequiredAndroidSafetyNetEvaluationType

    [DscProperty()]
    [System.ComponentModel.Description('The intended app management levels for this policy. Inherited from targetedManagedAppProtection.')]
    [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise', 'androidEnterpriseDedicatedDevicesWithAzureAdSharedMode', 'androidOpenSourceProjectUserAssociated', 'androidOpenSourceProjectUserless', 'unknownFutureValue')]
    [System.String] $TargetedAppManagementLevels

    [DscProperty()]
    [System.ComponentModel.Description('If Keyboard Restriction is enabled, only keyboards in this approved list will be allowed. A key should be Android package id for a keyboard and value should be a friendly name.')]
    [System.String[]] $ApprovedKeyboards

    [DscProperty()]
    [System.ComponentModel.Description('App packages in this list will be exempt from the policy and will be able to receive data from managed apps.')]
    [System.String[]] $ExemptedAppPackages

    [DscProperty()]
    [System.ComponentModel.Description('A grace period before blocking app access during off clock hours.')]
    [System.String] $GracePeriodToBlockAppsDuringOffClockHours

    [DscProperty()]
    [System.ComponentModel.Description('The period after which access is checked when the device is not connected to the internet. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodOfflineBeforeAccessCheck

    [DscProperty()]
    [System.ComponentModel.Description('The period after which access is checked when the device is connected to the internet. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodOnlineBeforeAccessCheck

    [DscProperty()]
    [System.ComponentModel.Description('Timeout in minutes for an app pin instead of non biometrics passcode')]
    [System.String] $PinRequiredInsteadOfBiometricTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Sources from which data is allowed to be transferred. Possible values are: allApps, managedApps, none.')]
    [ValidateSet('allApps', 'managedApps', 'none')]
    [System.String] $AllowedInboundDataTransferSources

    [DscProperty()]
    [System.ComponentModel.Description('Destinations to which data is allowed to be transferred. Possible values are: allApps, managedApps, none.')]
    [ValidateSet('allApps', 'managedApps', 'none')]
    [System.String] $AllowedOutboundDataTransferDestinations

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether organizational credentials are required for app use.')]
    [System.Nullable[System.Boolean]] $OrganizationalCredentialsRequired

    [DscProperty()]
    [System.ComponentModel.Description('The level to which the clipboard may be shared between apps on the managed device. Possible values are: allApps, managedAppsWithPasteIn, managedApps, blocked.')]
    [ValidateSet('allApps', 'managedAppsWithPasteIn', 'managedApps', 'blocked')]
    [System.String] $AllowedOutboundClipboardSharingLevel

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the backup of a managed app''s data is blocked.')]
    [System.Nullable[System.Boolean]] $DataBackupBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether device compliance is required.')]
    [System.Nullable[System.Boolean]] $DeviceComplianceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether internet links should be opened in the managed browser app, or any custom browser specified by CustomBrowserProtocol (for Android) or CustomBrowserPackageId/CustomBrowserDisplayName (for Android).')]
    [System.Nullable[System.Boolean]] $ManagedBrowserToOpenLinksRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether users may use the Save As menu item to save a copy of protected files.')]
    [System.Nullable[System.Boolean]] $SaveAsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('The amount of time an app is allowed to remain disconnected from the internet before all managed data it is wiped. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodOfflineBeforeWipeIsEnforced

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether an app-level pin is required.')]
    [System.Nullable[System.Boolean]] $PinRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether use of the app pin is required if the device pin is set.')]
    [System.Nullable[System.Boolean]] $DisableAppPinIfDevicePinIsSet

    [DscProperty()]
    [System.ComponentModel.Description('Maximum number of incorrect pin retry attempts before the managed app is either blocked or wiped.')]
    [System.Nullable[System.UInt32]] $MaximumPinRetries

    [DscProperty()]
    [System.ComponentModel.Description('Block simple PIN and require complex PIN to be set.')]
    [System.Nullable[System.Boolean]] $SimplePinBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Minimum pin length required for an app-level pin if PinRequired is set to True.')]
    [System.Nullable[System.UInt32]] $MinimumPinLength

    [DscProperty()]
    [System.ComponentModel.Description('Character set which may be used for an app-level pin if PinRequired is set to True. Possible values are: numeric, alphanumericAndSymbol.')]
    [ValidateSet('numeric', 'alphanumericAndSymbol')]
    [System.String] $PinCharacterSet

    [DscProperty()]
    [System.ComponentModel.Description('Data storage locations where a user may store managed data.')]
    [System.String[]] $AllowedDataStorageLocations

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether contacts can be synced to the user''s device.')]
    [System.Nullable[System.Boolean]] $ContactSyncBlocked

    [DscProperty()]
    [System.ComponentModel.Description('TimePeriod before the all-level pin must be reset if PinRequired is set to True. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodBeforePinReset

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether printing is allowed from managed apps.')]
    [System.Nullable[System.Boolean]] $PrintBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Require user to apply Class 3 Biometrics on their Android device.')]
    [System.Nullable[System.Boolean]] $RequireClass3Biometrics

    [DscProperty()]
    [System.ComponentModel.Description('A PIN prompt will override biometric prompts if class 3 biometrics are updated on the device.')]
    [System.Nullable[System.Boolean]] $RequirePinAfterBiometricChange

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether use of the fingerprint reader is allowed in place of a pin if PinRequired is set to True.')]
    [System.Nullable[System.Boolean]] $FingerprintBlocked

    [DscProperty()]
    [System.ComponentModel.Description('List of IDs representing the Android apps controlled by this protection policy.')]
    [System.String[]] $Apps

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Android Protection Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('ID of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('ID of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Indicates in which managed browser(s) that internet links should be opened. Used in conjunction with CustomBrowserPackageId, CustomBrowserDisplayName and ManagedBrowserToOpenLinksRequired. Possible values are: notConfigured, microsoftEdge.')]
    [ValidateSet('notConfigured', 'microsoftEdge')]
    [System.String] $ManagedBrowser

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data.')]
    [System.String] $MaximumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data.')]
    [System.String] $MaximumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data.')]
    [System.String] $MaximumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum version of the Company portal that must be installed on the device or app access will be blocked')]
    [System.String] $MinimumRequiredCompanyPortalVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredPatchVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app')]
    [System.String] $MinimumWarningAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum version of the Company portal that must be installed on the device or the user will receive a warning')]
    [System.String] $MinimumWarningCompanyPortalVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app')]
    [System.String] $MinimumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app')]
    [System.String] $MinimumWarningPatchVersion

    [DscProperty()]
    [System.ComponentModel.Description('The apps controlled by this protection policy, overrides any values in Apps unless this value is ''selectedPublicApps''.')]
    [ValidateSet('allApps', 'allMicrosoftApps', 'allCoreMicrosoftApps', 'selectedPublicApps')]
    [System.String] $AppGroupType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from taking Screenshots.')]
    [System.Nullable[System.Boolean]] $ScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the ''Encrypt org data'' value is enabled.  True = require')]
    [System.Nullable[System.Boolean]] $EncryptAppData

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the ''Encrypt org data on enrolled devices'' value is enabled.  False = require.  Only functions if EncryptAppData is set to True')]
    [System.Nullable[System.Boolean]] $DisableAppEncryptionIfDeviceEncryptionIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The application name for browser associated with the ''Unmanaged Browser ID''. This name will be displayed to users if the specified browser is not installed.')]
    [System.String] $CustomBrowserDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The application ID for a single browser. Web content (http/s) from policy managed applications will open in the specified browser.')]
    [System.String] $CustomBrowserPackageId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy. To avoid creation of duplicate policies DisplayName will be searched for if the ID is not found')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneAppProtectionPolicyAndroid] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppProtectionPolicyAndroid]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Android App Protection Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $policy = $null
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Could not find an Intune App Protection Policy for Android with Id {$($this.Id)}"
                    $policy = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -AndroidManagedAppProtectionId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $policy)
                {
                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        Write-Verbose -Message "Searching for Policy using DisplayName {$($this.DisplayName)}"
                        $policy = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection `
                            -All `
                            -Filter "displayName eq '$($this.DisplayName)'" `
                            -ErrorAction SilentlyContinue
                    }
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "Could not find an Intune App Protection Policy for Android with Name {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }
            $IdArray = [Array]($policy.Id)
            if ($IdArray.Length -gt 1)
            {
                throw 'Multiple Policies with same displayname identified - Module currently only functions with unique names'
            }
            else
            {
                $resolvedId = $policy.Id
            }

            $policyApps = Get-MgBetaDeviceAppManagementAndroidManagedAppProtectionApp -AndroidManagedAppProtectionId $resolvedId

            $appsArray = @()
            if ($policy.AppGroupType -eq 'selectedPublicApps')
            {
                foreach ($app in $policyApps)
                {
                    $appsArray += $app.MobileAppIdentifier.packageId
                }
            }

            $assignmentsValues = Get-MgBetaDeviceAppManagementAndroidManagedAppProtectionAssignment -AndroidManagedAppProtectionId $policy.Id
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                [array]$assignmentsValues = $assignmentsValues | Where-Object -FilterScript { $_.source -eq 'direct' }
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }

            $approvedKeyboardArray = @()
            foreach ($keyboard in $policy.approvedKeyboards)
            {
                $approvedKeyboardArray += $keyboard.Name + '|' + $keyboard.Value
            }

            $exemptedAppPackagesArray = @()
            foreach ($exemptedapppackage in $policy.exemptedAppPackages)
            {
                $exemptedAppPackagesArray += $exemptedapppackage.Name + '|' + $exemptedapppackage.Value
            }

            return $this.AsResult(@{
                AllowedAndroidDeviceManufacturers                  = $policy.AllowedAndroidDeviceManufacturers
                AllowedAndroidDeviceModels                         = $policy.AllowedAndroidDeviceModels
                AllowedDataIngestionLocations                      = [string[]]$policy.AllowedDataIngestionLocations
                AllowedDataStorageLocations                        = [string[]]$policy.AllowedDataStorageLocations
                AllowedInboundDataTransferSources                  = $policy.AllowedInboundDataTransferSources
                AllowedOutboundClipboardSharingExceptionLength     = $policy.AllowedOutboundClipboardSharingExceptionLength
                AllowedOutboundClipboardSharingLevel               = $policy.AllowedOutboundClipboardSharingLevel
                AllowedOutboundDataTransferDestinations            = $policy.AllowedOutboundDataTransferDestinations
                AppActionIfAccountIsClockedOut                     = $policy.AppActionIfAccountIsClockedOut
                AppActionIfAndroidDeviceManufacturerNotAllowed     = $policy.AppActionIfAndroidDeviceManufacturerNotAllowed
                AppActionIfAndroidDeviceModelNotAllowed            = $policy.AppActionIfAndroidDeviceModelNotAllowed
                AppActionIfAndroidSafetyNetAppsVerificationFailed  = $policy.AppActionIfAndroidSafetyNetAppsVerificationFailed
                AppActionIfAndroidSafetyNetDeviceAttestationFailed = $policy.AppActionIfAndroidSafetyNetDeviceAttestationFailed
                AppActionIfDeviceComplianceRequired                = $policy.AppActionIfDeviceComplianceRequired
                AppActionIfDeviceLockNotSet                        = $policy.AppActionIfDeviceLockNotSet
                AppActionIfDevicePasscodeComplexityLessThanHigh    = $policy.AppActionIfDevicePasscodeComplexityLessThanHigh
                AppActionIfDevicePasscodeComplexityLessThanLow     = $policy.AppActionIfDevicePasscodeComplexityLessThanLow
                AppActionIfDevicePasscodeComplexityLessThanMedium  = $policy.AppActionIfDevicePasscodeComplexityLessThanMedium
                AppActionIfMaximumPinRetriesExceeded               = $policy.AppActionIfMaximumPinRetriesExceeded
                AppActionIfSamsungKnoxAttestationRequired          = $policy.AppActionIfSamsungKnoxAttestationRequired
                AppActionIfUnableToAuthenticateUser                = $policy.AppActionIfUnableToAuthenticateUser
                AppGroupType                                       = $policy.AppGroupType.ToString()
                ApprovedKeyboards                                  = $approvedKeyboardArray
                Apps                                               = $appsArray
                Assignments                                        = $assignmentResult
                BiometricAuthenticationBlocked                     = $policy.BiometricAuthenticationBlocked
                BlockAfterCompanyPortalUpdateDeferralInDays        = $policy.BlockAfterCompanyPortalUpdateDeferralInDays
                BlockDataIngestionIntoOrganizationDocuments        = $policy.BlockDataIngestionIntoOrganizationDocuments
                ConnectToVpnOnLaunch                               = $policy.ConnectToVpnOnLaunch
                ContactSyncBlocked                                 = $policy.ContactSyncBlocked
                CustomBrowserDisplayName                           = $policy.CustomBrowserDisplayName
                CustomBrowserPackageId                             = $policy.CustomBrowserPackageId
                CustomDialerAppDisplayName                         = $policy.CustomDialerAppDisplayName
                CustomDialerAppPackageId                           = $policy.CustomDialerAppPackageId
                DataBackupBlocked                                  = $policy.DataBackupBlocked
                Description                                        = $policy.Description
                DeviceComplianceRequired                           = $policy.DeviceComplianceRequired
                DeviceLockRequired                                 = $policy.DeviceLockRequired
                DialerRestrictionLevel                             = $policy.DialerRestrictionLevel
                DisableAppEncryptionIfDeviceEncryptionIsEnabled    = $policy.DisableAppEncryptionIfDeviceEncryptionIsEnabled
                DisableAppPinIfDevicePinIsSet                      = $policy.DisableAppPinIfDevicePinIsSet
                DisplayName                                        = $policy.DisplayName
                EncryptAppData                                     = $policy.EncryptAppData
                ExemptedAppPackages                                = $exemptedAppPackagesArray
                FingerprintAndBiometricEnabled                     = $policy.FingerprintAndBiometricEnabled
                FingerprintBlocked                                 = $policy.FingerprintBlocked
                GracePeriodToBlockAppsDuringOffClockHours          = $policy.GracePeriodToBlockAppsDuringOffClockHours
                Id                                                 = $policy.Id
                KeyboardsRestricted                                = $policy.KeyboardsRestricted
                ManagedBrowser                                     = $policy.ManagedBrowser.ToString()
                ManagedBrowserToOpenLinksRequired                  = $policy.ManagedBrowserToOpenLinksRequired
                MaximumAllowedDeviceThreatLevel                    = $policy.MaximumAllowedDeviceThreatLevel
                MaximumPinRetries                                  = $policy.MaximumPinRetries
                MaximumRequiredOsVersion                           = $policy.MaximumRequiredOsVersion
                MaximumWarningOsVersion                            = $policy.MaximumWarningOsVersion
                MaximumWipeOsVersion                               = $policy.MaximumWipeOsVersion
                MessagingRedirectAppDisplayName                    = $policy.MessagingRedirectAppDisplayName
                MessagingRedirectAppPackageId                      = $policy.MessagingRedirectAppPackageId
                MinimumPinLength                                   = $policy.MinimumPinLength
                MinimumRequiredAppVersion                          = $policy.MinimumRequiredAppVersion
                MinimumRequiredCompanyPortalVersion                = $policy.MinimumRequiredCompanyPortalVersion
                MinimumRequiredOsVersion                           = $policy.MinimumRequiredOsVersion
                MinimumRequiredPatchVersion                        = $policy.MinimumRequiredPatchVersion
                MinimumWarningAppVersion                           = $policy.MinimumWarningAppVersion
                MinimumWarningCompanyPortalVersion                 = $policy.MinimumWarningCompanyPortalVersion
                MinimumWarningOsVersion                            = $policy.MinimumWarningOsVersion
                MinimumWarningPatchVersion                         = $policy.MinimumWarningPatchVersion
                MinimumWipeAppVersion                              = $policy.MinimumWipeAppVersion
                MinimumWipeCompanyPortalVersion                    = $policy.MinimumWipeCompanyPortalVersion
                MinimumWipeOsVersion                               = $policy.MinimumWipeOsVersion
                MinimumWipePatchVersion                            = $policy.MinimumWipePatchVersion
                MobileThreatDefensePartnerPriority                 = $policy.MobileThreatDefensePartnerPriority
                MobileThreatDefenseRemediationAction               = $policy.MobileThreatDefenseRemediationAction
                NotificationRestriction                            = $policy.NotificationRestriction
                OrganizationalCredentialsRequired                  = $policy.OrganizationalCredentialsRequired
                PeriodBeforePinReset                               = $policy.PeriodBeforePinReset
                PeriodOfflineBeforeAccessCheck                     = $policy.PeriodOfflineBeforeAccessCheck
                PeriodOfflineBeforeWipeIsEnforced                  = $policy.PeriodOfflineBeforeWipeIsEnforced
                PeriodOnlineBeforeAccessCheck                      = $policy.PeriodOnlineBeforeAccessCheck
                PinCharacterSet                                    = $policy.PinCharacterSet
                PinRequired                                        = $policy.PinRequired
                PinRequiredInsteadOfBiometricTimeout               = $policy.PinRequiredInsteadOfBiometricTimeout
                PreviousPinBlockCount                              = $policy.PreviousPinBlockCount
                PrintBlocked                                       = $policy.PrintBlocked
                ProtectedMessagingRedirectAppType                  = $policy.ProtectedMessagingRedirectAppType
                PurviewContentEvaluationRequired                   = $policy.PurviewContentEvaluationRequired
                RequireClass3Biometrics                            = $policy.RequireClass3Biometrics
                RequiredAndroidSafetyNetAppsVerificationType       = $policy.RequiredAndroidSafetyNetAppsVerificationType
                RequiredAndroidSafetyNetDeviceAttestationType      = $policy.RequiredAndroidSafetyNetDeviceAttestationType
                RequiredAndroidSafetyNetEvaluationType             = $policy.RequiredAndroidSafetyNetEvaluationType
                RequirePinAfterBiometricChange                     = $policy.RequirePinAfterBiometricChange
                RoleScopeTagIds                                    = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                SaveAsBlocked                                      = $policy.SaveAsBlocked
                ScreenCaptureBlocked                               = $policy.ScreenCaptureBlocked
                SimplePinBlocked                                   = $policy.SimplePinBlocked
                TargetedAppManagementLevels                        = $policy.TargetedAppManagementLevels
                WarnAfterCompanyPortalUpdateDeferralInDays         = $policy.WarnAfterCompanyPortalUpdateDeferralInDays
                WipeAfterCompanyPortalUpdateDeferralInDays         = $policy.WipeAfterCompanyPortalUpdateDeferralInDays
                Ensure                                             = 'Present'
                Credential                                         = $this.Credential
                ApplicationId                                      = $this.ApplicationId
                ApplicationSecret                                  = $this.ApplicationSecret
                TenantId                                           = $this.TenantId
                CertificateThumbprint                              = $this.CertificateThumbprint
                CertificatePath                                    = $this.CertificatePath
                CertificatePassword                                = $this.CertificatePassword
                ManagedIdentity                                    = $this.ManagedIdentity
                AccessTokens                                       = $this.AccessTokens
            })
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune App Protection Policy for Android with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        # The service rejects an empty string on the maximum OS version properties.
        $emptyStringSensitiveProperties = @('MaximumRequiredOsVersion', 'MaximumWarningOsVersion', 'MaximumWipeOsVersion')
        foreach ($property in $emptyStringSensitiveProperties)
        {
            if ([System.String]::IsNullOrEmpty($boundParameters.$property))
            {
                $boundParameters.Remove($property) | Out-Null
            }
        }

        #rebuild array as a MicrosoftGraphKeyValuePair hash table for ApprovedKeyboards
        $myApprovedKeyboards = @()
        foreach ($keyboard in $this.ApprovedKeyboards)
        {
            $myApprovedKeyboards += @{
                name  = $keyboard.Split('|')[0]
                value = $keyboard.Split('|')[1]
            }
        }
        $boundParameters.ApprovedKeyboards = $myApprovedKeyboards

        $myExemptedAppPackages = @()
        foreach ($exemptedAppPackage in $this.ExemptedAppPackages)
        {
            $myExemptedAppPackages += @{
                name  = $exemptedAppPackage.Split('|')[0]
                value = $exemptedAppPackage.Split('|')[1]
            }
        }
        $boundParameters.ExemptedAppPackages = $myExemptedAppPackages

        # Set the managedbrowser values
        $ManagedBrowserValuesHash = $this.SetManagedBrowserValues($boundParameters.ManagedBrowser, $boundParameters.ManagedBrowserToOpenLinksRequired, $boundParameters.CustomBrowserDisplayName, $boundParameters.CustomBrowserPackageId)
        $boundParameters.ManagedBrowser = $ManagedBrowserValuesHash.ManagedBrowser
        $boundParameters.ManagedBrowserToOpenLinksRequired = $ManagedBrowserValuesHash.ManagedBrowserToOpenLinksRequired
        $boundParameters.CustomBrowserDisplayName = $ManagedBrowserValuesHash.CustomBrowserDisplayName
        $boundParameters.CustomBrowserPackageId = $ManagedBrowserValuesHash.CustomBrowserPackageId

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Apps') | Out-Null

            Write-Verbose -Message "Creating new Android App Protection Policy {$($this.DisplayName)}"
            $newpolicy = New-MgBetaDeviceAppManagementAndroidManagedAppProtection -BodyParameter $createParameters

            if ($newPolicy.Id)
            {
                Write-Verbose -Message "Update targetApps for Android App Protection Policy with Id {$($newPolicy.Id)} and DisplayName {$($this.DisplayName)}"
                $targetApps = $this.GetAppsToHashtable($this.Apps, $this.AppGroupType)
                $Url = "/beta/deviceAppManagement/androidManagedAppProtections('$($newPolicy.Id)')/targetApps"
                Invoke-M365DSCGraphRequest -Method POST -Uri $Url -Body $targetApps

                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $newPolicy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/androidManagedAppProtections'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Apps') | Out-Null

            Write-Verbose -Message "Updating existing Android App Protection Policy {$($this.DisplayName)}"
            Update-MgBetaDeviceAppManagementAndroidManagedAppProtection -AndroidManagedAppProtectionId $currentPolicy.Id -BodyParameter $updateParameters

            Write-Verbose -Message "Update targetApps for Android App Protection Policy with Id {$($currentPolicy.Id)} and DisplayName {$($this.DisplayName)}"
            $targetApps = $this.GetAppsToHashtable($this.Apps, $this.AppGroupType)
            $Url = "/beta/deviceAppManagement/androidManagedAppProtections('$($currentPolicy.Id)')/targetApps"
            Invoke-M365DSCGraphRequest -Method POST -Uri $Url -Body $targetApps

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/androidManagedAppProtections'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Android App Protection Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceAppManagementAndroidManagedAppProtection -AndroidManagedAppProtectionId $currentPolicy.id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $complexFunctions = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $mergedFilter = $this.Filter
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $mergedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$policies = Get-MgBetaDeviceAppManagementAndroidManagedAppProtection -All -Filter $mergedFilter -ErrorAction Stop
            $policies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $policies

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.displayName)" -DeferWrite
                $params = @{
                    Id                    = $policy.Id
                    DisplayName           = $policy.DisplayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationID         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.AppGroupType -ne 'SelectedPublicApps')
                {
                    $ValuesToCheck.Remove('Apps')
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    # $CustomDisplayName / $CustomPackageId are deliberately [System.Object] and not [System.String]:
    # the original function took unbound [string] parameters, so an omitted value arrived as $null and
    # the '-ne ''' guards below evaluated to $true. A [String] method parameter coerces $null to '',
    # which would silently flip the guard and pick 'microsoftEdge' where the function picked
    # 'notConfigured'. [System.Object] keeps $null intact and preserves the original behaviour.
    hidden [System.Collections.Hashtable] SetManagedBrowserValues([System.String] $Browser, [System.Boolean] $OpenLinksRequired, [System.Object] $CustomDisplayName, [System.Object] $CustomPackageId)
    {
        # via the gui there are only 3 possible configs:
        # edge - edge, true, empty id strings
        # any app - not configured, false, empty strings
        # unmanaged browser not configured, true, strings must not be empty
        if (!$OpenLinksRequired)
        {
            $Browser = 'notConfigured'
            $OpenLinksRequired = $false
            $CustomDisplayName = ''
            $CustomPackageId = ''

        }
        else
        {
            if (($CustomDisplayName -ne '') -and ($CustomPackageId -ne ''))
            {
                $Browser = 'notConfigured'
                $OpenLinksRequired = $true
            }
            else
            {
                $Browser = 'microsoftEdge'
                $OpenLinksRequired = $true
                $CustomDisplayName = ''
                $CustomPackageId = ''
            }

        }

        $ManagedBrowserHash = @{
            'ManagedBrowser'                    = $Browser
            'ManagedBrowserToOpenLinksRequired' = $OpenLinksRequired
            'CustomBrowserDisplayName'          = $CustomDisplayName
            'CustomBrowserPackageId'            = $CustomPackageId
        }

        return $ManagedBrowserHash
    }

    hidden [System.Collections.Hashtable] GetAppsToHashtable([System.String[]] $AppList, [System.String] $GroupType)
    {
        $formattedApps = @()
        $allApps = (Get-MgBetaDeviceAppManagementManagedAppStatus -ManagedAppStatusId managedAppList).content.appList | Where-Object {
            $_.appIdentifier.'@odata.type' -eq '#microsoft.graph.androidMobileAppIdentifier'
        }

        switch ($GroupType)
        {
            'selectedPublicApps'
            {
                if ($AppList.Count -eq 0)
                {
                    throw "AppGroupType is set to 'selectedPublicApps' but no Apps were provided."
                }
            }
            'allCoreMicrosoftApps'
            {
                $AppList = $allApps | Where-Object appGroups -EQ 'coreMicrosoft' | ForEach-Object {
                    $_.appIdentifier.bundleId
                }
            }
            'allMicrosoftApps'
            {
                $AppList = $allApps | Where-Object appGroups -EQ 'microsoft' | ForEach-Object {
                    $_.appIdentifier.bundleId
                }
            }
            'allApps'
            {
                $AppList = $allApps | ForEach-Object {
                    $_.appIdentifier.bundleId
                }
            }
        }

        foreach ($app in $AppList)
        {
            $formattedApps += @{
                id                  = $app + '.android'
                mobileAppIdentifier = @{
                    '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                    packageId     = $app
                }
            }
        }

        return @{
            apps         = $formattedApps
            appGroupType = $GroupType
        }
    }

    hidden [IntuneAppProtectionPolicyAndroid] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppProtectionPolicyAndroid])
        {
            return $Values
        }

        $result = [IntuneAppProtectionPolicyAndroid]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}
