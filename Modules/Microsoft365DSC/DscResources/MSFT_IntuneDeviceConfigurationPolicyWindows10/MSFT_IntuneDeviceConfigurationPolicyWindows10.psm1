using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from adding email accounts to the device that are not associated with a Microsoft account.')]
    [System.Nullable[System.Boolean]] $AccountsBlockAddingNonMicrosoftAccountEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Windows apps can be activated by voice. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $ActivateAppsWithVoice

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from selecting an AntiTheft mode preference (Windows 10 Mobile only).')]
    [System.Nullable[System.Boolean]] $AntiTheftModeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting permits users to change installation options that typically are available only to system administrators.')]
    [System.Nullable[System.Boolean]] $AppManagementMSIAllowUserControlOverInstall

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting directs Windows Installer to use elevated permissions when it installs any program on the system.')]
    [System.Nullable[System.Boolean]] $AppManagementMSIAlwaysInstallWithElevatedPrivileges

    [DscProperty()]
    [System.ComponentModel.Description('List of semi-colon delimited Package Family Names of Windows apps. Listed Windows apps are to be launched after logon.')]
    [System.String[]] $AppManagementPackageFamilyNamesToLaunchAfterLogOn

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether apps from AppX packages signed with a trusted certificate can be side loaded. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $AppsAllowTrustedAppsSideloading

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to disable the launch of all apps from Windows Store that came pre-installed or were downloaded.')]
    [System.Nullable[System.Boolean]] $AppsBlockWindowsStoreOriginatedApps

    [DscProperty()]
    [System.ComponentModel.Description('Allows secondary authentication devices to work with Windows.')]
    [System.Nullable[System.Boolean]] $AuthenticationAllowSecondaryDevice

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the preferred domain among available domains in the Azure AD tenant.')]
    [System.String] $AuthenticationPreferredAzureADTenantDomainName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not Web Credential Provider will be enabled. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $AuthenticationWebSignIn

    [DscProperty()]
    [System.ComponentModel.Description('Specify a list of allowed Bluetooth services and profiles in hex formatted strings.')]
    [System.String[]] $BluetoothAllowedServices

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using bluetooth advertising.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockAdvertising

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using bluetooth discoverable mode.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockDiscoverableMode

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using bluetooth.')]
    [System.Nullable[System.Boolean]] $BluetoothBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to block specific bundled Bluetooth peripherals to automatically pair with the host device.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockPrePairing

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to block the users from using Swift Pair and other proximity based scenarios.')]
    [System.Nullable[System.Boolean]] $BluetoothBlockPromptedProximalConnections

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from accessing the camera of the device.')]
    [System.Nullable[System.Boolean]] $CameraBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using data over cellular while roaming.')]
    [System.Nullable[System.Boolean]] $CellularBlockDataWhenRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using VPN over cellular.')]
    [System.Nullable[System.Boolean]] $CellularBlockVpn

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using VPN when roaming over cellular.')]
    [System.Nullable[System.Boolean]] $CellularBlockVpnWhenRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to allow the cellular data channel on the device. If not configured, the cellular data channel is allowed and the user can turn it off. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $CellularData

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from doing manual root certificate installation.')]
    [System.Nullable[System.Boolean]] $CertificatesBlockManualRootCertificateInstallation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time zone to be applied to the device. This is the standard Windows name for the target time zone.')]
    [System.String] $ConfigureTimeZone

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to block Connected Devices Service which enables discovery and connection to other devices, remote messaging, remote app sessions and other cross-device experiences.')]
    [System.Nullable[System.Boolean]] $ConnectedDevicesServiceBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using copy paste.')]
    [System.Nullable[System.Boolean]] $CopyPasteBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to Block the user from using Cortana.')]
    [System.Nullable[System.Boolean]] $CortanaBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether to allow or disallow the Federal Information Processing Standard (FIPS) policy.')]
    [System.Nullable[System.Boolean]] $CryptographyAllowFipsAlgorithmPolicy

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to block direct memory access (DMA) for all hot pluggable PCI downstream ports until a user logs into Windows.')]
    [System.Nullable[System.Boolean]] $DataProtectionBlockDirectMemoryAccess

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not to block end user access to Defender.')]
    [System.Nullable[System.Boolean]] $DefenderBlockEndUserAccess

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender On Access Protection functionality.')]
    [System.Nullable[System.Boolean]] $DefenderBlockOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the level of cloud-delivered protection. Possible values are: notConfigured, high, highPlus, zeroTolerance.')]
    [ValidateSet('notConfigured', 'high', 'highPlus', 'zeroTolerance')]
    [System.String] $DefenderCloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('Timeout extension for file scanning by the cloud. Valid values 0 to 50')]
    [System.Nullable[System.UInt32]] $DefenderCloudExtendedTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Timeout extension for file scanning by the cloud. Valid values 0 to 50')]
    [System.Nullable[System.UInt32]] $DefenderCloudExtendedTimeoutInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before deleting quarantined malware. Valid values 0 to 90')]
    [System.Nullable[System.UInt32]] $DefenderDaysBeforeDeletingQuarantinedMalware

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets Defenders actions to take on detected Malware per threat level.')]
    [MSFT_MicrosoftGraphdefenderDetectedMalwareActions] $DefenderDetectedMalwareActions

    [DscProperty()]
    [System.ComponentModel.Description('When blocked, catch-up scans for scheduled full scans will be turned off.')]
    [System.Nullable[System.Boolean]] $DefenderDisableCatchupFullScan

    [DscProperty()]
    [System.ComponentModel.Description('When blocked, catch-up scans for scheduled quick scans will be turned off.')]
    [System.Nullable[System.Boolean]] $DefenderDisableCatchupQuickScan

    [DscProperty()]
    [System.ComponentModel.Description('File extensions to exclude from scans and real time protection.')]
    [System.String[]] $DefenderFileExtensionsToExclude

    [DscProperty()]
    [System.ComponentModel.Description('Files and folder to exclude from scans and real time protection.')]
    [System.String[]] $DefenderFilesAndFoldersToExclude

    [DscProperty()]
    [System.ComponentModel.Description('Value for monitoring file activity. Possible values are: userDefined, disable, monitorAllFiles, monitorIncomingFilesOnly, monitorOutgoingFilesOnly.')]
    [ValidateSet('userDefined', 'disable', 'monitorAllFiles', 'monitorIncomingFilesOnly', 'monitorOutgoingFilesOnly')]
    [System.String] $DefenderMonitorFileActivity

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets Defenders action to take on Potentially Unwanted Application (PUA), which includes software with behaviors of ad-injection, software bundling, persistent solicitation for payment or subscription, etc. Defender alerts user when PUA is being downloaded or attempts to install itself. Added in Windows 10 for desktop. Possible values are: deviceDefault, block, audit.')]
    [ValidateSet('deviceDefault', 'block', 'audit')]
    [System.String] $DefenderPotentiallyUnwantedAppAction

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets Defenders action to take on Potentially Unwanted Application (PUA), which includes software with behaviors of ad-injection, software bundling, persistent solicitation for payment or subscription, etc. Defender alerts user when PUA is being downloaded or attempts to install itself. Added in Windows 10 for desktop. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderPotentiallyUnwantedAppActionSetting

    [DscProperty()]
    [System.ComponentModel.Description('Processes to exclude from scans and real time protection.')]
    [System.String[]] $DefenderProcessesToExclude

    [DscProperty()]
    [System.ComponentModel.Description('The configuration for how to prompt user for sample submission. Possible values are: userDefined, alwaysPrompt, promptBeforeSendingPersonalData, neverSendData, sendAllDataWithoutPrompting.')]
    [ValidateSet('userDefined', 'alwaysPrompt', 'promptBeforeSendingPersonalData', 'neverSendData', 'sendAllDataWithoutPrompting')]
    [System.String] $DefenderPromptForSampleSubmission

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require behavior monitoring.')]
    [System.Nullable[System.Boolean]] $DefenderRequireBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require cloud protection.')]
    [System.Nullable[System.Boolean]] $DefenderRequireCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require network inspection system.')]
    [System.Nullable[System.Boolean]] $DefenderRequireNetworkInspectionSystem

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require real time monitoring.')]
    [System.Nullable[System.Boolean]] $DefenderRequireRealTimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan archive files.')]
    [System.Nullable[System.Boolean]] $DefenderScanArchiveFiles

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan downloads.')]
    [System.Nullable[System.Boolean]] $DefenderScanDownloads

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan incoming mail messages.')]
    [System.Nullable[System.Boolean]] $DefenderScanIncomingMail

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan mapped network drives during full scan.')]
    [System.Nullable[System.Boolean]] $DefenderScanMappedNetworkDrivesDuringFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Max CPU usage percentage during scan. Valid values 0 to 100')]
    [System.Nullable[System.UInt32]] $DefenderScanMaxCpu

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan files opened from a network folder.')]
    [System.Nullable[System.Boolean]] $DefenderScanNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan removable drives during full scan.')]
    [System.Nullable[System.Boolean]] $DefenderScanRemovableDrivesDuringFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to scan scripts loaded in Internet Explorer browser.')]
    [System.Nullable[System.Boolean]] $DefenderScanScriptsLoadedInInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('The defender system scan type. Possible values are: userDefined, disabled, quick, full.')]
    [ValidateSet('userDefined', 'disabled', 'quick', 'full')]
    [System.String] $DefenderScanType

    [DscProperty()]
    [System.ComponentModel.Description('The time to perform a daily quick scan.')]
    [System.String] $DefenderScheduledQuickScanTime

    [DscProperty()]
    [System.ComponentModel.Description('The defender time for the system scan.')]
    [System.String] $DefenderScheduledScanTime

    [DscProperty()]
    [System.ComponentModel.Description('When enabled, low CPU priority will be used during scheduled scans.')]
    [System.Nullable[System.Boolean]] $DefenderScheduleScanEnableLowCpuPriority

    [DscProperty()]
    [System.ComponentModel.Description('The signature update interval in hours. Specify 0 not to check. Valid values 0 to 24')]
    [System.Nullable[System.UInt32]] $DefenderSignatureUpdateIntervalInHours

    [DscProperty()]
    [System.ComponentModel.Description('Checks for the user consent level in Windows Defender to send data. Possible values are: sendSafeSamplesAutomatically, alwaysPrompt, neverSend, sendAllSamplesAutomatically.')]
    [ValidateSet('sendSafeSamplesAutomatically', 'alwaysPrompt', 'neverSend', 'sendAllSamplesAutomatically')]
    [System.String] $DefenderSubmitSamplesConsentType

    [DscProperty()]
    [System.ComponentModel.Description('Defender day of the week for the system scan. Possible values are: userDefined, everyday, sunday, monday, tuesday, wednesday, thursday, friday, saturday, noScheduledScan.')]
    [ValidateSet('userDefined', 'everyday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'noScheduledScan')]
    [System.String] $DefenderSystemScanSchedule

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow developer unlock. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $DeveloperUnlockSetting

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from resetting their phone.')]
    [System.Nullable[System.Boolean]] $DeviceManagementBlockFactoryResetOnMobile

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from doing manual un-enrollment from device management.')]
    [System.Nullable[System.Boolean]] $DeviceManagementBlockManualUnenroll

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value allowing the device to send diagnostic and usage telemetry data, such as Watson. Possible values are: userDefined, none, basic, enhanced, full.')]
    [ValidateSet('userDefined', 'none', 'basic', 'enhanced', 'full')]
    [System.String] $DiagnosticsDataSubmissionMode

    [DscProperty()]
    [System.ComponentModel.Description('List of legacy applications that have GDI DPI Scaling turned off.')]
    [System.String[]] $DisplayAppListWithGdiDPIScalingTurnedOff

    [DscProperty()]
    [System.ComponentModel.Description('List of legacy applications that have GDI DPI Scaling turned on.')]
    [System.String[]] $DisplayAppListWithGdiDPIScalingTurnedOn

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to change Start pages on Edge. Use the EdgeHomepageUrls to specify the Start pages that the user would see by default when they open Edge.')]
    [System.Nullable[System.Boolean]] $EdgeAllowStartPagesModification

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to prevent access to about flags on Edge browser.')]
    [System.Nullable[System.Boolean]] $EdgeBlockAccessToAboutFlags

    [DscProperty()]
    [System.ComponentModel.Description('Block the address bar dropdown functionality in Microsoft Edge. Disable this settings to minimize network connections from Microsoft Edge to Microsoft services.')]
    [System.Nullable[System.Boolean]] $EdgeBlockAddressBarDropdown

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block auto fill.')]
    [System.Nullable[System.Boolean]] $EdgeBlockAutofill

    [DscProperty()]
    [System.ComponentModel.Description('Block Microsoft compatibility list in Microsoft Edge. This list from Microsoft helps Edge properly display sites with known compatibility issues.')]
    [System.Nullable[System.Boolean]] $EdgeBlockCompatibilityList

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block developer tools in the Edge browser.')]
    [System.Nullable[System.Boolean]] $EdgeBlockDeveloperTools

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using the Edge browser.')]
    [System.Nullable[System.Boolean]] $EdgeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from making changes to Favorites.')]
    [System.Nullable[System.Boolean]] $EdgeBlockEditFavorites

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block extensions in the Edge browser.')]
    [System.Nullable[System.Boolean]] $EdgeBlockExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Allow or prevent Edge from entering the full screen mode.')]
    [System.Nullable[System.Boolean]] $EdgeBlockFullScreenMode

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block InPrivate browsing on corporate networks, in the Edge browser.')]
    [System.Nullable[System.Boolean]] $EdgeBlockInPrivateBrowsing

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using JavaScript.')]
    [System.Nullable[System.Boolean]] $EdgeBlockJavaScript

    [DscProperty()]
    [System.ComponentModel.Description('Block the collection of information by Microsoft for live tile creation when users pin a site to Start from Microsoft Edge.')]
    [System.Nullable[System.Boolean]] $EdgeBlockLiveTileDataCollection

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block password manager.')]
    [System.Nullable[System.Boolean]] $EdgeBlockPasswordManager

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block popups.')]
    [System.Nullable[System.Boolean]] $EdgeBlockPopups

    [DscProperty()]
    [System.ComponentModel.Description('Decide whether Microsoft Edge is prelaunched at Windows startup.')]
    [System.Nullable[System.Boolean]] $EdgeBlockPrelaunch

    [DscProperty()]
    [System.ComponentModel.Description('Configure Edge to allow or block printing.')]
    [System.Nullable[System.Boolean]] $EdgeBlockPrinting

    [DscProperty()]
    [System.ComponentModel.Description('Configure Edge to allow browsing history to be saved or to never save browsing history.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSavingHistory

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from adding new search engine or changing the default search engine.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSearchEngineCustomization

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from using the search suggestions in the address bar.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSearchSuggestions

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from sending the do not track header.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSendingDoNotTrackHeader

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to switch the intranet traffic from Edge to Internet Explorer. Note: the name of this property is misleading the property is obsolete, use EdgeSendIntranetTrafficToInternetExplorer instead.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSendingIntranetTrafficToInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the user can sideload extensions.')]
    [System.Nullable[System.Boolean]] $EdgeBlockSideloadingExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Configure whether Edge preloads the new tab page at Windows startup.')]
    [System.Nullable[System.Boolean]] $EdgeBlockTabPreloading

    [DscProperty()]
    [System.ComponentModel.Description('Configure to load a blank page in Edge instead of the default New tab page and prevent users from changing it.')]
    [System.Nullable[System.Boolean]] $EdgeBlockWebContentOnNewTabPage

    [DscProperty()]
    [System.ComponentModel.Description('Clear browsing data on exiting Microsoft Edge.')]
    [System.Nullable[System.Boolean]] $EdgeClearBrowsingDataOnExit

    [DscProperty()]
    [System.ComponentModel.Description('Indicates which cookies to block in the Edge browser. Possible values are: userDefined, allow, blockThirdParty, blockAll.')]
    [ValidateSet('userDefined', 'allow', 'blockThirdParty', 'blockAll')]
    [System.String] $EdgeCookiePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Block the Microsoft web page that opens on the first use of Microsoft Edge. This policy allows enterprises, like those enrolled in zero emissions configurations, to block this page.')]
    [System.Nullable[System.Boolean]] $EdgeDisableFirstRunPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the enterprise mode site list location. Could be a local file, local network or http location.')]
    [System.String] $EdgeEnterpriseModeSiteListLocation

    [DscProperty()]
    [System.ComponentModel.Description('Get or set a value that specifies whether to set the favorites bar to always be visible or hidden on any page. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $EdgeFavoritesBarVisibility

    [DscProperty()]
    [System.ComponentModel.Description('The location of the favorites list to provision. Could be a local file, local network or http location.')]
    [System.String] $EdgeFavoritesListLocation

    [DscProperty()]
    [System.ComponentModel.Description('The first run URL for when Edge browser is opened for the first time.')]
    [System.String] $EdgeFirstRunUrl

    [DscProperty()]
    [System.ComponentModel.Description('Causes the Home button to either hide, load the default Start page, load a New tab page, or a custom URL')]
    [MSFT_MicrosoftGraphedgeHomeButtonConfiguration] $EdgeHomeButtonConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Enable the Home button configuration.')]
    [System.Nullable[System.Boolean]] $EdgeHomeButtonConfigurationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The list of URLs for homepages shodwn on MDM-enrolled devices on Edge browser.')]
    [System.String[]] $EdgeHomepageUrls

    [DscProperty()]
    [System.ComponentModel.Description('Controls how the Microsoft Edge settings are restricted based on the configure kiosk mode. Possible values are: notConfigured, digitalSignage, normalMode, publicBrowsingSingleApp, publicBrowsingMultiApp.')]
    [ValidateSet('notConfigured', 'digitalSignage', 'normalMode', 'publicBrowsingSingleApp', 'publicBrowsingMultiApp')]
    [System.String] $EdgeKioskModeRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time in minutes from the last user activity before Microsoft Edge kiosk resets.  Valid values are 0-1440. The default is 5. 0 indicates no reset. Valid values 0 to 1440')]
    [System.Nullable[System.UInt32]] $EdgeKioskResetAfterIdleTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Specify the page opened when new tabs are created.')]
    [System.String] $EdgeNewTabPageURL

    [DscProperty()]
    [System.ComponentModel.Description('Specify what kind of pages are open at start. Possible values are: notConfigured, startPage, newTabPage, previousPages, specificPages.')]
    [ValidateSet('notConfigured', 'startPage', 'newTabPage', 'previousPages', 'specificPages')]
    [System.String] $EdgeOpensWith

    [DscProperty()]
    [System.ComponentModel.Description('Allow or prevent users from overriding certificate errors.')]
    [System.Nullable[System.Boolean]] $EdgePreventCertificateErrorOverride

    [DscProperty()]
    [System.ComponentModel.Description('Specify the list of package family names of browser extensions that are required and cannot be turned off by the user.')]
    [System.String[]] $EdgeRequiredExtensionPackageFamilyNames

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Require the user to use the smart screen filter.')]
    [System.Nullable[System.Boolean]] $EdgeRequireSmartScreen

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT admins to set a default search engine for MDM-Controlled devices. Users can override this and change their default search engine provided the AllowSearchEngineCustomization policy is not set.')]
    [MSFT_MicrosoftGraphedgeSearchEngineBase] $EdgeSearchEngine

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to switch the intranet traffic from Edge to Internet Explorer.')]
    [System.Nullable[System.Boolean]] $EdgeSendIntranetTrafficToInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Controls the message displayed by Edge before switching to Internet Explorer. Possible values are: notConfigured, disabled, enabled, keepGoing.')]
    [ValidateSet('notConfigured', 'disabled', 'enabled', 'keepGoing')]
    [System.String] $EdgeShowMessageWhenOpeningInternetExplorerSites

    [DscProperty()]
    [System.ComponentModel.Description('Enable favorites sync between Internet Explorer and Microsoft Edge. Additions, deletions, modifications and order changes to favorites are shared between browsers.')]
    [System.Nullable[System.Boolean]] $EdgeSyncFavoritesWithInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what type of telemetry data (none, intranet, internet, both) is sent to Microsoft 365 Analytics. Possible values are: notConfigured, intranet, internet, intranetAndInternet.')]
    [ValidateSet('notConfigured', 'intranet', 'internet', 'intranetAndInternet')]
    [System.String] $EdgeTelemetryForMicrosoft365Analytics

    [DscProperty()]
    [System.ComponentModel.Description('Allow users with administrative rights to delete all user data and settings using CTRL + Win + R at the device lock screen so that the device can be automatically re-configured and re-enrolled into management.')]
    [System.Nullable[System.Boolean]] $EnableAutomaticRedeployment

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows you to specify battery charge level at which Energy Saver is turned on. While on battery, Energy Saver is automatically turned on at (and below) the specified battery charge level. Valid input range (0-100). Valid values 0 to 100')]
    [System.Nullable[System.UInt32]] $EnergySaverOnBatteryThresholdPercentage

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows you to specify battery charge level at which Energy Saver is turned on. While plugged in, Energy Saver is automatically turned on at (and below) the specified battery charge level. Valid input range (0-100). Valid values 0 to 100')]
    [System.Nullable[System.UInt32]] $EnergySaverPluggedInThresholdPercentage

    [DscProperty()]
    [System.ComponentModel.Description('Endpoint for discovering cloud printers.')]
    [System.String] $EnterpriseCloudPrintDiscoveryEndPoint

    [DscProperty()]
    [System.ComponentModel.Description('Maximum number of printers that should be queried from a discovery endpoint. This is a mobile only setting. Valid values 1 to 65535')]
    [System.Nullable[System.UInt32]] $EnterpriseCloudPrintDiscoveryMaxLimit

    [DscProperty()]
    [System.ComponentModel.Description('OAuth resource URI for printer discovery service as configured in Azure portal.')]
    [System.String] $EnterpriseCloudPrintMopriaDiscoveryResourceIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Authentication endpoint for acquiring OAuth tokens.')]
    [System.String] $EnterpriseCloudPrintOAuthAuthority

    [DscProperty()]
    [System.ComponentModel.Description('GUID of a client application authorized to retrieve OAuth tokens from the OAuth Authority.')]
    [System.String] $EnterpriseCloudPrintOAuthClientIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('OAuth resource URI for print service as configured in the Azure portal.')]
    [System.String] $EnterpriseCloudPrintResourceIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enable device discovery UX.')]
    [System.Nullable[System.Boolean]] $ExperienceBlockDeviceDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow the error dialog from displaying if no SIM card is detected.')]
    [System.Nullable[System.Boolean]] $ExperienceBlockErrorDialogWhenNoSIM

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enable task switching on the device.')]
    [System.Nullable[System.Boolean]] $ExperienceBlockTaskSwitcher

    [DscProperty()]
    [System.ComponentModel.Description('Allow or prevent the syncing of Microsoft Edge Browser settings. Option for IT admins to prevent syncing across devices, but allow user override. Possible values are: notConfigured, blockedWithUserOverride, blocked.')]
    [ValidateSet('notConfigured', 'blockedWithUserOverride', 'blocked')]
    [System.String] $ExperienceDoNotSyncBrowserSettings

    [DscProperty()]
    [System.ComponentModel.Description('Controls if the user can configure search to Find My Files mode, which searches files in secondary hard drives and also outside of the user profile. Find My Files does not allow users to search files or locations to which they do not have access. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $FindMyFiles

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block DVR and broadcasting.')]
    [System.Nullable[System.Boolean]] $GameDvrBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Controls the user access to the ink workspace, from the desktop and from above the lock screen. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $InkWorkspaceAccess

    [DscProperty()]
    [System.ComponentModel.Description('Controls the user access to the ink workspace, from the desktop and from above the lock screen. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $InkWorkspaceAccessState

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether to show recommended app suggestions in the ink workspace.')]
    [System.Nullable[System.Boolean]] $InkWorkspaceBlockSuggestedApps

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using internet sharing.')]
    [System.Nullable[System.Boolean]] $InternetSharingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from location services.')]
    [System.Nullable[System.Boolean]] $LocationServicesBlocked

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting specifies whether Windows apps can be activated by voice while the system is locked. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $LockScreenActivateAppsWithVoice

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether to show a user-configurable setting to control the screen timeout while on the lock screen of Windows 10 Mobile devices. If this policy is set to Allow, the value set by lockScreenTimeoutInSeconds is ignored.')]
    [System.Nullable[System.Boolean]] $LockScreenAllowTimeoutConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block action center notifications over lock screen.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockActionCenterNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not the user can interact with Cortana using speech while the system is locked.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockCortana

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to allow toast notifications above the device lock screen.')]
    [System.Nullable[System.Boolean]] $LockScreenBlockToastNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Set the duration (in seconds) from the screen locking to the screen turning off for Windows 10 Mobile devices. Supported values are 11-1800. Valid values 11 to 1800')]
    [System.Nullable[System.UInt32]] $LockScreenTimeoutInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Disables the ability to quickly switch between users that are logged on simultaneously without logging off.')]
    [System.Nullable[System.Boolean]] $LogonBlockFastUserSwitching

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the MMS send/receive functionality on the device.')]
    [System.Nullable[System.Boolean]] $MessagingBlockMMS

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the RCS send/receive functionality on the device.')]
    [System.Nullable[System.Boolean]] $MessagingBlockRichCommunicationServices

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block text message back up and restore and Messaging Everywhere.')]
    [System.Nullable[System.Boolean]] $MessagingBlockSync

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block a Microsoft account.')]
    [System.Nullable[System.Boolean]] $MicrosoftAccountBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block Microsoft account settings sync.')]
    [System.Nullable[System.Boolean]] $MicrosoftAccountBlockSettingsSync

    [DscProperty()]
    [System.ComponentModel.Description('Controls the Microsoft Account Sign-In Assistant (wlidsvc) NT service. Possible values are: notConfigured, disabled.')]
    [ValidateSet('notConfigured', 'disabled')]
    [System.String] $MicrosoftAccountSignInAssistantSettings

    [DscProperty()]
    [System.ComponentModel.Description('If set, proxy settings will be applied to all processes and accounts in the device. Otherwise, it will be applied to the user account that''s enrolled into MDM.')]
    [System.Nullable[System.Boolean]] $NetworkProxyApplySettingsDeviceWide

    [DscProperty()]
    [System.ComponentModel.Description('Address to the proxy auto-config (PAC) script you want to use.')]
    [System.String] $NetworkProxyAutomaticConfigurationUrl

    [DscProperty()]
    [System.ComponentModel.Description('Disable automatic detection of settings. If enabled, the system will try to find the path to a proxy auto-config (PAC) script.')]
    [System.Nullable[System.Boolean]] $NetworkProxyDisableAutoDetect

    [DscProperty()]
    [System.ComponentModel.Description('Specifies manual proxy server settings.')]
    [MSFT_MicrosoftGraphwindows10NetworkProxyServer] $NetworkProxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using near field communication.')]
    [System.Nullable[System.Boolean]] $NfcBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value allowing IT admins to prevent apps and features from working with files on OneDrive.')]
    [System.Nullable[System.Boolean]] $OneDriveDisableFileSync

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether PINs or passwords such as ''1111'' or ''1234'' are allowed. For Windows 10 desktops, it also controls the use of picture passwords.')]
    [System.Nullable[System.Boolean]] $PasswordBlockSimple

    [DscProperty()]
    [System.ComponentModel.Description('The password expiration in days. Valid values 0 to 730')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines the period of time (in days) that a password must be used before the user can change it. Valid values 0 to 998')]
    [System.Nullable[System.UInt32]] $PasswordMinimumAgeInDays

    [DscProperty()]
    [System.ComponentModel.Description('The number of character sets required in the password.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumCharacterSetCount

    [DscProperty()]
    [System.ComponentModel.Description('The minimum password length. Valid values 4 to 16')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('The minutes of inactivity before the screen times out.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('The number of previous passwords to prevent reuse of. Valid values 0 to 50')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require the user to have a password.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('The required password type. Possible values are: deviceDefault, alphanumeric, numeric.')]
    [ValidateSet('deviceDefault', 'alphanumeric', 'numeric')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require a password upon resuming from an idle state.')]
    [System.Nullable[System.Boolean]] $PasswordRequireWhenResumeFromIdleState

    [DscProperty()]
    [System.ComponentModel.Description('The number of sign in failures before factory reset. Valid values 0 to 999')]
    [System.Nullable[System.UInt32]] $PasswordSignInFailureCountBeforeFactoryReset

    [DscProperty()]
    [System.ComponentModel.Description('A http or https Url to a jpg, jpeg or png image that needs to be downloaded and used as the Desktop Image or a file Url to a local image on the file system that needs to used as the Desktop Image.')]
    [System.String] $PersonalizationDesktopImageUrl

    [DscProperty()]
    [System.ComponentModel.Description('A http or https Url to a jpg, jpeg or png image that needs to be downloaded and used as the Lock Screen Image or a file Url to a local image on the file system that needs to be used as the Lock Screen Image.')]
    [System.String] $PersonalizationLockScreenImageUrl

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user presses the Power button while on battery. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerButtonActionOnBattery

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user presses the Power button while plugged in. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerButtonActionPluggedIn

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows you to turn off hybrid sleep while on battery. If you set this setting to disable, a hiberfile is not generated when the system transitions to sleep (Stand By). If you set this setting to enable or do not configure this policy setting, users control this setting. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $PowerHybridSleepOnBattery

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows you to turn off hybrid sleep while plugged in. If you set this setting to disable, a hiberfile is not generated when the system transitions to sleep (Stand By). If you set this setting to enable or do not configure this policy setting, users control this setting. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $PowerHybridSleepPluggedIn

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user closes the lid on a mobile PC while on battery. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerLidCloseActionOnBattery

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user closes the lid on a mobile PC while plugged in. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerLidCloseActionPluggedIn

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user presses the Sleep button while on battery. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerSleepButtonActionOnBattery

    [DscProperty()]
    [System.ComponentModel.Description('This setting specifies the action that Windows takes when a user presses the Sleep button while plugged in. Possible values are: notConfigured, noAction, sleep, hibernate, shutdown.')]
    [ValidateSet('notConfigured', 'noAction', 'sleep', 'hibernate', 'shutdown')]
    [System.String] $PowerSleepButtonActionPluggedIn

    [DscProperty()]
    [System.ComponentModel.Description('Prevent user installation of additional printers from printers settings.')]
    [System.Nullable[System.Boolean]] $PrinterBlockAddition

    [DscProperty()]
    [System.ComponentModel.Description('Name (network host name) of an installed printer.')]
    [System.String] $PrinterDefaultName

    [DscProperty()]
    [System.ComponentModel.Description('Automatically provision printers based on their names (network host names).')]
    [System.String[]] $PrinterNames

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the use of advertising ID. Added in Windows 10, version 1607. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $PrivacyAdvertisingId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow the automatic acceptance of the pairing and privacy user consent dialog when launching apps.')]
    [System.Nullable[System.Boolean]] $PrivacyAutoAcceptPairingAndConsentPrompts

    [DscProperty()]
    [System.ComponentModel.Description('Blocks the usage of cloud based speech services for Cortana, Dictation, or Store applications.')]
    [System.Nullable[System.Boolean]] $PrivacyBlockActivityFeed

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the usage of cloud based speech services for Cortana, Dictation, or Store applications.')]
    [System.Nullable[System.Boolean]] $PrivacyBlockInputPersonalization

    [DscProperty()]
    [System.ComponentModel.Description('Blocks the shared experiences/discovery of recently used resources in task switcher etc.')]
    [System.Nullable[System.Boolean]] $PrivacyBlockPublishUserActivities

    [DscProperty()]
    [System.ComponentModel.Description('This policy prevents the privacy experience from launching during user logon for new and upgraded users.')]
    [System.Nullable[System.Boolean]] $PrivacyDisableLaunchExperience

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from reset protection mode.')]
    [System.Nullable[System.Boolean]] $ResetProtectionModeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what filter level of safe search is required. Possible values are: userDefined, strict, moderate.')]
    [ValidateSet('userDefined', 'strict', 'moderate')]
    [System.String] $SafeSearchFilter

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from taking Screenshots.')]
    [System.Nullable[System.Boolean]] $ScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if search can use diacritics.')]
    [System.Nullable[System.Boolean]] $SearchBlockDiacritics

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the web search.')]
    [System.Nullable[System.Boolean]] $SearchBlockWebResults

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to use automatic language detection when indexing content and properties.')]
    [System.Nullable[System.Boolean]] $SearchDisableAutoLanguageDetection

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to disable the search indexer backoff feature.')]
    [System.Nullable[System.Boolean]] $SearchDisableIndexerBackoff

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block indexing of WIP-protected items to prevent them from appearing in search results for Cortana or Explorer.')]
    [System.Nullable[System.Boolean]] $SearchDisableIndexingEncryptedItems

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow users to add locations on removable drives to libraries and to be indexed.')]
    [System.Nullable[System.Boolean]] $SearchDisableIndexingRemovableDrive

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if search can use location information.')]
    [System.Nullable[System.Boolean]] $SearchDisableLocation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if search can use location information.')]
    [System.Nullable[System.Boolean]] $SearchDisableUseLocation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies minimum amount of hard drive space on the same drive as the index location before indexing stops.')]
    [System.Nullable[System.Boolean]] $SearchEnableAutomaticIndexSizeManangement

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block remote queries of this computers index.')]
    [System.Nullable[System.Boolean]] $SearchEnableRemoteQueries

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether to allow automatic device encryption during OOBE when the device is Azure AD joined (desktop only).')]
    [System.Nullable[System.Boolean]] $SecurityBlockAzureADJoinedDevicesAutoEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Accounts in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockAccountsPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from installing provisioning packages.')]
    [System.Nullable[System.Boolean]] $SettingsBlockAddProvisioningPackage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Apps in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockAppsPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from changing the language settings.')]
    [System.Nullable[System.Boolean]] $SettingsBlockChangeLanguage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from changing power and sleep settings.')]
    [System.Nullable[System.Boolean]] $SettingsBlockChangePowerSleep

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from changing the region settings.')]
    [System.Nullable[System.Boolean]] $SettingsBlockChangeRegion

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from changing date and time settings.')]
    [System.Nullable[System.Boolean]] $SettingsBlockChangeSystemTime

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Devices in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockDevicesPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Ease of Access in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockEaseOfAccessPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from editing the device name.')]
    [System.Nullable[System.Boolean]] $SettingsBlockEditDeviceName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Gaming in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockGamingPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Network & Internet in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockNetworkInternetPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Personalization in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockPersonalizationPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Privacy in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockPrivacyPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the runtime configuration agent from removing provisioning packages.')]
    [System.Nullable[System.Boolean]] $SettingsBlockRemoveProvisioningPackage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockSettingsApp

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to System in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockSystemPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Time & Language in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockTimeLanguagePage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block access to Update & Security in Settings app.')]
    [System.Nullable[System.Boolean]] $SettingsBlockUpdateSecurityPage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block multiple users of the same app to share data.')]
    [System.Nullable[System.Boolean]] $SharedUserAppDataAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Added in Windows 10, version 1703. Allows IT Admins to control whether users are allowed to install apps from places other than the Store. Possible values are: notConfigured, anywhere, storeOnly, recommendations, preferStore.')]
    [ValidateSet('notConfigured', 'anywhere', 'storeOnly', 'recommendations', 'preferStore')]
    [System.String] $SmartScreenAppInstallControl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not users can override SmartScreen Filter warnings about potentially malicious websites.')]
    [System.Nullable[System.Boolean]] $SmartScreenBlockPromptOverride

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not users can override the SmartScreen Filter warnings about downloading unverified files')]
    [System.Nullable[System.Boolean]] $SmartScreenBlockPromptOverrideForFiles

    [DscProperty()]
    [System.ComponentModel.Description('This property will be deprecated in July 2019 and will be replaced by property SmartScreenAppInstallControl. Allows IT Admins to control whether users are allowed to install apps from places other than the Store.')]
    [System.Nullable[System.Boolean]] $SmartScreenEnableAppInstallControl

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block the user from unpinning apps from taskbar.')]
    [System.Nullable[System.Boolean]] $StartBlockUnpinningAppsFromTaskbar

    [DscProperty()]
    [System.ComponentModel.Description('Setting the value of this collapses the app list, removes the app list entirely, or disables the corresponding toggle in the Settings app. Possible values are: userDefined, collapse, remove, disableSettingsApp.')]
    [ValidateSet('userDefined', 'collapse', 'remove', 'disableSettingsApp')]
    [System.String] $StartMenuAppListVisibility

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides the change account setting from appearing in the user tile in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideChangeAccountSettings

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides the most used apps from appearing on the start menu and disables the corresponding toggle in the Settings app.')]
    [System.Nullable[System.Boolean]] $StartMenuHideFrequentlyUsedApps

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides hibernate from appearing in the power button in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideHibernate

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides lock from appearing in the user tile in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideLock

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides the power button from appearing in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHidePowerButton

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides recent jump lists from appearing on the start menu/taskbar and disables the corresponding toggle in the Settings app.')]
    [System.Nullable[System.Boolean]] $StartMenuHideRecentJumpLists

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides recently added apps from appearing on the start menu and disables the corresponding toggle in the Settings app.')]
    [System.Nullable[System.Boolean]] $StartMenuHideRecentlyAddedApps

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides ''Restart/Update and Restart'' from appearing in the power button in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideRestartOptions

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides shut down/update and shut down from appearing in the power button in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideShutDown

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides sign out from appearing in the user tile in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideSignOut

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides sleep from appearing in the power button in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideSleep

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides switch account from appearing in the user tile in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideSwitchAccount

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this policy hides the user tile from appearing in the start menu.')]
    [System.Nullable[System.Boolean]] $StartMenuHideUserTile

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to import Edge assets to be used with startMenuLayoutXml policy. Start layout can contain secondary tile from Edge app which looks for Edge local asset file. Edge local asset would not exist and cause Edge secondary tile to appear empty in this case. This policy only gets applied when startMenuLayoutXml policy is modified. The value should be a UTF-8 Base64 encoded byte array.')]
    [System.String] $StartMenuLayoutEdgeAssetsXml

    [DscProperty()]
    [System.ComponentModel.Description('Allows admins to override the default Start menu layout and prevents the user from changing it. The layout is modified by specifying an XML file based on a layout modification schema. XML needs to be in a UTF8 encoded byte array format.')]
    [System.String] $StartMenuLayoutXml

    [DscProperty()]
    [System.ComponentModel.Description('Allows admins to decide how the Start menu is displayed. Possible values are: userDefined, fullScreen, nonFullScreen.')]
    [ValidateSet('userDefined', 'fullScreen', 'nonFullScreen')]
    [System.String] $StartMenuMode

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Documents folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderDocuments

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Downloads folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderDownloads

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the FileExplorer shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderFileExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the HomeGroup folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderHomeGroup

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Music folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderMusic

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Network folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the PersonalFolder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderPersonalFolder

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Pictures folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderPictures

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Settings folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderSettings

    [DscProperty()]
    [System.ComponentModel.Description('Enforces the visibility (Show/Hide) of the Videos folder shortcut on the Start menu. Possible values are: notConfigured, hide, show.')]
    [ValidateSet('notConfigured', 'hide', 'show')]
    [System.String] $StartMenuPinnedFolderVideos

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using removable storage.')]
    [System.Nullable[System.Boolean]] $StorageBlockRemovableStorage

    [DscProperty()]
    [System.ComponentModel.Description('Indicating whether or not to require encryption on a mobile device.')]
    [System.Nullable[System.Boolean]] $StorageRequireMobileDeviceEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether application data is restricted to the system drive.')]
    [System.Nullable[System.Boolean]] $StorageRestrictAppDataToSystemVolume

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the installation of applications is restricted to the system drive.')]
    [System.Nullable[System.Boolean]] $StorageRestrictAppInstallToSystemVolume

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the fully qualified domain name (FQDN) or IP address of a proxy server to forward Connected User Experiences and Telemetry requests.')]
    [System.String] $SystemTelemetryProxyServer

    [DscProperty()]
    [System.ComponentModel.Description('Specify whether non-administrators can use Task Manager to end tasks.')]
    [System.Nullable[System.Boolean]] $TaskManagerBlockEndTask

    [DscProperty()]
    [System.ComponentModel.Description('Whether the device is required to connect to the network.')]
    [System.Nullable[System.Boolean]] $TenantLockdownRequireNetworkDuringOutOfBoxExperience

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to uninstall a fixed list of built-in Windows apps.')]
    [System.Nullable[System.Boolean]] $UninstallBuiltInApps

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from USB connection.')]
    [System.Nullable[System.Boolean]] $UsbBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from voice recording.')]
    [System.Nullable[System.Boolean]] $VoiceRecordingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not user''s localhost IP address is displayed while making phone calls using the WebRTC')]
    [System.Nullable[System.Boolean]] $WebRtcBlockLocalhostIpAddress

    [DscProperty()]
    [System.ComponentModel.Description('Indicating whether or not to block automatically connecting to Wi-Fi hotspots. Has no impact if Wi-Fi is blocked.')]
    [System.Nullable[System.Boolean]] $WiFiBlockAutomaticConnectHotspots

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using Wi-Fi.')]
    [System.Nullable[System.Boolean]] $WiFiBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using Wi-Fi manual configuration.')]
    [System.Nullable[System.Boolean]] $WiFiBlockManualConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Specify how often devices scan for Wi-Fi networks. Supported values are 1-500, where 100 = default, and 500 = low frequency. Valid values 1 to 500')]
    [System.Nullable[System.UInt32]] $WiFiScanInterval

    [DscProperty()]
    [System.ComponentModel.Description('Windows 10 force update schedule for Apps.')]
    [MSFT_MicrosoftGraphwindows10AppsForceUpdateSchedule] $Windows10AppsForceUpdateSchedule

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT admins to block experiences that are typically for consumers only, such as Start suggestions, Membership notifications, Post-OOBE app install and redirect tiles.')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockConsumerSpecificFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT admins to turn off all Windows Spotlight features')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block suggestions from Microsoft that show after each OS clean install, upgrade or in an on-going basis to introduce users to what is new or changed')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockOnActionCenter

    [DscProperty()]
    [System.ComponentModel.Description('Block personalized content in Windows spotlight based on users device usage.')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockTailoredExperiences

    [DscProperty()]
    [System.ComponentModel.Description('Block third party content delivered via Windows Spotlight')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockThirdPartyNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Block Windows Spotlight Windows welcome experience')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockWelcomeExperience

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT admins to turn off the popup of Windows Tips.')]
    [System.Nullable[System.Boolean]] $WindowsSpotlightBlockWindowsTips

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the type of Spotlight. Possible values are: notConfigured, disabled, enabled.')]
    [ValidateSet('notConfigured', 'disabled', 'enabled')]
    [System.String] $WindowsSpotlightConfigureOnLockScreen

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block automatic update of apps from Windows Store.')]
    [System.Nullable[System.Boolean]] $WindowsStoreBlockAutoUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to Block the user from using the Windows store.')]
    [System.Nullable[System.Boolean]] $WindowsStoreBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enable Private Store Only.')]
    [System.Nullable[System.Boolean]] $WindowsStoreEnablePrivateStoreOnly

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow other devices from discovering this PC for projection.')]
    [System.Nullable[System.Boolean]] $WirelessDisplayBlockProjectionToThisDevice

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow user input from wireless display receiver.')]
    [System.Nullable[System.Boolean]] $WirelessDisplayBlockUserInputFromReceiver

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to require a PIN for new devices to initiate pairing.')]
    [System.Nullable[System.Boolean]] $WirelessDisplayRequirePinForPairing

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [IntuneDeviceConfigurationPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy for Windows 10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows10GeneralConfiguration')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexDefenderDetectedMalwareActions = [ordered]@{}
            if ($null -ne $getValue.defenderDetectedMalwareActions.highSeverity)
            {
                $complexDefenderDetectedMalwareActions.Add('HighSeverity', $getValue.defenderDetectedMalwareActions.highSeverity)
            }
            if ($null -ne $getValue.defenderDetectedMalwareActions.lowSeverity)
            {
                $complexDefenderDetectedMalwareActions.Add('LowSeverity', $getValue.defenderDetectedMalwareActions.lowSeverity)
            }
            if ($null -ne $getValue.defenderDetectedMalwareActions.moderateSeverity)
            {
                $complexDefenderDetectedMalwareActions.Add('ModerateSeverity', $getValue.defenderDetectedMalwareActions.moderateSeverity)
            }
            if ($null -ne $getValue.defenderDetectedMalwareActions.severeSeverity)
            {
                $complexDefenderDetectedMalwareActions.Add('SevereSeverity', $getValue.defenderDetectedMalwareActions.severeSeverity)
            }
            if ($complexDefenderDetectedMalwareActions.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDefenderDetectedMalwareActions = $null
            }

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }

            $complexEdgeHomeButtonConfiguration = [ordered]@{}
            $complexEdgeHomeButtonConfiguration.Add('HomeButtonCustomURL', $getValue.edgeHomeButtonConfiguration.homeButtonCustomURL)
            if ($null -ne $getValue.edgeHomeButtonConfiguration.'@odata.type')
            {
                $complexEdgeHomeButtonConfiguration.Add('odataType', $getValue.edgeHomeButtonConfiguration.'@odata.type')
            }
            if ($complexEdgeHomeButtonConfiguration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexEdgeHomeButtonConfiguration = $null
            }

            $complexEdgeSearchEngine = [ordered]@{}
            if ($null -ne $getValue.edgeSearchEngine.edgeSearchEngineType)
            {
                $complexEdgeSearchEngine.Add('EdgeSearchEngineType', $getValue.edgeSearchEngine.edgeSearchEngineType)
            }
            $complexEdgeSearchEngine.Add('EdgeSearchEngineOpenSearchXmlUrl', $getValue.edgeSearchEngine.edgeSearchEngineOpenSearchXmlUrl)
            if ($null -ne $getValue.edgeSearchEngine.'@odata.type')
            {
                $complexEdgeSearchEngine.Add('odataType', $getValue.edgeSearchEngine.'@odata.type')
            }
            if ($complexEdgeSearchEngine.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexEdgeSearchEngine = $null
            }

            $complexNetworkProxyServer = [ordered]@{}
            $complexNetworkProxyServer.Add('Address', $getValue.networkProxyServer.address)
            $complexNetworkProxyServer.Add('Exceptions', $getValue.networkProxyServer.exceptions)
            $complexNetworkProxyServer.Add('UseForLocalAddresses', $getValue.networkProxyServer.useForLocalAddresses)
            if ($complexNetworkProxyServer.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexNetworkProxyServer = $null
            }

            $complexWindows10AppsForceUpdateSchedule = [ordered]@{}
            if ($null -ne $getValue.windows10AppsForceUpdateSchedule.recurrence)
            {
                $complexWindows10AppsForceUpdateSchedule.Add('Recurrence', $getValue.windows10AppsForceUpdateSchedule.recurrence)
            }
            $complexWindows10AppsForceUpdateSchedule.Add('RunImmediatelyIfAfterStartDateTime', $getValue.windows10AppsForceUpdateSchedule.runImmediatelyIfAfterStartDateTime)
            if ($null -ne $getValue.windows10AppsForceUpdateSchedule.startDateTime)
            {
                $complexWindows10AppsForceUpdateSchedule.Add('StartDateTime', ([DateTimeOffset]$getValue.windows10AppsForceUpdateSchedule.startDateTime).ToString('o'))
            }
            if ($complexWindows10AppsForceUpdateSchedule.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexWindows10AppsForceUpdateSchedule = $null
            }
            #endregion

            #region resource generator code
            $timeDefenderScheduledQuickScanTime = $null
            if ($null -ne $getValue.defenderScheduledQuickScanTime)
            {
                $timeDefenderScheduledQuickScanTime = ([TimeSpan]$getValue.defenderScheduledQuickScanTime).ToString()
            }

            $timeDefenderScheduledScanTime = $null
            if ($null -ne $getValue.defenderScheduledScanTime)
            {
                $timeDefenderScheduledScanTime = ([TimeSpan]$getValue.defenderScheduledScanTime).ToString()
            }
            #endregion

            $results = @{
                #region resource generator code
                AccountsBlockAddingNonMicrosoftAccountEmail           = $getValue.accountsBlockAddingNonMicrosoftAccountEmail
                ActivateAppsWithVoice                                 = $getValue.activateAppsWithVoice
                AntiTheftModeBlocked                                  = $getValue.antiTheftModeBlocked
                AppManagementMSIAllowUserControlOverInstall           = $getValue.appManagementMSIAllowUserControlOverInstall
                AppManagementMSIAlwaysInstallWithElevatedPrivileges   = $getValue.appManagementMSIAlwaysInstallWithElevatedPrivileges
                AppManagementPackageFamilyNamesToLaunchAfterLogOn     = $getValue.appManagementPackageFamilyNamesToLaunchAfterLogOn
                AppsAllowTrustedAppsSideloading                       = $getValue.appsAllowTrustedAppsSideloading
                AppsBlockWindowsStoreOriginatedApps                   = $getValue.appsBlockWindowsStoreOriginatedApps
                AuthenticationAllowSecondaryDevice                    = $getValue.authenticationAllowSecondaryDevice
                AuthenticationPreferredAzureADTenantDomainName        = $getValue.authenticationPreferredAzureADTenantDomainName
                AuthenticationWebSignIn                               = $getValue.authenticationWebSignIn
                BluetoothAllowedServices                              = $getValue.bluetoothAllowedServices
                BluetoothBlockAdvertising                             = $getValue.bluetoothBlockAdvertising
                BluetoothBlockDiscoverableMode                        = $getValue.bluetoothBlockDiscoverableMode
                BluetoothBlocked                                      = $getValue.bluetoothBlocked
                BluetoothBlockPrePairing                              = $getValue.bluetoothBlockPrePairing
                BluetoothBlockPromptedProximalConnections             = $getValue.bluetoothBlockPromptedProximalConnections
                CameraBlocked                                         = $getValue.cameraBlocked
                CellularBlockDataWhenRoaming                          = $getValue.cellularBlockDataWhenRoaming
                CellularBlockVpn                                      = $getValue.cellularBlockVpn
                CellularBlockVpnWhenRoaming                           = $getValue.cellularBlockVpnWhenRoaming
                CellularData                                          = $getValue.cellularData
                CertificatesBlockManualRootCertificateInstallation    = $getValue.certificatesBlockManualRootCertificateInstallation
                ConfigureTimeZone                                     = $getValue.configureTimeZone
                ConnectedDevicesServiceBlocked                        = $getValue.connectedDevicesServiceBlocked
                CopyPasteBlocked                                      = $getValue.copyPasteBlocked
                CortanaBlocked                                        = $getValue.cortanaBlocked
                CryptographyAllowFipsAlgorithmPolicy                  = $getValue.cryptographyAllowFipsAlgorithmPolicy
                DataProtectionBlockDirectMemoryAccess                 = $getValue.dataProtectionBlockDirectMemoryAccess
                DefenderBlockEndUserAccess                            = $getValue.defenderBlockEndUserAccess
                DefenderBlockOnAccessProtection                       = $getValue.defenderBlockOnAccessProtection
                DefenderCloudBlockLevel                               = $getValue.defenderCloudBlockLevel
                DefenderCloudExtendedTimeout                          = $getValue.defenderCloudExtendedTimeout
                DefenderCloudExtendedTimeoutInSeconds                 = $getValue.defenderCloudExtendedTimeoutInSeconds
                DefenderDaysBeforeDeletingQuarantinedMalware          = $getValue.defenderDaysBeforeDeletingQuarantinedMalware
                DefenderDetectedMalwareActions                        = $complexDefenderDetectedMalwareActions
                DefenderDisableCatchupFullScan                        = $getValue.defenderDisableCatchupFullScan
                DefenderDisableCatchupQuickScan                       = $getValue.defenderDisableCatchupQuickScan
                DefenderFileExtensionsToExclude                       = $getValue.defenderFileExtensionsToExclude
                DefenderFilesAndFoldersToExclude                      = $getValue.defenderFilesAndFoldersToExclude
                DefenderMonitorFileActivity                           = $getValue.defenderMonitorFileActivity
                DefenderPotentiallyUnwantedAppAction                  = $getValue.defenderPotentiallyUnwantedAppAction
                DefenderPotentiallyUnwantedAppActionSetting           = $getValue.defenderPotentiallyUnwantedAppActionSetting
                DefenderProcessesToExclude                            = $getValue.defenderProcessesToExclude
                DefenderPromptForSampleSubmission                     = $getValue.defenderPromptForSampleSubmission
                DefenderRequireBehaviorMonitoring                     = $getValue.defenderRequireBehaviorMonitoring
                DefenderRequireCloudProtection                        = $getValue.defenderRequireCloudProtection
                DefenderRequireNetworkInspectionSystem                = $getValue.defenderRequireNetworkInspectionSystem
                DefenderRequireRealTimeMonitoring                     = $getValue.defenderRequireRealTimeMonitoring
                DefenderScanArchiveFiles                              = $getValue.defenderScanArchiveFiles
                DefenderScanDownloads                                 = $getValue.defenderScanDownloads
                DefenderScanIncomingMail                              = $getValue.defenderScanIncomingMail
                DefenderScanMappedNetworkDrivesDuringFullScan         = $getValue.defenderScanMappedNetworkDrivesDuringFullScan
                DefenderScanMaxCpu                                    = $getValue.defenderScanMaxCpu
                DefenderScanNetworkFiles                              = $getValue.defenderScanNetworkFiles
                DefenderScanRemovableDrivesDuringFullScan             = $getValue.defenderScanRemovableDrivesDuringFullScan
                DefenderScanScriptsLoadedInInternetExplorer           = $getValue.defenderScanScriptsLoadedInInternetExplorer
                DefenderScanType                                      = $getValue.defenderScanType
                DefenderScheduledQuickScanTime                        = $timeDefenderScheduledQuickScanTime
                DefenderScheduledScanTime                             = $timeDefenderScheduledScanTime
                DefenderScheduleScanEnableLowCpuPriority              = $getValue.defenderScheduleScanEnableLowCpuPriority
                DefenderSignatureUpdateIntervalInHours                = $getValue.defenderSignatureUpdateIntervalInHours
                DefenderSubmitSamplesConsentType                      = $getValue.defenderSubmitSamplesConsentType
                DefenderSystemScanSchedule                            = $getValue.defenderSystemScanSchedule
                DeveloperUnlockSetting                                = $getValue.developerUnlockSetting
                DeviceManagementApplicabilityRuleDeviceMode           = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition            = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion            = $complexDeviceManagementApplicabilityRuleOsVersion
                DeviceManagementBlockFactoryResetOnMobile             = $getValue.deviceManagementBlockFactoryResetOnMobile
                DeviceManagementBlockManualUnenroll                   = $getValue.deviceManagementBlockManualUnenroll
                DiagnosticsDataSubmissionMode                         = $getValue.diagnosticsDataSubmissionMode
                DisplayAppListWithGdiDPIScalingTurnedOff              = $getValue.displayAppListWithGdiDPIScalingTurnedOff
                DisplayAppListWithGdiDPIScalingTurnedOn               = $getValue.displayAppListWithGdiDPIScalingTurnedOn
                EdgeAllowStartPagesModification                       = $getValue.edgeAllowStartPagesModification
                EdgeBlockAccessToAboutFlags                           = $getValue.edgeBlockAccessToAboutFlags
                EdgeBlockAddressBarDropdown                           = $getValue.edgeBlockAddressBarDropdown
                EdgeBlockAutofill                                     = $getValue.edgeBlockAutofill
                EdgeBlockCompatibilityList                            = $getValue.edgeBlockCompatibilityList
                EdgeBlockDeveloperTools                               = $getValue.edgeBlockDeveloperTools
                EdgeBlocked                                           = $getValue.edgeBlocked
                EdgeBlockEditFavorites                                = $getValue.edgeBlockEditFavorites
                EdgeBlockExtensions                                   = $getValue.edgeBlockExtensions
                EdgeBlockFullScreenMode                               = $getValue.edgeBlockFullScreenMode
                EdgeBlockInPrivateBrowsing                            = $getValue.edgeBlockInPrivateBrowsing
                EdgeBlockJavaScript                                   = $getValue.edgeBlockJavaScript
                EdgeBlockLiveTileDataCollection                       = $getValue.edgeBlockLiveTileDataCollection
                EdgeBlockPasswordManager                              = $getValue.edgeBlockPasswordManager
                EdgeBlockPopups                                       = $getValue.edgeBlockPopups
                EdgeBlockPrelaunch                                    = $getValue.edgeBlockPrelaunch
                EdgeBlockPrinting                                     = $getValue.edgeBlockPrinting
                EdgeBlockSavingHistory                                = $getValue.edgeBlockSavingHistory
                EdgeBlockSearchEngineCustomization                    = $getValue.edgeBlockSearchEngineCustomization
                EdgeBlockSearchSuggestions                            = $getValue.edgeBlockSearchSuggestions
                EdgeBlockSendingDoNotTrackHeader                      = $getValue.edgeBlockSendingDoNotTrackHeader
                EdgeBlockSendingIntranetTrafficToInternetExplorer     = $getValue.edgeBlockSendingIntranetTrafficToInternetExplorer
                EdgeBlockSideloadingExtensions                        = $getValue.edgeBlockSideloadingExtensions
                EdgeBlockTabPreloading                                = $getValue.edgeBlockTabPreloading
                EdgeBlockWebContentOnNewTabPage                       = $getValue.edgeBlockWebContentOnNewTabPage
                EdgeClearBrowsingDataOnExit                           = $getValue.edgeClearBrowsingDataOnExit
                EdgeCookiePolicy                                      = $getValue.edgeCookiePolicy
                EdgeDisableFirstRunPage                               = $getValue.edgeDisableFirstRunPage
                EdgeEnterpriseModeSiteListLocation                    = $getValue.edgeEnterpriseModeSiteListLocation
                EdgeFavoritesBarVisibility                            = $getValue.edgeFavoritesBarVisibility
                EdgeFavoritesListLocation                             = $getValue.edgeFavoritesListLocation
                EdgeFirstRunUrl                                       = $getValue.edgeFirstRunUrl
                EdgeHomeButtonConfiguration                           = $complexEdgeHomeButtonConfiguration
                EdgeHomeButtonConfigurationEnabled                    = $getValue.edgeHomeButtonConfigurationEnabled
                EdgeHomepageUrls                                      = $getValue.edgeHomepageUrls
                EdgeKioskModeRestriction                              = $getValue.edgeKioskModeRestriction
                EdgeKioskResetAfterIdleTimeInMinutes                  = $getValue.edgeKioskResetAfterIdleTimeInMinutes
                EdgeNewTabPageURL                                     = $getValue.edgeNewTabPageURL
                EdgeOpensWith                                         = $getValue.edgeOpensWith
                EdgePreventCertificateErrorOverride                   = $getValue.edgePreventCertificateErrorOverride
                EdgeRequiredExtensionPackageFamilyNames               = $getValue.edgeRequiredExtensionPackageFamilyNames
                EdgeRequireSmartScreen                                = $getValue.edgeRequireSmartScreen
                EdgeSearchEngine                                      = $complexEdgeSearchEngine
                EdgeSendIntranetTrafficToInternetExplorer             = $getValue.edgeSendIntranetTrafficToInternetExplorer
                EdgeShowMessageWhenOpeningInternetExplorerSites       = $getValue.edgeShowMessageWhenOpeningInternetExplorerSites
                EdgeSyncFavoritesWithInternetExplorer                 = $getValue.edgeSyncFavoritesWithInternetExplorer
                EdgeTelemetryForMicrosoft365Analytics                 = $getValue.edgeTelemetryForMicrosoft365Analytics
                EnableAutomaticRedeployment                           = $getValue.enableAutomaticRedeployment
                EnergySaverOnBatteryThresholdPercentage               = $getValue.energySaverOnBatteryThresholdPercentage
                EnergySaverPluggedInThresholdPercentage               = $getValue.energySaverPluggedInThresholdPercentage
                EnterpriseCloudPrintDiscoveryEndPoint                 = $getValue.enterpriseCloudPrintDiscoveryEndPoint
                EnterpriseCloudPrintDiscoveryMaxLimit                 = $getValue.enterpriseCloudPrintDiscoveryMaxLimit
                EnterpriseCloudPrintMopriaDiscoveryResourceIdentifier = $getValue.enterpriseCloudPrintMopriaDiscoveryResourceIdentifier
                EnterpriseCloudPrintOAuthAuthority                    = $getValue.enterpriseCloudPrintOAuthAuthority
                EnterpriseCloudPrintOAuthClientIdentifier             = $getValue.enterpriseCloudPrintOAuthClientIdentifier
                EnterpriseCloudPrintResourceIdentifier                = $getValue.enterpriseCloudPrintResourceIdentifier
                ExperienceBlockDeviceDiscovery                        = $getValue.experienceBlockDeviceDiscovery
                ExperienceBlockErrorDialogWhenNoSIM                   = $getValue.experienceBlockErrorDialogWhenNoSIM
                ExperienceBlockTaskSwitcher                           = $getValue.experienceBlockTaskSwitcher
                ExperienceDoNotSyncBrowserSettings                    = $getValue.experienceDoNotSyncBrowserSettings
                FindMyFiles                                           = $getValue.findMyFiles
                GameDvrBlocked                                        = $getValue.gameDvrBlocked
                InkWorkspaceAccess                                    = $getValue.inkWorkspaceAccess
                InkWorkspaceAccessState                               = $getValue.inkWorkspaceAccessState
                InkWorkspaceBlockSuggestedApps                        = $getValue.inkWorkspaceBlockSuggestedApps
                InternetSharingBlocked                                = $getValue.internetSharingBlocked
                LocationServicesBlocked                               = $getValue.locationServicesBlocked
                LockScreenActivateAppsWithVoice                       = $getValue.lockScreenActivateAppsWithVoice
                LockScreenAllowTimeoutConfiguration                   = $getValue.lockScreenAllowTimeoutConfiguration
                LockScreenBlockActionCenterNotifications              = $getValue.lockScreenBlockActionCenterNotifications
                LockScreenBlockCortana                                = $getValue.lockScreenBlockCortana
                LockScreenBlockToastNotifications                     = $getValue.lockScreenBlockToastNotifications
                LockScreenTimeoutInSeconds                            = $getValue.lockScreenTimeoutInSeconds
                LogonBlockFastUserSwitching                           = $getValue.logonBlockFastUserSwitching
                MessagingBlockMMS                                     = $getValue.messagingBlockMMS
                MessagingBlockRichCommunicationServices               = $getValue.messagingBlockRichCommunicationServices
                MessagingBlockSync                                    = $getValue.messagingBlockSync
                MicrosoftAccountBlocked                               = $getValue.microsoftAccountBlocked
                MicrosoftAccountBlockSettingsSync                     = $getValue.microsoftAccountBlockSettingsSync
                MicrosoftAccountSignInAssistantSettings               = $getValue.microsoftAccountSignInAssistantSettings
                NetworkProxyApplySettingsDeviceWide                   = $getValue.networkProxyApplySettingsDeviceWide
                NetworkProxyAutomaticConfigurationUrl                 = $getValue.networkProxyAutomaticConfigurationUrl
                NetworkProxyDisableAutoDetect                         = $getValue.networkProxyDisableAutoDetect
                NetworkProxyServer                                    = $complexNetworkProxyServer
                NfcBlocked                                            = $getValue.nfcBlocked
                OneDriveDisableFileSync                               = $getValue.oneDriveDisableFileSync
                PasswordBlockSimple                                   = $getValue.passwordBlockSimple
                PasswordExpirationDays                                = $getValue.passwordExpirationDays
                PasswordMinimumAgeInDays                              = $getValue.passwordMinimumAgeInDays
                PasswordMinimumCharacterSetCount                      = $getValue.passwordMinimumCharacterSetCount
                PasswordMinimumLength                                 = $getValue.passwordMinimumLength
                PasswordMinutesOfInactivityBeforeScreenTimeout        = $getValue.passwordMinutesOfInactivityBeforeScreenTimeout
                PasswordPreviousPasswordBlockCount                    = $getValue.passwordPreviousPasswordBlockCount
                PasswordRequired                                      = $getValue.passwordRequired
                PasswordRequiredType                                  = $getValue.passwordRequiredType
                PasswordRequireWhenResumeFromIdleState                = $getValue.passwordRequireWhenResumeFromIdleState
                PasswordSignInFailureCountBeforeFactoryReset          = $getValue.passwordSignInFailureCountBeforeFactoryReset
                PersonalizationDesktopImageUrl                        = $getValue.personalizationDesktopImageUrl
                PersonalizationLockScreenImageUrl                     = $getValue.personalizationLockScreenImageUrl
                PowerButtonActionOnBattery                            = $getValue.powerButtonActionOnBattery
                PowerButtonActionPluggedIn                            = $getValue.powerButtonActionPluggedIn
                PowerHybridSleepOnBattery                             = $getValue.powerHybridSleepOnBattery
                PowerHybridSleepPluggedIn                             = $getValue.powerHybridSleepPluggedIn
                PowerLidCloseActionOnBattery                          = $getValue.powerLidCloseActionOnBattery
                PowerLidCloseActionPluggedIn                          = $getValue.powerLidCloseActionPluggedIn
                PowerSleepButtonActionOnBattery                       = $getValue.powerSleepButtonActionOnBattery
                PowerSleepButtonActionPluggedIn                       = $getValue.powerSleepButtonActionPluggedIn
                PrinterBlockAddition                                  = $getValue.printerBlockAddition
                PrinterDefaultName                                    = $getValue.printerDefaultName
                PrinterNames                                          = $getValue.printerNames
                PrivacyAdvertisingId                                  = $getValue.privacyAdvertisingId
                PrivacyAutoAcceptPairingAndConsentPrompts             = $getValue.privacyAutoAcceptPairingAndConsentPrompts
                PrivacyBlockActivityFeed                              = $getValue.privacyBlockActivityFeed
                PrivacyBlockInputPersonalization                      = $getValue.privacyBlockInputPersonalization
                PrivacyBlockPublishUserActivities                     = $getValue.privacyBlockPublishUserActivities
                PrivacyDisableLaunchExperience                        = $getValue.privacyDisableLaunchExperience
                ResetProtectionModeBlocked                            = $getValue.resetProtectionModeBlocked
                SafeSearchFilter                                      = $getValue.safeSearchFilter
                ScreenCaptureBlocked                                  = $getValue.screenCaptureBlocked
                SearchBlockDiacritics                                 = $getValue.searchBlockDiacritics
                SearchBlockWebResults                                 = $getValue.searchBlockWebResults
                SearchDisableAutoLanguageDetection                    = $getValue.searchDisableAutoLanguageDetection
                SearchDisableIndexerBackoff                           = $getValue.searchDisableIndexerBackoff
                SearchDisableIndexingEncryptedItems                   = $getValue.searchDisableIndexingEncryptedItems
                SearchDisableIndexingRemovableDrive                   = $getValue.searchDisableIndexingRemovableDrive
                SearchDisableLocation                                 = $getValue.searchDisableLocation
                SearchDisableUseLocation                              = $getValue.searchDisableUseLocation
                SearchEnableAutomaticIndexSizeManangement             = $getValue.searchEnableAutomaticIndexSizeManangement
                SearchEnableRemoteQueries                             = $getValue.searchEnableRemoteQueries
                SecurityBlockAzureADJoinedDevicesAutoEncryption       = $getValue.securityBlockAzureADJoinedDevicesAutoEncryption
                SettingsBlockAccountsPage                             = $getValue.settingsBlockAccountsPage
                SettingsBlockAddProvisioningPackage                   = $getValue.settingsBlockAddProvisioningPackage
                SettingsBlockAppsPage                                 = $getValue.settingsBlockAppsPage
                SettingsBlockChangeLanguage                           = $getValue.settingsBlockChangeLanguage
                SettingsBlockChangePowerSleep                         = $getValue.settingsBlockChangePowerSleep
                SettingsBlockChangeRegion                             = $getValue.settingsBlockChangeRegion
                SettingsBlockChangeSystemTime                         = $getValue.settingsBlockChangeSystemTime
                SettingsBlockDevicesPage                              = $getValue.settingsBlockDevicesPage
                SettingsBlockEaseOfAccessPage                         = $getValue.settingsBlockEaseOfAccessPage
                SettingsBlockEditDeviceName                           = $getValue.settingsBlockEditDeviceName
                SettingsBlockGamingPage                               = $getValue.settingsBlockGamingPage
                SettingsBlockNetworkInternetPage                      = $getValue.settingsBlockNetworkInternetPage
                SettingsBlockPersonalizationPage                      = $getValue.settingsBlockPersonalizationPage
                SettingsBlockPrivacyPage                              = $getValue.settingsBlockPrivacyPage
                SettingsBlockRemoveProvisioningPackage                = $getValue.settingsBlockRemoveProvisioningPackage
                SettingsBlockSettingsApp                              = $getValue.settingsBlockSettingsApp
                SettingsBlockSystemPage                               = $getValue.settingsBlockSystemPage
                SettingsBlockTimeLanguagePage                         = $getValue.settingsBlockTimeLanguagePage
                SettingsBlockUpdateSecurityPage                       = $getValue.settingsBlockUpdateSecurityPage
                SharedUserAppDataAllowed                              = $getValue.sharedUserAppDataAllowed
                SmartScreenAppInstallControl                          = $getValue.smartScreenAppInstallControl
                SmartScreenBlockPromptOverride                        = $getValue.smartScreenBlockPromptOverride
                SmartScreenBlockPromptOverrideForFiles                = $getValue.smartScreenBlockPromptOverrideForFiles
                SmartScreenEnableAppInstallControl                    = $getValue.smartScreenEnableAppInstallControl
                StartBlockUnpinningAppsFromTaskbar                    = $getValue.startBlockUnpinningAppsFromTaskbar
                StartMenuAppListVisibility                            = $getValue.startMenuAppListVisibility
                StartMenuHideChangeAccountSettings                    = $getValue.startMenuHideChangeAccountSettings
                StartMenuHideFrequentlyUsedApps                       = $getValue.startMenuHideFrequentlyUsedApps
                StartMenuHideHibernate                                = $getValue.startMenuHideHibernate
                StartMenuHideLock                                     = $getValue.startMenuHideLock
                StartMenuHidePowerButton                              = $getValue.startMenuHidePowerButton
                StartMenuHideRecentJumpLists                          = $getValue.startMenuHideRecentJumpLists
                StartMenuHideRecentlyAddedApps                        = $getValue.startMenuHideRecentlyAddedApps
                StartMenuHideRestartOptions                           = $getValue.startMenuHideRestartOptions
                StartMenuHideShutDown                                 = $getValue.startMenuHideShutDown
                StartMenuHideSignOut                                  = $getValue.startMenuHideSignOut
                StartMenuHideSleep                                    = $getValue.startMenuHideSleep
                StartMenuHideSwitchAccount                            = $getValue.startMenuHideSwitchAccount
                StartMenuHideUserTile                                 = $getValue.startMenuHideUserTile
                StartMenuLayoutEdgeAssetsXml                          = $getValue.startMenuLayoutEdgeAssetsXml
                StartMenuLayoutXml                                    = $getValue.startMenuLayoutXml
                StartMenuMode                                         = $getValue.startMenuMode
                StartMenuPinnedFolderDocuments                        = $getValue.startMenuPinnedFolderDocuments
                StartMenuPinnedFolderDownloads                        = $getValue.startMenuPinnedFolderDownloads
                StartMenuPinnedFolderFileExplorer                     = $getValue.startMenuPinnedFolderFileExplorer
                StartMenuPinnedFolderHomeGroup                        = $getValue.startMenuPinnedFolderHomeGroup
                StartMenuPinnedFolderMusic                            = $getValue.startMenuPinnedFolderMusic
                StartMenuPinnedFolderNetwork                          = $getValue.startMenuPinnedFolderNetwork
                StartMenuPinnedFolderPersonalFolder                   = $getValue.startMenuPinnedFolderPersonalFolder
                StartMenuPinnedFolderPictures                         = $getValue.startMenuPinnedFolderPictures
                StartMenuPinnedFolderSettings                         = $getValue.startMenuPinnedFolderSettings
                StartMenuPinnedFolderVideos                           = $getValue.startMenuPinnedFolderVideos
                StorageBlockRemovableStorage                          = $getValue.storageBlockRemovableStorage
                StorageRequireMobileDeviceEncryption                  = $getValue.storageRequireMobileDeviceEncryption
                StorageRestrictAppDataToSystemVolume                  = $getValue.storageRestrictAppDataToSystemVolume
                StorageRestrictAppInstallToSystemVolume               = $getValue.storageRestrictAppInstallToSystemVolume
                SystemTelemetryProxyServer                            = $getValue.systemTelemetryProxyServer
                TaskManagerBlockEndTask                               = $getValue.taskManagerBlockEndTask
                TenantLockdownRequireNetworkDuringOutOfBoxExperience  = $getValue.tenantLockdownRequireNetworkDuringOutOfBoxExperience
                UninstallBuiltInApps                                  = $getValue.uninstallBuiltInApps
                UsbBlocked                                            = $getValue.usbBlocked
                VoiceRecordingBlocked                                 = $getValue.voiceRecordingBlocked
                WebRtcBlockLocalhostIpAddress                         = $getValue.webRtcBlockLocalhostIpAddress
                WiFiBlockAutomaticConnectHotspots                     = $getValue.wiFiBlockAutomaticConnectHotspots
                WiFiBlocked                                           = $getValue.wiFiBlocked
                WiFiBlockManualConfiguration                          = $getValue.wiFiBlockManualConfiguration
                WiFiScanInterval                                      = $getValue.wiFiScanInterval
                Windows10AppsForceUpdateSchedule                      = $complexWindows10AppsForceUpdateSchedule
                WindowsSpotlightBlockConsumerSpecificFeatures         = $getValue.windowsSpotlightBlockConsumerSpecificFeatures
                WindowsSpotlightBlocked                               = $getValue.windowsSpotlightBlocked
                WindowsSpotlightBlockOnActionCenter                   = $getValue.windowsSpotlightBlockOnActionCenter
                WindowsSpotlightBlockTailoredExperiences              = $getValue.windowsSpotlightBlockTailoredExperiences
                WindowsSpotlightBlockThirdPartyNotifications          = $getValue.windowsSpotlightBlockThirdPartyNotifications
                WindowsSpotlightBlockWelcomeExperience                = $getValue.windowsSpotlightBlockWelcomeExperience
                WindowsSpotlightBlockWindowsTips                      = $getValue.windowsSpotlightBlockWindowsTips
                WindowsSpotlightConfigureOnLockScreen                 = $getValue.windowsSpotlightConfigureOnLockScreen
                WindowsStoreBlockAutoUpdate                           = $getValue.windowsStoreBlockAutoUpdate
                WindowsStoreBlocked                                   = $getValue.windowsStoreBlocked
                WindowsStoreEnablePrivateStoreOnly                    = $getValue.windowsStoreEnablePrivateStoreOnly
                WirelessDisplayBlockProjectionToThisDevice            = $getValue.wirelessDisplayBlockProjectionToThisDevice
                WirelessDisplayBlockUserInputFromReceiver             = $getValue.wirelessDisplayBlockUserInputFromReceiver
                WirelessDisplayRequirePinForPairing                   = $getValue.wirelessDisplayRequirePinForPairing
                Description                                           = $getValue.Description
                DisplayName                                           = $getValue.DisplayName
                Id                                                    = $getValue.Id
                RoleScopeTagIds                                       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                                = 'Present'
                Credential                                            = $this.Credential
                ApplicationId                                         = $this.ApplicationId
                TenantId                                              = $this.TenantId
                ApplicationSecret                                     = $this.ApplicationSecret
                CertificateThumbprint                                 = $this.CertificateThumbprint
                CertificatePath                                       = $this.CertificatePath
                CertificatePassword                                   = $this.CertificatePassword
                ManagedIdentity                                       = $this.ManagedIdentity
                AccessTokens                                          = $this.AccessTokens
                #endregion
            }

            $rawAssignments = @()
            $rawAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $rawAssignments)
            {
                $rawAssignments = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId -All
            }
            $assignmentResult = @()
            if ($null -ne $rawAssignments -and $rawAssignments.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $rawAssignments
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

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windows10GeneralConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            #endregion
            #region new Intune assignment management
            if ($policy.id)
            {
                $intuneAssignments = @()
                if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
                {
                    $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
                }
                foreach ($assignment in $intuneAssignments)
                {
                    New-MgBetaDeviceManagementDeviceConfigurationAssignment `
                        -DeviceConfigurationId $policy.id `
                        -BodyParameter $assignment
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Configuration Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10GeneralConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
            #region new Intune assignment management
            $currentAssignments = @()
            $currentAssignments += Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $currentInstance.id

            $intuneAssignments = @()
            if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
            {
                $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
            }
            foreach ($assignment in $intuneAssignments)
            {
                if ( $null -eq ($currentAssignments | Where-Object { $_.Target.groupId -eq $assignment.Target.groupId -and $_.Target.'@odata.type' -eq $assignment.Target.'@odata.type' }))
                {
                    New-MgBetaDeviceManagementDeviceConfigurationAssignment `
                        -DeviceConfigurationId $currentInstance.id `
                        -BodyParameter $assignment
                }
                else
                {
                    $currentAssignments = $currentAssignments | Where-Object { -not ($_.Target.groupId -eq $assignment.Target.groupId -and $_.Target.'@odata.type' -eq $assignment.Target.'@odata.type') }
                }
            }
            if ($currentAssignments.Count -gt 0)
            {
                foreach ($assignment in $currentAssignments)
                {
                    Remove-MgBetaDeviceManagementDeviceConfigurationAssignment `
                        -DeviceConfigurationId $currentInstance.Id `
                        -DeviceConfigurationAssignmentId $assignment.Id
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Policy for Windows10 with Id {$($currentInstance.Id)}"
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
                -ODataType 'microsoft.graph.windows10GeneralConfiguration' `
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

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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

                if ($null -ne $Results.DefenderDetectedMalwareActions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DefenderDetectedMalwareActions `
                        -CIMInstanceName 'MicrosoftGraphdefenderDetectedMalwareActions'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DefenderDetectedMalwareActions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DefenderDetectedMalwareActions') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleDeviceMode'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsEdition'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsVersion'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
                    }
                }
                if ($null -ne $Results.EdgeHomeButtonConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EdgeHomeButtonConfiguration `
                        -CIMInstanceName 'MicrosoftGraphedgeHomeButtonConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EdgeHomeButtonConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EdgeHomeButtonConfiguration') | Out-Null
                    }
                }
                if ($null -ne $Results.EdgeSearchEngine)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EdgeSearchEngine `
                        -CIMInstanceName 'MicrosoftGraphedgeSearchEngineBase'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EdgeSearchEngine = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EdgeSearchEngine') | Out-Null
                    }
                }
                if ($null -ne $Results.NetworkProxyServer)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NetworkProxyServer `
                        -CIMInstanceName 'MicrosoftGraphwindows10NetworkProxyServer'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NetworkProxyServer = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NetworkProxyServer') | Out-Null
                    }
                }
                if ($null -ne $Results.Windows10AppsForceUpdateSchedule)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Windows10AppsForceUpdateSchedule `
                        -CIMInstanceName 'MicrosoftGraphwindows10AppsForceUpdateSchedule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Windows10AppsForceUpdateSchedule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Windows10AppsForceUpdateSchedule') | Out-Null
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
                    -NoEscape @('DefenderDetectedMalwareActions', 'DeviceManagementApplicabilityRuleDeviceMode',
                    'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion',
                    'EdgeHomeButtonConfiguration', 'EdgeSearchEngine', 'NetworkProxyServer',
                    'Windows10AppsForceUpdateSchedule', 'Assignments') `
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

    hidden [IntuneDeviceConfigurationPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphdefenderDetectedMalwareActions
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates a Defender action to take for high severity Malware threat detected. Possible values are: deviceDefault, clean, quarantine, remove, allow, userDefined, block.')]
    [ValidateSet('deviceDefault', 'clean', 'quarantine', 'remove', 'allow', 'userDefined', 'block')]
    [System.String] $HighSeverity

    [DscProperty()]
    [System.ComponentModel.Description('Indicates a Defender action to take for low severity Malware threat detected. Possible values are: deviceDefault, clean, quarantine, remove, allow, userDefined, block.')]
    [ValidateSet('deviceDefault', 'clean', 'quarantine', 'remove', 'allow', 'userDefined', 'block')]
    [System.String] $LowSeverity

    [DscProperty()]
    [System.ComponentModel.Description('Indicates a Defender action to take for moderate severity Malware threat detected. Possible values are: deviceDefault, clean, quarantine, remove, allow, userDefined, block.')]
    [ValidateSet('deviceDefault', 'clean', 'quarantine', 'remove', 'allow', 'userDefined', 'block')]
    [System.String] $ModerateSeverity

    [DscProperty()]
    [System.ComponentModel.Description('Indicates a Defender action to take for severe severity Malware threat detected. Possible values are: deviceDefault, clean, quarantine, remove, allow, userDefined, block.')]
    [ValidateSet('deviceDefault', 'clean', 'quarantine', 'remove', 'allow', 'userDefined', 'block')]
    [System.String] $SevereSeverity
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule for device mode')]
    [ValidateSet('standardConfiguration', 'sModeConfiguration')]
    [System.String] $DeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsEdition
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule OS edition type')]
    [System.String[]] $OsEditionTypes

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsVersion
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version for Applicability Rule')]
    [System.String] $MinOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version for Applicability Rule')]
    [System.String] $MaxOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_MicrosoftGraphedgeHomeButtonConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The specific URL to load.')]
    [System.String] $HomeButtonCustomURL

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.edgeHomeButtonHidden', '#microsoft.graph.edgeHomeButtonLoadsStartPage', '#microsoft.graph.edgeHomeButtonOpensCustomURL', '#microsoft.graph.edgeHomeButtonOpensNewTab')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphedgeSearchEngineBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Allows IT admins to set a predefined default search engine for MDM-Controlled devices. Possible values are: default, bing.')]
    [ValidateSet('default', 'bing')]
    [System.String] $EdgeSearchEngineType

    [DscProperty()]
    [System.ComponentModel.Description('Points to a https link containing the OpenSearch xml file that contains, at minimum, the short name and the URL to the search Engine.')]
    [System.String] $EdgeSearchEngineOpenSearchXmlUrl

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.edgeSearchEngine', '#microsoft.graph.edgeSearchEngineCustom')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphwindows10NetworkProxyServer
{
    [DscProperty()]
    [System.ComponentModel.Description('Address to the proxy server. Specify an address in the format '':''')]
    [System.String] $Address

    [DscProperty()]
    [System.ComponentModel.Description('Addresses that should not use the proxy server. The system will not use the proxy server for addresses beginning with what is specified in this node.')]
    [System.String[]] $Exceptions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the proxy server should be used for local (intranet) addresses.')]
    [System.Nullable[System.Boolean]] $UseForLocalAddresses
}

class MSFT_MicrosoftGraphwindows10AppsForceUpdateSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('Recurrence schedule. Possible values are: none, daily, weekly, monthly.')]
    [ValidateSet('none', 'daily', 'weekly', 'monthly')]
    [System.String] $Recurrence

    [DscProperty()]
    [System.ComponentModel.Description('If true, runs the task immediately if StartDateTime is in the past, else, runs at the next recurrence.')]
    [System.Nullable[System.Boolean]] $RunImmediatelyIfAfterStartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The start time for the force restart.')]
    [System.String] $StartDateTime
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
