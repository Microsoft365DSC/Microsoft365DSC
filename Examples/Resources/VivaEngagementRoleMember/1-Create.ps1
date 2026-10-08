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
        VivaEngagementRoleMember "VivaEngagementRoleMember-Example1"
        {
            Members               = @("admin@contoso.com");
            Role                  = "Network Admin";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        VivaEngagementRoleMember "VivaEngagementRoleMember-Example2"
        {
            Members               = @("admin@contoso.com","NestorW@contoso.com");
            Role                  = "Verified Admin";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        VivaEngagementRoleMember "VivaEngagementRoleMember-Example3"
        {
            Members               = @("NestorW@contoso.com","AllanD@contoso.com");
            Role                  = "Corporate Communicator";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
