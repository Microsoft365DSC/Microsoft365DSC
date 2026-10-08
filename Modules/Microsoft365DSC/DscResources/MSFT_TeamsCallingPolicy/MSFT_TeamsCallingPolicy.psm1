using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsCallingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Calling Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Calling Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Enables the user to use the AI Interpreter related features. Possible values are: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AIInterpreter

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether meeting knowledge generation is allowed for calling when the user starts a recording, a transcription or Copilot.')]
    [System.Nullable[System.Boolean]] $AllowMeetingKnowledgeGeneration

    [DscProperty()]
    [System.ComponentModel.Description('The maximum amount a user can spend on outgoing PSTN calls, including all calls made through Pay-as-you-go Calling Plans and any overages on plans with bundled minutes.')]
    [System.Nullable[System.UInt32]] $CallingSpendUserLimit

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter lets you control how Copilot is used during calls and if transcription is needed to be turned on and saved after the call. Possible values: Enabled, EnabledWithTranscript, Disabled')]
    [ValidateSet('Enabled', 'EnabledWithTranscript', 'Disabled')]
    [System.String] $Copilot

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows an admin to enable or disable spend limits on PSTN calls for their user base.')]
    [System.Nullable[System.Boolean]] $EnableSpendLimits

    [DscProperty()]
    [System.ComponentModel.Description('Determines if MediaBypass is enabled for PSTN calls on specified Web platforms.')]
    [System.Nullable[System.Boolean]] $EnableWebPstnMediaBypass

    [DscProperty()]
    [System.ComponentModel.Description('This setting controls whether users must provide or obtain explicit consent before recording a 1:1 PSTN or Teams call. When enabled, both parties will receive a notification, and consent must be given before recording starts. Possible values: Enabled: Requires users to give and obtain explicit consent before starting a call recording. Disabled: Users are not required to obtain explicit consent before recording starts.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ExplicitRecordingConsent

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter lets you control how inbound federated calls should be routed. Possible values are: RegularIncoming, Unanswered, Voicemail.')]
    [ValidateSet('RegularIncoming', 'Unanswered', 'Voicemail')]
    [System.String] $InboundFederatedCallRoutingTreatment

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter lets you control how inbound PSTN calls should be routed. Possible values are: RegularIncoming, Unanswered, Voicemail, UserOverride.')]
    [ValidateSet('RegularIncoming', 'Unanswered', 'Voicemail', 'UserOverride')]
    [System.String] $InboundPstnCallRoutingTreatment

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter allows you to set the PopoutForIncomingPstnCalls setting''s URL path of the website to launch upon receiving incoming PSTN calls. This parameter accepts an HTTPS URL with less than 1024 characters. The URL can contain a {phone} placeholder that is replaced with the caller''s PSTN number in E.164 format when launched.')]
    [System.String] $PopoutAppPathForIncomingPstnCalls

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter allows you to control the tenant users'' ability to launch an external website URL automatically in the browser window upon incoming PSTN calls for specific users or user groups. Possible values are: Enabled, Disabled.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $PopoutForIncomingPstnCalls

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether users enabled for compliance recording are blocked from joining calls initiated or received by the user assigned to this policy. Possible values are: None, All.')]
    [ValidateSet('None', 'All')]
    [System.String] $PreventComplianceRecording

    [DscProperty()]
    [System.ComponentModel.Description('Allows users to use real time text during a call, allowing them to communicate by typing their messages in real time. Possible values are: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $RealTimeText

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether audio notifications are played when a recording or transcription starts or stops for the users assigned to this policy. Possible values are: Enabled, Disabled.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $RecordingAndTranscriptionAudioNotification

    [DscProperty()]
    [System.ComponentModel.Description('TBD. Possible values are: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ReportCall

    [DscProperty()]
    [System.ComponentModel.Description('Controls if Teams calls are shown in the call log.')]
    [System.Nullable[System.Boolean]] $ShowTeamsCallsInCallLog

    [DscProperty()]
    [System.ComponentModel.Description('Controls the alerts shown to the user when AI-based detection identifies a voice phishing attempt during a live inbound Teams call. Possible values are: BannerAndAudio, Banner, Audio, None.')]
    [ValidateSet('BannerAndAudio', 'Banner', 'Audio', 'None')]
    [System.String] $VoicePhishingDetection

    [DscProperty()]
    [System.ComponentModel.Description('Enables the user to use the voice simulation feature while being AI interpreted. Possible values are: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $VoiceSimulationInInterpreter

    [DscProperty()]
    [System.ComponentModel.Description('Controls all calling capabilities in Teams. Turning this off will turn off all calling functionality in Teams. If you use Skype for Business for calling, this policy will not affect calling functionality in Skype for Business.')]
    [System.Nullable[System.Boolean]] $AllowPrivateCalling

    [DscProperty()]
    [System.ComponentModel.Description('Enables inbound calls to be routed to voice mail. Valid options are: AlwaysEnabled, AlwaysDisabled, UserOverride.')]
    [ValidateSet('AlwaysEnabled', 'AlwaysDisabled', 'UserOverride')]
    [System.String] $AllowVoicemail

    [DscProperty()]
    [System.ComponentModel.Description('Enables inbound calls to be routed to call groups.')]
    [System.Nullable[System.Boolean]] $AllowCallGroups

    [DscProperty()]
    [System.ComponentModel.Description('Enables inbound calls to be routed to delegates; allows delegates to make outbound calls on behalf of the users for whom they have delegated permissions.')]
    [System.Nullable[System.Boolean]] $AllowDelegation

    [DscProperty()]
    [System.ComponentModel.Description('Enables call forwarding or simultaneous ringing of inbound calls to other users in your tenant.')]
    [System.Nullable[System.Boolean]] $AllowCallForwardingToUser

    [DscProperty()]
    [System.ComponentModel.Description('Enables call forwarding or simultaneous ringing of inbound calls to any phone number.')]
    [System.Nullable[System.Boolean]] $AllowCallForwardingToPhone

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter provides the ability to configure call redirection capabilities on Teams phones.')]
    [ValidateSet('Enabled', 'Disabled', 'UserOverride')]
    [System.String] $AllowCallRedirect

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the user is allowed to use SIP devices for calling on behalf of a Teams client.')]
    [System.Nullable[System.Boolean]] $AllowSIPDevicesCalling

    [DscProperty()]
    [System.ComponentModel.Description('Allows PSTN calling from the Team web client')]
    [System.Nullable[System.Boolean]] $AllowWebPSTNCalling

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter to True will send calls through PSTN and incur charges rather than going through the network and bypassing the tolls.')]
    [System.Nullable[System.Boolean]] $PreventTollBypass

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter lets you configure how incoming calls are handled when a user is already in a call or conference or has a call placed on hold. New or incoming calls will be rejected with a busy signal. Valid options are: Enabled, Disabled and Unanswered.')]
    [ValidateSet('Enabled', 'Disabled', 'Unanswered', 'UserOverride')]
    [System.String] $BusyOnBusyEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Sets the expiration of the recorded 1:1 calls.')]
    [System.Nullable[System.UInt32]] $CallRecordingExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter allows you to turn on or turn off music on hold when a PSTN caller is placed on hold. It is turned on by default. Valid options are: Enabled, Disabled, UserOverride. For now setting the value to UserOverride is the same as Enabled. This setting does not apply to call park and SLA boss delegate features. Valid options are: Enabled, Disabled, UserOverride.')]
    [ValidateSet('Enabled', 'Disabled', 'UserOverride')]
    [System.String] $MusicOnHoldEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter to True will allows 1:1 Calls to be recorded.')]
    [System.Nullable[System.Boolean]] $AllowCloudRecordingForCalls

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether post-meeting captions and transcriptions are allowed in a user''s meetings. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowTranscriptionforCalling

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether real-time captions are available for the user in Teams meetings. Set this to DisabledUserOverride to allow user to turn on live captions. Set this to Disabled to prohibit.')]
    [ValidateSet('DisabledUserOverride', 'Disabled')]
    [System.String] $LiveCaptionsEnabledTypeForCalling

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows the tenant admin to enable or disable the Auto-Answer setting. Valid options are: Enabled, Disabled.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $AutoAnswerEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter determines whether calls identified as Spam will be rejected or not (probably). Valid options are: Enabled, Disabled.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $SpamFilteringEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policyexists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin.')]
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

    [TeamsCallingPolicy] Get()
    {
        ${$Identity} = $null
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsCallingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Calling Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsCallingPolicy -Identity $this.Identity -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Calling Policy ${$Identity}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Teams Calling Policy {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                                   = $this.Identity
                AIInterpreter                              = $policy.AIInterpreter
                AllowMeetingKnowledgeGeneration            = $policy.AllowMeetingKnowledgeGeneration
                AllowPrivateCalling                        = $policy.AllowPrivateCalling
                AllowWebPSTNCalling                        = $policy.AllowWebPSTNCalling
                AllowVoicemail                             = $policy.AllowVoicemail
                AllowCallGroups                            = $policy.AllowCallGroups
                AllowDelegation                            = $policy.AllowDelegation
                AllowCallForwardingToUser                  = $policy.AllowCallForwardingToUser
                AllowCallForwardingToPhone                 = $policy.AllowCallForwardingToPhone
                AllowCallRedirect                          = $policy.AllowCallRedirect
                AllowSIPDevicesCalling                     = $policy.AllowSIPDevicesCalling
                CallingSpendUserLimit                      = $policy.CallingSpendUserLimit
                Copilot                                    = $policy.Copilot
                Description                                = $policy.Description
                EnableSpendLimits                          = $policy.EnableSpendLimits
                EnableWebPstnMediaBypass                   = $policy.EnableWebPstnMediaBypass
                ExplicitRecordingConsent                   = $policy.ExplicitRecordingConsent
                InboundFederatedCallRoutingTreatment       = $policy.InboundFederatedCallRoutingTreatment
                InboundPstnCallRoutingTreatment            = $policy.InboundPstnCallRoutingTreatment
                PopoutAppPathForIncomingPstnCalls          = $policy.PopoutAppPathForIncomingPstnCalls
                PopoutForIncomingPstnCalls                 = $policy.PopoutForIncomingPstnCalls
                PreventComplianceRecording                 = $policy.PreventComplianceRecording
                PreventTollBypass                          = $policy.PreventTollBypass
                RealTimeText                               = $policy.RealTimeText
                RecordingAndTranscriptionAudioNotification = $policy.RecordingAndTranscriptionAudioNotification
                ReportCall                                 = $policy.ReportCall
                ShowTeamsCallsInCallLog                    = $policy.ShowTeamsCallsInCallLog
                BusyOnBusyEnabledType                      = $policy.BusyOnBusyEnabledType
                CallRecordingExpirationDays                = $policy.CallRecordingExpirationDays
                MusicOnHoldEnabledType                     = $policy.MusicOnHoldEnabledType
                AllowCloudRecordingForCalls                = $policy.AllowCloudRecordingForCalls
                AllowTranscriptionForCalling               = $policy.AllowTranscriptionForCalling
                LiveCaptionsEnabledTypeForCalling          = $policy.LiveCaptionsEnabledTypeForCalling
                AutoAnswerEnabledType                      = $policy.AutoAnswerEnabledType
                SpamFilteringEnabledType                   = $policy.SpamFilteringEnabledType
                VoicePhishingDetection                     = $policy.VoicePhishingDetection
                VoiceSimulationInInterpreter               = $policy.VoiceSimulationInInterpreter
                Ensure                                     = 'Present'
                Credential                                 = $this.Credential
                ApplicationId                              = $this.ApplicationId
                TenantId                                   = $this.TenantId
                CertificateThumbprint                      = $this.CertificateThumbprint
                CertificatePath                            = $this.CertificatePath
                CertificatePassword                        = $this.CertificatePassword
                ManagedIdentity                            = $this.ManagedIdentity
                AccessTokens                               = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Calling Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()

        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Calling Policy {$($this.Identity)}"
            New-CsTeamsCallingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Calling Policy {$($this.Identity)}"
            Set-CsTeamsCallingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Calling Policy {$($this.Identity)}"
            Remove-CsTeamsCallingPolicy -Identity $this.Identity -Confirm:$false
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
            [array]$policies = Get-CsTeamsCallingPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Length)] $($policy.Identity)" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity
                    Ensure                = 'Present'
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
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [TeamsCallingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsCallingPolicy])
        {
            return $Values
        }

        $result = [TeamsCallingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
