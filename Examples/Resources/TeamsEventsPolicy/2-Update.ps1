<#
This example adds a new Teams Events Policy.
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
        TeamsEventsPolicy 'TeamsEventsPolicy-Example'
        {
            Identity                                = "CorporateEvents"
            Description                             = "Lets the marketing and communications teams run town halls and webinars" # Updated Property
            AllowEmailEditing                       = "Enabled"
            AllowEngagementReport                   = "ForceEnabled"
            AllowEventIntegrations                  = $true
            AllowWebinars                           = "Enabled"
            AllowTownhalls                          = "Enabled"
            AllowedQuestionTypesInRegistrationForm  = "AllQuestions"
            AllowedTownhallTypesForRecordingPublish = "EveryoneInCompanyIncludingGuests"
            AllowedWebinarTypesForRecordingPublish  = "EveryoneInCompanyIncludingGuests"
            BackroomChat                            = "Enabled"
            BroadcastPremiumApps                    = "Enabled"
            ExternalPresenterJoinVerification       = "eOTP"
            ImmersiveEvents                         = "Enabled"
            InfoShownInReportMode                   = "IdentityOnly"
            RecordingForTownhall                    = "Enabled"
            RecordingForWebinar                     = "Enabled"
            Registration                            = "Enabled"
            TownhallChatExperience                  = "Optimized"
            TownhallEventAttendeeAccess             = "EveryoneInOrganizationAndGuests"
            TownhallMaxResolution                   = "Max1080p"
            TranscriptionForTownhall                = "Enabled"
            TranscriptionForWebinar                 = "Enabled"
            UseMicrosoftECDN                        = $true
            EventAccessType                         = "EveryoneInCompanyExcludingGuests"
            Ensure                                  = "Present"
            ApplicationId                           = $ApplicationId
            TenantId                                = $TenantId
            CertificateThumbprint                   = $CertificateThumbprint
        }
    }
}
