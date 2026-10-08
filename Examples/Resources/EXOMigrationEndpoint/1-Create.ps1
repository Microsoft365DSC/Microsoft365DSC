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
        EXOMigrationEndpoint "EXOMigrationEndpoint-Example"
        {
            AcceptUntrustedCertificates   = $True;
            Authentication                = "Basic";
            EndpointType                  = "IMAP";
            Ensure                        = "Present";
            Identity                      = "Gmail IMAP Migration";
            MailboxPermission             = "Admin";
            MaxConcurrentIncrementalSyncs = "10";
            MaxConcurrentMigrations       = "20";
            Port                          = "993";
            RemoteServer                  = "imap.gmail.com";
            Security                      = "Ssl";
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
