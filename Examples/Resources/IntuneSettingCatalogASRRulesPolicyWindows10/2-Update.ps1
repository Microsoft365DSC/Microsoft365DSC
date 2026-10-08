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
        IntuneSettingCatalogASRRulesPolicyWindows10 'IntuneSettingCatalogASRRulesPolicyWindows10-Example'
        {
            DisplayName                                                                                         = 'Attack Surface Reduction Rules'
            Assignments                                                                                         = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            )
            AttackSurfaceReductionOnlyExclusions                                                                = @('C:\Program Files\Contoso\Ledger', 'C:\ProgramData\Contoso\Cache', 'D:\LineOfBusiness')
            BlockAbuseOfExploitedVulnerableSignedDrivers                                                        = 'audit' # Updated Property
            BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions                               = @('C:\Windows\System32\drivers\contosovpn.sys')
            BlockAdobeReaderFromCreatingChildProcesses                                                          = 'block'
            BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions                                 = @('C:\Program Files\Contoso\FormsPrinter\FormsPrinter.exe')
            BlockAllOfficeApplicationsFromCreatingChildProcesses                                                = 'block'
            BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions                       = @('C:\Program Files\Contoso\Ledger\LedgerAddin.exe')
            BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem                                   = 'block'
            BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions          = @('C:\Program Files\Contoso\Diagnostics\CredentialCheck.exe')
            BlockExecutableContentFromEmailClientAndWebmail                                                     = 'block'
            BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions                            = @('C:\ProgramData\Contoso\Mail\Attachments')
            BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion                          = 'audit'
            BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions = @('C:\Program Files\Contoso\Ledger\LedgerClient.exe')
            BlockExecutionOfPotentiallyObfuscatedScripts                                                        = 'block'
            BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions                               = @('C:\ProgramData\Contoso\Scripts\InventoryReport.ps1')
            BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent                                   = 'block'
            BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions          = @('C:\ProgramData\Contoso\Scripts\DeployPrinters.vbs')
            BlockOfficeApplicationsFromCreatingExecutableContent                                                = 'block'
            BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions                       = @('C:\Program Files\Contoso\Ledger\ReportBuilder.exe')
            BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses                                          = 'block'
            BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions                 = @('C:\Program Files\Contoso\Ledger\ExcelBridge.exe')
            BlockOfficeCommunicationAppFromCreatingChildProcesses                                               = 'block'
            BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions                      = @('C:\Program Files\Contoso\Helpdesk\TicketLauncher.exe')
            BlockPersistenceThroughWMIEventSubscription                                                         = 'block'
            BlockProcessCreationsFromPSExecAndWMICommands                                                       = 'warn'
            BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions                              = @('C:\Program Files\Contoso\Deployment\RemoteInstall.exe')
            BlockRebootingMachineInSafeMode                                                                     = 'audit'
            BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions                                            = @('C:\Program Files\Contoso\Deployment\RecoveryTool.exe')
            BlockUntrustedUnsignedProcessesThatRunFromUSB                                                       = 'block'
            BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions                              = @('D:\FieldTools\SiteSurvey.exe')
            BlockUseOfCopiedOrImpersonatedSystemTools                                                           = 'audit'
            BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions                                  = @('C:\Program Files\Contoso\Deployment\ContosoRobocopy.exe')
            BlockWebShellCreationForServers                                                                     = 'block'
            BlockWebshellCreationForServers_ASROnlyPerRuleExclusions                                            = @('C:\inetpub\wwwroot\contoso\upload')
            BlockWin32APICallsFromOfficeMacros                                                                  = 'block'
            BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions                                         = @('C:\Program Files\Contoso\Ledger\MacroBridge.xlam')
            ControlledFolderAccessAllowedApplications                                                           = @('C:\Program Files\Contoso\Ledger\LedgerClient.exe', 'C:\Program Files\Contoso\Backup\BackupAgent.exe')
            ControlledFolderAccessProtectedFolders                                                              = @('C:\ProgramData\Contoso\Ledger\Records', 'D:\FinanceArchive')
            Description                                                                                         = 'Attack surface reduction rules for corporate Windows devices'
            EnableControlledFolderAccess                                                                        = '2'
            RoleScopeTagIds                                                                                     = @('0')
            UseAdvancedProtectionAgainstRansomware                                                              = 'block'
            UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions                                     = @('C:\Program Files\Contoso\Backup\BackupAgent.exe')
            Ensure                                                                                              = 'Present'
            ApplicationId                                                                                       = $ApplicationId;
            TenantId                                                                                            = $TenantId;
            CertificateThumbprint                                                                               = $CertificateThumbprint;
        }
    }
}
