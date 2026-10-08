<#
This examples sets the Teams Meeting Configuration.
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
        TeamsMeetingConfiguration 'TeamsMeetingConfiguration-Example'
        {
            IsSingleInstance                     = 'Yes'
            ClientAppSharingPort                 = 50040
            ClientAppSharingPortRange            = 20
            ClientAudioPort                      = 50000
            ClientAudioPortRange                 = 20
            ClientMediaPortRangeEnabled          = $True
            ClientVideoPort                      = 50020
            ClientVideoPortRange                 = 20
            CustomFooterText                     = "This is some custom footer text"
            DisableAnonymousJoin                 = $False
            EnableAttributedTranscripts          = $false
            EnableGraphTranscriptAccess          = $false
            EnableQoS                            = $False
            HelpURL                              = "https://contoso.com/teams/help"
            LegalURL                             = "https://contoso.com/teams/legal"
            LogoURL                              = "https://contoso.com/teams/logo.png"
            PublishedEntraAuthenticationContexts = @(
                MSFT_TeamsPublishedEntraAuthenticationContext{
                    Id                   = "c3"
                    PublishedName        = "Confidential meetings"
                    PublishedDescription = "Requires step-up authentication to join confidential meetings"
                }
            )
            ReportMeeting                        = "Enabled"
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
