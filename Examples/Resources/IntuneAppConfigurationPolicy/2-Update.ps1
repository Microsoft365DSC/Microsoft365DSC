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
        IntuneAppConfigurationPolicy 'IntuneAppConfigurationPolicy-Example'
        {
            DisplayName                 = 'Mobile Workforce App Settings'
            Description                 = "Managed browser settings for the mobile workforce"
            Assignments                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Users'
                }
            );
            appGroupType                = "selectedPublicApps"
            Apps                        = @(
                MSFT_managedMobileApp{
                    id                  = "com.microsoft.emmx.android"
                    mobileAppIdentifier = MSFT_AppIdentifier{
                        packageID = "com.microsoft.emmx"
                    }
                }
                MSFT_managedMobileApp{
                    id                  = "com.microsoft.msedge.ios"
                    mobileAppIdentifier = MSFT_AppIdentifier{
                        bundleID = "com.microsoft.msedge"
                    }
                }
            );
            CustomSettings              = @(
                MSFT_IntuneAppConfigurationPolicyCustomSetting{
                    name  = 'com.microsoft.intune.mam.managedbrowser.BlockListURLs'
                    value = 'https://www.aol.com'
                }
                MSFT_IntuneAppConfigurationPolicyCustomSetting{
                    name  = 'com.microsoft.intune.mam.managedbrowser.bookmarks'
                    value = 'Outlook Web|https://outlook.office.com||Bing|https://www.bing.com'
                }
                MSFT_IntuneAppConfigurationPolicyCustomSetting{
                    name  = 'com.microsoft.intune.mam.managedbrowser.homepage'
                    value = 'https://portal.contoso.com' # Updated Property
                }
            );
            roleScopeTagIds             = @("0")
            targetedAppManagementLevels = "unspecified"
            Ensure                      = 'Present'
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
