using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationPolicyAndroidWorkProfile : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the device general configuration policy for Android WorkProfile.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the device general configuration policy for Android WorkProfile')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block face unlock.')]
    [System.Nullable[System.Boolean]] $PasswordBlockFaceUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block fingerprint unlock')]
    [System.Nullable[System.Boolean]] $PasswordBlockFingerprintUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block iris unlock.')]
    [System.Nullable[System.Boolean]] $PasswordBlockIrisUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Smart Lock and other trust agents.')]
    [System.Nullable[System.Boolean]] $passwordBlockTrustAgents

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before the password expires')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Minimum length of passwords')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Minutes of inactivity before the screen times out')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Number of previous passwords to block')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Number of sign in failures allowed before factory reset')]
    [System.Nullable[System.UInt32]] $PasswordSignInFailureCountBeforeFactoryReset

    [DscProperty()]
    [System.ComponentModel.Description('Type of password that is required')]
    [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the required device password complexity on Android. One of: NONE, LOW, MEDIUM, HIGH.')]
    [ValidateSet('none', 'low', 'medium', 'high')]
    [System.String] $RequiredPasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to allow installation of apps from unknown sources.')]
    [System.Nullable[System.Boolean]] $WorkProfileAllowAppInstallsFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('Type of data sharing that is allowed')]
    [ValidateSet('deviceDefault', 'preventAny', 'allowPersonalToWork', 'noRestrictions')]
    [System.String] $WorkProfileDataSharingType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block notifications while device locked')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockNotificationsWhileDeviceLocked

    [DscProperty()]
    [System.ComponentModel.Description('Block users from adding/removing accounts in work profile')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockAddingAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Allow bluetooth devices to access enterprise contacts')]
    [System.Nullable[System.Boolean]] $WorkProfileBluetoothEnableContactSharing

    [DscProperty()]
    [System.ComponentModel.Description('Block screen capture in work profile')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockScreenCapture

    [DscProperty()]
    [System.ComponentModel.Description('Block display work profile caller ID in personal profile')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockCrossProfileCallerId

    [DscProperty()]
    [System.ComponentModel.Description('Block work profile camera')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockCamera

    [DscProperty()]
    [System.ComponentModel.Description('Block work profile contacts availability in personal profile')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockCrossProfileContactsSearch

    [DscProperty()]
    [System.ComponentModel.Description('Boolean that indicates if the setting disallow cross profile copy paste is enabled')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockCrossProfileCopyPaste

    [DscProperty()]
    [System.ComponentModel.Description('Type of password that is required')]
    [ValidateSet('deviceDefault', 'prompt', 'autoGrant', 'autoDeny')]
    [System.String] $WorkProfileDefaultAppPermissionPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block face unlock in work profile.')]
    [System.Nullable[System.Boolean]] $WorkProfilePasswordBlockFaceUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block fingerprint unlock in work profile')]
    [System.Nullable[System.Boolean]] $WorkProfilePasswordBlockFingerprintUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block iris unlock in work profile.')]
    [System.Nullable[System.Boolean]] $WorkProfilePasswordBlockIrisUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether or not to block Smart Lock and other trust agents for work profile')]
    [System.Nullable[System.Boolean]] $WorkProfilePasswordBlockTrustAgents

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before the work profile password expires')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Minimum length of work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of numeric characters required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinNumericCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of non-letter characters required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinNonLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of letter characters required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinLetterCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of lower-case characters required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinLowerCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of upper-case characters required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinUpperCaseCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minimum count of symbols required in work profile password')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinSymbolCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Minutes of inactivity before the screen times out')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Number of previous work profile passwords to block')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Number of sign in failures allowed before work profile is removed and all corporate data deleted')]
    [System.Nullable[System.UInt32]] $WorkProfilePasswordSignInFailureCountBeforeFactoryReset

    [DscProperty()]
    [System.ComponentModel.Description('Type of work profile password that is required')]
    [ValidateSet('deviceDefault', 'lowSecurityBiometric', 'required', 'atLeastNumeric', 'numericComplex', 'atLeastAlphabetic', 'atLeastAlphanumeric', 'alphanumericWithSymbols')]
    [System.String] $WorkProfilePasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the required device password complexity on Android. One of: NONE, LOW, MEDIUM, HIGH in work profile.')]
    [ValidateSet('none', 'low', 'medium', 'high')]
    [System.String] $WorkProfileRequiredPasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Password is required or not for work profile')]
    [System.Nullable[System.Boolean]] $WorkProfileRequirePassword

    [DscProperty()]
    [System.ComponentModel.Description('Prevent the use of a unified password for the device and the work profile.')]
    [System.Nullable[System.Boolean]] $BlockUnifiedPasswordForWorkProfile

    [DscProperty()]
    [System.ComponentModel.Description('Require the Android Verify apps feature is turned on')]
    [System.Nullable[System.Boolean]] $SecurityRequireVerifyApps

    [DscProperty()]
    [System.ComponentModel.Description('Package identifier for always-on VPN.')]
    [System.String] $VpnAlwaysOnPackageIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Enable lockdown mode for always-on VPN.')]
    [System.Nullable[System.Boolean]] $VpnEnableAlwaysOnLockdownMode

    [DscProperty()]
    [System.ComponentModel.Description('Allow widgets from work profile apps.')]
    [System.Nullable[System.Boolean]] $WorkProfileAllowWidgets

    [DscProperty()]
    [System.ComponentModel.Description('Prevent app installations from unknown sources in the personal profile.')]
    [System.Nullable[System.Boolean]] $WorkProfileBlockPersonalAppInstallsFromUnknownSources

    [DscProperty()]
    [System.ComponentModel.Description('Determine domains allow-list for accounts that can be added to work profile.')]
    [System.String[]] $AllowedGoogleAccountDomains

    [DscProperty()]
    [System.ComponentModel.Description('Control user''s ability to add accounts in work profile including Google accounts.')]
    [ValidateSet('allowAllExceptGoogleAccounts', 'blockAll', 'allowAll')]
    [System.String] $WorkProfileAccountUse

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site collection exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [IntuneDeviceConfigurationPolicyAndroidWorkProfile] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationPolicyAndroidWorkProfile]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy Android for Work Profile {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $policy = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.androidWorkProfileGeneralDeviceConfiguration')" `
                    -ErrorAction Stop

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No Intune Device Configuration Policy Android for Work Profile with {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }
            $resolvedId = $policy.Id

            Write-Verbose -Message "An Intune Device Configuration Policy Android for Work Profile with {$($this.DisplayName)} was found"
            $results = @{
                Description                                               = $policy.Description
                Id                                                        = $policy.Id
                DisplayName                                               = $policy.DisplayName
                RoleScopeTagIds                                           = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                PasswordBlockFaceUnlock                                   = $policy.passwordBlockFaceUnlock
                PasswordBlockFingerprintUnlock                            = $policy.passwordBlockFingerprintUnlock
                PasswordBlockIrisUnlock                                   = $policy.passwordBlockIrisUnlock
                PasswordBlockTrustAgents                                  = $policy.passwordBlockTrustAgents
                PasswordExpirationDays                                    = $policy.passwordExpirationDays
                PasswordMinimumLength                                     = $policy.passwordMinimumLength
                PasswordMinutesOfInactivityBeforeScreenTimeout            = $policy.passwordMinutesOfInactivityBeforeScreenTimeout
                PasswordPreviousPasswordBlockCount                        = $policy.passwordPreviousPasswordBlockCount
                PasswordSignInFailureCountBeforeFactoryReset              = $policy.passwordSignInFailureCountBeforeFactoryReset
                PasswordRequiredType                                      = $policy.passwordRequiredType
                RequiredPasswordComplexity                                = $policy.requiredPasswordComplexity
                WorkProfileAllowAppInstallsFromUnknownSources             = $policy.workProfileAllowAppInstallsFromUnknownSources
                WorkProfileDataSharingType                                = $policy.workProfileDataSharingType
                WorkProfileBlockNotificationsWhileDeviceLocked            = $policy.workProfileBlockNotificationsWhileDeviceLocked
                WorkProfileBlockAddingAccounts                            = $policy.workProfileBlockAddingAccounts
                WorkProfileBluetoothEnableContactSharing                  = $policy.workProfileBluetoothEnableContactSharing
                WorkProfileBlockScreenCapture                             = $policy.workProfileBlockScreenCapture
                WorkProfileBlockCrossProfileCallerId                      = $policy.workProfileBlockCrossProfileCallerId
                WorkProfileBlockCamera                                    = $policy.workProfileBlockCamera
                WorkProfileBlockCrossProfileContactsSearch                = $policy.workProfileBlockCrossProfileContactsSearch
                WorkProfileBlockCrossProfileCopyPaste                     = $policy.workProfileBlockCrossProfileCopyPaste
                WorkProfileDefaultAppPermissionPolicy                     = $policy.workProfileDefaultAppPermissionPolicy
                WorkProfilePasswordBlockFaceUnlock                        = $policy.workProfilePasswordBlockFaceUnlock
                WorkProfilePasswordBlockFingerprintUnlock                 = $policy.workProfilePasswordBlockFingerprintUnlock
                WorkProfilePasswordBlockIrisUnlock                        = $policy.workProfilePasswordBlockIrisUnlock
                WorkProfilePasswordBlockTrustAgents                       = $policy.workProfilePasswordBlockTrustAgents
                WorkProfilePasswordExpirationDays                         = $policy.workProfilePasswordExpirationDays
                WorkProfilePasswordMinimumLength                          = $policy.workProfilePasswordMinimumLength
                WorkProfilePasswordMinNumericCharacters                   = $policy.workProfilePasswordMinNumericCharacters
                WorkProfilePasswordMinNonLetterCharacters                 = $policy.workProfilePasswordMinNonLetterCharacters
                WorkProfilePasswordMinLetterCharacters                    = $policy.workProfilePasswordMinLetterCharacters
                WorkProfilePasswordMinLowerCaseCharacters                 = $policy.workProfilePasswordMinLowerCaseCharacters
                WorkProfilePasswordMinUpperCaseCharacters                 = $policy.workProfilePasswordMinUpperCaseCharacters
                WorkProfilePasswordMinSymbolCharacters                    = $policy.workProfilePasswordMinSymbolCharacters
                WorkProfilePasswordMinutesOfInactivityBeforeScreenTimeout = $policy.workProfilePasswordMinutesOfInactivityBeforeScreenTimeout
                WorkProfilePasswordPreviousPasswordBlockCount             = $policy.workProfilePasswordPreviousPasswordBlockCount
                WorkProfilePasswordSignInFailureCountBeforeFactoryReset   = $policy.workProfilePasswordSignInFailureCountBeforeFactoryReset
                WorkProfilePasswordRequiredType                           = $policy.workProfilePasswordRequiredType
                WorkProfileRequiredPasswordComplexity                     = $policy.workProfileRequiredPasswordComplexity
                WorkProfileRequirePassword                                = $policy.workProfileRequirePassword
                BlockUnifiedPasswordForWorkProfile                        = $policy.blockUnifiedPasswordForWorkProfile
                SecurityRequireVerifyApps                                 = $policy.securityRequireVerifyApps
                VpnAlwaysOnPackageIdentifier                              = $policy.vpnAlwaysOnPackageIdentifier
                VpnEnableAlwaysOnLockdownMode                             = $policy.vpnEnableAlwaysOnLockdownMode
                WorkProfileAllowWidgets                                   = $policy.workProfileAllowWidgets
                WorkProfileBlockPersonalAppInstallsFromUnknownSources     = $policy.workProfileBlockPersonalAppInstallsFromUnknownSources
                AllowedGoogleAccountDomains                               = $policy.allowedGoogleAccountDomains
                WorkProfileAccountUse                                     = $policy.workProfileAccountUse
                Ensure                                                    = 'Present'
                Credential                                                = $this.Credential
                ApplicationId                                             = $this.ApplicationId
                TenantId                                                  = $this.TenantId
                ApplicationSecret                                         = $this.ApplicationSecret
                CertificateThumbprint                                     = $this.CertificateThumbprint
                CertificatePath                                           = $this.CertificatePath
                CertificatePassword                                       = $this.CertificatePassword
                ManagedIdentity                                           = $this.ManagedIdentity
                AccessTokens                                              = $this.AccessTokens
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $policy.Id
            }
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

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Device Configuration Policy {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Device Configuration Policy {$($this.DisplayName)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.androidWorkProfileGeneralDeviceConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentPolicy.Id

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Device Configuration Policy {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentPolicy.Id
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
            [array]$policies = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.androidWorkProfileGeneralDeviceConfiguration' `
                -Filter $this.Filter
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.DisplayName)" -DeferWrite
                $params = @{
                    DisplayName           = $policy.DisplayName
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

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
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

    hidden [IntuneDeviceConfigurationPolicyAndroidWorkProfile] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationPolicyAndroidWorkProfile])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationPolicyAndroidWorkProfile]::new()
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
