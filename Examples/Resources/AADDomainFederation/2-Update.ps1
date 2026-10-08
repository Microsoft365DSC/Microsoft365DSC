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
        AADDomainFederation "AADDomainFederation-Example"
        {
            ActiveSignInUri                       = "https://adfs.contoso.com/adfs/services/trust/2005/usernamemixed";
            DisplayName                           = "Contoso Federation - Updated";
            DomainId                              = "contoso.com";
            Ensure                                = "Present";
            FederatedIdpMfaBehavior               = "enforceMfaByFederatedIdp"; # Updated Property
            IssuerUri                             = "http://contoso.com/adfs/services/trust";
            IsSignedAuthenticationRequestRequired = $False; # Updated Property
            MetadataExchangeUri                   = "https://adfs.contoso.com/FederationMetadata/2007-06/FederationMetadata.xml";
            NextSigningCertificate                = "<base64-encoded-next-signing-certificate>" # New certificate being staged for rollover
            PasswordResetUri                      = "https://adfs.contoso.com/adfs/portal/updatepassword/";
            PassiveSignInUri                      = "https://adfs.contoso.com/adfs/ls/";
            PreferredAuthenticationProtocol       = "saml"; # Updated Property
            SigningCertificate                    = "<base64-encoded-signing-certificate>"
            SignOutUri                            = "https://adfs.contoso.com/adfs/ls/?wa=wsignout1.0";
            ApplicationId                         = $ApplicationId;
            TenantId                              = $TenantId;
            CertificateThumbprint                 = $CertificateThumbprint;
        }
    }
}
