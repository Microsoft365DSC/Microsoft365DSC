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
        TeamsCallParkPolicy 'TeamsCallParkPolicy-Example'
        {
            AllowCallPark         = $True;
            Description           = "Lets the front desk and reception staff park calls and page colleagues to pick them up"; # Updated Property
            Ensure                = "Present";
            Identity              = "Front Desk Call Park";
            ParkTimeoutSeconds    = 300;
            PickupRangeEnd        = 99;
            PickupRangeStart      = 10;
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
