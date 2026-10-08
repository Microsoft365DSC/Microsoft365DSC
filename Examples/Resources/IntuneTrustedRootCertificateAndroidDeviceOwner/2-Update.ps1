<#
This example creates a new Intune Trusted Root Certificate Configuration Policy for Android Device Owner/Administrator devices
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
        IntuneTrustedRootCertificateAndroidDeviceOwner "IntuneTrustedRootCertificateAndroidDeviceOwner-Example"
        {
            Description            = "Deploys the Contoso issuing root certificate to Android Enterprise fully managed devices";
            DisplayName            = "Contoso Root CA (Android Device Owner)";
            RoleScopeTagIds        = @("0");
            Ensure                 = "Present";
            certFileName           = "ContosoRootCA-2027.cer"; # Updated Property
            trustedRootCertificate = "<base64-encoded-root-certificate-updated>"; # Updated Property
            Assignments            = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
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
