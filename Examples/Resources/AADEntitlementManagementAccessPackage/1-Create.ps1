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
        AADEntitlementManagementAccessPackage 'AADEntitlementManagementAccessPackage-Example'
        {
            AccessPackagesIncompatibleWith = @();
            CatalogId                      = "General";
            Description                    = "Grants access to the finance reporting toolset";
            DisplayName                    = "Finance Reporting Access";
            Ensure                         = "Present";
            IsHidden                       = $False;
            IsRoleScopesVisible            = $True;
            IncompatibleAccessPackages     = @();
            IncompatibleGroups             = @();
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            CertificateThumbprint          = $CertificateThumbprint
        }
    }
}
