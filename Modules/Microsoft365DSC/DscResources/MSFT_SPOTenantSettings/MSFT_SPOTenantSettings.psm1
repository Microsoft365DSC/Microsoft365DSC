using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOTenantSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Enables OneDrive and SharePoint integration with Microsoft Entra B2B.')]
    [System.Nullable[System.Boolean]] $EnableAzureADB2BIntegration

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the lower bound on the compatibility level for new sites.')]
    [System.Nullable[System.UInt32]] $MinCompatibilityLevel

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the upper bound on the compatibility level for new sites.')]
    [System.Nullable[System.UInt32]] $MaxCompatibilityLevel

    [DscProperty()]
    [System.ComponentModel.Description('Removes the search capability from People Picker. Note, recently resolved names will still appear in the list until browser cache is cleared or expired.')]
    [System.Nullable[System.Boolean]] $SearchResolveExactEmailOrUPN

    [DscProperty()]
    [System.ComponentModel.Description('When set to true this will disable the ability to use Modern Authentication that leverages ADAL across the tenant.')]
    [System.Nullable[System.Boolean]] $OfficeClientADALDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuring whether users will be able to create anonymous requests for people to upload files regardless of the Share with anyone link configuration setting.')]
    [System.Nullable[System.Boolean]] $OneDriveRequestFilesLinkEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before a Request files link expires for all OneDrive sites. The value can be from 0 to 730 days. To remove the expiration requirement, set the value to zero (0).')]
    [ValidateRange(0, 730)]
    [System.Nullable[System.UInt32]] $OneDriveRequestFilesLinkExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Setting this parameter prevents Office clients using non-modern authentication protocols from accessing SharePoint Online resources.')]
    [System.Nullable[System.Boolean]] $LegacyAuthProtocolsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the home realm discovery value to be sent to Azure Active Directory (AAD) during the user sign-in process.')]
    [System.String] $SignInAccelerationDomain

    [DscProperty()]
    [System.ComponentModel.Description('Lets SharePoint issue a special cookie that will allow this feature to work even when Keep Me Signed In is not selected.')]
    [System.Nullable[System.Boolean]] $UsePersistentCookiesForExplorerView

    [DscProperty()]
    [System.ComponentModel.Description('Configure PublicCDN')]
    [System.Nullable[System.Boolean]] $PublicCdnEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configure filetypes allowed for PublicCDN')]
    [System.String] $PublicCdnAllowedFileTypes

    [DscProperty()]
    [System.ComponentModel.Description('When set to $true, users aren''t able to share with security groups or SharePoint groups.')]
    [System.Nullable[System.Boolean]] $UseFindPeopleInPeoplePicker

    [DscProperty()]
    [System.ComponentModel.Description('When set to $true, users aren''t able to share with security groups or SharePoint groups.')]
    [System.Nullable[System.Boolean]] $NotificationsInSharePointEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether an email notification should be sent to the OneDrive for Business owners when an anonymous links are created or changed.')]
    [System.Nullable[System.Boolean]] $OwnerAnonymousNotification

    [DscProperty()]
    [System.ComponentModel.Description('When this parameter is set to true, an email notification that user receives when is mentioned, includes the surrounding document context. Set it to false to disable this feature.')]
    [System.Nullable[System.Boolean]] $AllowCommentsTextOnEmailEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables web property bag update when DenyAddAndCustomizePages is enabled. When AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled is set to $true, web property bag can be updated even if DenyAddAndCustomizePages is turned on when the user had AddAndCustomizePages (prior to DenyAddAndCustomizePages removing it).')]
    [System.Nullable[System.Boolean]] $AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables of disables applications running in app-only mode to access IB sites.')]
    [System.Nullable[System.Boolean]] $AppBypassInformationBarriers

    [DscProperty()]
    [System.ComponentModel.Description('When the feature is enabled, all guest users are subject to conditional access policy. By default guest users who are accessing SharePoint Online files with pass code are exempt from the conditional access policy.')]
    [System.Nullable[System.Boolean]] $ApplyAppEnforcedRestrictionsToAdHocRecipients

    [DscProperty()]
    [System.ComponentModel.Description('Can be used to configure a custom page to show when a user is navigating to a SharePoint Online site that has been archived using Microsoft Syntex Archiving.')]
    [System.String] $ArchiveRedirectUrl

    [DscProperty()]
    [System.ComponentModel.Description('The File Type IDs which need to specified to prevent download. Allowed values: TeamsMeetingRecording.')]
    [System.String[]] $BlockDownloadFileTypeIds

    [DscProperty()]
    [System.ComponentModel.Description('You can block the download of Teams meeting recording files from SharePoint or OneDrive. This allows users to remain productive while addressing the risk of accidental data loss. Users have browser-only access to play the meeting recordings with no ability to download or sync files or access them through apps.')]
    [System.Nullable[System.Boolean]] $BlockDownloadFileTypePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Allows blocking of the automated e-mail being sent when somebody uploads a document to a site that''s protected with a sensitivity label and their document has a higher priority sensitivity label than the sensitivity label applied to the site.')]
    [System.Nullable[System.Boolean]] $BlockSendLabelMismatchEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before a Request files link expires for all SharePoint sites (not including OneDrive sites). The value can be from 0 to 730 days.')]
    [ValidateRange(0, 730)]
    [System.Nullable[System.UInt32]] $CoreRequestFilesLinkExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Enable or disable the Request files link on the core partition for all SharePoint sites (not including OneDrive sites). If this value is not set, Request files will only show for OneDrives with Anyone links enabled.')]
    [System.Nullable[System.Boolean]] $CoreRequestFilesLinkEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultOneDriveInformationBarrierMode sets the information barrier mode for all OneDrive sites. The valid values are: Open, Explicit, Implicit, OwnerModerated, Mixed.')]
    [ValidateSet('Open', 'Explicit', 'Implicit', 'OwnerModerated', 'Mixed')]
    [System.String] $DefaultOneDriveInformationBarrierMode

    [DscProperty()]
    [System.ComponentModel.Description('Allows temporary whiteboard collaboration for anonymous meeting participants during Teams meetings.')]
    [ValidateSet('Unspecified', 'On', 'Off')]
    [System.String] $AllowAnonymousMeetingParticipantsToAccessWhiteboards

    [DscProperty()]
    [System.ComponentModel.Description('This parameter exempts users in the specified security groups from this policy so that they can download meeting recording files.')]
    [System.String[]] $ExcludedBlockDownloadGroupIds

    [DscProperty()]
    [System.ComponentModel.Description('Use this to turn off setting the default sensitivity label for a document library.')]
    [System.Nullable[System.Boolean]] $DisableDocumentLibraryDefaultLabeling

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables users in the organization to authenticate SharePoint applications using popups.')]
    [System.Nullable[System.Boolean]] $IsEnableAppAuthPopUpEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days to keep versions when version history limits are managed manually.')]
    [System.Nullable[System.UInt32]] $ExpireVersionsAfterDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of major versions to keep when version history limits are managed manually.')]
    [System.Nullable[System.UInt32]] $MajorVersionLimit

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables AutoExpiration version trim for document libraries. Parameter `ExpireVersionsAfterDays` is required when `EnableAutoExpirationVersionTrim` is false. Set `ExpireVersionsAfterDays` to 0 for NoExpiration, set it to greater or equal 30 for ExpireAfter.')]
    [System.Nullable[System.Boolean]] $EnableAutoExpirationVersionTrim

    [DscProperty()]
    [System.ComponentModel.Description('Use this parameter to disable or enable Viva Connections analytics.')]
    [System.Nullable[System.Boolean]] $DisableVivaConnectionsAnalytics

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether guest users can be site collection administrators on SharePoint sites. Valid values are: Unspecified, On, Off')]
    [ValidateSet('Unspecified', 'On', 'Off')]
    [System.String] $CoreBlockGuestsAsSiteAdmin

    [DscProperty()]
    [System.ComponentModel.Description('Sets whether Whiteboard is enabled or disabled for OneDrive for Business users.')]
    [System.Nullable[System.Boolean]] $IsWBFluidEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value to specify whether CollabMeetingNotes Fluid Framework is enabled.')]
    [System.Nullable[System.Boolean]] $IsCollabMeetingNotesFluidEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets the IBImplicitGroupBased value.')]
    [System.Nullable[System.Boolean]] $IBImplicitGroupBased

    [DscProperty()]
    [System.ComponentModel.Description('Displays the Open in desktop option for files synchronized with the OneDrive sync app.')]
    [System.Nullable[System.Boolean]] $ShowOpenInDesktopOptionForSyncedFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows showing group suggestions for information barriers in the People Picker.')]
    [System.Nullable[System.Boolean]] $ShowPeoplePickerGroupSuggestionsForIB

    [DscProperty()]
    [System.ComponentModel.Description('Enables reduced session timeout for temporary URLs used by apps for document download scenarios. Reduction occurs when an app redeeming an IP address does not match the original requesting IP. The default value is 15 minutes if ReduceTempTokenLifetimeValue is not set.')]
    [System.Nullable[System.Boolean]] $ReduceTempTokenLifetimeEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Optional value, in minutes, to set the session timeout for temporary URLs. Allowed values are from 5 to 15. The default value is 15 minutes.')]
    [System.Nullable[System.UInt32]] $ReduceTempTokenLifetimeValue

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether viewers commenting on media items is disabled or not.')]
    [System.Nullable[System.Boolean]] $ViewersCanCommentOnMediaDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a help link shown when Conditional Access Policy blocks a user. The value must be a valid URL starting with http:// or https://.')]
    [System.String] $ConditionalAccessPolicyErrorHelpLink

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a URL appended to the external sharing policy block message to direct users to internal guidance or request portals.')]
    [System.String] $CustomizedExternalSharingServiceUrl

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the At A Glance feature in sharing e-mails.')]
    [System.Nullable[System.Boolean]] $IncludeAtAGlanceInShareEmails

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables mass delete detection notifications.')]
    [System.Nullable[System.Boolean]] $MassDeleteNotificationDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Sets the sharing state for blocking guests as site admin in OneDrive. Valid values are: On, Off, Unspecified')]
    [ValidateSet('On', 'Off', 'Unspecified')]
    [System.String] $OneDriveBlockGuestsAsSiteAdmin

    [DscProperty()]
    [System.ComponentModel.Description('Sets the retention period for the recycle bin. The value of Recycle Bin Retention Period must be between 14 and 93. By default it is set to 93.')]
    [ValidateRange(14, 93)]
    [System.Nullable[System.UInt32]] $RecycleBinRetentionPeriod

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables legacy browser authentication protocols.')]
    [System.Nullable[System.Boolean]] $LegacyBrowserAuthProtocolsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables showing the organization-wide sharing option in the sharing dialog for videos.')]
    [System.Nullable[System.Boolean]] $EnableDiscoverableByOrganizationForVideos

    [DscProperty()]
    [System.ComponentModel.Description('Sets a custom learn more link to inform users denied access due to restricted site access control policy.')]
    [System.String] $RestrictedAccessControlforSitesErrorHelpLink

    [DscProperty()]
    [System.ComponentModel.Description('Sets a value to specify whether Workflow 2010 is disabled.')]
    [System.Nullable[System.Boolean]] $Workflow2010Disabled

    [DscProperty()]
    [System.ComponentModel.Description('Sets a value to specify whether the sync button on document libraries is hidden.')]
    [System.Nullable[System.Boolean]] $HideSyncButtonOnDocLib

    [DscProperty()]
    [System.ComponentModel.Description('Sets the default destination for the Stream app launcher tile.')]
    [System.Nullable[System.Int32]] $StreamLaunchConfig

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether media reactions are enabled.')]
    [System.Nullable[System.Boolean]] $EnableMediaReactions

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether content security policy is enabled.')]
    [System.Nullable[System.Boolean]] $ContentSecurityPolicyEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables activation of spaces.')]
    [System.Nullable[System.Boolean]] $DisableSpacesActivation

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether apps can bypass the unmanaged device policy.')]
    [System.Nullable[System.Boolean]] $AllowAppsBypassOfUnmanagedDevicePolicy

    [DscProperty()]
    [System.ComponentModel.Description('Allows administrators to prevent specific Adaptive Card Extensions from being added to pages or rendering on pages where they were previously added.')]
    [System.String[]] $DisabledAdaptiveCardExtensionIds

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables writing SharePoint News and Announcement notification data to each user''s NewsNotificationList.')]
    [System.Nullable[System.Boolean]] $EnableNotificationsSubscriptions

    [DscProperty()]
    [System.ComponentModel.Description('When set to true, a valid request digest is required for state-changing SOAP API calls.')]
    [System.Nullable[System.Boolean]] $EnforceRequestDigest

    [DscProperty()]
    [System.ComponentModel.Description('Sets the Transport Layer Security (TLS) token binding policy setting.')]
    [ValidateSet('Audit', 'None', 'PassiveEnforcement', 'StrictEnforcement')]
    [System.String] $TlsTokenBindingPolicyValue

    [DscProperty()]
    [System.ComponentModel.Description('Sets the authentication context resilience mode.')]
    [ValidateSet('DefaultAAD', 'Disabled', 'Enabled')]
    [System.String] $AuthContextResilienceMode

    [DscProperty()]
    [System.ComponentModel.Description('Sets the All-Organization Security Group by object ID.')]
    [System.String] $AllOrganizationSecurityGroupId

    [DscProperty()]
    [System.ComponentModel.Description('Sets the site templates that receive content type hub synchronization.')]
    [System.String[]] $ContentTypeSyncSiteTemplatesList

    [DscProperty()]
    [System.ComponentModel.Description('Sets whether webparts that support inserting images, like for example Image or Hero webpart, the Web search (Powered by Bing) should allow choosing external images.')]
    [System.Nullable[System.Boolean]] $FilePickerExternalImageSearchEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Defines if the default themes are visible or hidden')]
    [System.Nullable[System.Boolean]] $HideDefaultThemes

    [DscProperty()]
    [System.ComponentModel.Description('To enable or disable Sync button on Team sites')]
    [System.Nullable[System.Boolean]] $HideSyncButtonOnTeamSite

    [DscProperty()]
    [System.ComponentModel.Description('Allows turning on support for data access in the Viva Connections Adaptive Card Designer.')]
    [System.Nullable[System.Boolean]] $IsDataAccessInCardDesignerEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block external sharing until at least one Office DLP policy scans the content of the file.')]
    [ValidateSet('AllowExternalSharing', 'BlockExternalSharing')]
    [System.String] $MarkNewFilesSensitiveByDefault

    [DscProperty()]
    [System.ComponentModel.Description('When the feature is enabled, videos can have transcripts generated on demand or generated automatically in certain scenarios. This is the default because the policy is default on. If a video owner decides they don''t want the transcript, they can always hide or delete it from that video. Possible values: Enabled, Disabled.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $MediaTranscription

    [DscProperty()]
    [System.ComponentModel.Description('When the feature is enabled, videos can have transcripts generated automatically on upload. The policy is default on. If a tenant admin decides to disable the feature, he can do so by disabling the policy at tenant level. This feature can not be enabled or disabled at site level. Possible values: Enabled, Disabled.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $MediaTranscriptionAutomaticFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Provide GUID for the Web Parts that are to be disabled on the Sharepoint Site')]
    [System.String[]] $DisabledWebPartIds

    [DscProperty()]
    [System.ComponentModel.Description('This parameter allows site owners to create or update the service principal.')]
    [System.Nullable[System.Boolean]] $SiteOwnerManageLegacyServicePrincipalEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Disables or enables the Social Bar. It will give users the ability to like a page, see the number of views, likes, and comments on a page, and see the people who have liked a page.')]
    [System.Nullable[System.Boolean]] $SocialBarOnSitePagesDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Set to false to enable a comment section on all site pages, users who have access to the pages can leave comments. Set to true to disable this feature.')]
    [System.Nullable[System.Boolean]] $CommentsOnSitePagesDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Boolean indicating if Azure Information Protection (AIP) should be enabled on the tenant.')]
    [System.Nullable[System.Boolean]] $EnableAIPIntegration

    [DscProperty()]
    [System.ComponentModel.Description('Allows turning on support for sensitivity labels on OneNote files in SharePoint and OneDrive.')]
    [System.Nullable[System.Boolean]] $EnableSensitivityLabelForOneNote

    [DscProperty()]
    [System.ComponentModel.Description('Allows turning on support for PDFs with sensitivity labels.')]
    [System.Nullable[System.Boolean]] $EnableSensitivityLabelForPDF

    [DscProperty()]
    [System.ComponentModel.Description('Allows turning on support for sensitivity labels on video files in SharePoint and OneDrive.')]
    [System.Nullable[System.Boolean]] $EnableSensitivityLabelForVideoFiles

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether or not we need to include external participants in shared channels for SharePoint access restriction.')]
    [System.Nullable[System.Boolean]] $ExemptNativeUsersFromTenantLevelRestricedAccessControl

    [DscProperty()]
    [System.ComponentModel.Description('List of security groups to include in OneDrive access restrictions')]
    [System.String[]] $AllowSelectSGsInODBListInTenant

    [DscProperty()]
    [System.ComponentModel.Description('List of security groups to exclude in OneDrive access restrictions')]
    [System.String[]] $DenySelectSGsInODBListInTenant

    [DscProperty()]
    [System.ComponentModel.Description('List of security groups to exclude in SharePoint access restrictions')]
    [System.String[]] $DenySelectSecurityGroupsInSPSitesList

    [DscProperty()]
    [System.ComponentModel.Description('List of security groups to include in SharePoint access restrictions.')]
    [System.String[]] $AllowSelectSecurityGroupsInSPSitesList

    [DscProperty()]
    [System.ComponentModel.Description('The default timezone of a tenant for newly created sites.')]
    [System.String] $TenantDefaultTimezone

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value to specify if user checks handle mobile friendly url.')]
    [System.Nullable[System.Boolean]] $MobileFriendlyUrlEnabledInTenant

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value to specify the advanced setting of the conditional access policy.')]
    [System.Nullable[System.Boolean]] $AllowDownloadingNonWebViewableFiles

    [DscProperty()]
    [System.ComponentModel.Description('Prevents users from editing Office files in the browser and copying and pasting Office file contents out of the browser window.')]
    [System.Nullable[System.Boolean]] $AllowEditing

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables file-level archiving for SharePoint Online sites in the tenant. When set to $false, users can no longer archive files on any site even if the site-level setting is enabled. Existing archived files remain archived and can still be reactivated.')]
    [System.Nullable[System.Boolean]] $AllowFileArchive

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether newly created SharePoint Online sites have file-level archiving enabled by default. Use this together with `-AllowFileArchive $true` when you want new sites to inherit file archiving automatically instead of enabling it site by site.')]
    [System.Nullable[System.Boolean]] $AllowFileArchiveOnNewSitesByDefault

    [DscProperty()]
    [System.ComponentModel.Description('Set whether to hide the sync button on OneDrive for Business sites.')]
    [System.Nullable[System.Boolean]] $HideSyncButtonOnODB

    [DscProperty()]
    [System.ComponentModel.Description('Configure if ACS-based app-only authentication should be disabled or not.')]
    [System.Nullable[System.Boolean]] $DisableCustomAppAuthentication

    [DscProperty()]
    [System.ComponentModel.Description('Guids of out of the box modern list templates to hide when creating a new list.')]
    [System.String[]] $DisabledModernListTemplateIds

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuring whether personal lists created within the OneDrive for Business site of the user is enabled or disabled in the tenant. If set to $false, personal lists will be allowed to be created in the tenant. If set to $true, it will be disabled in the tenant.')]
    [System.Nullable[System.Boolean]] $DisablePersonalListCreation

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuring whether display name of people who view the file are visible in the property pane of the site in SharePoint site collection.')]
    [System.Nullable[System.Boolean]] $DisplayNamesOfFileViewersInSpo

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuration on whether Fluid components are enabled or disabled in the tenant. If set to $true, then this feature will be enabled on all sites in the tenant. If set to $false, it will be disabled on all sites in the tenant.')]
    [System.Nullable[System.Boolean]] $IsFluidEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allows configuring whether loop components are enabled or disabled in the tenant. If set to $true, loop components will be allowed to be created in the tenant. If set to $false, it will be disabled in the tenant.')]
    [System.Nullable[System.Boolean]] $IsLoopEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When the feature is enabled, all the add-ins features will be disabled.')]
    [System.Nullable[System.Boolean]] $IsSharePointAddInsDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the newsfeed is allowed on the modern site pages in SharePoint.')]
    [System.Nullable[System.Boolean]] $IsSharePointNewsfeedEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether users are allowed to create sites.')]
    [System.Nullable[System.Boolean]] $IsSiteCreationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the UI commands for creating sites are shown.')]
    [System.Nullable[System.Boolean]] $IsSiteCreationUiEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether creating new modern pages is allowed on SharePoint sites.')]
    [System.Nullable[System.Boolean]] $IsSitePagesCreationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the Knowledge Agent feature tenant-wide. When set to $true, the Knowledge Agent functionality is enabled for the tenant; when set to $false it is disabled. Use this parameter to control tenant-level Knowledge Agent behavior.')]
    [System.Nullable[System.Boolean]] $KnowledgeAgentEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of site collection URLs that should be selected for the tenant Knowledge Agent. Each entry must be a full site URL (for example: https://contoso.sharepoint.com/sites/team1). The cmdlet will resolve each URL to the corresponding site id and configure the tenant Knowledge Agent to target those sites.')]
    [System.String[]] $KnowledgeAgentSelectedSitesList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the URL of the redirected site for those site collections which have the locked state ''NoAccess''. The valid values are: '''' (default) - Blank by default, this will also remove or clear any value that has been set. Full URL - Example: https://contoso.sharepoint.com/Pages/Locked.aspx')]
    [System.String] $NoAccessRedirectUrl

    [DscProperty()]
    [System.ComponentModel.Description('Ensures that an external user can only accept an external sharing invitation with an account matching the invited email address. Note, this only applies to new external users accepting new sharing invitations. Also, the resource owner must share with an organizational or Microsoft account or the external user will be unable to access the resource. ')]
    [System.Nullable[System.Boolean]] $RequireAcceptingAccountMatchInvitedAccount

    [DscProperty()]
    [System.ComponentModel.Description('Permits the use of special characters in file and folder names in SharePoint Online and OneDrive for Business document libraries. The only two characters that can be managed at this time are the # and % characters.')]
    [ValidateSet('NoPreference', 'Allowed', 'Disallowed')]
    [System.String] $SpecialCharactersStateInFileFolderNames

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

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

    [SPOTenantSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOTenantSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for SPO Tenant'

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('MicrosoftGraph')

                $null = $this.Connect('PNP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            $SPOTenantSettings = Get-PnPTenant -ErrorAction Stop
            $SPOTenantGraphSettings = Get-MgAdminSharepointSetting -Property *
            $CompatibilityRange = $SPOTenantSettings.CompatibilityRange.Split(',')
            $MinCompat = $null
            $MaxCompat = $null
            if ($CompatibilityRange.Length -eq 2)
            {
                $MinCompat = $CompatibilityRange[0]
                $MaxCompat = $CompatibilityRange[1]
            }

            # Additional Properties via REST
            $parametersToRetrieve = @(
                'ExemptNativeUsersFromTenantLevelRestricedAccessControl',
                'AllowSelectSGsInODBListInTenant',
                'DenySelectSGsInODBListInTenant',
                'DenySelectSecurityGroupsInSPSitesList',
                'AllowSelectSecurityGroupsInSPSitesList',
                'HideSyncButtonOnODB',
                'MobileFriendlyUrlEnabledInTenant'
            )

            $response = Invoke-PnPSPRestMethod -Method Get `
                -Url "$((Get-MSCloudLoginConnectionProfile -Workload PnP).AdminUrl)/_api/SPO.Tenant?`$select=$($parametersToRetrieve -join ',')"

            $AllowSelectSGsInODBListInTenantValue = @()
            if ($null -ne $response.AllowSelectSGsInODBListInTenant)
            {
                $AllowSelectSGsInODBListInTenantValue = [System.String[]]$response.AllowSelectSGsInODBListInTenant
            }

            $DenySelectSGsInODBListInTenantValue = @()
            if ($null -ne $response.DenySelectSGsInODBListInTenant)
            {
                $DenySelectSGsInODBListInTenantValue = [System.String[]]$response.DenySelectSGsInODBListInTenant
            }

            $DenySelectSecurityGroupsInSPSitesListValue = @()
            if ($null -ne $response.DenySelectSecurityGroupsInSPSitesList)
            {
                $DenySelectSecurityGroupsInSPSitesListValue = [System.String[]]$response.DenySelectSecurityGroupsInSPSitesList
            }

            $AllowSelectSecurityGroupsInSPSitesListValue = @()
            if ($null -ne $response.AllowSelectSecurityGroupsInSPSitesList)
            {
                $AllowSelectSecurityGroupsInSPSitesListValue = [System.String[]]$response.AllowSelectSecurityGroupsInSPSitesList
            }

            $results = @{
                IsSingleInstance                                               = 'Yes'
                ExemptNativeUsersFromTenantLevelRestricedAccessControl         = $response.ExemptNativeUsersFromTenantLevelRestricedAccessControl
                AllowSelectSGsInODBListInTenant                                = $AllowSelectSGsInODBListInTenantValue
                DenySelectSGsInODBListInTenant                                 = $DenySelectSGsInODBListInTenantValue
                DenySelectSecurityGroupsInSPSitesList                          = $DenySelectSecurityGroupsInSPSitesListValue
                AllowSelectSecurityGroupsInSPSitesList                         = $AllowSelectSecurityGroupsInSPSitesListValue
                EnableAzureADB2BIntegration                                    = $SPOTenantSettings.EnableAzureADB2BIntegration
                HideSyncButtonOnODB                                            = $response.HideSyncButtonOnODB
                MobileFriendlyUrlEnabledInTenant                               = $response.MobileFriendlyUrlEnabledInTenant
                MinCompatibilityLevel                                          = $MinCompat
                MaxCompatibilityLevel                                          = $MaxCompat
                AllOrganizationSecurityGroupId                                 = $SPOTenantSettings.AllOrganizationSecurityGroupId
                AllowAnonymousMeetingParticipantsToAccessWhiteboards           = $SPOTenantSettings.AllowAnonymousMeetingParticipantsToAccessWhiteboards
                AllowAppsBypassOfUnmanagedDevicePolicy                         = $SPOTenantSettings.AllowAppsBypassOfUnmanagedDevicePolicy
                AllowCommentsTextOnEmailEnabled                                = $SPOTenantSettings.AllowCommentsTextOnEmailEnabled
                AllowDownloadingNonWebViewableFiles                            = $SPOTenantSettings.AllowDownloadingNonWebViewableFiles
                AllowEditing                                                   = $SPOTenantSettings.AllowEditing
                AllowFileArchive                                               = $SPOTenantSettings.AllowFileArchive
                AllowFileArchiveOnNewSitesByDefault                            = $SPOTenantSettings.AllowFileArchiveOnNewSitesByDefault
                AppBypassInformationBarriers                                   = $SPOTenantSettings.AppBypassInformationBarriers
                AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled = $SPOTenantSettings.AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled
                ApplyAppEnforcedRestrictionsToAdHocRecipients                  = $SPOTenantSettings.ApplyAppEnforcedRestrictionsToAdHocRecipients
                ArchiveRedirectUrl                                             = $SPOTenantSettings.ArchiveRedirectUrl
                AuthContextResilienceMode                                      = $SPOTenantSettings.AuthContextResilienceMode
                BlockDownloadFileTypeIds                                       = Get-M365DSCArrayFromProperty -PropertyValue $SPOTenantSettings.BlockDownloadFileTypeIds -ElementType ([System.String])
                BlockDownloadFileTypePolicy                                    = $SPOTenantSettings.BlockDownloadFileTypePolicy
                BlockSendLabelMismatchEmail                                    = $SPOTenantSettings.BlockSendLabelMismatchEmail
                CommentsOnSitePagesDisabled                                    = $SPOTenantSettings.CommentsOnSitePagesDisabled
                ConditionalAccessPolicyErrorHelpLink                           = $SPOTenantSettings.ConditionalAccessPolicyErrorHelpLink
                ContentTypeSyncSiteTemplatesList                               = Get-M365DSCArrayFromProperty -PropertyValue $SPOTenantSettings.ContentTypeSyncSiteTemplatesList -ElementType ([System.String])
                CoreRequestFilesLinkExpirationInDays                           = $SPOTenantSettings.CoreRequestFilesLinkExpirationInDays
                CoreRequestFilesLinkEnabled                                    = $SPOTenantSettings.CoreRequestFilesLinkEnabled
                CoreBlockGuestsAsSiteAdmin                                     = $SPOTenantSettings.CoreBlockGuestsAsSiteAdmin
                ContentSecurityPolicyEnforcement                               = $SPOTenantSettings.ContentSecurityPolicyEnforcement
                CustomizedExternalSharingServiceUrl                            = $SPOTenantSettings.CustomizedExternalSharingServiceUrl
                DefaultOneDriveInformationBarrierMode                          = $SPOTenantSettings.DefaultOneDriveInformationBarrierMode
                DisableCustomAppAuthentication                                 = $SPOTenantSettings.DisableCustomAppAuthentication
                DisableDocumentLibraryDefaultLabeling                          = $SPOTenantSettings.DisableDocumentLibraryDefaultLabeling
                DisableSpacesActivation                                        = $SPOTenantSettings.DisableSpacesActivation
                DisableVivaConnectionsAnalytics                                = $SPOTenantSettings.DisableVivaConnectionsAnalytics
                DisabledAdaptiveCardExtensionIds                               = Get-M365DSCArrayFromProperty -PropertyValue $SPOTenantSettings.DisabledAdaptiveCardExtensionIds -ElementType ([System.String])
                DisabledModernListTemplateIds                                  = [System.String[]]$SPOTenantSettings.DisabledModernListTemplateIds
                DisabledWebPartIds                                             = [System.String[]]$SPOTenantSettings.DisabledWebPartIds
                DisablePersonalListCreation                                    = $SPOTenantSettings.DisablePersonalListCreation
                DisplayNamesOfFileViewersInSpo                                 = $SPOTenantSettings.DisplayNamesOfFileViewersInSpo
                EnableDiscoverableByOrganizationForVideos                      = $SPOTenantSettings.EnableDiscoverableByOrganizationForVideos
                EnableAIPIntegration                                           = $SPOTenantSettings.EnableAIPIntegration
                EnableMediaReactions                                           = $SPOTenantSettings.EnableMediaReactions
                EnableNotificationsSubscriptions                               = $SPOTenantSettings.EnableNotificationsSubscriptions
                EnableSensitivityLabelForOneNote                               = $SPOTenantSettings.EnableSensitivityLabelForOneNote
                EnableSensitivityLabelForPDF                                   = $SPOTenantSettings.EnableSensitivityLabelForPDF
                EnableSensitivityLabelForVideoFiles                            = $SPOTenantSettings.EnableSensitivityLabelForVideoFiles
                EnforceRequestDigest                                           = $SPOTenantSettings.EnforceRequestDigest
                # TODO: Add GroupId lookup
                ExcludedBlockDownloadGroupIds                                  = Get-M365DSCArrayFromProperty -PropertyValue $SPOTenantSettings.ExcludedBlockDownloadGroupIds -ElementType ([System.String])
                FilePickerExternalImageSearchEnabled                           = $SPOTenantSettings.FilePickerExternalImageSearchEnabled
                ExpireVersionsAfterDays                                        = $SPOTenantSettings.ExpireVersionsAfterDays
                HideDefaultThemes                                              = $SPOTenantSettings.HideDefaultThemes
                HideSyncButtonOnDocLib                                         = $SPOTenantSettings.HideSyncButtonOnDocLib
                HideSyncButtonOnTeamSite                                       = $SPOTenantSettings.HideSyncButtonOnTeamSite
                IBImplicitGroupBased                                           = $SPOTenantSettings.IBImplicitGroupBased
                IncludeAtAGlanceInShareEmails                                  = $SPOTenantSettings.IncludeAtAGlanceInShareEmails
                IsCollabMeetingNotesFluidEnabled                               = $SPOTenantSettings.IsCollabMeetingNotesFluidEnabled
                IsDataAccessInCardDesignerEnabled                              = $SPOTenantSettings.IsDataAccessInCardDesignerEnabled
                IsEnableAppAuthPopUpEnabled                                    = $SPOTenantSettings.IsEnableAppAuthPopUpEnabled
                EnableAutoExpirationVersionTrim                                = $SPOTenantSettings.EnableAutoExpirationVersionTrim
                IsFluidEnabled                                                 = $SPOTenantSettings.IsFluidEnabled
                IsLoopEnabled                                                  = $SPOTenantSettings.IsLoopEnabled
                IsSharePointAddInsDisabled                                     = $SPOTenantSettings.IsSharePointAddInsDisabled
                IsWBFluidEnabled                                               = $SPOTenantSettings.IsWBFluidEnabled
                KnowledgeAgentEnabled                                          = $SPOTenantSettings.KnowledgeAgentEnabled
                KnowledgeAgentSelectedSitesList                                = Get-M365DSCArrayFromProperty -PropertyValue $SPOTenantSettings.KnowledgeAgentSelectedSitesList -ElementType ([System.String])
                LegacyBrowserAuthProtocolsEnabled                              = $SPOTenantSettings.LegacyBrowserAuthProtocolsEnabled
                LegacyAuthProtocolsEnabled                                     = $SPOTenantSettings.LegacyAuthProtocolsEnabled
                MajorVersionLimit                                              = $SPOTenantSettings.MajorVersionLimit
                MassDeleteNotificationDisabled                                 = $SPOTenantSettings.MassDeleteNotificationDisabled
                MarkNewFilesSensitiveByDefault                                 = $SPOTenantSettings.MarkNewFilesSensitiveByDefault
                MediaTranscription                                             = $SPOTenantSettings.MediaTranscriptionEnabled
                MediaTranscriptionAutomaticFeatures                            = $SPOTenantSettings.MediaTranscriptionAutomaticFeatures
                NoAccessRedirectUrl                                            = $SPOTenantSettings.NoAccessRedirectUrl
                NotificationsInSharePointEnabled                               = $SPOTenantSettings.NotificationsInSharePointEnabled
                OfficeClientADALDisabled                                       = $SPOTenantSettings.OfficeClientADALDisabled
                OneDriveBlockGuestsAsSiteAdmin                                 = $SPOTenantSettings.OneDriveBlockGuestsAsSiteAdmin
                OneDriveRequestFilesLinkEnabled                                = $SPOTenantSettings.OneDriveRequestFilesLinkEnabled
                OneDriveRequestFilesLinkExpirationInDays                       = $SPOTenantSettings.OneDriveRequestFilesLinkExpirationInDays
                OwnerAnonymousNotification                                     = $SPOTenantSettings.OwnerAnonymousNotification
                #PermissiveBrowserFileHandlingOverride                          = $SPOTenantSettings.PermissiveBrowserFileHandlingOverride
                PublicCdnAllowedFileTypes                                      = $SPOTenantSettings.PublicCdnAllowedFileTypes
                PublicCdnEnabled                                               = $SPOTenantSettings.PublicCdnEnabled
                ReduceTempTokenLifetimeEnabled                                 = $SPOTenantSettings.ReduceTempTokenLifetimeEnabled
                ReduceTempTokenLifetimeValue                                   = $SPOTenantSettings.ReduceTempTokenLifetimeValue
                RecycleBinRetentionPeriod                                      = $SPOTenantSettings.RecycleBinRetentionPeriod
                RestrictedAccessControlforSitesErrorHelpLink                   = $SPOTenantSettings.RestrictedAccessControlforSitesErrorHelpLink
                RequireAcceptingAccountMatchInvitedAccount                     = $SPOTenantSettings.RequireAcceptingAccountMatchInvitedAccount
                SearchResolveExactEmailOrUPN                                   = $SPOTenantSettings.SearchResolveExactEmailOrUPN
                ShowOpenInDesktopOptionForSyncedFiles                          = $SPOTenantSettings.ShowOpenInDesktopOptionForSyncedFiles
                ShowPeoplePickerGroupSuggestionsForIB                          = $SPOTenantSettings.ShowPeoplePickerGroupSuggestionsForIB
                SignInAccelerationDomain                                       = $SPOTenantSettings.SignInAccelerationDomain
                SiteOwnerManageLegacyServicePrincipalEnabled                   = $SPOTenantSettings.SiteOwnerManageLegacyServicePrincipalEnabled
                SocialBarOnSitePagesDisabled                                   = $SPOTenantSettings.SocialBarOnSitePagesDisabled
                SpecialCharactersStateInFileFolderNames                        = $SPOTenantSettings.SpecialCharactersStateInFileFolderNames
                StreamLaunchConfig                                             = $SPOTenantSettings.StreamLaunchConfig
                TlsTokenBindingPolicyValue                                     = $SPOTenantSettings.TlsTokenBindingPolicyValue
                UseFindPeopleInPeoplePicker                                    = $SPOTenantSettings.UseFindPeopleInPeoplePicker
                UsePersistentCookiesForExplorerView                            = $SPOTenantSettings.UsePersistentCookiesForExplorerView
                ViewersCanCommentOnMediaDisabled                               = $SPOTenantSettings.ViewersCanCommentOnMediaDisabled
                Workflow2010Disabled                                           = $SPOTenantSettings.Workflow2010Disabled
                IsSharePointNewsfeedEnabled                                    = $SPOTenantGraphSettings.IsSharePointNewsfeedEnabled
                IsSiteCreationEnabled                                          = $SPOTenantGraphSettings.IsSiteCreationEnabled
                IsSiteCreationUiEnabled                                        = $SPOTenantGraphSettings.IsSiteCreationUiEnabled
                IsSitePagesCreationEnabled                                     = $SPOTenantGraphSettings.IsSitePagesCreationEnabled
                TenantDefaultTimezone                                          = $SPOTenantGraphSettings.TenantDefaultTimeZone
                Credential                                                     = $this.Credential
                ApplicationId                                                  = $this.ApplicationId
                TenantId                                                       = $this.TenantId
                ApplicationSecret                                              = $this.ApplicationSecret
                CertificateThumbprint                                          = $this.CertificateThumbprint
                CertificatePassword                                            = $this.CertificatePassword
                CertificatePath                                                = $this.CertificatePath
                ManagedIdentity                                                = $this.ManagedIdentity
                AccessTokens                                                   = $this.AccessTokens
            }

            if ($SPOTenantSettings.OneDriveRequestFilesLinkExpirationInDays -eq -1)
            {
                $results.Remove('OneDriveRequestFilesLinkExpirationInDays') | Out-Null
            }
            if ($SPOTenantSettings.CoreRequestFilesLinkExpirationInDays -eq -1)
            {
                $results.Remove('CoreRequestFilesLinkExpirationInDays') | Out-Null
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

        if ($this.GetBoundParameters().ContainsKey('IsFluidEnabled') -and $this.GetBoundParameters().ContainsKey('IsLoopEnabled') -and $this.IsFluidEnabled -ne $this.IsLoopEnabled)
        {
            Write-Warning -Message "The 'IsFluidEnabled' property is present together with the 'IsLoopEnabled' property but they have different values. Both parameters refer to the same functionality and should be set to the same value if both are specified. Please update your configuration to ensure only one of the parameters is specified in order to avoid unexpected results."
        }

        Write-Verbose -Message 'Updating configuration for the SPO Tenant Settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $spoRestParameters = @(
            'ExemptNativeUsersFromTenantLevelRestricedAccessControl',
            'AllowSelectSGsInODBListInTenant',
            'DenySelectSGsInODBListInTenant',
            'DenySelectSecurityGroupsInSPSitesList',
            'AllowSelectSecurityGroupsInSPSitesList',
            'HideSyncButtonOnODB',
            'MobileFriendlyUrlEnabledInTenant'
        )
        $spoGraphParameters = @(
            'IsSharePointNewsfeedEnabled',
            'IsSiteCreationEnabled',
            'IsSiteCreationUiEnabled',
            'IsSitePagesCreationEnabled',
            'TenantDefaultTimezone'
        )
        $CurrentParameters.Remove('IsSingleInstance') | Out-Null
        $spoRestParametersSplat = @{}
        foreach ($param in $spoRestParameters)
        {
            if ($currentParameters.ContainsKey($param))
            {
                $spoRestParametersSplat.Add($param, $CurrentParameters[$param])
                $CurrentParameters.Remove($param) | Out-Null
            }
        }
        $spoGraphParametersSplat = @{}
        foreach ($param in $spoGraphParameters)
        {
            if ($CurrentParameters.ContainsKey($param))
            {
                $paramWithLowerCase = $param.Substring(0, 1).ToLower() + $param.Substring(1)
                $spoGraphParametersSplat.Add($paramWithLowerCase, $CurrentParameters[$param])
                $CurrentParameters.Remove($param) | Out-Null
            }
        }

        if ($this.PublicCdnEnabled -eq $false)
        {
            Write-Verbose -Message 'The use of the public CDN is not enabled, for that the PublicCdnAllowedFileTypes parameter can not be configured and will be removed'
            $CurrentParameters.Remove('PublicCdnAllowedFileTypes') | Out-Null
        }

        if ($spoGraphParametersSplat.Keys.Count -gt 0)
        {
            Reset-MSCloudLoginConnectionProfileContext -Workload 'MicrosoftGraph'
            $null = $this.Connect('MicrosoftGraph')
            $null = Update-MgAdminSharepointSetting -BodyParameter $spoGraphParametersSplat -ErrorAction Stop
        }

        $null = $this.Connect('PNP')
        $null = Set-PnPTenant @CurrentParameters -Force

        # Updating via REST
        try
        {
            Write-Verbose -Message "Updating properties via REST PATCH call: $($spoRestParametersSplat | ConvertTo-Json -Depth 5)"
            Invoke-PnPSPRestMethod -Method PATCH `
                -Url "$((Get-MSCloudLoginConnectionProfile -Workload PnP).AdminUrl)/_api/SPO.Tenant" `
                -Content $spoRestParametersSplat
        }
        catch
        {
            if ($_.Exception.Message.Contains('The requested operation is part of an experimental feature that is not supported in the current environment.'))
            {
                Write-Verbose -Message 'Updating via REST: The associated feature is not available in the given tenant.'
            }
            else
            {
                throw $_
            }
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

        try
        {
            $ConnectionModeGraph = $this.Connect('MicrosoftGraph')

            $ConnectionMode = $this.Connect('PNP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $this.ResourceCache['ExportMode'] = $true
            $dscContent = [System.Text.StringBuilder]::new()

            $Params = @{
                IsSingleInstance      = 'Yes'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            if ($null -eq $Results.MaxCompatibilityLevel)
            {
                $Results.Remove('MaxCompatibilityLevel') | Out-Null
            }
            if ($null -eq $Results.MinCompatibilityLevel)
            {
                $Results.Remove('MinCompatibilityLevel') | Out-Null
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
            ExcludedProperties = @()
        }
    }

    hidden [SPOTenantSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOTenantSettings])
        {
            return $Values
        }

        $result = [SPOTenantSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
