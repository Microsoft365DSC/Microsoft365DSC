using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets whether applications inside Microsoft Defender Application Guard can access the devices camera and microphone.')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowCameraMicrophoneRedirection

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to download files from Edge in the application guard container and save them on the host file system')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowFileSaveOnHost

    [DscProperty()]
    [System.ComponentModel.Description('Allow persisting user generated data inside the App Guard Container (favorites, cookies, web passwords, etc.)')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowPersistence

    [DscProperty()]
    [System.ComponentModel.Description('Allow printing to Local Printers from Container')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowPrintToLocalPrinters

    [DscProperty()]
    [System.ComponentModel.Description('Allow printing to Network Printers from Container')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowPrintToNetworkPrinters

    [DscProperty()]
    [System.ComponentModel.Description('Allow printing to PDF from Container')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowPrintToPDF

    [DscProperty()]
    [System.ComponentModel.Description('Allow printing to XPS from Container')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowPrintToXPS

    [DscProperty()]
    [System.ComponentModel.Description('Allow application guard to use virtual GPU')]
    [System.Nullable[System.Boolean]] $ApplicationGuardAllowVirtualGPU

    [DscProperty()]
    [System.ComponentModel.Description('Block clipboard to share data from Host to Container, or from Container to Host, or both ways, or neither ways. Possible values are: notConfigured, blockBoth, blockHostToContainer, blockContainerToHost, blockNone.')]
    [ValidateSet('notConfigured', 'blockBoth', 'blockHostToContainer', 'blockContainerToHost', 'blockNone')]
    [System.String] $ApplicationGuardBlockClipboardSharing

    [DscProperty()]
    [System.ComponentModel.Description('Block clipboard to transfer image file, text file or neither of them. Possible values are: notConfigured, blockImageAndTextFile, blockImageFile, blockNone, blockTextFile.')]
    [ValidateSet('notConfigured', 'blockImageAndTextFile', 'blockImageFile', 'blockNone', 'blockTextFile')]
    [System.String] $ApplicationGuardBlockFileTransfer

    [DscProperty()]
    [System.ComponentModel.Description('Block enterprise sites to load non-enterprise content, such as third party plug-ins')]
    [System.Nullable[System.Boolean]] $ApplicationGuardBlockNonEnterpriseContent

    [DscProperty()]
    [System.ComponentModel.Description('Allows certain device level Root Certificates to be shared with the Microsoft Defender Application Guard container.')]
    [System.String[]] $ApplicationGuardCertificateThumbprints

    [DscProperty()]
    [System.ComponentModel.Description('Enable Windows Defender Application Guard')]
    [System.Nullable[System.Boolean]] $ApplicationGuardEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable Windows Defender Application Guard for newer Windows builds. Possible values are: notConfigured, enabledForEdge, enabledForOffice, enabledForEdgeAndOffice.')]
    [ValidateSet('notConfigured', 'enabledForEdge', 'enabledForOffice', 'enabledForEdgeAndOffice')]
    [System.String] $ApplicationGuardEnabledOptions

    [DscProperty()]
    [System.ComponentModel.Description('Force auditing will persist Windows logs and events to meet security/compliance criteria (sample events are user login-logoff, use of privilege rights, software installation, system changes, etc.)')]
    [System.Nullable[System.Boolean]] $ApplicationGuardForceAuditing

    [DscProperty()]
    [System.ComponentModel.Description('Enables the Admin to choose what types of app to allow on devices. Possible values are: notConfigured, enforceComponentsAndStoreApps, auditComponentsAndStoreApps, enforceComponentsStoreAppsAndSmartlocker, auditComponentsStoreAppsAndSmartlocker.')]
    [ValidateSet('notConfigured', 'enforceComponentsAndStoreApps', 'auditComponentsAndStoreApps', 'enforceComponentsStoreAppsAndSmartlocker', 'auditComponentsStoreAppsAndSmartlocker')]
    [System.String] $AppLockerApplicationControl

    [DscProperty()]
    [System.ComponentModel.Description('Allows the admin to allow standard users to enable encryption during Azure AD Join.')]
    [System.Nullable[System.Boolean]] $BitLockerAllowStandardUserEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allows the Admin to disable the warning prompt for other disk encryption on the user machines.')]
    [System.Nullable[System.Boolean]] $BitLockerDisableWarningForOtherDiskEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allows the admin to require encryption to be turned on using BitLocker. This policy is valid only for a mobile SKU.')]
    [System.Nullable[System.Boolean]] $BitLockerEnableStorageCardEncryptionOnMobile

    [DscProperty()]
    [System.ComponentModel.Description('Allows the admin to require encryption to be turned on using BitLocker.')]
    [System.Nullable[System.Boolean]] $BitLockerEncryptDevice

    [DscProperty()]
    [System.ComponentModel.Description('BitLocker Fixed Drive Policy.')]
    [MSFT_MicrosoftGraphbitLockerFixedDrivePolicy] $BitLockerFixedDrivePolicy

    [DscProperty()]
    [System.ComponentModel.Description('This setting initiates a client-driven recovery password rotation after an OS drive recovery (either by using bootmgr or WinRE). Possible values are: notConfigured, disabled, enabledForAzureAd, enabledForAzureAdAndHybrid.')]
    [ValidateSet('notConfigured', 'disabled', 'enabledForAzureAd', 'enabledForAzureAdAndHybrid')]
    [System.String] $BitLockerRecoveryPasswordRotation

    [DscProperty()]
    [System.ComponentModel.Description('BitLocker Removable Drive Policy.')]
    [MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy] $BitLockerRemovableDrivePolicy

    [DscProperty()]
    [System.ComponentModel.Description('BitLocker System Drive Policy.')]
    [MSFT_MicrosoftGraphbitLockerSystemDrivePolicy] $BitLockerSystemDrivePolicy

    [DscProperty()]
    [System.ComponentModel.Description('List of folder paths to be added to the list of protected folders')]
    [System.String[]] $DefenderAdditionalGuardedFolders

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Adobe Reader from creating child processes. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderAdobeReaderLaunchChildProcess

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating use of advanced protection against ransomeware. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderAdvancedRansomewareProtectionType

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Behavior Monitoring functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('To best protect your PC, Windows Defender will send information to Microsoft about any problems it finds. Microsoft will analyze that information, learn more about problems affecting you and other customers, and offer improved solutions.')]
    [System.Nullable[System.Boolean]] $DefenderAllowCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows user access to the Windows Defender UI. If disallowed, all Windows Defender notifications will also be suppressed.')]
    [System.Nullable[System.Boolean]] $DefenderAllowEndUserAccess

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Intrusion Prevention functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowIntrusionPreventionSystem

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender On Access Protection functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Realtime Monitoring functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowRealTimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows scanning of archives.')]
    [System.Nullable[System.Boolean]] $DefenderAllowScanArchiveFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender IOAVP Protection functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowScanDownloads

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a scanning of network files.')]
    [System.Nullable[System.Boolean]] $DefenderAllowScanNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a full scan of removable drives. During a quick scan, removable drives may still be scanned.')]
    [System.Nullable[System.Boolean]] $DefenderAllowScanRemovableDrivesDuringFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Script Scanning functionality.')]
    [System.Nullable[System.Boolean]] $DefenderAllowScanScriptsLoadedInInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('List of exe files and folders to be excluded from attack surface reduction rules')]
    [System.String[]] $DefenderAttackSurfaceReductionExcludedPaths

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows user access to the Windows Defender UI. If disallowed, all Windows Defender notifications will also be suppressed.')]
    [System.Nullable[System.Boolean]] $DefenderBlockEndUserAccess

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior ofBlock persistence through WMI event subscription. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderBlockPersistenceThroughWmiType

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to manage whether a check for new virus and spyware definitions will occur before running a scan.')]
    [System.Nullable[System.Boolean]] $DefenderCheckForSignaturesBeforeRunningScan

    [DscProperty()]
    [System.ComponentModel.Description('Added in Windows 10, version 1709. This policy setting determines how aggressive Windows Defender Antivirus will be in blocking and scanning suspicious files. Value type is integer. This feature requires the ''Join Microsoft MAPS'' setting enabled in order to function. Possible values are: notConfigured, high, highPlus, zeroTolerance.')]
    [ValidateSet('notConfigured', 'high', 'highPlus', 'zeroTolerance')]
    [System.String] $DefenderCloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('Added in Windows 10, version 1709. This feature allows Windows Defender Antivirus to block a suspicious file for up to 60 seconds, and scan it in the cloud to make sure it''s safe. Value type is integer, range is 0 - 50. This feature depends on three other MAPS settings the must all be enabled- ''Configure the ''Block at First Sight'' feature ''Join Microsoft MAPS'' ''Send file samples when further analysis is required''. Valid values 0 to 50')]
    [System.Nullable[System.UInt32]] $DefenderCloudExtendedTimeoutInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Time period (in days) that quarantine items will be stored on the system. Valid values 0 to 90')]
    [System.Nullable[System.UInt32]] $DefenderDaysBeforeDeletingQuarantinedMalware

    [DscProperty()]
    [System.ComponentModel.Description('Allows an administrator to specify any valid threat severity levels and the corresponding default action ID to take.')]
    [MSFT_MicrosoftGraphdefenderDetectedMalwareActions] $DefenderDetectedMalwareActions

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Behavior Monitoring functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to configure catch-up scans for scheduled full scans. A catch-up scan is a scan that is initiated because a regularly scheduled scan was missed. Usually these scheduled scans are missed because the computer was turned off at the scheduled time.')]
    [System.Nullable[System.Boolean]] $DefenderDisableCatchupFullScan

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to configure catch-up scans for scheduled quick scans. A catch-up scan is a scan that is initiated because a regularly scheduled scan was missed. Usually these scheduled scans are missed because the computer was turned off at the scheduled time.')]
    [System.Nullable[System.Boolean]] $DefenderDisableCatchupQuickScan

    [DscProperty()]
    [System.ComponentModel.Description('To best protect your PC, Windows Defender will send information to Microsoft about any problems it finds. Microsoft will analyze that information, learn more about problems affecting you and other customers, and offer improved solutions.')]
    [System.Nullable[System.Boolean]] $DefenderDisableCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Intrusion Prevention functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableIntrusionPreventionSystem

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender On Access Protection functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Realtime Monitoring functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableRealTimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows scanning of archives.')]
    [System.Nullable[System.Boolean]] $DefenderDisableScanArchiveFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender IOAVP Protection functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableScanDownloads

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a scanning of network files.')]
    [System.Nullable[System.Boolean]] $DefenderDisableScanNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a full scan of removable drives. During a quick scan, removable drives may still be scanned.')]
    [System.Nullable[System.Boolean]] $DefenderDisableScanRemovableDrivesDuringFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows Windows Defender Script Scanning functionality.')]
    [System.Nullable[System.Boolean]] $DefenderDisableScanScriptsLoadedInInternetExplorer

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating if execution of executable content (exe, dll, ps, js, vbs, etc) should be dropped from email (webmail/mail-client). Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderEmailContentExecution

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating if execution of executable content (exe, dll, ps, js, vbs, etc) should be dropped from email (webmail/mail-client). Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderEmailContentExecutionType

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to enable or disable low CPU priority for scheduled scans.')]
    [System.Nullable[System.Boolean]] $DefenderEnableLowCpuPriority

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows scanning of email.')]
    [System.Nullable[System.Boolean]] $DefenderEnableScanIncomingMail

    [DscProperty()]
    [System.ComponentModel.Description('Allows or disallows a full scan of mapped network drives.')]
    [System.Nullable[System.Boolean]] $DefenderEnableScanMappedNetworkDrivesDuringFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Xml content containing information regarding exploit protection details.')]
    [System.String] $DefenderExploitProtectionXml

    [DscProperty()]
    [System.ComponentModel.Description('Name of the file from which DefenderExploitProtectionXml was obtained.')]
    [System.String] $DefenderExploitProtectionXmlFileName

    [DscProperty()]
    [System.ComponentModel.Description('File extensions to exclude from scans and real time protection.')]
    [System.String[]] $DefenderFileExtensionsToExclude

    [DscProperty()]
    [System.ComponentModel.Description('Files and folder to exclude from scans and real time protection.')]
    [System.String[]] $DefenderFilesAndFoldersToExclude

    [DscProperty()]
    [System.ComponentModel.Description('List of paths to exe that are allowed to access protected folders')]
    [System.String[]] $DefenderGuardedFoldersAllowedAppPaths

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of protected folders. Possible values are: userDefined, enable, auditMode, blockDiskModification, auditDiskModification.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'blockDiskModification', 'auditDiskModification')]
    [System.String] $DefenderGuardMyFoldersType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of NetworkProtection. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderNetworkProtectionType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office applications/macros creating or launching executable content. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderOfficeAppsExecutableContentCreationOrLaunch

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office applications/macros creating or launching executable content. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderOfficeAppsExecutableContentCreationOrLaunchType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office application launching child processes. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderOfficeAppsLaunchChildProcess

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office application launching child processes. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderOfficeAppsLaunchChildProcessType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office applications injecting into other processes. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderOfficeAppsOtherProcessInjection

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior ofOffice applications injecting into other processes. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderOfficeAppsOtherProcessInjectionType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Office communication applications, including Microsoft Outlook, from creating child processes. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderOfficeCommunicationAppsLaunchChildProcess

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Win32 imports from Macro code in Office. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderOfficeMacroCodeAllowWin32Imports

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of Win32 imports from Macro code in Office. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderOfficeMacroCodeAllowWin32ImportsType

    [DscProperty()]
    [System.ComponentModel.Description('Added in Windows 10, version 1607. Specifies the level of detection for potentially unwanted applications (PUAs). Windows Defender alerts you when potentially unwanted software is being downloaded or attempts to install itself on your computer. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderPotentiallyUnwantedAppAction

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating if credential stealing from the Windows local security authority subsystem is permitted. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderPreventCredentialStealingType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to process creations originating from PSExec and WMI commands. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderProcessCreation

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to process creations originating from PSExec and WMI commands. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderProcessCreationType

    [DscProperty()]
    [System.ComponentModel.Description('Processes to exclude from scans and real time protection.')]
    [System.String[]] $DefenderProcessesToExclude

    [DscProperty()]
    [System.ComponentModel.Description('Controls which sets of files should be monitored. Possible values are: monitorAllFiles, monitorIncomingFilesOnly, monitorOutgoingFilesOnly.')]
    [ValidateSet('monitorAllFiles', 'monitorIncomingFilesOnly', 'monitorOutgoingFilesOnly')]
    [System.String] $DefenderScanDirection

    [DscProperty()]
    [System.ComponentModel.Description('Represents the average CPU load factor for the Windows Defender scan (in percent). The default value is 50. Valid values 0 to 100')]
    [System.Nullable[System.UInt32]] $DefenderScanMaxCpuPercentage

    [DscProperty()]
    [System.ComponentModel.Description('Selects whether to perform a quick scan or full scan. Possible values are: userDefined, disabled, quick, full.')]
    [ValidateSet('userDefined', 'disabled', 'quick', 'full')]
    [System.String] $DefenderScanType

    [DscProperty()]
    [System.ComponentModel.Description('Selects the time of day that the Windows Defender quick scan should run. For example, a value of 0=12:00AM, a value of 60=1:00AM, a value of 120=2:00, and so on, up to a value of 1380=11:00PM. The default value is 120')]
    [System.String] $DefenderScheduledQuickScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Selects the day that the Windows Defender scan should run. Possible values are: userDefined, everyday, sunday, monday, tuesday, wednesday, thursday, friday, saturday, noScheduledScan.')]
    [ValidateSet('userDefined', 'everyday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'noScheduledScan')]
    [System.String] $DefenderScheduledScanDay

    [DscProperty()]
    [System.ComponentModel.Description('Selects the time of day that the Windows Defender scan should run.')]
    [System.String] $DefenderScheduledScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of js/vbs executing payload downloaded from Internet. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderScriptDownloadedPayloadExecution

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of js/vbs executing payload downloaded from Internet. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderScriptDownloadedPayloadExecutionType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of obfuscated js/vbs/ps/macro code. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderScriptObfuscatedMacroCode

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating the behavior of obfuscated js/vbs/ps/macro code. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderScriptObfuscatedMacroCodeType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block user from overriding Exploit Protection settings.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterBlockExploitProtectionOverride

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the account protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableAccountUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the app and browser protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableAppBrowserUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the Clear TPM button.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableClearTpmUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the family options area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableFamilyUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the hardware protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableHardwareUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the device performance and health area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableHealthUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the firewall and network protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableNetworkUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the notification area control. The user needs to either sign out and sign in or reboot the computer for this setting to take effect.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableNotificationAreaUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the ransomware protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableRansomwareUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the secure boot area under Device security.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableSecureBootUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the security process troubleshooting under Device security.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableTroubleshootingUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of the virus and threat protection area.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableVirusUI

    [DscProperty()]
    [System.ComponentModel.Description('Used to disable the display of update TPM Firmware when a vulnerable firmware is detected.')]
    [System.Nullable[System.Boolean]] $DefenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI

    [DscProperty()]
    [System.ComponentModel.Description('The email address that is displayed to users.')]
    [System.String] $DefenderSecurityCenterHelpEmail

    [DscProperty()]
    [System.ComponentModel.Description('The phone number or Skype ID that is displayed to users.')]
    [System.String] $DefenderSecurityCenterHelpPhone

    [DscProperty()]
    [System.ComponentModel.Description('The help portal URL this is displayed to users.')]
    [System.String] $DefenderSecurityCenterHelpURL

    [DscProperty()]
    [System.ComponentModel.Description('Configure where to display IT contact information to end users. Possible values are: notConfigured, displayInAppAndInNotifications, displayOnlyInApp, displayOnlyInNotifications.')]
    [ValidateSet('notConfigured', 'displayInAppAndInNotifications', 'displayOnlyInApp', 'displayOnlyInNotifications')]
    [System.String] $DefenderSecurityCenterITContactDisplay

    [DscProperty()]
    [System.ComponentModel.Description('Notifications to show from the displayed areas of app. Possible values are: notConfigured, blockNoncriticalNotifications, blockAllNotifications.')]
    [ValidateSet('notConfigured', 'blockNoncriticalNotifications', 'blockAllNotifications')]
    [System.String] $DefenderSecurityCenterNotificationsFromApp

    [DscProperty()]
    [System.ComponentModel.Description('The company name that is displayed to the users.')]
    [System.String] $DefenderSecurityCenterOrganizationDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the interval (in hours) that will be used to check for signatures, so instead of using the ScheduleDay and ScheduleTime the check for new signatures will be set according to the interval. Valid values 0 to 24')]
    [System.Nullable[System.UInt32]] $DefenderSignatureUpdateIntervalInHours

    [DscProperty()]
    [System.ComponentModel.Description('Checks for the user consent level in Windows Defender to send data. Possible values are: sendSafeSamplesAutomatically, alwaysPrompt, neverSend, sendAllSamplesAutomatically.')]
    [ValidateSet('sendSafeSamplesAutomatically', 'alwaysPrompt', 'neverSend', 'sendAllSamplesAutomatically')]
    [System.String] $DefenderSubmitSamplesConsentType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to executables that don''t meet a prevalence, age, or trusted list criteria. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderUntrustedExecutable

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to executables that don''t meet a prevalence, age, or trusted list criteria. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderUntrustedExecutableType

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to untrusted and unsigned processes that run from USB. Possible values are: userDefined, enable, auditMode, warn, notConfigured.')]
    [ValidateSet('userDefined', 'enable', 'auditMode', 'warn', 'notConfigured')]
    [System.String] $DefenderUntrustedUSBProcess

    [DscProperty()]
    [System.ComponentModel.Description('Value indicating response to untrusted and unsigned processes that run from USB. Possible values are: userDefined, block, auditMode, warn, disable.')]
    [ValidateSet('userDefined', 'block', 'auditMode', 'warn', 'disable')]
    [System.String] $DefenderUntrustedUSBProcessType

    [DscProperty()]
    [System.ComponentModel.Description('This property will be deprecated in May 2019 and will be replaced with property DeviceGuardSecureBootWithDMA. Specifies whether Platform Security Level is enabled at next reboot.')]
    [System.Nullable[System.Boolean]] $DeviceGuardEnableSecureBootWithDMA

    [DscProperty()]
    [System.ComponentModel.Description('Turns On Virtualization Based Security(VBS).')]
    [System.Nullable[System.Boolean]] $DeviceGuardEnableVirtualizationBasedSecurity

    [DscProperty()]
    [System.ComponentModel.Description('Allows the IT admin to configure the launch of System Guard. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $DeviceGuardLaunchSystemGuard

    [DscProperty()]
    [System.ComponentModel.Description('Turn on Credential Guard when Platform Security Level with Secure Boot and Virtualization Based Security are both enabled. Possible values are: notConfigured, enableWithUEFILock, enableWithoutUEFILock, disable.')]
    [ValidateSet('notConfigured', 'enableWithUEFILock', 'enableWithoutUEFILock', 'disable')]
    [System.String] $DeviceGuardLocalSystemAuthorityCredentialGuardSettings

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether Platform Security Level is enabled at next reboot. Possible values are: notConfigured, withoutDMA, withDMA.')]
    [ValidateSet('notConfigured', 'withoutDMA', 'withDMA')]
    [System.String] $DeviceGuardSecureBootWithDMA

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
    [System.ComponentModel.Description('This policy is intended to provide additional security against external DMA capable devices. It allows for more control over the enumeration of external DMA capable devices incompatible with DMA Remapping/device memory isolation and sandboxing. This policy only takes effect when Kernel DMA Protection is supported and enabled by the system firmware. Kernel DMA Protection is a platform feature that cannot be controlled via policy or by end user. It has to be supported by the system at the time of manufacturing. To check if the system supports Kernel DMA Protection, please check the Kernel DMA Protection field in the Summary page of MSINFO32.exe. Possible values are: deviceDefault, blockAll, allowAll.')]
    [ValidateSet('deviceDefault', 'blockAll', 'allowAll')]
    [System.String] $DmaGuardDeviceEnumerationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Blocks stateful FTP connections to the device')]
    [System.Nullable[System.Boolean]] $FirewallBlockStatefulFTP

    [DscProperty()]
    [System.ComponentModel.Description('Specify how the certificate revocation list is to be enforced. Possible values are: deviceDefault, none, attempt, require.')]
    [ValidateSet('deviceDefault', 'none', 'attempt', 'require')]
    [System.String] $FirewallCertificateRevocationListCheckMethod

    [DscProperty()]
    [System.ComponentModel.Description('Configures the idle timeout for security associations, in seconds, from 300 to 3600 inclusive. This is the period after which security associations will expire and be deleted. Valid values 300 to 3600')]
    [System.Nullable[System.UInt32]] $FirewallIdleTimeoutForSecurityAssociationInSeconds

    [DscProperty()]
    [System.ComponentModel.Description('Configures IPSec exemptions to allow both IPv4 and IPv6 DHCP traffic')]
    [System.Nullable[System.Boolean]] $FirewallIPSecExemptionsAllowDHCP

    [DscProperty()]
    [System.ComponentModel.Description('Configures IPSec exemptions to allow ICMP')]
    [System.Nullable[System.Boolean]] $FirewallIPSecExemptionsAllowICMP

    [DscProperty()]
    [System.ComponentModel.Description('Configures IPSec exemptions to allow neighbor discovery IPv6 ICMP type-codes')]
    [System.Nullable[System.Boolean]] $FirewallIPSecExemptionsAllowNeighborDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Configures IPSec exemptions to allow router discovery IPv6 ICMP type-codes')]
    [System.Nullable[System.Boolean]] $FirewallIPSecExemptionsAllowRouterDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Configures IPSec exemptions to no exemptions')]
    [System.Nullable[System.Boolean]] $FirewallIPSecExemptionsNone

    [DscProperty()]
    [System.ComponentModel.Description('If an authentication set is not fully supported by a keying module, direct the module to ignore only unsupported authentication suites rather than the entire set')]
    [System.Nullable[System.Boolean]] $FirewallMergeKeyingModuleSettings

    [DscProperty()]
    [System.ComponentModel.Description('Configures how packet queueing should be applied in the tunnel gateway scenario. Possible values are: deviceDefault, disabled, queueInbound, queueOutbound, queueBoth.')]
    [ValidateSet('deviceDefault', 'disabled', 'queueInbound', 'queueOutbound', 'queueBoth')]
    [System.String] $FirewallPacketQueueingMethod

    [DscProperty()]
    [System.ComponentModel.Description('Select the preshared key encoding to be used. Possible values are: deviceDefault, none, utF8.')]
    [ValidateSet('deviceDefault', 'none', 'utF8')]
    [System.String] $FirewallPreSharedKeyEncodingMethod

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall profile settings for domain networks')]
    [MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] $FirewallProfileDomain

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall profile settings for private networks')]
    [MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] $FirewallProfilePrivate

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall profile settings for public networks')]
    [MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] $FirewallProfilePublic

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall rule settings. This collection can contain a maximum of 150 elements.')]
    [MSFT_MicrosoftGraphwindowsFirewallRule[]] $FirewallRules

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines which challenge/response authentication protocol is used for network logons. Possible values are: lmAndNltm, lmNtlmAndNtlmV2, lmAndNtlmOnly, lmAndNtlmV2, lmNtlmV2AndNotLm, lmNtlmV2AndNotLmOrNtm.')]
    [ValidateSet('lmAndNltm', 'lmNtlmAndNtlmV2', 'lmAndNtlmOnly', 'lmAndNtlmV2', 'lmNtlmV2AndNotLm', 'lmNtlmV2AndNotLmOrNtm')]
    [System.String] $LanManagerAuthenticationLevel

    [DscProperty()]
    [System.ComponentModel.Description('If enabled,the SMB client will allow insecure guest logons. If not configured, the SMB client will reject insecure guest logons.')]
    [System.Nullable[System.Boolean]] $LanManagerWorkstationDisableInsecureGuestLogons

    [DscProperty()]
    [System.ComponentModel.Description('Define a different account name to be associated with the security identifier (SID) for the account ''Administrator''.')]
    [System.String] $LocalSecurityOptionsAdministratorAccountName

    [DscProperty()]
    [System.ComponentModel.Description('Define the behavior of the elevation prompt for admins in Admin Approval Mode. Possible values are: notConfigured, elevateWithoutPrompting, promptForCredentialsOnTheSecureDesktop, promptForConsentOnTheSecureDesktop, promptForCredentials, promptForConsent, promptForConsentForNonWindowsBinaries.')]
    [ValidateSet('notConfigured', 'elevateWithoutPrompting', 'promptForCredentialsOnTheSecureDesktop', 'promptForConsentOnTheSecureDesktop', 'promptForCredentials', 'promptForConsent', 'promptForConsentForNonWindowsBinaries')]
    [System.String] $LocalSecurityOptionsAdministratorElevationPromptBehavior

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether to allows anonymous users to perform certain activities, such as enumerating the names of domain accounts and network shares.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares

    [DscProperty()]
    [System.ComponentModel.Description('Block PKU2U authentication requests to this device to use online identities.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowPKU2UAuthenticationRequests

    [DscProperty()]
    [System.ComponentModel.Description('Edit the default Security Descriptor Definition Language string to allow or deny users and groups to make remote calls to the SAM.')]
    [System.String] $LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManager

    [DscProperty()]
    [System.ComponentModel.Description('UI helper boolean for LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManager entity')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether a computer can be shut down without having to log on to Windows.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn

    [DscProperty()]
    [System.ComponentModel.Description('Allow UIAccess apps to prompt for elevation without using the secure desktop.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowUIAccessApplicationElevation

    [DscProperty()]
    [System.ComponentModel.Description('Allow UIAccess apps to prompt for elevation without using the secure desktop.Default is enabled')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowUIAccessApplicationsForSecureLocations

    [DscProperty()]
    [System.ComponentModel.Description('Prevent a portable computer from being undocked without having to log in.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsAllowUndockWithoutHavingToLogon

    [DscProperty()]
    [System.ComponentModel.Description('Prevent users from adding new Microsoft accounts to this computer.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsBlockMicrosoftAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Enable Local accounts that are not password protected to log on from locations other than the physical device.Default is enabled')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsBlockRemoteLogonWithBlankPassword

    [DscProperty()]
    [System.ComponentModel.Description('Enabling this settings allows only interactively logged on user to access CD-ROM media.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsBlockRemoteOpticalDriveAccess

    [DscProperty()]
    [System.ComponentModel.Description('Restrict installing printer drivers as part of connecting to a shared printer to admins only.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsBlockUsersInstallingPrinterDrivers

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether the virtual memory pagefile is cleared when the system is shut down.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsClearVirtualMemoryPageFile

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether packet signing is required by the SMB client component.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsClientDigitallySignCommunicationsAlways

    [DscProperty()]
    [System.ComponentModel.Description('If this security setting is enabled, the Server Message Block (SMB) redirector is allowed to send plaintext passwords to non-Microsoft SMB servers that do not support password encryption during authentication.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers

    [DscProperty()]
    [System.ComponentModel.Description('App installations requiring elevated privileges will prompt for admin credentials.Default is enabled')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDetectApplicationInstallationsAndPromptForElevation

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the Local Administrator account is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDisableAdministratorAccount

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether the SMB client attempts to negotiate SMB packet signing.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees

    [DscProperty()]
    [System.ComponentModel.Description('Determines if the Guest account is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDisableGuestAccount

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether packet signing is required by the SMB server component.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDisableServerDigitallySignCommunicationsAlways

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether the SMB server will negotiate SMB packet signing with clients that request it.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines what additional permissions will be granted for anonymous connections to the computer.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Require CTRL+ALT+DEL to be pressed before a user can log on.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDoNotRequireCtrlAltDel

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines if, at the next password change, the LAN Manager (LM) hash value for the new password is stored. Its not stored by default.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange

    [DscProperty()]
    [System.ComponentModel.Description('Define who is allowed to format and eject removable NTFS media. Possible values are: notConfigured, administrators, administratorsAndPowerUsers, administratorsAndInteractiveUsers.')]
    [ValidateSet('notConfigured', 'administrators', 'administratorsAndPowerUsers', 'administratorsAndInteractiveUsers')]
    [System.String] $LocalSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser

    [DscProperty()]
    [System.ComponentModel.Description('Define a different account name to be associated with the security identifier (SID) for the account ''Guest''.')]
    [System.String] $LocalSecurityOptionsGuestAccountName

    [DscProperty()]
    [System.ComponentModel.Description('Do not display the username of the last person who signed in on this device.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsHideLastSignedInUser

    [DscProperty()]
    [System.ComponentModel.Description('Do not display the username of the person signing in to this device after credentials are entered and before the devices desktop is shown.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsHideUsernameAtSignIn

    [DscProperty()]
    [System.ComponentModel.Description('Configure the user information that is displayed when the session is locked. If not configured, user display name, domain and username are shown. Possible values are: notConfigured, administrators, administratorsAndPowerUsers, administratorsAndInteractiveUsers.')]
    [ValidateSet('notConfigured', 'administrators', 'administratorsAndPowerUsers', 'administratorsAndInteractiveUsers')]
    [System.String] $LocalSecurityOptionsInformationDisplayedOnLockScreen

    [DscProperty()]
    [System.ComponentModel.Description('Configure the user information that is displayed when the session is locked. If not configured, user display name, domain and username are shown. Possible values are: notConfigured, userDisplayNameDomainUser, userDisplayNameOnly, doNotDisplayUser.')]
    [ValidateSet('notConfigured', 'userDisplayNameDomainUser', 'userDisplayNameOnly', 'doNotDisplayUser')]
    [System.String] $LocalSecurityOptionsInformationShownOnLockScreen

    [DscProperty()]
    [System.ComponentModel.Description('Set message text for users attempting to log in.')]
    [System.String] $LocalSecurityOptionsLogOnMessageText

    [DscProperty()]
    [System.ComponentModel.Description('Set message title for users attempting to log in.')]
    [System.String] $LocalSecurityOptionsLogOnMessageTitle

    [DscProperty()]
    [System.ComponentModel.Description('Define maximum minutes of inactivity on the interactive desktops login screen until the screen saver runs. Valid values 0 to 9999')]
    [System.Nullable[System.UInt32]] $LocalSecurityOptionsMachineInactivityLimit

    [DscProperty()]
    [System.ComponentModel.Description('Define maximum minutes of inactivity on the interactive desktops login screen until the screen saver runs. Valid values 0 to 9999')]
    [System.Nullable[System.UInt32]] $LocalSecurityOptionsMachineInactivityLimitInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('This security setting allows a client to require the negotiation of 128-bit encryption and/or NTLMv2 session security. Possible values are: none, requireNtmlV2SessionSecurity, require128BitEncryption, ntlmV2And128BitEncryption.')]
    [ValidateSet('none', 'requireNtmlV2SessionSecurity', 'require128BitEncryption', 'ntlmV2And128BitEncryption')]
    [System.String] $LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients

    [DscProperty()]
    [System.ComponentModel.Description('This security setting allows a server to require the negotiation of 128-bit encryption and/or NTLMv2 session security. Possible values are: none, requireNtmlV2SessionSecurity, require128BitEncryption, ntlmV2And128BitEncryption.')]
    [ValidateSet('none', 'requireNtmlV2SessionSecurity', 'require128BitEncryption', 'ntlmV2And128BitEncryption')]
    [System.String] $LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers

    [DscProperty()]
    [System.ComponentModel.Description('Enforce PKI certification path validation for a given executable file before it is permitted to run.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsOnlyElevateSignedExecutables

    [DscProperty()]
    [System.ComponentModel.Description('By default, this security setting restricts anonymous access to shares and pipes to the settings for named pipes that can be accessed anonymously and Shares that can be accessed anonymously')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines what happens when the smart card for a logged-on user is removed from the smart card reader. Possible values are: noAction, lockWorkstation, forceLogoff, disconnectRemoteDesktopSession.')]
    [ValidateSet('noAction', 'lockWorkstation', 'forceLogoff', 'disconnectRemoteDesktopSession')]
    [System.String] $LocalSecurityOptionsSmartCardRemovalBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Define the behavior of the elevation prompt for standard users. Possible values are: notConfigured, automaticallyDenyElevationRequests, promptForCredentialsOnTheSecureDesktop, promptForCredentials.')]
    [ValidateSet('notConfigured', 'automaticallyDenyElevationRequests', 'promptForCredentialsOnTheSecureDesktop', 'promptForCredentials')]
    [System.String] $LocalSecurityOptionsStandardUserElevationPromptBehavior

    [DscProperty()]
    [System.ComponentModel.Description('Enable all elevation requests to go to the interactive user''s desktop rather than the secure desktop. Prompt behavior policy settings for admins and standard users are used.')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether the built-in admin account uses Admin Approval Mode or runs all apps with full admin privileges.Default is enabled')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsUseAdminApprovalMode

    [DscProperty()]
    [System.ComponentModel.Description('Define whether Admin Approval Mode and all UAC policy settings are enabled, default is enabled')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsUseAdminApprovalModeForAdministrators

    [DscProperty()]
    [System.ComponentModel.Description('Virtualize file and registry write failures to per user locations')]
    [System.Nullable[System.Boolean]] $LocalSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT Admins to control whether users can can ignore SmartScreen warnings and run malicious files.')]
    [System.Nullable[System.Boolean]] $SmartScreenBlockOverrideForFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows IT Admins to configure SmartScreen for Windows.')]
    [System.Nullable[System.Boolean]] $SmartScreenEnableInShell

    [DscProperty()]
    [System.ComponentModel.Description('This user right is used by Credential Manager during Backup/Restore. Users'' saved credentials might be compromised if this privilege is given to other entities. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsAccessCredentialManagerAsTrustedCaller

    [DscProperty()]
    [System.ComponentModel.Description('This user right allows a process to impersonate any user without authentication. The process can therefore gain access to the same local resources as that user. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsActAsPartOfTheOperatingSystem

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups are allowed to connect to the computer over the network. State Allowed is supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsAllowAccessFromNetwork

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can bypass file, directory, registry, and other persistent objects permissions when backing up files and directories. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsBackupData

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups are block from connecting to the computer over the network. State Block is supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsBlockAccessFromNetwork

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups can change the time and date on the internal clock of the computer. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsChangeSystemTime

    [DscProperty()]
    [System.ComponentModel.Description('This security setting determines whether users can create global objects that are available to all sessions. Users who can create global objects could affect processes that run under other users'' sessions, which could lead to application failure or data corruption. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsCreateGlobalObjects

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups can call an internal API to create and change the size of a page file. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsCreatePageFile

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which accounts can be used by processes to create a directory object using the object manager. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsCreatePermanentSharedObjects

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines if the user can create a symbolic link from the computer to which they are logged on. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsCreateSymbolicLinks

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users/groups can be used by processes to create a token that can then be used to get access to any local resources when the process uses an internal API to create an access token. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsCreateToken

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can attach a debugger to any process or to the kernel. Only states NotConfigured and Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsDebugPrograms

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can set the Trusted for Delegation setting on a user or computer object. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsDelegation

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users cannot log on to the computer. States NotConfigured, Blocked are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsDenyLocalLogOn

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which accounts can be used by a process to add entries to the security log. The security log is used to trace unauthorized system access.  Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsGenerateSecurityAudits

    [DscProperty()]
    [System.ComponentModel.Description('Assigning this user right to a user allows programs running on behalf of that user to impersonate a client. Requiring this user right for this kind of impersonation prevents an unauthorized user from convincing a client to connect to a service that they have created and then impersonating that client, which can elevate the unauthorized user''s permissions to administrative or system levels. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsImpersonateClient

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which accounts can use a process with Write Property access to another process to increase the execution priority assigned to the other process. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsIncreaseSchedulingPriority

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can dynamically load and unload device drivers or other code in to kernel mode. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsLoadUnloadDrivers

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can log on to the computer. States NotConfigured, Allowed are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsLocalLogOn

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which accounts can use a process to keep data in physical memory, which prevents the system from paging the data to virtual memory on disk. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsLockMemory

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can specify object access auditing options for individual resources, such as files, Active Directory objects, and registry keys. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsManageAuditingAndSecurityLogs

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups can run maintenance tasks on a volume, such as remote defragmentation. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsManageVolumes

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines who can modify firmware environment values. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsModifyFirmwareEnvironment

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which user accounts can modify the integrity label of objects, such as files, registry keys, or processes owned by other users. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsModifyObjectLabels

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can use performance monitoring tools to monitor the performance of system processes. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsProfileSingleProcess

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users and groups are prohibited from logging on as a Remote Desktop Services client. Only states NotConfigured and Blocked are supported')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsRemoteDesktopServicesLogOn

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users are allowed to shut down a computer from a remote location on the network. Misuse of this user right can result in a denial of service. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsRemoteShutdown

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can bypass file, directory, registry, and other persistent objects permissions when restoring backed up files and directories, and determines which users can set any valid security principal as the owner of an object. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsRestoreData

    [DscProperty()]
    [System.ComponentModel.Description('This user right determines which users can take ownership of any securable object in the system, including Active Directory objects, files and folders, printers, registry keys, processes, and threads. Only states NotConfigured and Allowed are supported.')]
    [MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] $UserRightsTakeOwnership

    [DscProperty()]
    [System.ComponentModel.Description('Configure windows defender TamperProtection settings. Possible values are: notConfigured, enable, disable.')]
    [ValidateSet('notConfigured', 'enable', 'disable')]
    [System.String] $WindowsDefenderTamperProtection

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether the Accessory management service''s start type is Automatic(2), Manual(3), Disabled(4). Default: Manual. Possible values are: manual, automatic, disabled.')]
    [ValidateSet('manual', 'automatic', 'disabled')]
    [System.String] $XboxServicesAccessoryManagementServiceStartupMode

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether xbox game save is enabled (1) or disabled (0).')]
    [System.Nullable[System.Boolean]] $XboxServicesEnableXboxGameSaveTask

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether Live Auth Manager service''s start type is Automatic(2), Manual(3), Disabled(4). Default: Manual. Possible values are: manual, automatic, disabled.')]
    [ValidateSet('manual', 'automatic', 'disabled')]
    [System.String] $XboxServicesLiveAuthManagerServiceStartupMode

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether Live Game save service''s start type is Automatic(2), Manual(3), Disabled(4). Default: Manual. Possible values are: manual, automatic, disabled.')]
    [ValidateSet('manual', 'automatic', 'disabled')]
    [System.String] $XboxServicesLiveGameSaveServiceStartupMode

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines whether Networking service''s start type is Automatic(2), Manual(3), Disabled(4). Default: Manual. Possible values are: manual, automatic, disabled.')]
    [ValidateSet('manual', 'automatic', 'disabled')]
    [System.String] $XboxServicesLiveNetworkingServiceStartupMode

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

    [IntuneDeviceConfigurationEndpointProtectionPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationEndpointProtectionPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Endpoint Protection Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}."

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
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Endpoint Protection Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows10EndpointProtectionConfiguration')" `
                            -ErrorAction SilentlyContinue

                        if ($null -eq $getValue)
                        {
                            Write-Verbose -Message "Could not find an Intune Device Configuration Endpoint Protection Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                            return $this.AsResult($nullResult)
                        }
                        if (([array]$getValue).Count -gt 1)
                        {
                            throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                        }
                    }
                }
                #endregion
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Endpoint Protection Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexBitLockerFixedDrivePolicy = [ordered]@{}
            if ($null -ne $getValue.bitLockerFixedDrivePolicy.encryptionMethod)
            {
                $complexBitLockerFixedDrivePolicy.Add('EncryptionMethod', $getValue.bitLockerFixedDrivePolicy.encryptionMethod)
            }
            $complexRecoveryOptions = [ordered]@{}
            $complexRecoveryOptions.Add('BlockDataRecoveryAgent', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.blockDataRecoveryAgent)
            $complexRecoveryOptions.Add('EnableBitLockerAfterRecoveryInformationToStore', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.enableBitLockerAfterRecoveryInformationToStore)
            $complexRecoveryOptions.Add('EnableRecoveryInformationSaveToStore', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.enableRecoveryInformationSaveToStore)
            $complexRecoveryOptions.Add('HideRecoveryOptions', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.hideRecoveryOptions)
            if ($null -ne $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryInformationToStore)
            {
                $complexRecoveryOptions.Add('RecoveryInformationToStore', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryInformationToStore)
            }
            if ($null -ne $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryKeyUsage)
            {
                $complexRecoveryOptions.Add('RecoveryKeyUsage', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryKeyUsage)
            }
            if ($null -ne $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryPasswordUsage)
            {
                $complexRecoveryOptions.Add('RecoveryPasswordUsage', $getValue.bitLockerFixedDrivePolicy.recoveryOptions.recoveryPasswordUsage)
            }
            if ($complexRecoveryOptions.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRecoveryOptions = $null
            }
            $complexBitLockerFixedDrivePolicy.Add('RecoveryOptions', $complexRecoveryOptions)
            $complexBitLockerFixedDrivePolicy.Add('RequireEncryptionForWriteAccess', $getValue.bitLockerFixedDrivePolicy.requireEncryptionForWriteAccess)
            if ($complexBitLockerFixedDrivePolicy.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexBitLockerFixedDrivePolicy = $null
            }

            $complexBitLockerRemovableDrivePolicy = [ordered]@{}
            $complexBitLockerRemovableDrivePolicy.Add('BlockCrossOrganizationWriteAccess', $getValue.bitLockerRemovableDrivePolicy.blockCrossOrganizationWriteAccess)
            if ($null -ne $getValue.bitLockerRemovableDrivePolicy.encryptionMethod)
            {
                $complexBitLockerRemovableDrivePolicy.Add('EncryptionMethod', $getValue.bitLockerRemovableDrivePolicy.encryptionMethod)
            }
            $complexBitLockerRemovableDrivePolicy.Add('RequireEncryptionForWriteAccess', $getValue.bitLockerRemovableDrivePolicy.requireEncryptionForWriteAccess)
            if ($complexBitLockerRemovableDrivePolicy.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexBitLockerRemovableDrivePolicy = $null
            }

            $complexBitLockerSystemDrivePolicy = [ordered]@{}
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.encryptionMethod)
            {
                $complexBitLockerSystemDrivePolicy.Add('EncryptionMethod', $getValue.bitLockerSystemDrivePolicy.encryptionMethod)
            }
            $complexBitLockerSystemDrivePolicy.Add('MinimumPinLength', $getValue.bitLockerSystemDrivePolicy.minimumPinLength)
            $complexBitLockerSystemDrivePolicy.Add('PrebootRecoveryEnableMessageAndUrl', $getValue.bitLockerSystemDrivePolicy.prebootRecoveryEnableMessageAndUrl)
            $complexBitLockerSystemDrivePolicy.Add('PrebootRecoveryMessage', $getValue.bitLockerSystemDrivePolicy.prebootRecoveryMessage)
            $complexBitLockerSystemDrivePolicy.Add('PrebootRecoveryUrl', $getValue.bitLockerSystemDrivePolicy.prebootRecoveryUrl)
            $complexRecoveryOptions = [ordered]@{}
            $complexRecoveryOptions.Add('BlockDataRecoveryAgent', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.blockDataRecoveryAgent)
            $complexRecoveryOptions.Add('EnableBitLockerAfterRecoveryInformationToStore', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.enableBitLockerAfterRecoveryInformationToStore)
            $complexRecoveryOptions.Add('EnableRecoveryInformationSaveToStore', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.enableRecoveryInformationSaveToStore)
            $complexRecoveryOptions.Add('HideRecoveryOptions', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.hideRecoveryOptions)
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryInformationToStore)
            {
                $complexRecoveryOptions.Add('RecoveryInformationToStore', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryInformationToStore)
            }
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryKeyUsage)
            {
                $complexRecoveryOptions.Add('RecoveryKeyUsage', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryKeyUsage)
            }
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryPasswordUsage)
            {
                $complexRecoveryOptions.Add('RecoveryPasswordUsage', $getValue.bitLockerSystemDrivePolicy.recoveryOptions.recoveryPasswordUsage)
            }
            if ($complexRecoveryOptions.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRecoveryOptions = $null
            }
            $complexBitLockerSystemDrivePolicy.Add('RecoveryOptions', $complexRecoveryOptions)
            $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationBlockWithoutTpmChip', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationBlockWithoutTpmChip)
            $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationRequired', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationRequired)
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmKeyUsage)
            {
                $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationTpmKeyUsage', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmKeyUsage)
            }
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmPinAndKeyUsage)
            {
                $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationTpmPinAndKeyUsage', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmPinAndKeyUsage)
            }
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmPinUsage)
            {
                $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationTpmPinUsage', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmPinUsage)
            }
            if ($null -ne $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmUsage)
            {
                $complexBitLockerSystemDrivePolicy.Add('StartupAuthenticationTpmUsage', $getValue.bitLockerSystemDrivePolicy.startupAuthenticationTpmUsage)
            }
            if ($complexBitLockerSystemDrivePolicy.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexBitLockerSystemDrivePolicy = $null
            }

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

            $complexFirewallProfileDomain = [ordered]@{}
            $complexFirewallProfileDomain.Add('AuthorizedApplicationRulesFromGroupPolicyMerged', $getValue.firewallProfileDomain.authorizedApplicationRulesFromGroupPolicyMerged)
            $complexFirewallProfileDomain.Add('AuthorizedApplicationRulesFromGroupPolicyNotMerged', $getValue.firewallProfileDomain.authorizedApplicationRulesFromGroupPolicyNotMerged)
            $complexFirewallProfileDomain.Add('ConnectionSecurityRulesFromGroupPolicyMerged', $getValue.firewallProfileDomain.connectionSecurityRulesFromGroupPolicyMerged)
            $complexFirewallProfileDomain.Add('ConnectionSecurityRulesFromGroupPolicyNotMerged', $getValue.firewallProfileDomain.connectionSecurityRulesFromGroupPolicyNotMerged)
            if ($null -ne $getValue.firewallProfileDomain.firewallEnabled)
            {
                $complexFirewallProfileDomain.Add('FirewallEnabled', $getValue.firewallProfileDomain.firewallEnabled)
            }
            $complexFirewallProfileDomain.Add('GlobalPortRulesFromGroupPolicyMerged', $getValue.firewallProfileDomain.globalPortRulesFromGroupPolicyMerged)
            $complexFirewallProfileDomain.Add('GlobalPortRulesFromGroupPolicyNotMerged', $getValue.firewallProfileDomain.globalPortRulesFromGroupPolicyNotMerged)
            $complexFirewallProfileDomain.Add('InboundConnectionsBlocked', $getValue.firewallProfileDomain.inboundConnectionsBlocked)
            $complexFirewallProfileDomain.Add('InboundConnectionsRequired', $getValue.firewallProfileDomain.inboundConnectionsRequired)
            $complexFirewallProfileDomain.Add('InboundNotificationsBlocked', $getValue.firewallProfileDomain.inboundNotificationsBlocked)
            $complexFirewallProfileDomain.Add('InboundNotificationsRequired', $getValue.firewallProfileDomain.inboundNotificationsRequired)
            $complexFirewallProfileDomain.Add('IncomingTrafficBlocked', $getValue.firewallProfileDomain.incomingTrafficBlocked)
            $complexFirewallProfileDomain.Add('IncomingTrafficRequired', $getValue.firewallProfileDomain.incomingTrafficRequired)
            $complexFirewallProfileDomain.Add('OutboundConnectionsBlocked', $getValue.firewallProfileDomain.outboundConnectionsBlocked)
            $complexFirewallProfileDomain.Add('OutboundConnectionsRequired', $getValue.firewallProfileDomain.outboundConnectionsRequired)
            $complexFirewallProfileDomain.Add('PolicyRulesFromGroupPolicyMerged', $getValue.firewallProfileDomain.policyRulesFromGroupPolicyMerged)
            $complexFirewallProfileDomain.Add('PolicyRulesFromGroupPolicyNotMerged', $getValue.firewallProfileDomain.policyRulesFromGroupPolicyNotMerged)
            $complexFirewallProfileDomain.Add('SecuredPacketExemptionAllowed', $getValue.firewallProfileDomain.securedPacketExemptionAllowed)
            $complexFirewallProfileDomain.Add('SecuredPacketExemptionBlocked', $getValue.firewallProfileDomain.securedPacketExemptionBlocked)
            $complexFirewallProfileDomain.Add('StealthModeBlocked', $getValue.firewallProfileDomain.stealthModeBlocked)
            $complexFirewallProfileDomain.Add('StealthModeRequired', $getValue.firewallProfileDomain.stealthModeRequired)
            $complexFirewallProfileDomain.Add('UnicastResponsesToMulticastBroadcastsBlocked', $getValue.firewallProfileDomain.unicastResponsesToMulticastBroadcastsBlocked)
            $complexFirewallProfileDomain.Add('UnicastResponsesToMulticastBroadcastsRequired', $getValue.firewallProfileDomain.unicastResponsesToMulticastBroadcastsRequired)
            if ($complexFirewallProfileDomain.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexFirewallProfileDomain = $null
            }

            $complexFirewallProfilePrivate = [ordered]@{}
            $complexFirewallProfilePrivate.Add('AuthorizedApplicationRulesFromGroupPolicyMerged', $getValue.firewallProfilePrivate.authorizedApplicationRulesFromGroupPolicyMerged)
            $complexFirewallProfilePrivate.Add('AuthorizedApplicationRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePrivate.authorizedApplicationRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePrivate.Add('ConnectionSecurityRulesFromGroupPolicyMerged', $getValue.firewallProfilePrivate.connectionSecurityRulesFromGroupPolicyMerged)
            $complexFirewallProfilePrivate.Add('ConnectionSecurityRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePrivate.connectionSecurityRulesFromGroupPolicyNotMerged)
            if ($null -ne $getValue.firewallProfilePrivate.firewallEnabled)
            {
                $complexFirewallProfilePrivate.Add('FirewallEnabled', $getValue.firewallProfilePrivate.firewallEnabled)
            }
            $complexFirewallProfilePrivate.Add('GlobalPortRulesFromGroupPolicyMerged', $getValue.firewallProfilePrivate.globalPortRulesFromGroupPolicyMerged)
            $complexFirewallProfilePrivate.Add('GlobalPortRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePrivate.globalPortRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePrivate.Add('InboundConnectionsBlocked', $getValue.firewallProfilePrivate.inboundConnectionsBlocked)
            $complexFirewallProfilePrivate.Add('InboundConnectionsRequired', $getValue.firewallProfilePrivate.inboundConnectionsRequired)
            $complexFirewallProfilePrivate.Add('InboundNotificationsBlocked', $getValue.firewallProfilePrivate.inboundNotificationsBlocked)
            $complexFirewallProfilePrivate.Add('InboundNotificationsRequired', $getValue.firewallProfilePrivate.inboundNotificationsRequired)
            $complexFirewallProfilePrivate.Add('IncomingTrafficBlocked', $getValue.firewallProfilePrivate.incomingTrafficBlocked)
            $complexFirewallProfilePrivate.Add('IncomingTrafficRequired', $getValue.firewallProfilePrivate.incomingTrafficRequired)
            $complexFirewallProfilePrivate.Add('OutboundConnectionsBlocked', $getValue.firewallProfilePrivate.outboundConnectionsBlocked)
            $complexFirewallProfilePrivate.Add('OutboundConnectionsRequired', $getValue.firewallProfilePrivate.outboundConnectionsRequired)
            $complexFirewallProfilePrivate.Add('PolicyRulesFromGroupPolicyMerged', $getValue.firewallProfilePrivate.policyRulesFromGroupPolicyMerged)
            $complexFirewallProfilePrivate.Add('PolicyRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePrivate.policyRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePrivate.Add('SecuredPacketExemptionAllowed', $getValue.firewallProfilePrivate.securedPacketExemptionAllowed)
            $complexFirewallProfilePrivate.Add('SecuredPacketExemptionBlocked', $getValue.firewallProfilePrivate.securedPacketExemptionBlocked)
            $complexFirewallProfilePrivate.Add('StealthModeBlocked', $getValue.firewallProfilePrivate.stealthModeBlocked)
            $complexFirewallProfilePrivate.Add('StealthModeRequired', $getValue.firewallProfilePrivate.stealthModeRequired)
            $complexFirewallProfilePrivate.Add('UnicastResponsesToMulticastBroadcastsBlocked', $getValue.firewallProfilePrivate.unicastResponsesToMulticastBroadcastsBlocked)
            $complexFirewallProfilePrivate.Add('UnicastResponsesToMulticastBroadcastsRequired', $getValue.firewallProfilePrivate.unicastResponsesToMulticastBroadcastsRequired)
            if ($complexFirewallProfilePrivate.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexFirewallProfilePrivate = $null
            }

            $complexFirewallProfilePublic = [ordered]@{}
            $complexFirewallProfilePublic.Add('AuthorizedApplicationRulesFromGroupPolicyMerged', $getValue.firewallProfilePublic.authorizedApplicationRulesFromGroupPolicyMerged)
            $complexFirewallProfilePublic.Add('AuthorizedApplicationRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePublic.authorizedApplicationRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePublic.Add('ConnectionSecurityRulesFromGroupPolicyMerged', $getValue.firewallProfilePublic.connectionSecurityRulesFromGroupPolicyMerged)
            $complexFirewallProfilePublic.Add('ConnectionSecurityRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePublic.connectionSecurityRulesFromGroupPolicyNotMerged)
            if ($null -ne $getValue.firewallProfilePublic.firewallEnabled)
            {
                $complexFirewallProfilePublic.Add('FirewallEnabled', $getValue.firewallProfilePublic.firewallEnabled)
            }
            $complexFirewallProfilePublic.Add('GlobalPortRulesFromGroupPolicyMerged', $getValue.firewallProfilePublic.globalPortRulesFromGroupPolicyMerged)
            $complexFirewallProfilePublic.Add('GlobalPortRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePublic.globalPortRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePublic.Add('InboundConnectionsBlocked', $getValue.firewallProfilePublic.inboundConnectionsBlocked)
            $complexFirewallProfilePublic.Add('InboundConnectionsRequired', $getValue.firewallProfilePublic.inboundConnectionsRequired)
            $complexFirewallProfilePublic.Add('InboundNotificationsBlocked', $getValue.firewallProfilePublic.inboundNotificationsBlocked)
            $complexFirewallProfilePublic.Add('InboundNotificationsRequired', $getValue.firewallProfilePublic.inboundNotificationsRequired)
            $complexFirewallProfilePublic.Add('IncomingTrafficBlocked', $getValue.firewallProfilePublic.incomingTrafficBlocked)
            $complexFirewallProfilePublic.Add('IncomingTrafficRequired', $getValue.firewallProfilePublic.incomingTrafficRequired)
            $complexFirewallProfilePublic.Add('OutboundConnectionsBlocked', $getValue.firewallProfilePublic.outboundConnectionsBlocked)
            $complexFirewallProfilePublic.Add('OutboundConnectionsRequired', $getValue.firewallProfilePublic.outboundConnectionsRequired)
            $complexFirewallProfilePublic.Add('PolicyRulesFromGroupPolicyMerged', $getValue.firewallProfilePublic.policyRulesFromGroupPolicyMerged)
            $complexFirewallProfilePublic.Add('PolicyRulesFromGroupPolicyNotMerged', $getValue.firewallProfilePublic.policyRulesFromGroupPolicyNotMerged)
            $complexFirewallProfilePublic.Add('SecuredPacketExemptionAllowed', $getValue.firewallProfilePublic.securedPacketExemptionAllowed)
            $complexFirewallProfilePublic.Add('SecuredPacketExemptionBlocked', $getValue.firewallProfilePublic.securedPacketExemptionBlocked)
            $complexFirewallProfilePublic.Add('StealthModeBlocked', $getValue.firewallProfilePublic.stealthModeBlocked)
            $complexFirewallProfilePublic.Add('StealthModeRequired', $getValue.firewallProfilePublic.stealthModeRequired)
            $complexFirewallProfilePublic.Add('UnicastResponsesToMulticastBroadcastsBlocked', $getValue.firewallProfilePublic.unicastResponsesToMulticastBroadcastsBlocked)
            $complexFirewallProfilePublic.Add('UnicastResponsesToMulticastBroadcastsRequired', $getValue.firewallProfilePublic.unicastResponsesToMulticastBroadcastsRequired)
            if ($complexFirewallProfilePublic.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexFirewallProfilePublic = $null
            }

            $complexFirewallRules = @()
            foreach ($currentfirewallRules in $getValue.firewallRules)
            {
                $myfirewallRules = [ordered]@{}
                if ($null -ne $currentfirewallRules.action)
                {
                    $myfirewallRules.Add('Action', $currentfirewallRules.action)
                }
                $myfirewallRules.Add('Description', $currentfirewallRules.description)
                $myfirewallRules.Add('DisplayName', $currentfirewallRules.displayName)
                if ($null -ne $currentfirewallRules.edgeTraversal)
                {
                    $myfirewallRules.Add('EdgeTraversal', $currentfirewallRules.edgeTraversal)
                }
                $myfirewallRules.Add('FilePath', $currentfirewallRules.filePath)
                if ($null -ne $currentfirewallRules.interfaceTypes)
                {
                    $myfirewallRules.Add('InterfaceTypes', [System.String[]]($currentfirewallRules.interfaceTypes.ToString().Split(',') | Where-Object { -not [System.String]::IsNullOrEmpty($_) }))
                }
                $myfirewallRules.Add('LocalAddressRanges', $currentfirewallRules.localAddressRanges)
                $myfirewallRules.Add('LocalPortRanges', $currentfirewallRules.localPortRanges)
                $myfirewallRules.Add('LocalUserAuthorizations', $currentfirewallRules.localUserAuthorizations)
                $myfirewallRules.Add('PackageFamilyName', $currentfirewallRules.packageFamilyName)
                if ($null -ne $currentfirewallRules.profileTypes)
                {
                    $myfirewallRules.Add('ProfileTypes', $currentfirewallRules.profileTypes)
                }
                $myfirewallRules.Add('Protocol', $currentfirewallRules.protocol)
                $myfirewallRules.Add('RemoteAddressRanges', $currentfirewallRules.remoteAddressRanges)
                $myfirewallRules.Add('RemotePortRanges', $currentfirewallRules.remotePortRanges)
                $myfirewallRules.Add('ServiceName', $currentfirewallRules.serviceName)
                if ($null -ne $currentfirewallRules.trafficDirection)
                {
                    $myfirewallRules.Add('TrafficDirection', $currentfirewallRules.trafficDirection)
                }
                if ($myfirewallRules.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexFirewallRules += $myfirewallRules
                }
            }

            $complexUserRightsAccessCredentialManagerAsTrustedCaller = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsAccessCredentialManagerAsTrustedCaller.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsAccessCredentialManagerAsTrustedCaller.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsAccessCredentialManagerAsTrustedCaller.state)
            {
                $complexUserRightsAccessCredentialManagerAsTrustedCaller.Add('State', $getValue.userRightsAccessCredentialManagerAsTrustedCaller.state)
            }
            if ($complexUserRightsAccessCredentialManagerAsTrustedCaller.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsAccessCredentialManagerAsTrustedCaller = $null
            }

            $complexUserRightsActAsPartOfTheOperatingSystem = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsActAsPartOfTheOperatingSystem.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsActAsPartOfTheOperatingSystem.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsActAsPartOfTheOperatingSystem.state)
            {
                $complexUserRightsActAsPartOfTheOperatingSystem.Add('State', $getValue.userRightsActAsPartOfTheOperatingSystem.state)
            }
            if ($complexUserRightsActAsPartOfTheOperatingSystem.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsActAsPartOfTheOperatingSystem = $null
            }

            $complexUserRightsAllowAccessFromNetwork = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsAllowAccessFromNetwork.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsAllowAccessFromNetwork.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsAllowAccessFromNetwork.state)
            {
                $complexUserRightsAllowAccessFromNetwork.Add('State', $getValue.userRightsAllowAccessFromNetwork.state)
            }
            if ($complexUserRightsAllowAccessFromNetwork.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsAllowAccessFromNetwork = $null
            }

            $complexUserRightsBackupData = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsBackupData.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsBackupData.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsBackupData.state)
            {
                $complexUserRightsBackupData.Add('State', $getValue.userRightsBackupData.state)
            }
            if ($complexUserRightsBackupData.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsBackupData = $null
            }

            $complexUserRightsBlockAccessFromNetwork = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsBlockAccessFromNetwork.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsBlockAccessFromNetwork.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsBlockAccessFromNetwork.state)
            {
                $complexUserRightsBlockAccessFromNetwork.Add('State', $getValue.userRightsBlockAccessFromNetwork.state)
            }
            if ($complexUserRightsBlockAccessFromNetwork.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsBlockAccessFromNetwork = $null
            }

            $complexUserRightsChangeSystemTime = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsChangeSystemTime.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsChangeSystemTime.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsChangeSystemTime.state)
            {
                $complexUserRightsChangeSystemTime.Add('State', $getValue.userRightsChangeSystemTime.state)
            }
            if ($complexUserRightsChangeSystemTime.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsChangeSystemTime = $null
            }

            $complexUserRightsCreateGlobalObjects = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsCreateGlobalObjects.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsCreateGlobalObjects.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsCreateGlobalObjects.state)
            {
                $complexUserRightsCreateGlobalObjects.Add('State', $getValue.userRightsCreateGlobalObjects.state)
            }
            if ($complexUserRightsCreateGlobalObjects.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsCreateGlobalObjects = $null
            }

            $complexUserRightsCreatePageFile = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsCreatePageFile.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsCreatePageFile.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsCreatePageFile.state)
            {
                $complexUserRightsCreatePageFile.Add('State', $getValue.userRightsCreatePageFile.state)
            }
            if ($complexUserRightsCreatePageFile.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsCreatePageFile = $null
            }

            $complexUserRightsCreatePermanentSharedObjects = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsCreatePermanentSharedObjects.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsCreatePermanentSharedObjects.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsCreatePermanentSharedObjects.state)
            {
                $complexUserRightsCreatePermanentSharedObjects.Add('State', $getValue.userRightsCreatePermanentSharedObjects.state)
            }
            if ($complexUserRightsCreatePermanentSharedObjects.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsCreatePermanentSharedObjects = $null
            }

            $complexUserRightsCreateSymbolicLinks = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsCreateSymbolicLinks.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsCreateSymbolicLinks.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsCreateSymbolicLinks.state)
            {
                $complexUserRightsCreateSymbolicLinks.Add('State', $getValue.userRightsCreateSymbolicLinks.state)
            }
            if ($complexUserRightsCreateSymbolicLinks.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsCreateSymbolicLinks = $null
            }

            $complexUserRightsCreateToken = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsCreateToken.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsCreateToken.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsCreateToken.state)
            {
                $complexUserRightsCreateToken.Add('State', $getValue.userRightsCreateToken.state)
            }
            if ($complexUserRightsCreateToken.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsCreateToken = $null
            }

            $complexUserRightsDebugPrograms = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsDebugPrograms.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsDebugPrograms.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsDebugPrograms.state)
            {
                $complexUserRightsDebugPrograms.Add('State', $getValue.userRightsDebugPrograms.state)
            }
            if ($complexUserRightsDebugPrograms.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsDebugPrograms = $null
            }

            $complexUserRightsDelegation = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsDelegation.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsDelegation.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsDelegation.state)
            {
                $complexUserRightsDelegation.Add('State', $getValue.userRightsDelegation.state)
            }
            if ($complexUserRightsDelegation.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsDelegation = $null
            }

            $complexUserRightsDenyLocalLogOn = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsDenyLocalLogOn.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsDenyLocalLogOn.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsDenyLocalLogOn.state)
            {
                $complexUserRightsDenyLocalLogOn.Add('State', $getValue.userRightsDenyLocalLogOn.state)
            }
            if ($complexUserRightsDenyLocalLogOn.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsDenyLocalLogOn = $null
            }

            $complexUserRightsGenerateSecurityAudits = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsGenerateSecurityAudits.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsGenerateSecurityAudits.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsGenerateSecurityAudits.state)
            {
                $complexUserRightsGenerateSecurityAudits.Add('State', $getValue.userRightsGenerateSecurityAudits.state)
            }
            if ($complexUserRightsGenerateSecurityAudits.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsGenerateSecurityAudits = $null
            }

            $complexUserRightsImpersonateClient = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsImpersonateClient.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsImpersonateClient.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsImpersonateClient.state)
            {
                $complexUserRightsImpersonateClient.Add('State', $getValue.userRightsImpersonateClient.state)
            }
            if ($complexUserRightsImpersonateClient.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsImpersonateClient = $null
            }

            $complexUserRightsIncreaseSchedulingPriority = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsIncreaseSchedulingPriority.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsIncreaseSchedulingPriority.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsIncreaseSchedulingPriority.state)
            {
                $complexUserRightsIncreaseSchedulingPriority.Add('State', $getValue.userRightsIncreaseSchedulingPriority.state)
            }
            if ($complexUserRightsIncreaseSchedulingPriority.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsIncreaseSchedulingPriority = $null
            }

            $complexUserRightsLoadUnloadDrivers = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsLoadUnloadDrivers.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsLoadUnloadDrivers.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsLoadUnloadDrivers.state)
            {
                $complexUserRightsLoadUnloadDrivers.Add('State', $getValue.userRightsLoadUnloadDrivers.state)
            }
            if ($complexUserRightsLoadUnloadDrivers.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsLoadUnloadDrivers = $null
            }

            $complexUserRightsLocalLogOn = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsLocalLogOn.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsLocalLogOn.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsLocalLogOn.state)
            {
                $complexUserRightsLocalLogOn.Add('State', $getValue.userRightsLocalLogOn.state)
            }
            if ($complexUserRightsLocalLogOn.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsLocalLogOn = $null
            }

            $complexUserRightsLockMemory = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsLockMemory.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsLockMemory.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsLockMemory.state)
            {
                $complexUserRightsLockMemory.Add('State', $getValue.userRightsLockMemory.state)
            }
            if ($complexUserRightsLockMemory.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsLockMemory = $null
            }

            $complexUserRightsManageAuditingAndSecurityLogs = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsManageAuditingAndSecurityLogs.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsManageAuditingAndSecurityLogs.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsManageAuditingAndSecurityLogs.state)
            {
                $complexUserRightsManageAuditingAndSecurityLogs.Add('State', $getValue.userRightsManageAuditingAndSecurityLogs.state)
            }
            if ($complexUserRightsManageAuditingAndSecurityLogs.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsManageAuditingAndSecurityLogs = $null
            }

            $complexUserRightsManageVolumes = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsManageVolumes.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsManageVolumes.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsManageVolumes.state)
            {
                $complexUserRightsManageVolumes.Add('State', $getValue.userRightsManageVolumes.state)
            }
            if ($complexUserRightsManageVolumes.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsManageVolumes = $null
            }

            $complexUserRightsModifyFirmwareEnvironment = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsModifyFirmwareEnvironment.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsModifyFirmwareEnvironment.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsModifyFirmwareEnvironment.state)
            {
                $complexUserRightsModifyFirmwareEnvironment.Add('State', $getValue.userRightsModifyFirmwareEnvironment.state)
            }
            if ($complexUserRightsModifyFirmwareEnvironment.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsModifyFirmwareEnvironment = $null
            }

            $complexUserRightsModifyObjectLabels = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsModifyObjectLabels.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsModifyObjectLabels.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsModifyObjectLabels.state)
            {
                $complexUserRightsModifyObjectLabels.Add('State', $getValue.userRightsModifyObjectLabels.state)
            }
            if ($complexUserRightsModifyObjectLabels.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsModifyObjectLabels = $null
            }

            $complexUserRightsProfileSingleProcess = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsProfileSingleProcess.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsProfileSingleProcess.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsProfileSingleProcess.state)
            {
                $complexUserRightsProfileSingleProcess.Add('State', $getValue.userRightsProfileSingleProcess.state)
            }
            if ($complexUserRightsProfileSingleProcess.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsProfileSingleProcess = $null
            }

            $complexUserRightsRemoteDesktopServicesLogOn = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsRemoteDesktopServicesLogOn.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsRemoteDesktopServicesLogOn.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsRemoteDesktopServicesLogOn.state)
            {
                $complexUserRightsRemoteDesktopServicesLogOn.Add('State', $getValue.userRightsRemoteDesktopServicesLogOn.state)
            }
            if ($complexUserRightsRemoteDesktopServicesLogOn.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsRemoteDesktopServicesLogOn = $null
            }

            $complexUserRightsRemoteShutdown = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsRemoteShutdown.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsRemoteShutdown.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsRemoteShutdown.state)
            {
                $complexUserRightsRemoteShutdown.Add('State', $getValue.userRightsRemoteShutdown.state)
            }
            if ($complexUserRightsRemoteShutdown.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsRemoteShutdown = $null
            }

            $complexUserRightsRestoreData = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsRestoreData.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsRestoreData.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsRestoreData.state)
            {
                $complexUserRightsRestoreData.Add('State', $getValue.userRightsRestoreData.state)
            }
            if ($complexUserRightsRestoreData.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsRestoreData = $null
            }

            $complexUserRightsTakeOwnership = [ordered]@{}
            $complexLocalUsersOrGroups = @()
            foreach ($currentLocalUsersOrGroups in $getValue.userRightsTakeOwnership.localUsersOrGroups)
            {
                $myLocalUsersOrGroups = [ordered]@{}
                $myLocalUsersOrGroups.Add('Description', $currentLocalUsersOrGroups.description)
                $myLocalUsersOrGroups.Add('Name', $currentLocalUsersOrGroups.name)
                $myLocalUsersOrGroups.Add('SecurityIdentifier', $currentLocalUsersOrGroups.securityIdentifier)
                if ($myLocalUsersOrGroups.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexLocalUsersOrGroups += $myLocalUsersOrGroups
                }
            }
            $complexUserRightsTakeOwnership.Add('LocalUsersOrGroups', $complexLocalUsersOrGroups)
            if ($null -ne $getValue.userRightsTakeOwnership.state)
            {
                $complexUserRightsTakeOwnership.Add('State', $getValue.userRightsTakeOwnership.state)
            }
            if ($complexUserRightsTakeOwnership.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserRightsTakeOwnership = $null
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
                ApplicationGuardAllowCameraMicrophoneRedirection                             = $getValue.applicationGuardAllowCameraMicrophoneRedirection
                ApplicationGuardAllowFileSaveOnHost                                          = $getValue.applicationGuardAllowFileSaveOnHost
                ApplicationGuardAllowPersistence                                             = $getValue.applicationGuardAllowPersistence
                ApplicationGuardAllowPrintToLocalPrinters                                    = $getValue.applicationGuardAllowPrintToLocalPrinters
                ApplicationGuardAllowPrintToNetworkPrinters                                  = $getValue.applicationGuardAllowPrintToNetworkPrinters
                ApplicationGuardAllowPrintToPDF                                              = $getValue.applicationGuardAllowPrintToPDF
                ApplicationGuardAllowPrintToXPS                                              = $getValue.applicationGuardAllowPrintToXPS
                ApplicationGuardAllowVirtualGPU                                              = $getValue.applicationGuardAllowVirtualGPU
                ApplicationGuardBlockClipboardSharing                                        = $getValue.applicationGuardBlockClipboardSharing
                ApplicationGuardBlockFileTransfer                                            = $getValue.applicationGuardBlockFileTransfer
                ApplicationGuardBlockNonEnterpriseContent                                    = $getValue.applicationGuardBlockNonEnterpriseContent
                ApplicationGuardCertificateThumbprints                                       = $getValue.applicationGuardCertificateThumbprints
                ApplicationGuardEnabled                                                      = $getValue.applicationGuardEnabled
                ApplicationGuardEnabledOptions                                               = $getValue.applicationGuardEnabledOptions
                ApplicationGuardForceAuditing                                                = $getValue.applicationGuardForceAuditing
                AppLockerApplicationControl                                                  = $getValue.appLockerApplicationControl
                BitLockerAllowStandardUserEncryption                                         = $getValue.bitLockerAllowStandardUserEncryption
                BitLockerDisableWarningForOtherDiskEncryption                                = $getValue.bitLockerDisableWarningForOtherDiskEncryption
                BitLockerEnableStorageCardEncryptionOnMobile                                 = $getValue.bitLockerEnableStorageCardEncryptionOnMobile
                BitLockerEncryptDevice                                                       = $getValue.bitLockerEncryptDevice
                BitLockerFixedDrivePolicy                                                    = $complexBitLockerFixedDrivePolicy
                BitLockerRecoveryPasswordRotation                                            = $getValue.bitLockerRecoveryPasswordRotation
                BitLockerRemovableDrivePolicy                                                = $complexBitLockerRemovableDrivePolicy
                BitLockerSystemDrivePolicy                                                   = $complexBitLockerSystemDrivePolicy
                DefenderAdditionalGuardedFolders                                             = $getValue.defenderAdditionalGuardedFolders
                DefenderAdobeReaderLaunchChildProcess                                        = $getValue.defenderAdobeReaderLaunchChildProcess
                DefenderAdvancedRansomewareProtectionType                                    = $getValue.defenderAdvancedRansomewareProtectionType
                DefenderAllowBehaviorMonitoring                                              = $getValue.defenderAllowBehaviorMonitoring
                DefenderAllowCloudProtection                                                 = $getValue.defenderAllowCloudProtection
                DefenderAllowEndUserAccess                                                   = $getValue.defenderAllowEndUserAccess
                DefenderAllowIntrusionPreventionSystem                                       = $getValue.defenderAllowIntrusionPreventionSystem
                DefenderAllowOnAccessProtection                                              = $getValue.defenderAllowOnAccessProtection
                DefenderAllowRealTimeMonitoring                                              = $getValue.defenderAllowRealTimeMonitoring
                DefenderAllowScanArchiveFiles                                                = $getValue.defenderAllowScanArchiveFiles
                DefenderAllowScanDownloads                                                   = $getValue.defenderAllowScanDownloads
                DefenderAllowScanNetworkFiles                                                = $getValue.defenderAllowScanNetworkFiles
                DefenderAllowScanRemovableDrivesDuringFullScan                               = $getValue.defenderAllowScanRemovableDrivesDuringFullScan
                DefenderAllowScanScriptsLoadedInInternetExplorer                             = $getValue.defenderAllowScanScriptsLoadedInInternetExplorer
                DefenderAttackSurfaceReductionExcludedPaths                                  = $getValue.defenderAttackSurfaceReductionExcludedPaths
                DefenderBlockEndUserAccess                                                   = $getValue.defenderBlockEndUserAccess
                DefenderBlockPersistenceThroughWmiType                                       = $getValue.defenderBlockPersistenceThroughWmiType
                DefenderCheckForSignaturesBeforeRunningScan                                  = $getValue.defenderCheckForSignaturesBeforeRunningScan
                DefenderCloudBlockLevel                                                      = $getValue.defenderCloudBlockLevel
                DefenderCloudExtendedTimeoutInSeconds                                        = $getValue.defenderCloudExtendedTimeoutInSeconds
                DefenderDaysBeforeDeletingQuarantinedMalware                                 = $getValue.defenderDaysBeforeDeletingQuarantinedMalware
                DefenderDetectedMalwareActions                                               = $complexDefenderDetectedMalwareActions
                DefenderDisableBehaviorMonitoring                                            = $getValue.defenderDisableBehaviorMonitoring
                DefenderDisableCatchupFullScan                                               = $getValue.defenderDisableCatchupFullScan
                DefenderDisableCatchupQuickScan                                              = $getValue.defenderDisableCatchupQuickScan
                DefenderDisableCloudProtection                                               = $getValue.defenderDisableCloudProtection
                DefenderDisableIntrusionPreventionSystem                                     = $getValue.defenderDisableIntrusionPreventionSystem
                DefenderDisableOnAccessProtection                                            = $getValue.defenderDisableOnAccessProtection
                DefenderDisableRealTimeMonitoring                                            = $getValue.defenderDisableRealTimeMonitoring
                DefenderDisableScanArchiveFiles                                              = $getValue.defenderDisableScanArchiveFiles
                DefenderDisableScanDownloads                                                 = $getValue.defenderDisableScanDownloads
                DefenderDisableScanNetworkFiles                                              = $getValue.defenderDisableScanNetworkFiles
                DefenderDisableScanRemovableDrivesDuringFullScan                             = $getValue.defenderDisableScanRemovableDrivesDuringFullScan
                DefenderDisableScanScriptsLoadedInInternetExplorer                           = $getValue.defenderDisableScanScriptsLoadedInInternetExplorer
                DefenderEmailContentExecution                                                = $getValue.defenderEmailContentExecution
                DefenderEmailContentExecutionType                                            = $getValue.defenderEmailContentExecutionType
                DefenderEnableLowCpuPriority                                                 = $getValue.defenderEnableLowCpuPriority
                DefenderEnableScanIncomingMail                                               = $getValue.defenderEnableScanIncomingMail
                DefenderEnableScanMappedNetworkDrivesDuringFullScan                          = $getValue.defenderEnableScanMappedNetworkDrivesDuringFullScan
                DefenderExploitProtectionXml                                                 = $getValue.defenderExploitProtectionXml
                DefenderExploitProtectionXmlFileName                                         = $getValue.defenderExploitProtectionXmlFileName
                DefenderFileExtensionsToExclude                                              = $getValue.defenderFileExtensionsToExclude
                DefenderFilesAndFoldersToExclude                                             = $getValue.defenderFilesAndFoldersToExclude
                DefenderGuardedFoldersAllowedAppPaths                                        = $getValue.defenderGuardedFoldersAllowedAppPaths
                DefenderGuardMyFoldersType                                                   = $getValue.defenderGuardMyFoldersType
                DefenderNetworkProtectionType                                                = $getValue.defenderNetworkProtectionType
                DefenderOfficeAppsExecutableContentCreationOrLaunch                          = $getValue.defenderOfficeAppsExecutableContentCreationOrLaunch
                DefenderOfficeAppsExecutableContentCreationOrLaunchType                      = $getValue.defenderOfficeAppsExecutableContentCreationOrLaunchType
                DefenderOfficeAppsLaunchChildProcess                                         = $getValue.defenderOfficeAppsLaunchChildProcess
                DefenderOfficeAppsLaunchChildProcessType                                     = $getValue.defenderOfficeAppsLaunchChildProcessType
                DefenderOfficeAppsOtherProcessInjection                                      = $getValue.defenderOfficeAppsOtherProcessInjection
                DefenderOfficeAppsOtherProcessInjectionType                                  = $getValue.defenderOfficeAppsOtherProcessInjectionType
                DefenderOfficeCommunicationAppsLaunchChildProcess                            = $getValue.defenderOfficeCommunicationAppsLaunchChildProcess
                DefenderOfficeMacroCodeAllowWin32Imports                                     = $getValue.defenderOfficeMacroCodeAllowWin32Imports
                DefenderOfficeMacroCodeAllowWin32ImportsType                                 = $getValue.defenderOfficeMacroCodeAllowWin32ImportsType
                DefenderPotentiallyUnwantedAppAction                                         = $getValue.defenderPotentiallyUnwantedAppAction
                DefenderPreventCredentialStealingType                                        = $getValue.defenderPreventCredentialStealingType
                DefenderProcessCreation                                                      = $getValue.defenderProcessCreation
                DefenderProcessCreationType                                                  = $getValue.defenderProcessCreationType
                DefenderProcessesToExclude                                                   = $getValue.defenderProcessesToExclude
                DefenderScanDirection                                                        = $getValue.defenderScanDirection
                DefenderScanMaxCpuPercentage                                                 = $getValue.defenderScanMaxCpuPercentage
                DefenderScanType                                                             = $getValue.defenderScanType
                DefenderScheduledQuickScanTime                                               = $timeDefenderScheduledQuickScanTime
                DefenderScheduledScanDay                                                     = $getValue.defenderScheduledScanDay
                DefenderScheduledScanTime                                                    = $timeDefenderScheduledScanTime
                DefenderScriptDownloadedPayloadExecution                                     = $getValue.defenderScriptDownloadedPayloadExecution
                DefenderScriptDownloadedPayloadExecutionType                                 = $getValue.defenderScriptDownloadedPayloadExecutionType
                DefenderScriptObfuscatedMacroCode                                            = $getValue.defenderScriptObfuscatedMacroCode
                DefenderScriptObfuscatedMacroCodeType                                        = $getValue.defenderScriptObfuscatedMacroCodeType
                DefenderSecurityCenterBlockExploitProtectionOverride                         = $getValue.defenderSecurityCenterBlockExploitProtectionOverride
                DefenderSecurityCenterDisableAccountUI                                       = $getValue.defenderSecurityCenterDisableAccountUI
                DefenderSecurityCenterDisableAppBrowserUI                                    = $getValue.defenderSecurityCenterDisableAppBrowserUI
                DefenderSecurityCenterDisableClearTpmUI                                      = $getValue.defenderSecurityCenterDisableClearTpmUI
                DefenderSecurityCenterDisableFamilyUI                                        = $getValue.defenderSecurityCenterDisableFamilyUI
                DefenderSecurityCenterDisableHardwareUI                                      = $getValue.defenderSecurityCenterDisableHardwareUI
                DefenderSecurityCenterDisableHealthUI                                        = $getValue.defenderSecurityCenterDisableHealthUI
                DefenderSecurityCenterDisableNetworkUI                                       = $getValue.defenderSecurityCenterDisableNetworkUI
                DefenderSecurityCenterDisableNotificationAreaUI                              = $getValue.defenderSecurityCenterDisableNotificationAreaUI
                DefenderSecurityCenterDisableRansomwareUI                                    = $getValue.defenderSecurityCenterDisableRansomwareUI
                DefenderSecurityCenterDisableSecureBootUI                                    = $getValue.defenderSecurityCenterDisableSecureBootUI
                DefenderSecurityCenterDisableTroubleshootingUI                               = $getValue.defenderSecurityCenterDisableTroubleshootingUI
                DefenderSecurityCenterDisableVirusUI                                         = $getValue.defenderSecurityCenterDisableVirusUI
                DefenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI                   = $getValue.defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI
                DefenderSecurityCenterHelpEmail                                              = $getValue.defenderSecurityCenterHelpEmail
                DefenderSecurityCenterHelpPhone                                              = $getValue.defenderSecurityCenterHelpPhone
                DefenderSecurityCenterHelpURL                                                = $getValue.defenderSecurityCenterHelpURL
                DefenderSecurityCenterITContactDisplay                                       = $getValue.defenderSecurityCenterITContactDisplay
                DefenderSecurityCenterNotificationsFromApp                                   = $getValue.defenderSecurityCenterNotificationsFromApp
                DefenderSecurityCenterOrganizationDisplayName                                = $getValue.defenderSecurityCenterOrganizationDisplayName
                DefenderSignatureUpdateIntervalInHours                                       = $getValue.defenderSignatureUpdateIntervalInHours
                DefenderSubmitSamplesConsentType                                             = $getValue.defenderSubmitSamplesConsentType
                DefenderUntrustedExecutable                                                  = $getValue.defenderUntrustedExecutable
                DefenderUntrustedExecutableType                                              = $getValue.defenderUntrustedExecutableType
                DefenderUntrustedUSBProcess                                                  = $getValue.defenderUntrustedUSBProcess
                DefenderUntrustedUSBProcessType                                              = $getValue.defenderUntrustedUSBProcessType
                DeviceGuardEnableSecureBootWithDMA                                           = $getValue.deviceGuardEnableSecureBootWithDMA
                DeviceGuardEnableVirtualizationBasedSecurity                                 = $getValue.deviceGuardEnableVirtualizationBasedSecurity
                DeviceGuardLaunchSystemGuard                                                 = $getValue.deviceGuardLaunchSystemGuard
                DeviceGuardLocalSystemAuthorityCredentialGuardSettings                       = $getValue.deviceGuardLocalSystemAuthorityCredentialGuardSettings
                DeviceGuardSecureBootWithDMA                                                 = $getValue.deviceGuardSecureBootWithDMA
                DeviceManagementApplicabilityRuleDeviceMode                                  = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition                                   = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion                                   = $complexDeviceManagementApplicabilityRuleOsVersion
                DmaGuardDeviceEnumerationPolicy                                              = $getValue.dmaGuardDeviceEnumerationPolicy
                FirewallBlockStatefulFTP                                                     = $getValue.firewallBlockStatefulFTP
                FirewallCertificateRevocationListCheckMethod                                 = $getValue.firewallCertificateRevocationListCheckMethod
                FirewallIdleTimeoutForSecurityAssociationInSeconds                           = $getValue.firewallIdleTimeoutForSecurityAssociationInSeconds
                FirewallIPSecExemptionsAllowDHCP                                             = $getValue.firewallIPSecExemptionsAllowDHCP
                FirewallIPSecExemptionsAllowICMP                                             = $getValue.firewallIPSecExemptionsAllowICMP
                FirewallIPSecExemptionsAllowNeighborDiscovery                                = $getValue.firewallIPSecExemptionsAllowNeighborDiscovery
                FirewallIPSecExemptionsAllowRouterDiscovery                                  = $getValue.firewallIPSecExemptionsAllowRouterDiscovery
                FirewallIPSecExemptionsNone                                                  = $getValue.firewallIPSecExemptionsNone
                FirewallMergeKeyingModuleSettings                                            = $getValue.firewallMergeKeyingModuleSettings
                FirewallPacketQueueingMethod                                                 = $getValue.firewallPacketQueueingMethod
                FirewallPreSharedKeyEncodingMethod                                           = $getValue.firewallPreSharedKeyEncodingMethod
                FirewallProfileDomain                                                        = $complexFirewallProfileDomain
                FirewallProfilePrivate                                                       = $complexFirewallProfilePrivate
                FirewallProfilePublic                                                        = $complexFirewallProfilePublic
                FirewallRules                                                                = $complexFirewallRules
                LanManagerAuthenticationLevel                                                = $getValue.lanManagerAuthenticationLevel
                LanManagerWorkstationDisableInsecureGuestLogons                              = $getValue.lanManagerWorkstationDisableInsecureGuestLogons
                LocalSecurityOptionsAdministratorAccountName                                 = $getValue.localSecurityOptionsAdministratorAccountName
                LocalSecurityOptionsAdministratorElevationPromptBehavior                     = $getValue.localSecurityOptionsAdministratorElevationPromptBehavior
                LocalSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares          = $getValue.localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares
                LocalSecurityOptionsAllowPKU2UAuthenticationRequests                         = $getValue.localSecurityOptionsAllowPKU2UAuthenticationRequests
                LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManager                = $getValue.localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager
                LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool      = $getValue.localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool
                LocalSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn              = $getValue.localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn
                LocalSecurityOptionsAllowUIAccessApplicationElevation                        = $getValue.localSecurityOptionsAllowUIAccessApplicationElevation
                LocalSecurityOptionsAllowUIAccessApplicationsForSecureLocations              = $getValue.localSecurityOptionsAllowUIAccessApplicationsForSecureLocations
                LocalSecurityOptionsAllowUndockWithoutHavingToLogon                          = $getValue.localSecurityOptionsAllowUndockWithoutHavingToLogon
                LocalSecurityOptionsBlockMicrosoftAccounts                                   = $getValue.localSecurityOptionsBlockMicrosoftAccounts
                LocalSecurityOptionsBlockRemoteLogonWithBlankPassword                        = $getValue.localSecurityOptionsBlockRemoteLogonWithBlankPassword
                LocalSecurityOptionsBlockRemoteOpticalDriveAccess                            = $getValue.localSecurityOptionsBlockRemoteOpticalDriveAccess
                LocalSecurityOptionsBlockUsersInstallingPrinterDrivers                       = $getValue.localSecurityOptionsBlockUsersInstallingPrinterDrivers
                LocalSecurityOptionsClearVirtualMemoryPageFile                               = $getValue.localSecurityOptionsClearVirtualMemoryPageFile
                LocalSecurityOptionsClientDigitallySignCommunicationsAlways                  = $getValue.localSecurityOptionsClientDigitallySignCommunicationsAlways
                LocalSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers      = $getValue.localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers
                LocalSecurityOptionsDetectApplicationInstallationsAndPromptForElevation      = $getValue.localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation
                LocalSecurityOptionsDisableAdministratorAccount                              = $getValue.localSecurityOptionsDisableAdministratorAccount
                LocalSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees   = $getValue.localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees
                LocalSecurityOptionsDisableGuestAccount                                      = $getValue.localSecurityOptionsDisableGuestAccount
                LocalSecurityOptionsDisableServerDigitallySignCommunicationsAlways           = $getValue.localSecurityOptionsDisableServerDigitallySignCommunicationsAlways
                LocalSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees   = $getValue.localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees
                LocalSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts              = $getValue.localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts
                LocalSecurityOptionsDoNotRequireCtrlAltDel                                   = $getValue.localSecurityOptionsDoNotRequireCtrlAltDel
                LocalSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange        = $getValue.localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange
                LocalSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser                = $getValue.localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser
                LocalSecurityOptionsGuestAccountName                                         = $getValue.localSecurityOptionsGuestAccountName
                LocalSecurityOptionsHideLastSignedInUser                                     = $getValue.localSecurityOptionsHideLastSignedInUser
                LocalSecurityOptionsHideUsernameAtSignIn                                     = $getValue.localSecurityOptionsHideUsernameAtSignIn
                LocalSecurityOptionsInformationDisplayedOnLockScreen                         = $getValue.localSecurityOptionsInformationDisplayedOnLockScreen
                LocalSecurityOptionsInformationShownOnLockScreen                             = $getValue.localSecurityOptionsInformationShownOnLockScreen
                LocalSecurityOptionsLogOnMessageText                                         = $getValue.localSecurityOptionsLogOnMessageText
                LocalSecurityOptionsLogOnMessageTitle                                        = $getValue.localSecurityOptionsLogOnMessageTitle
                LocalSecurityOptionsMachineInactivityLimit                                   = $getValue.localSecurityOptionsMachineInactivityLimit
                LocalSecurityOptionsMachineInactivityLimitInMinutes                          = $getValue.localSecurityOptionsMachineInactivityLimitInMinutes
                LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients             = $getValue.localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients
                LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers             = $getValue.localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers
                LocalSecurityOptionsOnlyElevateSignedExecutables                             = $getValue.localSecurityOptionsOnlyElevateSignedExecutables
                LocalSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares             = $getValue.localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares
                LocalSecurityOptionsSmartCardRemovalBehavior                                 = $getValue.localSecurityOptionsSmartCardRemovalBehavior
                LocalSecurityOptionsStandardUserElevationPromptBehavior                      = $getValue.localSecurityOptionsStandardUserElevationPromptBehavior
                LocalSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation           = $getValue.localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation
                LocalSecurityOptionsUseAdminApprovalMode                                     = $getValue.localSecurityOptionsUseAdminApprovalMode
                LocalSecurityOptionsUseAdminApprovalModeForAdministrators                    = $getValue.localSecurityOptionsUseAdminApprovalModeForAdministrators
                LocalSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $getValue.localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations
                SmartScreenBlockOverrideForFiles                                             = $getValue.smartScreenBlockOverrideForFiles
                SmartScreenEnableInShell                                                     = $getValue.smartScreenEnableInShell
                UserRightsAccessCredentialManagerAsTrustedCaller                             = $complexUserRightsAccessCredentialManagerAsTrustedCaller
                UserRightsActAsPartOfTheOperatingSystem                                      = $complexUserRightsActAsPartOfTheOperatingSystem
                UserRightsAllowAccessFromNetwork                                             = $complexUserRightsAllowAccessFromNetwork
                UserRightsBackupData                                                         = $complexUserRightsBackupData
                UserRightsBlockAccessFromNetwork                                             = $complexUserRightsBlockAccessFromNetwork
                UserRightsChangeSystemTime                                                   = $complexUserRightsChangeSystemTime
                UserRightsCreateGlobalObjects                                                = $complexUserRightsCreateGlobalObjects
                UserRightsCreatePageFile                                                     = $complexUserRightsCreatePageFile
                UserRightsCreatePermanentSharedObjects                                       = $complexUserRightsCreatePermanentSharedObjects
                UserRightsCreateSymbolicLinks                                                = $complexUserRightsCreateSymbolicLinks
                UserRightsCreateToken                                                        = $complexUserRightsCreateToken
                UserRightsDebugPrograms                                                      = $complexUserRightsDebugPrograms
                UserRightsDelegation                                                         = $complexUserRightsDelegation
                UserRightsDenyLocalLogOn                                                     = $complexUserRightsDenyLocalLogOn
                UserRightsGenerateSecurityAudits                                             = $complexUserRightsGenerateSecurityAudits
                UserRightsImpersonateClient                                                  = $complexUserRightsImpersonateClient
                UserRightsIncreaseSchedulingPriority                                         = $complexUserRightsIncreaseSchedulingPriority
                UserRightsLoadUnloadDrivers                                                  = $complexUserRightsLoadUnloadDrivers
                UserRightsLocalLogOn                                                         = $complexUserRightsLocalLogOn
                UserRightsLockMemory                                                         = $complexUserRightsLockMemory
                UserRightsManageAuditingAndSecurityLogs                                      = $complexUserRightsManageAuditingAndSecurityLogs
                UserRightsManageVolumes                                                      = $complexUserRightsManageVolumes
                UserRightsModifyFirmwareEnvironment                                          = $complexUserRightsModifyFirmwareEnvironment
                UserRightsModifyObjectLabels                                                 = $complexUserRightsModifyObjectLabels
                UserRightsProfileSingleProcess                                               = $complexUserRightsProfileSingleProcess
                UserRightsRemoteDesktopServicesLogOn                                         = $complexUserRightsRemoteDesktopServicesLogOn
                UserRightsRemoteShutdown                                                     = $complexUserRightsRemoteShutdown
                UserRightsRestoreData                                                        = $complexUserRightsRestoreData
                UserRightsTakeOwnership                                                      = $complexUserRightsTakeOwnership
                WindowsDefenderTamperProtection                                              = $getValue.windowsDefenderTamperProtection
                XboxServicesAccessoryManagementServiceStartupMode                            = $getValue.xboxServicesAccessoryManagementServiceStartupMode
                XboxServicesEnableXboxGameSaveTask                                           = $getValue.xboxServicesEnableXboxGameSaveTask
                XboxServicesLiveAuthManagerServiceStartupMode                                = $getValue.xboxServicesLiveAuthManagerServiceStartupMode
                XboxServicesLiveGameSaveServiceStartupMode                                   = $getValue.xboxServicesLiveGameSaveServiceStartupMode
                XboxServicesLiveNetworkingServiceStartupMode                                 = $getValue.xboxServicesLiveNetworkingServiceStartupMode
                Description                                                                  = $getValue.Description
                DisplayName                                                                  = $getValue.DisplayName
                Id                                                                           = $getValue.Id
                RoleScopeTagIds                                                              = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                                                       = 'Present'
                Credential                                                                   = $this.Credential
                ApplicationId                                                                = $this.ApplicationId
                TenantId                                                                     = $this.TenantId
                ApplicationSecret                                                            = $this.ApplicationSecret
                CertificateThumbprint                                                        = $this.CertificateThumbprint
                ManagedIdentity                                                              = $this.ManagedIdentity
                AccessTokens                                                                 = $this.AccessTokens
                #endregion
            }

            $returnAssignments = @()
            $graphAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $graphAssignments)
            {
                $graphAssignments = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId
            }
            if ($graphAssignments.Count -gt 0)
            {
                $returnAssignments += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($graphAssignments)
            }
            $results.Add('Assignments', $returnAssignments)

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

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Endpoint Protection Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            if ($createParameters.FirewallRules.Count -gt 0)
            {
                $intuneFirewallRules = @()
                foreach ($firewallRule in $createParameters.FirewallRules)
                {
                    if ($firewallRule.interfaceTypes -gt 1)
                    {
                        $firewallRule.interfaceTypes = $firewallRule.interfaceTypes -join ','
                    }
                    $intuneFirewallRules += $firewallRule
                }
                $createParameters.FirewallRules = $intuneFirewallRules
            }
            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windows10EndpointProtectionConfiguration')
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
            Write-Verbose -Message "Updating the Intune Device Configuration Endpoint Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            if ($updateParameters.FirewallRules.Count -gt 0)
            {
                $intuneFirewallRules = @()
                foreach ($firewallRule in $updateParameters.FirewallRules)
                {
                    if ($firewallRule.interfaceTypes -gt 1)
                    {
                        $firewallRule.interfaceTypes = $firewallRule.interfaceTypes -join ','
                    }
                    $intuneFirewallRules += $firewallRule
                }
                $updateParameters.FirewallRules = $intuneFirewallRules
            }
            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10EndpointProtectionConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Endpoint Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
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
                -ODataType 'microsoft.graph.windows10EndpointProtectionConfiguration' `
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
                    DisplayName           = $config.displayName
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
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ( $null -ne $Results.BitLockerFixedDrivePolicy)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'BitLockerFixedDrivePolicy'
                            CimInstanceName = 'MicrosoftGraphBitLockerFixedDrivePolicy'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RecoveryOptions'
                            CimInstanceName = 'MicrosoftGraphBitLockerRecoveryOptions'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.BitLockerFixedDrivePolicy `
                        -CIMInstanceName 'MicrosoftGraphbitLockerFixedDrivePolicy' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.BitLockerFixedDrivePolicy = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('BitLockerFixedDrivePolicy') | Out-Null
                    }
                }
                if ( $null -ne $Results.BitLockerRemovableDrivePolicy)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.BitLockerRemovableDrivePolicy `
                        -CIMInstanceName 'MicrosoftGraphbitLockerRemovableDrivePolicy'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.BitLockerRemovableDrivePolicy = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('BitLockerRemovableDrivePolicy') | Out-Null
                    }
                }
                if ( $null -ne $Results.BitLockerSystemDrivePolicy)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'BitLockerSystemDrivePolicy'
                            CimInstanceName = 'MicrosoftGraphBitLockerSystemDrivePolicy'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RecoveryOptions'
                            CimInstanceName = 'MicrosoftGraphBitLockerRecoveryOptions'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.BitLockerSystemDrivePolicy `
                        -CIMInstanceName 'MicrosoftGraphbitLockerSystemDrivePolicy' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.BitLockerSystemDrivePolicy = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('BitLockerSystemDrivePolicy') | Out-Null
                    }
                }
                if ( $null -ne $Results.DefenderDetectedMalwareActions)
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
                if ( $null -ne $Results.DeviceManagementApplicabilityRuleDeviceMode)
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
                if ( $null -ne $Results.DeviceManagementApplicabilityRuleOsEdition)
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
                if ( $null -ne $Results.DeviceManagementApplicabilityRuleOsVersion)
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
                if ( $null -ne $Results.FirewallProfileDomain)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FirewallProfileDomain `
                        -CIMInstanceName 'MicrosoftGraphwindowsFirewallNetworkProfile'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FirewallProfileDomain = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FirewallProfileDomain') | Out-Null
                    }
                }
                if ( $null -ne $Results.FirewallProfilePrivate)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FirewallProfilePrivate `
                        -CIMInstanceName 'MicrosoftGraphwindowsFirewallNetworkProfile'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FirewallProfilePrivate = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FirewallProfilePrivate') | Out-Null
                    }
                }
                if ( $null -ne $Results.FirewallProfilePublic)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FirewallProfilePublic `
                        -CIMInstanceName 'MicrosoftGraphwindowsFirewallNetworkProfile'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FirewallProfilePublic = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FirewallProfilePublic') | Out-Null
                    }
                }
                if ( $null -ne $Results.FirewallRules)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FirewallRules `
                        -CIMInstanceName 'MicrosoftGraphwindowsFirewallRule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FirewallRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FirewallRules') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsAccessCredentialManagerAsTrustedCaller)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsAccessCredentialManagerAsTrustedCaller'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsAccessCredentialManagerAsTrustedCaller `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsAccessCredentialManagerAsTrustedCaller = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsAccessCredentialManagerAsTrustedCaller') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsActAsPartOfTheOperatingSystem)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsActAsPartOfTheOperatingSystem'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsActAsPartOfTheOperatingSystem `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsActAsPartOfTheOperatingSystem = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsActAsPartOfTheOperatingSystem') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsAllowAccessFromNetwork)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsAllowAccessFromNetwork'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsAllowAccessFromNetwork `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsAllowAccessFromNetwork = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsAllowAccessFromNetwork') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsBackupData)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsBackupData'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsBackupData `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsBackupData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsBackupData') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsBlockAccessFromNetwork)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsBlockAccessFromNetwork'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsBlockAccessFromNetwork `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsBlockAccessFromNetwork = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsBlockAccessFromNetwork') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsChangeSystemTime)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsChangeSystemTime'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsChangeSystemTime `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsChangeSystemTime = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsChangeSystemTime') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsCreateGlobalObjects)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsCreateGlobalObjects'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsCreateGlobalObjects `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsCreateGlobalObjects = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsCreateGlobalObjects') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsCreatePageFile)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsCreatePageFile'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsCreatePageFile `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsCreatePageFile = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsCreatePageFile') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsCreatePermanentSharedObjects)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsCreatePermanentSharedObjects'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsCreatePermanentSharedObjects `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsCreatePermanentSharedObjects = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsCreatePermanentSharedObjects') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsCreateSymbolicLinks)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsCreateSymbolicLinks'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsCreateSymbolicLinks `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsCreateSymbolicLinks = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsCreateSymbolicLinks') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsCreateToken)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsCreateToken'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsCreateToken `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsCreateToken = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsCreateToken') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsDebugPrograms)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsDebugPrograms'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsDebugPrograms `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsDebugPrograms = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsDebugPrograms') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsDelegation)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsDelegation'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsDelegation `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsDelegation = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsDelegation') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsDenyLocalLogOn)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsDenyLocalLogOn'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsDenyLocalLogOn `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsDenyLocalLogOn = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsDenyLocalLogOn') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsGenerateSecurityAudits)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsGenerateSecurityAudits'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsGenerateSecurityAudits `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsGenerateSecurityAudits = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsGenerateSecurityAudits') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsImpersonateClient)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsImpersonateClient'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsImpersonateClient `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsImpersonateClient = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsImpersonateClient') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsIncreaseSchedulingPriority)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsIncreaseSchedulingPriority'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsIncreaseSchedulingPriority `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsIncreaseSchedulingPriority = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsIncreaseSchedulingPriority') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsLoadUnloadDrivers)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsLoadUnloadDrivers'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsLoadUnloadDrivers `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsLoadUnloadDrivers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsLoadUnloadDrivers') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsLocalLogOn)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsLocalLogOn'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsLocalLogOn `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsLocalLogOn = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsLocalLogOn') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsLockMemory)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsLockMemory'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsLockMemory `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsLockMemory = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsLockMemory') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsManageAuditingAndSecurityLogs)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsManageAuditingAndSecurityLogs'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsManageAuditingAndSecurityLogs `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsManageAuditingAndSecurityLogs = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsManageAuditingAndSecurityLogs') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsManageVolumes)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsManageVolumes'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsManageVolumes `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsManageVolumes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsManageVolumes') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsModifyFirmwareEnvironment)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsModifyFirmwareEnvironment'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsModifyFirmwareEnvironment `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsModifyFirmwareEnvironment = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsModifyFirmwareEnvironment') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsModifyObjectLabels)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsModifyObjectLabels'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsModifyObjectLabels `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsModifyObjectLabels = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsModifyObjectLabels') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsProfileSingleProcess)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsProfileSingleProcess'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsProfileSingleProcess `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsProfileSingleProcess = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsProfileSingleProcess') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsRemoteDesktopServicesLogOn)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsRemoteDesktopServicesLogOn'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsRemoteDesktopServicesLogOn `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsRemoteDesktopServicesLogOn = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsRemoteDesktopServicesLogOn') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsRemoteShutdown)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsRemoteShutdown'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsRemoteShutdown `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsRemoteShutdown = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsRemoteShutdown') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsRestoreData)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsRestoreData'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsRestoreData `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsRestoreData = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsRestoreData') | Out-Null
                    }
                }
                if ( $null -ne $Results.UserRightsTakeOwnership)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'UserRightsTakeOwnership'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'LocalUsersOrGroups'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserRightsTakeOwnership `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementUserRightsSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserRightsTakeOwnership = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserRightsTakeOwnership') | Out-Null
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
                    -NoEscape @('BitLockerFixedDrivePolicy', 'BitLockerRemovableDrivePolicy', 'BitLockerSystemDrivePolicy', 'DefenderDetectedMalwareActions',
                    'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition',
                    'DeviceManagementApplicabilityRuleOsVersion',
                    'FirewallProfileDomain', 'FirewallProfilePrivate', 'FirewallProfilePublic', 'FirewallRules',
                    'UserRightsAccessCredentialManagerAsTrustedCaller', 'UserRightsActAsPartOfTheOperatingSystem', 'UserRightsAllowAccessFromNetwork',
                    'UserRightsBackupData', 'UserRightsBlockAccessFromNetwork', 'UserRightsChangeSystemTime', 'UserRightsCreateGlobalObjects',
                    'UserRightsCreatePageFile', 'UserRightsCreatePermanentSharedObjects', 'UserRightsCreateSymbolicLinks', 'UserRightsCreateToken',
                    'UserRightsDebugPrograms', 'UserRightsDelegation', 'UserRightsDenyLocalLogOn', 'UserRightsGenerateSecurityAudits',
                    'UserRightsImpersonateClient', 'UserRightsIncreaseSchedulingPriority', 'UserRightsLoadUnloadDrivers', 'UserRightsLocalLogOn',
                    'UserRightsLockMemory', 'UserRightsManageAuditingAndSecurityLogs', 'UserRightsManageVolumes', 'UserRightsModifyFirmwareEnvironment',
                    'UserRightsModifyObjectLabels', 'UserRightsProfileSingleProcess', 'UserRightsRemoteDesktopServicesLogOn', 'UserRightsRemoteShutdown',
                    'UserRightsRestoreData', 'UserRightsTakeOwnership', 'Assignments') `
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

    hidden [IntuneDeviceConfigurationEndpointProtectionPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationEndpointProtectionPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationEndpointProtectionPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphbitLockerFixedDrivePolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for fixed drives. Possible values are: aesCbc128, aesCbc256, xtsAes128, xtsAes256.')]
    [ValidateSet('aesCbc128', 'aesCbc256', 'xtsAes128', 'xtsAes256')]
    [System.String] $EncryptionMethod

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows you to control how BitLocker-protected fixed data drives are recovered in the absence of the required credentials. This policy setting is applied when you turn on BitLocker.')]
    [MSFT_MicrosoftGraphBitLockerRecoveryOptions] $RecoveryOptions

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting determines whether BitLocker protection is required for fixed data drives to be writable on a computer.')]
    [System.Nullable[System.Boolean]] $RequireEncryptionForWriteAccess
}

class MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('This policy setting determines whether BitLocker protection is required for removable data drives to be writable on a computer.')]
    [System.Nullable[System.Boolean]] $BlockCrossOrganizationWriteAccess

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for removable  drives. Possible values are: aesCbc128, aesCbc256, xtsAes128, xtsAes256.')]
    [ValidateSet('aesCbc128', 'aesCbc256', 'xtsAes128', 'xtsAes256')]
    [System.String] $EncryptionMethod

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to block write access to devices configured in another organization.  If requireEncryptionForWriteAccess is false, this value does not affect.')]
    [System.Nullable[System.Boolean]] $RequireEncryptionForWriteAccess
}

class MSFT_MicrosoftGraphbitLockerSystemDrivePolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for operating system drives. Possible values are: aesCbc128, aesCbc256, xtsAes128, xtsAes256.')]
    [ValidateSet('aesCbc128', 'aesCbc256', 'xtsAes128', 'xtsAes256')]
    [System.String] $EncryptionMethod

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum length of startup pin. Valid values 4 to 20')]
    [System.Nullable[System.UInt32]] $MinimumPinLength

    [DscProperty()]
    [System.ComponentModel.Description('Enable pre-boot recovery message and Url. If requireStartupAuthentication is false, this value does not affect.')]
    [System.Nullable[System.Boolean]] $PrebootRecoveryEnableMessageAndUrl

    [DscProperty()]
    [System.ComponentModel.Description('Defines a custom recovery message.')]
    [System.String] $PrebootRecoveryMessage

    [DscProperty()]
    [System.ComponentModel.Description('Defines a custom recovery URL.')]
    [System.String] $PrebootRecoveryUrl

    [DscProperty()]
    [System.ComponentModel.Description('Allows to recover BitLocker encrypted operating system drives in the absence of the required startup key information. This policy setting is applied when you turn on BitLocker.')]
    [MSFT_MicrosoftGraphBitLockerRecoveryOptions] $RecoveryOptions

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to allow BitLocker without a compatible TPM (requires a password or a startup key on a USB flash drive).')]
    [System.Nullable[System.Boolean]] $StartupAuthenticationBlockWithoutTpmChip

    [DscProperty()]
    [System.ComponentModel.Description('Require additional authentication at startup.')]
    [System.Nullable[System.Boolean]] $StartupAuthenticationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if TPM startup key is allowed/required/disallowed. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $StartupAuthenticationTpmKeyUsage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if TPM startup pin key and key are allowed/required/disallowed. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $StartupAuthenticationTpmPinAndKeyUsage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if TPM startup pin is allowed/required/disallowed. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $StartupAuthenticationTpmPinUsage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if TPM startup is allowed/required/disallowed. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $StartupAuthenticationTpmUsage
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

class MSFT_MicrosoftGraphwindowsFirewallNetworkProfile
{
    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to merge authorized application rules from group policy with those from local store instead of ignoring the local store rules. When AuthorizedApplicationRulesFromGroupPolicyNotMerged and AuthorizedApplicationRulesFromGroupPolicyMerged are both true, AuthorizedApplicationRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $AuthorizedApplicationRulesFromGroupPolicyMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to prevent merging authorized application rules from group policy with those from local store instead of ignoring the local store rules. When AuthorizedApplicationRulesFromGroupPolicyNotMerged and AuthorizedApplicationRulesFromGroupPolicyMerged are both true, AuthorizedApplicationRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $AuthorizedApplicationRulesFromGroupPolicyNotMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to merge connection security rules from group policy with those from local store instead of ignoring the local store rules. When ConnectionSecurityRulesFromGroupPolicyNotMerged and ConnectionSecurityRulesFromGroupPolicyMerged are both true, ConnectionSecurityRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $ConnectionSecurityRulesFromGroupPolicyMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to prevent merging connection security rules from group policy with those from local store instead of ignoring the local store rules. When ConnectionSecurityRulesFromGroupPolicyNotMerged and ConnectionSecurityRulesFromGroupPolicyMerged are both true, ConnectionSecurityRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $ConnectionSecurityRulesFromGroupPolicyNotMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the host device to allow or block the firewall and advanced security enforcement for the network profile. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $FirewallEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to merge global port rules from group policy with those from local store instead of ignoring the local store rules. When GlobalPortRulesFromGroupPolicyNotMerged and GlobalPortRulesFromGroupPolicyMerged are both true, GlobalPortRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $GlobalPortRulesFromGroupPolicyMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to prevent merging global port rules from group policy with those from local store instead of ignoring the local store rules. When GlobalPortRulesFromGroupPolicyNotMerged and GlobalPortRulesFromGroupPolicyMerged are both true, GlobalPortRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $GlobalPortRulesFromGroupPolicyNotMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to block all incoming connections by default. When InboundConnectionsRequired and InboundConnectionsBlocked are both true, InboundConnectionsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $InboundConnectionsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to allow all incoming connections by default. When InboundConnectionsRequired and InboundConnectionsBlocked are both true, InboundConnectionsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $InboundConnectionsRequired

    [DscProperty()]
    [System.ComponentModel.Description('Prevents the firewall from displaying notifications when an application is blocked from listening on a port. When InboundNotificationsRequired and InboundNotificationsBlocked are both true, InboundNotificationsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $InboundNotificationsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Allows the firewall to display notifications when an application is blocked from listening on a port. When InboundNotificationsRequired and InboundNotificationsBlocked are both true, InboundNotificationsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $InboundNotificationsRequired

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to block all incoming traffic regardless of other policy settings. When IncomingTrafficRequired and IncomingTrafficBlocked are both true, IncomingTrafficBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $IncomingTrafficBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to allow incoming traffic pursuant to other policy settings. When IncomingTrafficRequired and IncomingTrafficBlocked are both true, IncomingTrafficBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $IncomingTrafficRequired

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to block all outgoing connections by default. When OutboundConnectionsRequired and OutboundConnectionsBlocked are both true, OutboundConnectionsBlocked takes priority. This setting will get applied to Windows releases version 1809 and above.')]
    [System.Nullable[System.Boolean]] $OutboundConnectionsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to allow all outgoing connections by default. When OutboundConnectionsRequired and OutboundConnectionsBlocked are both true, OutboundConnectionsBlocked takes priority. This setting will get applied to Windows releases version 1809 and above.')]
    [System.Nullable[System.Boolean]] $OutboundConnectionsRequired

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to merge Firewall Rule policies from group policy with those from local store instead of ignoring the local store rules. When PolicyRulesFromGroupPolicyNotMerged and PolicyRulesFromGroupPolicyMerged are both true, PolicyRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $PolicyRulesFromGroupPolicyMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to prevent merging Firewall Rule policies from group policy with those from local store instead of ignoring the local store rules. When PolicyRulesFromGroupPolicyNotMerged and PolicyRulesFromGroupPolicyMerged are both true, PolicyRulesFromGroupPolicyMerged takes priority.')]
    [System.Nullable[System.Boolean]] $PolicyRulesFromGroupPolicyNotMerged

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to allow the host computer to respond to unsolicited network traffic of that traffic is secured by IPSec even when stealthModeBlocked is set to true. When SecuredPacketExemptionBlocked and SecuredPacketExemptionAllowed are both true, SecuredPacketExemptionAllowed takes priority.')]
    [System.Nullable[System.Boolean]] $SecuredPacketExemptionAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to block the host computer to respond to unsolicited network traffic of that traffic is secured by IPSec even when stealthModeBlocked is set to true. When SecuredPacketExemptionBlocked and SecuredPacketExemptionAllowed are both true, SecuredPacketExemptionAllowed takes priority.')]
    [System.Nullable[System.Boolean]] $SecuredPacketExemptionBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Prevent the server from operating in stealth mode. When StealthModeRequired and StealthModeBlocked are both true, StealthModeBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $StealthModeBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Allow the server to operate in stealth mode. When StealthModeRequired and StealthModeBlocked are both true, StealthModeBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $StealthModeRequired

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to block unicast responses to multicast broadcast traffic. When UnicastResponsesToMulticastBroadcastsRequired and UnicastResponsesToMulticastBroadcastsBlocked are both true, UnicastResponsesToMulticastBroadcastsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $UnicastResponsesToMulticastBroadcastsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures the firewall to allow unicast responses to multicast broadcast traffic. When UnicastResponsesToMulticastBroadcastsRequired and UnicastResponsesToMulticastBroadcastsBlocked are both true, UnicastResponsesToMulticastBroadcastsBlocked takes priority.')]
    [System.Nullable[System.Boolean]] $UnicastResponsesToMulticastBroadcastsRequired
}

class MSFT_MicrosoftGraphwindowsFirewallRule
{
    [DscProperty()]
    [System.ComponentModel.Description('The action the rule enforces. If not specified, the default is Allowed. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('The description of the rule.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the rule. Does not need to be unique.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether edge traversal is enabled or disabled for this rule. The EdgeTraversal setting indicates that specific inbound traffic is allowed to tunnel through NATs and other edge devices using the Teredo tunneling technology. In order for this setting to work correctly, the application or service with the inbound firewall rule needs to support IPv6. The primary application of this setting allows listeners on the host to be globally addressable through a Teredo IPv6 address. New rules have the EdgeTraversal property disabled by default. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $EdgeTraversal

    [DscProperty()]
    [System.ComponentModel.Description('The full file path of an app that''s affected by the firewall rule.')]
    [System.String] $FilePath

    [DscProperty()]
    [System.ComponentModel.Description('The interface types of the rule. Possible values are: notConfigured, remoteAccess, wireless, lan.')]
    [ValidateSet('notConfigured', 'remoteAccess', 'wireless', 'lan')]
    [System.String[]] $InterfaceTypes

    [DscProperty()]
    [System.ComponentModel.Description('List of local addresses covered by the rule. Default is any address. Valid tokens include:'''' indicates any local address. If present, this must be the only token included.A subnet can be specified using either the subnet mask or network prefix notation. If neither a subnet mask nor a network prefix is specified, the subnet mask defaults to 255.255.255.255.A valid IPv6 address.An IPv4 address range in the format of ''start address - end address'' with no spaces included.An IPv6 address range in the format of ''start address - end address'' with no spaces included.')]
    [System.String[]] $LocalAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('List of local port ranges. For example, ''100-120'', ''200'', ''300-320''. If not specified, the default is All.')]
    [System.String[]] $LocalPortRanges

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the list of authorized local users for the app container. This is a string in Security Descriptor Definition Language (SDDL) format.')]
    [System.String] $LocalUserAuthorizations

    [DscProperty()]
    [System.ComponentModel.Description('The package family name of a Microsoft Store application that''s affected by the firewall rule.')]
    [System.String] $PackageFamilyName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the profiles to which the rule belongs. If not specified, the default is All. Possible values are: notConfigured, domain, private, public.')]
    [System.String] $ProfileTypes

    [DscProperty()]
    [System.ComponentModel.Description('0-255 number representing the IP protocol (TCP = 6, UDP = 17). If not specified, the default is All. Valid values 0 to 255')]
    [System.Nullable[System.UInt32]] $Protocol

    [DscProperty()]
    [System.ComponentModel.Description('List of tokens specifying the remote addresses covered by the rule. Tokens are case insensitive. Default is any address. Valid tokens include:'''' indicates any remote address. If present, this must be the only token included.''Defaultgateway''''DHCP''''DNS''''WINS''''Intranet'' (supported on Windows versions 1809+)''RmtIntranet'' (supported on Windows versions 1809+)''Internet'' (supported on Windows versions 1809+)''Ply2Renders'' (supported on Windows versions 1809+)''LocalSubnet'' indicates any local address on the local subnet.A subnet can be specified using either the subnet mask or network prefix notation. If neither a subnet mask nor a network prefix is specified, the subnet mask defaults to 255.255.255.255.A valid IPv6 address.An IPv4 address range in the format of ''start address - end address'' with no spaces included.An IPv6 address range in the format of ''start address - end address'' with no spaces included.')]
    [System.String[]] $RemoteAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('List of remote port ranges. For example, ''100-120'', ''200'', ''300-320''. If not specified, the default is All.')]
    [System.String[]] $RemotePortRanges

    [DscProperty()]
    [System.ComponentModel.Description('The name used in cases when a service, not an application, is sending or receiving traffic.')]
    [System.String] $ServiceName

    [DscProperty()]
    [System.ComponentModel.Description('The traffic direction that the rule is enabled for. If not specified, the default is Out. Possible values are: notConfigured, out, in.')]
    [ValidateSet('notConfigured', 'out', 'in')]
    [System.String] $TrafficDirection
}

class MSFT_MicrosoftGraphdeviceManagementUserRightsSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Representing a collection of local users or groups which will be set on device if the state of this setting is Allowed. This collection can contain a maximum of 500 elements.')]
    [MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup[]] $LocalUsersOrGroups

    [DscProperty()]
    [System.ComponentModel.Description('Representing the current state of this user rights setting. Possible values are: notConfigured, blocked, allowed.')]
    [ValidateSet('notConfigured', 'blocked', 'allowed')]
    [System.String] $State
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

class MSFT_MicrosoftGraphBitLockerRecoveryOptions
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to block certificate-based data recovery agent.')]
    [System.Nullable[System.Boolean]] $BlockDataRecoveryAgent

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to enable BitLocker until recovery information is stored in AD DS.')]
    [System.Nullable[System.Boolean]] $EnableBitLockerAfterRecoveryInformationToStore

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow BitLocker recovery information to store in AD DS.')]
    [System.Nullable[System.Boolean]] $EnableRecoveryInformationSaveToStore

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to allow showing recovery options in BitLocker Setup Wizard for fixed or system disk.')]
    [System.Nullable[System.Boolean]] $HideRecoveryOptions

    [DscProperty()]
    [System.ComponentModel.Description('Configure what pieces of BitLocker recovery information are stored to AD DS. Possible values are: passwordAndKey, passwordOnly.')]
    [ValidateSet('passwordAndKey', 'passwordOnly')]
    [System.String] $RecoveryInformationToStore

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether users are allowed or required to generate a 256-bit recovery key for fixed or system disk. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $RecoveryKeyUsage

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether users are allowed or required to generate a 48-digit recovery password for fixed or system disk. Possible values are: blocked, required, allowed, notConfigured.')]
    [ValidateSet('blocked', 'required', 'allowed', 'notConfigured')]
    [System.String] $RecoveryPasswordUsage
}

class MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup
{
    [DscProperty()]
    [System.ComponentModel.Description('Admins description of this local user or group.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The name of this local user or group.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The security identifier of this local user or group (e.g. S-1-5-32-544).')]
    [System.String] $SecurityIdentifier
}
