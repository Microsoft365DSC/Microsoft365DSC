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
        IntuneDeviceConfigurationPolicyAndroidDeviceOwner 'IntuneDeviceConfigurationPolicyAndroidDeviceOwner-Example'
        {
            DisplayName                                              = 'Corporate Android Device Restrictions'
            Description                                              = "Kiosk baseline for shared Android tablets in retail stores"
            RoleScopeTagIds                                          = @("0")
            AccountsBlockModification                                = $true
            AndroidDeviceOwnerDelegatedScopeAppSettings              = @(
                MSFT_MicrosoftGraphandroiddeviceownerdelegatedscopeappsetting{
                    appScopes = @("certificateInstall")
                    appDetail = MSFT_MicrosoftGraphapplistitem{
                        appId       = "com.contoso.certmanager"
                        name        = "Contoso Certificate Manager"
                        publisher   = "Contoso Ltd"
                        appStoreUrl = "https://play.google.com/store/apps/details?id=com.contoso.certmanager"
                    }
                }
            )
            AppsAllowInstallFromUnknownSources                       = $false
            AppsAutoUpdatePolicy                                     = "wiFiOnly"
            AppsDefaultPermissionPolicy                              = "prompt"
            AppsRecommendSkippingFirstUseHints                       = $true
            AzureAdSharedDeviceDataClearApps                         = @(
                MSFT_MicrosoftGraphapplistitem{
                    appId       = "com.microsoft.emmx"
                    name        = "Microsoft Edge"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://play.google.com/store/apps/details?id=com.microsoft.emmx"
                }
            )
            BluetoothBlockConfiguration                              = $true
            BluetoothBlockContactSharing                             = $true
            CameraBlocked                                            = $false # Updated Property
            CellularBlockWiFiTethering                               = $true
            CertificateCredentialConfigurationDisabled               = $false
            CrossProfilePoliciesAllowCopyPaste                       = $false
            CrossProfilePoliciesAllowDataSharing                     = "crossProfileDataSharingBlocked"
            CrossProfilePoliciesShowWorkContactsInPersonalProfile    = $false
            DataRoamingBlocked                                       = $true
            DateTimeConfigurationBlocked                             = $true
            DetailedHelpText                                         = MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage{
                defaultMessage    = "This tablet is managed by Contoso IT. Call the service desk on 555 0142 for assistance."
                localizedMessages = @(
                    MSFT_MicrosoftGraphkeyvaluepair{
                        Name  = "en-us"
                        Value = "This tablet is managed by Contoso IT. Call the service desk on 555 0142 for assistance."
                    }
                )
            }
            DeviceLocationMode                                       = "disabled"
            DeviceOwnerLockScreenMessage                             = MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage{
                defaultMessage    = "Property of Contoso Retail. If found, please return to any Contoso store."
                localizedMessages = @(
                    MSFT_MicrosoftGraphkeyvaluepair{
                        Name  = "en-us"
                        Value = "Property of Contoso Retail. If found, please return to any Contoso store."
                    }
                )
            }
            EnrollmentProfile                                        = "dedicatedDevice"
            FactoryResetBlocked                                      = $true
            FactoryResetDeviceAdministratorEmails                    = @("deviceadmin@contoso.com")
            GlobalProxy                                              = MSFT_MicrosoftGraphandroiddeviceownerglobalproxy{
                odataType     = "#microsoft.graph.androidDeviceOwnerGlobalProxyDirect"
                host          = "proxy.contoso.com"
                port          = 8080
                excludedHosts = @("intranet.contoso.com", "updates.contoso.com")
            }
            GoogleAccountsBlocked                                    = $true
            KioskCustomizationDeviceSettingsBlocked                  = $true
            KioskCustomizationPowerButtonActionsBlocked              = $true
            KioskCustomizationStatusBar                              = "systemInfoOnly"
            KioskCustomizationSystemErrorWarnings                    = $false
            KioskCustomizationSystemNavigation                       = "homeButtonOnly"
            KioskModeAppOrderEnabled                                 = $true
            KioskModeAppPositions                                    = @(
                MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem{
                    position = 1
                    item     = MSFT_MicrosoftGraphandroiddeviceownerkioskmodehomescreenitem{
                        odataType = "#microsoft.graph.androidDeviceOwnerKioskModeApp"
                        package   = "com.microsoft.emmx"
                        className = "com.microsoft.emmx.Main"
                    }
                }
                MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem{
                    position = 2
                    item     = MSFT_MicrosoftGraphandroiddeviceownerkioskmodehomescreenitem{
                        odataType = "#microsoft.graph.androidDeviceOwnerKioskModeWeblink"
                        label     = "Store Handbook"
                        link      = "https://contoso.sharepoint.com/sites/retail/handbook"
                    }
                }
            )
            KioskModeApps                                            = @(
                MSFT_MicrosoftGraphapplistitem{
                    appId       = "com.microsoft.emmx"
                    name        = "Microsoft Edge"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://play.google.com/store/apps/details?id=com.microsoft.emmx"
                }
                MSFT_MicrosoftGraphapplistitem{
                    appId       = "com.microsoft.teams"
                    name        = "Microsoft Teams"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://play.google.com/store/apps/details?id=com.microsoft.teams"
                }
            )
            KioskModeAppsInFolderOrderedByName                       = $true
            KioskModeBluetoothConfigurationEnabled                   = $false
            KioskModeDebugMenuEasyAccessEnabled                      = $false
            KioskModeExitCode                                        = "<kiosk-mode-exit-code>"
            KioskModeFlashlightConfigurationEnabled                  = $true
            KioskModeFolderIcon                                      = "darkSquare"
            KioskModeGridHeight                                      = 6
            KioskModeGridWidth                                       = 4
            KioskModeIconSize                                        = "regular"
            KioskModeLockHomeScreen                                  = $true
            KioskModeManagedFolders                                  = @(
                MSFT_MicrosoftGraphandroiddeviceownerkioskmodemanagedfolder{
                    folderIdentifier = "store-tools"
                    folderName       = "Store Tools"
                    items            = @(
                        MSFT_MicrosoftGraphandroiddeviceownerkioskmodefolderitem{
                            odataType = "#microsoft.graph.androidDeviceOwnerKioskModeApp"
                            package   = "com.microsoft.teams"
                            className = "com.microsoft.teams.Main"
                        }
                    )
                }
            )
            KioskModeManagedHomeScreenAppSettings                    = @(
                MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapp{
                    package                   = "com.microsoft.emmx"
                    className                 = "com.microsoft.emmx.Main"
                    offlineAppAccessEnabled   = $true
                    preSignInAppAccessEnabled = $false
                }
                MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapp{
                    package                   = "com.microsoft.teams"
                    className                 = "com.microsoft.teams.Main"
                    offlineAppAccessEnabled   = $false
                    preSignInAppAccessEnabled = $true
                }
            )
            KioskModeManagedHomeScreenAutoSignout                    = $true
            KioskModeManagedHomeScreenInactiveSignOutDelayInSeconds  = 60
            KioskModeManagedHomeScreenInactiveSignOutNoticeInSeconds = 30
            KioskModeManagedHomeScreenPinComplexity                  = "complex"
            KioskModeManagedHomeScreenPinRequired                    = $true
            KioskModeManagedHomeScreenPinRequiredToResume            = $true
            KioskModeManagedHomeScreenSignInBackground               = "https://cdn.contoso.com/branding/kiosk-signin-background.png"
            KioskModeManagedHomeScreenSignInBrandingLogo             = "https://cdn.contoso.com/branding/contoso-logo.png"
            KioskModeManagedHomeScreenSignInEnabled                  = $true
            KioskModeManagedSettingsEntryDisabled                    = $true
            KioskModeMediaVolumeConfigurationEnabled                 = $true
            KioskModeScreenOrientation                               = "landscape"
            KioskModeScreenSaverConfigurationEnabled                 = $true
            KioskModeScreenSaverDetectMediaDisabled                  = $false
            KioskModeScreenSaverDisplayTimeInSeconds                 = 120
            KioskModeScreenSaverImageUrl                             = "https://cdn.contoso.com/branding/kiosk-screensaver.png"
            KioskModeScreenSaverStartDelayInSeconds                  = 300
            KioskModeShowAppNotificationBadge                        = $true
            KioskModeShowDeviceInfo                                  = $true
            KioskModeUseManagedHomeScreenApp                         = "multiAppMode"
            KioskModeVirtualHomeButtonEnabled                        = $true
            KioskModeVirtualHomeButtonType                           = "swipeUp"
            KioskModeWallpaperUrl                                    = "https://cdn.contoso.com/branding/kiosk-wallpaper.png"
            KioskModeWiFiConfigurationEnabled                        = $true
            KioskModeWifiAllowedSsids                                = @("Contoso-Retail", "Contoso-BackOffice")
            LocateDeviceLostModeEnabled                              = $true
            LocateDeviceUserlessDisabled                             = $false
            MicrophoneForceMute                                      = $true
            MicrosoftLauncherConfigurationEnabled                    = $true
            MicrosoftLauncherCustomWallpaperAllowUserModification    = $false
            MicrosoftLauncherCustomWallpaperEnabled                  = $true
            MicrosoftLauncherCustomWallpaperImageUrl                 = "https://cdn.contoso.com/branding/launcher-wallpaper.png"
            MicrosoftLauncherDockPresenceAllowUserModification       = $false
            MicrosoftLauncherDockPresenceConfiguration               = "show"
            MicrosoftLauncherFeedAllowUserModification               = $false
            MicrosoftLauncherFeedEnabled                             = $true
            MicrosoftLauncherSearchBarPlacementConfiguration         = "top"
            NetworkEscapeHatchAllowed                                = $true
            NfcBlockOutgoingBeam                                     = $true
            PasswordBlockKeyguard                                    = $false
            PasswordBlockKeyguardFeatures                            = @("camera", "unredactedNotifications")
            PasswordExpirationDays                                   = 90
            PasswordMinimumLength                                    = 8
            PasswordMinimumLetterCharacters                          = 2
            PasswordMinimumLowerCaseCharacters                       = 1
            PasswordMinimumNonLetterCharacters                       = 2
            PasswordMinimumNumericCharacters                         = 1
            PasswordMinimumSymbolCharacters                          = 1
            PasswordMinimumUpperCaseCharacters                       = 1
            PasswordMinutesOfInactivityBeforeScreenTimeout           = 5
            PasswordPreviousPasswordCountToBlock                     = 5
            PasswordRequiredType                                     = "customPassword"
            PasswordRequireUnlock                                    = "daily"
            PasswordSignInFailureCountBeforeFactoryReset             = 10
            PersonalProfileAppsAllowInstallFromUnknownSources        = $false
            PersonalProfileCameraBlocked                             = $true
            PersonalProfilePersonalApplications                      = @(
                MSFT_MicrosoftGraphapplistitem{
                    appId       = "com.spotify.music"
                    name        = "Spotify"
                    publisher   = "Spotify AB"
                    appStoreUrl = "https://play.google.com/store/apps/details?id=com.spotify.music"
                }
            )
            PersonalProfilePlayStoreMode                             = "blockedApps"
            PersonalProfileScreenCaptureBlocked                      = $true
            PlayStoreMode                                            = "allowList"
            ScreenCaptureBlocked                                     = $true
            SecurityCommonCriteriaModeEnabled                        = $false
            SecurityDeveloperSettingsEnabled                         = $false
            SecurityRequireVerifyApps                                = $true
            ShareDeviceLocationDisabled                              = $true
            ShortHelpText                                            = MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage{
                defaultMessage    = "Managed by Contoso IT."
                localizedMessages = @(
                    MSFT_MicrosoftGraphkeyvaluepair{
                        Name  = "en-us"
                        Value = "Managed by Contoso IT."
                    }
                )
            }
            StatusBarBlocked                                         = $false
            StayOnModes                                              = @("ac", "usb")
            StorageAllowUsb                                          = $false
            StorageBlockExternalMedia                                = $true
            StorageBlockUsbFileTransfer                              = $true
            SystemUpdateFreezePeriods                                = @(
                MSFT_MicrosoftGraphandroiddeviceownersystemupdatefreezeperiod{
                    startMonth = 12
                    startDay   = 23
                    endMonth   = 12
                    endDay     = 30
                }
            )
            SystemUpdateInstallType                                  = "windowed"
            SystemUpdateWindowStartMinutesAfterMidnight              = 120
            SystemUpdateWindowEndMinutesAfterMidnight                = 300
            SystemWindowsBlocked                                     = $true
            UsersBlockAdd                                            = $true
            UsersBlockRemove                                         = $true
            VolumeBlockAdjustment                                    = $false
            VpnAlwaysOnLockdownMode                                  = $false
            VpnAlwaysOnPackageIdentifier                             = "com.microsoft.scmx"
            WifiBlockEditConfigurations                              = $true
            WifiBlockEditPolicyDefinedConfigurations                 = $true
            WorkProfilePasswordExpirationDays                        = 90
            WorkProfilePasswordMinimumLength                         = 8
            WorkProfilePasswordMinimumLetterCharacters               = 2
            WorkProfilePasswordMinimumLowerCaseCharacters            = 1
            WorkProfilePasswordMinimumNonLetterCharacters            = 2
            WorkProfilePasswordMinimumNumericCharacters              = 1
            WorkProfilePasswordMinimumSymbolCharacters               = 1
            WorkProfilePasswordMinimumUpperCaseCharacters            = 1
            WorkProfilePasswordPreviousPasswordCountToBlock          = 5
            WorkProfilePasswordRequiredType                          = "customPassword"
            WorkProfilePasswordRequireUnlock                         = "daily"
            WorkProfilePasswordSignInFailureCountBeforeFactoryReset  = 10
            Assignments                                              = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
            )
            Ensure                                                   = "Present"
            ApplicationId                                            = $ApplicationId;
            TenantId                                                 = $TenantId;
            CertificateThumbprint                                    = $CertificateThumbprint;
        }
    }
}
