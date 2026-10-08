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

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        IntunePolicySets "IntunePolicySets-Example"
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Users'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName                           = 'Intune Excluded Users'
                }
            );
            Description           = "Baseline policies applied to newly enrolled corporate devices";
            DisplayName           = "New Device Baseline";
            Ensure                = "Present";
            GuidedDeploymentTags  = @();
            Items                 = @(
                MSFT_DeviceManagementConfigurationPolicyItems{
                    guidedDeploymentTags = @()
                    payloadId            = 'T_12345678-90ab-90ab-90ab-1234567890ab'
                    displayName          = 'Android App Protection - Corporate'
                    dataType             = '#microsoft.graph.managedAppProtectionPolicySetItem'
                    itemType             = '#microsoft.graph.androidManagedAppProtection'
                }
            );
            RoleScopeTags         = @("0","1");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
   }
}
