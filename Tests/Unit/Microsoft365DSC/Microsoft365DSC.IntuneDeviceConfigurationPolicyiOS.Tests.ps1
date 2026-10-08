[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'IntuneDeviceConfigurationPolicyiOS' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    FaceTimeBlocked                                = $True
                    KioskModeAllowSleepButton                      = $True
                    MediaContentRatingCanada                       = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    UnpairedExternalBootToRecoveryAllowed          = $True
                    ICloudBlockPhotoStreamSync                     = $True
                    KeyboardBlockPredictive                        = $True
                    SafariBlockPopups                              = $True
                    GameCenterBlocked                              = $True
                    PasscodeBlockSimple                            = $True
                    ITunesBlocked                                  = $True
                    PasscodeMinimumCharacterSetCount               = 25
                    AppleWatchForceWristDetection                  = $True
                    PasscodeExpirationDays                         = 25
                    EnterpriseAppBlockTrustModification            = $True
                    AirPlayForcePairingPasswordForOutgoingRequests = $True
                    KeyboardBlockAutoCorrect                       = $True
                    ITunesBlockExplicitContent                     = $True
                    IBooksStoreBlockErotica                        = $True
                    KioskModeAllowRingerSwitch                     = $True
                    DocumentsBlockUnmanagedDocumentsInManagedApps  = $True
                    MessagesBlocked                                = $True
                    DeviceBlockEnableRestrictions                  = $True
                    AppStoreBlocked                                = $True
                    SpotlightBlockInternetResults                  = $True
                    KioskModeAppType                               = 'notConfigured'
                    KioskModeAllowVolumeButtons                    = $True
                    VoiceDialingBlocked                            = $True
                    PasscodeMinimumLength                          = 25
                    ICloudBlockSharedPhotoStream                   = $True
                    ActivationLockAllowWhenSupervised              = $True
                    CellularBlockVoiceRoaming                      = $True
                    MediaContentRatingIreland                      = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    PkiBlockOTAUpdates                             = $True
                    KeyboardBlockDictation                         = $True
                    PasscodeBlockModification                      = $True
                    AutoUnlockBlocked                              = $True
                    PasswordBlockProximityRequests                 = $True
                    MediaContentRatingAustralia                    = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    ITunesBlockMusicService                        = $True
                    DiagnosticDataBlockSubmissionModification      = $True
                    EnterpriseAppBlockTrust                        = $True
                    ManagedPasteboardRequired                      = $True
                    ProximityBlockSetupToNewDevice                 = $True
                    PasscodeMinutesOfInactivityBeforeScreenTimeout = 25
                    ITunesBlockRadio                               = $True
                    CellularBlockGlobalBackgroundFetchWhileRoaming = $True
                    SiriBlocked                                    = $True
                    MediaContentRatingJapan                        = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    FindMyFriendsInFindMyAppBlocked                = $True
                    CellularBlockPerAppDataModification            = $True
                    ClassroomForceAutomaticallyJoinClasses         = $True
                    SiriBlockUserGeneratedContent                  = $True
                    MediaContentRatingApps                         = 'allAllowed'
                    SafariCookieSettings                           = 'browserDefault'
                    DeviceBlockNameModification                    = $True
                    WifiPowerOnForced                              = $True
                    ContactsAllowManagedToUnmanagedWrite           = $True
                    AirPrintBlockCredentialsStorage                = $True
                    '@odata.type'                                  = '#microsoft.graph.iosGeneralDeviceConfiguration'
                    KioskModeAllowAssistiveTouchSettings           = $True
                    PasscodeRequiredType                           = 'deviceDefault'
                    PasscodePreviousPasscodeBlockCount             = 25
                    AutoFillForceAuthentication                    = $True
                    CompliantAppListType                           = 'none'
                    ICloudBlockBackup                              = $True
                    KioskModeAllowAutoLock                         = $True
                    LockScreenBlockControlCenter                   = $True
                    EsimBlockModification                          = $True
                    AppleNewsBlocked                               = $True
                    CellularBlockPersonalHotspot                   = $True
                    KioskModeBuiltInAppId                          = 'FakeStringValue'
                    AirPrintForceTrustedTLS                        = $True
                    CameraBlocked                                  = $True
                    SiriRequireProfanityFilter                     = $True
                    PasscodeBlockFingerprintUnlock                 = $True
                    DateAndTimeForceSetAutomatically               = $True
                    KioskModeAllowAssistiveSpeak                   = $True
                    AccountBlockModification                       = $True
                    BlockSystemAppRemoval                          = $True
                    DocumentsBlockManagedDocumentsInUnmanagedApps  = $True
                    FindMyFriendsBlocked                           = $True
                    ICloudBlockManagedAppsSync                     = $True
                    LockScreenBlockTodayView                       = $True
                    BluetoothBlockModification                     = $True
                    KioskModeManagedAppId                          = 'FakeStringValue'
                    SoftwareUpdatesForceDelayed                    = $True
                    ConfigurationProfileBlockChanges               = $True
                    WiFiConnectOnlyToConfiguredNetworks            = $True
                    MediaContentRatingNewZealand                   = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    KioskModeRequireMonoAudio                      = $True
                    AppStoreRequirePassword                        = $True
                    ICloudBlockDocumentSync                        = $True
                    CellularBlockDataRoaming                       = $True
                    ICloudRequireEncryptedBackup                   = $True
                    ApplePersonalizedAdsBlocked                    = $True
                    KioskModeBlockAutoLock                         = $True
                    ClassroomAppBlockRemoteScreenObservation       = $True
                    PasscodeBlockFingerprintModification           = $True
                    FindMyDeviceInFindMyAppBlocked                 = $True
                    IBooksStoreBlocked                             = $True
                    KioskModeRequireVoiceOver                      = $True
                    KioskModeAllowVoiceOverSettings                = $True
                    AirDropForceUnmanagedDropTarget                = $True
                    SafariBlockAutofill                            = $True
                    PasscodeSignInFailureCountBeforeWipe           = 25
                    ContinuousPathKeyboardBlocked                  = $True
                    KeychainBlockCloudSync                         = $True
                    VpnBlockCreation                               = $True
                    KioskModeAllowVoiceControlModification         = $True
                    MediaContentRatingUnitedStates                 = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    KioskModeBlockVolumeButtons                    = $True
                    HostPairingBlocked                             = $True
                    AppClipsBlocked                                = $True
                    PasscodeRequired                               = $True
                    AppStoreBlockInAppPurchases                    = $True
                    LockScreenBlockNotificationView                = $True
                    KioskModeBlockSleepButton                      = $True
                    OnDeviceOnlyDictationForced                    = $True
                    NetworkUsageRules                              = @(
                        @{
                            cellularDataBlocked          = $True
                            cellularDataBlockWhenRoaming = $True
                            managedApps                  = @(
                                @{
                                    appId = 'FakeStringValue'
                                    name  = 'FakeStringValue'
                                }
                            )
                        }
                    )
                    ICloudBlockActivityContinuation                = $True
                    SoftwareUpdatesEnforcedDelayInDays             = 25
                    AppsSingleAppModeList                          = @(
                        @{
                            name          = 'FakeStringValue'
                            appId         = 'FakeStringValue'
                            appStoreUrl   = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.appleAppListItem'
                            publisher     = 'FakeStringValue'
                        }
                    )
                    ICloudBlockPhotoLibrary                        = $True
                    PrivacyForceLimitAdTracking                    = $True
                    MediaContentRatingGermany                      = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    KeyboardBlockShortcuts                         = $True
                    OnDeviceOnlyTranslationForced                  = $True
                    FilesUsbDriveAccessBlocked                     = $True
                    AppStoreBlockAutomaticDownloads                = $True
                    KioskModeRequireColorInversion                 = $True
                    SharedDeviceBlockTemporarySessions             = $True
                    GamingBlockGameCenterFriends                   = $True
                    EnterpriseBookBlockBackup                      = $True
                    EnterpriseBookBlockMetadataSync                = $True
                    AirDropBlocked                                 = $True
                    KioskModeBlockRingerSwitch                     = $True
                    KioskModeEnableVoiceControl                    = $True
                    MediaContentRatingUnitedKingdom                = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    CellularBlockPlanModification                  = $True
                    AirPrintBlocked                                = $True
                    KioskModeAllowZoomSettings                     = $True
                    AppRemovalBlocked                              = $True
                    ICloudPrivateRelayBlocked                      = $True
                    PodcastsBlocked                                = $True
                    WallpaperBlockModification                     = $True
                    ClassroomForceRequestPermissionToLeaveClasses  = $True
                    AppsVisibilityList                             = @(
                        @{
                            name          = 'FakeStringValue'
                            appId         = 'FakeStringValue'
                            appStoreUrl   = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.appleAppListItem'
                            publisher     = 'FakeStringValue'
                        }
                    )
                    SiriBlockedWhenLocked                          = $True
                    MediaContentRatingFrance                       = @{
                        movieRating = 'allAllowed'
                        tvRating    = 'allAllowed'
                    }
                    DefinitionLookupBlocked                        = $True
                    SafariBlockJavaScript                          = $True
                    AppsVisibilityListType                         = 'none'
                    AppleWatchBlockPairing                         = $True
                    KioskModeAppStoreUrl                           = 'FakeStringValue'
                    NfcBlocked                                     = $True
                    LockScreenBlockPassbook                        = $True
                    PasswordBlockAutoFill                          = $True
                    CompliantAppsList                              = @(
                        @{
                            name          = 'FakeStringValue'
                            appId         = 'FakeStringValue'
                            appStoreUrl   = 'FakeStringValue'
                            '@odata.type' = '#microsoft.graph.appleAppListItem'
                            publisher     = 'FakeStringValue'
                        }
                    )
                    AirPrintBlockiBeaconDiscovery                  = $True
                    ScreenCaptureBlocked                           = $True
                    KioskModeAllowTouchscreen                      = $True
                    ContactsAllowUnmanagedToManagedRead            = $True
                    KioskModeBlockTouchscreen                      = $True
                    UsbRestrictedModeBlocked                       = $True
                    DeviceBlockEraseContentAndSettings             = $True
                    PasswordBlockAirDropSharing                    = $True
                    CellularBlockPersonalHotspotModification       = $True
                    NotificationsBlockSettingsModification         = $True
                    SafariBlocked                                  = $True
                    CertificatesBlockUntrustedTlsCertificates      = $True
                    FilesNetworkDriveAccessBlocked                 = $True
                    KeyboardBlockSpellCheck                        = $True
                    ClassroomAppForceUnpromptedScreenObservation   = $True
                    ClassroomForceUnpromptedAppAndDeviceLock       = $True
                    KioskModeAllowScreenRotation                   = $True
                    KioskModeAllowColorInversionSettings           = $True
                    PasscodeMinutesOfInactivityBeforeLock          = 25
                    DiagnosticDataBlockSubmission                  = $True
                    GamingBlockMultiplayer                         = $True
                    SafariRequireFraudWarning                      = $True
                    KioskModeRequireAssistiveTouch                 = $True
                    AppStoreBlockUIAppInstallation                 = $True
                    KioskModeBlockScreenRotation                   = $True
                    WiFiConnectToAllowedNetworksOnlyForced         = $True
                    KioskModeRequireZoom                           = $True
                    Description          = 'FakeStringValue'
                    DisplayName          = 'FakeStringValue'
                    Id                   = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
                return @()
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The IntuneDeviceConfigurationPolicyiOS should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountBlockModification                       = $True
                    ActivationLockAllowWhenSupervised              = $True
                    AirDropBlocked                                 = $True
                    AirDropForceUnmanagedDropTarget                = $True
                    AirPlayForcePairingPasswordForOutgoingRequests = $True
                    AirPrintBlockCredentialsStorage                = $True
                    AirPrintBlocked                                = $True
                    AirPrintBlockiBeaconDiscovery                  = $True
                    AirPrintForceTrustedTLS                        = $True
                    AppClipsBlocked                                = $True
                    AppleNewsBlocked                               = $True
                    ApplePersonalizedAdsBlocked                    = $True
                    AppleWatchBlockPairing                         = $True
                    AppleWatchForceWristDetection                  = $True
                    AppRemovalBlocked                              = $True
                    AppsSingleAppModeList                          = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppStoreBlockAutomaticDownloads                = $True
                    AppStoreBlocked                                = $True
                    AppStoreBlockInAppPurchases                    = $True
                    AppStoreBlockUIAppInstallation                 = $True
                    AppStoreRequirePassword                        = $True
                    AppsVisibilityList                             = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppsVisibilityListType                         = 'none'
                    AutoFillForceAuthentication                    = $True
                    AutoUnlockBlocked                              = $True
                    BlockSystemAppRemoval                          = $True
                    BluetoothBlockModification                     = $True
                    CameraBlocked                                  = $True
                    CellularBlockDataRoaming                       = $True
                    CellularBlockGlobalBackgroundFetchWhileRoaming = $True
                    CellularBlockPerAppDataModification            = $True
                    CellularBlockPersonalHotspot                   = $True
                    CellularBlockPersonalHotspotModification       = $True
                    CellularBlockPlanModification                  = $True
                    CellularBlockVoiceRoaming                      = $True
                    CertificatesBlockUntrustedTlsCertificates      = $True
                    ClassroomAppBlockRemoteScreenObservation       = $True
                    ClassroomAppForceUnpromptedScreenObservation   = $True
                    ClassroomForceAutomaticallyJoinClasses         = $True
                    ClassroomForceRequestPermissionToLeaveClasses  = $True
                    ClassroomForceUnpromptedAppAndDeviceLock       = $True
                    CompliantAppListType                           = 'none'
                    CompliantAppsList                              = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    ConfigurationProfileBlockChanges               = $True
                    ContactsAllowManagedToUnmanagedWrite           = $True
                    ContactsAllowUnmanagedToManagedRead            = $True
                    ContinuousPathKeyboardBlocked                  = $True
                    DateAndTimeForceSetAutomatically               = $True
                    DefinitionLookupBlocked                        = $True
                    Description                                    = 'FakeStringValue'
                    DeviceBlockEnableRestrictions                  = $True
                    DeviceBlockEraseContentAndSettings             = $True
                    DeviceBlockNameModification                    = $True
                    DiagnosticDataBlockSubmission                  = $True
                    DiagnosticDataBlockSubmissionModification      = $True
                    DisplayName                                    = 'FakeStringValue'
                    DocumentsBlockManagedDocumentsInUnmanagedApps  = $True
                    DocumentsBlockUnmanagedDocumentsInManagedApps  = $True
                    EnterpriseAppBlockTrust                        = $True
                    EnterpriseAppBlockTrustModification            = $True
                    EnterpriseBookBlockBackup                      = $True
                    EnterpriseBookBlockMetadataSync                = $True
                    EsimBlockModification                          = $True
                    FaceTimeBlocked                                = $True
                    FilesNetworkDriveAccessBlocked                 = $True
                    FilesUsbDriveAccessBlocked                     = $True
                    FindMyDeviceInFindMyAppBlocked                 = $True
                    FindMyFriendsBlocked                           = $True
                    FindMyFriendsInFindMyAppBlocked                = $True
                    GameCenterBlocked                              = $True
                    GamingBlockGameCenterFriends                   = $True
                    GamingBlockMultiplayer                         = $True
                    HostPairingBlocked                             = $True
                    IBooksStoreBlocked                             = $True
                    IBooksStoreBlockErotica                        = $True
                    ICloudBlockActivityContinuation                = $True
                    ICloudBlockBackup                              = $True
                    ICloudBlockDocumentSync                        = $True
                    ICloudBlockManagedAppsSync                     = $True
                    ICloudBlockPhotoLibrary                        = $True
                    ICloudBlockPhotoStreamSync                     = $True
                    ICloudBlockSharedPhotoStream                   = $True
                    ICloudPrivateRelayBlocked                      = $True
                    ICloudRequireEncryptedBackup                   = $True
                    Id                                             = 'FakeStringValue'
                    ITunesBlocked                                  = $True
                    ITunesBlockExplicitContent                     = $True
                    ITunesBlockMusicService                        = $True
                    ITunesBlockRadio                               = $True
                    KeyboardBlockAutoCorrect                       = $True
                    KeyboardBlockDictation                         = $True
                    KeyboardBlockPredictive                        = $True
                    KeyboardBlockShortcuts                         = $True
                    KeyboardBlockSpellCheck                        = $True
                    KeychainBlockCloudSync                         = $True
                    KioskModeAllowAssistiveSpeak                   = $True
                    KioskModeAllowAssistiveTouchSettings           = $True
                    KioskModeAllowAutoLock                         = $True
                    KioskModeAllowColorInversionSettings           = $True
                    KioskModeAllowRingerSwitch                     = $True
                    KioskModeAllowScreenRotation                   = $True
                    KioskModeAllowSleepButton                      = $True
                    KioskModeAllowTouchscreen                      = $True
                    KioskModeAllowVoiceControlModification         = $True
                    KioskModeAllowVoiceOverSettings                = $True
                    KioskModeAllowVolumeButtons                    = $True
                    KioskModeAllowZoomSettings                     = $True
                    KioskModeAppStoreUrl                           = 'FakeStringValue'
                    KioskModeAppType                               = 'notConfigured'
                    KioskModeBlockAutoLock                         = $True
                    KioskModeBlockRingerSwitch                     = $True
                    KioskModeBlockScreenRotation                   = $True
                    KioskModeBlockSleepButton                      = $True
                    KioskModeBlockTouchscreen                      = $True
                    KioskModeBlockVolumeButtons                    = $True
                    KioskModeBuiltInAppId                          = 'FakeStringValue'
                    KioskModeEnableVoiceControl                    = $True
                    KioskModeManagedAppId                          = 'FakeStringValue'
                    KioskModeRequireAssistiveTouch                 = $True
                    KioskModeRequireColorInversion                 = $True
                    KioskModeRequireMonoAudio                      = $True
                    KioskModeRequireVoiceOver                      = $True
                    KioskModeRequireZoom                           = $True
                    LockScreenBlockControlCenter                   = $True
                    LockScreenBlockNotificationView                = $True
                    LockScreenBlockPassbook                        = $True
                    LockScreenBlockTodayView                       = $True
                    ManagedPasteboardRequired                      = $True
                    MediaContentRatingApps                         = 'allAllowed'
                    MediaContentRatingAustralia                    = ([MSFT_MicrosoftGraphmediacontentratingaustralia] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingCanada                       = ([MSFT_MicrosoftGraphmediacontentratingcanada] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingFrance                       = ([MSFT_MicrosoftGraphmediacontentratingfrance] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingGermany                      = ([MSFT_MicrosoftGraphmediacontentratinggermany] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingIreland                      = ([MSFT_MicrosoftGraphmediacontentratingireland] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingJapan                        = ([MSFT_MicrosoftGraphmediacontentratingjapan] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingNewZealand                   = ([MSFT_MicrosoftGraphmediacontentratingnewzealand] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedKingdom                = ([MSFT_MicrosoftGraphmediacontentratingunitedkingdom] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedStates                 = ([MSFT_MicrosoftGraphmediacontentratingunitedstates] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MessagesBlocked                                = $True
                    NetworkUsageRules                              = @(
                            ([MSFT_MicrosoftGraphiosnetworkusagerule] @{
                            cellularDataBlocked          = $True
                            cellularDataBlockWhenRoaming = $True
                            managedApps                  = @(
                                ([MSFT_MicrosoftGraphapplistitem] @{
                                    appId     = 'FakeStringValue'
                                    name      = 'FakeStringValue'
                                    odataType = '#microsoft.graph.appleAppListItem'
                                })
                            )
                        })
                    )
                    NfcBlocked                                     = $True
                    NotificationsBlockSettingsModification         = $True
                    OnDeviceOnlyDictationForced                    = $True
                    OnDeviceOnlyTranslationForced                  = $True
                    PasscodeBlockFingerprintModification           = $True
                    PasscodeBlockFingerprintUnlock                 = $True
                    PasscodeBlockModification                      = $True
                    PasscodeBlockSimple                            = $True
                    PasscodeExpirationDays                         = 25
                    PasscodeMinimumCharacterSetCount               = 25
                    PasscodeMinimumLength                          = 25
                    PasscodeMinutesOfInactivityBeforeLock          = 25
                    PasscodeMinutesOfInactivityBeforeScreenTimeout = 25
                    PasscodePreviousPasscodeBlockCount             = 25
                    PasscodeRequired                               = $True
                    PasscodeRequiredType                           = 'deviceDefault'
                    PasscodeSignInFailureCountBeforeWipe           = 25
                    PasswordBlockAirDropSharing                    = $True
                    PasswordBlockAutoFill                          = $True
                    PasswordBlockProximityRequests                 = $True
                    PkiBlockOTAUpdates                             = $True
                    PodcastsBlocked                                = $True
                    PrivacyForceLimitAdTracking                    = $True
                    ProximityBlockSetupToNewDevice                 = $True
                    SafariBlockAutofill                            = $True
                    SafariBlocked                                  = $True
                    SafariBlockJavaScript                          = $True
                    SafariBlockPopups                              = $True
                    SafariCookieSettings                           = 'browserDefault'
                    SafariRequireFraudWarning                      = $True
                    ScreenCaptureBlocked                           = $True
                    SharedDeviceBlockTemporarySessions             = $True
                    SiriBlocked                                    = $True
                    SiriBlockedWhenLocked                          = $True
                    SiriBlockUserGeneratedContent                  = $True
                    SiriRequireProfanityFilter                     = $True
                    SoftwareUpdatesEnforcedDelayInDays             = 25
                    SoftwareUpdatesForceDelayed                    = $True
                    SpotlightBlockInternetResults                  = $True
                    UnpairedExternalBootToRecoveryAllowed          = $True
                    UsbRestrictedModeBlocked                       = $True
                    VoiceDialingBlocked                            = $True
                    VpnBlockCreation                               = $True
                    WallpaperBlockModification                     = $True
                    WiFiConnectOnlyToConfiguredNetworks            = $True
                    WiFiConnectToAllowedNetworksOnlyForced         = $True
                    WifiPowerOnForced                              = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1 -ParameterFilter {
                    $null -eq $BodyParameter.networkUsageRules[0].managedApps[0].'@odata.type'
                }
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyiOS exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountBlockModification                       = $True
                    ActivationLockAllowWhenSupervised              = $True
                    AirDropBlocked                                 = $True
                    AirDropForceUnmanagedDropTarget                = $True
                    AirPlayForcePairingPasswordForOutgoingRequests = $True
                    AirPrintBlockCredentialsStorage                = $True
                    AirPrintBlocked                                = $True
                    AirPrintBlockiBeaconDiscovery                  = $True
                    AirPrintForceTrustedTLS                        = $True
                    AppClipsBlocked                                = $True
                    AppleNewsBlocked                               = $True
                    ApplePersonalizedAdsBlocked                    = $True
                    AppleWatchBlockPairing                         = $True
                    AppleWatchForceWristDetection                  = $True
                    AppRemovalBlocked                              = $True
                    AppsSingleAppModeList                          = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppStoreBlockAutomaticDownloads                = $True
                    AppStoreBlocked                                = $True
                    AppStoreBlockInAppPurchases                    = $True
                    AppStoreBlockUIAppInstallation                 = $True
                    AppStoreRequirePassword                        = $True
                    AppsVisibilityList                             = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppsVisibilityListType                         = 'none'
                    AutoFillForceAuthentication                    = $True
                    AutoUnlockBlocked                              = $True
                    BlockSystemAppRemoval                          = $True
                    BluetoothBlockModification                     = $True
                    CameraBlocked                                  = $True
                    CellularBlockDataRoaming                       = $True
                    CellularBlockGlobalBackgroundFetchWhileRoaming = $True
                    CellularBlockPerAppDataModification            = $True
                    CellularBlockPersonalHotspot                   = $True
                    CellularBlockPersonalHotspotModification       = $True
                    CellularBlockPlanModification                  = $True
                    CellularBlockVoiceRoaming                      = $True
                    CertificatesBlockUntrustedTlsCertificates      = $True
                    ClassroomAppBlockRemoteScreenObservation       = $True
                    ClassroomAppForceUnpromptedScreenObservation   = $True
                    ClassroomForceAutomaticallyJoinClasses         = $True
                    ClassroomForceRequestPermissionToLeaveClasses  = $True
                    ClassroomForceUnpromptedAppAndDeviceLock       = $True
                    CompliantAppListType                           = 'none'
                    CompliantAppsList                              = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    ConfigurationProfileBlockChanges               = $True
                    ContactsAllowManagedToUnmanagedWrite           = $True
                    ContactsAllowUnmanagedToManagedRead            = $True
                    ContinuousPathKeyboardBlocked                  = $True
                    DateAndTimeForceSetAutomatically               = $True
                    DefinitionLookupBlocked                        = $True
                    Description                                    = 'FakeStringValue'
                    DeviceBlockEnableRestrictions                  = $True
                    DeviceBlockEraseContentAndSettings             = $True
                    DeviceBlockNameModification                    = $True
                    DiagnosticDataBlockSubmission                  = $True
                    DiagnosticDataBlockSubmissionModification      = $True
                    DisplayName                                    = 'FakeStringValue'
                    DocumentsBlockManagedDocumentsInUnmanagedApps  = $True
                    DocumentsBlockUnmanagedDocumentsInManagedApps  = $True
                    EnterpriseAppBlockTrust                        = $True
                    EnterpriseAppBlockTrustModification            = $True
                    EnterpriseBookBlockBackup                      = $True
                    EnterpriseBookBlockMetadataSync                = $True
                    EsimBlockModification                          = $True
                    FaceTimeBlocked                                = $True
                    FilesNetworkDriveAccessBlocked                 = $True
                    FilesUsbDriveAccessBlocked                     = $True
                    FindMyDeviceInFindMyAppBlocked                 = $True
                    FindMyFriendsBlocked                           = $True
                    FindMyFriendsInFindMyAppBlocked                = $True
                    GameCenterBlocked                              = $True
                    GamingBlockGameCenterFriends                   = $True
                    GamingBlockMultiplayer                         = $True
                    HostPairingBlocked                             = $True
                    IBooksStoreBlocked                             = $True
                    IBooksStoreBlockErotica                        = $True
                    ICloudBlockActivityContinuation                = $True
                    ICloudBlockBackup                              = $True
                    ICloudBlockDocumentSync                        = $True
                    ICloudBlockManagedAppsSync                     = $True
                    ICloudBlockPhotoLibrary                        = $True
                    ICloudBlockPhotoStreamSync                     = $True
                    ICloudBlockSharedPhotoStream                   = $True
                    ICloudPrivateRelayBlocked                      = $True
                    ICloudRequireEncryptedBackup                   = $True
                    Id                                             = 'FakeStringValue'
                    ITunesBlocked                                  = $True
                    ITunesBlockExplicitContent                     = $True
                    ITunesBlockMusicService                        = $True
                    ITunesBlockRadio                               = $True
                    KeyboardBlockAutoCorrect                       = $True
                    KeyboardBlockDictation                         = $True
                    KeyboardBlockPredictive                        = $True
                    KeyboardBlockShortcuts                         = $True
                    KeyboardBlockSpellCheck                        = $True
                    KeychainBlockCloudSync                         = $True
                    KioskModeAllowAssistiveSpeak                   = $True
                    KioskModeAllowAssistiveTouchSettings           = $True
                    KioskModeAllowAutoLock                         = $True
                    KioskModeAllowColorInversionSettings           = $True
                    KioskModeAllowRingerSwitch                     = $True
                    KioskModeAllowScreenRotation                   = $True
                    KioskModeAllowSleepButton                      = $True
                    KioskModeAllowTouchscreen                      = $True
                    KioskModeAllowVoiceControlModification         = $True
                    KioskModeAllowVoiceOverSettings                = $True
                    KioskModeAllowVolumeButtons                    = $True
                    KioskModeAllowZoomSettings                     = $True
                    KioskModeAppStoreUrl                           = 'FakeStringValue'
                    KioskModeAppType                               = 'notConfigured'
                    KioskModeBlockAutoLock                         = $True
                    KioskModeBlockRingerSwitch                     = $True
                    KioskModeBlockScreenRotation                   = $True
                    KioskModeBlockSleepButton                      = $True
                    KioskModeBlockTouchscreen                      = $True
                    KioskModeBlockVolumeButtons                    = $True
                    KioskModeBuiltInAppId                          = 'FakeStringValue'
                    KioskModeEnableVoiceControl                    = $True
                    KioskModeManagedAppId                          = 'FakeStringValue'
                    KioskModeRequireAssistiveTouch                 = $True
                    KioskModeRequireColorInversion                 = $True
                    KioskModeRequireMonoAudio                      = $True
                    KioskModeRequireVoiceOver                      = $True
                    KioskModeRequireZoom                           = $True
                    LockScreenBlockControlCenter                   = $True
                    LockScreenBlockNotificationView                = $True
                    LockScreenBlockPassbook                        = $True
                    LockScreenBlockTodayView                       = $True
                    ManagedPasteboardRequired                      = $True
                    MediaContentRatingApps                         = 'allAllowed'
                    MediaContentRatingAustralia                    = ([MSFT_MicrosoftGraphmediacontentratingaustralia] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingCanada                       = ([MSFT_MicrosoftGraphmediacontentratingcanada] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingFrance                       = ([MSFT_MicrosoftGraphmediacontentratingfrance] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingGermany                      = ([MSFT_MicrosoftGraphmediacontentratinggermany] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingIreland                      = ([MSFT_MicrosoftGraphmediacontentratingireland] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingJapan                        = ([MSFT_MicrosoftGraphmediacontentratingjapan] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingNewZealand                   = ([MSFT_MicrosoftGraphmediacontentratingnewzealand] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedKingdom                = ([MSFT_MicrosoftGraphmediacontentratingunitedkingdom] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedStates                 = ([MSFT_MicrosoftGraphmediacontentratingunitedstates] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MessagesBlocked                                = $True
                    NetworkUsageRules                              = @(
                            ([MSFT_MicrosoftGraphiosnetworkusagerule] @{
                            cellularDataBlocked          = $True
                            cellularDataBlockWhenRoaming = $True

                        })
                    )
                    NfcBlocked                                     = $True
                    NotificationsBlockSettingsModification         = $True
                    OnDeviceOnlyDictationForced                    = $True
                    OnDeviceOnlyTranslationForced                  = $True
                    PasscodeBlockFingerprintModification           = $True
                    PasscodeBlockFingerprintUnlock                 = $True
                    PasscodeBlockModification                      = $True
                    PasscodeBlockSimple                            = $True
                    PasscodeExpirationDays                         = 25
                    PasscodeMinimumCharacterSetCount               = 25
                    PasscodeMinimumLength                          = 25
                    PasscodeMinutesOfInactivityBeforeLock          = 25
                    PasscodeMinutesOfInactivityBeforeScreenTimeout = 25
                    PasscodePreviousPasscodeBlockCount             = 25
                    PasscodeRequired                               = $True
                    PasscodeRequiredType                           = 'deviceDefault'
                    PasscodeSignInFailureCountBeforeWipe           = 25
                    PasswordBlockAirDropSharing                    = $True
                    PasswordBlockAutoFill                          = $True
                    PasswordBlockProximityRequests                 = $True
                    PkiBlockOTAUpdates                             = $True
                    PodcastsBlocked                                = $True
                    PrivacyForceLimitAdTracking                    = $True
                    ProximityBlockSetupToNewDevice                 = $True
                    SafariBlockAutofill                            = $True
                    SafariBlocked                                  = $True
                    SafariBlockJavaScript                          = $True
                    SafariBlockPopups                              = $True
                    SafariCookieSettings                           = 'browserDefault'
                    SafariRequireFraudWarning                      = $True
                    ScreenCaptureBlocked                           = $True
                    SharedDeviceBlockTemporarySessions             = $True
                    SiriBlocked                                    = $True
                    SiriBlockedWhenLocked                          = $True
                    SiriBlockUserGeneratedContent                  = $True
                    SiriRequireProfanityFilter                     = $True
                    SoftwareUpdatesEnforcedDelayInDays             = 25
                    SoftwareUpdatesForceDelayed                    = $True
                    SpotlightBlockInternetResults                  = $True
                    UnpairedExternalBootToRecoveryAllowed          = $True
                    UsbRestrictedModeBlocked                       = $True
                    VoiceDialingBlocked                            = $True
                    VpnBlockCreation                               = $True
                    WallpaperBlockModification                     = $True
                    WiFiConnectOnlyToConfiguredNetworks            = $True
                    WiFiConnectToAllowedNetworksOnlyForced         = $True
                    WifiPowerOnForced                              = $True

                    Ensure                                         = 'Absent'
                    Credential                                     = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name 'The IntuneDeviceConfigurationPolicyiOS Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountBlockModification                       = $True
                    ActivationLockAllowWhenSupervised              = $True
                    AirDropBlocked                                 = $True
                    AirDropForceUnmanagedDropTarget                = $True
                    AirPlayForcePairingPasswordForOutgoingRequests = $True
                    AirPrintBlockCredentialsStorage                = $True
                    AirPrintBlocked                                = $True
                    AirPrintBlockiBeaconDiscovery                  = $True
                    AirPrintForceTrustedTLS                        = $True
                    AppClipsBlocked                                = $True
                    AppleNewsBlocked                               = $True
                    ApplePersonalizedAdsBlocked                    = $True
                    AppleWatchBlockPairing                         = $True
                    AppleWatchForceWristDetection                  = $True
                    AppRemovalBlocked                              = $True
                    AppsSingleAppModeList                          = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppStoreBlockAutomaticDownloads                = $True
                    AppStoreBlocked                                = $True
                    AppStoreBlockInAppPurchases                    = $True
                    AppStoreBlockUIAppInstallation                 = $True
                    AppStoreRequirePassword                        = $True
                    AppsVisibilityList                             = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppsVisibilityListType                         = 'none'
                    AutoFillForceAuthentication                    = $True
                    AutoUnlockBlocked                              = $True
                    BlockSystemAppRemoval                          = $True
                    BluetoothBlockModification                     = $True
                    CameraBlocked                                  = $True
                    CellularBlockDataRoaming                       = $True
                    CellularBlockGlobalBackgroundFetchWhileRoaming = $True
                    CellularBlockPerAppDataModification            = $True
                    CellularBlockPersonalHotspot                   = $True
                    CellularBlockPersonalHotspotModification       = $True
                    CellularBlockPlanModification                  = $True
                    CellularBlockVoiceRoaming                      = $True
                    CertificatesBlockUntrustedTlsCertificates      = $True
                    ClassroomAppBlockRemoteScreenObservation       = $True
                    ClassroomAppForceUnpromptedScreenObservation   = $True
                    ClassroomForceAutomaticallyJoinClasses         = $True
                    ClassroomForceRequestPermissionToLeaveClasses  = $True
                    ClassroomForceUnpromptedAppAndDeviceLock       = $True
                    CompliantAppListType                           = 'none'
                    CompliantAppsList                              = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    ConfigurationProfileBlockChanges               = $True
                    ContactsAllowManagedToUnmanagedWrite           = $True
                    ContactsAllowUnmanagedToManagedRead            = $True
                    ContinuousPathKeyboardBlocked                  = $True
                    DateAndTimeForceSetAutomatically               = $True
                    DefinitionLookupBlocked                        = $True
                    Description                                    = 'FakeStringValue'
                    DeviceBlockEnableRestrictions                  = $True
                    DeviceBlockEraseContentAndSettings             = $True
                    DeviceBlockNameModification                    = $True
                    DiagnosticDataBlockSubmission                  = $True
                    DiagnosticDataBlockSubmissionModification      = $True
                    DisplayName                                    = 'FakeStringValue'
                    DocumentsBlockManagedDocumentsInUnmanagedApps  = $True
                    DocumentsBlockUnmanagedDocumentsInManagedApps  = $True
                    EnterpriseAppBlockTrust                        = $True
                    EnterpriseAppBlockTrustModification            = $True
                    EnterpriseBookBlockBackup                      = $True
                    EnterpriseBookBlockMetadataSync                = $True
                    EsimBlockModification                          = $True
                    FaceTimeBlocked                                = $True
                    FilesNetworkDriveAccessBlocked                 = $True
                    FilesUsbDriveAccessBlocked                     = $True
                    FindMyDeviceInFindMyAppBlocked                 = $True
                    FindMyFriendsBlocked                           = $True
                    FindMyFriendsInFindMyAppBlocked                = $True
                    GameCenterBlocked                              = $True
                    GamingBlockGameCenterFriends                   = $True
                    GamingBlockMultiplayer                         = $True
                    HostPairingBlocked                             = $True
                    IBooksStoreBlocked                             = $True
                    IBooksStoreBlockErotica                        = $True
                    ICloudBlockActivityContinuation                = $True
                    ICloudBlockBackup                              = $True
                    ICloudBlockDocumentSync                        = $True
                    ICloudBlockManagedAppsSync                     = $True
                    ICloudBlockPhotoLibrary                        = $True
                    ICloudBlockPhotoStreamSync                     = $True
                    ICloudBlockSharedPhotoStream                   = $True
                    ICloudPrivateRelayBlocked                      = $True
                    ICloudRequireEncryptedBackup                   = $True
                    Id                                             = 'FakeStringValue'
                    ITunesBlocked                                  = $True
                    ITunesBlockExplicitContent                     = $True
                    ITunesBlockMusicService                        = $True
                    ITunesBlockRadio                               = $True
                    KeyboardBlockAutoCorrect                       = $True
                    KeyboardBlockDictation                         = $True
                    KeyboardBlockPredictive                        = $True
                    KeyboardBlockShortcuts                         = $True
                    KeyboardBlockSpellCheck                        = $True
                    KeychainBlockCloudSync                         = $True
                    KioskModeAllowAssistiveSpeak                   = $True
                    KioskModeAllowAssistiveTouchSettings           = $True
                    KioskModeAllowAutoLock                         = $True
                    KioskModeAllowColorInversionSettings           = $True
                    KioskModeAllowRingerSwitch                     = $True
                    KioskModeAllowScreenRotation                   = $True
                    KioskModeAllowSleepButton                      = $True
                    KioskModeAllowTouchscreen                      = $True
                    KioskModeAllowVoiceControlModification         = $True
                    KioskModeAllowVoiceOverSettings                = $True
                    KioskModeAllowVolumeButtons                    = $True
                    KioskModeAllowZoomSettings                     = $True
                    KioskModeAppStoreUrl                           = 'FakeStringValue'
                    KioskModeAppType                               = 'notConfigured'
                    KioskModeBlockAutoLock                         = $True
                    KioskModeBlockRingerSwitch                     = $True
                    KioskModeBlockScreenRotation                   = $True
                    KioskModeBlockSleepButton                      = $True
                    KioskModeBlockTouchscreen                      = $True
                    KioskModeBlockVolumeButtons                    = $True
                    KioskModeBuiltInAppId                          = 'FakeStringValue'
                    KioskModeEnableVoiceControl                    = $True
                    KioskModeManagedAppId                          = 'FakeStringValue'
                    KioskModeRequireAssistiveTouch                 = $True
                    KioskModeRequireColorInversion                 = $True
                    KioskModeRequireMonoAudio                      = $True
                    KioskModeRequireVoiceOver                      = $True
                    KioskModeRequireZoom                           = $True
                    LockScreenBlockControlCenter                   = $True
                    LockScreenBlockNotificationView                = $True
                    LockScreenBlockPassbook                        = $True
                    LockScreenBlockTodayView                       = $True
                    ManagedPasteboardRequired                      = $True
                    MediaContentRatingApps                         = 'allAllowed'
                    MediaContentRatingAustralia                    = ([MSFT_MicrosoftGraphmediacontentratingaustralia] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingCanada                       = ([MSFT_MicrosoftGraphmediacontentratingcanada] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingFrance                       = ([MSFT_MicrosoftGraphmediacontentratingfrance] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingGermany                      = ([MSFT_MicrosoftGraphmediacontentratinggermany] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingIreland                      = ([MSFT_MicrosoftGraphmediacontentratingireland] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingJapan                        = ([MSFT_MicrosoftGraphmediacontentratingjapan] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingNewZealand                   = ([MSFT_MicrosoftGraphmediacontentratingnewzealand] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedKingdom                = ([MSFT_MicrosoftGraphmediacontentratingunitedkingdom] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedStates                 = ([MSFT_MicrosoftGraphmediacontentratingunitedstates] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MessagesBlocked                                = $True
                    NetworkUsageRules                              = @(
                            ([MSFT_MicrosoftGraphiosnetworkusagerule] @{
                            cellularDataBlocked          = $True
                            cellularDataBlockWhenRoaming = $True
                            managedApps                  = @(
                                ([MSFT_MicrosoftGraphapplistitem] @{
                                    appId     = 'FakeStringValue'
                                    name      = 'FakeStringValue'
                                    odataType = '#microsoft.graph.appleAppListItem'
                                })
                            )
                        })
                    )
                    NfcBlocked                                     = $True
                    NotificationsBlockSettingsModification         = $True
                    OnDeviceOnlyDictationForced                    = $True
                    OnDeviceOnlyTranslationForced                  = $True
                    PasscodeBlockFingerprintModification           = $True
                    PasscodeBlockFingerprintUnlock                 = $True
                    PasscodeBlockModification                      = $True
                    PasscodeBlockSimple                            = $True
                    PasscodeExpirationDays                         = 25
                    PasscodeMinimumCharacterSetCount               = 25
                    PasscodeMinimumLength                          = 25
                    PasscodeMinutesOfInactivityBeforeLock          = 25
                    PasscodeMinutesOfInactivityBeforeScreenTimeout = 25
                    PasscodePreviousPasscodeBlockCount             = 25
                    PasscodeRequired                               = $True
                    PasscodeRequiredType                           = 'deviceDefault'
                    PasscodeSignInFailureCountBeforeWipe           = 25
                    PasswordBlockAirDropSharing                    = $True
                    PasswordBlockAutoFill                          = $True
                    PasswordBlockProximityRequests                 = $True
                    PkiBlockOTAUpdates                             = $True
                    PodcastsBlocked                                = $True
                    PrivacyForceLimitAdTracking                    = $True
                    ProximityBlockSetupToNewDevice                 = $True
                    SafariBlockAutofill                            = $True
                    SafariBlocked                                  = $True
                    SafariBlockJavaScript                          = $True
                    SafariBlockPopups                              = $True
                    SafariCookieSettings                           = 'browserDefault'
                    SafariRequireFraudWarning                      = $True
                    ScreenCaptureBlocked                           = $True
                    SharedDeviceBlockTemporarySessions             = $True
                    SiriBlocked                                    = $True
                    SiriBlockedWhenLocked                          = $True
                    SiriBlockUserGeneratedContent                  = $True
                    SiriRequireProfanityFilter                     = $True
                    SoftwareUpdatesEnforcedDelayInDays             = 25
                    SoftwareUpdatesForceDelayed                    = $True
                    SpotlightBlockInternetResults                  = $True
                    UnpairedExternalBootToRecoveryAllowed          = $True
                    UsbRestrictedModeBlocked                       = $True
                    VoiceDialingBlocked                            = $True
                    VpnBlockCreation                               = $True
                    WallpaperBlockModification                     = $True
                    WiFiConnectOnlyToConfiguredNetworks            = $True
                    WiFiConnectToAllowedNetworksOnlyForced         = $True
                    WifiPowerOnForced                              = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyiOS exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountBlockModification                       = $False # Updated property
                    ActivationLockAllowWhenSupervised              = $True
                    AirDropBlocked                                 = $True
                    AirDropForceUnmanagedDropTarget                = $True
                    AirPlayForcePairingPasswordForOutgoingRequests = $True
                    AirPrintBlockCredentialsStorage                = $True
                    AirPrintBlocked                                = $True
                    AirPrintBlockiBeaconDiscovery                  = $True
                    AirPrintForceTrustedTLS                        = $True
                    AppClipsBlocked                                = $True
                    AppleNewsBlocked                               = $True
                    ApplePersonalizedAdsBlocked                    = $True
                    AppleWatchBlockPairing                         = $True
                    AppleWatchForceWristDetection                  = $True
                    AppRemovalBlocked                              = $True
                    AppsSingleAppModeList                          = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppStoreBlockAutomaticDownloads                = $True
                    AppStoreBlocked                                = $True
                    AppStoreBlockInAppPurchases                    = $True
                    AppStoreBlockUIAppInstallation                 = $True
                    AppStoreRequirePassword                        = $True
                    AppsVisibilityList                             = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    AppsVisibilityListType                         = 'none'
                    AutoFillForceAuthentication                    = $True
                    AutoUnlockBlocked                              = $True
                    BlockSystemAppRemoval                          = $True
                    BluetoothBlockModification                     = $True
                    CameraBlocked                                  = $True
                    CellularBlockDataRoaming                       = $True
                    CellularBlockGlobalBackgroundFetchWhileRoaming = $True
                    CellularBlockPerAppDataModification            = $True
                    CellularBlockPersonalHotspot                   = $True
                    CellularBlockPersonalHotspotModification       = $True
                    CellularBlockPlanModification                  = $True
                    CellularBlockVoiceRoaming                      = $True
                    CertificatesBlockUntrustedTlsCertificates      = $True
                    ClassroomAppBlockRemoteScreenObservation       = $True
                    ClassroomAppForceUnpromptedScreenObservation   = $True
                    ClassroomForceAutomaticallyJoinClasses         = $True
                    ClassroomForceRequestPermissionToLeaveClasses  = $True
                    ClassroomForceUnpromptedAppAndDeviceLock       = $True
                    CompliantAppListType                           = 'none'
                    CompliantAppsList                              = @(
                            ([MSFT_MicrosoftGraphapplistitem] @{
                            appId       = 'FakeStringValue'
                            publisher   = 'FakeStringValue'
                            appStoreUrl = 'FakeStringValue'
                            name        = 'FakeStringValue'
                            odataType   = '#microsoft.graph.appleAppListItem'

                        })
                    )
                    ConfigurationProfileBlockChanges               = $True
                    ContactsAllowManagedToUnmanagedWrite           = $True
                    ContactsAllowUnmanagedToManagedRead            = $True
                    ContinuousPathKeyboardBlocked                  = $True
                    DateAndTimeForceSetAutomatically               = $True
                    DefinitionLookupBlocked                        = $True
                    Description                                    = 'FakeStringValue'
                    DeviceBlockEnableRestrictions                  = $True
                    DeviceBlockEraseContentAndSettings             = $True
                    DeviceBlockNameModification                    = $True
                    DiagnosticDataBlockSubmission                  = $True
                    DiagnosticDataBlockSubmissionModification      = $True
                    DisplayName                                    = 'FakeStringValue'
                    DocumentsBlockManagedDocumentsInUnmanagedApps  = $True
                    DocumentsBlockUnmanagedDocumentsInManagedApps  = $True
                    EnterpriseAppBlockTrust                        = $True
                    EnterpriseAppBlockTrustModification            = $True
                    EnterpriseBookBlockBackup                      = $True
                    EnterpriseBookBlockMetadataSync                = $True
                    EsimBlockModification                          = $True
                    FaceTimeBlocked                                = $True
                    FilesNetworkDriveAccessBlocked                 = $True
                    FilesUsbDriveAccessBlocked                     = $True
                    FindMyDeviceInFindMyAppBlocked                 = $True
                    FindMyFriendsBlocked                           = $True
                    FindMyFriendsInFindMyAppBlocked                = $True
                    GameCenterBlocked                              = $True
                    GamingBlockGameCenterFriends                   = $True
                    GamingBlockMultiplayer                         = $True
                    HostPairingBlocked                             = $True
                    IBooksStoreBlocked                             = $True
                    IBooksStoreBlockErotica                        = $True
                    ICloudBlockActivityContinuation                = $True
                    ICloudBlockBackup                              = $True
                    ICloudBlockDocumentSync                        = $True
                    ICloudBlockManagedAppsSync                     = $True
                    ICloudBlockPhotoLibrary                        = $True
                    ICloudBlockPhotoStreamSync                     = $True
                    ICloudBlockSharedPhotoStream                   = $True
                    ICloudPrivateRelayBlocked                      = $True
                    ICloudRequireEncryptedBackup                   = $True
                    Id                                             = 'FakeStringValue'
                    ITunesBlocked                                  = $True
                    ITunesBlockExplicitContent                     = $True
                    ITunesBlockMusicService                        = $True
                    ITunesBlockRadio                               = $True
                    KeyboardBlockAutoCorrect                       = $True
                    KeyboardBlockDictation                         = $True
                    KeyboardBlockPredictive                        = $True
                    KeyboardBlockShortcuts                         = $True
                    KeyboardBlockSpellCheck                        = $True
                    KeychainBlockCloudSync                         = $True
                    KioskModeAllowAssistiveSpeak                   = $True
                    KioskModeAllowAssistiveTouchSettings           = $True
                    KioskModeAllowAutoLock                         = $True
                    KioskModeAllowColorInversionSettings           = $True
                    KioskModeAllowRingerSwitch                     = $True
                    KioskModeAllowScreenRotation                   = $True
                    KioskModeAllowSleepButton                      = $True
                    KioskModeAllowTouchscreen                      = $True
                    KioskModeAllowVoiceControlModification         = $True
                    KioskModeAllowVoiceOverSettings                = $True
                    KioskModeAllowVolumeButtons                    = $True
                    KioskModeAllowZoomSettings                     = $True
                    KioskModeAppStoreUrl                           = 'FakeStringValue'
                    KioskModeAppType                               = 'notConfigured'
                    KioskModeBlockAutoLock                         = $True
                    KioskModeBlockRingerSwitch                     = $True
                    KioskModeBlockScreenRotation                   = $True
                    KioskModeBlockSleepButton                      = $True
                    KioskModeBlockTouchscreen                      = $True
                    KioskModeBlockVolumeButtons                    = $True
                    KioskModeBuiltInAppId                          = 'FakeStringValue'
                    KioskModeEnableVoiceControl                    = $True
                    KioskModeManagedAppId                          = 'FakeStringValue'
                    KioskModeRequireAssistiveTouch                 = $True
                    KioskModeRequireColorInversion                 = $True
                    KioskModeRequireMonoAudio                      = $True
                    KioskModeRequireVoiceOver                      = $True
                    KioskModeRequireZoom                           = $True
                    LockScreenBlockControlCenter                   = $True
                    LockScreenBlockNotificationView                = $True
                    LockScreenBlockPassbook                        = $True
                    LockScreenBlockTodayView                       = $True
                    ManagedPasteboardRequired                      = $True
                    MediaContentRatingApps                         = 'allAllowed'
                    MediaContentRatingAustralia                    = ([MSFT_MicrosoftGraphmediacontentratingaustralia] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingCanada                       = ([MSFT_MicrosoftGraphmediacontentratingcanada] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingFrance                       = ([MSFT_MicrosoftGraphmediacontentratingfrance] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingGermany                      = ([MSFT_MicrosoftGraphmediacontentratinggermany] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingIreland                      = ([MSFT_MicrosoftGraphmediacontentratingireland] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingJapan                        = ([MSFT_MicrosoftGraphmediacontentratingjapan] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingNewZealand                   = ([MSFT_MicrosoftGraphmediacontentratingnewzealand] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedKingdom                = ([MSFT_MicrosoftGraphmediacontentratingunitedkingdom] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MediaContentRatingUnitedStates                 = ([MSFT_MicrosoftGraphmediacontentratingunitedstates] @{
                            movieRating = 'allAllowed'
                            tvRating    = 'allAllowed'
                        })
                    MessagesBlocked                                = $True
                    NetworkUsageRules                              = @(
                            ([MSFT_MicrosoftGraphiosnetworkusagerule] @{
                            cellularDataBlocked          = $True
                            cellularDataBlockWhenRoaming = $True

                        })
                    )
                    NfcBlocked                                     = $True
                    NotificationsBlockSettingsModification         = $True
                    OnDeviceOnlyDictationForced                    = $True
                    OnDeviceOnlyTranslationForced                  = $True
                    PasscodeBlockFingerprintModification           = $True
                    PasscodeBlockFingerprintUnlock                 = $True
                    PasscodeBlockModification                      = $True
                    PasscodeBlockSimple                            = $True
                    PasscodeExpirationDays                         = 25
                    PasscodeMinimumCharacterSetCount               = 25
                    PasscodeMinimumLength                          = 25
                    PasscodeMinutesOfInactivityBeforeLock          = 25
                    PasscodeMinutesOfInactivityBeforeScreenTimeout = 25
                    PasscodePreviousPasscodeBlockCount             = 25
                    PasscodeRequired                               = $True
                    PasscodeRequiredType                           = 'deviceDefault'
                    PasscodeSignInFailureCountBeforeWipe           = 25
                    PasswordBlockAirDropSharing                    = $True
                    PasswordBlockAutoFill                          = $True
                    PasswordBlockProximityRequests                 = $True
                    PkiBlockOTAUpdates                             = $True
                    PodcastsBlocked                                = $True
                    PrivacyForceLimitAdTracking                    = $True
                    ProximityBlockSetupToNewDevice                 = $True
                    SafariBlockAutofill                            = $True
                    SafariBlocked                                  = $True
                    SafariBlockJavaScript                          = $True
                    SafariBlockPopups                              = $True
                    SafariCookieSettings                           = 'browserDefault'
                    SafariRequireFraudWarning                      = $True
                    ScreenCaptureBlocked                           = $True
                    SharedDeviceBlockTemporarySessions             = $True
                    SiriBlocked                                    = $True
                    SiriBlockedWhenLocked                          = $True
                    SiriBlockUserGeneratedContent                  = $True
                    SiriRequireProfanityFilter                     = $True
                    SoftwareUpdatesEnforcedDelayInDays             = 25
                    SoftwareUpdatesForceDelayed                    = $True
                    SpotlightBlockInternetResults                  = $True
                    UnpairedExternalBootToRecoveryAllowed          = $True
                    UsbRestrictedModeBlocked                       = $True
                    VoiceDialingBlocked                            = $True
                    VpnBlockCreation                               = $True
                    WallpaperBlockModification                     = $True
                    WiFiConnectOnlyToConfiguredNetworks            = $True
                    WiFiConnectToAllowedNetworksOnlyForced         = $True
                    WifiPowerOnForced                              = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationPolicyiOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
