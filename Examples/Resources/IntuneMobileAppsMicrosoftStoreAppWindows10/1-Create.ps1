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
        IntuneMobileAppsMicrosoftStoreAppWindows10 "IntuneMobileAppsMicrosoftStoreAppWindows10-Example"
        {
            Description           = "PowerShell Description";
            Developer             = "";
            DisplayName           = "PowerShell";
            Ensure                = "Present";
            InstallExperience     = MSFT_MicrosoftGraphWinGetAppInstallExperience{
                RunAsAccount = "system"
            };
            IsFeatured            = $False;
            Notes                 = "";
            Owner                 = "";
            PackageIdentifier     = "9MZ1SNWT0N5D";
            PrivacyInformationUrl = "https://github.com/PowerShell/PowerShell#telemetry";
            Publisher             = "Microsoft Corporation";
            Assignments           = @(
                MSFT_DeviceManagementWingetMobileAppAssignment {
                    groupDisplayName                           = 'All devices'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    intent                                     = 'required'
                }
                MSFT_DeviceManagementWingetMobileAppAssignment{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                    intent           = 'required'
                }
            );
            Categories            = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            RoleScopeTagIds       = @("0");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
