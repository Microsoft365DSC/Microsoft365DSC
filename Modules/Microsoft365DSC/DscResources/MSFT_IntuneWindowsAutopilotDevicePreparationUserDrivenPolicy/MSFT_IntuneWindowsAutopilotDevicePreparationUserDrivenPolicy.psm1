using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy : M365DSCResourceBase
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
    [System.ComponentModel.Description('Deployment mode (0: UserDriven)')]
    [System.Nullable[System.Int32]] $DeploymentMode

    [DscProperty()]
    [System.ComponentModel.Description('Deployment type (0: SingleUser)')]
    [System.Nullable[System.Int32]] $DeploymentType

    [DscProperty()]
    [System.ComponentModel.Description('Join type (0: EntraIdJoined)')]
    [System.Nullable[System.Int32]] $JoinType

    [DscProperty()]
    [System.ComponentModel.Description('User account type (0: Administrator, 1: StandardUser)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AccountType

    [DscProperty()]
    [System.ComponentModel.Description('Minutes allowed before showing installation error')]
    [ValidateRange(15, 720)]
    [System.Nullable[System.Int32]] $Timeout

    [DscProperty()]
    [System.ComponentModel.Description('Custom error message')]
    [System.String] $CustomErrorMessage

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to skip setup after multiple attempts (false: No, true: Yes)')]
    [ValidateSet('false', 'true')]
    [System.String] $AllowSkip

    [DscProperty()]
    [System.ComponentModel.Description('Show link to diagnostics (false: No, true: Yes)')]
    [ValidateSet('false', 'true')]
    [System.String] $AllowDiagnostics

    [DscProperty()]
    [System.ComponentModel.Description('Allowed applications')]
    [ValidateLength(0, 1000)]
    [System.String[]] $AllowedApplications

    [DscProperty()]
    [System.ComponentModel.Description('Allowed scripts')]
    [ValidateLength(0, 1000)]
    [System.String[]] $AllowedScripts

    [DscProperty()]
    [System.ComponentModel.Description('Device security group')]
    [System.String] $AssignmentTarget

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

    [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    $getValue = Invoke-M365DSCCommand -ScriptBlock {
                        Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id  -ErrorAction Stop `
                            -ExpandProperty 'settings($expand=settingDefinitions)'
                    } -SuppressNotFoundError
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Invoke-M365DSCCommand -ScriptBlock {
                            Get-MgBetaDeviceManagementConfigurationPolicy `
                                -All `
                                -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/templateId eq '80d33118-b7b4-40d8-b15f-81be745e053f_1'" `
                                -ErrorAction SilentlyContinue
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Autopilot Device Preparation User Driven Policy with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

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

            $batchRequestsScripts = @()
            $batchRequestsApps = @()

            foreach ($script in $policySettings.AllowedScriptIds)
            {
                $batchRequestsScripts += @{
                    id = $script
                    method = 'GET'
                    url = "/deviceManagement/deviceManagementScripts/$($script)?`$select=id,displayName"
                }
            }
            foreach ($app in $policySettings.AllowedApplicationIds)
            {
                $convertedApp = $app | ConvertFrom-Json
                $batchRequestsApps += @{
                    id = $convertedApp.id
                    method = 'GET'
                    url = "/deviceAppManagement/mobileApps/$($convertedApp.id)?`$select=id,displayName"
                }
            }
            $policySettings.Remove('AllowedScriptIds')
            $policySettings.Remove('AllowedApplicationIds')

            $batchResponsesScripts = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsScripts
            $batchResponsesApps = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsApps

            $results = @{
                #region resource generator code
                Description                       = $getValue.Description
                DisplayName                       = $getValue.Name
                RoleScopeTagIds                   = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                                = $getValue.Id
                AllowedApplications               = Get-M365DSCArrayFromProperty -PropertyValue ($batchResponsesApps | ForEach-Object { $_.body.displayName }) -ElementType ([System.String])
                AllowedScripts                    = Get-M365DSCArrayFromProperty -PropertyValue ($batchResponsesScripts | ForEach-Object { $_.body.displayName }) -ElementType ([System.String])
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                ApplicationSecret                 = $this.ApplicationSecret
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                #endregion
            }
            $results += $policySettings

            $target = Get-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -DeviceManagementConfigurationPolicyId $resolvedId
            $assignmentResult = ""
            if ($target.enrollmentTimeDeviceMembershipTargetValidationStatuses.Count -gt 0)
            {
                $groupId = $target.enrollmentTimeDeviceMembershipTargetValidationStatuses[0].targetId
                $resolvedGroup = Get-M365DSCIntuneGroup -GroupId $groupId
                $assignmentResult = $resolvedGroup.displayName
            }
            $results.Add('AssignmentTarget', $assignmentResult)

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

        Write-Verbose -Message "Setting configuration of the Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('AssignmentTarget') | Out-Null

        $templateReferenceId = '80d33118-b7b4-40d8-b15f-81be745e053f_1'
        $platforms = 'windows10'
        $technologies = 'enrollment'

        if ($this.GetBoundParameters().ContainsKey('AllowedScripts'))
        {
            $batchRequestsScripts = @()
            foreach ($script in $this.AllowedScripts)
            {
                $batchRequestsScripts += @{
                    id = $script
                    method = 'GET'
                    url = "/deviceManagement/deviceManagementScripts?`$filter=displayName eq '$($script -replace "'", "''")'&`$select=id,displayName"
                }
            }
            $batchResponsesScripts = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsScripts

            $boundParameters.Remove('AllowedScripts') | Out-Null
            $newScripts = @()
            foreach ($script in $batchResponsesScripts.body.value)
            {
                $newScripts += $script.id
            }
            $boundParameters.Add('allowedScriptIds', $newScripts)
        }

        if ($this.GetBoundParameters().ContainsKey('AllowedApplications'))
        {
            $batchRequestsApps = @()
            foreach ($app in $this.AllowedApplications)
            {
                $batchRequestsApps += @{
                    id = $app
                    method = 'GET'
                    url = "/deviceAppManagement/mobileApps?`$filter=displayName eq '$($app -replace "'", "''")'&`$select=id,displayName"
                }
            }
            $batchResponsesApps = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsApps
            $newApps = @()
            foreach ($app in $batchResponsesApps.body.value)
            {
                $newApps += @{
                    id = $app.id
                    type = $app.'@odata.type'
                } | ConvertTo-Json -Compress
            }
            $boundParameters.Add('allowedApplicationIds', $newApps)
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Windows Autopilot Device Preparation User Driven Policy with Name {$($this.DisplayName)}"
            $boundParameters.Remove("Assignments") | Out-Null

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

            if ($policy.Id -and $this.GetBoundParameters().ContainsKey('AssignmentTarget'))
            {
                if (-not [System.String]::IsNullOrEmpty($this.AssignmentTarget))
                {
                    [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy]::SetAssignmentTarget($policy.Id, $this.AssignmentTarget)
                }
            }

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
            Write-Verbose -Message "Updating the Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($currentInstance.Id)}"
            $boundParameters.Remove("Assignments") | Out-Null

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

            if ($this.GetBoundParameters().ContainsKey('AssignmentTarget'))
            {
                if (-not [System.String]::IsNullOrEmpty($this.AssignmentTarget))
                {
                    [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy]::SetAssignmentTarget($currentInstance.Id, $this.AssignmentTarget)
                }
                else
                {
                    Clear-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -DeviceManagementConfigurationPolicyId $currentInstance.Id
                }
            }

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Autopilot Device Preparation User Driven Policy with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = '80d33118-b7b4-40d8-b15f-81be745e053f_1'
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
                if (-not [System.String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [System.String]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
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

    hidden [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy])
        {
            return $Values
        }

        $result = [IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }

    hidden static [void] SetAssignmentTarget([System.String] $PolicyId, [System.String] $GroupDisplayName)
    {
        $group = Get-MgGroup -All -Filter "displayName eq '$($GroupDisplayName -replace "'", "''")'" -Property 'id' -ErrorAction Stop
        if ($null -eq $group)
        {
            throw "Could not find the device group {$GroupDisplayName}."
        }

        $result = Set-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget `
            -DeviceManagementConfigurationPolicyId $PolicyId `
            -BodyParameter @{
                enrollmentTimeDeviceMembershipTargets = @(
                    @{
                        targetId   = $group.Id
                        targetType = 'staticSecurityGroup'
                    }
                )
            }
        if ($null -ne $result -and $result.validationSucceeded -eq $false)
        {
            $errorCodes = @($result.enrollmentTimeDeviceMembershipTargetValidationStatuses.targetValidationErrorCode) -join ', '
            throw "The device group {$GroupDisplayName} was rejected as the target of the policy: $errorCodes"
        }
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
