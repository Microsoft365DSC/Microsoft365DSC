<#
This example creates a new Device Compliance Policy for iOs devices
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
        IntuneDeviceCompliancePolicyAndroidWorkProfile 'IntuneDeviceCompliancePolicyAndroidWorkProfile-Example'
        {
            DisplayName                                        = 'Android Work Profile Compliance'
            Description                                        = 'Compliance baseline for Android Enterprise work profile devices'
            AdvancedThreatProtectionRequiredSecurityLevel      = 'unavailable'
            Assignments                                        = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Excluded Devices'
                }
            )
            DeviceThreatProtectionEnabled                      = $False
            DeviceThreatProtectionRequiredSecurityLevel        = 'unavailable'
            MinAndroidSecurityPatchLevel                       = '2025-06-01'
            OsMaximumVersion                                   = '15'
            OsMinimumVersion                                   = '11'
            PasswordExpirationDays                             = 90
            PasswordMinimumLength                              = 8 # Updated Property
            PasswordMinutesOfInactivityBeforeLock              = 5
            PasswordPreviousPasswordBlockCount                 = 5
            PasswordRequired                                   = $True
            PasswordRequiredType                               = 'numericComplex'
            PasswordSignInFailureCountBeforeFactoryReset       = 10
            RequiredPasswordComplexity                         = 'medium'
            RoleScopeTagIds                                    = @('0')
            ScheduledActionsForRule                            = @(
                MSFT_ScheduledActionConfigurations{
                    actionType       = 'block'
                    gracePeriodHours = 24
                }
            )
            SecurityBlockJailbrokenDevices                     = $True
            SecurityDisableUsbDebugging                        = $True
            SecurityPreventInstallAppsFromUnknownSources       = $True
            SecurityRequireCompanyPortalAppIntegrity           = $True
            SecurityRequireGooglePlayServices                  = $True
            SecurityRequiredAndroidSafetyNetEvaluationType     = 'basic'
            SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
            SecurityRequireSafetyNetAttestationCertifiedDevice = $True
            SecurityRequireUpToDateSecurityProviders           = $True
            SecurityRequireVerifyApps                          = $True
            StorageRequireEncryption                           = $True
            WorkProfileInactiveBeforeScreenLockInMinutes       = 5
            WorkProfilePasswordExpirationInDays                = 90
            WorkProfilePasswordMinimumLength                   = 6
            WorkProfilePasswordRequiredType                    = 'alphanumericWithSymbols'
            WorkProfilePreviousPasswordBlockCount              = 5
            WorkProfileRequiredPasswordComplexity              = 'Medium'
            WorkProfileRequirePassword                         = $True
            Ensure                                             = 'Present'
            ApplicationId                                      = $ApplicationId;
            TenantId                                           = $TenantId;
            CertificateThumbprint                              = $CertificateThumbprint;
        }
    }
}
