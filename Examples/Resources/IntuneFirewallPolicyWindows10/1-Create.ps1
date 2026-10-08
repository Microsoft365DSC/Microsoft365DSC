<#
This example creates a new Intune Firewall Policy for Windows10.
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
        IntuneFirewallPolicyWindows10 'IntuneFirewallPolicyWindows10-Example'
        {
            Assignments                                                  = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            Description                                                  = "Baseline Windows Defender Firewall settings for corporate laptops";
            DisplayName                                                  = "Intune Firewall Policy Windows10";
            RoleScopeTagIds                                              = @("0");
            CRLcheck                                                     = "1";
            DisableStatefulFtp                                           = "false";
            EnablePacketQueue                                            = @(1);
            IPsecExempt                                                  = @(2);
            OpportunisticallyMatchAuthSetPerKM                           = "false";
            PresharedKeyEncoding                                         = "1";
            SaIdleTime                                                   = 300;
            DomainProfile_EnableFirewall                                 = "true";
            DomainProfile_DefaultInboundAction                           = "1";
            DomainProfile_DefaultOutboundAction                          = "0";
            DomainProfile_DisableInboundNotifications                    = "true";
            DomainProfile_DisableStealthMode                             = "false";
            DomainProfile_DisableStealthModeIpsecSecuredPacketExemption  = "false";
            DomainProfile_DisableUnicastResponsesToMulticastBroadcast    = "false";
            DomainProfile_Shielded                                       = "false";
            DomainProfile_AllowLocalPolicyMerge                          = "false";
            DomainProfile_AllowLocalIpsecPolicyMerge                     = "false";
            DomainProfile_AuthAppsAllowUserPrefMerge                     = "false";
            DomainProfile_GlobalPortsAllowUserPrefMerge                  = "false";
            DomainProfile_EnableLogDroppedPackets                        = "true";
            DomainProfile_EnableLogSuccessConnections                    = "true";
            DomainProfile_EnableLogIgnoredRules                          = "false";
            DomainProfile_LogFilePath                                    = "%systemroot%\system32\LogFiles\Firewall\pfirewall.log";
            DomainProfile_LogMaxFileSize                                 = 1024;
            PrivateProfile_EnableFirewall                                = "true";
            PrivateProfile_DefaultInboundAction                          = "1";
            PrivateProfile_DefaultOutboundAction                         = "0";
            PrivateProfile_DisableInboundNotifications                   = "true";
            PrivateProfile_DisableStealthMode                            = "false";
            PrivateProfile_DisableStealthModeIpsecSecuredPacketExemption = "false";
            PrivateProfile_DisableUnicastResponsesToMulticastBroadcast   = "false";
            PrivateProfile_Shielded                                      = "false";
            PrivateProfile_AllowLocalPolicyMerge                         = "false";
            PrivateProfile_AllowLocalIpsecPolicyMerge                    = "false";
            PrivateProfile_AuthAppsAllowUserPrefMerge                    = "false";
            PrivateProfile_GlobalPortsAllowUserPrefMerge                 = "false";
            PrivateProfile_EnableLogDroppedPackets                       = "true";
            PrivateProfile_EnableLogSuccessConnections                   = "true";
            PrivateProfile_EnableLogIgnoredRules                         = "false";
            PrivateProfile_LogFilePath                                   = "%systemroot%\system32\LogFiles\Firewall\pfirewall-private.log";
            PrivateProfile_LogMaxFileSize                                = 1024;
            PublicProfile_EnableFirewall                                 = "true";
            PublicProfile_DefaultInboundAction                           = "1";
            PublicProfile_DefaultOutboundAction                          = "0";
            PublicProfile_DisableInboundNotifications                    = "true";
            PublicProfile_DisableStealthMode                             = "false";
            PublicProfile_DisableStealthModeIpsecSecuredPacketExemption  = "false";
            PublicProfile_DisableUnicastResponsesToMulticastBroadcast    = "true";
            PublicProfile_Shielded                                       = "false";
            PublicProfile_AllowLocalPolicyMerge                          = "false";
            PublicProfile_AllowLocalIpsecPolicyMerge                     = "false";
            PublicProfile_AuthAppsAllowUserPrefMerge                     = "false";
            PublicProfile_GlobalPortsAllowUserPrefMerge                  = "false";
            PublicProfile_EnableLogDroppedPackets                        = "true";
            PublicProfile_EnableLogSuccessConnections                    = "true";
            PublicProfile_EnableLogIgnoredRules                          = "false";
            PublicProfile_LogFilePath                                    = "%systemroot%\system32\LogFiles\Firewall\pfirewall-public.log";
            PublicProfile_LogMaxFileSize                                 = 4096;
            ObjectAccess_AuditFilteringPlatformConnection                = "3";
            ObjectAccess_AuditFilteringPlatformPacketDrop                = "1";
            AllowedTlsAuthenticationEndpoints                            = @("https://nls.contoso.com", "https://nls-backup.contoso.com");
            ConfiguredTlsAuthenticationNetworkName                       = "Contoso Corporate Network";
            Target                                                       = "wsl";
            EnableLoopback                                               = "true";
            HyperVVMSettings_DomainProfile_EnableFirewall                = "true";
            HyperVVMSettings_DomainProfile_AllowLocalPolicyMerge         = "false";
            HyperVVMSettings_DomainProfile_DefaultInboundAction          = "1";
            HyperVVMSettings_DomainProfile_DefaultOutboundAction         = "0";
            HyperVVMSettings_PrivateProfile_EnableFirewall               = "true";
            HyperVVMSettings_PrivateProfile_AllowLocalPolicyMerge        = "false";
            HyperVVMSettings_PrivateProfile_DefaultInboundAction         = "1";
            HyperVVMSettings_PrivateProfile_DefaultOutboundAction        = "0";
            HyperVVMSettings_PublicProfile_EnableFirewall                = "true";
            HyperVVMSettings_PublicProfile_AllowLocalPolicyMerge         = "false";
            HyperVVMSettings_PublicProfile_DefaultInboundAction          = "1";
            HyperVVMSettings_PublicProfile_DefaultOutboundAction         = "0";
            AllowHostPolicyMerge                                         = "false";
            Ensure                                                       = "Present";
            ApplicationId                                                = $ApplicationId;
            TenantId                                                     = $TenantId;
            CertificateThumbprint                                        = $CertificateThumbprint;
        }
    }
}
