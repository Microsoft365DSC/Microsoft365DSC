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
        EXOOMEConfiguration 'EXOOMEConfiguration-Example'
        {
            Identity                 = "OME Configuration"
            BackgroundColor          = "#ffffff"
            DisclaimerText           = "This message is confidential and intended only for the named recipients."
            EmailText                = "Encrypted message enclosed."
            IntroductionText         = "has sent you a secure message."
            OTPEnabled               = $True
            PortalText               = "Contoso secure message portal"
            PrivacyStatementUrl      = "https://www.contoso.com/privacy"
            ReadButtonText           = "Read the secure message"
            SocialIdSignIn           = $True
            Ensure                   = "Present"
            ApplicationId            = $ApplicationId
            TenantId                 = $TenantId
            CertificateThumbprint    = $CertificateThumbprint
        }
    }
}
