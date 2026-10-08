using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsGuestMessagingConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Determines if a user is allowed to edit their own messages.')]
    [System.Nullable[System.Boolean]] $AllowUserEditMessage

    [DscProperty()]
    [System.ComponentModel.Description('Determines if a user is allowed to delete their own messages.')]
    [System.Nullable[System.Boolean]] $AllowUserDeleteMessage

    [DscProperty()]
    [System.ComponentModel.Description('Determines if a user is allowed to chat.')]
    [System.Nullable[System.Boolean]] $AllowUserChat

    [DscProperty()]
    [System.ComponentModel.Description('Turn this setting on to allow users to permanently delete their one-on-one chat, group chat, and meeting chat as participants (this deletes the chat only for them, not other users in the chat).')]
    [System.Nullable[System.Boolean]] $AllowUserDeleteChat

    [DscProperty()]
    [System.ComponentModel.Description('Determines Giphy content restrictions. Default value is Moderate, other options are Strict and NoRestriction.')]
    [ValidateSet('Moderate', 'Strict', 'NoRestriction')]
    [System.String] $GiphyRatingType

    [DscProperty()]
    [System.ComponentModel.Description('Determines if memes are available for use.')]
    [System.Nullable[System.Boolean]] $AllowMemes

    [DscProperty()]
    [System.ComponentModel.Description('Determines if stickers are available for use.')]
    [System.Nullable[System.Boolean]] $AllowStickers

    [DscProperty()]
    [System.ComponentModel.Description('Determines if Giphy are available for use.')]
    [System.Nullable[System.Boolean]] $AllowGiphy

    [DscProperty()]
    [System.ComponentModel.Description('Determines if Immersive Reader is enabled.')]
    [System.Nullable[System.Boolean]] $AllowImmersiveReader

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

    [TeamsGuestMessagingConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsGuestMessagingConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Teams Guest Messaging settings'

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $config = Get-CsTeamsGuestMessagingConfiguration -ErrorAction Stop

            return $this.AsResult(@{
                AllowUserEditMessage      = $config.AllowUserEditMessage
                AllowUserDeleteMessage    = $config.AllowUserDeleteMessage
                AllowUserChat             = $config.AllowUserChat
                AllowUserDeleteChat       = $config.AllowUserDeleteChat
                AllowGiphy                = $config.AllowGiphy
                GiphyRatingType           = $config.GiphyRatingType
                AllowMemes                = $config.AllowMemes
                AllowStickers             = $config.AllowStickers
                AllowImmersiveReader      = $config.AllowImmersiveReader
                IsSingleInstance          = 'Yes'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
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
        $Identity = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration of Teams Guest Messaging settings'

        $boundParameters = $this.GetBoundParameters()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        # Check that at least one optional parameter is specified
        $inputValues = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters.Clone()
        foreach ($item in $inputValues.GetEnumerator())
        {
            if ([System.String]::IsNullOrEmpty($item.Value))
            {
                $inputValues.Remove($item.Key) | Out-Null
            }
        }

        if ($inputValues.Count -eq 0)
        {
            throw "You need to specify at least one optional parameter for the [TeamsGuestMessagingConfiguration] instance {$Identity}"
        }

        $SetParams = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters.Clone()
        $SetParams.Add('Identity', 'Global')
        $SetParams.Remove('IsSingleInstance') | Out-Null
        Set-CsTeamsGuestMessagingConfiguration @SetParams
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

    hidden [TeamsGuestMessagingConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsGuestMessagingConfiguration])
        {
            return $Values
        }

        $result = [TeamsGuestMessagingConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
