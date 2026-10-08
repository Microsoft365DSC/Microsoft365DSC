using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationPolicyiOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow account modification when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $AccountBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Activation Lock makes it harder for a lost or stolen device to be reactivated.')]
    [System.Nullable[System.Boolean]] $ActivationLockAllowWhenSupervised

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow AirDrop when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $AirDropBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Force AirDrop to be considered an unmanaged drop target.')]
    [System.Nullable[System.Boolean]] $AirDropForceUnmanagedDropTarget

    [DscProperty()]
    [System.ComponentModel.Description('Force requiring a pairing password for outgoing AirPlay requests.')]
    [System.Nullable[System.Boolean]] $AirPlayForcePairingPasswordForOutgoingRequests

    [DscProperty()]
    [System.ComponentModel.Description('Blocks keychain storage of username and password for outgoing AirPrint request.')]
    [System.Nullable[System.Boolean]] $AirPrintBlockCredentialsStorage

    [DscProperty()]
    [System.ComponentModel.Description('Blocks AirPrint request.')]
    [System.Nullable[System.Boolean]] $AirPrintBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocking prevents malicious AirPrint Bluetooth beacons phishing for network traffic.')]
    [System.Nullable[System.Boolean]] $AirPrintBlockiBeaconDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Forces trusted certificates for TLS printing communication')]
    [System.Nullable[System.Boolean]] $AirPrintForceTrustedTLS

    [DscProperty()]
    [System.ComponentModel.Description('Block app clips.')]
    [System.Nullable[System.Boolean]] $AppClipsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block Apple News')]
    [System.Nullable[System.Boolean]] $AppleNewsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block Apple PersonalizedAdsBlocked')]
    [System.Nullable[System.Boolean]] $ApplePersonalizedAdsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow Apple Watch pairing when the device is in supervised mode (iOS 9.0 and later).')]
    [System.Nullable[System.Boolean]] $AppleWatchBlockPairing

    [DscProperty()]
    [System.ComponentModel.Description('Force paired Apple watch to use wrist detection.')]
    [System.Nullable[System.Boolean]] $AppleWatchForceWristDetection

    [DscProperty()]
    [System.ComponentModel.Description('Block app removal.')]
    [System.Nullable[System.Boolean]] $AppRemovalBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Apps you add to this list and assign to a device can lock the device to run only that app once launched, or lock the device while a certain action is running (for example, taking a test). Once the action is complete, or you remove the restriction, the device returns to its normal state.')]
    [MSFT_MicrosoftGraphapplistitem[]] $AppsSingleAppModeList

    [DscProperty()]
    [System.ComponentModel.Description('Blocks automatic downloading of apps purchased on other devices. Does not affect updates to existing apps.')]
    [System.Nullable[System.Boolean]] $AppStoreBlockAutomaticDownloads

    [DscProperty()]
    [System.ComponentModel.Description('For supervised devices as of iOS 13.0.')]
    [System.Nullable[System.Boolean]] $AppStoreBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block AppStore in-app purchases.')]
    [System.Nullable[System.Boolean]] $AppStoreBlockInAppPurchases

    [DscProperty()]
    [System.ComponentModel.Description('Block App Store from Home Screen. Users may continue to use iTunes or Apple Configurator to install or update apps.')]
    [System.Nullable[System.Boolean]] $AppStoreBlockUIAppInstallation

    [DscProperty()]
    [System.ComponentModel.Description('Users must enter Apple ID password for each in-app and iTunes purchase.')]
    [System.Nullable[System.Boolean]] $AppStoreRequirePassword

    [DscProperty()]
    [System.ComponentModel.Description('Enter the iTunes App Store URL of the app you want. For example, to specify the Microsoft Work Folders app for iOS, enter https://itunes.apple.com/us/app/work-folders/id950878067?mt=8. To find the URL of an app, use a search engine to locate the store page. For example, to find the Work Folders app, you could search Microsoft Work Folders ITunes.')]
    [MSFT_MicrosoftGraphapplistitem[]] $AppsVisibilityList

    [DscProperty()]
    [System.ComponentModel.Description('Set whether the list is a list of apps to hide or a list of apps to make visible.')]
    [ValidateSet('none', 'appsInListCompliant', 'appsNotInListCompliant')]
    [System.String] $AppsVisibilityListType

    [DscProperty()]
    [System.ComponentModel.Description('Require Touch ID or Face ID before passwords or credit card information can be auto filled in Safari and Apps. Available with iOS 12.0 and later.')]
    [System.Nullable[System.Boolean]] $AutoFillForceAuthentication

    [DscProperty()]
    [System.ComponentModel.Description('Block auto unlock.')]
    [System.Nullable[System.Boolean]] $AutoUnlockBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocking disables the ability to remove system apps from the device.')]
    [System.Nullable[System.Boolean]] $BlockSystemAppRemoval

    [DscProperty()]
    [System.ComponentModel.Description('Block modification of Bluetooth settings. To use this setting, the device must be in supervised mode (iOS 10.0+).')]
    [System.Nullable[System.Boolean]] $BluetoothBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from accessing the camera of the device. Requires a supervised device for iOS 13 and later.')]
    [System.Nullable[System.Boolean]] $CameraBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block data roaming over the cellular network. This won''t show in the device''s management profile, but a block will be enforced for data roaming every time the device checks in (typically every 8 hours).')]
    [System.Nullable[System.Boolean]] $CellularBlockDataRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Block global background fetch while roaming over the cellular network.')]
    [System.Nullable[System.Boolean]] $CellularBlockGlobalBackgroundFetchWhileRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Block changes to app cellular data usage settings.')]
    [System.Nullable[System.Boolean]] $CellularBlockPerAppDataModification

    [DscProperty()]
    [System.ComponentModel.Description('This value is available only with certain carriers. This won''t show in the device''s management profile, but a block will be enforced for personal hotspot every time the device checks in (typically every 8 hours). Block modification of personal hotspot in addition to this setting to ensure personal hotspot will always be blocked.')]
    [System.Nullable[System.Boolean]] $CellularBlockPersonalHotspot

    [DscProperty()]
    [System.ComponentModel.Description('For devices running iOS 12.2 and later. Users can''t turn Personal Hotspot on or off. If you block this setting and block Personal Hotspot, Personal Hotspot will be turned off.')]
    [System.Nullable[System.Boolean]] $CellularBlockPersonalHotspotModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow users to change the settings of the cellular plan on a supervised device.')]
    [System.Nullable[System.Boolean]] $CellularBlockPlanModification

    [DscProperty()]
    [System.ComponentModel.Description('Block voice roaming over the cellular network.')]
    [System.Nullable[System.Boolean]] $CellularBlockVoiceRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Block untrusted Transport Layer Security (TLS) certificates.')]
    [System.Nullable[System.Boolean]] $CertificatesBlockUntrustedTlsCertificates

    [DscProperty()]
    [System.ComponentModel.Description('Block remote screen observation by Classroom app. To use this setting, the device must be in supervised mode (iOS 9.3+).')]
    [System.Nullable[System.Boolean]] $ClassroomAppBlockRemoteScreenObservation

    [DscProperty()]
    [System.ComponentModel.Description('Student devices enrolled in a class via the Classroom app will automatically give permission to that course''s teacher to silently observe the student''s screen.')]
    [System.Nullable[System.Boolean]] $ClassroomAppForceUnpromptedScreenObservation

    [DscProperty()]
    [System.ComponentModel.Description('Students can join a class without prompting the teacher.')]
    [System.Nullable[System.Boolean]] $ClassroomForceAutomaticallyJoinClasses

    [DscProperty()]
    [System.ComponentModel.Description('Requires a student enrolled in an unmanaged course via Classroom to request permission from the teacher when attempting to leave the course. Only available in iOS 11.3+')]
    [System.Nullable[System.Boolean]] $ClassroomForceRequestPermissionToLeaveClasses

    [DscProperty()]
    [System.ComponentModel.Description('Teachers can lock an app open or lock the device without first prompting the user.')]
    [System.Nullable[System.Boolean]] $ClassroomForceUnpromptedAppAndDeviceLock

    [DscProperty()]
    [System.ComponentModel.Description('Device compliance can be viewed in the Restricted Apps Compliance report.')]
    [ValidateSet('none', 'appsInListCompliant', 'appsNotInListCompliant')]
    [System.String] $CompliantAppListType

    [DscProperty()]
    [System.ComponentModel.Description('Enter the iTunes App Store URL of the app you want. For example, to specify the Microsoft Work Folders app for iOS, enter https://itunes.apple.com/us/app/work-folders/id950878067?mt=8. To find the URL of an app, use a search engine to locate the store page. For example, to find the Work Folders app, you could search Microsoft Work Folders ITunes.')]
    [MSFT_MicrosoftGraphapplistitem[]] $CompliantAppsList

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from installing configuration profiles and certificates interactively when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $ConfigurationProfileBlockChanges

    [DscProperty()]
    [System.ComponentModel.Description('Users can sync and add their managed contacts (including business and corporate ones) to an unmanaged app, such as the device''s built-in contacts app.')]
    [System.Nullable[System.Boolean]] $ContactsAllowManagedToUnmanagedWrite

    [DscProperty()]
    [System.ComponentModel.Description('An unmanaged app, such as the device''s built-in contacts app, can access contact info in a managed app, such as Outlook.')]
    [System.Nullable[System.Boolean]] $ContactsAllowUnmanagedToManagedRead

    [DscProperty()]
    [System.ComponentModel.Description('QuickPath enables continuous input on the device keyboard. Available for iOS/iPadOS 13.0 and later.')]
    [System.Nullable[System.Boolean]] $ContinuousPathKeyboardBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Forces device to Set Date & Time Automatically. The device''s time zone will only be updated when the device has cellular connections or wifi with location services enabled.')]
    [System.Nullable[System.Boolean]] $DateAndTimeForceSetAutomatically

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block definition lookup when the device is in supervised mode (iOS 8.1.3 and later ).')]
    [System.Nullable[System.Boolean]] $DefinitionLookupBlocked

    [DscProperty()]
    [System.ComponentModel.Description('On iOS 12.0 and later, this blocks users from setting their own Screen Time settings, which includes device restrictions. On iOS 11.4.1 and earlier, this blocks the user from enabling restrictions in the device settings. The blocking effect is the same on any supervised iOS device.')]
    [System.Nullable[System.Boolean]] $DeviceBlockEnableRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Block the use of the erase all content and settings option on the device.')]
    [System.Nullable[System.Boolean]] $DeviceBlockEraseContentAndSettings

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow device name modification when the device is in supervised mode (iOS 9.0 and later).')]
    [System.Nullable[System.Boolean]] $DeviceBlockNameModification

    [DscProperty()]
    [System.ComponentModel.Description('Block the device from sending diagnostic and usage telemetry data.')]
    [System.Nullable[System.Boolean]] $DiagnosticDataBlockSubmission

    [DscProperty()]
    [System.ComponentModel.Description('Block the modification of the diagnostic submission and app analytics settings in the Diagnostics and Usage pane in Settings. To use this setting, the device must be in supervised mode (iOS 9.3.2+).')]
    [System.Nullable[System.Boolean]] $DiagnosticDataBlockSubmissionModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from viewing managed documents in unmanaged apps.')]
    [System.Nullable[System.Boolean]] $DocumentsBlockManagedDocumentsInUnmanagedApps

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from viewing unmanaged documents in managed apps.')]
    [System.Nullable[System.Boolean]] $DocumentsBlockUnmanagedDocumentsInManagedApps

    [DscProperty()]
    [System.ComponentModel.Description('Emails that the user sends or receives which don''t match the domains you specify here will be marked as untrusted.')]
    [System.String[]] $EmailInDomainSuffixes

    [DscProperty()]
    [System.ComponentModel.Description('Removes the Trust Enterprise Developer button in Settings->General->Profiles & Device Management.')]
    [System.Nullable[System.Boolean]] $EnterpriseAppBlockTrust

    [DscProperty()]
    [System.ComponentModel.Description('Block the changing of enterprise app trust settings.')]
    [System.Nullable[System.Boolean]] $EnterpriseAppBlockTrustModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to backup enterprise book.')]
    [System.Nullable[System.Boolean]] $EnterpriseBookBlockBackup

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to sync enterprise book metadata.')]
    [System.Nullable[System.Boolean]] $EnterpriseBookBlockMetadataSync

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow the addition or removal of cellular plans on the eSIM of a supervised device.')]
    [System.Nullable[System.Boolean]] $EsimBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using FaceTime. Requires a supervised device for iOS 13 and later.')]
    [System.Nullable[System.Boolean]] $FaceTimeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Using the Server Message Block (SMB) protocol, devices can access files or other resources on a network server. Available for devices running iOS and iPadOS, versions 13.0 and later.')]
    [System.Nullable[System.Boolean]] $FilesNetworkDriveAccessBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Devices with access can connect to and open files on a USB drive. Available for devices running iOS and iPadOS, versions 13.0 and later.')]
    [System.Nullable[System.Boolean]] $FilesUsbDriveAccessBlocked

    [DscProperty()]
    [System.ComponentModel.Description('A Find My app feature. Available for iOS/iPadOS 13.0 and later.')]
    [System.Nullable[System.Boolean]] $FindMyDeviceInFindMyAppBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block changes to the Find My Friends app settings.')]
    [System.Nullable[System.Boolean]] $FindMyFriendsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('A Find My app feature. Used to locate family and friends from an Apple device or iCloud.com. Available for iOS/iPadOS 13.0 and later.')]
    [System.Nullable[System.Boolean]] $FindMyFriendsInFindMyAppBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using Game Center when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $GameCenterBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block adding Game Center friends. For supervised devices as of iOS 13.0.')]
    [System.Nullable[System.Boolean]] $GamingBlockGameCenterFriends

    [DscProperty()]
    [System.ComponentModel.Description('For supervised devices as of iOS 13.0.')]
    [System.Nullable[System.Boolean]] $GamingBlockMultiplayer

    [DscProperty()]
    [System.ComponentModel.Description('Host pairing allows you to control which devices the device can pair with.')]
    [System.Nullable[System.Boolean]] $HostPairingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using the iBooks Store when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $IBooksStoreBlocked

    [DscProperty()]
    [System.ComponentModel.Description('User will not be able to download media from the iBook store that has been tagged as erotica.')]
    [System.Nullable[System.Boolean]] $IBooksStoreBlockErotica

    [DscProperty()]
    [System.ComponentModel.Description('Handoff lets users start work on one iOS device, and continue it on another MacOS or iOS device.')]
    [System.Nullable[System.Boolean]] $ICloudBlockActivityContinuation

    [DscProperty()]
    [System.ComponentModel.Description('Block backing up device to iCloud.')]
    [System.Nullable[System.Boolean]] $ICloudBlockBackup

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing documents and data.')]
    [System.Nullable[System.Boolean]] $ICloudBlockDocumentSync

    [DscProperty()]
    [System.ComponentModel.Description('Block managed apps from syncing to cloud.')]
    [System.Nullable[System.Boolean]] $ICloudBlockManagedAppsSync

    [DscProperty()]
    [System.ComponentModel.Description('Any photos not fully downloaded from iCloud Photo Library to device will be removed from local storage.')]
    [System.Nullable[System.Boolean]] $ICloudBlockPhotoLibrary

    [DscProperty()]
    [System.ComponentModel.Description('Block photo stream syncing to iCloud.')]
    [System.Nullable[System.Boolean]] $ICloudBlockPhotoStreamSync

    [DscProperty()]
    [System.ComponentModel.Description('Block shared photo streaming. Blocking can cause data loss.')]
    [System.Nullable[System.Boolean]] $ICloudBlockSharedPhotoStream

    [DscProperty()]
    [System.ComponentModel.Description('Block iCloud private relay.')]
    [System.Nullable[System.Boolean]] $ICloudPrivateRelayBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Require encryption on device backup.')]
    [System.Nullable[System.Boolean]] $ICloudRequireEncryptedBackup

    [DscProperty()]
    [System.ComponentModel.Description('Block iTunes.')]
    [System.Nullable[System.Boolean]] $ITunesBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block explicit iTunes music, podcast, and news content from iTunes. For supervised devices as of 13.0.')]
    [System.Nullable[System.Boolean]] $ITunesBlockExplicitContent

    [DscProperty()]
    [System.ComponentModel.Description('Block Music service. If true, Music app reverts to classic mode and Music service is disabled.')]
    [System.Nullable[System.Boolean]] $ITunesBlockMusicService

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using iTunes Radio when the device is in supervised mode (iOS 9.3 and later).')]
    [System.Nullable[System.Boolean]] $ITunesBlockRadio

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block keyboard auto-correction when the device is in supervised mode (iOS 8.1.3 and later).')]
    [System.Nullable[System.Boolean]] $KeyboardBlockAutoCorrect

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using dictation input when the device is in supervised mode.')]
    [System.Nullable[System.Boolean]] $KeyboardBlockDictation

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block predictive keyboards when device is in supervised mode (iOS 8.1.3 and later).')]
    [System.Nullable[System.Boolean]] $KeyboardBlockPredictive

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block keyboard shortcuts when the device is in supervised mode (iOS 9.0 and later).')]
    [System.Nullable[System.Boolean]] $KeyboardBlockShortcuts

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block keyboard spell-checking when the device is in supervised mode (iOS 8.1.3 and later).')]
    [System.Nullable[System.Boolean]] $KeyboardBlockSpellCheck

    [DscProperty()]
    [System.ComponentModel.Description('Disables syncing credentials stored in the Keychain to iCloud.')]
    [System.Nullable[System.Boolean]] $KeychainBlockCloudSync

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow assistive speak while in kiosk mode.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowAssistiveSpeak

    [DscProperty()]
    [System.ComponentModel.Description('Users can turn AssistiveTouch on or off.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowAssistiveTouchSettings

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow auto lock')]
    [System.Nullable[System.Boolean]] $KioskModeAllowAutoLock

    [DscProperty()]
    [System.ComponentModel.Description('Users can turn invert colors on or off.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowColorInversionSettings

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow ringer switch')]
    [System.Nullable[System.Boolean]] $KioskModeAllowRingerSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow screen rotation')]
    [System.Nullable[System.Boolean]] $KioskModeAllowScreenRotation

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow sleep button')]
    [System.Nullable[System.Boolean]] $KioskModeAllowSleepButton

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow touchscreen')]
    [System.Nullable[System.Boolean]] $KioskModeAllowTouchscreen

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow the user to toggle voice control in kiosk mode.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowVoiceControlModification

    [DscProperty()]
    [System.ComponentModel.Description('Users can turn VoiceOver on or off.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowVoiceOverSettings

    [DscProperty()]
    [System.ComponentModel.Description('Kiosk mode allow volume buttons')]
    [System.Nullable[System.Boolean]] $KioskModeAllowVolumeButtons

    [DscProperty()]
    [System.ComponentModel.Description('Users can turn zoom on or off.')]
    [System.Nullable[System.Boolean]] $KioskModeAllowZoomSettings

    [DscProperty()]
    [System.ComponentModel.Description('URL of app for kiosk mode, e.g. https://itunes.apple.com/us/app/work-folders/id950878067?mt=8')]
    [System.String] $KioskModeAppStoreUrl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates type of app in kiosk mode.')]
    [ValidateSet('notConfigured', 'appStoreApp', 'managedApp', 'builtInApp')]
    [System.String] $KioskModeAppType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the auto-lock while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockAutoLock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the ringer switch while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockRingerSwitch

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the screen rotation while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockScreenRotation

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the sleep button while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockSleepButton

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the touchscreen while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockTouchscreen

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the volume buttons while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeBlockVolumeButtons

    [DscProperty()]
    [System.ComponentModel.Description('To see a list of bundle IDs for common built-in iOS apps, see the Intune documentation.')]
    [System.String] $KioskModeBuiltInAppId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enable the voice control while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeEnableVoiceControl

    [DscProperty()]
    [System.ComponentModel.Description('Add managed Intune apps from the Software Node.')]
    [System.String] $KioskModeManagedAppId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce assistive touch while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeRequireAssistiveTouch

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce color inversion while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeRequireColorInversion

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce mono audio while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeRequireMonoAudio

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce voice control while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeRequireVoiceOver

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce zoom while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeRequireZoom

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using control center on the lock screen.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockControlCenter

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using the notification view on the lock screen.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockNotificationView

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using passbook when the device is locked.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockPassbook

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using the Today View on the lock screen.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockTodayView

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce managed pasteboard.')]
    [System.Nullable[System.Boolean]] $ManagedPasteboardRequired

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for apps.')]
    [ValidateSet('allAllowed', 'allBlocked', 'agesAbove4', 'agesAbove9', 'agesAbove12', 'agesAbove17')]
    [System.String] $MediaContentRatingApps

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for Australia')]
    [MSFT_MicrosoftGraphmediacontentratingaustralia] $MediaContentRatingAustralia

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for Canada')]
    [MSFT_MicrosoftGraphmediacontentratingcanada] $MediaContentRatingCanada

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for France')]
    [MSFT_MicrosoftGraphmediacontentratingfrance] $MediaContentRatingFrance

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for Germany')]
    [MSFT_MicrosoftGraphmediacontentratinggermany] $MediaContentRatingGermany

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for Ireland')]
    [MSFT_MicrosoftGraphmediacontentratingireland] $MediaContentRatingIreland

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for Japan')]
    [MSFT_MicrosoftGraphmediacontentratingjapan] $MediaContentRatingJapan

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for New Zealand')]
    [MSFT_MicrosoftGraphmediacontentratingnewzealand] $MediaContentRatingNewZealand

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for United Kingdom')]
    [MSFT_MicrosoftGraphmediacontentratingunitedkingdom] $MediaContentRatingUnitedKingdom

    [DscProperty()]
    [System.ComponentModel.Description('Media content rating settings for United States')]
    [MSFT_MicrosoftGraphmediacontentratingunitedstates] $MediaContentRatingUnitedStates

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using the Messages app on the supervised device.')]
    [System.Nullable[System.Boolean]] $MessagesBlocked

    [DscProperty()]
    [System.ComponentModel.Description('If you don''t add any managed apps, the configured settings will apply to all managed apps by default. If you add specific managed apps, the configured settings will apply to only those apps.')]
    [MSFT_MicrosoftGraphiosnetworkusagerule[]] $NetworkUsageRules

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using nfc on the supervised device.')]
    [System.Nullable[System.Boolean]] $NfcBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow notifications settings modification (iOS 9.3 and later).')]
    [System.Nullable[System.Boolean]] $NotificationsBlockSettingsModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce on device only dictation.')]
    [System.Nullable[System.Boolean]] $OnDeviceOnlyDictationForced

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enforce on device only translation.')]
    [System.Nullable[System.Boolean]] $OnDeviceOnlyTranslationForced

    [DscProperty()]
    [System.ComponentModel.Description('Block users from adding, changing, or removing fingerprints and faces. Face ID is available in iOS 11.0 and later.')]
    [System.Nullable[System.Boolean]] $PasscodeBlockFingerprintModification

    [DscProperty()]
    [System.ComponentModel.Description('Face ID is available on iOS 11.0 and later.')]
    [System.Nullable[System.Boolean]] $PasscodeBlockFingerprintUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Block passcode from being added, changed or removed. Changes to passcode restrictions will be ignored on supervised devices after blocking passcode modification.')]
    [System.Nullable[System.Boolean]] $PasscodeBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Block simple password sequences, such as 1234 or 1111.')]
    [System.Nullable[System.Boolean]] $PasscodeBlockSimple

    [DscProperty()]
    [System.ComponentModel.Description('Number of days until device password must be changed. (1-65535)')]
    [System.Nullable[System.UInt32]] $PasscodeExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Minimum number (0-4) of non-alphanumeric characters, such as #, %, !, etc., required in the password. The default value is 0.')]
    [System.Nullable[System.UInt32]] $PasscodeMinimumCharacterSetCount

    [DscProperty()]
    [System.ComponentModel.Description('Minimum number of digits or characters in password. (4-14)')]
    [System.Nullable[System.UInt32]] $PasscodeMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Set to 0 to require a password immediately. There is no maximum number of minutes, and this number overrides the number currently set on the device. (This compliance check is supported for devices with OS versions iOS 8.0 and above)')]
    [System.Nullable[System.UInt32]] $PasscodeMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('Set to 0 to use the device''s minimum possible value. This number (0-60) overrides the number currently set on the device. If set to Immediately, devices will use the minimum possible value per device.')]
    [System.Nullable[System.UInt32]] $PasscodeMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Number of new passwords that must be used until an old one can be reused. (1-24)')]
    [System.Nullable[System.UInt32]] $PasscodePreviousPasscodeBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('In addition to requiring a password on all devices, this setting enforces a non-simple, 6-digit password requirement (regardless of other password settings you configure) on devices that are enrolled with Apple user enrollment.')]
    [System.Nullable[System.Boolean]] $PasscodeRequired

    [DscProperty()]
    [System.ComponentModel.Description('Type of passcode that is required.')]
    [ValidateSet('deviceDefault', 'alphanumeric', 'numeric')]
    [System.String] $PasscodeRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Number of consecutive times an incorrect password can be entered before device is wiped of all data. (2-11)')]
    [System.Nullable[System.UInt32]] $PasscodeSignInFailureCountBeforeWipe

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block AirDrop password sharing')]
    [System.Nullable[System.Boolean]] $PasswordBlockAirDropSharing

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block password autofill.')]
    [System.Nullable[System.Boolean]] $PasswordBlockAutoFill

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block password proximity requests.')]
    [System.Nullable[System.Boolean]] $PasswordBlockProximityRequests

    [DscProperty()]
    [System.ComponentModel.Description('Allows your users to receive software updates without connecting their devices to a computer')]
    [System.Nullable[System.Boolean]] $PkiBlockOTAUpdates

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block podcasts.')]
    [System.Nullable[System.Boolean]] $PodcastsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Disables device advertising identifier')]
    [System.Nullable[System.Boolean]] $PrivacyForceLimitAdTracking

    [DscProperty()]
    [System.ComponentModel.Description('Block user''s from using their Apple devices to set up and configure other Apple devices.')]
    [System.Nullable[System.Boolean]] $ProximityBlockSetupToNewDevice

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Safari autofill.')]
    [System.Nullable[System.Boolean]] $SafariBlockAutofill

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Safari. For supervised devices as of iOS 13.0.')]
    [System.Nullable[System.Boolean]] $SafariBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block javascript in Safari.')]
    [System.Nullable[System.Boolean]] $SafariBlockJavaScript

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block popups on Safari.')]
    [System.Nullable[System.Boolean]] $SafariBlockPopups

    [DscProperty()]
    [System.ComponentModel.Description('Cookie settings for Safari.')]
    [ValidateSet('browserDefault', 'blockAlways', 'allowCurrentWebSite', 'allowFromWebsitesVisited', 'allowAlways')]
    [System.String] $SafariCookieSettings

    [DscProperty()]
    [System.ComponentModel.Description('Documents downloaded from the URLs you specify here will be considered managed (Safari only).')]
    [System.String[]] $SafariManagedDomains

    [DscProperty()]
    [System.ComponentModel.Description('Users can save passwords in Safari only from URLs matching the patterns you specify here. To use this setting, the device must be in supervised mode and not configured for multiple users. (iOS 9.3+)')]
    [System.String[]] $SafariPasswordAutoFillDomains

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require fraud warning in Safari.')]
    [System.Nullable[System.Boolean]] $SafariRequireFraudWarning

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from taking Screenshots')]
    [System.Nullable[System.Boolean]] $ScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block temporary sessions on shared devices.')]
    [System.Nullable[System.Boolean]] $SharedDeviceBlockTemporarySessions

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Siri.')]
    [System.Nullable[System.Boolean]] $SiriBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Siri when locked.')]
    [System.Nullable[System.Boolean]] $SiriBlockedWhenLocked

    [DscProperty()]
    [System.ComponentModel.Description('Block Siri from querying user-generated content from the internet.')]
    [System.Nullable[System.Boolean]] $SiriBlockUserGeneratedContent

    [DscProperty()]
    [System.ComponentModel.Description('Prevents Siri from dictating, or speaking profane language.')]
    [System.Nullable[System.Boolean]] $SiriRequireProfanityFilter

    [DscProperty()]
    [System.ComponentModel.Description('Delay the user''s software update for this many days. The maximum is 90 days. (1-90)')]
    [System.Nullable[System.UInt32]] $SoftwareUpdatesEnforcedDelayInDays

    [DscProperty()]
    [System.ComponentModel.Description('Delay user visibility of Software Updates. This does not impact any scheduled updates. It represents days before software updates are visible to end users after release.')]
    [System.Nullable[System.Boolean]] $SoftwareUpdatesForceDelayed

    [DscProperty()]
    [System.ComponentModel.Description('Blocks Spotlight from returning any results from an Internet search.')]
    [System.Nullable[System.Boolean]] $SpotlightBlockInternetResults

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to boot devices into recovery mode with unpaired devices. Available for devices running iOS and iPadOS versions 14.5 and later.')]
    [System.Nullable[System.Boolean]] $UnpairedExternalBootToRecoveryAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Blocks USB Restricted mode. USB Restricted mode blocks USB accessories from exchanging data with a device that has been locked over an hour.')]
    [System.Nullable[System.Boolean]] $UsbRestrictedModeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block voice dialing.')]
    [System.Nullable[System.Boolean]] $VoiceDialingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocks the creation of VPN configurations')]
    [System.Nullable[System.Boolean]] $VpnBlockCreation

    [DscProperty()]
    [System.ComponentModel.Description('Block wallpaper from being changed.')]
    [System.Nullable[System.Boolean]] $WallpaperBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Force the device to use only Wi-Fi networks set up through configuration profiles.')]
    [System.Nullable[System.Boolean]] $WiFiConnectOnlyToConfiguredNetworks

    [DscProperty()]
    [System.ComponentModel.Description('Require devices to use Wi-Fi networks set up via configuration profiles. Available for devices running iOS and iPadOS versions 14.5 and later.')]
    [System.Nullable[System.Boolean]] $WiFiConnectToAllowedNetworksOnlyForced

    [DscProperty()]
    [System.ComponentModel.Description('Wi-Fi can''t be turned off in the Settings app or in the Control Center, even when the device is in airplane mode. Available for iOS/iPadOS 13.0 and later.')]
    [System.Nullable[System.Boolean]] $WifiPowerOnForced

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceConfigurationPolicyiOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationPolicyiOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy for iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if (-not $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.iosGeneralDeviceConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Nothing with id {$($this.id)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "Found something with id {$($this.id)}"
            $results = @{
                #region resource generator code
                Id                                             = $getValue.Id
                Description                                    = $getValue.Description
                DisplayName                                    = $getValue.DisplayName
                RoleScopeTagIds                                = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                AccountBlockModification                       = $getValue.accountBlockModification
                ActivationLockAllowWhenSupervised              = $getValue.activationLockAllowWhenSupervised
                AirDropBlocked                                 = $getValue.airDropBlocked
                AirDropForceUnmanagedDropTarget                = $getValue.airDropForceUnmanagedDropTarget
                AirPlayForcePairingPasswordForOutgoingRequests = $getValue.airPlayForcePairingPasswordForOutgoingRequests
                AirPrintBlockCredentialsStorage                = $getValue.airPrintBlockCredentialsStorage
                AirPrintBlocked                                = $getValue.airPrintBlocked
                AirPrintBlockiBeaconDiscovery                  = $getValue.airPrintBlockiBeaconDiscovery
                AirPrintForceTrustedTLS                        = $getValue.airPrintForceTrustedTLS
                AppClipsBlocked                                = $getValue.appClipsBlocked
                AppleNewsBlocked                               = $getValue.appleNewsBlocked
                ApplePersonalizedAdsBlocked                    = $getValue.applePersonalizedAdsBlocked
                AppleWatchBlockPairing                         = $getValue.appleWatchBlockPairing
                AppleWatchForceWristDetection                  = $getValue.appleWatchForceWristDetection
                AppRemovalBlocked                              = $getValue.appRemovalBlocked
                AppStoreBlockAutomaticDownloads                = $getValue.appStoreBlockAutomaticDownloads
                AppStoreBlocked                                = $getValue.appStoreBlocked
                AppStoreBlockInAppPurchases                    = $getValue.appStoreBlockInAppPurchases
                AppStoreBlockUIAppInstallation                 = $getValue.appStoreBlockUIAppInstallation
                AppStoreRequirePassword                        = $getValue.appStoreRequirePassword
                AppsVisibilityListType                         = $getValue.appsVisibilityListType
                AutoFillForceAuthentication                    = $getValue.autoFillForceAuthentication
                AutoUnlockBlocked                              = $getValue.autoUnlockBlocked
                BlockSystemAppRemoval                          = $getValue.blockSystemAppRemoval
                BluetoothBlockModification                     = $getValue.bluetoothBlockModification
                CameraBlocked                                  = $getValue.cameraBlocked
                CellularBlockDataRoaming                       = $getValue.cellularBlockDataRoaming
                CellularBlockGlobalBackgroundFetchWhileRoaming = $getValue.cellularBlockGlobalBackgroundFetchWhileRoaming
                CellularBlockPerAppDataModification            = $getValue.cellularBlockPerAppDataModification
                CellularBlockPersonalHotspot                   = $getValue.cellularBlockPersonalHotspot
                CellularBlockPersonalHotspotModification       = $getValue.cellularBlockPersonalHotspotModification
                CellularBlockPlanModification                  = $getValue.cellularBlockPlanModification
                CellularBlockVoiceRoaming                      = $getValue.cellularBlockVoiceRoaming
                CertificatesBlockUntrustedTlsCertificates      = $getValue.certificatesBlockUntrustedTlsCertificates
                ClassroomAppBlockRemoteScreenObservation       = $getValue.classroomAppBlockRemoteScreenObservation
                ClassroomAppForceUnpromptedScreenObservation   = $getValue.classroomAppForceUnpromptedScreenObservation
                ClassroomForceAutomaticallyJoinClasses         = $getValue.classroomForceAutomaticallyJoinClasses
                ClassroomForceRequestPermissionToLeaveClasses  = $getValue.classroomForceRequestPermissionToLeaveClasses
                ClassroomForceUnpromptedAppAndDeviceLock       = $getValue.classroomForceUnpromptedAppAndDeviceLock
                CompliantAppListType                           = $getValue.compliantAppListType
                ConfigurationProfileBlockChanges               = $getValue.configurationProfileBlockChanges
                ContactsAllowManagedToUnmanagedWrite           = $getValue.contactsAllowManagedToUnmanagedWrite
                ContactsAllowUnmanagedToManagedRead            = $getValue.contactsAllowUnmanagedToManagedRead
                ContinuousPathKeyboardBlocked                  = $getValue.continuousPathKeyboardBlocked
                DateAndTimeForceSetAutomatically               = $getValue.dateAndTimeForceSetAutomatically
                DefinitionLookupBlocked                        = $getValue.definitionLookupBlocked
                DeviceBlockEnableRestrictions                  = $getValue.deviceBlockEnableRestrictions
                DeviceBlockEraseContentAndSettings             = $getValue.deviceBlockEraseContentAndSettings
                DeviceBlockNameModification                    = $getValue.deviceBlockNameModification
                DiagnosticDataBlockSubmission                  = $getValue.diagnosticDataBlockSubmission
                DiagnosticDataBlockSubmissionModification      = $getValue.diagnosticDataBlockSubmissionModification
                DocumentsBlockManagedDocumentsInUnmanagedApps  = $getValue.documentsBlockManagedDocumentsInUnmanagedApps
                DocumentsBlockUnmanagedDocumentsInManagedApps  = $getValue.documentsBlockUnmanagedDocumentsInManagedApps
                EmailInDomainSuffixes                          = $getValue.emailInDomainSuffixes
                EnterpriseAppBlockTrust                        = $getValue.enterpriseAppBlockTrust
                EnterpriseAppBlockTrustModification            = $getValue.enterpriseAppBlockTrustModification
                EnterpriseBookBlockBackup                      = $getValue.enterpriseBookBlockBackup
                EnterpriseBookBlockMetadataSync                = $getValue.enterpriseBookBlockMetadataSync
                EsimBlockModification                          = $getValue.esimBlockModification
                FaceTimeBlocked                                = $getValue.faceTimeBlocked
                FilesNetworkDriveAccessBlocked                 = $getValue.filesNetworkDriveAccessBlocked
                FilesUsbDriveAccessBlocked                     = $getValue.filesUsbDriveAccessBlocked
                FindMyDeviceInFindMyAppBlocked                 = $getValue.findMyDeviceInFindMyAppBlocked
                FindMyFriendsBlocked                           = $getValue.findMyFriendsBlocked
                FindMyFriendsInFindMyAppBlocked                = $getValue.findMyFriendsInFindMyAppBlocked
                GameCenterBlocked                              = $getValue.gameCenterBlocked
                GamingBlockGameCenterFriends                   = $getValue.gamingBlockGameCenterFriends
                GamingBlockMultiplayer                         = $getValue.gamingBlockMultiplayer
                HostPairingBlocked                             = $getValue.hostPairingBlocked
                IBooksStoreBlocked                             = $getValue.iBooksStoreBlocked
                IBooksStoreBlockErotica                        = $getValue.iBooksStoreBlockErotica
                ICloudBlockActivityContinuation                = $getValue.iCloudBlockActivityContinuation
                ICloudBlockBackup                              = $getValue.iCloudBlockBackup
                ICloudBlockDocumentSync                        = $getValue.iCloudBlockDocumentSync
                ICloudBlockManagedAppsSync                     = $getValue.iCloudBlockManagedAppsSync
                ICloudBlockPhotoLibrary                        = $getValue.iCloudBlockPhotoLibrary
                ICloudBlockPhotoStreamSync                     = $getValue.iCloudBlockPhotoStreamSync
                ICloudBlockSharedPhotoStream                   = $getValue.iCloudBlockSharedPhotoStream
                ICloudPrivateRelayBlocked                      = $getValue.iCloudPrivateRelayBlocked
                ICloudRequireEncryptedBackup                   = $getValue.iCloudRequireEncryptedBackup
                ITunesBlocked                                  = $getValue.iTunesBlocked
                ITunesBlockExplicitContent                     = $getValue.iTunesBlockExplicitContent
                ITunesBlockMusicService                        = $getValue.iTunesBlockMusicService
                ITunesBlockRadio                               = $getValue.iTunesBlockRadio
                KeyboardBlockAutoCorrect                       = $getValue.keyboardBlockAutoCorrect
                KeyboardBlockDictation                         = $getValue.keyboardBlockDictation
                KeyboardBlockPredictive                        = $getValue.keyboardBlockPredictive
                KeyboardBlockShortcuts                         = $getValue.keyboardBlockShortcuts
                KeyboardBlockSpellCheck                        = $getValue.keyboardBlockSpellCheck
                KeychainBlockCloudSync                         = $getValue.keychainBlockCloudSync
                KioskModeAllowAssistiveSpeak                   = $getValue.kioskModeAllowAssistiveSpeak
                KioskModeAllowAssistiveTouchSettings           = $getValue.kioskModeAllowAssistiveTouchSettings
                KioskModeAllowAutoLock                         = $getValue.kioskModeAllowAutoLock
                KioskModeAllowColorInversionSettings           = $getValue.kioskModeAllowColorInversionSettings
                KioskModeAllowRingerSwitch                     = $getValue.kioskModeAllowRingerSwitch
                KioskModeAllowScreenRotation                   = $getValue.kioskModeAllowScreenRotation
                KioskModeAllowSleepButton                      = $getValue.kioskModeAllowSleepButton
                KioskModeAllowTouchscreen                      = $getValue.kioskModeAllowTouchscreen
                KioskModeAllowVoiceControlModification         = $getValue.kioskModeAllowVoiceControlModification
                KioskModeAllowVoiceOverSettings                = $getValue.kioskModeAllowVoiceOverSettings
                KioskModeAllowVolumeButtons                    = $getValue.kioskModeAllowVolumeButtons
                KioskModeAllowZoomSettings                     = $getValue.kioskModeAllowZoomSettings
                KioskModeAppStoreUrl                           = $getValue.kioskModeAppStoreUrl
                KioskModeAppType                               = $getValue.kioskModeAppType
                KioskModeBlockAutoLock                         = $getValue.kioskModeBlockAutoLock
                KioskModeBlockRingerSwitch                     = $getValue.kioskModeBlockRingerSwitch
                KioskModeBlockScreenRotation                   = $getValue.kioskModeBlockScreenRotation
                KioskModeBlockSleepButton                      = $getValue.kioskModeBlockSleepButton
                KioskModeBlockTouchscreen                      = $getValue.kioskModeBlockTouchscreen
                KioskModeBlockVolumeButtons                    = $getValue.kioskModeBlockVolumeButtons
                KioskModeBuiltInAppId                          = $getValue.kioskModeBuiltInAppId
                KioskModeEnableVoiceControl                    = $getValue.kioskModeEnableVoiceControl
                KioskModeManagedAppId                          = $getValue.kioskModeManagedAppId
                KioskModeRequireAssistiveTouch                 = $getValue.kioskModeRequireAssistiveTouch
                KioskModeRequireColorInversion                 = $getValue.kioskModeRequireColorInversion
                KioskModeRequireMonoAudio                      = $getValue.kioskModeRequireMonoAudio
                KioskModeRequireVoiceOver                      = $getValue.kioskModeRequireVoiceOver
                KioskModeRequireZoom                           = $getValue.kioskModeRequireZoom
                LockScreenBlockControlCenter                   = $getValue.lockScreenBlockControlCenter
                LockScreenBlockNotificationView                = $getValue.lockScreenBlockNotificationView
                LockScreenBlockPassbook                        = $getValue.lockScreenBlockPassbook
                LockScreenBlockTodayView                       = $getValue.lockScreenBlockTodayView
                ManagedPasteboardRequired                      = $getValue.managedPasteboardRequired
                MediaContentRatingApps                         = $getValue.mediaContentRatingApps
                MessagesBlocked                                = $getValue.messagesBlocked
                NfcBlocked                                     = $getValue.nfcBlocked
                NotificationsBlockSettingsModification         = $getValue.notificationsBlockSettingsModification
                OnDeviceOnlyDictationForced                    = $getValue.onDeviceOnlyDictationForced
                OnDeviceOnlyTranslationForced                  = $getValue.onDeviceOnlyTranslationForced
                PasscodeBlockFingerprintModification           = $getValue.passcodeBlockFingerprintModification
                PasscodeBlockFingerprintUnlock                 = $getValue.passcodeBlockFingerprintUnlock
                PasscodeBlockModification                      = $getValue.passcodeBlockModification
                PasscodeBlockSimple                            = $getValue.passcodeBlockSimple
                PasscodeExpirationDays                         = $getValue.passcodeExpirationDays
                PasscodeMinimumCharacterSetCount               = $getValue.passcodeMinimumCharacterSetCount
                PasscodeMinimumLength                          = $getValue.passcodeMinimumLength
                PasscodeMinutesOfInactivityBeforeLock          = $getValue.passcodeMinutesOfInactivityBeforeLock
                PasscodeMinutesOfInactivityBeforeScreenTimeout = $getValue.passcodeMinutesOfInactivityBeforeScreenTimeout
                PasscodePreviousPasscodeBlockCount             = $getValue.passcodePreviousPasscodeBlockCount
                PasscodeRequired                               = $getValue.passcodeRequired
                PasscodeRequiredType                           = $getValue.passcodeRequiredType
                PasscodeSignInFailureCountBeforeWipe           = $getValue.passcodeSignInFailureCountBeforeWipe
                PasswordBlockAirDropSharing                    = $getValue.passwordBlockAirDropSharing
                PasswordBlockAutoFill                          = $getValue.passwordBlockAutoFill
                PasswordBlockProximityRequests                 = $getValue.passwordBlockProximityRequests
                PkiBlockOTAUpdates                             = $getValue.pkiBlockOTAUpdates
                PodcastsBlocked                                = $getValue.podcastsBlocked
                PrivacyForceLimitAdTracking                    = $getValue.privacyForceLimitAdTracking
                ProximityBlockSetupToNewDevice                 = $getValue.proximityBlockSetupToNewDevice
                SafariBlockAutofill                            = $getValue.safariBlockAutofill
                SafariBlocked                                  = $getValue.safariBlocked
                SafariBlockJavaScript                          = $getValue.safariBlockJavaScript
                SafariBlockPopups                              = $getValue.safariBlockPopups
                SafariCookieSettings                           = $getValue.safariCookieSettings
                SafariManagedDomains                           = $getValue.safariManagedDomains
                SafariPasswordAutoFillDomains                  = $getValue.safariPasswordAutoFillDomains
                SafariRequireFraudWarning                      = $getValue.safariRequireFraudWarning
                ScreenCaptureBlocked                           = $getValue.screenCaptureBlocked
                SharedDeviceBlockTemporarySessions             = $getValue.sharedDeviceBlockTemporarySessions
                SiriBlocked                                    = $getValue.siriBlocked
                SiriBlockedWhenLocked                          = $getValue.siriBlockedWhenLocked
                SiriBlockUserGeneratedContent                  = $getValue.siriBlockUserGeneratedContent
                SiriRequireProfanityFilter                     = $getValue.siriRequireProfanityFilter
                SoftwareUpdatesEnforcedDelayInDays             = $getValue.softwareUpdatesEnforcedDelayInDays
                SoftwareUpdatesForceDelayed                    = $getValue.softwareUpdatesForceDelayed
                SpotlightBlockInternetResults                  = $getValue.spotlightBlockInternetResults
                UnpairedExternalBootToRecoveryAllowed          = $getValue.unpairedExternalBootToRecoveryAllowed
                UsbRestrictedModeBlocked                       = $getValue.usbRestrictedModeBlocked
                VoiceDialingBlocked                            = $getValue.voiceDialingBlocked
                VpnBlockCreation                               = $getValue.vpnBlockCreation
                WallpaperBlockModification                     = $getValue.wallpaperBlockModification
                WiFiConnectOnlyToConfiguredNetworks            = $getValue.wiFiConnectOnlyToConfiguredNetworks
                WiFiConnectToAllowedNetworksOnlyForced         = $getValue.wiFiConnectToAllowedNetworksOnlyForced
                WifiPowerOnForced                              = $getValue.wifiPowerOnForced
                ManagedIdentity                                = $this.ManagedIdentity
                Ensure                                         = 'Present'
                Credential                                     = $this.Credential
                ApplicationId                                  = $this.ApplicationId
                TenantId                                       = $this.TenantId
                ApplicationSecret                              = $this.ApplicationSecret
                CertificateThumbprint                          = $this.CertificateThumbprint
                AccessTokens                                   = $this.AccessTokens
            }

            $complexAppsSingleAppModeList = @()
            $currentValueArray = $getValue.appsSingleAppModeList
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = @{}
                    $currentHash.Add('AppId', $currentValue.appId)
                    $currentHash.Add('Publisher', $currentValue.publisher)
                    $currentHash.Add('AppStoreUrl', $currentValue.appStoreUrl)
                    $currentHash.Add('Name', $currentValue.name)
                    $currentHash.Add('oDataType', $currentValue.'@odata.type')
                    $complexAppsSingleAppModeList += $currentHash
                }
            }
            $results.Add('AppsSingleAppModeList', $complexAppsSingleAppModeList)

            $complexAppsVisibilityList = @()
            $currentValueArray = $getValue.appsVisibilityList
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = @{}
                    $currentHash.Add('AppId', $currentValue.appId)
                    $currentHash.Add('Publisher', $currentValue.publisher)
                    $currentHash.Add('AppStoreUrl', $currentValue.appStoreUrl)
                    $currentHash.Add('Name', $currentValue.name)
                    $currentHash.Add('oDataType', $currentValue.'@odata.type')
                    $complexAppsVisibilityList += $currentHash
                }
            }
            $results.Add('AppsVisibilityList', $complexAppsVisibilityList)

            $complexCompliantAppsList = @()
            $currentValueArray = $getValue.compliantAppsList
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = @{}
                    $currentHash.Add('AppId', $currentValue.appId)
                    $currentHash.Add('Publisher', $currentValue.publisher)
                    $currentHash.Add('AppStoreUrl', $currentValue.appStoreUrl)
                    $currentHash.Add('Name', $currentValue.name)
                    $currentHash.Add('oDataType', $currentValue.'@odata.type')
                    $complexCompliantAppsList += $currentHash
                }
            }
            $results.Add('CompliantAppsList', $complexCompliantAppsList)

            $ratingCountries = @(
                'Australia'
                'Canada'
                'France'
                'Germany'
                'Ireland'
                'Japan'
                'NewZealand'
                'UnitedKingdom'
                'UnitedStates'
            )
            foreach ($country in $ratingCountries)
            {
                $complexMediaContentRating = [ordered]@{}
                $currentValue = $getValue."mediaContentRating$country"
                if ($null -ne $currentValue)
                {
                    $complexMediaContentRating.Add('MovieRating', $currentValue.movieRating)
                    $complexMediaContentRating.Add('TvRating', $currentValue.tvRating)
                }
                $results.Add("MediaContentRating$country", $complexMediaContentRating)
            }
            <#$results.Add('MediaContentRatingCanada', $getValue.mediaContentRatingCanada)
            $results.Add('MediaContentRatingFrance', $getValue.mediaContentRatingFrance)
            $results.Add('MediaContentRatingGermany', $getValue.mediaContentRatingGermany)
            $results.Add('MediaContentRatingIreland', $getValue.mediaContentRatingIreland)
            $results.Add('MediaContentRatingJapan', $getValue.mediaContentRatingJapan)
            $results.Add('MediaContentRatingNewZealand', $getValue.mediaContentRatingNewZealand)
            $results.Add('MediaContentRatingUnitedKingdom', $getValue.mediaContentRatingUnitedKingdom)
            $results.Add('MediaContentRatingUnitedStates', $getValue.mediaContentRatingUnitedStates)#>

            $complexNetworkUsageRules = @()
            $currentValueArray = $getValue.networkUsageRules
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentValueHash = @{}
                    $currentValueHash.Add('CellularDataBlocked', $currentValue.cellularDataBlocked)
                    $currentValueHash.Add('CellularDataBlockWhenRoaming', $currentValue.cellularDataBlockWhenRoaming)
                    $complexManagedApps = @()
                    $currentValueChildArray = $currentValue.managedApps
                    if ($null -ne $currentValueChildArray -and $currentValueChildArray.Count -gt 0)
                    {
                        foreach ($currentChildValue in $currentValueChildArray)
                        {
                            $currentHash = @{}
                            $currentHash.Add('AppId', $currentChildValue.appId)
                            $currentHash.Add('Publisher', $currentChildValue.publisher)
                            $currentHash.Add('AppStoreUrl', $currentChildValue.appStoreUrl)
                            $currentHash.Add('Name', $currentChildValue.name)
                            $currentHash.Add('oDataType', '#microsoft.graph.appleAppListItem')
                            $complexManagedApps += $currentHash
                        }
                    }
                    $currentValueHash.Add('ManagedApps', $complexManagedApps)
                    $complexNetworkUsageRules += $currentValueHash
                }
            }
            $results.Add('NetworkUsageRules', $complexNetworkUsageRules)

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $getValue.Id
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
            }
            $results.Add('Assignments', $assignmentResult)

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Device Configuration Policy iOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('Assignments') | Out-Null
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        foreach ($rule in $boundParameters.networkUsageRules)
        {
            foreach ($app in $rule.managedApps)
            {
                $app.Remove('@odata.type')
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.iosGeneralDeviceConfiguration')

            #region resource generator code
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.iosGeneralDeviceConfiguration')

            #region resource generator code
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.DisplayName)}"

            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.iosGeneralDeviceConfiguration' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.displayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($Results.AppsSingleAppModeList)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.AppsSingleAppModeList -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.AppsSingleAppModeList = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AppsSingleAppModeList') | Out-Null
                    }
                }
                if ($Results.AppsVisibilityList)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.AppsVisibilityList -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.AppsVisibilityList = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AppsVisibilityList') | Out-Null
                    }
                }
                if ($Results.CompliantAppsList)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.CompliantAppsList -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.CompliantAppsList = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CompliantAppsList') | Out-Null
                    }
                }
                if ($Results.MediaContentRatingAustralia.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingAustralia -CIMInstanceName MicrosoftGraphmediacontentratingaustralia
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingAustralia = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingAustralia') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingAustralia') | Out-Null
                }
                if ($Results.MediaContentRatingCanada.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingCanada -CIMInstanceName MicrosoftGraphmediacontentratingcanada
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingCanada = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingCanada') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingCanada') | Out-Null
                }
                if ($Results.MediaContentRatingFrance.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingFrance -CIMInstanceName MicrosoftGraphmediacontentratingfrance
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingFrance = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingFrance') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingFrance') | Out-Null
                }
                if ($Results.MediaContentRatingGermany.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingGermany -CIMInstanceName MicrosoftGraphmediacontentratinggermany
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingGermany = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingGermany') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingGermany') | Out-Null
                }
                if ($Results.MediaContentRatingIreland.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingIreland -CIMInstanceName MicrosoftGraphmediacontentratingireland
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingIreland = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingIreland') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingIreland') | Out-Null
                }
                if ($Results.MediaContentRatingJapan.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingJapan -CIMInstanceName MicrosoftGraphmediacontentratingjapan
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingJapan = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingJapan') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingJapan') | Out-Null
                }
                if ($Results.MediaContentRatingNewZealand.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingNewZealand -CIMInstanceName MicrosoftGraphmediacontentratingnewzealand
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingNewZealand = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingNewZealand') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingNewZealand') | Out-Null
                }
                if ($Results.MediaContentRatingUnitedKingdom.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingUnitedKingdom -CIMInstanceName MicrosoftGraphmediacontentratingunitedkingdom
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingUnitedKingdom = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingUnitedKingdom') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingUnitedKingdom') | Out-Null
                }
                if ($Results.MediaContentRatingUnitedStates.Count -gt 0)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.MediaContentRatingUnitedStates -CIMInstanceName MicrosoftGraphmediacontentratingunitedstates
                    if ($complexTypeStringResult)
                    {
                        $Results.MediaContentRatingUnitedStates = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MediaContentRatingUnitedStates') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('MediaContentRatingUnitedStates') | Out-Null
                }
                if ($Results.NetworkUsageRules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.NetworkUsageRules -CIMInstanceName MicrosoftGraphiosnetworkusagerule
                    if ($complexTypeStringResult)
                    {
                        $Results.NetworkUsageRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NetworkUsageRules') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AppsSingleAppModeList', 'AppsVisibilityList', 'CompliantAppsList', 'MediaContentRatingAustralia',
                    'MediaContentRatingCanada', 'MediaContentRatingFrance', 'MediaContentRatingGermany', 'MediaContentRatingIreland',
                    'MediaContentRatingJapan', 'MediaContentRatingNewZealand', 'MediaContentRatingUnitedKingdom',
                    'MediaContentRatingUnitedStates', 'NetworkUsageRules', 'Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceConfigurationPolicyiOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationPolicyiOS])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationPolicyiOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphapplistitem
{
    [DscProperty()]
    [System.ComponentModel.Description('odatatype of the item.')]
    [ValidateSet('#microsoft.graph.appleAppListItem')]
    [System.String] $odataType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Kiosk mode managed app id')]
    [System.String] $appId

    [DscProperty()]
    [System.ComponentModel.Description('Define the app store URL.')]
    [System.String] $appStoreUrl

    [DscProperty()]
    [System.ComponentModel.Description('Define the name of the app.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Define the publisher of the app.')]
    [System.String] $publisher
}

class MSFT_MicrosoftGraphmediacontentratingaustralia
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for Australia')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'mature', 'agesAbove15', 'agesAbove18')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for Australia')]
    [ValidateSet('allAllowed', 'allBlocked', 'preschoolers', 'children', 'general', 'parentalGuidance', 'mature', 'agesAbove15', 'agesAbove15AdultViolence')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingcanada
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for Canada')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'agesAbove14', 'agesAbove18', 'restricted')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for Canada')]
    [ValidateSet('allAllowed', 'allBlocked', 'children', 'childrenAbove8', 'general', 'parentalGuidance', 'agesAbove14', 'agesAbove18')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingfrance
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for France')]
    [ValidateSet('allAllowed', 'allBlocked', 'agesAbove10', 'agesAbove12', 'agesAbove16', 'agesAbove18')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for France')]
    [ValidateSet('allAllowed', 'allBlocked', 'agesAbove10', 'agesAbove12', 'agesAbove16', 'agesAbove18')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratinggermany
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for Germany')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'agesAbove6', 'agesAbove12', 'agesAbove16', 'adults')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for Germany')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'agesAbove6', 'agesAbove12', 'agesAbove16', 'adults')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingireland
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for Ireland')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'agesAbove12', 'agesAbove15', 'agesAbove16', 'adults')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for Ireland')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'children', 'youngAdults', 'parentalSupervision', 'mature')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingjapan
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for Japan')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'agesAbove15', 'agesAbove18')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for Japan')]
    [ValidateSet('allAllowed', 'allBlocked', 'explicitAllowed')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingnewzealand
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for New Zealand')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'mature', 'agesAbove13', 'agesAbove15', 'agesAbove16', 'agesAbove18', 'restricted', 'agesAbove16Restricted')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for New Zealand')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'adults')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingunitedkingdom
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for UK')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'universalChildren', 'parentalGuidance', 'agesAbove12Video', 'agesAbove12Cinema', 'agesAbove15', 'adults')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for UK')]
    [ValidateSet('allAllowed', 'allBlocked', 'caution')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphmediacontentratingunitedstates
{
    [DscProperty()]
    [System.ComponentModel.Description('Movies rating selected for USA')]
    [ValidateSet('allAllowed', 'allBlocked', 'general', 'parentalGuidance', 'parentalGuidance13', 'restricted', 'adults')]
    [System.String] $movieRating

    [DscProperty()]
    [System.ComponentModel.Description('TV rating selected for USA')]
    [ValidateSet('allAllowed', 'allBlocked', 'childrenAll', 'childrenAbove7', 'general', 'parentalGuidance', 'childrenAbove14', 'adults')]
    [System.String] $tvRating
}

class MSFT_MicrosoftGraphiosnetworkusagerule
{
    [DscProperty()]
    [System.ComponentModel.Description('If set to true, corresponding managed apps will not be allowed to use cellular data at any time.')]
    [System.Nullable[System.Boolean]] $cellularDataBlocked

    [DscProperty()]
    [System.ComponentModel.Description('If set to true, corresponding managed apps will not be allowed to use cellular data when roaming.')]
    [System.Nullable[System.Boolean]] $cellularDataBlockWhenRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Information about the managed apps that this rule is going to apply to.')]
    [MSFT_MicrosoftGraphapplistitem[]] $managedApps
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}
