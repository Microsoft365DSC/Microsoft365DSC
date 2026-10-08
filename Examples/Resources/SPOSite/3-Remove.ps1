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
        SPOSite 'SPOSite-Example'
        {
            Url                                                            = "https://contoso.sharepoint.com/sites/marketing"
            Owner                                                          = "AdeleV@$TenantId"
            Title                                                          = "Marketing"
            TimeZoneId                                                     = 13
            Ensure                                                         = "Absent"
            ApplicationId                                                  = $ApplicationId
            TenantId                                                       = $TenantId
            CertificateThumbprint                                          = $CertificateThumbprint
        }
    }
}
