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
        EXOAntiPhishRule 'EXOAntiPhishRule-Example'
        {
            Identity                  = "Executive Impersonation Protection"
            Comments                  = "Applies the anti-phishing policy to the executives group and their assistants." # Updated Property
            AntiPhishPolicy           = "Our Rule"
            Enabled                   = $True
            Priority                  = 0
            RecipientDomainIs         = @("contoso.com")
            SentTo                    = @("AdeleV@$TenantId")
            SentToMemberOf            = @("Executives@$TenantId")
            ExceptIfRecipientDomainIs = @("fabrikam.com")
            ExceptIfSentTo            = @("AlexW@$TenantId")
            ExceptIfSentToMemberOf    = @("Retail@$TenantId")
            Ensure                    = "Present"
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
