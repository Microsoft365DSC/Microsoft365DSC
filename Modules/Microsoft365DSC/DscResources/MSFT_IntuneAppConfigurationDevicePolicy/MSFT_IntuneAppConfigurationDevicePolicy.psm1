using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppConfigurationDevicePolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Setting to specify whether to allow ConnectedApps experience for this Android app.')]
    [System.Nullable[System.Boolean]] $ConnectedAppsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the state of the credential provider role for this Android app. Possible values are: notConfigured, allowed, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'allowed')]
    [System.String] $CredentialProviderRoleState

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise app configuration package id.')]
    [System.String] $PackageId

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise app configuration JSON payload.')]
    [System.String] $PayloadJson

    [DscProperty()]
    [System.ComponentModel.Description('List of Android app permissions and corresponding permission actions.')]
    [MSFT_MicrosoftGraphandroidPermissionAction[]] $PermissionActions

    [DscProperty()]
    [System.ComponentModel.Description('Android Enterprise profile applicability (AndroidWorkProfile, DeviceOwner, or default (applies to both)). Possible values are: default, androidWorkProfile, androidDeviceOwner.')]
    [ValidateSet('default', 'androidWorkProfile', 'androidDeviceOwner')]
    [System.String] $ProfileApplicability

    [DscProperty()]
    [System.ComponentModel.Description('Mdm iOS app configuration Base64 binary. Must not be an empty string if specified.')]
    [ValidateNotNullOrEmpty()]
    [System.String] $EncodedSettingXml

    [DscProperty()]
    [System.ComponentModel.Description('iOS app configuration setting items. Must not be an empty collection if specified.')]
    [ValidateNotNullOrEmpty()]
    [MSFT_MicrosoftGraphappConfigurationSettingItem[]] $Settings

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this App configuration entity.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The associated app.')]
    [System.String[]] $TargetedMobileApps

    [DscProperty(Key)]
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

    [IntuneAppConfigurationDevicePolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppConfigurationDevicePolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune App Configuration Device Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration -ManagedDeviceMobileAppConfigurationId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune App Configuration Device Policy with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune App Configuration Device Policy with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $policyId = $getValue.Id
            Write-Verbose -Message "An Intune App Configuration Device Policy with Id {$policyId} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexPermissionActions = @()
            foreach ($currentpermissionActions in $getValue.permissionActions)
            {
                $mypermissionActions = [ordered]@{}
                if ($null -ne $currentpermissionActions.action)
                {
                    $mypermissionActions.Add('Action', $currentpermissionActions.action)
                }
                $mypermissionActions.Add('Permission', $currentpermissionActions.permission)
                if ($mypermissionActions.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexPermissionActions += $mypermissionActions
                }
            }

            $complexSettings = @()
            foreach ($currentsettings in $getValue.settings)
            {
                $mysettings = [ordered]@{}
                $mysettings.Add('AppConfigKey', $currentsettings.appConfigKey)
                if ($null -ne $currentsettings.appConfigKeyType)
                {
                    $mysettings.Add('AppConfigKeyType', $currentsettings.appConfigKeyType)
                }
                $mysettings.Add('AppConfigKeyValue', $currentsettings.appConfigKeyValue)
                if ($mysettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexSettings += $mysettings
                }
            }
            #endregion

            $platform = 'android'
            if ($null -ne $getValue.encodedSettingXml -or $null -ne $getValue.settings)
            {
                $platform = 'ios'
            }

            $targetedApps = @()
            foreach ($targetedApp in $getValue.TargetedMobileApps)
            {
                $app = Get-MgBetaDeviceAppManagementMobileApp -MobileAppId $targetedApp -ErrorAction SilentlyContinue
                if ($null -eq $app)
                {
                    Write-Warning -Message "App [$targetedApp] was not found. Please make sure the targeted app exists."
                    continue
                }

                if ($platform -eq 'android')
                {
                    $targetedApps += $app.packageId
                }
                else
                {
                    $targetedApps += $app.bundleId
                }
            }

            $payloadJsonValue = $null
            if (-not [System.String]::IsNullOrEmpty($getValue.payloadJson))
            {
                $payloadJsonValue = $this.DecodeTextPayload($getValue.payloadJson)
            }

            $results = @{
                #region resource generator code
                ConnectedAppsEnabled        = $getValue.connectedAppsEnabled
                CredentialProviderRoleState = $getValue.credentialProviderRoleState
                PackageId                   = $getValue.packageId
                PayloadJson                 = $payloadJsonValue
                PermissionActions           = $complexPermissionActions
                ProfileApplicability        = $getValue.profileApplicability
                EncodedSettingXml           = $getValue.encodedSettingXml
                Settings                    = $complexSettings
                Description                 = $getValue.Description
                DisplayName                 = $getValue.DisplayName
                RoleScopeTagIds             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                TargetedMobileApps          = $targetedApps
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
                #endregion
            }
            if ($platform -ne 'iOS')
            {
                $results.Remove('EncodedSettingXml') | Out-Null
                $results.Remove('Settings') | Out-Null
            }
            $assignmentsValues = Get-MgBetaDeviceAppManagementMobileAppConfigurationAssignment -ManagedDeviceMobileAppConfigurationId $policyId

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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $platform = 'android'
        if ($boundParameters.ContainsKey('EncodedSettingXml') -or $boundParameters.ContainsKey('Settings'))
        {
            $platform = 'ios'
        }

        if (-not [System.String]::IsNullOrEmpty($boundParameters.PayloadJson))
        {
            $boundParameters.PayloadJson = $this.EncodeTextPayload($boundParameters.PayloadJson)
        }

        $mobileApps = Get-MgBetaDeviceAppManagementMobileApp -All
        $targetedApps = @()
        foreach ($targetedApp in $this.TargetedMobileApps)
        {
            $app = $mobileApps | Where-Object -FilterScript {
                ($platform -eq 'android' -and $_.packageId -eq $targetedApp -and $_.'@odata.type' -eq '#microsoft.graph.androidManagedStoreApp') -or `
                ($platform -eq 'ios' -and $_.bundleId -eq $targetedApp)
            }

            if ($null -eq $app)
            {
                throw "Could not find a mobile app with packageId or bundleId {$targetedApp}"
            }
            $targetedApps += $app.Id
        }
        $boundParameters.TargetedMobileApps = $targetedApps

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune App Configuration Device Policy with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null
            if ($platform -eq 'android')
            {
                $createParameters.Add('@odata.type', '#microsoft.graph.androidManagedStoreAppConfiguration')
                $createParameters.Add('appSupportsOemConfig', $false)
            }
            else
            {
                $createParameters.Add('@odata.type', '#microsoft.graph.iosMobileAppConfiguration')
            }

            #region resource generator code
            $policy = New-MgBetaDeviceAppManagementMobileAppConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.Id)
            {
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId "$($policy.Id)/microsoft.graph.managedDeviceMobileAppConfiguration" `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/mobileAppConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune App Configuration Device Policy with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            if ($platform -eq 'android')
            {
                $updateParameters.Add('@odata.type', '#microsoft.graph.androidManagedStoreAppConfiguration')
            }
            else
            {
                $updateParameters.Add('@odata.type', '#microsoft.graph.iosMobileAppConfiguration')
            }

            #region resource generator code
            Update-MgBetaDeviceAppManagementMobileAppConfiguration `
                -ManagedDeviceMobileAppConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId "$($currentInstance.Id)/microsoft.graph.managedDeviceMobileAppConfiguration" `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/mobileAppConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune App Configuration Device Policy with Id {$($currentInstance.Id)}"
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
            [array]$getValue = Get-MgBetaDeviceAppManagementMobileAppConfiguration `
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
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
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

                if ($null -ne $Results.PermissionActions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PermissionActions `
                        -CIMInstanceName 'MicrosoftGraphandroidPermissionAction'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PermissionActions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PermissionActions') | Out-Null
                    }
                }
                if ($null -ne $Results.Settings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Settings `
                        -CIMInstanceName 'MicrosoftGraphappConfigurationSettingItem'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Settings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Settings') | Out-Null
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
                    -NoEscape @('PermissionActions', 'Settings', 'Assignments') `
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

    hidden [IntuneAppConfigurationDevicePolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppConfigurationDevicePolicy])
        {
            return $Values
        }

        $result = [IntuneAppConfigurationDevicePolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphandroidPermissionAction
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of Android permission action. Possible values are: prompt, autoGrant, autoDeny.')]
    [ValidateSet('prompt', 'autoGrant', 'autoDeny')]
    [System.String] $Action

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Android permission string, defined in the official Android documentation.  Example ''android.permission.READ_CONTACTS''.')]
    [System.String] $Permission
}

class MSFT_MicrosoftGraphappConfigurationSettingItem
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('app configuration key.')]
    [System.String] $AppConfigKey

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('app configuration key type. Possible values are: stringType, integerType, realType, booleanType, tokenType.')]
    [ValidateSet('stringType', 'integerType', 'realType', 'booleanType', 'tokenType')]
    [System.String] $AppConfigKeyType

    [DscProperty()]
    [System.ComponentModel.Description('app configuration key value.')]
    [System.String] $AppConfigKeyValue
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
