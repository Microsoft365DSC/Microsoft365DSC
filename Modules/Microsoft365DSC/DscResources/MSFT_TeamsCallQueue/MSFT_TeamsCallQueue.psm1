using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsCallQueue : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the Call Queue.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Name parameter specifies a unique name for the Call Queue.')]
    [ValidateRange(15, 180)]
    [System.Nullable[System.Int32]] $AgentAlertTime

    [DscProperty()]
    [System.ComponentModel.Description('The AllowOptOut parameter indicates whether or not agents can opt in or opt out from taking calls from a Call Queue.')]
    [System.Nullable[System.Boolean]] $AllowOptOut

    [DscProperty()]
    [System.ComponentModel.Description('The DistributionLists parameter lets you add all the members of the distribution lists to the Call Queue. This is a list of distribution list GUIDs. A service wide configurable maximum number of DLs per Call Queue are allowed. Only the first N (service wide configurable) agents from all distribution lists combined are considered for accepting the call. Nested DLs are supported. O365 Groups can also be used to add members to the Call Queue.')]
    [System.String[]] $DistributionLists

    [DscProperty()]
    [System.ComponentModel.Description('The UseDefaultMusicOnHold parameter indicates that this Call Queue uses the default music on hold. This parameter cannot be specified together with MusicOnHoldAudioFileId.')]
    [System.Nullable[System.Boolean]] $UseDefaultMusicOnHold

    [DscProperty()]
    [System.ComponentModel.Description('The WelcomeMusicAudioFileId parameter represents the audio file to play when callers are connected with the Call Queue. This is the unique identifier of the audio file.')]
    [System.String] $WelcomeMusicAudioFileId

    [DscProperty()]
    [System.ComponentModel.Description('The WelcomeTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt that is played to callers when they connect to the Call Queue.')]
    [System.String] $WelcomeTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The MusicOnHoldFileContent parameter represents music to play when callers are placed on hold. This is the unique identifier of the audio file. This parameter is required if the UseDefaultMusicOnHold parameter is not specified.')]
    [System.String] $MusicOnHoldAudioFileId

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowAction parameter designates the action to take if the overflow threshold is reached. The OverflowAction property must be set to one of the following values: DisconnectWithBusy, Forward, Voicemail, and SharedVoicemail. The default value is DisconnectWithBusy.')]
    [ValidateSet('DisconnectWithBusy', 'Forward', 'Voicemail', 'SharedVoicemail')]
    [System.String] $OverflowAction

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowActionTarget parameter represents the target of the overflow action. If the OverFlowAction is set to Forward, this parameter must be set to a Guid or a telephone number with a mandatory ''tel:'' prefix. If the OverflowAction is set to SharedVoicemail, this parameter must be set to a group ID (Microsoft 365, Distribution list, or Mail-enabled security). Otherwise, this parameter is optional.')]
    [System.String] $OverflowActionTarget

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowThreshold parameter defines the number of calls that can be in the queue at any one time before the overflow action is triggered. The OverflowThreshold can be any integer value between 0 and 200, inclusive. A value of 0 causes calls not to reach agents and the overflow action to be taken immediately.')]
    [ValidateRange(0, 200)]
    [System.Nullable[System.Int32]] $OverflowThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutAction parameter defines the action to take if the timeout threshold is reached. The TimeoutAction property must be set to one of the following values: Disconnect, Forward, Voicemail, and SharedVoicemail. The default value is Disconnect.')]
    [ValidateSet('Disconnect', 'Forward', 'Voicemail', 'SharedVoicemail')]
    [System.String] $TimeoutAction

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutActionTarget represents the target of the timeout action. If the TimeoutAction is set to Forward, this parameter must be set to a Guid or a telephone number with a mandatory ''tel:'' prefix. If the TimeoutAction is set to SharedVoicemail, this parameter must be set to an Office 365 Group ID. Otherwise, this field is optional.')]
    [System.String] $TimeoutActionTarget

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutThreshold parameter defines the time (in seconds) that a call can be in the queue before that call times out. At that point, the system will take the action specified by the TimeoutAction parameter. The TimeoutThreshold can be any integer value between 0 and 2700 seconds (inclusive), and is rounded to the nearest 15th interval. For example, if set to 47 seconds, then it is rounded down to 45. If set to 0, welcome music is played, and then the timeout action will be taken.')]
    [ValidateRange(0, 2700)]
    [System.Nullable[System.Int32]] $TimeoutThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The RoutingMethod defines how agents will be called in a Call Queue. If the routing method is set to Serial, then agents will be called one at a time. If the routing method is set to Attendant, then agents will be called in parallel. If routing method is set to RoundRobin, the agents will be called using Round Robin strategy so that all agents share the call-load equally. If routing method is set to LongestIdle, the agents will be called based on their idle time, i.e., the agent that has been idle for the longest period will be called.')]
    [ValidateSet('Attendant', 'Serial', 'RoundRobin', 'LongestIdle')]
    [System.String] $RoutingMethod

    [DscProperty()]
    [System.ComponentModel.Description('The PresenceBasedRouting parameter indicates whether or not presence based routing will be applied while call being routed to Call Queue agents. When set to False, calls will be routed to agents who have opted in to receive calls, regardless of their presence state. When set to True, opted-in agents will receive calls only when their presence state is Available.')]
    [System.Nullable[System.Boolean]] $PresenceBasedRouting

    [DscProperty()]
    [System.ComponentModel.Description('The ConferenceMode parameter indicates whether or not Conference mode will be applied on calls for this Call queue. Conference mode significantly reduces the amount of time it takes for a caller to be connected to an agent, after the agent accepts the call.')]
    [System.Nullable[System.Boolean]] $ConferenceMode

    [DscProperty()]
    [System.ComponentModel.Description('The Users parameter lets you add agents to the Call Queue. This parameter expects a list of user unique identifiers (GUID).')]
    [System.String[]] $Users

    [DscProperty()]
    [System.ComponentModel.Description('The LanguageId parameter indicates the language that is used to play shared voicemail prompts. This parameter becomes a required parameter If either OverflowAction or TimeoutAction is set to SharedVoicemail. You can query the supported languages using the Get-CsAutoAttendantSupportedLanguage cmdlet.')]
    [System.String] $LanguageId

    [DscProperty()]
    [System.ComponentModel.Description('This is a list of UserPrincipalNames of authorized users who should not appear on the list of supervisors for the agents who are members of this queue.')]
    [System.String[]] $HideAuthorizedUsers

    [DscProperty()]
    [System.ComponentModel.Description('The OboResourceAccountIds parameter lets you add resource account with phone number to the Call Queue. The agents in the Call Queue will be able to make outbound calls using the phone number on the resource accounts. This is a list of resource account GUIDs. Only Call Queue managed by a Teams Channel will be able to use this feature.')]
    [System.String[]] $OboResourceAccountIds

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowDisconnectTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being disconnected due to overflow.')]
    [System.String] $OverflowDisconnectTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowDisconnectAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being disconnected due to overflow.')]
    [System.String] $OverflowDisconnectAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectPersonTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a person in the organization due to overflow.')]
    [System.String] $OverflowRedirectPersonTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectPersonAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a person in the organization due to overflow.')]
    [System.String] $OverflowRedirectPersonAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectVoiceAppsTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a voice application due to overflow.')]
    [System.String] $OverflowRedirectVoiceAppTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectVoiceAppAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a voice application due to overflow.')]
    [System.String] $OverflowRedirectVoiceAppAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectPhoneNumberTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to an external PSTN phone number due to overflow.')]
    [System.String] $OverflowRedirectPhoneNumberTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectPhoneNumberAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to an external PSTN phone number due to overflow.')]
    [System.String] $OverflowRedirectPhoneNumberAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a person''s voicemail due to overflow.')]
    [System.String] $OverflowRedirectVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectVoiceMailAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a person''s voicemail due to overflow.')]
    [System.String] $OverflowRedirectVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowRedirectVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a person''s voicemail due to overflow.')]
    [System.String] $OverflowSharedVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The OverflowSharedVoicemailAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is to be played as a greeting to the caller when transferred to shared voicemail on overflow. This parameter becomes a required parameter when OverflowAction is SharedVoicemail and OverflowSharedVoicemailTextToSpeechPrompt is null.')]
    [System.String] $OverflowSharedVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOverflowSharedVoicemailTranscription parameter is used to turn on transcription for voicemails left by a caller on overflow. This parameter is only applicable when OverflowAction is set to SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableOverflowSharedVoicemailTranscription

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOverflowSharedVoicemailSystemPromptSuppression parameter is used to turn off the default voicemail system prompts. This parameter is only applicable when OverflowAction is set to SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableOverflowSharedVoicemailSystemPromptSuppression

    [DscProperty()]
    [System.ComponentModel.Description('If the OverflowAction is set to Forward, and the OverflowActionTarget is set to an Auto attendant or Call queue resource account GUID, this parameter indicates the priority assigned to the call. Supported values are from 1 (Very High) to 5 (Very Low).')]
    [ValidateSet('1', '2', '3', '4', '5')]
    [ValidateRange(1, 5)]
    [System.Nullable[System.Int32]] $OverflowActionCallPriority

    [DscProperty()]
    [System.ComponentModel.Description('The TextAnnouncementForCR parameter indicates the custom Text-to-Speech (TTS) prompt which is played to callers when compliance recording for call queues is enabled.')]
    [System.String] $TextAnnouncementForCR

    [DscProperty()]
    [System.ComponentModel.Description('The TextAnnouncementForCRFailure parameter indicates the custom Text-to-Speech (TTS) prompt which is played to callers if the compliance recording for call queue bot is unable to join or drops from the call.')]
    [System.String] $TextAnnouncementForCRFailure

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAudioFileAnnouncementForCR parameter indicates the unique identifier for the audio file prompt played to callers when compliance recording for call queues is enabled.')]
    [System.String] $CustomAudioFileAnnouncementForCR

    [DscProperty()]
    [System.ComponentModel.Description('The CustomAudioFileAnnouncementForCRFailure parameter indicates the unique identifier for the audio file prompt played to callers if the compliance recording bot is unable to join or drops from the call.')]
    [System.String] $CustomAudioFileAnnouncementForCRFailure

    [DscProperty()]
    [System.ComponentModel.Description('The ComplianceRecordingForCallQueueTemplateId parameter indicates a list of up to two Compliance Recording for Call Queue templates to apply to the call queue.')]
    [System.String[]] $ComplianceRecordingForCallQueueTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The SharedCallQueueHistoryTemplateId parameter indicates the Shared Call Queue History template to apply to the call queue.')]
    [System.String] $SharedCallQueueHistoryTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The AutoRecordingTemplateId parameter indicates the auto recording template to apply to the call queue.')]
    [System.String] $AutoRecordingTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The SharedVoicemailTriageSettingsTemplateId parameter indicates the shared voicemail triage settings template to apply to the call queue.')]
    [System.String] $SharedVoicemailTriageSettingsTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutDisconnectTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being disconnected due to timeout.')]
    [System.String] $TimeoutDisconnectTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutDisconnectAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being disconnected due to timeout.')]
    [System.String] $TimeoutDisconnectAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectPersonTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a person in the organization due to timeout.')]
    [System.String] $TimeoutRedirectPersonTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectPersonAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a person in the organization due to timeout.')]
    [System.String] $TimeoutRedirectPersonAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectVoiceAppsTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a voice application due to timeout.')]
    [System.String] $TimeoutRedirectVoiceAppTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectVoiceAppAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a voice application due to timeout.')]
    [System.String] $TimeoutRedirectVoiceAppAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectPhoneNumberTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to an external PSTN phone number due to timeout.')]
    [System.String] $TimeoutRedirectPhoneNumberTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectPhoneNumberAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to an external PSTN phone number due to timeout.')]
    [System.String] $TimeoutRedirectPhoneNumberAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is played to the caller when being redirected to a person''s voicemail due to timeout.')]
    [System.String] $TimeoutRedirectVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutRedirectVoiceMailAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is played to the caller when being redirected to a person''s voicemail due to timeout.')]
    [System.String] $TimeoutRedirectVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutSharedVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt which is to be played as a greeting to the caller when transferred to shared voicemail on timeout. This parameter becomes a required parameter when TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailAudioFilePrompt is null.')]
    [System.String] $TimeoutSharedVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The TimeoutSharedVoicemailAudioFilePrompt parameter indicates the unique identifier for the Audio file prompt which is to be played as a greeting to the caller when transferred to shared voicemail on timeout. This parameter becomes a required parameter when TimeoutAction is SharedVoicemail and TimeoutSharedVoicemailTextToSpeechPrompt is null.')]
    [System.String] $TimeoutSharedVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The EnableTimeoutSharedVoicemailTranscription parameter is used to turn on transcription for voicemails left by a caller on timeout. This parameter is only applicable when TimeoutAction is set to SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableTimeoutSharedVoicemailTranscription

    [DscProperty()]
    [System.ComponentModel.Description('The EnableTimeoutSharedVoicemailSystemPromptSuppression parameter is used to turn off the default voicemail system prompts. This parameter is only applicable when TimeoutAction is set to SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableTimeoutSharedVoicemailSystemPromptSuppression

    [DscProperty()]
    [System.ComponentModel.Description('If the TimeoutAction is set to Forward, and the TimeoutActionTarget is set to an Auto attendant or Call queue resource account GUID, this parameter indicates the priority assigned to the call. Supported values are from 1 (Very High) to 5 (Very Low).')]
    [ValidateSet('1', '2', '3', '4', '5')]
    [ValidateRange(1, 5)]
    [System.Nullable[System.Int32]] $TimeoutActionCallPriority

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentAction parameter defines the action to take if no agents are available. Supported values are Queue, Disconnect, Forward, Voicemail, and SharedVoicemail.')]
    [ValidateSet('Queue', 'Disconnect', 'Forward', 'Voicemail', 'SharedVoicemail')]
    [System.String] $NoAgentAction

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentActionTarget parameter represents the target of the no agent action. If NoAgentAction is Forward, this parameter must be a GUID or telephone number with the tel: prefix. If NoAgentAction is SharedVoicemail, this parameter must be a group ID.')]
    [System.String] $NoAgentActionTarget

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentSharedVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are transferred to shared voicemail because no agents are available.')]
    [System.String] $NoAgentSharedVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentSharedVoicemailAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are transferred to shared voicemail because no agents are available.')]
    [System.String] $NoAgentSharedVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The EnableNoAgentSharedVoicemailTranscription parameter turns on transcription for voicemails left when no agents are available. This parameter is only applicable when NoAgentAction is SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableNoAgentSharedVoicemailTranscription

    [DscProperty()]
    [System.ComponentModel.Description('The EnableNoAgentSharedVoicemailSystemPromptSuppression parameter turns off the default voicemail system prompts when no agents are available. This parameter is only applicable when NoAgentAction is SharedVoicemail.')]
    [System.Nullable[System.Boolean]] $EnableNoAgentSharedVoicemailSystemPromptSuppression

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentApplyTo parameter defines whether NoAgentAction applies to all calls in queue or only new calls when the no agents condition occurs.')]
    [ValidateSet('AllCalls', 'NewCalls')]
    [System.String] $NoAgentApplyTo

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentDisconnectAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are disconnected because no agents are available.')]
    [System.String] $NoAgentDisconnectAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentDisconnectTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are disconnected because no agents are available.')]
    [System.String] $NoAgentDisconnectTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectPersonAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are redirected to a person because no agents are available.')]
    [System.String] $NoAgentRedirectPersonAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectPersonTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are redirected to a person because no agents are available.')]
    [System.String] $NoAgentRedirectPersonTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectVoiceAppAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are redirected to a voice application because no agents are available.')]
    [System.String] $NoAgentRedirectVoiceAppAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectVoiceAppTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are redirected to a voice application because no agents are available.')]
    [System.String] $NoAgentRedirectVoiceAppTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectPhoneNumberAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are redirected to an external PSTN phone number because no agents are available.')]
    [System.String] $NoAgentRedirectPhoneNumberAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectPhoneNumberTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are redirected to an external PSTN phone number because no agents are available.')]
    [System.String] $NoAgentRedirectPhoneNumberTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectVoicemailAudioFilePrompt parameter indicates the unique identifier for the audio file prompt played when callers are redirected to a person''s voicemail because no agents are available.')]
    [System.String] $NoAgentRedirectVoicemailAudioFilePrompt

    [DscProperty()]
    [System.ComponentModel.Description('The NoAgentRedirectVoicemailTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played when callers are redirected to a person''s voicemail because no agents are available.')]
    [System.String] $NoAgentRedirectVoicemailTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('If NoAgentAction is set to Forward, and NoAgentActionTarget is set to an Auto attendant or Call queue resource account GUID, this parameter indicates the priority assigned to the call. Supported values are from 1 (Very High) to 5 (Very Low).')]
    [ValidateSet('1', '2', '3', '4', '5')]
    [ValidateRange(1, 5)]
    [System.Nullable[System.Int32]] $NoAgentActionCallPriority

    [DscProperty()]
    [System.ComponentModel.Description('The IsCallbackEnabled parameter indicates whether callback is enabled for the call queue.')]
    [System.Nullable[System.Boolean]] $IsCallbackEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The CallbackRequestDtmf parameter indicates the DTMF key callers press to select callback.')]
    [ValidateSet('Tone0', 'Tone1', 'Tone2', 'Tone3', 'Tone4', 'Tone5', 'Tone6', 'Tone7', 'Tone8', 'Tone9', 'ToneStar', 'TonePound')]
    [System.String] $CallbackRequestDtmf

    [DscProperty()]
    [System.ComponentModel.Description('The WaitTimeBeforeOfferingCallbackInSecond parameter indicates the number of seconds a call must wait before becoming eligible for callback.')]
    [System.Nullable[System.Int32]] $WaitTimeBeforeOfferingCallbackInSecond

    [DscProperty()]
    [System.ComponentModel.Description('The NumberOfCallsInQueueBeforeOfferingCallback parameter indicates the number of calls in queue before a call becomes eligible for callback.')]
    [System.Nullable[System.Int32]] $NumberOfCallsInQueueBeforeOfferingCallback

    [DscProperty()]
    [System.ComponentModel.Description('The CallToAgentRatioThresholdBeforeOfferingCallback parameter indicates the call-to-agent ratio threshold before a call becomes eligible for callback. The minimum value is 1.')]
    [System.Nullable[System.Int32]] $CallToAgentRatioThresholdBeforeOfferingCallback

    [DscProperty()]
    [System.ComponentModel.Description('The CallbackOfferAudioFilePromptResourceId parameter indicates the unique identifier for the audio file prompt played to calls that are eligible for callback.')]
    [System.String] $CallbackOfferAudioFilePromptResourceId

    [DscProperty()]
    [System.ComponentModel.Description('The CallbackOfferTextToSpeechPrompt parameter indicates the Text-to-Speech (TTS) prompt played to calls that are eligible for callback.')]
    [System.String] $CallbackOfferTextToSpeechPrompt

    [DscProperty()]
    [System.ComponentModel.Description('The CallbackEmailNotificationTarget parameter indicates the group ID that receives notifications when a callback times out or cannot be completed.')]
    [System.String] $CallbackEmailNotificationTarget

    [DscProperty()]
    [System.ComponentModel.Description('The ServiceLevelThresholdResponseTimeInSecond parameter indicates the target number of seconds calls should be answered in for service level calculation.')]
    [System.Nullable[System.Int32]] $ServiceLevelThresholdResponseTimeInSecond

    [DscProperty()]
    [System.ComponentModel.Description('The ShouldOverwriteCallableChannelProperty parameter indicates whether reassignment of a Teams channel to a new call queue should be forced.')]
    [System.Nullable[System.Boolean]] $ShouldOverwriteCallableChannelProperty

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Team containing the Scheduling Group to connect a call queue to.')]
    [System.String] $ShiftsTeamId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Scheduling Group to connect a call queue to.')]
    [System.String] $ShiftsSchedulingGroupId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the channel to connect a call queue to.')]
    [System.String] $ChannelId

    [DscProperty()]
    [System.ComponentModel.Description('Guid should contain 32 digits with 4 dashes (xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx). This is the GUID of one of the owners of the team the channels belongs to.')]
    [System.String] $ChannelUserObjectId

    [DscProperty()]
    [System.ComponentModel.Description('This is a list of UserPrincipalNames for users who are authorized to make changes to this call queue. The users must also have a TeamsVoiceApplications policy assigned.')]
    [System.String[]] $AuthorizedUsers

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Team Message Policy exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Service Admin')]
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
    [System.String] $Filter

    [TeamsCallQueue] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsCallQueue]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Teams Call Queue {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-M365DSCHost -Message "Getting Office 365 queue $($this.Name)"
                $queue = $this.GetCallQueue()
            }
            else
            {
                $queue = $this.ExportedInstance
            }

            if ($null -eq $queue)
            {
                return $this.AsResult($nullReturn)
            }

            $usersValue = @()
            foreach ($user in $queue.Users)
            {
                $onlineUser = Get-CsOnlineUser -Identity $user -Properties UserPrincipalName -ErrorAction SilentlyContinue
                if ($null -eq $onlineUser)
                {
                    Write-Warning -Message "Unable to retrieve details for user with object id $user. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                if ($this.Users -contains $onlineUser.Identity)
                {
                    $usersValue += $onlineUser.Identity
                }
                else
                {
                    $usersValue += $onlineUser.UserPrincipalName
                }
            }

            $authorizedUsersValue = @()
            foreach ($authorizedUser in $queue.AuthorizedUsers)
            {
                $user = Get-CsOnlineUser -Identity $authorizedUser -Properties UserPrincipalName -ErrorAction SilentlyContinue
                if ($null -eq $user)
                {
                    Write-Warning -Message "Unable to retrieve details for authorized user with object id $authorizedUser. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                if ($this.AuthorizedUsers -contains $user.Identity)
                {
                    $authorizedUsersValue += $user.Identity
                }
                else
                {
                    $authorizedUsersValue += $user.UserPrincipalName
                }
            }

            $hideAuthorizedUsersValue = @()
            foreach ($authorizedUser in $queue.HideAuthorizedUsers)
            {
                $user = Get-CsOnlineUser -Identity $authorizedUser -Properties UserPrincipalName -ErrorAction SilentlyContinue
                if ($null -eq $user)
                {
                    Write-Warning -Message "Unable to retrieve details for hidden authorized user with object id $authorizedUser. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                if ($this.HideAuthorizedUsers -contains $user.Identity)
                {
                    $hideAuthorizedUsersValue += $user.Identity
                }
                else
                {
                    $hideAuthorizedUsersValue += $user.UserPrincipalName
                }
            }

            $returnHashtable = @{
                Name                                          = $queue.Name
                AgentAlertTime                                = $queue.AgentAlertTime
                AllowOptOut                                   = $queue.AllowOptOut
                DistributionLists                             = [String[]]$queue.DistributionLists
                HideAuthorizedUsers                           = $hideAuthorizedUsersValue
                UseDefaultMusicOnHold                         = $queue.UseDefaultMusicOnHold
                WelcomeMusicAudioFileId                       = $queue.WelcomeMusicResourceId
                WelcomeTextToSpeechPrompt                     = $queue.WelcomeTextToSpeechPrompt
                MusicOnHoldAudioFileId                        = $queue.MusicOnHoldResourceId
                OverflowAction                                = $queue.OverflowAction
                OverflowActionTarget                          = $queue.OverflowActionTarget.Id
                OverflowThreshold                             = $queue.OverflowThreshold
                TimeoutAction                                 = $queue.TimeoutAction
                TimeoutActionTarget                           = $queue.TimeoutActionTarget.Id
                TimeoutThreshold                              = $queue.TimeoutThreshold
                RoutingMethod                                 = $queue.RoutingMethod
                PresenceBasedRouting                          = $queue.PresenceBasedRouting
                ConferenceMode                                = $queue.ConferenceMode
                Users                                         = [String[]]$usersValue
                LanguageId                                    = $queue.LanguageId
                OboResourceAccountIds                         = [String[]]$queue.OboResourceAccountIds
                EnableOverflowSharedVoicemailSystemPromptSuppression = $queue.EnableOverflowSharedVoicemailSystemPromptSuppression
                OverflowDisconnectTextToSpeechPrompt          = $queue.OverflowDisconnectTextToSpeechPrompt
                OverflowDisconnectAudioFilePrompt             = $queue.OverflowDisconnectAudioFilePrompt
                OverflowRedirectPersonTextToSpeechPrompt      = $queue.OverflowRedirectPersonTextToSpeechPrompt
                OverflowRedirectPersonAudioFilePrompt         = $queue.OverflowRedirectPersonAudioFilePrompt
                OverflowRedirectVoiceAppTextToSpeechPrompt    = $queue.OverflowRedirectVoiceAppTextToSpeechPrompt
                OverflowRedirectVoiceAppAudioFilePrompt       = $queue.OverflowRedirectVoiceAppAudioFilePrompt
                OverflowRedirectPhoneNumberTextToSpeechPrompt = $queue.OverflowRedirectPhoneNumberTextToSpeechPrompt
                OverflowRedirectPhoneNumberAudioFilePrompt    = $queue.OverflowRedirectPhoneNumberAudioFilePrompt
                OverflowRedirectVoicemailTextToSpeechPrompt   = $queue.OverflowRedirectVoicemailTextToSpeechPrompt
                OverflowRedirectVoicemailAudioFilePrompt      = $queue.OverflowRedirectVoicemailAudioFilePrompt
                OverflowSharedVoicemailTextToSpeechPrompt     = $queue.OverflowSharedVoicemailTextToSpeechPrompt
                OverflowSharedVoicemailAudioFilePrompt        = $queue.OverflowSharedVoicemailAudioFilePrompt
                EnableOverflowSharedVoicemailTranscription    = $queue.EnableOverflowSharedVoicemailTranscription
                TextAnnouncementForCR                         = $queue.TextAnnouncementForCR
                TextAnnouncementForCRFailure                  = $queue.TextAnnouncementForCRFailure
                TimeoutDisconnectTextToSpeechPrompt           = $queue.TimeoutDisconnectTextToSpeechPrompt
                TimeoutDisconnectAudioFilePrompt              = $queue.TimeoutDisconnectAudioFilePrompt
                TimeoutRedirectPersonTextToSpeechPrompt       = $queue.TimeoutRedirectPersonTextToSpeechPrompt
                TimeoutRedirectPersonAudioFilePrompt          = $queue.TimeoutRedirectPersonAudioFilePrompt
                TimeoutRedirectVoiceAppTextToSpeechPrompt     = $queue.TimeoutRedirectVoiceAppTextToSpeechPrompt
                TimeoutRedirectVoiceAppAudioFilePrompt        = $queue.TimeoutRedirectVoiceAppAudioFilePrompt
                TimeoutRedirectPhoneNumberTextToSpeechPrompt  = $queue.TimeoutRedirectPhoneNumberTextToSpeechPrompt
                TimeoutRedirectPhoneNumberAudioFilePrompt     = $queue.TimeoutRedirectPhoneNumberAudioFilePrompt
                TimeoutRedirectVoicemailTextToSpeechPrompt    = $queue.TimeoutRedirectVoicemailTextToSpeechPrompt
                TimeoutRedirectVoicemailAudioFilePrompt       = $queue.TimeoutRedirectVoicemailAudioFilePrompt
                TimeoutSharedVoicemailTextToSpeechPrompt      = $queue.TimeoutSharedVoicemailTextToSpeechPrompt
                TimeoutSharedVoicemailAudioFilePrompt         = $queue.TimeoutSharedVoicemailAudioFilePrompt
                EnableTimeoutSharedVoicemailTranscription     = $queue.EnableTimeoutSharedVoicemailTranscription
                EnableTimeoutSharedVoicemailSystemPromptSuppression = $queue.EnableTimeoutSharedVoicemailSystemPromptSuppression
                NoAgentAction                                 = $queue.NoAgentAction
                NoAgentActionTarget                           = $queue.NoAgentActionTarget.Id
                NoAgentSharedVoicemailTextToSpeechPrompt      = $queue.NoAgentSharedVoicemailTextToSpeechPrompt
                NoAgentSharedVoicemailAudioFilePrompt         = $queue.NoAgentSharedVoicemailAudioFilePrompt
                EnableNoAgentSharedVoicemailTranscription     = $queue.EnableNoAgentSharedVoicemailTranscription
                EnableNoAgentSharedVoicemailSystemPromptSuppression = $queue.EnableNoAgentSharedVoicemailSystemPromptSuppression
                NoAgentApplyTo                                = $queue.NoAgentApplyTo
                NoAgentDisconnectAudioFilePrompt              = $queue.NoAgentDisconnectAudioFilePrompt
                NoAgentDisconnectTextToSpeechPrompt           = $queue.NoAgentDisconnectTextToSpeechPrompt
                NoAgentRedirectPersonAudioFilePrompt          = $queue.NoAgentRedirectPersonAudioFilePrompt
                NoAgentRedirectPersonTextToSpeechPrompt       = $queue.NoAgentRedirectPersonTextToSpeechPrompt
                NoAgentRedirectVoiceAppAudioFilePrompt        = $queue.NoAgentRedirectVoiceAppAudioFilePrompt
                NoAgentRedirectVoiceAppTextToSpeechPrompt     = $queue.NoAgentRedirectVoiceAppTextToSpeechPrompt
                NoAgentRedirectPhoneNumberAudioFilePrompt     = $queue.NoAgentRedirectPhoneNumberAudioFilePrompt
                NoAgentRedirectPhoneNumberTextToSpeechPrompt  = $queue.NoAgentRedirectPhoneNumberTextToSpeechPrompt
                NoAgentRedirectVoicemailAudioFilePrompt       = $queue.NoAgentRedirectVoicemailAudioFilePrompt
                NoAgentRedirectVoicemailTextToSpeechPrompt    = $queue.NoAgentRedirectVoicemailTextToSpeechPrompt
                ShouldOverwriteCallableChannelProperty        = $queue.ShouldOverwriteCallableChannelProperty
                OverflowActionCallPriority                    = $queue.OverflowActionCallPriority
                TimeoutActionCallPriority                     = $queue.TimeoutActionCallPriority
                NoAgentActionCallPriority                     = $queue.NoAgentActionCallPriority
                IsCallbackEnabled                             = $queue.IsCallbackEnabled
                CallbackRequestDtmf                           = $queue.CallbackRequestDtmf
                WaitTimeBeforeOfferingCallbackInSecond        = $queue.WaitTimeBeforeOfferingCallbackInSecond
                NumberOfCallsInQueueBeforeOfferingCallback    = $queue.NumberOfCallsInQueueBeforeOfferingCallback
                CallToAgentRatioThresholdBeforeOfferingCallback = $queue.CallToAgentRatioThresholdBeforeOfferingCallback
                CallbackOfferAudioFilePromptResourceId        = $queue.CallbackOfferAudioFilePromptResourceId
                CallbackOfferTextToSpeechPrompt               = $queue.CallbackOfferTextToSpeechPrompt
                CallbackEmailNotificationTarget               = $queue.CallbackEmailNotificationTarget.Id
                ServiceLevelThresholdResponseTimeInSecond     = $queue.ServiceLevelThresholdResponseTimeInSecond
                ShiftsTeamId                                  = $queue.ShiftsTeamId
                CustomAudioFileAnnouncementForCR              = $queue.CustomAudioFileAnnouncementForCR
                CustomAudioFileAnnouncementForCRFailure       = $queue.CustomAudioFileAnnouncementForCRFailure
                ComplianceRecordingForCallQueueTemplateId     = [String[]]$queue.ComplianceRecordingForCallQueueTemplateId
                SharedCallQueueHistoryTemplateId              = $queue.SharedCallQueueHistoryTemplateId
                AutoRecordingTemplateId                       = $queue.AutoRecordingTemplateId
                SharedVoicemailTriageSettingsTemplateId       = $queue.SharedVoicemailTriageSettingsTemplateId
                ShiftsSchedulingGroupId                       = $queue.ShiftsSchedulingGroupId
                ChannelId                                     = $queue.ChannelId
                ChannelUserObjectId                           = $queue.ChannelUserObjectId
                AuthorizedUsers                               = $authorizedUsersValue
                Ensure                                        = 'Present'
                Credential                                    = $this.Credential
                ApplicationId                                 = $this.ApplicationId
                TenantId                                      = $this.TenantId
                CertificateThumbprint                         = $this.CertificateThumbprint
                CertificatePath                               = $this.CertificatePath
                CertificatePassword                           = $this.CertificatePassword
                ManagedIdentity                               = $this.ManagedIdentity
                AccessTokens                                  = $this.AccessTokens
            }

            if ($returnHashtable.OverflowActionCallPriority -eq 0)
            {
                $returnHashtable.Remove('OverflowActionCallPriority') | Out-Null
            }
            if ($returnHashtable.TimeoutActionCallPriority -eq 0)
            {
                $returnHashtable.Remove('TimeoutActionCallPriority') | Out-Null
            }
            if ($returnHashtable.NoAgentActionCallPriority -eq 0)
            {
                $returnHashtable.Remove('NoAgentActionCallPriority') | Out-Null
            }

            return $this.AsResult($returnHashtable)
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

        Write-Verbose -Message "Setting configuration of Teams Call Queue {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()
        $opsParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.GetBoundParameters().ContainsKey('Users') -and $this.Users.Count -gt 0)
        {
            $opsParameters.Remove('Users') | Out-Null
            $userIds = @()
            foreach ($user in $this.Users)
            {
                $onlineUser = Get-CsOnlineUser -Identity $user -Properties Id -ErrorAction SilentlyContinue
                if ($null -eq $onlineUser)
                {
                    Write-Warning -Message "Unable to retrieve details for user $user. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                $userIds += $onlineUser.Identity
            }

            $opsParameters.Add('Users', $userIds)
        }

        if ($this.GetBoundParameters().ContainsKey('AuthorizedUsers') -and $this.AuthorizedUsers.Count -gt 0)
        {
            $opsParameters.Remove('AuthorizedUsers') | Out-Null
            $authorizedUserIds = @()
            foreach ($user in $this.AuthorizedUsers)
            {
                $userDetails = Get-CsOnlineUser -Identity $user -Properties Id -ErrorAction SilentlyContinue
                if ($null -eq $userDetails)
                {
                    Write-Warning -Message "Unable to retrieve details for user $user. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                $authorizedUserIds += $userDetails.Identity
            }

            $opsParameters.Add('AuthorizedUsers', $authorizedUserIds)
        }

        if ($this.GetBoundParameters().ContainsKey('HideAuthorizedUsers') -and $this.HideAuthorizedUsers.Count -gt 0)
        {
            $opsParameters.Remove('HideAuthorizedUsers') | Out-Null
            $hideAuthorizedUserIds = @()
            foreach ($user in $this.HideAuthorizedUsers)
            {
                $userDetails = Get-CsOnlineUser -Identity $user -Properties Id -ErrorAction SilentlyContinue
                if ($null -eq $userDetails)
                {
                    Write-Warning -Message "Unable to retrieve details for user $user. Ensure the user exists and the account used for authentication has the necessary permissions to read user details."
                    continue
                }

                $hideAuthorizedUserIds += $userDetails.Identity
            }

            $opsParameters.Add('HideAuthorizedUsers', $hideAuthorizedUserIds)
        }

        if ($currentValues.Ensure -eq 'Absent' -and 'Present' -eq $this.Ensure )
        {
            Write-Verbose -Message "Creating a new Teams Call Queue with Name {$($this.Name)}"
            New-CsCallQueue @opsParameters
        }
        elseif (($currentValues.Ensure -eq 'Present' -and 'Present' -eq $this.Ensure))
        {
            Write-Verbose -Message "Updating the Teams Call Queue with Name {$($this.Name)}"
            $opsParameters.Add('Identity', $this.GetCallQueue().Identity)
            Set-CsCallQueue @opsParameters
        }
        elseif (($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present'))
        {
            Write-Verbose -Message "Removing the Teams Call Queue with Name {$($this.Name)}"
            Remove-CsCallQueue -Identity $this.GetCallQueue().Identity
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('ChannelUserObjectId', 'ShouldOverwriteCallableChannelProperty')
        }
    }

    [string] Export()
    {
        $currentBatch = $null
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
            [array] $exportedInstances = @()
            $offset = 0

            do
            {
                [array] $currentBatch = Get-CsCallQueue -NameFilter $this.Filter -First 100 -Skip $offset
                if ($currentBatch)
                {
                    $exportedInstances += $currentBatch
                    $offset += $currentBatch.Count
                }
            } while ($currentBatch.Count -eq 100)

            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($instance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($instance.Name)" -DeferWrite

                $params = @{
                    Name                  = $instance.Name
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

                $this.ExportedInstance = $instance
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
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

    hidden [System.Object] GetCallQueue()
    {
        $queueName = $this.Name
        $queue = Get-CsCallQueue -NameFilter $queueName `
            -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.Name -eq $queueName }

        if ($null -eq $queue)
        {
            return $null
        }

        return $queue
    }

    hidden [TeamsCallQueue] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsCallQueue])
        {
            return $Values
        }

        $result = [TeamsCallQueue]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
