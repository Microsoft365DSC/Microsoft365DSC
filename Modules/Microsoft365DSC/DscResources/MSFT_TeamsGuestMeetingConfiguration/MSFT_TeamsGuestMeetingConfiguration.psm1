using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsGuestMeetingConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether video is enabled in a user''s meetings or calls. Set this to TRUE to allow guests to share their video. Set this to FALSE to prohibit guests from sharing their video.')]
    [System.Nullable[System.Boolean]] $AllowIPVideo

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether real-time captions are available for guests in Teams meetings.')]
    [ValidateSet('Disabled', 'DisabledUserOverride')]
    [System.String] $LiveCaptionsEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Determines the mode in which guests can share a screen in calls or meetings. Set this to SingleApplication to allow the user to share an application at a given point in time. Set this to EntireScreen to allow the user to share anything on their screens. Set this to Disabled to prohibit the user from sharing their screens.')]
    [ValidateSet('Disabled', 'EntireScreen', 'SingleApplication')]
    [System.String] $ScreenSharingMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether guests can start ad-hoc meetings. Set this to TRUE to allow guests to start ad-hoc meetings. Set this to FALSE to prohibit guests from starting ad-hoc meetings.')]
    [System.Nullable[System.Boolean]] $AllowMeetNow

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $AllowMultipleScreenshare

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether guests can enable post-meeting captions and transcriptions in meetings. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowTranscription

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

    [TeamsGuestMeetingConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsGuestMeetingConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Guest Meeting settings'

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $config = Get-CsTeamsGuestMeetingConfiguration -ErrorAction Stop

            $result = @{
                AllowIPVideo             = $config.AllowIPVideo
                LiveCaptionsEnabledType  = $config.LiveCaptionsEnabledType
                ScreenSharingMode        = $config.ScreenSharingMode
                AllowMeetNow             = $config.AllowMeetNow
                AllowMultipleScreenshare = $config.AllowMultipleScreenshare
                AllowTranscription       = $config.AllowTranscription
                IsSingleInstance         = 'Yes'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Teams Guest Meeting settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetParams.Add('Identity', 'Global')
        $SetParams.Remove('IsSingleInstance') | Out-Null
        Set-CsTeamsGuestMeetingConfiguration @SetParams
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

    hidden [TeamsGuestMeetingConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsGuestMeetingConfiguration])
        {
            return $Values
        }

        $result = [TeamsGuestMeetingConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
