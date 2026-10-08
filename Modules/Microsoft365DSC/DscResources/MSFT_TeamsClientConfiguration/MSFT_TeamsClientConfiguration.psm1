using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsClientConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether users are able to leverage Box as a third party storage solution in Microsoft Teams. If $true, users will be able to add Box in the client and interact with the files stored there.')]
    [System.Nullable[System.Boolean]] $AllowBox

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether users are able to leverage DropBox as a third party storage solution in Microsoft Teams. If $true, users will be able to add DropBox in the client and interact with the files stored there.')]
    [System.Nullable[System.Boolean]] $AllowDropBox

    [DscProperty()]
    [System.ComponentModel.Description('When set to $true, mail hooks are enabled, and users can post messages to a channel by sending an email to the email address of Teams channel.')]
    [System.Nullable[System.Boolean]] $AllowEmailIntoChannel

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether users are able to leverage GoogleDrive as a third party storage solution in Microsoft Teams. If $true, users will be able to add Google Drive in the client and interact with the files stored there.')]
    [System.Nullable[System.Boolean]] $AllowGoogleDrive

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether or not guest users in your organization will have access to the Teams client. If $true, guests in your tenant will be able to access the Teams client. Note that this setting has a core dependency on Guest Access being enabled in your Office 365 tenant.')]
    [System.Nullable[System.Boolean]] $AllowGuestUser

    [DscProperty()]
    [System.ComponentModel.Description('When set to $true, users will be able to see the organizational chart icon other users'' contact cards, and when clicked, this icon will display the detailed organizational chart.')]
    [System.Nullable[System.Boolean]] $AllowOrganizationTab

    [DscProperty()]
    [System.ComponentModel.Description('Surface Hub uses a device account to provide email and collaboration services (IM, video, voice). This device account is used as the originating identity (the from party) when sending email, IM, and placing calls. As this account is not coming from an individual, identifiable user, it is deemed anonymous because it originated from the Surface Hub''s device account. If set to $true, these device accounts will be able to send chat messages in Skype for Business Online (does not apply to Microsoft Teams).')]
    [System.Nullable[System.Boolean]] $AllowResourceAccountSendMessage

    [DscProperty()]
    [System.ComponentModel.Description('When set to True, Supervised Chat is enabled for the tenant.')]
    [System.Nullable[System.Boolean]] $AllowRoleBasedChatPermissions

    [DscProperty()]
    [System.ComponentModel.Description('If set to $true, the Exchange address book policy (ABP) will be used to provide customized view of the global address book for each user. This is only a virtual separation and not a legal separation.')]
    [System.Nullable[System.Boolean]] $AllowScopedPeopleSearchandAccess

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether users are able to leverage ShareFile as a third party storage solution in Microsoft Teams. If $true, users will be able to add ShareFile in the client and interact with the files stored there.')]
    [System.Nullable[System.Boolean]] $AllowShareFile

    [DscProperty()]
    [System.ComponentModel.Description('When set to $true, Teams conversations automatically show up in Skype for Business for users that aren''t enabled for Teams.')]
    [System.Nullable[System.Boolean]] $AllowSkypeBusinessInterop

    [DscProperty()]
    [System.ComponentModel.Description('Designates whether users are able to leverage Egnyte as a third party storage solution in Microsoft Teams. If $true, users will be able to add Egnyte in the client and interact with the files stored there.')]
    [System.Nullable[System.Boolean]] $AllowEgnyte

    [DscProperty()]
    [System.ComponentModel.Description('This setting applies only to Skype for Business Online (not Microsoft Teams) and defines whether the user must provide a secondary form of authentication to access the meeting content from a resource device account. Meeting content is defined as files that are shared to the Content Bin - files that have been attached to the meeting.')]
    [ValidateSet('NotRequired', 'RequiredOutsideScheduleMeeting', 'AlwaysRequired')]
    [System.String] $ContentPin

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $ExtendedWorkInfoInPeopleSearch

    [DscProperty()]
    [System.ComponentModel.Description('Require a secondary form of authentication to access meeting content.')]
    [ValidateSet('NoAccess', 'PartialAccess', 'FullAccess')]
    [System.String] $ResourceAccountContentAccess

    [DscProperty()]
    [System.ComponentModel.Description('Senders domains can be further restricted to ensure that only allowed SMTP domains can send emails to the Teams channels. This is a comma-separated string of the domains you''d like to allow to send emails to Teams channels.')]
    [System.String[]] $RestrictedSenderList

    [DscProperty()]
    [System.ComponentModel.Description('This setting controls whether users are redirected from teams.microsoft.com to the unified domain teams.cloud.microsoft. Possible values are: MicrosoftDefault, Microsoft will manage redirection behavior. If no explicit admin configuration is set, users may be redirected automatically. Disabled, Users will remain on teams.microsoft.com. Use this if your organization''s apps are incompatible with the unified domain')]
    [ValidateSet('MicrosoftDefault', 'Disabled')]
    [System.String] $UseUnifiedDomain

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

    [TeamsClientConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsClientConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Client'

        try
        {
            if (-not $this.ResourceCache['exportMode'])
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $config = Get-CsTeamsClientConfiguration -ErrorAction Stop

            $result = @{
                AllowBox                         = $config.AllowBox
                AllowDropBox                     = $config.AllowDropBox
                AllowEgnyte                      = $config.AllowEgnyte
                AllowEmailIntoChannel            = $config.AllowEmailIntoChannel
                AllowGoogleDrive                 = $config.AllowGoogleDrive
                AllowGuestUser                   = $config.AllowGuestUser
                AllowOrganizationTab             = $config.AllowOrganizationTab
                AllowResourceAccountSendMessage  = $config.AllowResourceAccountSendMessage
                AllowRoleBasedChatPermissions    = $config.AllowRoleBasedChatPermissions
                AllowScopedPeopleSearchandAccess = $config.AllowScopedPeopleSearchandAccess
                AllowShareFile                   = $config.AllowShareFile
                AllowSkypeBusinessInterop        = $config.AllowSkypeBusinessInterop
                ContentPin                       = $config.ContentPin
                ExtendedWorkInfoInPeopleSearch   = $config.ExtendedWorkInfoInPeopleSearch
                ResourceAccountContentAccess     = $config.ResourceAccountContentAccess
                RestrictedSenderList             = $config.RestrictedSenderList
                UseUnifiedDomain                 = $config.UseUnifiedDomain
                IsSingleInstance                 = 'Yes'
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                TenantId                         = $this.TenantId
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                AccessTokens                     = $this.AccessTokens
            }
            if ([System.String]::IsNullOrEmpty($Config.RestrictedSenderList))
            {
                $result.Remove('RestrictedSenderList') | Out-Null
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

        Write-Verbose -Message 'Setting configuration of Teams Client'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ([System.String]::IsNullOrEmpty($this.RestrictedSenderList))
        {
            $SetParams.Remove('RestrictedSenderList') | Out-Null
        }
        else
        {
            # https://learn.microsoft.com/en-us/powershell/module/teams/set-csteamsclientconfiguration?view=teams-ps#-restrictedsenderlist
            # This is a semicolon-separated string of the domains you'd like to allow to send emails to Teams channels
            $tempValue = $SetParams['RestrictedSenderList'] -join ';'
            $SetParams.RestrictedSenderList = $tempValue
        }

        $SetParams.Remove('IsSingleInstance') | Out-Null
        $SetParams.Add('Identity', 'Global')
        Set-CsTeamsClientConfiguration @SetParams
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ([System.String]::IsNullOrEmpty($DesiredValues.RestrictedSenderList))
                {
                    $ValuesToCheck.Remove('RestrictedSenderList') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [TeamsClientConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsClientConfiguration])
        {
            return $Values
        }

        $result = [TeamsClientConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
