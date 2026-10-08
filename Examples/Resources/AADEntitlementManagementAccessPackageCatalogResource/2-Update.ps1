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
        AADEntitlementManagementAccessPackageCatalogResource 'AADEntitlementManagementAccessPackageCatalogResource-Example'
        {
            CatalogId             = "General";
            DisplayName           = "Mark 8 Project Team";
            OriginSystem          = "AadGroup";
            OriginId              = "Mark 8 Project Team";
            AddedBy               = "MeganB@$TenantId";
            AddedOn               = "2026-01-01T00:00:00.0000000Z";
            Description           = "Welcome to the team that we've assembled to create the Mark 8.";
            ResourceType          = "Microsoft 365 Teams Group";
            Ensure                = "Present";
            IsPendingOnboarding   = $False;
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
