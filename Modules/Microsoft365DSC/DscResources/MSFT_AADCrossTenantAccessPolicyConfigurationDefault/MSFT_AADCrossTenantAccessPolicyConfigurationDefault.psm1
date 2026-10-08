using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCrossTenantAccessPolicyConfigurationDefault : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Defines your default configuration for inbound app service connect settings that control which applications can connect across tenant boundaries.')]
    [MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting] $AppServiceConnectInbound

    [DscProperty()]
    [System.ComponentModel.Description('Determines the default configuration for automatically redeeming invitations for users from other organizations.')]
    [MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings] $AutomaticUserConsentSettings

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users from other organizations accessing your resources via Azure AD B2B collaboration.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BCollaborationInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users in your organization going outbound to access resources in another organization via Azure AD B2B collaboration.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BCollaborationOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users from other organizations accessing your resources via Azure AD B2B direct connect.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BDirectConnectInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your partner-specific configuration for users in your organization going outbound to access resources in another organization via Azure AD B2B direct connect.')]
    [MSFT_AADCrossTenantAccessPolicyB2BSetting] $B2BDirectConnectOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether users can use granular delegated admin privileges (GDAP) to sign-in and access resources in other organizations. Default value is false.')]
    [System.Nullable[System.Boolean]] $BlockServiceProviderOutboundAccess

    [DscProperty()]
    [System.ComponentModel.Description('Determines the partner-specific configuration for trusting other Conditional Access claims from external Azure AD organizations.')]
    [MSFT_AADCrossTenantAccessPolicyInboundTrust] $InboundTrust

    [DscProperty()]
    [System.ComponentModel.Description('Defines the priority order based on which an identity provider is selected during invitation redemption for a guest user.')]
    [MSFT_AADDefaultInvitationRedemptionIdentityProviderConfiguration] $InvitationRedemptionIdentityProviderConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Defines your default configuration for inbound Microsoft 365 collaboration settings that determine which users from other organizations can collaborate with your organization using Microsoft 365 apps.')]
    [MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting] $M365CollaborationInbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines your default configuration for outbound Microsoft 365 collaboration settings that determine which users in your organization can collaborate with other organizations using Microsoft 365 apps.')]
    [MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting] $M365CollaborationOutbound

    [DscProperty()]
    [System.ComponentModel.Description('Defines the default tenant restrictions configuration for users in your organization who access an external organization on your network or devices.')]
    [MSFT_AADCrossTenantAccessPolicyTenantRestrictions] $TenantRestrictions

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the instance should exist or not. This resource cannot be removed and the value must be set to ''Ensure''.')]
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

    [AADCrossTenantAccessPolicyConfigurationDefault] Get()
    {
        $tenantRestrictionsValue = $null
        $B2BDirectConnectOutboundValue = $null
        $InboundTrustValue = $null
        $B2BDirectConnectInboundValue = $null
        $B2BCollaborationOutboundValue = $null
        $invitationRedemptionIdentityProviderConfigurationValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCrossTenantAccessPolicyConfigurationDefault]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of AzureAD Cross Tenant Access Policy Configuration Default'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $getValue = Get-MgBetaPolicyCrossTenantAccessPolicyDefault -ErrorAction SilentlyContinue

            if ($null -eq $getValue)
            {
                Write-Verbose -Message 'Could not find an Azure AD Cross Tenant Access Configuration Default'
                return $this.AsResult($nullResult)
            }

            $appServiceConnectInboundValue = $null
            if ($null -ne $getValue.AppServiceConnectInbound)
            {
                $appServiceConnectInboundValue = [ordered]@{
                    Applications = [ordered]@{
                        AccessType = $getValue.AppServiceConnectInbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.AppServiceConnectInbound.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }
            }

            $AutomaticUserConsentSettingsValue = $null
            if ($null -ne $getValue.AutomaticUserConsentSettings)
            {
                $AutomaticUserConsentSettingsValue = [ordered]@{
                    InboundAllowed  = $getValue.AutomaticUserConsentSettings.InboundAllowed
                    OutboundAllowed = $getValue.AutomaticUserConsentSettings.OutboundAllowed
                }
            }

            $B2BCollaborationInboundValue = $null
            if ($null -ne $getValue.B2BCollaborationInbound)
            {
                $B2BCollaborationInboundValue = [ordered]@{
                    Applications   = [ordered]@{
                        AccessType = $getValue.B2BCollaborationInbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BCollaborationInbound.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.B2BCollaborationInbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BCollaborationInbound.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }

                # Convert users back to UPN
                $newValue = @()
                foreach ($valueEntry in $B2BCollaborationInboundValue.UsersAndGroups.Targets)
                {
                    $currentEntry = [ordered]@{
                        Target     = $valueEntry.Target
                        TargetType = $valueEntry.TargetType
                    }
                    if ($valueEntry.TargetType -eq 'user')
                    {
                        if ($valueEntry.Target -ne 'AllUsers')
                        {
                            $user = Get-MgUser -UserId $valueEntry.Target -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $currentEntry.Target = $user.UserPrincipalName
                            }
                            else
                            {
                                $currentEntry.Target = $valueEntry.Target
                            }
                        }
                    }
                    else
                    {
                        $group = [System.Array] (Get-MgGroup -GroupId $valueEntry.Target -ErrorAction SilentlyContinue)
                        if ($null -ne $group -and $group.Length -eq 1)
                        {
                            $currentEntry.Target = $group.DisplayName
                        }
                        else
                        {
                            $currentEntry.Target = $valueEntry.Target
                        }
                    }
                    $newValue += $currentEntry
                }
                $B2BCollaborationInboundValue.UsersAndGroups.Targets = $newValue
            }
            if ($null -ne $getValue.B2BCollaborationOutbound)
            {
                $B2BCollaborationOutboundValue = [ordered]@{
                    Applications   = [ordered]@{
                        AccessType = $getValue.B2BCollaborationOutbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BCollaborationOutbound.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.B2BCollaborationOutbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BCollaborationOutbound.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }

                # Convert users back to UPN
                $newValue = @()
                foreach ($valueEntry in $B2BCollaborationOutboundValue.UsersAndGroups.Targets)
                {
                    $currentEntry = [ordered]@{
                        Target     = $valueEntry.Target
                        TargetType = $valueEntry.TargetType
                    }
                    if ($valueEntry.TargetType -eq 'user')
                    {
                        if ($valueEntry.Target -ne 'AllUsers')
                        {
                            $user = Get-MgUser -UserId $valueEntry.Target -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $currentEntry.Target = $user.UserPrincipalName
                            }
                            else
                            {
                                $currentEntry.Target = $valueEntry.Target
                            }
                        }
                    }
                    else
                    {
                        $group = [System.Array] (Get-MgGroup -GroupId $valueEntry.Target -ErrorAction SilentlyContinue)
                        if ($null -ne $group -and $group.Length -eq 1)
                        {
                            $currentEntry.Target = $group.DisplayName
                        }
                        else
                        {
                            $currentEntry.Target = $valueEntry.Target
                        }
                    }
                    $newValue += $currentEntry
                }
                $B2BCollaborationOutboundValue.UsersAndGroups.Targets = $newValue
            }
            if ($null -ne $getValue.B2BDirectConnectInbound)
            {
                $B2BDirectConnectInboundValue = [ordered]@{
                    Applications   = [ordered]@{
                        AccessType = $getValue.B2BDirectConnectInbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BDirectConnectInbound.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.B2BDirectConnectInbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BDirectConnectInbound.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }
            }
            if ($null -ne $getValue.B2BDirectConnectOutbound)
            {
                $B2BDirectConnectOutboundValue = [ordered]@{
                    Applications   = [ordered]@{
                        AccessType = $getValue.B2BDirectConnectOutbound.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BDirectConnectOutbound.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.B2BDirectConnectOutbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.B2BDirectConnectOutbound.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }
                # Convert users back to UPN
                $newValue = @()
                foreach ($valueEntry in $B2BDirectConnectOutboundValue.UsersAndGroups.Targets)
                {
                    $currentEntry = [ordered]@{
                        Target     = $valueEntry.Target
                        TargetType = $valueEntry.TargetType
                    }
                    if ($valueEntry.TargetType -eq 'user')
                    {
                        if ($valueEntry.Target -ne 'AllUsers')
                        {
                            $user = Get-MgUser -UserId $valueEntry.Target -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $currentEntry.Target = $user.UserPrincipalName
                            }
                            else
                            {
                                $currentEntry.Target = $valueEntry.Target
                            }
                        }
                    }
                    else
                    {
                        $group = [System.Array] (Get-MgGroup -GroupId $valueEntry.Target -ErrorAction SilentlyContinue)
                        if ($null -ne $group -and $group.Length -eq 1)
                        {
                            $currentEntry.Target = $group.DisplayName
                        }
                        else
                        {
                            $currentEntry.Target = $valueEntry.Target
                        }
                    }
                    $newValue += $currentEntry
                }
                $B2BDirectConnectOutboundValue.UsersAndGroups.Targets = $newValue
            }
            if ($null -ne $getValue.InboundTrust)
            {
                $InboundTrustValue = [ordered]@{
                    IsCompliantDeviceAccepted           = $getValue.InboundTrust.IsCompliantDeviceAccepted
                    IsHybridAzureADJoinedDeviceAccepted = $getValue.InboundTrust.IsHybridAzureADJoinedDeviceAccepted
                    IsMfaAccepted                       = $getValue.InboundTrust.IsMfaAccepted
                }
            }
            if ($null -ne $getValue.InvitationRedemptionIdentityProviderConfiguration)
            {
                $invitationRedemptionIdentityProviderConfigurationValue = [ordered]@{
                    FallbackIdentityProvider               = $getValue.InvitationRedemptionIdentityProviderConfiguration.FallbackIdentityProvider
                    PrimaryIdentityProviderPrecedenceOrder = $getValue.InvitationRedemptionIdentityProviderConfiguration.PrimaryIdentityProviderPrecedenceOrder
                }
            }
            $m365CollaborationInboundValue = $null
            if ($null -ne $getValue.M365CollaborationInbound)
            {
                $m365CollaborationInboundValue = [ordered]@{
                    Users = [ordered]@{
                        AccessType = $getValue.M365CollaborationInbound.Users.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.M365CollaborationInbound.Users.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }
            }
            $m365CollaborationOutboundValue = $null
            if ($null -ne $getValue.M365CollaborationOutbound)
            {
                $m365CollaborationOutboundValue = [ordered]@{
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.M365CollaborationOutbound.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.M365CollaborationOutbound.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }

                # Convert users back to UPN
                $newValue = @()
                foreach ($valueEntry in $m365CollaborationOutboundValue.UsersAndGroups.Targets)
                {
                    $currentEntry = [ordered]@{
                        Target     = $valueEntry.Target
                        TargetType = $valueEntry.TargetType
                    }
                    if ($valueEntry.TargetType -eq 'user')
                    {
                        if ($valueEntry.Target -ne 'AllUsers')
                        {
                            $user = Get-MgUser -UserId $valueEntry.Target -ErrorAction SilentlyContinue
                            if ($null -ne $user)
                            {
                                $currentEntry.Target = $user.UserPrincipalName
                            }
                            else
                            {
                                $currentEntry.Target = $valueEntry.Target
                            }
                        }
                    }
                    else
                    {
                        $group = [System.Array] (Get-MgGroup -GroupId $valueEntry.Target -ErrorAction SilentlyContinue)
                        if ($null -ne $group -and $group.Length -eq 1)
                        {
                            $currentEntry.Target = $group.DisplayName
                        }
                        else
                        {
                            $currentEntry.Target = $valueEntry.Target
                        }
                    }
                    $newValue += $currentEntry
                }
                $m365CollaborationOutboundValue.UsersAndGroups.Targets = $newValue
            }
            if ($null -ne $getValue.TenantRestrictions)
            {
                $tenantRestrictionsValue = [ordered]@{
                    Applications = [ordered]@{
                        AccessType = $getValue.TenantRestrictions.Applications.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.TenantRestrictions.Applications.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                    <# Not yet supported
                    Devices = [ordered]@{
                        Mode = $getValue.TenantRestrictions.Devices.Mode
                        Rule = $getValue.TenantRestrictions.Devices.Rule
                    }
                    #>
                    UsersAndGroups = [ordered]@{
                        AccessType = $getValue.TenantRestrictions.UsersAndGroups.AccessType
                        Targets    = Get-M365DSCArrayFromProperty -Property ($getValue.TenantRestrictions.UsersAndGroups.Targets | ForEach-Object {
                            [ordered]@{
                                Target     = $_.Target
                                TargetType = $_.TargetType
                            }
                        }) -ElementType ([System.Object])
                    }
                }
            }

            $results = @{
                IsSingleInstance                                  = 'Yes'
                AppServiceConnectInbound                          = $appServiceConnectInboundValue
                AutomaticUserConsentSettings                      = $AutomaticUserConsentSettingsValue
                B2BCollaborationInbound                           = $B2BCollaborationInboundValue
                B2BCollaborationOutbound                          = $B2BCollaborationOutboundValue
                B2BDirectConnectInbound                           = $B2BDirectConnectInboundValue
                B2BDirectConnectOutbound                          = $B2BDirectConnectOutboundValue
                BlockServiceProviderOutboundAccess                = $getValue.BlockServiceProviderOutboundAccess
                InboundTrust                                      = $InboundTrustValue
                InvitationRedemptionIdentityProviderConfiguration = $invitationRedemptionIdentityProviderConfigurationValue
                M365CollaborationInbound                          = $m365CollaborationInboundValue
                M365CollaborationOutbound                         = $m365CollaborationOutboundValue
                TenantRestrictions                                = $tenantRestrictionsValue
                Ensure                                            = 'Present'
                Credential                                        = $this.Credential
                ApplicationId                                     = $this.ApplicationId
                TenantId                                          = $this.TenantId
                ApplicationSecret                                 = $this.ApplicationSecret
                CertificateThumbprint                             = $this.CertificateThumbprint
                CertificatePath                                   = $this.CertificatePath
                CertificatePassword                               = $this.CertificatePassword
                ManagedIdentity                                   = $this.ManagedIdentity
                AccessTokens                                      = $this.AccessTokens
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of AzureAD Cross Tenant Access Policy Configuration Default'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $OperationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $OperationParams.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $OperationParams.AppServiceConnectInbound)
        {
            $OperationParams.AppServiceConnectInbound = $this.GetAppServiceConnectSetting($OperationParams.AppServiceConnectInbound)
            $temp = $OperationParams.AppServiceConnectInbound
            $OperationParams.Remove('AppServiceConnectInbound') | Out-Null
            $OperationParams.Add('appServiceConnectInbound', $temp)
        }
        if ($null -ne $OperationParams.AutomaticUserConsentSettings)
        {
            $OperationParams.AutomaticUserConsentSettings = $this.GetAutomaticUserConsentSettings($OperationParams.AutomaticUserConsentSettings)
            $temp = $OperationParams.AutomaticUserConsentSettings
            $OperationParams.Remove('AutomaticUserConsentSettings') | Out-Null
            $OperationParams.Add('automaticUserConsentSettings', $temp)
        }
        if ($null -ne $OperationParams.B2BCollaborationInbound)
        {
            $OperationParams.B2BCollaborationInbound = $this.GetB2BSetting($OperationParams.B2BCollaborationInbound)
            $OperationParams.B2BCollaborationInbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BCollaborationInbound)
            $temp = $OperationParams.B2BCollaborationInbound
            $OperationParams.Remove('B2BCollaborationInbound') | Out-Null
            $OperationParams.Add('b2bCollaborationInbound', $temp)
        }
        if ($null -ne $OperationParams.B2BCollaborationOutbound)
        {
            $OperationParams.B2BCollaborationOutbound = $this.GetB2BSetting($OperationParams.B2BCollaborationOutbound)
            $OperationParams.B2BCollaborationOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BCollaborationOutbound)
            $temp = $OperationParams.B2BCollaborationOutbound
            $OperationParams.Remove('B2BCollaborationOutbound') | Out-Null
            $OperationParams.Add('b2bCollaborationOutbound', $temp)
        }
        if ($null -ne $OperationParams.B2BDirectConnectInbound)
        {
            $OperationParams.B2BDirectConnectInbound = $this.GetB2BSetting($OperationParams.B2BDirectConnectInbound)
            $OperationParams.B2BDirectConnectInbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BDirectConnectInbound)
            $temp = $OperationParams.B2BDirectConnectInbound
            $OperationParams.Remove('B2BDirectConnectInbound') | Out-Null
            $OperationParams.Add('b2bDirectConnectInbound', $temp)
        }
        if ($null -ne $OperationParams.B2BDirectConnectOutbound)
        {
            $OperationParams.B2BDirectConnectOutbound = $this.GetB2BSetting($OperationParams.B2BDirectConnectOutbound)
            $OperationParams.B2BDirectConnectOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.B2BDirectConnectOutbound)
            $temp = $OperationParams.B2BDirectConnectOutbound
            $OperationParams.Remove('B2BDirectConnectOutbound') | Out-Null
            $OperationParams.Add('b2bDirectConnectOutbound', $temp)
        }
        if ($null -ne $OperationParams.InboundTrust)
        {
            $OperationParams.InboundTrust = $this.GetInboundTrust($OperationParams.InboundTrust)
            $temp = $OperationParams.InboundTrust
            $OperationParams.Remove('InboundTrust') | Out-Null
            $OperationParams.Add('inboundTrust', $temp)
        }
        if ($null -ne $OperationParams.InvitationRedemptionIdentityProviderConfiguration)
        {
            $OperationParams.InvitationRedemptionIdentityProviderConfiguration = $this.GetDefaultInvitationRedemptionIdentityProviderConfiguration($OperationParams.InvitationRedemptionIdentityProviderConfiguration)
            $temp = $OperationParams.InvitationRedemptionIdentityProviderConfiguration
            $OperationParams.Remove('InvitationRedemptionIdentityProviderConfiguration') | Out-Null
            $OperationParams.Add('invitationRedemptionIdentityProviderConfiguration', $temp)
        }
        if ($null -ne $OperationParams.M365CollaborationInbound)
        {
            $OperationParams.M365CollaborationInbound = $this.GetM365CollaborationInboundSetting($OperationParams.M365CollaborationInbound)
            $temp = $OperationParams.M365CollaborationInbound
            $OperationParams.Remove('M365CollaborationInbound') | Out-Null
            $OperationParams.Add('m365CollaborationInbound', $temp)
        }
        if ($null -ne $OperationParams.M365CollaborationOutbound)
        {
            $OperationParams.M365CollaborationOutbound = $this.GetM365CollaborationOutboundSetting($OperationParams.M365CollaborationOutbound)
            $OperationParams.M365CollaborationOutbound = $this.UpdateSettingUserIdFromUPN($OperationParams.M365CollaborationOutbound)
            $temp = $OperationParams.M365CollaborationOutbound
            $OperationParams.Remove('M365CollaborationOutbound') | Out-Null
            $OperationParams.Add('m365CollaborationOutbound', $temp)
        }
        if ($null -ne $OperationParams.TenantRestrictions)
        {
            $OperationParams.TenantRestrictions = $this.GetTenantRestrictions($OperationParams.TenantRestrictions)
            $OperationParams.TenantRestrictions = $this.UpdateSettingUserIdFromUPN($OperationParams.TenantRestrictions)
            $temp = $OperationParams.TenantRestrictions
            $OperationParams.Remove('TenantRestrictions') | Out-Null
            $OperationParams.Add('tenantRestrictions', $temp)
        }

        $OperationParams = Rename-M365DSCCimInstanceParameter -Properties $OperationParams

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Cross Tenant Access Policy Configuration Default with:`r`n$(ConvertTo-Json $OperationParams -Depth 10)"
            Update-MgBetaPolicyCrossTenantAccessPolicyDefault -BodyParameter $OperationParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            throw 'Removing Cross Tenant Access Policy Configuration Default is not supported'
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $dscContent = [System.Text.StringBuilder]::new()
            $Params = @{
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

            if ($null -ne $Results.AppServiceConnectInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'AppServiceConnectInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyAppServiceConnectSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.AppServiceConnectInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyAppServiceConnectSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.AppServiceConnectInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AppServiceConnectInbound') | Out-Null
                }
            }

            if ($null -ne $Results.AutomaticUserConsentSettings)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.AutomaticUserConsentSettings `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyAutomaticUserConsentSettings'

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.AutomaticUserConsentSettings = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('AutomaticUserConsentSettings') | Out-Null
                }
            }

            if ($null -ne $Results.B2BCollaborationInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BCollaborationInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BCollaborationInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BCollaborationInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BCollaborationInbound') | Out-Null
                }
            }

            if ($null -ne $Results.B2BCollaborationOutbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BCollaborationOutbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BCollaborationOutbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BCollaborationOutbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BCollaborationOutbound') | Out-Null
                }
            }

            if ($null -ne $Results.B2BDirectConnectInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BDirectConnectInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BDirectConnectInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BDirectConnectInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BDirectConnectInbound') | Out-Null
                }
            }

            if ($null -ne $Results.B2BDirectConnectOutbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'B2BDirectConnectOutbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyB2BSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.B2BDirectConnectOutbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyB2BSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.B2BDirectConnectOutbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('B2BDirectConnectOutbound') | Out-Null
                }
            }

            if ($null -ne $Results.InboundTrust)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.InboundTrust `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyInboundTrust'

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.InboundTrust = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('InboundTrust') | Out-Null
                }
            }

            if ($null -ne $Results.InvitationRedemptionIdentityProviderConfiguration)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.InvitationRedemptionIdentityProviderConfiguration `
                    -CIMInstanceName 'AADDefaultInvitationRedemptionIdentityProviderConfiguration'

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.InvitationRedemptionIdentityProviderConfiguration = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('InvitationRedemptionIdentityProviderConfiguration') | Out-Null
                }
            }

            if ($null -ne $Results.M365CollaborationInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'M365CollaborationInbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyM365CollaborationInboundSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Users'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.M365CollaborationInbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyM365CollaborationInboundSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.M365CollaborationInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('M365CollaborationInbound') | Out-Null
                }
            }

            if ($null -ne $Results.M365CollaborationOutbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'M365CollaborationOutbound'
                        CimInstanceName = 'AADCrossTenantAccessPolicyM365CollaborationOutboundSetting'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.M365CollaborationOutbound `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyM365CollaborationOutboundSetting' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.M365CollaborationOutbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('M365CollaborationOutbound') | Out-Null
                }
            }

            if ($null -ne $Results.TenantRestrictions)
            {
                $complexMapping = @(
                    @{
                        Name            = 'Applications'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'UsersAndGroups'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTargetConfiguration'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Devices'
                        CimInstanceName = 'AADDevicesFilter'
                        IsRequired      = $False
                    },
                    @{
                        Name            = 'Targets'
                        CimInstanceName = 'AADCrossTenantAccessPolicyTarget'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.TenantRestrictions `
                    -CIMInstanceName 'AADCrossTenantAccessPolicyTenantRestrictions' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.TenantRestrictions = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('TenantRestrictions') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential `
                -NoEscape @('AppServiceConnectInbound', 'AutomaticUserConsentSettings', 'B2BCollaborationInbound', 'B2BCollaborationOutbound', 'B2BDirectConnectInbound', 'B2BDirectConnectOutbound', 'InboundTrust', 'InvitationRedemptionIdentityProviderConfiguration', 'M365CollaborationInbound', 'M365CollaborationOutbound', 'TenantRestrictions')

            # Fix OrganizationName variable in CIMInstance
            $currentDSCBlock = $currentDSCBlock.Replace('@$OrganizationName''', "@' + `$OrganizationName")

            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName

            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Collections.Hashtable] GetAutomaticUserConsentSettings([System.Object] $Setting)
    {
        $result = @{
            inboundAllowed  = $Setting.InboundAllowed
            outboundAllowed = $Setting.OutboundAllowed
        }

        return $result
    }

    hidden [System.Collections.Hashtable] GetB2BSetting([System.Object] $Setting)
    {
        #region Applications
        $applications = @{
            accessType = $Setting.applications.accessType
        }

        if ($null -ne $Setting.applications.targets)
        {
            $targets = @()
            foreach ($currentTarget in $Setting.applications.targets)
            {
                $targets += @{
                    target     = $currentTarget.target
                    targetType = $currentTarget.targetType
                }
            }
            $applications.Add('targets', $targets)
        }
        #endregion

        #region UsersAndGroups
        $usersAndGroups = @{
            accessType = $Setting.usersAndGroups.accessType
        }

        if ($null -ne $Setting.usersAndGroups.targets)
        {
            $targets = @()
            foreach ($currentTarget in $Setting.usersAndGroups.targets)
            {
                $user = $null
                $group = $null
                if ($currentTarget.targetType -eq 'User')
                {
                    $user = Get-MgUser -UserId $currentTarget.target -ErrorAction SilentlyContinue
                }
                elseif ($currentTarget.targetType -eq 'Group')
                {
                    $group = Get-MgGroup -GroupId $currentTarget.target -ErrorAction SilentlyContinue
                }

                $targetValue = $currentTarget.target
                if ($null -ne $user)
                {
                    $targetValue = $user.UserPrincipalName
                }
                elseif ($null -ne $group)
                {
                    $targetValue = $group.DisplayName
                }
                $targets += @{
                    target     = $targetValue
                    targetType = $currentTarget.targetType
                }
            }
            $usersAndGroups.Add('targets', $targets)
        }
        #endregion
        $results = @{
            applications   = $applications
            usersAndGroups = $usersAndGroups
        }

        return $results
    }

    hidden [System.Collections.Hashtable] GetAppServiceConnectSetting([System.Object] $Setting)
    {
        $body = $this.GetB2BSetting($Setting)
        $body.Remove('usersAndGroups')

        return $body
    }

    hidden [System.Collections.Hashtable] GetM365CollaborationInboundSetting([System.Object] $Setting)
    {
        # Targets are external principals that do not exist in the local tenant.
        $users = @{
            accessType = $Setting.Users.AccessType
        }

        if ($null -ne $Setting.Users.Targets)
        {
            $targets = @()
            foreach ($currentTarget in $Setting.Users.Targets)
            {
                $targets += @{
                    target     = $currentTarget.Target
                    targetType = $currentTarget.TargetType
                }
            }
            $users.Add('targets', $targets)
        }

        return @{
            users = $users
        }
    }

    hidden [System.Collections.Hashtable] GetM365CollaborationOutboundSetting([System.Object] $Setting)
    {
        $body = $this.GetB2BSetting($Setting)
        $body.Remove('applications')

        return $body
    }

    hidden [System.Collections.Hashtable] GetDefaultInvitationRedemptionIdentityProviderConfiguration([System.Object] $Setting)
    {
        return @{
            fallbackIdentityProvider               = $Setting.FallbackIdentityProvider
            primaryIdentityProviderPrecedenceOrder = $Setting.PrimaryIdentityProviderPrecedenceOrder
        }
    }

    hidden [System.Collections.Hashtable] GetTenantRestrictions([System.Object] $Setting)
    {
        $body = $this.GetB2BSetting($Setting)
        <#
        $body.Add('devices', @{
            mode = $Setting.Devices.Mode
            rule = $Setting.Devices.Rule
        })
        #>

        return $body
    }

    hidden [System.Collections.Hashtable] UpdateSettingUserIdFromUPN([System.Collections.Hashtable] $Setting)
    {
        if ($null -ne $Setting.UsersAndGroups -and $null -ne $Setting.UsersAndGroups.Targets)
        {
            for ($i = 0; $i -lt $Setting.UsersAndGroups.Targets.Length; $i++)
            {
                $user = $Setting.UsersAndGroups.Targets[$i]
                $userValue = $user.Target
                if ($null -ne $userValue)
                {
                    if ($user.TargetType -eq 'user')
                    {
                        Write-Verbose -Message "Detected User type with UPN {$($user.Target)}"
                        $user = Get-MgUser -UserId $user.Target -ErrorAction SilentlyContinue
                        if ($null -ne $user)
                        {
                            $userValue = $user.Id
                        }
                    }
                    elseif ($user.TargetType -eq 'group')
                    {
                        Write-Verbose -Message "Detected Group type with Name {$($user.Target)}"
                        $group = Get-MgGroup -Filter "DisplayName eq  '$($user.Target)'" -ErrorAction SilentlyContinue
                        if ($null -ne $group)
                        {
                            $userValue = $group.Id
                        }
                    }
                }
                if ($null -ne $userValue)
                {
                    Write-Verbose -Message "Updating principal to Id {$userValue}"
                }
                if ($null -ne $Setting.UsersAndGroups.Targets[$i].Target)
                {
                    $Setting.UsersAndGroups.Targets[$i].Target = $userValue
                }
            }
        }
        return $Setting
    }

    hidden [System.Collections.Hashtable] GetInboundTrust([System.Object] $Setting)
    {
        $result = @{
            isCompliantDeviceAccepted           = $Setting.isCompliantDeviceAccepted
            isHybridAzureADJoinedDeviceAccepted = $Setting.isHybridAzureADJoinedDeviceAccepted
            isMfaAccepted                       = $Setting.isMfaAccepted
        }

        return $result
    }

    hidden [AADCrossTenantAccessPolicyConfigurationDefault] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCrossTenantAccessPolicyConfigurationDefault])
        {
            return $Values
        }

        $result = [AADCrossTenantAccessPolicyConfigurationDefault]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADCrossTenantAccessPolicyAppServiceConnectSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target applications that are allowed for inbound app service connect across tenant boundaries.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications
}

class MSFT_AADCrossTenantAccessPolicyAutomaticUserConsentSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you want to automatically trust Inbound invitations.')]
    [System.Nullable[System.Boolean]] $InboundAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you want to automatically trust Outbound invitations.')]
    [System.Nullable[System.Boolean]] $OutboundAllowed
}

class MSFT_AADCrossTenantAccessPolicyB2BSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The list of applications targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('The list of users and groups targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyInboundTrust
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether compliant devices from external Azure AD organizations are trusted.')]
    [System.Nullable[System.Boolean]] $IsCompliantDeviceAccepted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether hybrid Azure AD joined devices from external Azure AD organizations are trusted.')]
    [System.Nullable[System.Boolean]] $IsHybridAzureADJoinedDeviceAccepted

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether MFA from external Azure AD organizations is trusted.')]
    [System.Nullable[System.Boolean]] $IsMfaAccepted
}

class MSFT_AADDefaultInvitationRedemptionIdentityProviderConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of identity providers in priority order of preference to be used for guest invitation redemption. The possible values are: azureActiveDirectory, externalFederation, or socialIdentityProviders.')]
    [ValidateSet('azureActiveDirectory', 'externalFederation', 'socialIdentityProviders')]
    [System.String[]] $PrimaryIdentityProviderPrecedenceOrder

    [DscProperty()]
    [System.ComponentModel.Description('The fallback identity provider to be used in case no primary identity provider can be used for guest invitation redemption. The possible values are: defaultConfiguredIdp, emailOneTimePasscode, or microsoftAccount.')]
    [ValidateSet('defaultConfiguredIdp', 'emailOneTimePasscode', 'microsoftAccount')]
    [System.String] $FallbackIdentityProvider
}

class MSFT_AADCrossTenantAccessPolicyM365CollaborationInboundSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target users from other organizations who are allowed inbound Microsoft 365 collaboration with your organization.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Users
}

class MSFT_AADCrossTenantAccessPolicyM365CollaborationOutboundSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the target users and groups in your organization who are allowed outbound Microsoft 365 collaboration with external organizations.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyTenantRestrictions
{
    [DscProperty()]
    [System.ComponentModel.Description('The list of applications targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $Applications

    [DscProperty()]
    [System.ComponentModel.Description('Defines the rule for filtering devices and whether devices satisfying the rule should be allowed or blocked. This property isn''t supported on the server side yet.')]
    [MSFT_AADDevicesFilter] $Devices

    [DscProperty()]
    [System.ComponentModel.Description('The list of users and groups targeted with your cross-tenant access policy.')]
    [MSFT_AADCrossTenantAccessPolicyTargetConfiguration] $UsersAndGroups
}

class MSFT_AADCrossTenantAccessPolicyTargetConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether access is allowed or blocked. The possible values are: allowed, blocked, unknownFutureValue.')]
    [ValidateSet('allowed', 'blocked', 'unknownFutureValue')]
    [System.String] $AccessType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to target users, groups, or applications with this rule.')]
    [MSFT_AADCrossTenantAccessPolicyTarget[]] $Targets
}

class MSFT_AADDevicesFilter
{
    [DscProperty()]
    [System.ComponentModel.Description('Determines whether devices that satisfy the rule should be allowed or blocked. The possible values are: allowed, blocked.')]
    [ValidateSet('allowed', 'blocked')]
    [System.String] $Mode

    [DscProperty()]
    [System.ComponentModel.Description('Defines the rule to filter the devices. For example, ''device.deviceAttribute2 -eq ''PrivilegedAccessWorkstation''.')]
    [System.String] $Rule
}

class MSFT_AADCrossTenantAccessPolicyTarget
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Defines the target for cross-tenant access policy settings and can have one of the following values: The unique identifier of the user, group, or application, AllUsers, AllApplications - Refers to any Microsoft cloud application, Office365 - Includes the applications mentioned as part of the Office 365 suite.')]
    [System.String] $Target

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of resource that you want to target. The possible values are: user, group, application, unknownFutureValue.')]
    [ValidateSet('user', 'group', 'application', 'unknownFutureValue')]
    [System.String] $TargetType
}
