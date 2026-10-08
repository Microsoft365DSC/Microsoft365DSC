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
        IntuneAppControlForBusinessPolicyWindows10 'IntuneAppControlForBusinessPolicyWindows10-Example'
        {
            Assignments                                               = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Devices"
                }
            );
            ConfigureApplicationControlOptions                        = "1";
            ConfigureApplicationControlsAuditMode                     = "1";
            ConfigureApplicationControlsTrustAppsFromManagedInstaller = "1";
            ConfigureApplicationControlsTrustAppsWithGoodReputation   = "1";
            Description                                               = "Audits application execution on pilot devices";
            DisplayName                                               = "App Control for Business - Audit Mode";
            Ensure                                                    = "Present";
            RoleScopeTagIds                                           = @("0");
            ApplicationId                                             = $ApplicationId;
            TenantId                                                  = $TenantId;
            CertificateThumbprint                                     = $CertificateThumbprint;
        }
    }
}
