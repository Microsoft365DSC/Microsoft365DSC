using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthorizationPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Display name for this policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of this policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Boolean Indicates whether users can sign up for email based subscriptions.')]
    [System.Nullable[System.Boolean]] $AllowedToSignUpEmailBasedSubscriptions

    [DscProperty()]
    [System.ComponentModel.Description('Boolean Indicates whether the Self-Serve Password Reset feature can be used by users on the tenant.')]
    [System.Nullable[System.Boolean]] $AllowedToUseSSPR

    [DscProperty()]
    [System.ComponentModel.Description('Boolean Indicates whether a user can join the tenant by email validation.')]
    [System.Nullable[System.Boolean]] $AllowEmailVerifiedUsersToJoinOrganization

    [DscProperty()]
    [System.ComponentModel.Description('Indicates who can invite external users to the organization. Possible values are: None, AdminsAndGuestInviters, AdminsGuestInvitersAndAllMembers, Everyone. Everyone is the default setting for all cloud environments except US Government.')]
    [ValidateSet('None', 'AdminsAndGuestInviters', 'AdminsGuestInvitersAndAllMembers', 'Everyone')]
    [System.String] $AllowInvitesFrom

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether user consent for risky apps is allowed.')]
    [System.Nullable[System.Boolean]] $AllowUserConsentForRiskyApps

    [DscProperty()]
    [System.ComponentModel.Description('Boolean To disable the use of MSOL PowerShell, set this property to true. This will also disable user-based access to the legacy service endpoint used by MSOL PowerShell. This does not affect Azure AD Connect or Microsoft Graph.')]
    [System.Nullable[System.Boolean]] $BlockMsolPowershell

    [DscProperty()]
    [System.ComponentModel.Description('The permissions the default user role holds.')]
    [MSFT_DefaultUserRolePermissions] $DefaultUserRolePermissions

    [DscProperty()]
    [System.ComponentModel.Description('List of features enabled for private preview on the tenant.')]
    [System.String[]] $EnabledPreviewFeatures

    [DscProperty()]
    [System.ComponentModel.Description('The role that should be granted to guest users. Refer to List unifiedRoleDefinitions to find the list of available role templates. Only supported roles today are User, Guest User, and Restricted Guest User (2af84b1e-32c8-42b7-82bc-daa82404023b).')]
    [ValidateSet('Guest', 'RestrictedGuest', 'User')]
    [System.String] $GuestUserRole

    [DscProperty()]
    [System.ComponentModel.Description('String collection Indicates if user consent to apps is allowed, and if it is, which permission to grant consent and which app consent policy (permissionGrantPolicy) govern the permission for users to grant consent. Value should be in the format managePermissionGrantsForSelf.{id}, where {id} is the id of a built-in or custom app consent policy. An empty list indicates user consent to apps is disabled.')]
    [System.String[]] $PermissionGrantPolicyIdsAssignedToDefaultUserRole

    [DscProperty()]
    [System.ComponentModel.Description('Specify that the Azure Authorization Policy should exist.')]
    [ValidateSet('Present')]
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

    [AADAuthorizationPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthorizationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Authorization Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $Policy = Get-MgBetaPolicyAuthorizationPolicy -ErrorAction Stop

            $complexDefaultUserRolePermissions = @{
                AllowedToCreateApps                      = $Policy.DefaultUserRolePermissions.AllowedToCreateApps
                AllowedToCreateSecurityGroups            = $Policy.DefaultUserRolePermissions.AllowedToCreateSecurityGroups
                AllowedToCreateTenants                   = $Policy.DefaultUserRolePermissions.AllowedToCreateTenants
                AllowedToReadBitlockerKeysForOwnedDevice = $Policy.DefaultUserRolePermissions.AllowedToReadBitlockerKeysForOwnedDevice
                AllowedToReadOtherUsers                  = $Policy.DefaultUserRolePermissions.AllowedToReadOtherUsers
            }

            $result = @{
                IsSingleInstance                                        = 'Yes'
                DisplayName                                             = $Policy.DisplayName
                Description                                             = $Policy.Description
                AllowedToSignUpEmailBasedSubscriptions                  = $Policy.AllowedToSignUpEmailBasedSubscriptions
                AllowedToUseSSPR                                        = $Policy.AllowedToUseSSPR
                AllowEmailVerifiedUsersToJoinOrganization               = $Policy.AllowEmailVerifiedUsersToJoinOrganization
                AllowInvitesFrom                                        = $Policy.AllowInvitesFrom
                AllowUserConsentForRiskyApps                            = $Policy.AllowUserConsentForRiskyApps
                BlockMsolPowerShell                                     = $Policy.BlockMsolPowerShell
                DefaultUserRolePermissions                              = $complexDefaultUserRolePermissions
                EnabledPreviewFeatures                                  = $Policy.EnabledPreviewFeatures
                PermissionGrantPolicyIdsAssignedToDefaultUserRole       = $Policy.PermissionGrantPolicyIdsAssignedToDefaultUserRole
                GuestUserRole                                           = $this.GetGuestUserRoleNameFromId($Policy.GuestUserRoleId)
                Ensure                                                  = 'Present'
                Credential                                              = $this.Credential
                ApplicationSecret                                       = $this.ApplicationSecret
                ApplicationId                                           = $this.ApplicationId
                TenantId                                                = $this.TenantId
                CertificateThumbprint                                   = $this.CertificateThumbprint
                CertificatePath                                         = $this.CertificatePath
                CertificatePassword                                     = $this.CertificatePassword
                ManagedIdentity                                         = $this.ManagedIdentity
                AccessTokens                                            = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of AzureAD Authorization Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $desiredParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $desiredParameters.Remove('IsSingleInstance') | Out-Null

        $updateParameters = @{}

        foreach ($param in $desiredParameters.Keys)
        {
            $desiredParam = $desiredParameters.$param
            $currentParam = $currentPolicy.$param

            # The null checks come first so that Compare-Object never receives a null operand.
            if (($null -eq $desiredParam -and $null -ne $currentParam) -or
                ($null -ne $desiredParam -and $null -eq $currentParam) -or
                ($desiredParam -is [System.Array] -and (Compare-Object -ReferenceObject $desiredParam -DifferenceObject $currentParam)) -or
                ($desiredParam -isnot [System.Array] -and $desiredParam -ne $currentParam))
            {
                if ($param -eq 'GuestUserRole')
                {
                    $updateParameters.Add('GuestUserRoleId', $this.GetGuestUserRoleIdFromName($desiredParam))
                }
                else
                {
                    $updateParameters.Add($param, $desiredParam)
                }
            }
        }

        try
        {
            Write-Verbose -Message "Updating existing authorization policy"
            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $updateParameters
            $null = Update-MgBetaPolicyAuthorizationPolicy -AuthorizationPolicyId 'authorizationPolicy' -BodyParameter $updateParameters -ErrorAction Stop
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw $_
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $currentDSCBlock = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                IsSingleInstance      = 'Yes'
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
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                Write-M365DSCHost -Message "    |---[1/1] $($results.DisplayName)" -DeferWrite

                if ($null -ne $Results.DefaultUserRolePermissions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DefaultUserRolePermissions `
                        -CIMInstanceName 'MSFT_DefaultUserRolePermissions'

                    if ([System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Remove('DefaultUserRolePermissions') | Out-Null
                    }
                    else
                    {
                        $Results.DefaultUserRolePermissions = $complexTypeStringResult
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $results `
                    -Credential $this.Credential `
                    -NoEscape @('DefaultUserRolePermissions')
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $currentDSCBlock
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetGuestUserRoleIdTable()
    {
        return @{
            'User'            = 'a0b1b346-4d3e-4e8b-98f8-753987be4970'
            'Guest'           = '10dae51f-b6af-4016-8d66-8c2a99b929b3'
            'RestrictedGuest' = '2af84b1e-32c8-42b7-82bc-daa82404023b'
        }
    }

    hidden [System.String] GetGuestUserRoleIdFromName([System.String] $GuestUserRole)
    {
        $guestUserRoleIdTable = $this.GetGuestUserRoleIdTable()
        return $guestUserRoleIdTable.$GuestUserRole
    }

    hidden [System.String] GetGuestUserRoleNameFromId([System.String] $GuestUserRoleId)
    {
        $guestUserRoleIdTable = $this.GetGuestUserRoleIdTable()
        if (-not $guestUserRoleIdTable.ContainsValue($GuestUserRoleId))
        {
            throw "Unexpected value of GuestuserRoleId '$GuestUserRoleId', should be one of $($guestUserRoleIdTable.Values -join ',')"
        }

        $roleName = $null
        foreach ($key in $guestUserRoleIdTable.Keys)
        {
            if ($guestUserRoleIdTable.$key -eq $GuestUserRoleId)
            {
                $roleName = $key
                Write-Verbose "`tRoleName matching GuestUserRoleId is $roleName"
                break
            }
        }
        Write-Verbose "return $roleName"
        return $roleName
    }

    hidden [AADAuthorizationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthorizationPolicy])
        {
            return $Values
        }

        $result = [AADAuthorizationPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DefaultUserRolePermissions
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the default user role can create applications. This setting corresponds to the Users can register applications setting in the User settings menu in the Microsoft Entra admin center.')]
    [System.Nullable[System.Boolean]] $AllowedToCreateApps

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the default user role can create security groups. This setting corresponds to the following menus in the Microsoft Entra admin center: - The Users can create security groups in Microsoft Entra admin centers, API or PowerShell setting in the Group settings menu. - Users can create security groups setting in the User settings menu.')]
    [System.Nullable[System.Boolean]] $AllowedToCreateSecurityGroups

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the default user role can create tenants. This setting corresponds to the Restrict non-admin users from creating tenants setting in the User settings menu in the Microsoft Entra admin center. When this setting is false, users assigned the Tenant Creator role can still create tenants.')]
    [System.Nullable[System.Boolean]] $AllowedToCreateTenants

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the registered owners of a device can read their own BitLocker recovery keys with default user role.')]
    [System.Nullable[System.Boolean]] $AllowedToReadBitlockerKeysForOwnedDevice

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the default user role can read other users. DO NOT SET THIS VALUE TO false.')]
    [System.Nullable[System.Boolean]] $AllowedToReadOtherUsers
}
