<#
This example adds a new Teams Voice Route.
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
        TeamsVoiceRoute 'TeamsVoiceRoute-Example'
        {
            Identity              = 'North America SBC Route'
            Description           = 'Routes North American numbers to the primary and backup SBC pair' # Updated Property
            NumberPattern         = '^\+1(425|206)(\d{7})'
            OnlinePstnGatewayList = @("sbc1.$TenantId", "sbc2.$TenantId")
            OnlinePstnUsages      = @('Long Distance', 'Local', 'Internal')
            Priority              = 1
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
