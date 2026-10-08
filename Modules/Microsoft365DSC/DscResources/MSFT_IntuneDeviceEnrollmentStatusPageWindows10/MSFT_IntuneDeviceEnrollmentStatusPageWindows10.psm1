using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceEnrollmentStatusPageWindows10 : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the device enrollment configuration')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The description of the device enrollment configuration')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block device reset on installation failure')]
    [System.Nullable[System.Boolean]] $AllowDeviceResetOnInstallFailure

    [DscProperty()]
    [System.ComponentModel.Description('Allow the user to continue using the device on installation failure')]
    [System.Nullable[System.Boolean]] $AllowDeviceUseOnInstallFailure

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block log collection on installation failure')]
    [System.Nullable[System.Boolean]] $AllowLogCollectionOnInstallFailure

    [DscProperty()]
    [System.ComponentModel.Description('Install all required apps as non blocking apps during white glove')]
    [System.Nullable[System.Boolean]] $AllowNonBlockingAppInstallation

    [DscProperty()]
    [System.ComponentModel.Description('Allow the user to retry the setup on installation failure')]
    [System.Nullable[System.Boolean]] $BlockDeviceSetupRetryByUser

    [DscProperty()]
    [System.ComponentModel.Description('Set custom error message to show upon installation failure')]
    [System.String] $CustomErrorMessage

    [DscProperty()]
    [System.ComponentModel.Description('Only show installation progress for first user post enrollment')]
    [System.Nullable[System.Boolean]] $DisableUserStatusTrackingAfterFirstUser

    [DscProperty()]
    [System.ComponentModel.Description('Set installation progress timeout in minutes')]
    [System.Nullable[System.UInt32]] $InstallProgressTimeoutInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Allows quality updates installation during OOBE')]
    [System.Nullable[System.Boolean]] $InstallQualityUpdates

    [DscProperty()]
    [System.ComponentModel.Description('Ids of selected applications to track the installation status. When this parameter is used, SelectedMobileAppNames is ignored')]
    [System.String[]] $SelectedMobileAppIds

    [DscProperty()]
    [System.ComponentModel.Description('Names of selected applications to track the installation status. This parameter is ignored when SelectedMobileAppIds is also specified')]
    [System.String[]] $SelectedMobileAppNames

    [DscProperty()]
    [System.ComponentModel.Description('Show or hide installation progress to user')]
    [System.Nullable[System.Boolean]] $ShowInstallationProgress

    [DscProperty()]
    [System.ComponentModel.Description('Only show installation progress for Autopilot enrollment scenarios')]
    [System.Nullable[System.Boolean]] $TrackInstallProgressForAutopilotOnly

    [DscProperty()]
    [System.ComponentModel.Description('Priority is used when a user exists in multiple groups that are assigned enrollment configuration. Users are subject only to the configuration with the lowest priority value.')]
    [System.Nullable[System.UInt32]] $Priority

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

    [IntuneDeviceEnrollmentStatusPageWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceEnrollmentStatusPageWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Enrollment Status Page for Windows 10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if ($this.GetBoundParameters().ContainsKey('SelectedMobileAppIds') -and $this.GetBoundParameters().ContainsKey('SelectedMobileAppNames'))
                {
                    Write-Verbose -Message '[WARNING] Both SelectedMobileAppIds and SelectedMobileAppNames are specified. SelectedMobileAppIds will be ignored!'
                }

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $this.Id -ErrorAction SilentlyContinue `
                        | Where-Object -FilterScript { $null -ne $_.DisplayName }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Enrollment Configuration for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue | Where-Object `
                            -FilterScript {
                                $_.'@odata.type' -eq '#microsoft.graph.windows10EnrollmentCompletionPageConfiguration' -and $null -ne $_.DisplayName
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Enrollment Configuration for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }

                if ($getValue -is [Array] -and $getValue.Length -gt 1)
                {
                    throw "The DisplayName {$($this.DisplayName)} returned multiple policies, make sure DisplayName is unique."
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Enrollment Configuration for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $SelectedMobileAppNamesValue = @()
            foreach ($mobileApp in $getValue.selectedMobileAppIds)
            {
                $mobileEntry = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $mobileApp
                $SelectedMobileAppNamesValue += $mobileEntry.DisplayName
            }

            $results = @{
                #region resource generator code
                AllowDeviceResetOnInstallFailure        = $getValue.allowDeviceResetOnInstallFailure
                AllowDeviceUseOnInstallFailure          = $getValue.allowDeviceUseOnInstallFailure
                AllowLogCollectionOnInstallFailure      = $getValue.allowLogCollectionOnInstallFailure
                AllowNonBlockingAppInstallation         = $getValue.allowNonBlockingAppInstallation
                BlockDeviceSetupRetryByUser             = $getValue.blockDeviceSetupRetryByUser
                CustomErrorMessage                      = $getValue.customErrorMessage
                DisableUserStatusTrackingAfterFirstUser = $getValue.disableUserStatusTrackingAfterFirstUser
                InstallProgressTimeoutInMinutes         = $getValue.installProgressTimeoutInMinutes
                InstallQualityUpdates                   = $getValue.installQualityUpdates
                SelectedMobileAppNames                  = $SelectedMobileAppNamesValue
                SelectedMobileAppIds                    = $getValue.selectedMobileAppIds
                ShowInstallationProgress                = $getValue.showInstallationProgress
                TrackInstallProgressForAutopilotOnly    = $getValue.trackInstallProgressForAutopilotOnly
                Priority                                = $getValue.Priority
                Description                             = $getValue.Description
                DisplayName                             = $getValue.DisplayName
                Id                                      = $getValue.Id
                RoleScopeTagIds                         = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                  = 'Present'
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                ApplicationSecret                       = $this.ApplicationSecret
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceEnrollmentConfigurationAssignment -DeviceEnrollmentConfigurationId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                [array]$assignmentsValues = $assignmentsValues | Where-Object -FilterScript { $_.source -eq 'direct' }
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
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

        Write-Verbose -Message "Setting configuration of the Intune Device Enrollment Status Page for Windows 10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('SelectedMobileAppNames') -eq $true)
        {
            Write-Verbose -Message 'Converting SelectedMobileAppNames to SelectedMobileAppIds'
            if ($boundParameters.SelectedMobileAppNames.Count -ne 0)
            {
                [Array]$mobileAppIds = $boundParameters.SelectedMobileAppNames | ForEach-Object { (Get-MgBetaDeviceAppManagementMobileApp -All -Filter "DisplayName eq '$($_ -replace "'", "''")'").Id }
                $boundParameters.SelectedMobileAppIds = $mobileAppIds
            }
            else
            {
                $boundParameters.SelectedMobileAppIds = @()
            }
            $boundParameters.Remove('SelectedMobileAppNames') | Out-Null
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Enrollment Configuration for Windows10 with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Priority') | Out-Null

            #region resource generator code
            if ($createParameters.showInstallationProgress -eq $false)
            {
                $createParameters.blockDeviceSetupRetryByUser = $true
                $createParameters.Remove('allowLogCollectionOnInstallFailure') | Out-Null
                $createParameters.Remove('allowNonBlockingAppInstallation') | Out-Null
                $createParameters.Remove('customErrorMessage') | Out-Null
                $createParameters.Remove('disableUserStatusTrackingAfterFirstUser') | Out-Null
                $createParameters.Remove('installProgressTimeoutInMinutes') | Out-Null
                $createParameters.Remove('installQualityUpdates') | Out-Null
                $createParameters.Remove('trackInstallProgressForAutopilotOnly') | Out-Null
            }

            if ($createParameters.blockDeviceSetupRetryByUser -eq $true)
            {
                $createParameters.Remove('allowDeviceUseOnInstallFailure') | Out-Null
                $createParameters.Remove('allowDeviceResetOnInstallFailure') | Out-Null
                $createParameters.Remove('selectedMobileAppIds') | Out-Null
            }

            $createParameters.Add('@odata.type', '#microsoft.graph.windows10EnrollmentCompletionPageConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceEnrollmentConfiguration -BodyParameter $createParameters

            $intuneAssignments = @()
            if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
            {
                $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
            }
            Set-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $policy.Id `
                -EnrollmentConfigurationAssignments $intuneAssignments `
                -ErrorAction Stop

            if ($createParameters.ContainsKey('Priority') -and $policy.Priority -ne $this.Priority)
            {
                $this.UpdateDeviceEnrollmentConfigurationPriority($policy.id, $this.Priority)
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Enrollment Configuration for Windows10 with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Priority') | Out-Null

            #region resource generator code
            if ($updateParameters.blockDeviceSetupRetryByUser -eq $true)
            {
                $updateParameters.Remove('allowDeviceUseOnInstallFailure') | Out-Null
                $updateParameters.Remove('allowDeviceResetOnInstallFailure') | Out-Null
                $updateParameters.Remove('selectedMobileAppIds') | Out-Null
            }

            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10EnrollmentCompletionPageConfiguration')
            Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
                -DeviceEnrollmentConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters

            if ($currentInstance.Id -notlike '*_DefaultWindows10EnrollmentCompletionPageConfiguration')
            {
                $intuneAssignments = @()
                if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
                {
                    $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
                }
                Set-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $currentInstance.Id `
                    -EnrollmentConfigurationAssignments $intuneAssignments `
                    -ErrorAction Stop

                if ($updateParameters.ContainsKey('Priority') -and $this.Priority -ne $currentInstance.Priority)
                {
                    $this.UpdateDeviceEnrollmentConfigurationPriority($currentInstance.id, $this.Priority)
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Enrollment Configuration for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $currentInstance.Id
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
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceEnrollmentConfigurations' `
                -ODataType 'microsoft.graph.windows10EnrollmentCompletionPageConfiguration' `
                -Filter $this.Filter
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
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.displayName
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
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

    # TODO: Only do this if not doing a Report. It requires a connection to the Graph workload, which is not available when doing a report.
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SelectedMobileAppIds')
            # Compare on app display names: resolve desired ids to names, then drop the id lists.
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                if ($DesiredValues.ContainsKey('SelectedMobileAppIds') -and -not $DesiredValues.ContainsKey('SelectedMobileAppNames'))
                {
                    $resolvedNames = @()
                    foreach ($appId in $DesiredValues.SelectedMobileAppIds)
                    {
                        $resolvedNames += (Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $appId).DisplayName
                    }
                    $DesiredValues.SelectedMobileAppNames = $resolvedNames
                    $ValuesToCheck.SelectedMobileAppNames = $resolvedNames
                }
                $DesiredValues.Remove('SelectedMobileAppIds') | Out-Null
                $ValuesToCheck.Remove('SelectedMobileAppIds') | Out-Null
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [void] UpdateDeviceEnrollmentConfigurationPriority([System.String] $DeviceEnrollmentConfigurationId, [System.UInt32] $Priority)
    {
        try
        {
            $null = Set-MgBetaDeviceManagementDeviceEnrollmentConfigurationPriority `
                -DeviceEnrollmentConfigurationId $DeviceEnrollmentConfigurationId `
                -Priority $Priority `
                -ErrorAction Stop 4> $null
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    hidden [IntuneDeviceEnrollmentStatusPageWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceEnrollmentStatusPageWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceEnrollmentStatusPageWindows10]::new()
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
