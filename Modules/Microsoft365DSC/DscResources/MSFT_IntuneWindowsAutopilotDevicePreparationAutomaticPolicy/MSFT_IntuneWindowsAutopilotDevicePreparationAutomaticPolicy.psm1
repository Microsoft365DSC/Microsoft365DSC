using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsAutopilotDevicePreparationAutomaticPolicy : M365DSCResourceBase
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
    [System.ComponentModel.Description('Allowed applications')]
    [ValidateLength(0, 1000)]
    [System.String[]] $AllowedApplications

    [DscProperty()]
    [System.ComponentModel.Description('Allowed scripts')]
    [ValidateLength(0, 1000)]
    [System.String[]] $AllowedScripts

    [DscProperty()]
    [System.ComponentModel.Description('The group assigned as the target of the policy')]
    [System.String] $AssignmentTarget

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

    [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Invoke-M365DSCCommand -ScriptBlock {
                            Get-MgBetaDeviceManagementConfigurationPolicy `
                                -All `
                                -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/templateId eq 'a6157a7f-aa00-42d9-ac82-7d2479f545db_1'" `
                                -ErrorAction SilentlyContinue
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Autopilot Device Preparation Automatic Policy with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

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

            $batchResponsesScripts = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsScripts
            $batchResponsesApps = Invoke-M365DSCGraphBatchRequest -Requests $batchRequestsApps

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                AllowedApplications   = Get-M365DSCArrayFromProperty -PropertyValue ($batchResponsesApps | ForEach-Object { $_.body.displayName }) -ElementType ([System.String])
                AllowedScripts        = Get-M365DSCArrayFromProperty -PropertyValue ($batchResponsesScripts | ForEach-Object { $_.body.displayName }) -ElementType ([System.String])
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

            $target = Get-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -DeviceManagementConfigurationPolicyId $resolvedId
            $assignmentResult = ""
            if ($target.enrollmentTimeDeviceMembershipTargetValidationStatuses.Count -gt 0)
            {
                $groupId = $target.enrollmentTimeDeviceMembershipTargetValidationStatuses[0].targetId
                $resolvedGroup = Get-M365DSCIntuneGroup -GroupId $groupId
                $assignmentResult = $resolvedGroup.displayName
            }
            $results.Add('AssignmentTarget', $assignmentResult)

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

        Write-Verbose -Message "Setting configuration of the Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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

        $templateReferenceId = 'a6157a7f-aa00-42d9-ac82-7d2479f545db_1'
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
            Write-Verbose -Message "Creating an Intune Windows Autopilot Device Preparation Automatic Policy with Name {$($this.DisplayName)}"

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

            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id -and $this.GetBoundParameters().ContainsKey('AssignmentTarget'))
            {
                if (-not [System.String]::IsNullOrEmpty($this.AssignmentTarget))
                {
                    [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy]::SetAssignmentTarget($policy.Id, $this.AssignmentTarget)
                }
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($currentInstance.Id)}"

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

            if ($this.GetBoundParameters().ContainsKey('AssignmentTarget'))
            {
                if (-not [System.String]::IsNullOrEmpty($this.AssignmentTarget))
                {
                    [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy]::SetAssignmentTarget($currentInstance.Id, $this.AssignmentTarget)
                }
                else
                {
                    Clear-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -DeviceManagementConfigurationPolicyId $currentInstance.Id
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Autopilot Device Preparation Automatic Policy with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = 'a6157a7f-aa00-42d9-ac82-7d2479f545db_1'
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
                    DisplayName           = $config.name
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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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

    hidden [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy])
        {
            return $Values
        }

        $result = [IntuneWindowsAutopilotDevicePreparationAutomaticPolicy]::new()
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
