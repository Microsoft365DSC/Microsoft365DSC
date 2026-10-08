using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppProtectionPolicyiOS : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the iOS App Protection Policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Id of the iOS App Protection Policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the iOS App Protection Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Data storage locations where a user may store managed data. Inherited from managedAppProtection.')]
    [System.String[]] $AllowedDataIngestionLocations

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if content sync for widgets is allowed for iOS on App Protection Policies.')]
    [System.Nullable[System.Boolean]] $AllowWidgetContentSync

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or warn, if the user is clocked out (non-working time).')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfAccountIsClockedOut

    [DscProperty()]
    [System.ComponentModel.Description('If set, it will specify what action to take in the case where the user is unable to checkin because their authentication token is invalid. This happens when the user is deleted or disabled in AAD. .')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfUnableToAuthenticateUser

    [DscProperty()]
    [System.ComponentModel.Description('Public Apps selection: group or individual Inherited from targetedManagedAppProtection.')]
    [ValidateSet('selectedPublicApps', 'allCoreMicrosoftApps', 'allMicrosoftApps', 'allApps')]
    [System.String] $AppGroupType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether a user can bring data into org documents.')]
    [System.Nullable[System.Boolean]] $BlockDataIngestionIntoOrganizationDocuments

    [DscProperty()]
    [System.ComponentModel.Description('Protocol of a custom dialer app to click-to-open a phone number on iOS, for example, skype:.')]
    [System.String] $CustomDialerAppProtocol

    [DscProperty()]
    [System.ComponentModel.Description('The classes of dialer apps that are allowed to click-to-open a phone number.')]
    [ValidateSet('allApps', 'managedApps', 'customApp', 'blocked')]
    [System.String] $DialerRestrictionLevel

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom urls that are allowed to invocate an unmanaged app.')]
    [System.String[]] $ExemptedUniversalLinks

    [DscProperty()]
    [System.ComponentModel.Description('Configuration state (blocked or not blocked) for Apple Intelligence Genmoji setting.')]
    [ValidateSet('notBlocked', 'blocked')]
    [System.String] $GenmojiConfigurationState

    [DscProperty()]
    [System.ComponentModel.Description('A grace period before blocking app access during off clock hours. Must be an ISO8601 timespan format.')]
    [System.String] $GracePeriodToBlockAppsDuringOffClockHours

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom urls that are allowed to invocate a managed app.')]
    [System.String[]] $managedUniversalLinks

    [DscProperty()]
    [System.ComponentModel.Description('Maximum allowed device threat level, as reported by the MTD app Inherited from managedAppProtection.')]
    [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
    [System.String] $MaximumAllowedDeviceThreatLevel

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data. Inherited from managedAppProtection.')]
    [System.String] $MaximumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data. Inherited from managedAppProtection.')]
    [System.String] $MaximumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data. Inherited from managedAppProtection.')]
    [System.String] $MaximumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('When a specific app redirection is enforced by protectedMessagingRedirectAppType in an App Protection Policy, this value defines the app url redirect schemes which are allowed to be used.')]
    [System.String] $MessagingRedirectAppUrlScheme

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app from accessing company data.')]
    [System.String] $MinimumWarningSdkVersion

    [DscProperty()]
    [System.ComponentModel.Description('Indicates how to prioritize which Mobile Threat Defense (MTD) partner is enabled for a given platform, when more than one is enabled. An app can only be actively using a single Mobile Threat Defense partner. When NULL, Microsoft Defender will be given preference. Otherwise setting the value to defenderOverThirdPartyPartner or thirdPartyPartnerOverDefender will make explicit which partner to prioritize.')]
    [ValidateSet('defenderOverThirdPartyPartner', 'thirdPartyPartnerOverDefender', 'unknownFutureValue')]
    [System.String] $MobileThreatDefensePartnerPriority

    [DscProperty()]
    [System.ComponentModel.Description('Determines what action to take if the mobile threat defense threat threshold isn''t met. Warn isn''t a supported value for this property Inherited from managedAppProtection.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $MobileThreatDefenseRemediationAction

    [DscProperty()]
    [System.ComponentModel.Description('Requires a pin to be unique from the number specified in this property. Inherited from managedAppProtection.')]
    [System.Nullable[System.UInt32]] $PreviousPinBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Defines how app messaging redirection is protected by an App Protection Policy. Default is anyApp. Inherited from managedAppProtection.')]
    [ValidateSet('anyApp', 'anyManagedApp', 'specificApps', 'blocked')]
    [System.String] $ProtectedMessagingRedirectAppType

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a Microsoft Purview content evaluation is required. The possible values are: notRequired, requiredWhenOnline, required.')]
    [ValidateSet('notRequired', 'requiredWhenOnline', 'required')]
    [System.String] $PurviewContentEvaluationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Configuration state (blocked or not blocked) for Apple Intelligence screen capture setting.')]
    [ValidateSet('notBlocked', 'blocked')]
    [System.String] $ScreenCaptureConfigurationState

    [DscProperty()]
    [System.ComponentModel.Description('Defines if third party keyboards are allowed while accessing a managed app.')]
    [System.Nullable[System.Boolean]] $ThirdPartyKeyboardsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configuration state (blocked or not blocked) for Apple Intelligence writing tools setting.')]
    [ValidateSet('notBlocked', 'blocked')]
    [System.String] $WritingToolsConfigurationState

    [DscProperty()]
    [System.ComponentModel.Description('The period after which access is checked when the device is not connected to the internet. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodOfflineBeforeAccessCheck

    [DscProperty()]
    [System.ComponentModel.Description('The period after which access is checked when the device is connected to the internet. Must be an ISO8601 timespan format.')]
    [System.String] $PeriodOnlineBeforeAccessCheck

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
    [System.ComponentModel.Description('Indicates whether internet links should be opened in the managed browser app, or any custom browser specified by CustomBrowserProtocol (for iOS) or CustomBrowserPackageId/CustomBrowserDisplayName (for Android).')]
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
    [System.ComponentModel.Description('Indicates whether use of the fingerprint reader is allowed in place of a pin if PinRequired is set to True.')]
    [System.Nullable[System.Boolean]] $FingerprintBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether use of the FaceID is allowed in place of a pin if PinRequired is set to True.')]
    [System.Nullable[System.Boolean]] $FaceIdBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates in which managed browser(s) that internet links should be opened. When this property is configured, ManagedBrowserToOpenLinksRequired should be true. Possible values are: notConfigured, microsoftEdge.')]
    [ValidateSet('notConfigured', 'microsoftEdge')]
    [System.String] $ManagedBrowser

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app from accessing company data.')]
    [System.String] $MinimumWarningAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app from accessing company data.')]
    [System.String] $MinimumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumRequiredSdkVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than or equal to the specified version will wipe the managed app and the associated company data.')]
    [System.String] $MinimumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than or equal to the specified version will wipe the managed app and the associated company data.')]
    [System.String] $MinimumWipeAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, when the device is either rooted or jailbroken, if DeviceComplianceRequired is set to true.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfDeviceComplianceRequired

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, based on maximum number of incorrect pin retry attempts.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfMaximumPinRetriesExceeded

    [DscProperty()]
    [System.ComponentModel.Description('Timeout in minutes for an app pin instead of non biometrics passcode. Must be an ISO8601 timespan format.')]
    [System.String] $PinRequiredInsteadOfBiometricTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of characters that may be cut or copied from Org data and accounts to any application. This setting overrides the AllowedOutboundClipboardSharingLevel restriction. Default value of ''0'' means no exception is allowed.')]
    [System.Nullable[System.UInt32]] $AllowedOutboundClipboardSharingExceptionLength

    [DscProperty()]
    [System.ComponentModel.Description('Specify app notification restriction.')]
    [ValidateSet('allow', 'blockOrganizationalData', 'block')]
    [System.String] $NotificationRestriction

    [DscProperty()]
    [System.ComponentModel.Description('The intended app management levels for this policy.')]
    [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise', 'androidEnterpriseDedicatedDevicesWithAzureAdSharedMode', 'androidOpenSourceProjectUserAssociated', 'androidOpenSourceProjectUserless')]
    [System.String[]] $TargetedAppManagementLevels

    [DscProperty()]
    [System.ComponentModel.Description('Require app data to be encrypted.')]
    [ValidateSet('useDeviceSettings', 'afterDeviceRestart', 'whenDeviceLockedExceptOpenFiles', 'whenDeviceLocked')]
    [System.String] $AppDataEncryptionType

    [DscProperty()]
    [System.ComponentModel.Description('Apps in this list will be exempt from the policy and will be able to receive data from managed apps.')]
    [System.String[]] $ExemptedAppProtocols

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data.')]
    [System.String] $MinimumWipeSdkVersion

    [DscProperty()]
    [System.ComponentModel.Description('Semicolon separated list of device models allowed, as a string, for the managed app to work.')]
    [System.String[]] $AllowedIosDeviceModels

    [DscProperty()]
    [System.ComponentModel.Description('Defines a managed app behavior, either block or wipe, if the specified device model is not allowed.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfIosDeviceModelNotAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Defines if open-in operation is supported from the managed app to the filesharing locations selected. This setting only applies when AllowedOutboundDataTransferDestinations is set to ManagedApps and DisableProtectionOfManagedOutboundOpenInData is set to False.')]
    [System.Nullable[System.Boolean]] $FilterOpenInToOnlyManagedApps

    [DscProperty()]
    [System.ComponentModel.Description('Disable protection of data transferred to other apps through IOS ''OpenIn'' option. This setting is only allowed to be True when AllowedOutboundDataTransferDestinations is set to ManagedApps.')]
    [System.Nullable[System.Boolean]] $DisableProtectionOfManagedOutboundOpenInData

    [DscProperty()]
    [System.ComponentModel.Description('Protect incoming data from unknown source. This setting is only allowed to be True when AllowedInboundDataTransferSources is set to AllApps.')]
    [System.Nullable[System.Boolean]] $ProtectInboundDataFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('A custom browser protocol to open weblink on iOS.')]
    [System.String] $CustomBrowserProtocol

    [DscProperty()]
    [System.ComponentModel.Description('List of IDs representing the iOS apps controlled by this protection policy.')]
    [System.String[]] $Apps

    [DscProperty()]
    [System.ComponentModel.Description('List of IDs of the groups assigned to this iOS Protection Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin.')]
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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneAppProtectionPolicyiOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppProtectionPolicyiOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune iOS App Protection Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    [Array]$policy = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $this.Id -ErrorAction SilentlyContinue
                }
                if ($policy.Length -eq 0)
                {
                    Write-Verbose -Message "No iOS App Protection Policy {$($this.Id)} was found by Id. Trying to retrieve by DisplayName"
                    [Array]$policy = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ErrorAction SilentlyContinue
                }

                if ($policy.Length -gt 1)
                {
                    throw "Multiple policies with display name {$($this.DisplayName)} were found. Please ensure only one instance exists."
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No iOS App Protection Policy {$($this.DisplayName)} was found by Display Name. Instance doesn't exist."
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
                $policyId = $policy.Id
            }

            Write-Verbose -Message "An Intune iOS App Protection Policy with Id {$policyId} and DisplayName {$($this.DisplayName)} was found."

            $policyApps = Get-MgBetaDeviceAppManagementiOSManagedAppProtectionApp -IosManagedAppProtectionId $policyId

            $appsArray = @()
            if ($policy.AppGroupType -eq 'selectedPublicApps')
            {
                foreach ($app in $policyApps)
                {
                    $appsArray += $app.mobileAppIdentifier.bundleId
                }
            }

            $assignmentsValues = Get-MgBetaDeviceAppManagementiOSManagedAppProtectionAssignment -IosManagedAppProtectionId $policyId
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                [array]$assignmentsValues = $assignmentsValues | Where-Object -FilterScript { $_.source -eq 'direct' }
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }

            $exemptedAppProtocolsArray = @()
            foreach ($exemptedAppProtocol in [Array]$policy.exemptedAppProtocols)
            {
                $exemptedAppProtocolsArray += ($exemptedAppProtocol.Name + ':' + $exemptedAppProtocol.Value)
            }

            $AllowedDataIngestionLocationsValue = @()
            if ($null -ne $policy.AllowedDataIngestionLocations)
            {
                $AllowedDataIngestionLocationsValue = [String[]]($policy.AllowedDataIngestionLocations)
            }

            $exemptedUniversalLinksValue = @()
            if ($null -ne $policy.exemptedUniversalLinks)
            {
                $exemptedUniversalLinksValue = [String[]]($policy.exemptedUniversalLinks)
            }

            $managedUniversalLinksValue = @()
            if ($null -ne $policy.managedUniversalLinks)
            {
                $managedUniversalLinksValue = [String[]]($policy.managedUniversalLinks)
            }

            $allowedDataStorageLocationsValue = @()
            if ($null -ne $policy.AllowedDataStorageLocations)
            {
                $allowedDataStorageLocationsValue = [String[]]($policy.AllowedDataStorageLocations)
            }

            $allowedIosDeviceModelsValue = @()
            if (-not [System.String]::IsNullOrEmpty($policy.AllowedIosDeviceModels))
            {
                $allowedIosDeviceModelsValue = [String[]]($policy.AllowedIosDeviceModels -split ';')
            }

            $gracePeriodToBlockAppsDuringOffClockHoursString = $null
            if (-not [System.String]::IsNullOrEmpty($policy.GracePeriodToBlockAppsDuringOffClockHours))
            {
                $gracePeriodToBlockAppsDuringOffClockHoursString = [M365DSCResourceBase]::FormatDuration($policy.GracePeriodToBlockAppsDuringOffClockHours)
            }

            return $this.AsResult(@{
                Id                                             = $policy.Id
                DisplayName                                    = $policy.DisplayName
                Description                                    = $policy.Description
                RoleScopeTagIds                                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                AllowedDataIngestionLocations                  = $AllowedDataIngestionLocationsValue
                AllowWidgetContentSync                         = $policy.AllowWidgetContentSync
                AppActionIfAccountIsClockedOut                 = $policy.appActionIfAccountIsClockedOut
                AppActionIfUnableToAuthenticateUser            = $policy.appActionIfUnableToAuthenticateUser
                AppGroupType                                   = $policy.appGroupType
                BlockDataIngestionIntoOrganizationDocuments    = $policy.blockDataIngestionIntoOrganizationDocuments
                CustomDialerAppProtocol                        = $policy.customDialerAppProtocol
                DialerRestrictionLevel                         = $policy.dialerRestrictionLevel
                ExemptedUniversalLinks                         = $exemptedUniversalLinksValue
                GenmojiConfigurationState                      = $policy.genmojiConfigurationState
                GracePeriodToBlockAppsDuringOffClockHours      = $gracePeriodToBlockAppsDuringOffClockHoursString
                ManagedUniversalLinks                          = $managedUniversalLinksValue
                MaximumAllowedDeviceThreatLevel                = $policy.maximumAllowedDeviceThreatLevel
                MaximumRequiredOsVersion                       = $policy.maximumRequiredOsVersion
                MaximumWarningOsVersion                        = $policy.maximumWarningOsVersion
                MaximumWipeOsVersion                           = $policy.maximumWipeOsVersion
                MessagingRedirectAppUrlScheme                  = $policy.messagingRedirectAppUrlScheme
                MinimumWarningSdkVersion                       = $policy.minimumWarningSdkVersion
                MobileThreatDefensePartnerPriority             = $policy.mobileThreatDefensePartnerPriority
                MobileThreatDefenseRemediationAction           = $policy.mobileThreatDefenseRemediationAction
                PreviousPinBlockCount                          = $policy.previousPinBlockCount
                ProtectedMessagingRedirectAppType              = $policy.protectedMessagingRedirectAppType
                PurviewContentEvaluationRequired               = $policy.purviewContentEvaluationRequired
                ScreenCaptureConfigurationState                = $policy.screenCaptureConfigurationState
                thirdPartyKeyboardsBlocked                     = $policy.thirdPartyKeyboardsBlocked
                WritingToolsConfigurationState                 = $policy.writingToolsConfigurationState
                PeriodOfflineBeforeAccessCheck                 = $policy.PeriodOfflineBeforeAccessCheck
                PeriodOnlineBeforeAccessCheck                  = $policy.PeriodOnlineBeforeAccessCheck
                AllowedInboundDataTransferSources              = $policy.AllowedInboundDataTransferSources
                AllowedOutboundDataTransferDestinations        = $policy.AllowedOutboundDataTransferDestinations
                OrganizationalCredentialsRequired              = $policy.OrganizationalCredentialsRequired
                AllowedOutboundClipboardSharingLevel           = $policy.AllowedOutboundClipboardSharingLevel
                DataBackupBlocked                              = $policy.DataBackupBlocked
                DeviceComplianceRequired                       = $policy.DeviceComplianceRequired
                ManagedBrowser                                 = $policy.ManagedBrowser
                MinimumRequiredAppVersion                      = $policy.MinimumRequiredAppVersion
                MinimumRequiredOsVersion                       = $policy.MinimumRequiredOsVersion
                MinimumRequiredSdkVersion                      = $policy.MinimumRequiredSDKVersion
                MinimumWarningAppVersion                       = $policy.MinimumWarningAppVersion
                MinimumWarningOsVersion                        = $policy.MinimumWarningOsVersion
                ManagedBrowserToOpenLinksRequired              = $policy.ManagedBrowserToOpenLinksRequired
                SaveAsBlocked                                  = $policy.SaveAsBlocked
                PeriodOfflineBeforeWipeIsEnforced              = $policy.PeriodOfflineBeforeWipeIsEnforced
                PinRequired                                    = $policy.PinRequired
                DisableAppPinIfDevicePinIsSet                  = $policy.disableAppPinIfDevicePinIsSet
                MaximumPinRetries                              = $policy.MaximumPinRetries
                SimplePinBlocked                               = $policy.SimplePinBlocked
                MinimumPinLength                               = $policy.MinimumPinLength
                PinCharacterSet                                = $policy.PinCharacterSet
                AllowedDataStorageLocations                    = $allowedDataStorageLocationsValue
                ContactSyncBlocked                             = $policy.ContactSyncBlocked
                PeriodBeforePinReset                           = $policy.PeriodBeforePinReset
                FaceIdBlocked                                  = $policy.FaceIdBlocked
                PrintBlocked                                   = $policy.PrintBlocked
                FingerprintBlocked                             = $policy.FingerprintBlocked
                AppDataEncryptionType                          = $policy.AppDataEncryptionType
                Assignments                                    = $assignmentResult
                CustomBrowserProtocol                          = $policy.CustomBrowserProtocol
                Apps                                           = $appsArray
                MinimumWipeOsVersion                           = $policy.minimumWipeOsVersion
                MinimumWipeAppVersion                          = $policy.MinimumWipeAppVersion
                AppActionIfDeviceComplianceRequired            = $policy.AppActionIfDeviceComplianceRequired
                AppActionIfMaximumPinRetriesExceeded           = $policy.AppActionIfMaximumPinRetriesExceeded
                PinRequiredInsteadOfBiometricTimeout           = $policy.PinRequiredInsteadOfBiometricTimeout
                AllowedOutboundClipboardSharingExceptionLength = $policy.AllowedOutboundClipboardSharingExceptionLength
                NotificationRestriction                        = $policy.NotificationRestriction
                TargetedAppManagementLevels                    = [string[]]$policy.TargetedAppManagementLevels.ToString().Split(',')
                ExemptedAppProtocols                           = $exemptedAppProtocolsArray
                MinimumWipeSdkVersion                          = $policy.MinimumWipeSdkVersion
                AllowedIosDeviceModels                         = $allowedIosDeviceModelsValue
                AppActionIfIosDeviceModelNotAllowed            = $policy.AppActionIfIosDeviceModelNotAllowed
                FilterOpenInToOnlyManagedApps                  = $policy.FilterOpenInToOnlyManagedApps
                DisableProtectionOfManagedOutboundOpenInData   = $policy.DisableProtectionOfManagedOutboundOpenInData
                ProtectInboundDataFromUnknownSources           = $policy.ProtectInboundDataFromUnknownSources
                Ensure                                         = 'Present'
                Credential                                     = $this.Credential
                ApplicationId                                  = $this.ApplicationId
                ApplicationSecret                              = $this.ApplicationSecret
                TenantId                                       = $this.TenantId
                CertificateThumbprint                          = $this.CertificateThumbprint
                CertificatePath                                = $this.CertificatePath
                CertificatePassword                            = $this.CertificatePassword
                ManagedIdentity                                = $this.ManagedIdentity
                AccessTokens                                   = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of the Intune App Protection Policy for iOS with DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new iOS App Protection Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id')
            $createParameters.Remove('Assignments')
            $createParameters.Remove('Apps')
            $createParameters.TargetedAppManagementLevels = $createParameters.TargetedAppManagementLevels -join ','

            $myExemptedAppProtocols = @()
            foreach ($exemptedAppProtocol in $this.ExemptedAppProtocols)
            {
                $myExemptedAppProtocols += @{
                    name  = $exemptedAppProtocol.Split(':')[0]
                    value = $exemptedAppProtocol.Split(':')[1]
                }
            }
            $createParameters.ExemptedAppProtocols = $myExemptedAppProtocols

            if ($createParameters.ContainsKey('AllowedIosDeviceModels'))
            {
                $createParameters.AllowedIosDeviceModels = $this.AllowedIosDeviceModels -join ';'
            }

            # Remove empty string parameters that the cmdlet can't handle
            $arrayTemp = @('MinimumWarningSdkVersion', 'MaximumRequiredOsVersion', 'MaximumWarningOsVersion', 'MaximumWipeOsVersion')
            foreach ($item in $arrayTemp)
            {
                if ([System.String]::IsNullOrEmpty($createParameters.$item))
                {
                    $createParameters.Remove($item)
                }
            }

            $policy = New-MgBetaDeviceAppManagementiOSManagedAppProtection -BodyParameter $createParameters
            if ($policy.Id)
            {
                Write-Verbose -Message "Update targetApps for iOS App Protection Policy with Id {$($policy.Id)} and DisplayName {$($this.DisplayName)}"
                $targetApps = $this.GetAppsToHashtable($this.Apps, $this.AppGroupType)
                $Url = "/beta/deviceAppManagement/iosManagedAppProtections('$($policy.Id)')/targetApps"
                Invoke-M365DSCGraphRequest -Method POST -Uri $Url -Body $targetApps

                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/iosManagedAppProtections'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing iOS App Protection Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id')
            $updateParameters.Remove('Assignments')
            $updateParameters.Remove('Apps')
            $updateParameters.TargetedAppManagementLevels = $updateParameters.TargetedAppManagementLevels -join ','

            # Remove empty string parameters that the cmdlet can't handle
            $arrayTemp = @('MinimumWarningSdkVersion', 'MaximumRequiredOsVersion', 'MaximumWarningOsVersion', 'MaximumWipeOsVersion')
            foreach ($item in $arrayTemp)
            {
                if ([System.String]::IsNullOrEmpty($updateParameters.$item))
                {
                    $updateParameters.Remove($item)
                }
            }

            $myExemptedAppProtocols = @()
            foreach ($exemptedAppProtocol in $this.ExemptedAppProtocols)
            {
                $myExemptedAppProtocols += @{
                    name  = $exemptedAppProtocol.Split(':')[0]
                    value = $exemptedAppProtocol.Split(':')[1]
                }
            }
            $updateParameters.ExemptedAppProtocols = $myExemptedAppProtocols

            if ($updateParameters.ContainsKey('AllowedIosDeviceModels'))
            {
                $updateParameters.AllowedIosDeviceModels = $this.AllowedIosDeviceModels -join ';'
            }

            Update-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $currentPolicy.Id -BodyParameter $updateParameters

            Write-Verbose -Message "Updating targetApps for iOS App Protection Policy with Id {$($currentPolicy.Id)} and DisplayName {$($this.DisplayName)}"
            $targetApps = $this.GetAppsToHashtable($this.Apps, $this.AppGroupType)
            $Url = "/beta/deviceAppManagement/iosManagedAppProtections('$($currentPolicy.Id)')/targetApps"
            Invoke-M365DSCGraphRequest -Method POST -Uri $Url -Body $targetApps

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/iosManagedAppProtections'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing iOS App Protection Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceAppManagementiOSManagedAppProtection -IosManagedAppProtectionId $currentPolicy.Id
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

        #Ensure the proper dependencies are installed in the current environment
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            $mergedFilter = $this.Filter
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $mergedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$policies = Get-MgBetaDeviceAppManagementiOSManagedAppProtection -All -Filter $mergedFilter -ErrorAction Stop
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
                    Id                    = $policy.id
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
                $Results = $this.GetForExport($Params)
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
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.AppGroupType -ne 'SelectedPublicApps')
                {
                    $ValuesToCheck.Remove('Apps')
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.Collections.Hashtable] GetAppsToHashtable([System.String[]] $AppList, [System.String] $AppGroupType)
    {
        $formattedApps = @()
        $allApps = (Get-MgBetaDeviceAppManagementManagedAppStatus -ManagedAppStatusId managedAppList).content.appList | Where-Object {
            $_.appIdentifier.'@odata.type' -eq '#microsoft.graph.iosMobileAppIdentifier'
        }

        switch ($AppGroupType)
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
                id                  = $app + '.ios'
                mobileAppIdentifier = @{
                    '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                    bundleId      = $app
                }
            }
        }

        return @{
            apps         = $formattedApps
            appGroupType = $AppGroupType
        }
    }

    hidden [IntuneAppProtectionPolicyiOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppProtectionPolicyiOS])
        {
            return $Values
        }

        $result = [IntuneAppProtectionPolicyiOS]::new()
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
