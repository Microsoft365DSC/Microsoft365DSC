using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyAndroidDeviceOwner : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Android Device Owner device compliance policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the Android Device Owner device compliance policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Android Device Owner device compliance policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Minimum Android security patch level.')]
    [System.String] $MinAndroidSecurityPatchLevel

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of letter characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of lower case characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLowerCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of non-letter characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumNonLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of numeric characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumNumericCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of symbol characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumSymbolCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the minimum number of upper case letter characters required for device password. Valid values 1 to 16.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumUpperCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Require device to have no pending Android system updates.')]
    [System.Nullable[System.Boolean]] $RequireNoPendingSystemUpdates

    [DscProperty()]
    [System.ComponentModel.Description('Require a specific Play Integrity evaluation type for compliance. Possible values are: basic, hardwareBacked.')]
    [ValidateSet('basic', 'hardwareBacked')]
    [System.String] $SecurityRequiredAndroidSafetyNetEvaluationType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the non-compliance actions.')]
    [MSFT_ScheduledActionConfigurations[]] $ScheduledActionsForRule

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionEnabled of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $DeviceThreatProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionRequiredSecurityLevel of the Android Device Owner device compliance policy.')]
    [System.String] $DeviceThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('AdvancedThreatProtectionRequiredSecurityLevel of the Android Device Owner device compliance policy.')]
    [System.String] $AdvancedThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireSafetyNetAttestationBasicIntegrity of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireSafetyNetAttestationBasicIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireSafetyNetAttestationCertifiedDevice of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireSafetyNetAttestationCertifiedDevice

    [DscProperty()]
    [System.ComponentModel.Description('osMinimumVersion of the Android Device Owner device compliance policy.')]
    [System.String] $osMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('osMaximumVersion of the Android Device Owner device compliance policy.')]
    [System.String] $osMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequired of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $passwordRequired

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumLength of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.UInt32]] $passwordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequiredType of the Android Device Owner device compliance policy.')]
    [ValidateSet('deviceDefault', 'alphabetic', 'alphanumeric', 'alphanumericWithSymbols', 'lowSecurityBiometric', 'numeric', 'numericComplex', 'any', 'customPassword', 'required')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinutesOfInactivityBeforeLock of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('PasswordExpirationDays of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('PasswordPreviousPasswordCountToBlock of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordCountToBlock

    [DscProperty()]
    [System.ComponentModel.Description('StorageRequireEncryption of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $StorageRequireEncryption

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireIntuneAppIntegrity of the Android Device Owner device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireIntuneAppIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('Block rooted Android devices.')]
    [System.Nullable[System.Boolean]] $SecurityBlockJailbrokenDevices

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance. Inherited from deviceConfiguration')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed')]
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

    [IntuneDeviceCompliancePolicyAndroidDeviceOwner] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceCompliancePolicyAndroidDeviceOwner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Android Work Profile Device Compliance Policy {$($this.DisplayName)}"

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
                    -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.androidDeviceOwnerCompliancePolicy')" `
                    -ExpandProperty 'scheduledActionsForRule($expand=scheduledActionConfigurations)' `
                    -ErrorAction Stop

                if (([array]$devicePolicy).Count -gt 1)
                {
                    throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                }
                if ($null -eq $devicePolicy)
                {
                    Write-Verbose -Message "No Intune Android Device Owner Device Compliance Policy with displayName {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $devicePolicy = $this.ExportedInstance
            }
            $resolvedId = $devicePolicy.Id

            Write-Verbose -Message "Found Intune Android Device Owner Device Compliance Policy with displayName {$($this.DisplayName)}"

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

            $results = @{
                DisplayName                                        = $devicePolicy.DisplayName
                Id                                                 = $devicePolicy.Id
                Description                                        = $devicePolicy.Description
                MinAndroidSecurityPatchLevel                       = $devicePolicy.minAndroidSecurityPatchLevel
                PasswordMinimumLetterCharacters                    = $devicePolicy.passwordMinimumLetterCharacters
                PasswordMinimumLowerCaseCharacters                 = $devicePolicy.passwordMinimumLowerCaseCharacters
                PasswordMinimumNonLetterCharacters                 = $devicePolicy.passwordMinimumNonLetterCharacters
                PasswordMinimumNumericCharacters                   = $devicePolicy.passwordMinimumNumericCharacters
                PasswordMinimumSymbolCharacters                    = $devicePolicy.passwordMinimumSymbolCharacters
                PasswordMinimumUpperCaseCharacters                 = $devicePolicy.passwordMinimumUpperCaseCharacters
                RequireNoPendingSystemUpdates                      = $devicePolicy.requireNoPendingSystemUpdates
                SecurityRequiredAndroidSafetyNetEvaluationType     = $devicePolicy.securityRequiredAndroidSafetyNetEvaluationType
                ScheduledActionsForRule                            = $complexScheduledActionsForRule
                DeviceThreatProtectionEnabled                      = $devicePolicy.deviceThreatProtectionEnabled
                DeviceThreatProtectionRequiredSecurityLevel        = $devicePolicy.deviceThreatProtectionRequiredSecurityLevel
                AdvancedThreatProtectionRequiredSecurityLevel      = $devicePolicy.advancedThreatProtectionRequiredSecurityLevel
                SecurityRequireSafetyNetAttestationBasicIntegrity  = $devicePolicy.securityRequireSafetyNetAttestationBasicIntegrity
                SecurityRequireSafetyNetAttestationCertifiedDevice = $devicePolicy.securityRequireSafetyNetAttestationCertifiedDevice
                OsMinimumVersion                                   = $devicePolicy.osMinimumVersion
                OsMaximumVersion                                   = $devicePolicy.osMaximumVersion
                PasswordRequired                                   = $devicePolicy.passwordRequired
                PasswordMinimumLength                              = $devicePolicy.passwordMinimumLength
                PasswordRequiredType                               = $devicePolicy.passwordRequiredType
                PasswordMinutesOfInactivityBeforeLock              = $devicePolicy.passwordMinutesOfInactivityBeforeLock
                PasswordExpirationDays                             = $devicePolicy.passwordExpirationDays
                PasswordPreviousPasswordCountToBlock               = $devicePolicy.passwordPreviousPasswordCountToBlock
                StorageRequireEncryption                           = $devicePolicy.storageRequireEncryption
                SecurityRequireIntuneAppIntegrity                  = $devicePolicy.securityRequireIntuneAppIntegrity
                SecurityBlockJailbrokenDevices                     = $devicePolicy.securityBlockJailbrokenDevices
                RoleScopeTagIds                                    = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $devicePolicy.roleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                             = 'Present'
                Credential                                         = $this.Credential
                ApplicationId                                      = $this.ApplicationId
                TenantId                                           = $this.TenantId
                ApplicationSecret                                  = $this.ApplicationSecret
                CertificateThumbprint                              = $this.CertificateThumbprint
                CertificatePath                                    = $this.CertificatePath
                CertificatePassword                                = $this.CertificatePassword
                ManagedIdentity                                    = $this.ManagedIdentity
                AccessTokens                                       = $this.AccessTokens
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

        Write-Verbose -Message "Intune Android Device Owner Device Compliance Policy {$($this.DisplayName)}"

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentDeviceAndroidPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
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

        if ($this.Ensure -eq 'Present' -and $currentDeviceAndroidPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Intune Android Work Profile Device Compliance Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerCompliancePolicy')
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
        elseif ($this.Ensure -eq 'Present' -and $currentDeviceAndroidPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Intune Android Device Owner Device Compliance Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidDeviceOwnerCompliancePolicy')
            Update-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $updateParameters `
                -DeviceCompliancePolicyId $currentDeviceAndroidPolicy.Id

            Invoke-MgBetaScheduleDeviceManagementDeviceCompliancePolicyActionForRule `
                -DeviceCompliancePolicyId $currentDeviceAndroidPolicy.Id `
                -DeviceComplianceScheduledActionForRules $complexScheduledActionsForRule

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentDeviceAndroidPolicy.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceCompliancePolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentDeviceAndroidPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune Android Device Owner Device Compliance Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDeviceCompliancePolicy -DeviceCompliancePolicyId $currentDeviceAndroidPolicy.Id
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
            [array]$configDeviceAndroidPolicies = Get-M365DSCExportCachedCollection -Collection 'deviceCompliancePolicies' `
                -ODataType 'microsoft.graph.androidDeviceOwnerCompliancePolicy' `
                -Filter $strippedFilter
            $configDeviceAndroidPolicies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $configDeviceAndroidPolicies

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($configDeviceAndroidPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($configDeviceAndroidPolicy in $configDeviceAndroidPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($configDeviceAndroidPolicies.Count)] $($configDeviceAndroidPolicy.displayName)" -DeferWrite
                $params = @{
                    DisplayName           = $configDeviceAndroidPolicy.displayName
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

                $this.ExportedInstance = $configDeviceAndroidPolicy
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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'ScheduledActionsForRule') `
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

    hidden [IntuneDeviceCompliancePolicyAndroidDeviceOwner] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceCompliancePolicyAndroidDeviceOwner])
        {
            return $Values
        }

        $result = [IntuneDeviceCompliancePolicyAndroidDeviceOwner]::new()
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
