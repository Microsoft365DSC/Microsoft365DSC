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
        IntuneWifiConfigurationPolicyAndroidOpenSourceProject 'IntuneWifiConfigurationPolicyAndroidOpenSourceProject-Example'
        {
            DisplayName                    = 'wifi aosp'
            Description                    = 'Wi-Fi for shared warehouse scanning devices'
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
            ConnectAutomatically           = $false
            ConnectWhenNetworkNameIsHidden = $true
            NetworkName                    = 'Warehouse Scanner Wi-Fi'
            PreSharedKey                   = '<wifi-pre-shared-key>'
            PreSharedKeyIsSet              = $true
            ProxyExclusionList             = @('intranet.contoso.com', '*.contoso.local')
            ProxyManualAddress             = 'proxy.contoso.com'
            ProxyManualPort                = 8080
            ProxySetting                   = 'manual'
            RoleScopeTagIds                = @('0')
            Ssid                           = 'Contoso-Scanners'
            WiFiSecurityType               = 'wpaPersonal'
            Ensure                         = 'Present'
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
