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
        IntuneWifiConfigurationPolicyMacOS 'IntuneWifiConfigurationPolicyMacOS-Example'
        {
            DisplayName                          = 'macos wifi'
            Description                          = 'Corporate Wi-Fi for managed Mac devices'
            Assignments                          = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            ConnectAutomatically                 = $true
            ConnectWhenNetworkNameIsHidden       = $false # Updated Property
            DeploymentChannel                    = 'deviceChannel'
            ForcePreSharedKeyUpdate              = $false
            NetworkName                          = 'Design Studio Wi-Fi'
            PreSharedKey                         = '<wifi-pre-shared-key>'
            ProxyManualAddress                   = 'proxy.contoso.com'
            ProxyManualPort                      = 8080
            ProxySettings                        = 'manual'
            RoleScopeTagIds                      = @('0')
            Ssid                                 = 'Contoso-Mac'
            WifiRequirePhysicalMacAddressEnabled = $true
            WiFiSecurityType                     = 'wpaPersonal'
            Ensure                               = 'Present'
            ApplicationId                        = $ApplicationId;
            TenantId                             = $TenantId;
            CertificateThumbprint                = $CertificateThumbprint;
        }
    }
}
