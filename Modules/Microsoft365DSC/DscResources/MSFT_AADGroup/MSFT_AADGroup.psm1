using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroup : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the Azure Active Directory Group')]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies a mail nickname for the group.')]
    [System.String] $MailNickname

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a description for the group.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an ID for the group.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('User Service Principal values for the group''s owners.')]
    [System.String[]] $Owners

    [DscProperty()]
    [System.ComponentModel.Description('User Service Principal values for the group''s members.')]
    [System.String[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('Displayname values for the groups member of the group.')]
    [System.String[]] $GroupAsMembers

    [DscProperty()]
    [System.ComponentModel.Description('DisplayName values for the groups that this group is a member of.')]
    [System.String[]] $MemberOf

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the current group is part of a selected Group Lifecycle Policy configuration. Only applicable for Microsoft 365 Groups.')]
    [System.Nullable[System.Boolean]] $GroupLifecyclePolicySelectedEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the type of the group. To create a security group, leave empty. To create a dynamic membership security group, specify DynamicMembership. To create a Microsoft 365 (aka Unified) group, specify Unified. To create a Microsoft 365 dynamic membership group, specify both Unified and DynamicMembership.')]
    [System.String[]] $GroupTypes

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the membership rule for a dynamic group.')]
    [System.String] $MembershipRule

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the rule processing state. The acceptable values for this parameter are: On. Process the group rule or Paused. Stop processing the group rule.')]
    [ValidateSet('On', 'Paused')]
    [System.String] $MembershipRuleProcessingState

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies whether the group is security enabled. For security groups, this value must be $True.')]
    [System.Nullable[System.Boolean]] $SecurityEnabled

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies whether this group is mail enabled. Currently, you cannot create mail enabled groups in Microsoft Graph, instead the EXODistributionGroup resource can be used.')]
    [System.Nullable[System.Boolean]] $MailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this group can be assigned a role. Only available when creating a group and can''t be modified after group is created.')]
    [System.Nullable[System.Boolean]] $IsAssignableToRole

    [DscProperty()]
    [System.ComponentModel.Description('DisplayName values for the roles that the group is assigned to.')]
    [System.String[]] $AssignedToRole

    [DscProperty()]
    [System.ComponentModel.Description('This parameter determines the visibility of the group''s content and members list.')]
    [ValidateSet('Public', 'Private', 'HiddenMembership')]
    [System.String] $Visibility

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a Microsoft 365 group''s color theme. Possible values are Teal, Purple, Green, Blue, Pink, Orange or Red. Returned by default.')]
    [ValidateSet('Teal', 'Purple', 'Green', 'Blue', 'Pink', 'Orange', 'Red')]
    [System.String] $Theme

    [DscProperty()]
    [System.ComponentModel.Description('List of Licenses assigned to the group.')]
    [MSFT_AADGroupLicense[]] $AssignedLicenses

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether or not a group is configured to write back group object properties to on-premises Active Directory. These properties are used when group writeback is configured in the Microsoft Entra Connect sync client.')]
    [MSFT_MicrosoftGraphGroupWritebackConfiguration] $WritebackConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD Group should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
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

    [AADGroup] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroup]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Group with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'
                $nullReturn.Owners = @()
                $nullReturn.Members = @()
                $nullReturn.GroupAsMembers = @()
                $nullReturn.MemberOf = @()
                $nullReturn.AssignedToRole = @()
                $nullReturn.AssignedLicenses = @()

                # Graph omits writebackConfiguration and assignedLicenses from the default group projection
                $selectProperties = @('id', 'displayName', 'description', 'mailNickname', 'mail', 'mailEnabled', 'securityEnabled', 'groupTypes', 'membershipRule', 'membershipRuleProcessingState', 'isAssignableToRole', 'visibility', 'theme', 'assignedLicenses', 'writebackConfiguration')

                if ($this.GetBoundParameters().ContainsKey('Id') -and -not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message 'GroupID was specified'
                    try
                    {
                        $Group = Get-MgBetaGroup -GroupId $this.Id -Property $selectProperties -ExpandProperty 'members' -ErrorAction Stop
                    }
                    catch
                    {
                        Write-Verbose -Message "Couldn't get group by ID, trying by name"
                        [array]$Group = Get-MgBetaGroup -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -Property $selectProperties -ExpandProperty 'members' -ErrorAction Stop
                        if ($Group.Count -gt 1)
                        {
                            throw "Duplicate AzureAD Groups named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                else
                {
                    Write-Verbose -Message 'Id was NOT specified'
                    ## Can retreive multiple AAD Groups since displayname is not unique
                    [array]$Group = Get-MgBetaGroup -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -Property $selectProperties -ExpandProperty 'members' -ErrorAction Stop
                    if ($Group.Count -gt 1)
                    {
                        throw "Duplicate AzureAD Groups named $($this.DisplayName) exist in tenant"
                    }
                }

                if ($null -eq $Group)
                {
                    Write-Verbose -Message 'Group was null, returning null'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $Group = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found existing AzureAD Group'
            $prefetched = $null
            $navigationCache = $this.ResourceCache['NavigationCache']
            if ($null -ne $navigationCache -and $navigationCache.ContainsKey($Group.Id))
            {
                $prefetched = $navigationCache[$Group.Id]
            }

            $batchResponse = @()
            if ($null -eq $prefetched)
            {
                $batchRequests = @(
                    @{
                        id     = 'Owners'
                        method = 'GET'
                        url    = "/groups/$($Group.Id)/owners"
                    }
                    @{
                        id     = 'MemberOf'
                        method = 'GET'
                        url    = "/groups/$($Group.Id)/memberOf"
                    }
                    @{
                        id     = 'GroupLifecyclePolicies'
                        method = 'GET'
                        url    = "/groups/$($Group.Id)/groupLifecyclePolicies"
                    }
                )
                $batchResponse = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }

            # Owners
            [Array]$ownersResponse = if ($null -ne $prefetched) { $prefetched.Owners } else { ($batchResponse | Where-Object -FilterScript { $_.id -eq 'Owners' }).body.value }
            $OwnersValues = @()
            foreach ($owner in $ownersResponse)
            {
                if ($null -ne $owner.userPrincipalName)
                {
                    $OwnersValues += $owner.userPrincipalName
                }
                elseif ($owner.'@odata.type' -eq '#microsoft.graph.servicePrincipal')
                {
                    $OwnersValues += $owner.displayName
                }
            }

            $MembersValues = $null
            $result = @{}
            $MembersValues = [System.Collections.Generic.List[System.String]]::new()
            $GroupAsMembersValues = [System.Collections.Generic.List[System.String]]::new()

            # If the Members and GroupAsMembers parameters are not specified, do not attempt to retrieve them as part of the Get() method.
            if ($Group.MembershipRuleProcessingState -ne 'On' -and ($this.GetBoundParameters().ContainsKey('Members') -or $this.GetBoundParameters().ContainsKey('GroupAsMembers')))
            {
                # Members
                $groupMembers = $Group.Members
                if ((($this.Members.Count -gt 0 -or $this.GroupAsMembers.Count -gt 0) -and $Group.Members.Count -eq 20) -or `
                    $this.ResourceCache['requireGroupMemberFetching'] -eq $true)
                {
                    # Fetch all group members
                    $groupMembers = Get-MgBetaGroupMember -GroupId $Group.Id -All -Top 999
                }
                foreach ($member in $groupMembers)
                {
                    switch ($member.'@odata.type')
                    {
                        '#microsoft.graph.user'
                        {
                            $MembersValues.Add($member.userPrincipalName)
                        }
                        '#microsoft.graph.servicePrincipal'
                        {
                            $MembersValues.Add($member.displayName)
                        }
                        '#microsoft.graph.device'
                        {
                            $MembersValues.Add($member.displayName)
                        }
                        '#microsoft.graph.group'
                        {
                            $GroupAsMembersValues.Add($member.displayName)
                        }
                    }
                }
            }

            # MemberOf
            [Array]$memberOfResponse = if ($null -ne $prefetched) { $prefetched.MemberOf } else { ($batchResponse | Where-Object -FilterScript { $_.id -eq 'MemberOf' }).body.value }
            $MemberOfValues = @()
            # Note: only process security-groups that this group is a member of and not directory roles (if any)
            foreach ($member in ($memberOfResponse | Where-Object -FilterScript { $_.'@odata.type' -eq '#microsoft.graph.group' }))
            {
                if ($null -ne $member.displayName)
                {
                    $MemberOfValues += $member.displayName
                }
            }

            if ($null -eq $this.ResourceCache['DirectoryRoleDefinitions'])
            {
                $this.ResourceCache['DirectoryRoleDefinitions'] = [System.Collections.Generic.Dictionary[System.String, System.String]]::new()
                $allRoleDefinitions = Get-MgBetaRoleManagementDirectoryRoleDefinition -All
                foreach ($roleDefinition in $allRoleDefinitions)
                {
                    $this.ResourceCache['DirectoryRoleDefinitions'].Add($roleDefinition.Id, $roleDefinition.DisplayName)
                }
            }

            # AssignedToRole
            $AssignedToRoleValues = @()
            if ($Group.IsAssignableToRole -eq $true)
            {
                $roleAssignments = Get-MgBetaRoleManagementDirectoryRoleAssignment -Filter "PrincipalId eq '$($Group.Id)'"
                foreach ($assignment in $roleAssignments)
                {
                    $roleDisplayName = $null
                    if (-not $this.ResourceCache['DirectoryRoleDefinitions'].TryGetValue($assignment.RoleDefinitionId, [ref] $roleDisplayName))
                    {
                        $roleDisplayName = (Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $assignment.RoleDefinitionId).DisplayName
                    }
                    $AssignedToRoleValues += $roleDisplayName
                }
            }

            # Licenses
            $assignedLicensesValues = @()
            if ($Group.AssignedLicenses.Count -gt 0)
            {
                [Array]$assignedLicensesValues = $this.GetGroupLicenses($Group.AssignedLicenses)
            }

            $writebackConfigurationValue = $null
            if ($null -ne $Group.WritebackConfiguration -and `
                ($null -ne $Group.WritebackConfiguration.isEnabled -or `
                    -not [System.String]::IsNullOrEmpty($Group.WritebackConfiguration.onPremisesGroupType)))
            {
                $writebackConfigurationValue = @{
                    IsEnabled           = $Group.WritebackConfiguration.isEnabled
                    OnPremisesGroupType = $Group.WritebackConfiguration.onPremisesGroupType
                }
            }

            # GroupLifecyclePolicies
            $groupLifecyclePoliciesRequest = if ($null -ne $prefetched) { $prefetched.GroupLifecyclePolicies } else { ($batchResponse | Where-Object -FilterScript { $_.id -eq 'GroupLifecyclePolicies' }).body.value }
            $isGroupLifecyclePoliciesEnabled = $null -ne $groupLifecyclePoliciesRequest -and `
                $groupLifecyclePoliciesRequest.managedGroupTypes -eq 'selected'

            $policySettings = @{
                DisplayName                   = $Group.DisplayName
                Id                            = $Group.Id
                Owners                        = $OwnersValues
                MemberOf                      = $MemberOfValues
                Description                   = $Group.Description
                GroupTypes                    = Get-M365DSCArrayFromProperty -PropertyValue $Group.GroupTypes -ElementType ([System.String])
                MembershipRule                = $Group.MembershipRule
                MembershipRuleProcessingState = $Group.MembershipRuleProcessingState
                GroupAsMembers                = $GroupAsMembersValues
                Members                       = $MembersValues
                SecurityEnabled               = $Group.SecurityEnabled
                MailEnabled                   = $Group.MailEnabled
                IsAssignableToRole            = $false -or $Group.IsAssignableToRole
                AssignedToRole                = $AssignedToRoleValues
                MailNickname                  = $Group.MailNickname
                Visibility                    = $Group.Visibility
                Theme                         = $Group.Theme
                AssignedLicenses              = $assignedLicensesValues
                WritebackConfiguration        = $writebackConfigurationValue
                Ensure                        = 'Present'
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                CertificateThumbprint         = $this.CertificateThumbprint
                ApplicationSecret             = $this.ApplicationSecret
                Credential                    = $this.Credential
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
            }

            $result += $policySettings
            if ($result.MailEnabled)
            {
                $result.Add('GroupLifecyclePolicySelectedEnabled', $isGroupLifecyclePoliciesEnabled)
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message 'Setting configuration of Azure AD Groups'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $currentGroup = $this.Get().ToHashtable()
        $backCurrentOwners = $currentGroup.Owners
        $backCurrentMembers = $currentGroup.Members
        $backCurrentGroupAsMembers = $currentGroup.GroupAsMembers
        $backCurrentMemberOf = $currentGroup.MemberOf
        $backCurrentAssignedToRole = $currentGroup.AssignedToRole
        $currentParameters.Remove('Owners') | Out-Null
        $currentParameters.Remove('Members') | Out-Null
        $currentParameters.Remove('GroupAsMembers') | Out-Null
        $currentParameters.Remove('MemberOf') | Out-Null
        $currentParameters.Remove('AssignedToRole') | Out-Null
        $currentParameters.Remove('GroupLifecyclePolicySelectedEnabled') | Out-Null

        if ($null -ne $this.WritebackConfiguration)
        {
            $writebackConfigurationBody = @{}
            if ($null -ne $this.WritebackConfiguration.IsEnabled)
            {
                $writebackConfigurationBody.Add('isEnabled', $this.WritebackConfiguration.IsEnabled)
            }
            if (-not [System.String]::IsNullOrEmpty($this.WritebackConfiguration.OnPremisesGroupType))
            {
                $writebackConfigurationBody.Add('onPremisesGroupType', $this.WritebackConfiguration.OnPremisesGroupType)
            }
            $currentParameters.WritebackConfiguration = $writebackConfigurationBody
        }

        if ($this.Ensure -eq 'Present' -and `
            ($null -ne $this.GroupTypes -and $this.GroupTypes.Contains('Unified')) -and `
            ($null -ne $this.MailEnabled -and $this.MailEnabled -eq $false))
        {
            Write-Verbose -Message 'Cannot set mailenabled to false if GroupTypes is set to Unified when creating group.'
            throw 'Cannot set mailenabled to false if GroupTypes is set to Unified when creating a group.'
        }

        $currentValuesToCheck = @()
        if ($currentGroup.AssignedLicenses.Length -gt 0)
        {
            $currentValuesToCheck = $currentGroup.AssignedLicenses.SkuId
        }
        $desiredValuesToCheck = @()
        if ($this.AssignedLicenses.Length -gt 0)
        {
            $desiredValuesToCheck = $this.AssignedLicenses.SkuId
        }

        [Array]$licensesDiff = Compare-Object -ReferenceObject $currentValuesToCheck -DifferenceObject $desiredValuesToCheck -IncludeEqual
        $toAdd = @()
        $toRemove = @()
        foreach ($diff in $licensesDiff)
        {
            if ($diff.SideIndicator -eq '=>')
            {
                $toAdd += $diff.InputObject
            }
            elseif ($diff.SideIndicator -eq '<=')
            {
                $toRemove += $diff.InputObject
            }
            elseif ($diff.SideIndicator -eq '==')
            {
                # This will take care of the scenario where the license is already assigned but has different disabled plans
                $toAdd += $diff.InputObject
            }
        }

        # Convert AssignedLicenses from SkuPartNumber back to GUID
        $licensesToAdd = @()
        $licensesToRemove = @()
        [Array]$AllLicenses = $this.GetCombinedLicenses($currentGroup.AssignedLicenses, $this.AssignedLicenses)

        $allSkus = Get-MgBetaSubscribedSku
        # Create complete list of all Service Plans
        $allServicePlans = @()
        Write-Verbose -Message 'Getting all Service Plans'
        foreach ($sku in $allSkus)
        {
            foreach ($serviceplan in $sku.ServicePlans)
            {
                if ($allServicePlans.Length -eq 0 -or -not $allServicePlans.ServicePlanName.Contains($servicePlan.ServicePlanName))
                {
                    $allServicePlans += @{
                        ServicePlanId   = $serviceplan.ServicePlanId
                        ServicePlanName = $serviceplan.ServicePlanName
                    }
                }
            }
        }

        foreach ($assignedLicense in $AllLicenses)
        {
            $skuInfo = $allSkus | Where-Object -FilterScript { ($_.SkuPartNumber -replace [char]0xFEFF, '') -eq $assignedLicense.SkuId }
            if ($skuInfo)
            {
                if ($toAdd.Contains($assignedLicense.SkuId))
                {
                    $disabledPlansValues = @()
                    foreach ($plan in $assignedLicense.DisabledPlans)
                    {
                        $foundItem = $allServicePlans | Where-Object -FilterScript { $_.ServicePlanName -eq $plan }
                        $disabledPlansValues += $foundItem.ServicePlanId
                    }

                    $skuInfo = $allSkus | Where-Object -FilterScript { ($_.SkuPartNumber -replace [char]0xFEFF, '') -eq $assignedLicense.SkuId }
                    $licensesToAdd += @{
                        disabledPlans = $disabledPlansValues
                        skuId         = $skuInfo.SkuId
                    }
                }
                elseif ($toRemove.Contains($assignedLicense.SkuId))
                {
                    $licensesToRemove += $skuInfo.SkuId
                }
            }
            else
            {
                Write-Warning -Message "Specified Sku {$($assignedLicense.SkuId)} could not be found on the tenant."
            }
        }

        $currentParameters.Remove('AssignedLicenses') | Out-Null

        if ($this.Ensure -eq 'Present' -and $currentGroup.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Checking to see if an existing deleted group exists with DisplayName {$($this.DisplayName)}"
            $restoringExisting = $false
            [Array]$groups = Get-MgBetaDirectoryDeletedItemAsGroup -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
            if ($groups.Length -gt 1)
            {
                throw "Multiple deleted groups with the name {$($this.DisplayName)} were found. Cannot restore the existing group. Please ensure that you either have no instance of the group in the deleted list or that you have a single one."
            }

            if ($groups.Length -eq 1)
            {
                Write-Verbose -Message "Found an instance of a deleted group {$($this.DisplayName)}. Restoring it."
                Restore-MgBetaDirectoryDeletedItem -DirectoryObjectId $groups[0].Id
                $restoringExisting = $true
                $restoredGroupId = $groups[0].Id
                $null = Invoke-M365DSCCommand -ScriptBlock { Get-MgBetaGroup -GroupId $restoredGroupId -ErrorAction Stop } -RetryOnNotFoundError -MaxRetries 5
                $null = Invoke-M365DSCCommand -ScriptBlock { Get-MgBetaGroupMember -GroupId $restoredGroupId -ErrorAction Stop } -RetryOnNotFoundError -MaxRetries 5
                $commandParameters = ([Hashtable]$this.GetBoundParameters()).Clone()
                $commandParameters.Id = $restoredGroupId
                $currentGroup = Invoke-M365DSCCommand -ScriptBlock { $this.GetForExport($commandParameters) } -RetryOnNotFoundError
                $backCurrentOwners = $currentGroup.Owners
                $backCurrentMembers = $currentGroup.Members
            }

            if (-not $restoringExisting)
            {
                Write-Verbose -Message "Creating new group {$($this.DisplayName)}"
                $currentParameters.Remove('Id') | Out-Null

                $ownerReferences = [AADGroup]::GetDirectoryObjectReferences($this.Owners, $false)
                $memberReferences = @()
                if ($this.MembershipRuleProcessingState -ne 'On')
                {
                    $memberReferences = [AADGroup]::GetDirectoryObjectReferences($this.Members, $true)
                }

                if ($null -ne $ownerReferences -and $null -ne $memberReferences -and ($ownerReferences.Count + $memberReferences.Count) -le 20)
                {
                    if ($ownerReferences.Count -gt 0)
                    {
                        $currentParameters.Add('owners@odata.bind', $ownerReferences)
                        $backCurrentOwners = $this.Owners
                    }

                    if ($memberReferences.Count -gt 0)
                    {
                        $currentParameters.Add('members@odata.bind', $memberReferences)
                        $backCurrentMembers = $this.Members
                    }
                }

                try
                {
                    Write-Verbose -Message "Creating Group with Values: $(Convert-M365DscHashtableToString -Hashtable $currentParameters)"
                    $currentGroup = New-MgBetaGroup -BodyParameter $currentParameters
                    Write-Verbose -Message "Created Group $($currentGroup.id), wait for sync to complete"
                    Invoke-M365DSCCommand -ScriptBlock { Get-MgBetaGroup -GroupId $currentGroup.Id -Property Id -ErrorAction Stop } -RetryOnNotFoundError | Out-Null
                }
                catch
                {
                    Write-Verbose -Message $_
                    $this.LogError($_, "Couldn't create group $($this.DisplayName)")

                    throw
                }
            }
        }

        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Group {$($this.DisplayName)} exists and it should."
            try
            {
                if ($currentGroup.Ensure -eq 'Present')
                {
                    Write-Verbose -Message "Updating settings by ID for group {$($this.DisplayName)}"

                    if ($currentParameters.ContainsKey('IsAssignableToRole'))
                    {
                        Write-Verbose -Message 'Cannot set IsAssignableToRole once group is created.'
                        $currentParameters.Remove('IsAssignableToRole') | Out-Null
                    }

                    if ($currentParameters.ContainsKey('Id'))
                    {
                        $currentParameters.Remove('Id') | Out-Null
                    }

                    Write-Verbose -Message "Updating existing Group with Values: $(Convert-M365DscHashtableToString -Hashtable $currentParameters)"
                    Invoke-M365DSCCommand -ScriptBlock {
                        Update-MgBetaGroup -GroupId $currentGroup.Id -BodyParameter $currentParameters -ErrorAction Stop
                    } -RetryOnNotFoundError -MaxRetries 5 | Out-Null
                }

                if (($licensesToAdd.Length -gt 0 -or $licensesToRemove.Length -gt 0) -and $this.GetBoundParameters().ContainsKey('AssignedLicenses'))
                {
                    Write-Verbose -Message "Setting Group Licenses with:`r`nLicensesToAdd: $(ConvertTo-Json $licensesToAdd)`r`nLicensesToRemove: $(ConvertTo-Json $licensesToRemove)"
                    Invoke-M365DSCCommand -ScriptBlock {
                        Set-MgGroupLicense -GroupId $currentGroup.Id `
                            -AddLicenses $licensesToAdd `
                            -RemoveLicenses $licensesToRemove `
                            -ErrorAction Stop
                    } -RetryOnNotFoundError -MaxRetries 5 | Out-Null
                }
            }
            catch
            {
                $this.LogError($_, "Couldn't set group $($this.DisplayName)")

                throw
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentGroup.Ensure -eq 'Present')
        {
            try
            {
                Remove-MgBetaGroup -GroupId $currentGroup.Id | Out-Null
            }
            catch
            {
                $this.LogError($_, "Couldn't delete group $($this.DisplayName)")

                throw
            }
        }

        if ($this.Ensure -ne 'Absent')
        {
            #Owners
            Write-Verbose -Message 'Updating Owners'
            if ($this.GetBoundParameters().ContainsKey('Owners'))
            {
                $desiredOwnersValue = @()
                if ($this.Owners.Length -gt 0)
                {
                    $desiredOwnersValue = $this.Owners
                }
                if ($null -eq $backCurrentOwners)
                {
                    $backCurrentOwners = @()
                }
                $ownersDiff = Compare-Object -ReferenceObject $backCurrentOwners -DifferenceObject $desiredOwnersValue
                foreach ($diff in $ownersDiff)
                {
                    $directoryObject = [AADGroup]::GetDirectoryObject($diff.InputObject, $false)
                    if ($diff.SideIndicator -eq '=>')
                    {
                        Write-Verbose -Message "Adding new owner {$($diff.InputObject)} to AAD Group {$($currentGroup.DisplayName)}"
                        $ownerObject = @{
                            '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/{$($directoryObject.Id)}"
                        }
                        try
                        {
                            Invoke-M365DSCCommand -ScriptBlock {
                                New-MgGroupOwnerByRef -GroupId ($currentGroup.Id) -BodyParameter $ownerObject -ErrorAction Stop | Out-Null
                            } -RetryOnNotFoundError -MaxRetries 5
                        }
                        catch
                        {
                            if ($_.Exception.Message -notlike '*One or more added object references already exist for the following modified properties*')
                            {
                                throw $_
                            }
                        }
                    }
                    elseif ($diff.SideIndicator -eq '<=')
                    {
                        Write-Verbose -Message "Removing new owner {$($diff.InputObject)} to AAD Group {$($currentGroup.DisplayName)}"
                        Remove-MgGroupOwnerDirectoryObjectByRef -GroupId ($currentGroup.Id) -DirectoryObjectId ($directoryObject.Id) | Out-Null
                    }
                }

            }

            #Members
            Write-Verbose -Message 'Updating Members'
            if ($this.MembershipRuleProcessingState -ne 'On' -and $this.GetBoundParameters().ContainsKey('Members'))
            {
                $desiredMembersValue = @()
                if ($this.Members.Length -ne 0)
                {
                    $desiredMembersValue = $this.Members
                }
                if ($null -eq $backCurrentMembers)
                {
                    $backCurrentMembers = @()
                }
                Write-Verbose -Message 'Comparing current members and desired list'
                $membersDiff = Compare-Object -ReferenceObject $backCurrentMembers -DifferenceObject $desiredMembersValue
                foreach ($diff in $membersDiff)
                {
                    Write-Verbose -Message "Found difference for member {$($diff.InputObject)}"
                    $directoryObject = [AADGroup]::GetDirectoryObject($diff.InputObject, $true)

                    if ($diff.SideIndicator -eq '=>')
                    {
                        Write-Verbose -Message "Adding new member {$($diff.InputObject)} to AAD Group {$($currentGroup.DisplayName)}"
                        try
                        {
                            $memberObject = @{
                                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/{$($directoryObject.Id)}"
                            }
                            Invoke-M365DSCCommand -ScriptBlock {
                                New-MgBetaGroupMemberByRef -GroupId ($currentGroup.Id) -BodyParameter $memberObject -ErrorAction Stop
                            } -RetryOnNotFoundError -MaxRetries 5
                        }
                        catch
                        {
                            if ($_.Exception.Message -notlike '*One or more added object references already exist for the following modified properties*')
                            {
                                throw $_
                            }
                        }
                    }
                    elseif ($diff.SideIndicator -eq '<=')
                    {
                        Write-Verbose -Message "Removing new member {$($diff.InputObject)} from AAD Group {$($currentGroup.DisplayName)}"
                        Remove-MgBetaGroupMemberDirectoryObjectByRef -GroupId ($currentGroup.Id) -DirectoryObjectId ($directoryObject.Id) | Out-Null
                    }
                }
            }
            elseif ($this.MembershipRuleProcessingState -eq 'On')
            {
                Write-Verbose -Message 'Ignoring membership since this is a dynamic group.'
            }

            #GroupAsMembers
            Write-Verbose -Message 'Updating GroupAsMembers'
            if ($this.MembershipRuleProcessingState -ne 'On' -and $this.GetBoundParameters().ContainsKey('GroupAsMembers'))
            {
                $desiredGroupAsMembersValue = @()
                if ($this.GroupAsMembers.Length -ne 0)
                {
                    $desiredGroupAsMembersValue = $this.GroupAsMembers
                }
                if ($null -eq $backCurrentGroupAsMembers)
                {
                    $backCurrentGroupAsMembers = @()
                }
                $groupAsMembersDiff = Compare-Object -ReferenceObject $backCurrentGroupAsMembers -DifferenceObject $desiredGroupAsMembersValue
                foreach ($diff in $groupAsMembersDiff)
                {
                    try
                    {
                        $groupAsMember = Get-MgBetaGroup -Filter "DisplayName eq '$($diff.InputObject -replace "'", "''")'" -ErrorAction SilentlyContinue
                    }
                    catch
                    {
                        $groupAsMember = $null
                    }
                    if ($null -eq $groupAsMember)
                    {
                        throw "Group '$($diff.InputObject)' does not exist"
                    }
                    else
                    {
                        if ($diff.SideIndicator -eq '=>')
                        {
                            Write-Verbose -Message "Adding AAD group {$($groupAsMember.DisplayName)} as member of AAD group {$($currentGroup.DisplayName)}"
                            $groupAsMemberObject = @{
                                '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($groupAsMember.Id)"
                            }
                            Invoke-M365DSCCommand -ScriptBlock {
                                New-MgBetaGroupMemberByRef -GroupId ($currentGroup.Id) -Body $groupAsMemberObject -ErrorAction Stop
                            } -RetryOnNotFoundError -MaxRetries 5 | Out-Null
                        }
                        if ($diff.SideIndicator -eq '<=')
                        {
                            Write-Verbose -Message "Removing AAD Group {$($groupAsMember.DisplayName)} from AAD group {$($currentGroup.DisplayName)}"
                            Remove-MgBetaGroupMemberDirectoryObjectByRef -GroupId ($currentGroup.Id) -DirectoryObjectId ($groupAsMember.Id) | Out-Null
                        }
                    }
                }
            }

            #MemberOf
            Write-Verbose -Message 'Updating MemberOf'
            if ($this.GetBoundParameters().ContainsKey('MemberOf'))
            {
                $desiredMemberOfValue = @()
                if ($this.MemberOf.Length -ne 0)
                {
                    $desiredMemberOfValue = $this.MemberOf
                }
                if ($null -eq $backCurrentMemberOf)
                {
                    $backCurrentMemberOf = @()
                }
                $memberOfDiff = Compare-Object -ReferenceObject $backCurrentMemberOf -DifferenceObject $desiredMemberOfValue
                foreach ($diff in $memberOfDiff)
                {
                    try
                    {
                        $memberOfGroup = Get-MgBetaGroup -Filter "DisplayName eq '$($diff.InputObject -replace "'", "''")'" -ErrorAction Stop
                    }
                    catch
                    {
                        $memberOfGroup = $null
                    }
                    if ($null -eq $memberOfGroup)
                    {
                        throw "Security-group or directory role '$($diff.InputObject)' does not exist"
                    }
                    else
                    {
                        if ($diff.SideIndicator -eq '=>')
                        {
                            # see if memberOfGroup contains property SecurityEnabled (it can be true or false)
                            if ($memberOfGroup.SecurityEnabled)
                            {
                                Write-Verbose -Message "Adding AAD group {$($currentGroup.DisplayName)} as member of AAD group {$($memberOfGroup.DisplayName)}"
                                $memberOfObject = @{
                                    '@odata.id' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($currentGroup.Id)"
                                }
                                Invoke-M365DSCCommand -ScriptBlock {
                                    New-MgBetaGroupMemberByRef -GroupId ($memberOfGroup.Id) -BodyParameter $memberOfObject -ErrorAction Stop
                                } -RetryOnNotFoundError -MaxRetries 5 | Out-Null
                            }
                            else
                            {
                                throw "Cannot add AAD group {$($currentGroup.DisplayName)} to {$($memberOfGroup.DisplayName)} as it is not a security-group"
                            }
                        }
                        elseif ($diff.SideIndicator -eq '<=')
                        {
                            if ($memberOfGroup.SecurityEnabled)
                            {
                                Write-Verbose -Message "Removing AAD Group {$($currentGroup.DisplayName)} from AAD group {$($memberOfGroup.DisplayName)}"
                                Remove-MgBetaGroupMemberDirectoryObjectByRef -GroupId ($memberOfGroup.Id) -DirectoryObjectId ($currentGroup.Id) | Out-Null
                            }
                            else
                            {
                                throw "Cannot remove AAD group {$($currentGroup.DisplayName)} from {$($memberOfGroup.DisplayName)} as it is not a security-group"
                            }
                        }
                    }
                }
            }

            if ($currentGroup.IsAssignableToRole -eq $true -and $this.GetBoundParameters().ContainsKey('AssignedToRole'))
            {
                $desiredAssignedToRoleValue = @()
                if ($this.AssignedToRole.Length -ne 0)
                {
                    $desiredAssignedToRoleValue = $this.AssignedToRole
                }
                if ($null -eq $backCurrentAssignedToRole)
                {
                    $backCurrentAssignedToRole = @()
                }
                $assignedToRoleDiff = Compare-Object -ReferenceObject $backCurrentAssignedToRole -DifferenceObject $desiredAssignedToRoleValue
                foreach ($diff in $assignedToRoleDiff)
                {
                    try
                    {
                        $role = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($diff.InputObject -replace "'", "''")'"
                    }
                    catch
                    {
                        $role = $null
                    }
                    if ($null -eq $role)
                    {
                        throw "Directory Role '$($diff.InputObject)' does not exist"
                    }
                    else
                    {
                        if ($diff.SideIndicator -eq '=>')
                        {
                            Write-Verbose -Message "Assigning AAD group {$($currentGroup.DisplayName)} to Directory Role {$($diff.InputObject)}"
                            New-MgBetaRoleManagementDirectoryRoleAssignment -RoleDefinitionId $role.Id -PrincipalId $currentGroup.Id -DirectoryScopeId '/'
                        }
                        elseif ($diff.SideIndicator -eq '<=')
                        {
                            Write-Verbose -Message "Removing AAD group {$($currentGroup.DisplayName)} from Directory Role {$($role.DisplayName)}"
                            $roleAssignment = Get-MgBetaRoleManagementDirectoryRoleAssignment -Filter "PrincipalId eq '$($currentGroup.Id)' and RoleDefinitionId eq '$($role.Id)'"
                            Remove-MgBetaRoleManagementDirectoryRoleAssignment -UnifiedRoleAssignmentId $roleAssignment.Id
                        }
                    }
                }
            }

            # GroupLifecyclePolicies
            if ($this.GetBoundParameters().ContainsKey('GroupLifecyclePolicySelectedEnabled'))
            {
                if ($null -eq $this.ResourceCache['GroupLifecyclePolicy'])
                {
                    $this.ResourceCache['GroupLifecyclePolicy'] = Get-MgBetaGroupLifecyclePolicy
                }

                if ($this.ResourceCache['GroupLifecyclePolicy'].ManagedGroupTypes -ne 'selected')
                {
                    Write-Warning -Message "Cannot assign or remove group from lifecycle policy because the current mode is not 'Selected'."
                    return
                }

                if (-not $currentGroup.MailEnabled)
                {
                    Write-Warning -Message 'Cannot assign or remove group from lifecycle policy because it is not a Microsoft 365 Group.'
                    return
                }

                if ($this.GroupLifecyclePolicySelectedEnabled -and -not $currentGroup.GroupLifecyclePolicySelectedEnabled)
                {
                    Write-Verbose -Message "Enabling Group Lifecycle Policy for AAD group {$($currentGroup.DisplayName)}"
                    Add-MgBetaGroupToLifecyclePolicy -GroupLifecyclePolicyId $this.ResourceCache['GroupLifecyclePolicy'].Id -GroupId $currentGroup.Id
                }
                elseif (-not $this.GroupLifecyclePolicySelectedEnabled -and $currentGroup.GroupLifecyclePolicySelectedEnabled)
                {
                    Write-Verbose -Message "Removing AAD group {$($currentGroup.DisplayName)} from Group Lifecycle Policy"
                    Remove-MgBetaGroupFromLifecyclePolicy -GroupLifecyclePolicyId $this.ResourceCache['GroupLifecyclePolicy'].Id -GroupId $currentGroup.Id
                }
            }
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
            $ExportParameters = @{
                Filter         = $this.Filter
                All            = [switch]$true
                ExpandProperty = 'members'
                Property       = 'id', 'displayName', 'description', 'mailNickname', 'mail', 'mailEnabled', 'securityEnabled', 'groupTypes', 'membershipRule', 'membershipRuleProcessingState', 'isAssignableToRole', 'visibility', 'theme', 'assignedLicenses', 'writebackConfiguration'
                ErrorAction    = 'Stop'
                Sort           = 'DisplayName'
            }

            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                # Sort (OrderBy) and Expand cannot be used together
                $ExportParameters.Remove('Sort') | Out-Null
            }

            # Define the list of attributes
            $attributesToCheck = @(
                'description',
                'displayName',
                'hasMembersWithLicenseErrors',
                'mail',
                'mailNickname',
                'onPremisesSecurityIdentifier',
                'onPremisesSyncEnabled',
                'preferredLanguage'
            )

            # Initialize a flag to indicate whether any attribute matches the condition
            $matchConditionFound = $false

            # Check each attribute in the list
            foreach ($attribute in $attributesToCheck)
            {
                if ($this.Filter -like "*$attribute eq *")
                {
                    $matchConditionFound = $true
                    break
                }
            }

            # If any attribute matches, add parameters to $ExportParameters
            if ($matchConditionFound -or ($this.Filter -like '*endsWith*') -or ($this.Filter -like '*not*'))
            {
                $ExportParameters.Add('CountVariable', 'count')
                $ExportParameters.Add('ConsistencyLevel', 'eventual')
                $ExportParameters.Remove('ExpandProperty') | Out-Null
                $this.ResourceCache['requireGroupMemberFetching'] = $true
            }

            # Exclude Distribution Groups and mail enabled security groups from Exchange
            [array] $this.ResourceCache['exportedGroups'] = Get-MgBetaGroup @ExportParameters
            $this.ResourceCache['exportedGroups'] = $this.ResourceCache['exportedGroups'] | Where-Object -FilterScript {
                -not ($_.MailEnabled -and ($null -eq $_.GroupTypes -or $_.GroupTypes.Count -eq 0)) -and `
                    -not ($_.MailEnabled -and $_.SecurityEnabled -and ($null -eq $_.GroupTypes -or $_.GroupTypes.Count -eq 0))
            }

            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $this.ResourceCache['exportedGroups'] = $this.ResourceCache['exportedGroups'] | Sort-Object -Property DisplayName
            }

            $navigationCache = @{}
            $navigationRequests = @()
            foreach ($exportedGroup in $this.ResourceCache['exportedGroups'])
            {
                $navigationCache[$exportedGroup.Id] = @{
                    Owners                 = @()
                    MemberOf               = @()
                    GroupLifecyclePolicies = @()
                }
                $navigationRequests += @{
                    id     = "$($exportedGroup.Id)|Owners"
                    method = 'GET'
                    url    = "/groups/$($exportedGroup.Id)/owners"
                }
                $navigationRequests += @{
                    id     = "$($exportedGroup.Id)|MemberOf"
                    method = 'GET'
                    url    = "/groups/$($exportedGroup.Id)/memberOf"
                }
                $navigationRequests += @{
                    id     = "$($exportedGroup.Id)|GroupLifecyclePolicies"
                    method = 'GET'
                    url    = "/groups/$($exportedGroup.Id)/groupLifecyclePolicies"
                }
            }
            if ($navigationRequests.Count -gt 0)
            {
                $navigationResponses = Invoke-M365DSCGraphBatchRequest -Requests $navigationRequests
                foreach ($navigationResponse in $navigationResponses)
                {
                    if ($navigationResponse.status -ne 200 -or $null -eq $navigationResponse.body)
                    {
                        continue
                    }

                    $separatorIndex = ([System.String]$navigationResponse.id).LastIndexOf('|')
                    if ($separatorIndex -lt 0)
                    {
                        continue
                    }

                    $groupId = ([System.String]$navigationResponse.id).Substring(0, $separatorIndex)
                    $navigationName = ([System.String]$navigationResponse.id).Substring($separatorIndex + 1)
                    if ($navigationCache.ContainsKey($groupId))
                    {
                        $navigationCache[$groupId][$navigationName] = @($navigationResponse.body.value)
                    }
                }
            }
            $this.ResourceCache['NavigationCache'] = $navigationCache

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($group in $this.ResourceCache['exportedGroups'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedGroups'].Count)] $($group.DisplayName)" -DeferWrite
                $Params = @{
                    ApplicationSecret     = $this.ApplicationSecret
                    DisplayName           = $group.DisplayName
                    MailNickName          = $group.MailNickName
                    Members               = @('toextract')
                    SecurityEnabled       = $true
                    MailEnabled           = $true
                    Id                    = $group.Id
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $group
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.AssignedLicenses)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AssignedLicenses'
                            CimInstanceName = 'AADGroupLicense'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AssignedLicenses `
                        -CIMInstanceName 'AADGroupLicense' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AssignedLicenses = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AssignedLicenses') | Out-Null
                    }
                }

                if ($null -ne $Results.WritebackConfiguration)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'WritebackConfiguration'
                            CimInstanceName = 'MicrosoftGraphGroupWritebackConfiguration'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.WritebackConfiguration `
                        -CIMInstanceName 'MicrosoftGraphGroupWritebackConfiguration' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.WritebackConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WritebackConfiguration') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AssignedLicenses', 'WritebackConfiguration') `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ContainsKey('GroupLifecyclePolicySelectedEnabled') -and -not $CurrentValues.MailEnabled)
                {
                    Write-Verbose -Message "Removing 'GroupLifecyclePolicySelectedEnabled' from comparison because group is not a Microsoft 365 Group."
                    $ValuesToCheck.Remove('GroupLifecyclePolicySelectedEnabled') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden static [System.Object] GetDirectoryObject([System.String] $Identity, [System.Boolean] $IncludeDevices)
    {
        $directoryObject = Get-MgUser -UserId $Identity -ErrorAction SilentlyContinue
        if ($null -eq $directoryObject)
        {
            Write-Verbose -Message "Trying to retrieve Service Principal {$Identity}"
            [array]$app = Get-MgApplication -Filter "DisplayName eq '$($Identity -replace "'", "''")'"
            if ($app.Count -gt 0)
            {
                $directoryObject = Get-MgServicePrincipal -Filter "AppId eq '$($app.AppId)'"
            }
            else
            {
                [array]$spInstances = Get-MgServicePrincipal -Filter "DisplayName eq '$($Identity -replace "'", "''")'"
                if ($spInstances.Count -gt 1)
                {
                    throw "Duplicate Service Principals named '$Identity' exist in tenant"
                }
                elseif ($spInstances.Count -eq 1)
                {
                    $directoryObject = $spInstances
                }
            }
        }

        if ($null -eq $directoryObject -and $IncludeDevices)
        {
            Write-Verbose -Message "Trying to retrieve Device {$Identity}"
            $directoryObject = Get-MgDevice -Filter "DisplayName eq '$($Identity -replace "'", "''")'"
        }

        return $directoryObject
    }

    hidden static [System.String[]] GetDirectoryObjectReferences([System.String[]] $Identities, [System.Boolean] $IncludeDevices)
    {
        $directoryObjectsUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + 'v1.0/directoryObjects/'
        $references = @()
        foreach ($identity in $Identities)
        {
            $directoryObject = [AADGroup]::GetDirectoryObject($identity, $IncludeDevices)
            if (@($directoryObject.Id).Count -ne 1 -or [System.String]::IsNullOrEmpty($directoryObject.Id))
            {
                return $null
            }

            $references += $directoryObjectsUrl + $directoryObject.Id
        }

        return $references
    }

    hidden [System.Collections.Hashtable[]] GetGroupLicenses([System.Object] $AssignedLicenses)
    {
        $returnValue = @()
        if ($null -eq $this.ResourceCache['SubscribedSkus'])
        {
            $this.ResourceCache['SubscribedSkus'] = Get-MgBetaSubscribedSku
        }

        # Create complete list of all Service Plans
        $allServicePlans = @()
        Write-Verbose -Message 'Getting all Service Plans'
        foreach ($sku in $this.ResourceCache['SubscribedSkus'])
        {
            foreach ($serviceplan in $sku.ServicePlans)
            {
                if ($allServicePlans.Length -eq 0 -or -not $allServicePlans.ServicePlanName.Contains($servicePlan.ServicePlanName))
                {
                    $allServicePlans += @{
                        ServicePlanId   = $serviceplan.ServicePlanId
                        ServicePlanName = $serviceplan.ServicePlanName
                    }
                }
            }
        }

        foreach ($assignedLicense in $AssignedLicenses)
        {
            $skuPartNumber = $this.ResourceCache['SubscribedSkus'] | Where-Object -FilterScript { $_.SkuId -eq $assignedLicense.SkuId }
            $disabledPlansValues = @()
            foreach ($plan in $assignedLicense.DisabledPlans)
            {
                $foundItem = $allServicePlans | Where-Object -FilterScript { $_.ServicePlanId -eq $plan }
                $disabledPlansValues += $foundItem.ServicePlanName
            }
            $currentLicense = @{
                disabledPlans = $disabledPlansValues
                skuId         = $skuPartNumber.SkuPartNumber -replace [char]0xFEFF
            }
            $returnValue += $currentLicense
        }

        return $returnValue
    }

    hidden [System.Object[]] GetCombinedLicenses([System.Object[]] $CurrentLicenses, [System.Object[]] $DesiredLicenses)
    {
        $result = @()
        if ($currentLicenses.Length -gt 0)
        {
            foreach ($license in $CurrentLicenses)
            {
                Write-Verbose -Message "Including Current $license"
                $result += @{
                    skuId         = $license.SkuId
                    disabledPlans = $license.DisabledPlans
                }
            }
        }

        if ($DesiredLicenses.Length -gt 0)
        {
            foreach ($license in $DesiredLicenses)
            {
                $licenseSkuId = $license.SkuId
                if ($result.Length -eq 0)
                {
                    $result += @{
                        skuId         = $licenseSkuId
                        disabledPlans = $license.DisabledPlans
                    }
                }
                else
                {
                    if (-not $result.skuId.Contains($licenseSkuId))
                    {
                        $result += @{
                            skuId         = $licenseSkuId
                            disabledPlans = $license.DisabledPlans
                        }
                    }
                    else
                    {
                        # Set the Desired Disabled Plans if the sku is already added to the list
                        foreach ($item in $result)
                        {
                            if ($item.skuId -eq $licenseSkuId)
                            {
                                $item.disabledPlans = $license.disabledPlans
                            }
                        }
                    }
                }
            }
        }

        return $result
    }

    hidden [AADGroup] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroup])
        {
            return $Values
        }

        $result = [AADGroup]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADGroupLicense
{
    [DscProperty()]
    [System.ComponentModel.Description('A collection of the unique identifiers for plans that have been disabled.')]
    [System.String[]] $DisabledPlans

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The unique identifier for the SKU.')]
    [System.String] $SkuId
}

class MSFT_MicrosoftGraphGroupWritebackConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether writeback of cloud groups to on-premise Active Directory is enabled. Default value is true for Microsoft 365 groups and false for security groups.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the target on-premises group type the cloud object is written back as. Nullable. The possible values are: universalDistributionGroup, universalSecurityGroup, universalMailEnabledSecurityGroup.If the cloud group is a unified (Microsoft 365) group, this property can be one of the following: universalDistributionGroup, universalSecurityGroup, universalMailEnabledSecurityGroup. Microsoft Entra security groups can be written back as universalSecurityGroup. If isEnabled or the NewUnifiedGroupWritebackDefault group setting is true but this property isn''t explicitly configured: Microsoft 365 groups are written back as universalDistributionGroup by defaultSecurity groups are written back as universalSecurityGroup by default')]
    [ValidateSet('universalDistributionGroup', 'universalSecurityGroup', 'universalMailEnabledSecurityGroup')]
    [System.String] $OnPremisesGroupType
}
