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
        TeamsNetworkRoamingPolicy 'TeamsNetworkRoamingPolicy-Example'
        {
            AllowIPVideo          = $true;
            Ensure                = "Present";
            Description           = "Video and media limits for staff roaming outside the office";
            Identity              = "Amsterdam Roaming";
            MediaBitRateKb        = 50000;
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
