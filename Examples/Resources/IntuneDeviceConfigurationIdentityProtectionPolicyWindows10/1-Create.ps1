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
        IntuneDeviceConfigurationIdentityProtectionPolicyWindows10 'IntuneDeviceConfigurationIdentityProtectionPolicyWindows10-Example'
        {
            Assignments                                  = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            );
            DeviceManagementApplicabilityRuleDeviceMode  = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition   = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Education editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Education")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion   = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                  = "identity protection";
            EnhancedAntiSpoofingForFacialFeaturesEnabled = $True;
            Ensure                                       = "Present";
            PinExpirationInDays                          = 5;
            PinLowercaseCharactersUsage                  = "allowed";
            PinMaximumLength                             = 4;
            PinMinimumLength                             = 4;
            PinPreviousBlockCount                        = 3;
            PinRecoveryEnabled                           = $True;
            PinSpecialCharactersUsage                    = "allowed";
            PinUppercaseCharactersUsage                  = "allowed";
            SecurityDeviceRequired                       = $True;
            UnlockWithBiometricsEnabled                  = $True;
            UseCertificatesForOnPremisesAuthEnabled      = $True;
            UseSecurityKeyForSignin                      = $True;
            WindowsHelloForBusinessBlocked               = $False;
            ApplicationId                                = $ApplicationId;
            TenantId                                     = $TenantId;
            CertificateThumbprint                        = $CertificateThumbprint;
        }
    }
}
