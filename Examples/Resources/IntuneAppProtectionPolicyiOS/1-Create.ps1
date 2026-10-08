<#
This example creates a new App ProtectionPolicy for iOS.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        IntuneAppProtectionPolicyiOS 'IntuneAppProtectionPolicyiOS-Example'
        {
            DisplayName                                    = 'iOS App Protection - Corporate'
            AllowedDataIngestionLocations                  = @('oneDriveForBusiness', 'sharePoint', 'camera', 'photoLibrary')
            AllowedDataStorageLocations                    = @('oneDriveForBusiness', 'sharePoint')
            AllowedInboundDataTransferSources              = 'managedApps'
            AllowedIosDeviceModels                         = @('iPhone14,7', 'iPhone15,2', 'iPad13,18')
            AllowedOutboundClipboardSharingExceptionLength = 0
            AllowedOutboundClipboardSharingLevel           = 'managedAppsWithPasteIn'
            AllowedOutboundDataTransferDestinations        = 'managedApps'
            AllowWidgetContentSync                         = $false
            AppActionIfAccountIsClockedOut                 = 'block'
            AppActionIfDeviceComplianceRequired            = 'block'
            AppActionIfIosDeviceModelNotAllowed            = 'block'
            AppActionIfMaximumPinRetriesExceeded           = 'block'
            AppActionIfUnableToAuthenticateUser            = 'block'
            AppDataEncryptionType                          = 'whenDeviceLocked'
            AppGroupType                                   = 'selectedPublicApps'
            Apps                                           = @('com.microsoft.msedge', 'com.microsoft.office.outlook', 'com.microsoft.skydrive', 'com.microsoft.skype.teams')
            Assignments                                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Users'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Excluded Users'
                }
            )
            BlockDataIngestionIntoOrganizationDocuments    = $true
            ContactSyncBlocked                             = $false
            CustomBrowserProtocol                          = 'contosobrowser://'
            CustomDialerAppProtocol                        = 'contosophone://'
            DataBackupBlocked                              = $true
            Description                                    = 'Protects company data in the iOS apps used by the sales team'
            DeviceComplianceRequired                       = $true
            DialerRestrictionLevel                         = 'customApp'
            DisableAppPinIfDevicePinIsSet                  = $false
            DisableProtectionOfManagedOutboundOpenInData   = $false
            ExemptedAppProtocols                           = @('Default:tel;telprompt;skype;app-settings;calshow;itms;itmss', 'Contoso Softphone:contosophone')
            ExemptedUniversalLinks                         = @('tel://', 'maps://')
            FaceIdBlocked                                  = $false
            FilterOpenInToOnlyManagedApps                  = $true
            FingerprintBlocked                             = $false
            GenmojiConfigurationState                      = 'blocked'
            GracePeriodToBlockAppsDuringOffClockHours      = 'PT1H'
            ManagedBrowser                                 = 'notConfigured'
            ManagedBrowserToOpenLinksRequired              = $true
            managedUniversalLinks                          = @('http://', 'https://', 'https://*.contoso.com/*')
            MaximumAllowedDeviceThreatLevel                = 'medium'
            MaximumPinRetries                              = 5
            MaximumRequiredOsVersion                       = '20.0'
            MaximumWarningOsVersion                        = '19.0'
            MaximumWipeOsVersion                           = '26.0'
            MessagingRedirectAppUrlScheme                  = 'contosomessenger://'
            MinimumPinLength                               = 6
            MinimumRequiredAppVersion                      = '2.70'
            MinimumRequiredOsVersion                       = '16.0'
            MinimumRequiredSdkVersion                      = '19.7.6'
            MinimumWarningAppVersion                       = '2.75'
            MinimumWarningOsVersion                        = '17.0'
            MinimumWarningSdkVersion                       = '19.7.9'
            MinimumWipeAppVersion                          = '2.60'
            MinimumWipeOsVersion                           = '15.0'
            MinimumWipeSdkVersion                          = '19.5.0'
            MobileThreatDefensePartnerPriority             = 'defenderOverThirdPartyPartner'
            MobileThreatDefenseRemediationAction           = 'block'
            NotificationRestriction                        = 'blockOrganizationalData'
            OrganizationalCredentialsRequired              = $false
            PeriodBeforePinReset                           = 'P90D'
            PeriodOfflineBeforeAccessCheck                 = 'PT12H'
            PeriodOfflineBeforeWipeIsEnforced              = 'P90D'
            PeriodOnlineBeforeAccessCheck                  = 'PT30M'
            PinCharacterSet                                = 'alphanumericAndSymbol'
            PinRequired                                    = $true
            PinRequiredInsteadOfBiometricTimeout           = 'PT30M'
            PreviousPinBlockCount                          = 5
            PrintBlocked                                   = $true
            ProtectedMessagingRedirectAppType              = 'specificApps'
            ProtectInboundDataFromUnknownSources           = $false
            PurviewContentEvaluationRequired               = 'requiredWhenOnline'
            RoleScopeTagIds                                = @('0')
            SaveAsBlocked                                  = $true
            ScreenCaptureConfigurationState                = 'blocked'
            SimplePinBlocked                               = $true
            TargetedAppManagementLevels                    = @('unspecified')
            ThirdPartyKeyboardsBlocked                     = $true
            WritingToolsConfigurationState                 = 'notBlocked'
            Ensure                                         = 'Present'
            ApplicationId                                  = $ApplicationId;
            TenantId                                       = $TenantId;
            CertificateThumbprint                          = $CertificateThumbprint;
        }
    }
}
