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
        IntuneEndpointDetectionAndResponsePolicyMacOS 'IntuneEndpointDetectionAndResponsePolicyMacOS-Example'
        {
            DisplayName           = 'Edr Policy'
            tags_item_key         = 'GROUP'
            tags_item_value       = 'tag'
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            )
            Description           = 'Tags macOS devices reporting to Microsoft Defender for Endpoint'
            RoleScopeTagIds       = @('0')
            Ensure                = 'Present'

            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
