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
        SPOTenantSettings 'SPOTenantSettings-Example'
        {
            IsSingleInstance                                               = "Yes"
            EnableAzureADB2BIntegration                                    = $true
            MinCompatibilityLevel                                          = 16
            MaxCompatibilityLevel                                          = 16
            SearchResolveExactEmailOrUPN                                   = $false
            OfficeClientADALDisabled                                       = $false
            OneDriveRequestFilesLinkEnabled                                = $false
            LegacyAuthProtocolsEnabled                                     = $true
            LegacyBrowserAuthProtocolsEnabled                              = $true
            SignInAccelerationDomain                                       = ""
            UsePersistentCookiesForExplorerView                            = $false
            PublicCdnEnabled                                               = $false
            UseFindPeopleInPeoplePicker                                    = $false
            NotificationsInSharePointEnabled                               = $true
            EnableNotificationsSubscriptions                               = $true
            OwnerAnonymousNotification                                     = $true
            AllowCommentsTextOnEmailEnabled                                = $true
            AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled = $true
            AppBypassInformationBarriers                                   = $false
            ApplyAppEnforcedRestrictionsToAdHocRecipients                  = $true
            ArchiveRedirectUrl                                             = "https://contoso.sharepoint.com/sites/intranet/SitePages/Archived-site.aspx"
            NoAccessRedirectUrl                                            = "https://contoso.sharepoint.com/sites/intranet/SitePages/Site-locked.aspx"
            ConditionalAccessPolicyErrorHelpLink                           = "https://contoso.sharepoint.com/sites/intranet/SitePages/Access-blocked.aspx"
            CustomizedExternalSharingServiceUrl                            = "https://contoso.sharepoint.com/sites/intranet/SitePages/External-sharing-guidance.aspx"
            RestrictedAccessControlforSitesErrorHelpLink                   = "https://contoso.sharepoint.com/sites/intranet/SitePages/Request-site-access.aspx"
            BlockDownloadFileTypePolicy                                    = $false
            BlockSendLabelMismatchEmail                                    = $false
            CoreRequestFilesLinkEnabled                                    = $false
            DefaultOneDriveInformationBarrierMode                          = "Open"
            AllowAnonymousMeetingParticipantsToAccessWhiteboards           = "Off"
            DisableDocumentLibraryDefaultLabeling                          = $false
            IsEnableAppAuthPopUpEnabled                                    = $true
            EnableAutoExpirationVersionTrim                                = $false
            ExpireVersionsAfterDays                                        = 180
            MajorVersionLimit                                              = 500
            RecycleBinRetentionPeriod                                      = 93
            DisableVivaConnectionsAnalytics                                = $false
            CoreBlockGuestsAsSiteAdmin                                     = "On"
            OneDriveBlockGuestsAsSiteAdmin                                 = "On"
            IsWBFluidEnabled                                               = $true
            IsCollabMeetingNotesFluidEnabled                               = $true
            IsFluidEnabled                                                 = $true
            IsLoopEnabled                                                  = $true
            IBImplicitGroupBased                                           = $false
            ShowOpenInDesktopOptionForSyncedFiles                          = $true
            ShowPeoplePickerGroupSuggestionsForIB                          = $false
            ReduceTempTokenLifetimeEnabled                                 = $true
            ReduceTempTokenLifetimeValue                                   = 15
            ViewersCanCommentOnMediaDisabled                               = $false
            IncludeAtAGlanceInShareEmails                                  = $true
            MassDeleteNotificationDisabled                                 = $false
            EnableDiscoverableByOrganizationForVideos                      = $true
            Workflow2010Disabled                                           = $true
            HideSyncButtonOnDocLib                                         = $false
            HideSyncButtonOnTeamSite                                       = $false
            HideSyncButtonOnODB                                            = $false
            StreamLaunchConfig                                             = 1
            EnableMediaReactions                                           = $true
            ContentSecurityPolicyEnforcement                               = $false
            DisableSpacesActivation                                        = $false
            AllowAppsBypassOfUnmanagedDevicePolicy                         = $false
            DisabledAdaptiveCardExtensionIds                               = @()
            DisabledWebPartIds                                             = @()
            DisabledModernListTemplateIds                                  = @()
            EnforceRequestDigest                                           = $true
            TlsTokenBindingPolicyValue                                     = "None"
            AuthContextResilienceMode                                      = "DefaultAAD"
            ContentTypeSyncSiteTemplatesList                               = @("STS#3", "GROUP#0")
            FilePickerExternalImageSearchEnabled                           = $true
            HideDefaultThemes                                              = $false
            IsDataAccessInCardDesignerEnabled                              = $false
            MarkNewFilesSensitiveByDefault                                 = "AllowExternalSharing"
            MediaTranscription                                             = "Enabled"
            MediaTranscriptionAutomaticFeatures                            = "Enabled"
            SiteOwnerManageLegacyServicePrincipalEnabled                   = $false
            SocialBarOnSitePagesDisabled                                   = $false
            CommentsOnSitePagesDisabled                                    = $false
            EnableAIPIntegration                                           = $false
            EnableSensitivityLabelForOneNote                               = $true
            EnableSensitivityLabelForPDF                                   = $true
            EnableSensitivityLabelForVideoFiles                            = $true
            ExemptNativeUsersFromTenantLevelRestricedAccessControl         = $true
            AllowSelectSGsInODBListInTenant                                = @()
            DenySelectSGsInODBListInTenant                                 = @()
            AllowSelectSecurityGroupsInSPSitesList                         = @()
            DenySelectSecurityGroupsInSPSitesList                          = @()
            TenantDefaultTimezone                                          = "(UTC-08:00) Pacific Time (US and Canada)"
            MobileFriendlyUrlEnabledInTenant                               = $true
            AllowDownloadingNonWebViewableFiles                            = $true
            AllowEditing                                                   = $true
            AllowFileArchive                                               = $true
            AllowFileArchiveOnNewSitesByDefault                            = $false
            DisableCustomAppAuthentication                                 = $false
            DisablePersonalListCreation                                    = $false
            DisplayNamesOfFileViewersInSpo                                 = $true
            IsSharePointAddInsDisabled                                     = $false
            IsSharePointNewsfeedEnabled                                    = $true
            IsSiteCreationEnabled                                          = $true
            IsSiteCreationUiEnabled                                        = $true
            IsSitePagesCreationEnabled                                     = $true
            KnowledgeAgentEnabled                                          = $false
            RequireAcceptingAccountMatchInvitedAccount                     = $true
            SpecialCharactersStateInFileFolderNames                        = "Allowed"
            ApplicationId                                                  = $ApplicationId
            TenantId                                                       = $TenantId
            CertificateThumbprint                                          = $CertificateThumbprint
        }
    }
}
