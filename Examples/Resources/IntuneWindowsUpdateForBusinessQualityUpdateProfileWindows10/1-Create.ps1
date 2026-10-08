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
        IntuneWindowsUpdateForBusinessQualityUpdateProfileWindows10 'IntuneWindowsUpdateForBusinessQualityUpdateProfileWindows10-Example'
        {
            Assignments             = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Excluded Devices'
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                }
            );
            DisplayName             = 'Windows Quality Update'
            Description             = 'Expedites the June 2024 security update to corporate Windows devices'
            ExpeditedUpdateSettings = MSFT_MicrosoftGraphexpeditedWindowsQualityUpdateSettings{
                QualityUpdateRelease  = '2024-06-11T00:00:00Z'
                DaysUntilForcedReboot = 0
            }
            RoleScopeTagIds         = @("0")
            Ensure                  = 'Present'
            ApplicationId           = $ApplicationId;
            TenantId                = $TenantId;
            CertificateThumbprint   = $CertificateThumbprint;
        }
    }
}
