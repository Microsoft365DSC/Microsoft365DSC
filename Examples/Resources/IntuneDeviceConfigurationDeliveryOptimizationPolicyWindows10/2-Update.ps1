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
        IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10 'IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10-Example'
        {
            Assignments                                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            );
            Description                                    = "";
            DisplayName                                    = "IntuneDeviceConfigurationDeliveryOptimizationPolicyWindows10_1";
            DOAbsoluteMaxCacheSize                         = 4;
            DOAllowVPNPeerCaching                          = "1";
            DOCacheHost                                    = @("Cache Host");
            DOCacheHostSource                              = 1;
            DODelayBackgroundDownloadFromHttp              = 500000;
            DODelayCacheServerFallbackBackground           = 120;
            DODelayCacheServerFallbackForeground           = 50;
            DODelayForegroundDownloadFromHttp              = 10;
            DODisallowCacheServerDownloadsOnVPN            = "1";
            DODownloadMode                                 = "0";
            DOGroupId                                      = "00000000-0000-0000-0000-000000000000";
            DOGroupIdSource                                = "2";
            DOMaxBackgroundDownloadBandwidth               = 20;
            DOMaxCacheAge                                  = 3;
            DOMaxCacheSize                                 = 80;
            DOMaxForegroundDownloadBandwidth               = 25;
            DOMinBackgroundQos                             = 1000;
            DOMinBatteryPercentageAllowedToUpload          = 77;
            DOMinDiskSizeAllowedToPeer                     = 20000;
            DOMinFileSizeToCache                           = 33550;
            DOMinRAMAllowedToPeer                          = 15000;
            DOModifyCacheDrive                             = "%SystemDrive%\";
            DOMonthlyUploadDataCap                         = 67890;
            DOPercentageMaxBackgroundBandwidth             = 20; # Updated Property
            DOPercentageMaxForegroundBandwidth             = 10;
            DORestrictPeerSelectionBy                      = "1";
            DOVpnKeywords                                  = @("vpn 1","vpn 2");
            Ensure                                         = "Present";
            RoleScopeTagIds                                = @("0");
            SetHoursToLimitBackgroundDownloadBandwidth     = "1";
            SetHoursToLimitBackgroundDownloadBandwidthFrom = "8";
            SetHoursToLimitBackgroundDownloadBandwidthIn   = 50;
            SetHoursToLimitBackgroundDownloadBandwidthOut  = 57;
            SetHoursToLimitBackgroundDownloadBandwidthTo   = "19";
            SetHoursToLimitForegroundDownloadBandwidth     = "1";
            SetHoursToLimitForegroundDownloadBandwidthFrom = "8";
            SetHoursToLimitForegroundDownloadBandwidthIn   = 10;
            SetHoursToLimitForegroundDownloadBandwidthOut  = 31;
            SetHoursToLimitForegroundDownloadBandwidthTo   = "17";
            ApplicationId                                  = $ApplicationId;
            TenantId                                       = $TenantId;
            CertificateThumbprint                          = $CertificateThumbprint;
        }
    }
}
