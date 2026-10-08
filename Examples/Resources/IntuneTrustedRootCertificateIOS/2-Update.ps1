<#
This example creates a new Intune Trusted Root Certificate Configuration Policy for iOs devices
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

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        IntuneTrustedRootCertificateIOS "IntuneTrustedRootCertificateIOS-Example"
        {
            Description            = "Deploys the Contoso issuing root certificate to corporate iPhones and iPads";
            DisplayName            = "Contoso Root CA (iOS)";
            RoleScopeTagIds        = @("0");
            Ensure                 = "Present";
            certFileName           = "ContosoRootCA-2027.cer"; # Updated Property
            trustedRootCertificate = "<base64-encoded-root-certificate-updated>"; # Updated Property
            Assignments            = @(
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
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
