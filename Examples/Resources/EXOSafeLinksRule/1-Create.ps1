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
        EXOSafeLinksRule 'EXOSafeLinksRule-Example'
        {
            Identity                  = "Research Department URL Rule"
            Comments                  = "Applies to Research Department, except managers"
            Enabled                   = $True
            Priority                  = 0
            ExceptIfRecipientDomainIs = @("fabrikam.com")
            ExceptIfSentTo            = @("AlexW@$TenantId")
            ExceptIfSentToMemberOf    = "Executives@$TenantId"
            RecipientDomainIs         = @("contoso.com")
            SafeLinksPolicy           = "Marketing Block URL"
            SentTo                    = @("AdeleV@$TenantId")
            SentToMemberOf            = "Retail@$TenantId"
            Ensure                    = "Present"
            ApplicationId             = $ApplicationId
            TenantId                  = $TenantId
            CertificateThumbprint     = $CertificateThumbprint
        }
    }
}
