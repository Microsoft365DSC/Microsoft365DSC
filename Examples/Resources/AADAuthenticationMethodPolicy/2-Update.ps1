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
        AADAuthenticationMethodPolicy "AADAuthenticationMethodPolicy-Example"
        {
            RegistrationEnforcement          = MSFT_MicrosoftGraphregistrationEnforcement{
                AuthenticationMethodsRegistrationCampaign = MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaign{
                    SnoozeDurationInDays = (Get-Random -Minimum 1 -Maximum 14)
                    IncludeTargets       = @(
                        MSFT_MicrosoftGraphAuthenticationMethodsRegistrationCampaignIncludeTarget{
                            TargetedAuthenticationMethod = 'microsoftAuthenticator'
                            TargetType                   = 'group'
                            Id                           = 'all_users'
                        }
                    )
                    State                = 'default'
                }
            };
            ReportSuspiciousActivitySettings = MSFT_MicrosoftGraphreportSuspiciousActivitySettings{
                VoiceReportingCode = 0
                IncludeTarget      = MSFT_AADAuthenticationMethodPolicyIncludeTarget{
                    Id         = 'all_users'
                    TargetType = 'group'
                }
                State              = 'default'
            };
            SystemCredentialPreferences      = MSFT_MicrosoftGraphsystemCredentialPreferences{
                IncludeTargets = @(
                    MSFT_AADAuthenticationMethodPolicyIncludeTarget{
                        Id         = 'all_users'
                        TargetType = 'group'
                    }
                )
                State          = 'default'
            };
            ReconfirmationInDays             = 180
            IsSingleInstance                 = 'Yes'
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
