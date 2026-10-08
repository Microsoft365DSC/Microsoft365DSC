using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceRemediation : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Description of the device health script')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The entire content of the detection powershell script')]
    [System.String] $DetectionScriptContent

    [DscProperty()]
    [System.ComponentModel.Description('List of ComplexType DetectionScriptParameters objects.')]
    [MSFT_MicrosoftGraphdeviceHealthScriptParameter[]] $DetectionScriptParameters

    [DscProperty()]
    [System.ComponentModel.Description('DeviceHealthScriptType for the script policy. Possible values are: deviceHealthScript, managedInstallerScript.')]
    [ValidateSet('deviceHealthScript', 'managedInstallerScript')]
    [System.String] $DeviceHealthScriptType

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the device health script')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the script signature needs be checked')]
    [System.Nullable[System.Boolean]] $EnforceSignatureCheck

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the script is a global script provided by Microsoft')]
    [System.Nullable[System.Boolean]] $IsGlobalScript

    [DscProperty()]
    [System.ComponentModel.Description('Name of the device health script publisher')]
    [System.String] $Publisher

    [DscProperty()]
    [System.ComponentModel.Description('The entire content of the remediation powershell script')]
    [System.String] $RemediationScriptContent

    [DscProperty()]
    [System.ComponentModel.Description('List of ComplexType RemediationScriptParameters objects.')]
    [MSFT_MicrosoftGraphdeviceHealthScriptParameter[]] $RemediationScriptParameters

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for the device health script')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Indicate whether PowerShell script(s) should run as 32-bit')]
    [System.Nullable[System.Boolean]] $RunAs32Bit

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of execution context. Possible values are: system, user.')]
    [ValidateSet('system', 'user')]
    [System.String] $RunAsAccount

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_IntuneDeviceRemediationPolicyAssignments[]] $Assignments

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

    [IntuneDeviceRemediation] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceRemediation]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Remediation with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = $null
            #region resource generator code
            if (-not [string]::IsNullOrEmpty($this.Id))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $this.Id -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Could not find an Intune Device Remediation with Id {$($this.Id)}"
                }

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    $matchingScripts = Get-MgBetaDeviceManagementDeviceHealthScript `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue | Where-Object `
                        -FilterScript {
                            $_.DeviceHealthScriptType -eq 'deviceHealthScript' `
                    }

                    if ($null -ne $matchingScripts)
                    {
                        if ($matchingScripts -is [array] -and $matchingScripts.Count -gt 1)
                        {
                            throw "Multiple Intune Device Remediation scripts found with DisplayName '$($this.DisplayName)'. Please specify the Id parameter to identify which script to manage. Found scripts: $($matchingScripts.Id -join ', ')"
                        }
                        $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $matchingScripts.Id
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Device Remediation with DisplayName {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Remediation with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexDetectionScriptParameters = @()
            foreach ($currentDetectionScriptParameters in $getValue.detectionScriptParameters)
            {
                $myDetectionScriptParameters = [ordered]@{}
                $myDetectionScriptParameters.Add('ApplyDefaultValueWhenNotAssigned', $currentDetectionScriptParameters.applyDefaultValueWhenNotAssigned)
                $myDetectionScriptParameters.Add('Description', $currentDetectionScriptParameters.description)
                $myDetectionScriptParameters.Add('IsRequired', $currentDetectionScriptParameters.isRequired)
                $myDetectionScriptParameters.Add('Name', $currentDetectionScriptParameters.name)
                $myDetectionScriptParameters.Add('DefaultValue', $currentDetectionScriptParameters.defaultValue)
                if ($null -ne $currentDetectionScriptParameters.'@odata.type')
                {
                    $myDetectionScriptParameters.Add('odataType', $currentDetectionScriptParameters.'@odata.type')
                }
                if ($myDetectionScriptParameters.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexDetectionScriptParameters += $myDetectionScriptParameters
                }
            }

            $complexRemediationScriptParameters = @()
            foreach ($currentRemediationScriptParameters in $getValue.remediationScriptParameters)
            {
                $myRemediationScriptParameters = [ordered]@{}
                $myRemediationScriptParameters.Add('ApplyDefaultValueWhenNotAssigned', $currentRemediationScriptParameters.applyDefaultValueWhenNotAssigned)
                $myRemediationScriptParameters.Add('Description', $currentRemediationScriptParameters.description)
                $myRemediationScriptParameters.Add('IsRequired', $currentRemediationScriptParameters.isRequired)
                $myRemediationScriptParameters.Add('Name', $currentRemediationScriptParameters.name)
                $myRemediationScriptParameters.Add('DefaultValue', $currentRemediationScriptParameters.defaultValue)
                if ($null -ne $currentRemediationScriptParameters.'@odata.type')
                {
                    $myRemediationScriptParameters.Add('odataType', $currentRemediationScriptParameters.'@odata.type')
                }
                if ($myRemediationScriptParameters.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexRemediationScriptParameters += $myRemediationScriptParameters
                }
            }
            #endregion

            $results = @{
                #region resource generator code
                Description                 = $getValue.Description
                DetectionScriptContent      = $getValue.DetectionScriptContent
                DetectionScriptParameters   = $complexDetectionScriptParameters
                DeviceHealthScriptType      = $getValue.DeviceHealthScriptType
                DisplayName                 = $getValue.DisplayName
                EnforceSignatureCheck       = $getValue.EnforceSignatureCheck
                IsGlobalScript              = $getValue.IsGlobalScript
                Publisher                   = $getValue.Publisher
                RemediationScriptContent    = $getValue.RemediationScriptContent
                RemediationScriptParameters = $complexRemediationScriptParameters
                RoleScopeTagIds             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                RunAs32Bit                  = $getValue.RunAs32Bit
                RunAsAccount                = $getValue.RunAsAccount
                Id                          = $getValue.Id
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                TenantId                    = $this.TenantId
                ApplicationSecret           = $this.ApplicationSecret
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                AccessTokens                = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-MgBetaDeviceManagementDeviceHealthScriptAssignment -DeviceHealthScriptId $resolvedId
            $assignmentResult = @()
            foreach ($assignment in $assignmentsValues)
            {
                if (-not [System.String]::IsNullOrEmpty($assignment.RunSchedule.time))
                {
                    $time = Get-Date -Format 'HH:mm:ss' -Date $assignment.RunSchedule.time
                }
                else
                {
                    $time = $null
                }

                $assignmentResult += [ordered]@{
                    Assignment           = (ConvertFrom-IntunePolicyAssignment `
                            -IncludeDeviceFilter:$true `
                            -Assignments $assignment) | Select-Object -First 1
                    RunRemediationScript = $assignment.runRemediationScript
                    RunSchedule          = [ordered]@{
                        DataType = $assignment.RunSchedule.'@odata.type'
                        Date     = $assignment.RunSchedule.date
                        Interval = $assignment.RunSchedule.Interval
                        Time     = $time
                        UseUtc   = $assignment.RunSchedule.useUtc
                    }
                }
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

        $boundParameters.Remove('IsGlobalScript') | Out-Null

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Remediation with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaDeviceManagementDeviceHealthScript -BodyParameter $createParameters
            $assignmentsHash = @()
            foreach ($assignment in $this.Assignments)
            {
                $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment.Assignment
                $runSchedule = $null
                if ($null -ne $assignment.RunSchedule.DataType)
                {
                    $runSchedule = @{
                        '@odata.type' = $assignment.RunSchedule.DataType
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Date))
                    {
                        $runSchedule.Add('date', $assignment.RunSchedule.Date)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Interval))
                    {
                        $runSchedule.Add('interval', $assignment.RunSchedule.Interval)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Time))
                    {
                        $runSchedule.Add('time', $assignment.RunSchedule.Time)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.UseUtc))
                    {
                        $runSchedule.Add('useUtc', $assignment.RunSchedule.UseUtc)
                    }
                }
                $assignmentsHash += @{
                    runRemediationScript = $true
                    runSchedule          = $runSchedule
                    target               = $assignmentTarget.target
                }
            }

            if ($policy.Id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceHealthScripts' `
                    -RootIdentifier 'deviceHealthScriptAssignments'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Remediation with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('DeviceHealthScriptType') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            if ($currentInstance.IsGlobalScript)
            {
                Write-Warning -Message "The Intune Device Remediation with Id {$($currentInstance.Id)} is a global script and only few properties can be updated."
                $updateParameters = @{
                    Id              = $currentInstance.Id
                    RoleScopeTagIds = $resolvedRoleScopeTagIds
                    RunAs32Bit      = $this.RunAs32Bit
                    RunAsAccount    = $this.RunAsAccount
                }
            }

            #region resource generator code
            Update-MgBetaDeviceManagementDeviceHealthScript `
                -DeviceHealthScriptId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = @()
            foreach ($assignment in $this.Assignments)
            {
                $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment.Assignment
                $runSchedule = $null
                if ($null -ne $assignment.RunSchedule.DataType)
                {
                    $runSchedule = @{
                        '@odata.type' = $assignment.RunSchedule.DataType
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Date))
                    {
                        $runSchedule.Add('date', $assignment.RunSchedule.Date)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Interval))
                    {
                        $runSchedule.Add('interval', $assignment.RunSchedule.Interval)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.Time))
                    {
                        $runSchedule.Add('time', $assignment.RunSchedule.Time)
                    }
                    if (-not [string]::IsNullOrEmpty($assignment.RunSchedule.UseUtc))
                    {
                        $runSchedule.Add('useUtc', $assignment.RunSchedule.UseUtc)
                    }
                }
                $assignmentsHash += @{
                    runRemediationScript = $true
                    runSchedule          = $runSchedule
                    target               = $assignmentTarget.target
                }
            }
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceHealthScripts' `
                -RootIdentifier 'deviceHealthScriptAssignments'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($currentInstance.IsGlobalScript)
            {
                throw "The Intune Device Remediation with Id {$($currentInstance.Id)} is a global script and cannot be removed."
            }
            Write-Verbose -Message "Removing the Intune Device Remediation with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $currentInstance.Id
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
            # Only export scripts that are not from Microsoft
            [array]$getValue = Get-MgBetaDeviceManagementDeviceHealthScript `
                -Filter $this.Filter `
                -All `
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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.DisplayName))
                {
                    $displayedKey = $config.DisplayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
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

                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.DetectionScriptParameters)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DetectionScriptParameters `
                        -CIMInstanceName 'MicrosoftGraphdeviceHealthScriptParameter'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DetectionScriptParameters = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DetectionScriptParameters') | Out-Null
                    }
                }
                if ($null -ne $Results.RemediationScriptParameters)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RemediationScriptParameters `
                        -CIMInstanceName 'MicrosoftGraphdeviceHealthScriptParameter'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.RemediationScriptParameters = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RemediationScriptParameters') | Out-Null
                    }
                }
                if ($Results.Assignments)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'RunSchedule'
                            CimInstanceName = 'IntuneDeviceRemediationRunSchedule'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'Assignment'
                            CimInstanceName = 'DeviceManagementConfigurationPolicyAssignments'
                            IsRequired      = $true
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Assignments `
                        -CIMInstanceName 'MSFT_IntuneDeviceRemediationPolicyAssignments' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [string]::IsNullOrEmpty($complexTypeStringResult))
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
                    -NoEscape @('DetectionScriptParameters', 'RemediationScriptParameters', 'Assignments') `
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
        return @{
            ExcludedProperties = @('IsGlobalScript')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($CurrentValues.IsGlobalScript)
                {
                    Write-Verbose -Message 'Detected a global script, removing read-only properties from the comparison'
                    $ValuesToCheck.Remove('DetectionScriptContent') | Out-Null
                    $ValuesToCheck.Remove('RemediationScriptContent') | Out-Null
                    $ValuesToCheck.Remove('DetectionScriptParameters') | Out-Null
                    $ValuesToCheck.Remove('RemediationScriptParameters') | Out-Null
                    $ValuesToCheck.Remove('DeviceHealthScriptType') | Out-Null
                    $ValuesToCheck.Remove('Publisher') | Out-Null
                    $ValuesToCheck.Remove('EnforceSignatureCheck') | Out-Null
                    $ValuesToCheck.Remove('DisplayName') | Out-Null
                    $ValuesToCheck.Remove('Description') | Out-Null
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [IntuneDeviceRemediation] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceRemediation])
        {
            return $Values
        }

        $result = [IntuneDeviceRemediation]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphdeviceHealthScriptParameter
{
    [DscProperty()]
    [System.ComponentModel.Description('Whether Apply DefaultValue When Not Assigned')]
    [System.Nullable[System.Boolean]] $ApplyDefaultValueWhenNotAssigned

    [DscProperty()]
    [System.ComponentModel.Description('The description of the param')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Whether the param is required')]
    [System.Nullable[System.Boolean]] $IsRequired

    [DscProperty()]
    [System.ComponentModel.Description('The name of the param')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The default value of boolean param')]
    [System.Nullable[System.Boolean]] $DefaultValue

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.deviceHealthScriptBooleanParameter', '#microsoft.graph.deviceHealthScriptIntegerParameter', '#microsoft.graph.deviceHealthScriptStringParameter')]
    [System.String] $odataType
}

class MSFT_IntuneDeviceRemediationPolicyAssignments
{
    [DscProperty()]
    [System.ComponentModel.Description('If the remediation script should be run.')]
    [System.Nullable[System.Boolean]] $RunRemediationScript

    [DscProperty()]
    [System.ComponentModel.Description('The run schedule of the remediation.')]
    [MSFT_IntuneDeviceRemediationRunSchedule] $RunSchedule

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment of the schedule.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments] $Assignment
}

class MSFT_IntuneDeviceRemediationRunSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the schedule.')]
    [ValidateSet('#microsoft.graph.deviceHealthScriptRunOnceSchedule', '#microsoft.graph.deviceHealthScriptHourlySchedule', '#microsoft.graph.deviceHealthScriptDailySchedule')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The date when to run the schedule. Only applicable when the odataType is a run once schedule. Format: 2024-01-01')]
    [System.String] $Date

    [DscProperty()]
    [System.ComponentModel.Description('The interval of the schedule. Must be 1 in case of a run once schedule.')]
    [System.Nullable[System.UInt32]] $Interval

    [DscProperty()]
    [System.ComponentModel.Description('The time when to run the schedule. Only applicable when the dataType is not an hourly schedule. Format: 01:00:00')]
    [System.String] $Time

    [DscProperty()]
    [System.ComponentModel.Description('If to use UTC as the time source. Only applicable when the dataType is not an hourly schedule.')]
    [System.Nullable[System.Boolean]] $UseUtc
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
