<#
This example adds a new Teams Emergency Call Routing Policy.
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
        TeamsEmergencyCallRoutingPolicy 'TeamsEmergencyCallRoutingPolicy-Example'
        {
            Identity                       = "Amsterdam Office"
            AllowEnhancedEmergencyServices = $False
            Description                    = "Routes emergency calls placed from the Amsterdam and Utrecht offices" # Updated Property
            EmergencyNumbers               = @(
                MSFT_TeamsEmergencyNumber
                {
                    EmergencyDialString = '123456'
                    EmergencyDialMask   = '123'
                    OnlinePSTNUsage     = ''
                }
            )
            Ensure                         = "Present"
            ApplicationId                  = $ApplicationId
            TenantId                       = $TenantId
            CertificateThumbprint          = $CertificateThumbprint
        }
    }
}
