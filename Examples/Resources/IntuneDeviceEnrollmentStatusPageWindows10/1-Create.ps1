<#
This example creates a new Device Enrollment Status Page.
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
        IntuneDeviceEnrollmentStatusPageWindows10 'IntuneDeviceEnrollmentStatusPageWindows10-Example'
        {
            AllowDeviceResetOnInstallFailure        = $True;
            AllowDeviceUseOnInstallFailure          = $True;
            AllowLogCollectionOnInstallFailure      = $True;
            AllowNonBlockingAppInstallation         = $False;
            Assignments                             = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            BlockDeviceSetupRetryByUser             = $False;
            CustomErrorMessage                      = "Setup could not be completed. Please try again or contact your support person for help.";
            Description                             = "Tracks app and policy installation while Autopilot provisions corporate devices";
            DisableUserStatusTrackingAfterFirstUser = $True;
            DisplayName                             = "Autopilot Device Setup Status";
            Ensure                                  = "Present";
            InstallProgressTimeoutInMinutes         = 60;
            InstallQualityUpdates                   = $False;
            RoleScopeTagIds                         = @("0");
            SelectedMobileAppIds                    = @();
            ShowInstallationProgress                = $True;
            TrackInstallProgressForAutopilotOnly    = $True;
            ApplicationId                           = $ApplicationId;
            TenantId                                = $TenantId;
            CertificateThumbprint                   = $CertificateThumbprint;
        }
    }
}
