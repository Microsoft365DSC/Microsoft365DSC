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
        EXODynamicDistributionGroup "EXODynamicDistributionGroup-Example"
        {
            AcceptMessagesOnlyFrom               = @("AdeleV@$TenantId")
            AcceptMessagesOnlyFromDLMembers      = @("Executives@$TenantId")
            Alias                                = "fieldsalesmarketing"
            BypassModerationFromSendersOrMembers = @("AdeleV@$TenantId")
            ConditionalCompany                   = "Contoso"
            ConditionalCustomAttribute1          = @("Field Sales")
            ConditionalCustomAttribute10         = @("EMEA")
            ConditionalCustomAttribute11         = @("Enterprise")
            ConditionalCustomAttribute12         = @("Aurora")
            ConditionalCustomAttribute13         = @("Gold")
            ConditionalCustomAttribute14         = @("English")
            ConditionalCustomAttribute15         = @("Standard Retention")
            ConditionalCustomAttribute2          = @("Commercial")
            ConditionalCustomAttribute3          = @("Direct")
            ConditionalCustomAttribute4          = @("Wave 1")
            ConditionalCustomAttribute5          = @("Onboarded")
            ConditionalCustomAttribute6          = @("Cost Center 1000")
            ConditionalCustomAttribute7          = @("Commercial Division")
            ConditionalCustomAttribute8          = @("Redmond")
            ConditionalCustomAttribute9          = @("Building 31")
            ConditionalDepartment                = @("Sales", "Marketing")
            ConditionalStateOrProvince           = @("Washington", "Oregon")
            CustomAttribute1                     = "Field Sales"
            CustomAttribute10                    = "EMEA"
            CustomAttribute11                    = "Enterprise"
            CustomAttribute12                    = "Aurora"
            CustomAttribute13                    = "Gold"
            CustomAttribute14                    = "English"
            CustomAttribute15                    = "Standard Retention"
            CustomAttribute2                     = "Commercial"
            CustomAttribute3                     = "Direct"
            CustomAttribute4                     = "Wave 1"
            CustomAttribute5                     = "Onboarded"
            CustomAttribute6                     = "Cost Center 1000"
            CustomAttribute7                     = "Commercial Division"
            CustomAttribute8                     = "Redmond"
            CustomAttribute9                     = "Building 31"
            DisplayName                          = "Field Sales and Marketing"
            EmailAddresses                       = @("SMTP:fieldsalesmarketing@$TenantId", "smtp:field.sales@$TenantId")
            ExtensionCustomAttribute1            = @("Sales", "Marketing")
            ExtensionCustomAttribute2            = "Commercial"
            ExtensionCustomAttribute3            = "Direct"
            ExtensionCustomAttribute4            = "Wave 1"
            ExtensionCustomAttribute5            = "Onboarded"
            GrantSendOnBehalfTo                  = @("AdeleV@$TenantId")
            HiddenFromAddressListsEnabled        = $false
            Identity                             = "Field Sales and Marketing"
            IncludedRecipients                   = @("MailboxUsers", "MailContacts")
            MailTip                              = "Messages sent here reach the field sales, marketing and pre-sales organisation." # Updated Property
            MailTipTranslations                  = @("FR:Les messages envoyes ici atteignent toute l'organisation commerciale.")
            ManagedBy                            = "MeganB@$TenantId"
            ModeratedBy                          = @("MeganB@$TenantId")
            ModerationEnabled                    = $true
            Name                                 = "Field Sales and Marketing"
            Notes                                = "Automatically includes every mailbox in the Sales and Marketing departments in Washington, Oregon and California." # Updated Property
            PhoneticDisplayName                  = "Field Sales and Marketing"
            PrimarySmtpAddress                   = "fieldsalesmarketing@$TenantId"
            RecipientContainer                   = "$TenantId"
            RejectMessagesFrom                   = @("AlexW@$TenantId")
            RejectMessagesFromDLMembers          = @("SalesandMarketing@$TenantId")
            ReportToManagerEnabled               = $false
            ReportToOriginatorEnabled            = $true
            RequireSenderAuthenticationEnabled   = $true
            SendModerationNotifications          = "Internal" # Updated Property
            SendOofMessageToOriginatorEnabled    = $false
            SimpleDisplayName                    = "Field Sales and Marketing"
            WindowsEmailAddress                  = "fieldsalesmarketing@$TenantId"
            Ensure                               = "Present"
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
