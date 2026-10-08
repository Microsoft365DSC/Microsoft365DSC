<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
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
        IntuneAppProtectionPolicyAndroid 'IntuneAppProtectionPolicyAndroid-Example'
        {
            DisplayName                                        = 'Android App Protection - Corporate'
            AllowedAndroidDeviceManufacturers                  = 'Samsung;Google;Motorola'
            AllowedAndroidDeviceModels                         = @('SM-G991B', 'SM-A546B', 'Pixel 8')
            AllowedDataIngestionLocations                      = @('oneDriveForBusiness', 'sharePoint', 'camera', 'photoLibrary')
            AllowedDataStorageLocations                        = @('oneDriveForBusiness', 'sharePoint')
            AllowedInboundDataTransferSources                  = 'managedApps'
            AllowedOutboundClipboardSharingExceptionLength     = 0
            AllowedOutboundClipboardSharingLevel               = 'managedAppsWithPasteIn'
            AllowedOutboundDataTransferDestinations            = 'managedApps'
            AppActionIfAccountIsClockedOut                     = 'warn'
            AppActionIfAndroidDeviceManufacturerNotAllowed     = 'block'
            AppActionIfAndroidDeviceModelNotAllowed            = 'block'
            AppActionIfAndroidSafetyNetAppsVerificationFailed  = 'block'
            AppActionIfAndroidSafetyNetDeviceAttestationFailed = 'block'
            AppActionIfDeviceComplianceRequired                = 'block'
            AppActionIfDeviceLockNotSet                        = 'block'
            AppActionIfDevicePasscodeComplexityLessThanHigh    = 'warn'
            AppActionIfDevicePasscodeComplexityLessThanLow     = 'block'
            AppActionIfDevicePasscodeComplexityLessThanMedium  = 'warn'
            AppActionIfMaximumPinRetriesExceeded               = 'block'
            AppActionIfSamsungKnoxAttestationRequired          = 'warn'
            appActionIfUnableToAuthenticateUser                = 'block'
            AppGroupType                                       = 'selectedPublicApps'
            ApprovedKeyboards                                  = @('com.google.android.inputmethod.latin|Gboard', 'com.samsung.android.honeyboard|Samsung Keyboard')
            Apps                                               = @('com.microsoft.emmx', 'com.microsoft.office.outlook', 'com.microsoft.skydrive', 'com.microsoft.teams')
            Assignments                                        = @(
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
            BiometricAuthenticationBlocked                     = $false
            BlockAfterCompanyPortalUpdateDeferralInDays        = 60
            BlockDataIngestionIntoOrganizationDocuments        = $true
            ConnectToVpnOnLaunch                               = $false
            ContactSyncBlocked                                 = $true # Updated Property
            CustomBrowserDisplayName                           = 'Contoso Secure Browser'
            CustomBrowserPackageId                             = 'com.contoso.securebrowser'
            CustomDialerAppDisplayName                         = 'Contoso Softphone'
            CustomDialerAppPackageId                           = 'com.contoso.softphone'
            DataBackupBlocked                                  = $true
            Description                                        = 'Protects company data in the Android apps used by field technicians'
            DeviceComplianceRequired                           = $true
            DeviceLockRequired                                 = $true
            DialerRestrictionLevel                             = 'customApp'
            DisableAppEncryptionIfDeviceEncryptionIsEnabled    = $false
            DisableAppPinIfDevicePinIsSet                      = $false
            EncryptAppData                                     = $true
            ExemptedAppPackages                                = @('com.android.chrome|Google Chrome', 'com.google.android.apps.maps|Google Maps')
            FingerprintAndBiometricEnabled                     = $true
            FingerprintBlocked                                 = $false
            GracePeriodToBlockAppsDuringOffClockHours          = 'PT1H'
            KeyboardsRestricted                                = $true
            ManagedBrowser                                     = 'notConfigured'
            ManagedBrowserToOpenLinksRequired                  = $true
            MaximumAllowedDeviceThreatLevel                    = 'medium'
            MaximumPinRetries                                  = 5
            MaximumRequiredOsVersion                           = '15.0'
            MaximumWarningOsVersion                            = '15.0'
            MaximumWipeOsVersion                               = '16.0'
            MessagingRedirectAppDisplayName                    = 'Contoso Secure Messenger'
            MessagingRedirectAppPackageId                      = 'com.contoso.securemessenger'
            MinimumPinLength                                   = 6
            MinimumRequiredAppVersion                          = '16.0'
            MinimumRequiredCompanyPortalVersion                = '5.0.5484.0'
            MinimumRequiredOsVersion                           = '11.0'
            MinimumRequiredPatchVersion                        = '2023-01-01'
            MinimumWarningAppVersion                           = '16.5'
            MinimumWarningCompanyPortalVersion                 = '5.0.5545.0'
            MinimumWarningOsVersion                            = '12.0'
            MinimumWarningPatchVersion                         = '2024-01-01'
            MinimumWipeAppVersion                              = '15.0'
            MinimumWipeCompanyPortalVersion                    = '5.0.5333.0'
            MinimumWipeOsVersion                               = '10.0'
            MinimumWipePatchVersion                            = '2022-01-01'
            MobileThreatDefensePartnerPriority                 = 'defenderOverThirdPartyPartner'
            MobileThreatDefenseRemediationAction               = 'block'
            NotificationRestriction                            = 'blockOrganizationalData'
            OrganizationalCredentialsRequired                  = $false
            PeriodBeforePinReset                               = 'P90D'
            PeriodOfflineBeforeAccessCheck                     = 'PT12H'
            PeriodOfflineBeforeWipeIsEnforced                  = 'P90D'
            PeriodOnlineBeforeAccessCheck                      = 'PT30M'
            PinCharacterSet                                    = 'numeric'
            PinRequired                                        = $true
            PinRequiredInsteadOfBiometricTimeout               = 'PT30M'
            PreviousPinBlockCount                              = 5
            PrintBlocked                                       = $true
            ProtectedMessagingRedirectAppType                  = 'specificApps'
            PurviewContentEvaluationRequired                   = 'requiredWhenOnline'
            RequireClass3Biometrics                            = $true
            RequiredAndroidSafetyNetAppsVerificationType       = 'enabled'
            RequiredAndroidSafetyNetDeviceAttestationType      = 'basicIntegrityAndDeviceCertification'
            RequiredAndroidSafetyNetEvaluationType             = 'hardwareBacked'
            RequirePinAfterBiometricChange                     = $true
            RoleScopeTagIds                                    = @('0')
            SaveAsBlocked                                      = $true
            ScreenCaptureBlocked                               = $true
            SimplePinBlocked                                   = $true
            TargetedAppManagementLevels                        = 'unspecified'
            WarnAfterCompanyPortalUpdateDeferralInDays         = 30
            WipeAfterCompanyPortalUpdateDeferralInDays         = 90
            Ensure                                             = 'Present'
            ApplicationId                                      = $ApplicationId;
            TenantId                                           = $TenantId;
            CertificateThumbprint                              = $CertificateThumbprint;
        }
    }
}
