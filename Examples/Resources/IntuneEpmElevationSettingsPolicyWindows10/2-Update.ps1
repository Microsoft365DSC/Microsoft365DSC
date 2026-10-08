<#
This example updates a Intune Firewall Policy for Windows10.
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
        IntuneEpmElevationSettingsPolicyWindows10 'IntuneEpmElevationSettingsPolicyWindows10-Example'
        {
            Assignments                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            Description                 = 'Elevation rules for engineering and design workstations' # Updated Property
            AllowElevationDetection     = "0";
            DefaultBehaviorValidation   = @("1", "2");
            DefaultElevationResponse    = "1";
            DisplayName                 = "Endpoint Privilege Management Defaults";
            EndpointPrivilegeManagement = "1";
            ReportingScope              = "1";
            SendDataToMicrosoft         = "1";
            Ensure                      = "Present";
            RoleScopeTagIds             = @("0");
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
