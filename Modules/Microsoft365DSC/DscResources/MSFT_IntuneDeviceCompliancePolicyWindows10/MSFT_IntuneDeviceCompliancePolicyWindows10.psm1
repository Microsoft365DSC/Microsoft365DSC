using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The id of the Windows 10 device compliance policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Windows 10 device compliance policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Windows 10 device compliance policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('PasswordBlockSimple of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordBlockSimple

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequiredToUnlockFromIdle of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordRequiredToUnlockFromIdle

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinutesOfInactivityBeforeLock of the Windows 10 device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('PasswordExpirationDays of the Windows 10 device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumLength of the Windows 10 device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumCharacterSetCount of the Windows 10 device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumCharacterSetCount

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequiredType of the Windows 10 device compliance policy.')]
    [ValidateSet('DeviceDefault', 'Alphanumeric', 'Numeric')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('PasswordPreviousPasswordBlockCount of the Windows 10 device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('RequireHealthyDeviceReport of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $RequireHealthyDeviceReport

    [DscProperty()]
    [System.ComponentModel.Description('OsMinimumVersion of the Windows 10 device compliance policy.')]
    [System.String] $OsMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('OsMaximumVersion of the Windows 10 device compliance policy.')]
    [System.String] $OsMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('MobileOsMinimumVersion of the Windows 10 device compliance policy.')]
    [System.String] $MobileOsMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('MobileOsMaximumVersion of the Windows 10 device compliance policy.')]
    [System.String] $MobileOsMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('EarlyLaunchAntiMalwareDriverEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $EarlyLaunchAntiMalwareDriverEnabled

    [DscProperty()]
    [System.ComponentModel.Description('BitLockerEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $BitLockerEnabled

    [DscProperty()]
    [System.ComponentModel.Description('SecureBootEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecureBootEnabled

    [DscProperty()]
    [System.ComponentModel.Description('CodeIntegrityEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $CodeIntegrityEnabled

    [DscProperty()]
    [System.ComponentModel.Description('FirmwareProtectionEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $FirmwareProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('KernelDmaProtectionEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $KernelDmaProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('MemoryIntegrityEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $MemoryIntegrityEnabled

    [DscProperty()]
    [System.ComponentModel.Description('VirtualizationBasedSecurityEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $VirtualizationBasedSecurityEnabled

    [DscProperty()]
    [System.ComponentModel.Description('StorageRequireEncryption of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $StorageRequireEncryption

    [DscProperty()]
    [System.ComponentModel.Description('ActiveFirewallRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $ActiveFirewallRequired

    [DscProperty()]
    [System.ComponentModel.Description('DefenderEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $DefenderEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DefenderVersion of the Windows 10 device compliance policy.')]
    [System.String] $DefenderVersion

    [DscProperty()]
    [System.ComponentModel.Description('SignatureOutOfDate of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $SignatureOutOfDate

    [DscProperty()]
    [System.ComponentModel.Description('RTPEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $RTPEnabled

    [DscProperty()]
    [System.ComponentModel.Description('AntivirusRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $AntivirusRequired

    [DscProperty()]
    [System.ComponentModel.Description('AntiSpywareRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $AntiSpywareRequired

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionEnabled of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $DeviceThreatProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionRequiredSecurityLevel of the Windows 10 device compliance policy.')]
    [ValidateSet('Unavailable', 'Secured', 'Low', 'Medium', 'High', 'NotSet')]
    [System.String] $DeviceThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('ConfigurationManagerComplianceRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $ConfigurationManagerComplianceRequired

    [DscProperty()]
    [System.ComponentModel.Description('TpmRequired of the Windows 10 device compliance policy.')]
    [System.Nullable[System.Boolean]] $TpmRequired

    [DscProperty()]
    [System.ComponentModel.Description('DeviceCompliancePolicyScript of the Windows 10 device compliance policy.')]
    [MSFT_MicrosoftGraphDeviceCompliancePolicyScript] $DeviceCompliancePolicyScript

    [DscProperty()]
    [System.ComponentModel.Description('ValidOperatingSystemBuildRanges of the Windows 10 device compliance policy.')]
    [MSFT_MicrosoftGraphOperatingSystemVersionRange[]] $ValidOperatingSystemBuildRanges

    [DscProperty()]
    [System.ComponentModel.Description('The WSL distributions and the operating system versions they are allowed to run.')]
    [MSFT_MicrosoftGraphWslDistributionConfiguration[]] $WslDistributions

    [DscProperty()]
    [System.ComponentModel.Description('Actions to take for noncompliant devices.')]
    [MSFT_MicrosoftGraphDeviceComplianceScheduledActionsForRuleConfiguration[]] $ScheduledActionsForRule

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

    [IntuneDeviceCompliancePolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceCompliancePolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Compliance Windows 10 Policy {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $devicePolicy = Get-MgBetaDeviceManagementDeviceCompliancePolicy `
                    -All `
                    -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows10CompliancePolicy')" `
                    -ExpandProperty 'scheduledActionsForRule($expand=scheduledActionConfigurations)' `
                    -ErrorAction SilentlyContinue
                if (([array]$devicePolicy).Count -gt 1)
                {
                    throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                }
                if ($null -eq $devicePolicy)
                {
                    Write-Verbose -Message "No Windows 10 Device Compliance Policy with displayName {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $devicePolicy = $this.ExportedInstance
            }

            $complexValidOperatingSystemBuildRanges = @()
            foreach ($currentValidOperatingSystemBuildRanges in $devicePolicy.validOperatingSystemBuildRanges)
            {
                $myValidOperatingSystemBuildRanges = [ordered]@{}
                if ($null -ne $currentValidOperatingSystemBuildRanges.lowestVersion)
                {
                    $myValidOperatingSystemBuildRanges.Add('LowestVersion', $currentValidOperatingSystemBuildRanges.lowestVersion)
                }
                if ($null -ne $currentValidOperatingSystemBuildRanges.highestVersion)
                {
                    $myValidOperatingSystemBuildRanges.Add('HighestVersion', $currentValidOperatingSystemBuildRanges.highestVersion)
                }
                if ($null -ne $currentValidOperatingSystemBuildRanges.description)
                {
                    $myValidOperatingSystemBuildRanges.Add('Description', $currentValidOperatingSystemBuildRanges.description)
                }
                if ($myValidOperatingSystemBuildRanges.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexValidOperatingSystemBuildRanges += $myValidOperatingSystemBuildRanges
                }
            }

            $complexWslDistributions = @()
            foreach ($currentWslDistribution in $devicePolicy.wslDistributions)
            {
                $myWslDistribution = [ordered]@{}
                if ($null -ne $currentWslDistribution.distribution)
                {
                    $myWslDistribution.Add('Distribution', $currentWslDistribution.distribution)
                }
                if ($null -ne $currentWslDistribution.minimumOSVersion)
                {
                    $myWslDistribution.Add('MinimumOSVersion', $currentWslDistribution.minimumOSVersion)
                }
                if ($null -ne $currentWslDistribution.maximumOSVersion)
                {
                    $myWslDistribution.Add('MaximumOSVersion', $currentWslDistribution.maximumOSVersion)
                }
                if ($myWslDistribution.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexWslDistributions += $myWslDistribution
                }
            }

            $complexDeviceCompliancePolicyScript = [ordered]@{}
            if ($null -ne $devicePolicy.deviceCompliancePolicyScript)
            {
                Write-Verbose -Message "Resolving Device Compliance Policy Script with Id {$($devicePolicy.deviceCompliancePolicyScript.deviceComplianceScriptId)}"
                $policyScript = Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/deviceComplianceScripts/$($devicePolicy.deviceCompliancePolicyScript.deviceComplianceScriptId)" -Method GET
                if (-not ([System.String]$policyScript.displayName).StartsWith('Built-in WSL Compliance-', [System.StringComparison]::Ordinal))
                {
                    $complexDeviceCompliancePolicyScript.Add('DisplayName', $policyScript.displayName)
                    $complexDeviceCompliancePolicyScript.Add('RulesContent', $this.DecodeTextPayload($devicePolicy.deviceCompliancePolicyScript.rulesContent))
                }
            }
            if ($complexDeviceCompliancePolicyScript.Keys.Count -eq 0)
            {
                $complexDeviceCompliancePolicyScript = $null
            }

            $complexScheduledActionsForRule = @()
            foreach ($actionConfiguration in $devicePolicy.ScheduledActionsForRule.ScheduledActionConfigurations)
            {
                $scheduledAction = [ordered]@{
                    ActionType       = [string]$actionConfiguration.ActionType
                    GracePeriodHours = $actionConfiguration.GracePeriodHours
                }
                if ($null -ne $actionConfiguration.NotificationMessageCCList -and `
                        $actionConfiguration.NotificationMessageCCList.Count -gt 0)
                {
                    [System.String[]]$groups = @()
                    foreach ($group in $actionConfiguration.NotificationMessageCCList)
                    {
                        $groups += (Get-M365DSCIntuneGroup -GroupId $group).DisplayName
                    }
                    $scheduledAction.Add('NotificationMessageCCList', $groups)
                }
                if ($null -ne $actionConfiguration.NotificationTemplateId -and `
                        $actionConfiguration.NotificationTemplateId -ne '00000000-0000-0000-0000-000000000000')
                {
                    $notificationTemplate = Get-MgBetaDeviceManagementNotificationMessageTemplate `
                        -NotificationMessageTemplateId $actionConfiguration.NotificationTemplateId `
                        -ErrorAction SilentlyContinue
                    $scheduledAction.Add('NotificationTemplate', $notificationTemplate.DisplayName)
                }
                $complexScheduledActionsForRule += $scheduledAction
            }

            Write-Verbose -Message "Found Windows 10 Device Compliance Policy with displayName {$($this.DisplayName)}"
            $results = @{
                Id                                          = $devicePolicy.Id
                DisplayName                                 = $devicePolicy.DisplayName
                Description                                 = $devicePolicy.Description
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $devicePolicy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                PasswordRequired                            = $devicePolicy.passwordRequired
                PasswordBlockSimple                         = $devicePolicy.passwordBlockSimple
                PasswordRequiredToUnlockFromIdle            = $devicePolicy.passwordRequiredToUnlockFromIdle
                PasswordMinutesOfInactivityBeforeLock       = $devicePolicy.passwordMinutesOfInactivityBeforeLock
                PasswordExpirationDays                      = $devicePolicy.passwordExpirationDays
                PasswordMinimumLength                       = $devicePolicy.passwordMinimumLength
                PasswordMinimumCharacterSetCount            = $devicePolicy.passwordMinimumCharacterSetCount
                PasswordRequiredType                        = $devicePolicy.passwordRequiredType
                PasswordPreviousPasswordBlockCount          = $devicePolicy.passwordPreviousPasswordBlockCount
                RequireHealthyDeviceReport                  = $devicePolicy.requireHealthyDeviceReport
                OsMinimumVersion                            = $devicePolicy.osMinimumVersion
                OsMaximumVersion                            = $devicePolicy.osMaximumVersion
                MobileOsMinimumVersion                      = $devicePolicy.mobileOsMinimumVersion
                MobileOsMaximumVersion                      = $devicePolicy.mobileOsMaximumVersion
                EarlyLaunchAntiMalwareDriverEnabled         = $devicePolicy.earlyLaunchAntiMalwareDriverEnabled
                BitLockerEnabled                            = $devicePolicy.bitLockerEnabled
                SecureBootEnabled                           = $devicePolicy.secureBootEnabled
                CodeIntegrityEnabled                        = $devicePolicy.codeIntegrityEnabled
                FirmwareProtectionEnabled                   = $devicePolicy.firmwareProtectionEnabled
                KernelDmaProtectionEnabled                  = $devicePolicy.kernelDmaProtectionEnabled
                MemoryIntegrityEnabled                      = $devicePolicy.memoryIntegrityEnabled
                VirtualizationBasedSecurityEnabled          = $devicePolicy.virtualizationBasedSecurityEnabled
                StorageRequireEncryption                    = $devicePolicy.storageRequireEncryption
                ActiveFirewallRequired                      = $devicePolicy.activeFirewallRequired
                DefenderEnabled                             = $devicePolicy.defenderEnabled
                DefenderVersion                             = $devicePolicy.defenderVersion
                SignatureOutOfDate                          = $devicePolicy.signatureOutOfDate
                RTPEnabled                                  = $devicePolicy.rtpEnabled
                AntivirusRequired                           = $devicePolicy.antivirusRequired
                AntiSpywareRequired                         = $devicePolicy.antiSpywareRequired
                DeviceThreatProtectionEnabled               = $devicePolicy.deviceThreatProtectionEnabled
                DeviceThreatProtectionRequiredSecurityLevel = $devicePolicy.deviceThreatProtectionRequiredSecurityLevel
                ConfigurationManagerComplianceRequired      = $devicePolicy.configurationManagerComplianceRequired
                TpmRequired                                 = $devicePolicy.tpmRequired
                ScheduledActionsForRule                     = $complexScheduledActionsForRule
                DeviceCompliancePolicyScript                = $complexDeviceCompliancePolicyScript
                ValidOperatingSystemBuildRanges             = $complexValidOperatingSystemBuildRanges
                WslDistributions                            = $complexWslDistributions
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
            }

            $returnAssignments = @()
            $graphAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $devicePolicy
            if ($null -eq $graphAssignments)
            {
                $graphAssignments = Get-MgBetaDeviceManagementDeviceCompliancePolicyAssignment -DeviceCompliancePolicyId $devicePolicy.Id
            }
            if ($graphAssignments.Count -gt 0)
            {
                [array]$graphAssignments = $graphAssignments | Where-Object -FilterScript { $_.source -eq 'direct' }
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

        Write-Verbose -Message "Setting configuration of the Intune Device Compliance Policy for Windows 10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentDeviceWindows10Policy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($null -ne $boundParameters.DeviceCompliancePolicyScript)
        {
            $script = $boundParameters.DeviceCompliancePolicyScript
            $scriptName = $script.Displayname
            $scriptRulesContent = $script.RulesContent

            $complianceScript = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/deviceComplianceScripts?`$filter=DisplayName eq '$($scriptName -replace "'", "''")'" -Method GET).value
            if ($complianceScript.Count -eq 0)
            {
                throw "The referenced Intune Device Compliance Script with DisplayName {$scriptName} was not found"
            }

            $script = @{
                deviceComplianceScriptId = $complianceScript.id
                rulesContent             = $this.EncodeTextPayload($scriptRulesContent)
            }
            $boundParameters.Remove('DeviceCompliancePolicyScript') | Out-Null
            $boundParameters.Add('DeviceCompliancePolicyScript', $script)
        }

        $notificationTemplates = Get-MgBetaDeviceManagementNotificationMessageTemplate -All | Where-Object -FilterScript {
            $_.Id -ne '8ca486fc-bee8-4ef2-983b-21e8908d11b8' # Exclude the second, unused default template
        }
        $complexScheduledActionsForRule = @(
            @{
                ruleName                      = 'PasswordRequired'
                scheduledActionConfigurations = @()
            }
        )
        foreach ($scheduledAction in $boundParameters.ScheduledActionsForRule)
        {
            $actionConfiguration = @{
                actionType       = $scheduledAction.ActionType
                gracePeriodHours = $scheduledAction.GracePeriodHours
            }

            $ccList = @()
            if ($null -ne $scheduledAction.NotificationMessageCCList)
            {
                foreach ($group in $scheduledAction.NotificationMessageCCList)
                {
                    $groupObject = Get-MgGroup -All -Filter "displayName eq '$group'" -ErrorAction SilentlyContinue
                    if ($null -eq $groupObject)
                    {
                        throw "The referenced Intune Group with DisplayName {$group} was not found for NotificationMessageCCList"
                    }
                    $ccList += $groupObject.Id
                }
            }
            $actionConfiguration.notificationMessageCCList = $ccList

            $template = [System.Guid]::Empty
            if (-not [string]::IsNullOrEmpty($scheduledAction.NotificationTemplate))
            {
                $template = $notificationTemplates | Where-Object -FilterScript { $_.DisplayName -eq $scheduledAction.NotificationTemplate }
                if ($null -eq $template)
                {
                    throw "The referenced Intune Notification Template with DisplayName {$($scheduledAction.NotificationTemplate)} was not found"
                }
                $template = $template.Id
            }
            $actionConfiguration.notificationTemplateId = [string]$template
            $complexScheduledActionsForRule[0].scheduledActionConfigurations += $actionConfiguration
        }
        $boundParameters.Remove('ScheduledActionsForRule') | Out-Null

        if (@($complexScheduledActionsForRule[0].scheduledActionConfigurations |
                    Where-Object -FilterScript { $_.actionType -eq 'block' }).Count -eq 0)
        {
            $complexScheduledActionsForRule[0].scheduledActionConfigurations += @{
                actionType       = 'block'
                gracePeriodHours = 0
            }
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentDeviceWindows10Policy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Intune Device Compliance Windows 10 Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.windows10CompliancePolicy')
            $createParameters.Add('scheduledActionsForRule', $complexScheduledActionsForRule)
            $policy = New-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceCompliancePolicies'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentDeviceWindows10Policy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Intune Device Compliance Windows 10 Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10CompliancePolicy')
            Update-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $updateParameters `
                -DeviceCompliancePolicyId $currentDeviceWindows10Policy.Id

            Invoke-MgBetaScheduleDeviceManagementDeviceCompliancePolicyActionForRule `
                -DeviceCompliancePolicyId $currentDeviceWindows10Policy.Id `
                -DeviceComplianceScheduledActionForRules $complexScheduledActionsForRule

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentDeviceWindows10Policy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceCompliancePolicies'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentDeviceWindows10Policy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune Device Compliance Windows 10 Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $currentDeviceWindows10Policy.Id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $complexFunctions = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $strippedFilter = $null
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $strippedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$configDeviceWindowsPolicies = Get-M365DSCExportCachedCollection -Collection 'deviceCompliancePolicies' `
                -ODataType 'microsoft.graph.windows10CompliancePolicy' `
                -Filter $strippedFilter
            $configDeviceWindowsPolicies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $configDeviceWindowsPolicies

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($configDeviceWindowsPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($configDeviceWindowsPolicy in $configDeviceWindowsPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($configDeviceWindowsPolicies.Count)] $($configDeviceWindowsPolicy.displayName)" -DeferWrite
                $params = @{
                    DisplayName           = $configDeviceWindowsPolicy.displayName
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

                $this.ExportedInstance = $configDeviceWindowsPolicy
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.ValidOperatingSystemBuildRanges)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ValidOperatingSystemBuildRanges `
                        -CIMInstanceName 'MicrosoftGraphOperatingSystemVersionRange' `
                        -IsArray
                    if (-not [string]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ValidOperatingSystemBuildRanges = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ValidOperatingSystemBuildRanges') | Out-Null
                    }
                }
                if ($null -ne $Results.WslDistributions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.WslDistributions `
                        -CIMInstanceName 'MicrosoftGraphWslDistributionConfiguration' `
                        -IsArray
                    if (-not [string]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.WslDistributions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WslDistributions') | Out-Null
                    }
                }
                if ($null -ne $Results.DeviceCompliancePolicyScript)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceCompliancePolicyScript `
                        -CIMInstanceName 'MicrosoftGraphDeviceCompliancePolicyScript'
                    if (-not [string]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceCompliancePolicyScript = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceCompliancePolicyScript') | Out-Null
                    }
                }
                if ($null -ne $Results.ScheduledActionsForRule)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ScheduledActionsForRule `
                        -CIMInstanceName 'MicrosoftGraphDeviceComplianceScheduledActionsForRuleConfiguration' `
                        -IsArray
                    if (-not [string]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ScheduledActionsForRule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ScheduledActionsForRule') | Out-Null
                    }
                }
                if ($null -ne $Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Assignments'
                            CimInstanceName = 'MSFT_DeviceManagementConfigurationPolicyAssignments'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName 'MSFT_DeviceManagementConfigurationPolicyAssignments' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
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
                    -NoEscape @('ValidOperatingSystemBuildRanges', 'WslDistributions', 'DeviceCompliancePolicyScript', 'ScheduledActionsForRule', 'Assignments') `
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

    hidden [IntuneDeviceCompliancePolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceCompliancePolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceCompliancePolicyWindows10]::new()
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

class MSFT_MicrosoftGraphDeviceCompliancePolicyScript
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Device compliance script name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Rules content of the custom settings.')]
    [System.String] $RulesContent
}

class MSFT_MicrosoftGraphOperatingSystemVersionRange
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The description of this range (e.g. Valid 1702 builds)')]
    [System.String] $Description

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The lowest inclusive version that this range contains.')]
    [System.String] $LowestVersion

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The highest inclusive version that this range contains.')]
    [System.String] $HighestVersion
}

class MSFT_MicrosoftGraphWslDistributionConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Linux distribution like Debian, Fedora, Ubuntu etc.')]
    [System.String] $Distribution

    [DscProperty()]
    [System.ComponentModel.Description('Minimum supported operating system version of the Linux distribution.')]
    [System.String] $MinimumOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Maximum supported operating system version of the Linux distribution.')]
    [System.String] $MaximumOSVersion
}

class MSFT_MicrosoftGraphDeviceComplianceScheduledActionsForRuleConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The action type of the compliance policy action.')]
    [ValidateSet('block', 'notification', 'retire')]
    [System.String] $ActionType

    [DscProperty()]
    [System.ComponentModel.Description('Number of hours the device can be in grace period.')]
    [System.Nullable[System.UInt32]] $GracePeriodHours

    [DscProperty()]
    [System.ComponentModel.Description('Display names of the groups that should be notified if the compliance fails.')]
    [System.String[]] $NotificationMessageCCList

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the Notification Template used in the compliance policy. Can only be used with ActionType ''notification''.')]
    [System.String] $NotificationTemplate
}
