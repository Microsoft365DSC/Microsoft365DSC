<#
This example creates a new Intune Device Features Configuration Policy for IOS.
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
        IntuneDeviceFeaturesConfigurationPolicyIOS "IntuneDeviceFeaturesConfigurationPolicyIOS-Example"
        {
            AirPrintDestinations                       = @(
                MSFT_airPrintDestination{
                    port         = 631
                    resourcePath = "printers/Xerox_Phaser_7600"
                    forceTls     = $true
                    ipAddress    = "10.20.30.40"
                }
            );
            Assignments                                = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            AssetTagTemplate                           = "Contoso IT - Mobile Fleet";
            ContentFilterSettings                      = @(
                MSFT_iosWebContentFilterSpecificWebsitesAccess{
                    allowedUrls = @("https://intranet.contoso.com")
                    dataType    = "#microsoft.graph.iosWebContentFilterAutoFilter"
                    blockedUrls = @("https://downloads.fabrikam.com")
                }
            );
            Description                                = "Corporate iOS device features - revised"; # Updated Property
            DeviceManagementApplicabilityRuleOsVersion = @(
                MSFT_deviceManagementApplicabilityRuleOsVersion{
                    Name         = "iPadOS and iOS 16 or later"
                    MinOSVersion = "16.0"
                    MaxOSVersion = "18.5"
                    RuleType     = "include"
                }
            );
            DisplayName                                = "Corporate iOS Device Features";
            Ensure                                     = "Present";
            HomeScreenDockIcons                        = @(
                MSFT_iosHomeScreenApp{
                    bundleID    = "com.apple.store.Jolly"
                    displayName = "Apple Store"
                    isWebClip   = $false
                }
            );
            HomeScreenGridHeight                       = 6;
            HomeScreenGridWidth                        = 4;
            HomeScreenPages                            = @(
                MSFT_iosHomeScreenItem{
                    icons = @(
                        MSFT_iosHomeScreenApp{
                            bundleID    = "com.apple.AppStore"
                            displayName = "App Store"
                            isWebClip   = $false
                        }
                    )

                }
            );
            Id                                         = "ab915bca-1234-4b11-8acb-719a771139bc";
            IosSingleSignOnExtension                   = @(
                MSFT_iosSingleSignOnExtension{
                    extensionIdentifier = "com.contoso.sso.credential"
                    dataType            = "#microsoft.graph.iosCredentialSingleSignOnExtension"
                    domains             = @("contoso.com")
                    teamIdentifier      = "4HMSJJRMAD"
                    realm               = "CONTOSO.COM"
                }
            );
            LockScreenFootnote                         = "If found, please return to the Contoso service desk.";
            NotificationSettings                       = @(
                MSFT_iosNotificationSettings{
                    alertType                = "banner"
                    enabled                  = $true
                    showOnLockScreen         = $true
                    badgesEnabled            = $true
                    soundsEnabled            = $true
                    publisher                = "Microsoft Corporation"
                    bundleID                 = "com.microsoft.Office.Outlook"
                    showInNotificationCenter = $true
                    previewVisibility        = "hideWhenLocked"
                    appName                  = "Outlook"
                }
            );
            RoleScopeTagIds                            = @("0");
            SingleSignOnSettings                       = @(
                MSFT_iosSingleSignOnSettings{
                    allowedAppsList       = @(
                        MSFT_appListItem{
                            appId = "com.microsoft.companyportal"
                            name  = "Intune Company Portal"
                        }
                    )
                    allowedUrls           = @("https://sso.contoso.com")
                    kerberosRealm         = "CONTOSO.COM"
                    displayName           = "Contoso Single Sign-On"
                    kerberosPrincipalName = "userPrincipalName"
                }
            );
            WallpaperDisplayLocation                   = "lockAndHomeScreens";
            WallpaperImage                             = @(
                MSFT_mimeContent{
                    type  = "image/png"
                    value = @("<base64-encoded-wallpaper-image>")
                }
            );
            ApplicationId                              = $ApplicationId;
            TenantId                                   = $TenantId;
            CertificateThumbprint                      = $CertificateThumbprint;
        }
    }
}
