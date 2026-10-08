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
        IntuneEndpointDetectionAndResponsePolicyLinux 'IntuneEndpointDetectionAndResponsePolicyLinux-Example'
        {
            DisplayName           = 'Linux Server EDR Tagging'
            tags_item_key         = 'GROUP'
            tags_item_value       = 'LinuxServers'
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            )
            Description           = 'Tags Linux servers reporting to Microsoft Defender for Endpoint'
            RoleScopeTagIds       = @('0')
            Ensure                = 'Present'

            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
