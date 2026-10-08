<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example {
    param
    (
        [Parameter()]
        [System.String] $ApplicationId,

        [Parameter()]
        [System.String] $TenantId,

        [Parameter()]
        [System.String] $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost {
        IntuneDerivedCredential "IntuneDerivedCredential-Example"
        {
            DisplayName                = "Entrust Derived Credential";
            HelpUrl                    = "https://intranet.contoso.com/mobility/derived-credentials";
            Issuer                     = "purebred";
            NotificationType           = "companyPortal,email";
            RenewalThresholdPercentage = 20;
            Ensure                     = "Present";
            ApplicationId              = $ApplicationId;
            TenantId                   = $TenantId;
            CertificateThumbprint      = $CertificateThumbprint;
        }
    }
}
