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
        EXOPhishSimOverrideRule "EXOPhishSimOverrideRule-Example"
        {
            Comment               = "Allows security awareness training campaigns from the training vendor";
            Domains               = @("fabrikam.com","wingtiptoys.com");
            Ensure                = "Present";
            IsSingleInstance      = "Yes";
            SenderIpRanges        = @("192.168.1.55");
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
