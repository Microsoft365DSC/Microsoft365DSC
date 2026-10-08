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
        AADOrganizationCertificateBasedAuthConfiguration "AADOrganizationCertificateBasedAuthConfiguration-Example"
        {
            CertificateAuthorities = @(
                MSFT_MicrosoftGraphcertificateAuthority{
                    IsRootAuthority                   = $True
                    DeltaCertificateRevocationListUrl = "http://crl.contoso.com/root-delta.crl"
                    Certificate                       = "<base64-encoded-certificate>"
                }
                MSFT_MicrosoftGraphcertificateAuthority{
                    IsRootAuthority                   = $False
                    CertificateRevocationListUrl      = "http://crl.contoso.com/issuing.crl"
                    DeltaCertificateRevocationListUrl = "http://crl.contoso.com/issuing-delta.crl"
                    Certificate                       = "<base64-encoded-certificate-2>"
                }
            );
            Ensure                 = "Present";
            OrganizationId         = "$TenantId";
            ApplicationId          = $ApplicationId
            TenantId               = $TenantId
            CertificateThumbprint  = $CertificateThumbprint
        }
    }
}
