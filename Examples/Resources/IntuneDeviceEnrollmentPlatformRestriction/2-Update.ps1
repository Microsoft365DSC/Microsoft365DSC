<#
This example creates a new Device Enrollment Platform Restriction.
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
        IntuneDeviceEnrollmentPlatformRestriction 'IntuneDeviceEnrollmentPlatformRestriction-Example'
        {
            AndroidForWorkRestriction         = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            AndroidRestriction                = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            Assignments                       = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                });
            Description                       = "This is the default Device Type Restriction applied with the lowest priority to all users regardless of group membership.";
            DeviceEnrollmentConfigurationType = "platformRestrictions";
            DisplayName                       = "All users and all devices";
            Id                                = "3868d43e-873e-4416-8fd1-fc3d67c7c15c_DefaultPlatformRestrictions";
            Ensure                            = "Present";
            IosRestriction                    = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            MacOSRestriction                  = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            MacRestriction                    = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            TvosRestriction                   = MSFT_DeviceEnrollmentPlatformRestriction{
                personalDeviceEnrollmentBlocked = $False
                platformBlocked                 = $False
            };
            VisionOSRestriction               = MSFT_DeviceEnrollmentPlatformRestriction{
                personalDeviceEnrollmentBlocked = $False
                platformBlocked                 = $False
            };
            WindowsHomeSkuRestriction         = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            WindowsMobileRestriction          = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $True
                personalDeviceEnrollmentBlocked = $False
            };
            WindowsRestriction                = MSFT_DeviceEnrollmentPlatformRestriction{
                platformBlocked                 = $False
                personalDeviceEnrollmentBlocked = $False
            };
            ApplicationId                     = $ApplicationId;
            TenantId                          = $TenantId;
            CertificateThumbprint             = $CertificateThumbprint;
        }
    }
}
