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
        TeamsAppPermissionPolicy "TeamsAppPermissionPolicy-Example"
        {
            DefaultCatalogApps     = "com.microsoft.teamspace.tab.vsts";
            DefaultCatalogAppsType = "AllowedAppList";
            Description            = "Restricts apps for the sales department";
            Ensure                 = "Present";
            GlobalCatalogAppsType  = "BlockedAppList";
            Identity               = "SalesAppPermissions";
            PrivateCatalogAppsType = "BlockedAppList";
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
