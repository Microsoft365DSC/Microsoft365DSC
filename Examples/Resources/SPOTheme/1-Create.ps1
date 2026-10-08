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
        SPOTheme 'SPOTheme-Example'
        {
            Name                  = "PSTheme1"
            IsInverted            = $false
            Palette               = @(
                MSFT_SPOThemePaletteProperty
                {
                    Property = "themePrimary"
                    Value    = "#0078d4"
                }
                MSFT_SPOThemePaletteProperty
                {
                    Property = "themeLighterAlt"
                    Value    = "#eff6fc"
                }
            )
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
