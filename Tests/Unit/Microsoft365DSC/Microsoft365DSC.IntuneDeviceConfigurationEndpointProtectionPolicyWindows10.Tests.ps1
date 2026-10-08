[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "IntuneDeviceConfigurationEndpointProtectionPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin@onmicrosoft.com", $secpasswd)

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

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    localSecurityOptionsClearVirtualMemoryPageFile = $True
                    defenderSecurityCenterDisableHardwareUI = $True
                    applicationGuardAllowPrintToNetworkPrinters = $True
                    defenderFilesAndFoldersToExclude = @("FakeStringValue")
                    defenderAllowScanArchiveFiles = $True
                    firewallIPSecExemptionsNone = $True
                    bitLockerAllowStandardUserEncryption = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager = "FakeStringValue"
                    defenderScheduledScanDay = "userDefined"
                    firewallPacketQueueingMethod = "deviceDefault"
                    defenderUntrustedUSBProcessType = "userDefined"
                    defenderNetworkProtectionType = "userDefined"
                    defenderProcessCreation = "userDefined"
                    applicationGuardEnabledOptions = "notConfigured"
                    defenderOfficeAppsLaunchChildProcess = "userDefined"
                    defenderAllowRealTimeMonitoring = $True
                    firewallIPSecExemptionsAllowNeighborDiscovery = $True
                    defenderUntrustedExecutable = "userDefined"
                    defenderGuardMyFoldersType = "userDefined"
                    localSecurityOptionsInformationDisplayedOnLockScreen = "notConfigured"
                    defenderScheduledQuickScanTime = "00:00:00"
                    localSecurityOptionsUseAdminApprovalMode = $True
                    applicationGuardAllowCameraMicrophoneRedirection = $True
                    applicationGuardAllowPrintToXPS = $True
                    deviceGuardLaunchSystemGuard = "notConfigured"
                    defenderScanDirection = "monitorAllFiles"
                    userRightsIncreaseSchedulingPriority = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    deviceGuardEnableVirtualizationBasedSecurity = $True
                    defenderBlockEndUserAccess = $True
                    firewallIPSecExemptionsAllowRouterDiscovery = $True
                    xboxServicesLiveGameSaveServiceStartupMode = "manual"
                    bitLockerFixedDrivePolicy = @{
                        RecoveryOptions = @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        }
                        RequireEncryptionForWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    }
                    userRightsCreateSymbolicLinks = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    applicationGuardBlockFileTransfer = "notConfigured"
                    defenderCheckForSignaturesBeforeRunningScan = $True
                    userRightsRemoteShutdown = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    firewallRules = @(
                        @{
                            localAddressRanges = @("FakeStringValue")
                            action = "notConfigured"
                            description = "FakeStringValue"
                            interfaceTypes = "notConfigured"
                            remotePortRanges = @("FakeStringValue")
                            displayName = "FakeStringValue"
                            filePath = "FakeStringValue"
                            localUserAuthorizations = "FakeStringValue"
                            protocol = 25
                            trafficDirection = "notConfigured"
                            remoteAddressRanges = @("FakeStringValue")
                            packageFamilyName = "FakeStringValue"
                            serviceName = "FakeStringValue"
                            localPortRanges = @("FakeStringValue")
                            profileTypes = "notConfigured"
                            edgeTraversal = "notConfigured"
                        }
                    )
                    defenderSignatureUpdateIntervalInHours = 25
                    defenderEnableLowCpuPriority = $True
                    localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares = $True
                    defenderFileExtensionsToExclude = @("FakeStringValue")
                    localSecurityOptionsHideLastSignedInUser = $True
                    userRightsBlockAccessFromNetwork = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers = "none"
                    xboxServicesLiveAuthManagerServiceStartupMode = "manual"
                    localSecurityOptionsMachineInactivityLimitInMinutes = 25
                    localSecurityOptionsClientDigitallySignCommunicationsAlways = $True
                    defenderSecurityCenterDisableNetworkUI = $True
                    userRightsModifyObjectLabels = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    deviceGuardLocalSystemAuthorityCredentialGuardSettings = "notConfigured"
                    firewallIdleTimeoutForSecurityAssociationInSeconds = 25
                    defenderSecurityCenterHelpURL = "FakeStringValue"
                    localSecurityOptionsDisableServerDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool = $True
                    userRightsChangeSystemTime = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsAllowUndockWithoutHavingToLogon = $True
                    defenderEnableScanMappedNetworkDrivesDuringFullScan = $True
                    defenderUntrustedUSBProcess = "userDefined"
                    localSecurityOptionsHideUsernameAtSignIn = $True
                    defenderAllowScanDownloads = $True
                    localSecurityOptionsDisableAdministratorAccount = $True
                    defenderSecurityCenterDisableHealthUI = $True
                    userRightsCreateGlobalObjects = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares = $True
                    localSecurityOptionsMachineInactivityLimit = 25
                    firewallCertificateRevocationListCheckMethod = "deviceDefault"
                    defenderSecurityCenterDisableFamilyUI = $True
                    defenderAllowCloudProtection = $True
                    bitLockerEnableStorageCardEncryptionOnMobile = $True
                    applicationGuardEnabled = $True
                    defenderOfficeAppsOtherProcessInjection = "userDefined"
                    userRightsImpersonateClient = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    '@odata.type' = "#microsoft.graph.windows10EndpointProtectionConfiguration"
                    localSecurityOptionsUseAdminApprovalModeForAdministrators = $True
                    lanManagerWorkstationDisableInsecureGuestLogons = $True
                    defenderAdvancedRansomewareProtectionType = "userDefined"
                    defenderUntrustedExecutableType = "userDefined"
                    defenderDisableScanArchiveFiles = $True
                    lanManagerAuthenticationLevel = "lmAndNltm"
                    userRightsActAsPartOfTheOperatingSystem = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderPreventCredentialStealingType = "userDefined"
                    localSecurityOptionsAllowUIAccessApplicationsForSecureLocations = $True
                    deviceGuardEnableSecureBootWithDMA = $True
                    localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees = $True
                    defenderScriptObfuscatedMacroCode = "userDefined"
                    defenderDaysBeforeDeletingQuarantinedMalware = 25
                    defenderAllowScanRemovableDrivesDuringFullScan = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees = $True
                    firewallProfilePrivate = @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    }
                    defenderSecurityCenterDisableAppBrowserUI = $True
                    localSecurityOptionsInformationShownOnLockScreen = "notConfigured"
                    defenderOfficeAppsLaunchChildProcessType = "userDefined"
                    deviceGuardSecureBootWithDMA = "notConfigured"
                    deviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    deviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    deviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "FakeStringValue"
                        MaxOSVersion = "FakeStringValue"
                        RuleType = "include"
                    }
                    applicationGuardAllowPrintToPDF = $True
                    userRightsCreateToken = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderExploitProtectionXml = $True
                    userRightsRemoteDesktopServicesLogOn = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsBlockRemoteLogonWithBlankPassword = $True
                    userRightsBackupData = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    userRightsDenyLocalLogOn = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsOnlyElevateSignedExecutables = $True
                    applicationGuardAllowVirtualGPU = $True
                    defenderScanType = "userDefined"
                    bitLockerSystemDrivePolicy = @{
                        prebootRecoveryEnableMessageAndUrl = $True
                        StartupAuthenticationTpmPinUsage = "blocked"
                        encryptionMethod = "aesCbc128"
                        minimumPinLength = 25
                        prebootRecoveryMessage = "FakeStringValue"
                        StartupAuthenticationTpmPinAndKeyUsage = "blocked"
                        StartupAuthenticationRequired = $True
                        RecoveryOptions = @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        }
                        prebootRecoveryUrl = "FakeStringValue"
                        StartupAuthenticationTpmUsage = "blocked"
                        StartupAuthenticationTpmKeyUsage = "blocked"
                        StartupAuthenticationBlockWithoutTpmChip = $True
                    }
                    defenderAllowBehaviorMonitoring = $True
                    defenderAllowIntrusionPreventionSystem = $True
                    localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange = $True
                    defenderSecurityCenterHelpEmail = "FakeStringValue"
                    defenderDisableBehaviorMonitoring = $True
                    localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $True
                    applicationGuardBlockClipboardSharing = "notConfigured"
                    defenderEmailContentExecution = "userDefined"
                    localSecurityOptionsBlockRemoteOpticalDriveAccess = $True
                    firewallProfilePublic = @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    }
                    defenderScriptDownloadedPayloadExecutionType = "userDefined"
                    xboxServicesAccessoryManagementServiceStartupMode = "manual"
                    xboxServicesEnableXboxGameSaveTask = $True
                    bitLockerEncryptDevice = $True
                    localSecurityOptionsBlockMicrosoftAccounts = $True
                    bitLockerRemovableDrivePolicy = @{
                        requireEncryptionForWriteAccess = $True
                        blockCrossOrganizationWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    }
                    defenderSecurityCenterBlockExploitProtectionOverride = $True
                    localSecurityOptionsLogOnMessageText = "FakeStringValue"
                    applicationGuardCertificateThumbprints = @("FakeStringValue")
                    defenderCloudBlockLevel = "notConfigured"
                    defenderProcessCreationType = "userDefined"
                    defenderDisableScanDownloads = $True
                    defenderOfficeCommunicationAppsLaunchChildProcess = "userDefined"
                    localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers = $True
                    userRightsAllowAccessFromNetwork = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    applicationGuardForceAuditing = $True
                    defenderDisableRealTimeMonitoring = $True
                    defenderSecurityCenterNotificationsFromApp = "notConfigured"
                    localSecurityOptionsAdministratorAccountName = "FakeStringValue"
                    windowsDefenderTamperProtection = "notConfigured"
                    defenderSecurityCenterDisableAccountUI = $True
                    localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation = $True
                    defenderEmailContentExecutionType = "userDefined"
                    defenderAllowScanNetworkFiles = $True
                    defenderSecurityCenterDisableNotificationAreaUI = $True
                    userRightsProfileSingleProcess = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsSmartCardRemovalBehavior = "noAction"
                    defenderDisableCloudProtection = $True
                    userRightsManageVolumes = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    smartScreenEnableInShell = $True
                    applicationGuardBlockNonEnterpriseContent = $True
                    defenderAdditionalGuardedFolders = @("FakeStringValue")
                    localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts = $True
                    userRightsRestoreData = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients = "none"
                    defenderDisableOnAccessProtection = $True
                    bitLockerRecoveryPasswordRotation = "notConfigured"
                    firewallPreSharedKeyEncodingMethod = "deviceDefault"
                    userRightsDelegation = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    userRightsDebugPrograms = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI = $True
                    defenderSecurityCenterOrganizationDisplayName = "FakeStringValue"
                    localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser = "notConfigured"
                    userRightsLockMemory = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    appLockerApplicationControl = "notConfigured"
                    defenderBlockPersistenceThroughWmiType = "userDefined"
                    defenderDisableScanNetworkFiles = $True
                    defenderDisableCatchupQuickScan = $True
                    localSecurityOptionsLogOnMessageTitle = "FakeStringValue"
                    localSecurityOptionsStandardUserElevationPromptBehavior = "notConfigured"
                    userRightsGenerateSecurityAudits = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderSecurityCenterDisableClearTpmUI = $True
                    defenderEnableScanIncomingMail = $True
                    defenderSecurityCenterHelpPhone = "FakeStringValue"
                    localSecurityOptionsDoNotRequireCtrlAltDel = $True
                    userRightsTakeOwnership = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    userRightsLocalLogOn = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    applicationGuardAllowPersistence = $True
                    defenderCloudExtendedTimeoutInSeconds = 25
                    firewallIPSecExemptionsAllowICMP = $True
                    defenderAllowEndUserAccess = $True
                    defenderScriptDownloadedPayloadExecution = "userDefined"
                    defenderExploitProtectionXmlFileName = "FakeStringValue"
                    defenderScriptObfuscatedMacroCodeType = "userDefined"
                    defenderDisableScanRemovableDrivesDuringFullScan = $True
                    localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn = $True
                    defenderOfficeMacroCodeAllowWin32ImportsType = "userDefined"
                    firewallIPSecExemptionsAllowDHCP = $True
                    firewallProfileDomain = @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    }
                    localSecurityOptionsAllowPKU2UAuthenticationRequests = $True
                    defenderSecurityCenterDisableTroubleshootingUI = $True
                    defenderPotentiallyUnwantedAppAction = "userDefined"
                    userRightsModifyFirmwareEnvironment = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderOfficeAppsExecutableContentCreationOrLaunch = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunchType = "userDefined"
                    defenderSubmitSamplesConsentType = "sendSafeSamplesAutomatically"
                    defenderAdobeReaderLaunchChildProcess = "userDefined"
                    localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation = $True
                    defenderDisableIntrusionPreventionSystem = $True
                    defenderDisableCatchupFullScan = $True
                    bitLockerDisableWarningForOtherDiskEncryption = $True
                    xboxServicesLiveNetworkingServiceStartupMode = "manual"
                    firewallBlockStatefulFTP = $True
                    firewallMergeKeyingModuleSettings = $True
                    userRightsManageAuditingAndSecurityLogs = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    userRightsCreatePermanentSharedObjects = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsBlockUsersInstallingPrinterDrivers = $True
                    smartScreenBlockOverrideForFiles = $True
                    userRightsCreatePageFile = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderAllowOnAccessProtection = $True
                    dmaGuardDeviceEnumerationPolicy = "deviceDefault"
                    defenderOfficeAppsOtherProcessInjectionType = "userDefined"
                    localSecurityOptionsGuestAccountName = "FakeStringValue"
                    defenderDetectedMalwareActions = @{
                        lowSeverity = "deviceDefault"
                        severeSeverity = "deviceDefault"
                        moderateSeverity = "deviceDefault"
                        highSeverity = "deviceDefault"
                    }
                    defenderProcessesToExclude = @("FakeStringValue")
                    defenderScheduledScanTime = "00:00:00"
                    defenderSecurityCenterDisableSecureBootUI = $True
                    applicationGuardAllowFileSaveOnHost = $True
                    localSecurityOptionsDisableGuestAccount = $True
                    defenderSecurityCenterDisableRansomwareUI = $True
                    defenderGuardedFoldersAllowedAppPaths = @("FakeStringValue")
                    defenderOfficeMacroCodeAllowWin32Imports = "userDefined"
                    applicationGuardAllowPrintToLocalPrinters = $True
                    defenderSecurityCenterITContactDisplay = "notConfigured"
                    defenderAttackSurfaceReductionExcludedPaths = @("FakeStringValue")
                    defenderAllowScanScriptsLoadedInInternetExplorer = $True
                    defenderSecurityCenterDisableVirusUI = $True
                    userRightsAccessCredentialManagerAsTrustedCaller = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    localSecurityOptionsAllowUIAccessApplicationElevation = $True
                    defenderDisableScanScriptsLoadedInInternetExplorer = $True
                    localSecurityOptionsAdministratorElevationPromptBehavior = "notConfigured"
                    userRightsLoadUnloadDrivers = @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            }
                        )
                    }
                    defenderScanMaxCpuPercentage = 25
                    description = "FakeStringValue"
                    displayName = "FakeStringValue"
                    id = "FakeStringValue"
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationGuardAllowCameraMicrophoneRedirection = $True
                    ApplicationGuardAllowFileSaveOnHost = $True
                    ApplicationGuardAllowPersistence = $True
                    ApplicationGuardAllowPrintToLocalPrinters = $True
                    ApplicationGuardAllowPrintToNetworkPrinters = $True
                    ApplicationGuardAllowPrintToPDF = $True
                    ApplicationGuardAllowPrintToXPS = $True
                    ApplicationGuardAllowVirtualGPU = $True
                    ApplicationGuardBlockClipboardSharing = "notConfigured"
                    ApplicationGuardBlockFileTransfer = "notConfigured"
                    ApplicationGuardBlockNonEnterpriseContent = $True
                    ApplicationGuardCertificateThumbprints = @("FakeStringValue")
                    ApplicationGuardEnabled = $True
                    ApplicationGuardEnabledOptions = "notConfigured"
                    ApplicationGuardForceAuditing = $True
                    AppLockerApplicationControl = "notConfigured"
                    BitLockerAllowStandardUserEncryption = $True
                    BitLockerDisableWarningForOtherDiskEncryption = $True
                    BitLockerEnableStorageCardEncryptionOnMobile = $True
                    BitLockerEncryptDevice = $True
                    bitLockerFixedDrivePolicy = ([MSFT_MicrosoftGraphbitLockerFixedDrivePolicy] @{
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        RequireEncryptionForWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerRecoveryPasswordRotation = "notConfigured"
                    bitLockerRemovableDrivePolicy = ([MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy] @{
                        requireEncryptionForWriteAccess = $True
                        blockCrossOrganizationWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerSystemDrivePolicy = ([MSFT_MicrosoftGraphbitLockerSystemDrivePolicy] @{
                        prebootRecoveryEnableMessageAndUrl = $True
                        StartupAuthenticationTpmPinUsage = "blocked"
                        encryptionMethod = "aesCbc128"
                        minimumPinLength = 25
                        prebootRecoveryMessage = "FakeStringValue"
                        StartupAuthenticationTpmPinAndKeyUsage = "blocked"
                        StartupAuthenticationRequired = $True
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        prebootRecoveryUrl = "FakeStringValue"
                        StartupAuthenticationTpmUsage = "blocked"
                        StartupAuthenticationTpmKeyUsage = "blocked"
                        StartupAuthenticationBlockWithoutTpmChip = $True
                    })
                    defenderAdditionalGuardedFolders = @("FakeStringValue")
                    defenderAdobeReaderLaunchChildProcess = "userDefined"
                    defenderAdvancedRansomewareProtectionType = "userDefined"
                    defenderAllowBehaviorMonitoring = $True
                    defenderAllowCloudProtection = $True
                    defenderAllowEndUserAccess = $True
                    defenderAllowIntrusionPreventionSystem = $True
                    defenderAllowOnAccessProtection = $True
                    defenderAllowRealTimeMonitoring = $True
                    defenderAllowScanArchiveFiles = $True
                    defenderAllowScanDownloads = $True
                    defenderAllowScanNetworkFiles = $True
                    defenderAllowScanRemovableDrivesDuringFullScan = $True
                    defenderAllowScanScriptsLoadedInInternetExplorer = $True
                    defenderAttackSurfaceReductionExcludedPaths = @("FakeStringValue")
                    defenderBlockEndUserAccess = $True
                    defenderBlockPersistenceThroughWmiType = "userDefined"
                    defenderCheckForSignaturesBeforeRunningScan = $True
                    defenderCloudBlockLevel = "notConfigured"
                    defenderCloudExtendedTimeoutInSeconds = 25
                    defenderDaysBeforeDeletingQuarantinedMalware = 25
                    defenderDetectedMalwareActions = ([MSFT_MicrosoftGraphdefenderDetectedMalwareActions] @{
                        lowSeverity = "deviceDefault"
                        severeSeverity = "deviceDefault"
                        moderateSeverity = "deviceDefault"
                        highSeverity = "deviceDefault"
                    })
                    defenderDisableBehaviorMonitoring = $True
                    defenderDisableCatchupFullScan = $True
                    defenderDisableCatchupQuickScan = $True
                    defenderDisableCloudProtection = $True
                    defenderDisableIntrusionPreventionSystem = $True
                    defenderDisableOnAccessProtection = $True
                    defenderDisableRealTimeMonitoring = $True
                    defenderDisableScanArchiveFiles = $True
                    defenderDisableScanDownloads = $True
                    defenderDisableScanNetworkFiles = $True
                    defenderDisableScanRemovableDrivesDuringFullScan = $True
                    defenderDisableScanScriptsLoadedInInternetExplorer = $True
                    defenderEmailContentExecution = "userDefined"
                    defenderEmailContentExecutionType = "userDefined"
                    defenderEnableLowCpuPriority = $True
                    defenderEnableScanIncomingMail = $True
                    defenderEnableScanMappedNetworkDrivesDuringFullScan = $True
                    defenderExploitProtectionXml = $True
                    defenderExploitProtectionXmlFileName = "FakeStringValue"
                    defenderFileExtensionsToExclude = @("FakeStringValue")
                    defenderFilesAndFoldersToExclude = @("FakeStringValue")
                    defenderGuardedFoldersAllowedAppPaths = @("FakeStringValue")
                    defenderGuardMyFoldersType = "userDefined"
                    defenderNetworkProtectionType = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunch = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunchType = "userDefined"
                    defenderOfficeAppsLaunchChildProcess = "userDefined"
                    defenderOfficeAppsLaunchChildProcessType = "userDefined"
                    defenderOfficeAppsOtherProcessInjection = "userDefined"
                    defenderOfficeAppsOtherProcessInjectionType = "userDefined"
                    defenderOfficeCommunicationAppsLaunchChildProcess = "userDefined"
                    defenderOfficeMacroCodeAllowWin32Imports = "userDefined"
                    defenderOfficeMacroCodeAllowWin32ImportsType = "userDefined"
                    defenderPotentiallyUnwantedAppAction = "userDefined"
                    defenderPreventCredentialStealingType = "userDefined"
                    defenderProcessCreation = "userDefined"
                    defenderProcessCreationType = "userDefined"
                    defenderProcessesToExclude = @("FakeStringValue")
                    defenderScanDirection = "monitorAllFiles"
                    defenderScanMaxCpuPercentage = 25
                    defenderScanType = "userDefined"
                    defenderScheduledQuickScanTime = "00:00:00"
                    defenderScheduledScanDay = "userDefined"
                    defenderScheduledScanTime = "00:00:00"
                    defenderScriptDownloadedPayloadExecution = "userDefined"
                    defenderScriptDownloadedPayloadExecutionType = "userDefined"
                    defenderScriptObfuscatedMacroCode = "userDefined"
                    defenderScriptObfuscatedMacroCodeType = "userDefined"
                    defenderSecurityCenterBlockExploitProtectionOverride = $True
                    defenderSecurityCenterDisableAccountUI = $True
                    defenderSecurityCenterDisableAppBrowserUI = $True
                    defenderSecurityCenterDisableClearTpmUI = $True
                    defenderSecurityCenterDisableFamilyUI = $True
                    defenderSecurityCenterDisableHardwareUI = $True
                    defenderSecurityCenterDisableHealthUI = $True
                    defenderSecurityCenterDisableNetworkUI = $True
                    defenderSecurityCenterDisableNotificationAreaUI = $True
                    defenderSecurityCenterDisableRansomwareUI = $True
                    defenderSecurityCenterDisableSecureBootUI = $True
                    defenderSecurityCenterDisableTroubleshootingUI = $True
                    defenderSecurityCenterDisableVirusUI = $True
                    defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI = $True
                    defenderSecurityCenterHelpEmail = "FakeStringValue"
                    defenderSecurityCenterHelpPhone = "FakeStringValue"
                    defenderSecurityCenterHelpURL = "FakeStringValue"
                    defenderSecurityCenterITContactDisplay = "notConfigured"
                    defenderSecurityCenterNotificationsFromApp = "notConfigured"
                    defenderSecurityCenterOrganizationDisplayName = "FakeStringValue"
                    defenderSignatureUpdateIntervalInHours = 25
                    defenderSubmitSamplesConsentType = "sendSafeSamplesAutomatically"
                    defenderUntrustedExecutable = "userDefined"
                    defenderUntrustedExecutableType = "userDefined"
                    defenderUntrustedUSBProcess = "userDefined"
                    defenderUntrustedUSBProcessType = "userDefined"
                    description = "FakeStringValue"
                    deviceGuardEnableSecureBootWithDMA = $True
                    deviceGuardEnableVirtualizationBasedSecurity = $True
                    deviceGuardLaunchSystemGuard = "notConfigured"
                    deviceGuardLocalSystemAuthorityCredentialGuardSettings = "notConfigured"
                    deviceGuardSecureBootWithDMA = "notConfigured"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        Name = "FakeStringValue"
                        MinOSVersion = "FakeStringValue"
                        MaxOSVersion = "FakeStringValue"
                        RuleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dmaGuardDeviceEnumerationPolicy = "deviceDefault"
                    firewallBlockStatefulFTP = $True
                    firewallCertificateRevocationListCheckMethod = "deviceDefault"
                    firewallIdleTimeoutForSecurityAssociationInSeconds = 25
                    firewallIPSecExemptionsAllowDHCP = $True
                    firewallIPSecExemptionsAllowICMP = $True
                    firewallIPSecExemptionsAllowNeighborDiscovery = $True
                    firewallIPSecExemptionsAllowRouterDiscovery = $True
                    firewallIPSecExemptionsNone = $True
                    firewallMergeKeyingModuleSettings = $True
                    firewallPacketQueueingMethod = "deviceDefault"
                    firewallPreSharedKeyEncodingMethod = "deviceDefault"
                    firewallProfileDomain = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePrivate = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePublic = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallRules = @(
                        ([MSFT_MicrosoftGraphwindowsFirewallRule] @{
                            localAddressRanges = @("FakeStringValue")
                            action = "notConfigured"
                            description = "FakeStringValue"
                            interfaceTypes = @("notConfigured")
                            remotePortRanges = @("FakeStringValue")
                            displayName = "FakeStringValue"
                            filePath = "FakeStringValue"
                            localUserAuthorizations = "FakeStringValue"
                            protocol = 25
                            trafficDirection = "notConfigured"
                            remoteAddressRanges = @("FakeStringValue")
                            packageFamilyName = "FakeStringValue"
                            serviceName = "FakeStringValue"
                            localPortRanges = @("FakeStringValue")
                            profileTypes = "notConfigured"
                            edgeTraversal = "notConfigured"
                        })
                    )
                    id = "FakeStringValue"
                    lanManagerAuthenticationLevel = "lmAndNltm"
                    lanManagerWorkstationDisableInsecureGuestLogons = $True
                    localSecurityOptionsAdministratorAccountName = "FakeStringValue"
                    localSecurityOptionsAdministratorElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares = $True
                    localSecurityOptionsAllowPKU2UAuthenticationRequests = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager = "FakeStringValue"
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool = $True
                    localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn = $True
                    localSecurityOptionsAllowUIAccessApplicationElevation = $True
                    localSecurityOptionsAllowUIAccessApplicationsForSecureLocations = $True
                    localSecurityOptionsAllowUndockWithoutHavingToLogon = $True
                    localSecurityOptionsBlockMicrosoftAccounts = $True
                    localSecurityOptionsBlockRemoteLogonWithBlankPassword = $True
                    localSecurityOptionsBlockRemoteOpticalDriveAccess = $True
                    localSecurityOptionsBlockUsersInstallingPrinterDrivers = $True
                    localSecurityOptionsClearVirtualMemoryPageFile = $True
                    localSecurityOptionsClientDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers = $True
                    localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation = $True
                    localSecurityOptionsDisableAdministratorAccount = $True
                    localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees = $True
                    localSecurityOptionsDisableGuestAccount = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees = $True
                    localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts = $True
                    localSecurityOptionsDoNotRequireCtrlAltDel = $True
                    localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange = $True
                    localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser = "notConfigured"
                    localSecurityOptionsGuestAccountName = "FakeStringValue"
                    localSecurityOptionsHideLastSignedInUser = $True
                    localSecurityOptionsHideUsernameAtSignIn = $True
                    localSecurityOptionsInformationDisplayedOnLockScreen = "notConfigured"
                    localSecurityOptionsInformationShownOnLockScreen = "notConfigured"
                    localSecurityOptionsLogOnMessageText = "FakeStringValue"
                    localSecurityOptionsLogOnMessageTitle = "FakeStringValue"
                    localSecurityOptionsMachineInactivityLimit = 25
                    localSecurityOptionsMachineInactivityLimitInMinutes = 25
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients = "none"
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers = "none"
                    localSecurityOptionsOnlyElevateSignedExecutables = $True
                    localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares = $True
                    localSecurityOptionsSmartCardRemovalBehavior = "noAction"
                    localSecurityOptionsStandardUserElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation = $True
                    localSecurityOptionsUseAdminApprovalMode = $True
                    localSecurityOptionsUseAdminApprovalModeForAdministrators = $True
                    localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $True
                    smartScreenBlockOverrideForFiles = $True
                    smartScreenEnableInShell = $True
                    userRightsAccessCredentialManagerAsTrustedCaller = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsActAsPartOfTheOperatingSystem = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsAllowAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBackupData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBlockAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsChangeSystemTime = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateGlobalObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePageFile = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePermanentSharedObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateSymbolicLinks = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateToken = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDebugPrograms = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDelegation = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDenyLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsGenerateSecurityAudits = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsImpersonateClient = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsIncreaseSchedulingPriority = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLoadUnloadDrivers = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLockMemory = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageAuditingAndSecurityLogs = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageVolumes = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyFirmwareEnvironment = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyObjectLabels = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsProfileSingleProcess = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteDesktopServicesLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteShutdown = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRestoreData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsTakeOwnership = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    windowsDefenderTamperProtection = "notConfigured"
                    xboxServicesAccessoryManagementServiceStartupMode = "manual"
                    xboxServicesEnableXboxGameSaveTask = $True
                    xboxServicesLiveAuthManagerServiceStartupMode = "manual"
                    xboxServicesLiveGameSaveServiceStartupMode = "manual"
                    xboxServicesLiveNetworkingServiceStartupMode = "manual"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationGuardAllowCameraMicrophoneRedirection = $True
                    ApplicationGuardAllowFileSaveOnHost = $True
                    ApplicationGuardAllowPersistence = $True
                    ApplicationGuardAllowPrintToLocalPrinters = $True
                    ApplicationGuardAllowPrintToNetworkPrinters = $True
                    ApplicationGuardAllowPrintToPDF = $True
                    ApplicationGuardAllowPrintToXPS = $True
                    ApplicationGuardAllowVirtualGPU = $True
                    ApplicationGuardBlockClipboardSharing = "notConfigured"
                    ApplicationGuardBlockFileTransfer = "notConfigured"
                    ApplicationGuardBlockNonEnterpriseContent = $True
                    ApplicationGuardCertificateThumbprints = @("FakeStringValue")
                    ApplicationGuardEnabled = $True
                    ApplicationGuardEnabledOptions = "notConfigured"
                    ApplicationGuardForceAuditing = $True
                    AppLockerApplicationControl = "notConfigured"
                    BitLockerAllowStandardUserEncryption = $True
                    BitLockerDisableWarningForOtherDiskEncryption = $True
                    BitLockerEnableStorageCardEncryptionOnMobile = $True
                    BitLockerEncryptDevice = $True
                    bitLockerFixedDrivePolicy = ([MSFT_MicrosoftGraphbitLockerFixedDrivePolicy] @{
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        RequireEncryptionForWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerRecoveryPasswordRotation = "notConfigured"
                    bitLockerRemovableDrivePolicy = ([MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy] @{
                        requireEncryptionForWriteAccess = $True
                        blockCrossOrganizationWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerSystemDrivePolicy = ([MSFT_MicrosoftGraphbitLockerSystemDrivePolicy] @{
                        prebootRecoveryEnableMessageAndUrl = $True
                        StartupAuthenticationTpmPinUsage = "blocked"
                        encryptionMethod = "aesCbc128"
                        minimumPinLength = 25
                        prebootRecoveryMessage = "FakeStringValue"
                        StartupAuthenticationTpmPinAndKeyUsage = "blocked"
                        StartupAuthenticationRequired = $True
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        prebootRecoveryUrl = "FakeStringValue"
                        StartupAuthenticationTpmUsage = "blocked"
                        StartupAuthenticationTpmKeyUsage = "blocked"
                        StartupAuthenticationBlockWithoutTpmChip = $True
                    })
                    defenderAdditionalGuardedFolders = @("FakeStringValue")
                    defenderAdobeReaderLaunchChildProcess = "userDefined"
                    defenderAdvancedRansomewareProtectionType = "userDefined"
                    defenderAllowBehaviorMonitoring = $True
                    defenderAllowCloudProtection = $True
                    defenderAllowEndUserAccess = $True
                    defenderAllowIntrusionPreventionSystem = $True
                    defenderAllowOnAccessProtection = $True
                    defenderAllowRealTimeMonitoring = $True
                    defenderAllowScanArchiveFiles = $True
                    defenderAllowScanDownloads = $True
                    defenderAllowScanNetworkFiles = $True
                    defenderAllowScanRemovableDrivesDuringFullScan = $True
                    defenderAllowScanScriptsLoadedInInternetExplorer = $True
                    defenderAttackSurfaceReductionExcludedPaths = @("FakeStringValue")
                    defenderBlockEndUserAccess = $True
                    defenderBlockPersistenceThroughWmiType = "userDefined"
                    defenderCheckForSignaturesBeforeRunningScan = $True
                    defenderCloudBlockLevel = "notConfigured"
                    defenderCloudExtendedTimeoutInSeconds = 25
                    defenderDaysBeforeDeletingQuarantinedMalware = 25
                    defenderDetectedMalwareActions = ([MSFT_MicrosoftGraphdefenderDetectedMalwareActions] @{
                        lowSeverity = "deviceDefault"
                        severeSeverity = "deviceDefault"
                        moderateSeverity = "deviceDefault"
                        highSeverity = "deviceDefault"
                    })
                    defenderDisableBehaviorMonitoring = $True
                    defenderDisableCatchupFullScan = $True
                    defenderDisableCatchupQuickScan = $True
                    defenderDisableCloudProtection = $True
                    defenderDisableIntrusionPreventionSystem = $True
                    defenderDisableOnAccessProtection = $True
                    defenderDisableRealTimeMonitoring = $True
                    defenderDisableScanArchiveFiles = $True
                    defenderDisableScanDownloads = $True
                    defenderDisableScanNetworkFiles = $True
                    defenderDisableScanRemovableDrivesDuringFullScan = $True
                    defenderDisableScanScriptsLoadedInInternetExplorer = $True
                    defenderEmailContentExecution = "userDefined"
                    defenderEmailContentExecutionType = "userDefined"
                    defenderEnableLowCpuPriority = $True
                    defenderEnableScanIncomingMail = $True
                    defenderEnableScanMappedNetworkDrivesDuringFullScan = $True
                    defenderExploitProtectionXml = $True
                    defenderExploitProtectionXmlFileName = "FakeStringValue"
                    defenderFileExtensionsToExclude = @("FakeStringValue")
                    defenderFilesAndFoldersToExclude = @("FakeStringValue")
                    defenderGuardedFoldersAllowedAppPaths = @("FakeStringValue")
                    defenderGuardMyFoldersType = "userDefined"
                    defenderNetworkProtectionType = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunch = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunchType = "userDefined"
                    defenderOfficeAppsLaunchChildProcess = "userDefined"
                    defenderOfficeAppsLaunchChildProcessType = "userDefined"
                    defenderOfficeAppsOtherProcessInjection = "userDefined"
                    defenderOfficeAppsOtherProcessInjectionType = "userDefined"
                    defenderOfficeCommunicationAppsLaunchChildProcess = "userDefined"
                    defenderOfficeMacroCodeAllowWin32Imports = "userDefined"
                    defenderOfficeMacroCodeAllowWin32ImportsType = "userDefined"
                    defenderPotentiallyUnwantedAppAction = "userDefined"
                    defenderPreventCredentialStealingType = "userDefined"
                    defenderProcessCreation = "userDefined"
                    defenderProcessCreationType = "userDefined"
                    defenderProcessesToExclude = @("FakeStringValue")
                    defenderScanDirection = "monitorAllFiles"
                    defenderScanMaxCpuPercentage = 25
                    defenderScanType = "userDefined"
                    defenderScheduledQuickScanTime = "00:00:00"
                    defenderScheduledScanDay = "userDefined"
                    defenderScheduledScanTime = "00:00:00"
                    defenderScriptDownloadedPayloadExecution = "userDefined"
                    defenderScriptDownloadedPayloadExecutionType = "userDefined"
                    defenderScriptObfuscatedMacroCode = "userDefined"
                    defenderScriptObfuscatedMacroCodeType = "userDefined"
                    defenderSecurityCenterBlockExploitProtectionOverride = $True
                    defenderSecurityCenterDisableAccountUI = $True
                    defenderSecurityCenterDisableAppBrowserUI = $True
                    defenderSecurityCenterDisableClearTpmUI = $True
                    defenderSecurityCenterDisableFamilyUI = $True
                    defenderSecurityCenterDisableHardwareUI = $True
                    defenderSecurityCenterDisableHealthUI = $True
                    defenderSecurityCenterDisableNetworkUI = $True
                    defenderSecurityCenterDisableNotificationAreaUI = $True
                    defenderSecurityCenterDisableRansomwareUI = $True
                    defenderSecurityCenterDisableSecureBootUI = $True
                    defenderSecurityCenterDisableTroubleshootingUI = $True
                    defenderSecurityCenterDisableVirusUI = $True
                    defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI = $True
                    defenderSecurityCenterHelpEmail = "FakeStringValue"
                    defenderSecurityCenterHelpPhone = "FakeStringValue"
                    defenderSecurityCenterHelpURL = "FakeStringValue"
                    defenderSecurityCenterITContactDisplay = "notConfigured"
                    defenderSecurityCenterNotificationsFromApp = "notConfigured"
                    defenderSecurityCenterOrganizationDisplayName = "FakeStringValue"
                    defenderSignatureUpdateIntervalInHours = 25
                    defenderSubmitSamplesConsentType = "sendSafeSamplesAutomatically"
                    defenderUntrustedExecutable = "userDefined"
                    defenderUntrustedExecutableType = "userDefined"
                    defenderUntrustedUSBProcess = "userDefined"
                    defenderUntrustedUSBProcessType = "userDefined"
                    description = "FakeStringValue"
                    deviceGuardEnableSecureBootWithDMA = $True
                    deviceGuardEnableVirtualizationBasedSecurity = $True
                    deviceGuardLaunchSystemGuard = "notConfigured"
                    deviceGuardLocalSystemAuthorityCredentialGuardSettings = "notConfigured"
                    deviceGuardSecureBootWithDMA = "notConfigured"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        Name = "FakeStringValue"
                        MinOSVersion = "FakeStringValue"
                        MaxOSVersion = "FakeStringValue"
                        RuleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dmaGuardDeviceEnumerationPolicy = "deviceDefault"
                    firewallBlockStatefulFTP = $True
                    firewallCertificateRevocationListCheckMethod = "deviceDefault"
                    firewallIdleTimeoutForSecurityAssociationInSeconds = 25
                    firewallIPSecExemptionsAllowDHCP = $True
                    firewallIPSecExemptionsAllowICMP = $True
                    firewallIPSecExemptionsAllowNeighborDiscovery = $True
                    firewallIPSecExemptionsAllowRouterDiscovery = $True
                    firewallIPSecExemptionsNone = $True
                    firewallMergeKeyingModuleSettings = $True
                    firewallPacketQueueingMethod = "deviceDefault"
                    firewallPreSharedKeyEncodingMethod = "deviceDefault"
                    firewallProfileDomain = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePrivate = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePublic = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallRules = @(
                        ([MSFT_MicrosoftGraphwindowsFirewallRule] @{
                            localAddressRanges = @("FakeStringValue")
                            action = "notConfigured"
                            description = "FakeStringValue"
                            interfaceTypes = @("notConfigured")
                            remotePortRanges = @("FakeStringValue")
                            displayName = "FakeStringValue"
                            filePath = "FakeStringValue"
                            localUserAuthorizations = "FakeStringValue"
                            protocol = 25
                            trafficDirection = "notConfigured"
                            remoteAddressRanges = @("FakeStringValue")
                            packageFamilyName = "FakeStringValue"
                            serviceName = "FakeStringValue"
                            localPortRanges = @("FakeStringValue")
                            profileTypes = "notConfigured"
                            edgeTraversal = "notConfigured"
                        })
                    )
                    id = "FakeStringValue"
                    lanManagerAuthenticationLevel = "lmAndNltm"
                    lanManagerWorkstationDisableInsecureGuestLogons = $True
                    localSecurityOptionsAdministratorAccountName = "FakeStringValue"
                    localSecurityOptionsAdministratorElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares = $True
                    localSecurityOptionsAllowPKU2UAuthenticationRequests = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager = "FakeStringValue"
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool = $True
                    localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn = $True
                    localSecurityOptionsAllowUIAccessApplicationElevation = $True
                    localSecurityOptionsAllowUIAccessApplicationsForSecureLocations = $True
                    localSecurityOptionsAllowUndockWithoutHavingToLogon = $True
                    localSecurityOptionsBlockMicrosoftAccounts = $True
                    localSecurityOptionsBlockRemoteLogonWithBlankPassword = $True
                    localSecurityOptionsBlockRemoteOpticalDriveAccess = $True
                    localSecurityOptionsBlockUsersInstallingPrinterDrivers = $True
                    localSecurityOptionsClearVirtualMemoryPageFile = $True
                    localSecurityOptionsClientDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers = $True
                    localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation = $True
                    localSecurityOptionsDisableAdministratorAccount = $True
                    localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees = $True
                    localSecurityOptionsDisableGuestAccount = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees = $True
                    localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts = $True
                    localSecurityOptionsDoNotRequireCtrlAltDel = $True
                    localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange = $True
                    localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser = "notConfigured"
                    localSecurityOptionsGuestAccountName = "FakeStringValue"
                    localSecurityOptionsHideLastSignedInUser = $True
                    localSecurityOptionsHideUsernameAtSignIn = $True
                    localSecurityOptionsInformationDisplayedOnLockScreen = "notConfigured"
                    localSecurityOptionsInformationShownOnLockScreen = "notConfigured"
                    localSecurityOptionsLogOnMessageText = "FakeStringValue"
                    localSecurityOptionsLogOnMessageTitle = "FakeStringValue"
                    localSecurityOptionsMachineInactivityLimit = 25
                    localSecurityOptionsMachineInactivityLimitInMinutes = 25
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients = "none"
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers = "none"
                    localSecurityOptionsOnlyElevateSignedExecutables = $True
                    localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares = $True
                    localSecurityOptionsSmartCardRemovalBehavior = "noAction"
                    localSecurityOptionsStandardUserElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation = $True
                    localSecurityOptionsUseAdminApprovalMode = $True
                    localSecurityOptionsUseAdminApprovalModeForAdministrators = $True
                    localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $True
                    smartScreenBlockOverrideForFiles = $True
                    smartScreenEnableInShell = $True
                    userRightsAccessCredentialManagerAsTrustedCaller = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsActAsPartOfTheOperatingSystem = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsAllowAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBackupData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBlockAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsChangeSystemTime = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateGlobalObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePageFile = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePermanentSharedObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateSymbolicLinks = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateToken = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDebugPrograms = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDelegation = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDenyLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsGenerateSecurityAudits = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsImpersonateClient = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsIncreaseSchedulingPriority = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLoadUnloadDrivers = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLockMemory = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageAuditingAndSecurityLogs = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageVolumes = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyFirmwareEnvironment = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyObjectLabels = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsProfileSingleProcess = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteDesktopServicesLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteShutdown = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRestoreData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsTakeOwnership = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    windowsDefenderTamperProtection = "notConfigured"
                    xboxServicesAccessoryManagementServiceStartupMode = "manual"
                    xboxServicesEnableXboxGameSaveTask = $True
                    xboxServicesLiveAuthManagerServiceStartupMode = "manual"
                    xboxServicesLiveGameSaveServiceStartupMode = "manual"
                    xboxServicesLiveNetworkingServiceStartupMode = "manual"
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationGuardAllowCameraMicrophoneRedirection = $True
                    ApplicationGuardAllowFileSaveOnHost = $True
                    ApplicationGuardAllowPersistence = $True
                    ApplicationGuardAllowPrintToLocalPrinters = $True
                    ApplicationGuardAllowPrintToNetworkPrinters = $True
                    ApplicationGuardAllowPrintToPDF = $True
                    ApplicationGuardAllowPrintToXPS = $True
                    ApplicationGuardAllowVirtualGPU = $True
                    ApplicationGuardBlockClipboardSharing = "notConfigured"
                    ApplicationGuardBlockFileTransfer = "notConfigured"
                    ApplicationGuardBlockNonEnterpriseContent = $True
                    ApplicationGuardCertificateThumbprints = @("FakeStringValue")
                    ApplicationGuardEnabled = $True
                    ApplicationGuardEnabledOptions = "notConfigured"
                    ApplicationGuardForceAuditing = $True
                    AppLockerApplicationControl = "notConfigured"
                    BitLockerAllowStandardUserEncryption = $True
                    BitLockerDisableWarningForOtherDiskEncryption = $True
                    BitLockerEnableStorageCardEncryptionOnMobile = $True
                    BitLockerEncryptDevice = $True
                    bitLockerFixedDrivePolicy = ([MSFT_MicrosoftGraphbitLockerFixedDrivePolicy] @{
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        RequireEncryptionForWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerRecoveryPasswordRotation = "notConfigured"
                    bitLockerRemovableDrivePolicy = ([MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy] @{
                        requireEncryptionForWriteAccess = $True
                        blockCrossOrganizationWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerSystemDrivePolicy = ([MSFT_MicrosoftGraphbitLockerSystemDrivePolicy] @{
                        prebootRecoveryEnableMessageAndUrl = $True
                        StartupAuthenticationTpmPinUsage = "blocked"
                        encryptionMethod = "aesCbc128"
                        minimumPinLength = 25
                        prebootRecoveryMessage = "FakeStringValue"
                        StartupAuthenticationTpmPinAndKeyUsage = "blocked"
                        StartupAuthenticationRequired = $True
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        prebootRecoveryUrl = "FakeStringValue"
                        StartupAuthenticationTpmUsage = "blocked"
                        StartupAuthenticationTpmKeyUsage = "blocked"
                        StartupAuthenticationBlockWithoutTpmChip = $True
                    })
                    defenderAdditionalGuardedFolders = @("FakeStringValue")
                    defenderAdobeReaderLaunchChildProcess = "userDefined"
                    defenderAdvancedRansomewareProtectionType = "userDefined"
                    defenderAllowBehaviorMonitoring = $True
                    defenderAllowCloudProtection = $True
                    defenderAllowEndUserAccess = $True
                    defenderAllowIntrusionPreventionSystem = $True
                    defenderAllowOnAccessProtection = $True
                    defenderAllowRealTimeMonitoring = $True
                    defenderAllowScanArchiveFiles = $True
                    defenderAllowScanDownloads = $True
                    defenderAllowScanNetworkFiles = $True
                    defenderAllowScanRemovableDrivesDuringFullScan = $True
                    defenderAllowScanScriptsLoadedInInternetExplorer = $True
                    defenderAttackSurfaceReductionExcludedPaths = @("FakeStringValue")
                    defenderBlockEndUserAccess = $True
                    defenderBlockPersistenceThroughWmiType = "userDefined"
                    defenderCheckForSignaturesBeforeRunningScan = $True
                    defenderCloudBlockLevel = "notConfigured"
                    defenderCloudExtendedTimeoutInSeconds = 25
                    defenderDaysBeforeDeletingQuarantinedMalware = 25
                    defenderDetectedMalwareActions = ([MSFT_MicrosoftGraphdefenderDetectedMalwareActions] @{
                        lowSeverity = "deviceDefault"
                        severeSeverity = "deviceDefault"
                        moderateSeverity = "deviceDefault"
                        highSeverity = "deviceDefault"
                    })
                    defenderDisableBehaviorMonitoring = $True
                    defenderDisableCatchupFullScan = $True
                    defenderDisableCatchupQuickScan = $True
                    defenderDisableCloudProtection = $True
                    defenderDisableIntrusionPreventionSystem = $True
                    defenderDisableOnAccessProtection = $True
                    defenderDisableRealTimeMonitoring = $True
                    defenderDisableScanArchiveFiles = $True
                    defenderDisableScanDownloads = $True
                    defenderDisableScanNetworkFiles = $True
                    defenderDisableScanRemovableDrivesDuringFullScan = $True
                    defenderDisableScanScriptsLoadedInInternetExplorer = $True
                    defenderEmailContentExecution = "userDefined"
                    defenderEmailContentExecutionType = "userDefined"
                    defenderEnableLowCpuPriority = $True
                    defenderEnableScanIncomingMail = $True
                    defenderEnableScanMappedNetworkDrivesDuringFullScan = $True
                    defenderExploitProtectionXml = $True
                    defenderExploitProtectionXmlFileName = "FakeStringValue"
                    defenderFileExtensionsToExclude = @("FakeStringValue")
                    defenderFilesAndFoldersToExclude = @("FakeStringValue")
                    defenderGuardedFoldersAllowedAppPaths = @("FakeStringValue")
                    defenderGuardMyFoldersType = "userDefined"
                    defenderNetworkProtectionType = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunch = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunchType = "userDefined"
                    defenderOfficeAppsLaunchChildProcess = "userDefined"
                    defenderOfficeAppsLaunchChildProcessType = "userDefined"
                    defenderOfficeAppsOtherProcessInjection = "userDefined"
                    defenderOfficeAppsOtherProcessInjectionType = "userDefined"
                    defenderOfficeCommunicationAppsLaunchChildProcess = "userDefined"
                    defenderOfficeMacroCodeAllowWin32Imports = "userDefined"
                    defenderOfficeMacroCodeAllowWin32ImportsType = "userDefined"
                    defenderPotentiallyUnwantedAppAction = "userDefined"
                    defenderPreventCredentialStealingType = "userDefined"
                    defenderProcessCreation = "userDefined"
                    defenderProcessCreationType = "userDefined"
                    defenderProcessesToExclude = @("FakeStringValue")
                    defenderScanDirection = "monitorAllFiles"
                    defenderScanMaxCpuPercentage = 25
                    defenderScanType = "userDefined"
                    defenderScheduledQuickScanTime = "00:00:00"
                    defenderScheduledScanDay = "userDefined"
                    defenderScheduledScanTime = "00:00:00"
                    defenderScriptDownloadedPayloadExecution = "userDefined"
                    defenderScriptDownloadedPayloadExecutionType = "userDefined"
                    defenderScriptObfuscatedMacroCode = "userDefined"
                    defenderScriptObfuscatedMacroCodeType = "userDefined"
                    defenderSecurityCenterBlockExploitProtectionOverride = $True
                    defenderSecurityCenterDisableAccountUI = $True
                    defenderSecurityCenterDisableAppBrowserUI = $True
                    defenderSecurityCenterDisableClearTpmUI = $True
                    defenderSecurityCenterDisableFamilyUI = $True
                    defenderSecurityCenterDisableHardwareUI = $True
                    defenderSecurityCenterDisableHealthUI = $True
                    defenderSecurityCenterDisableNetworkUI = $True
                    defenderSecurityCenterDisableNotificationAreaUI = $True
                    defenderSecurityCenterDisableRansomwareUI = $True
                    defenderSecurityCenterDisableSecureBootUI = $True
                    defenderSecurityCenterDisableTroubleshootingUI = $True
                    defenderSecurityCenterDisableVirusUI = $True
                    defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI = $True
                    defenderSecurityCenterHelpEmail = "FakeStringValue"
                    defenderSecurityCenterHelpPhone = "FakeStringValue"
                    defenderSecurityCenterHelpURL = "FakeStringValue"
                    defenderSecurityCenterITContactDisplay = "notConfigured"
                    defenderSecurityCenterNotificationsFromApp = "notConfigured"
                    defenderSecurityCenterOrganizationDisplayName = "FakeStringValue"
                    defenderSignatureUpdateIntervalInHours = 25
                    defenderSubmitSamplesConsentType = "sendSafeSamplesAutomatically"
                    defenderUntrustedExecutable = "userDefined"
                    defenderUntrustedExecutableType = "userDefined"
                    defenderUntrustedUSBProcess = "userDefined"
                    defenderUntrustedUSBProcessType = "userDefined"
                    description = "FakeStringValue"
                    deviceGuardEnableSecureBootWithDMA = $True
                    deviceGuardEnableVirtualizationBasedSecurity = $True
                    deviceGuardLaunchSystemGuard = "notConfigured"
                    deviceGuardLocalSystemAuthorityCredentialGuardSettings = "notConfigured"
                    deviceGuardSecureBootWithDMA = "notConfigured"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        Name = "FakeStringValue"
                        MinOSVersion = "FakeStringValue"
                        MaxOSVersion = "FakeStringValue"
                        RuleType = "include"
                    })
                    displayName = "FakeStringValue"
                    dmaGuardDeviceEnumerationPolicy = "deviceDefault"
                    firewallBlockStatefulFTP = $True
                    firewallCertificateRevocationListCheckMethod = "deviceDefault"
                    firewallIdleTimeoutForSecurityAssociationInSeconds = 25
                    firewallIPSecExemptionsAllowDHCP = $True
                    firewallIPSecExemptionsAllowICMP = $True
                    firewallIPSecExemptionsAllowNeighborDiscovery = $True
                    firewallIPSecExemptionsAllowRouterDiscovery = $True
                    firewallIPSecExemptionsNone = $True
                    firewallMergeKeyingModuleSettings = $True
                    firewallPacketQueueingMethod = "deviceDefault"
                    firewallPreSharedKeyEncodingMethod = "deviceDefault"
                    firewallProfileDomain = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePrivate = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePublic = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallRules = @(
                        ([MSFT_MicrosoftGraphwindowsFirewallRule] @{
                            localAddressRanges = @("FakeStringValue")
                            action = "notConfigured"
                            description = "FakeStringValue"
                            interfaceTypes = @("notConfigured")
                            remotePortRanges = @("FakeStringValue")
                            displayName = "FakeStringValue"
                            filePath = "FakeStringValue"
                            localUserAuthorizations = "FakeStringValue"
                            protocol = 25
                            trafficDirection = "notConfigured"
                            remoteAddressRanges = @("FakeStringValue")
                            packageFamilyName = "FakeStringValue"
                            serviceName = "FakeStringValue"
                            localPortRanges = @("FakeStringValue")
                            profileTypes = "notConfigured"
                            edgeTraversal = "notConfigured"
                        })
                    )
                    id = "FakeStringValue"
                    lanManagerAuthenticationLevel = "lmAndNltm"
                    lanManagerWorkstationDisableInsecureGuestLogons = $True
                    localSecurityOptionsAdministratorAccountName = "FakeStringValue"
                    localSecurityOptionsAdministratorElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares = $True
                    localSecurityOptionsAllowPKU2UAuthenticationRequests = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager = "FakeStringValue"
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool = $True
                    localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn = $True
                    localSecurityOptionsAllowUIAccessApplicationElevation = $True
                    localSecurityOptionsAllowUIAccessApplicationsForSecureLocations = $True
                    localSecurityOptionsAllowUndockWithoutHavingToLogon = $True
                    localSecurityOptionsBlockMicrosoftAccounts = $True
                    localSecurityOptionsBlockRemoteLogonWithBlankPassword = $True
                    localSecurityOptionsBlockRemoteOpticalDriveAccess = $True
                    localSecurityOptionsBlockUsersInstallingPrinterDrivers = $True
                    localSecurityOptionsClearVirtualMemoryPageFile = $True
                    localSecurityOptionsClientDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers = $True
                    localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation = $True
                    localSecurityOptionsDisableAdministratorAccount = $True
                    localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees = $True
                    localSecurityOptionsDisableGuestAccount = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees = $True
                    localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts = $True
                    localSecurityOptionsDoNotRequireCtrlAltDel = $True
                    localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange = $True
                    localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser = "notConfigured"
                    localSecurityOptionsGuestAccountName = "FakeStringValue"
                    localSecurityOptionsHideLastSignedInUser = $True
                    localSecurityOptionsHideUsernameAtSignIn = $True
                    localSecurityOptionsInformationDisplayedOnLockScreen = "notConfigured"
                    localSecurityOptionsInformationShownOnLockScreen = "notConfigured"
                    localSecurityOptionsLogOnMessageText = "FakeStringValue"
                    localSecurityOptionsLogOnMessageTitle = "FakeStringValue"
                    localSecurityOptionsMachineInactivityLimit = 25
                    localSecurityOptionsMachineInactivityLimitInMinutes = 25
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients = "none"
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers = "none"
                    localSecurityOptionsOnlyElevateSignedExecutables = $True
                    localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares = $True
                    localSecurityOptionsSmartCardRemovalBehavior = "noAction"
                    localSecurityOptionsStandardUserElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation = $True
                    localSecurityOptionsUseAdminApprovalMode = $True
                    localSecurityOptionsUseAdminApprovalModeForAdministrators = $True
                    localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $True
                    smartScreenBlockOverrideForFiles = $True
                    smartScreenEnableInShell = $True
                    userRightsAccessCredentialManagerAsTrustedCaller = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsActAsPartOfTheOperatingSystem = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsAllowAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBackupData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBlockAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsChangeSystemTime = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateGlobalObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePageFile = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePermanentSharedObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateSymbolicLinks = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateToken = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDebugPrograms = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDelegation = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDenyLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsGenerateSecurityAudits = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsImpersonateClient = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsIncreaseSchedulingPriority = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLoadUnloadDrivers = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLockMemory = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageAuditingAndSecurityLogs = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageVolumes = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyFirmwareEnvironment = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyObjectLabels = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsProfileSingleProcess = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteDesktopServicesLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteShutdown = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRestoreData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsTakeOwnership = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    windowsDefenderTamperProtection = "notConfigured"
                    xboxServicesAccessoryManagementServiceStartupMode = "manual"
                    xboxServicesEnableXboxGameSaveTask = $True
                    xboxServicesLiveAuthManagerServiceStartupMode = "manual"
                    xboxServicesLiveGameSaveServiceStartupMode = "manual"
                    xboxServicesLiveNetworkingServiceStartupMode = "manual"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApplicationGuardAllowCameraMicrophoneRedirection = $False # Updated property
                    ApplicationGuardAllowFileSaveOnHost = $True
                    ApplicationGuardAllowPersistence = $True
                    ApplicationGuardAllowPrintToLocalPrinters = $True
                    ApplicationGuardAllowPrintToNetworkPrinters = $True
                    ApplicationGuardAllowPrintToPDF = $True
                    ApplicationGuardAllowPrintToXPS = $True
                    ApplicationGuardAllowVirtualGPU = $True
                    ApplicationGuardBlockClipboardSharing = "notConfigured"
                    ApplicationGuardBlockFileTransfer = "notConfigured"
                    ApplicationGuardBlockNonEnterpriseContent = $True
                    ApplicationGuardCertificateThumbprints = @("FakeStringValue")
                    ApplicationGuardEnabled = $True
                    ApplicationGuardEnabledOptions = "notConfigured"
                    ApplicationGuardForceAuditing = $True
                    AppLockerApplicationControl = "notConfigured"
                    BitLockerAllowStandardUserEncryption = $True
                    BitLockerDisableWarningForOtherDiskEncryption = $True
                    BitLockerEnableStorageCardEncryptionOnMobile = $True
                    BitLockerEncryptDevice = $True
                    bitLockerFixedDrivePolicy = ([MSFT_MicrosoftGraphbitLockerFixedDrivePolicy] @{
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        RequireEncryptionForWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerRecoveryPasswordRotation = "notConfigured"
                    bitLockerRemovableDrivePolicy = ([MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy] @{
                        requireEncryptionForWriteAccess = $True
                        blockCrossOrganizationWriteAccess = $True
                        encryptionMethod = "aesCbc128"
                    })
                    bitLockerSystemDrivePolicy = ([MSFT_MicrosoftGraphbitLockerSystemDrivePolicy] @{
                        prebootRecoveryEnableMessageAndUrl = $True
                        StartupAuthenticationTpmPinUsage = "blocked"
                        encryptionMethod = "aesCbc128"
                        minimumPinLength = 25
                        prebootRecoveryMessage = "FakeStringValue"
                        StartupAuthenticationTpmPinAndKeyUsage = "blocked"
                        StartupAuthenticationRequired = $True
                        RecoveryOptions = ([MSFT_MicrosoftGraphBitLockerRecoveryOptions] @{
                            RecoveryInformationToStore = "passwordAndKey"
                            HideRecoveryOptions = $True
                            BlockDataRecoveryAgent = $True
                            RecoveryKeyUsage = "blocked"
                            EnableBitLockerAfterRecoveryInformationToStore = $True
                            EnableRecoveryInformationSaveToStore = $True
                            RecoveryPasswordUsage = "blocked"
                        })
                        prebootRecoveryUrl = "FakeStringValue"
                        StartupAuthenticationTpmUsage = "blocked"
                        StartupAuthenticationTpmKeyUsage = "blocked"
                        StartupAuthenticationBlockWithoutTpmChip = $True
                    })
                    defenderAdditionalGuardedFolders = @("FakeStringValue")
                    defenderAdobeReaderLaunchChildProcess = "userDefined"
                    defenderAdvancedRansomewareProtectionType = "userDefined"
                    defenderAllowBehaviorMonitoring = $True
                    defenderAllowCloudProtection = $True
                    defenderAllowEndUserAccess = $True
                    defenderAllowIntrusionPreventionSystem = $True
                    defenderAllowOnAccessProtection = $True
                    defenderAllowRealTimeMonitoring = $True
                    defenderAllowScanArchiveFiles = $True
                    defenderAllowScanDownloads = $True
                    defenderAllowScanNetworkFiles = $True
                    defenderAllowScanRemovableDrivesDuringFullScan = $True
                    defenderAllowScanScriptsLoadedInInternetExplorer = $True
                    defenderAttackSurfaceReductionExcludedPaths = @("FakeStringValue")
                    defenderBlockEndUserAccess = $True
                    defenderBlockPersistenceThroughWmiType = "userDefined"
                    defenderCheckForSignaturesBeforeRunningScan = $True
                    defenderCloudBlockLevel = "notConfigured"
                    defenderCloudExtendedTimeoutInSeconds = 25
                    defenderDaysBeforeDeletingQuarantinedMalware = 25
                    defenderDetectedMalwareActions = ([MSFT_MicrosoftGraphdefenderDetectedMalwareActions] @{
                        lowSeverity = "deviceDefault"
                        severeSeverity = "deviceDefault"
                        moderateSeverity = "deviceDefault"
                        highSeverity = "deviceDefault"
                    })
                    defenderDisableBehaviorMonitoring = $True
                    defenderDisableCatchupFullScan = $True
                    defenderDisableCatchupQuickScan = $True
                    defenderDisableCloudProtection = $True
                    defenderDisableIntrusionPreventionSystem = $True
                    defenderDisableOnAccessProtection = $True
                    defenderDisableRealTimeMonitoring = $True
                    defenderDisableScanArchiveFiles = $True
                    defenderDisableScanDownloads = $True
                    defenderDisableScanNetworkFiles = $True
                    defenderDisableScanRemovableDrivesDuringFullScan = $True
                    defenderDisableScanScriptsLoadedInInternetExplorer = $True
                    defenderEmailContentExecution = "userDefined"
                    defenderEmailContentExecutionType = "userDefined"
                    defenderEnableLowCpuPriority = $True
                    defenderEnableScanIncomingMail = $True
                    defenderEnableScanMappedNetworkDrivesDuringFullScan = $True
                    defenderExploitProtectionXml = $True
                    defenderExploitProtectionXmlFileName = "FakeStringValue"
                    defenderFileExtensionsToExclude = @("FakeStringValue")
                    defenderFilesAndFoldersToExclude = @("FakeStringValue")
                    defenderGuardedFoldersAllowedAppPaths = @("FakeStringValue")
                    defenderGuardMyFoldersType = "userDefined"
                    defenderNetworkProtectionType = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunch = "userDefined"
                    defenderOfficeAppsExecutableContentCreationOrLaunchType = "userDefined"
                    defenderOfficeAppsLaunchChildProcess = "userDefined"
                    defenderOfficeAppsLaunchChildProcessType = "userDefined"
                    defenderOfficeAppsOtherProcessInjection = "userDefined"
                    defenderOfficeAppsOtherProcessInjectionType = "userDefined"
                    defenderOfficeCommunicationAppsLaunchChildProcess = "userDefined"
                    defenderOfficeMacroCodeAllowWin32Imports = "userDefined"
                    defenderOfficeMacroCodeAllowWin32ImportsType = "userDefined"
                    defenderPotentiallyUnwantedAppAction = "userDefined"
                    defenderPreventCredentialStealingType = "userDefined"
                    defenderProcessCreation = "userDefined"
                    defenderProcessCreationType = "userDefined"
                    defenderProcessesToExclude = @("FakeStringValue")
                    defenderScanDirection = "monitorAllFiles"
                    defenderScanMaxCpuPercentage = 25
                    defenderScanType = "userDefined"
                    defenderScheduledQuickScanTime = "00:00:00"
                    defenderScheduledScanDay = "userDefined"
                    defenderScheduledScanTime = "00:00:00"
                    defenderScriptDownloadedPayloadExecution = "userDefined"
                    defenderScriptDownloadedPayloadExecutionType = "userDefined"
                    defenderScriptObfuscatedMacroCode = "userDefined"
                    defenderScriptObfuscatedMacroCodeType = "userDefined"
                    defenderSecurityCenterBlockExploitProtectionOverride = $True
                    defenderSecurityCenterDisableAccountUI = $True
                    defenderSecurityCenterDisableAppBrowserUI = $True
                    defenderSecurityCenterDisableClearTpmUI = $True
                    defenderSecurityCenterDisableFamilyUI = $True
                    defenderSecurityCenterDisableHardwareUI = $True
                    defenderSecurityCenterDisableHealthUI = $True
                    defenderSecurityCenterDisableNetworkUI = $True
                    defenderSecurityCenterDisableNotificationAreaUI = $True
                    defenderSecurityCenterDisableRansomwareUI = $True
                    defenderSecurityCenterDisableSecureBootUI = $True
                    defenderSecurityCenterDisableTroubleshootingUI = $True
                    defenderSecurityCenterDisableVirusUI = $True
                    defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI = $True
                    defenderSecurityCenterHelpEmail = "FakeStringValue"
                    defenderSecurityCenterHelpPhone = "FakeStringValue"
                    defenderSecurityCenterHelpURL = "FakeStringValue"
                    defenderSecurityCenterITContactDisplay = "notConfigured"
                    defenderSecurityCenterNotificationsFromApp = "notConfigured"
                    defenderSecurityCenterOrganizationDisplayName = "FakeStringValue"
                    defenderSignatureUpdateIntervalInHours = 25
                    defenderSubmitSamplesConsentType = "sendSafeSamplesAutomatically"
                    defenderUntrustedExecutable = "userDefined"
                    defenderUntrustedExecutableType = "userDefined"
                    defenderUntrustedUSBProcess = "userDefined"
                    defenderUntrustedUSBProcessType = "userDefined"
                    description = "FakeStringValue"
                    deviceGuardEnableSecureBootWithDMA = $True
                    deviceGuardEnableVirtualizationBasedSecurity = $True
                    deviceGuardLaunchSystemGuard = "notConfigured"
                    deviceGuardLocalSystemAuthorityCredentialGuardSettings = "notConfigured"
                    deviceGuardSecureBootWithDMA = "notConfigured"
                    deviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                        Name = "DifferentValue"
                        DeviceMode = "sModeConfiguration"
                        RuleType = "exclude"
                    })
                    deviceManagementApplicabilityRuleOsEdition = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                        Name = "DifferentValue"
                        OsEditionTypes = @("windows10Education")
                        RuleType = "exclude"
                    })
                    deviceManagementApplicabilityRuleOsVersion = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                        Name = "DifferentValue"
                        MinOSVersion = "DifferentValue"
                        MaxOSVersion = "DifferentValue"
                        RuleType = "exclude"
                    })
                    displayName = "FakeStringValue"
                    dmaGuardDeviceEnumerationPolicy = "deviceDefault"
                    firewallBlockStatefulFTP = $True
                    firewallCertificateRevocationListCheckMethod = "deviceDefault"
                    firewallIdleTimeoutForSecurityAssociationInSeconds = 25
                    firewallIPSecExemptionsAllowDHCP = $True
                    firewallIPSecExemptionsAllowICMP = $True
                    firewallIPSecExemptionsAllowNeighborDiscovery = $True
                    firewallIPSecExemptionsAllowRouterDiscovery = $True
                    firewallIPSecExemptionsNone = $True
                    firewallMergeKeyingModuleSettings = $True
                    firewallPacketQueueingMethod = "deviceDefault"
                    firewallPreSharedKeyEncodingMethod = "deviceDefault"
                    firewallProfileDomain = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePrivate = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallProfilePublic = ([MSFT_MicrosoftGraphwindowsFirewallNetworkProfile] @{
                        policyRulesFromGroupPolicyNotMerged = $True
                        inboundConnectionsRequired = $True
                        securedPacketExemptionAllowed = $True
                        securedPacketExemptionBlocked = $True
                        globalPortRulesFromGroupPolicyMerged = $True
                        stealthModeBlocked = $True
                        outboundConnectionsBlocked = $True
                        inboundConnectionsBlocked = $True
                        authorizedApplicationRulesFromGroupPolicyMerged = $True
                        inboundNotificationsRequired = $True
                        firewallEnabled = "notConfigured"
                        stealthModeRequired = $True
                        incomingTrafficBlocked = $True
                        incomingTrafficRequired = $True
                        unicastResponsesToMulticastBroadcastsBlocked = $True
                        policyRulesFromGroupPolicyMerged = $True
                        unicastResponsesToMulticastBroadcastsRequired = $True
                        connectionSecurityRulesFromGroupPolicyNotMerged = $True
                        globalPortRulesFromGroupPolicyNotMerged = $True
                        outboundConnectionsRequired = $True
                        inboundNotificationsBlocked = $True
                        connectionSecurityRulesFromGroupPolicyMerged = $True
                        authorizedApplicationRulesFromGroupPolicyNotMerged = $True
                    })
                    firewallRules = @(
                        ([MSFT_MicrosoftGraphwindowsFirewallRule] @{
                            localAddressRanges = @("FakeStringValue")
                            action = "notConfigured"
                            description = "FakeStringValue"
                            interfaceTypes = @("notConfigured")
                            remotePortRanges = @("FakeStringValue")
                            displayName = "FakeStringValue"
                            filePath = "FakeStringValue"
                            localUserAuthorizations = "FakeStringValue"
                            protocol = 25
                            trafficDirection = "notConfigured"
                            remoteAddressRanges = @("FakeStringValue")
                            packageFamilyName = "FakeStringValue"
                            serviceName = "FakeStringValue"
                            localPortRanges = @("FakeStringValue")
                            profileTypes = "notConfigured"
                            edgeTraversal = "notConfigured"
                        })
                    )
                    id = "FakeStringValue"
                    lanManagerAuthenticationLevel = "lmAndNltm"
                    lanManagerWorkstationDisableInsecureGuestLogons = $True
                    localSecurityOptionsAdministratorAccountName = "FakeStringValue"
                    localSecurityOptionsAdministratorElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares = $True
                    localSecurityOptionsAllowPKU2UAuthenticationRequests = $True
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager = "FakeStringValue"
                    localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool = $True
                    localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn = $True
                    localSecurityOptionsAllowUIAccessApplicationElevation = $True
                    localSecurityOptionsAllowUIAccessApplicationsForSecureLocations = $True
                    localSecurityOptionsAllowUndockWithoutHavingToLogon = $True
                    localSecurityOptionsBlockMicrosoftAccounts = $True
                    localSecurityOptionsBlockRemoteLogonWithBlankPassword = $True
                    localSecurityOptionsBlockRemoteOpticalDriveAccess = $True
                    localSecurityOptionsBlockUsersInstallingPrinterDrivers = $True
                    localSecurityOptionsClearVirtualMemoryPageFile = $True
                    localSecurityOptionsClientDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers = $True
                    localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation = $True
                    localSecurityOptionsDisableAdministratorAccount = $True
                    localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees = $True
                    localSecurityOptionsDisableGuestAccount = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsAlways = $True
                    localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees = $True
                    localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts = $True
                    localSecurityOptionsDoNotRequireCtrlAltDel = $True
                    localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange = $True
                    localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser = "notConfigured"
                    localSecurityOptionsGuestAccountName = "FakeStringValue"
                    localSecurityOptionsHideLastSignedInUser = $True
                    localSecurityOptionsHideUsernameAtSignIn = $True
                    localSecurityOptionsInformationDisplayedOnLockScreen = "notConfigured"
                    localSecurityOptionsInformationShownOnLockScreen = "notConfigured"
                    localSecurityOptionsLogOnMessageText = "FakeStringValue"
                    localSecurityOptionsLogOnMessageTitle = "FakeStringValue"
                    localSecurityOptionsMachineInactivityLimit = 25
                    localSecurityOptionsMachineInactivityLimitInMinutes = 25
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients = "none"
                    localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers = "none"
                    localSecurityOptionsOnlyElevateSignedExecutables = $True
                    localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares = $True
                    localSecurityOptionsSmartCardRemovalBehavior = "noAction"
                    localSecurityOptionsStandardUserElevationPromptBehavior = "notConfigured"
                    localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation = $True
                    localSecurityOptionsUseAdminApprovalMode = $True
                    localSecurityOptionsUseAdminApprovalModeForAdministrators = $True
                    localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $True
                    smartScreenBlockOverrideForFiles = $True
                    smartScreenEnableInShell = $True
                    userRightsAccessCredentialManagerAsTrustedCaller = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsActAsPartOfTheOperatingSystem = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsAllowAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBackupData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsBlockAccessFromNetwork = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsChangeSystemTime = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateGlobalObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePageFile = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreatePermanentSharedObjects = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateSymbolicLinks = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsCreateToken = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDebugPrograms = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDelegation = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsDenyLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsGenerateSecurityAudits = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsImpersonateClient = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsIncreaseSchedulingPriority = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLoadUnloadDrivers = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLocalLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsLockMemory = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageAuditingAndSecurityLogs = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsManageVolumes = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyFirmwareEnvironment = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsModifyObjectLabels = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsProfileSingleProcess = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteDesktopServicesLogOn = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRemoteShutdown = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsRestoreData = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    userRightsTakeOwnership = ([MSFT_MicrosoftGraphdeviceManagementUserRightsSetting] @{
                        State = "notConfigured"
                        LocalUsersOrGroups = @(
                            ([MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup] @{
                                Description = "FakeStringValue"
                                Name = "FakeStringValue"
                                SecurityIdentifier = "FakeStringValue"
                            })
                        )
                    })
                    windowsDefenderTamperProtection = "notConfigured"
                    xboxServicesAccessoryManagementServiceStartupMode = "manual"
                    xboxServicesEnableXboxGameSaveTask = $True
                    xboxServicesLiveAuthManagerServiceStartupMode = "manual"
                    xboxServicesLiveGameSaveServiceStartupMode = "manual"
                    xboxServicesLiveNetworkingServiceStartupMode = "manual"
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It "Should return Values from the Get method" {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It "Should call the Set method" {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
