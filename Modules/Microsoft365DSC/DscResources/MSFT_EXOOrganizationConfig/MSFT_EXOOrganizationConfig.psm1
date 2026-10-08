using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOrganizationConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The ActivityBasedAuthenticationTimeoutEnabled parameter specifies whether the timed logoff feature is enabled. The default value is $true')]
    [System.Nullable[System.Boolean]] $ActivityBasedAuthenticationTimeoutEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ActivityBasedAuthenticationTimeoutInterval parameter specifies the time span for logoff. You enter this value as a time span: hh:mm:ss where hh = hours, mm = minutes and ss = seconds. Valid values for this parameter are from 00:05:00 to 08:00:00 (5 minutes to 8 hours). The default value is 06:00:00 (6 hours).')]
    [ValidatePattern('^(0[0-7]:[0-5][0-9]:[0-5][0-9]|08:00:00)$')]
    [System.String] $ActivityBasedAuthenticationTimeoutInterval

    [DscProperty()]
    [System.ComponentModel.Description('The ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled parameter specifies whether to keep single sign-on enabled. The default value is $true.')]
    [System.Nullable[System.Boolean]] $ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AppsForOfficeEnabled parameter specifies whether to enable apps for Outlook features. By default, the parameter is set to $true. If the flag is set to $false, no new apps can be activated for any user in the organization.')]
    [System.Nullable[System.Boolean]] $AppsForOfficeEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AsyncSendEnabled parameter specifies whether to enable or disable async send in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $AsyncSendEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AuditDisabled parameter specifies whether to disable or enable mailbox auditing for the organization.')]
    [System.Nullable[System.Boolean]] $AuditDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter to $true will cause unknown users to be redirected to the on-premises endpoint and will allow on-premises users to discover their mailbox automatically.')]
    [System.Nullable[System.Boolean]] $AutodiscoverPartialDirSync

    [DscProperty()]
    [System.ComponentModel.Description('The AutoExpandingArchive switch enables the unlimited archiving feature (called auto-expanding archiving) in an Exchange Online organization. You don''t need to specify a value with this switch.')]
    [System.Nullable[System.Boolean]] $AutoExpandingArchive

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BlockMoveMessagesForGroupFolders')]
    [System.Nullable[System.Boolean]] $BlockMoveMessagesForGroupFolders

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsAddressEntryRestricted parameter specifies whether addresses can be collected from Bookings customers.')]
    [System.Nullable[System.Boolean]] $BookingsAddressEntryRestricted

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsAuthEnabled parameter specifies whether to enforce authentication to access all published Bookings pages.')]
    [System.Nullable[System.Boolean]] $BookingsAuthEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsBlockedWordsEnabled')]
    [System.Nullable[System.Boolean]] $BookingsBlockedWordsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsCreationOfCustomQuestionsRestricted parameter specifies whether Bookings admins can add custom questions.')]
    [System.Nullable[System.Boolean]] $BookingsCreationOfCustomQuestionsRestricted

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsEnabled parameter specifies whether to enable Microsoft Bookings in an organization.')]
    [System.Nullable[System.Boolean]] $BookingsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsExposureOfStaffDetailsRestricted parameter specifies whether the attributes of internal Bookings staff members are visible to external Bookings customers.')]
    [System.Nullable[System.Boolean]] $BookingsExposureOfStaffDetailsRestricted

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsMembershipApprovalRequired parameter enables a membership approval requirement when new staff members are added to Bookings calendars.')]
    [System.Nullable[System.Boolean]] $BookingsMembershipApprovalRequired

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsNamingPolicyEnabled')]
    [System.Nullable[System.Boolean]] $BookingsNamingPolicyEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsNamingPolicyPrefix')]
    [System.String] $BookingsNamingPolicyPrefix

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsNamingPolicyPrefixEnabled')]
    [System.Nullable[System.Boolean]] $BookingsNamingPolicyPrefixEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsNamingPolicySuffix')]
    [System.String] $BookingsNamingPolicySuffix

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsNamingPolicySuffixEnabled')]
    [System.Nullable[System.Boolean]] $BookingsNamingPolicySuffixEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsNotesEntryRestricted parameter specifies whether appointment notes can be collected from Bookings customers.')]
    [System.Nullable[System.Boolean]] $BookingsNotesEntryRestricted

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsPaymentsEnabled parameter specifies whether to enable online payment node inside Bookings.')]
    [System.Nullable[System.Boolean]] $BookingsPaymentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsPhoneNumberEntryRestricted parameter specifies whether phone numbers can be collected from Bookings customers.')]
    [System.Nullable[System.Boolean]] $BookingsPhoneNumberEntryRestricted

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsSearchEngineIndexDisabled')]
    [System.Nullable[System.Boolean]] $BookingsSearchEngineIndexDisabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for BookingsSmsMicrosoftEnabled')]
    [System.Nullable[System.Boolean]] $BookingsSmsMicrosoftEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsSocialSharingRestricted parameter allows you to control whether, or not, your users can see social sharing options inside Bookings.')]
    [System.Nullable[System.Boolean]] $BookingsSocialSharingRestricted

    [DscProperty()]
    [System.ComponentModel.Description('The ByteEncoderTypeFor7BitCharsets parameter specifies the 7-bit transfer encoding method for MIME format for messages sent to this remote domain.')]
    [System.Nullable[System.UInt32]] $ByteEncoderTypeFor7BitCharsets

    [DscProperty()]
    [System.ComponentModel.Description('No description available for ComplianceMLBgdCrawlEnabled')]
    [System.Nullable[System.Boolean]] $ComplianceMLBgdCrawlEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsActionableMessagesEnabled parameter specifies whether to enable or disable actionable buttons in messages (connector cards) from connected apps on Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ConnectorsActionableMessagesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsEnabled parameter specifies whether to enable or disable all connected apps in organization.')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsEnabledForOutlook parameter specifies whether to enable or disable connected apps in Outlook on the web. ')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabledForOutlook

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsEnabledForSharepoint parameter specifies whether to enable or disable connected apps on Sharepoint.')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabledForSharepoint

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsEnabledForTeams parameter specifies whether to enable or disable connected apps on Teams.')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabledForTeams

    [DscProperty()]
    [System.ComponentModel.Description('The ConnectorsEnabledForYammer parameter specifies whether to enable or disable connected apps on Yammer.')]
    [System.Nullable[System.Boolean]] $ConnectorsEnabledForYammer

    [DscProperty()]
    [System.ComponentModel.Description('Enable Customer Lockbox.')]
    [System.Nullable[System.Boolean]] $CustomerLockboxEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultAuthenticationPolicy parameter specifies the authentication policy that''s used for the whole organization. You can use any value that uniquely identifies the policy.')]
    [System.String] $DefaultAuthenticationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultGroupAccessType parameter specifies the default access type for Office 365 groups.')]
    [ValidateSet('Private', 'Public')]
    [System.String] $DefaultGroupAccessType

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultMinutesToReduceLongEventsBy parameter specifies the number of minutes to reduce calendar events by if the events are 60 minutes or longer.')]
    [ValidateRange(0, 29)]
    [System.Nullable[System.UInt32]] $DefaultMinutesToReduceLongEventsBy

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultMinutesToReduceShortEventsBy parameter specifies the number of minutes to reduce calendar events by if the events are less than 60 minutes long.')]
    [ValidateRange(0, 29)]
    [System.Nullable[System.UInt32]] $DefaultMinutesToReduceShortEventsBy

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderAgeLimit parameter specifies the default age limit for the contents of public folders across the entire organization. Content in a public folder is automatically deleted when this age limit is exceeded. This attribute applies to all public folders in the organization that don''t have their own AgeLimit setting. To specify a value, enter it as a time span: dd.hh:mm:ss where d = days, h = hours, m = minutes, and s = seconds. Or, enter the value $null. The default value is blank ($null).')]
    [ValidatePattern('^([0-9][0-9]|[0-9]).[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$')]
    [System.String] $DefaultPublicFolderAgeLimit

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderDeletedItemRetention parameter specifies the default value of the length of time to retain deleted items for public folders across the entire organization. This attribute applies to all public folders in the organization that don''t have their own RetainDeletedItemsFor attribute set.')]
    [ValidatePattern('^([0-9][0-9]|[0-9]).[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$')]
    [System.String] $DefaultPublicFolderDeletedItemRetention

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderIssueWarningQuota parameter specifies the default value across the entire organization for the public folder size at which a warning message is sent to this folder''s owners, warning that the public folder is almost full. This attribute applies to all public folders within the organization that don''t have their own warning quota attribute set. The default value of this attribute is unlimited. The valid input range for this parameter is from 0 through 2199023254529 bytes(2 TB). If you enter a value of unlimited, no size limit is imposed on the public folder.')]
    [System.String] $DefaultPublicFolderIssueWarningQuota

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderMaxItemSize parameter specifies the default maximum size for posted items within public folders across the entire organization. Items larger than the value of the DefaultPublicFolderMaxItemSize parameter are rejected. This attribute applies to all public folders within the organization that don''t have their own MaxItemSize attribute set. The default value of this attribute is unlimited.')]
    [System.String] $DefaultPublicFolderMaxItemSize

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderMovedItemRetention parameter specifies how long items that have been moved between mailboxes are kept in the source mailbox for recovery purposes before being removed by the Public Folder Assistant.')]
    [ValidatePattern('^([0-9][0-9]|[0-9]).[0-9][0-9]:[0-9][0-9]:[0-9][0-9]$')]
    [System.String] $DefaultPublicFolderMovedItemRetention

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultPublicFolderProhibitPostQuota parameter specifies the size of a public folder at which users are notified that the public folder is full. Users can''t post to a folder whose size is larger than the DefaultPublicFolderProhibitPostQuota parameter value. The default value of this attribute is unlimited.')]
    [System.String] $DefaultPublicFolderProhibitPostQuota

    [DscProperty()]
    [System.ComponentModel.Description('The DelayedDelicensingEnabled parameter enables or disables a 30 day grace period for Exchange Online license removals from mailboxes.')]
    [System.Nullable[System.Boolean]] $DelayedDelicensingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DirectReportsGroupAutoCreationEnabled parameter specifies whether to enable or disable the automatic creation of direct report Office 365 groups.')]
    [System.Nullable[System.Boolean]] $DirectReportsGroupAutoCreationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DisablePlusAddressInRecipients parameter specifies whether to enable or disable plus addressing (also known as subaddressing) for Exchange Online mailboxes.')]
    [System.Nullable[System.Boolean]] $DisablePlusAddressInRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The DistributionGroupDefaultOU parameter specifies the container where distribution groups are created by default.')]
    [System.String] $DistributionGroupDefaultOU

    [DscProperty()]
    [System.ComponentModel.Description('The DistributionGroupNameBlockedWordsList parameter specifies words that can''t be included in the names of distribution groups. Separate multiple values with commas.')]
    [System.String[]] $DistributionGroupNameBlockedWordsList

    [DscProperty()]
    [System.ComponentModel.Description('The DistributionGroupNamingPolicy parameter specifies the template applied to the name of distribution groups that are created in the organization. You can enforce that a prefix or suffix be applied to all distribution groups. Prefixes and suffixes can be either a string or an attribute, and you can combine strings and attributes.')]
    [System.String] $DistributionGroupNamingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The DLPViaDcsEnabled parameter specifies if Data Loss Prevention policies are evaluated using Exchange or Data Classification Services (DCS) policy evaluation.')]
    [System.Nullable[System.Boolean]] $DLPViaDcsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ElcProcessingDisabled parameter specifies whether to enable or disable the processing of mailboxes by the Managed Folder Assistant.')]
    [System.Nullable[System.Boolean]] $ElcProcessingDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The EnableOutlookEvents parameter specifies whether Outlook or Outlook on the web automatically discovers events from email messages and adds them to user calendars.')]
    [System.Nullable[System.Boolean]] $EnableOutlookEvents

    [DscProperty()]
    [System.ComponentModel.Description('The EndUserDLUpgradeFlowsDisabled parameter specifies whether to prevent users from upgrading their own distribution groups to Office 365 groups in an Exchange Online organization.')]
    [System.Nullable[System.Boolean]] $EndUserDLUpgradeFlowsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The EndUserMailNotificationForDelayedDelicensingEnabled parameter enables or disables periodic email warnings to affected users that have pending Exchange Online license removal requests on their mailboxes.')]
    [System.Nullable[System.Boolean]] $EndUserMailNotificationForDelayedDelicensingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowedAppIDs parameter specifies the Azure AD applications that are allowed to access Exchange Web Services (EWS) when the EwsEnabled parameter on this cmdlet is also set to the value $true. Unspecified applications are blocked from accessing EWS. You identify each application by its Azure AD application ID (GUID).')]
    [System.String[]] $EwsAllowedAppIDs

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowEntourage parameter specifies whether to enable or disable Entourage 2008 to access Exchange Web Services (EWS) for the entire organization.')]
    [System.Nullable[System.Boolean]] $EwsAllowEntourage

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowList parameter specifies the applications that are allowed to access EWS or REST when the EwsApplicationAccessPolicy parameter is set to EwsAllowList. Other applications that aren''t specified by this parameter aren''t allowed to access EWS or REST. You identify the application by its user agent string value. Wildcard characters (*) are supported.')]
    [System.String[]] $EwsAllowList

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowMacOutlook parameter enables or disables access to mailboxes by Outlook for Mac clients that use Exchange Web Services (for example, Outlook for Mac 2011 or later).')]
    [System.Nullable[System.Boolean]] $EwsAllowMacOutlook

    [DscProperty()]
    [System.ComponentModel.Description('The EwsAllowOutlook parameter enables or disables access to mailboxes by Outlook clients that use Exchange Web Services. Outlook uses Exchange Web Services for free/busy, out-of-office settings, and calendar sharing.')]
    [System.Nullable[System.Boolean]] $EwsAllowOutlook

    [DscProperty()]
    [System.ComponentModel.Description('The EwsApplicationAccessPolicy parameter specifies the client applications that have access to EWS and REST.')]
    [ValidateSet('EnforceAllowList', 'EnforceBlockList')]
    [System.String] $EwsApplicationAccessPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The EwsBlockList parameter specifies the applications that aren''t allowed to access EWS or REST when the EwsApplicationAccessPolicy parameter is set to EnforceBlockList. All other applications that aren''t specified by this parameter are allowed to access EWS or REST. You identify the application by its user agent string value. Wildcard characters (*) are supported.')]
    [System.String[]] $EwsBlockList

    [DscProperty()]
    [System.ComponentModel.Description('The EwsEnabled parameter specifies whether to globally enable or disable EWS access for the entire organization, regardless of what application is making the request.')]
    [System.Nullable[System.Boolean]] $EwsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeNotificationEnabled parameter enables or disables Exchange notifications sent to administrators regarding their organizations. Valid input for this parameter is $true or $false.')]
    [System.Nullable[System.Boolean]] $ExchangeNotificationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeNotificationRecipients parameter specifies the recipients for Exchange notifications sent to administrators regarding their organizations. If the ExchangeNotificationEnabled parameter is set to $false, no notification messages are sent. Be sure to enclose values that contain spaces in quotation marks and separate multiple values with commas. If this parameter isn''t set, Exchange notifications are sent to all administrators.')]
    [System.String[]] $ExchangeNotificationRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The FindTimeAttendeeAuthenticationEnabled parameter controls whether attendees are required to verify their identity in meeting polls using the FindTime Outlook add-in.')]
    [System.Nullable[System.Boolean]] $FindTimeAttendeeAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The FindTimeAutoScheduleDisabled parameter controls automatically scheduling the meeting once a consensus is reached in meeting polls using the FindTime Outlook add-in.')]
    [System.Nullable[System.Boolean]] $FindTimeAutoScheduleDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The FindTimeLockPollForAttendeesEnabled controls whether the Lock poll for attendees setting is managed by the organization.')]
    [System.Nullable[System.Boolean]] $FindTimeLockPollForAttendeesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The FindTimeOnlineMeetingOptionDisabled parameter controls the availability of the Online meeting checkbox for Teams in meeting polls using the FindTime Outlook add-in.')]
    [System.Nullable[System.Boolean]] $FindTimeOnlineMeetingOptionDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The FocusedInboxOn parameter enables or disables Focused Inbox for the organization.')]
    [System.Nullable[System.Boolean]] $FocusedInboxOn

    [DscProperty()]
    [System.ComponentModel.Description('The HierarchicalAddressBookRoot parameter specifies the user, contact, or group to be used as the root organization for a hierarchical address book in the Exchange organization. You can use any value that uniquely identifies the recipient.')]
    [System.String] $HierarchicalAddressBookRoot

    [DscProperty()]
    [System.ComponentModel.Description('The IPListBlocked parameter specifies the blocked IP addresses that aren''t allowed to connect to Exchange Online organization. These settings affect client connections that use Basic authentication where on-premises Active Directory Federation Services (ADFS) servers federate authentication with Azure Active Directory. Note that the new settings might take up to 4 hours to fully propagate across the service.')]
    [System.String[]] $IPListBlocked

    [DscProperty()]
    [System.ComponentModel.Description('No description available for IsGroupFoldersAndRulesEnabled')]
    [System.Nullable[System.Boolean]] $IsGroupFoldersAndRulesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for IsGroupMemberAllowedToEditContent')]
    [System.Nullable[System.Boolean]] $IsGroupMemberAllowedToEditContent

    [DscProperty()]
    [System.ComponentModel.Description('The LeanPopoutEnabled parameter specifies whether to enable faster loading of pop-out messages in Outlook on the web for Internet Explorer and Microsoft Edge.')]
    [System.Nullable[System.Boolean]] $LeanPopoutEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The LinkPreviewEnabled parameter specifies whether link preview of URLs in email messages is allowed for the organization.')]
    [System.Nullable[System.Boolean]] $LinkPreviewEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsAllTipsEnabled parameter specifies whether MailTips are enabled. The default value is $true.')]
    [System.Nullable[System.Boolean]] $MailTipsAllTipsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsExternalRecipientsTipsEnabled parameter specifies whether MailTips for external recipients are enabled. The default value is $false.')]
    [System.Nullable[System.Boolean]] $MailTipsExternalRecipientsTipsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsGroupMetricsEnabled parameter specifies whether MailTips that rely on group metrics data are enabled. The default value is $true.')]
    [System.Nullable[System.Boolean]] $MailTipsGroupMetricsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsLargeAudienceThreshold parameter specifies what a large audience is. The default value is 25.')]
    [System.Nullable[System.UInt32]] $MailTipsLargeAudienceThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The MailTipsMailboxSourcedTipsEnabled parameter specifies whether MailTips that rely on mailbox data (out-of-office or full mailbox) are enabled.')]
    [System.Nullable[System.Boolean]] $MailTipsMailboxSourcedTipsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for MaskClientIpInReceivedHeadersEnabled.')]
    [System.Nullable[System.Boolean]] $MaskClientIpInReceivedHeadersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for MatchSenderOrganizerProperties.')]
    [System.Nullable[System.Boolean]] $MatchSenderOrganizerProperties

    [DscProperty()]
    [System.ComponentModel.Description('No description available for MessageHighlightsEnabled.')]
    [System.Nullable[System.Boolean]] $MessageHighlightsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MessageRecallEnabled parameter enables or disables the message recall feature in the organization.')]
    [System.Nullable[System.Boolean]] $MessageRecallEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MessageRemindersEnabled parameter enables or disables the message reminders feature in the organization.')]
    [System.Nullable[System.Boolean]] $MessageRemindersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The MobileAppEducationEnabled specifies whether to show or hide the Outlook for iOS and Android education reminder in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $MobileAppEducationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OAuth2ClientProfileEnabled parameter enables or disables modern authentication in the Exchange organization.')]
    [System.Nullable[System.Boolean]] $OAuth2ClientProfileEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OnlineMeetingsByDefaultEnabled parameter specifies whether to set all meetings as Teams by default during meeting creation.')]
    [System.Nullable[System.Boolean]] $OnlineMeetingsByDefaultEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookGifPickerDisabled parameter disables the GIF Search (powered by Bing) feature that''s built into the Compose page in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $OutlookGifPickerDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookMobileGCCRestrictionsEnabled parameter specifies whether to enable or disable features within Outlook for iOS and Android that are not FedRAMP compliant for Office 365 US Government Community Cloud (GCC) customers.')]
    [System.Nullable[System.Boolean]] $OutlookMobileGCCRestrictionsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookPayEnabled parameter enables or disables Payments in Outlook in the Office 365 organization.')]
    [System.Nullable[System.Boolean]] $OutlookPayEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for OutlookTextPredictionDisabled.')]
    [System.Nullable[System.Boolean]] $OutlookTextPredictionDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The PublicComputersDetectionEnabled parameter specifies whether Outlook on the web will detect when a user signs from a public or private computer or network, and then enforces the attachment handling settings from public networks. The default is $false. However, if you set this parameter to $true, Outlook on the web will determine if the user is signing in from a public computer, and all public attachment handling rules will be applied and enforced.')]
    [System.Nullable[System.Boolean]] $PublicComputersDetectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFoldersEnabled parameter specifies how public folders are deployed in your organization.')]
    [ValidateSet('None', 'Local', 'Remote')]
    [System.String] $PublicFoldersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFolderShowClientControl parameter enables or disables access to public folders in Microsoft Outlook.')]
    [System.Nullable[System.Boolean]] $PublicFolderShowClientControl

    [DscProperty()]
    [System.ComponentModel.Description('The ReadTrackingEnabled parameter specifies whether the tracking for read status for messages in an organization is enabled. The default value is $false.')]
    [System.Nullable[System.Boolean]] $ReadTrackingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for RecallReadMessagesEnabled.')]
    [System.Nullable[System.Boolean]] $RecallReadMessagesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RemotePublicFolderMailboxes parameter specifies the identities of the public folder objects (represented as mail user objects locally) corresponding to the public folder mailboxes created in the remote forest. The public folder values set here are used only if the public folder deployment is a remote deployment.')]
    [System.String[]] $RemotePublicFolderMailboxes

    [DscProperty()]
    [System.ComponentModel.Description('The SendFromAliasEnabled parameter allows mailbox users to send messages using aliases (proxy addresses). It does this by disabling the rewriting of aliases to their primary SMTP address. This change is implemented in the Exchange Online service')]
    [System.Nullable[System.Boolean]] $SendFromAliasEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available for SharedDomainEmailAddressFlowEnabled.')]
    [System.Nullable[System.Boolean]] $SharedDomainEmailAddressFlowEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ShortenEventScopeDefault parameter specifies whether calendar events start late or end early in the organization.')]
    [System.String] $ShortenEventScopeDefault

    [DscProperty()]
    [System.ComponentModel.Description('The SiteMailboxCreationURL parameter specifies the URL that''s used to create site mailboxes. Site mailboxes improve collaboration and user productivity by allowing access to both SharePoint documents and Exchange email in Outlook 2013 or later.')]
    [System.String] $SiteMailboxCreationURL

    [DscProperty()]
    [System.ComponentModel.Description('The SmtpActionableMessagesEnabled parameter specifies whether to enable or disable action buttons in email messages in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SmtpActionableMessagesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TenantAdminNotificationForDelayedDelicensingEnabled parameter enables or disables weekly admin Service Health advisory notifications that are sent to admins.')]
    [System.Nullable[System.Boolean]] $TenantAdminNotificationForDelayedDelicensingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The VisibleMeetingUpdateProperties parameter specifies whether meeting message updates will be auto-processed on behalf of attendees. Auto-processed updates are applied to the attendee''s calendar item, and then the meeting message is moved to the deleted items. The attendee never sees the update in their inbox, but their calendar is updated.')]
    [System.String] $VisibleMeetingUpdateProperties

    [DscProperty()]
    [System.ComponentModel.Description('The WebPushNotificationsDisabled parameter specifies whether to enable or disable Web Push Notifications in Outlook on the Web. This feature provides web push notifications which appear on a user''s desktop while the user is not using Outlook on the Web. This brings awareness of incoming messages while they are working elsewhere on their computer.')]
    [System.Nullable[System.Boolean]] $WebPushNotificationsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The WebSuggestedRepliesDisabled parameter specifies whether to enable or disable Suggested Replies in Outlook on the web. This feature provides suggested replies to emails so users can easily and quickly respond to messages.')]
    [System.Nullable[System.Boolean]] $WebSuggestedRepliesDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The WorkspaceTenantEnabled parameter enables or disables workspace booking in the organization.')]
    [System.Nullable[System.Boolean]] $WorkspaceTenantEnabled

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is available only in the cloud-based service.')]
    [System.Nullable[System.Boolean]] $RejectDirectSend

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [EXOOrganizationConfig] Get()
    {
        $EndUserMailNotificationForDelayedDelicensingEnabledValue = $null
        $TenantAdminNotificationForDelayedDelicensingEnabledValue = $null
        $DelayedDelicensingEnabledStateValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOrganizationConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting EXOOrganizationConfig'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $ConfigSettings = Get-OrganizationConfig -RetrieveEwsOperationAccessPolicy -ErrorAction SilentlyContinue
                if ($null -eq $ConfigSettings)
                {
                    throw 'There was an error retrieving values from the Get function in EXOOrganizationConfig.'
                }
            }
            else
            {
                $ConfigSettings = $this.ExportedInstance
            }

            # DelayedDelicensingEnabledState
            if ($null -ne $configSettings.DelayedDelicensingEnabledState)
            {
                $DelayedDelicensingEnabledStateParsed = $configSettings.DelayedDelicensingEnabledState.ToString().Split(';')[0].Replace('Enabled: ', '')
                $DelayedDelicensingEnabledStateValue = $false
                if ($DelayedDelicensingEnabledStateParsed -eq 'True')
                {
                    $DelayedDelicensingEnabledStateValue = $true
                }
                else
                {
                    $DelayedDelicensingEnabledStateValue = $false
                }
            }

            # EndUserMailNotificationForDelayedDelicensingEnabled
            if ($null -ne $configSettings.EndUserMailNotificationForDelayedDelicensingState)
            {
                $EndUserMailNotificationForDelayedDelicensingEnabledParsed = $configSettings.EndUserMailNotificationForDelayedDelicensingState.ToString().Split(';')[0].Replace('Enabled: ', '')
                $EndUserMailNotificationForDelayedDelicensingEnabledValue = $false
                if ($EndUserMailNotificationForDelayedDelicensingEnabledParsed -eq 'True')
                {
                    $EndUserMailNotificationForDelayedDelicensingEnabledValue = $true
                }
                else
                {
                    $EndUserMailNotificationForDelayedDelicensingEnabledValue = $false
                }
            }

            # TenantAdminNotificationForDelayedDelicensingEnabled
            if ($null -ne $configSettings.TenantAdminNotificationForDelayedDelicensingState)
            {
                $TenantAdminNotificationForDelayedDelicensingEnabledParsed = $configSettings.TenantAdminNotificationForDelayedDelicensingState.ToString().Split(';')[0].Replace('Enabled: ', '')
                $TenantAdminNotificationForDelayedDelicensingEnabledValue = $false
                if ($TenantAdminNotificationForDelayedDelicensingEnabledParsed -eq 'True')
                {
                    $TenantAdminNotificationForDelayedDelicensingEnabledValue = $true
                }
                else
                {
                    $TenantAdminNotificationForDelayedDelicensingEnabledValue = $false
                }
            }

            $EwsAllowedAppIDsValue = @()
            if (-not [System.String]::IsNullOrWhiteSpace($ConfigSettings.EwsAllowedAppIDs))
            {
                $EwsAllowedAppIDsValue = [System.String[]]($ConfigSettings.EwsAllowedAppIDs.Split(',').Trim())
            }

            $results = @{
                IsSingleInstance                                          = 'Yes'
                ActivityBasedAuthenticationTimeoutEnabled                 = $ConfigSettings.ActivityBasedAuthenticationTimeoutEnabled
                ActivityBasedAuthenticationTimeoutInterval                = $ConfigSettings.ActivityBasedAuthenticationTimeoutInterval
                ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled = $ConfigSettings.ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled
                AppsForOfficeEnabled                                      = $ConfigSettings.AppsForOfficeEnabled
                AsyncSendEnabled                                          = $ConfigSettings.AsyncSendEnabled
                AuditDisabled                                             = $ConfigSettings.AuditDisabled
                AutodiscoverPartialDirSync                                = $ConfigSettings.AutodiscoverPartialDirSync
                AutoExpandingArchive                                      = $ConfigSettings.AutoExpandingArchiveEnabled
                BlockMoveMessagesForGroupFolders                          = $ConfigSettings.BlockMoveMessagesForGroupFolders
                BookingsAddressEntryRestricted                            = $ConfigSettings.BookingsAddressEntryRestricted
                BookingsAuthEnabled                                       = $ConfigSettings.BookingsAuthEnabled
                BookingsBlockedWordsEnabled                               = $ConfigSettings.BookingsBlockedWordsEnabled
                BookingsCreationOfCustomQuestionsRestricted               = $ConfigSettings.BookingsCreationOfCustomQuestionsRestricted
                BookingsEnabled                                           = $ConfigSettings.BookingsEnabled
                BookingsExposureOfStaffDetailsRestricted                  = $ConfigSettings.BookingsExposureOfStaffDetailsRestricted
                BookingsMembershipApprovalRequired                        = $ConfigSettings.BookingsMembershipApprovalRequired
                BookingsNamingPolicyEnabled                               = $ConfigSettings.BookingsNamingPolicyEnabled
                BookingsNamingPolicyPrefix                                = $ConfigSettings.BookingsNamingPolicyPrefix
                BookingsNamingPolicyPrefixEnabled                         = $ConfigSettings.BookingsNamingPolicyPrefixEnabled
                BookingsNamingPolicySuffix                                = $ConfigSettings.BookingsNamingPolicySuffix
                BookingsNamingPolicySuffixEnabled                         = $ConfigSettings.BookingsNamingPolicySuffixEnabled
                BookingsNotesEntryRestricted                              = $ConfigSettings.BookingsNotesEntryRestricted
                BookingsPaymentsEnabled                                   = $ConfigSettings.BookingsPaymentsEnabled
                BookingsPhoneNumberEntryRestricted                        = $ConfigSettings.BookingsPhoneNumberEntryRestricted
                BookingsSearchEngineIndexDisabled                         = $ConfigSettings.BookingsSearchEngineIndexDisabled
                BookingsSmsMicrosoftEnabled                               = $ConfigSettings.BookingsSmsMicrosoftEnabled
                BookingsSocialSharingRestricted                           = $ConfigSettings.BookingsSocialSharingRestricted
                ByteEncoderTypeFor7BitCharsets                            = $ConfigSettings.ByteEncoderTypeFor7BitCharsets
                ComplianceMLBgdCrawlEnabled                               = $ConfigSettings.ComplianceMLBgdCrawlEnabled
                ConnectorsActionableMessagesEnabled                       = $ConfigSettings.ConnectorsActionableMessagesEnabled
                ConnectorsEnabled                                         = $ConfigSettings.ConnectorsEnabled
                ConnectorsEnabledForOutlook                               = $ConfigSettings.ConnectorsEnabledForOutlook
                ConnectorsEnabledForSharepoint                            = $ConfigSettings.ConnectorsEnabledForSharepoint
                ConnectorsEnabledForTeams                                 = $ConfigSettings.ConnectorsEnabledForTeams
                ConnectorsEnabledForYammer                                = $ConfigSettings.ConnectorsEnabledForYammer
                CustomerLockboxEnabled                                    = $ConfigSettings.CustomerLockboxEnabled
                DefaultAuthenticationPolicy                               = $ConfigSettings.DefaultAuthenticationPolicy
                DefaultGroupAccessType                                    = $ConfigSettings.DefaultGroupAccessType
                DefaultMinutesToReduceLongEventsBy                        = $ConfigSettings.DefaultMinutesToReduceLongEventsBy
                DefaultMinutesToReduceShortEventsBy                       = $ConfigSettings.DefaultMinutesToReduceShortEventsBy
                DefaultPublicFolderAgeLimit                               = $ConfigSettings.DefaultPublicFolderAgeLimit
                DefaultPublicFolderDeletedItemRetention                   = $ConfigSettings.DefaultPublicFolderDeletedItemRetention
                DefaultPublicFolderIssueWarningQuota                      = $ConfigSettings.DefaultPublicFolderIssueWarningQuota
                DefaultPublicFolderMaxItemSize                            = $ConfigSettings.DefaultPublicFolderMaxItemSize
                DefaultPublicFolderMovedItemRetention                     = $ConfigSettings.DefaultPublicFolderMovedItemRetention
                DefaultPublicFolderProhibitPostQuota                      = $ConfigSettings.DefaultPublicFolderProhibitPostQuota
                DelayedDelicensingEnabled                                 = $DelayedDelicensingEnabledStateValue
                DirectReportsGroupAutoCreationEnabled                     = $ConfigSettings.DirectReportsGroupAutoCreationEnabled
                DisablePlusAddressInRecipients                            = $ConfigSettings.DisablePlusAddressInRecipients
                DistributionGroupDefaultOU                                = $ConfigSettings.DistributionGroupDefaultOU
                DistributionGroupNameBlockedWordsList                     = $ConfigSettings.DistributionGroupNameBlockedWordsList
                DistributionGroupNamingPolicy                             = $ConfigSettings.DistributionGroupNamingPolicy
                DLPViaDcsEnabled                                          = $ConfigSettings.DLPViaDcsEnabled
                ElcProcessingDisabled                                     = $ConfigSettings.ElcProcessingDisabled
                EnableOutlookEvents                                       = $ConfigSettings.EnableOutlookEvents
                EndUserDLUpgradeFlowsDisabled                             = $ConfigSettings.EndUserDLUpgradeFlowsDisabled
                EndUserMailNotificationForDelayedDelicensingEnabled       = $EndUserMailNotificationForDelayedDelicensingEnabledValue
                EwsAllowedAppIDs                                          = $EwsAllowedAppIDsValue
                EwsAllowEntourage                                         = $ConfigSettings.EwsAllowEntourage
                EwsAllowList                                              = $ConfigSettings.EwsAllowList
                EwsAllowMacOutlook                                        = $ConfigSettings.EwsAllowMacOutlook
                EwsAllowOutlook                                           = $ConfigSettings.EwsAllowOutlook
                EwsApplicationAccessPolicy                                = $ConfigSettings.EwsApplicationAccessPolicy
                EwsBlockList                                              = $ConfigSettings.EwsBlockList
                EwsEnabled                                                = $ConfigSettings.EwsEnabled
                ExchangeNotificationEnabled                               = $ConfigSettings.ExchangeNotificationEnabled
                ExchangeNotificationRecipients                            = $ConfigSettings.ExchangeNotificationRecipients
                FindTimeAttendeeAuthenticationEnabled                     = $ConfigSettings.FindTimeAttendeeAuthenticationEnabled
                FindTimeAutoScheduleDisabled                              = $ConfigSettings.FindTimeAutoScheduleDisabled
                FindTimeLockPollForAttendeesEnabled                       = $ConfigSettings.FindTimeLockPollForAttendeesEnabled
                FindTimeOnlineMeetingOptionDisabled                       = $ConfigSettings.FindTimeOnlineMeetingOptionDisabled
                FocusedInboxOn                                            = $ConfigSettings.FocusedInboxOn
                HierarchicalAddressBookRoot                               = $ConfigSettings.HierarchicalAddressBookRoot
                IPListBlocked                                             = $ConfigSettings.IPListBlocked
                IsGroupFoldersAndRulesEnabled                             = $ConfigSettings.IsGroupFoldersAndRulesEnabled
                IsGroupMemberAllowedToEditContent                         = $ConfigSettings.IsGroupMemberAllowedToEditContent
                LeanPopoutEnabled                                         = $ConfigSettings.LeanPopoutEnabled
                LinkPreviewEnabled                                        = $ConfigSettings.LinkPreviewEnabled
                MailTipsAllTipsEnabled                                    = $ConfigSettings.MailTipsAllTipsEnabled
                MailTipsExternalRecipientsTipsEnabled                     = $ConfigSettings.MailTipsExternalRecipientsTipsEnabled
                MailTipsGroupMetricsEnabled                               = $ConfigSettings.MailTipsGroupMetricsEnabled
                MailTipsLargeAudienceThreshold                            = $ConfigSettings.MailTipsLargeAudienceThreshold
                MailTipsMailboxSourcedTipsEnabled                         = $ConfigSettings.MailTipsMailboxSourcedTipsEnabled
                MaskClientIpInReceivedHeadersEnabled                      = $ConfigSettings.MaskClientIpInReceivedHeadersEnabled
                MatchSenderOrganizerProperties                            = $ConfigSettings.MatchSenderOrganizerProperties
                MessageHighlightsEnabled                                  = $ConfigSettings.MessageHighlightsEnabled
                MessageRecallEnabled                                      = $ConfigSettings.MessageRecallEnabled
                MessageRemindersEnabled                                   = $ConfigSettings.MessageRemindersEnabled
                MobileAppEducationEnabled                                 = $ConfigSettings.MobileAppEducationEnabled
                OAuth2ClientProfileEnabled                                = $ConfigSettings.OAuth2ClientProfileEnabled
                OnlineMeetingsByDefaultEnabled                            = $ConfigSettings.OnlineMeetingsByDefaultEnabled
                OutlookMobileGCCRestrictionsEnabled                       = $ConfigSettings.OutlookMobileGCCRestrictionsEnabled
                OutlookGifPickerDisabled                                  = $ConfigSettings.OutlookGifPickerDisabled
                OutlookPayEnabled                                         = $ConfigSettings.OutlookPayEnabled
                OutlookTextPredictionDisabled                             = $ConfigSettings.OutlookTextPredictionDisabled
                PublicComputersDetectionEnabled                           = $ConfigSettings.PublicComputersDetectionEnabled
                PublicFoldersEnabled                                      = $ConfigSettings.PublicFoldersEnabled
                PublicFolderShowClientControl                             = $ConfigSettings.PublicFolderShowClientControl
                ReadTrackingEnabled                                       = $ConfigSettings.ReadTrackingEnabled
                RecallReadMessagesEnabled                                 = $ConfigSettings.RecallReadMessagesEnabled
                RejectDirectSend                                          = $ConfigSettings.RejectDirectSend
                RemotePublicFolderMailboxes                               = $ConfigSettings.RemotePublicFolderMailboxes
                SendFromAliasEnabled                                      = $ConfigSettings.SendFromAliasEnabled
                SharedDomainEmailAddressFlowEnabled                       = $ConfigSettings.SharedDomainEmailAddressFlowEnabled
                ShortenEventScopeDefault                                  = $ConfigSettings.ShortenEventScopeDefault
                SiteMailboxCreationURL                                    = $ConfigSettings.SiteMailboxCreationURL
                SmtpActionableMessagesEnabled                             = $ConfigSettings.SmtpActionableMessagesEnabled
                TenantAdminNotificationForDelayedDelicensingEnabled       = $TenantAdminNotificationForDelayedDelicensingEnabledValue
                VisibleMeetingUpdateProperties                            = $ConfigSettings.VisibleMeetingUpdateProperties
                WebPushNotificationsDisabled                              = $ConfigSettings.WebPushNotificationsDisabled
                WebSuggestedRepliesDisabled                               = $ConfigSettings.WebSuggestedRepliesDisabled
                WorkspaceTenantEnabled                                    = $ConfigSettings.WorkspaceTenantEnabled
                Credential                                                = $this.Credential
                ApplicationId                                             = $this.ApplicationId
                CertificateThumbprint                                     = $this.CertificateThumbprint
                CertificatePath                                           = $this.CertificatePath
                CertificatePassword                                       = $this.CertificatePassword
                ManagedIdentity                                           = $this.ManagedIdentity
                TenantId                                                  = $this.TenantId
                AccessTokens                                              = $this.AccessTokens
            }

            if ($null -eq $ConfigSettings.AutoExpandingArchiveEnabled)
            {
                $results.AutoExpandingArchive = $false
            }

            if ([System.String]::IsNullOrEmpty($results.EwsApplicationAccessPolicy))
            {
                $results.Remove('EwsApplicationAccessPolicy')
            }

            if ($null -eq $this.EwsAllowList)
            {
                $results.Remove('EwsAllowList')
            }

            if ($null -eq $this.EwsBlockList)
            {
                $results.Remove('EwsBlockList')
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        if ($null -ne $this.EwsAllowList -and $null -ne $this.EwsBlockList)
        {
            throw "You can't specify both EWSAllowList and EWSBlockList properties."
        }

        Write-Verbose -Message 'Setting EXOOrganizationConfig'

        $null = $this.Connect('ExchangeOnline')

        Write-Verbose -Message "Setting EXOOrganizationConfig with values: $(Convert-M365DscHashtableToString -Hashtable $this.GetBoundParameters())"
        $SetValues = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetValues.Remove('IsSingleInstance') | Out-Null

        $isAutoExpandingArchiveEnabled = Get-OrganizationConfig | Select-Object -Property AutoExpandingArchiveEnabled

        if ($isAutoExpandingArchiveEnabled.AutoExpandingArchiveEnabled -eq $True)
        {
            $SetValues.Remove('AutoExpandingArchive') | Out-Null
        }

        $secondaryParameterSet = @{}
        if ($SetValues.ContainsKey('TenantAdminNotificationForDelayedDelicensingEnabled') -or $SetValues.ContainsKey('DelayedDelicensingEnabled') -or $SetValues.ContainsKey('EndUserMailNotificationForDelayedDelicensingEnabled'))
        {
            if ($SetValues.ContainsKey('DefaultMinutesToReduceLongEventsBy'))
            {
                $secondaryParameterSet.Add('DefaultMinutesToReduceLongEventsBy', $SetValues['DefaultMinutesToReduceLongEventsBy'])
                $SetValues.Remove('DefaultMinutesToReduceLongEventsBy') | Out-Null
            }
            if ($SetValues.ContainsKey('DefaultMinutesToReduceShortEventsBy'))
            {
                $secondaryParameterSet.Add('DefaultMinutesToReduceShortEventsBy', $SetValues['DefaultMinutesToReduceShortEventsBy'])
                $SetValues.Remove('DefaultMinutesToReduceShortEventsBy') | Out-Null
            }
            if ($SetValues.ContainsKey('ShortenEventScopeDefault'))
            {
                $secondaryParameterSet.Add('ShortenEventScopeDefault', $SetValues['ShortenEventScopeDefault'])
                $SetValues.Remove('ShortenEventScopeDefault') | Out-Null
            }
        }

        if ($SetValues.DelayedDelicensingEnabled -ne $true)
        {
            # If DelayedDelicensingEnabled is being set to false or does not exist, we cannot set the other two parameters
            $SetValues.Remove('TenantAdminNotificationForDelayedDelicensingEnabled') | Out-Null
            $SetValues.Remove('EndUserMailNotificationForDelayedDelicensingEnabled') | Out-Null
        }

        if ($SetValues.ContainsKey('EwsAllowedAppIDs'))
        {
            $SetValues['EwsAllowedAppIDs'] = $null
            if (@($this.EwsAllowedAppIDs).Count -gt 0)
            {
                $SetValues['EwsAllowedAppIDs'] = [System.String]::Join(',', $this.EwsAllowedAppIDs)
            }
        }

        Set-OrganizationConfig @SetValues

        if ($secondaryParameterSet.Count -gt 0)
        {
            Set-OrganizationConfig @secondaryParameterSet
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $dscContent = [System.Text.StringBuilder]::new()
            $organizationConfig = Get-OrganizationConfig -ErrorAction Stop
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                AccessTokens          = $this.AccessTokens
            }

            $this.ExportedInstance = $organizationConfig
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ContainsKey('DelayedDelicensingEnabled'))
                {
                    if ($DesiredValues.DelayedDelicensingEnabled -ne $true)
                    {
                        $ValuesToCheck.Remove('TenantAdminNotificationForDelayedDelicensingEnabled') | Out-Null
                        $ValuesToCheck.Remove('EndUserMailNotificationForDelayedDelicensingEnabled') | Out-Null
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [EXOOrganizationConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOrganizationConfig])
        {
            return $Values
        }

        $result = [EXOOrganizationConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
