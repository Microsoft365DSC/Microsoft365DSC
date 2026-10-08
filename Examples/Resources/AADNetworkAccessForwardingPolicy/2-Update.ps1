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
        AADNetworkAccessForwardingPolicy "AADNetworkAccessForwardingPolicy-Example"
        {
            Name                  = "Custom Bypass";
            PolicyRules           = @(
                MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule {
                    Name         = 'Custom policy internet rule'
                    ActionValue  = 'bypass'
                    RuleType     = 'fqdn'
                    Protocol     = 'tcp'
                    Ports        = @('80', '443')
                    Destinations = @('www.microsoft.com')
                }

                MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule {
                    Name         = 'Custom policy internet rule 2'
                    ActionValue  = 'bypass'
                    RuleType     = 'ipAddress'
                    Protocol     = 'tcp'
                    Ports        = @('80', '443')
                    Destinations = @('192.168.1.1')
                }

                MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule {
                    Name         = 'Custom policy internet rule 3'
                    ActionValue  = 'bypass'
                    RuleType     = 'ipSubnet'
                    Protocol     = 'tcp'
                    Ports        = @('80', '443')
                    Destinations = @('192.164.0.0/24')
                }
            );
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
