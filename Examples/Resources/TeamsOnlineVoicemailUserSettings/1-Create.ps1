<#
This example adds a new Teams Channels Policy.
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
        TeamsOnlineVoicemailUserSettings 'TeamsOnlineVoicemailUserSettings-Example'
        {
            CallAnswerRule                           = "RegularVoicemail";
            CallToActionDetectionEnabled             = $true;
            CategoryDetectionEnabled                 = $true;
            DefaultGreetingPromptOverwrite           = "Hellow World!";
            Ensure                                   = "Present";
            Identity                                 = "John.Smith@contoso.com";
            OofGreetingEnabled                       = $False;
            OofGreetingFollowAutomaticRepliesEnabled = $False;
            PromptLanguage                           = "en-US";
            ShareData                                = $False;
            UrgencyDetectionEnabled                  = $true;
            VoicemailEnabled                         = $True;
            VoiceToTextSummaryEnabled                = $true;
            ApplicationId                            = $ApplicationId;
            TenantId                                 = $TenantId;
            CertificateThumbprint                    = $CertificateThumbprint;
        }
    }
}
