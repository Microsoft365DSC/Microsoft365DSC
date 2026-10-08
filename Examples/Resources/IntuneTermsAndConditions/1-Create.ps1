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
        IntuneTermsAndConditions "IntuneTermsAndConditions-Example"
        {
            AcceptanceStatement   = "Summary of Terms and Conditions";
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Users"
                }
            );
            BodyText              = "Some Terms and Conditions";
            Description           = "";
            DisplayName           = "IntuneTermsAndConditions_1";
            Ensure                = "Present";
            RoleScopeTagIds       = @("0");
            Title                 = "IntuneTermsAndConditions_1";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
