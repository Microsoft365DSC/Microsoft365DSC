<#
This example creates a new Device Configuration Policy for iOS.
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
        IntuneDeviceConfigurationPolicyiOS 'IntuneDeviceConfigurationPolicyiOS-Example'
        {
            DisplayName                                    = 'iOS Device Restrictions'
            Description                                    = "Device restrictions for corporate iPhones and iPads"
            RoleScopeTagIds                                = @("0")
            AccountBlockModification                       = $true
            ActivationLockAllowWhenSupervised              = $true
            AirDropBlocked                                 = $true # Updated Property
            AirDropForceUnmanagedDropTarget                = $true
            AirPlayForcePairingPasswordForOutgoingRequests = $true
            AirPrintBlockCredentialsStorage                = $true
            AirPrintBlocked                                = $false
            AirPrintBlockiBeaconDiscovery                  = $true
            AirPrintForceTrustedTLS                        = $true
            AppClipsBlocked                                = $true
            AppleNewsBlocked                               = $true
            ApplePersonalizedAdsBlocked                    = $true
            AppleWatchBlockPairing                         = $false
            AppleWatchForceWristDetection                  = $true
            AppRemovalBlocked                              = $true
            AppsSingleAppModeList                          = @(
                MSFT_MicrosoftGraphapplistitem{
                    odataType   = "#microsoft.graph.appleAppListItem"
                    appId       = "com.microsoft.msedge"
                    name        = "Microsoft Edge"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://apps.apple.com/us/app/microsoft-edge/id1288723196"
                }
            )
            AppStoreBlockAutomaticDownloads                = $false
            AppStoreBlocked                                = $false
            AppStoreBlockInAppPurchases                    = $true
            AppStoreBlockUIAppInstallation                 = $false
            AppStoreRequirePassword                        = $true
            AppsVisibilityList                             = @(
                MSFT_MicrosoftGraphapplistitem{
                    odataType   = "#microsoft.graph.appleAppListItem"
                    appId       = "com.microsoft.skype.teams"
                    name        = "Microsoft Teams"
                    publisher   = "Microsoft Corporation"
                    appStoreUrl = "https://apps.apple.com/us/app/microsoft-teams/id1113153706"
                }
            )
            AppsVisibilityListType                         = "appsInListCompliant"
            AutoFillForceAuthentication                    = $true
            AutoUnlockBlocked                              = $false
            BlockSystemAppRemoval                          = $true
            BluetoothBlockModification                     = $true
            CameraBlocked                                  = $false
            CellularBlockDataRoaming                       = $true
            CellularBlockGlobalBackgroundFetchWhileRoaming = $true
            CellularBlockPerAppDataModification            = $true
            CellularBlockPersonalHotspot                   = $false
            CellularBlockPersonalHotspotModification       = $true
            CellularBlockPlanModification                  = $true
            CellularBlockVoiceRoaming                      = $true
            CertificatesBlockUntrustedTlsCertificates      = $true
            ClassroomAppBlockRemoteScreenObservation       = $false
            ClassroomAppForceUnpromptedScreenObservation   = $false
            ClassroomForceAutomaticallyJoinClasses         = $false
            ClassroomForceRequestPermissionToLeaveClasses  = $false
            ClassroomForceUnpromptedAppAndDeviceLock       = $false
            CompliantAppListType                           = "appsNotInListCompliant"
            CompliantAppsList                              = @(
                MSFT_MicrosoftGraphapplistitem{
                    odataType   = "#microsoft.graph.appleAppListItem"
                    appId       = "com.zhiliaoapp.musically"
                    name        = "TikTok"
                    publisher   = "TikTok Ltd."
                    appStoreUrl = "https://apps.apple.com/us/app/tiktok/id835599320"
                }
            )
            ConfigurationProfileBlockChanges               = $true
            ContactsAllowManagedToUnmanagedWrite           = $false
            ContactsAllowUnmanagedToManagedRead            = $false
            ContinuousPathKeyboardBlocked                  = $false
            DateAndTimeForceSetAutomatically               = $true
            DefinitionLookupBlocked                        = $false
            DeviceBlockEnableRestrictions                  = $true
            DeviceBlockEraseContentAndSettings             = $true
            DeviceBlockNameModification                    = $true
            DiagnosticDataBlockSubmission                  = $true
            DiagnosticDataBlockSubmissionModification      = $true
            DocumentsBlockManagedDocumentsInUnmanagedApps  = $true
            DocumentsBlockUnmanagedDocumentsInManagedApps  = $true
            EmailInDomainSuffixes                          = @("contoso.com", "mail.contoso.com")
            EnterpriseAppBlockTrust                        = $false
            EnterpriseAppBlockTrustModification            = $true
            EnterpriseBookBlockBackup                      = $true
            EnterpriseBookBlockMetadataSync                = $true
            EsimBlockModification                          = $true
            FaceTimeBlocked                                = $false
            FilesNetworkDriveAccessBlocked                 = $true
            FilesUsbDriveAccessBlocked                     = $true
            FindMyDeviceInFindMyAppBlocked                 = $false
            FindMyFriendsBlocked                           = $true
            FindMyFriendsInFindMyAppBlocked                = $true
            GameCenterBlocked                              = $true
            GamingBlockGameCenterFriends                   = $true
            GamingBlockMultiplayer                         = $true
            HostPairingBlocked                             = $true
            IBooksStoreBlocked                             = $false
            IBooksStoreBlockErotica                        = $true
            ICloudBlockActivityContinuation                = $true
            ICloudBlockBackup                              = $true
            ICloudBlockDocumentSync                        = $true
            ICloudBlockManagedAppsSync                     = $true
            ICloudBlockPhotoLibrary                        = $true
            ICloudBlockPhotoStreamSync                     = $true
            ICloudBlockSharedPhotoStream                   = $true
            ICloudPrivateRelayBlocked                      = $true
            ICloudRequireEncryptedBackup                   = $true
            ITunesBlocked                                  = $false
            ITunesBlockExplicitContent                     = $true
            ITunesBlockMusicService                        = $true
            ITunesBlockRadio                               = $true
            KeyboardBlockAutoCorrect                       = $false
            KeyboardBlockDictation                         = $true
            KeyboardBlockPredictive                        = $false
            KeyboardBlockShortcuts                         = $false
            KeyboardBlockSpellCheck                        = $false
            KeychainBlockCloudSync                         = $true
            KioskModeAllowAssistiveSpeak                   = $true
            KioskModeAllowAssistiveTouchSettings           = $true
            KioskModeAllowAutoLock                         = $true
            KioskModeAllowColorInversionSettings           = $true
            KioskModeAllowRingerSwitch                     = $true
            KioskModeAllowScreenRotation                   = $true
            KioskModeAllowSleepButton                      = $true
            KioskModeAllowTouchscreen                      = $true
            KioskModeAllowVoiceControlModification         = $true
            KioskModeAllowVoiceOverSettings                = $true
            KioskModeAllowVolumeButtons                    = $true
            KioskModeAllowZoomSettings                     = $true
            KioskModeAppStoreUrl                           = "https://apps.apple.com/us/app/microsoft-edge/id1288723196"
            KioskModeAppType                               = "appStoreApp"
            KioskModeBlockAutoLock                         = $false
            KioskModeBlockRingerSwitch                     = $false
            KioskModeBlockScreenRotation                   = $false
            KioskModeBlockSleepButton                      = $false
            KioskModeBlockTouchscreen                      = $false
            KioskModeBlockVolumeButtons                    = $false
            KioskModeEnableVoiceControl                    = $true
            KioskModeRequireAssistiveTouch                 = $false
            KioskModeRequireColorInversion                 = $false
            KioskModeRequireMonoAudio                      = $false
            KioskModeRequireVoiceOver                      = $false
            KioskModeRequireZoom                           = $false
            LockScreenBlockControlCenter                   = $true
            LockScreenBlockNotificationView                = $true
            LockScreenBlockPassbook                        = $true
            LockScreenBlockTodayView                       = $true
            ManagedPasteboardRequired                      = $true
            MediaContentRatingApps                         = "agesAbove17"
            MediaContentRatingAustralia                    = MSFT_MicrosoftGraphmediacontentratingaustralia{
                movieRating = "mature"
                tvRating    = "mature"
            }
            MediaContentRatingCanada                       = MSFT_MicrosoftGraphmediacontentratingcanada{
                movieRating = "agesAbove14"
                tvRating    = "agesAbove14"
            }
            MediaContentRatingFrance                       = MSFT_MicrosoftGraphmediacontentratingfrance{
                movieRating = "agesAbove12"
                tvRating    = "agesAbove12"
            }
            MediaContentRatingGermany                      = MSFT_MicrosoftGraphmediacontentratinggermany{
                movieRating = "agesAbove12"
                tvRating    = "agesAbove12"
            }
            MediaContentRatingIreland                      = MSFT_MicrosoftGraphmediacontentratingireland{
                movieRating = "agesAbove12"
                tvRating    = "youngAdults"
            }
            MediaContentRatingJapan                        = MSFT_MicrosoftGraphmediacontentratingjapan{
                movieRating = "agesAbove15"
                tvRating    = "explicitAllowed"
            }
            MediaContentRatingNewZealand                   = MSFT_MicrosoftGraphmediacontentratingnewzealand{
                movieRating = "agesAbove13"
                tvRating    = "parentalGuidance"
            }
            MediaContentRatingUnitedKingdom                = MSFT_MicrosoftGraphmediacontentratingunitedkingdom{
                movieRating = "agesAbove12Video"
                tvRating    = "caution"
            }
            MediaContentRatingUnitedStates                 = MSFT_MicrosoftGraphmediacontentratingunitedstates{
                movieRating = "parentalGuidance13"
                tvRating    = "childrenAbove14"
            }
            MessagesBlocked                                = $false
            NetworkUsageRules                              = @(
                MSFT_MicrosoftGraphiosnetworkusagerule{
                    cellularDataBlocked          = $false
                    cellularDataBlockWhenRoaming = $true
                    managedApps                  = @(
                        MSFT_MicrosoftGraphapplistitem{
                            odataType   = "#microsoft.graph.appleAppListItem"
                            appId       = "com.microsoft.officemobile"
                            name        = "Microsoft 365 Copilot"
                            publisher   = "Microsoft Corporation"
                            appStoreUrl = "https://apps.apple.com/us/app/microsoft-365-copilot/id541164041"
                        }
                    )
                }
            )
            NfcBlocked                                     = $false
            NotificationsBlockSettingsModification         = $true
            OnDeviceOnlyDictationForced                    = $true
            OnDeviceOnlyTranslationForced                  = $true
            PasscodeBlockFingerprintModification           = $true
            PasscodeBlockFingerprintUnlock                 = $false
            PasscodeBlockModification                      = $true
            PasscodeBlockSimple                            = $true
            PasscodeExpirationDays                         = 365
            PasscodeMinimumCharacterSetCount               = 2
            PasscodeMinimumLength                          = 6
            PasscodeMinutesOfInactivityBeforeLock          = 1
            PasscodeMinutesOfInactivityBeforeScreenTimeout = 5
            PasscodePreviousPasscodeBlockCount             = 5
            PasscodeRequired                               = $true
            PasscodeRequiredType                           = "alphanumeric"
            PasscodeSignInFailureCountBeforeWipe           = 10
            PasswordBlockAirDropSharing                    = $true
            PasswordBlockAutoFill                          = $true
            PasswordBlockProximityRequests                 = $true
            PkiBlockOTAUpdates                             = $false
            PodcastsBlocked                                = $true
            PrivacyForceLimitAdTracking                    = $true
            ProximityBlockSetupToNewDevice                 = $true
            SafariBlockAutofill                            = $true
            SafariBlocked                                  = $false
            SafariBlockJavaScript                          = $false
            SafariBlockPopups                              = $true
            SafariCookieSettings                           = "allowFromWebsitesVisited"
            SafariManagedDomains                           = @("contoso.com", "intranet.contoso.com")
            SafariPasswordAutoFillDomains                  = @("portal.contoso.com")
            SafariRequireFraudWarning                      = $true
            ScreenCaptureBlocked                           = $true
            SharedDeviceBlockTemporarySessions             = $true
            SiriBlocked                                    = $false
            SiriBlockedWhenLocked                          = $true
            SiriBlockUserGeneratedContent                  = $true
            SiriRequireProfanityFilter                     = $true
            SoftwareUpdatesEnforcedDelayInDays             = 30
            SoftwareUpdatesForceDelayed                    = $true
            SpotlightBlockInternetResults                  = $true
            UnpairedExternalBootToRecoveryAllowed          = $false
            UsbRestrictedModeBlocked                       = $false
            VoiceDialingBlocked                            = $true
            VpnBlockCreation                               = $true
            WallpaperBlockModification                     = $true
            WiFiConnectOnlyToConfiguredNetworks            = $true
            WiFiConnectToAllowedNetworksOnlyForced         = $true
            WifiPowerOnForced                              = $true
            Assignments                                    = @(
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
            Ensure                                         = "Present"
            ApplicationId                                  = $ApplicationId;
            TenantId                                       = $TenantId;
            CertificateThumbprint                          = $CertificateThumbprint;
        }
    }
}
