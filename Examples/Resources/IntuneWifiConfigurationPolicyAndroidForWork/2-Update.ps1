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
        IntuneWifiConfigurationPolicyAndroidForWork 'IntuneWifiConfigurationPolicyAndroidForWork-Example'
        {
            DisplayName                    = 'Contoso Work Profile Wi-Fi'
            Description                    = 'Corporate Wi-Fi for Android work profile devices in branch offices' # Updated Property
            Assignments                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            )
            ConnectAutomatically           = $true
            ConnectWhenNetworkNameIsHidden = $true
            NetworkName                    = 'CorpNet'
            RoleScopeTagIds                = @('0')
            Ssid                           = 'Contoso-Work'
            WiFiSecurityType               = 'wpa2Enterprise'
            Ensure                         = 'Present'
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
