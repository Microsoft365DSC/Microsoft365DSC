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
        IntuneDeviceConfigurationSharedMultiDevicePolicyWindows10 'IntuneDeviceConfigurationSharedMultiDevicePolicyWindows10-Example'
        {
            AccountManagerPolicy                        = MSFT_MicrosoftGraphsharedPCAccountManagerPolicy{
                CacheAccountsAboveDiskFreePercentage  = 60 # Updated Property
                AccountDeletionPolicy                 = 'diskSpaceThreshold'
                RemoveAccountsBelowDiskFreePercentage = 20
            };
            AllowedAccounts                             = @("guest","domain");
            AllowLocalStorage                           = $True;
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = 'Standard configuration devices only'
                DeviceMode = 'standardConfiguration'
                RuleType   = 'include'
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = 'Shared PC eligible editions'
                OsEditionTypes = @('windows10Enterprise', 'windows10Education')
                RuleType       = 'include'
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = 'Windows 10 22H2 or later'
                MinOSVersion = '10.0.19045.0'
                MaxOSVersion = '10.0.26100.9999'
                RuleType     = 'include'
            };
            DisableAccountManager                       = $False;
            DisableEduPolicies                          = $False;
            DisablePowerPolicies                        = $False;
            DisableSignInOnResume                       = $False;
            DisplayName                                 = "Shared Multi device";
            Enabled                                     = $True;
            Ensure                                      = "Present";
            FastFirstSignIn                             = "notConfigured";
            IdleTimeBeforeSleepInSeconds                = 60;
            LocalStorage                                = "enabled";
            MaintenanceStartTime                        = "00:03:00";
            SetAccountManager                           = "enabled";
            SetEduPolicies                              = "enabled";
            SetPowerPolicies                            = "enabled";
            SignInOnResume                              = "enabled";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
