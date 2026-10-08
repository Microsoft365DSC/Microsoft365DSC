<#
This example updates a Intune Firewall Policy for Windows10.
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
            Description           = "Code signing certificate trusted for line of business and engineering application elevation"; # Updated Property
            DisplayName           = "Contoso Elevation Signing Certificate";
            Ensure                = "Present";
            CertificateFile       = "<base64-encoded-certificate>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
