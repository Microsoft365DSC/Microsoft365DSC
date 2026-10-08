using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADDeviceRegistrationPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not administrators can configure Azure AD Join.')]
    [System.Nullable[System.Boolean]] $AzureADJoinIsAdminConfigurable

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum number of devices that a user can have within your organization before blocking new device registrations. The default value is set to 50. If this property isn''t specified, the current value is kept.')]
    [System.Nullable[System.UInt32]] $UserDeviceQuota

    [DscProperty()]
    [System.ComponentModel.Description('Scope that a device registration policy applies to.')]
    [ValidateSet('All', 'Selected', 'None')]
    [System.String] $AzureADAllowedToJoin

    [DscProperty()]
    [System.ComponentModel.Description('List of users that this policy applies to.')]
    [System.String[]] $AzureADAllowedToJoinUsers

    [DscProperty()]
    [System.ComponentModel.Description('List of groups that this policy applies to.')]
    [System.String[]] $AzureADAllowedToJoinGroups

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the authorization policy for controlling registration of new devices using Microsoft Entra registered.')]
    [MSFT_AzureADRegistrationPolicy] $AzureADRegistration

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the authentication policy for a user to complete registration using Microsoft Entra join or Microsoft Entra registered within your organization. The possible values are: notRequired, required, unknownFutureValue. The default value is notRequired.')]
    [ValidateSet('notRequired', 'required')]
    [System.String] $MultiFactorAuthConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether global administrators are local administrators on all Microsoft Entra-joined devices. This setting only applies to future registrations. Default is true.')]
    [System.Nullable[System.Boolean]] $LocalAdminsEnableGlobalAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Scope that a device registration policy applies to for local admins.')]
    [ValidateSet('All', 'Selected', 'None')]
    [System.String] $AzureAdJoinLocalAdminsRegisteringMode

    [DscProperty()]
    [System.ComponentModel.Description('List of groups that this policy applies to.')]
    [System.String[]] $AzureAdJoinLocalAdminsRegisteringGroups

    [DscProperty()]
    [System.ComponentModel.Description('List of users that this policy applies to.')]
    [System.String[]] $AzureAdJoinLocalAdminsRegisteringUsers

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this policy scope is configurable by the admin. The default value is false. An admin can set it to true to enable Local Admin Password Solution (LAPS) within their organzation.')]
    [System.Nullable[System.Boolean]] $LocalAdminPasswordIsEnabled

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

    [AADDeviceRegistrationPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADDeviceRegistrationPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Device Registration Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $getValue = Get-MgBetaPolicyDeviceRegistrationPolicy -ErrorAction Stop

            $azureADAllowedToJoinValue = 'None'
            $azureADAllowedToJoinUsersValue = @()
            $azureADAllowedToJoinGroupsValue = @()
            if ($getValue.AzureADJoin.AllowedToJoin.'@odata.type' -eq '#microsoft.graph.allDeviceRegistrationMembership')
            {
                $azureADAllowedToJoinValue = 'All'
            }
            elseif ($getValue.AzureADJoin.AllowedToJoin.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
            {
                $azureADAllowedToJoinValue = 'Selected'

                foreach ($userId in $getValue.AzureAdJoin.AllowedToJoin.users)
                {
                    try
                    {
                        $userInfo = Get-MgUser -UserId $userId -ErrorAction Stop
                        $azureADAllowedToJoinUsersValue += $userInfo.UserPrincipalName
                    }
                    catch
                    {
                        $message = "Could not find a user with id $($userId) specified in AllowedToJoin. Skipping user!"
                        $this.LogError($_, $message)
                        continue
                    }
                }

                foreach ($groupId in $getValue.AzureAdJoin.AllowedToJoin.groups)
                {
                    try
                    {
                        $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction Stop
                        $azureADAllowedToJoinGroupsValue += $groupInfo.DisplayName
                    }
                    catch
                    {
                        $message = "Could not find a group with id $($groupId) specified in AllowedToJoin. Skipping group!"
                        $this.LogError($_, $message)
                        continue
                    }
                }
            }

            $localAdminsRegisteringUsersValue = @()
            $localAdminsRegisteringGroupsValue = @()
            $localAdminsRegisteringModeValue = 'All'

            if ($getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.'@odata.type' -eq '#microsoft.graph.noDeviceRegistrationMembership')
            {
                $localAdminsRegisteringModeValue = 'None'
            }
            elseif ($getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
            {
                $localAdminsRegisteringModeValue = 'Selected'
                foreach ($userId in $getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.users)
                {
                    try
                    {
                        $userInfo = Get-MgUser -UserId $userId -ErrorAction Stop
                        $localAdminsRegisteringUsersValue += $userInfo.UserPrincipalName
                    }
                    catch
                    {
                        $message = "Could not find a user with id $($userId) specified in AllowedToJoin. Skipping user!"
                        $this.LogError($_, $message)
                        continue
                    }
                }

                foreach ($groupId in $getValue.AzureAdJoin.LocalAdmins.RegisteringUsers.groups)
                {
                    try
                    {
                        $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction Stop
                        $localAdminsRegisteringGroupsValue += $groupInfo.DisplayName
                    }
                    catch
                    {
                        $message = "Could not find a group with id $($groupId) specified in AllowedToJoin. Skipping group!"
                        $this.LogError($_, $message)
                        continue
                    }
                }
            }

            $azureADRegistrationUsersValue = @()
            $azureADRegistrationGroupsValue = @()
            if ($getValue.AzureADRegistration.AllowedToRegister.'@odata.type' -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
            {
                foreach ($userId in $getValue.AzureADRegistration.AllowedToRegister.users)
                {
                    try
                    {
                        $userInfo = Get-MgUser -UserId $userId -ErrorAction Stop
                        $azureADRegistrationUsersValue += $userInfo.UserPrincipalName
                    }
                    catch
                    {
                        $message = "Could not find a user with id $($userId) specified in AllowedToRegister. Skipping user!"
                        $this.LogError($_, $message)
                        continue
                    }
                }

                foreach ($groupId in $getValue.AzureADRegistration.AllowedToRegister.groups)
                {
                    try
                    {
                        $groupInfo = Get-MgGroup -GroupId $groupId -ErrorAction Stop
                        $azureADRegistrationGroupsValue += $groupInfo.DisplayName
                    }
                    catch
                    {
                        $message = "Could not find a group with id $($groupId) specified in AllowedToRegister. Skipping group!"
                        $this.LogError($_, $message)
                        continue
                    }
                }
            }

            $azureADRegistrationValue = @{
                AllowedToRegister   = @{
                    Groups    = $azureADRegistrationGroupsValue
                    Users     = $azureADRegistrationUsersValue
                    odataType = $getValue.AzureADRegistration.AllowedToRegister.'@odata.type'
                }
                IsAdminConfigurable = [Boolean]$getValue.AzureADRegistration.IsAdminConfigurable
            }

            $localAdminsEnableGlobalAdminsValue = $true
            if (-not $getValue.AzureAdJoin.LocalAdmins.EnableGlobalAdmins)
            {
                $localAdminsEnableGlobalAdminsValue = $false
            }
            $results = @{
                IsSingleInstance                        = 'Yes'
                AzureADJoinIsAdminConfigurable          = [Boolean]$getValue.AzureAdJoin.IsAdminConfigurable
                AzureADAllowedToJoin                    = $azureADAllowedToJoinValue
                AzureADAllowedToJoinGroups              = $azureADAllowedToJoinGroupsValue
                AzureADAllowedToJoinUsers               = $azureADAllowedToJoinUsersValue
                AzureADRegistration                     = $azureADRegistrationValue
                UserDeviceQuota                         = $getValue.UserDeviceQuota
                MultiFactorAuthConfiguration            = $getValue.MultiFactorAuthConfiguration
                LocalAdminsEnableGlobalAdmins           = $localAdminsEnableGlobalAdminsValue
                LocalAdminPasswordIsEnabled             = [Boolean]$getValue.LocalAdminPassword.IsEnabled
                AzureAdJoinLocalAdminsRegisteringMode   = $localAdminsRegisteringModeValue
                AzureAdJoinLocalAdminsRegisteringGroups = $localAdminsRegisteringGroupsValue
                AzureAdJoinLocalAdminsRegisteringUsers  = $localAdminsRegisteringUsersValue
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                ApplicationSecret                       = $this.ApplicationSecret
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
            }

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
        $azureADRegistrationAllowedUsers = $null
        $localAdminAllowedGroups = $null
        $localAdminAllowedUsers = $null
        $azureADRegistrationAllowedGroups = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of AzureAD Device Registration Policy'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = $this.GetBoundParameters()
        foreach ($propertyName in @(
                'AzureADAllowedToJoin',
                'AzureADAllowedToJoinGroups',
                'AzureADAllowedToJoinUsers',
                'AzureADJoinIsAdminConfigurable',
                'AzureAdJoinLocalAdminsRegisteringGroups',
                'AzureAdJoinLocalAdminsRegisteringMode',
                'AzureAdJoinLocalAdminsRegisteringUsers',
                'AzureADRegistration',
                'LocalAdminPasswordIsEnabled',
                'LocalAdminsEnableGlobalAdmins',
                'MultiFactorAuthConfiguration',
                'UserDeviceQuota'))
        {
            if (-not $boundParameters.ContainsKey($propertyName))
            {
                $this.$propertyName = $currentInstance[$propertyName]
            }
        }

        $azureADRegistrationAllowedToRegister = '#microsoft.graph.noDeviceRegistrationMembership'
        if ($this.AzureADAllowedToJoin -eq 'All')
        {
            $azureADRegistrationAllowedToRegister = '#microsoft.graph.allDeviceRegistrationMembership'
        }
        elseif ($this.AzureADAllowedToJoin -eq 'Selected')
        {
            $azureADRegistrationAllowedToRegister = '#microsoft.graph.enumeratedDeviceRegistrationMembership'

            $azureADRegistrationAllowedUsers = @()
            foreach ($user in $this.AzureADAllowedToJoinUsers)
            {
                $userInfo = Get-MgUser -UserId $user
                $azureADRegistrationAllowedUsers += $userInfo.Id
            }

            $azureADRegistrationAllowedGroups = @()
            foreach ($group in $this.AzureADAllowedToJoinGroups)
            {
                $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($group -replace "'", "''")'"
                $azureADRegistrationAllowedGroups += $groupInfo.Id
            }
        }

        $azureADRegistrationIsAdminConfigurable = $false
        $azureADRegistrationAllowedToRegisterType = '#microsoft.graph.allDeviceRegistrationMembership'
        $azureADRegistrationAllowedToRegisterUsers = $null
        $azureADRegistrationAllowedToRegisterGroups = $null
        if ($null -ne $this.AzureADRegistration)
        {
            if ($null -ne $this.AzureADRegistration.IsAdminConfigurable)
            {
                $azureADRegistrationIsAdminConfigurable = $this.AzureADRegistration.IsAdminConfigurable
            }

            if (-not [System.String]::IsNullOrEmpty($this.AzureADRegistration.AllowedToRegister.odataType))
            {
                $azureADRegistrationAllowedToRegisterType = $this.AzureADRegistration.AllowedToRegister.odataType
            }

            if ($azureADRegistrationAllowedToRegisterType -eq '#microsoft.graph.enumeratedDeviceRegistrationMembership')
            {
                $azureADRegistrationAllowedToRegisterUsers = @()
                foreach ($user in $this.AzureADRegistration.AllowedToRegister.Users)
                {
                    $userInfo = Get-MgUser -UserId $user
                    $azureADRegistrationAllowedToRegisterUsers += $userInfo.Id
                }

                $azureADRegistrationAllowedToRegisterGroups = @()
                foreach ($group in $this.AzureADRegistration.AllowedToRegister.Groups)
                {
                    $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($group -replace "'", "''")'"
                    $azureADRegistrationAllowedToRegisterGroups += $groupInfo.Id
                }
            }
        }

        $localAdminAllowedMode = '#microsoft.graph.noDeviceRegistrationMembership'
        if ($this.AzureAdJoinLocalAdminsRegisteringMode -eq 'All')
        {
            $localAdminAllowedMode = '#microsoft.graph.allDeviceRegistrationMembership'
        }
        elseif ($this.AzureAdJoinLocalAdminsRegisteringMode -eq 'Selected')
        {
            $localAdminAllowedMode = '#microsoft.graph.enumeratedDeviceRegistrationMembership'

            $localAdminAllowedUsers = @()
            foreach ($user in $this.AzureAdJoinLocalAdminsRegisteringUsers)
            {
                $userInfo = Get-MgUser -UserId $user
                $localAdminAllowedUsers += $userInfo.Id
            }

            $localAdminAllowedGroups = @()
            foreach ($group in $this.AzureAdJoinLocalAdminsRegisteringGroups)
            {
                $groupInfo = Get-MgGroup -Filter "DisplayName eq '$($group -replace "'", "''")'"
                $localAdminAllowedGroups += $groupInfo.Id
            }
        }

        $multiFactorAuthConfigurationValue = $this.MultiFactorAuthConfiguration
        if ([System.String]::IsNullOrEmpty($multiFactorAuthConfigurationValue))
        {
            $multiFactorAuthConfigurationValue = 'notRequired'
        }

        $updateParameters = @{
            userDeviceQuota              = $this.UserDeviceQuota
            multiFactorAuthConfiguration = $multiFactorAuthConfigurationValue
            azureADJoin                  = @{
                isAdminConfigurable = $this.AzureADJoinIsAdminConfigurable
                allowedToJoin       = @{
                    '@odata.type' = $azureADRegistrationAllowedToRegister
                    users         = $azureADRegistrationAllowedUsers
                    groups        = $azureADRegistrationAllowedGroups
                }
                localAdmins         = @{
                    enableGlobalAdmins = $this.LocalAdminsEnableGlobalAdmins
                    registeringUsers   = @{
                        '@odata.type' = $localAdminAllowedMode
                        users         = $localAdminAllowedUsers
                        groups        = $localAdminAllowedGroups
                    }
                }
            }
            localAdminPassword           = @{
                isEnabled = $this.LocalAdminPasswordIsEnabled
            }
            azureADRegistration          = @{
                isAdminConfigurable = $azureADRegistrationIsAdminConfigurable
                allowedToRegister   = @{
                    '@odata.type' = $azureADRegistrationAllowedToRegisterType
                    users         = $azureADRegistrationAllowedToRegisterUsers
                    groups        = $azureADRegistrationAllowedToRegisterGroups
                }
            }
        }
        $uri = '/beta/policies/deviceRegistrationPolicy'
        Write-Verbose -Message "Updating Device Registration Policy with payload:`r`n$(ConvertTo-Json $updateParameters -Depth 10)"
        Invoke-M365DSCGraphRequest -Method PUT -Uri $uri -Body $updateParameters
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $i = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $dscContent = [System.Text.StringBuilder]::new()
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
            $rawResults = $Results.Clone()

            if ($null -ne $Results.AzureADRegistration)
            {
                $complexMapping = @(
                    @{
                        Name            = 'AzureADRegistration'
                        CimInstanceName = 'AzureADRegistrationPolicy'
                        IsRequired      = $False
                    }
                    @{
                        Name            = 'AllowedToRegister'
                        CimInstanceName = 'DeviceRegistrationMembership'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.AzureADRegistration `
                    -CIMInstanceName 'AzureADRegistrationPolicy' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.AzureADRegistration = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AzureADRegistration') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential `
                -RawResults $rawResults `
                -NoEscape @('AzureADRegistration')

            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            $i++
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.ErrorDetails.Message -like '*Insufficient privileges*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Insufficient permissions or license to export Attribute Sets."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    hidden [AADDeviceRegistrationPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADDeviceRegistrationPolicy])
        {
            return $Values
        }

        $result = [AADDeviceRegistrationPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AzureADRegistrationPolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('Determines if Microsoft Entra registered is allowed.')]
    [MSFT_DeviceRegistrationMembership] $AllowedToRegister

    [DscProperty()]
    [System.ComponentModel.Description('Determines if administrators can modify this policy.')]
    [System.Nullable[System.Boolean]] $IsAdminConfigurable
}

class MSFT_DeviceRegistrationMembership
{
    [DscProperty()]
    [System.ComponentModel.Description('List of groups that this policy applies to.')]
    [System.String[]] $Groups

    [DscProperty()]
    [System.ComponentModel.Description('List of users that this policy applies to.')]
    [System.String[]] $Users

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.allDeviceRegistrationMembership', '#microsoft.graph.enumeratedDeviceRegistrationMembership', '#microsoft.graph.noDeviceRegistrationMembership')]
    [System.String] $odataType
}
