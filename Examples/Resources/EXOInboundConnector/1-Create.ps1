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
        EXOInboundConnector 'EXOInboundConnector-Example'
        {
            Identity                     = "Partner Mail Gateway"
            AssociatedAcceptedDomains    = @("$TenantId")
            CloudServicesMailEnabled     = $False
            Comment                      = "Accepts mail relayed by the partner gateway"
            ConnectorSource              = "Default"
            ConnectorType                = "Partner"
            EFSkipIPs                    = @("20.81.42.17")
            EFSkipLastIP                 = $False
            EFUsers                      = @("AdeleV@$TenantId")
            Enabled                      = $True
            RequireTls                   = $True
            RestrictDomainsToCertificate = $True
            RestrictDomainsToIPAddresses = $False
            SenderDomains                = "*.contoso.com"
            SenderIPAddresses            = @("20.81.42.17")
            TlsSenderCertificateName     = "contoso.com"
            TreatMessagesAsInternal      = $False
            Ensure                       = "Present"
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            CertificateThumbprint        = $CertificateThumbprint
        }
    }
}
