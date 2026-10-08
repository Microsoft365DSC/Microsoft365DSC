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
        EXODkimSigningConfig 'EXODkimSigningConfig-Example'
        {
            KeySize                = 2048
            Identity               = $TenantId
            HeaderCanonicalization = "Relaxed"
            Enabled                = $false
            BodyCanonicalization   = "Relaxed"
            AdminDisplayName       = "Signing keys for the initial domain"
            Ensure                 = "Present"
            ApplicationId          = $ApplicationId
            TenantId               = $TenantId
            CertificateThumbprint  = $CertificateThumbprint
        }
    }
}
