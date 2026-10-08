using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyMacOS : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the MacOS device compliance policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The id of the MacOS device compliance policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the MacOS device compliance policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequired of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('PasswordBlockSimple of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordBlockSimple

    [DscProperty()]
    [System.ComponentModel.Description('PasswordExpirationDays of the MacOS device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumLength of the MacOS device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinutesOfInactivityBeforeLock of the MacOS device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('PasswordPreviousPasswordBlockCount of the MacOS device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumCharacterSetCount of the MacOS device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumCharacterSetCount

    [DscProperty()]
    [System.ComponentModel.Description('DeviceCompliancePolicyScript of the MacOS device compliance policy.')]
    [MSFT_MicrosoftGraphDeviceCompliancePolicyScript] $DeviceCompliancePolicyScript

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the non-compliance actions.')]
    [MSFT_ScheduledActionConfigurations[]] $ScheduledActionsForRule

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequiredType of the MacOS device compliance policy.')]
    [ValidateSet('DeviceDefault', 'Alphanumeric', 'Numeric')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('OsMinimumVersion of the MacOS device compliance policy.')]
    [System.String] $OsMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('OsMaximumVersion of the MacOS device compliance policy.')]
    [System.String] $OsMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum MacOS build version.')]
    [System.String] $OsMinimumBuildVersion

    [DscProperty()]
    [System.ComponentModel.Description('Maximum MacOS build version.')]
    [System.String] $OsMaximumBuildVersion

    [DscProperty()]
    [System.ComponentModel.Description('SystemIntegrityProtectionEnabled of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $SystemIntegrityProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionEnabled of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $DeviceThreatProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionRequiredSecurityLevel of the MacOS device compliance policy.')]
    [ValidateSet('Unavailable', 'Secured', 'Low', 'Medium', 'High', 'NotSet')]
    [System.String] $DeviceThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('AdvancedThreatProtectionRequiredSecurityLevel of the MacOS device compliance policy.')]
    [ValidateSet('Unavailable', 'Secured', 'Low', 'Medium', 'High', 'NotSet')]
    [System.String] $AdvancedThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('StorageRequireEncryption of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $StorageRequireEncryption

    [DscProperty()]
    [System.ComponentModel.Description('System and Privacy setting that determines which download locations apps can be run from on a macOS device.')]
    [ValidateSet('notConfigured', 'macAppStore', 'macAppStoreAndIdentifiedDevelopers', 'anywhere')]
    [System.String] $GatekeeperAllowedAppSource

    [DscProperty()]
    [System.ComponentModel.Description('FirewallEnabled of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $FirewallEnabled

    [DscProperty()]
    [System.ComponentModel.Description('FirewallBlockAllIncoming of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $FirewallBlockAllIncoming

    [DscProperty()]
    [System.ComponentModel.Description('FirewallEnableStealthMode of the MacOS device compliance policy.')]
    [System.Nullable[System.Boolean]] $FirewallEnableStealthMode

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

    [IntuneDeviceCompliancePolicyMacOS] Get()
    {
        $devicePolicy = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceCompliancePolicyMacOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Compliance MacOS Policy {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $devicePolicy = Get-MgBetaDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $this.Id `
                        -ExpandProperty 'scheduledActionsForRule($expand=scheduledActionConfigurations)' `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $devicePolicy)
                {
                    $devicePolicy = Get-MgBetaDeviceManagementDeviceCompliancePolicy `
                        -All `
                        -ExpandProperty 'scheduledActionsForRule($expand=scheduledActionConfigurations)' `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.macOSCompliancePolicy')" `
                        -ErrorAction Stop
                }

                if (([array]$devicePolicy).Count -gt 1)
                {
                    throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                }
                if ($null -eq $devicePolicy)
                {
                    Write-Verbose -Message "No MacOS Device Compliance Policy with displayName {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $devicePolicy = $this.ExportedInstance
            }

            $complexDeviceCompliancePolicyScript = [ordered]@{}
            if ($null -ne $devicePolicy.deviceCompliancePolicyScript)
            {
                Write-Verbose -Message "Resolving Device Compliance Policy Script with Id {$($devicePolicy.deviceCompliancePolicyScript.deviceComplianceScriptId)}"
                $policyScript = Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/deviceComplianceScripts/$($devicePolicy.deviceCompliancePolicyScript.deviceComplianceScriptId)" -Method GET
                $complexDeviceCompliancePolicyScript.Add('DisplayName', $policyScript.displayName)
                $complexDeviceCompliancePolicyScript.Add('RulesContent', $this.DecodeTextPayload($devicePolicy.deviceCompliancePolicyScript.rulesContent))
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
                    $scheduledAction.Add('NotificationTemplateId', $notificationTemplate.DisplayName)
                }
                $complexScheduledActionsForRule += $scheduledAction
            }

            Write-Verbose -Message "Found MacOS Device Compliance Policy with displayName {$($this.DisplayName)}"
            $results = @{
                DisplayName                                   = $devicePolicy.DisplayName
                Id                                            = $devicePolicy.Id
                Description                                   = $devicePolicy.Description
                RoleScopeTagIds                               = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $devicePolicy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                PasswordRequired                              = $devicePolicy.passwordRequired
                PasswordBlockSimple                           = $devicePolicy.passwordBlockSimple
                PasswordExpirationDays                        = $devicePolicy.passwordExpirationDays
                PasswordMinimumLength                         = $devicePolicy.passwordMinimumLength
                PasswordMinutesOfInactivityBeforeLock         = $devicePolicy.passwordMinutesOfInactivityBeforeLock
                PasswordPreviousPasswordBlockCount            = $devicePolicy.passwordPreviousPasswordBlockCount
                PasswordMinimumCharacterSetCount              = $devicePolicy.passwordMinimumCharacterSetCount
                PasswordRequiredType                          = $devicePolicy.passwordRequiredType
                OsMinimumVersion                              = $devicePolicy.osMinimumVersion
                OsMaximumVersion                              = $devicePolicy.osMaximumVersion
                OsMinimumBuildVersion                         = $devicePolicy.osMinimumBuildVersion
                OsMaximumBuildVersion                         = $devicePolicy.osMaximumBuildVersion
                ScheduledActionsForRule                       = $complexScheduledActionsForRule
                DeviceCompliancePolicyScript                  = $complexDeviceCompliancePolicyScript
                SystemIntegrityProtectionEnabled              = $devicePolicy.systemIntegrityProtectionEnabled
                DeviceThreatProtectionEnabled                 = $devicePolicy.deviceThreatProtectionEnabled
                DeviceThreatProtectionRequiredSecurityLevel   = $devicePolicy.deviceThreatProtectionRequiredSecurityLevel
                AdvancedThreatProtectionRequiredSecurityLevel = $devicePolicy.advancedThreatProtectionRequiredSecurityLevel
                StorageRequireEncryption                      = $devicePolicy.storageRequireEncryption
                GatekeeperAllowedAppSource                    = $devicePolicy.gatekeeperAllowedAppSource
                FirewallEnabled                               = $devicePolicy.firewallEnabled
                FirewallBlockAllIncoming                      = $devicePolicy.firewallBlockAllIncoming
                FirewallEnableStealthMode                     = $devicePolicy.firewallEnableStealthMode
                Ensure                                        = 'Present'
                Credential                                    = $this.Credential
                ApplicationId                                 = $this.ApplicationId
                TenantId                                      = $this.TenantId
                ApplicationSecret                             = $this.ApplicationSecret
                CertificateThumbprint                         = $this.CertificateThumbprint
                CertificatePath                               = $this.CertificatePath
                CertificatePassword                           = $this.CertificatePassword
                ManagedIdentity                               = $this.ManagedIdentity
                AccessTokens                                  = $this.AccessTokens
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

        Write-Verbose -Message "Intune Device Compliance MacOS Policy {$($this.DisplayName)}"

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentDeviceMacOsPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($null -ne $boundParameters.DeviceCompliancePolicyScript)
        {
            $scriptName = $boundParameters.DeviceCompliancePolicyScript.DisplayName
            $scriptRulesContent = $boundParameters.DeviceCompliancePolicyScript.RulesContent

            [array]$complianceScript = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/deviceComplianceScripts?`$filter=DisplayName eq '$($scriptName -replace "'", "''")' and platform eq 'macOS'" -Method GET).value
            if ($complianceScript.Count -eq 0)
            {
                throw "The referenced Intune Device Compliance Script with DisplayName {$scriptName} was not found"
            }
            if ($complianceScript.Count -gt 1)
            {
                throw "A compliance script with a duplicated displayName {'$scriptName'} was found - Ensure displayName is unique"
            }

            $policyScript = @{
                deviceComplianceScriptId = $complianceScript[0].id
                rulesContent             = $this.EncodeTextPayload($scriptRulesContent)
            }
            $boundParameters.Remove('DeviceCompliancePolicyScript') | Out-Null
            $boundParameters.Add('DeviceCompliancePolicyScript', $policyScript)
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
        $baseScheduledActionConfiguration = @{
            ActionType       = 'block'
            GracePeriodHours = 0
            NotificationMessageCCList = @()
            NotificationTemplateId = ""
        }
        if ($null -eq $boundParameters.ScheduledActionsForRule -or $boundParameters.ScheduledActionsForRule.Count -eq 0)
        {
            $boundParameters.ScheduledActionsForRule = @($baseScheduledActionConfiguration)
        }
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
            if (-not [string]::IsNullOrEmpty($scheduledAction.NotificationTemplateId))
            {
                $template = $notificationTemplates | Where-Object -FilterScript { $_.DisplayName -eq $scheduledAction.NotificationTemplateId }
                if ($null -eq $template)
                {
                    throw "The referenced Intune Notification Template with DisplayName {$($scheduledAction.NotificationTemplateId)} was not found"
                }
                $template = $template.Id
            }
            $actionConfiguration.notificationTemplateId = [string]$template
            $complexScheduledActionsForRule[0].scheduledActionConfigurations += $actionConfiguration
        }
        $boundParameters.Remove('ScheduledActionsForRule') | Out-Null

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentDeviceMacOsPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Intune Device Compliance MacOS Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.macOSCompliancePolicy')
            $createParameters.Add('scheduledActionsForRule', $complexScheduledActionsForRule)
            $policy = New-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $createParameters

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceCompliancePolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentDeviceMacOsPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Intune Device Compliance MacOS Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.macOSCompliancePolicy')
            Update-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $updateParameters `
                -DeviceCompliancePolicyId $currentDeviceMacOsPolicy.Id

            Invoke-MgBetaScheduleDeviceManagementDeviceCompliancePolicyActionForRule `
                -DeviceCompliancePolicyId $currentDeviceMacOsPolicy.Id `
                -DeviceComplianceScheduledActionForRules $complexScheduledActionsForRule

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentDeviceMacOsPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceCompliancePolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentDeviceMacOsPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune Device Compliance MacOS Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $currentDeviceMacOsPolicy.Id
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
            [array]$configDeviceMacOsPolicies = Get-M365DSCExportCachedCollection -Collection 'deviceCompliancePolicies' `
                -ODataType 'microsoft.graph.macOSCompliancePolicy' `
                -Filter $strippedFilter
            $configDeviceMacOsPolicies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $configDeviceMacOsPolicies

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($configDeviceMacOsPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($configDeviceMacOsPolicy in $configDeviceMacOsPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($configDeviceMacOsPolicies.Count)] $($configDeviceMacOsPolicy.displayName)" -DeferWrite
                $params = @{
                    DisplayName           = $configDeviceMacOsPolicy.displayName
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

                $this.ExportedInstance = $configDeviceMacOsPolicy
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Assignments) -CIMInstanceName DeviceManagementConfigurationPolicyAssignments

                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                if ($Results.ScheduledActionsForRule)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ScheduledActionsForRule `
                        -CIMInstanceName MSFT_scheduledActionConfigurations
                    if ($complexTypeStringResult)
                    {
                        $Results.ScheduledActionsForRule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ScheduledActionsForRule') | Out-Null
                    }
                }

                if ($Results.DeviceCompliancePolicyScript)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceCompliancePolicyScript `
                        -CIMInstanceName 'MicrosoftGraphDeviceCompliancePolicyScript'
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceCompliancePolicyScript = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceCompliancePolicyScript') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'ScheduledActionsForRule', 'DeviceCompliancePolicyScript') `
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

    hidden [IntuneDeviceCompliancePolicyMacOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceCompliancePolicyMacOS])
        {
            return $Values
        }

        $result = [IntuneDeviceCompliancePolicyMacOS]::new()
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

class MSFT_ScheduledActionConfigurations
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the action configuration.')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('Number of hours to wait till the action will be enforced. Valid values 0 to 8760.')]
    [System.Nullable[System.UInt32]] $gracePeriodHours

    [DscProperty()]
    [System.ComponentModel.Description('The action to take.')]
    [ValidateSet('notification', 'block', 'retire', 'remoteLock', 'pushNotification')]
    [System.String] $actionType

    [DscProperty()]
    [System.ComponentModel.Description('The notification Message template to use.')]
    [System.String] $notificationTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('A list of group IDs to specify who to CC this notification message to.')]
    [System.String[]] $notificationMessageCCList
}
