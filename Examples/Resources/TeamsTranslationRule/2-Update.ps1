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
        TeamsTranslationRule 'TeamsTranslationRule-Example'
        {
            Description           = "Adds the North American +1 country code to ten-digit numbers"; # Updated Property
            Ensure                = "Present";
            Identity              = "AddPlus1";
            Pattern               = "^(\d{10})$";
            Translation           = "+1`$1";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
