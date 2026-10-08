<#
This example configures the Teams Guest Calling Configuration.
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
        TeamsTenantDialPlan 'TeamsTenantDialPlan-Example'
        {
            Identity              = 'AmsterdamPlan'
            Description           = 'Dial plan for the Amsterdam office'
            NormalizationRules    = @(
                MSFT_TeamsVoiceNormalizationRule
                {
                    Pattern             = '^00(\d+)$'
                    Description         = 'LB International Dialing Rule'
                    Identity            = 'LB Intl Dialing'
                    Translation         = '+$1'
                    Priority            = 0
                    IsInternalExtension = $False
                }
            )
            SimpleName            = 'AmsterdamPlan'
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
