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
        IntuneVPNConfigurationPolicyAndroidDeviceOwner "IntuneVPNConfigurationPolicyAndroidDeviceOwner-Example"
        {
            Assignments           = @();
            alwaysOn              = $true;
            alwaysOnLockdown      = $false;
            authenticationMethod  = "azureAD";
            connectionName        = "Contoso Corporate VPN";
            connectionType        = "microsoftProtect";
            Description           = "Always-on VPN for fully managed Android devices";
            DisplayName           = "Android Fully Managed Corporate VPN";
            Ensure                = "Present";
            customData            = @(
                MSFT_CustomData{
                    key   = 'ContosoVpnSettings'
                    value = '[{"key":"splitTunnel","type":"int","value":"1"},{"type":"int","key":"compression","value":"0"}]'
                }
            );
            customKeyValueData    = @(
                MSFT_customKeyValueData{
                    value = '[{"key":"splitTunnel","type":"int","value":"1"},{"type":"int","key":"compression","value":"0"}]'
                    name  = 'ContosoVpnSettings'
                }
            );
            proxyExclusionList    = @("intranet.contoso.com", "*.contoso.local");
            proxyServer           = @(
                MSFT_MicrosoftvpnProxyServer{
                    port                            = 8080
                    automaticConfigurationScriptUrl = 'https://proxy.contoso.com/proxy.pac'
                    address                         = 'proxy.contoso.com'
                }
            );
            servers               = @(
                MSFT_MicrosoftGraphvpnServer{
                    isDefaultServer = $True
                    description     = 'Primary VPN gateway'
                    address         = 'vpn.contoso.com:8080'
                }
            );
            targetedMobileApps    = @(
                MSFT_targetedMobileApps{
                    name      = 'Microsoft Edge'
                    publisher = 'Microsoft Corporation'
                    appId     = 'com.microsoft.emmx'
                }
            );
            targetedPackageIds    = @("com.microsoft.emmx");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
