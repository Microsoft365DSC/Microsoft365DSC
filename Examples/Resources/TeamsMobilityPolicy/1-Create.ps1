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
        TeamsMobilityPolicy 'TeamsMobilityPolicy-Example'
        {
            Description            = "Mobile calling defaults for field engineers";
            Ensure                 = "Present";
            Identity               = "Field Engineer Mobility";
            IPAudioMobileMode      = "AllNetworks";
            IPVideoMobileMode      = "AllNetworks";
            LinksInTeams           = "OfferBrowserOptions";
            MobileDialerPreference = "Teams";
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
