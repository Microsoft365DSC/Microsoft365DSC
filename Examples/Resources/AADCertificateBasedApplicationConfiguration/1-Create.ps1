<#
This example creates a certificate-based application configuration with trusted certificate authorities.
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
        AADCertificateBasedApplicationConfiguration "AADCertificateBasedApplicationConfiguration-Example"
        {
            Description                   = "Trusted certificate authorities from Contoso";
            DisplayName                   = "Contoso Root CA Configuration";
            Ensure                        = "Present";
            TrustedCertificateAuthorities = @(
                MSFT_AADCertificateBasedApplicationConfigurationTrustedCertificateAuthority{
                    Certificate                = "<base64-encoded-certificate>"
                    IsRootAuthority            = $true
                    Issuer                     = "CN=Contoso Root CA, O=Contoso, C=US"
                    IssuerSubjectKeyIdentifier = "1234567890ABCDEF"
                }
            );
            ApplicationId                 = $ApplicationId;
            TenantId                      = $TenantId;
            CertificateThumbprint         = $CertificateThumbprint;
        }
    }
}
