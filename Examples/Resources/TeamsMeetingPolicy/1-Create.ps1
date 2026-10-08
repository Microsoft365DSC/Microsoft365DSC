<#
This example adds a new Teams Meeting Policy.
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
        TeamsMeetingPolicy 'TeamsMeetingPolicy-Example'
        {
            Identity                                     = "Corporate Meeting Policy"
            AIInterpreter                                = "Enabled"
            AllowAnnotations                             = $true
            AllowAnonymousUsersToDialOut                 = $false
            AllowAnonymousUsersToJoinMeeting             = $true
            AllowAnonymousUsersToStartMeeting            = $false
            AllowAvatarsInGallery                        = $true
            AllowBreakoutRooms                           = $true
            AllowCartCaptionsScheduling                  = "EnabledUserOverride"
            AllowChannelMeetingScheduling                = $true
            AllowCloudRecording                          = $true
            AllowDocumentCollaboration                   = "Enabled"
            AllowedStreamingMediaInput                   = "RTMP"
            AllowedUsersForMeetingDetails                = "Everyone"
            AllowEngagementReport                        = "Enabled"
            AllowExternalNonTrustedMeetingChat           = $false
            AllowExternalParticipantGiveRequestControl   = $false
            AllowImmersiveView                           = $true
            AllowIntelligentRecap                        = $true
            AllowIPAudio                                 = $true
            AllowIPVideo                                 = $true
            AllowMeetingCoach                            = $true
            AllowMeetingKnowledgeGeneration              = $true
            AllowMeetingReactions                        = $true
            AllowMeetingRegistration                     = $true
            AllowMeetNow                                 = $true
            AllowMultipleScreenshare                     = $true
            AllowNDIStreaming                            = $false
            AllowNetworkConfigurationSettingsLookup      = $false
            AllowOrganizersToOverrideLobbySettings       = $true
            AllowOutlookAddIn                            = $true
            AllowParticipantGiveRequestControl           = $true
            AllowPowerPointSharing                       = $true
            AllowPrivateMeetingScheduling                = $true
            AllowPrivateMeetNow                          = $true
            AllowPSTNUsersToBypassLobby                  = $false
            AllowRecordingStorageOutsideRegion           = $false
            AllowSharedNotes                             = $true
            AllowTasksFromTranscript                     = "Enabled"
            AllowTranscription                           = $true
            AllowUserToJoinExternalMeeting               = "FederatedOnly"
            AllowWatermarkCustomizationForCameraVideo    = $false
            AllowWatermarkCustomizationForScreenSharing  = $false
            AllowWatermarkForCameraVideo                 = $true
            AllowWatermarkForScreenSharing               = $true
            AllowWhiteboard                              = $true
            AnonymousUserAuthenticationMethod            = "OneTimePasscode"
            AttendeeIdentityMasking                      = "Disabled"
            AudibleRecordingNotification                 = "AllAttendees"
            AutoAdmittedUsers                            = "EveryoneInCompany"
            AutomaticallyStartCopilot                    = "Disabled"
            AutoRecording                                = "Disabled"
            BackroomChat                                 = "Enabled"
            BlockedAnonymousJoinClientTypes              = "ACS"
            CaptchaVerificationForMeetingJoin            = "AnonymousUsersAndUntrustedOrganizations"
            ChannelRecordingDownload                     = "Allow"
            ConditionalAccessAttendeeVerification        = $true
            ConnectToMeetingControls                     = "Enabled"
            ContentSharingInExternalMeetings             = "EnabledForTrustedOrgs"
            Copilot                                      = "EnabledWithTranscript"
            CopyRestriction                              = $false
            DesignatedPresenterRoleMode                  = "EveryoneInCompanyUserOverride"
            Description                                  = "Meeting defaults for corporate staff"
            DetectSensitiveContentDuringScreenSharing    = $true
            DisableAudioAnnouncementsForResourceAccounts = $false
            EnableExternalRecordingDetection             = $true
            EnablePreMeetingConsent                      = $false
            EnrollUserOverride                           = "Enabled"
            ExplicitRecordingConsent                     = "Disabled"
            ExternalBotAccessMode                        = "RequireApprovalWhenDetected"
            ExternalMeetingJoin                          = "EnabledForTrustedOrgs"
            FilterProfanityInTranscript                  = "Enabled"
            InfoShownInReportMode                        = "FullInformation"
            IntelligentRecapDocxFileExpirationDays       = 120
            IPAudioMode                                  = "EnabledOutgoingIncoming"
            IPVideoMode                                  = "EnabledOutgoingIncoming"
            LiveCaptionsEnabledType                      = "DisabledUserOverride"
            LiveInterpretationEnabledType                = "DisabledUserOverride"
            LiveStreamingMode                            = "Enabled"
            LobbyChat                                    = "Enabled"
            MediaBitRateKb                               = 50000
            MeetingChatEnabledType                       = "Enabled"
            MeetingInviteLanguages                       = "en-US"
            MeetingKnowledgeExpirationDays               = 365
            NewMeetingRecordingExpirationDays            = 120
            NoiseSuppressionForDialInParticipants        = "Enabled"
            ParticipantNameChange                        = "Disabled"
            ParticipantSlideControl                      = "EveryoneInOrganization"
            PasscodeComplexity                           = "Default"
            PreferredMeetingProviderForIslandsMode       = "TeamsAndSfb"
            PreventComplianceRecording                   = "None"
            QnAEngagementMode                            = "Enabled"
            RealTimeText                                 = "Enabled"
            RecordingAndTranscriptionAudioNotification   = "Enabled"
            RoomAttributeUserOverride                    = "Attribute"
            RoomPeopleNameUserOverride                   = "On"
            ScreenSharingMode                            = "EntireScreen"
            SetRecordingAndTranscriptOwnership           = "Disabled"
            SmsNotifications                             = "OnAllowOrganizerOverride"
            SpeakerAttributionMode                       = "EnabledUserOverride"
            StreamingAttendeeMode                        = "Enabled"
            SyntheticMediaDetection                      = "Enabled"
            TeamsCameraFarEndPTZMode                     = "AutoAcceptInTenant"
            UsersCanAdmitFromLobby                       = "OrganizerAndCoOrganizersOnly"
            VideoFiltersMode                             = "BlurAndDefaultBackgrounds"
            VoiceIsolation                               = "Enabled"
            VoiceSimulationInInterpreter                 = "Disabled"
            WatermarkForAnonymousUsers                   = "WatermarkWithDisplayName"
            WatermarkForCameraVideoOpacity               = 40
            WatermarkForCameraVideoPattern               = "Tiled"
            WatermarkForScreenSharingOpacity             = 40
            WatermarkForScreenSharingPattern             = "Tiled"
            WhoCanRegister                               = "EveryoneInCompany"
            Ensure                                       = "Present"
            ApplicationId                                = $ApplicationId
            TenantId                                     = $TenantId
            CertificateThumbprint                        = $CertificateThumbprint
        }
    }
}
