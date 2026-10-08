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
        TeamsNotificationAndFeedsPolicy 'TeamsNotificationAndFeedsPolicy-Example'
        {
            Description               = "Keeps activity feed suggestions available with a user opt-out";
            IsSingleInstance          = "Yes";
            SuggestedFeedsEnabledType = "EnabledUserOverride"; # Updated Property
            TrendingFeedsEnabledType  = "EnabledUserOverride";
            ApplicationId             = $ApplicationId;
            TenantId                  = $TenantId;
            CertificateThumbprint     = $CertificateThumbprint;
        }
    }
}
