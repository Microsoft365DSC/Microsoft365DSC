using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceCompliancePolicyAndroidWorkProfile : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the AndroidWorkProfile device compliance policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the AndroidWorkProfile device compliance policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('The password complexity types that can be set on Android. One of: NONE, LOW, MEDIUM, HIGH. This is an API targeted to Android 11+.')]
    [ValidateSet('none', 'low', 'medium', 'high')]
    [System.String] $RequiredPasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies Android Work Profile password type.')]
    [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
    [System.String] $WorkProfilePasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies Android Work Profile password complexity.')]
    [ValidateSet('None', 'Low', 'Medium', 'High')]
    [System.String] $WorkProfileRequiredPasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Android Work Profile password is required.')]
    [System.Nullable[System.Boolean]] $WorkProfileRequirePassword

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of previous passwords that cannot be reused in an Android Work Profile compliance policy.')]
    [System.Nullable[System.UInt32]] $WorkProfilePreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Defines the duration of inactivity (in minutes) after which the screen is locked.')]
    [System.Nullable[System.UInt32]] $WorkProfileInactiveBeforeScreenLockInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the minimum number of characters required in a password for an Android Work Profile.')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before a password expires for an Android Work Profile.')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the non-compliance actions.')]
    [MSFT_ScheduledActionConfigurations[]] $ScheduledActionsForRule

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequired of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinimumLength of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('PasswordRequiredType of the AndroidWorkProfile device compliance policy.')]
    [ValidateSet('deviceDefault', 'alphabetic', 'alphanumeric', 'alphanumericWithSymbols', 'lowSecurityBiometric', 'numeric', 'numericComplex', 'any')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('PasswordMinutesOfInactivityBeforeLock of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('PasswordExpirationDays of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('PasswordPreviousPasswordBlockCount of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('PasswordSignInFailureCountBeforeFactoryReset of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.UInt32]] $PasswordSignInFailureCountBeforeFactoryReset

    [DscProperty()]
    [System.ComponentModel.Description('SecurityPreventInstallAppsFromUnknownSources of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityPreventInstallAppsFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('SecurityDisableUsbDebugging of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityDisableUsbDebugging

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireVerifyApps of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireVerifyApps

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionEnabled of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $DeviceThreatProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DeviceThreatProtectionRequiredSecurityLevel of the AndroidWorkProfile device compliance policy.')]
    [ValidateSet('unavailable', 'secured', 'low', 'medium', 'high', 'notSet')]
    [System.String] $DeviceThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('AdvancedThreatProtectionRequiredSecurityLevel of the AndroidWorkProfile device compliance policy.')]
    [ValidateSet('unavailable', 'secured', 'low', 'medium', 'high', 'notSet')]
    [System.String] $AdvancedThreatProtectionRequiredSecurityLevel

    [DscProperty()]
    [System.ComponentModel.Description('SecurityBlockJailbrokenDevices of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityBlockJailbrokenDevices

    [DscProperty()]
    [System.ComponentModel.Description('OsMinimumVersion of the AndroidWorkProfile device compliance policy.')]
    [System.String] $OsMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('OsMaximumVersion of the AndroidWorkProfile device compliance policy.')]
    [System.String] $OsMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('MinAndroidSecurityPatchLevel of the AndroidWorkProfile device compliance policy.')]
    [System.String] $MinAndroidSecurityPatchLevel

    [DscProperty()]
    [System.ComponentModel.Description('StorageRequireEncryption of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $StorageRequireEncryption

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireSafetyNetAttestationBasicIntegrity of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireSafetyNetAttestationBasicIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireSafetyNetAttestationCertifiedDevice of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireSafetyNetAttestationCertifiedDevice

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireGooglePlayServices of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireGooglePlayServices

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireUpToDateSecurityProviders of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireUpToDateSecurityProviders

    [DscProperty()]
    [System.ComponentModel.Description('SecurityRequireCompanyPortalAppIntegrity of the AndroidWorkProfile device compliance policy.')]
    [System.Nullable[System.Boolean]] $SecurityRequireCompanyPortalAppIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('Require a specific SafetyNet evaluation type for compliance.')]
    [ValidateSet('basic', 'hardwareBacked')]
    [System.String] $SecurityRequiredAndroidSafetyNetEvaluationType

    [DscProperty()]
    [System.ComponentModel.Description('RoleScopeTagIds of the AndroidWorkProfile device compliance policy.')]
    [System.String[]] $RoleScopeTagIds

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

    [IntuneDeviceCompliancePolicyAndroidWorkProfile] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceCompliancePolicyAndroidWorkProfile]::new()
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
                    -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.androidWorkProfileCompliancePolicy')" `
                    -ExpandProperty 'scheduledActionsForRule($expand=scheduledActionConfigurations)' `
                    -ErrorAction SilentlyContinue

                if (([array]$devicePolicy).Count -gt 1)
                {
                    throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                }
                if ($null -eq $devicePolicy)
                {
                    Write-Verbose -Message "No Intune Android Work Profile Device Compliance Policy with displayName {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $devicePolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Intune Android Work Profile Device Compliance Policy with displayName {$($this.DisplayName)}"

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
                RequiredPasswordComplexity                         = $devicePolicy.requiredPasswordComplexity
                WorkProfilePasswordRequiredType                    = $devicePolicy.workProfilePasswordRequiredType
                WorkProfileRequiredPasswordComplexity              = $devicePolicy.workProfileRequiredPasswordComplexity
                WorkProfileRequirePassword                         = $devicePolicy.workProfileRequirePassword
                WorkProfilePreviousPasswordBlockCount              = $devicePolicy.workProfilePreviousPasswordBlockCount
                WorkProfileInactiveBeforeScreenLockInMinutes       = $devicePolicy.workProfileInactiveBeforeScreenLockInMinutes
                WorkProfilePasswordMinimumLength                   = $devicePolicy.workProfilePasswordMinimumLength
                WorkProfilePasswordExpirationInDays                = $devicePolicy.workProfilePasswordExpirationInDays
                ScheduledActionsForRule                            = $complexScheduledActionsForRule
                PasswordRequired                                   = $devicePolicy.passwordRequired
                PasswordMinimumLength                              = $devicePolicy.passwordMinimumLength
                PasswordRequiredType                               = $devicePolicy.passwordRequiredType
                PasswordMinutesOfInactivityBeforeLock              = $devicePolicy.passwordMinutesOfInactivityBeforeLock
                PasswordExpirationDays                             = $devicePolicy.passwordExpirationDays
                PasswordPreviousPasswordBlockCount                 = $devicePolicy.passwordPreviousPasswordBlockCount
                PasswordSignInFailureCountBeforeFactoryReset       = $devicePolicy.passwordSignInFailureCountBeforeFactoryReset
                SecurityPreventInstallAppsFromUnknownSources       = $devicePolicy.securityPreventInstallAppsFromUnknownSources
                SecurityDisableUsbDebugging                        = $devicePolicy.securityDisableUsbDebugging
                SecurityRequireVerifyApps                          = $devicePolicy.securityRequireVerifyApps
                DeviceThreatProtectionEnabled                      = $devicePolicy.deviceThreatProtectionEnabled
                DeviceThreatProtectionRequiredSecurityLevel        = $devicePolicy.deviceThreatProtectionRequiredSecurityLevel
                AdvancedThreatProtectionRequiredSecurityLevel      = $devicePolicy.advancedThreatProtectionRequiredSecurityLevel
                SecurityBlockJailbrokenDevices                     = $devicePolicy.securityBlockJailbrokenDevices
                OsMinimumVersion                                   = $devicePolicy.osMinimumVersion
                OsMaximumVersion                                   = $devicePolicy.osMaximumVersion
                MinAndroidSecurityPatchLevel                       = $devicePolicy.minAndroidSecurityPatchLevel
                StorageRequireEncryption                           = $devicePolicy.storageRequireEncryption
                SecurityRequireSafetyNetAttestationBasicIntegrity  = $devicePolicy.securityRequireSafetyNetAttestationBasicIntegrity
                SecurityRequireSafetyNetAttestationCertifiedDevice = $devicePolicy.securityRequireSafetyNetAttestationCertifiedDevice
                SecurityRequireGooglePlayServices                  = $devicePolicy.securityRequireGooglePlayServices
                SecurityRequireUpToDateSecurityProviders           = $devicePolicy.securityRequireUpToDateSecurityProviders
                SecurityRequireCompanyPortalAppIntegrity           = $devicePolicy.securityRequireCompanyPortalAppIntegrity
                SecurityRequiredAndroidSafetyNetEvaluationType     = $devicePolicy.securityRequiredAndroidSafetyNetEvaluationType
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

        Write-Verbose -Message "Setting configuration of the Intune Android Work Profile Device Compliance Policy {$($this.DisplayName)}"

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
            $createParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileCompliancePolicy')
            $createParameters.Add('scheduledActionsForRule', $complexScheduledActionsForRule)
            $policy = New-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $createParameters

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            if ($policy.Id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceCompliancePolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentDeviceAndroidPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Intune Android Work Profile Device Compliance Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileCompliancePolicy')
            Update-MgBetaDeviceManagementDeviceCompliancePolicy -BodyParameter $updateParameters `
                -DeviceCompliancePolicyId $currentDeviceAndroidPolicy.Id

            Invoke-MgBetaScheduleDeviceManagementDeviceCompliancePolicyActionForRule `
                -DeviceCompliancePolicyId $currentDeviceAndroidPolicy.Id `
                -DeviceComplianceScheduledActionForRules $complexScheduledActionsForRule

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentDeviceAndroidPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceCompliancePolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentDeviceAndroidPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune Android Work Profile Device Compliance Policy {$($this.DisplayName)}"
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
                -ODataType 'microsoft.graph.androidWorkProfileCompliancePolicy' `
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

    hidden [IntuneDeviceCompliancePolicyAndroidWorkProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceCompliancePolicyAndroidWorkProfile])
        {
            return $Values
        }

        $result = [IntuneDeviceCompliancePolicyAndroidWorkProfile]::new()
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
