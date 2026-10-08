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
        SPOStorageEntity 'SPOStorageEntity-Example'
        {
            Key                   = "ContosoHelpDeskUrl"
            Value                 = "https://contoso.sharepoint.com/sites/helpdesk"
            EntityScope           = "Tenant"
            Description           = "Link to the corporate help desk site"
            Comment               = "Maintained by the intranet team"
            SiteUrl               = "https://contoso-admin.sharepoint.com"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
