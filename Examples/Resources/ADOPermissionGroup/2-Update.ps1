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
        ADOPermissionGroup "ADOPermissionGroup-Example"
        {
            Description           = "Members can create and administer projects across the engineering organization.";
            DisplayName           = "ProjectAdministrators";
            Ensure                = "Present";
            Level                 = "Organization";
            Members               = @("AdeleV@$TenantId", "admin@$TenantId"); # Updated Property
            OrganizationName      = "Contoso-Dev";
            PrincipalName         = "[CONTOSO-DEV]\ProjectAdministrators";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
