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
        AADFederationConfiguration "AADFederationConfiguration-Example"
        {
            IssuerUri                       = 'http://contoso.com/adfs/services/trust'
            DisplayName                     = 'Contoso Partner Federation'
            MetadataExchangeUri             = 'https://contoso.com/adfs/services/trust/mex'
            PassiveSignInUri                = 'https://contoso.com/adfs/ls/'
            PreferredAuthenticationProtocol = 'wsFed'
            Domains                         = @('contoso.com')
            Ensure                          = 'Present'
            ApplicationId                   = $ApplicationId
            TenantId                        = $TenantId
            CertificateThumbprint           = $CertificateThumbprint
        }
    }
}
