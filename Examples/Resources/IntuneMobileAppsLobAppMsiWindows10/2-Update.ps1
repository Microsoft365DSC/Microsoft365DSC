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
        IntuneMobileAppsLobAppMsiWindows10 "IntuneMobileAppsLobAppMsiWindows10-Example"
        {
            Assignments            = @(
                MSFT_DeviceManagementMobileAppAssignment {
                    groupDisplayName                           = 'All devices'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    intent                                     = 'required'
                }
                MSFT_DeviceManagementMobileAppAssignment{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                    intent           = 'required'
                }
            );
            Categories             = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            Description            = "MSI App Description";
            Developer              = "";
            DisplayName            = "MSI App";
            Ensure                 = "Present";
            FileName               = "MSIApp.msi";
            CommandLine            = "-arg1 -arg2";
            IgnoreVersionDetection = $True;
            IsFeatured             = $True; # Updated Property
            Notes                  = "";
            Owner                  = "";
            Publisher              = "Microsoft";
            RoleScopeTagIds        = @("0");
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
