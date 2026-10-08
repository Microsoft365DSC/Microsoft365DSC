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
        EXOOutboundConnector 'EXOOutboundConnector-Example'
        {
            Identity                      = "Contoso Outbound Connector"
            AllAcceptedDomains            = $False
            CloudServicesMailEnabled      = $False
            Comment                       = "Outbound connector to Contoso"
            ConnectorSource               = "Default"
            ConnectorType                 = "Partner"
            Enabled                       = $False # Updated Property
            IsTransportRuleScoped         = $False
            RecipientDomains              = "contoso.com"
            RouteAllMessagesViaOnPremises = $False
            TlsDomain                     = "*.contoso.com"
            TlsSettings                   = "DomainValidation"
            UseMxRecord                   = $True
            Ensure                        = "Present"
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
