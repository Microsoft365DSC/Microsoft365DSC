using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSecurityBaselineDefenderForEndpoint : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Scope for Device Setting')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineDefenderForEndpoint] $DeviceSettings

    [DscProperty()]
    [System.ComponentModel.Description('Scope for Device Setting')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineDefenderForEndpoint] $UserSettings

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

    [IntuneSecurityBaselineDefenderForEndpoint] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSecurityBaselineDefenderForEndpoint]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Security Baseline Defender For Endpoint with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
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
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline Defender For Endpoint with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline Defender For Endpoint with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Security Baseline Defender For Endpoint with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -ContainsDeviceAndUserSettings

            #region resource generator code
            $complexDeviceSettings = [ordered]@{}

            # Add device settings with conditional checks
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny', $policySettings.DeviceSettings.deviceInstall_Classes_Deny)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny_List)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny_List', $policySettings.DeviceSettings.deviceInstall_Classes_Deny_List)
            }
            if ($null -ne $policySettings.DeviceSettings.deviceInstall_Classes_Deny_Retroactive)
            {
                $complexDeviceSettings.Add('DeviceInstall_Classes_Deny_Retroactive', $policySettings.DeviceSettings.deviceInstall_Classes_Deny_Retroactive)
            }
            if ($null -ne $policySettings.DeviceSettings.encryptionMethodWithXts_Name)
            {
                $complexDeviceSettings.Add('EncryptionMethodWithXts_Name', $policySettings.DeviceSettings.encryptionMethodWithXts_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.encryptionMethodWithXtsOsDropDown_Name)
            {
                $complexDeviceSettings.Add('EncryptionMethodWithXtsOsDropDown_Name', $policySettings.DeviceSettings.encryptionMethodWithXtsOsDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.encryptionMethodWithXtsFdvDropDown_Name)
            {
                $complexDeviceSettings.Add('EncryptionMethodWithXtsFdvDropDown_Name', $policySettings.DeviceSettings.encryptionMethodWithXtsFdvDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.encryptionMethodWithXtsRdvDropDown_Name)
            {
                $complexDeviceSettings.Add('EncryptionMethodWithXtsRdvDropDown_Name', $policySettings.DeviceSettings.encryptionMethodWithXtsRdvDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVRecoveryUsage_Name)
            {
                $complexDeviceSettings.Add('FDVRecoveryUsage_Name', $policySettings.DeviceSettings.fDVRecoveryUsage_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVActiveDirectoryBackup_Name)
            {
                $complexDeviceSettings.Add('FDVActiveDirectoryBackup_Name', $policySettings.DeviceSettings.fDVActiveDirectoryBackup_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVHideRecoveryPage_Name)
            {
                $complexDeviceSettings.Add('FDVHideRecoveryPage_Name', $policySettings.DeviceSettings.fDVHideRecoveryPage_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVRecoveryPasswordUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('FDVRecoveryPasswordUsageDropDown_Name', $policySettings.DeviceSettings.fDVRecoveryPasswordUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVRequireActiveDirectoryBackup_Name)
            {
                $complexDeviceSettings.Add('FDVRequireActiveDirectoryBackup_Name', $policySettings.DeviceSettings.fDVRequireActiveDirectoryBackup_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVAllowDRA_Name)
            {
                $complexDeviceSettings.Add('FDVAllowDRA_Name', $policySettings.DeviceSettings.fDVAllowDRA_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVActiveDirectoryBackupDropDown_Name)
            {
                $complexDeviceSettings.Add('FDVActiveDirectoryBackupDropDown_Name', $policySettings.DeviceSettings.fDVActiveDirectoryBackupDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVRecoveryKeyUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('FDVRecoveryKeyUsageDropDown_Name', $policySettings.DeviceSettings.fDVRecoveryKeyUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVDenyWriteAccess_Name)
            {
                $complexDeviceSettings.Add('FDVDenyWriteAccess_Name', $policySettings.DeviceSettings.fDVDenyWriteAccess_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVEncryptionType_Name)
            {
                $complexDeviceSettings.Add('FDVEncryptionType_Name', $policySettings.DeviceSettings.fDVEncryptionType_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.fDVEncryptionTypeDropDown_Name)
            {
                $complexDeviceSettings.Add('FDVEncryptionTypeDropDown_Name', $policySettings.DeviceSettings.fDVEncryptionTypeDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.enablePreBootPinExceptionOnDECapableDevice_Name)
            {
                $complexDeviceSettings.Add('EnablePreBootPinExceptionOnDECapableDevice_Name', $policySettings.DeviceSettings.enablePreBootPinExceptionOnDECapableDevice_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.enhancedPIN_Name)
            {
                $complexDeviceSettings.Add('EnhancedPIN_Name', $policySettings.DeviceSettings.enhancedPIN_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSRecoveryUsage_Name)
            {
                $complexDeviceSettings.Add('OSRecoveryUsage_Name', $policySettings.DeviceSettings.OSRecoveryUsage_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSRequireActiveDirectoryBackup_Name)
            {
                $complexDeviceSettings.Add('OSRequireActiveDirectoryBackup_Name', $policySettings.DeviceSettings.OSRequireActiveDirectoryBackup_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSActiveDirectoryBackup_Name)
            {
                $complexDeviceSettings.Add('OSActiveDirectoryBackup_Name', $policySettings.DeviceSettings.OSActiveDirectoryBackup_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSRecoveryPasswordUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('OSRecoveryPasswordUsageDropDown_Name', $policySettings.DeviceSettings.OSRecoveryPasswordUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSHideRecoveryPage_Name)
            {
                $complexDeviceSettings.Add('OSHideRecoveryPage_Name', $policySettings.DeviceSettings.OSHideRecoveryPage_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSAllowDRA_Name)
            {
                $complexDeviceSettings.Add('OSAllowDRA_Name', $policySettings.DeviceSettings.OSAllowDRA_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSRecoveryKeyUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('OSRecoveryKeyUsageDropDown_Name', $policySettings.DeviceSettings.OSRecoveryKeyUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSActiveDirectoryBackupDropDown_Name)
            {
                $complexDeviceSettings.Add('OSActiveDirectoryBackupDropDown_Name', $policySettings.DeviceSettings.OSActiveDirectoryBackupDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.enablePrebootInputProtectorsOnSlates_Name)
            {
                $complexDeviceSettings.Add('EnablePrebootInputProtectorsOnSlates_Name', $policySettings.DeviceSettings.enablePrebootInputProtectorsOnSlates_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSEncryptionType_Name)
            {
                $complexDeviceSettings.Add('OSEncryptionType_Name', $policySettings.DeviceSettings.OSEncryptionType_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.OSEncryptionTypeDropDown_Name)
            {
                $complexDeviceSettings.Add('OSEncryptionTypeDropDown_Name', $policySettings.DeviceSettings.OSEncryptionTypeDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configureAdvancedStartup_Name)
            {
                $complexDeviceSettings.Add('ConfigureAdvancedStartup_Name', $policySettings.DeviceSettings.configureAdvancedStartup_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configureTPMStartupKeyUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('ConfigureTPMStartupKeyUsageDropDown_Name', $policySettings.DeviceSettings.configureTPMStartupKeyUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configureTPMPINKeyUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('ConfigureTPMPINKeyUsageDropDown_Name', $policySettings.DeviceSettings.configureTPMPINKeyUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configureTPMUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('ConfigureTPMUsageDropDown_Name', $policySettings.DeviceSettings.configureTPMUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configureNonTPMStartupKeyUsage_Name)
            {
                $complexDeviceSettings.Add('ConfigureNonTPMStartupKeyUsage_Name', $policySettings.DeviceSettings.configureNonTPMStartupKeyUsage_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.configurePINUsageDropDown_Name)
            {
                $complexDeviceSettings.Add('ConfigurePINUsageDropDown_Name', $policySettings.DeviceSettings.configurePINUsageDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVConfigureBDE)
            {
                $complexDeviceSettings.Add('RDVConfigureBDE', $policySettings.DeviceSettings.RDVConfigureBDE)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVAllowBDE_Name)
            {
                $complexDeviceSettings.Add('RDVAllowBDE_Name', $policySettings.DeviceSettings.RDVAllowBDE_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVEncryptionType_Name)
            {
                $complexDeviceSettings.Add('RDVEncryptionType_Name', $policySettings.DeviceSettings.RDVEncryptionType_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVEncryptionTypeDropDown_Name)
            {
                $complexDeviceSettings.Add('RDVEncryptionTypeDropDown_Name', $policySettings.DeviceSettings.RDVEncryptionTypeDropDown_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVDisableBDE_Name)
            {
                $complexDeviceSettings.Add('RDVDisableBDE_Name', $policySettings.DeviceSettings.RDVDisableBDE_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVDenyWriteAccess_Name)
            {
                $complexDeviceSettings.Add('RDVDenyWriteAccess_Name', $policySettings.DeviceSettings.RDVDenyWriteAccess_Name)
            }
            if ($null -ne $policySettings.DeviceSettings.RDVCrossOrg)
            {
                $complexDeviceSettings.Add('RDVCrossOrg', $policySettings.DeviceSettings.RDVCrossOrg)
            }
            if ($null -ne $policySettings.DeviceSettings.EnableSmartScreen)
            {
                $complexDeviceSettings.Add('EnableSmartScreen', $policySettings.DeviceSettings.EnableSmartScreen)
            }
            if ($null -ne $policySettings.DeviceSettings.EnableSmartScreenDropdown)
            {
                $complexDeviceSettings.Add('EnableSmartScreenDropdown', $policySettings.DeviceSettings.EnableSmartScreenDropdown)
            }
            if ($null -ne $policySettings.DeviceSettings.DisableSafetyFilterOverrideForAppRepUnknown)
            {
                $complexDeviceSettings.Add('DisableSafetyFilterOverrideForAppRepUnknown', $policySettings.DeviceSettings.DisableSafetyFilterOverrideForAppRepUnknown)
            }
            if ($null -ne $policySettings.DeviceSettings.Disable_Managing_Safety_Filter_IE9)
            {
                $complexDeviceSettings.Add('Disable_Managing_Safety_Filter_IE9', $policySettings.DeviceSettings.Disable_Managing_Safety_Filter_IE9)
            }
            if ($null -ne $policySettings.DeviceSettings.IE9SafetyFilterOptions)
            {
                $complexDeviceSettings.Add('IE9SafetyFilterOptions', $policySettings.DeviceSettings.IE9SafetyFilterOptions)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowWarningForOtherDiskEncryption)
            {
                $complexDeviceSettings.Add('AllowWarningForOtherDiskEncryption', $policySettings.DeviceSettings.AllowWarningForOtherDiskEncryption)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowStandardUserEncryption)
            {
                $complexDeviceSettings.Add('AllowStandardUserEncryption', $policySettings.DeviceSettings.AllowStandardUserEncryption)
            }
            if ($null -ne $policySettings.DeviceSettings.ConfigureRecoveryPasswordRotation)
            {
                $complexDeviceSettings.Add('ConfigureRecoveryPasswordRotation', $policySettings.DeviceSettings.ConfigureRecoveryPasswordRotation)
            }
            if ($null -ne $policySettings.DeviceSettings.RequireDeviceEncryption)
            {
                $complexDeviceSettings.Add('RequireDeviceEncryption', $policySettings.DeviceSettings.RequireDeviceEncryption)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowArchiveScanning)
            {
                $complexDeviceSettings.Add('AllowArchiveScanning', $policySettings.DeviceSettings.AllowArchiveScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowBehaviorMonitoring)
            {
                $complexDeviceSettings.Add('AllowBehaviorMonitoring', $policySettings.DeviceSettings.AllowBehaviorMonitoring)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowCloudProtection)
            {
                $complexDeviceSettings.Add('AllowCloudProtection', $policySettings.DeviceSettings.AllowCloudProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowEmailScanning)
            {
                $complexDeviceSettings.Add('AllowEmailScanning', $policySettings.DeviceSettings.AllowEmailScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowFullScanRemovableDriveScanning)
            {
                $complexDeviceSettings.Add('AllowFullScanRemovableDriveScanning', $policySettings.DeviceSettings.AllowFullScanRemovableDriveScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowOnAccessProtection)
            {
                $complexDeviceSettings.Add('AllowOnAccessProtection', $policySettings.DeviceSettings.AllowOnAccessProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowRealtimeMonitoring)
            {
                $complexDeviceSettings.Add('AllowRealtimeMonitoring', $policySettings.DeviceSettings.AllowRealtimeMonitoring)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowScanningNetworkFiles)
            {
                $complexDeviceSettings.Add('AllowScanningNetworkFiles', $policySettings.DeviceSettings.AllowScanningNetworkFiles)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowIOAVProtection)
            {
                $complexDeviceSettings.Add('AllowIOAVProtection', $policySettings.DeviceSettings.AllowIOAVProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowScriptScanning)
            {
                $complexDeviceSettings.Add('AllowScriptScanning', $policySettings.DeviceSettings.AllowScriptScanning)
            }
            if ($null -ne $policySettings.DeviceSettings.AllowUserUIAccess)
            {
                $complexDeviceSettings.Add('AllowUserUIAccess', $policySettings.DeviceSettings.AllowUserUIAccess)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutionOfPotentiallyObfuscatedScripts)
            {
                $complexDeviceSettings.Add('BlockExecutionOfPotentiallyObfuscatedScripts', $policySettings.DeviceSettings.BlockExecutionOfPotentiallyObfuscatedScripts)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockWin32APICallsFromOfficeMacros)
            {
                $complexDeviceSettings.Add('BlockWin32APICallsFromOfficeMacros', $policySettings.DeviceSettings.BlockWin32APICallsFromOfficeMacros)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion)
            {
                $complexDeviceSettings.Add('BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion', $policySettings.DeviceSettings.BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeCommunicationAppFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockOfficeCommunicationAppFromCreatingChildProcesses', $policySettings.DeviceSettings.BlockOfficeCommunicationAppFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAllOfficeApplicationsFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockAllOfficeApplicationsFromCreatingChildProcesses', $policySettings.DeviceSettings.BlockAllOfficeApplicationsFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAdobeReaderFromCreatingChildProcesses)
            {
                $complexDeviceSettings.Add('BlockAdobeReaderFromCreatingChildProcesses', $policySettings.DeviceSettings.BlockAdobeReaderFromCreatingChildProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem)
            {
                $complexDeviceSettings.Add('BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem', $policySettings.DeviceSettings.BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent)
            {
                $complexDeviceSettings.Add('BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent', $policySettings.DeviceSettings.BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockWebshellCreationForServers)
            {
                $complexDeviceSettings.Add('BlockWebshellCreationForServers', $policySettings.DeviceSettings.BlockWebshellCreationForServers)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockWebshellCreationForServers_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockWebshellCreationForServers_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockWebshellCreationForServers_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockUntrustedUnsignedProcessesThatRunFromUSB)
            {
                $complexDeviceSettings.Add('BlockUntrustedUnsignedProcessesThatRunFromUSB', $policySettings.DeviceSettings.BlockUntrustedUnsignedProcessesThatRunFromUSB)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockPersistenceThroughWMIEventSubscription)
            {
                $complexDeviceSettings.Add('BlockPersistenceThroughWMIEventSubscription', $policySettings.DeviceSettings.BlockPersistenceThroughWMIEventSubscription)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockUseOfCopiedOrImpersonatedSystemTools)
            {
                $complexDeviceSettings.Add('BlockUseOfCopiedOrImpersonatedSystemTools', $policySettings.DeviceSettings.BlockUseOfCopiedOrImpersonatedSystemTools)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAbuseOfExploitedVulnerableSignedDrivers)
            {
                $complexDeviceSettings.Add('BlockAbuseOfExploitedVulnerableSignedDrivers', $policySettings.DeviceSettings.BlockAbuseOfExploitedVulnerableSignedDrivers)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockProcessCreationsFromPSExecAndWMICommands)
            {
                $complexDeviceSettings.Add('BlockProcessCreationsFromPSExecAndWMICommands', $policySettings.DeviceSettings.BlockProcessCreationsFromPSExecAndWMICommands)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeApplicationsFromCreatingExecutableContent)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromCreatingExecutableContent', $policySettings.DeviceSettings.BlockOfficeApplicationsFromCreatingExecutableContent)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses', $policySettings.DeviceSettings.BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockRebootingMachineInSafeMode)
            {
                $complexDeviceSettings.Add('BlockRebootingMachineInSafeMode', $policySettings.DeviceSettings.BlockRebootingMachineInSafeMode)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.UseAdvancedProtectionAgainstRansomware)
            {
                $complexDeviceSettings.Add('UseAdvancedProtectionAgainstRansomware', $policySettings.DeviceSettings.UseAdvancedProtectionAgainstRansomware)
            }
            if ($null -ne $policySettings.DeviceSettings.UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutableContentFromEmailClientAndWebmail)
            {
                $complexDeviceSettings.Add('BlockExecutableContentFromEmailClientAndWebmail', $policySettings.DeviceSettings.BlockExecutableContentFromEmailClientAndWebmail)
            }
            if ($null -ne $policySettings.DeviceSettings.BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions)
            {
                $complexDeviceSettings.Add('BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions', $policySettings.DeviceSettings.BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions)
            }
            if ($null -ne $policySettings.DeviceSettings.CheckForSignaturesBeforeRunningScan)
            {
                $complexDeviceSettings.Add('CheckForSignaturesBeforeRunningScan', $policySettings.DeviceSettings.CheckForSignaturesBeforeRunningScan)
            }
            if ($null -ne $policySettings.DeviceSettings.CloudBlockLevel)
            {
                $complexDeviceSettings.Add('CloudBlockLevel', $policySettings.DeviceSettings.CloudBlockLevel)
            }
            if ($null -ne $policySettings.DeviceSettings.CloudExtendedTimeout)
            {
                $complexDeviceSettings.Add('CloudExtendedTimeout', $policySettings.DeviceSettings.CloudExtendedTimeout)
            }
            if ($null -ne $policySettings.DeviceSettings.DisableLocalAdminMerge)
            {
                $complexDeviceSettings.Add('DisableLocalAdminMerge', $policySettings.DeviceSettings.DisableLocalAdminMerge)
            }
            if ($null -ne $policySettings.DeviceSettings.EnableNetworkProtection)
            {
                $complexDeviceSettings.Add('EnableNetworkProtection', $policySettings.DeviceSettings.EnableNetworkProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.HideExclusionsFromLocalAdmins)
            {
                $complexDeviceSettings.Add('HideExclusionsFromLocalAdmins', $policySettings.DeviceSettings.HideExclusionsFromLocalAdmins)
            }
            if ($null -ne $policySettings.DeviceSettings.HideExclusionsFromLocalUsers)
            {
                $complexDeviceSettings.Add('HideExclusionsFromLocalUsers', $policySettings.DeviceSettings.HideExclusionsFromLocalUsers)
            }
            if ($null -ne $policySettings.DeviceSettings.OobeEnableRtpAndSigUpdate)
            {
                $complexDeviceSettings.Add('OobeEnableRtpAndSigUpdate', $policySettings.DeviceSettings.OobeEnableRtpAndSigUpdate)
            }
            if ($null -ne $policySettings.DeviceSettings.PUAProtection)
            {
                $complexDeviceSettings.Add('PUAProtection', $policySettings.DeviceSettings.PUAProtection)
            }
            if ($null -ne $policySettings.DeviceSettings.RealTimeScanDirection)
            {
                $complexDeviceSettings.Add('RealTimeScanDirection', $policySettings.DeviceSettings.RealTimeScanDirection)
            }
            if ($null -ne $policySettings.DeviceSettings.ScanParameter)
            {
                $complexDeviceSettings.Add('ScanParameter', $policySettings.DeviceSettings.ScanParameter)
            }
            if ($null -ne $policySettings.DeviceSettings.ScheduleQuickScanTime)
            {
                $complexDeviceSettings.Add('ScheduleQuickScanTime', $policySettings.DeviceSettings.ScheduleQuickScanTime)
            }
            if ($null -ne $policySettings.DeviceSettings.ScheduleScanDay)
            {
                $complexDeviceSettings.Add('ScheduleScanDay', $policySettings.DeviceSettings.ScheduleScanDay)
            }
            if ($null -ne $policySettings.DeviceSettings.ScheduleScanTime)
            {
                $complexDeviceSettings.Add('ScheduleScanTime', $policySettings.DeviceSettings.ScheduleScanTime)
            }
            if ($null -ne $policySettings.DeviceSettings.SignatureUpdateInterval)
            {
                $complexDeviceSettings.Add('SignatureUpdateInterval', $policySettings.DeviceSettings.SignatureUpdateInterval)
            }
            if ($null -ne $policySettings.DeviceSettings.SubmitSamplesConsent)
            {
                $complexDeviceSettings.Add('SubmitSamplesConsent', $policySettings.DeviceSettings.SubmitSamplesConsent)
            }
            if ($null -ne $policySettings.DeviceSettings.LsaCfgFlags)
            {
                $complexDeviceSettings.Add('LsaCfgFlags', $policySettings.DeviceSettings.LsaCfgFlags)
            }
            if ($null -ne $policySettings.DeviceSettings.DeviceEnumerationPolicy)
            {
                $complexDeviceSettings.Add('DeviceEnumerationPolicy', $policySettings.DeviceSettings.DeviceEnumerationPolicy)
            }
            if ($null -ne $policySettings.DeviceSettings.SmartScreenEnabled)
            {
                $complexDeviceSettings.Add('SmartScreenEnabled', $policySettings.DeviceSettings.SmartScreenEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.SmartScreenPuaEnabled)
            {
                $complexDeviceSettings.Add('SmartScreenPuaEnabled', $policySettings.DeviceSettings.SmartScreenPuaEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.SmartScreenDnsRequestsEnabled)
            {
                $complexDeviceSettings.Add('SmartScreenDnsRequestsEnabled', $policySettings.DeviceSettings.SmartScreenDnsRequestsEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.NewSmartScreenLibraryEnabled)
            {
                $complexDeviceSettings.Add('NewSmartScreenLibraryEnabled', $policySettings.DeviceSettings.NewSmartScreenLibraryEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.SmartScreenForTrustedDownloadsEnabled)
            {
                $complexDeviceSettings.Add('SmartScreenForTrustedDownloadsEnabled', $policySettings.DeviceSettings.SmartScreenForTrustedDownloadsEnabled)
            }
            if ($null -ne $policySettings.DeviceSettings.PreventSmartScreenPromptOverride)
            {
                $complexDeviceSettings.Add('PreventSmartScreenPromptOverride', $policySettings.DeviceSettings.PreventSmartScreenPromptOverride)
            }
            if ($null -ne $policySettings.DeviceSettings.PreventSmartScreenPromptOverrideForFiles)
            {
                $complexDeviceSettings.Add('PreventSmartScreenPromptOverrideForFiles', $policySettings.DeviceSettings.PreventSmartScreenPromptOverrideForFiles)
            }

            # Check if $complexDeviceSettings is empty
            if ($complexDeviceSettings.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceSettings = $null
            }
            $policySettings.Remove('DeviceSettings') | Out-Null

            $complexUserSettings = [ordered]@{}

            # Add user settings with conditional checks
            if ($null -ne $policySettings.UserSettings.DisableSafetyFilterOverrideForAppRepUnknown)
            {
                $complexUserSettings.Add('DisableSafetyFilterOverrideForAppRepUnknown', $policySettings.UserSettings.DisableSafetyFilterOverrideForAppRepUnknown)
            }

            # Check if $complexUserSettings is empty
            if ($complexUserSettings.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserSettings = $null
            }
            $policySettings.Remove('UserSettings') | Out-Null
            #endregion

            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                DeviceSettings        = $complexDeviceSettings
                UserSettings          = $complexUserSettings
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
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

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '49b8320f-e179-472e-8e2c-2fde00289ca2_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Security Baseline Defender For Endpoint with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Security Baseline Defender For Endpoint with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Security Baseline Defender For Endpoint with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
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
            $policyTemplateID = '49b8320f-e179-472e-8e2c-2fde00289ca2_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
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
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.Name
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

                if ($null -ne $Results.DeviceSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineDefenderForEndpoint'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.UserSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineDefenderForEndpoint'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserSettings') | Out-Null
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
                    -NoEscape @('DeviceSettings', 'UserSettings', 'Assignments') `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneSecurityBaselineDefenderForEndpoint] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSecurityBaselineDefenderForEndpoint])
        {
            return $Values
        }

        $result = [IntuneSecurityBaselineDefenderForEndpoint]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineDefenderForEndpoint
{
    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices using drivers that match these device setup classes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DeviceInstall_Classes_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Prevented Classes - Depends on DeviceInstall_Classes_Deny')]
    [System.String[]] $DeviceInstall_Classes_Deny_List

    [DscProperty()]
    [System.ComponentModel.Description('Also apply to matching devices that are already installed. - Depends on DeviceInstall_Classes_Deny (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DeviceInstall_Classes_Deny_Retroactive

    [DscProperty()]
    [System.ComponentModel.Description('Choose drive encryption method and cipher strength (Windows 10 [Version 1511] and later) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EncryptionMethodWithXts_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for operating system drives: - Depends on EncryptionMethodWithXts_Name (3: AES-CBC 128-bit, 4: AES-CBC 256-bit, 6: XTS-AES 128-bit (default), 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsOsDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for fixed data drives: - Depends on EncryptionMethodWithXts_Name (3: AES-CBC 128-bit, 4: AES-CBC 256-bit, 6: XTS-AES 128-bit (default), 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsFdvDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for removable data drives: - Depends on EncryptionMethodWithXts_Name (3: AES-CBC 128-bit  (default), 4: AES-CBC 256-bit, 6: XTS-AES 128-bit, 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsRdvDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Choose how BitLocker-protected fixed drives can be recovered (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVRecoveryUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Save BitLocker recovery information to AD DS for fixed data drives - Depends on FDVRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Omit recovery options from the BitLocker setup wizard - Depends on FDVRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVHideRecoveryPage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure user storage of BitLocker recovery information: - Depends on FDVRecoveryUsage_Name (2: Allow 48-digit recovery password, 1: Require 48-digit recovery password, 0: Do not allow 48-digit recovery password)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $FDVRecoveryPasswordUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not enable BitLocker until recovery information is stored to AD DS for fixed data drives - Depends on FDVRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVRequireActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow data recovery agent - Depends on FDVRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVAllowDRA_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure storage of BitLocker recovery information to AD DS: - Depends on FDVRecoveryUsage_Name (1: Backup recovery passwords and key packages, 2: Backup recovery passwords only)')]
    [ValidateSet('1', '2')]
    [System.String] $FDVActiveDirectoryBackupDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on FDVRecoveryUsage_Name (2: Allow 256-bit recovery key, 1: Require 256-bit recovery key, 0: Do not allow 256-bit recovery key)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $FDVRecoveryKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Deny write access to fixed drives not protected by BitLocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVDenyWriteAccess_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on fixed data drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $FDVEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) - Depends on FDVEncryptionType_Name (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $FDVEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow devices compliant with InstantGo or HSTI to opt out of pre-boot PIN. (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnablePreBootPinExceptionOnDECapableDevice_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow enhanced PINs for startup (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnhancedPIN_Name

    [DscProperty()]
    [System.ComponentModel.Description('Choose how BitLocker-protected operating system drives can be recovered (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSRecoveryUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not enable BitLocker until recovery information is stored to AD DS for operating system drives - Depends on OSRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSRequireActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Save BitLocker recovery information to AD DS for operating system drives - Depends on OSRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure user storage of BitLocker recovery information: - Depends on OSRecoveryUsage_Name (2: Allow 48-digit recovery password, 1: Require 48-digit recovery password, 0: Do not allow 48-digit recovery password)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $OSRecoveryPasswordUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Omit recovery options from the BitLocker setup wizard - Depends on OSRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSHideRecoveryPage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow data recovery agent - Depends on OSRecoveryUsage_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSAllowDRA_Name

    [DscProperty()]
    [System.ComponentModel.Description(' - Depends on OSRecoveryUsage_Name (2: Allow 256-bit recovery key, 1: Require 256-bit recovery key, 0: Do not allow 256-bit recovery key)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $OSRecoveryKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure storage of BitLocker recovery information to AD DS: - Depends on OSRecoveryUsage_Name (1: Store recovery passwords and key packages, 2: Store recovery passwords only)')]
    [ValidateSet('1', '2')]
    [System.String] $OSActiveDirectoryBackupDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enable use of BitLocker authentication requiring preboot keyboard input on slates (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnablePrebootInputProtectorsOnSlates_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on operating system drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $OSEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) - Depends on OSEncryptionType_Name (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $OSEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Require additional authentication at startup (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ConfigureAdvancedStartup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup key: - Depends on ConfigureAdvancedStartup_Name (2: Allow startup key with TPM, 1: Require startup key with TPM, 0: Do not allow startup key with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMStartupKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup key and PIN: - Depends on ConfigureAdvancedStartup_Name (2: Allow startup key and PIN with TPM, 1: Require startup key and PIN with TPM, 0: Do not allow startup key and PIN with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMPINKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup: - Depends on ConfigureAdvancedStartup_Name (2: Allow TPM, 1: Require TPM, 0: Do not allow TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow BitLocker without a compatible TPM (requires a password or a startup key on a USB flash drive) - Depends on ConfigureAdvancedStartup_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ConfigureNonTPMStartupKeyUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup PIN: - Depends on ConfigureAdvancedStartup_Name (2: Allow startup PIN with TPM, 1: Require startup PIN with TPM, 0: Do not allow startup PIN with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigurePINUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Control use of BitLocker on removable drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVConfigureBDE

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to apply BitLocker protection on removable data drives (Device) - Depends on RDVConfigureBDE (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVAllowBDE_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on removable data drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $RDVEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to suspend and decrypt BitLocker protection on removable data drives (Device) - Depends on RDVConfigureBDE (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVDisableBDE_Name

    [DscProperty()]
    [System.ComponentModel.Description('Deny write access to removable drives not protected by BitLocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVDenyWriteAccess_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow write access to devices configured in another organization - Depends on RDVDenyWriteAccess_Name (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RDVCrossOrg

    [DscProperty()]
    [System.ComponentModel.Description('Configure Windows Defender SmartScreen (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableSmartScreen

    [DscProperty()]
    [System.ComponentModel.Description('Pick one of the following settings: (Device) - Depends on EnableSmartScreen (block: Warn and prevent bypass, warn: Warn)')]
    [ValidateSet('Block', 'Warn')]
    [System.String] $EnableSmartScreenDropdown

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing SmartScreen Filter warnings about files that are not commonly downloaded from the Internet (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableSafetyFilterOverrideForAppRepUnknown

    [DscProperty()]
    [System.ComponentModel.Description('Prevent managing SmartScreen Filter (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $Disable_Managing_Safety_Filter_IE9

    [DscProperty()]
    [System.ComponentModel.Description('Select SmartScreen Filter mode - Depends on Disable_Managing_Safety_Filter_IE9 (0: Off, 1: On)')]
    [ValidateSet('0', '1')]
    [System.String] $IE9SafetyFilterOptions

    [DscProperty()]
    [System.ComponentModel.Description('Allow Warning For Other Disk Encryption (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowWarningForOtherDiskEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allow Standard User Encryption - Depends on AllowWarningForOtherDiskEncryption (0: This is the default, when the policy is not set. If current logged on user is a standard user, ''RequireDeviceEncryption'' policy will not try to enable encryption on any drive., 1: ''RequireDeviceEncryption'' policy will try to enable encryption on all fixed drives even if a current logged in user is standard user.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowStandardUserEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Configure Recovery Password Rotation (0: Refresh off (default), 1: Refresh on for Azure AD-joined devices, 2: Refresh on for both Azure AD-joined and hybrid-joined devices)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $ConfigureRecoveryPasswordRotation

    [DscProperty()]
    [System.ComponentModel.Description('Require Device Encryption (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $RequireDeviceEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allow Archive Scanning (0: Not allowed. Turns off scanning on archived files., 1: Allowed. Scans the archive files.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowArchiveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow Behavior Monitoring (0: Not allowed. Turns off behavior monitoring., 1: Allowed. Turns on real-time behavior monitoring.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowBehaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allow Cloud Protection (0: Not allowed. Turns off the Microsoft Active Protection Service., 1: Allowed. Turns on the Microsoft Active Protection Service.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowCloudProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Email Scanning (0: Not allowed. Turns off email scanning., 1: Allowed. Turns on email scanning.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowEmailScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow Full Scan Removable Drive Scanning (0: Not allowed. Turns off scanning on removable drives., 1: Allowed. Scans removable drives.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanRemovableDriveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow On Access Protection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Realtime Monitoring (0: Not allowed. Turns off the real-time monitoring service., 1: Allowed. Turns on and runs the real-time monitoring service.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowRealtimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allow Scanning Network Files (0: Not allowed. Turns off scanning of network files., 1: Allowed. Scans network files.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScanningNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allow scanning of all downloaded files and attachments (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIOAVProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Script Scanning (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScriptScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow User UI Access (0: Not allowed. Prevents users from accessing UI., 1: Allowed. Lets users access UI.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUserUIAccess

    [DscProperty()]
    [System.ComponentModel.Description('Block execution of potentially obfuscated scripts - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutionOfPotentiallyObfuscatedScripts

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Win32 API calls from Office macros - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWin32APICallsFromOfficeMacros

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block executable files from running unless they meet a prevalence, age, or trusted list criterion - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office communication application from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeCommunicationAppFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block all Office applications from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAllOfficeApplicationsFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Adobe Reader from creating child processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAdobeReaderFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block credential stealing from the Windows local security authority subsystem - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block JavaScript or VBScript from launching downloaded executable content - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Webshell creation for Servers - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWebshellCreationForServers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWebshellCreationForServers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block untrusted and unsigned processes that run from USB - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUntrustedUnsignedProcessesThatRunFromUSB

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block persistence through WMI event subscription - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockPersistenceThroughWMIEventSubscription

    [DscProperty()]
    [System.ComponentModel.Description('[PREVIEW] Block use of copied or impersonated system tools - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUseOfCopiedOrImpersonatedSystemTools

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block abuse of exploited vulnerable signed drivers (Device) - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAbuseOfExploitedVulnerableSignedDrivers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block process creations originating from PSExec and WMI commands - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockProcessCreationsFromPSExecAndWMICommands

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office applications from creating executable content - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromCreatingExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block Office applications from injecting code into other processes - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('[PREVIEW] Block rebooting machine in Safe Mode - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockRebootingMachineInSafeMode

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Use advanced protection against ransomware - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $UseAdvancedProtectionAgainstRansomware

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Block executable content from email client and webmail - Depends on AttackSurfaceReductionRules (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableContentFromEmailClientAndWebmail

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Check For Signatures Before Running Scan (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $CheckForSignaturesBeforeRunningScan

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Block Level (0: NotConfigured, 2: High, 4: HighPlus, 6: ZeroTolerance)')]
    [ValidateSet('0', '2', '4', '6')]
    [System.Nullable[System.Int32]] $CloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Extended Timeout')]
    [System.Nullable[System.Int32]] $CloudExtendedTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Disable Local Admin Merge (0: Enable Local Admin Merge, 1: Disable Local Admin Merge)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableLocalAdminMerge

    [DscProperty()]
    [System.ComponentModel.Description('Enable Network Protection (0: Disabled, 1: Enabled (block mode), 2: Enabled (audit mode))')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $EnableNetworkProtection

    [DscProperty()]
    [System.ComponentModel.Description('Hide Exclusions From Local Admins (1: If you enable this setting, local admins will no longer be able to see the exclusion list in Windows Security App or via PowerShell., 0: If you disable or do not configure this setting, local admins will be able to see exclusions in the Windows Security App and via PowerShell.)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $HideExclusionsFromLocalAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Hide Exclusions From Local Users (1: If you enable this setting, local users will no longer be able to see the exclusion list in Windows Security App or via PowerShell., 0: If you disable or do not configure this setting, local users will be able to see exclusions in the Windows Security App and via PowerShell.)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $HideExclusionsFromLocalUsers

    [DscProperty()]
    [System.ComponentModel.Description('Oobe Enable Rtp And Sig Update (1: If you enable this setting, real-time protection and Security Intelligence Updates are enabled during OOBE., 0: If you either disable or do not configure this setting, real-time protection and Security Intelligence Updates during OOBE is not enabled.)')]
    [ValidateSet('1', '0')]
    [System.Nullable[System.Int32]] $OobeEnableRtpAndSigUpdate

    [DscProperty()]
    [System.ComponentModel.Description('PUA Protection (0: PUA Protection off. Windows Defender will not protect against potentially unwanted applications., 1: PUA Protection on. Detected items are blocked. They will show in history along with other threats., 2: Audit mode. Windows Defender will detect potentially unwanted applications, but take no action. You can review information about the applications Windows Defender would have taken action against by searching for events created by Windows Defender in the Event Viewer.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $PUAProtection

    [DscProperty()]
    [System.ComponentModel.Description('Real Time Scan Direction (0: Monitor all files (bi-directional)., 1: Monitor incoming files., 2: Monitor outgoing files.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $RealTimeScanDirection

    [DscProperty()]
    [System.ComponentModel.Description('Scan Parameter (1: Quick scan, 2: Full scan)')]
    [ValidateSet('1', '2')]
    [System.Nullable[System.Int32]] $ScanParameter

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Quick Scan Time')]
    [System.Nullable[System.Int32]] $ScheduleQuickScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Scan Day (0: Every day, 1: Sunday, 2: Monday, 3: Tuesday, 4: Wednesday, 5: Thursday, 6: Friday, 7: Saturday, 8: No scheduled scan)')]
    [ValidateSet('0', '1', '2', '3', '4', '5', '6', '7', '8')]
    [System.Nullable[System.Int32]] $ScheduleScanDay

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Scan Time')]
    [System.Nullable[System.Int32]] $ScheduleScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Signature Update Interval')]
    [System.Nullable[System.Int32]] $SignatureUpdateInterval

    [DscProperty()]
    [System.ComponentModel.Description('Submit Samples Consent (0: Always prompt., 1: Send safe samples automatically., 2: Never send., 3: Send all samples automatically.)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $SubmitSamplesConsent

    [DscProperty()]
    [System.ComponentModel.Description('Credential Guard (0: (Disabled) Turns off Credential Guard remotely if configured previously without UEFI Lock., 1: (Enabled with UEFI lock) Turns on Credential Guard with UEFI lock., 2: (Enabled without lock) Turns on Credential Guard without UEFI lock.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $LsaCfgFlags

    [DscProperty()]
    [System.ComponentModel.Description('Device Enumeration Policy (0: Block all (Most restrictive), 1: Only after log in/screen unlock, 2: Allow all (Least restrictive))')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $DeviceEnumerationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Configure Microsoft Defender SmartScreen (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configure Microsoft Defender SmartScreen to block potentially unwanted apps (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenPuaEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable Microsoft Defender SmartScreen DNS requests (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenDnsRequestsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable new SmartScreen library (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $NewSmartScreenLibraryEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Force Microsoft Defender SmartScreen checks on downloads from trusted sources (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenForTrustedDownloadsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing Microsoft Defender SmartScreen prompts for sites (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $PreventSmartScreenPromptOverride

    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing of Microsoft Defender SmartScreen warnings about downloads (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $PreventSmartScreenPromptOverrideForFiles
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineDefenderForEndpoint
{
    [DscProperty()]
    [System.ComponentModel.Description('Prevent bypassing SmartScreen Filter warnings about files that are not commonly downloaded from the Internet (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableSafetyFilterOverrideForAppRepUnknown
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
