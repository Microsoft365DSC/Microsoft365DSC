using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADConditionalAccessPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DisplayName of the AAD CA Policy')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the GUID for the Policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the State of the Policy.')]
    [ValidateSet('disabled', 'enabled', 'enabledForReportingButNotEnforced')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Apps in scope of the Policy.')]
    [System.String[]] $IncludeApplications

    [DscProperty()]
    [System.ComponentModel.Description('Rule syntax is similar to that used for membership rules for groups in Microsoft Entra ID.')]
    [System.String] $ApplicationsFilter

    [DscProperty()]
    [System.ComponentModel.Description('Mode to use for the filter. Possible values are include or exclude.')]
    [ValidateSet('include', 'exclude')]
    [System.String] $ApplicationsFilterMode

    [DscProperty()]
    [System.ComponentModel.Description('Cloud Apps out of scope of the Policy.')]
    [System.String[]] $ExcludeApplications

    [DscProperty()]
    [System.ComponentModel.Description('User Actions in scope of the Policy.')]
    [System.String[]] $IncludeUserActions

    [DscProperty()]
    [System.ComponentModel.Description('Users in scope of the Policy.')]
    [System.String[]] $IncludeUsers

    [DscProperty()]
    [System.ComponentModel.Description('Users out of scope of the Policy.')]
    [System.String[]] $ExcludeUsers

    [DscProperty()]
    [System.ComponentModel.Description('Groups in scope of the Policy.')]
    [System.String[]] $IncludeGroups

    [DscProperty()]
    [System.ComponentModel.Description('Groups out of scope of the Policy.')]
    [System.String[]] $ExcludeGroups

    [DscProperty()]
    [System.ComponentModel.Description('AAD Admin Roles in scope of the Policy.')]
    [System.String[]] $IncludeRoles

    [DscProperty()]
    [System.ComponentModel.Description('AAD Admin Roles out of scope of the Policy.')]
    [System.String[]] $ExcludeRoles

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Included internal guests or external user types. This is a multi-valued property. Supported values are: b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, internalGuest, OtherExternalUser, serviceProvider and unknownFutureValue.')]
    [ValidateSet('none', 'internalGuest', 'b2bCollaborationGuest', 'b2bCollaborationMember', 'b2bDirectConnectUser', 'otherExternalUser', 'serviceProvider', 'unknownFutureValue')]
    [System.String[]] $IncludeGuestOrExternalUserTypes

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Included Tenants membership kind. The possible values are: all, enumerated, unknownFutureValue. enumerated references an object of conditionalAccessEnumeratedExternalTenants derived type.')]
    [ValidateSet('', 'all', 'enumerated', 'unknownFutureValue')]
    [System.String] $IncludeExternalTenantsMembershipKind

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Included collection of tenant ids in the scope of Conditional Access for guests and external users policy targeting.')]
    [System.String[]] $IncludeExternalTenantsMembers

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Excluded internal guests or external user types. This is a multi-valued property. Supported values are: b2bCollaborationGuest, b2bCollaborationMember, b2bDirectConnectUser, internalGuest, OtherExternalUser, serviceProvider and unknownFutureValue.')]
    [ValidateSet('none', 'internalGuest', 'b2bCollaborationGuest', 'b2bCollaborationMember', 'b2bDirectConnectUser', 'otherExternalUser', 'serviceProvider', 'unknownFutureValue')]
    [System.String[]] $ExcludeGuestOrExternalUserTypes

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Excluded Tenants membership kind. The possible values are: all, enumerated, unknownFutureValue. enumerated references an object of conditionalAccessEnumeratedExternalTenants derived type.')]
    [ValidateSet('', 'all', 'enumerated', 'unknownFutureValue')]
    [System.String] $ExcludeExternalTenantsMembershipKind

    [DscProperty()]
    [System.ComponentModel.Description('Represents the Excluded collection of tenant ids in the scope of Conditional Access for guests and external users policy targeting.')]
    [System.String[]] $ExcludeExternalTenantsMembers

    [DscProperty()]
    [System.ComponentModel.Description('Service Principals in scope of the Policy. ''Attribute Definition Reader'' role is needed.')]
    [System.String[]] $IncludeServicePrincipals

    [DscProperty()]
    [System.ComponentModel.Description('Service Principals out of scope of the Policy. ''Attribute Definition Reader'' role is needed.')]
    [System.String[]] $ExcludeServicePrincipals

    [DscProperty()]
    [System.ComponentModel.Description('Mode to use for the Service Principal filter. Possible values are include or exclude. ''Attribute Definition Reader'' role is needed.')]
    [ValidateSet('include', 'exclude')]
    [System.String] $ServicePrincipalFilterMode

    [DscProperty()]
    [System.ComponentModel.Description('Rule syntax for the Service Principal filter. ''Attribute Definition Reader'' role is needed.')]
    [System.String] $ServicePrincipalFilterRule

    [DscProperty()]
    [System.ComponentModel.Description('Client Device Platforms in scope of the Policy.')]
    [System.String[]] $IncludePlatforms

    [DscProperty()]
    [System.ComponentModel.Description('Client Device Platforms out of scope of the Policy.')]
    [System.String[]] $ExcludePlatforms

    [DscProperty()]
    [System.ComponentModel.Description('AAD Named Locations in scope of the Policy.')]
    [System.String[]] $IncludeLocations

    [DscProperty()]
    [System.ComponentModel.Description('AAD Named Locations out of scope of the Policy.')]
    [System.String[]] $ExcludeLocations

    [DscProperty()]
    [System.ComponentModel.Description('Client Device Filter mode of the Policy.')]
    [ValidateSet('include', 'exclude')]
    [System.String] $DeviceFilterMode

    [DscProperty()]
    [System.ComponentModel.Description('Client Device Filter rule of the Policy.')]
    [System.String] $DeviceFilterRule

    [DscProperty()]
    [System.ComponentModel.Description('AAD Identity Protection User Risk Levels in scope of the Policy.')]
    [System.String[]] $UserRiskLevels

    [DscProperty()]
    [System.ComponentModel.Description('AAD Identity Protection Sign-in Risk Levels in scope of the Policy.')]
    [System.String[]] $SignInRiskLevels

    [DscProperty()]
    [System.ComponentModel.Description('Client App types in scope of the Policy.')]
    [System.String[]] $ClientAppTypes

    [DscProperty()]
    [System.ComponentModel.Description('Operator to be used for Grant Controls.')]
    [ValidateSet('AND', 'OR')]
    [System.String] $GrantControlOperator

    [DscProperty()]
    [System.ComponentModel.Description('List of built-in Grant Controls to be applied by the Policy.')]
    [System.String[]] $BuiltInControls

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, whether Application Enforced Restrictions are enabled in the Policy.')]
    [System.Nullable[System.Boolean]] $ApplicationEnforcedRestrictionsIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, whether Cloud App Security is enforced by the Policy.')]
    [System.Nullable[System.Boolean]] $CloudAppSecurityIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, what Cloud App Security control is enforced by the Policy.')]
    [System.String] $CloudAppSecurityType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies continuous access evaluation settings. The possible values are: disabled, strictEnforcement, strictLocation')]
    [ValidateSet('disabled', 'strictEnforcement', 'strictLocation')]
    [System.String] $ContinuousAccessEvaluationMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if token protection for sign-in sessions is to be enforced by the policy.')]
    [System.Nullable[System.Boolean]] $SecureSignInSessionIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Sign in frequency time in the given unit to be enforced by the policy.')]
    [System.Nullable[System.UInt32]] $SignInFrequencyValue

    [DscProperty()]
    [System.ComponentModel.Description('Display names of the terms of use to assign.')]
    [System.String[]] $TermsOfUse

    [DscProperty()]
    [System.ComponentModel.Description('Custom Controls assigned to the grant property of this policy.')]
    [System.String[]] $CustomAuthenticationFactors

    [DscProperty()]
    [System.ComponentModel.Description('Sign in frequency unit (days/hours) to be interpreted by the policy.')]
    [ValidateSet('Days', 'Hours', '')]
    [System.String] $SignInFrequencyType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, whether sign-in frequency is enforced by the Policy.')]
    [System.Nullable[System.Boolean]] $SignInFrequencyIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Sign in frequency interval. Possible values are: ''timeBased'', ''everyTime'' and ''unknownFutureValue''.')]
    [ValidateSet('timeBased', 'everyTime', 'unknownFutureValue')]
    [System.String] $SignInFrequencyInterval

    [DscProperty()]
    [System.ComponentModel.Description('The possible values are primaryAndSecondaryAuthentication, secondaryAuthentication, unknownFutureValue. This property isn''t required when using frequencyInterval with the value of timeBased.')]
    [ValidateSet('primaryAndSecondaryAuthentication', 'secondaryAuthentication')]
    [System.String] $SignInFrequencyAuthenticationType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, whether Browser Persistence is controlled by the Policy.')]
    [System.Nullable[System.Boolean]] $PersistentBrowserIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, what Browser Persistence control is enforced by the Policy.')]
    [ValidateSet('Always', 'Never', '')]
    [System.String] $PersistentBrowserMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies, if DisableResilienceDefaults is enabled.')]
    [System.Nullable[System.Boolean]] $DisableResilienceDefaultsIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Name of the associated authentication strength policy.')]
    [System.String] $AuthenticationStrength

    [DscProperty()]
    [System.ComponentModel.Description('Names of the associated authentication flow transfer methods. Possible values are '''', ''deviceCodeFlow'', ''authenticationTransfer'', or ''deviceCodeFlow,authenticationTransfer''.')]
    [System.String] $TransferMethods

    [DscProperty()]
    [System.ComponentModel.Description('Authentication context class references.')]
    [System.String[]] $AuthenticationContexts

    [DscProperty()]
    [System.ComponentModel.Description('Insider risk levels conditions.')]
    [ValidateSet('minor', 'moderate', 'elevated', 'unknownFutureValue')]
    [System.String[]] $InsiderRiskLevels

    [DscProperty()]
    [System.ComponentModel.Description('Service principal risk levels included in the policy.')]
    [ValidateSet('low', 'medium', 'high', 'none', 'unknownFutureValue', 'hidden')]
    [System.String[]] $ServicePrincipalRiskLevels

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the protocol flows to block.')]
    [System.String[]] $ProtocolFlows

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD CA Policy should exist or not.')]
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

    [AADConditionalAccessPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADConditionalAccessPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Conditional Access Policy for {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                if ($this.GetBoundParameters().ContainsKey('Id') -and -not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message 'PolicyID was specified'
                    try
                    {
                        $Policy = Get-MgBetaIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $this.Id -ErrorAction Stop
                    }
                    catch
                    {
                        Write-Verbose -Message "Couldn't find existing policy by ID {$($this.Id)}"
                        $Policy = Get-MgBetaIdentityConditionalAccessPolicy -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"

                        if ($Policy.Length -gt 1)
                        {
                            throw "Duplicate CA Policies named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                else
                {
                    Write-Verbose -Message 'Id was NOT specified'
                    ## Can retreive multiple CA Policies since displayname is not unique
                    $Policy = Get-MgBetaIdentityConditionalAccessPolicy -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"

                    if ($Policy.Length -gt 1)
                    {
                        throw "Duplicate CA Policies named $($this.DisplayName) exist in tenant"
                    }
                }

                if ([String]::IsNullOrEmpty($Policy.id))
                {
                    Write-Verbose -Message "No existing Policy with name {$($this.DisplayName)} were found"
                    $currentValues = $this.GetBoundParameters()
                    $currentValues.Ensure = 'Absent'
                    return $this.AsResult($currentValues)
                }
            }
            else
            {
                Write-Verbose -Message "Using cached policy {$($this.ExportedInstance.DisplayName)}"
                $Policy = $this.ExportedInstance
            }

            Write-Verbose -Message 'Get(): Found existing Conditional Access policy'
            $PolicyDisplayName = $Policy.DisplayName

            Write-Verbose -Message 'Get(): Process IncludeUsers'
            #translate IncludeUser GUIDs to UPN, except id value is GuestsOrExternalUsers, None or All
            $includeUsersValue = @()
            if ($Policy.Conditions.Users.IncludeUsers)
            {
                foreach ($IncludeUserGUID in $Policy.Conditions.Users.IncludeUsers)
                {
                    if ($IncludeUserGUID -notin 'GuestsOrExternalUsers', 'All', 'None')
                    {
                        $IncludeUser = $null
                        try
                        {
                            $IncludeUser = (Get-MgUser -UserId $IncludeUserGUID -ErrorAction Stop).userprincipalname
                        }
                        catch
                        {
                            Write-Warning -Message "Couldn't find IncludedUser '$IncludeUserGUID', that is defined in policy '$PolicyDisplayName'. Skipping user."
                            continue
                        }
                        if ($IncludeUser)
                        {
                            $includeUsersValue += $IncludeUser
                        }
                    }
                    else
                    {
                        $includeUsersValue += $IncludeUserGUID
                    }
                }
            }

            Write-Verbose -Message 'Get(): Process ExcludeUsers'
            #translate ExcludeUser GUIDs to UPN, except id value is GuestsOrExternalUsers, None or All
            $excludeUsersValue = @()
            if ($Policy.Conditions.Users.ExcludeUsers)
            {
                foreach ($ExcludedUser in $Policy.Conditions.Users.ExcludeUsers)
                {
                    if ($ExcludedUser -notin 'GuestsOrExternalUsers', 'All', 'None')
                    {
                        $ExcludeUser = $null
                        try
                        {
                            $ExcludeUser = (Get-MgUser -UserId $ExcludedUser -ErrorAction Stop).UserPrincipalName
                        }
                        catch
                        {
                            Write-Warning -Message "Couldn't find ExcludedUser '$ExcludedUser', that is defined in policy '$PolicyDisplayName'. Skipping user."
                            continue
                        }
                        if ($ExcludeUser)
                        {
                            $excludeUsersValue += $ExcludeUser
                        }
                    }
                    else
                    {
                        $excludeUsersValue += $ExcludedUser
                    }
                }
            }

            Write-Verbose -Message 'Get(): Process IncludeGroups'
            #translate IncludeGroup GUIDs to DisplayName
            $includeGroupsValue = @()
            if ($Policy.Conditions.Users.IncludeGroups)
            {
                foreach ($IncludeGroupGUID in $Policy.Conditions.Users.IncludeGroups)
                {
                    $IncludeGroup = $null
                    try
                    {
                        $IncludeGroup = (Get-MgGroup -GroupId $IncludeGroupGUID -ErrorAction Stop).displayname
                    }
                    catch
                    {
                        Write-Warning -Message "Couldn't find IncludedGroup '$IncludeGroupGUID', that is defined in policy '$PolicyDisplayName'. Skipping group."
                        continue
                    }
                    if ($IncludeGroup)
                    {
                        $includeGroupsValue += $IncludeGroup
                    }
                }
            }

            Write-Verbose -Message 'Get(): Process ExcludeGroups'
            #translate ExcludeGroup GUIDs to DisplayName
            $excludeGroupsValue = @()
            if ($Policy.Conditions.Users.ExcludeGroups)
            {
                foreach ($ExcludeGroupGUID in $Policy.Conditions.Users.ExcludeGroups)
                {
                    $ExcludeGroup = $null
                    try
                    {
                        $ExcludeGroup = (Get-MgGroup -GroupId $ExcludeGroupGUID -ErrorAction Stop).displayname
                    }
                    catch
                    {
                        Write-Warning -Message "Couldn't find ExcludedGroup '$ExcludeGroupGUID', that is defined in policy '$PolicyDisplayName'. Skipping group."
                        continue
                    }
                    if ($ExcludeGroup)
                    {
                        $excludeGroupsValue += $ExcludeGroup
                    }
                }
            }

            $includeRolesValue = @()
            $excludeRolesValue = @()
            #translate role template guids to role name
            if ($Policy.Conditions.Users.IncludeRoles -or $Policy.Conditions.Users.ExcludeRoles)
            {
                Write-Verbose -Message 'Get(): Role condition defined, processing'
                #build role translation table
                $rolelookup = @{}
                foreach ($role in Get-MgDirectoryRoleTemplate -All)
                {
                    $rolelookup[$role.Id] = $role.DisplayName
                }

                Write-Verbose -Message 'Get(): Processing IncludeRoles'
                if ($Policy.Conditions.Users.IncludeRoles)
                {
                    foreach ($IncludeRoleGUID in $Policy.Conditions.Users.IncludeRoles)
                    {
                        if ($null -eq $rolelookup[$IncludeRoleGUID])
                        {
                            Write-Warning -Message "Couldn't find IncludedRole '$IncludeRoleGUID', that is defined in policy '$PolicyDisplayName'. Skipping role."
                        }
                        else
                        {
                            $includeRolesValue += $rolelookup[$IncludeRoleGUID]
                        }
                    }
                }

                Write-Verbose -Message 'Get(): Processing ExcludeRoles'
                if ($Policy.Conditions.Users.ExcludeRoles)
                {
                    foreach ($ExcludeRoleGUID in $Policy.Conditions.Users.ExcludeRoles)
                    {
                        if ($null -eq $rolelookup[$ExcludeRoleGUID])
                        {
                            Write-Warning -Message "Couldn't find ExcludedRole '$ExcludeRoleGUID', that is defined in policy '$PolicyDisplayName'. Skipping role."
                        }
                        else
                        {
                            $excludeRolesValue += $rolelookup[$ExcludeRoleGUID]
                        }
                    }
                }
            }

            $includeLocationsValue = @()
            $excludeLocationsValue = @()
            #translate Location template guids to Location name
            if ($Policy.Conditions.Locations)
            {
                Write-Verbose -Message 'Get(): Location condition defined, processing'
                #build Location translation table
                $Locationlookup = @{}
                foreach ($Location in Get-MgBetaIdentityConditionalAccessNamedLocation)
                {
                    $Locationlookup[$Location.Id] = $Location.DisplayName
                }

                Write-Verbose -Message 'Get(): Processing IncludeLocations'
                if ($Policy.Conditions.Locations.IncludeLocations)
                {
                    foreach ($IncludeLocationGUID in $Policy.Conditions.Locations.IncludeLocations)
                    {
                        if ($IncludeLocationGUID -in 'All', 'AllTrusted')
                        {
                            $includeLocationsValue += $IncludeLocationGUID
                        }
                        elseif ($IncludeLocationGUID -eq '00000000-0000-0000-0000-000000000000')
                        {
                            $includeLocationsValue += 'Multifactor authentication trusted IPs'
                        }
                        elseif ($null -eq $Locationlookup[$IncludeLocationGUID])
                        {
                            Write-Warning -Message "Couldn't find Location $IncludeLocationGUID , couldn't add to policy $PolicyDisplayName"
                        }
                        else
                        {
                            $includeLocationsValue += $Locationlookup[$IncludeLocationGUID]
                        }
                    }
                }

                Write-Verbose -Message 'Get(): Processing ExcludeLocations'
                if ($Policy.Conditions.Locations.ExcludeLocations)
                {
                    foreach ($ExcludeLocationGUID in $Policy.Conditions.Locations.ExcludeLocations)
                    {
                        if ($ExcludeLocationGUID -in 'All', 'AllTrusted')
                        {
                            $excludeLocationsValue += $ExcludeLocationGUID
                        }
                        elseif ($ExcludeLocationGUID -eq '00000000-0000-0000-0000-000000000000')
                        {
                            $excludeLocationsValue += 'Multifactor authentication trusted IPs'
                        }
                        elseif ($null -eq $Locationlookup[$ExcludeLocationGUID])
                        {
                            Write-Warning -Message "Couldn't find Location $ExcludeLocationGUID , couldn't add to policy $PolicyDisplayName"
                        }
                        else
                        {
                            $excludeLocationsValue += $Locationlookup[$ExcludeLocationGUID]
                        }
                    }
                }
            }
            $cloudAppSecurityTypeValue = $null
            if ($Policy.SessionControls.CloudAppSecurity.IsEnabled)
            {
                $cloudAppSecurityTypeValue = [System.String]$Policy.SessionControls.CloudAppSecurity.CloudAppSecurityType
            }
            $ContinuousAccessEvaluationModeValue = $null
            if ($Policy.SessionControls.ContinuousAccessEvaluation.Mode)
            {
                $ContinuousAccessEvaluationModeValue = [System.String]$Policy.SessionControls.ContinuousAccessEvaluation.Mode
            }
            if ($Policy.SessionControls.SignInFrequency.IsEnabled)
            {
                $signInFrequencyTypeValue = [System.String]$Policy.SessionControls.SignInFrequency.Type
                $SignInFrequencyIntervalValue = [System.String]$Policy.SessionControls.SignInFrequency.FrequencyInterval
                $signInFrequencyAuthenticationTypeValue = [System.String]$Policy.SessionControls.SignInFrequency.AuthenticationType
            }
            else
            {
                $signInFrequencyTypeValue = $null
                $SignInFrequencyIntervalValue = $null
                $signInFrequencyAuthenticationTypeValue = $null
            }
            $persistentBrowserModeValue = $null
            if ($Policy.SessionControls.PersistentBrowser.IsEnabled)
            {
                $persistentBrowserModeValue = [System.String]$Policy.SessionControls.PersistentBrowser.Mode
            }
            $includeGuestOrExternalUserTypesValue = $null
            if ($Policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes)
            {
                [Array]$includeGuestOrExternalUserTypesValue = ($Policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes).Split(',')
            }
            $excludeGuestOrExternalUserTypesValue = $null
            if ($Policy.Conditions.Users.ExcludeGuestsOrExternalUsers.GuestOrExternalUserTypes)
            {
                [Array]$excludeGuestOrExternalUserTypesValue = ($Policy.Conditions.Users.ExcludeGuestsOrExternalUsers.GuestOrExternalUserTypes).Split(',')
            }

            $termsOfUseNames = @()
            if ($Policy.GrantControls.TermsOfUse)
            {
                $agreements = Get-MgBetaAgreement
                foreach ($termsOfUseId in $Policy.GrantControls.TermsOfUse)
                {
                    $agreement = $agreements | Where-Object -FilterScript { $_.Id -eq $termsOfUseId }
                    if ($null -eq $agreement)
                    {
                        Write-Warning -Message "Couldn't find Terms of Use '$termsOfUseId', that is defined in policy '$PolicyDisplayName'. Skipping terms of use."
                    }
                    else
                    {
                        $termsOfUseNames += $agreement.DisplayName
                    }
                }
            }

            $AuthenticationStrengthValue = $null
            if ($null -ne $Policy.GrantControls -and $null -ne $Policy.GrantControls.AuthenticationStrength -and `
                    $null -ne $Policy.GrantControls.AuthenticationStrength.Id)
            {
                $strengthPolicy = Get-MgBetaPolicyAuthenticationStrengthPolicy -AuthenticationStrengthPolicyId $Policy.GrantControls.AuthenticationStrength.Id
                if ($null -ne $strengthPolicy)
                {
                    $AuthenticationStrengthValue = $strengthPolicy.DisplayName
                }
            }

            $AuthenticationContextsValues = @()
            if ($null -ne $Policy.Conditions.Applications.IncludeAuthenticationContextClassReferences)
            {
                foreach ($class in $Policy.Conditions.Applications.IncludeAuthenticationContextClassReferences)
                {
                    $classReference = Get-MgBetaIdentityConditionalAccessAuthenticationContextClassReference `
                        -AuthenticationContextClassReferenceId $class `
                        -ErrorAction SilentlyContinue
                    if ($null -ne $classReference)
                    {
                        $AuthenticationContextsValues += $classReference.DisplayName
                    }
                }
            }

            $InsiderRiskLevelsValue = $null
            if (-not [System.String]::IsNullOrEmpty($Policy.Conditions.InsiderRiskLevels))
            {
                $InsiderRiskLevelsValue = $Policy.Conditions.InsiderRiskLevels.Split(',')
            }

            $ProtocolFlowsValue = @()
            if ($null -ne $Policy.Conditions.AuthenticationFlows.protocolFlows)
            {
                $ProtocolFlowsValue = $Policy.Conditions.AuthenticationFlows.protocolFlows.Split(',')
            }

            $DisableResilienceDefaultsIsEnabledValue = $false
            if (-not [System.String]::IsNullOrEmpty($Policy.SessionControls.disableResilienceDefaults))
            {
                $DisableResilienceDefaultsIsEnabledValue = [Boolean]::Parse($Policy.SessionControls.disableResilienceDefaults)
            }

            $includeApplicationsValue = @()
            if ($Policy.Conditions.Applications.IncludeApplications)
            {
                foreach ($app in $Policy.Conditions.Applications.IncludeApplications)
                {
                    # Only resolve to display name if the app is a GUID and not already in the list of included applications
                    # to prevent drifts during Test()
                    if ([System.Guid]::TryParse($app, [ref][System.Guid]::Empty) -and $this.IncludeApplications -notcontains $app)
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $includeApplicationsValue += $appInfo.DisplayName
                        }
                        else
                        {
                            Write-Warning -Message "Couldn't find IncludedApplication '$app', that is defined in policy '$PolicyDisplayName'. Skipping application."
                        }
                    }
                    else
                    {
                        $includeApplicationsValue += $app
                    }
                }
            }

            $excludeApplicationsValue = @()
            if ($Policy.Conditions.Applications.ExcludeApplications)
            {
                foreach ($app in $Policy.Conditions.Applications.ExcludeApplications)
                {
                    # Only resolve to display name if the app is a GUID and not already in the list of excluded applications
                    # to prevent drifts during Test()
                    if ([System.Guid]::TryParse($app, [ref][System.Guid]::Empty) -and $this.ExcludeApplications -notcontains $app)
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $excludeApplicationsValue += $appInfo.DisplayName
                        }
                        else
                        {
                            Write-Warning -Message "Couldn't find ExcludedApplication '$app', that is defined in policy '$PolicyDisplayName'. Skipping application."
                        }
                    }
                    else
                    {
                        $excludeApplicationsValue += $app
                    }
                }
            }

            $result = @{
                DisplayName                              = $Policy.DisplayName
                Id                                       = $Policy.Id
                State                                    = $Policy.State
                IncludeApplications                      = [System.String[]]$includeApplicationsValue
                #no translation of Application GUIDs, return empty string array if undefined
                ExcludeApplications                      = [System.String[]]$excludeApplicationsValue
                ApplicationsFilter                       = $Policy.Conditions.Applications.ApplicationFilter.Rule
                ApplicationsFilterMode                   = $Policy.Conditions.Applications.ApplicationFilter.Mode
                #no translation of GUIDs, return empty string array if undefined
                IncludeUserActions                       = [System.String[]]($Policy.Conditions.Applications.IncludeUserActions)
                #no translation needed, return empty string array if undefined
                IncludeUsers                             = $includeUsersValue
                ExcludeUsers                             = $excludeUsersValue
                IncludeGroups                            = $includeGroupsValue
                ExcludeGroups                            = $excludeGroupsValue
                IncludeRoles                             = $includeRolesValue
                ExcludeRoles                             = $excludeRolesValue
                IncludeGuestOrExternalUserTypes          = [System.String[]]$includeGuestOrExternalUserTypesValue
                IncludeExternalTenantsMembershipKind     = [System.String]$Policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.MembershipKind
                IncludeExternalTenantsMembers            = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.members -ElementType ([System.String])

                ExcludeGuestOrExternalUserTypes          = [System.String[]]$excludeGuestOrExternalUserTypesValue
                ExcludeExternalTenantsMembershipKind     = [System.String]$Policy.Conditions.Users.ExcludeGuestsOrExternalUsers.ExternalTenants.MembershipKind
                ExcludeExternalTenantsMembers            = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.Users.ExcludeGuestsOrExternalUsers.ExternalTenants.members -ElementType ([System.String])

                IncludeServicePrincipals                 = $Policy.Conditions.ClientApplications.IncludeServicePrincipals
                ExcludeServicePrincipals                 = $Policy.Conditions.ClientApplications.ExcludeServicePrincipals
                ServicePrincipalFilterMode               = $Policy.Conditions.ClientApplications.ServicePrincipalFilter.Mode
                ServicePrincipalFilterRule               = $Policy.Conditions.ClientApplications.ServicePrincipalFilter.Rule

                IncludePlatforms                         = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.Platforms.IncludePlatforms -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                ExcludePlatforms                         = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.Platforms.ExcludePlatforms -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                IncludeLocations                         = $includeLocationsValue
                ExcludeLocations                         = $excludeLocationsValue

                #no translation needed, return empty string array if undefined
                DeviceFilterMode                         = [System.String]$Policy.Conditions.Devices.DeviceFilter.Mode
                #no translation or conversion needed
                DeviceFilterRule                         = [System.String]$Policy.Conditions.Devices.DeviceFilter.Rule
                #no translation or conversion needed
                UserRiskLevels                           = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.UserRiskLevels -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                SignInRiskLevels                         = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.SignInRiskLevels -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                ClientAppTypes                           = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.ClientAppTypes -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                GrantControlOperator                     = $Policy.GrantControls.Operator
                #no translation or conversion needed
                BuiltInControls                          = Get-M365DSCArrayFromProperty -PropertyValue $Policy.GrantControls.BuiltInControls -ElementType ([System.String])
                CustomAuthenticationFactors              = Get-M365DSCArrayFromProperty -PropertyValue $Policy.GrantControls.CustomAuthenticationFactors -ElementType ([System.String])
                #no translation needed, return empty string array if undefined
                ApplicationEnforcedRestrictionsIsEnabled = $false -or $Policy.SessionControls.ApplicationEnforcedRestrictions.IsEnabled
                #make false if undefined, true if true
                CloudAppSecurityIsEnabled                = $false -or $Policy.SessionControls.CloudAppSecurity.IsEnabled
                #make false if undefined, true if true
                CloudAppSecurityType                     = [System.String]$cloudAppSecurityTypeValue
                ContinuousAccessEvaluationMode           = $ContinuousAccessEvaluationModeValue
                SecureSignInSessionIsEnabled             = $false -or $Policy.SessionControls.SecureSignInSession.IsEnabled
                #no translation needed, return empty string array if undefined
                SignInFrequencyIsEnabled                 = $false -or $Policy.SessionControls.SignInFrequency.IsEnabled
                #make false if undefined, true if true
                SignInFrequencyValue                     = $Policy.SessionControls.SignInFrequency.Value
                #no translation or conversion needed, $null returned if undefined
                SignInFrequencyType                      = [System.String]$signInFrequencyTypeValue
                SignInFrequencyInterval                  = $SignInFrequencyIntervalValue
                SignInFrequencyAuthenticationType        = $signInFrequencyAuthenticationTypeValue
                #no translation needed
                PersistentBrowserIsEnabled               = $false -or $Policy.SessionControls.PersistentBrowser.IsEnabled
                #no translation needed
                DisableResilienceDefaultsIsEnabled       = $DisableResilienceDefaultsIsEnabledValue
                #make false if undefined, true if true
                PersistentBrowserMode                    = [System.String]$persistentBrowserModeValue
                #no translation needed
                AuthenticationStrength                   = $AuthenticationStrengthValue
                AuthenticationContexts                   = $AuthenticationContextsValues
                TransferMethods                          = [System.String]$Policy.Conditions.AuthenticationFlows.TransferMethods
                ProtocolFlows                            = $ProtocolFlowsValue
                #no translation needed, return empty string array if undefined
                ServicePrincipalRiskLevels               = Get-M365DSCArrayFromProperty -PropertyValue $Policy.Conditions.ServicePrincipalRiskLevels -ElementType ([System.String])
                #Standard part
                TermsOfUse                               = [System.String[]]$termsOfUseNames
                InsiderRiskLevels                        = $InsiderRiskLevelsValue
                Ensure                                   = 'Present'
                Credential                               = $this.Credential
                ApplicationSecret                        = $this.ApplicationSecret
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePath                          = $this.CertificatePath
                CertificatePassword                      = $this.CertificatePassword
                ManagedIdentity                          = $this.ManagedIdentity
                AccessTokens                             = $this.AccessTokens
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
        $NewParameters = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of AzureAD Conditional Access Policy for {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentPolicy = $this.Get().ToHashtable()
        $currentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present')#create policy attribute objects
        {
            Write-Verbose -Message "Set(): Policy $($this.Displayname) Ensure Present"
            $NewParameters = @{}
            $NewParameters.Add('displayName', $this.DisplayName)
            if (-not [system.string]::IsNullOrEmpty($this.State))
            {
                $NewParameters.Add('state', $this.State)
            }
            #create Conditions object
            $conditions = @{}
            #create and provision Application Condition object
            Write-Verbose -Message 'Set(): create Application Condition object'
            if ($currentParameters.ContainsKey('IncludeApplications'))
            {
                $conditions.Add('applications', @{})
                $IncludeApplicationsValue = @()
                foreach ($app in $this.IncludeApplications)
                {
                    if ($app -in @('All', 'AllAgentIdResources', 'MicrosoftAdminPortals', 'Office365'))
                    {
                        $IncludeApplicationsValue += $app
                        continue
                    }

                    if ([System.Guid]::TryParse($app, [ref][System.Guid]::Empty))
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $IncludeApplicationsValue += $app
                        }
                        else
                        {
                            throw "Couldn't find IncludedApplication '$app' for conditional access policy '$($this.DisplayName)'."
                        }
                    }
                    else
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "DisplayName eq '$($app -replace "'", "''")'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $IncludeApplicationsValue += $appInfo.AppId
                        }
                        else
                        {
                            throw "Couldn't find IncludedApplication '$app' for conditional access policy '$($this.DisplayName)'."
                        }
                    }
                }

                $conditions.Applications.Add('includeApplications', $IncludeApplicationsValue)
            }
            if ($currentParameters.ContainsKey('ExcludeApplications'))
            {
                if (-not $conditions.ContainsKey('applications'))
                {
                    $conditions.Add('applications', @{})
                }
                $ExcludeApplicationsValue = @()
                foreach ($app in $this.ExcludeApplications)
                {
                    if ($app -in @('AllAgentIdResources', 'MicrosoftAdminPortals', 'Office365'))
                    {
                        $ExcludeApplicationsValue += $app
                        continue
                    }

                    if ([System.Guid]::TryParse($app, [ref][System.Guid]::Empty))
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "AppId eq '$app'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $ExcludeApplicationsValue += $app
                        }
                        else
                        {
                            throw "Couldn't find ExcludedApplication '$app' for conditional access policy '$($this.DisplayName)'."
                        }
                    }
                    else
                    {
                        $appInfo = Get-MgServicePrincipal -Filter "DisplayName eq '$($app -replace "'", "''")'" -ErrorAction SilentlyContinue
                        if ($null -ne $appInfo)
                        {
                            $ExcludeApplicationsValue += $appInfo.AppId
                        }
                        else
                        {
                            throw "Couldn't find ExcludedApplication '$app' for conditional access policy '$($this.DisplayName)'."
                        }
                    }
                }
                $conditions.Applications.Add('excludeApplications', $ExcludeApplicationsValue)
            }
            if ($this.ApplicationsFilter -and $this.ApplicationsFilterMode)
            {
                if (-not $conditions.ContainsKey('applications'))
                {
                    $conditions.Add('applications', @{})
                }
                $appFilterValue = @{
                    rule = $this.ApplicationsFilter
                    mode = $this.ApplicationsFilterMode
                }
                $conditions.Applications.Add('applicationFilter', $appFilterValue)
            }
            if ($this.IncludeUserActions)
            {
                if (-not $conditions.ContainsKey('applications'))
                {
                    $conditions.Add('applications', @{})
                }
                $conditions.Applications.Add('includeUserActions', $this.IncludeUserActions)
            }
            if ($this.AuthenticationContexts)
            {
                if (-not $conditions.ContainsKey('applications'))
                {
                    $conditions.Add('applications', @{})
                }
                # Retrieve the class reference based on display name.
                $AuthenticationContextsValues = @()
                $classReferences = Get-MgBetaIdentityConditionalAccessAuthenticationContextClassReference -ErrorAction SilentlyContinue
                foreach ($authContext in $this.AuthenticationContexts)
                {
                    $currentClassId = $classReferences | Where-Object -FilterScript { $_.DisplayName -eq $authContext }
                    if ($null -ne $currentClassId)
                    {
                        $AuthenticationContextsValues += $currentClassId.Id
                    }
                }
                $conditions.Applications.Add('includeAuthenticationContextClassReferences', $AuthenticationContextsValues)
            }

            #create and provision User Condition object
            Write-Verbose -Message 'Set(): process includeusers'
            if ($currentParameters.ContainsKey('IncludeUsers'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.Users.Add('includeUsers', @())
                foreach ($includeuser in $this.IncludeUsers)
                {
                    #translate user UPNs to GUID, except id value is GuestsOrExternalUsers, None or All
                    if ($includeuser)
                    {
                        if ($includeuser -notin 'GuestsOrExternalUsers', 'All', 'None')
                        {
                            $userguid = (Get-MgUser -UserId $includeuser -ErrorAction Stop).Id
                            $conditions.users.includeUsers += $userguid
                        }
                        else
                        {
                            $conditions.users.includeUsers += $includeuser
                        }
                    }
                }
            }

            Write-Verbose -Message 'Set(): process excludeusers'
            if ($currentParameters.ContainsKey('ExcludeUsers'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.users.Add('excludeUsers', @())
                foreach ($excludeuser in $this.ExcludeUsers)
                {
                    #translate user UPNs to GUID, except id value is GuestsOrExternalUsers, None or All
                    if ($excludeuser)
                    {
                        if ($excludeuser -notin 'GuestsOrExternalUsers', 'All', 'None')
                        {
                            $userguid = (Get-MgUser -UserId $excludeuser -ErrorAction Stop).Id
                            $conditions.users.excludeUsers += $userguid
                        }
                        else
                        {
                            $conditions.users.excludeUsers += $excludeuser
                        }
                    }
                }
            }

            Write-Verbose -Message 'Set(): process includegroups'
            if ($currentParameters.ContainsKey('IncludeGroups'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.users.Add('includeGroups', @())
                foreach ($includegroup in $this.IncludeGroups)
                {
                    #translate user Group names to GUID
                    if ($includegroup)
                    {
                        [array]$groupLookup = Get-MgGroup -Filter "DisplayName eq '$($includegroup -replace "'", "''")'" -ErrorAction Stop

                        if ($groupLookup.Count -gt 1)
                        {
                            throw "More than one group found with displayname '$includegroup', couldn't add to policy '$($this.DisplayName)'"
                        }
                        elseif ($null -eq $groupLookup)
                        {
                            throw "Couldn't find group '$includegroup', couldn't add to policy '$($this.DisplayName)'"
                        }

                        Write-Verbose -Message 'Adding group to includegroups'
                        $conditions.Users.IncludeGroups += $GroupLookup.Id
                    }
                }
            }

            Write-Verbose -Message 'Set(): process excludegroups'
            if ($currentParameters.ContainsKey('ExcludeGroups'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.users.Add('excludeGroups', @())
                foreach ($ExcludeGroup in $this.ExcludeGroups)
                {
                    #translate user Group names to GUID
                    if ($ExcludeGroup)
                    {
                        [array]$groupLookup = Get-MgGroup -Filter "DisplayName eq '$($ExcludeGroup -replace "'", "''")'" -ErrorAction Stop

                        if ($groupLookup.Count -gt 1)
                        {
                            throw "More than one group found with displayname '$ExcludeGroup', couldn't add to policy '$($this.DisplayName)'"
                        }
                        elseif ($null -eq $GroupLookup)
                        {
                            throw "Couldn't find group '$ExcludeGroup', couldn't add to policy '$($this.DisplayName)'"
                        }

                        Write-Verbose -Message 'Adding group to ExcludeGroups'
                        $conditions.users.excludeGroups += $GroupLookup.Id
                    }
                }
            }

            Write-Verbose -Message 'Set(): process includeroles'
            if ($currentParameters.ContainsKey('IncludeRoles'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.Users.Add('includeRoles', @())
                if ($this.IncludeRoles)
                {
                    #translate role names to template guid if defined
                    $rolelookup = @{}
                    foreach ($role in Get-MgDirectoryRoleTemplate -All)
                    {
                        $rolelookup[$role.DisplayName] = $role.Id
                    }
                    foreach ($IncludeRole in $this.IncludeRoles)
                    {
                        if ($IncludeRole)
                        {
                            if ($null -eq $rolelookup[$IncludeRole])
                            {
                                throw "Couldn't find role '$IncludeRole', couldn't add to policy '$($this.DisplayName)'"
                            }
                            else
                            {
                                $conditions.users.includeRoles += $rolelookup[$IncludeRole]
                            }
                        }
                    }
                }
            }

            Write-Verbose -Message 'Set(): process excluderoles'
            if ($currentParameters.ContainsKey('ExcludeRoles'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $conditions.users.Add('excludeRoles', @())
                if ($this.ExcludeRoles)
                {
                    #translate role names to template guid if defined
                    $rolelookup = @{}
                    foreach ($role in Get-MgDirectoryRoleTemplate -All)
                    {
                        $rolelookup[$role.DisplayName] = $role.Id
                    }
                    foreach ($ExcludeRole in $this.ExcludeRoles)
                    {
                        if ($ExcludeRole)
                        {
                            if ($null -eq $rolelookup[$ExcludeRole])
                            {
                                throw "Couldn't find role '$ExcludeRole', couldn't add to policy '$($this.DisplayName)'"
                            }
                            else
                            {
                                $conditions.users.excludeRoles += $rolelookup[$ExcludeRole]
                            }
                        }
                    }
                }
            }

            Write-Verbose -Message 'Set(): process includeGuestOrExternalUser'
            if ($currentParameters.ContainsKey('IncludeGuestOrExternalUserTypes'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $includeGuestsOrExternalUsers = $null
                if ($this.IncludeGuestOrExternalUserTypes.Count -ne 0)
                {
                    if ($this.IncludeGuestOrExternalUserTypes -ne 'None')
                    {
                        $includeGuestsOrExternalUsers = @{}
                        $includeGuestOrExternalUserTypesValue = $this.IncludeGuestOrExternalUserTypes -join ','
                        $includeGuestsOrExternalUsers.Add('guestOrExternalUserTypes', $includeGuestOrExternalUserTypesValue)
                        $externalTenants = @{}
                        if ($this.IncludeExternalTenantsMembershipKind -eq 'All')
                        {
                            $externalTenants.Add('@odata.type', '#microsoft.graph.conditionalAccessAllExternalTenants')
                        }
                        elseif ($this.IncludeExternalTenantsMembershipKind -eq 'enumerated')
                        {
                            $externalTenants.Add('@odata.type', '#microsoft.graph.conditionalAccessEnumeratedExternalTenants')
                        }
                        $externalTenants.Add('membershipKind', $this.IncludeExternalTenantsMembershipKind)
                        if ($this.IncludeExternalTenantsMembers)
                        {
                            $externalTenants.Add('members', $this.IncludeExternalTenantsMembers)
                        }
                        $includeGuestsOrExternalUsers.Add('externalTenants', $externalTenants)
                    }
                }
                $conditions.Users.Add('includeGuestsOrExternalUsers', $includeGuestsOrExternalUsers)
            }

            Write-Verbose -Message 'Set(): process excludeGuestsOrExternalUsers'
            if ($currentParameters.ContainsKey('ExcludeGuestOrExternalUserTypes'))
            {
                if (-not $conditions.ContainsKey('users'))
                {
                    $conditions.Add('users', @{})
                }
                $excludeGuestsOrExternalUsers = $null
                if ($this.ExcludeGuestOrExternalUserTypes.Count -ne 0)
                {
                    if ($this.ExcludeGuestOrExternalUserTypes -ne 'None')
                    {
                        $excludeGuestsOrExternalUsers = @{}
                        $excludeGuestOrExternalUserTypesValue = $this.ExcludeGuestOrExternalUserTypes -join ','
                        $excludeGuestsOrExternalUsers.Add('guestOrExternalUserTypes', $excludeGuestOrExternalUserTypesValue)
                        $externalTenants = @{}
                        $excludeMembershipKind = $this.ExcludeExternalTenantsMembershipKind
                        if ([System.String]::IsNullOrEmpty($excludeMembershipKind))
                        {
                            $excludeMembershipKind = 'All'
                        }
                        if ($excludeMembershipKind -eq 'All')
                        {
                            $externalTenants.Add('@odata.type', '#microsoft.graph.conditionalAccessAllExternalTenants')
                            if ($this.GetBoundParameters().ContainsKey('ExcludeExternalTenantsMembers') -and $this.ExcludeExternalTenantsMembers.Count -gt 0)
                            {
                                throw "Set(): ExcludeExternalTenantsMembers is defined, but ExcludeExternalTenantsMembershipKind is 'All'. Please set ExcludeExternalTenantsMembershipKind to 'enumerated' to use ExcludeExternalTenantsMembers."
                            }
                        }
                        elseif ($excludeMembershipKind -eq 'enumerated')
                        {
                            $externalTenants.Add('@odata.type', '#microsoft.graph.conditionalAccessEnumeratedExternalTenants')
                        }
                        $externalTenants.Add('membershipKind', $excludeMembershipKind)
                        if ($this.ExcludeExternalTenantsMembers)
                        {
                            $externalTenants.Add('members', $this.ExcludeExternalTenantsMembers)
                        }
                        $excludeGuestsOrExternalUsers.Add('externalTenants', $externalTenants)
                    }
                }
                $conditions.Users.Add('excludeGuestsOrExternalUsers', $excludeGuestsOrExternalUsers)
            }

            Write-Verbose -Message 'Set(): process includeServicePrincipals'
            if ($currentParameters.ContainsKey('IncludeServicePrincipals'))
            {
                if (-not $conditions.ContainsKey('clientApplications'))
                {
                    $conditions.Add('clientApplications', @{})
                }
                $conditions.clientApplications.Add('includeServicePrincipals', $this.IncludeServicePrincipals)
            }

            Write-Verbose -Message 'Set(): process excludeServicePrincipals'
            if ($currentParameters.ContainsKey('ExcludeServicePrincipals'))
            {
                if (-not $conditions.ContainsKey('clientApplications'))
                {
                    $conditions.Add('clientApplications', @{})
                }
                $conditions.clientApplications.Add('excludeServicePrincipals', $this.ExcludeServicePrincipals)
            }

            Write-Verbose -Message 'Set(): process servicePrincipalFilter'
            if ($currentParameters.ContainsKey('ServicePrincipalFilterMode') -and $currentParameters.ContainsKey('ServicePrincipalFilterRule'))
            {
                $attributeMatches = [regex]::Matches($this.ServicePrincipalFilterRule, 'CustomSecurityAttribute\.(\w+)')
                $referencedAttributes = $attributeMatches | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique

                $missingAttributes = @()
                if ($referencedAttributes.Count -gt 0) {
                    try {
                        $customAttributeDefinitions = Get-MgDirectoryCustomSecurityAttributeDefinition -All
                        $missingAttributes = $referencedAttributes | Where-Object { $_ -notin $customAttributeDefinitions.id }
                    }
                    catch {
                        $message = "Failed to retrieve custom security attribute definitions: $_"
                        Write-Verbose -Message $message
                        $this.LogError($_, $message)
                        throw $message
                    }
                }

                if ($missingAttributes.Count -gt 0) {
                    $message = "Couldn't find custom attribute(s) '$($missingAttributes -join "', '")' in the tenant. Filter not applied to policy '$($this.DisplayName)'."
                    Write-Verbose -Message $message
                    $this.LogError($_, $message)
                    throw $message
                }
                else {
                    # Only reachable when ALL referenced attributes are validated
                    if (-not $conditions.ContainsKey('clientApplications')) {
                        $conditions.Add('clientApplications', @{})
                    }
                    $conditions.clientApplications.Add('servicePrincipalFilter', @{})
                    $conditions.clientApplications.servicePrincipalFilter.Add('mode', $this.ServicePrincipalFilterMode)
                    $conditions.clientApplications.servicePrincipalFilter.Add('rule', $this.ServicePrincipalFilterRule)
                }
            }

            Write-Verbose -Message 'Set(): process platform condition'
            if ($currentParameters.ContainsKey('IncludePlatforms') -or $currentParameters.ContainsKey('ExcludePlatforms'))
            {
                if ($this.IncludePlatforms -or $this.ExcludePlatforms)
                {
                    #create and provision Platform condition object if used
                    if (-not $conditions.Contains('platforms'))
                    {
                        $conditions.Add('platforms', @{
                                includePlatforms = @()
                            })
                    }
                    else
                    {
                        $conditions.platforms.Add('includePlatforms', @())
                    }
                    Write-Verbose -Message "Set(): IncludePlatforms: $($this.IncludePlatforms)"
                    if (([Array]$this.IncludePlatforms).Length -eq 0)
                    {
                        $conditions.platforms.includePlatforms = @('all')
                    }
                    else
                    {
                        $conditions.platforms.includePlatforms = [AADConditionalAccessPolicy]::ConvertToGraphPlatform($this.IncludePlatforms)
                    }
                    if (([Array]$this.ExcludePlatforms).Length -ne 0)
                    {
                        $conditions.platforms.Add('excludePlatforms', @())
                        $conditions.platforms.excludePlatforms = [AADConditionalAccessPolicy]::ConvertToGraphPlatform($this.ExcludePlatforms)
                    }
                    else
                    {
                        $conditions.platforms.Add('excludePlatforms', @())
                    }
                }
                else
                {
                    Write-Verbose -Message 'Set(): setting platform condition to null'
                    $conditions.platforms = $null
                }
            }

            Write-Verbose -Message 'Set(): process include and exclude locations'
            if ($currentParameters.ContainsKey('IncludeLocations') -or $currentParameters.ContainsKey('ExcludeLocations'))
            {
                if ($this.IncludeLocations -or $this.ExcludeLocations)
                {
                    $conditions.Add('locations', @{
                            excludeLocations = @()
                            includeLocations = @()
                        })
                    $conditions.locations.includeLocations = @()
                    $conditions.locations.excludeLocations = @()
                    Write-Verbose -Message 'Set(): locations specified'
                    #create and provision Location condition object if used, translate Location names to guid
                    $LocationLookup = @{}
                    foreach ($Location in Get-MgBetaIdentityConditionalAccessNamedLocation)
                    {
                        $LocationLookup[$Location.displayName] = $Location.Id
                    }
                    foreach ($IncludeLocation in $this.IncludeLocations)
                    {
                        if ($IncludeLocation)
                        {
                            if ($IncludeLocation -in 'All', 'AllTrusted')
                            {
                                $conditions.locations.includeLocations += $IncludeLocation
                            }
                            elseif ($IncludeLocation -eq 'Multifactor authentication trusted IPs')
                            {
                                $conditions.locations.includeLocations += '00000000-0000-0000-0000-000000000000'
                            }
                            elseif ($null -eq $LocationLookup[$IncludeLocation])
                            {
                                $message = "Couldn't find Location $IncludeLocation , couldn't add to policy $($this.DisplayName)"
                                $this.LogError($_, $message)
                                throw $message # and avoid creating or updating a policy with a missing location
                            }
                            else
                            {
                                $conditions.locations.includeLocations += $LocationLookup[$IncludeLocation]
                            }
                        }
                    }
                    foreach ($ExcludeLocation in $this.ExcludeLocations)
                    {
                        if ($ExcludeLocation)
                        {
                            if ($ExcludeLocation -eq 'All' -or $ExcludeLocation -eq 'AllTrusted')
                            {
                                $conditions.locations.excludeLocations += $ExcludeLocation
                            }
                            elseif ($ExcludeLocation -eq 'Multifactor authentication trusted IPs')
                            {
                                $conditions.locations.excludeLocations += '00000000-0000-0000-0000-000000000000'
                            }
                            elseif ($null -eq $LocationLookup[$ExcludeLocation])
                            {
                                $message = "Couldn't find Location $ExcludeLocation , couldn't add to policy $($this.DisplayName)"
                                $this.LogError($_, $message)
                                throw $message # and avoid creating or updating a policy with a missing location
                            }
                            else
                            {
                                $conditions.locations.excludeLocations += $LocationLookup[$ExcludeLocation]
                            }
                        }
                    }
                }
            }

            Write-Verbose -Message 'Set(): process device filter'
            if ($currentParameters.ContainsKey('DeviceFilterMode') -and $currentParameters.ContainsKey('DeviceFilterRule'))
            {
                if ($this.DeviceFilterMode -and $this.DeviceFilterRule)
                {
                    if (-not $conditions.Contains('Devices'))
                    {
                        $conditions.Add('devices', @{})
                        $conditions.devices.Add('deviceFilter', @{})
                        $conditions.devices.deviceFilter.Add('mode', $this.DeviceFilterMode)
                        $conditions.devices.deviceFilter.Add('rule', $this.DeviceFilterRule)
                    }
                    else
                    {
                        if (-not $conditions.Devices.Contains('DeviceFilter'))
                        {
                            $conditions.devices.Add('DeviceFilter', @{})
                            $conditions.devices.deviceFilter.Add('mode', $this.DeviceFilterMode)
                            $conditions.devices.deviceFilter.Add('rule', $this.DeviceFilterRule)
                        }
                        else
                        {
                            if (-not $conditions.devices.deviceFilter.Contains('mode'))
                            {
                                $conditions.devices.deviceFilter.Add('mode', $this.DeviceFilterMode)
                            }
                            else
                            {
                                $conditions.devices.deviceFilter.mode = $this.DeviceFilterMode
                            }
                            if (-not $conditions.devices.deviceFilter.Contains('rule'))
                            {
                                $conditions.devices.deviceFilter.Add('rule', $this.DeviceFilterRule)
                            }
                            else
                            {
                                $conditions.devices.deviceFilter.rule = $this.DeviceFilterRule
                            }
                        }
                    }
                }
            }

            if ([String]::IsNullOrEmpty($this.InsiderRiskLevels) -eq $false)
            {
                $conditions.Add('insiderRiskLevels', $($this.InsiderRiskLevels -join ','))
            }

            if ($this.ServicePrincipalRiskLevels -is [string[]] -and $this.ServicePrincipalRiskLevels.Count -gt 0)
            {
                $conditions.Add('servicePrincipalRiskLevels', $this.ServicePrincipalRiskLevels)
            }

            Write-Verbose -Message 'Set(): process risk levels and app types'
            Write-Verbose -Message "Set(): UserRiskLevels: $($this.UserRiskLevels)"
            if ($currentParameters.ContainsKey('UserRiskLevels'))
            {
                $Conditions.Add('userRiskLevels', $this.UserRiskLevels)
                #no translation or conversion needed
            }

            Write-Verbose -Message "Set(): SignInRiskLevels: $($this.SignInRiskLevels)"
            if ($currentParameters.ContainsKey('SignInRiskLevels'))
            {
                $Conditions.Add('signInRiskLevels', $this.SignInRiskLevels)
                #no translation or conversion needed
            }

            Write-Verbose -Message "Set(): ClientAppTypes: $($this.ClientAppTypes)"
            if ($currentParameters.ContainsKey('ClientAppTypes'))
            {
                $Conditions.Add('clientAppTypes', $this.ClientAppTypes)
                #no translation or conversion needed
            }

            Write-Verbose -Message "Set(): authenticationFlows transferMethods: $($this.TransferMethods)"
            if ($currentParameters.ContainsKey('TransferMethods') -or `
                $currentParameters.ContainsKey('ProtocolFlows'))
            {
                #create and provision TransferMethods condition object if used
                $authenticationFlows = if ([System.String]::IsNullOrEmpty($this.TransferMethods) -and [System.String]::IsNullOrEmpty($this.ProtocolFlows))
                {
                    $null
                }
                else
                {
                    $value = @{}

                    if (-not [System.String]::IsNullOrEmpty($this.TransferMethods))
                    {
                        $value.Add('transferMethods', $this.TransferMethods)
                    }
                    if (-not [System.String]::IsNullOrEmpty($this.ProtocolFlows))
                    {
                        $value.Add('protocolFlows', $this.ProtocolFlows -join ',')
                    }
                    $value
                }
                if (-not $conditions.Contains('authenticationFlows'))
                {
                    $conditions.Add('authenticationFlows', $authenticationFlows)
                }
                else
                {
                    $conditions.authenticationFlows = $authenticationFlows
                }
            }
            Write-Verbose -Message 'Set(): Adding processed conditions'
            #add all conditions to the parameter list
            $NewParameters.Add('conditions', $Conditions)
            #create and provision Grant Control object
            Write-Verbose -Message 'Set(): create and provision Grant Control object'

            if ($this.GrantControlOperator -and ($this.BuiltInControls -or $this.TermsOfUse -or $this.CustomAuthenticationFactors -or $this.AuthenticationStrength))
            {
                $grantControls = @{
                    operator = $this.GrantControlOperator
                }

                if ($currentParameters.ContainsKey('BuiltInControls'))
                {
                    $GrantControls.Add('builtInControls', $this.BuiltInControls)
                }
                if ($currentParameters.ContainsKey('CustomAuthenticationFactors'))
                {
                    $GrantControls.Add('customAuthenticationFactors', $this.CustomAuthenticationFactors)
                }
                if ($currentParameters.ContainsKey('AuthenticationStrength'))
                {
                    $strengthPolicy = Get-MgBetaPolicyAuthenticationStrengthPolicy | Where-Object -FilterScript { $_.DisplayName -eq $this.AuthenticationStrength } -ErrorAction SilentlyContinue
                    if ($null -eq $strengthPolicy)
                    {
                        Write-Warning -Message "Authentication Strength Policy '$($this.AuthenticationStrength)' not found for Conditional Access Policy '$($this.DisplayName)'."
                    }
                    else
                    {
                        $authenticationStrengthInstance = @{
                            id            = $strengthPolicy.Id
                        }
                        $GrantControls.Add('authenticationStrength', $authenticationStrengthInstance)
                    }
                }

                if ($currentParameters.ContainsKey('TermsOfUse'))
                {
                    Write-Verbose -Message "Getting Terms of Use {$($this.TermsOfUse -join ', ')}"
                    $agreements = Get-MgBetaAgreement
                    $termsOfUseIds = @()
                    foreach ($termsOfUseName in $this.TermsOfUse)
                    {
                        $termsOfUseObj = $agreements | Where-Object -FilterScript { $_.DisplayName -eq $termsOfUseName }
                        if ($null -eq $termsOfUseObj)
                        {
                            Write-Warning -Message "Terms of Use '$termsOfUseName' not found for Conditional Access Policy '$($this.DisplayName)'."
                        }
                        else
                        {
                            $termsOfUseIds += $termsOfUseObj.Id
                        }
                    }
                    if ($termsOfUseIds.Count -gt 0)
                    {
                        $GrantControls.Add('termsOfUse', $termsOfUseIds)
                    }
                }

                #no translation or conversion needed
                Write-Verbose -Message 'Set(): Adding processed grant controls'
                $NewParameters.Add('grantControls', $GrantControls)
            }

            if ($this.GetBoundParameters().ContainsKey('ApplicationEnforcedRestrictionsIsEnabled') -or $this.GetBoundParameters().ContainsKey('CloudAppSecurityIsEnabled') `
                -or $this.GetBoundParameters().ContainsKey('SignInFrequencyIsEnabled') -or $this.GetBoundParameters().ContainsKey('PersistentBrowserIsEnabled') `
                -or ($null -ne $this.DisableResilienceDefaultsIsEnabled) -or $this.GetBoundParameters().ContainsKey('SecureSignInSessionIsEnabled'))
            {
                Write-Verbose -Message 'Set(): process session controls'
                Write-Verbose -Message 'Set(): create provision Session Control object'
                $sessionControls = @{
                    applicationEnforcedRestrictions = $null
                    cloudAppSecurity                = $null
                    continuousAccessEvaluation      = $null
                    secureSignInSession             = $null
                    signInFrequency                 = $null
                    persistentBrowser               = $null
                    disableResilienceDefaults       = $null
                }

                if ($this.ApplicationEnforcedRestrictionsIsEnabled -eq $true)
                {
                    $sessionControls.applicationEnforcedRestrictions = @{
                        isEnabled = $this.ApplicationEnforcedRestrictionsIsEnabled
                    }
                }
                if ($this.CloudAppSecurityIsEnabled)
                {
                    $cloudAppSecurityValue = @{
                        isEnabled            = $true
                        cloudAppSecurityType = $this.CloudAppSecurityType
                    }
                    $sessionControls.cloudAppSecurity = $cloudAppSecurityValue
                }
                if ($this.ContinuousAccessEvaluationMode)
                {
                    $sessionControls.continuousAccessEvaluation = @{
                        mode = $this.ContinuousAccessEvaluationMode
                    }
                }
                if ($this.SecureSignInSessionIsEnabled)
                {
                    $secureSignInSessionValue = @{
                        isEnabled = $this.SecureSignInSessionIsEnabled
                    }
                    $sessionControls.secureSignInSession = $secureSignInSessionValue
                }
                if ($this.SignInFrequencyIsEnabled)
                {
                    $signinFrequencyProp = @{
                        isEnabled         = $true
                        type              = $null
                        value             = $null
                        frequencyInterval = $null
                    }

                    $sessionControls.signInFrequency = $signinFrequencyProp
                    #create and provision SignInFrequency object if used
                    $sessionControls.signInFrequency.isEnabled = $true
                    if ($this.SignInFrequencyType -ne '')
                    {
                        $sessionControls.signInFrequency.type = $this.SignInFrequencyType
                    }
                    else
                    {
                        $sessionControls.signInFrequency.Remove('type') | Out-Null
                    }
                    if ($this.SignInFrequencyValue -gt 0)
                    {
                        $sessionControls.signInFrequency.value = $this.SignInFrequencyValue
                    }
                    else
                    {
                        $sessionControls.signInFrequency.Remove('value') | Out-Null
                    }
                    $sessionControls.signInFrequency.frequencyInterval = $this.SignInFrequencyInterval
                    if ($this.GetBoundParameters().ContainsKey('SignInFrequencyAuthenticationType'))
                    {
                        $sessionControls.signInFrequency.authenticationType = $this.SignInFrequencyAuthenticationType
                    }
                }
                if ($this.PersistentBrowserIsEnabled)
                {
                    $persistentBrowserValue = @{
                        isEnabled = $true
                        mode      = $this.PersistentBrowserMode
                    }
                    $sessionControls.persistentBrowser = $persistentBrowserValue
                }
                if ($this.DisableResilienceDefaultsIsEnabled)
                {
                    $sessionControls.disableResilienceDefaults = $this.DisableResilienceDefaultsIsEnabled
                }
                if ($sessionControls.Values.Where({ $null -ne $_ }).Count -eq 0)
                {
                    $sessionControls = $null
                }

                $NewParameters.Add('sessionControls', $sessioncontrols)
            }
        }

        Write-Verbose -Message "Set(): Policy body: $($NewParameters | ConvertTo-Json -Depth 5)"

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Set(): Change policy $($this.DisplayName)"
            try
            {
                Write-Verbose -Message "Updating existing policy with values: $(Convert-M365DscHashtableToString -Hashtable $NewParameters)"

                Update-MgBetaIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $currentPolicy.Id `
                    -BodyParameter $NewParameters
            }
            catch
            {
                $this.LogError($_, 'Error updating data:')

                throw
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Set(): create policy $($this.DisplayName)"
            Write-Verbose -Message 'Create Parameters:'
            Write-Verbose -Message (Convert-M365DscHashtableToString $NewParameters)

            if ($newparameters.Conditions.applications.Count -gt 0 -and ($newparameters.Conditions.Users.Count -gt 0 -or $newparameters.Conditions.ClientApplications.Count -gt 0) -and ($newparameters.GrantControls.Count -gt 0 -or $newparameters.SessionControls.Count -gt 0))
            {
                try
                {
                    New-MgBetaIdentityConditionalAccessPolicy -BodyParameter $NewParameters
                }
                catch
                {
                    $this.LogError($_, 'Error creating new policy:')

                    throw
                }
            }
            else
            {
                throw 'Set(): Failed creating new policy. At least a user rule, application rule and grant or session control is required'
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Set(): delete policy $($this.DisplayName)"
            try
            {
                Remove-MgBetaIdentityConditionalAccessPolicy -ConditionalAccessPolicyId $currentPolicy.Id
            }
            catch
            {
                $this.LogError($_, 'Error updating data:')

                throw
            }
        }
        Write-Verbose -Message "Set(): Finished processing Policy $($this.Displayname)"
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        try
        {
            [array] $Policies = Get-MgBetaIdentityConditionalAccessPolicy -Filter $this.Filter -All -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()

            if ($Policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                foreach ($Policy in $Policies)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "    |---[$i/$($Policies.Count)] $($Policy.DisplayName)" -DeferWrite
                    $Params = @{
                        DisplayName           = $Policy.DisplayName
                        Id                    = $Policy.Id
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        ApplicationSecret     = $this.ApplicationSecret
                        CertificateThumbprint = $this.CertificateThumbprint
                        Credential            = $this.Credential
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }
                    $this.ExportedInstance = $Policy
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ([System.String]::IsNullOrEmpty($Results.DeviceFilterMode))
                    {
                        $Results.Remove('DeviceFilterMode') | Out-Null
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -RawResults $rawResults

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden static [System.String[]] ConvertToGraphPlatform([System.String[]] $Platforms)
    {
        $graphPlatforms = @('android', 'iOS', 'windows', 'windowsPhone', 'macOS', 'linux', 'all', 'unknownFutureValue')
        $result = @()
        foreach ($platform in $Platforms)
        {
            $graphPlatform = $graphPlatforms | Where-Object -FilterScript { $_ -eq $platform }
            if ($null -eq $graphPlatform)
            {
                $graphPlatform = $platform
            }
            $result += $graphPlatform
        }

        return $result
    }

    hidden [AADConditionalAccessPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADConditionalAccessPolicy])
        {
            return $Values
        }

        $result = [AADConditionalAccessPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
