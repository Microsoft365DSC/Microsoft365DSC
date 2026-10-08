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
        IntuneDeviceConfigurationWiredNetworkPolicyWindows10 'IntuneDeviceConfigurationWiredNetworkPolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            AuthenticationBlockPeriodInMinutes          = 5
            AuthenticationMethod                        = 'usernameAndPassword'
            AuthenticationPeriodInSeconds               = 55 # Updated Property
            AuthenticationRetryDelayPeriodInSeconds     = 5
            AuthenticationType                          = 'machine'
            CacheCredentials                            = $True
            Description                                 = '802.1X authentication for the workstations on the corporate wired network'
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = 'Standard configuration devices only'
                DeviceMode = 'standardConfiguration'
                RuleType   = 'include'
            }
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = 'Enterprise and Professional editions only'
                OsEditionTypes = @('windows10Enterprise', 'windows10Professional')
                RuleType       = 'include'
            }
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = 'Windows 10 22H2 or later'
                MinOSVersion = '10.0.19045.0'
                MaxOSVersion = '10.0.26100.9999'
                RuleType     = 'include'
            }
            DisableUserPromptForServerValidation        = $True
            DisplayName                                 = 'Wired Network'
            EapolStartPeriodInSeconds                   = 5
            EapType                                     = 'peap'
            Enforce8021X                                = $True
            Ensure                                      = 'Present'
            ForceFIPSCompliance                         = $False
            MaximumAuthenticationFailures               = 5
            MaximumEAPOLStartMessages                   = 5
            OuterIdentityPrivacyTemporaryValue          = 'anonymous'
            PerformServerValidation                     = $True
            RequireCryptographicBinding                 = $True
            RoleScopeTagIds                             = @('0')
            SecondaryAuthenticationMethod               = 'certificate'
            TrustedServerCertificateNames               = @('nps.contoso.com')
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
