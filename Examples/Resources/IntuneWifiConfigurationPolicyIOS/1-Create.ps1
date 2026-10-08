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
        IntuneWifiConfigurationPolicyIOS 'IntuneWifiConfigurationPolicyIOS-Example'
        {
            DisplayName                    = 'ios wifi'
            Description                    = 'Corporate Wi-Fi for company-owned iPhones and iPads'
            Assignments                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            ConnectAutomatically           = $true
            ConnectWhenNetworkNameIsHidden = $true
            DisableMacAddressRandomization = $true
            ForcePreSharedKeyUpdate        = $false
            NetworkName                    = 'Head Office Wi-Fi'
            PreSharedKey                   = '<wifi-pre-shared-key>'
            ProxyManualAddress             = 'proxy.contoso.com'
            ProxyManualPort                = 8080
            ProxySettings                  = 'manual'
            RoleScopeTagIds                = @('0')
            Ssid                           = 'Contoso-Mobile'
            WiFiSecurityType               = 'wpaPersonal'
            Ensure                         = 'Present'
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
