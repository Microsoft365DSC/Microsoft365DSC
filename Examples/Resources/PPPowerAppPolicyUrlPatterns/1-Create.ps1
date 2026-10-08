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
        PPPowerAppPolicyUrlPatterns "PPPowerAppPolicyUrlPatterns-Example"
        {
            Ensure                = "Present";
            PolicyName            = "Contoso Data Policy";
            PPTenantId            = "e91d4e0e-d5a5-4e3a-be14-2192592a59af";
            RuleSet               = @(
                MSFT_PPPowerAPpPolicyUrlPatternsRule{
                    pattern                           = 'https://contoso.com'
                    customConnectorRuleClassification = 'General'
                    order                             = 1
                }
                MSFT_PPPowerAPpPolicyUrlPatternsRule{
                    pattern                           = 'https://fabrikam.com'
                    customConnectorRuleClassification = 'General'
                    order                             = 2
                }
                MSFT_PPPowerAPpPolicyUrlPatternsRule{
                    pattern                           = '*'
                    customConnectorRuleClassification = 'Ignore'
                    order                             = 3
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
