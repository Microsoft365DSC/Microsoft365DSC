using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAdministrativeUnit : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the Administrative Unit')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Object-Id of the Administrative Unit')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Administrative Unit')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Visibility of the Administrative Unit. Specify HiddenMembership if members of the AU are hidden')]
    [System.String] $Visibility

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the management rights on resources in the administrative units should be restricted to ONLY the administrators scoped on the administrative unit object.')]
    [System.Nullable[System.Boolean]] $IsMemberManagementRestricted

    [DscProperty()]
    [System.ComponentModel.Description('Specify membership type. Possible values are Assigned and Dynamic. Note that the functionality is currently in preview.')]
    [System.String] $MembershipType

    [DscProperty()]
    [System.ComponentModel.Description('Specify membership rule. Requires that MembershipType is set to Dynamic. Note that the functionality is currently in preview.')]
    [System.String] $MembershipRule

    [DscProperty()]
    [System.ComponentModel.Description('Specify dynamic membership-rule processing-state. Valid values are ''On'' and ''Paused''. Requires that MembershipType is set to Dynamic. Note that the functionality is currently in preview.')]
    [System.String] $MembershipRuleProcessingState

    [DscProperty()]
    [System.ComponentModel.Description('Specify members. Only specify if MembershipType is NOT set to Dynamic')]
    [MSFT_MicrosoftGraphMember[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('Specify Scoped Role Membership. Note: Any groups must be role-enabled')]
    [MSFT_MicrosoftGraphScopedRoleMembership[]] $ScopedRoleMembers

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Administrative Unit exists, absent ensures it is removed.')]
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

    [AADAdministrativeUnit] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAdministrativeUnit]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Administrative Unit '$($this.DisplayName)'"

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
                    $getValue = Get-MgDirectoryAdministrativeUnit -AdministrativeUnitId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue -and -not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    Write-Verbose -Message "Could not find an Azure AD Administrative Unit by Id, trying by DisplayName {$($this.DisplayName)}"
                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgDirectoryAdministrativeUnit -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" -ErrorAction Stop
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Administrative Unit with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($getValue.GetType().FullName -eq 'System.Object[]' -and $getValue.Count -gt 1)
            {
                throw "Multiple Azure AD Administrative Units with DisplayName {$($this.DisplayName)} were found. Please specify the Id of the desired Administrative Unit."
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Administrative Unit with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."
            $results = @{
                #region resource generator code
                Description                  = $getValue.Description
                DisplayName                  = $getValue.DisplayName
                Visibility                   = $getValue.Visibility
                IsMemberManagementRestricted = $getValue.IsMemberManagementRestricted
                Id                           = $getValue.Id
                Ensure                       = 'Present'
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                ApplicationSecret            = $this.ApplicationSecret
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                ManagedIdentity              = $this.ManagedIdentity
                AccessTokens                 = $this.AccessTokens
                #endregion
            }

            if (-not [string]::IsNullOrEmpty($getValue.membershipType))
            {
                $results.Add('MembershipType', $getValue.membershipType)
            }
            if (-not [string]::IsNullOrEmpty($getValue.membershipRule))
            {
                $results.Add('MembershipRule', $getValue.membershipRule)
            }
            if (-not [string]::IsNullOrEmpty($getValue.membershipRuleProcessingState))
            {
                $results.Add('MembershipRuleProcessingState', $getValue.membershipRuleProcessingState)
            }

            Write-Verbose -Message "AU {$($this.DisplayName)} MembershipType {$($results.MembershipType)}"
            if ($results.MembershipType -ne 'Dynamic')
            {
                Write-Verbose -Message "AU {$($this.DisplayName)} get Members"
                [array]$auMembers = Get-MgDirectoryAdministrativeUnitMember -AdministrativeUnitId $getValue.Id -All -Property @('id', 'displayName', 'userPrincipalName')
                if ($auMembers.Count -gt 0)
                {
                    Write-Verbose -Message "AU {$($this.DisplayName)} process $($auMembers.Count) members"
                    $memberSpec = @()
                    foreach ($auMember in $auMembers)
                    {
                        $member = [ordered]@{}
                        if ($auMember.'@odata.type' -match 'user')
                        {
                            $member.Add('Identity', $auMember.userPrincipalName)
                            $member.Add('Type', 'User')
                        }
                        elseif ($auMember.'@odata.type' -match 'group')
                        {
                            $member.Add('Identity', $auMember.displayName)
                            $member.Add('Type', 'Group')
                        }
                        elseif ($auMember.'@odata.type' -match 'device')
                        {
                            $member.Add('Identity', $auMember.displayName)
                            $member.Add('Type', 'Device')
                        }
                        else
                        {
                            throw "AU {$($this.DisplayName)}: member {$($auMember.Id)} has invalid type {$($auMember.'@odata.type')}"
                        }
                        $memberSpec += $member
                    }
                    Write-Verbose -Message "AU {$($this.DisplayName)} add Members to results"
                    $results.Add('Members', $memberSpec)
                }
            }

            Write-Verbose -Message "AU {$($this.DisplayName)} get Scoped Role Members"
            $ErrorActionPreference = 'Stop'
            [array]$auScopedRoleMembers = Get-MgDirectoryAdministrativeUnitScopedRoleMember -AdministrativeUnitId $getValue.Id -All
            $scopedRoleMemberRequests = [System.Collections.Generic.List[System.Object]]::new($auScopedRoleMembers.Count)
            foreach ($auScopedRoleMemberId in ($auScopedRoleMembers.RoleMemberInfo.Id | Select-Object -Unique))
            {
                $scopedRoleMemberRequests.Add(@{
                        id     = $auScopedRoleMemberId
                        method = 'GET'
                        url    = "/directoryObjects/$($auScopedRoleMemberId)?`$select=id"
                    })
            }
            if ($null -eq $this.ResourceCache['DirectoryRoles'])
            {
                $this.ResourceCache['DirectoryRoles'] = Get-MgDirectoryRole -All
            }
            if ($auScopedRoleMembers.Count -gt 0)
            {
                Write-Verbose -Message "AU {$($this.DisplayName)} process $($auScopedRoleMembers.Count) scoped role members"
                $memberObjectResponses = Invoke-M365DSCGraphBatchRequest -Requests $scopedRoleMemberRequests -AsList
                $scopedRoleMemberSpec = @()
                foreach ($auScopedRoleMember in $auScopedRoleMembers)
                {
                    Write-Verbose -Message "AU {$($this.DisplayName)} verify RoleId {$($auScopedRoleMember.RoleId)}"
                    $roleObject = $this.ResourceCache['DirectoryRoles'] | Where-Object { $_.Id -eq $auScopedRoleMember.RoleId }
                    Write-Verbose -Message "Found DirectoryRole '$($roleObject.DisplayName)' with id $($roleObject.Id)"
                    $scopedRoleMember = [ordered]@{
                        RoleName       = $roleObject.DisplayName
                        RoleMemberInfo = [ordered]@{
                            Identity = $null
                            Type     = $null
                        }
                    }
                    Write-Verbose -Message "AU {$($this.DisplayName)} verify RoleMemberInfo.Id {$($auScopedRoleMember.RoleMemberInfo.Id)}"
                    $memberObject = $memberObjectResponses.Where({ $_.id -eq $auScopedRoleMember.RoleMemberInfo.Id }).body
                    Write-Verbose -Message "AU {$($this.DisplayName)} @odata.Type={$($memberObject.'@odata.type')}"
                    if (($memberObject.'@odata.type') -match 'user')
                    {
                        Write-Verbose -Message "AU {$($this.DisplayName)} UPN = {$($auScopedRoleMember.RoleMemberInfo.userPrincipalName)}"
                        $scopedRoleMember.RoleMemberInfo.Identity = $auScopedRoleMember.RoleMemberInfo.userPrincipalName
                        $scopedRoleMember.RoleMemberInfo.Type = 'User'
                    }
                    elseif (($memberObject.'@odata.type') -match 'group')
                    {
                        Write-Verbose -Message "AU {$($this.DisplayName)} Group = {$($auScopedRoleMember.RoleMemberInfo.DisplayName)}"
                        $scopedRoleMember.RoleMemberInfo.Identity = $auScopedRoleMember.RoleMemberInfo.DisplayName
                        $scopedRoleMember.RoleMemberInfo.Type = 'Group'
                    }
                    elseif (($memberObject.'@odata.type') -match 'servicePrincipal')
                    {
                        Write-Verbose -Message "AU {$($this.DisplayName)} SPN = {$($auScopedRoleMember.RoleMemberInfo.DisplayName)}"
                        $scopedRoleMember.RoleMemberInfo.Identity = $auScopedRoleMember.RoleMemberInfo.DisplayName
                        $scopedRoleMember.RoleMemberInfo.Type = 'ServicePrincipal'
                    }
                    else
                    {
                        throw "AU {$($this.DisplayName)}: scoped role member {$($memberObject.Id)} has invalid type {$($memberObject.'@odata.type')}"
                    }
                    Write-Verbose -Message "AU {$($this.DisplayName)} scoped role member: RoleName '$($scopedRoleMember.RoleName)' Type '$($scopedRoleMember.RoleMemberInfo.Type)' Identity '$($scopedRoleMember.RoleMemberInfo.Identity)'"
                    $scopedRoleMemberSpec += $scopedRoleMember
                }
                Write-Verbose -Message "AU {$($this.DisplayName)} add $($scopedRoleMemberSpec.Count) ScopedRoleMembers to results"
                $results.Add('ScopedRoleMembers', $scopedRoleMemberSpec)
            }
            Write-Verbose -Message "AU {$($this.DisplayName)} return results"
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
        $memberSpecification = $null
        $scopedRoleMemberSpecification = $null
        $roleObject = $null
        $createParameters = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Administrative Unit '$($this.DisplayName)'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $backCurrentMembers = $currentInstance.Members
        $backCurrentScopedRoleMembers = $currentInstance.ScopedRoleMembers

        if ($this.Ensure -eq 'Present')
        {
            if ($this.MembershipType -eq 'Dynamic' -and $this.Members.Count -gt 0)
            {
                throw "AU {$($this.DisplayName)}: Members is not allowed when MembershipType is Dynamic"
            }
            $createParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $createParameters = Rename-M365DSCCimInstanceParameter -Properties $createParameters
            $createParameters.Remove('Id') | Out-Null

            $memberSpecification = $null
            if ($createParameters.MembershipType -ne 'Dynamic' -and $createParameters.Members.Count -gt 0)
            {
                $memberSpecification = @()
                Write-Verbose -Message "AU {$($this.DisplayName)} process $($createParameters.Members.Count) Members"
                foreach ($member in $createParameters.Members)
                {
                    Write-Verbose -Message "AU {$($this.DisplayName)} member Type '$($member.Type)' Identity '$($member.Identity)'"
                    if ($member.Type -eq 'User')
                    {
                        [array]$memberIdentity = Get-MgUser -Filter "UserPrincipalName eq '$($member.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($memberIdentity)
                        {
                            $memberSpecification += $memberIdentity.Id
                        }
                        else
                        {
                            throw "AU {$($this.DisplayName)}: User {$($member.Identity)} does not exist"
                        }
                    }
                    elseif ($member.Type -eq 'Group')
                    {
                        [array]$memberIdentity = Get-MgGroup -Filter "DisplayName eq '$($member.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($memberIdentity)
                        {
                            if ($memberIdentity.Count -gt 1)
                            {
                                throw "AU {$($this.DisplayName)}: Group displayname {$($member.Identity)} is not unique"
                            }
                            $memberSpecification += $memberIdentity.Id
                        }
                        else
                        {
                            throw "AU {$($this.DisplayName)}: Group {$($member.Identity)} does not exist"
                        }
                    }
                    elseif ($member.Type -eq 'Device')
                    {
                        [array]$memberIdentity = Get-MgDevice -Filter "DisplayName eq '$($member.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($memberIdentity)
                        {
                            if ($memberIdentity.Count -gt 1)
                            {
                                throw "AU {$($this.DisplayName)}: Device displayname {$($member.Identity)} is not unique"
                            }
                            $memberSpecification += $memberIdentity.Id
                        }
                        else
                        {
                            throw "AU {$($this.DisplayName)}: Device {$($member.Identity)} does not exist"
                        }
                    }
                    else
                    {
                        throw "AU {$($this.DisplayName)}: Member {$($member.Identity)} has invalid type {$($member.Type)}"
                    }
                }
                # Members are added to the AU *after* it has been created
            }
            $createParameters.Remove('Members') | Out-Null

            # Resolve ScopedRoleMembers Type/Identity to user, group or service principal
            if ($createParameters.ScopedRoleMembers)
            {
                Write-Verbose -Message "AU {$($this.DisplayName)} process $($createParameters.ScopedRoleMembers.Count) ScopedRoleMembers"
                $scopedRoleMemberSpecification = @()
                foreach ($roleMember in $createParameters.ScopedRoleMembers)
                {
                    Write-Verbose -Message "AU {$($this.DisplayName)} member: role '$($roleMember.RoleName)' type '$($roleMember.RoleMemberInfo.Type)' identity $($roleMember.RoleMemberInfo.Identity)"
                    try
                    {
                        $roleObject = Get-MgDirectoryRole -Filter "DisplayName eq '$($roleMember.RoleName -replace "'", "''")'" -ErrorAction stop

                        if ($null -eq $roleObject)
                        {
                            throw "Azure AD role {$($rolemember.RoleName)} may not be enabled"
                        }
                    }
                    catch
                    {
                        Write-Verbose -Message "Azure AD role {$($rolemember.RoleName)} is not enabled"
                        $roleTemplate = Get-MgDirectoryRoleTemplate -All -ErrorAction Stop | Where-Object { $_.DisplayName -eq $rolemember.RoleName }
                        if ($null -ne $roleTemplate)
                        {
                            Write-Verbose -Message "Enable Azure AD role {$($rolemember.RoleName)} with id {$($roleTemplate.Id)}"
                            $roleObject = New-MgDirectoryRole -RoleTemplateId $roleTemplate.Id -ErrorAction Stop
                        }
                    }
                    if ($null -eq $roleObject)
                    {
                        throw "AU {$($this.DisplayName)}: RoleName {$($roleMember.RoleName)} does not exist"
                    }
                    if ($roleMember.RoleMemberInfo.Type -eq 'User')
                    {
                        [System.Array]$roleMemberIdentity = Get-MgUser -Filter "UserPrincipalName eq '$($roleMember.RoleMemberInfo.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($null -eq $roleMemberIdentity)
                        {
                            throw "AU {$($this.DisplayName)}:  Scoped Role User {$($roleMember.RoleMemberInfo.Identity)} for role {$($roleMember.RoleName)} does not exist"
                        }
                    }
                    elseif ($roleMember.RoleMemberInfo.Type -eq 'Group')
                    {
                        [System.Array]$roleMemberIdentity = Get-MgGroup -Filter "displayName eq '$($roleMember.RoleMemberInfo.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($null -eq $roleMemberIdentity)
                        {
                            throw "AU {$($this.DisplayName)}: Scoped Role Group {$($roleMember.RoleMemberInfo.Identity)} for role {$($roleMember.RoleName)} does not exist"
                        }
                        elseif ($roleMemberIdentity.IsAssignableToRole -eq $false)
                        {
                            throw "AU {$($this.DisplayName)}: Scoped Role Group {$($roleMember.RoleMemberInfo.Identity)} for role {$($roleMember.RoleName)} is not role-enabled"
                        }
                    }
                    elseif ($roleMember.RoleMemberInfo.Type -eq 'ServicePrincipal')
                    {
                        [System.Array]$roleMemberIdentity = Get-MgServicePrincipal -Filter "displayName eq '$($roleMember.RoleMemberInfo.Identity -replace "'", "''")'" -ErrorAction Stop
                        if ($null -eq $roleMemberIdentity)
                        {
                            throw "AU {$($this.DisplayName)}: Scoped Role ServicePrincipal {$($roleMember.RoleMemberInfo.Identity)} for role {$($roleMember.RoleName)} does not exist"
                        }
                    }
                    else
                    {
                        throw "AU {$($this.DisplayName)}: Invalid ScopedRoleMember.RoleMemberInfo.Type {$($roleMember.RoleMemberInfo.Type)}"
                    }
                    if ($roleMemberIdentity.Count -gt 1)
                    {
                        throw "AU {$($this.DisplayName)}: ScopedRoleMember for role {$($roleMember.RoleName)}: $($roleMember.RoleMemberInfo.Type) {$($roleMember.RoleMemberInfo.Identity)} is not unique"
                    }
                    $scopedRoleMemberSpecification += [ordered]@{
                        RoleId         = $roleObject.Id
                        RoleMemberInfo = @{
                            Id = $roleMemberIdentity[0].Id
                        }
                    }
                }
                # ScopedRoleMember-info is added after the AU is created
            }
            $createParameters.Remove('ScopedRoleMembers') | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Administrative Unit with DisplayName {$($this.DisplayName)}"

            #region resource generator code
            Write-Verbose -Message "Creating new Administrative Unit with: $(Convert-M365DscHashtableToString -Hashtable $createParameters)"
            $policy = New-MgDirectoryAdministrativeUnit -BodyParameter $createParameters
            Start-Sleep -Seconds 5 # Sleep added to allow for AU to be fully available before adding members

            if ($this.MembershipType -ne 'Dynamic')
            {
                foreach ($member in $memberSpecification)
                {
                    Write-Verbose -Message "Adding new assigned member {$($member)}"
                    $url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($member)"

                    Invoke-M365DSCCommand -ScriptBLock {
                        New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $policy.Id -BodyParameter @{
                            "@odata.id" = $url
                        }
                    } -RetryOnNotFoundError
                }
            }

            foreach ($scopedRoleMember in $scopedRoleMemberSpecification)
            {
                Invoke-M365DSCCommand -ScriptBLock {
                    New-MgDirectoryAdministrativeUnitScopedRoleMember -AdministrativeUnitId $policy.Id -BodyParameter $scopedRoleMember
                } -RetryOnNotFoundError
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Administrative Unit with Id {$($currentInstance.Id)}"

            $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $updateParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('IsMemberManagementRestricted') | Out-Null

            $requestedMembers = $updateParameters.Members
            $updateParameters.Remove('Members') | Out-Null
            $requestedScopedRoleMembers = $updateParameters.ScopedRoleMembers
            $updateParameters.Remove('ScopedRoleMembers') | Out-Null

            #region resource generator code
            Update-MgDirectoryAdministrativeUnit -AdministrativeUnitId $currentInstance.Id -BodyParameter $updateParameters
            #endregion

            if ($this.MembershipType -ne 'Dynamic')
            {
                if ($this.GetBoundParameters().ContainsKey('Members') -and ($backCurrentMembers.Count -gt 0 -or $requestedMembers.Count -gt 0))
                {
                    $currentMembers = @()
                    foreach ($member in $backCurrentMembers)
                    {
                        $currentMembers += @{Type = $member.Type; Identity = $member.Identity }
                    }
                    $desiredMembers = @()
                    foreach ($member in $requestedMembers)
                    {
                        $desiredMembers += @{Type = $member.Type; Identity = $member.Identity }
                    }
                    $membersDiff = Compare-Object -ReferenceObject $currentMembers -DifferenceObject $desiredMembers
                    foreach ($diff in $membersDiff)
                    {
                        if ($diff.InputObject.Type -eq 'User')
                        {
                            [array]$memberObject = Get-MgUser -Filter "UserPrincipalName eq '$($diff.InputObject.Identity -replace "'", "''")'"
                            #$memberType = 'users'
                        }
                        elseif ($diff.InputObject.Type -eq 'Group')
                        {
                            [array]$memberObject = Get-MgGroup -Filter "DisplayName eq '$($diff.InputObject.Identity -replace "'", "''")'"
                            #$memberType = 'groups'
                        }
                        elseif ($diff.InputObject.Type -eq 'Device')
                        {
                            [array]$memberObject = Get-MgDevice -Filter "DisplayName eq '$($diff.InputObject.Identity -replace "'", "''")'"
                            #memberType = 'devices'
                        }
                        else
                        {
                            # a *new* member has been specified with invalid type
                            throw "AU {$($this.DisplayName)}: Member {$($diff.InputObject.Identity)} has invalid type {$($diff.InputObject.Type)}"
                        }
                        if ($null -eq $memberObject)
                        {
                            throw "AU member {$($diff.InputObject.Identity)} does not exist as a $($diff.InputObject.Type)"
                        }
                        if ($memberObject.Count -gt 1)
                        {
                            throw "AU member {$($diff.InputObject.Identity)} is not a unique $($diff.InputObject.Type.ToLower()) (Count=$($memberObject.Count))"
                        }
                        if ($diff.SideIndicator -eq '=>')
                        {
                            Write-Verbose -Message "AdministrativeUnit {$($this.DisplayName)} Adding member {$($diff.InputObject.Identity)}, type {$($diff.InputObject.Type)}"

                            $url = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "v1.0/directoryObjects/$($memberObject.Id)"
                            New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId ($currentInstance.Id) -BodyParameter @{ "@odata.id" = $url } | Out-Null
                        }
                        else
                        {
                            Write-Verbose -Message "Administrative Unit {$($this.DisplayName)} Removing member {$($diff.InputObject.Identity)}, type {$($diff.InputObject.Type)}"
                            Remove-MgDirectoryAdministrativeUnitMemberDirectoryObjectByRef -AdministrativeUnitId ($currentInstance.Id) -DirectoryObjectId ($memberObject.Id) | Out-Null
                        }
                    }
                }
            }

            if ($this.GetBoundParameters().ContainsKey('ScopedRoleMembers') -and ($backCurrentScopedRoleMembers.Count -gt 0 -or $requestedScopedRoleMembers.Count -gt 0))
            {
                $currentScopedRoleMembersValue = @()
                if ($currentInstance.ScopedRoleMembers.Length -ne 0)
                {
                    $currentScopedRoleMembersValue = $backCurrentScopedRoleMembers
                }
                if ($null -eq $currentScopedRoleMembersValue)
                {
                    $currentScopedRoleMembersValue = @()
                }
                $desiredScopedRoleMembersValue = $requestedScopedRoleMembers
                if ($null -eq $desiredScopedRoleMembersValue)
                {
                    $desiredScopedRoleMembersValue = @()
                }

                # flatten hashtables for compare
                $compareCurrentScopedRoleMembersValue = @()
                foreach ($roleMember in $currentScopedRoleMembersValue)
                {
                    $compareCurrentScopedRoleMembersValue += [PSCustomObject]@{
                        RoleName = $roleMember.RoleName
                        Identity = $roleMember.RoleMemberInfo.Identity
                        Type     = $roleMember.RoleMemberInfo.Type
                    }
                }
                $compareDesiredScopedRoleMembersValue = @()
                foreach ($roleMember in $desiredScopedRoleMembersValue)
                {
                    $compareDesiredScopedRoleMembersValue += [PSCustomObject]@{
                        RoleName = $roleMember.RoleName
                        Identity = $roleMember.RoleMemberInfo.Identity
                        Type     = $roleMember.RoleMemberInfo.Type
                    }
                }
                Write-Verbose -Message "AU {$($this.DisplayName)} Update ScopedRoleMembers: Current members: $($compareCurrentScopedRoleMembersValue.Identity -join ', ')"
                Write-Verbose -Message "                                            Desired members: $($compareDesiredScopedRoleMembersValue.Identity -join ', ')"
                $scopedRoleMembersDiff = Compare-Object -ReferenceObject $compareCurrentScopedRoleMembersValue -DifferenceObject $compareDesiredScopedRoleMembersValue -Property RoleName, Identity, Type
                # $scopedRoleMembersDiff = Compare-Object -ReferenceObject $CurrentScopedRoleMembersValue -DifferenceObject $DesiredScopedRoleMembersValue -Property RoleName, Identity, Type
                Write-Verbose -Message "                                            # compare results : $($scopedRoleMembersDiff.Count -gt 0)"

                foreach ($diff in $scopedRoleMembersDiff)
                {
                    if ($diff.Type -eq 'User')
                    {
                        [array]$memberObject = Get-MgUser -Filter "UserPrincipalName eq '$($diff.Identity -replace "'", "''")'"
                        #$memberType = 'users'
                    }
                    elseif ($diff.Type -eq 'Group')
                    {
                        [array]$memberObject = Get-MgGroup -Filter "DisplayName eq '$($diff.Identity -replace "'", "''")'"
                        #$membertype = 'groups'
                    }
                    elseif ($diff.Type -eq 'ServicePrincipal')
                    {
                        [array]$memberObject = Get-MgServicePrincipal -Filter "DisplayName eq '$($diff.Identity -replace "'", "''")'"
                        #$memberType = "servicePrincipals"
                    }
                    else
                    {
                        if ($diff.RoleName)
                        {
                            throw "AU {$($this.DisplayName)} scoped role {$($diff.RoleName)} member {$($diff.Identity)} has invalid type $($diff.Type)"
                        }
                        else
                        {
                            Write-Verbose -Message 'Compare ScopedRoleMembers - skip processing blank RoleName'
                            continue   # don't process,
                        }
                    }
                    if ($null -eq $memberObject)
                    {
                        throw "AU scoped role member {$($diff.Identity)} does not exist as a $($diff.Type)"
                    }
                    if ($memberObject.Count -gt 1)
                    {
                        throw "AU scoped role member {$($diff.Identity)} is not a unique $($diff.Type) (Count=$($memberObject.Count))"
                    }
                    if ($diff.SideIndicator -ne '==')
                    {
                        $roleObject = Get-MgDirectoryRole -Filter "DisplayName eq '$($diff.RoleName -replace "'", "''")'"
                        if ($null -eq $roleObject)
                        {
                            throw "AU {$($this.DisplayName)} Scoped Role {$($diff.RoleName)} does not exist as an Azure AD role"
                        }
                    }
                    if ($diff.SideIndicator -eq '=>')
                    {
                        Write-Verbose -Message "Adding new scoped role {$($diff.RoleName)} member {$($diff.Identity)}, type {$($diff.Type)} to Administrative Unit {$($this.DisplayName)}"

                        $scopedRoleMemberParam = [ordered]@{
                            RoleId         = $roleObject.Id
                            RoleMemberInfo = @{
                                Id = $memberObject.Id
                            }
                        }
                        # addition of scoped rolemember may throw if role is not supported as a scoped role
                        New-MgDirectoryAdministrativeUnitScopedRoleMember -AdministrativeUnitId ($currentInstance.Id) -BodyParameter $scopedRoleMemberParam -ErrorAction Stop | Out-Null
                    }
                    else
                    {
                        if (-not [string]::IsNullOrEmpty($diff.Rolename))
                        {
                            Write-Verbose -Message "Removing scoped role {$($diff.RoleName)} member {$($diff.Identity)}, type {$($diff.Type)} from Administrative Unit {$($this.DisplayName)}"
                            $scopedRoleMemberObject = Get-MgDirectoryAdministrativeUnitScopedRoleMember -AdministrativeUnitId ($currentInstance.Id) -All | Where-Object -FilterScript { $_.RoleId -eq $roleObject.Id -and $_.RoleMemberInfo.Id -eq $memberObject.Id }
                            Remove-MgDirectoryAdministrativeUnitScopedRoleMember -AdministrativeUnitId ($currentInstance.Id) -ScopedRoleMembershipId $scopedRoleMemberObject.Id -ErrorAction Stop | Out-Null
                        }
                    }
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AU {$($this.DisplayName)}"
            # If switching to Beta in future, must use *-MgBetaAdministrativeUnit cmdlets instead of *-MgBetaDirectoryAdministrativeUnit
            # See https://github.com/microsoft/Microsoft365DSC/pull/6145
            Remove-MgDirectoryAdministrativeUnit -AdministrativeUnitId $currentInstance.Id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $allConditionsMatched = $null
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
            $ExportParameters = @{
                Filter      = $this.Filter
                All         = [switch]$true
                ErrorAction = 'Stop'
            }
            $queryTypes = @{
                'eq'         = @('description')
                'startsWith' = @('description')
                'eq null'    = @(
                    'description',
                    'displayName'
                )
            }

            #extract arguments from the query
            # Define the regex pattern to match all words in the query
            $pattern = '([^\s,()]+)'
            $query = $this.Filter

            # Match all words in the query
            $matches = [regex]::Matches($query, $pattern)

            # Extract the matched argument into an array
            $arguments = @()
            foreach ($match in $matches)
            {
                $arguments += $match.Value
            }

            #extracting keys to check vs arguments in the filter
            $Keys = $queryTypes.Keys

            $matchedKey = $arguments | Where-Object { $_ -in $Keys }
            $matchedProperty = $arguments | Where-Object { $_ -in $queryTypes[$matchedKey] }
            if ($matchedProperty -and $matchedKey)
            {
                $allConditionsMatched = $true
            }

            # If all conditions match the support, add parameters to $ExportParameters
            if ($allConditionsMatched -or ($this.Filter -like '*endsWith*') -or ($this.Filter -like '*not*'))
            {
                $ExportParameters.Add('CountVariable', 'count')
                $ExportParameters.Add('headers', @{'ConsistencyLevel' = 'Eventual' })
            }

            [array] $exportedInstances = Get-MgDirectoryAdministrativeUnit @ExportParameters
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
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
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
                    Id                    = $config.Id
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
                if ($null -ne $Results.ScopedRoleMembers)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'RoleMemberInfo'
                            CimInstanceName = 'MicrosoftGraphMember'
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.ScopedRoleMembers) `
                        -CIMInstanceName MicrosoftGraphScopedRoleMembership -ComplexTypeMapping $complexMapping

                    $Results.ScopedRoleMembers = $complexTypeStringResult

                    if ([String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.Remove('ScopedRoleMembers') | Out-Null
                    }
                }
                if ($null -ne $Results.Members)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Members) `
                        -CIMInstanceName MicrosoftGraphMember
                    $Results.Members = $complexTypeStringResult

                    if ([String]::IsNullOrEmpty($complexTypeStringResult))
                    {
                        $Results.Remove('Members') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Members', 'ScopedRoleMembers') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Visibility')
        }
    }

    hidden [AADAdministrativeUnit] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAdministrativeUnit])
        {
            return $Values
        }

        $result = [AADAdministrativeUnit]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphMember
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Identity of member. For users, specify a UserPrincipalName. For groups, devices and serviceprincipals, specify DisplayName')]
    [System.String] $Identity

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specify User, Group or Device to interpret the identity for Members. Specify User, Group or ServicePrincipal for ScopedRoleMembers.')]
    [ValidateSet('User', 'Group', 'Device', 'ServicePrincipal')]
    [System.String] $Type
}

class MSFT_MicrosoftGraphScopedRoleMembership
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Azure AD Role that is assigned. See https://learn.microsoft.com/en-us/azure/active-directory/roles/admin-units-assign-roles#roles-that-can-be-assigned-with-administrative-unit-scope')]
    [System.String] $RoleName

    [DscProperty()]
    [System.ComponentModel.Description('Member that is assigned the scoped role. Note: Any groups must be role-enabled')]
    [MSFT_MicrosoftGraphMember] $RoleMemberInfo
}
