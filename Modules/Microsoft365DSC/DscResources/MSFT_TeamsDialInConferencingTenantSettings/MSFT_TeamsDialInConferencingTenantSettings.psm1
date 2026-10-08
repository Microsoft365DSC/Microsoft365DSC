using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsDialInConferencingTenantSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only accepted value is Yes.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the default value that gets assigned to the ''AllowPSTNOnlyMeetings'' setting of users when they are enabled for dial-in conferencing, or when a user''s dial-in conferencing provider is set to Microsoft. If set to $true, the ''AllowPSTNOnlyMeetings'' setting of the user will also be set to true. If $false, the user setting will be false. The default value for AllowPSTNOnlyMeetingsByDefault is $false.')]
    [System.Nullable[System.Boolean]] $AllowPSTNOnlyMeetingsByDefault

    [DscProperty()]
    [System.ComponentModel.Description('Automatically Migrate User Meetings.')]
    [System.Nullable[System.Boolean]] $AutomaticallyMigrateUserMeetings

    [DscProperty()]
    [System.ComponentModel.Description('Automatically replace ACP Provider.')]
    [System.Nullable[System.Boolean]] $AutomaticallyReplaceAcpProvider

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether advisory emails will be sent to users when the events listed below occur. Setting the parameter to $true enables the emails to be sent, $false disables the emails. The default is $true.')]
    [System.Nullable[System.Boolean]] $AutomaticallySendEmailsToUsers

    [DscProperty()]
    [System.ComponentModel.Description('Enable Dial out join confirmation.')]
    [System.Nullable[System.Boolean]] $EnableDialOutJoinConfirmation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if, by default, announcements are made as users enter and exit a conference call. Set to $true to enable notifications, $false to disable notifications. The default is $true.')]
    [System.Nullable[System.Boolean]] $EnableEntryExitNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the name of a user is recorded on entry to the conference. This recording is used during entry and exit notifications. Set to $true to enable name recording, set to $false to bypass name recording. The default is $true.')]
    [System.Nullable[System.Boolean]] $EnableNameRecording

    [DscProperty()]
    [System.ComponentModel.Description('Supported entry and exit announcement type.')]
    [System.String] $EntryExitAnnouncementsType

    [DscProperty()]
    [System.ComponentModel.Description('This parameter allows tenant administrators to configure masking of PSTN participant phone numbers in the roster view for Microsoft Teams meetings enabled for Audio Conferencing, scheduled within the organization. Possible values are MaskedForExternalUsers, MaskedForAllUsers or NoMasking')]
    [ValidateSet('MaskedForExternalUsers', 'MaskedForAllUsers', 'NoMasking')]
    [System.String] $MaskPstnNumbersType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether service numbers assigned to the tenant should be migrated to the new forest of the tenant when the tenant is migrated cross region. If false, service numbers will be released back to stock once the migration completes. This settings does not apply to ported-in numbers that are always migrated.')]
    [System.Nullable[System.Boolean]] $MigrateServiceNumbersOnCrossForestMove

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of digits in the automatically generated PINs. Organizers can enter their PIN to start a meeting they scheduled if they join via phone and are the first person to join. The minimum value is 4, the maximum is 12, and the default is 5.')]
    [System.Nullable[System.UInt32]] $PinLength

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if Private Meetings are enabled for the users in this tenant.')]
    [System.Nullable[System.Boolean]] $UseUniqueConferenceIds

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Global Admin.')]
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

    [TeamsDialInConferencingTenantSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsDialInConferencingTenantSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the Teams Dial In Conferencing Tenant Settings'

        try
        {
            $null = $this.Connect('MicrosoftTeams')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-CsOnlineDialInConferencingTenantSettings -ErrorAction Stop

            return $this.AsResult(@{
                IsSingleInstance                       = 'Yes'
                AllowPSTNOnlyMeetingsByDefault         = $instance.AllowPSTNOnlyMeetingsByDefault
                AutomaticallyMigrateUserMeetings       = $instance.AutomaticallyMigrateUserMeetings
                AutomaticallyReplaceAcpProvider        = $instance.AutomaticallyReplaceAcpProvider
                AutomaticallySendEmailsToUsers         = $instance.AutomaticallySendEmailsToUsers
                EnableDialOutJoinConfirmation          = $instance.EnableDialOutJoinConfirmation
                EnableEntryExitNotifications           = $instance.EnableEntryExitNotifications
                EnableNameRecording                    = $instance.EnableNameRecording
                EntryExitAnnouncementsType             = $instance.EntryExitAnnouncementsType
                MaskPstnNumbersType                    = $instance.MaskPstnNumbersType
                MigrateServiceNumbersOnCrossForestMove = $instance.MigrateServiceNumbersOnCrossForestMove
                PinLength                              = $instance.PinLength
                UseUniqueConferenceIds                 = $instance.UseUniqueConferenceIds
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePath                        = $this.CertificatePath
                CertificatePassword                    = $this.CertificatePassword
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Dial In Conferencing Tenant Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftTeams')

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetParameters.Remove('IsSingleInstance') | Out-Null

        try
        {
            Set-CsOnlineDialInConferencingTenantSettings @SetParameters
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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

    hidden [TeamsDialInConferencingTenantSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsDialInConferencingTenantSettings])
        {
            return $Values
        }

        $result = [TeamsDialInConferencingTenantSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
