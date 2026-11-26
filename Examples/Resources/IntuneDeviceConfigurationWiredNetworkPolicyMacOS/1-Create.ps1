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
        IntuneDeviceConfigurationWiredNetworkPolicyMacOS 'IntuneDeviceConfigurationWiredNetworkPolicyMacOS-Example'
        {
            Assignments                          = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
            );
            AuthenticationMethod                 = "usernameAndPassword";
            DeploymentChannel                    = "deviceChannel";
            Description                          = "802.1X wired access for managed Macs";
            DisplayName                          = "macOS Wired Network";
            EapType                              = "eapTtls";
            EnableOuterIdentityPrivacy           = "anonymous";
            NetworkInterface                     = "anyEthernet";
            NetworkName                          = "Contoso Wired";
            NonEapAuthenticationMethodForEapTtls = "microsoftChapVersionTwo";
            RoleScopeTagIds                      = @("0");
            TrustedServerCertificateNames        = @("radius01.contoso.com", "radius02.contoso.com");
            Ensure                               = "Present";
            ApplicationId                        = $ApplicationId;
            TenantId                             = $TenantId;
            CertificateThumbprint                = $CertificateThumbprint;
        }
    }
}
