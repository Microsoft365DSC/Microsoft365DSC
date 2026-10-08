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
        IntuneMobileAppsStoreApp "IntuneMobileAppsStoreApp-Example"
        {
            TargetPlatform                     = "iOS"
            ApplicableDeviceType               = MSFT_MicrosoftGraphiosDeviceType{
                iPad          = $True
                iPhoneAndIPod = $True
            }
            AppStoreUrl                        = "https://apps.apple.com/us/app/microsoft-outlook/id951937596"
            BundleId                           = "com.microsoft.Office.Outlook"
            Description                        = "Store App Description";
            Developer                          = "Contoso";
            DisplayName                        = "Store App";
            Ensure                             = "Present";
            InformationUrl                     = "";
            IsFeatured                         = $True; # Updated Property
            MinimumSupportedOperatingSystem    = MSFT_MicrosoftGraphMinimumOperatingSystem{
                V8_0   = $True
                V9_0   = $False
                V10_0  = $False
                V11_0  = $False
                V12_0  = $False
                V13_0  = $False
                V14_0  = $False
                V15_0  = $False
            };
            Notes                              = "";
            Owner                              = "";
            PrivacyInformationUrl              = "";
            Publisher                          = "Contoso";
            Assignments                        = @(
                MSFT_DeviceManagementStoreMobileAppAssignment {
                    groupDisplayName                           = 'All devices'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    intent                                     = 'required'
                    assignmentSettings                         = MSFT_DeviceManagementStoreMobileAppAssignmentSettings {
                        odataType                = '#microsoft.graph.iosStoreAppAssignmentSettings'
                        uninstallOnDeviceRemoval = $False
                        isRemovable              = $True
                        preventManagedAppBackup  = $True
                    }
                }
                MSFT_DeviceManagementStoreMobileAppAssignment{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                    intent           = 'required'
                }
            );
            Categories                         = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            ApplicationId                      = $ApplicationId;
            TenantId                           = $TenantId;
            CertificateThumbprint              = $CertificateThumbprint;
        }
    }
}
