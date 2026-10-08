using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneUserSettingsPolicyWindows365 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether the user''s Cloud PC enables cross-region disaster recovery and specifies the network for the disaster recovery.')]
    [MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting] $CrossRegionDisasterRecoverySetting

    [DscProperty(Key)]
    [System.ComponentModel.Description('The setting name displayed in the user interface.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the local admin option is enabled. Default value is false. To enable the local admin option, change the setting to true. If the local admin option is enabled, the end user can be an admin of the Cloud PC device.')]
    [System.Nullable[System.Boolean]] $LocalAdminEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Defines the setting of the Cloud PC notification prompts for the Cloud PC user.')]
    [MSFT_MicrosoftGraphcloudPcNotificationSetting] $NotificationSetting

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the provisioning source of the Cloud PC prepared for an end user. The default value is image.')]
    [ValidateSet('image', 'snapshot')]
    [System.String] $ProvisioningSourceType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether an end user is allowed to reset their Cloud PC. When true, the user is allowed to reset their Cloud PC. When false, end-user initiated reset isn''t allowed. The default value is false.')]
    [System.Nullable[System.Boolean]] $ResetEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Defines how frequently a restore point is created (that is, a snapshot is taken) for users'' provisioned Cloud PCs (default is 12 hours), and whether the user is allowed to restore their own Cloud PCs to a backup made at a specific point in time.')]
    [MSFT_MicrosoftGraphcloudPcRestorePointSetting] $RestorePointSetting

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneUserSettingsPolicyWindows365] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneUserSettingsPolicyWindows365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune User Settings Policy for Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
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
                    $getValue = Get-MgBetaDeviceManagementVirtualEndpointUserSetting -CloudPcUserSettingId $this.Id -ExpandProperty 'assignments' -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune User Settings Policy for Windows365 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementVirtualEndpointUserSetting -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ExpandProperty 'assignments' `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune User Settings Policy for Windows365 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune User Settings Policy for Windows365 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexCrossRegionDisasterRecoverySetting = @{}
            $complexDisasterRecoveryNetworkSetting = @{}
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.onPremisesConnectionId)
            {
                $onPremisesConnectionDisplayName = (Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -CloudPcOnPremisesConnectionId $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.onPremisesConnectionId -ErrorAction SilentlyContinue).DisplayName
                $complexDisasterRecoveryNetworkSetting.Add('OnPremisesConnectionId', $onPremisesConnectionDisplayName)
            }
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.regionGroup)
            {
                $complexDisasterRecoveryNetworkSetting.Add('RegionGroup', $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.regionGroup)
            }
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.regionName)
            {
                $complexDisasterRecoveryNetworkSetting.Add('RegionName', $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.regionName)
            }
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.'@odata.type')
            {
                $complexDisasterRecoveryNetworkSetting.Add('odataType', $getValue.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.'@odata.type')
            }
            if ($complexDisasterRecoveryNetworkSetting.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDisasterRecoveryNetworkSetting = $null
            }
            $complexCrossRegionDisasterRecoverySetting.Add('DisasterRecoveryNetworkSetting', $complexDisasterRecoveryNetworkSetting)
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.disasterRecoveryType)
            {
                $complexCrossRegionDisasterRecoverySetting.Add('DisasterRecoveryType', $getValue.CrossRegionDisasterRecoverySetting.disasterRecoveryType)
            }
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.MaintainCrossRegionRestorePointEnabled)
            {
                $complexCrossRegionDisasterRecoverySetting.Add('MaintainCrossRegionRestorePointEnabled', $getValue.CrossRegionDisasterRecoverySetting.MaintainCrossRegionRestorePointEnabled)
            }
            if ($null -ne $getValue.CrossRegionDisasterRecoverySetting.userInitiatedDisasterRecoveryAllowed)
            {
                $complexCrossRegionDisasterRecoverySetting.Add('UserInitiatedDisasterRecoveryAllowed', $getValue.CrossRegionDisasterRecoverySetting.userInitiatedDisasterRecoveryAllowed)
            }
            if ($complexCrossRegionDisasterRecoverySetting.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexCrossRegionDisasterRecoverySetting = $null
            }

            $complexNotificationSetting = @{}
            $complexNotificationSetting.Add('RestartPromptsDisabled', $getValue.NotificationSetting.restartPromptsDisabled)
            if ($complexNotificationSetting.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexNotificationSetting = $null
            }

            $complexRestorePointSetting = @{}
            if ($null -ne $getValue.RestorePointSetting.frequencyType)
            {
                $complexRestorePointSetting.Add('FrequencyType', $getValue.RestorePointSetting.frequencyType)
            }
            $complexRestorePointSetting.Add('UserRestoreEnabled', $getValue.RestorePointSetting.userRestoreEnabled)
            if ($complexRestorePointSetting.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRestorePointSetting = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                CrossRegionDisasterRecoverySetting = $complexCrossRegionDisasterRecoverySetting
                DisplayName                        = $getValue.DisplayName
                LocalAdminEnabled                  = $getValue.LocalAdminEnabled
                NotificationSetting                = $complexNotificationSetting
                ProvisioningSourceType             = $getValue.ProvisioningSourceType
                ResetEnabled                       = $getValue.ResetEnabled
                RestorePointSetting                = $complexRestorePointSetting
                Id                                 = $getValue.Id
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                TenantId                           = $this.TenantId
                ApplicationSecret                  = $this.ApplicationSecret
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
                #endregion
            }
            $assignmentsValues = $getValue.Assignments
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

        Write-Verbose -Message "Setting configuration of the Intune User Settings Policy for Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $this.ValidateBoundParameters()

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if (-not [System.String]::IsNullOrEmpty($boundParameters.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.OnPremisesConnectionId))
        {
            $onPremisesConnection = Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -All -Filter "DisplayName eq '$($boundParameters.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.OnPremisesConnectionId -replace "'", "''")'" -ErrorAction SilentlyContinue
            if ($null -ne $onPremisesConnection)
            {
                $boundParameters.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.OnPremisesConnectionId = $onPremisesConnection.Id
            }
            else
            {
                throw "Could not find an On-Premises Connection with DisplayName {$($boundParameters.CrossRegionDisasterRecoverySetting.DisasterRecoveryNetworkSetting.OnPremisesConnectionId)}"
            }
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune User Settings Policy for Windows365 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            if ($createParameters.crossRegionDisasterRecoverySetting.disasterRecoveryType -eq 'crossRegion')
            {
                $createParameters.crossRegionDisasterRecoverySetting.Add('crossRegionDisasterRecoveryEnabled', $true)
            }

            if ($null -ne $createParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting -and $createParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting.ContainsKey('@odata.type'))
            {
                # The api does not like odataType to be present
                $createParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting.Remove('@odata.type') | Out-Null
            }
            #region resource generator code
            $policy = New-MgBetaDeviceManagementVirtualEndpointUserSetting -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/virtualEndpoint/userSettings'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune User Settings Policy for Windows365 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            if ($updateParameters.crossRegionDisasterRecoverySetting.disasterRecoveryType -eq 'crossRegion')
            {
                $updateParameters.crossRegionDisasterRecoverySetting.Add('crossRegionDisasterRecoveryEnabled', $true)
            }

            if ($null -ne $updateParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting -and $updateParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting.ContainsKey('@odata.type'))
            {
                # The api does not like odataType to be present
                $updateParameters.crossRegionDisasterRecoverySetting.disasterRecoveryNetworkSetting.Remove('@odata.type') | Out-Null
            }

            #region resource generator code
            Update-MgBetaDeviceManagementVirtualEndpointUserSetting `
                -CloudPcUserSettingId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/virtualEndpoint/userSettings'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune User Settings Policy for Windows365 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementVirtualEndpointUserSetting -CloudPcUserSettingId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        $this.ValidateBoundParameters()

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
            [array]$getValue = Get-MgBetaDeviceManagementVirtualEndpointUserSetting `
                -Filter $this.Filter `
                -ExpandProperty 'assignments' `
                -All `
                -NoPageSize `
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.CrossRegionDisasterRecoverySetting)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'CrossRegionDisasterRecoverySetting'
                            CimInstanceName = 'MicrosoftGraphCloudPcCrossRegionDisasterRecoverySetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'DisasterRecoveryNetworkSetting'
                            CimInstanceName = 'MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CrossRegionDisasterRecoverySetting `
                        -CIMInstanceName 'MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CrossRegionDisasterRecoverySetting = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CrossRegionDisasterRecoverySetting') | Out-Null
                    }
                }
                if ($null -ne $Results.NotificationSetting)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.NotificationSetting `
                        -CIMInstanceName 'MicrosoftGraphcloudPcNotificationSetting'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.NotificationSetting = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('NotificationSetting') | Out-Null
                    }
                }
                if ($null -ne $Results.RestorePointSetting)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RestorePointSetting `
                        -CIMInstanceName 'MicrosoftGraphcloudPcRestorePointSetting'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.RestorePointSetting = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RestorePointSetting') | Out-Null
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
                    -NoEscape @('Assignments', 'CrossRegionDisasterRecoverySetting', 'NotificationSetting', 'RestorePointSetting') `
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

    hidden [void] ValidateBoundParameters()
    {
        if ($null -ne $this.CrossRegionDisasterRecoverySetting -and
            $this.CrossRegionDisasterRecoverySetting.UserInitiatedDisasterRecoveryAllowed -and
            $this.CrossRegionDisasterRecoverySetting.DisasterRecoveryType -ne 'premium')
        {
            throw "The property UserInitiatedDisasterRecoveryAllowed can only be set to 'True' when DisasterRecoveryType is configured as 'premium'."
        }
    }

    hidden [IntuneUserSettingsPolicyWindows365] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneUserSettingsPolicyWindows365])
        {
            return $Values
        }

        $result = [IntuneUserSettingsPolicyWindows365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the network settings of the Cloud PC during a cross-region disaster recovery operation.')]
    [MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting] $DisasterRecoveryNetworkSetting

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of disaster recovery to perform when a disaster occurs on the user''s Cloud PC. The possible values are: notConfigured, crossRegion, premium, unknownFutureValue. The default value is notConfigured.')]
    [ValidateSet('notConfigured', 'crossRegion', 'premium', 'unknownFutureValue')]
    [System.String] $DisasterRecoveryType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether Windows 365 maintain the cross-region disaster recovery function generated restore points. If true, the Windows 365 stored restore points false indicates that Windows 365 doesn''t generate or keep the restore point from the original Cloud PC. If a disaster occurs, the new Cloud PC can only be provisioned using the initial image. This limitation can result in the loss of some user data on the original Cloud PC. The default value is false.')]
    [System.Nullable[System.Boolean]] $MaintainCrossRegionRestorePointEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the client allows the end user to initiate a disaster recovery activation. True indicates that the client includes the option for the end user to activate Backup Cloud PC. When false, the end user doesn''t have the option to activate disaster recovery. The default value is false. Currently, only premium disaster recovery is supported.')]
    [System.Nullable[System.Boolean]] $UserInitiatedDisasterRecoveryAllowed
}

class MSFT_MicrosoftGraphcloudPcNotificationSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('If true, doesn''t prompt the user to restart the Cloud PC. If false, prompts the user to restart Cloud PC. The default value is false.')]
    [System.Nullable[System.Boolean]] $RestartPromptsDisabled
}

class MSFT_MicrosoftGraphcloudPcRestorePointSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The time interval in hours to take snapshots (restore points) of a Cloud PC automatically. Possible values are: default, fourHours, sixHours, twelveHours, sixteenHours, twentyFourHours. The default value is default that indicates that the time interval for automatic capturing of restore point snapshots is set to 12 hours.')]
    [ValidateSet('default', 'fourHours', 'sixHours', 'twelveHours', 'sixteenHours', 'twentyFourHours')]
    [System.String] $FrequencyType

    [DscProperty()]
    [System.ComponentModel.Description('If true, the user has the ability to use snapshots to restore Cloud PCs. If false, non-admin users can''t use snapshots to restore the Cloud PC.')]
    [System.Nullable[System.Boolean]] $UserRestoreEnabled
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

class MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the display name of the virtual network that the new Cloud PC joins.  Only applicable for the ''#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting'' odata type.')]
    [System.String] $OnPremisesConnectionId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the logic geographic group this region belongs to. Multiple regions can belong to one region group. When a region group is configured for disaster recovery, the new Cloud PC is assigned to one of the regions within the group based on resource availability. For example, the europeUnion region group contains the North Europe and West Europe regions.  Only applicable for the ''#microsoft.graph.cloudPcDisasterRecoveryMicrosoftHostedNetworkSetting'' odata type. Possible values are: default, australia, canada, usCentral, usEast, usWest, france, germany, europeUnion, unitedKingdom, japan, asia, india, southAmerica, euap, usGovernment, usGovernmentDOD, unknownFutureValue, norway, switzerland, southKorea, middleEast, mexico, australasia, europe. Use the Prefer: include-unknown-enum-members request header to get the following values in this evolvable enum: norway, switzerland, southKorea, middleEast, mexico, australasia, europe.')]
    [ValidateSet('default', 'australia', 'canada', 'usCentral', 'usEast', 'usWest', 'france', 'germany', 'europeUnion', 'unitedKingdom', 'japan', 'asia', 'india', 'southAmerica', 'euap', 'usGovernment', 'usGovernmentDOD', 'unknownFutureValue', 'norway', 'switzerland', 'southKorea', 'middleEast', 'mexico', 'australasia', 'europe')]
    [System.String] $RegionGroup

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the Azure region that the new Cloud PC is assigned to. The Windows 365 service creates and manages the underlying virtual network. Only applicable for the ''#microsoft.graph.cloudPcDisasterRecoveryMicrosoftHostedNetworkSetting'' odata type.')]
    [System.String] $RegionName

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting', '#microsoft.graph.cloudPcDisasterRecoveryMicrosoftHostedNetworkSetting')]
    [System.String] $odataType
}
