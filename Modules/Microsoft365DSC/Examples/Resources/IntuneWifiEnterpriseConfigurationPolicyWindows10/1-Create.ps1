<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param(
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

    node localhost
    {
        IntuneWifiEnterpriseConfigurationPolicyWindows10 "myWifiEnterpriseConfigWindows10Policy"
        {
            Assignments                                = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = "none"
                    dataType = "#microsoft.graph.groupAssignmentTarget"
                }
            )
            AuthenticationMethod                       = "certificate"
            AuthenticationType                         = "user"
            ConnectAutomatically                       = $True
            ConnectWhenNetworkNameIsHidden             = $False
            Description                                = "My Enterprise Wifi Network"
            DeviceManagementApplicabilityRuleOsEdition = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                RuleType = ""
            }
            DeviceManagementApplicabilityRuleOsVersion = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                RuleType = ""
            }
            DisplayName                                = "Enterprise Wifi Configuration"
            EapType                                    = "eapTls"
            Ensure                                     = "Present"
            ForceFIPSCompliance                        = $False
            MeteredConnectionLimit                     = "unrestricted"
            NetworkName                                = "EnterpriseWifi"
            NetworkSingleSignOn                        = "disabled"
            ProxySetting                               = "none"
            RoleScopeTagIds                            = @()
            Ssid                                       = "ssid"
            TrustedServerCertificateNames              = @()
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
