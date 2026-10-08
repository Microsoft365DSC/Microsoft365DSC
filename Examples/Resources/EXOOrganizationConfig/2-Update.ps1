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
        EXOOrganizationConfig 'EXOOrganizationConfig-Example'
        {
            IsSingleInstance                                          = "Yes"
            ActivityBasedAuthenticationTimeoutEnabled                 = $true
            ActivityBasedAuthenticationTimeoutInterval                = "06:00:00"
            ActivityBasedAuthenticationTimeoutWithSingleSignOnEnabled = $true
            AppsForOfficeEnabled                                      = $true
            AsyncSendEnabled                                          = $true
            AuditDisabled                                             = $false
            AutodiscoverPartialDirSync                                = $false
            BlockMoveMessagesForGroupFolders                          = $false
            BookingsAddressEntryRestricted                            = $true
            BookingsAuthEnabled                                       = $true
            BookingsBlockedWordsEnabled                               = $true
            BookingsCreationOfCustomQuestionsRestricted               = $false
            BookingsEnabled                                           = $true
            BookingsExposureOfStaffDetailsRestricted                  = $true
            BookingsMembershipApprovalRequired                        = $true
            BookingsNamingPolicyEnabled                               = $true
            BookingsNamingPolicyPrefix                                = "Contoso-"
            BookingsNamingPolicyPrefixEnabled                         = $true
            BookingsNamingPolicySuffix                                = "-Bookings"
            BookingsNamingPolicySuffixEnabled                         = $true
            BookingsNotesEntryRestricted                              = $true
            BookingsPaymentsEnabled                                   = $false
            BookingsPhoneNumberEntryRestricted                        = $true
            BookingsSearchEngineIndexDisabled                         = $true
            BookingsSmsMicrosoftEnabled                               = $false
            BookingsSocialSharingRestricted                           = $true
            ByteEncoderTypeFor7BitCharsets                            = 0
            ComplianceMLBgdCrawlEnabled                               = $true
            ConnectorsActionableMessagesEnabled                       = $true
            ConnectorsEnabled                                         = $true
            ConnectorsEnabledForOutlook                               = $true
            ConnectorsEnabledForSharepoint                            = $true
            ConnectorsEnabledForTeams                                 = $true
            ConnectorsEnabledForYammer                                = $true
            CustomerLockboxEnabled                                    = $false
            DefaultGroupAccessType                                    = "Private"
            DefaultMinutesToReduceLongEventsBy                        = 10
            DefaultMinutesToReduceShortEventsBy                       = 5
            DefaultPublicFolderAgeLimit                               = "180.00:00:00"
            DefaultPublicFolderDeletedItemRetention                   = "30.00:00:00"
            DefaultPublicFolderIssueWarningQuota                      = "1.7GB"
            DefaultPublicFolderMaxItemSize                            = "10MB"
            DefaultPublicFolderMovedItemRetention                     = "07.00:00:00"
            DefaultPublicFolderProhibitPostQuota                      = "2GB"
            DelayedDelicensingEnabled                                 = $true
            DirectReportsGroupAutoCreationEnabled                     = $false
            DisablePlusAddressInRecipients                            = $false
            DistributionGroupNameBlockedWordsList                     = @("CEO", "Payroll", "Confidential")
            DistributionGroupNamingPolicy                             = ""
            DLPViaDcsEnabled                                          = $false
            ElcProcessingDisabled                                     = $false
            EnableOutlookEvents                                       = $true
            EndUserDLUpgradeFlowsDisabled                             = $false
            EndUserMailNotificationForDelayedDelicensingEnabled       = $true
            EwsAllowEntourage                                         = $false
            EwsAllowList                                              = @("MacOutlook/*", "Microsoft Office/*")
            EwsAllowMacOutlook                                        = $true
            EwsAllowOutlook                                           = $true
            EwsApplicationAccessPolicy                                = "EnforceBlockList"
            EwsBlockList                                              = @("LegacyMailApp/*")
            EwsEnabled                                                = $true
            ExchangeNotificationEnabled                               = $true
            ExchangeNotificationRecipients                            = @("MeganB@$TenantId")
            FindTimeAttendeeAuthenticationEnabled                     = $true
            FindTimeAutoScheduleDisabled                              = $false
            FindTimeLockPollForAttendeesEnabled                       = $false
            FindTimeOnlineMeetingOptionDisabled                       = $false
            FocusedInboxOn                                            = $true
            IPListBlocked                                             = @("203.0.113.0/24")
            IsGroupFoldersAndRulesEnabled                             = $true
            IsGroupMemberAllowedToEditContent                         = $true
            LeanPopoutEnabled                                         = $false
            LinkPreviewEnabled                                        = $true
            MailTipsAllTipsEnabled                                    = $true
            MailTipsExternalRecipientsTipsEnabled                     = $true
            MailTipsGroupMetricsEnabled                               = $true
            MailTipsLargeAudienceThreshold                            = 25
            MailTipsMailboxSourcedTipsEnabled                         = $true
            MaskClientIpInReceivedHeadersEnabled                      = $false
            MatchSenderOrganizerProperties                            = $false
            MessageHighlightsEnabled                                  = $true
            MessageRecallEnabled                                      = $true
            MessageRemindersEnabled                                   = $true
            MobileAppEducationEnabled                                 = $true
            OAuth2ClientProfileEnabled                                = $true
            OnlineMeetingsByDefaultEnabled                            = $true
            OutlookGifPickerDisabled                                  = $false
            OutlookMobileGCCRestrictionsEnabled                       = $false
            OutlookPayEnabled                                         = $true
            OutlookTextPredictionDisabled                             = $false
            PublicComputersDetectionEnabled                           = $false
            PublicFoldersEnabled                                      = "Local"
            PublicFolderShowClientControl                             = $false
            ReadTrackingEnabled                                       = $false
            RecallReadMessagesEnabled                                 = $false
            SendFromAliasEnabled                                      = $true
            SharedDomainEmailAddressFlowEnabled                       = $false
            ShortenEventScopeDefault                                  = "EndEarly"
            SiteMailboxCreationURL                                    = "https://contoso.sharepoint.com/sites/SiteMailboxes"
            SmtpActionableMessagesEnabled                             = $true
            TenantAdminNotificationForDelayedDelicensingEnabled       = $true
            VisibleMeetingUpdateProperties                            = "Location,AllProperties:15"
            WebPushNotificationsDisabled                              = $false
            WebSuggestedRepliesDisabled                               = $false
            WorkspaceTenantEnabled                                    = $true
            RejectDirectSend                                          = $false
            ApplicationId                                             = $ApplicationId
            TenantId                                                  = $TenantId
            CertificateThumbprint                                     = $CertificateThumbprint
        }
    }
}
