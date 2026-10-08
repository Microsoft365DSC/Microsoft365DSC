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
        SPOSiteScript 'SPOSiteScript-Example'
        {
            Title                 = "Contoso Site Logo"
            Content               = '{"$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json", "actions": [{"verb": "setSiteLogo", "url": "https://contoso.sharepoint.com/SiteAssets/company-logo.png"}], "version": 1}'
            Description           = "Applies the corporate logo to new team and communication sites" # Updated Property
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
