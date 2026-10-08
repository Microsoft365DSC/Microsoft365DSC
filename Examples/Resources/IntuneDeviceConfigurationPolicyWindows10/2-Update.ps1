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
        IntuneDeviceConfigurationPolicyWindows10 'IntuneDeviceConfigurationPolicyWindows10-Example'
        {
            AccountsBlockAddingNonMicrosoftAccountEmail          = $False;
            ActivateAppsWithVoice                                = "notConfigured";
            AntiTheftModeBlocked                                 = $True; # Updated Property
            AppManagementMSIAllowUserControlOverInstall          = $False;
            AppManagementMSIAlwaysInstallWithElevatedPrivileges  = $False;
            AppManagementPackageFamilyNamesToLaunchAfterLogOn    = @();
            AppsAllowTrustedAppsSideloading                      = "notConfigured";
            AppsBlockWindowsStoreOriginatedApps                  = $False;
            Assignments                                          = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            AuthenticationAllowSecondaryDevice                   = $False;
            AuthenticationWebSignIn                              = "notConfigured";
            BluetoothAllowedServices                             = @();
            BluetoothBlockAdvertising                            = $True;
            BluetoothBlockDiscoverableMode                       = $False;
            BluetoothBlocked                                     = $True;
            BluetoothBlockPrePairing                             = $True;
            BluetoothBlockPromptedProximalConnections            = $False;
            CameraBlocked                                        = $False;
            CellularBlockDataWhenRoaming                         = $False;
            CellularBlockVpn                                     = $True;
            CellularBlockVpnWhenRoaming                          = $True;
            CellularData                                         = "allowed";
            CertificatesBlockManualRootCertificateInstallation   = $False;
            ConnectedDevicesServiceBlocked                       = $False;
            CopyPasteBlocked                                     = $False;
            CortanaBlocked                                       = $False;
            CryptographyAllowFipsAlgorithmPolicy                 = $False;
            DefenderBlockEndUserAccess                           = $False;
            DefenderBlockOnAccessProtection                      = $False;
            DefenderCloudBlockLevel                              = "notConfigured";
            DefenderDisableCatchupFullScan                       = $False;
            DefenderDisableCatchupQuickScan                      = $False;
            DefenderFileExtensionsToExclude                      = @();
            DefenderFilesAndFoldersToExclude                     = @();
            DefenderMonitorFileActivity                          = "userDefined";
            DefenderPotentiallyUnwantedAppActionSetting          = "userDefined";
            DefenderProcessesToExclude                           = @();
            DefenderPromptForSampleSubmission                    = "userDefined";
            DefenderRequireBehaviorMonitoring                    = $False;
            DefenderRequireCloudProtection                       = $False;
            DefenderRequireNetworkInspectionSystem               = $False;
            DefenderRequireRealTimeMonitoring                    = $False;
            DefenderScanArchiveFiles                             = $False;
            DefenderScanDownloads                                = $False;
            DefenderScanIncomingMail                             = $False;
            DefenderScanMappedNetworkDrivesDuringFullScan        = $False;
            DefenderScanNetworkFiles                             = $False;
            DefenderScanRemovableDrivesDuringFullScan            = $False;
            DefenderScanScriptsLoadedInInternetExplorer          = $False;
            DefenderScanType                                     = "userDefined";
            DefenderScheduleScanEnableLowCpuPriority             = $False;
            DefenderSystemScanSchedule                           = "userDefined";
            DeveloperUnlockSetting                               = "notConfigured";
            DeviceManagementApplicabilityRuleDeviceMode          = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = 'S mode devices only'
                DeviceMode = 'sModeConfiguration'
                RuleType   = 'include'
            };
            DeviceManagementApplicabilityRuleOsEdition           = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = 'Enterprise and Professional editions only'
                OsEditionTypes = @('windows10Enterprise', 'windows10Professional')
                RuleType       = 'include'
            };
            DeviceManagementApplicabilityRuleOsVersion           = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = 'Windows 11 23H2 and later'
                MinOSVersion = '10.0.22631.0'
                MaxOSVersion = '10.0.26200.9999'
                RuleType     = 'include'
            };
            DeviceManagementBlockFactoryResetOnMobile            = $False;
            DeviceManagementBlockManualUnenroll                  = $False;
            DiagnosticsDataSubmissionMode                        = "userDefined";
            DisplayAppListWithGdiDPIScalingTurnedOff             = @();
            DisplayAppListWithGdiDPIScalingTurnedOn              = @();
            DisplayName                                          = "device config";
            EdgeAllowStartPagesModification                      = $False;
            EdgeBlockAccessToAboutFlags                          = $False;
            EdgeBlockAddressBarDropdown                          = $False;
            EdgeBlockAutofill                                    = $False;
            EdgeBlockCompatibilityList                           = $False;
            EdgeBlockDeveloperTools                              = $False;
            EdgeBlocked                                          = $False;
            EdgeBlockEditFavorites                               = $False;
            EdgeBlockExtensions                                  = $False;
            EdgeBlockFullScreenMode                              = $False;
            EdgeBlockInPrivateBrowsing                           = $False;
            EdgeBlockJavaScript                                  = $False;
            EdgeBlockLiveTileDataCollection                      = $False;
            EdgeBlockPasswordManager                             = $False;
            EdgeBlockPopups                                      = $False;
            EdgeBlockPrelaunch                                   = $False;
            EdgeBlockPrinting                                    = $False;
            EdgeBlockSavingHistory                               = $False;
            EdgeBlockSearchEngineCustomization                   = $False;
            EdgeBlockSearchSuggestions                           = $False;
            EdgeBlockSendingDoNotTrackHeader                     = $False;
            EdgeBlockSendingIntranetTrafficToInternetExplorer    = $False;
            EdgeBlockSideloadingExtensions                       = $False;
            EdgeBlockTabPreloading                               = $False;
            EdgeBlockWebContentOnNewTabPage                      = $False;
            EdgeClearBrowsingDataOnExit                          = $False;
            EdgeCookiePolicy                                     = "userDefined";
            EdgeDisableFirstRunPage                              = $False;
            EdgeFavoritesBarVisibility                           = "notConfigured";
            EdgeHomeButtonConfigurationEnabled                   = $False;
            EdgeHomepageUrls                                     = @();
            EdgeKioskModeRestriction                             = "notConfigured";
            EdgeOpensWith                                        = "notConfigured";
            EdgePreventCertificateErrorOverride                  = $False;
            EdgeRequiredExtensionPackageFamilyNames              = @();
            EdgeRequireSmartScreen                               = $False;
            EdgeSendIntranetTrafficToInternetExplorer            = $False;
            EdgeShowMessageWhenOpeningInternetExplorerSites      = "notConfigured";
            EdgeSyncFavoritesWithInternetExplorer                = $False;
            EdgeTelemetryForMicrosoft365Analytics                = "notConfigured";
            EnableAutomaticRedeployment                          = $False;
            Ensure                                               = "Present";
            ExperienceBlockDeviceDiscovery                       = $False;
            ExperienceBlockErrorDialogWhenNoSIM                  = $False;
            ExperienceBlockTaskSwitcher                          = $False;
            ExperienceDoNotSyncBrowserSettings                   = "notConfigured";
            FindMyFiles                                          = "notConfigured";
            GameDvrBlocked                                       = $True;
            InkWorkspaceAccess                                   = "notConfigured";
            InkWorkspaceAccessState                              = "notConfigured";
            InkWorkspaceBlockSuggestedApps                       = $False;
            InternetSharingBlocked                               = $False;
            LocationServicesBlocked                              = $False;
            LockScreenActivateAppsWithVoice                      = "notConfigured";
            LockScreenAllowTimeoutConfiguration                  = $False;
            LockScreenBlockActionCenterNotifications             = $False;
            LockScreenBlockCortana                               = $False;
            LockScreenBlockToastNotifications                    = $False;
            LogonBlockFastUserSwitching                          = $False;
            MessagingBlockMMS                                    = $False;
            MessagingBlockRichCommunicationServices              = $False;
            MessagingBlockSync                                   = $False;
            MicrosoftAccountBlocked                              = $False;
            MicrosoftAccountBlockSettingsSync                    = $False;
            MicrosoftAccountSignInAssistantSettings              = "notConfigured";
            NetworkProxyApplySettingsDeviceWide                  = $False;
            NetworkProxyDisableAutoDetect                        = $True;
            NetworkProxyServer                                   = MSFT_MicrosoftGraphwindows10NetworkProxyServer{
                UseForLocalAddresses = $True
                Exceptions           = @('*.domain2.com')
                Address              = 'proxy.domain.com:8080'
            };
            NfcBlocked                                           = $False;
            OneDriveDisableFileSync                              = $False;
            PasswordBlockSimple                                  = $False;
            PasswordRequired                                     = $False;
            PasswordRequiredType                                 = "deviceDefault";
            PasswordRequireWhenResumeFromIdleState               = $False;
            PowerButtonActionOnBattery                           = "notConfigured";
            PowerButtonActionPluggedIn                           = "notConfigured";
            PowerHybridSleepOnBattery                            = "notConfigured";
            PowerHybridSleepPluggedIn                            = "notConfigured";
            PowerLidCloseActionOnBattery                         = "notConfigured";
            PowerLidCloseActionPluggedIn                         = "notConfigured";
            PowerSleepButtonActionOnBattery                      = "notConfigured";
            PowerSleepButtonActionPluggedIn                      = "notConfigured";
            PrinterBlockAddition                                 = $False;
            PrinterNames                                         = @();
            PrivacyAdvertisingId                                 = "notConfigured";
            PrivacyAutoAcceptPairingAndConsentPrompts            = $False;
            PrivacyBlockActivityFeed                             = $False;
            PrivacyBlockInputPersonalization                     = $False;
            PrivacyBlockPublishUserActivities                    = $False;
            PrivacyDisableLaunchExperience                       = $False;
            ResetProtectionModeBlocked                           = $False;
            SafeSearchFilter                                     = "userDefined";
            ScreenCaptureBlocked                                 = $False;
            SearchBlockDiacritics                                = $False;
            SearchBlockWebResults                                = $False;
            SearchDisableAutoLanguageDetection                   = $False;
            SearchDisableIndexerBackoff                          = $False;
            SearchDisableIndexingEncryptedItems                  = $False;
            SearchDisableIndexingRemovableDrive                  = $False;
            SearchDisableLocation                                = $False;
            SearchDisableUseLocation                             = $False;
            SearchEnableAutomaticIndexSizeManangement            = $False;
            SearchEnableRemoteQueries                            = $False;
            SecurityBlockAzureADJoinedDevicesAutoEncryption      = $False;
            SettingsBlockAccountsPage                            = $False;
            SettingsBlockAddProvisioningPackage                  = $False;
            SettingsBlockAppsPage                                = $False;
            SettingsBlockChangeLanguage                          = $False;
            SettingsBlockChangePowerSleep                        = $False;
            SettingsBlockChangeRegion                            = $False;
            SettingsBlockChangeSystemTime                        = $False;
            SettingsBlockDevicesPage                             = $False;
            SettingsBlockEaseOfAccessPage                        = $False;
            SettingsBlockEditDeviceName                          = $False;
            SettingsBlockGamingPage                              = $False;
            SettingsBlockNetworkInternetPage                     = $False;
            SettingsBlockPersonalizationPage                     = $False;
            SettingsBlockPrivacyPage                             = $False;
            SettingsBlockRemoveProvisioningPackage               = $False;
            SettingsBlockSettingsApp                             = $False;
            SettingsBlockSystemPage                              = $False;
            SettingsBlockTimeLanguagePage                        = $False;
            SettingsBlockUpdateSecurityPage                      = $False;
            SharedUserAppDataAllowed                             = $False;
            SmartScreenAppInstallControl                         = "notConfigured";
            SmartScreenBlockPromptOverride                       = $False;
            SmartScreenBlockPromptOverrideForFiles               = $False;
            SmartScreenEnableAppInstallControl                   = $False;
            StartBlockUnpinningAppsFromTaskbar                   = $False;
            StartMenuAppListVisibility                           = "userDefined";
            StartMenuHideChangeAccountSettings                   = $False;
            StartMenuHideFrequentlyUsedApps                      = $False;
            StartMenuHideHibernate                               = $False;
            StartMenuHideLock                                    = $False;
            StartMenuHidePowerButton                             = $False;
            StartMenuHideRecentJumpLists                         = $False;
            StartMenuHideRecentlyAddedApps                       = $False;
            StartMenuHideRestartOptions                          = $False;
            StartMenuHideShutDown                                = $False;
            StartMenuHideSignOut                                 = $False;
            StartMenuHideSleep                                   = $False;
            StartMenuHideSwitchAccount                           = $False;
            StartMenuHideUserTile                                = $False;
            StartMenuMode                                        = "userDefined";
            StartMenuPinnedFolderDocuments                       = "notConfigured";
            StartMenuPinnedFolderDownloads                       = "notConfigured";
            StartMenuPinnedFolderFileExplorer                    = "notConfigured";
            StartMenuPinnedFolderHomeGroup                       = "notConfigured";
            StartMenuPinnedFolderMusic                           = "notConfigured";
            StartMenuPinnedFolderNetwork                         = "notConfigured";
            StartMenuPinnedFolderPersonalFolder                  = "notConfigured";
            StartMenuPinnedFolderPictures                        = "notConfigured";
            StartMenuPinnedFolderSettings                        = "notConfigured";
            StartMenuPinnedFolderVideos                          = "notConfigured";
            StorageBlockRemovableStorage                         = $False;
            StorageRequireMobileDeviceEncryption                 = $False;
            StorageRestrictAppDataToSystemVolume                 = $False;
            StorageRestrictAppInstallToSystemVolume              = $False;
            TaskManagerBlockEndTask                              = $False;
            TenantLockdownRequireNetworkDuringOutOfBoxExperience = $False;
            UninstallBuiltInApps                                 = $False;
            UsbBlocked                                           = $False;
            VoiceRecordingBlocked                                = $False;
            WebRtcBlockLocalhostIpAddress                        = $False;
            WiFiBlockAutomaticConnectHotspots                    = $False;
            WiFiBlocked                                          = $True;
            WiFiBlockManualConfiguration                         = $True;
            WindowsSpotlightBlockConsumerSpecificFeatures        = $False;
            WindowsSpotlightBlocked                              = $False;
            WindowsSpotlightBlockOnActionCenter                  = $False;
            WindowsSpotlightBlockTailoredExperiences             = $False;
            WindowsSpotlightBlockThirdPartyNotifications         = $False;
            WindowsSpotlightBlockWelcomeExperience               = $False;
            WindowsSpotlightBlockWindowsTips                     = $False;
            WindowsSpotlightConfigureOnLockScreen                = "notConfigured";
            WindowsStoreBlockAutoUpdate                          = $False;
            WindowsStoreBlocked                                  = $False;
            WindowsStoreEnablePrivateStoreOnly                   = $False;
            WirelessDisplayBlockProjectionToThisDevice           = $False;
            WirelessDisplayBlockUserInputFromReceiver            = $False;
            WirelessDisplayRequirePinForPairing                  = $False;
            ApplicationId                                        = $ApplicationId;
            TenantId                                             = $TenantId;
            CertificateThumbprint                                = $CertificateThumbprint;
        }
    }
}
