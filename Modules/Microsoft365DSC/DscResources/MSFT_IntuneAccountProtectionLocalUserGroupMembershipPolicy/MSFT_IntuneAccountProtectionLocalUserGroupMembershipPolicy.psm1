using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAccountProtectionLocalUserGroupMembershipPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Identity of the account protection policy.')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the account protection rules policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the account protection rules policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the Intune Policy.')]
    [MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Local User Group Collections of the Intune Policy.')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup[]] $AccessGroup

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

    [IntuneAccountProtectionLocalUserGroupMembershipPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAccountProtectionLocalUserGroupMembershipPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Account Protection Local User Group Membership Policy with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                #Retrieve policy general settings
                $policy = $null
                if (-not [String]::IsNullOrEmpty($this.Identity))
                {
                    $policy = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Identity -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $policy.settings
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No Account Protection Local User Group Membership Policy with identity {$($this.Identity)} was found"
                    if (-not [String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if (([array]$policy).Count -gt 1)
                        {
                            throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                        }

                        if ($null -eq $policy)
                        {
                            Write-Verbose -Message "No Account Protection Local User Group Membership Policy with displayName {$($this.DisplayName)} was found"
                            return $this.AsResult($nullResult)
                        }
                    }
                }
            }
            else
            {
                $policy = $this.ExportedInstance
                $settings = $policy.settings
            }

            # Retrieve policy specific settings
            $resolvedId = $policy.Id

            $returnHashtable = @{}
            $returnHashtable.Add('Identity', $policy.Id)
            $returnHashtable.Add('DisplayName', $policy.Name)
            $returnHashtable.Add('Description', $policy.Description)
            $returnHashtable.Add('RoleScopeTagIds', (Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds))

            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -ErrorAction Stop
            }
            $returnHashtable = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $returnHashtable

            foreach ($group in $returnHashtable.AccessGroup)
            {
                for ($i = 0; $i -lt $group.desc.Count; $i++)
                {
                    $member = $group.desc[$i]
                    switch ($member)
                    {
                        'S-1-5-32-544'
                        {
                            $member = 'administrators'
                        }
                        'S-1-5-32-545'
                        {
                            $member = 'users'
                        }
                        'S-1-5-32-546'
                        {
                            $member = 'guests'
                        }
                        'S-1-5-32-547'
                        {
                            $member = 'powerusers'
                        }
                        'S-1-5-32-555'
                        {
                            $member = 'remotedesktopusers'
                        }
                        'S-1-5-32-580'
                        {
                            $member = 'RemoteManagementUsers'
                        }
                    }
                    $group.desc[$i] = $member
                }
            }

            Write-Verbose -Message "Found Account Protection Local User Group Membership Policy {$($this.DisplayName)}"

            $returnHashtable.Add('Ensure', 'Present')
            $returnHashtable.Add('Credential', $this.Credential)
            $returnHashtable.Add('ApplicationId', $this.ApplicationId)
            $returnHashtable.Add('TenantId', $this.TenantId)
            $returnHashtable.Add('ApplicationSecret', $this.ApplicationSecret)
            $returnHashtable.Add('CertificateThumbprint', $this.CertificateThumbprint)
            $returnHashtable.Add('ManagedIdentity', $this.ManagedIdentity)
            $returnHashtable.Add('AccessTokens', $this.AccessTokens)

            $returnAssignments = @()
            $graphAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $graphAssignments)
            {
                $graphAssignments = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $policy.Id
            }
            if ($graphAssignments.Count -gt 0)
            {
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Account Protection Local User Group Membership Policy with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '22968f54-45fa-486c-848e-f8224aa69772_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        foreach ($group in $boundParameters.AccessGroup)
        {
            for ($i = 0; $i -lt $group.desc.Count; $i++)
            {
                $member = $group.desc[$i]
                switch ($member)
                {
                    'administrators'
                    {
                        $member = 'S-1-5-32-544'
                    }
                    'users'
                    {
                        $member = 'S-1-5-32-545'
                    }
                    'guests'
                    {
                        $member = 'S-1-5-32-546'
                    }
                    'powerusers'
                    {
                        $member = 'S-1-5-32-547'
                    }
                    'remotedesktopusers'
                    {
                        $member = 'S-1-5-32-555'
                    }
                    'RemoteManagementUsers'
                    {
                        $member = 'S-1-5-32-580'
                    }
                }
                $group.desc[$i] = $member
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Account Protection Local User Group Membership Policy {$($this.DisplayName)}"
            $boundParameters.Remove('Identity') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('DisplayName') | Out-Null
            $boundParameters.Remove('Description') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            $createParameters = @{}
            $createParameters.Add('name', $this.DisplayName)
            $createParameters.Add('description', $this.Description)
            $createParameters.Add('settings', @($settings))
            $createParameters.Add('platforms', $platforms)
            $createParameters.Add('technologies', $technologies)
            $createParameters.Add('templateReference', @{
                templateId = $templateReferenceId
            })
            $createParameters.Add('roleScopeTagIds', $resolvedRoleScopeTagIds)
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $policy.Id `
                -Targets $assignmentsHash
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Account Protection Local User Group Membership Policy {$($this.DisplayName)}"

            $boundParameters.Remove('Identity') | Out-Null
            $boundParameters.Remove('DisplayName') | Out-Null
            $boundParameters.Remove('Description') | Out-Null
            $boundParameters.Remove('Assignments') | Out-Null

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

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Targets $assignmentsHash
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Account Protection Local User Group Membership Policy {$($this.DisplayName)}"
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
            # Local user group membership template, family endpointSecurityAccountProtection
            $policyTemplateID = '22968f54-45fa-486c-848e-f8224aa69772_1'
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
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.AccessGroup)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.AccessGroup) -CIMInstanceName MicrosoftGraphIntuneSettingsCatalogAccessGroup

                    if ($complexTypeStringResult)
                    {
                        $Results.AccessGroup = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AccessGroup') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Assignments) -CIMInstanceName IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments

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
                    -NoEscape @('AccessGroup', 'Assignments') `
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

    hidden [IntuneAccountProtectionLocalUserGroupMembershipPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAccountProtectionLocalUserGroupMembershipPolicy])
        {
            return $Values
        }

        $result = [IntuneAccountProtectionLocalUserGroupMembershipPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments
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

class MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup
{
    [DscProperty()]
    [System.ComponentModel.Description('The action to use for adding / removing members. Possible values: Add (AddUpdate), Remove (RemoveUpdate), Replace (AddRestrict). Add and Remove do not update unspecified members, whereas Replace will replace all members with the ones specified.')]
    [ValidateSet('AddUpdate', 'RemoveUpdate', 'AddRestrict')]
    [System.String] $action

    [DscProperty()]
    [System.ComponentModel.Description('The local groups to add / remove the members to / from. List of the following values: `administrators`, `users`, `guests`, `powerusers`, `remotedesktopusers`, `remotemanagementusers`')]
    [ValidateSet('administrators', 'users', 'guests', 'powerusers', 'remotedesktopusers', 'remotemanagementusers')]
    [System.String[]] $desc

    [DscProperty()]
    [System.ComponentModel.Description('The members to add / remove to / from the group. For AzureAD Users, use the format `AzureAD\\<UserPrincipalName>`. For groups, use the security identifier (SID).')]
    [System.String[]] $member

    [DscProperty()]
    [System.ComponentModel.Description('The type of the selection. Either users / groups from AzureAD, or by manual identifier.')]
    [ValidateSet('users', 'manual')]
    [System.String] $userselectiontype
}
