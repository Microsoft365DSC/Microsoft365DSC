using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMessagingConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if closed captions will be displayed, for Teams Video Clips, during playback. Possible values: True, False')]
    [System.Nullable[System.Boolean]] $EnableVideoMessageCaptions

    [DscProperty()]
    [System.ComponentModel.Description('This setting determines if chat regulation for internal communication in tenant is allowed. Possible Values: True, False')]
    [System.Nullable[System.Boolean]] $EnableInOrganizationChatControl

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables the use of custom emojis and reactions across the whole tenant. Upon enablement, admins and/or users can define a user group that is allowed. Possible Values: True, False')]
    [System.Nullable[System.Boolean]] $CustomEmojis

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables the availability of Viva Engage storylines in Teams chats across the whole tenant.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $Storyline

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables MessagingNotes integration across the whole tenant. Possible Values: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $MessagingNotes

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables weaponizable file detection in Teams messages in the tenant. Possible Values: Enabled, Disabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $FileTypeCheck

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables malicious URL detection in Teams messages in the tenant. Possible Values: Enabled, Disabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $UrlReputationCheck

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables content-based phishing detection for Teams messages in the tenant.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ContentBasedPhishingCheck

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables the end users to Report incorrect security detections in Teams messages in the tenant. Possible Values: Enabled, Disabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ReportIncorrectSecurityDetections

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables/disables Viva Engage Communities integration across the whole tenant.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $Communities

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
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
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsMessagingConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMessagingConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Teams Messaging Configuration"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $instance = Get-CsTeamsMessagingConfiguration -Identity 'Global'
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message 'A Teams Messaging Configuration with Identity {Global} was found'
            $results = @{
                Communities                       = $instance.Communities
                ContentBasedPhishingCheck         = $instance.ContentBasedPhishingCheck
                CustomEmojis                      = $instance.CustomEmojis
                EnableInOrganizationChatControl   = $instance.EnableInOrganizationChatControl
                EnableVideoMessageCaptions        = $instance.EnableVideoMessageCaptions
                FileTypeCheck                     = $instance.FileTypeCheck
                MessagingNotes                    = $instance.MessagingNotes
                ReportIncorrectSecurityDetections = $instance.ReportIncorrectSecurityDetections
                Storyline                         = $instance.Storyline
                UrlReputationCheck                = $instance.UrlReputationCheck
                IsSingleInstance                  = 'Yes'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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

        $null = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $updateParameters.Remove('IsSingleInstance') | Out-Null
        Write-Verbose -Message 'Updating the Teams Messaging Configuration with Identity {Global}'

        Set-CsTeamsMessagingConfiguration @updateParameters -Identity 'Global' | Out-Null
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
            [array]$getValue = Get-CsTeamsMessagingConfiguration -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
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

                $this.ExportedInstance = $config
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

    hidden [TeamsMessagingConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMessagingConfiguration])
        {
            return $Values
        }

        $result = [TeamsMessagingConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
