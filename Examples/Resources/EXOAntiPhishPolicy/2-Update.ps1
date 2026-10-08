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
        EXOAntiPhishPolicy 'EXOAntiPhishPolicy-Example'
        {
            Identity                                      = "Our Rule"
            MakeDefault                                   = $false
            PhishThresholdLevel                           = 2 # Updated Property
            EnableTargetedDomainsProtection               = $true
            Enabled                                       = $true
            TargetedDomainsToProtect                      = @("northwindtraders.com")
            EnableSimilarUsersSafetyTips                  = $true
            ExcludedDomains                               = @("fabrikam.com")
            TargetedDomainActionRecipients                = @("MeganB@$TenantId")
            EnableMailboxIntelligence                     = $true
            EnableSimilarDomainsSafetyTips                = $true
            AdminDisplayName                              = "Impersonation and spoof protection for the finance team"
            AuthenticationFailAction                      = "MoveToJmf"
            TargetedUserProtectionAction                  = "BccMessage"
            TargetedUsersToProtect                        = @("Diego Siciliani;diego.siciliani@northwindtraders.com")
            EnableTargetedUserProtection                  = $true
            ExcludedSenders                               = @("newsletter@fabrikam.com")
            EnableOrganizationDomainsProtection           = $true
            EnableUnusualCharactersSafetyTips             = $true
            TargetedUserActionRecipients                  = @("MeganB@$TenantId")
            EnableFirstContactSafetyTips                  = $true
            EnableMailboxIntelligenceProtection           = $true
            EnableSpoofIntelligence                       = $true
            EnableUnauthenticatedSender                   = $true
            EnableViaTag                                  = $true
            HonorDmarcPolicy                              = $true
            ImpersonationProtectionState                  = "Manual"
            MailboxIntelligenceProtectionAction           = "BccMessage"
            MailboxIntelligenceProtectionActionRecipients = @("MeganB@$TenantId")
            TargetedDomainProtectionAction                = "BccMessage"
            Ensure                                        = "Present"
            DmarcQuarantineAction                         = "Quarantine"
            DmarcRejectAction                             = "Reject"
            ApplicationId                                 = $ApplicationId
            TenantId                                      = $TenantId
            CertificateThumbprint                         = $CertificateThumbprint
        }
    }
}
