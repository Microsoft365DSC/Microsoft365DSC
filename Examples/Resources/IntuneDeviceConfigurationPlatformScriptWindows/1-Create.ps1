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
        IntuneDeviceConfigurationPlatformScriptWindows 'IntuneDeviceConfigurationPlatformScriptWindows-Example'
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            Description           = "Activates the high performance power plan on lab workstations";
            DisplayName           = "Set High Performance Power Plan";
            Ensure                = "Present";
            EnforceSignatureCheck = $False;
            FileName              = "set-power-plan.ps1";
            RunAs32Bit            = $True;
            RoleScopeTagIds       = @("0");
            RunAsAccount          = "system";
            ScriptContent         = "cG93ZXJjZmcgL3NldGFjdGl2ZSBTQ0hFTUVfTUlODQo=";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
