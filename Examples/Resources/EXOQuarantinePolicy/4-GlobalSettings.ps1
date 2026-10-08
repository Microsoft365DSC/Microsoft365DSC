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
        EXOQuarantinePolicy 'EXOQuarantinePolicy-Example'
        {
            Identity                                 = "DefaultGlobalPolicy"
            QuarantinePolicyType                     = "GlobalQuarantineTag"
            EndUserSpamNotificationCustomFromAddress = "AdeleV@$TenantId"
            EndUserSpamNotificationFrequency         = "1.00:00:00"
            EsnCustomSubject                         = @("You have quarantined messages")
            MultiLanguageCustomDisclaimer            = @("Contact the service desk if you believe a message was quarantined in error.")
            MultiLanguageSenderName                  = @("Contoso Quarantine")
            MultiLanguageSetting                     = @("Default")
            OrganizationBrandingEnabled              = $false
            Ensure                                   = "Present"
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
        }
    }
}