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
        EXOIntraOrganizationConnector 'EXOIntraOrganizationConnector-Example'
        {
            Identity              = "MainCloudConnector"
            DiscoveryEndpoint     = "https://ExternalDiscovery.Contoso.com/"
            TargetAddressDomains  = "Cloud1.contoso.com","Cloud2.contoso.com"
            Enabled               = $False # Updated Property
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
