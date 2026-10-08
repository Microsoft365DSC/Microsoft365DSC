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
        EXOReportSubmissionPolicy 'EXOReportSubmissionPolicy-Example'
        {
            IsSingleInstance                            = 'Yes'
            DisableQuarantineReportingOption            = $False
            EnableCustomNotificationSender              = $True
            EnableOrganizationBranding                  = $False
            EnableReportToMicrosoft                     = $True
            EnableThirdPartyAddress                     = $False
            EnableUserEmailNotification                 = $True
            JunkReviewResultMessage                     = "Thank you for your submission. Our security team confirmed that the message you reported is junk."
            NotJunkReviewResultMessage                  = "Thank you for your submission. Our security team confirmed that the message you reported is not junk."
            NotificationFooterMessage                   = "This message was sent by the Contoso messaging security team. Please do not reply to it."
            NotificationSenderAddress                   = "MeganB@$TenantId"
            PhishingReviewResultMessage                 = "Thank you for your submission. Our security team confirmed that the message you reported is a phishing attempt."
            PostSubmitMessage                           = "Thank you for reporting this message. Our security team will review it and let you know the outcome."
            PostSubmitMessageEnabled                    = $True
            PostSubmitMessageTitle                      = "Message reported"
            PreSubmitMessage                            = "Reporting this message sends a copy of it to our security team for analysis."
            PreSubmitMessageEnabled                     = $True
            PreSubmitMessageTitle                       = "Report this message?"
            ReportChatMessageEnabled                    = $True
            ReportChatMessageToCustomizedAddressEnabled = $False
            ReportJunkAddresses                         = @("MeganB@$TenantId")
            ReportJunkToCustomizedAddress               = $True
            ReportNotJunkAddresses                      = @("MeganB@$TenantId")
            ReportNotJunkToCustomizedAddress            = $True
            ReportPhishAddresses                        = @("MeganB@$TenantId")
            ReportPhishToCustomizedAddress              = $True
            Ensure                                      = "Present"
            ApplicationId                               = $ApplicationId
            TenantId                                    = $TenantId
            CertificateThumbprint                       = $CertificateThumbprint
        }
    }
}
