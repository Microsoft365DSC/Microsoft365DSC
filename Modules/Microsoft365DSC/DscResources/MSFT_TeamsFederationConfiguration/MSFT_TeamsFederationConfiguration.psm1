using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsFederationConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('When set to True users will be potentially allowed to communicate with users from other domains.')]
    [System.Nullable[System.Boolean]] $AllowFederatedUsers

    [DscProperty()]
    [System.ComponentModel.Description('You can safelist specific ''trial-only'' tenant domains, while keeping the ExternalAccessWithTrialTenants set to Blocked. This will allow you to protect your organization against majority of tenants that don''t have any paid subscriptions, while still being able to collaborate externally with those trusted trial-tenants in the list.')]
    [System.String[]] $AllowedTrialTenantDomains

    [DscProperty()]
    [System.ComponentModel.Description('List of federated domains to allow.')]
    [System.String[]] $AllowedDomains

    [DscProperty()]
    [System.ComponentModel.Description('List of federated domains to block.')]
    [System.String[]] $BlockedDomains

    [DscProperty()]
    [System.ComponentModel.Description('If the BlockedDomains parameter is used, then BlockAllSubdomains can be used to activate all subdomains blocking. If the BlockedDomains parameter is ignored, then BlockAllSubdomains is also ignored. Just like for BlockedDomains, users will be disallowed from communicating with users from blocked domains. But all subdomains for domains in this list will also be blocked.')]
    [System.Nullable[System.Boolean]] $BlockAllSubdomains

    [DscProperty()]
    [System.ComponentModel.Description('Allows federation with people using Teams with an account that''s not managed by an organization.')]
    [System.Nullable[System.Boolean]] $AllowTeamsConsumer

    [DscProperty()]
    [System.ComponentModel.Description('Allows people using Teams with an account that''s not managed by an organization, to discover and start communication with users in your organization.')]
    [System.Nullable[System.Boolean]] $AllowTeamsConsumerInbound

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, users whose assigned external access policy has EnableFederationAccess set to False are blocked from being added to group chats that include external users and are removed from existing active ones. When set to False, such users can be added to these group chats only when a user of the same tenant with federation access starts the chat.')]
    [System.Nullable[System.Boolean]] $EnableExternalAccessRestrictionsForChatParticipants

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, all participants of a group chat must have mutual federation relationships with every other participant. When set to False, only the initiator of the group chat and the user joining or being added need a mutual federation relationship.')]
    [System.Nullable[System.Boolean]] $EnableMutualFederationForChatParticipants

    [DscProperty()]
    [System.ComponentModel.Description('When set to Blocked, all external access with users from Teams subscriptions that contain only trial licenses will be blocked. This means users from these trial-only tenants will not be able to reach to your users via chats, Teams calls, and meetings (using the users authenticated identity) and your users will not be able to reach users in these trial-only tenants. If this setting is set to Blocked, users from the trial-only tenant will also be removed from existing chats.')]
    [ValidateSet('Allowed', 'Blocked')]
    [System.String] $ExternalAccessWithTrialTenants

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, messages sent from discovered partners are considered unverified. That means that those messages will be delivered only if they were sent from a person who is on the recipient''s Contacts list.')]
    [System.Nullable[System.Boolean]] $TreatDiscoveredPartnersAsUnverified

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, indicates that the users homed on Skype for Business Online use the same SIP domain as users homed on the on-premises version of Skype for Business Server.')]
    [System.Nullable[System.Boolean]] $SharedSipAddressSpace

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, Teamsconsumer have access only to external user profiles')]
    [System.Nullable[System.Boolean]] $RestrictTeamsConsumerToExternalUserProfiles

    [DscProperty()]
    [System.ComponentModel.Description('When set to ''Enabled'', security operations team will be able to add domains and users to the blocklist on security portal. When set to ''Disabled'', security operations team will not have permissions to update the domains and users blocklists.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $SecurityTeamAllowBlockListDelegation

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

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

    [TeamsFederationConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsFederationConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Federation'

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $config = Get-CsTenantFederationConfiguration -ErrorAction Stop

            $AllowedDomainsArray = $config.AllowedDomains.AllowedDomain.Domain
            $AllowedDomainsValues = @()

            if ($AllowedDomainsArray.Length -gt 0)
            {
                foreach ($domain in $AllowedDomainsArray)
                {
                    $AllowedDomainsValues += $domain
                }
            }

            $BlockedDomainsArray = $config.BlockedDomains.Domain
            $BlockedDomainsValues = @()

            if ($BlockedDomainsArray.Length -gt 0)
            {
                foreach ($domain in $BlockedDomainsArray)
                {
                    $BlockedDomainsValues += $domain
                }
            }

            return $this.AsResult(@{
                AllowedDomains                                      = $AllowedDomainsValues
                BlockedDomains                                      = $BlockedDomainsValues
                AllowedTrialTenantDomains                           = [System.String[]]@(foreach ($trialDomain in $config.AllowedTrialTenantDomains) { $trialDomain.Domain })
                AllowFederatedUsers                                 = $config.AllowFederatedUsers
                AllowTeamsConsumer                                  = $config.AllowTeamsConsumer
                AllowTeamsConsumerInbound                           = $config.AllowTeamsConsumerInbound
                BlockAllSubdomains                                  = $config.BlockAllSubdomains
                EnableExternalAccessRestrictionsForChatParticipants = $config.EnableExternalAccessRestrictionsForChatParticipants
                EnableMutualFederationForChatParticipants           = $config.EnableMutualFederationForChatParticipants
                ExternalAccessWithTrialTenants                      = $config.ExternalAccessWithTrialTenants
                TreatDiscoveredPartnersAsUnverified                 = $config.TreatDiscoveredPartnersAsUnverified
                SharedSipAddressSpace                               = $config.SharedSipAddressSpace
                RestrictTeamsConsumerToExternalUserProfiles         = $config.RestrictTeamsConsumerToExternalUserProfiles
                SecurityTeamAllowBlockListDelegation                = $config.SecurityTeamAllowBlockListDelegation
                IsSingleInstance                                    = 'Yes'
                Credential                                          = $this.Credential
                ApplicationId                                       = $this.ApplicationId
                TenantId                                            = $this.TenantId
                CertificateThumbprint                               = $this.CertificateThumbprint
                CertificatePath                                     = $this.CertificatePath
                CertificatePassword                                 = $this.CertificatePassword
                ManagedIdentity                                     = $this.ManagedIdentity
                AccessTokens                                        = $this.AccessTokens
            })
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

        Write-Verbose -Message 'Setting configuration of Teams Federation'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ($this.GetBoundParameters().ContainsKey('AllowedDomains'))
        {
            if ($this.AllowedDomains.Count -gt 0)
            {
                $SetParams.Remove('AllowedDomains') | Out-Null
                $SetParams.Add('AllowedDomainsAsAList', $this.AllowedDomains)
            }
            else
            {
                $AllowAllKnownDomains = New-CsEdgeAllowAllKnownDomains
                $SetParams.AllowedDomains = $AllowAllKnownDomains
            }
        }

        $SetParams.Add('Identity', 'Global')
        $SetParams.Remove('IsSingleInstance') | Out-Null
        Set-CsTenantFederationConfiguration @SetParams
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $dscContent = [System.Text.StringBuilder]::new()
            $params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            $this.ResourceCache['exportMode'] = $true
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsFederationConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsFederationConfiguration])
        {
            return $Values
        }

        $result = [TeamsFederationConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
