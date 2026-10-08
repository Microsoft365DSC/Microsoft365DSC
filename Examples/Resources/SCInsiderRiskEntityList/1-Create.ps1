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
        SCInsiderRiskEntityList "SCInsiderRiskEntityList-Example"
        {
            Description           = "High risk file types monitored when data is copied to removable media";
            DisplayName           = "High risk file types";
            Ensure                = "Present";
            FileTypes             = @(".exe",".cmd",".bat");
            Keywords              = @();
            ListType              = "CustomFileTypeLists";
            Name                  = "Restricted File Types";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
