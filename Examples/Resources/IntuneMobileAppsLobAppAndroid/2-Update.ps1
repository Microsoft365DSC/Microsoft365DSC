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
        IntuneMobileAppsLobAppAndroid "IntuneMobileAppsLobAppAndroid-Example"
        {
            Assignments                     = @(
                MSFT_DeviceManagementMobileAppAssignment{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                    intent                                     = 'required'
                }
            );
            Categories                      = @(
                MSFT_DeviceManagementMobileAppCategory{
                    DisplayName = "Business"
                }
            );
            Description                     = "Contoso field service application for Android phones and tablets"; # Updated Property
            Developer                       = "Contoso Application Development";
            DisplayName                     = "Apk App";
            MinimumSupportedOperatingSystem = MSFT_MicrosoftGraphAndroidMinimumOperatingSystem{
                V10_0 = $true
            };
            PackageId                       = "com.contoso.lineofbusiness";
            TargetedPlatforms               = "androidDeviceAdministrator";
            InformationUrl                  = "https://intranet.contoso.com/apps/field-service";
            PrivacyInformationUrl           = "https://www.contoso.com/privacy";
            Ensure                          = "Present";
            FileName                        = "ContosoLineOfBusiness.apk";
            IsFeatured                      = $true;
            LargeIcon                       = MSFT_DeviceManagementMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-app-icon>"
            };
            Notes                           = "Reviewed annually by the mobility team";
            Owner                           = "Field Operations";
            Publisher                       = "Contoso";
            RoleScopeTagIds                 = @("0");
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
