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
        IntuneDeviceConfigurationSCEPCertificatePolicyWindows10 'IntuneDeviceConfigurationSCEPCertificatePolicyWindows10-Example'
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
            CertificateStore                            = "user";
            CertificateValidityPeriodScale              = "years";
            CertificateValidityPeriodValue              = 5;
            CustomSubjectAlternativeNames               = @(
                MSFT_MicrosoftGraphcustomSubjectAlternativeName{
                    SanType = 'domainNameService'
                    Name    = 'dns'
                }
            );
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
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "User Authentication Certificate";
            Ensure                                      = "Present";
            ExtendedKeyUsages                           = @(
                MSFT_MicrosoftGraphextendedKeyUsage{
                    ObjectIdentifier = '1.3.6.1.5.5.7.3.2'
                    Name             = 'Client Authentication'
                }
            );
            HashAlgorithm                               = "sha2";
            KeySize                                     = "size2048";
            KeyStorageProvider                          = "useTpmKspOtherwiseUseSoftwareKsp";
            KeyUsage                                    = @("digitalSignature");
            RenewalThresholdPercentage                  = 30; # Updated Property
            ScepServerUrls                              = @("https://ndes.contoso.com/certsrv/mscep/mscep.dll");
            SubjectAlternativeNameType                  = "none";
            SubjectNameFormat                           = "custom";
            SubjectNameFormatString                     = "CN={{UserName}},E={{EmailAddress}}";
            RootCertificateDisplayName                  = "Contoso Root CA Trust";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
