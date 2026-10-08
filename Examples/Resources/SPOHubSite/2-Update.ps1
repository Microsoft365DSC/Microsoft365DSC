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
        SPOHubSite 'SPOHubSite-Example'
        {
            Url                   = "https://contoso.sharepoint.com/sites/SalesandMarketing"
            Title                 = "Sales and Marketing"
            Description           = "Hub for the Sales, Marketing and Communications teams" # Updated Property
            LogoUrl               = "https://contoso.sharepoint.com/sites/SalesandMarketing/SiteAssets/hublogo.png"
            RequiresJoinApproval  = $true
            AllowedToJoin         = @("AdeleV@$TenantId", "MeganB@$TenantId")
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
