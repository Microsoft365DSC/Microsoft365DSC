<#
This example creates a new Device Compliance Policy for Android Device Owner devices
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
        IntuneDeviceCompliancePolicyAndroidDeviceOwner 'IntuneDeviceCompliancePolicyAndroidDeviceOwner-Example'
        {
            DisplayName                                        = 'Android Corporate-Owned Device Compliance'
            Description                                        = 'Compliance baseline for corporate-owned Android devices'
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
            AdvancedThreatProtectionRequiredSecurityLevel      = 'unavailable'
            MinAndroidSecurityPatchLevel                       = '2025-06-01'
            RequireNoPendingSystemUpdates                      = $False
            SecurityBlockJailbrokenDevices                     = $True
            SecurityRequireIntuneAppIntegrity                  = $True
            SecurityRequiredAndroidSafetyNetEvaluationType     = 'basic'
            SecurityRequireSafetyNetAttestationBasicIntegrity  = $True
            SecurityRequireSafetyNetAttestationCertifiedDevice = $True
            OsMinimumVersion                                   = '10'
            OsMaximumVersion                                   = '15'
            PasswordRequired                                   = $True
            PasswordMinimumLength                              = 8 # Updated Property
            PasswordMinimumLetterCharacters                    = 2
            PasswordMinimumLowerCaseCharacters                 = 1
            PasswordMinimumUpperCaseCharacters                 = 1
            PasswordMinimumNonLetterCharacters                 = 2
            PasswordMinimumNumericCharacters                   = 1
            PasswordMinimumSymbolCharacters                    = 1
            PasswordRequiredType                               = 'alphanumericWithSymbols'
            PasswordMinutesOfInactivityBeforeLock              = 5
            PasswordExpirationDays                             = 90
            PasswordPreviousPasswordCountToBlock               = 13
            StorageRequireEncryption                           = $True
            RoleScopeTagIds                                    = @('0')
            ScheduledActionsForRule                            = @(
                MSFT_ScheduledActionConfigurations{
                    actionType       = 'block'
                    gracePeriodHours = 24
                }
            )
            Ensure                                             = 'Present'
            ApplicationId                                      = $ApplicationId;
            TenantId                                           = $TenantId;
            CertificateThumbprint                              = $CertificateThumbprint;
        }
    }
}
