<#
This example removes a Device Control Policy.
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
        IntuneEpmCertificatePolicySetting "IntuneEpmCertificatePolicySetting-Example"
        {
            DisplayName           = "Contoso Elevation Signing Certificate";
            CertificateFile       = "<base64-encoded-certificate>";
            Ensure                = "Absent";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
