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
        O365ExternalConnection "O365ExternalConnection-Example"
        {
            ActivitySettings      = MSFT_MicrosoftGraphActivitySettings{
                UrlToItemResolvers = @(
                    MSFT_MicrosoftGraphUrlToItemResolverBase{
                        ItemId       = "{employeeId}"
                        Priority     = 1
                        UrlMatchInfo = MSFT_MicrosoftGraphUrlMatchInfo{
                            BaseUrls   = @("https://hr.contoso.com")
                            UrlPattern = "/employees/(?<employeeId>[0-9]+)"
                        }
                    }
                )
            };
            AuthorizedAppIds      = @("Contoso HR Connector", "Contoso Knowledge Indexer"); # Updated Property
            ContentCategory       = "knowledgeBase";
            Description           = "Indexes employee handbooks and policies from the Contoso HR system";
            Ensure                = "Present";
            Id                    = "contosohr";
            Name                  = "Contoso HR";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
