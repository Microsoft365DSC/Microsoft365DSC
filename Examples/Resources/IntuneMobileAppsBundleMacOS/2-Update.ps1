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
        IntuneMobileAppsBundleMacOS "IntuneMobileAppsBundleMacOS-Example"
        {
            Description                     = "macOS Pkg App Description";
            Developer                       = "Contoso";
            DisplayName                     = "macOS Pkg App";
            Ensure                          = "Present";
            InformationUrl                  = "";
            IsFeatured                      = $False;
            MinimumSupportedOperatingSystem = MSFT_MicrosoftGraphMacOSMinimumOperatingSystem{
                V10_7  = $False
                V10_8  = $False
                V10_9  = $False
                V10_10 = $False
                V10_11 = $False
                V10_12 = $False
                V10_13 = $False # Updated Property
                V10_14 = $True # Updated Property
                V10_15 = $False
                V11_0  = $False
                V12_0  = $False
                V13_0  = $False
                V14_0  = $False
                V15_0  = $False
            };
            Notes                           = "";
            Owner                           = "";
            PrivacyInformationUrl           = "";
            Publisher                       = "Contoso";
            Assignments                     = @(
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
            Categories                      = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            FileName                        = "CompanyPortal.pkg";
            IgnoreVersionDetection          = $true;
            IncludedApps                    = @(
                MSFT_MicrosoftGraphMacOSIncludedApp{
                    BundleId      = "com.microsoft.CompanyPortalMac"
                    BundleVersion = "5.2408.0"
                }
            );
            PackageFileType                 = "Pkg";
            PostInstallScript               = "#! Post-install script";
            PreInstallScript                = "#! Pre-install script";
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
