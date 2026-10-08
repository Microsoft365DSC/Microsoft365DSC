using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMeetingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Meeting Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Meeting Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Enables the user to use the AI Interpreter related features. Possible values: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AIInterpreter

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can use the Annotation feature')]
    [System.Nullable[System.Boolean]] $AllowAnnotations

    [DscProperty()]
    [System.ComponentModel.Description('CURRENTLY DISABLED: Determines whether anonymous users can use the Call Me At feature for meeting audio.')]
    [System.Nullable[System.Boolean]] $AllowAnonymousUsersToDialOut

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether anonymous users can join the meetings that impacted users organize. Set this to TRUE to allow anonymous users to join a meeting. Set this to FALSE to prohibit them from joining a meeting.')]
    [System.Nullable[System.Boolean]] $AllowAnonymousUsersToJoinMeeting

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether anonymous users can initiate a meeting. Set this to TRUE to allow anonymous users to initiate a meeting. Set this to FALSE to prohibit them from initiating a meeting.')]
    [System.Nullable[System.Boolean]] $AllowAnonymousUsersToStartMeeting

    [DscProperty()]
    [System.ComponentModel.Description('If admins disable avatars in 2D meetings, then users cannot represent themselves as avatars in the Gallery view. This does not disable avatars in Immersive view.')]
    [System.Nullable[System.Boolean]] $AllowAvatarsInGallery

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not meetings created by users with this policy are able to utilize the Breakout Rooms feature.')]
    [System.Nullable[System.Boolean]] $AllowBreakoutRooms

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can add a URL for captions from a Communications Access Real-Time Translation (CART) captioner for providing real-time captions in meetings.')]
    [ValidateSet('EnabledUserOverride', 'DisabledUserOverride', 'Disabled')]
    [System.String] $AllowCartCaptionsScheduling

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can schedule channel meetings. Set this to TRUE to allow a user to schedule channel meetings. Set this to FALSE to prohibit the user from scheduling channel meetings. Note this only restricts from scheduling and not from joining a meeting scheduled by another user.')]
    [System.Nullable[System.Boolean]] $AllowChannelMeetingScheduling

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether cloud recording is allowed in a user''s meetings. Set this to TRUE to allow the user to be able to record meetings. Set this to FALSE to prohibit the user from recording meetings.')]
    [System.Nullable[System.Boolean]] $AllowCloudRecording

    [DscProperty()]
    [System.ComponentModel.Description('This setting will allow admins to choose which users will be able to use the Document Collaboration feature.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $AllowDocumentCollaboration

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $AllowMultipleScreenshare

    [DscProperty()]
    [System.ComponentModel.Description('Enables the use of RTMP-In in Teams meetings.')]
    [System.String] $AllowedStreamingMediaInput

    [DscProperty()]
    [System.ComponentModel.Description('Controls which users should have ability to see the meeting info details on join screen. ''None'' option should disable the feature completely. Possible Values: UsersAllowedToByPassTheLobby: Users who are able to bypass lobby can see the meeting info details. Everyone: All meeting participants can see the meeting info details.')]
    [ValidateSet('Everyone', 'UsersAllowedToByPassTheLobby')]
    [System.String] $AllowedUsersForMeetingDetails

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not a meeting Organizer can track join and leave times for all users within their meetings as well as download a roster.')]
    [ValidateSet('Enabled', 'Disabled', 'ForceEnabled')]
    [System.String] $AllowEngagementReport

    [DscProperty()]
    [System.ComponentModel.Description('This field controls whether a user is allowed to chat in external meetings with users from non trusted organizations.')]
    [System.Nullable[System.Boolean]] $AllowExternalNonTrustedMeetingChat

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether external participants can request or give control of screen sharing during meetings scheduled by this user. Set this to TRUE to allow the user to be able to give or request control. Set this to FALSE to prohibit an external user from giving or requesting control in a meeting.')]
    [System.Nullable[System.Boolean]] $AllowExternalParticipantGiveRequestControl

    [DscProperty()]
    [System.ComponentModel.Description('If admins have disabled avatars, this does not disable using avatars in Immersive view on Teams desktop or web. Additionally, it does not prevent users from joining the Teams meeting on VR headsets.')]
    [System.Nullable[System.Boolean]] $AllowImmersiveView

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether Intelligent Recap is allowed for the user''s meetings.')]
    [System.Nullable[System.Boolean]] $AllowIntelligentRecap

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether audio is enabled in a user''s meetings or calls. Set this to TRUE to allow the user to share their audioo. Set this to FALSE to prohibit the user from sharing their audio.')]
    [System.Nullable[System.Boolean]] $AllowIPAudio

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether video is enabled in a user''s meetings or calls. Set this to TRUE to allow the user to share their video. Set this to FALSE to prohibit the user from sharing their video.')]
    [System.Nullable[System.Boolean]] $AllowIPVideo

    [DscProperty()]
    [System.ComponentModel.Description('This setting will allow admins to allow users the option of turning on Meeting Coach during meetings, which provides users with private personalized feedback on their communication and inclusivity.')]
    [System.Nullable[System.Boolean]] $AllowMeetingCoach

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether an AI-generated meeting knowledge file is created for meetings organized by the user.')]
    [System.Nullable[System.Boolean]] $AllowMeetingKnowledgeGeneration

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not meetings created by users with this policy are able to utilize the Meeting Reactions feature.')]
    [System.Nullable[System.Boolean]] $AllowMeetingReactions

    [DscProperty()]
    [System.ComponentModel.Description('Controls if a user can create a webinar meeting. The default value is True.')]
    [System.Nullable[System.Boolean]] $AllowMeetingRegistration

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can start ad-hoc meetings. Set this to TRUE to allow a user to start ad-hoc meetings. Set this to FALSE to prohibit the user from starting ad-hoc meetings.')]
    [System.Nullable[System.Boolean]] $AllowMeetNow

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user is able to use NDI (Network Device Interface) in meetings - both for output and input streams.')]
    [System.Nullable[System.Boolean]] $AllowNDIStreaming

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether network configuration setting lookups can be made by users who are not Enterprise Voice enabled. It is used to enable Network Roaming policies.')]
    [System.Nullable[System.Boolean]] $AllowNetworkConfigurationSettingsLookup

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether organizers can override lobby settings for both VOIP and PSTN. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowOrganizersToOverrideLobbySettings

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can schedule Teams Meetings in Outlook desktop client. Set this to TRUE to allow the user to be able to schedule Teams meetings in Outlook client. Set this to FALSE to prohibit a user from scheduling Teams meeting in Outlook client.')]
    [System.Nullable[System.Boolean]] $AllowOutlookAddIn

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether participants can request or give control of screen sharing during meetings scheduled by this user. Set this to TRUE to allow the user to be able to give or request control. Set this to FALSE to prohibit the user from giving, requesting control in a meeting.')]
    [System.Nullable[System.Boolean]] $AllowParticipantGiveRequestControl

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether Powerpoint sharing is allowed in a user''s meetings. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowPowerPointSharing

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can schedule private meetings. Note this only restricts from scheduling and not from joining a meeting scheduled by another user. Set this to TRUE to allow a user to schedule private meetings. Set this to FALSE to prohibit the user from scheduling private meetings. Note this only restricts from scheduling and not from joining a meeting scheduled by another user.')]
    [System.Nullable[System.Boolean]] $AllowPrivateMeetingScheduling

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user can start private ad-hoc meetings. Set this to TRUE to allow a user to start private ad-hoc meetings. Set this to FALSE to prohibit the user from starting private ad-hoc meetings.')]
    [System.Nullable[System.Boolean]] $AllowPrivateMeetNow

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether PSTN users should be automatically admitted to the meetings. Set this to TRUE to allow the PSTN user to be able bypass the meetinglobby. Set this to FALSE to prohibit the PSTN user from bypassing the meetinglobby.')]
    [System.Nullable[System.Boolean]] $AllowPSTNUsersToBypassLobby

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether cloud recording can be stored out of region for go-local tenants where recording is not yet enabled.')]
    [System.Nullable[System.Boolean]] $AllowRecordingStorageOutsideRegion

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether users are allowed to take shared notes. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowSharedNotes

    [DscProperty()]
    [System.ComponentModel.Description('This policy setting allows for the extraction of AI-Assisted Action Items/Tasks from the Meeting Transcript.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $AllowTasksFromTranscript

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether real-time and/or post-meeting captions and transcriptions are allowed in a user''s meetings. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowTranscription

    [DscProperty()]
    [System.ComponentModel.Description('Determines what types of external meetings users can join. Enabled is able join all external meetings.')]
    [ValidateSet('Enabled', 'FederatedOnly', 'Disabled')]
    [System.String] $AllowUserToJoinExternalMeeting

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows scheduling meetings with customized watermarking for video enabled.')]
    [System.Nullable[System.Boolean]] $AllowWatermarkCustomizationForCameraVideo

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows scheduling meetings with customized watermarking for screen sharing enabled.')]
    [System.Nullable[System.Boolean]] $AllowWatermarkCustomizationForScreenSharing

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows scheduling meetings with watermarking for video enabled.')]
    [System.Nullable[System.Boolean]] $AllowWatermarkForCameraVideo

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows scheduling meetings with watermarking for screen sharing enabled.')]
    [System.Nullable[System.Boolean]] $AllowWatermarkForScreenSharing

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether whiteboard is allowed in a user''s meetings. Set this to TRUE to allow. Set this to FALSE to prohibit.')]
    [System.Nullable[System.Boolean]] $AllowWhiteboard

    [DscProperty()]
    [System.ComponentModel.Description('Determines how anonymous users will be authenticated when joining a meeting. Possible values are: OneTimePasscode, if you would like anonymous users to be sent a one time passcode to their email when joining a meeting. None, if you would like to disable authentication for anonymous users joining a meeting')]
    [ValidateSet('None', 'OneTimePasscode')]
    [System.String] $AnonymousUserAuthenticationMethod

    [DscProperty()]
    [System.ComponentModel.Description('This setting will allow admins to enable or disable Masked Attendee mode in Meetings. Masked Attendee meetings will hide attendees'' identifying information (e.g., name, contact information, profile photo).')]
    [ValidateSet('Enabled', 'Disabled', 'DisabledUserOverride')]
    [System.String] $AttendeeIdentityMasking

    [DscProperty()]
    [System.ComponentModel.Description('The setting controls whether recording notification is played to all attendees or just PSTN users.')]
    [ValidateSet('AllAttendees', 'PstnOnly')]
    [System.String] $AudibleRecordingNotification

    [DscProperty()]
    [System.ComponentModel.Description('Determines what types of participants will automatically be added to meetings organized by this user. Set this to EveryoneInCompany if you would like meetings to place every external user in the lobby but allow all users in the company to join the meeting immediately. Set this to Everyone if you''d like to admit anonymous users by default. Set this to EveryoneInSameAndFederatedCompany if you would like meetings to allow federated users to join like your company''s users, but place all other external users in a lobby. Set this to InvitedUsers if you would like meetings to allow only the invited users.')]
    [ValidateSet('EveryoneInCompany', 'Everyone', 'EveryoneInSameAndFederatedCompany', 'OrganizerOnly', 'InvitedUsers', 'EveryoneInCompanyExcludingGuests')]
    [System.String] $AutoAdmittedUsers

    [DscProperty()]
    [System.ComponentModel.Description('This setting gives admins the ability to auto-start Copilot.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $AutomaticallyStartCopilot

    [DscProperty()]
    [System.ComponentModel.Description('This setting will enable Tenant Admins to turn on/off auto recording feature.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $AutoRecording

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $BackroomChat

    [DscProperty()]
    [System.ComponentModel.Description('A user can join a Teams meeting anonymously using a Teams client or using a custom application built using Azure Communication Services. When anonymous meeting join is enabled, both types of clients may be used by default. This optional parameter can be used to block one of the client types that can be used. The allowed values are ACS (to block the use of Azure Communication Services clients) or Teams (to block the use of Teams clients). Both can also be specified, separated by a comma, but this is equivalent to disabling anonymous join completely.')]
    [System.String] $BlockedAnonymousJoinClientTypes

    [DscProperty()]
    [System.ComponentModel.Description('Determines who must complete a verification check (CAPTCHA) before joining meetings organized by the user. Possible values: NotRequired, AnonymousUsersAndUntrustedOrganizations.')]
    [ValidateSet('NotRequired', 'AnonymousUsersAndUntrustedOrganizations')]
    [System.String] $CaptchaVerificationForMeetingJoin

    [DscProperty()]
    [System.ComponentModel.Description('Determines how channel meeting recordings are saved, permissioned, and who can download them.')]
    [ValidateSet('Allow', 'Block')]
    [System.String] $ChannelRecordingDownload

    [DscProperty()]
    [System.ComponentModel.Description('Enables Conditional Access authentication for users joining meetings organized by the user, using the authentication contexts published in the Teams meeting configuration.')]
    [System.Nullable[System.Boolean]] $ConditionalAccessAttendeeVerification

    [DscProperty()]
    [System.ComponentModel.Description('Allows external connections of thirdparty apps to Microsoft Teams.')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $ConnectToMeetingControls

    [DscProperty()]
    [System.ComponentModel.Description('This policy allows admins to determine whether the user can share content in meetings organized by external organizations. The user should have a Teams Premium license to be protected under this policy.')]
    [ValidateSet('EnabledForAnyone', 'EnabledForTrustedOrgs', 'Disabled')]
    [System.String] $ContentSharingInExternalMeetings

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows the admin to choose whether Copilot will be enabled with a persisted transcript or a non-persisted transcript.')]
    [ValidateSet('Disabled', 'Enabled', 'EnabledWithTranscript', 'EnabledWithTranscriptDefaultOn')]
    [System.String] $Copilot

    [DscProperty()]
    [System.ComponentModel.Description('This parameter enables a setting that controls a meeting option which allows users to disable right-click or Ctrl+C to copy, Copy link, Forward message, and Share to Outlook for meeting chat messages.')]
    [System.Nullable[System.Boolean]] $CopyRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Determines if users can change the default value of the Who can present? setting in Meeting options in the Teams client. This policy setting affects all meetings, including Meet Now meetings.')]
    [ValidateSet('OrganizerOnlyUserOverride', 'EveryoneInCompanyUserOverride', 'EveryoneUserOverride')]
    [System.String] $DesignatedPresenterRoleMode

    [DscProperty()]
    [System.ComponentModel.Description('Allows the admin to enable sensitive content detection during screen share.')]
    [System.Nullable[System.Boolean]] $DetectSensitiveContentDuringScreenSharing

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether Teams suppresses the system recording announcements in contact center calls. Set this to TRUE to suppress the announcements and leave compliance notifications to the contact center solution. Set this to FALSE to play all system recording announcements.')]
    [System.Nullable[System.Boolean]] $DisableAudioAnnouncementsForResourceAccounts

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether Teams detects third-party applications, such as screen recorders, audio recorders and AI note-takers, capturing audio on the user''s device during a meeting.')]
    [System.Nullable[System.Boolean]] $EnableExternalRecordingDetection

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether participants must explicitly accept a custom consent dialog before they can join any meeting hosted by the tenant. Requires at least one consent content entry in the Teams pre-meeting consent configuration.')]
    [System.Nullable[System.Boolean]] $EnablePreMeetingConsent

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not users will be able to enroll/capture their Biometric data: Face & Voice.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $EnrollUserOverride

    [DscProperty()]
    [System.ComponentModel.Description('This setting will enable Tenant Admins to turn on/off Explicit Recording Consent feature.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ExplicitRecordingConsent

    [DscProperty()]
    [System.ComponentModel.Description('Controls how external third-party meeting bots and meeting assistants are handled when they attempt to join meetings. Possible values: AllowAllBots, RequireApprovalWhenDetected, BlockDetectedBots.')]
    [ValidateSet('AllowAllBots', 'RequireApprovalWhenDetected', 'BlockDetectedBots')]
    [System.String] $ExternalBotAccessMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the user is allowed to join external meetings.')]
    [ValidateSet('EnabledForAnyone', 'EnabledForTrustedOrgs', 'Disabled')]
    [System.String] $ExternalMeetingJoin

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether meeting transcripts filter profanity.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $FilterProfanityInTranscript

    [DscProperty()]
    [System.ComponentModel.Description('This policy controls what kind of information get shown for the user''s attendance in attendance report/dashboard.')]
    [System.String] $InfoShownInReportMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days the intelligent recap .docx file is stored before it expires.')]
    [System.Nullable[System.Int32]] $IntelligentRecapDocxFileExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether audio can be turned on in meetings and group calls.')]
    [ValidateSet('EnabledOutgoingIncoming', 'Disabled')]
    [System.String] $IPAudioMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether video can be turned on in meetings and group calls. Can only be enabled if IPAudioMode is enabled')]
    [ValidateSet('EnabledOutgoingIncoming', 'Disabled')]
    [System.String] $IPVideoMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether a user should have the option to view live captions or not in a meeting.')]
    [ValidateSet('Disabled', 'DisabledUserOverride')]
    [System.String] $LiveCaptionsEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Determines how meeting organizers can configure a meeting for language interpretation, select attendees of the meeting to become interpreters that other attendees can select and listen to the real-time translation they provide.')]
    [System.String] $LiveInterpretationEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether you provide support for your users to stream their Teams meetings to large audiences through Real-Time Messaging Protocol (RTMP).')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $LiveStreamingMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether chat messages are allowed in the lobby. Possible values are: Enabled, Disabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $LobbyChat

    [DscProperty()]
    [System.ComponentModel.Description('Determines the media bit rate for audio/video/app sharing transmissions in meetings.')]
    [System.Nullable[System.UInt32]] $MediaBitRateKb

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not Chat will be enabled, enabled except anonymous or disabled for meetings.')]
    [ValidateSet('Disabled', 'Enabled', 'EnabledExceptAnonymous')]
    [System.String] $MeetingChatEnabledType

    [DscProperty()]
    [System.ComponentModel.Description('Controls how the join information in meeting invitations is displayed by enforcing a common language or enabling up to two languages to be displayed. Note: All Teams supported languages can be specified using language codes.')]
    [System.String] $MeetingInviteLanguages

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days meeting knowledge data is retained before it is automatically deleted.')]
    [System.Nullable[System.Int32]] $MeetingKnowledgeExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before meeting recordings will expire and move to the recycle bin. Value can be from 1 to 99,999 days. NOTE: You may opt to set Meeting Recordings to never expire by entering the value -1.')]
    [ValidateRange(-1, 99999)]
    [System.Nullable[System.Int32]] $NewMeetingRecordingExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Control Noises Supression Feature for PST legs joining a meeting. Possible Values: MicrosoftDefault, Enabled, Disabled')]
    [ValidateSet('Disabled', 'Enabled', 'MicrosoftDefault')]
    [System.String] $NoiseSuppressionForDialInParticipants

    [DscProperty()]
    [System.ComponentModel.Description('This setting will enable Tenant Admins to turn on/off participant renaming feature.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ParticipantNameChange

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether participants can give control of presentation slides during meetings scheduled by this user. Set the type of users you want to be able to give control and be given control of presentation slides in meetings. Users excluded from the selected group will be prohibited from giving control, or being given control, in a meeting. Possible Values: Everyone: Anyone in the meeting can give or take control. EveryoneInOrganization: Only internal AAD users and Multi-Tenant Organization (MTO) users can give or take control. EveryoneInOrganizationAndGuests: Only those who are Guests to the tenant, MTO users, and internal AAD users can give or take control. None: No one in the meeting can give or take control')]
    [ValidateSet('Everyone', 'EveryoneInOrganization', 'EveryoneInOrganizationAndGuests', 'None')]
    [System.String] $ParticipantSlideControl

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [ValidateSet('Default', 'NumericOnly')]
    [System.String] $PasscodeComplexity

    [DscProperty()]
    [System.ComponentModel.Description('Determines which Outlook Add-in the user will get as preferred Meeting provider(TeamsAndSfb or Teams).')]
    [ValidateSet('TeamsAndSfb', 'Teams')]
    [System.String] $PreferredMeetingProviderForIslandsMode

    [DscProperty()]
    [System.ComponentModel.Description('Identifier that references the Id of the pre-meeting consent content configuration stored as meeting settings. The service updates it when the consent content changes.')]
    [System.String] $PreMeetingConsentContentIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether users enabled for compliance recording are blocked from joining meetings organized by the user. Possible values: None, All.')]
    [ValidateSet('None', 'All')]
    [System.String] $PreventComplianceRecording

    [DscProperty()]
    [System.ComponentModel.Description('This setting enables Microsoft 365 Tenant Admins to Enable or Disable the Questions and Answers experience (Q+A).')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $QnAEngagementMode

    [DscProperty()]
    [System.ComponentModel.Description('Allows users to use real time text during a meeting, allowing them to communicate by typing their messages in real time. Possible Values: Enabled: User is allowed to turn on real time text. Disabled: User is not allowed to turn on real time text.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $RealTimeText

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether audio notifications are played when recording or transcription starts or stops.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $RecordingAndTranscriptionAudioNotification

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not biometric data will be used to distinguish and or attribute in the transcript.')]
    [ValidateSet('Off', 'Distinguish', 'Attribute')]
    [System.String] $RoomAttributeUserOverride

    [DscProperty()]
    [System.ComponentModel.Description('Determines if people recognition option is enabled for Teams Rooms. Enabling requires the RoomAttributeUserOverride to be Attribute for allowing individual voice and face profiles to be used for recognition in meetings.')]
    [ValidateSet('Off', 'On')]
    [System.String] $RoomPeopleNameUserOverride

    [DscProperty()]
    [System.ComponentModel.Description('Determines the mode in which a user can share a screen in calls or meetings. Set this to SingleApplication to allow the user to share an application at a given point in time. Set this to EntireScreen to allow the user to share anything on their screens. Set this to Disabled to prohibit the user from sharing their screens.')]
    [ValidateSet('SingleApplication', 'EntireScreen', 'Disabled')]
    [System.String] $ScreenSharingMode

    [DscProperty()]
    [System.ComponentModel.Description('This setting allows admins to control the visibility of ''Allow meeting organizers to choose who keeps recording and transcript'' feature in the organizer''s Meeting options. If you enable this setting, the Allow meeting organizers to choose who keeps recording and transcript setting appears in Meeting options. Organizers need to manually select a people from meeting attendees as the recording and transcript owner. If you disable this setting, Allow meeting organizers to choose who keeps recording and transcript is hidden, the default value of this setting is disabled.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $SetRecordingAndTranscriptOwnership

    [DscProperty()]
    [System.ComponentModel.Description('Participants can sign up for text message meeting reminders.')]
    [ValidateSet('OnAllowOrganizerOverride', 'OffAllowOrganizerOverride', 'Off')]
    [System.String] $SmsNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Determines if users are identified in transcriptions and if they can change the value of the Automatically identify me in meeting captions and transcripts setting.')]
    [ValidateSet('Disabled', 'DisabledUserOverride', 'EnabledUserOverride', 'Enabled')]
    [System.String] $SpeakerAttributionMode

    [DscProperty()]
    [System.ComponentModel.Description('Controls if Teams uses overflow capability once a meeting reaches its capacity (1,000 users with full functionality).')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $StreamingAttendeeMode

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether synthetic audio and video detection is enabled for the user''s meetings.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $SyntheticMediaDetection

    [DscProperty()]
    [System.ComponentModel.Description('Teams app Id of the registered detection bot used for synthetic media analysis. The all-zero GUID represents the platform default.')]
    [System.String] $SyntheticMediaDetectionAppId

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not meetings created by users with this policy are able to utilize the Camera Far-End PTZ Mode.')]
    [ValidateSet('Disabled', 'AutoAcceptInTenant', 'AutoAcceptAll')]
    [System.String] $TeamsCameraFarEndPTZMode

    [DscProperty()]
    [System.ComponentModel.Description('This policy controls who can admit from the lobby.')]
    [ValidateSet('OrganizerAndCoOrganizersOnly', 'OrganizersAndPresentersOnly')]
    [System.String] $UsersCanAdmitFromLobby

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether you provide support for your users to enable voice isolation in Teams meeting calls.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $VoiceIsolation

    [DscProperty()]
    [System.ComponentModel.Description('Enables the user to use the voice simulation feature while being AI interpreted. Possible Values: Disabled, Enabled')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $VoiceSimulationInInterpreter

    [DscProperty()]
    [System.ComponentModel.Description('Determines the meeting experience and watermark content of an anonymous user.')]
    [ValidateSet('JoinWithAudioOnly', 'WatermarkWithDisplayName')]
    [System.String] $WatermarkForAnonymousUsers

    [DscProperty()]
    [System.ComponentModel.Description('Allows the transparency of watermark to be customizable. Must be between 1 and 100 inclusive.')]
    [ValidateRange(1, 100)]
    [System.Nullable[System.Int32]] $WatermarkForCameraVideoOpacity

    [DscProperty()]
    [System.ComponentModel.Description('Allows the pattern design of watermark to be customizable.')]
    [ValidateSet('Single', 'Tiled')]
    [System.String] $WatermarkForCameraVideoPattern

    [DscProperty()]
    [System.ComponentModel.Description('Allows the transparency of watermark to be customizable. Must be between 1 and 100 inclusive.')]
    [ValidateRange(1, 100)]
    [System.Nullable[System.Int32]] $WatermarkForScreenSharingOpacity

    [DscProperty()]
    [System.ComponentModel.Description('Allows the pattern design of watermark to be customizable.')]
    [ValidateSet('Single', 'Tiled')]
    [System.String] $WatermarkForScreenSharingPattern

    [DscProperty()]
    [System.ComponentModel.Description('Determines the background effects that a user can configure in the Teams client. ')]
    [ValidateSet('NoFilters', 'BlurOnly', 'BlurAndDefaultBackgrounds', 'AllFilters')]
    [System.String] $VideoFiltersMode

    [DscProperty()]
    [System.ComponentModel.Description('Specifies who can attend and register for webinars.')]
    [ValidateSet('Everyone', 'EveryoneInCompany')]
    [System.String] $WhoCanRegister

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [TeamsMeetingPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMeetingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Meeting Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsMeetingPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Meeting Policy {$($this.Identity)}"
                return $this.AsResult($nullReturn)
            }
            Write-Verbose -Message "Found Teams Meeting Policy {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                                     = $this.Identity
                Description                                  = $policy.Description
                AIInterpreter                                = $policy.AIInterpreter
                AllowAnnotations                             = $policy.AllowAnnotations
                AllowAnonymousUsersToDialOut                 = $policy.AllowAnonymousUsersToDialOut
                AllowAnonymousUsersToJoinMeeting             = $policy.AllowAnonymousUsersToJoinMeeting
                AllowAnonymousUsersToStartMeeting            = $policy.AllowAnonymousUsersToStartMeeting
                AllowAvatarsInGallery                        = $policy.AllowAvatarsInGallery
                AllowBreakoutRooms                           = $policy.AllowBreakoutRooms
                AllowCartCaptionsScheduling                  = $policy.AllowCartCaptionsScheduling
                AllowChannelMeetingScheduling                = $policy.AllowChannelMeetingScheduling
                AllowCloudRecording                          = $policy.AllowCloudRecording
                AllowDocumentCollaboration                   = $policy.AllowDocumentCollaboration
                AllowMultipleScreenshare                     = $policy.AllowMultipleScreenshare
                AllowedStreamingMediaInput                   = $policy.AllowedStreamingMediaInput
                AllowedUsersForMeetingDetails                = $policy.AllowedUsersForMeetingDetails
                AllowEngagementReport                        = $policy.AllowEngagementReport
                AllowExternalNonTrustedMeetingChat           = $policy.AllowExternalNonTrustedMeetingChat
                AllowExternalParticipantGiveRequestControl   = $policy.AllowExternalParticipantGiveRequestControl
                AllowImmersiveView                           = $policy.AllowImmersiveView
                AllowIntelligentRecap                        = $policy.AllowIntelligentRecap
                AllowIPAudio                                 = $policy.AllowIPAudio
                AllowIPVideo                                 = $policy.AllowIPVideo
                AllowMeetingCoach                            = $policy.AllowMeetingCoach
                AllowMeetingKnowledgeGeneration              = $policy.AllowMeetingKnowledgeGeneration
                AllowMeetingReactions                        = $policy.AllowMeetingReactions
                AllowMeetingRegistration                     = $policy.AllowMeetingRegistration
                AllowMeetNow                                 = $policy.AllowMeetNow
                AllowNDIStreaming                            = $policy.AllowNDIStreaming
                AllowNetworkConfigurationSettingsLookup      = $policy.AllowNetworkConfigurationSettingsLookup
                AllowOrganizersToOverrideLobbySettings       = $policy.AllowOrganizersToOverrideLobbySettings
                AllowOutlookAddIn                            = $policy.AllowOutlookAddIn
                AllowParticipantGiveRequestControl           = $policy.AllowParticipantGiveRequestControl
                AllowPowerPointSharing                       = $policy.AllowPowerPointSharing
                AllowPrivateMeetingScheduling                = $policy.AllowPrivateMeetingScheduling
                AllowPrivateMeetNow                          = $policy.AllowPrivateMeetNow
                AllowPSTNUsersToBypassLobby                  = $policy.AllowPSTNUsersToBypassLobby
                AllowRecordingStorageOutsideRegion           = $policy.AllowRecordingStorageOutsideRegion
                AllowSharedNotes                             = $policy.AllowSharedNotes
                AllowTasksFromTranscript                     = $policy.AllowTasksFromTranscript
                AllowTranscription                           = $policy.AllowTranscription
                AllowUserToJoinExternalMeeting               = $policy.AllowUserToJoinExternalMeeting
                AllowWatermarkCustomizationForCameraVideo    = $policy.AllowWatermarkCustomizationForCameraVideo
                AllowWatermarkCustomizationForScreenSharing  = $policy.AllowWatermarkCustomizationForScreenSharing
                AllowWatermarkForCameraVideo                 = $policy.AllowWatermarkForCameraVideo
                AllowWatermarkForScreenSharing               = $policy.AllowWatermarkForScreenSharing
                AllowWhiteboard                              = $policy.AllowWhiteboard
                AnonymousUserAuthenticationMethod            = $policy.AnonymousUserAuthenticationMethod
                AttendeeIdentityMasking                      = $policy.AttendeeIdentityMasking
                AudibleRecordingNotification                 = $policy.AudibleRecordingNotification
                AutoAdmittedUsers                            = $policy.AutoAdmittedUsers
                AutomaticallyStartCopilot                    = $policy.AutomaticallyStartCopilot
                AutoRecording                                = $policy.AutoRecording
                BackroomChat                                 = $policy.BackroomChat
                BlockedAnonymousJoinClientTypes              = $policy.BlockedAnonymousJoinClientTypes
                CaptchaVerificationForMeetingJoin            = $policy.CaptchaVerificationForMeetingJoin
                ChannelRecordingDownload                     = $policy.ChannelRecordingDownload
                ConditionalAccessAttendeeVerification        = $policy.ConditionalAccessAttendeeVerification
                ConnectToMeetingControls                     = $policy.ConnectToMeetingControls
                ContentSharingInExternalMeetings             = $policy.ContentSharingInExternalMeetings
                Copilot                                      = $policy.Copilot
                CopyRestriction                              = $policy.CopyRestriction
                DesignatedPresenterRoleMode                  = $policy.DesignatedPresenterRoleMode
                DetectSensitiveContentDuringScreenSharing    = $policy.DetectSensitiveContentDuringScreenSharing
                DisableAudioAnnouncementsForResourceAccounts = $policy.DisableAudioAnnouncementsForResourceAccounts
                EnableExternalRecordingDetection             = $policy.EnableExternalRecordingDetection
                EnablePreMeetingConsent                      = $policy.EnablePreMeetingConsent
                EnrollUserOverride                           = $policy.EnrollUserOverride
                ExplicitRecordingConsent                     = $policy.ExplicitRecordingConsent
                ExternalBotAccessMode                        = $policy.ExternalBotAccessMode
                ExternalMeetingJoin                          = $policy.ExternalMeetingJoin
                FilterProfanityInTranscript                  = $policy.FilterProfanityInTranscript
                InfoShownInReportMode                        = $policy.InfoShownInReportMode
                IntelligentRecapDocxFileExpirationDays       = $policy.IntelligentRecapDocxFileExpirationDays
                IPAudioMode                                  = $policy.IPAudioMode
                IPVideoMode                                  = $policy.IPVideoMode
                LiveCaptionsEnabledType                      = $policy.LiveCaptionsEnabledType
                LiveInterpretationEnabledType                = $policy.LiveInterpretationEnabledType
                LiveStreamingMode                            = $policy.LiveStreamingMode
                LobbyChat                                    = $policy.LobbyChat
                MediaBitRateKb                               = $policy.MediaBitRateKb
                MeetingChatEnabledType                       = $policy.MeetingChatEnabledType
                MeetingInviteLanguages                       = $policy.MeetingInviteLanguages
                MeetingKnowledgeExpirationDays               = $policy.MeetingKnowledgeExpirationDays
                NewMeetingRecordingExpirationDays            = $policy.NewMeetingRecordingExpirationDays
                NoiseSuppressionForDialInParticipants        = $policy.NoiseSuppressionForDialInParticipants
                ParticipantNameChange                        = $policy.ParticipantNameChange
                ParticipantSlideControl                      = $policy.ParticipantSlideControl
                PasscodeComplexity                           = $policy.PasscodeComplexity
                PreferredMeetingProviderForIslandsMode       = $policy.PreferredMeetingProviderForIslandsMode
                PreMeetingConsentContentIdentifier           = $policy.PreMeetingConsentContentIdentifier
                PreventComplianceRecording                   = $policy.PreventComplianceRecording
                QnAEngagementMode                            = $policy.QnAEngagementMode
                RealTimeText                                 = $policy.RealTimeText
                RecordingAndTranscriptionAudioNotification   = $policy.RecordingAndTranscriptionAudioNotification
                RoomAttributeUserOverride                    = $policy.RoomAttributeUserOverride
                RoomPeopleNameUserOverride                   = $policy.RoomPeopleNameUserOverride
                ScreenSharingMode                            = $policy.ScreenSharingMode
                SetRecordingAndTranscriptOwnership           = $policy.SetRecordingAndTranscriptOwnership
                SmsNotifications                             = $policy.SmsNotifications
                SpeakerAttributionMode                       = $policy.SpeakerAttributionMode
                StreamingAttendeeMode                        = $policy.StreamingAttendeeMode
                SyntheticMediaDetection                      = $policy.SyntheticMediaDetection
                SyntheticMediaDetectionAppId                 = $policy.SyntheticMediaDetectionAppId
                TeamsCameraFarEndPTZMode                     = $policy.TeamsCameraFarEndPTZMode
                UsersCanAdmitFromLobby                       = $policy.UsersCanAdmitFromLobby
                VideoFiltersMode                             = $policy.VideoFiltersMode
                VoiceIsolation                               = $policy.VoiceIsolation
                VoiceSimulationInInterpreter                 = $policy.VoiceSimulationInInterpreter
                WatermarkForAnonymousUsers                   = $policy.WatermarkForAnonymousUsers
                WatermarkForCameraVideoOpacity               = $policy.WatermarkForCameraVideoOpacity
                WatermarkForCameraVideoPattern               = $policy.WatermarkForCameraVideoPattern
                WatermarkForScreenSharingOpacity             = $policy.WatermarkForScreenSharingOpacity
                WatermarkForScreenSharingPattern             = $policy.WatermarkForScreenSharingPattern
                WhoCanRegister                               = $policy.WhoCanRegister
                Ensure                                       = 'Present'
                Credential                                   = $this.Credential
                ApplicationId                                = $this.ApplicationId
                TenantId                                     = $this.TenantId
                CertificateThumbprint                        = $this.CertificateThumbprint
                CertificatePath                              = $this.CertificatePath
                CertificatePassword                          = $this.CertificatePassword
                ManagedIdentity                              = $this.ManagedIdentity
                AccessTokens                                 = $this.AccessTokens
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

        Write-Verbose -Message 'Setting Teams Meeting Policy'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # The AllowUserToJoinExternalMeeting is not available in Set-CsTeamsMeetingPolicy
        $SetParameters.Remove('AllowUserToJoinExternalMeeting') | Out-Null

        if ($this.AllowCloudRecording -eq $false -and $SetParameters.Keys -contains 'AllowRecordingStorageOutsideRegion')
        {
            $SetParameters.Remove('AllowRecordingStorageOutsideRegion') | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a Teams Meeting Policy with Identity {$($this.Identity)}"

            # The AllowAnonymousUsersToDialOut is temporarly disabled. Therefore
            # we can't create or update a policy with it and it needs to be removed;
            $SetParameters.Remove('AllowAnonymousUsersToDialOut') | Out-Null

            # TEMPORARLY REMOVINGif ($SetParameters.ContainsKey('AllowAnonymousUsersToDialOut'))
            if ($SetParameters.ContainsKey('AllowIPVideo'))
            {
                $SetParameters.Remove('AllowIPVideo') | Out-Null
            }
            Write-Verbose -Message "Creating new Policy with Values: $(Convert-M365DscHashtableToString -Hashtable $SetParameters)"
            New-CsTeamsMeetingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Meeting Policy with Identity {$($this.Identity)}"

            # The AllowAnonymousUsersToDialOut is temporarly disabled. Therefore
            # we can't create or update a policy with it and it needs to be removed;
            if ($SetParameters.ContainsKey('AllowAnonymousUsersToDialOut'))
            {
                $SetParameters.Remove('AllowAnonymousUsersToDialOut') | Out-Null
            }
            if ($SetParameters.AllowCloudRecording -eq $false )
            {
                $SetParameters.Remove('AllowRecordingStorageOutsideRegion')
                $SetParameters.Remove('RecordingStorageMode')
            }
            Set-CsTeamsMeetingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Meeting Policy {$($this.Identity)}"
            Remove-CsTeamsMeetingPolicy -Identity $this.Identity -Confirm:$false
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('AllowAnonymousUsersToDialOut', 'AllowIPVideo', 'AllowUserToJoinExternalMeeting')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.AllowCloudRecording -eq $false -and $DesiredValues.ContainsKey('AllowRecordingStorageOutsideRegion'))
                {
                    $ValuesToCheck.Remove('AllowCloudRecording') | Out-Null
                }
                elseif ($DesiredValues.AllowCloudRecording -eq $false)
                {
                    # AllowRecordingStorageOutsideRegion and RecordingStorageMode only work if AllowCloudRecording is set to True
                    $ValuesToCheck.Remove('AllowRecordingStorageOutsideRegion') | Out-Null
                    $ValuesToCheck.Remove('RecordingStorageMode') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
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
            [array]$policies = Get-CsTeamsMeetingPolicy -Filter $this.Filter -ErrorAction Stop
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

    hidden [TeamsMeetingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMeetingPolicy])
        {
            return $Values
        }

        $result = [TeamsMeetingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
