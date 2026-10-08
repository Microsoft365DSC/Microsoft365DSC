<#
This example creates a new PowerApps environment in production.
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
        PPPowerAppsEnvironment 'PPPowerAppsEnvironment-Example'
        {
            DisplayName           = "Contoso Production"
            EnvironmentSKU        = "Production"
            EnvironmentType       = "NotSpecified"
            Location              = "canada"
            ProvisionDatabase     = $true
            LanguageName          = "1033";
            CurrencyName          = "CAD";
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
