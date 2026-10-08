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
        EXOGroupSettings 'EXOGroupSettings-Example'
        {
            DisplayName                            = "All Company"
            AcceptMessagesOnlyFromSendersOrMembers = @("AdeleV@$TenantId")
            AccessType                             = "Public"
            AlwaysSubscribeMembersToCalendarEvents = $false
            AuditLogAgeLimit                       = "90.00:00:00"
            AutoSubscribeNewMembers                = $false
            CalendarMemberReadOnly                 = $false
            ConnectorsEnabled                      = $true
            CustomAttribute1                       = "Corporate"
            CustomAttribute2                       = "Communications"
            CustomAttribute3                       = "Announcements"
            CustomAttribute4                       = "All Staff"
            CustomAttribute5                       = "Onboarded"
            CustomAttribute6                       = "Cost Center 1000"
            CustomAttribute7                       = "Corporate Services"
            CustomAttribute8                       = "Redmond"
            CustomAttribute9                       = "Building 31"
            CustomAttribute10                      = "EMEA"
            CustomAttribute11                      = "Enterprise"
            CustomAttribute12                      = "Aurora"
            CustomAttribute13                      = "Gold"
            CustomAttribute14                      = "English"
            CustomAttribute15                      = "Standard Retention"
            EmailAddresses                         = @("SMTP:allcompany@$TenantId", "smtp:everyone@$TenantId")
            ExtensionCustomAttribute1              = @("Corporate")
            ExtensionCustomAttribute2              = @("Communications")
            ExtensionCustomAttribute3              = @("Announcements")
            ExtensionCustomAttribute4              = @("All Staff")
            ExtensionCustomAttribute5              = @("Onboarded")
            GrantSendOnBehalfTo                    = @("AdeleV@$TenantId")
            HiddenFromAddressListsEnabled          = $false
            HiddenFromExchangeClientsEnabled       = $false
            InformationBarrierMode                 = "Open"
            IsMemberAllowedToEditContent           = $true
            Language                               = "en-US"
            MailTip                                = "This group reaches every employee, please use it sparingly."
            MailTipTranslations                    = @("FR: Ce groupe contacte tous les employes, merci de l'utiliser avec parcimonie.")
            MaxReceiveSize                         = "36MB"
            MaxSendSize                            = "35MB"
            ModeratedBy                            = @("MeganB@$TenantId")
            ModerationEnabled                      = $false
            Notes                                  = "Reaches every employee in the organisation. Announcements only."
            PrimarySmtpAddress                     = "allcompany@$TenantId"
            RejectMessagesFromSendersOrMembers     = @("AlexW@$TenantId")
            RequireSenderAuthenticationEnabled     = $true
            SubscriptionEnabled                    = $false
            WelcomeMessageEnabled                  = $false
            ApplicationId                          = $ApplicationId
            TenantId                               = $TenantId
            CertificateThumbprint                  = $CertificateThumbprint
        }
    }
}
