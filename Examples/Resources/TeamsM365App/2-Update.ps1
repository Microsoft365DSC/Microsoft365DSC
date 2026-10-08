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
        TeamsM365App "TeamsM365App-Example"
        {
            AssignmentType        = "UsersAndGroups";
            Groups                = @("Finance Team");
            Id                    = "95de633a-083e-42f5-b444-a4295d8e9314";
            IsBlocked             = $False;
            Users                 = @();
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
