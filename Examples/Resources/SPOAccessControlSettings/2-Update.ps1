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
        SPOAccessControlSettings 'SPOAccessControlSettings-Example'
        {
            IsSingleInstance              = "Yes"
            DisplayStartASiteOption       = $false
            StartASiteFormUrl             = "https://contoso.sharepoint.com"
            IPAddressEnforcement          = $false
            IPAddressAllowList            = "10.20.0.0/16, 2001:db8:4a2f::/48"
            IPAddressWACTokenLifetime     = 15
            DisallowInfectedFileDownload  = $true
            ExternalServicesEnabled       = $true
            EmailAttestationRequired      = $false
            EmailAttestationReAuthDays    = 30
            EnableRestrictedAccessControl = $false
            RestrictResourceAccountAccess = $false
            ConditionalAccessPolicy       = "AllowFullAccess"
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
