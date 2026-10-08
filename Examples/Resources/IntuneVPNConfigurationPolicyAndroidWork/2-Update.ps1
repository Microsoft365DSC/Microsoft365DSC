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
        IntuneVPNConfigurationPolicyAndroidWork "IntuneVPNConfigurationPolicyAndroidWork-Example"
        {
            alwaysOn              = $true;
            alwaysOnLockdown      = $false;
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Users"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Users"
                }
            );
            authenticationMethod  = "usernameAndPassword";
            connectionName        = "Contoso Work Profile VPN";
            connectionType        = "microsoftProtect";
            customData            = @(
                MSFT_customData{
                    key   = "ProfileName"
                    value = "Contoso-Mobile"
                }
            );
            customKeyValueData    = @(
                MSFT_customKeyValueData{
                    name  = "ProfileName"
                    value = "Contoso-Mobile"
                }
            );
            Description           = "Per-app VPN access to the corporate network from Android Enterprise work profiles";
            DisplayName           = "Android Work Profile Corporate VPN";
            Ensure                = "Present";
            proxyExclusionList    = @("intranet.contoso.com", "*.contoso.local");
            proxyServer           = @(
                MSFT_MicrosoftvpnProxyServer{
                    address = "proxy.contoso.com"
                    port    = 8080
                }
            );
            RoleScopeTagIds       = @("0");
            servers               = @(
                MSFT_MicrosoftGraphvpnServer{
                    isDefaultServer = $true
                    description     = "Primary VPN gateway"
                    address         = "vpn2.contoso.com" # Updated Property
                }
            );
            targetedMobileApps    = @(
                MSFT_targetedMobileApps{
                    name        = "Outlook"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://play.google.com/store/apps/details?id=com.microsoft.office.outlook"
                    appId       = "com.microsoft.office.outlook"
                }
            );
            targetedPackageIds    = @("com.microsoft.office.outlook");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
