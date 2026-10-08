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
        SPOSiteScript 'SPOSiteScript-SiteDesign'
        {
            Title                 = "Contoso Team Site Lists"
            Content               = '{"$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json", "actions": [{"verb": "createSPList", "listName": "Customer Tracking", "templateType": 100}], "version": 1}'
            Description           = "Creates the customer tracking list on new team sites"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }

        SPOSiteDesign 'SPOSiteDesign-Example'
        {
            Title                 = "Contoso Team Site Design"
            SiteScriptNames       = @("Contoso Team Site Lists")
            WebTemplate           = "TeamSite"
            IsDefault             = $false
            Description           = "Standard layout for departmental and project team sites" # Updated Property
            PreviewImageAltText   = "Contoso team site layout"
            PreviewImageUrl       = "https://contoso.sharepoint.com/SiteAssets/team-site-preview.png"
            Version               = 1
            DependsOn             = "[SPOSiteScript]SPOSiteScript-SiteDesign"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
