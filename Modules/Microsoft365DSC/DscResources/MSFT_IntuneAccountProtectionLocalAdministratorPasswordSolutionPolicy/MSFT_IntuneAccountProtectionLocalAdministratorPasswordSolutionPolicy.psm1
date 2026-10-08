using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Identity of the account protection local administrator password solution policy.')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the account protection local administrator password solution policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the account protection local administrator password solution policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this policy.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the account protection local administrator password solution policy.')]
    [MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Configures which directory the local admin account password is backed up to. 0 - Disabled, 1 - Azure AD, 2 - AD')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.UInt32]] $BackupDirectory

    [DscProperty()]
    [System.ComponentModel.Description('Configures the maximum password age of the managed local administrator account for Azure AD. Minimum - 7, Maximum - 365')]
    [ValidateRange(7, 365)]
    [System.Nullable[System.UInt32]] $passwordagedays_aad

    [DscProperty()]
    [System.ComponentModel.Description('Configures the maximum password age of the managed local administrator account for Active Directory. Minimum - 1, Maximum - 365')]
    [ValidateRange(1, 365)]
    [System.Nullable[System.UInt32]] $PasswordAgeDays

    [DscProperty()]
    [System.ComponentModel.Description('Configures additional enforcement of maximum password age for the managed local administrator account.')]
    [System.Nullable[System.Boolean]] $PasswordExpirationProtectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configures how many previous encrypted passwords will be remembered in Active Directory. Minimum - 0, Maximum - 12')]
    [ValidateRange(0, 12)]
    [System.Nullable[System.UInt32]] $AdEncryptedPasswordHistorySize

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether the password is encrypted before being stored in Active Directory.')]
    [System.Nullable[System.Boolean]] $AdPasswordEncryptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configures the name or SID of a user or group that can decrypt the password stored in Active Directory.')]
    [System.String] $AdPasswordEncryptionPrincipal

    [DscProperty()]
    [System.ComponentModel.Description('Configures the name of the managed local administrator account.')]
    [System.String] $AdministratorAccountName

    [DscProperty()]
    [System.ComponentModel.Description('Configures the password complexity of the managed local administrator account. (1: Large letters, 2: Large letters + small letters, 3: Large letters + small letters + numbers, 4: Large letters + small letters + numbers + special characters, 5: Large letters + small letters + numbers + special characters (improved readability), 6: Passphrase (long words), 7: Passphrase (short words), 8: Passphrase (short words with unique prefixes))')]
    [ValidateSet('1', '2', '3', '4', '5', '6', '7', '8')]
    [ValidateRange(1, 8)]
    [System.Nullable[System.UInt32]] $PasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Passphrase Length (Minimum 3, Maximum 10 characters) - Depends on PasswordComplexity')]
    [ValidateRange(3, 10)]
    [System.Nullable[System.Int32]] $PassphraseLength

    [DscProperty()]
    [System.ComponentModel.Description('Configures the length of the password of the managed local administrator account. Minimum - 8, Maximum - 64')]
    [ValidateRange(8, 64)]
    [System.Nullable[System.UInt32]] $PasswordLength

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the actions to take upon expiration of the configured grace period. (1: Reset password, 3: Reset the password and logoff the managed account, 5: Reset the password and reboot, 11: Reset the password, logoff the managed account, and terminate any remaining processes.)')]
    [ValidateSet('1', '3', '5', '11')]
    [System.Nullable[System.UInt32]] $PostAuthenticationActions

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the amount of time (in hours) to wait after an authentication before executing the specified post-authentication actions. Minimum - 0, Maximum - 24')]
    [ValidateRange(0, 24)]
    [System.Nullable[System.UInt32]] $PostAuthenticationResetDelay

    [DscProperty()]
    [System.ComponentModel.Description('Automatic Account Management Enabled (false: The target account will not be automatically managed, true: The target account will be automatically managed)')]
    [ValidateSet('true', 'false')]
    [System.String] $AutomaticAccountManagementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Automatic Account Management Target - Depends on AutomaticAccountManagementEnabled (0: Manage the built-in administrator account, 1: Manage a new custom administrator account)')]
    [ValidateSet('0', '1')]
    [System.String] $AutomaticAccountManagementTarget

    [DscProperty()]
    [System.ComponentModel.Description('Automatic Account Management Randomize Name - Depends on AutomaticAccountManagementEnabled (false: The name of the target account will not use a random numeric suffix., true: The name of the target account will use a random numeric suffix.)')]
    [ValidateSet('true', 'false')]
    [System.String] $AutomaticAccountManagementRandomizeName

    [DscProperty()]
    [System.ComponentModel.Description('Automatic Account Management Name Or Prefix - Depends on AutomaticAccountManagementEnabled')]
    [System.String] $AutomaticAccountManagementNameOrPrefix

    [DscProperty()]
    [System.ComponentModel.Description('Automatic Account Management Enable Account - Depends on AutomaticAccountManagementEnabled (false: The target account will be disabled, true: The target account will be enabled)')]
    [ValidateSet('true', 'false')]
    [System.String] $AutomaticAccountManagementEnableAccount

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed')]
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

    [IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Account Protection LAPS Policy with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                #Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $templateReferenceId = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'

                # Retrieve policy general settings
                $policy = $null
                if (-not [System.String]::IsNullOrEmpty($this.Identity))
                {
                    $policy = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Identity -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $policy.settings
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No Account Protection LAPS Policy with Id {$($this.Identity)} was found"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/TemplateId eq '$templateReferenceId'" `
                            -ErrorAction SilentlyContinue

                        if ($policy.Length -gt 1)
                        {
                            throw "Duplicate Account Protection LAPS Policy named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
            }
            else
            {
                $policy = $this.ExportedInstance
                $settings = $policy.settings
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "No Account Protection LAPS Policy with Name {$($this.DisplayName)} was found"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $policy.Id
            Write-Verbose "Found Account Protection LAPS Policy with Id {$($resolvedId)} and Name {$($policy.Name)}"

            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -ErrorAction Stop
            }

            $returnHashtable = @{}
            $returnHashtable.Add('Identity', $resolvedId)
            $returnHashtable.Add('DisplayName', $policy.Name)
            $returnHashtable.Add('Description', $policy.Description)
            $returnHashtable.Add('RoleScopeTagIds', (Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds))

            $returnHashtable = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $returnHashtable

            if ($null -ne $returnHashtable.PasswordExpirationProtectionEnabled)
            {
                $returnHashtable.PasswordExpirationProtectionEnabled = [bool]::Parse($returnHashtable.PasswordExpirationProtectionEnabled)
            }

            if ($null -ne $returnHashtable.AdPasswordEncryptionEnabled)
            {
                $returnHashtable.AdPasswordEncryptionEnabled = [bool]::Parse($returnHashtable.AdPasswordEncryptionEnabled)
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $policy.Id
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -IncludeDeviceFilter $true -Assignments $assignmentsValues
            }
            $returnHashtable.Add('Assignments', $assignmentResult)

            $returnHashtable.Add('Ensure', 'Present')
            $returnHashtable.Add('Credential', $this.Credential)
            $returnHashtable.Add('ApplicationId', $this.ApplicationId)
            $returnHashtable.Add('TenantId', $this.TenantId)
            $returnHashtable.Add('ApplicationSecret', $this.ApplicationSecret)
            $returnHashtable.Add('CertificateThumbprint', $this.CertificateThumbprint)
            $returnHashtable.Add('ManagedIdentity', $this.ManagedIdentity)
            $returnHashtable.Add('AccessTokens', $this.AccessTokens)

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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        #Ensure the proper dependencies are installed in the current environment.
        #Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Account Protection LAPS Policy {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Identity') | Out-Null

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

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Account Protection LAPS Policy {$($currentPolicy.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Identity') | Out-Null

            #format settings from PSBoundParameters for update
            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region update policy assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Account Protection LAPS Policy {$($currentPolicy.DisplayName)}"
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentPolicy.Identity
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1

        try
        {
            $policyTemplateID = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$policies = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter

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

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite

                $params = @{
                    Identity              = $policy.Id
                    DisplayName           = $policy.Name
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
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments
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
                    $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*' -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune." -CommitWrite
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy])
        {
            return $Values
        }

        $result = [IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
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
