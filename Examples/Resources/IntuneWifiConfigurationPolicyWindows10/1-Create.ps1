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
        IntuneWifiConfigurationPolicyWindows10 'IntuneWifiConfigurationPolicyWindows10-Example'
        {
            DisplayName                                = "win10 wifi - revised";
            Description                                = "Corporate wireless network for managed Windows laptops";
            ConnectAutomatically                       = $true;
            ConnectToPreferredNetwork                  = $true;
            ConnectWhenNetworkNameIsHidden             = $true;
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Professional editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 11 22H2 or later"
                MinOSVersion = "10.0.22621.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            ForceFIPSCompliance                        = $true;
            ForcePreSharedKeyUpdate                    = $true;
            MeteredConnectionLimit                     = "fixed";
            NetworkName                                = "Contoso Corporate Wi-Fi";
            PreSharedKey                               = "<wifi-pre-shared-key>";
            ProxyManualAddress                         = "proxy.contoso.com";
            ProxyManualPort                            = 8080;
            ProxySetting                               = "manual";
            RoleScopeTagIds                            = @("0");
            Ssid                                       = "CONTOSO-CORP";
            WifiSecurityType                           = "wpa2Personal";
            Assignments                                = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            Ensure                                     = "Present";
            ApplicationId                              = $ApplicationId;
            TenantId                                   = $TenantId;
            CertificateThumbprint                      = $CertificateThumbprint;
        }
    }
}
