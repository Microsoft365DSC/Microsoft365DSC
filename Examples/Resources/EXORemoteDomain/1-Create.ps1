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
        EXORemoteDomain "EXORemoteDomain-Example"
        {
            Identity                             = "Fabrikam"
            AllowedOOFType                       = "External"
            AutoForwardEnabled                   = $True
            AutoReplyEnabled                     = $True
            ByteEncoderTypeFor7BitCharsets       = "Undefined"
            CharacterSet                         = "iso-8859-1"
            ContentType                          = "MimeHtmlText"
            DeliveryReportEnabled                = $True
            DisplaySenderName                    = $True
            DomainName                           = "contoso.com"
            IsInternal                           = $False
            LineWrapSize                         = "Unlimited"
            MeetingForwardNotificationEnabled    = $False
            Name                                 = "Fabrikam"
            NonMimeCharacterSet                  = "iso-8859-1"
            PreferredInternetCodePageForShiftJis = "Undefined"
            TargetDeliveryDomain                 = $False
            TrustedMailInboundEnabled            = $False
            TrustedMailOutboundEnabled           = $False
            UseSimpleDisplayName                 = $False
            Ensure                               = "Present"
            ApplicationId                        = $ApplicationId
            TenantId                             = $TenantId
            CertificateThumbprint                = $CertificateThumbprint
        }
    }
}
