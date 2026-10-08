using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAntivirusPolicyLinux : M365DSCResourceBase
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
    [System.ComponentModel.Description('Enable cloud delivered protection (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $enabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable automatic sample submissions (none: None, safe: Safe, all: All)')]
    [ValidateSet('none', 'safe', 'all')]
    [System.String] $automaticSampleSubmissionConsent

    [DscProperty()]
    [System.ComponentModel.Description('Diagnostic data collection level (0: optional, 1: required)')]
    [ValidateSet('0', '1')]
    [System.String] $diagnosticLevel

    [DscProperty()]
    [System.ComponentModel.Description('Automatic security intelligence updates (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $automaticDefinitionUpdateEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enable real-time protection (deprecated) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $enableRealTimeProtection

    [DscProperty()]
    [System.ComponentModel.Description('Enable passive mode (deprecated) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $passiveMode

    [DscProperty()]
    [System.ComponentModel.Description('Scan history size')]
    [ValidateRange(5000, 15000)]
    [System.Nullable[System.Int32]] $scanHistoryMaximumItems

    [DscProperty()]
    [System.ComponentModel.Description('Scan results retention')]
    [ValidateRange(1, 180)]
    [System.Nullable[System.Int32]] $scanResultsRetentionDays

    [DscProperty()]
    [System.ComponentModel.Description('Exclusions merge (0: merge, 1: admin_only)')]
    [ValidateSet('0', '1')]
    [System.String] $exclusionsMergePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Scan exclusions')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions[]] $exclusions

    [DscProperty()]
    [System.ComponentModel.Description('Threat type settings')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings[]] $threatTypeSettings

    [DscProperty()]
    [System.ComponentModel.Description('Threat type settings merge (0: merge, 1: admin_only)')]
    [ValidateSet('0', '1')]
    [System.String] $threatTypeSettingsMergePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Allowed threats')]
    [System.String[]] $allowedThreats

    [DscProperty()]
    [System.ComponentModel.Description('Disallowed threat actions')]
    [System.String[]] $disallowedThreatActions

    [DscProperty()]
    [System.ComponentModel.Description('Enable scanning of archives (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $scanArchives

    [DscProperty()]
    [System.ComponentModel.Description('Enable scanning after definition update (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $scanAfterDefinitionUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Enable file hash computation (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $enableFileHashComputation

    [DscProperty()]
    [System.ComponentModel.Description('Enable behavior monitoring (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $behaviorMonitoring

    [DscProperty()]
    [System.ComponentModel.Description('Configure cloud block level (normal: Normal, moderate: Moderate, high: High, plus: High_Plus, tolerance: Zero_Tolerance)')]
    [ValidateSet('normal', 'moderate', 'high', 'plus', 'tolerance')]
    [System.String] $cloudBlockLevel

    [DscProperty()]
    [System.ComponentModel.Description('maximum on demand scan threads')]
    [ValidateRange(1, 64)]
    [System.Nullable[System.Int32]] $maximumOnDemandScanThreads

    [DscProperty()]
    [System.ComponentModel.Description('Enforcement Level (0: disabled, 1: audit, 2: block)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $networkprotection_enforcementLevel

    [DscProperty()]
    [System.ComponentModel.Description('Unmonitored Filesystems')]
    [System.String[]] $unmonitoredFilesystems

    [DscProperty()]
    [System.ComponentModel.Description('non execute mount mute (0: unmute, 1: mute)')]
    [ValidateSet('0', '1')]
    [System.String] $nonExecMountPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Enforcement Level (0: Realtime, 1: OnDemand, 2: Passive)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $antivirusengine_enforcementLevel

    [DscProperty()]
    [System.ComponentModel.Description('Enable offline security intelligence update (Disabled: Disabled, Enabled: Enabled)')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $antivirusengine_offlineDefinitionUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Security intelligence Update time interval (seconds). Must be between 0 and 86400.')]
    [ValidateRange(0, 86400)]
    [System.Nullable[System.Int32]] $definitionUpdatesInterval

    [DscProperty()]
    [System.ComponentModel.Description('Offline security intelligence update fallback to cloud')]
    [ValidateSet('false', 'true')]
    [System.String] $offlinedefinitionupdatefallbacktocloud

    [DscProperty()]
    [System.ComponentModel.Description('Offline security intelligence update URL or directory')]
    [System.String] $offlinedefinitionupdateurl

    [DscProperty()]
    [System.ComponentModel.Description('Schedule Signature Updates Before Running Scan (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $scheduledScan_checkForDefinitionsUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Daily Schedule scan time. Must be between 0 and 1380.')]
    [ValidateRange(0, 1380)]
    [System.Nullable[System.Int32]] $scheduledScan_dailyConfiguration_timeOfDay

    [DscProperty()]
    [System.ComponentModel.Description('Weekly Schedule scan day (0: Never, 1: Sunday, 2: Monday, 3: Tuesday, 4: Wednesday, 5: Thursday, 6: Friday, 7: Saturday, 8: Daily)')]
    [ValidateSet('0', '1', '2', '3', '4', '5', '6', '7', '8')]
    [System.String] $scheduledScan_dayOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('Ignore Exclusions (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $scheduledScan_ignoreExclusions

    [DscProperty()]
    [System.ComponentModel.Description('Daily Schedule quick scan interval (hours). Must be between 0 and 24 hours.')]
    [ValidateRange(0, 24)]
    [System.Nullable[System.Int32]] $scheduledScan_interval

    [DscProperty()]
    [System.ComponentModel.Description('Run with low CPU priority (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $scheduledScan_lowPriorityScheduledScan

    [DscProperty()]
    [System.ComponentModel.Description('Randomize scan start time. Must be between 0 and 23 hours.')]
    [ValidateRange(0, 23)]
    [System.Nullable[System.Int32]] $scheduledScan_randomizeScanStartTime

    [DscProperty()]
    [System.ComponentModel.Description('Run scan when device is idle')]
    [ValidateSet('false', 'true')]
    [System.String] $scheduledScan_runScanWhenIdle

    [DscProperty()]
    [System.ComponentModel.Description('Weekly Scheduled scan type (quick: Quick scan, full: Full scan)')]
    [ValidateSet('quick', 'full')]
    [System.String] $scheduledScan_scanType

    [DscProperty()]
    [System.ComponentModel.Description('Weekly Schedule scan time. Must be between 0 and 1380.')]
    [ValidateRange(0, 1380)]
    [System.Nullable[System.Int32]] $scheduledScan_weeklyConfiguration_timeOfDay

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

    [IntuneAntivirusPolicyLinux] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAntivirusPolicyLinux]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Antivirus Policy for Linux with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Linux with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if ($getValue.Length -gt 1)
                        {
                            throw "Duplicate Intune Antivirus Policy for Linux named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Antivirus Policy for Linux with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Antivirus Policy for Linux with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }
            $settingTemplates = Get-M365DSCCachedSettingCatalogTemplate -TemplateId $getValue.TemplateReference.TemplateId
            if ($null -eq $settingTemplates)
            {
                $settingTemplates = [System.Object[]] @(Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate `
                        -DeviceManagementConfigurationPolicyTemplateId $getValue.TemplateReference.TemplateId `
                        -ExpandProperty 'settingDefinitions' `
                        -All `
                        -ErrorAction Stop)
                Set-M365DSCCachedSettingCatalogTemplate -TemplateId $getValue.TemplateReference.TemplateId -Templates $settingTemplates
            }
            [array]$settingDefinitions = $settingTemplates.SettingDefinitions

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -AllSettingDefinitions $settingDefinitions

            #region resource generator code
            $complexExclusions = @()
            foreach ($currentExclusions in $policySettings.exclusions)
            {
                $myExclusions = [ordered]@{}
                if ($null -ne $currentExclusions.exclusions_item_type)
                {
                    $myExclusions.Add('Exclusions_item_type', $currentExclusions.exclusions_item_type)
                }
                if ($null -ne $currentExclusions.exclusions_item_extension)
                {
                    $myExclusions.Add('Exclusions_item_extension', $currentExclusions.exclusions_item_extension)
                }
                if ($null -ne $currentExclusions.exclusions_item_name)
                {
                    $myExclusions.Add('Exclusions_item_name', $currentExclusions.exclusions_item_name)
                }
                if ($null -ne $currentExclusions.exclusions_item_path)
                {
                    $myExclusions.Add('Exclusions_item_path', $currentExclusions.exclusions_item_path)
                }
                if ($null -ne $currentExclusions.exclusions_item_isDirectory)
                {
                    $myExclusions.Add('Exclusions_item_isDirectory', $currentExclusions.exclusions_item_isDirectory)
                }
                if ($myExclusions.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexExclusions += $myExclusions
                }
            }
            $policySettings.Remove('exclusions') | Out-Null

            $complexThreatTypeSettings = @()
            foreach ($currentThreatTypeSettings in $policySettings.threatTypeSettings)
            {
                $myThreatTypeSettings = [ordered]@{}
                if ($null -ne $currentThreatTypeSettings.threatTypeSettings_item_key)
                {
                    $myThreatTypeSettings.Add('ThreatTypeSettings_item_key', $currentThreatTypeSettings.threatTypeSettings_item_key)
                }
                if ($null -ne $currentThreatTypeSettings.threatTypeSettings_item_value)
                {
                    $myThreatTypeSettings.Add('ThreatTypeSettings_item_value', $currentThreatTypeSettings.threatTypeSettings_item_value)
                }
                if ($myThreatTypeSettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexThreatTypeSettings += $myThreatTypeSettings
                }
            }
            $policySettings.Remove('threatTypeSettings') | Out-Null
            #endregion

            # TODO: Remove during next breaking change and update mof schema
            if ($policySettings.ContainsKey('diagnosticLevel'))
            {
                switch ($policySettings.diagnosticLevel)
                {
                    'optional' { $policySettings.diagnosticLevel = '0' }
                    'required' { $policySettings.diagnosticLevel = '1' }
                }
            }
            if ($policySettings.ContainsKey('exclusionsMergePolicy'))
            {
                switch ($policySettings.exclusionsMergePolicy)
                {
                    'merge' { $policySettings.exclusionsMergePolicy = '0' }
                    'admin_only' { $policySettings.exclusionsMergePolicy = '1' }
                }
            }
            if ($policySettings.ContainsKey('threatTypeSettingsMergePolicy'))
            {
                switch ($policySettings.threatTypeSettingsMergePolicy)
                {
                    'merge' { $policySettings.threatTypeSettingsMergePolicy = '0' }
                    'admin_only' { $policySettings.threatTypeSettingsMergePolicy = '1' }
                }
            }
            if ($policySettings.ContainsKey('behaviorMonitoring'))
            {
                switch ($policySettings.behaviorMonitoring)
                {
                    'disabled' { $policySettings.behaviorMonitoring = '0' }
                    'enabled' { $policySettings.behaviorMonitoring = '1' }
                }
            }
            if ($policySettings.ContainsKey('networkprotection_enforcementLevel'))
            {
                switch ($policySettings.networkprotection_enforcementLevel)
                {
                    'disabled' { $policySettings.networkprotection_enforcementLevel = '0' }
                    'audit' { $policySettings.networkprotection_enforcementLevel = '1' }
                    'block' { $policySettings.networkprotection_enforcementLevel = '2' }
                }
            }
            if ($policySettings.ContainsKey('nonExecMountPolicy'))
            {
                switch ($policySettings.nonExecMountPolicy)
                {
                    'unmute' { $policySettings.nonExecMountPolicy = '0' }
                    'mute' { $policySettings.nonExecMountPolicy = '1' }
                }
            }
            if ($policySettings.ContainsKey('antivirusengine_enforcementLevel'))
            {
                switch ($policySettings.antivirusengine_enforcementLevel)
                {
                    'real_time' { $policySettings.antivirusengine_enforcementLevel = '0' }
                    'on_demand' { $policySettings.antivirusengine_enforcementLevel = '1' }
                    'passive' { $policySettings.antivirusengine_enforcementLevel = '2' }
                }
            }

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                exclusions            = $complexExclusions
                threatTypeSettings    = $complexThreatTypeSettings
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

        $templateReferenceId = '4cfd164c-5e8a-4ea9-b15d-9aa71e4ffff4_1'
        $platforms = 'linux'
        $technologies = 'microsoftSense'

        # TODO: Remove during next breaking change and update mof schema
        if ($boundParameters.ContainsKey('diagnosticLevel'))
        {
            switch ($boundParameters.diagnosticLevel)
            {
                '0' { $boundParameters.diagnosticLevel = 'optional' }
                '1' { $boundParameters.diagnosticLevel = 'required' }
            }
        }
        if ($boundParameters.ContainsKey('exclusionsMergePolicy'))
        {
            switch ($boundParameters.exclusionsMergePolicy)
            {
                '0' { $boundParameters.exclusionsMergePolicy = 'merge' }
                '1' { $boundParameters.exclusionsMergePolicy = 'admin_only' }
            }
        }
        if ($boundParameters.ContainsKey('threatTypeSettingsMergePolicy'))
        {
            switch ($boundParameters.threatTypeSettingsMergePolicy)
            {
                '0' { $boundParameters.threatTypeSettingsMergePolicy = 'merge' }
                '1' { $boundParameters.threatTypeSettingsMergePolicy = 'admin_only' }
            }
        }
        if ($boundParameters.ContainsKey('behaviorMonitoring'))
        {
            switch ($boundParameters.behaviorMonitoring)
            {
                '0' { $boundParameters.behaviorMonitoring = 'disabled' }
                '1' { $boundParameters.behaviorMonitoring = 'enabled' }
            }
        }
        if ($boundParameters.ContainsKey('networkprotection_enforcementLevel'))
        {
            switch ($boundParameters.networkprotection_enforcementLevel)
            {
                '0' { $boundParameters.networkprotection_enforcementLevel = 'disabled' }
                '1' { $boundParameters.networkprotection_enforcementLevel = 'audit' }
                '2' { $boundParameters.networkprotection_enforcementLevel = 'block' }
            }
        }
        if ($boundParameters.ContainsKey('nonExecMountPolicy'))
        {
            switch ($boundParameters.nonExecMountPolicy)
            {
                '0' { $boundParameters.nonExecMountPolicy = 'unmute' }
                '1' { $boundParameters.nonExecMountPolicy = 'mute' }
            }
        }
        if ($boundParameters.ContainsKey('antivirusengine_enforcementLevel'))
        {
            switch ($boundParameters.antivirusengine_enforcementLevel)
            {
                '0' { $boundParameters.antivirusengine_enforcementLevel = 'real_time' }
                '1' { $boundParameters.antivirusengine_enforcementLevel = 'on_demand' }
                '2' { $boundParameters.antivirusengine_enforcementLevel = 'passive' }
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Antivirus Policy for Linux with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

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
            Write-Verbose -Message "Updating the Intune Antivirus Policy for Linux with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

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
            Write-Verbose -Message "Removing the Intune Antivirus Policy for Linux with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = '4cfd164c-5e8a-4ea9-b15d-9aa71e4ffff4_1'
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

                if ($null -ne $Results.exclusions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.exclusions `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogExclusions' -IsArray
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.exclusions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('exclusions') | Out-Null
                    }
                }
                if ($null -ne $Results.threatTypeSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.threatTypeSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogThreatTypeSettings' -IsArray
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.threatTypeSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('threatTypeSettings') | Out-Null
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
                    -NoEscape @('exclusions', 'threatTypeSettings', 'Assignments') `
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

    hidden [IntuneAntivirusPolicyLinux] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAntivirusPolicyLinux])
        {
            return $Values
        }

        $result = [IntuneAntivirusPolicyLinux]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type - Depends on exclusions (excludedPath: Path, excludedFileExtension: File extension, excludedFileName: Process name)')]
    [ValidateSet('excludedPath', 'excludedFileExtension', 'excludedFileName')]
    [System.String] $exclusions_item_type

    [DscProperty()]
    [System.ComponentModel.Description('File extension - Depends on exclusions_item_type=excludedFileExtension')]
    [System.String] $exclusions_item_extension

    [DscProperty()]
    [System.ComponentModel.Description('File name - exclusions_item_type=excludedFileName')]
    [System.String] $exclusions_item_name

    [DscProperty()]
    [System.ComponentModel.Description('Path - exclusions_item_type=excludedPath')]
    [System.String] $exclusions_item_path

    [DscProperty()]
    [System.ComponentModel.Description('Is directory (false: Disabled, true: Enabled) - Depends on exclusions_item_type=excludedPath')]
    [ValidateSet('false', 'true')]
    [System.String] $exclusions_item_isDirectory
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Threat type - Depends on threatTypeSettings (potentially_unwanted_application, archive_bomb)')]
    [ValidateSet('potentially_unwanted_application', 'archive_bomb')]
    [System.String] $threatTypeSettings_item_key

    [DscProperty()]
    [System.ComponentModel.Description('Action to take - Depends on threatTypeSettings (audit, block, off)')]
    [ValidateSet('audit', 'block', 'off')]
    [System.String] $threatTypeSettings_item_value
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
