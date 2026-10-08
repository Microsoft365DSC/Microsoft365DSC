<#
This example adds a new Teams Voice Routing Policy.
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
        TeamsVoiceRoutingPolicy 'TeamsVoiceRoutingPolicy-Example'
        {
            Identity              = 'Corporate Voice Routing'
            OnlinePstnUsages      = @('Long Distance', 'Local', 'Internal')
            Description           = 'Grants long distance and local calling to corporate users'
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
