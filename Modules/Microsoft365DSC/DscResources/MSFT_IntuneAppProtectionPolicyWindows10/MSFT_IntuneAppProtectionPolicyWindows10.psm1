using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAppProtectionPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the sources from which data is allowed to be transferred. Some possible values are allApps or none. Possible values are: allApps, none.')]
    [ValidateSet('allApps', 'none', 'selectedApps')]
    [System.String] $AllowedInboundDataTransferSources

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the level to which the clipboard may be shared across org & non-org resources. Some possible values are anyDestinationAnySource or none. Possible values are: anyDestinationAnySource, none, orgDestinationAnySource, orgDestinationOrgSource, unknownFutureValue.')]
    [ValidateSet('anyDestinationAnySource', 'none')]
    [System.String] $AllowedOutboundClipboardSharingLevel

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the destinations to which data is allowed to be transferred. Some possible values are allApps or none. Possible values are: allApps, none.')]
    [ValidateSet('allApps', 'none', 'selectedApps')]
    [System.String] $AllowedOutboundDataTransferDestinations

    [DscProperty()]
    [System.ComponentModel.Description('If set, it will specify what action to take in the case where the user is unable to checkin because their authentication token is invalid. This happens when the user is deleted or disabled in AAD. Some possible values are block or wipe. If this property is not set, no action will be taken. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $AppActionIfUnableToAuthenticateUser

    [DscProperty()]
    [System.ComponentModel.Description('Maximum allowed device threat level, as reported by the Mobile Threat Defense app. Possible values are: notConfigured, secured, low, medium, high.')]
    [ValidateSet('notConfigured', 'secured', 'low', 'medium', 'high')]
    [System.String] $MaximumAllowedDeviceThreatLevel

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will block the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MaximumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will result in warning message on the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MaximumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions bigger than the specified version will wipe the managed app and the associated company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MaximumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumRequiredAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumRequiredOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will block the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumRequiredSdkVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumWarningAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will result in warning message on the managed app from accessing company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumWarningOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will wipe the managed app and the associated company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumWipeAppVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will wipe the managed app and the associated company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumWipeOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('Versions less than the specified version will wipe the managed app and the associated company data. For example: ''8.1.0'' or ''13.1.1''.')]
    [System.String] $MinimumWipeSdkVersion

    [DscProperty()]
    [System.ComponentModel.Description('Determines what action to take if the mobile threat defense threat threshold isn''t met. Some possible values are block or wipe. Warn isn''t a supported value for this property. Possible values are: block, wipe, warn, blockWhenSettingIsSupported.')]
    [ValidateSet('block', 'wipe', 'warn', 'blockWhenSettingIsSupported')]
    [System.String] $MobileThreatDefenseRemediationAction

    [DscProperty()]
    [System.ComponentModel.Description('The period after which access is checked when the device is not connected to the internet. For example, PT5M indicates that the interval is 5 minutes in duration. A timespan value of PT0S indicates that access will be blocked immediately when the device is not connected to the internet.')]
    [System.String] $PeriodOfflineBeforeAccessCheck

    [DscProperty()]
    [System.ComponentModel.Description('The amount of time an app is allowed to remain disconnected from the internet before all managed data it is wiped. For example, P5D indicates that the interval is 5 days in duration. A timespan value of PT0S indicates that managed data will never be wiped when the device is not connected to the internet.')]
    [System.String] $PeriodOfflineBeforeWipeIsEnforced

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that printing is blocked from managed apps. When FALSE, indicates that printing is allowed from managed apps. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $PrintBlocked

    [DscProperty()]
    [System.ComponentModel.Description('The policy''s description.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy display name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of IDs representing the Windows apps controlled by this protection policy.')]
    [System.String[]] $Apps

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

    [IntuneAppProtectionPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAppProtectionPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune App Protection Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceAppManagementWindowsManagedAppProtection -WindowsManagedAppProtectionId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune App Protection Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceAppManagementWindowsManagedAppProtection -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune App Protection Policy for Windows10 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune App Protection Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            $policyApps = Get-MgBetaDeviceAppManagementWindowsManagedAppProtectionApp -WindowsManagedAppProtectionId $resolvedId
            $appsArray = @()
            foreach ($app in $policyApps)
            {
                $appsArray += $app.MobileAppIdentifier.windowsAppId
            }

            $results = @{
                #region resource generator code
                AllowedInboundDataTransferSources       = $getValue.allowedInboundDataTransferSources
                AllowedOutboundClipboardSharingLevel    = $getValue.allowedOutboundClipboardSharingLevel
                AllowedOutboundDataTransferDestinations = $getValue.allowedOutboundDataTransferDestinations
                AppActionIfUnableToAuthenticateUser     = $getValue.appActionIfUnableToAuthenticateUser
                Apps                                    = $appsArray
                MaximumAllowedDeviceThreatLevel         = $getValue.maximumAllowedDeviceThreatLevel
                MaximumRequiredOsVersion                = $getValue.maximumRequiredOsVersion
                MaximumWarningOsVersion                 = $getValue.maximumWarningOsVersion
                MaximumWipeOsVersion                    = $getValue.maximumWipeOsVersion
                MinimumRequiredAppVersion               = $getValue.minimumRequiredAppVersion
                MinimumRequiredOsVersion                = $getValue.minimumRequiredOsVersion
                MinimumRequiredSdkVersion               = $getValue.minimumRequiredSdkVersion
                MinimumWarningAppVersion                = $getValue.minimumWarningAppVersion
                MinimumWarningOsVersion                 = $getValue.minimumWarningOsVersion
                MinimumWipeAppVersion                   = $getValue.minimumWipeAppVersion
                MinimumWipeOsVersion                    = $getValue.minimumWipeOsVersion
                MinimumWipeSdkVersion                   = $getValue.minimumWipeSdkVersion
                MobileThreatDefenseRemediationAction    = $getValue.mobileThreatDefenseRemediationAction
                PeriodOfflineBeforeAccessCheck          = $getValue.periodOfflineBeforeAccessCheck
                PeriodOfflineBeforeWipeIsEnforced       = $getValue.periodOfflineBeforeWipeIsEnforced
                PrintBlocked                            = $getValue.printBlocked
                Description                             = $getValue.Description
                DisplayName                             = $getValue.DisplayName
                RoleScopeTagIds                         = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                                      = $getValue.Id
                Ensure                                  = 'Present'
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                ApplicationSecret                       = $this.ApplicationSecret
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                #endregion
            }
            $assignmentsValues = Get-MgBetaDeviceAppManagementWindowsManagedAppProtectionAssignment -WindowsManagedAppProtectionId $resolvedId -All
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

        Write-Verbose -Message "Setting configuration of the Intune App Protection Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($boundParameters.ContainsKey('Apps'))
        {
            $targetApps = @()
            foreach ($app in $boundParameters.Apps)
            {
                $targetApps += @{
                    mobileAppIdentifier = @{
                        '@odata.type' = '#microsoft.graph.windowsAppIdentifier'
                        windowsAppId   = $app
                    }
                }
            }
            $boundParameters.Remove('Apps') | Out-Null
            $boundParameters.Add('apps', $targetApps)
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune App Protection Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove("Assignments") | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windowsManagedAppProtection')
            $policy = New-MgBetaDeviceAppManagementWindowsManagedAppProtection -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceAppManagement/windowsManagedAppProtections'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune App Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove("Assignments") | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            if ($updateParameters.ContainsKey('apps'))
            {
                $targetAppsBody = @{
                    appGroupType = 'selectedPublicApps'
                    apps = $updateParameters.apps
                }
                $updateParameters.Remove('apps') | Out-Null
                Invoke-M365DSCGraphRequest -Method POST `
                    -Uri "beta/deviceAppManagement/windowsManagedAppProtections('$($currentInstance.Id)')/targetApps" `
                    -Body $($targetAppsBody | ConvertTo-Json -Depth 10)
            }
            Update-MgBetaDeviceAppManagementWindowsManagedAppProtection `
                -WindowsManagedAppProtectionId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceAppManagement/windowsManagedAppProtections'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune App Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceAppManagementWindowsManagedAppProtection -WindowsManagedAppProtectionId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaDeviceAppManagementWindowsManagedAppProtection `
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

    hidden [IntuneAppProtectionPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAppProtectionPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneAppProtectionPolicyWindows10]::new()
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
