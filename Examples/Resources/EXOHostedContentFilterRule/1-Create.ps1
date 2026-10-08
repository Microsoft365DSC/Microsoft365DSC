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
        EXOHostedContentFilterRule 'EXOHostedContentFilterRule-Example'
        {
            Identity                  = "Standard Spam Filter Rule"
            Comments                  = "Applies to all users, except when member of HR group"
            Enabled                   = $True
            Priority                  = 0
            SentTo                    = @("AdeleV@$TenantId")
            SentToMemberOf            = @("Executives@$TenantId")
            ExceptIfRecipientDomainIs = @("fabrikam.com")
            ExceptIfSentTo            = @("AlexW@$TenantId")
            ExceptIfSentToMemberOf    = "Retail@$TenantId"
            RecipientDomainIs         = @('contoso.com')
            HostedContentFilterPolicy = "Standard Spam Filter"
            Ensure                    = "Present"
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
