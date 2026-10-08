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
        EXOTransportConfig 'EXOTransportConfig-Example'
        {
            IsSingleInstance                        = "Yes";
            AddressBookPolicyRoutingEnabled         = $True;
            ClearCategories                         = $True;
            ConvertDisclaimerWrapperToEml           = $False;
            DSNConversionMode                       = "PreserveDSNBody";
            ExternalDelayDsnEnabled                 = $True;
            ExternalDsnLanguageDetectionEnabled     = $True;
            ExternalDsnSendHtml                     = $True;
            ExternalPostmasterAddress               = "postmaster@contoso.com";
            HeaderPromotionModeSetting              = "NoCreate";
            InternalDelayDsnEnabled                 = $True;
            InternalDsnLanguageDetectionEnabled     = $True;
            InternalDsnSendHtml                     = $True;
            JournalingReportNdrTo                   = "<>";
            JournalMessageExpirationDays            = 0;
            MaxRecipientEnvelopeLimit               = "Unlimited";
            ReplyAllStormBlockDurationHours         = 6;
            ReplyAllStormDetectionMinimumRecipients = 2500;
            ReplyAllStormDetectionMinimumReplies    = 10;
            ReplyAllStormProtectionEnabled          = $True;
            Rfc2231EncodingEnabled                  = $False;
            SmtpClientAuthenticationDisabled        = $True;
            ApplicationId                           = $ApplicationId
            TenantId                                = $TenantId
            CertificateThumbprint                   = $CertificateThumbprint
        }
    }
}
