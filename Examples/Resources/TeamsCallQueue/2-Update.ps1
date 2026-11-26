<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        TeamsCallQueue "TeamsCallQueue-Example"
        {
            Name                                                 = "Contoso Support Queue"
            AgentAlertTime                                       = 30
            AllowOptOut                                          = $true
            DistributionLists                                    = @("<team-group-id>")
            UseDefaultMusicOnHold                                = $true
            WelcomeTextToSpeechPrompt                            = "Thank you for calling Contoso Support. An agent will be with you shortly." # Updated Property
            OverflowAction                                       = "Forward"
            OverflowActionTarget                                 = "<resource-account-object-id>"
            OverflowThreshold                                    = 50
            OverflowActionCallPriority                           = 3
            OverflowRedirectPersonTextToSpeechPrompt             = "Please hold while we transfer you to the next available supervisor."
            OverflowRedirectVoiceAppTextToSpeechPrompt           = "Transferring you to the Contoso main menu."
            OverflowRedirectPhoneNumberTextToSpeechPrompt        = "Transferring you to our after-hours answering service."
            EnableOverflowSharedVoicemailTranscription           = $true
            EnableOverflowSharedVoicemailSystemPromptSuppression = $false
            TimeoutAction                                        = "Forward"
            TimeoutActionTarget                                  = "<resource-account-object-id>"
            TimeoutThreshold                                     = 1200
            TimeoutActionCallPriority                            = 2
            TimeoutRedirectPersonTextToSpeechPrompt              = "Transferring you to the support supervisor."
            TimeoutRedirectVoiceAppTextToSpeechPrompt            = "Returning you to the Contoso main menu."
            TimeoutRedirectPhoneNumberTextToSpeechPrompt         = "Transferring you to our answering service."
            EnableTimeoutSharedVoicemailTranscription            = $true
            EnableTimeoutSharedVoicemailSystemPromptSuppression  = $false
            NoAgentAction                                        = "Forward"
            NoAgentActionTarget                                  = "<resource-account-object-id>"
            NoAgentActionCallPriority                            = 1
            NoAgentApplyTo                                       = "NewCalls"
            NoAgentRedirectPersonTextToSpeechPrompt              = "Transferring you to the duty manager."
            NoAgentRedirectVoiceAppTextToSpeechPrompt            = "Transferring you to the Contoso main menu."
            NoAgentRedirectPhoneNumberTextToSpeechPrompt         = "Transferring you to our answering service."
            EnableNoAgentSharedVoicemailTranscription            = $true
            EnableNoAgentSharedVoicemailSystemPromptSuppression  = $false
            RoutingMethod                                        = "RoundRobin"
            PresenceBasedRouting                                 = $true
            ConferenceMode                                       = $true
            LanguageId                                           = "en-US"
            Users                                                = @("AdeleV@$TenantId", "MeganB@$TenantId")
            AuthorizedUsers                                      = @("AdeleV@$TenantId")
            HideAuthorizedUsers                                  = @("MeganB@$TenantId")
            TextAnnouncementForCR                                = "This call may be recorded for quality and compliance purposes."
            TextAnnouncementForCRFailure                         = "Recording is unavailable, so this call will continue unrecorded."
            ComplianceRecordingForCallQueueTemplateId            = @("<compliance-recording-call-queue-template-id>")
            SharedCallQueueHistoryTemplateId                     = "<shared-call-queue-history-template-id>"
            IsCallbackEnabled                                    = $true
            CallbackRequestDtmf                                  = "Tone1"
            WaitTimeBeforeOfferingCallbackInSecond               = 180
            NumberOfCallsInQueueBeforeOfferingCallback           = 10
            CallToAgentRatioThresholdBeforeOfferingCallback      = 5
            CallbackOfferTextToSpeechPrompt                      = "Press 1 to keep your place in the queue and receive a call back."
            CallbackEmailNotificationTarget                      = "<team-group-id>"
            ServiceLevelThresholdResponseTimeInSecond            = 30
            ShouldOverwriteCallableChannelProperty               = $true
            ChannelId                                            = "<team-channel-id>"
            ChannelUserObjectId                                  = "<team-owner-object-id>"
            Ensure                                               = "Present"
            ApplicationId                                        = $ApplicationId
            TenantId                                             = $TenantId
            CertificateThumbprint                                = $CertificateThumbprint
        }
    }
}
