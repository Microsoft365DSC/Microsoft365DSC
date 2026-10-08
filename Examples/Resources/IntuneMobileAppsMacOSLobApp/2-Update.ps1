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
        IntuneMobileAppsMacOSLobApp "IntuneMobileAppsMacOSLobApp-Example"
        {
            Description                     = "Collaboration client for managed Mac computers";
            Developer                       = "Contoso Workplace Engineering"; # Updated Property
            DisplayName                     = "TeamsForBusinessInstaller";
            Ensure                          = "Present";
            InformationUrl                  = "https://intranet.contoso.com/apps/collaboration-client";
            IsFeatured                      = $true;
            MinimumSupportedOperatingSystem = MSFT_DeviceManagementMinimumOperatingSystem{
                v11_0 = $true
            };
            Notes                           = "Reviewed annually by the mobility team";
            Owner                           = "Workplace Services";
            PrivacyInformationUrl           = "https://www.contoso.com/privacy";
            Publisher                       = "Contoso";
            BundleId                        = "com.contoso.collaborationclient";
            BuildNumber                     = "2026.0815.1";
            VersionNumber                   = "1.6.0";
            IgnoreVersionDetection          = $false;
            InstallAsManaged                = $true;
            LargeIcon                       = MSFT_DeviceManagementMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-app-icon>"
            };
            RoleScopeTagIds                 = @("0");
            ChildApps                       = @(
                MSFT_DeviceManagementMobileAppChildApp{
                    BundleId      = "com.contoso.collaborationclient.helper"
                    BuildNumber   = "2026.0815.1"
                    VersionNumber = "1.6.0"
                }
            );
            Assignments                     = @(
                MSFT_DeviceManagementMacOSLobAppAssignment{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                    intent                                     = 'required'
                }
            );
            Categories                      = @(
                MSFT_DeviceManagementMobileAppCategory{
                    DisplayName = "Productivity"
                }
            );
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
