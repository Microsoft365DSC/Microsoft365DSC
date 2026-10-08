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
        AADCustomAuthenticationExtension "AADCustomAuthenticationExtension-Example"
        {
            AuthenticationConfigurationResourceId    = "<application-id-uri>"
            AuthenticationConfigurationType          = "#microsoft.graph.azureAdTokenAuthentication"
            ClaimsForTokenConfiguration              = @(
                MSFT_AADCustomAuthenticationExtensionClaimForTokenConfiguration{
                    ClaimIdInApiResponse = 'CostCentre'
                }
                MSFT_AADCustomAuthenticationExtensionClaimForTokenConfiguration{
                    ClaimIdInApiResponse = 'Division'
                }
            )
            ClientConfigurationMaximumRetries        = 1
            ClientConfigurationTimeoutInMilliseconds = 2000
            CustomAuthenticationExtensionType        = "#microsoft.graph.onTokenIssuanceStartCustomExtension"
            Description                              = "Adds employee cost centre claims at token issuance"
            DisplayName                              = "TokenEnrichmentExtension"
            EndPointConfiguration                    = MSFT_AADCustomAuthenticationExtensionEndPointConfiguration{
                EndpointType = '#microsoft.graph.httpRequestEndpoint'
                TargetUrl    = 'https://api.contoso.com/tokenenrichment'
            }
            Ensure                                   = "Present";
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
        }
    }
}
