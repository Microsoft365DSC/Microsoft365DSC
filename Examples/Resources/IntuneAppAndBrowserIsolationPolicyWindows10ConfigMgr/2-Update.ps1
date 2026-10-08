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
        IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr 'IntuneAppAndBrowserIsolationPolicyWindows10ConfigMgr-Example'
        {
            Assignments                            = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                    collectionId                               = 'CM100014'
                }
            );
            AllowCameraMicrophoneRedirection       = 0; # Updated Property
            AllowPersistence                       = 0;
            AllowVirtualGPU                        = 0;
            AllowWindowsDefenderApplicationGuard   = 1;
            AuditApplicationGuard                  = 1;
            CertificateThumbprints                 = @("<certificate-thumbprint>");
            ClipboardFileType                      = 1;
            ClipboardSettings                      = 1;
            Description                            = "Application Guard isolation for Microsoft Edge on the finance workstations";
            DisplayName                            = 'App and Browser Isolation (ConfigMgr)'
            EnterpriseCloudResources               = @("contoso.sharepoint.com", "contoso-my.sharepoint.com");
            EnterpriseInternalProxyServers         = @("internalproxy.contoso.com:8080");
            EnterpriseIPRange                      = @("10.0.0.0-10.255.255.255", "192.168.0.0-192.168.255.255");
            EnterpriseIPRangesAreAuthoritative     = 1;
            EnterpriseNetworkDomainNames           = @("contoso.com", "corp.contoso.com");
            EnterpriseProxyServers                 = @("proxy.contoso.com:8080");
            EnterpriseProxyServersAreAuthoritative = 1;
            Ensure                                 = "Present";
            InstallWindowsDefenderApplicationGuard = "install";
            NeutralResources                       = @("login.microsoftonline.com", "login.windows.net");
            PrintingSettings                       = @(2, 4);
            RoleScopeTagIds                        = @("0");
            SaveFilesToHost                        = 0;
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
