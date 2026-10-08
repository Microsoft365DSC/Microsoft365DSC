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
        TeamsMessagingConfiguration 'TeamsMessagingConfiguration-Example'
        {
            Communities                       = "Enabled";
            ContentBasedPhishingCheck         = "Disabled";
            CustomEmojis                      = $True;
            EnableInOrganizationChatControl   = $False;
            EnableVideoMessageCaptions        = $True;
            FileTypeCheck                     = "Disabled";
            IsSingleInstance                  = "Yes";
            MessagingNotes                    = "Enabled";
            ReportIncorrectSecurityDetections = "Disabled";
            Storyline                         = "Enabled";
            UrlReputationCheck                = "Disabled";
            ApplicationId                     = $ApplicationId;
            TenantId                          = $TenantId;
            CertificateThumbprint             = $CertificateThumbprint;
        }
    }
}
