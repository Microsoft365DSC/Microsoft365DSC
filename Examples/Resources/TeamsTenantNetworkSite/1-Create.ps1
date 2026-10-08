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
        TeamsTenantNetworkSite 'TeamsTenantNetworkSite-Example'
        {
            Description                = "Amsterdam office network site";
            EmergencyCallingPolicy     = "Headquarters Emergency Calling Policy";
            EmergencyCallRoutingPolicy = "Amsterdam Office";
            EnableLocationBasedRouting = $false;
            Ensure                     = "Present";
            Identity                   = "Amsterdam";
            NetworkRegionID            = "Europe";
            NetworkRoamingPolicy       = "Amsterdam Roaming";
            ApplicationId              = $ApplicationId;
            TenantId                   = $TenantId;
            CertificateThumbprint      = $CertificateThumbprint;
        }
    }
}
