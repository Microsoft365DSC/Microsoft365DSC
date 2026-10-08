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
        IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled 'IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolled-Example'
        {
            DisplayName                            = "WIP";
            Assignments                            = @(
                MSFT_IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolledPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allLicensedUsersAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_IntuneWindowsInformationProtectionPolicyWindows10MdmEnrolledPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Users"
                }
            );
            AzureRightsManagementServicesAllowed   = $true;
            DataRecoveryCertificate                = MSFT_MicrosoftGraphwindowsInformationProtectionDataRecoveryCertificate{
                Certificate        = "<base64-encoded-certificate>"
                Description        = "Data recovery agent for encrypted corporate files"
                ExpirationDateTime = "2028-01-01T00:00:00.0000000Z"
                SubjectName        = "CN=Contoso Data Recovery Agent"
            };
            Description                            = "Protects corporate data on managed Windows 10 devices";
            EnforcementLevel                       = "encryptAndAuditOnly";
            EnterpriseDomain                       = "contoso.co.uk"; # Updated Property
            EnterpriseInternalProxyServers         = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Head office internal proxies"
                    Resources   = @("10.10.240.10", "10.10.240.11")
                }
            );
            EnterpriseIPRanges                     = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionIPRangeCollection{
                    DisplayName = "Head office network"
                    Ranges      = @(
                        MSFT_MicrosoftGraphIpRange{
                            LowerAddress = "10.10.0.1"
                            UpperAddress = "10.10.1.254" # Updated Property
                            odataType    = "#microsoft.graph.iPv4Range"
                        }
                    )
                }
            );
            EnterpriseIPRangesAreAuthoritative     = $true;
            EnterpriseNetworkDomainNames           = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Corporate network domains"
                    Resources   = @("contoso.com", "corp.contoso.com")
                }
            );
            EnterpriseProtectedDomainNames         = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Protected corporate domains"
                    Resources   = @("contoso.com", "finance.contoso.com")
                }
            );
            EnterpriseProxiedDomains               = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionProxiedDomainCollection{
                    DisplayName    = "Cloud resources reached through the corporate proxy"
                    ProxiedDomains = @(
                        MSFT_MicrosoftGraphProxiedDomain{
                            IpAddressOrFQDN = "contoso.sharepoint.com"
                            Proxy           = "10.10.240.10"
                        }
                    )
                }
            );
            EnterpriseProxyServers                 = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Corporate outbound proxies"
                    Resources   = @("10.10.240.10:8080", "10.10.240.11:8080")
                }
            );
            EnterpriseProxyServersAreAuthoritative = $true;
            ExemptApps                             = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionApp{
                    BinaryName        = "notepad.exe"
                    BinaryVersionHigh = "65535.65535.65535.65535"
                    BinaryVersionLow  = "0.0.0.0"
                    Denied            = $false
                    Description       = "Plain text editor that cannot handle encrypted content"
                    DisplayName       = "Notepad"
                    ProductName       = "notepad.exe"
                    PublisherName     = "O=Microsoft Corporation, L=Redmond, S=Washington, C=US"
                    odataType         = "#microsoft.graph.windowsInformationProtectionDesktopApp"
                }
            );
            IconsVisible                           = $true;
            IndexingEncryptedStoresOrItemsBlocked  = $false;
            NeutralDomainResources                 = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Domains used for both work and personal access"
                    Resources   = @("login.microsoftonline.com", "login.windows.net")
                }
            );
            ProtectedApps                          = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionApp{
                    Denied        = $false
                    Description   = "Corporate browser for line of business sites" # Updated Property
                    DisplayName   = "Microsoft Edge"
                    ProductName   = "Microsoft.MicrosoftEdge"
                    PublisherName = "CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US"
                    odataType     = "#microsoft.graph.windowsInformationProtectionStoreApp"
                }
            );
            ProtectionUnderLockConfigRequired      = $false;
            RevokeOnUnenrollDisabled               = $false;
            RightsManagementServicesTemplateId     = "<rms-template-id>";
            RoleScopeTagIds                        = @("0");
            SmbAutoEncryptedFileExtensions         = @(
                MSFT_MicrosoftGraphwindowsInformationProtectionResourceCollection{
                    DisplayName = "Office file types encrypted from corporate shares"
                    Resources   = @("docx", "xlsx", "pptx")
                }
            );
            Ensure                                 = "Present";
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
