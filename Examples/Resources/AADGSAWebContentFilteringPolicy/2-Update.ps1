<#
This example updates an existing Web Content Filtering Policy in Global Secure Access.
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
        AADGSAWebContentFilteringPolicy 'AADGSAWebContentFilteringPolicy-Example'
        {
            Name                  = "Block Social Media Access"
            Description           = "Restricts access to social networking categories during business hours" # Updated Property
            DefaultAction         = "allow"
            Rules                 = @(
                MSFT_AADGSAWebContentFilteringPolicyRule{
                    Name              = "Block social networking"
                    Priority          = 100
                    Description       = "Blocks social networking sites for standard users"
                    Action            = "block"
                    Status            = "enabled"
                    HttpRequestMethod = "get"
                    SessionType       = "user"
                    Destinations      = @(
                        MSFT_AADGSAWebContentFilteringPolicyRuleDestination{
                            Type   = "webFilteringWebCategoryDestination"
                            Values = @("SocialNetworking")
                        }
                    )
                }
            )
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
