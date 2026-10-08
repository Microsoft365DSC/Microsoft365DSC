<#
This example sets Power Platform tenant isolation settings.
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
        PPTenantIsolationSettings 'PPTenantIsolationSettings-Example'
        {
            IsSingleInstance      = 'Yes'
            Enabled               = $true
            Rules                 = @(
                MSFT_PPTenantRule{
                    TenantName = "$TenantId"
                    Direction  = 'Outbound'
                }
                MSFT_PPTenantRule{
                    TenantName = 'fabrikam.onmicrosoft.com'
                    Direction  = 'Both'
                }
            )
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
