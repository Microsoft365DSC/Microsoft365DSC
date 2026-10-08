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
        EXOHostedOutboundSpamFilterRule 'EXOHostedOutboundSpamFilterRule-Example'
        {
            Identity                       = "Contoso Executives"
            Comments                       = "Applies outbound spam limits to the executives group"
            Enabled                        = $True
            ExceptIfFrom                   = "AdeleV@$TenantId"
            ExceptIfFromMemberOf           = "U.S.Sales@$TenantId"
            ExceptIfSenderDomainIs         = "fabrikam.com"
            From                           = "AlexW@$TenantId"
            Priority                       = 0
            SenderDomainIs                 = "contoso.com"
            FromMemberOf                   = "Executives@$TenantId"
            HostedOutboundSpamFilterPolicy = "Outbound Spam Limits"
            Ensure                         = "Present"
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            CertificateThumbprint          = $CertificateThumbprint
        }
    }
}
