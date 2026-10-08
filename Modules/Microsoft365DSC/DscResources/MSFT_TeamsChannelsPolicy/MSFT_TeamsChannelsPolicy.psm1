using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsChannelsPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Channel Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Channel Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to share a shared channel with an external user. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowChannelSharingToExternalUser

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to create an org-wide team. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowOrgWideTeamCreation

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to discover private teams in suggestions and search results. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $EnablePrivateTeamDiscovery

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to create a private channel. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowPrivateChannelCreation

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to create a shared channel. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowSharedChannelCreation

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is allowed to participate in a shared channel that has been shared by an external user. Set this to TRUE to allow. Set this FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowUserToParticipateInExternalSharedChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables Next Generation Channel creation and editing. Possible values: Enabled, Disabled.')]
    [System.String] $AllowCreateChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables Classic Channel creation and editing. Possible values: Enabled, Disabled.')]
    [System.String] $AllowCreateClassicChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables Next Generation Private Channel creation and editing. Possible values: Enabled, Disabled.')]
    [System.String] $AllowCreatePrivateChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables Next Generation Shared Channel creation and editing. Possible values: Enabled, Disabled.')]
    [System.String] $AllowCreateSharedChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting sets whether users are able to create Next Generation Shared Channels by default. Possible values: Enabled, Disabled.')]
    [System.String] $CreateSharedChannelsByDefault

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables whether users from outside the team are allowed in Next Generation Channels. Possible values: Enabled, Disabled.')]
    [System.String] $AllowUsersFromOutsideTeam

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables whether guests from outside the team are allowed in Next Generation Channels. Possible values: Enabled, Disabled.')]
    [System.String] $AllowGuestsFromOutsideTeam

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables whether users from outside the team are allowed in Next Generation Private Channels. Possible values: Enabled, Disabled.')]
    [System.String] $AllowUsersFromOutsideTeamInPrivateChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables whether guests from outside the team are allowed in Next Generation Private Channels. Possible values: Enabled, Disabled.')]
    [System.String] $AllowGuestsFromOutsideTeamInPrivateChannel

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables sharing Next Generation Channels with Teams in the same organization. Possible values: Enabled, Disabled.')]
    [System.String] $AllowSharingWithTeamInOrg

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables sharing Next Generation Private Channels with Teams in the same organization. Possible values: Enabled, Disabled.')]
    [System.String] $AllowSharingPrivateChannelWithTeamInOrg

    [DscProperty()]
    [System.ComponentModel.Description('This setting sets the default channel type that users have available on channel creation. Possible values: Flexible, Private, Standard, Shared.')]
    [System.String] $DefaultChannelTypeOnCreation

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsChannelsPolicy] Get()
    {
        ${$Identity} = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsChannelsPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Channels Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsChannelsPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Channel Policy ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Channel Policy {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                                      = $this.Identity
                Description                                   = $policy.Description
                AllowChannelSharingToExternalUser             = $policy.AllowChannelSharingToExternalUser
                AllowOrgWideTeamCreation                      = $policy.AllowOrgWideTeamCreation
                EnablePrivateTeamDiscovery                    = $policy.EnablePrivateTeamDiscovery
                AllowPrivateChannelCreation                   = $policy.AllowPrivateChannelCreation
                AllowSharedChannelCreation                    = $policy.AllowSharedChannelCreation
                AllowUserToParticipateInExternalSharedChannel = $policy.AllowUserToParticipateInExternalSharedChannel
                AllowCreateChannel                            = $policy.AllowCreateChannel
                AllowCreateClassicChannel                     = $policy.AllowCreateClassicChannel
                AllowCreatePrivateChannel                     = $policy.AllowCreatePrivateChannel
                AllowCreateSharedChannel                      = $policy.AllowCreateSharedChannel
                CreateSharedChannelsByDefault                 = $policy.CreateSharedChannelsByDefault
                AllowUsersFromOutsideTeam                     = $policy.AllowUsersFromOutsideTeam
                AllowGuestsFromOutsideTeam                    = $policy.AllowGuestsFromOutsideTeam
                AllowUsersFromOutsideTeamInPrivateChannel     = $policy.AllowUsersFromOutsideTeamInPrivateChannel
                AllowGuestsFromOutsideTeamInPrivateChannel    = $policy.AllowGuestsFromOutsideTeamInPrivateChannel
                AllowSharingWithTeamInOrg                     = $policy.AllowSharingWithTeamInOrg
                AllowSharingPrivateChannelWithTeamInOrg       = $policy.AllowSharingPrivateChannelWithTeamInOrg
                DefaultChannelTypeOnCreation                  = $policy.DefaultChannelTypeOnCreation
                Ensure                                        = 'Present'
                Credential                                    = $this.Credential
                ApplicationId                                 = $this.ApplicationId
                TenantId                                      = $this.TenantId
                CertificateThumbprint                         = $this.CertificateThumbprint
                CertificatePath                               = $this.CertificatePath
                CertificatePassword                           = $this.CertificatePassword
                ManagedIdentity                               = $this.ManagedIdentity
                AccessTokens                                  = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Channel Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Channel Policy {$($this.Identity)}"
            New-CsTeamsChannelsPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Channel Policy {$($this.Identity)}"
            Set-CsTeamsChannelsPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Channel Policy {$($this.Identity)}"
            Remove-CsTeamsChannelsPolicy -Identity $this.Identity -Confirm:$false
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $i = 1
            [array]$policies = Get-CsTeamsChannelsPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity)" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [TeamsChannelsPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsChannelsPolicy])
        {
            return $Values
        }

        $result = [TeamsChannelsPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
