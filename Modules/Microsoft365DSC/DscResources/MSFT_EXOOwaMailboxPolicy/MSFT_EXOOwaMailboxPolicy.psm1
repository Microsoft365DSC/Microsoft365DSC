using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOOwaMailboxPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the policy. The maximum length is 64 characters.')]
    [ValidateLength(1, 64)]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The AccountTransferEnabled parameter specifies whether to enable or disable QR code sign-in. By default, QR code sign-in is enabled.')]
    [System.Nullable[System.Boolean]] $AccountTransferEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ActionForUnknownFileAndMIMETypes parameter specifies how to handle file types that aren''t specified in the Allow, Block, and Force Save lists for file types and MIME types')]
    [ValidateSet('Allow', 'ForceSave', 'Block')]
    [System.String] $ActionForUnknownFileAndMIMETypes

    [DscProperty()]
    [System.ComponentModel.Description('The ActiveSyncIntegrationEnabled parameter specifies whether to enable or disable Exchange ActiveSync settings in Outlook on the web. ')]
    [System.Nullable[System.Boolean]] $ActiveSyncIntegrationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $AdditionalAccountsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AdditionalStorageProvidersAvailable parameter specifies whether to allow additional storage providers (for example, Box, Dropbox, Facebook, Google Drive, Egnyte, personal OneDrive) attachments in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $AdditionalStorageProvidersAvailable

    [DscProperty()]
    [System.ComponentModel.Description('The AllAddressListsEnabled parameter specifies which address lists are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $AllAddressListsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The AllowCopyContactsToDeviceAddressBook parameter specifies whether users can copy the contents of their Contacts folder to a mobile device''s native address book when using Outlook on the web for devices.')]
    [System.Nullable[System.Boolean]] $AllowCopyContactsToDeviceAddressBook

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedFileTypes parameter specifies the attachment file types (file extensions) that can be saved locally or viewed from Outlook on the web.')]
    [System.String[]] $AllowedFileTypes

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedMimeTypes parameter specifies the MIME extensions of attachments that allow the attachments to be saved locally or viewed from Outlook on the web.')]
    [System.String[]] $AllowedMimeTypes

    [DscProperty()]
    [System.ComponentModel.Description('The AllowedOrganizationAccountDomains parameter specifies the domains of additional organization accounts that users are allowed to open in Outlook on the web.')]
    [System.String[]] $AllowedOrganizationAccountDomains

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentsOfflineEnabledWin parameter specifies whether attachments are available offline in the new Outlook for Windows.')]
    [System.Nullable[System.Boolean]] $AttachmentsOfflineEnabledWin

    [DscProperty()]
    [System.ComponentModel.Description('The BizBarEnabled parameter specifies whether the business bar is enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $BizBarEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BlockedFileTypes parameter specifies a list of attachment file types (file extensions) that can''t be saved locally or viewed from Outlook on the web.')]
    [System.String[]] $BlockedFileTypes

    [DscProperty()]
    [System.ComponentModel.Description('The BlockedMimeTypes parameter specifies MIME extensions in attachments that prevent the attachments from being saved locally or viewed from Outlook on the web.')]
    [System.String[]] $BlockedMimeTypes

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $BookingsMailboxCreationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BookingsMailboxDomain parameter specifies the domain to use when creating Bookings mailboxes (for example, Bookings with me) from Outlook on the web.')]
    [System.String] $BookingsMailboxDomain

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $ChangeSettingsAccountEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ClassicAttachmentsEnabled parameter specifies whether users can attach local files as regular email attachments in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ClassicAttachmentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ConditionalAccessPolicy parameter specifies the Outlook on the Web Policy for limited access. For this feature to work properly, you also need to configure a Conditional Access policy in the Azure Active Directory Portal.')]
    [ValidateSet('Off', 'ReadOnly', 'ReadOnlyPlusAttachmentsBlocked')]
    [System.String] $ConditionalAccessPolicy

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultClientLanguage parameter specifies the default language of a users mailbox if the language has not already been set.')]
    [System.Nullable[System.Int32]] $DefaultClientLanguage

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultTheme parameter specifies the default theme that''s used in Outlook on the web when the user hasn''t selected a theme. The default value is blank ($null).')]
    [System.String] $DefaultTheme

    [DscProperty()]
    [System.ComponentModel.Description('The DirectFileAccessOnPrivateComputersEnabled parameter specifies the left-click options for attachments in Outlook on the web for private computer sessions. ')]
    [System.Nullable[System.Boolean]] $DirectFileAccessOnPrivateComputersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DirectFileAccessOnPrivateComputersEnabled parameter specifies the left-click options for attachments in Outlook on the web for public computer sessions.')]
    [System.Nullable[System.Boolean]] $DirectFileAccessOnPublicComputersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DisableFacebook switch specifies whether users can synchronize their Facebook contacts to their Contacts folder in Outlook on the web. By default, Facebook integration is enabled.')]
    [System.Nullable[System.Boolean]] $DisableFacebook

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayPhotosEnabled parameter specifies whether users see sender photos in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $DisplayPhotosEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The EmptyStateEnabled parameter specifies whether the empty state experience is enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $EmptyStateEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExplicitLogonEnabled parameter specifies whether to allow a user to open someone else''s mailbox in Outlook on the web (provided that user has permissions to the mailbox).')]
    [System.Nullable[System.Boolean]] $ExplicitLogonEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExternalImageProxyEnabled parameter specifies whether to load all external images through the Outlook external image proxy.')]
    [System.Nullable[System.Boolean]] $ExternalImageProxyEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ExternalSPMySiteHostURL specifies the My Site Host URL for external users.')]
    [System.String] $ExternalSPMySiteHostURL

    [DscProperty()]
    [System.ComponentModel.Description('The FeedbackEnabled parameter specifies whether to enable or disable inline feedback surveys in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $FeedbackEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ForceSaveAttachmentFilteringEnabled parameter specifies whether files are filtered before they can be saved from Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ForceSaveAttachmentFilteringEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ForceSaveFileTypes parameter specifies the attachment file types (file extensions) that can only be saved from Outlook on the web (not opened).')]
    [System.String[]] $ForceSaveFileTypes

    [DscProperty()]
    [System.ComponentModel.Description('The ForceSaveMimeTypes parameter specifies the MIME extensions in attachments that only allow the attachments to be saved locally (not opened).')]
    [System.String[]] $ForceSaveMimeTypes

    [DscProperty()]
    [System.ComponentModel.Description('The ForceWacViewingFirstOnPrivateComputers parameter specifies whether private computers must first preview an Office file as a web page in Office Online Server (formerly known as Office Web Apps Server and Web Access Companion Server) before opening the file in the local application.')]
    [System.Nullable[System.Boolean]] $ForceWacViewingFirstOnPrivateComputers

    [DscProperty()]
    [System.ComponentModel.Description('The ForceWacViewingFirstOnPublicComputers parameter specifies whether public computers must first preview an Office file as a web page in Office Online Server before opening the file in the local application.')]
    [System.Nullable[System.Boolean]] $ForceWacViewingFirstOnPublicComputers

    [DscProperty()]
    [System.ComponentModel.Description('The FreCardsEnabled parameter specifies whether the theme, signature, and phone cards are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $FreCardsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The GlobalAddressListEnabled parameter specifies whether the global address list is available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $GlobalAddressListEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The GroupCreationEnabled parameter specifies whether Office 365 group creation is available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $GroupCreationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The HideClassicOutlookToggleOut parameter specifies whether to hide the toggle that switches users from the new Outlook back to classic Outlook.')]
    [System.Nullable[System.Boolean]] $HideClassicOutlookToggleOut

    [DscProperty()]
    [System.ComponentModel.Description('The InstantMessagingEnabled parameter specifies whether instant messaging is available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $InstantMessagingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The InstantMessagingType parameter specifies the type of instant messaging provider in Outlook on the web.')]
    [ValidateSet('None', 'Ocs')]
    [System.String] $InstantMessagingType

    [DscProperty()]
    [System.ComponentModel.Description('The InterestingCalendarsEnabled parameter specifies whether interesting calendars are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $InterestingCalendarsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The InternalSPMySiteHostURL specifies the My Site Host URL for internal users.')]
    [System.String] $InternalSPMySiteHostURL

    [DscProperty()]
    [System.ComponentModel.Description('The IRMEnabled parameter specifies whether Information Rights Management (IRM) features are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $IRMEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $ItemsToOtherAccountsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The IsDefault switch specifies whether the Outlook on the web policy is the default policy that''s used to configure the Outlook on the web settings for new mailboxes.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('The JournalEnabled parameter specifies whether the Journal folder is available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $JournalEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The LinkedInEnabled parameter specifies whether users can connect their account to LinkedIn in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $LinkedInEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The LocalEventsEnabled parameter specifies whether local events calendars are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $LocalEventsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The LogonAndErrorLanguage parameter specifies the language that used in Outlook on the web for forms-based authentication and for error messages when a user''s current language setting can''t be read. A valid value is a supported Microsoft Windows Language Code Identifier (LCID). For example, 1033 is US English.')]
    [System.Nullable[System.Int32]] $LogonAndErrorLanguage

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $MessagePreviewsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The MonthlyUpdatesEnabled parameter specifies whether monthly feature updates are enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $MonthlyUpdatesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The NotesEnabled parameter specifies whether the Notes folder is available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $NotesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The NpsSurveysEnabled parameter specifies whether to enable or disable the Net Promoter Score (NPS) survey in Outlook on the web. The survey allows uses to rate Outlook on the web on a scale of 1 to 5, and to provide feedback and suggested improvements in free text.')]
    [System.Nullable[System.Boolean]] $NpsSurveysEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OfflineEnabledWeb parameter specifies whether offline mode is enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $OfflineEnabledWeb

    [DscProperty()]
    [System.ComponentModel.Description('The OfflineEnabledWin parameter specifies whether offline mode is enabled in the new Outlook for Windows.')]
    [System.Nullable[System.Boolean]] $OfflineEnabledWin

    [DscProperty()]
    [System.ComponentModel.Description('The OneDriveAttachmentsEnabled parameter specifies whether users can attach files from OneDrive as cloud attachments in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $OneDriveAttachmentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OneWinNativeOutlookEnabled parameter controls the availability of the new Outlook for Windows App.')]
    [System.Nullable[System.Boolean]] $OneWinNativeOutlookEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When the OrganizationEnabled parameter is set to $false, the Automatic Reply option doesn''t include external and internal options, the address book doesn''t show the organization hierarchy, and the Resources tab in Calendar forms is disabled.')]
    [System.Nullable[System.Boolean]] $OrganizationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OnSendAddinsEnabled parameter specifies whether to enable or disable on send add-ins in Outlook on the web (add-ins that support events when a user clicks Send).')]
    [System.Nullable[System.Boolean]] $OnSendAddinsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutboundCharset parameter specifies the character set that''s used for outgoing messages in Outlook on the web.')]
    [ValidateSet('AutoDetect', 'AlwaysUTF8', 'UserLanguageChoice')]
    [System.String] $OutboundCharset

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookBetaToggleEnabled parameter specifies whether to enable or disable the Outlook on the web Preview toggle. The Preview toggle allows users to try the new Outlook on the web experience.')]
    [System.Nullable[System.Boolean]] $OutlookBetaToggleEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookDataFile parameter controls the availability of Outlook data files (.pst) in Outlook on the web.')]
    [ValidateSet('Allow', 'NoExport', 'NoExportNoGrow', 'NoExportNoOpen', 'NoExportNoOpenNoGrow', 'Deny')]
    [System.String] $OutlookDataFile

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookNewslettersAccessLevel parameter specifies the access level for Outlook Newsletters in Outlook on the web.')]
    [ValidateSet('NoAccess', 'ReadOnly', 'ReadWrite', 'Undefined')]
    [System.String] $OutlookNewslettersAccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookNewslettersReactions parameter specifies whether reactions are available for Outlook Newsletters in Outlook on the web.')]
    [ValidateSet('DefaultOff', 'DefaultOn', 'Disabled', 'Undefined')]
    [System.String] $OutlookNewslettersReactions

    [DscProperty()]
    [System.ComponentModel.Description('The OutlookNewslettersShowMore parameter specifies the availability of the Show more option for Outlook Newsletters in Outlook on the web.')]
    [ValidateSet('DefaultOff', 'DefaultOn', 'Disabled', 'Undefined')]
    [System.String] $OutlookNewslettersShowMore

    [DscProperty()]
    [System.ComponentModel.Description('The OWALightEnabled parameter controls the availability of the light version of Outlook on the web.')]
    [System.Nullable[System.Boolean]] $OWALightEnabled

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $PersonalAccountsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PersonalBookingsDisabled parameter specifies whether personal bookings (Bookings with me) are disabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $PersonalBookingsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('The PersonalAccountCalendarsEnabled parameter specifies whether to allow users to connect to their personal Outlook.com or Google Calendar in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $PersonalAccountCalendarsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PhoneticSupportEnabled parameter specifies phonetically spelled entries in the address book. This parameter is available for use in Japan.')]
    [System.Nullable[System.Boolean]] $PhoneticSupportEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PlacesEnabled parameter specifies whether to enable or disable Places in Outlook on the web. Places lets users search, share, and map location details by using Bing.')]
    [System.Nullable[System.Boolean]] $PlacesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PremiumClientEnabled parameter controls the availability of the full version of Outlook Web App.')]
    [System.Nullable[System.Boolean]] $PremiumClientEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PrintWithoutDownloadEnabled specifies whether to allow printing of supported files without downloading the attachment in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $PrintWithoutDownloadEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ProjectMocaEnabled parameter enables or disables access to Project Moca in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ProjectMocaEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PublicFoldersEnabled parameter specifies whether a user can browse or read items in public folders in Outlook Web App.')]
    [System.Nullable[System.Boolean]] $PublicFoldersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RecoverDeletedItemsEnabled parameter specifies whether a user can use Outlook Web App to view, recover, or delete permanently items that have been deleted from the Deleted Items folder.')]
    [System.Nullable[System.Boolean]] $RecoverDeletedItemsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ReferenceAttachmentsEnabled parameter specifies whether users can attach files from the cloud as linked attachments in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ReferenceAttachmentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RemindersAndNotificationsEnabled parameter specifies whether notifications and reminders are enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $RemindersAndNotificationsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ReportJunkEmailEnabled parameter specifies whether users can report messages to Microsoft or unsubscribe from messages in Outlook on the web. ')]
    [System.Nullable[System.Boolean]] $ReportJunkEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RulesEnabled parameter specifies whether a user can view, create, or modify server-side rules in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $RulesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SatisfactionEnabled parameter specifies whether to enable or disable the satisfaction survey.')]
    [System.Nullable[System.Boolean]] $SatisfactionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SaveAttachmentsToCloudEnabled parameter specifies whether users can save regular email attachments to the cloud.')]
    [System.Nullable[System.Boolean]] $SaveAttachmentsToCloudEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SearchFoldersEnabled parameter specifies whether Search Folders are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SearchFoldersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SetPhotoEnabled parameter specifies whether users can add, change, and remove their sender photo in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SetPhotoEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SetPhotoURL parameter controls where users go to select their photo. Note that you can''t specify a URL that contains one or more picture files, as there is no mechanism to copy a URL photo to the properties of the users'' Exchange Online mailboxes.')]
    [System.String] $SetPhotoURL

    [DscProperty()]
    [System.ComponentModel.Description('No description available.')]
    [System.Nullable[System.Boolean]] $ShowOnlineArchiveEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SignaturesEnabled parameter specifies whether to enable or disable the use of signatures in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SignaturesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SkipCreateUnifiedGroupCustomSharepointClassification parameter specifies whether to skip a custom SharePoint page during the creation of Office 365 Groups in Outlook web app.')]
    [System.Nullable[System.Boolean]] $SkipCreateUnifiedGroupCustomSharepointClassification

    [DscProperty()]
    [System.ComponentModel.Description('The SMimeSuppressNameChecksEnabled parameter specifies whether to suppress name checks when validating S/MIME certificates in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SMimeSuppressNameChecksEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SpellCheckerEnabled parameter specifies whether to enable or disable the built-in spell checker in the light version of Outlook on the web.')]
    [System.Nullable[System.Boolean]] $SpellCheckerEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TasksEnabled parameter specifies whether Tasks are available in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $TasksEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TeamSnapCalendarsEnabled parameter specifies whether to allow users to connect to their personal TeamSnap calendars in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $TeamSnapCalendarsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The TextMessagingEnabled parameter specifies whether users can send and receive text messages in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $TextMessagingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The ThemeSelectionEnabled parameter specifies whether users can change the theme in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $ThemeSelectionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The UMIntegrationEnabled parameter specifies whether Unified Messaging (UM) integration is enabled in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $UMIntegrationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The UseGB18030 parameter specifies whether to use the GB18030 character set instead of GB2312 in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $UseGB18030

    [DscProperty()]
    [System.ComponentModel.Description('The UseISO885915 parameter specifies whether to use the character set ISO8859-15 instead of ISO8859-1 in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $UseISO885915

    [DscProperty()]
    [System.ComponentModel.Description('The UserVoiceEnabled parameter specifies whether to enable or disable Outlook UserVoice in Outlook on the web. Outlook UserVoice is a customer feedback area that''s available in Office 365.')]
    [System.Nullable[System.Boolean]] $UserVoiceEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WacEditingEnabled parameter specifies whether to enable or disable editing documents in Outlook on the web by using Office Online Server (formerly known as Office Web Apps Server and Web Access Companion Server). ')]
    [System.Nullable[System.Boolean]] $WacEditingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WacExternalServicesEnabled parameter specifies whether to enable or disable external services when viewing documents in Outlook on the web (for example, machine translation) by using Office Online Server.')]
    [System.Nullable[System.Boolean]] $WacExternalServicesEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WacOMEXEnabled parameter specifies whether to enable or disable apps for Outlook in Outlook on the web in Office Online Server.')]
    [System.Nullable[System.Boolean]] $WacOMEXEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WacViewingOnPrivateComputersEnabled parameter specifies whether to enable or disable web viewing of supported Office documents private computer sessions in Office Online Server (formerly known as Office Web Apps Server and Web Access Companion Server). By default, all Outlook on the web sessions are considered to be on private computers.')]
    [System.Nullable[System.Boolean]] $WacViewingOnPrivateComputersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WacViewingOnPublicComputersEnabled parameter specifies whether to enable or disable web viewing of supported Office documents in public computer sessions in Office Online Server. ')]
    [System.Nullable[System.Boolean]] $WacViewingOnPublicComputersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WeatherEnabled parameter specifies whether to enable or disable weather information in the calendar in Outlook on the web.')]
    [System.Nullable[System.Boolean]] $WeatherEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WebPartsFrameOptionsType parameter specifies what sources can access web parts in IFRAME or FRAME elements in Outlook on the web.')]
    [ValidateSet('None', 'SameOrigin', 'Deny')]
    [System.String] $WebPartsFrameOptionsType

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the OWA Mailbox Policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOOwaMailboxPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOOwaMailboxPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting OWA Mailbox Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $OwaMailboxPolicy = Get-OwaMailboxPolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $OwaMailboxPolicy)
                {
                    Write-Verbose -Message "OWA Mailbox Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $OwaMailboxPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "OWA Mailbox Policy with Name $($OwaMailboxPolicy.Name) found"

            $result = @{
                Name                                                 = $OwaMailboxPolicy.Name
                AccountTransferEnabled                               = $OwaMailboxPolicy.AccountTransferEnabled
                ActionForUnknownFileAndMIMETypes                     = $OwaMailboxPolicy.ActionForUnknownFileAndMIMETypes
                ActiveSyncIntegrationEnabled                         = $OwaMailboxPolicy.ActiveSyncIntegrationEnabled
                AdditionalAccountsEnabled                            = $OwaMailboxPolicy.AdditionalAccountsEnabled
                AdditionalStorageProvidersAvailable                  = $OwaMailboxPolicy.AdditionalStorageProvidersAvailable
                AllAddressListsEnabled                               = $OwaMailboxPolicy.AllAddressListsEnabled
                AllowCopyContactsToDeviceAddressBook                 = $OwaMailboxPolicy.AllowCopyContactsToDeviceAddressBook
                AllowedFileTypes                                     = $OwaMailboxPolicy.AllowedFileTypes
                AllowedMimeTypes                                     = $OwaMailboxPolicy.AllowedMimeTypes
                AllowedOrganizationAccountDomains                    = $OwaMailboxPolicy.AllowedOrganizationAccountDomains
                AttachmentsOfflineEnabledWin                         = $OwaMailboxPolicy.AttachmentsOfflineEnabledWin
                BizBarEnabled                                        = $OwaMailboxPolicy.BizBarEnabled
                BlockedFileTypes                                     = $OwaMailboxPolicy.BlockedFileTypes
                BlockedMimeTypes                                     = $OwaMailboxPolicy.BlockedMimeTypes
                BookingsMailboxCreationEnabled                       = $OwaMailboxPolicy.BookingsMailboxCreationEnabled
                BookingsMailboxDomain                                = $OwaMailboxPolicy.BookingsMailboxDomain
                ChangeSettingsAccountEnabled                         = $OwaMailboxPolicy.ChangeSettingsAccountEnabled
                ClassicAttachmentsEnabled                            = $OwaMailboxPolicy.ClassicAttachmentsEnabled
                ConditionalAccessPolicy                              = $OwaMailboxPolicy.ConditionalAccessPolicy
                DefaultClientLanguage                                = $OwaMailboxPolicy.DefaultClientLanguage
                DefaultTheme                                         = $OwaMailboxPolicy.DefaultTheme
                DirectFileAccessOnPrivateComputersEnabled            = $OwaMailboxPolicy.DirectFileAccessOnPrivateComputersEnabled
                DirectFileAccessOnPublicComputersEnabled             = $OwaMailboxPolicy.DirectFileAccessOnPublicComputersEnabled
                DisableFacebook                                      = $OwaMailboxPolicy.DisableFacebook
                DisplayPhotosEnabled                                 = $OwaMailboxPolicy.DisplayPhotosEnabled
                EmptyStateEnabled                                    = $OwaMailboxPolicy.EmptyStateEnabled
                ExplicitLogonEnabled                                 = $OwaMailboxPolicy.ExplicitLogonEnabled
                ExternalImageProxyEnabled                            = $OwaMailboxPolicy.ExternalImageProxyEnabled
                ExternalSPMySiteHostURL                              = $OwaMailboxPolicy.ExternalSPMySiteHostURL
                FeedbackEnabled                                      = $OwaMailboxPolicy.FeedbackEnabled
                ForceSaveAttachmentFilteringEnabled                  = $OwaMailboxPolicy.ForceSaveAttachmentFilteringEnabled
                ForceSaveFileTypes                                   = $OwaMailboxPolicy.ForceSaveFileTypes
                ForceSaveMimeTypes                                   = $OwaMailboxPolicy.ForceSaveMimeTypes
                ForceWacViewingFirstOnPrivateComputers               = $OwaMailboxPolicy.ForceWacViewingFirstOnPrivateComputers
                ForceWacViewingFirstOnPublicComputers                = $OwaMailboxPolicy.ForceWacViewingFirstOnPublicComputers
                FreCardsEnabled                                      = $OwaMailboxPolicy.FreCardsEnabled
                GlobalAddressListEnabled                             = $OwaMailboxPolicy.GlobalAddressListEnabled
                GroupCreationEnabled                                 = $OwaMailboxPolicy.GroupCreationEnabled
                HideClassicOutlookToggleOut                          = $OwaMailboxPolicy.HideClassicOutlookToggleOut
                InstantMessagingEnabled                              = $OwaMailboxPolicy.InstantMessagingEnabled
                InstantMessagingType                                 = $OwaMailboxPolicy.InstantMessagingType
                InterestingCalendarsEnabled                          = $OwaMailboxPolicy.InterestingCalendarsEnabled
                InternalSPMySiteHostURL                              = $OwaMailboxPolicy.InternalSPMySiteHostURL
                IRMEnabled                                           = $OwaMailboxPolicy.IRMEnabled
                ItemsToOtherAccountsEnabled                          = $OwaMailboxPolicy.ItemsToOtherAccountsEnabled
                IsDefault                                            = $OwaMailboxPolicy.IsDefault
                JournalEnabled                                       = $OwaMailboxPolicy.JournalEnabled
                LinkedInEnabled                                      = $OwaMailboxPolicy.LinkedInEnabled
                LocalEventsEnabled                                   = $OwaMailboxPolicy.LocalEventsEnabled
                LogonAndErrorLanguage                                = $OwaMailboxPolicy.LogonAndErrorLanguage
                MessagePreviewsDisabled                              = $OwaMailboxPolicy.MessagePreviewsDisabled
                MonthlyUpdatesEnabled                                = $OwaMailboxPolicy.MonthlyUpdatesEnabled
                NotesEnabled                                         = $OwaMailboxPolicy.NotesEnabled
                NpsSurveysEnabled                                    = $OwaMailboxPolicy.NpsSurveysEnabled
                OfflineEnabledWeb                                    = $OwaMailboxPolicy.OfflineEnabledWeb
                OfflineEnabledWin                                    = $OwaMailboxPolicy.OfflineEnabledWin
                OneDriveAttachmentsEnabled                           = $OwaMailboxPolicy.OneDriveAttachmentsEnabled
                OneWinNativeOutlookEnabled                           = $OwaMailboxPolicy.OneWinNativeOutlookEnabled
                OrganizationEnabled                                  = $OwaMailboxPolicy.OrganizationEnabled
                OnSendAddinsEnabled                                  = $OwaMailboxPolicy.OnSendAddinsEnabled
                OutboundCharset                                      = $OwaMailboxPolicy.OutboundCharset
                OutlookBetaToggleEnabled                             = $OwaMailboxPolicy.OutlookBetaToggleEnabled
                OutlookDataFile                                      = $OwaMailboxPolicy.OutlookDataFile
                OutlookNewslettersAccessLevel                        = $OwaMailboxPolicy.OutlookNewslettersAccessLevel
                OutlookNewslettersReactions                          = $OwaMailboxPolicy.OutlookNewslettersReactions
                OutlookNewslettersShowMore                           = $OwaMailboxPolicy.OutlookNewslettersShowMore
                OWALightEnabled                                      = $OwaMailboxPolicy.OWALightEnabled
                PersonalBookingsDisabled                             = $OwaMailboxPolicy.PersonalBookingsDisabled
                PersonalAccountCalendarsEnabled                      = $OwaMailboxPolicy.PersonalAccountCalendarsEnabled
                PersonalAccountsEnabled                              = $OwaMailboxPolicy.PersonalAccountsEnabled
                PhoneticSupportEnabled                               = $OwaMailboxPolicy.PhoneticSupportEnabled
                PlacesEnabled                                        = $OwaMailboxPolicy.PlacesEnabled
                PremiumClientEnabled                                 = $OwaMailboxPolicy.PremiumClientEnabled
                PrintWithoutDownloadEnabled                          = $OwaMailboxPolicy.PrintWithoutDownloadEnabled
                ProjectMocaEnabled                                   = $OwaMailboxPolicy.ProjectMocaEnabled
                PublicFoldersEnabled                                 = $OwaMailboxPolicy.PublicFoldersEnabled
                RecoverDeletedItemsEnabled                           = $OwaMailboxPolicy.RecoverDeletedItemsEnabled
                ReferenceAttachmentsEnabled                          = $OwaMailboxPolicy.ReferenceAttachmentsEnabled
                RemindersAndNotificationsEnabled                     = $OwaMailboxPolicy.RemindersAndNotificationsEnabled
                ReportJunkEmailEnabled                               = $OwaMailboxPolicy.ReportJunkEmailEnabled
                RulesEnabled                                         = $OwaMailboxPolicy.RulesEnabled
                SatisfactionEnabled                                  = $OwaMailboxPolicy.SatisfactionEnabled
                SaveAttachmentsToCloudEnabled                        = $OwaMailboxPolicy.SaveAttachmentsToCloudEnabled
                SearchFoldersEnabled                                 = $OwaMailboxPolicy.SearchFoldersEnabled
                SetPhotoEnabled                                      = $OwaMailboxPolicy.SetPhotoEnabled
                SetPhotoURL                                          = $OwaMailboxPolicy.SetPhotoURL
                ShowOnlineArchiveEnabled                             = $OwaMailboxPolicy.ShowOnlineArchiveEnabled
                SignaturesEnabled                                    = $OwaMailboxPolicy.SignaturesEnabled
                SkipCreateUnifiedGroupCustomSharepointClassification = $OwaMailboxPolicy.SkipCreateUnifiedGroupCustomSharepointClassification
                SMimeSuppressNameChecksEnabled                       = $OwaMailboxPolicy.SMimeSuppressNameChecksEnabled
                SpellCheckerEnabled                                  = $OwaMailboxPolicy.SpellCheckerEnabled
                TasksEnabled                                         = $OwaMailboxPolicy.TasksEnabled
                TeamSnapCalendarsEnabled                             = $OwaMailboxPolicy.TeamSnapCalendarsEnabled
                TextMessagingEnabled                                 = $OwaMailboxPolicy.TextMessagingEnabled
                ThemeSelectionEnabled                                = $OwaMailboxPolicy.ThemeSelectionEnabled
                UMIntegrationEnabled                                 = $OwaMailboxPolicy.UMIntegrationEnabled
                UseGB18030                                           = $OwaMailboxPolicy.UseGB18030
                UseISO885915                                         = $OwaMailboxPolicy.UseISO885915
                UserVoiceEnabled                                     = $OwaMailboxPolicy.UserVoiceEnabled
                WacEditingEnabled                                    = $OwaMailboxPolicy.WacEditingEnabled
                WacExternalServicesEnabled                           = $OwaMailboxPolicy.WacExternalServicesEnabled
                WacOMEXEnabled                                       = $OwaMailboxPolicy.WacOMEXEnabled
                WacViewingOnPrivateComputersEnabled                  = $OwaMailboxPolicy.WacViewingOnPrivateComputersEnabled
                WacViewingOnPublicComputersEnabled                   = $OwaMailboxPolicy.WacViewingOnPublicComputersEnabled
                WeatherEnabled                                       = $OwaMailboxPolicy.WeatherEnabled
                WebPartsFrameOptionsType                             = $OwaMailboxPolicy.WebPartsFrameOptionsType
                Ensure                                               = 'Present'
                Credential                                           = $this.Credential
                ApplicationId                                        = $this.ApplicationId
                CertificateThumbprint                                = $this.CertificateThumbprint
                CertificatePath                                      = $this.CertificatePath
                CertificatePassword                                  = $this.CertificatePassword
                ManagedIdentity                                      = $this.ManagedIdentity
                TenantId                                             = $this.TenantId
                AccessTokens                                         = $this.AccessTokens
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

        Write-Verbose -Message "Setting OWA Mailbox Policy configuration for $($this.Name)"

        $currentOwaMailboxPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewOwaMailboxPolicyParams = @{
            Name      = $this.Name
            IsDefault = $this.IsDefault
            Confirm   = $false
        }

        $SetOwaMailboxPolicyParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetOwaMailboxPolicyParams.Add('Identity', $this.Name)
        $SetOwaMailboxPolicyParams.Remove('Name') | Out-Null

        # CASE: OWA Mailbox Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentOwaMailboxPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "OWA Mailbox Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create OWA Mailbox Policy
            New-OwaMailboxPolicy @NewOwaMailboxPolicyParams

            #Configure new OWA Mailbox Policy
            $attempt = 1
            while ($true)
            {
                try
                {
                    Set-OwaMailboxPolicy @SetOwaMailboxPolicyParams -ErrorAction Stop
                    break
                }
                catch
                {
                    if ($attempt -ge 5 -or -not (Test-M365DSCNotFoundError -ErrorRecord $_))
                    {
                        throw
                    }

                    $attempt++
                    Start-Sleep -Seconds 5
                }
            }

        }
        # CASE: OWA Mailbox Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentOwaMailboxPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "OWA Mailbox Policy '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-OwaMailboxPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: OWA Mailbox Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentOwaMailboxPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "OWA Mailbox Policy '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting OWA Mailbox Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetOwaMailboxPolicyParams)"
            Set-OwaMailboxPolicy @SetOwaMailboxPolicyParams
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
            [array]$AllOwaMailboxPolicies = Get-OwaMailboxPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllOwaMailboxPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($OwaMailboxPolicy in $AllOwaMailboxPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllOwaMailboxPolicies.Length)] $($OwaMailboxPolicy.Name)" -DeferWrite

                $Params = @{
                    Name                  = $OwaMailboxPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $OwaMailboxPolicy
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

    hidden [EXOOwaMailboxPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOOwaMailboxPolicy])
        {
            return $Values
        }

        $result = [EXOOwaMailboxPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
