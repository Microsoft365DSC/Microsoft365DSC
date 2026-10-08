<#
This example adds a new Teams Calling Policy.
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
        TeamsCallingPolicy 'TeamsCallingPolicy-Example'
        {
            Identity                                   = "CorporateCalling"
            Description                                = "Standard calling features for staff at the Amsterdam and Rotterdam offices" # Updated Property
            AIInterpreter                              = "Enabled"
            AllowMeetingKnowledgeGeneration            = $false
            CallingSpendUserLimit                      = 100
            Copilot                                    = "EnabledWithTranscript"
            EnableSpendLimits                          = $true
            EnableWebPstnMediaBypass                   = $true
            ExplicitRecordingConsent                   = "Enabled"
            InboundFederatedCallRoutingTreatment       = "RegularIncoming"
            InboundPstnCallRoutingTreatment            = "UserOverride"
            PopoutAppPathForIncomingPstnCalls          = "https://crm.contoso.com/callers/{phone}"
            PopoutForIncomingPstnCalls                 = "Enabled"
            PreventComplianceRecording                 = "None"
            RealTimeText                               = "Enabled"
            RecordingAndTranscriptionAudioNotification = "Enabled"
            ReportCall                                 = "Enabled"
            ShowTeamsCallsInCallLog                    = $true
            VoicePhishingDetection                     = "Banner"
            VoiceSimulationInInterpreter               = "Enabled"
            AllowPrivateCalling                        = $true
            AllowVoicemail                             = "UserOverride"
            AllowCallGroups                            = $true
            AllowDelegation                            = $true
            AllowCallForwardingToUser                  = $true
            AllowCallForwardingToPhone                 = $true
            AllowCallRedirect                          = "Enabled"
            AllowSIPDevicesCalling                     = $true
            AllowWebPSTNCalling                        = $true
            PreventTollBypass                          = $true
            BusyOnBusyEnabledType                      = "Enabled"
            CallRecordingExpirationDays                = 60
            MusicOnHoldEnabledType                     = "Enabled"
            AllowCloudRecordingForCalls                = $true
            AllowTranscriptionforCalling               = $true
            LiveCaptionsEnabledTypeForCalling          = "DisabledUserOverride"
            AutoAnswerEnabledType                      = "Disabled"
            SpamFilteringEnabledType                   = "Enabled"
            Ensure                                     = 'Present'
            ApplicationId                              = $ApplicationId
            TenantId                                   = $TenantId
            CertificateThumbprint                      = $CertificateThumbprint
        }
    }
}
