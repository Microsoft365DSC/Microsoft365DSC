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
        IntuneSecurityBaselineDefenderForEndpoint 'IntuneSecurityBaselineDefenderForEndpoint-Example'
        {
            DisplayName           = 'Defender for Endpoint Baseline'
            Description           = "Hardens Microsoft Defender antivirus, attack surface reduction, BitLocker and SmartScreen on managed Windows devices" # Updated Property
            RoleScopeTagIds       = @("0")
            DeviceSettings        = MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineDefenderForEndpoint{
                DeviceInstall_Classes_Deny                                                                          = 1
                DeviceInstall_Classes_Deny_List                                                                     = @("{d48179be-ec20-11d1-b6b8-00c04fa372a7}", "{7ebefbc0-3200-11d2-b4c2-00a0c9697d07}")
                DeviceInstall_Classes_Deny_Retroactive                                                              = 1
                EncryptionMethodWithXts_Name                                                                        = 1
                EncryptionMethodWithXtsOsDropDown_Name                                                              = "7"
                EncryptionMethodWithXtsFdvDropDown_Name                                                             = "7"
                EncryptionMethodWithXtsRdvDropDown_Name                                                             = "4"
                FDVRecoveryUsage_Name                                                                               = 1
                FDVActiveDirectoryBackup_Name                                                                       = 1
                FDVHideRecoveryPage_Name                                                                            = 1
                FDVRecoveryPasswordUsageDropDown_Name                                                               = "1"
                FDVRequireActiveDirectoryBackup_Name                                                                = 1
                FDVAllowDRA_Name                                                                                    = 0
                FDVActiveDirectoryBackupDropDown_Name                                                               = "1"
                FDVRecoveryKeyUsageDropDown_Name                                                                    = "0"
                FDVDenyWriteAccess_Name                                                                             = 1
                FDVEncryptionType_Name                                                                              = 1
                FDVEncryptionTypeDropDown_Name                                                                      = "1"
                EnablePreBootPinExceptionOnDECapableDevice_Name                                                     = 0
                EnhancedPIN_Name                                                                                    = 1
                OSRecoveryUsage_Name                                                                                = 1
                OSRequireActiveDirectoryBackup_Name                                                                 = 1
                OSActiveDirectoryBackup_Name                                                                        = 1
                OSRecoveryPasswordUsageDropDown_Name                                                                = "1"
                OSHideRecoveryPage_Name                                                                             = 1
                OSAllowDRA_Name                                                                                     = 0
                OSRecoveryKeyUsageDropDown_Name                                                                     = "0"
                OSActiveDirectoryBackupDropDown_Name                                                                = "1"
                EnablePrebootInputProtectorsOnSlates_Name                                                           = 1
                OSEncryptionType_Name                                                                               = 1
                OSEncryptionTypeDropDown_Name                                                                       = "1"
                ConfigureAdvancedStartup_Name                                                                       = 1
                ConfigureTPMStartupKeyUsageDropDown_Name                                                            = "0"
                ConfigureTPMPINKeyUsageDropDown_Name                                                                = "0"
                ConfigureTPMUsageDropDown_Name                                                                      = "2"
                ConfigureNonTPMStartupKeyUsage_Name                                                                 = 0
                ConfigurePINUsageDropDown_Name                                                                      = "1"
                RDVConfigureBDE                                                                                     = 1
                RDVAllowBDE_Name                                                                                    = 1
                RDVEncryptionType_Name                                                                              = 1
                RDVEncryptionTypeDropDown_Name                                                                      = "1"
                RDVDisableBDE_Name                                                                                  = 1
                RDVDenyWriteAccess_Name                                                                             = 1
                RDVCrossOrg                                                                                         = 1
                EnableSmartScreen                                                                                   = 1
                EnableSmartScreenDropdown                                                                           = "Block"
                DisableSafetyFilterOverrideForAppRepUnknown                                                         = 1
                Disable_Managing_Safety_Filter_IE9                                                                  = 1
                IE9SafetyFilterOptions                                                                              = "1"
                AllowWarningForOtherDiskEncryption                                                                  = 0
                AllowStandardUserEncryption                                                                         = 1
                ConfigureRecoveryPasswordRotation                                                                   = "1"
                RequireDeviceEncryption                                                                             = "1"
                AllowArchiveScanning                                                                                = 1
                AllowBehaviorMonitoring                                                                             = 1
                AllowCloudProtection                                                                                = 1
                AllowEmailScanning                                                                                  = 1
                AllowFullScanRemovableDriveScanning                                                                 = 1
                AllowOnAccessProtection                                                                             = 1
                AllowRealtimeMonitoring                                                                             = 1
                AllowScanningNetworkFiles                                                                           = 1
                AllowIOAVProtection                                                                                 = 1
                AllowScriptScanning                                                                                 = 1
                AllowUserUIAccess                                                                                   = 1
                BlockExecutionOfPotentiallyObfuscatedScripts                                                        = "block"
                BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions                               = @("C:\ProgramData\Contoso\Deployment\Scripts")
                BlockWin32APICallsFromOfficeMacros                                                                  = "block"
                BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions                                         = @("C:\Program Files\Contoso Finance\ReportBuilder.xlsm")
                BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion                          = "audit"
                BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions = @("C:\Program Files\Contoso Line Of Business")
                BlockOfficeCommunicationAppFromCreatingChildProcesses                                               = "block"
                BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions                      = @("C:\Program Files\Contoso Meeting Add-in")
                BlockAllOfficeApplicationsFromCreatingChildProcesses                                                = "block"
                BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions                       = @("C:\Program Files\Contoso Finance\ReportBuilder.exe")
                BlockAdobeReaderFromCreatingChildProcesses                                                          = "block"
                BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions                                 = @("C:\Program Files\Contoso Forms\FormHandler.exe")
                BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem                                   = "block"
                BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions          = @("C:\Program Files\Contoso Backup Agent\BackupAgent.exe")
                BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent                                   = "block"
                BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions          = @("C:\ProgramData\Contoso\Deployment\Bootstrap.js")
                BlockWebshellCreationForServers                                                                     = "block"
                BlockWebshellCreationForServers_ASROnlyPerRuleExclusions                                            = @("C:\inetpub\wwwroot\contoso-intranet")
                BlockUntrustedUnsignedProcessesThatRunFromUSB                                                       = "block"
                BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions                              = @("D:\Contoso Field Toolkit")
                BlockPersistenceThroughWMIEventSubscription                                                         = "block"
                BlockUseOfCopiedOrImpersonatedSystemTools                                                           = "audit"
                BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions                                  = @("C:\Program Files\Contoso Support Tools")
                BlockAbuseOfExploitedVulnerableSignedDrivers                                                        = "block"
                BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions                               = @("C:\Program Files\Contoso Print Drivers")
                BlockProcessCreationsFromPSExecAndWMICommands                                                       = "block"
                BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions                              = @("C:\Program Files\Contoso Remote Support\RemoteSupport.exe")
                BlockOfficeApplicationsFromCreatingExecutableContent                                                = "block"
                BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions                       = @("C:\Users\Public\Contoso Templates")
                BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses                                          = "block"
                BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions                 = @("C:\Program Files\Contoso Excel Add-in")
                BlockRebootingMachineInSafeMode                                                                     = "audit"
                BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions                                            = @("C:\Program Files\Contoso Recovery Agent")
                UseAdvancedProtectionAgainstRansomware                                                              = "block"
                UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions                                     = @("C:\Program Files\Contoso Archive Service")
                BlockExecutableContentFromEmailClientAndWebmail                                                     = "block"
                BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions                            = @("C:\Program Files\Contoso Mail Gateway")
                CheckForSignaturesBeforeRunningScan                                                                 = 1
                CloudBlockLevel                                                                                     = 2
                CloudExtendedTimeout                                                                                = 50
                DisableLocalAdminMerge                                                                              = 1
                EnableNetworkProtection                                                                             = 1
                HideExclusionsFromLocalAdmins                                                                       = 1
                HideExclusionsFromLocalUsers                                                                        = 1
                OobeEnableRtpAndSigUpdate                                                                           = 1
                PUAProtection                                                                                       = 1
                RealTimeScanDirection                                                                               = 0
                ScanParameter                                                                                       = 1
                ScheduleQuickScanTime                                                                               = 120
                ScheduleScanDay                                                                                     = 0
                ScheduleScanTime                                                                                    = 120
                SignatureUpdateInterval                                                                             = 4
                SubmitSamplesConsent                                                                                = 1
                LsaCfgFlags                                                                                         = 1
                DeviceEnumerationPolicy                                                                             = 1
                SmartScreenEnabled                                                                                  = 1
                SmartScreenPuaEnabled                                                                               = 1
                SmartScreenDnsRequestsEnabled                                                                       = 1
                NewSmartScreenLibraryEnabled                                                                        = 1
                SmartScreenForTrustedDownloadsEnabled                                                               = 1
                PreventSmartScreenPromptOverride                                                                    = 1
                PreventSmartScreenPromptOverrideForFiles                                                            = 1
            }
            UserSettings          = MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineDefenderForEndpoint{
                DisableSafetyFilterOverrideForAppRepUnknown = 1
            }
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    groupDisplayName                           = "Intune Pilot Devices"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
            )
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
