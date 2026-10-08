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
        EXOServicePrincipal 'EXOServicePrincipal-Example'
        {
            AppId                 = "<application-id>";
            AppName               = "ISV Portal";
            DisplayName           = "Kartikeya";
            Ensure                = "Present";
            Identity              = "00f6b0e4-1d00-427b-9a5b-ce6c43c43fc7";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
