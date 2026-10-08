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
        IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner 'IntuneWifiConfigurationPolicyAndroidEnterpriseDeviceOwner-Example'
        {
            DisplayName                        = 'Wifi - androidForWork'
            Description                        = 'Corporate Wi-Fi for company-owned Android devices'
            Assignments                        = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            )
            AuthenticationMethod               = 'usernameAndPassword'
            ConnectAutomatically               = $true # Updated Property
            ConnectWhenNetworkNameIsHidden     = $false
            EapType                            = 'peap'
            InnerAuthenticationProtocolForPeap = 'microsoftChapVersionTwo'
            MacAddressRandomizationMode        = 'automatic'
            NetworkName                        = 'Contoso Corporate Wi-Fi'
            OuterIdentityPrivacyTemporaryValue = 'anonymous'
            PreSharedKey                       = '<wifi-pre-shared-key>'
            PreSharedKeyIsSet                  = $true
            ProxyExclusionList                 = 'intranet.contoso.com,*.contoso.local'
            ProxyManualAddress                 = 'proxy.contoso.com'
            ProxyManualPort                    = 8080
            ProxySettings                      = 'manual'
            RoleScopeTagIds                    = @('0')
            Ssid                               = 'Contoso-Corp'
            TrustedServerCertificateNames      = @('Contoso Root CA')
            WiFiSecurityType                   = 'wpaPersonal'
            Ensure                             = 'Present'
            ApplicationId                      = $ApplicationId;
            TenantId                           = $TenantId;
            CertificateThumbprint              = $CertificateThumbprint;
        }
    }
}
