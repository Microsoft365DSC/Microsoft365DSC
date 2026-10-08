using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAntivirusPolicyWindows10ConfigMgr : M365DSCResourceBase
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
    [System.ComponentModel.Description('Allow Full Scan On Mapped Network Drives (0: Not allowed. Disables scanning on mapped network drives., 1: Allowed. Scans mapped network drives.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanOnMappedNetworkDrives

    [DscProperty()]
    [System.ComponentModel.Description('Allow Full Scan Removable Drive Scanning (0: Not allowed. Turns off scanning on removable drives., 1: Allowed. Scans removable drives.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowFullScanRemovableDriveScanning

    [DscProperty()]
    [System.ComponentModel.Description('[Deprecated] Allow Intrusion Prevention System (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIntrusionPreventionSystem

    [DscProperty()]
    [System.ComponentModel.Description('Allow scanning of all downloaded files and attachments (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowIOAVProtection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Realtime Monitoring (0: Not allowed. Turns off the real-time monitoring service., 1: Allowed. Turns on and runs the real-time monitoring service.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowRealtimeMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Allow Scanning Network Files (0: Not allowed. Turns off scanning of network files., 1: Allowed. Scans network files.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScanningNetworkFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allow Script Scanning (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowScriptScanning

    [DscProperty()]
    [System.ComponentModel.Description('Allow User UI Access (0: Not allowed. Prevents users from accessing UI., 1: Allowed. Lets users access UI.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUserUIAccess

    [DscProperty()]
    [System.ComponentModel.Description('Avg CPU Load Factor')]
    [ValidateRange(0, 100)]
    [System.Nullable[System.Int32]] $AvgCPULoadFactor

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
    [ValidateRange(0, 50)]
    [System.Nullable[System.Int32]] $CloudExtendedTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Days To Retain Cleaned Malware')]
    [ValidateRange(0, 90)]
    [System.Nullable[System.Int32]] $DaysToRetainCleanedMalware

    [DscProperty()]
    [System.ComponentModel.Description('Disable Catchup Full Scan (0: Enabled, 1: Disabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableCatchupFullScan

    [DscProperty()]
    [System.ComponentModel.Description('Disable Catchup Quick Scan (0: Enabled, 1: Disabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableCatchupQuickScan

    [DscProperty()]
    [System.ComponentModel.Description('Enable Low CPU Priority (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $EnableLowCPUPriority

    [DscProperty()]
    [System.ComponentModel.Description('Excluded Extensions')]
    [System.String[]] $ExcludedExtensions

    [DscProperty()]
    [System.ComponentModel.Description('Excluded Paths')]
    [System.String[]] $ExcludedPaths

    [DscProperty()]
    [System.ComponentModel.Description('Excluded Processes')]
    [System.String[]] $ExcludedProcesses

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
    [ValidateRange(0, 1380)]
    [System.Nullable[System.Int32]] $ScheduleQuickScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Scan Day (0: Every day, 1: Sunday, 2: Monday, 3: Tuesday, 4: Wednesday, 5: Thursday, 6: Friday, 7: Saturday, 8: No scheduled scan)')]
    [ValidateSet('0', '1', '2', '3', '4', '5', '6', '7', '8')]
    [System.Nullable[System.Int32]] $ScheduleScanDay

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Scan Time')]
    [ValidateRange(0, 1380)]
    [System.Nullable[System.Int32]] $ScheduleScanTime

    [DscProperty()]
    [System.ComponentModel.Description('Signature Update Fallback Order')]
    [System.String[]] $SignatureUpdateFallbackOrder

    [DscProperty()]
    [System.ComponentModel.Description('Signature Update File Shares Sources')]
    [System.String[]] $SignatureUpdateFileSharesSources

    [DscProperty()]
    [System.ComponentModel.Description('Signature Update Interval')]
    [ValidateRange(0, 24)]
    [System.Nullable[System.Int32]] $SignatureUpdateInterval

    [DscProperty()]
    [System.ComponentModel.Description('Submit Samples Consent (0: Always prompt., 1: Send safe samples automatically., 2: Never send., 3: Send all samples automatically.)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.Nullable[System.Int32]] $SubmitSamplesConsent

    [DscProperty()]
    [System.ComponentModel.Description('Allow On Access Protection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowOnAccessProtection

    [DscProperty()]
    [System.ComponentModel.Description('Remediation action for High severity threats - Depends on ThreatSeverityDefaultAction (clean: Clean, quarantine: Quarantine, remove: Remove, allow: Allow, userdefined: UserDefined, block: Block)')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $HighSeverityThreatDefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('Remediation action for Severe threats - Depends on ThreatSeverityDefaultAction (clean: Clean, quarantine: Quarantine, remove: Remove, allow: Allow, userdefined: UserDefined, block: Block)')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $SevereThreatDefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('Remediation action for Low severity threats - Depends on ThreatSeverityDefaultAction (clean: Clean, quarantine: Quarantine, remove: Remove, allow: Allow, userdefined: UserDefined, block: Block)')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $LowSeverityThreatDefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('Remediation action for Moderate severity threats - Depends on ThreatSeverityDefaultAction (clean: Clean, quarantine: Quarantine, remove: Remove, allow: Allow, userdefined: UserDefined, block: Block)')]
    [ValidateSet('clean', 'quarantine', 'remove', 'allow', 'userdefined', 'block')]
    [System.String] $ModerateSeverityThreatDefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to view the full History results (0: No, 1: Yes)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisablePrivacyMode

    [DscProperty()]
    [System.ComponentModel.Description('Create a system restore point before computers are cleaned. (0: No, 1: Yes)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DisableRestorePoint

    [DscProperty()]
    [System.ComponentModel.Description('Randomize scheduled scan and security intelligence update start times. (0: No, 1: Yes)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $RandomizeScheduleTaskTimes

    [DscProperty()]
    [System.ComponentModel.Description('Security Intelligence Location')]
    [System.String] $SecurityIntelligenceLocation

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

    [IntuneAntivirusPolicyWindows10ConfigMgr] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAntivirusPolicyWindows10ConfigMgr]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Antivirus Policy for Windows10 Config Mgr with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Windows10 Config Mgr with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and creationSource eq 'SccmAV' and technologies eq 'configManager'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Windows10 Config Mgr with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Antivirus Policy for Windows10 Config Mgr with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

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
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            $disableRestorePointInstance = $settings | Where-Object { $_.SettingInstance.SettingDefinitionId -like '*_disablerestorepoint' }
            if ($null -ne $disableRestorePointInstance)
            {
                $policySettings.DisableRestorePoint = [int]$disableRestorePointInstance.SettingInstance.choiceSettingValue.value.Split('_')[-1]
            }

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
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

        Write-Verbose -Message "Setting configuration of the Intune Antivirus Policy for Windows10 Config Mgr with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('RandomizeScheduleTaskTimes') | Out-Null

        $templateReferenceId = '804339ad-1553-4478-a742-138fb5807418_1'
        $platforms = 'windows10'
        $technologies = 'configManager'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Antivirus Policy for Windows10 Config Mgr with DisplayName {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            [array]$settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            if ($this.GetBoundParameters().ContainsKey('DisableRestorePoint'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_disablerestorepoint_$($this.DisableRestorePoint)"
                        }
                        settingDefinitionId = 'defender_disablerestorepoint'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('RandomizeScheduleTaskTimes'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_randomizescheduletasktimes_$($this.RandomizeScheduleTaskTimes)"
                        }
                        settingDefinitionId = 'defender_randomizescheduletasktimes'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('SecurityIntelligenceLocation'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                        simpleSettingValue  = @{
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                            value         = "$($this.SecurityIntelligenceLocation)"
                        }
                        settingDefinitionId = 'device_vendor_msft_policy_config_defender_securityintelligencelocation'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('DisablePrivacyMode'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_disableprivacymode_$($this.DisablePrivacyMode)"
                        }
                        settingDefinitionId = 'defender_disableprivacymode'
                    }
                }
            }

            $createParameters = @{
                name            = $this.DisplayName
                description     = $this.Description
                creationSource  = 'SccmAV'
                platforms       = $platforms
                technologies    = $technologies
                settings        = $settings
                roleScopeTagIds = $resolvedRoleScopeTagIds
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
            Write-Verbose -Message "Updating the Intune Antivirus Policy for Windows10 Config Mgr with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            [array]$settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            if ($this.GetBoundParameters().ContainsKey('DisableRestorePoint'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_disablerestorepoint_$($this.DisableRestorePoint)"
                        }
                        settingDefinitionId = 'defender_disablerestorepoint'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('RandomizeScheduleTaskTimes'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_randomizescheduletasktimes_$($this.RandomizeScheduleTaskTimes)"
                        }
                        settingDefinitionId = 'defender_randomizescheduletasktimes'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('SecurityIntelligenceLocation'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                        simpleSettingValue  = @{
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                            value         = "$($this.SecurityIntelligenceLocation)"
                        }
                        settingDefinitionId = 'device_vendor_msft_policy_config_defender_securityintelligencelocation'
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('DisablePrivacyMode'))
            {
                $settings += @{
                    '@odata.type'   = '#microsoft.graph.deviceManagementConfigurationSetting'
                    settingInstance = @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue  = @{
                            children = @()
                            value    = "defender_disableprivacymode_$($this.DisablePrivacyMode)"
                        }
                        settingDefinitionId = 'defender_disableprivacymode'
                    }
                }
            }

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -CreationSource 'SccmAV' `
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
            Write-Verbose -Message "Removing the Intune Antivirus Policy for Windows10 Config Mgr with Id {$($currentInstance.Id)}"
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
            $baseFilter = "creationSource eq 'SccmAV' and technologies eq 'configManager'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                -Filter $mergedFilter `
                -All `
                -ExpandProperty 'assignments' `
                -ErrorAction Stop
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
                    -NoEscape @('Assignments') `
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

    hidden [IntuneAntivirusPolicyWindows10ConfigMgr] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAntivirusPolicyWindows10ConfigMgr])
        {
            return $Values
        }

        $result = [IntuneAntivirusPolicyWindows10ConfigMgr]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
