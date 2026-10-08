<#
This example updates a device cleanup rule.
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
        IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 'IntuneWindowsUpdateForBusinessHotpatchProfileWindows10-Example'
        {
            DisplayName           = "Hotpatch - Windows 11 Enterprise";
            Description           = "Enables hotpatch quality updates so security fixes apply without a restart";
            HotpatchEnabled       = $False; # Updated Property
            RoleScopeTagIds       = @("0");
            ApprovalSettings      = @(
                MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting{
                    ApprovalMethodType           = "automatic"
                    DeferredDeploymentInDay      = 2
                    WindowsQualityUpdateCadence  = "monthly"
                    WindowsQualityUpdateCategory = "all"
                }
            );
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            Ensure                = 'Present';
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
