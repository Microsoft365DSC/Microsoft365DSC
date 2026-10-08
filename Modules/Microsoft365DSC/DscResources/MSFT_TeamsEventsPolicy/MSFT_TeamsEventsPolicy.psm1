using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsEventsPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Events Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Events Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs if a user is allowed to edit the communication emails in Teams Town Hall or Teams Webinar events.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AllowEmailEditing

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether attendance and engagement reports are allowed for events. Possible values are: Enabled, Disabled, ForceEnabled, ForceDisabled.')]
    [ValidateSet('Enabled', 'Disabled', 'ForceEnabled', 'ForceDisabled')]
    [System.String] $AllowEngagementReport

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs access to the integrations tab in the event creation workflow.')]
    [System.Nullable[System.Boolean]] $AllowEventIntegrations

    [DscProperty()]
    [System.ComponentModel.Description('Determines if webinars are allowed by the policy or not.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AllowWebinars

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs if a user can create town halls using Teams Events.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AllowTownhalls

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs which users in a tenant can add which registration form questions to an event registration page for attendees to answer when registering for the event.')]
    [ValidateSet('DefaultOnly', 'DefaultAndPredefinedOnly', 'AllQuestions')]
    [System.String] $AllowedQuestionTypesInRegistrationForm

    [DscProperty()]
    [System.ComponentModel.Description('This setting describes how IT admins can control which types of Town Hall attendees can have their recordings published.')]
    [ValidateSet('None', 'InviteOnly', 'EveryoneInCompanyIncludingGuests', 'Everyone')]
    [System.String] $AllowedTownhallTypesForRecordingPublish

    [DscProperty()]
    [System.ComponentModel.Description('This setting describes how IT admins can control which types of webinar attendees can have their recordings published.')]
    [ValidateSet('None', 'InviteOnly', 'EveryoneInCompanyIncludingGuests', 'Everyone')]
    [System.String] $AllowedWebinarTypesForRecordingPublish

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $BackroomChat

    [DscProperty()]
    [System.ComponentModel.Description('This setting will enable Tenant Admins to specify if an organizer of a Teams Premium town hall may add an app that is accessible by everyone, including attendees, in a broadcast style Event including a Town hall.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $BroadcastPremiumApps

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [ValidateSet('eOTP', 'None')]
    [System.String] $ExternalPresenterJoinVerification

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs if a user can create Immersive Events using Teams Events.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $ImmersiveEvents

    [DscProperty()]
    [System.ComponentModel.Description('Controls what information is shown in attendance reports. Possible values are: FullInformation, IdentityOnly.')]
    [ValidateSet('FullInformation', 'IdentityOnly')]
    [System.String] $InfoShownInReportMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether recording is allowed in a user''s townhall.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $RecordingForTownhall

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether recording is allowed in a user''s webinar.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $RecordingForWebinar

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $Registration

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs what identity types may attend a Town hall that is scheduled by a particular person or group that is assigned this policy.')]
    [ValidateSet('Everyone', 'EveryoneInOrganizationAndGuests')]
    [System.String] $TownhallEventAttendeeAccess

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether transcriptions are allowed in a user''s townhall.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $TranscriptionForTownhall

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether transcriptions are allowed in a user''s webinar.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $TranscriptionForWebinar

    [DscProperty()]
    [System.ComponentModel.Description('Defines who is allowed to join the event.')]
    [ValidateSet('Everyone', 'EveryoneInCompanyExcludingGuests')]
    [System.String] $EventAccessType

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs whether the user can enable the Comment Stream chat experience for Town Halls.')]
    [ValidateSet('Optimized', 'None')]
    [System.String] $TownhallChatExperience

    [DscProperty()]
    [System.ComponentModel.Description('This policy sets the maximum video resolution supported in Town hall events. Possible values are: Max720p: Town halls support video resolution up to 720p. Max1080p: Town halls support video resolution up to 1080p. MicrosoftManaged: Town halls will support video resolution up to 720p except for those customers whose networks have been assessed by Microsoft to support up to 1080p.')]
    [ValidateSet('Max720p', 'Max1080p', 'MicrosoftManaged')]
    [System.String] $TownhallMaxResolution

    [DscProperty()]
    [System.ComponentModel.Description('This setting governs whether the global admin disables this property and prevents the organizers from creating town halls that use Microsoft eCDN even though they have been assigned a Teams Premium license.')]
    [System.Nullable[System.Boolean]] $UseMicrosoftECDN

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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter = '*'

    [TeamsEventsPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsEventsPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Events Policy {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsEventsPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Events Policy {$($this.Identity)}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Events Policy {$($this.Identity)}"

            $result = @{
                Identity                                = $this.Identity
                Description                             = $policy.Description
                AllowWebinars                           = $policy.AllowWebinars
                BackroomChat                            = $policy.BackroomChat
                BroadcastPremiumApps                    = $policy.BroadcastPremiumApps
                EventAccessType                         = $policy.EventAccessType
                ExternalPresenterJoinVerification       = $policy.ExternalPresenterJoinVerification
                AllowEmailEditing                       = $policy.AllowEmailEditing
                AllowEngagementReport                   = $policy.AllowEngagementReport
                AllowEventIntegrations                  = $policy.AllowEventIntegrations
                AllowTownhalls                          = $policy.AllowTownhalls
                AllowedQuestionTypesInRegistrationForm  = $policy.AllowedQuestionTypesInRegistrationForm
                AllowedWebinarTypesForRecordingPublish  = $policy.AllowedWebinarTypesForRecordingPublish
                AllowedTownhallTypesForRecordingPublish = $policy.AllowedTownhallTypesForRecordingPublish
                ImmersiveEvents                         = $policy.ImmersiveEvents
                InfoShownInReportMode                   = $policy.InfoShownInReportMode
                RecordingForTownhall                    = $policy.RecordingForTownhall
                RecordingForWebinar                     = $policy.RecordingForWebinar
                Registration                            = $policy.Registration
                TownhallChatExperience                  = $policy.TownhallChatExperience
                TownhallEventAttendeeAccess             = $policy.TownhallEventAttendeeAccess
                TownhallMaxResolution                   = $policy.TownhallMaxResolution
                TranscriptionForTownhall                = $policy.TranscriptionForTownhall
                TranscriptionForWebinar                 = $policy.TranscriptionForWebinar
                UseMicrosoftECDN                        = $policy.UseMicrosoftECDN
                Ensure                                  = 'Present'
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
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

        Write-Verbose -Message "Setting Teams Events Policy {$($this.Identity)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Events Policy {$($this.Identity)}"
            New-CsTeamsEventsPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Events Policy {$($this.Identity)}"
            Set-CsTeamsEventsPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Events Policy {$($this.Identity)}"
            Remove-CsTeamsEventsPolicy -Identity $this.Identity -Confirm:$false
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
            [array]$policies = Get-CsTeamsEventsPolicy -Filter $this.Filter -ErrorAction Stop
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

    hidden [TeamsEventsPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsEventsPolicy])
        {
            return $Values
        }

        $result = [TeamsEventsPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
