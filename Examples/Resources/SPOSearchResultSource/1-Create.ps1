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
        SPOSearchResultSource 'SPOSearchResultSource-Example'
        {
            Name                  = "Company Policy Documents"
            Description           = "Returns only approved documents published in the corporate policy libraries"
            Protocol              = "Local"
            Type                  = "SharePoint"
            QueryTransform        = "{searchTerms} contentclass:STS_ListItem_DocumentLibrary"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
