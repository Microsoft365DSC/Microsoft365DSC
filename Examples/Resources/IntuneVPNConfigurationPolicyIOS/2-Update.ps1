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
        IntuneVPNConfigurationPolicyIOS "IntuneVPNConfigurationPolicyIOS-Example"
        {
            Assignments                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Devices"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            associatedDomains              = @("contoso.com", "portal.contoso.com");
            authenticationMethod           = "usernameAndPassword";
            connectionName                 = "Contoso Corporate VPN";
            cloudName                      = "zscalertwo";
            connectionType                 = "zscalerPrivateAccess";
            customData                     = @(
                MSFT_customData{
                    key   = "TunnelGroup"
                    value = "Corporate"
                }
            );
            customKeyValueData             = @(
                MSFT_customKeyValueData{
                    name  = "TunnelGroup"
                    value = "Corporate"
                }
            );
            Description                    = "Corporate VPN profile for iOS devices";
            disableOnDemandUserOverride    = $true;
            disconnectOnIdle               = $true;
            disconnectOnIdleTimerInSeconds = 300;
            DisplayName                    = "Corporate VPN - iOS";
            enablePerApp                   = $true;
            enableSplitTunneling           = $false;
            Ensure                         = "Present";
            excludedDomains                = @("cdn.contoso.com", "status.contoso.com");
            excludeList                    = @("updates.contoso.com");
            onDemandRules                  = @(
                MSFT_DeviceManagementConfigurationPolicyVpnOnDemandRule{
                    action                = "evaluateConnection"
                    domainAction          = "connectIfNeeded"
                    domains               = @("intranet.contoso.com", "sharepoint.contoso.com")
                    probeRequiredUrl      = "https://intranet.contoso.com/probe"
                    probeUrl              = "https://intranet.contoso.com/health"
                    interfaceTypeMatch    = "wiFi"
                    ssids                 = @("Contoso-Corp")
                    dnsServerAddressMatch = @("10.10.0.10", "10.10.0.11")
                }
            );
            optInToDeviceIdSharing         = $true;
            providerType                   = "packetTunnel";
            proxyServer                    = @(
                MSFT_MicrosoftvpnProxyServer{
                    port                            = 80
                    automaticConfigurationScriptUrl = "https://proxy.contoso.com/proxy.pac"
                    address                         = "proxy.contoso.com"
                }
            );
            RoleScopeTagIds                = @("0");
            safariDomains                  = @("intranet.contoso.com", "sharepoint.contoso.com");
            server                         = @(
                MSFT_MicrosoftGraphvpnServer{
                    isDefaultServer = $true
                    description     = "Primary VPN gateway"
                    address         = "vpn2.contoso.com" # Updated Property
                }
            );
            strictEnforcement              = $true;
            userDomain                     = "contoso.com";
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
