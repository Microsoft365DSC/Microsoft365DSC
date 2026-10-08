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
        AADNamedLocationPolicy 'AADNamedLocationPolicy-Example'
        {
            DisplayName           = "Company Network"
            IpRanges              = @("198.51.100.0/24", "203.0.113.0/24")
            IsTrusted             = $False
            OdataType             = "#microsoft.graph.ipNamedLocation"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
