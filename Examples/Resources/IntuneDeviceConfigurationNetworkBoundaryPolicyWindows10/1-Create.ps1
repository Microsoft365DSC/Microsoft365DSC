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
        IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10 'IntuneDeviceConfigurationNetworkBoundaryPolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            Description                                 = "Marks the corporate network, cloud resources and proxies as enterprise boundaries for Windows Information Protection";
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Education editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Education")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "Corporate Network Boundary";
            Ensure                                      = "Present";
            RoleScopeTagIds                             = @("0");
            WindowsNetworkIsolationPolicy               = MSFT_MicrosoftGraphwindowsNetworkIsolationPolicy{
                EnterpriseCloudResources               = @(
                    MSFT_MicrosoftGraphProxiedDomain{
                        IpAddressOrFQDN = "contoso.sharepoint.com"
                        Proxy           = "10.20.30.41"
                    }
                )
                EnterpriseProxyServers                 = @("10.20.30.40:8080")
                EnterpriseInternalProxyServers         = @("10.20.30.41:8080")
                EnterpriseIPRangesAreAuthoritative     = $True
                EnterpriseProxyServersAreAuthoritative = $True
                EnterpriseNetworkDomainNames           = @("contoso.com")
                EnterpriseIPRanges                     = @(
                    MSFT_MicrosoftGraphIpRange{
                        UpperAddress = "10.10.255.255"
                        LowerAddress = "10.10.0.0"
                        odataType    = '#microsoft.graph.iPv4Range'
                    }
                )
                NeutralDomainResources                 = @("sts.contoso.com", "login.microsoftonline.com")
            };
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
