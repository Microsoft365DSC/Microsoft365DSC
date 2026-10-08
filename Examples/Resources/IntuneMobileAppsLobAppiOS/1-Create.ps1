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
        IntuneMobileAppsLobAppiOS "IntuneMobileAppsLobAppiOS-Example"
        {
            AppleDeviceAppDeliveryProtocolType = "mobileDeviceManagement";
            ApplicableDeviceType               = MSFT_MicrosoftGraphIosDeviceType{
                IPad          = $True
                IPhoneAndIPod = $True
            };
            Assignments                        = @(
                MSFT_DeviceManagementLobAppiOSAssignment{
                    groupDisplayName                           = 'All devices'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    intent                                     = 'required'
                }
                MSFT_DeviceManagementLobAppiOSAssignment{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                    intent           = 'required'
                }
            );
            BuildNumber                        = "1";
            BundleId                           = "com.contoso.fieldservice";
            Categories                         = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            Description                        = "Line-of-business iOS application";
            Developer                          = "";
            DisplayName                        = "Contoso Field Service";
            Ensure                             = "Present";
            FileName                           = "ContosoFieldService.ipa";
            Id                                 = "63271b78-0fa4-46b8-9ac0-d4b777555dde";
            IsFeatured                         = $False;
            MinimumSupportedOperatingSystem    = MSFT_MicrosoftGraphIosMinimumOperatingSystem{
                V8_0  = $False
                V9_0  = $False
                V10_0 = $False
                V11_0 = $False
                V12_0 = $False
                V13_0 = $False
                V14_0 = $False
                V15_0 = $False
                V16_0 = $True
                V17_0 = $False
                V18_0 = $False
            };
            Notes                              = "";
            Owner                              = "";
            Publisher                          = "Contoso";
            RoleScopeTagIds                    = @("0");
            VersionNumber                      = "6.8.26";
            ApplicationId                      = $ApplicationId;
            TenantId                           = $TenantId;
            CertificateThumbprint              = $CertificateThumbprint;
        }
    }
}
