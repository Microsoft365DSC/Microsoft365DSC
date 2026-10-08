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
        IntuneDeviceConfigurationVpnPolicyWindows10 'IntuneDeviceConfigurationVpnPolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            );
            AssociatedApps                              = @(
                MSFT_MicrosoftGraphwindows10AssociatedApps{
                    AppType    = "desktop"
                    Identifier = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
                }
                MSFT_MicrosoftGraphwindows10AssociatedApps{
                    AppType    = "universal"
                    Identifier = "Microsoft.CompanyPortal_8wekyb3d8bbwe"
                }
            );
            AuthenticationMethod                        = "usernameAndPassword";
            ConnectionName                              = "Cisco VPN";
            ConnectionType                              = "ciscoAnyConnect";
            CustomXml                                   = "PENvbmZpZz48VmVyc2lvbj4xPC9WZXJzaW9uPjxEZXZpY2VTZXR1cD48Q29ubmVjdGlvbkVudHJ5PjxIb3N0TmFtZT52cG4uY29udG9zby5jb208L0hvc3ROYW1lPjwvQ29ubmVjdGlvbkVudHJ5PjwvRGV2aWNlU2V0dXA+PC9Db25maWc+";
            Description                                 = "Always-on connection to the corporate network for staff and contractors working remotely"; # Updated Property
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Professional editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 11 22H2 or later"
                MinOSVersion = "10.0.22621.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "VPN";
            DnsRules                                    = @(
                MSFT_MicrosoftGraphvpnDnsRule{
                    Servers     = @('10.0.1.10')
                    Name        = 'NRPT rule'
                    Persistent  = $True
                    AutoTrigger = $True
                }
            );
            DnsSuffixes                                 = @("mydomain.com");
            EnableAlwaysOn                              = $True;
            EnableConditionalAccess                     = $True;
            EnableDnsRegistration                       = $True;
            EnableSingleSignOnWithAlternateCertificate  = $True;
            EnableSplitTunneling                        = $False;
            Ensure                                      = "Present";
            OnlyAssociatedAppsCanUseConnection          = $False;
            ProfileTarget                               = "user";
            ProxyServer                                 = MSFT_MicrosoftGraphwindows10VpnProxyServer{
                Port                             = 8081
                BypassProxyServerForLocalAddress = $True
                AutomaticConfigurationScriptUrl  = ''
                Address                          = '10.0.10.100'
            };
            RememberUserCredentials                     = $True;
            RoleScopeTagIds                             = @("0");
            Routes                                      = @(
                MSFT_MicrosoftGraphvpnRoute{
                    DestinationPrefix = "10.20.0.0"
                    PrefixSize        = 16
                }
                MSFT_MicrosoftGraphvpnRoute{
                    DestinationPrefix = "172.16.0.0"
                    PrefixSize        = 12
                }
            );
            Servers                                     = @(
                MSFT_MicrosoftGraphvpnServer{
                    IsDefaultServer = $True
                    Description     = 'gateway1'
                    Address         = '10.0.1.10'
                }
            );
            SingleSignOnEku                             = MSFT_MicrosoftGraphextendedKeyUsage{
                Name             = "Client Authentication"
                ObjectIdentifier = "1.3.6.1.5.5.7.3.2"
            };
            SingleSignOnIssuerHash                      = "<issuing-ca-certificate-hash>";
            TrafficRules                                = @(
                MSFT_MicrosoftGraphvpnTrafficRule{
                    Name                = 'VPN rule'
                    AppType             = 'none'
                    LocalAddressRanges  = @(
                        MSFT_MicrosoftGraphIPv4Range{
                            UpperAddress = '10.0.2.240'
                            LowerAddress = '10.0.2.0'
                        }
                    )
                    RoutingPolicyType   = 'forceTunnel'
                    VpnTrafficDirection = 'outbound'
                }
            );
            TrustedNetworkDomains                       = @("corp.contoso.com");
            WindowsInformationProtectionDomain          = "contoso.com";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
