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
        TeamsChannelTab 'TeamsChannelTab-Example'
        {
            ChannelName           = "General"
            Configuration         = MSFT_MicrosoftGraphTeamsTabConfiguration{
                ContentUrl = "https://contoso.com"
                WebsiteUrl = "https://contoso.com"
            }
            DisplayName           = "Project Plan"
            SortOrderIndex        = "10100"
            TeamName              = "Mark 8 Project Team"
            TeamsApp              = "com.microsoft.teamspace.tab.web"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
