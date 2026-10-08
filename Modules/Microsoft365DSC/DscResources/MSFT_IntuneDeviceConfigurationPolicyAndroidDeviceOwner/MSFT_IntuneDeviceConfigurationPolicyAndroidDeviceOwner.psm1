using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationPolicyAndroidDeviceOwner : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The Id of the policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Block modification of accounts. Only supported on Dedicated devices.')]
    [System.Nullable[System.Boolean]] $AccountsBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the list of managed apps with app details and its associated delegated scope(s). This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphandroiddeviceownerdelegatedscopeappsetting[]] $AndroidDeviceOwnerDelegatedScopeAppSettings

    [DscProperty()]
    [System.ComponentModel.Description('When allowed, users can enable the ''unknown sources'' setting to install apps from sources other than the Google Play Store.')]
    [System.Nullable[System.Boolean]] $AppsAllowInstallFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('Devices check for app updates daily. The default behavior is to let device users decide. They''ll be able to set their preferences in the managed Google Play app.')]
    [ValidateSet('notConfigured', 'userChoice', 'never', 'wiFiOnly', 'always')]
    [System.String] $AppsAutoUpdatePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Define the default permission policy for requests for runtime permissions.')]
    [ValidateSet('deviceDefault', 'prompt', 'autoGrant', 'autoDeny')]
    [System.String] $AppsDefaultPermissionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Enable a suggestion to apps that they skip their user tutorials and any introductory hints when they first start up, if applicable.')]
    [System.Nullable[System.Boolean]] $AppsRecommendSkippingFirstUseHints

    [DscProperty()]
    [System.ComponentModel.Description('A list of managed apps that will have their data cleared during a global sign-out in AAD shared device mode. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphapplistitem[]] $AzureAdSharedDeviceDataClearApps

    [DscProperty()]
    [System.ComponentModel.Description('Block configuring Bluetooth.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Block access to work contacts from another device such as a car system when an Android device is paired via Bluetooth.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockContactSharing

    [DscProperty()]
    [System.ComponentModel.Description('Block all cameras on the device')]
    [System.Nullable[System.Boolean]] $CameraBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block tethering and access to portable hotspots.')]
    [System.Nullable[System.Boolean]] $CellularBlockWiFiTethering

    [DscProperty()]
    [System.ComponentModel.Description('Blocks users from making any changes to credentials associated with certificates associated with certificates assigned to them.')]
    [System.Nullable[System.Boolean]] $CertificateCredentialConfigurationDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not text copied from one profile (personal or work) can be pasted in the other.')]
    [System.Nullable[System.Boolean]] $CrossProfilePoliciesAllowCopyPaste

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether data from one profile (personal or work) can be shared with apps in the other profile.')]
    [ValidateSet('notConfigured', 'crossProfileDataSharingBlocked', 'dataSharingFromWorkToPersonalBlocked', 'crossProfileDataSharingAllowed', 'unkownFutureValue')]
    [System.String] $CrossProfilePoliciesAllowDataSharing

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not contacts stored in work profile are shown in personal profile contact searches/incoming calls.')]
    [System.Nullable[System.Boolean]] $CrossProfilePoliciesShowWorkContactsInPersonalProfile

    [DscProperty()]
    [System.ComponentModel.Description('Block data roaming.')]
    [System.Nullable[System.Boolean]] $DataRoamingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block user from manually setting the date and time.')]
    [System.Nullable[System.Boolean]] $DateTimeConfigurationBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Represents the customized detailed help text provided to users when they attempt to modify managed settings on their device.')]
    [MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage] $DetailedHelpText

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the location setting configuration for fully managed devices (COBO) and corporate owned devices with a work profile (COPE).')]
    [ValidateSet('disabled', 'notConfigured', 'unknownFutureValue')]
    [System.String] $DeviceLocationMode

    [DscProperty()]
    [System.ComponentModel.Description('Represents the customized lock screen message provided to users when they attempt to modify managed settings on their device.')]
    [MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage] $DeviceOwnerLockScreenMessage

    [DscProperty()]
    [System.ComponentModel.Description('Represents the enrollment profile type.')]
    [ValidateSet('notConfigured', 'dedicatedDevice', 'fullyManaged')]
    [System.String] $EnrollmentProfile

    [DscProperty()]
    [System.ComponentModel.Description('Block factory resetting from settings.')]
    [System.Nullable[System.Boolean]] $FactoryResetBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Email addresses of device admins for factory reset protection. When a device is factory reset, it will require that one of these admins log in with their Google account to unlock the device. If none are specified, factory reset protection is not enabled.')]
    [System.String[]] $FactoryResetDeviceAdministratorEmails

    [DscProperty()]
    [System.ComponentModel.Description('Proxy is set up directly with host, port and excluded hosts.')]
    [MSFT_MicrosoftGraphandroiddeviceownerglobalproxy] $GlobalProxy

    [DscProperty()]
    [System.ComponentModel.Description('Blocking prevents users from adding their personal Google account to their device.')]
    [System.Nullable[System.Boolean]] $GoogleAccountsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether a user can access the device''s Settings app while in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskCustomizationDeviceSettingsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Whether the power menu is shown when a user long presses the Power button of a device in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskCustomizationPowerButtonActionsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether system info and notifications are disabled in Kiosk Mode')]
    [ValidateSet('notConfigured', 'notificationsAndSystemInfoEnabled', 'systemInfoOnly')]
    [System.String] $KioskCustomizationStatusBar

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether system error dialogs for crashed or unresponsive apps are shown in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskCustomizationSystemErrorWarnings

    [DscProperty()]
    [System.ComponentModel.Description('Indicates which navigation features are enabled in Kiosk Mode.')]
    [ValidateSet('notConfigured', 'navigationEnabled', 'homeButtonOnly')]
    [System.String] $KioskCustomizationSystemNavigation

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to enable app ordering in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeAppOrderEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ordering of items on Kiosk Mode Managed Home Screen. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem[]] $KioskModeAppPositions

    [DscProperty()]
    [System.ComponentModel.Description('A list of managed apps that will be shown when the device is in Kiosk Mode. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphapplistitem[]] $KioskModeApps

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to alphabetize applications within a folder in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeAppsInFolderOrderedByName

    [DscProperty()]
    [System.ComponentModel.Description('Enable end-users to configure and pair devices over Bluetooth.')]
    [System.Nullable[System.Boolean]] $KioskModeBluetoothConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to allow a user to easy access to the debug menu in Kiosk Mode')]
    [System.Nullable[System.Boolean]] $KioskModeDebugMenuEasyAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The 4-6 digit PIN will be the code an IT administrator enters on a multi-app dedicated device to pause kiosk mode.')]
    [System.String] $KioskModeExitCode

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to allow a user to use the flashlight in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeFlashlightConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Folder icon configuration for managed home screen in Kiosk Mode.')]
    [ValidateSet('notConfigured', 'darkSquare', 'darkCircle', 'lightSquare', 'lightCircle')]
    [System.String] $KioskModeFolderIcon

    [DscProperty()]
    [System.ComponentModel.Description('Number of rows for Managed Home Screen grid with app ordering enabled in Kiosk Mode. Valid values 1 to 9999999.')]
    [System.Nullable[System.UInt32]] $KioskModeGridHeight

    [DscProperty()]
    [System.ComponentModel.Description('Number of columns for Managed Home Screen grid with app ordering enabled in Kiosk Mode. Valid values 1 to 9999999.')]
    [System.Nullable[System.UInt32]] $KioskModeGridWidth

    [DscProperty()]
    [System.ComponentModel.Description('Icon size configuration for managed home screen in Kiosk Mode.')]
    [ValidateSet('notConfigured', 'smallest', 'small', 'regular', 'large', 'largest')]
    [System.String] $KioskModeIconSize

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to lock home screen to the end user in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeLockHomeScreen

    [DscProperty()]
    [System.ComponentModel.Description('A list of managed folders for a device in Kiosk Mode. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodemanagedfolder[]] $KioskModeManagedFolders

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the list of managed applications and associated settings, which will be applied when android device is run on kiosk mode with Managed Home Screen. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapp[]] $KioskModeManagedHomeScreenAppSettings

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to automatically sign-out of MHS and Shared device mode applications after inactive for Managed Home Screen.')]
    [System.Nullable[System.Boolean]] $KioskModeManagedHomeScreenAutoSignout

    [DscProperty()]
    [System.ComponentModel.Description('Number of seconds to give user notice before automatically signing them out for Managed Home Screen. Valid values 0 to 9999999.')]
    [System.Nullable[System.UInt32]] $KioskModeManagedHomeScreenInactiveSignOutDelayInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Number of seconds device is inactive before automatically signing user out for Managed Home Screen. Valid values 0 to 9999999.')]
    [System.Nullable[System.UInt32]] $KioskModeManagedHomeScreenInactiveSignOutNoticeInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Complexity of PIN for sign-in session for Managed Home Screen.')]
    [ValidateSet('notConfigured', 'simple', 'complex')]
    [System.String] $KioskModeManagedHomeScreenPinComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not require user to set a PIN for sign-in session for Managed Home Screen.')]
    [System.Nullable[System.Boolean]] $KioskModeManagedHomeScreenPinRequired

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not required user to enter session PIN if screensaver has appeared for Managed Home Screen.')]
    [System.Nullable[System.Boolean]] $KioskModeManagedHomeScreenPinRequiredToResume

    [DscProperty()]
    [System.ComponentModel.Description('Custom URL background for sign-in screen for Managed Home Screen.')]
    [System.String] $KioskModeManagedHomeScreenSignInBackground

    [DscProperty()]
    [System.ComponentModel.Description('Custom URL branding logo for sign-in screen and session pin page for Managed Home Screen.')]
    [System.String] $KioskModeManagedHomeScreenSignInBrandingLogo

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not show sign-in screen for Managed Home Screen.')]
    [System.Nullable[System.Boolean]] $KioskModeManagedHomeScreenSignInEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to use single app kiosk mode or multi-app kiosk mode.')]
    [System.Nullable[System.Boolean]] $KioskModeManagedSettingsEntryDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to allow a user to change the media volume in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeMediaVolumeConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Screen orientation configuration for managed home screen in Kiosk Mode.')]
    [ValidateSet('notConfigured', 'portrait', 'landscape', 'autoRotate')]
    [System.String] $KioskModeScreenOrientation

    [DscProperty()]
    [System.ComponentModel.Description('Start screen saver when the device screen times out or locks.')]
    [System.Nullable[System.Boolean]] $KioskModeScreenSaverConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not the device screen should show the screen saver if audio/video is playing in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeScreenSaverDetectMediaDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The number of seconds that the device will display the screen saver for in Kiosk Mode. Valid values 0 to 9999999')]
    [System.Nullable[System.UInt32]] $KioskModeScreenSaverDisplayTimeInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('URL for an image that will be the device''s screen saver in Kiosk Mode.')]
    [System.String] $KioskModeScreenSaverImageUrl

    [DscProperty()]
    [System.ComponentModel.Description('The number of seconds the device needs to be inactive for before the screen saver is shown in Kiosk Mode. Valid values 1 to 9999999')]
    [System.Nullable[System.UInt32]] $KioskModeScreenSaverStartDelayInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to display application notification badges in Kiosk Mode.')]
    [System.Nullable[System.Boolean]] $KioskModeShowAppNotificationBadge

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to allow a user to access basic device information.')]
    [System.Nullable[System.Boolean]] $KioskModeShowDeviceInfo

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to use single app kiosk mode or multi-app kiosk mode.')]
    [ValidateSet('notConfigured', 'singleAppMode', 'multiAppMode')]
    [System.String] $KioskModeUseManagedHomeScreenApp

    [DscProperty()]
    [System.ComponentModel.Description('Enable IT administrators to temporarily leave multi-app kiosk mode to make changes on the device.')]
    [System.Nullable[System.Boolean]] $KioskModeVirtualHomeButtonEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable a soft-key button that returns users to the Managed Home Screen. Choose between a persistent, floating button or a button activated by a swipe-up gesture.')]
    [ValidateSet('notConfigured', 'swipeUp', 'floating')]
    [System.String] $KioskModeVirtualHomeButtonType

    [DscProperty()]
    [System.ComponentModel.Description('Customize the appearance of the screen background for assigned groups.')]
    [System.String] $KioskModeWallpaperUrl

    [DscProperty()]
    [System.ComponentModel.Description('The restricted set of WIFI SSIDs available for the user to configure in Kiosk Mode. This collection can contain a maximum of 500 elements.')]
    [System.String[]] $KioskModeWifiAllowedSsids

    [DscProperty()]
    [System.ComponentModel.Description('Enable end-users to connect to different Wi-Fi networks.')]
    [System.Nullable[System.Boolean]] $KioskModeWiFiConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not LocateDevice for devices with lost mode (COBO, COPE) is enabled.')]
    [System.Nullable[System.Boolean]] $LocateDeviceLostModeEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not LocateDevice for userless (COSU) devices is disabled.')]
    [System.Nullable[System.Boolean]] $LocateDeviceUserlessDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Block unmuting the microphone and adjusting the microphone volume.')]
    [System.Nullable[System.Boolean]] $MicrophoneForceMute

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to you want configure Microsoft Launcher.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user can modify the wallpaper to personalize their device.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherCustomWallpaperAllowUserModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to configure the wallpaper on the targeted devices.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherCustomWallpaperEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the URL for the image file to use as the wallpaper on the targeted devices.')]
    [System.String] $MicrosoftLauncherCustomWallpaperImageUrl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user can modify the device dock configuration on the device.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherDockPresenceAllowUserModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not you want to configure the device dock. ')]
    [ValidateSet('notConfigured', 'show', 'hide', 'disabled')]
    [System.String] $MicrosoftLauncherDockPresenceConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user can modify the launcher feed on the device.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherFeedAllowUserModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user can modify the launcher feed on the device.')]
    [System.Nullable[System.Boolean]] $MicrosoftLauncherFeedEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not you want to configure the device dock.')]
    [ValidateSet('notConfigured', 'top', 'bottom', 'hide')]
    [System.String] $MicrosoftLauncherSearchBarPlacementConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Whether the network escape hatch is enabled. If a network connection can''t be made at boot time, the escape hatch prompts the user to temporarily connect to a network in order to refresh the device policy. After applying policy, the temporary network will be forgotten and the device will continue booting. This prevents being unable to connect to a network if there is no suitable network in the last policy and the device boots into an app in lock task mode, or the user is otherwise unable to reach device settings.')]
    [System.Nullable[System.Boolean]] $NetworkEscapeHatchAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Block usage of NFC to beam data from apps.')]
    [System.Nullable[System.Boolean]] $NfcBlockOutgoingBeam

    [DscProperty()]
    [System.ComponentModel.Description('Disable lock screen')]
    [System.Nullable[System.Boolean]] $PasswordBlockKeyguard

    [DscProperty()]
    [System.ComponentModel.Description('These features are accessible to users when the device is locked. Users will not be able to see or access disabled features.')]
    [ValidateSet('notConfigured', 'camera', 'notifications', 'unredactedNotifications', 'trustAgents', 'fingerprint', 'remoteInput', 'allFeatures', 'face', 'iris', 'biometrics')]
    [System.String[]] $PasswordBlockKeyguardFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Number of days until device password must be changed. (1-365)')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum length of the password required on the device. Valid values 4 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of letter characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of lower case characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLowerCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of non-letter characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumNonLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of numeric characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumNumericCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of symbol characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumSymbolCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of upper case letter characters required for device password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumUpperCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Maximum time after which the device will lock. Can disable screen lock as well so that it never times out.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Enter the number of unique passwords required before a user can reuse an old one. (1-24)')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordCountToBlock

    [DscProperty()]
    [System.ComponentModel.Description('Set the password''s complexity requirements. Additional password requirements will become available based on your selection.')]
    [ValidateSet('deviceDefault', 'required', 'numeric', 'numericComplex', 'alphabetic', 'alphanumeric', 'alphanumericWithSymbols', 'lowSecurityBiometric', 'customPassword')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the timeout period after which a device must be unlocked using a form of strong authentication.')]
    [ValidateSet('deviceDefault', 'daily', 'unkownFutureValue')]
    [System.String] $PasswordRequireUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Number of consecutive times an incorrect password can be entered before device is wiped of all data. (4-11)')]
    [System.Nullable[System.UInt32]] $PasswordSignInFailureCountBeforeFactoryReset

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the user can install apps from unknown sources on the personal profile.')]
    [System.Nullable[System.Boolean]] $PersonalProfileAppsAllowInstallFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to disable the use of the camera on the personal profile.')]
    [System.Nullable[System.Boolean]] $PersonalProfileCameraBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Policy applied to applications in the personal profile. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphapplistitem[]] $PersonalProfilePersonalApplications

    [DscProperty()]
    [System.ComponentModel.Description('Used together with PersonalProfilePersonalApplications to control how apps in the personal profile are allowed or blocked')]
    [ValidateSet('notConfigured', 'blockedApps', 'allowedApps')]
    [System.String] $PersonalProfilePlayStoreMode

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to disable the capability to take screenshots on the personal profile.')]
    [System.Nullable[System.Boolean]] $PersonalProfileScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Users get access to all apps, except the ones you''ve required uninstall in Client Apps. If you choose ''Not configured'' for this setting, users can only access the apps you''ve listed as available or required in Client Apps.')]
    [ValidateSet('notConfigured', 'allowList', 'blockList')]
    [System.String] $PlayStoreMode

    [DscProperty()]
    [System.ComponentModel.Description('Block screen capture')]
    [System.Nullable[System.Boolean]] $ScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Represents the security common criteria mode enabled provided to users when they attempt to modify managed settings on their device.')]
    [System.Nullable[System.Boolean]] $SecurityCommonCriteriaModeEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user is allowed to access developer settings like developer options and safe boot on the device.')]
    [System.Nullable[System.Boolean]] $SecurityDeveloperSettingsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable Google Play Protect to scan apps before and after they''re installed. If it detects a threat, it might warn the user to remove the app from the device. Required by default.')]
    [System.Nullable[System.Boolean]] $SecurityRequireVerifyApps

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not location sharing is disabled for fully managed devices (COBO), and corporate owned devices with a work profile (COPE).')]
    [System.Nullable[System.Boolean]] $ShareDeviceLocationDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Represents the customized short help text provided to users when they attempt to modify managed settings on their device.')]
    [MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage] $ShortHelpText

    [DscProperty()]
    [System.ComponentModel.Description('Block access to the status bar, including notifications and quick settings.')]
    [System.Nullable[System.Boolean]] $StatusBarBlocked

    [DscProperty()]
    [System.ComponentModel.Description('The battery plugged in modes for which the device stays on. When using this setting, it is recommended to clear the Time to lock screen setting so that the device doesn''t lock itself while it stays on.')]
    [ValidateSet('notConfigured', 'ac', 'usb', 'wireless')]
    [System.String[]] $StayOnModes

    [DscProperty()]
    [System.ComponentModel.Description('Allow USB storage.')]
    [System.Nullable[System.Boolean]] $StorageAllowUsb

    [DscProperty()]
    [System.ComponentModel.Description('Block mounting of external media.')]
    [System.Nullable[System.Boolean]] $StorageBlockExternalMedia

    [DscProperty()]
    [System.ComponentModel.Description('Block transfer of files over USB.')]
    [System.Nullable[System.Boolean]] $StorageBlockUsbFileTransfer

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the annually repeating time periods during which system updates are postponed. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphandroiddeviceownersystemupdatefreezeperiod[]] $SystemUpdateFreezePeriods

    [DscProperty()]
    [System.ComponentModel.Description('When over-the-air updates are available for this device, they will be installed based on this policy.?')]
    [ValidateSet('deviceDefault', 'postpone', 'windowed', 'automatic')]
    [System.String] $SystemUpdateInstallType

    [DscProperty()]
    [System.ComponentModel.Description('End of the maintenance window in the device''s time zone.?')]
    [System.Nullable[System.UInt32]] $SystemUpdateWindowEndMinutesAfterMidnight

    [DscProperty()]
    [System.ComponentModel.Description('Beginning of the maintenance window in the device''s time zone.?')]
    [System.Nullable[System.UInt32]] $SystemUpdateWindowStartMinutesAfterMidnight

    [DscProperty()]
    [System.ComponentModel.Description('Disable window notifications such as toasts, incoming calls, outgoing calls, system alerts, and system errors.?')]
    [System.Nullable[System.Boolean]] $SystemWindowsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocks users from adding and signing in to personal accounts while on the device.')]
    [System.Nullable[System.Boolean]] $UsersBlockAdd

    [DscProperty()]
    [System.ComponentModel.Description('Block removal of users.')]
    [System.Nullable[System.Boolean]] $UsersBlockRemove

    [DscProperty()]
    [System.ComponentModel.Description('Block changes to volume.')]
    [System.Nullable[System.Boolean]] $VolumeBlockAdjustment

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this forces all network traffic through the VPN tunnel. If a connection to the VPN can''t be established, no network traffic will be allowed.')]
    [System.Nullable[System.Boolean]] $VpnAlwaysOnLockdownMode

    [DscProperty()]
    [System.ComponentModel.Description('Android app package name for app that will handle an always-on VPN connection.')]
    [System.String] $VpnAlwaysOnPackageIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Block user creation or editing of any Wi-Fi configurations.')]
    [System.Nullable[System.Boolean]] $WifiBlockEditConfigurations

    [DscProperty()]
    [System.ComponentModel.Description('Block changes to Wi-Fi configurations created by the device owner. Users can create their own Wi-Fi configurations.')]
    [System.Nullable[System.Boolean]] $WifiBlockEditPolicyDefinedConfigurations

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the number of days that a work profile password can be set before it expires and a new password will be required. Valid values 1 to 365')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum length of the work profile password. Valid values 4 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of numeric characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of non-letter characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumLowerCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of letter characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumNonLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of lower-case characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumNumericCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of upper-case letter characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumSymbolCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of symbol characters required for the work profile password. Valid values 1 to 16')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumUpperCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the length of the work profile password history, where the user will not be able to enter a new password that is the same as any password in the history. Valid values 0 to 24')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordPreviousPasswordCountToBlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum password quality required on the work profile password.')]
    [ValidateSet('deviceDefault', 'required', 'numeric', 'numericComplex', 'alphabetic', 'alphanumeric', 'alphanumericWithSymbols', 'lowSecurityBiometric', 'customPassword')]
    [System.String] $WorkProfilePasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the timeout period after which a work profile must be unlocked using a form of strong authentication.')]
    [ValidateSet('deviceDefault', 'daily', 'unkownFutureValue')]
    [System.String] $WorkProfilePasswordRequireUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the number of times a user can enter an incorrect work profile password before the device is wiped. Valid values 4 to 11')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordSignInFailureCountBeforeFactoryReset

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

    [IntuneDeviceConfigurationPolicyAndroidDeviceOwner] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationPolicyAndroidDeviceOwner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy Android Device Owner with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.androidDeviceOwnerGeneralDeviceConfiguration')" -ErrorAction SilentlyContinue
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

            $complexAndroidDeviceOwnerDelegatedScopeAppSettings = @()
            $currentValueArray = $getValue.androidDeviceOwnerDelegatedScopeAppSettings
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $complexAppDetail = [ordered]@{}
                    $currentChildValue = $currentValue.appDetail
                    if ($null -ne $currentChildValue)
                    {
                        $complexAppDetail.Add('appId', $currentChildValue.appId)
                        $complexAppDetail.Add('publisher', $currentChildValue.publisher)
                        $complexAppDetail.Add('appStoreUrl', $currentChildValue.appStoreUrl)
                        $complexAppDetail.Add('name', $currentChildValue.name)
                        $complexAppDetail.Add('odataType', $currentChildValue.'@odata.type')
                    }
                    if ($complexAppDetail.Values.Where({ $null -ne $_ }).Count -eq 0)
                    {
                        $complexAppDetail = $null
                    }

                    $currentHash = [ordered]@{}
                    $currentHash.Add('appDetail', $complexAppDetail)
                    $currentHash.Add('appScopes', $currentValue.appScopes)
                    $complexAndroidDeviceOwnerDelegatedScopeAppSettings += $currentHash
                }
            }

            $complexAzureAdSharedDeviceDataClearApps = @()
            $currentValueArray = $getValue.azureAdSharedDeviceDataClearApps
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = @{
                        appId       = $currentValue.appId
                        publisher   = $currentValue.publisher
                        appStoreUrl = $currentValue.appStoreUrl
                        name        = $currentValue.name
                        odataType   = $currentValue.'@odata.type'
                    }
                    $complexAzureAdSharedDeviceDataClearApps += $currentHash
                }
            }

            $complexDetailedHelpText = [ordered]@{}
            $currentValue = $getValue.detailedHelpText
            if ($null -ne $currentValue)
            {
                $complexDetailedHelpText.Add('DefaultMessage', $currentValue.defaultMessage)
                $complexLocalizedMessages = @()
                $currentValueArray = $currentValue.localizedMessages
                if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
                {
                    foreach ($currentChildValue in $currentValueArray)
                    {
                        $currentHash = @{
                            Name  = $currentChildValue.name
                            Value = $currentChildValue.value
                        }
                        $complexLocalizedMessages += $currentHash
                    }
                }
                $complexDetailedHelpText.Add('LocalizedMessages', $complexLocalizedMessages)
            }
            if ($complexDetailedHelpText.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDetailedHelpText = $null
            }

            $complexDeviceOwnerLockScreenMessage = [ordered]@{}
            $currentValue = $getValue.deviceOwnerLockScreenMessage
            if ($null -ne $currentValue)
            {
                $complexDeviceOwnerLockScreenMessage.Add('DefaultMessage', $currentValue.defaultMessage)
                $complexLocalizedMessages = @()
                $currentValueArray = $currentValue.localizedMessages
                if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
                {
                    foreach ($currentChildValue in $currentValueArray)
                    {
                        $currentHash = @{
                            Name  = $currentChildValue.name
                            Value = $currentChildValue.value
                        }
                        $complexLocalizedMessages += $currentHash
                    }
                }
                $complexDeviceOwnerLockScreenMessage.Add('LocalizedMessages', $complexLocalizedMessages)
            }
            if ($complexDeviceOwnerLockScreenMessage.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceOwnerLockScreenMessage = $null
            }

            $complexGlobalProxy = [ordered]@{}
            $currentValue = $getValue.globalProxy
            if ($null -ne $currentValue)
            {
                $complexGlobalProxy.Add('ProxyAutoConfigURL', $currentValue.proxyAutoConfigURL)
                $complexGlobalProxy.Add('ExcludedHosts', $currentValue.excludedHosts)
                $complexGlobalProxy.Add('Host', $currentValue.host)
                $complexGlobalProxy.Add('Port', $currentValue.port)
                $complexGlobalProxy.Add('oDataType', $currentValue.'@odata.type')
            }
            if ($complexGlobalProxy.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexGlobalProxy = $null
            }

            $complexKioskModeApps = @()
            $currentValueArray = $getValue.kioskModeApps
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = [ordered]@{}
                    $currentHash.Add('AppId', $currentValue.appId)
                    $currentHash.Add('Publisher', $currentValue.publisher)
                    $currentHash.Add('AppStoreUrl', $currentValue.appStoreUrl)
                    $currentHash.Add('Name', $currentValue.name)
                    $currentHash.Add('oDataType', $currentValue.'@odata.type')
                    $complexKioskModeApps += $currentHash
                }
            }

            $complexKioskModeManagedHomeScreenAppSettings = @()
            $currentValueArray = $getValue.kioskModeManagedHomeScreenAppSettings
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = [ordered]@{}
                    $currentHash.Add('ClassName', $currentValue.className)
                    $currentHash.Add('OfflineAppAccessEnabled', $currentValue.offlineAppAccessEnabled)
                    $currentHash.Add('Package', $currentValue.package)
                    $currentHash.Add('PreSignInAppAccessEnabled', $currentValue.preSignInAppAccessEnabled)
                    $complexKioskModeManagedHomeScreenAppSettings += $currentHash
                }
            }

            $complexPersonalProfilePersonalApplications = @()
            $currentValueArray = $getValue.personalProfilePersonalApplications
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = [ordered]@{}
                    $currentHash.Add('AppId', $currentValue.appId)
                    $currentHash.Add('Publisher', $currentValue.publisher)
                    $currentHash.Add('AppStoreUrl', $currentValue.appStoreUrl)
                    $currentHash.Add('Name', $currentValue.name)
                    $currentHash.Add('oDataType', $currentValue.'@odata.type')
                    $complexPersonalProfilePersonalApplications += $currentHash
                }
            }

            $complexShortHelpText = [ordered]@{}
            $currentValue = $getValue.shortHelpText
            if ($null -ne $currentValue)
            {
                $complexShortHelpText.Add('DefaultMessage', $currentValue.defaultMessage)
                $complexLocalizedMessages = @()
                $currentValueArray = $currentValue.localizedMessages
                if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
                {
                    foreach ($currentChildValue in $currentValueArray)
                    {
                        $currentHash = @{
                            Name  = $currentChildValue.name
                            Value = $currentChildValue.value
                        }
                        $complexLocalizedMessages += $currentHash
                    }
                }
                $complexShortHelpText.Add('LocalizedMessages', $complexLocalizedMessages)
            }
            if ($complexShortHelpText.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexShortHelpText = $null
            }

            $complexSystemUpdateFreezePeriods = @()
            $currentValueArray = $getValue.systemUpdateFreezePeriods
            if ($null -ne $currentValueArray -and $currentValueArray.Count -gt 0)
            {
                foreach ($currentValue in $currentValueArray)
                {
                    $currentHash = @{}
                    $currentHash.Add('StartDay', $currentValue.startDay)
                    $currentHash.Add('EndDay', $currentValue.endDay)
                    $currentHash.Add('StartMonth', $currentValue.startMonth)
                    $currentHash.Add('EndMonth', $currentValue.endMonth)
                    $complexSystemUpdateFreezePeriods += $currentHash
                }
            }

            $results = @{
                #region resource generator code
                Id                                                       = $getValue.Id
                Description                                              = $getValue.Description
                DisplayName                                              = $getValue.DisplayName
                RoleScopeTagIds                                          = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                AccountsBlockModification                                = $getValue.accountsBlockModification
                AndroidDeviceOwnerDelegatedScopeAppSettings              = $complexAndroidDeviceOwnerDelegatedScopeAppSettings
                AppsAllowInstallFromUnknownSources                       = $getValue.appsAllowInstallFromUnknownSources
                AppsAutoUpdatePolicy                                     = $getValue.appsAutoUpdatePolicy
                AppsDefaultPermissionPolicy                              = $getValue.appsDefaultPermissionPolicy
                AppsRecommendSkippingFirstUseHints                       = $getValue.appsRecommendSkippingFirstUseHints
                AzureAdSharedDeviceDataClearApps                         = $complexAzureAdSharedDeviceDataClearApps
                BluetoothBlockConfiguration                              = $getValue.bluetoothBlockConfiguration
                BluetoothBlockContactSharing                             = $getValue.bluetoothBlockContactSharing
                CameraBlocked                                            = $getValue.cameraBlocked
                CellularBlockWiFiTethering                               = $getValue.cellularBlockWiFiTethering
                CertificateCredentialConfigurationDisabled               = $getValue.certificateCredentialConfigurationDisabled
                CrossProfilePoliciesAllowCopyPaste                       = $getValue.crossProfilePoliciesAllowCopyPaste
                CrossProfilePoliciesAllowDataSharing                     = $getValue.crossProfilePoliciesAllowDataSharing
                CrossProfilePoliciesShowWorkContactsInPersonalProfile    = $getValue.crossProfilePoliciesShowWorkContactsInPersonalProfile
                DataRoamingBlocked                                       = $getValue.dataRoamingBlocked
                DateTimeConfigurationBlocked                             = $getValue.dateTimeConfigurationBlocked
                DetailedHelpText                                         = $complexDetailedHelpText
                DeviceLocationMode                                       = $getValue.deviceLocationMode
                DeviceOwnerLockScreenMessage                             = $complexDeviceOwnerLockScreenMessage
                EnrollmentProfile                                        = $getValue.enrollmentProfile
                FactoryResetBlocked                                      = $getValue.factoryResetBlocked
                FactoryResetDeviceAdministratorEmails                    = $getValue.factoryResetDeviceAdministratorEmails
                GlobalProxy                                              = $complexGlobalProxy
                GoogleAccountsBlocked                                    = $getValue.googleAccountsBlocked
                KioskCustomizationDeviceSettingsBlocked                  = $getValue.kioskCustomizationDeviceSettingsBlocked
                KioskCustomizationPowerButtonActionsBlocked              = $getValue.kioskCustomizationPowerButtonActionsBlocked
                KioskCustomizationStatusBar                              = $getValue.kioskCustomizationStatusBar
                KioskCustomizationSystemErrorWarnings                    = $getValue.kioskCustomizationSystemErrorWarnings
                KioskCustomizationSystemNavigation                       = $getValue.kioskCustomizationSystemNavigation
                KioskModeAppOrderEnabled                                 = $getValue.kioskModeAppOrderEnabled
                KioskModeAppPositions                                    = $getValue.kioskModeAppPositions
                KioskModeApps                                            = $complexKioskModeApps
                KioskModeAppsInFolderOrderedByName                       = $getValue.kioskModeAppsInFolderOrderedByName
                KioskModeBluetoothConfigurationEnabled                   = $getValue.kioskModeBluetoothConfigurationEnabled
                KioskModeDebugMenuEasyAccessEnabled                      = $getValue.kioskModeDebugMenuEasyAccessEnabled
                KioskModeExitCode                                        = $getValue.kioskModeExitCode
                KioskModeFlashlightConfigurationEnabled                  = $getValue.kioskModeFlashlightConfigurationEnabled
                KioskModeFolderIcon                                      = $getValue.kioskModeFolderIcon
                KioskModeGridHeight                                      = $getValue.kioskModeGridHeight
                KioskModeGridWidth                                       = $getValue.kioskModeGridWidth
                KioskModeIconSize                                        = $getValue.kioskModeIconSize
                KioskModeLockHomeScreen                                  = $getValue.kioskModeLockHomeScreen
                KioskModeManagedFolders                                  = $getValue.kioskModeManagedFolders
                KioskModeManagedHomeScreenAppSettings                    = $complexKioskModeManagedHomeScreenAppSettings
                KioskModeManagedHomeScreenAutoSignout                    = $getValue.kioskModeManagedHomeScreenAutoSignout
                KioskModeManagedHomeScreenInactiveSignOutDelayInSeconds  = $getValue.kioskModeManagedHomeScreenInactiveSignOutDelayInSeconds
                KioskModeManagedHomeScreenInactiveSignOutNoticeInSeconds = $getValue.kioskModeManagedHomeScreenInactiveSignOutNoticeInSeconds
                KioskModeManagedHomeScreenPinComplexity                  = $getValue.kioskModeManagedHomeScreenPinComplexity
                KioskModeManagedHomeScreenPinRequired                    = $getValue.kioskModeManagedHomeScreenPinRequired
                KioskModeManagedHomeScreenPinRequiredToResume            = $getValue.kioskModeManagedHomeScreenPinRequiredToResume
                KioskModeManagedHomeScreenSignInBackground               = $getValue.kioskModeManagedHomeScreenSignInBackground
                KioskModeManagedHomeScreenSignInBrandingLogo             = $getValue.kioskModeManagedHomeScreenSignInBrandingLogo
                KioskModeManagedHomeScreenSignInEnabled                  = $getValue.kioskModeManagedHomeScreenSignInEnabled
                KioskModeManagedSettingsEntryDisabled                    = $getValue.kioskModeManagedSettingsEntryDisabled
                KioskModeMediaVolumeConfigurationEnabled                 = $getValue.kioskModeMediaVolumeConfigurationEnabled
                KioskModeScreenOrientation                               = $getValue.kioskModeScreenOrientation
                KioskModeScreenSaverConfigurationEnabled                 = $getValue.kioskModeScreenSaverConfigurationEnabled
                KioskModeScreenSaverDetectMediaDisabled                  = $getValue.kioskModeScreenSaverDetectMediaDisabled
                KioskModeScreenSaverDisplayTimeInSeconds                 = $getValue.kioskModeScreenSaverDisplayTimeInSeconds
                KioskModeScreenSaverImageUrl                             = $getValue.kioskModeScreenSaverImageUrl
                KioskModeScreenSaverStartDelayInSeconds                  = $getValue.kioskModeScreenSaverStartDelayInSeconds
                KioskModeShowAppNotificationBadge                        = $getValue.kioskModeShowAppNotificationBadge
                KioskModeShowDeviceInfo                                  = $getValue.kioskModeShowDeviceInfo
                KioskModeUseManagedHomeScreenApp                         = $getValue.kioskModeUseManagedHomeScreenApp
                KioskModeVirtualHomeButtonEnabled                        = $getValue.kioskModeVirtualHomeButtonEnabled
                KioskModeVirtualHomeButtonType                           = $getValue.kioskModeVirtualHomeButtonType
                KioskModeWallpaperUrl                                    = $getValue.kioskModeWallpaperUrl
                KioskModeWifiAllowedSsids                                = $getValue.kioskModeWifiAllowedSsids
                KioskModeWiFiConfigurationEnabled                        = $getValue.kioskModeWiFiConfigurationEnabled
                LocateDeviceLostModeEnabled                              = $getValue.locateDeviceLostModeEnabled
                LocateDeviceUserlessDisabled                             = $getValue.locateDeviceUserlessDisabled
                MicrophoneForceMute                                      = $getValue.microphoneForceMute
                MicrosoftLauncherConfigurationEnabled                    = $getValue.microsoftLauncherConfigurationEnabled
                MicrosoftLauncherCustomWallpaperAllowUserModification    = $getValue.microsoftLauncherCustomWallpaperAllowUserModification
                MicrosoftLauncherCustomWallpaperEnabled                  = $getValue.microsoftLauncherCustomWallpaperEnabled
                MicrosoftLauncherCustomWallpaperImageUrl                 = $getValue.microsoftLauncherCustomWallpaperImageUrl
                MicrosoftLauncherDockPresenceAllowUserModification       = $getValue.microsoftLauncherDockPresenceAllowUserModification
                MicrosoftLauncherDockPresenceConfiguration               = $getValue.microsoftLauncherDockPresenceConfiguration
                MicrosoftLauncherFeedAllowUserModification               = $getValue.microsoftLauncherFeedAllowUserModification
                MicrosoftLauncherFeedEnabled                             = $getValue.microsoftLauncherFeedEnabled
                MicrosoftLauncherSearchBarPlacementConfiguration         = $getValue.microsoftLauncherSearchBarPlacementConfiguration
                NetworkEscapeHatchAllowed                                = $getValue.networkEscapeHatchAllowed
                NfcBlockOutgoingBeam                                     = $getValue.nfcBlockOutgoingBeam
                PasswordBlockKeyguard                                    = $getValue.passwordBlockKeyguard
                PasswordBlockKeyguardFeatures                            = $getValue.passwordBlockKeyguardFeatures
                PasswordExpirationDays                                   = $getValue.passwordExpirationDays
                PasswordMinimumLength                                    = $getValue.passwordMinimumLength
                PasswordMinimumLetterCharacters                          = $getValue.passwordMinimumLetterCharacters
                PasswordMinimumLowerCaseCharacters                       = $getValue.passwordMinimumLowerCaseCharacters
                PasswordMinimumNonLetterCharacters                       = $getValue.passwordMinimumNonLetterCharacters
                PasswordMinimumNumericCharacters                         = $getValue.passwordMinimumNumericCharacters
                PasswordMinimumSymbolCharacters                          = $getValue.passwordMinimumSymbolCharacters
                PasswordMinimumUpperCaseCharacters                       = $getValue.passwordMinimumUpperCaseCharacters
                PasswordMinutesOfInactivityBeforeScreenTimeout           = $getValue.passwordMinutesOfInactivityBeforeScreenTimeout
                PasswordPreviousPasswordCountToBlock                     = $getValue.passwordPreviousPasswordCountToBlock
                PasswordRequiredType                                     = $getValue.passwordRequiredType
                PasswordRequireUnlock                                    = $getValue.passwordRequireUnlock
                PasswordSignInFailureCountBeforeFactoryReset             = $getValue.passwordSignInFailureCountBeforeFactoryReset
                PersonalProfileAppsAllowInstallFromUnknownSources        = $getValue.personalProfileAppsAllowInstallFromUnknownSources
                PersonalProfileCameraBlocked                             = $getValue.personalProfileCameraBlocked
                PersonalProfilePersonalApplications                      = $complexPersonalProfilePersonalApplications
                PersonalProfilePlayStoreMode                             = $getValue.personalProfilePlayStoreMode
                PersonalProfileScreenCaptureBlocked                      = $getValue.personalProfileScreenCaptureBlocked
                PlayStoreMode                                            = $getValue.playStoreMode
                ScreenCaptureBlocked                                     = $getValue.screenCaptureBlocked
                SecurityCommonCriteriaModeEnabled                        = $getValue.securityCommonCriteriaModeEnabled
                SecurityDeveloperSettingsEnabled                         = $getValue.securityDeveloperSettingsEnabled
                SecurityRequireVerifyApps                                = $getValue.securityRequireVerifyApps
                ShareDeviceLocationDisabled                              = $getValue.shareDeviceLocationDisabled
                ShortHelpText                                            = $complexShortHelpText
                StatusBarBlocked                                         = $getValue.statusBarBlocked
                StayOnModes                                              = $getValue.stayOnModes
                StorageAllowUsb                                          = $getValue.storageAllowUsb
                StorageBlockExternalMedia                                = $getValue.storageBlockExternalMedia
                StorageBlockUsbFileTransfer                              = $getValue.storageBlockUsbFileTransfer
                SystemUpdateFreezePeriods                                = $complexSystemUpdateFreezePeriods
                SystemUpdateInstallType                                  = $getValue.systemUpdateInstallType
                SystemUpdateWindowEndMinutesAfterMidnight                = $getValue.systemUpdateWindowEndMinutesAfterMidnight
                SystemUpdateWindowStartMinutesAfterMidnight              = $getValue.systemUpdateWindowStartMinutesAfterMidnight
                SystemWindowsBlocked                                     = $getValue.systemWindowsBlocked
                UsersBlockAdd                                            = $getValue.usersBlockAdd
                UsersBlockRemove                                         = $getValue.usersBlockRemove
                VolumeBlockAdjustment                                    = $getValue.volumeBlockAdjustment
                VpnAlwaysOnLockdownMode                                  = $getValue.vpnAlwaysOnLockdownMode
                VpnAlwaysOnPackageIdentifier                             = $getValue.vpnAlwaysOnPackageIdentifier
                WifiBlockEditConfigurations                              = $getValue.wifiBlockEditConfigurations
                WifiBlockEditPolicyDefinedConfigurations                 = $getValue.wifiBlockEditPolicyDefinedConfigurations
                WorkProfilePasswordExpirationDays                        = $getValue.workProfilePasswordExpirationDays
                WorkProfilePasswordMinimumLength                         = $getValue.workProfilePasswordMinimumLength
                WorkProfilePasswordMinimumLetterCharacters               = $getValue.workProfilePasswordMinimumLetterCharacters
                WorkProfilePasswordMinimumLowerCaseCharacters            = $getValue.workProfilePasswordMinimumLowerCaseCharacters
                WorkProfilePasswordMinimumNonLetterCharacters            = $getValue.workProfilePasswordMinimumNonLetterCharacters
                WorkProfilePasswordMinimumNumericCharacters              = $getValue.workProfilePasswordMinimumNumericCharacters
                WorkProfilePasswordMinimumSymbolCharacters               = $getValue.workProfilePasswordMinimumSymbolCharacters
                WorkProfilePasswordMinimumUpperCaseCharacters            = $getValue.workProfilePasswordMinimumUpperCaseCharacters
                WorkProfilePasswordPreviousPasswordCountToBlock          = $getValue.workProfilePasswordPreviousPasswordCountToBlock
                WorkProfilePasswordRequiredType                          = $getValue.workProfilePasswordRequiredType
                WorkProfilePasswordRequireUnlock                         = $getValue.workProfilePasswordRequireUnlock
                WorkProfilePasswordSignInFailureCountBeforeFactoryReset  = $getValue.workProfilePasswordSignInFailureCountBeforeFactoryReset
                Ensure                                                   = 'Present'
                Credential                                               = $this.Credential
                ApplicationId                                            = $this.ApplicationId
                TenantId                                                 = $this.TenantId
                ApplicationSecret                                        = $this.ApplicationSecret
                CertificateThumbprint                                    = $this.CertificateThumbprint
                CertificatePath                                          = $this.CertificatePath
                CertificatePassword                                      = $this.CertificatePassword
                ManagedIdentity                                          = $this.ManagedIdentity
                AccessTokens                                             = $this.AccessTokens
            }

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

        Write-Verbose -Message "Setting configuration of the Intune Device Configuration Policy Android Device Owner with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            foreach ($key in ($createParameters.Clone()).Keys)
            {
                if ($key -eq 'DetailedHelpText' -or $key -eq 'DeviceOwnerLockScreenMessage' -or $key -eq 'ShortHelpText')
                {
                    if ($null -ne $createParameters.$key.DefaultMessage -or $null -ne $createParameters.$key.LocalizedMessages)
                    {
                        $createParameters.$key.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerUserFacingMessage')
                    }

                    if ($null -eq $createParameters.$key.LocalizedMessages)
                    {
                        $createParameters.$key.Add('localizedMessages', @())
                    }
                }

                if ($key -ne '@odata.type')
                {
                    $keyName = $key.Substring(0, 1).ToLower() + $key.Substring(1, $key.Length - 1)
                    $keyValue = $createParameters.$key
                    $createParameters.Remove($key) | Out-Null
                    $createParameters.Add($keyName, $keyValue) | Out-Null
                }
            }
            $createParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerGeneralDeviceConfiguration')

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
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            foreach ($key in (($updateParameters.Clone()).Keys | Sort-Object))
            {
                if ($key -eq 'DetailedHelpText' -or $key -eq 'DeviceOwnerLockScreenMessage' -or $key -eq 'ShortHelpText')
                {
                    if ($null -ne $updateParameters.$key.DefaultMessage -or $null -ne $updateParameters.$key.LocalizedMessages)
                    {
                        $updateParameters.$key.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerUserFacingMessage')
                    }

                    if ($null -eq $updateParameters.$key.LocalizedMessages)
                    {
                        $updateParameters.$key.Add('localizedMessages', @())
                    }
                }

                if ($key -ne '@odata.type')
                {
                    $keyName = $key.Substring(0, 1).ToLower() + $key.Substring(1, $key.Length - 1)
                    $keyValue = $updateParameters.$key
                    $updateParameters.Remove($key)
                    $updateParameters.Add($keyName, $keyValue)
                }
            }
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerGeneralDeviceConfiguration')

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
                -ODataType 'microsoft.graph.androidDeviceOwnerGeneralDeviceConfiguration' `
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

                if ($Results.AndroidDeviceOwnerDelegatedScopeAppSettings)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'androidDeviceOwnerDelegatedScopeAppSettings'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceownerdelegatedscopeappsetting'
                        }
                        @{
                            Name            = 'appDetail'
                            CimInstanceName = 'MicrosoftGraphapplistitem'
                            isRequired      = $true
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AndroidDeviceOwnerDelegatedScopeAppSettings `
                        -CIMInstanceName MicrosoftGraphandroiddeviceownerdelegatedscopeappsetting `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.AndroidDeviceOwnerDelegatedScopeAppSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AndroidDeviceOwnerDelegatedScopeAppSettings') | Out-Null
                    }
                }

                if ($Results.AzureAdSharedDeviceDataClearApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.AzureAdSharedDeviceDataClearApps -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.AzureAdSharedDeviceDataClearApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AzureAdSharedDeviceDataClearApps') | Out-Null
                    }
                }

                if ($Results.DetailedHelpText)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'DetailedHelpText'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceowneruserfacingmessage'
                        }
                        @{
                            Name            = 'localizedMessages'
                            CimInstanceName = 'MicrosoftGraphkeyvaluepair'
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DetailedHelpText `
                        -CIMInstanceName MicrosoftGraphandroiddeviceowneruserfacingmessage `
                        -ComplexTypeMapping $complexTypeMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.DetailedHelpText = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DetailedHelpText') | Out-Null
                    }
                }

                if ($Results.DeviceOwnerLockScreenMessage)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'DeviceOwnerLockScreenMessage'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceowneruserfacingmessage'
                        }
                        @{
                            Name            = 'localizedMessages'
                            CimInstanceName = 'MicrosoftGraphkeyvaluepair'
                            isRequired      = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceOwnerLockScreenMessage `
                        -CIMInstanceName MicrosoftGraphandroiddeviceowneruserfacingmessage `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceOwnerLockScreenMessage = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceOwnerLockScreenMessage') | Out-Null
                    }
                }

                if ($Results.GlobalProxy)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.GlobalProxy -CIMInstanceName MicrosoftGraphandroiddeviceownerglobalproxy
                    if ($complexTypeStringResult)
                    {
                        $Results.GlobalProxy = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('GlobalProxy') | Out-Null
                    }
                }

                if ($Results.KioskModeAppPositions)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'kioskModeAppPositions'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem'
                        }
                        @{
                            Name            = 'item'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceownerkioskmodehomescreenitem'
                            isRequired      = $true
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.KioskModeAppPositions `
                        -CIMInstanceName MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.KioskModeAppPositions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KioskModeAppPositions') | Out-Null
                    }
                }

                if ($Results.KioskModeApps)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.KioskModeApps -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.KioskModeApps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KioskModeApps') | Out-Null
                    }
                }

                if ($Results.KioskModeManagedFolders)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'kioskModeManagedFolders'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceownerkioskmodemanagedfolder'
                        }
                        @{
                            Name            = 'items'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceownerkioskmodefolderitem'
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.KioskModeManagedFolders `
                        -CIMInstanceName MicrosoftGraphandroiddeviceownerkioskmodemanagedfolder `
                        -ComplexTypeMapping $complexTypeMapping

                    if ($complexTypeStringResult)
                    {
                        $Results.KioskModeManagedFolders = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KioskModeManagedFolders') | Out-Null
                    }
                }

                if ($Results.KioskModeManagedHomeScreenAppSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.KioskModeManagedHomeScreenAppSettings -CIMInstanceName MicrosoftGraphandroiddeviceownerkioskmodeapp
                    if ($complexTypeStringResult)
                    {
                        $Results.KioskModeManagedHomeScreenAppSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('KioskModeManagedHomeScreenAppSettings') | Out-Null
                    }
                }

                if ($Results.PersonalProfilePersonalApplications)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.PersonalProfilePersonalApplications -CIMInstanceName MicrosoftGraphapplistitem
                    if ($complexTypeStringResult)
                    {
                        $Results.PersonalProfilePersonalApplications = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PersonalProfilePersonalApplications') | Out-Null
                    }
                }

                if ($Results.ShortHelpText)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'ShortHelpText'
                            CimInstanceName = 'MicrosoftGraphandroiddeviceowneruserfacingmessage'
                        }
                        @{
                            Name            = 'localizedMessages'
                            CimInstanceName = 'MicrosoftGraphkeyvaluepair'
                            isRequired      = $true
                            isArray         = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.ShortHelpText `
                        -CIMInstanceName MicrosoftGraphandroiddeviceowneruserfacingmessage `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.ShortHelpText = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ShortHelpText') | Out-Null
                    }
                }

                if ($Results.SystemUpdateFreezePeriods)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.SystemUpdateFreezePeriods -CIMInstanceName MicrosoftGraphandroiddeviceownersystemupdatefreezeperiod
                    if ($complexTypeStringResult)
                    {
                        $Results.SystemUpdateFreezePeriods = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('SystemUpdateFreezePeriods') | Out-Null
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
                    -NoEscape @('AndroidDeviceOwnerDelegatedScopeAppSettings', 'AzureAdSharedDeviceDataClearApps', 'DetailedHelpText',
                    'DeviceOwnerLockScreenMessage', 'GlobalProxy', 'KioskModeAppPositions', 'KioskModeApps', 'KioskModeManagedFolders',
                    'KioskModeManagedHomeScreenAppSettings', 'PersonalProfilePersonalApplications', 'ShortHelpText',
                    'SystemUpdateFreezePeriods', 'Assignments') `
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

    hidden [IntuneDeviceConfigurationPolicyAndroidDeviceOwner] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationPolicyAndroidDeviceOwner])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationPolicyAndroidDeviceOwner]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphandroiddeviceownerdelegatedscopeappsetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Information about the app.')]
    [MSFT_MicrosoftGraphapplistitem] $appDetail

    [DscProperty()]
    [System.ComponentModel.Description('List of scopes an app has been assigned.')]
    [ValidateSet('unspecified', 'certificateInstall', 'captureNetworkActivityLog', 'captureSecurityLog')]
    [System.String[]] $appScopes
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

class MSFT_MicrosoftGraphandroiddeviceowneruserfacingmessage
{
    [DscProperty()]
    [System.ComponentModel.Description('The default message displayed if the user''s locale doesn''t match with any of the localized messages.')]
    [System.String] $defaultMessage

    [DscProperty()]
    [System.ComponentModel.Description('The list of <locale, message> pairs. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphkeyvaluepair[]] $localizedMessages
}

class MSFT_MicrosoftGraphandroiddeviceownerglobalproxy
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the global proxy.')]
    [ValidateSet('#microsoft.graph.androidDeviceOwnerGlobalProxyAutoConfig', '#microsoft.graph.androidDeviceOwnerGlobalProxyDirect')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The proxy auto-config URL.')]
    [System.String] $proxyAutoConfigURL

    [DscProperty()]
    [System.ComponentModel.Description('The excluded hosts.')]
    [System.String[]] $excludedHosts

    [DscProperty()]
    [System.ComponentModel.Description('The host name.')]
    [System.String] $host

    [DscProperty()]
    [System.ComponentModel.Description('The port.')]
    [System.Nullable[System.UInt32]] $port
}

class MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapppositionitem
{
    [DscProperty()]
    [System.ComponentModel.Description('Item to be arranged.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodehomescreenitem] $item

    [DscProperty()]
    [System.ComponentModel.Description('Position of the item on the grid. Valid values 0 to 9999999.')]
    [System.Nullable[System.UInt32]] $position
}

class MSFT_MicrosoftGraphandroiddeviceownerkioskmodemanagedfolder
{
    [DscProperty()]
    [System.ComponentModel.Description('The folder identifier.')]
    [System.String] $folderIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('The folder name.')]
    [System.String] $folderName

    [DscProperty()]
    [System.ComponentModel.Description('Item to be arranged.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodefolderitem[]] $items
}

class MSFT_MicrosoftGraphandroiddeviceownerkioskmodeapp
{
    [DscProperty()]
    [System.ComponentModel.Description('Class name of application')]
    [System.String] $className

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the application can be used when sign in fails due to network issues in Managed Home Screen. When TRUE, indicates the application can be used when sign in fails due to network issues in Managed Home Screen. When FALSE, indicates the application cannot be used when sign in fails due to network issues in Managed Home Screen. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $offlineAppAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Package name of application')]
    [System.String] $package

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the application can be used prior to signing in to the Managed Home Screen. When TRUE, indicates the app can be used prior to sign in for Managed Home Screen. When FALSE, indicates the app cannot be used prior to sign in for Managed Home Screen. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $preSignInAppAccessEnabled
}

class MSFT_MicrosoftGraphandroiddeviceownersystemupdatefreezeperiod
{
    [DscProperty()]
    [System.ComponentModel.Description('The day of the end date of the freeze period. Valid values 1 to 31.')]
    [System.Nullable[System.UInt32]] $endDay

    [DscProperty()]
    [System.ComponentModel.Description('The month of the end date of the freeze period. Valid values 1 to 12.')]
    [System.Nullable[System.UInt32]] $endMonth

    [DscProperty()]
    [System.ComponentModel.Description('The day of the start date of the freeze period. Valid values 1 to 31.')]
    [System.Nullable[System.UInt32]] $startDay

    [DscProperty()]
    [System.ComponentModel.Description('The month of the start date of the freeze period. Valid values 1 to 12.')]
    [System.Nullable[System.UInt32]] $startMonth
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

class MSFT_MicrosoftGraphkeyvaluepair
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the message localizedMessages.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Value of the message localizedMessages.')]
    [System.String] $Value
}

class MSFT_MicrosoftGraphandroiddeviceownerkioskmodehomescreenitem
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of the item.')]
    [ValidateSet('#microsoft.graph.androidDeviceOwnerKioskModeApp', '#microsoft.graph.androidDeviceOwnerKioskModeWeblink', '#microsoft.graph.androidDeviceOwnerKioskModeManagedFolder')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The folder identifier.')]
    [System.String] $folderIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('The folder name.')]
    [System.String] $folderName

    [DscProperty()]
    [System.ComponentModel.Description('Item to be arranged.')]
    [MSFT_MicrosoftGraphandroiddeviceownerkioskmodefolderitem[]] $items

    [DscProperty()]
    [System.ComponentModel.Description('The class name of the item.')]
    [System.String] $className

    [DscProperty()]
    [System.ComponentModel.Description('The package of the item.')]
    [System.String] $package

    [DscProperty()]
    [System.ComponentModel.Description('The label of the item.')]
    [System.String] $label

    [DscProperty()]
    [System.ComponentModel.Description('The link of the item.')]
    [System.String] $link
}

class MSFT_MicrosoftGraphandroiddeviceownerkioskmodefolderitem
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the item.')]
    [ValidateSet('#microsoft.graph.androidDeviceOwnerKioskModeApp', '#microsoft.graph.androidDeviceOwnerKioskModeWeblink')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The class name of the item.')]
    [System.String] $className

    [DscProperty()]
    [System.ComponentModel.Description('The package of the item.')]
    [System.String] $package

    [DscProperty()]
    [System.ComponentModel.Description('The label of the item.')]
    [System.String] $label

    [DscProperty()]
    [System.ComponentModel.Description('The link of the item.')]
    [System.String] $link
}
