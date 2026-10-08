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
        IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 'IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10-Example'
        {
            DisplayName                                       = "Feature Updates - Windows 10 22H2";
            Assignments                                       = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            Description                                       = "Holds managed devices on Windows 10 version 22H2";
            FeatureUpdateVersion                              = "Windows 10, version 22H2";
            InstallFeatureUpdatesOptional                     = $false;
            InstallLatestWindows10OnWindows11IneligibleDevice = $false;
            RoleScopeTagIds                                   = @("0");
            RolloutSettings                                   = MSFT_MicrosoftGraphwindowsUpdateRolloutSettings{
                OfferEndDateTimeInUTC   = "2026-05-29T09:00:00.0000000Z"
                OfferIntervalInDays     = 7
                OfferStartDateTimeInUTC = "2026-03-02T09:00:00.0000000Z"
            };
            Ensure                                            = "Present";
            ApplicationId                                     = $ApplicationId;
            TenantId                                          = $TenantId;
            CertificateThumbprint                             = $CertificateThumbprint;
        }
    }
}
