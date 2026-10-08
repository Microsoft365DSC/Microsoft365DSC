using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppConfigurationPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Key of the entity. Read-Only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the app configuration policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the app configuration policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Custom settings for the app configuration policy.')]
    [MSFT_IntuneAppConfigurationPolicyCustomSetting[]] $CustomSettings

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

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $roleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The intended app management levels for this policy.')]
    [ValidateSet('unspecified', 'unmanaged', 'mdm', 'androidEnterprise', 'androidEnterpriseDedicatedDevicesWithAzureAdSharedMode', 'androidOpenSourceProjectUserAssociated', 'androidOpenSourceProjectUserless', 'unknownFutureValue')]
    [System.String] $targetedAppManagementLevels

    [DscProperty()]
    [System.ComponentModel.Description('Public Apps selection: group or individual.')]
    [ValidateSet('selectedPublicApps', 'allCoreMicrosoftApps', 'allMicrosoftApps', 'allApps')]
    [System.String] $appGroupType

    [DscProperty()]
    [System.ComponentModel.Description('List of apps to which the policy is deployed.')]
    [MSFT_managedMobileApp[]] $Apps

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneAppConfigurationPolicy] Get()
    {
        $complexMobileAppIdentifier = $null
        $complexAppsArray = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppConfigurationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune App Configuration Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = ([Hashtable]$this.GetBoundParameters()).Clone()
                $nullResult.Ensure = 'Absent'

                $configPolicy = $null
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $configPolicy = Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -All -Filter "Id eq '$($this.Id)'" -ExpandProperty 'Apps' `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $configPolicy)
                {
                    Write-Verbose -Message "Could not find an Intune App Configuration Policy with Id {$($this.Id)}, searching by DisplayName {$($this.DisplayName)}"

                    try
                    {
                        $configPolicy = Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ExpandProperty 'Apps' `
                            -ErrorAction Stop
                    }
                    catch
                    {
                        $configPolicy = $null
                    }

                    if ($null -eq $configPolicy)
                    {
                        Write-Verbose -Message "No App Configuration Policy with DisplayName {$($this.DisplayName)} was found"
                        return $this.AsResult($nullResult)
                    }
                    if (([array]$configPolicy).Count -gt 1)
                    {
                        throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                    }
                }
            }
            else
            {
                $configPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "Found App Configuration Policy with Id {$($configPolicy.Id)} and DisplayName {$($configPolicy.DisplayName)}"
            #get the full app details and replace what was retrieved using Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration
            if ($null -ne $configPolicy.Apps)
            {
                $AppConfiguration = Get-MgBetaDeviceAppManagementTargetedManagedAppConfigurationApp -TargetedManagedAppConfigurationId $configPolicy.Id
                $complexAppsArray = @()
                foreach ($currentValue in $AppConfiguration)
                {
                    if ($null -ne $currentValue)
                    {
                        if ($null -ne $currentValue.mobileAppIdentifier.bundleId)
                        {
                            $complexMobileAppIdentifier = @{
                                bundleID = $currentValue.mobileAppIdentifier.bundleId
                            }
                        }

                        if ($null -ne $currentValue.mobileAppIdentifier.packageId)
                        {
                            $complexMobileAppIdentifier = @{
                                packageId = $currentValue.mobileAppIdentifier.packageId
                            }
                        }

                        if ($null -ne $currentValue.mobileAppIdentifier.windowsAppId)
                        {
                            $complexMobileAppIdentifier = @{
                                windowsAppId = $currentValue.mobileAppIdentifier.windowsAppId
                            }
                        }
                        $complexAppsHash = [ordered]@{}
                        $complexAppsHash.Add('id', $currentValue.Id)
                        $complexAppsHash.Add('mobileAppIdentifier', $complexMobileAppIdentifier)
                        $complexAppsArray += $complexAppsHash
                    }
                }
            }

            $returnHashtable = @{
                Id                          = $configPolicy.Id
                DisplayName                 = $configPolicy.DisplayName
                Description                 = $configPolicy.Description
                CustomSettings              = $configPolicy.customSettings
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
                RoleScopeTagIds             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $configPolicy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                TargetedAppManagementLevels = [String]$configPolicy.TargetedAppManagementLevels
                AppGroupType                = [String]$configPolicy.AppGroupType
                Apps                        = $complexAppsArray
            }

            $returnAssignments = @()
            $graphAssignments = Get-MgBetaDeviceAppManagementTargetedManagedAppConfigurationAssignment -TargetedManagedAppConfigurationId $configPolicy.Id
            if ($graphAssignments.Count -gt 0)
            {
                [array]$graphAssignments = $graphAssignments | Where-Object -FilterScript { $_.source -eq 'direct' }
                $returnAssignments += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($graphAssignments)
            }
            $returnHashtable.Add('Assignments', $returnAssignments)

            return $this.AsResult($returnHashtable)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $mobileAppIdentifierHashtable = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Intune App Configuration Policy {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentconfigPolicy = $this.Get().ToHashtable()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($null -ne $resolvedRoleScopeTagIds)
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $resolvedRoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentconfigPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Intune App Configuration Policy {$($this.DisplayName)}"
            $creationParams = @{
                displayName     = $this.DisplayName
                description     = $this.Description
                roleScopeTagIds = $resolvedRoleScopeTagIds
            }
            if ($null -ne $this.CustomSettings)
            {
                [System.Object[]]$customSettingsValue = $this.ConvertToCustomSettings($this.CustomSettings)
                $creationParams.Add('customSettings', $customSettingsValue)
            }

            if ($null -ne $this.Apps)
            {
                $appsArray = @()
                foreach ($app in $this.Apps)
                {
                    if ($null -ne $app.mobileAppIdentifier.bundleID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                            'bundleId'    = $app.mobileAppIdentifier.bundleId
                        }
                    }

                    if ($null -ne $app.mobileAppIdentifier.packageID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                            'packageId'   = $app.mobileAppIdentifier.packageId
                        }
                    }

                    if ($null -ne $app.mobileAppIdentifier.windowsAppID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type'  = '#microsoft.graph.windowsAppIdentifier'
                            'windowsAppId' = $app.mobileAppIdentifier.windowsAppId
                        }
                    }

                    $appHashtable = @{
                        'id'                  = $App.Id
                        'mobileAppIdentifier' = $mobileAppIdentifierHashtable
                    }

                    $appsArray += $appHashtable

                }
                $creationParams.Add('apps', $appsArray)
            }

            $policy = New-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -BodyParameter $creationParams

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/targetedManagedAppConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentconfigPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Intune App Configuration Policy {$($this.DisplayName)}"

            $updateParams = @{
                displayName     = $this.DisplayName
                description     = $this.Description
                roleScopeTagIds = $resolvedRoleScopeTagIds
            }
            if ($null -ne $this.CustomSettings)
            {
                $customSettingsValue = $this.ConvertToCustomSettings($this.CustomSettings)
                $updateParams.Add('customSettings', $customSettingsValue)
            }

            if ($null -ne $this.Apps)
            {
                $appsArray = @()
                foreach ($app in $this.Apps)
                {
                    if ($null -ne $app.mobileAppIdentifier.bundleID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type' = '#microsoft.graph.iosMobileAppIdentifier'
                            bundleId      = $app.mobileAppIdentifier.bundleID
                        }
                    }

                    if ($null -ne $app.mobileAppIdentifier.packageID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type' = '#microsoft.graph.androidMobileAppIdentifier'
                            packageId     = $app.mobileAppIdentifier.packageId
                        }
                    }

                    if ($null -ne $app.mobileAppIdentifier.windowsAppID)
                    {
                        $mobileAppIdentifierHashtable = @{
                            '@odata.type' = '#microsoft.graph.windowsAppIdentifier'
                            windowsAppId  = $app.mobileAppIdentifier.windowsAppId
                        }
                    }

                    $appsArray += @{
                        'mobileAppIdentifier' = $mobileAppIdentifierHashtable
                    }
                }

                $appsBody = @{
                    appGroupType = $this.AppGroupType
                    apps         = $appsArray
                }
                #apps handled separately as not supported by Update-MgBetaDeviceAppManagementTargetedManagedAppConfiguration
                Write-Verbose -Message "Updating Apps for Intune App Configuration Policy {$($this.DisplayName)}"
                $Uri = "/beta/deviceAppManagement/targetedManagedAppConfigurations('$($currentconfigPolicy.Id)')/targetApps"
                Invoke-M365DSCGraphRequest -Method POST -Uri $Uri -Body $($appsBody | ConvertTo-Json -Depth 10)
            }

            Update-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -TargetedManagedAppConfigurationId $currentconfigPolicy.Id -BodyParameter $updateParams

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentconfigPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/targetedManagedAppConfigurations'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentconfigPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune App Configuration Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -TargetedManagedAppConfigurationId $currentconfigPolicy.Id
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
            $mergedFilter = $this.Filter
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
                $mergedFilter = Remove-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$configPolicies = Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -All -ExpandProperty 'Apps' -Filter $mergedFilter -ErrorAction Stop
            $configPolicies = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $configPolicies

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($configPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($configPolicy in $configPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($configPolicies.Count)] $($configPolicy.displayName)" -DeferWrite
                $params = @{
                    Id                    = $configPolicy.Id
                    DisplayName           = $configPolicy.displayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationID         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $configPolicy
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.CustomSettings.Count -gt 0)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'CustomSettings'
                            CimInstanceName = 'IntuneAppConfigurationPolicyCustomSetting'
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CustomSettings `
                        -CIMInstanceName IntuneAppConfigurationPolicyCustomSetting `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.CustomSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CustomSettings') | Out-Null
                    }
                }

                if ($Results.Apps)
                {
                    $complexTypeMapping = @(
                        @{
                            Name            = 'Apps'
                            CimInstanceName = 'managedMobileApp'
                        }
                        @{
                            Name            = 'mobileAppIdentifier'
                            CimInstanceName = 'AppIdentifier'
                            isRequired      = $true
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Apps `
                        -CIMInstanceName managedMobileApp `
                        -ComplexTypeMapping $complexTypeMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.Apps = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Apps') | Out-Null
                    }
                }

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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('CustomSettings', 'Assignments', 'Apps') `
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

    hidden [System.Object[]] ConvertToCustomSettings([MSFT_IntuneAppConfigurationPolicyCustomSetting[]] $Settings)
    {
        $result = @()
        foreach ($setting in $Settings)
        {
            $currentSetting = @{
                name  = $setting.name
                value = $setting.value
            }
            $result += $currentSetting
        }
        return $result
    }

    hidden [IntuneAppConfigurationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppConfigurationPolicy])
        {
            return $Values
        }

        $result = [IntuneAppConfigurationPolicy]::new()
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

class MSFT_IntuneAppConfigurationPolicyCustomSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Name of the custom setting.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('Value of the custom setting.')]
    [System.String] $value
}

class MSFT_managedMobileApp
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Key of the entity.')]
    [System.String] $id

    [DscProperty()]
    [System.ComponentModel.Description('The identifier for an app with it''s operating system type.')]
    [MSFT_AppIdentifier] $mobileAppIdentifier
}

class MSFT_AppIdentifier
{
    [DscProperty()]
    [System.ComponentModel.Description('AppId iOS.')]
    [System.String] $bundleID

    [DscProperty()]
    [System.ComponentModel.Description('AppId Android.')]
    [System.String] $packageID

    [DscProperty()]
    [System.ComponentModel.Description('AppId Windows.')]
    [System.String] $windowsAppId
}
