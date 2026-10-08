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
        IntuneDiskEncryptionFileVaultPolicyMacOS "IntuneDiskEncryptionFileVaultPolicyMacOS-Example"
        {
            Assignments                            = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Devices"
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                }
            );
            Defer                                  = "true";
            DeferDontAskAtUserLogout               = "false";
            DeferForceAtUserLoginMaxBypassAttempts = 5;
            Description                            = "";
            Enable                                 = "On";
            Ensure                                 = "Present";
            Location                               = "Contoso IT Service Desk";
            DisplayName                            = "IntuneDiskEncryptionFileVaultPolicyMacOS_1";
            RecoveryKeyRotationInMonths            = 1;
            RoleScopeTagIds                        = @("0");
            UseRecoveryKey                         = "true";
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
