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
            Members               = @();
            Role                  = "Network Admin";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        VivaEngagementRoleMember "VivaEngagementRoleMember-Example2"
        {
            Members               = @();
            Role                  = "Verified Admin";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        VivaEngagementRoleMember "VivaEngagementRoleMember-Example3"
        {
            Members               = @();
            Role                  = "Corporate Communicator";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
