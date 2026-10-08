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
        AADVerifiedIdAuthority 'AADVerifiedIdAuthority-Example'
        {
            DidMethod             = "web";
            Ensure                = "Present";
            KeyVaultMetadata      = MSFT_AADVerifiedIdAuthorityKeyVaultMetadata{
                SubscriptionId = "<subscription-id>"
                ResourceName   = "<key-vault-name>"
                ResourceUrl    = "<key-vault-uri>"
                ResourceGroup  = "<resource-group-name>"
            };
            LinkedDomainUrl       = "https://$TenantId/";
            Name                  = "Contoso Identity Verification"; # Updated Property
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
