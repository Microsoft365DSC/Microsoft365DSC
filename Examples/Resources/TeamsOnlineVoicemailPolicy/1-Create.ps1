<#
This example adds a new Teams Meeting Policy.
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
        TeamsOnlineVoicemailPolicy 'TeamsOnlineVoicemailPolicy-Example'
        {
            EnableEditingCallAnswerRulesSetting = $true;
            EnableTranscription                 = $true;
            EnableTranscriptionProfanityMasking = $false;
            EnableTranscriptionTranslation      = $true;
            EnableVoicemailTriage               = $false;
            Ensure                              = "Present";
            Identity                            = "CorporateVoicemail";
            MaximumRecordingLength              = 600;
            PreamblePostambleMandatory          = $false;
            PrimarySystemPromptLanguage         = "en-US";
            SecondarySystemPromptLanguage       = "fr-FR";
            ShareData                           = "Defer";
            ApplicationId                       = $ApplicationId;
            TenantId                            = $TenantId;
            CertificateThumbprint               = $CertificateThumbprint;
        }
    }
}
