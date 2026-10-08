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
        EXOHostedContentFilterPolicy 'EXOHostedContentFilterPolicy-Example'
        {
            Identity                             = "Standard Spam Filter"
            AddXHeaderValue                      = ""
            AdminDisplayName                     = ""
            BulkSpamAction                       = "MoveToJmf"
            BulkThreshold                        = 8 # Updated Property
            EnableLanguageBlockList              = $False
            EnableRegionBlockList                = $False
            HighConfidencePhishAction            = "Quarantine"
            HighConfidenceSpamAction             = "MoveToJmf"
            IncreaseScoreWithBizOrInfoUrls       = "Off"
            IncreaseScoreWithImageLinks          = "Off"
            IncreaseScoreWithNumericIps          = "Off"
            IncreaseScoreWithRedirectToOtherPort = "Off"
            InlineSafetyTipsEnabled              = $True
            LanguageBlockList                    = @()
            MakeDefault                          = $False
            MarkAsSpamBulkMail                   = "On"
            MarkAsSpamEmbedTagsInHtml            = "Off"
            MarkAsSpamEmptyMessages              = "Off"
            MarkAsSpamFormTagsInHtml             = "Off"
            MarkAsSpamFramesInHtml               = "Off"
            MarkAsSpamFromAddressAuthFail        = "Off"
            MarkAsSpamJavaScriptInHtml           = "Off"
            MarkAsSpamNdrBackscatter             = "Off"
            MarkAsSpamObjectTagsInHtml           = "Off"
            MarkAsSpamSensitiveWordList          = "Off"
            MarkAsSpamSpfRecordHardFail          = "Off"
            MarkAsSpamWebBugsInHtml              = "Off"
            ModifySubjectValue                   = ""
            PhishSpamAction                      = "MoveToJmf"
            PhishZapEnabled                      = $True
            QuarantineRetentionPeriod            = 15
            RedirectToRecipients                 = @()
            RegionBlockList                      = @()
            SpamAction                           = "MoveToJmf"
            SpamZapEnabled                       = $True
            TestModeAction                       = "None"
            TestModeBccToRecipients              = @()
            Ensure                               = "Present"
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
