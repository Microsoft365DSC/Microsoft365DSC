using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAndroidManagedStoreAppConfiguration : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration. Inherited from managedDeviceMobileAppConfiguration')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance. Inherited from managedDeviceMobileAppConfiguration')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('the associated app. Inherited from managedDeviceMobileAppConfiguration')]
    [System.String[]] $targetedMobileApps

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise app configuration package id.')]
    [System.String] $packageId

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise app configuration JSON payload.')]
    [System.String] $payloadJson

    [DscProperty()]
    [System.ComponentModel.Description('List of Android app permissions and corresponding permission actions.')]
    [MSFT_androidPermissionAction[]] $permissionActions

    [DscProperty()]
    [System.ComponentModel.Description('Whether or not this AppConfig is an OEMConfig policy. This property is read-only.')]
    [System.Nullable[System.Boolean]] $appSupportsOemConfig

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise profile applicability (AndroidWorkProfile, DeviceOwner, or default (applies to both)). Possible values are: default, androidWorkProfile, androidDeviceOwner.')]
    [ValidateSet('default', 'androidWorkProfile', 'androidDeviceOwner')]
    [System.String] $profileApplicability

    [DscProperty()]
    [System.ComponentModel.Description('Setting to specify whether to allow ConnectedApps experience for this app.')]
    [System.Nullable[System.Boolean]] $connectedAppsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the app is allowed to act as a credential provider. Possible values are: notConfigured, allowed.')]
    [ValidateSet('notConfigured', 'allowed')]
    [System.String] $credentialProviderRoleState

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

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

    [IntuneAndroidManagedStoreAppConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAndroidManagedStoreAppConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Android Managed Store App Configuration Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrWhiteSpace($this.Id))
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration -ManagedDeviceMobileAppConfigurationId $this.Id -ErrorAction SilentlyContinue
                }

                #region resource generator code
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.androidManagedStoreAppConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune Android Managed Store App Configuration Policy with id {$($this.Id)} and display name {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "An Intune Android Managed Store App Configuration Policy with id {$($this.Id)}"

            #need to convert dictionary object into a hashtable array so we can work with it
            $complexPermissionActions = @()
            foreach ($setting in $getValue.permissionActions)
            {
                $mySettings = [ordered]@{}
                $mySettings.Add('action', $setting['action'])
                $mySettings.Add('permission', $setting['permission'])

                if ($mySettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPermissionActions += $mySettings
                }
            }

            [System.String[]]$targetedMobileAppsValue = @()
            foreach ($appId in $getValue.TargetedMobileApps)
            {
                $appDetails = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $appId -ErrorAction SilentlyContinue
                if ($null -eq $appDetails)
                {
                    Write-Warning -Message "Could not retrieve details for Targeted Mobile App with id {$appId} targeted by this policy. Skipping it."
                }
                else
                {
                    $targetedMobileAppsValue += $appDetails.DisplayName
                }
            }

            $results = @{
                #region resource generator code
                Id                          = $getValue.Id
                Description                 = $getValue.Description
                DisplayName                 = $getValue.DisplayName
                RoleScopeTagIds             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues ([Array]$getValue.RoleScopeTagIds) -DesiredValues $this.RoleScopeTagIds
                targetedMobileApps          = $targetedMobileAppsValue
                packageId                   = $getValue.packageId
                payloadJson                 = $getValue.payloadJson
                appSupportsOemConfig        = $getValue.appSupportsOemConfig
                profileApplicability        = $getValue.profileApplicability
                connectedAppsEnabled        = $getValue.connectedAppsEnabled
                credentialProviderRoleState = $getValue.credentialProviderRoleState
                permissionActions           = $complexPermissionActions
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
            }

            $assignmentsValues = Get-MgBetaDeviceAppManagementMobileAppConfigurationAssignment -ManagedDeviceMobileAppConfigurationId $Results.Id
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
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

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('TargetedMobileApps'))
        {
            $newTargetedMobileApps = @()
            foreach ($app in $this.TargetedMobileApps)
            {
                $guid = [System.Guid]::Empty
                if ([System.Guid]::TryParse($app, [ref]$guid))
                {
                    $appId = (Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $app -ErrorAction SilentlyContinue).id
                    if ($null -eq $appId)
                    {
                        throw "Could not find an Android Managed Store App in Intune with the id {$app} that is being targeted by this policy. Please ensure the app exists."
                    }
                }
                else
                {
                    $appId = (Get-MgBetaDeviceAppManagementMobileApp -All -Filter "DisplayName eq '$($app -replace "'", "''")' and isof('microsoft.graph.androidManagedStoreApp')").id
                    if ($null -eq $appId)
                    {
                        throw "Could not find an Android Managed Store App in Intune with the display name {$app} that is being targeted by this policy. Please ensure the app exists."
                    }
                }
                $newTargetedMobileApps += $appId
            }
            $boundParameters.Remove('TargetedMobileApps') | Out-Null
            $boundParameters.Add('TargetedMobileApps', $newTargetedMobileApps)
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating the Intune Android Managed Store App Configuration Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.androidManagedStoreAppConfiguration')
            $policy = New-MgBetaDeviceAppManagementMobileAppConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/mobileAppConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Android Managed Store App Configuration Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidManagedStoreAppConfiguration')
            Update-MgBetaDeviceAppManagementMobileAppConfiguration -BodyParameter $updateParameters `
                -ManagedDeviceMobileAppConfigurationId $currentInstance.Id
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/mobileAppConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Android Managed Store App Configuration Policy {$($this.DisplayName)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementMobileAppConfiguration -ManagedDeviceMobileAppConfigurationId $currentInstance.Id
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
            $baseFilter = "isof('microsoft.graph.androidManagedStoreAppConfiguration')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array]$getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration -Filter $mergedFilter -All -ErrorAction Stop

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

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
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

                if ($null -ne $Results.permissionActions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.permissionActions `
                        -CIMInstanceName 'MSFT_androidPermissionAction'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.permissionActions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('permissionActions') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'permissionActions') `
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

    hidden [IntuneAndroidManagedStoreAppConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAndroidManagedStoreAppConfiguration])
        {
            return $Values
        }

        $result = [IntuneAndroidManagedStoreAppConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_androidPermissionAction
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Android permission string, defined in the official Android documentation. Example ''android.permission.READ_CONTACTS''.')]
    [System.String] $permission

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type of Android permission action. Possible values are: prompt, autoGrant, autoDeny.')]
    [ValidateSet('prompt', 'autoGrant', 'autoDeny')]
    [System.String] $action
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
