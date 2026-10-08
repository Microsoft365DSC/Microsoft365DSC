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
        AADAuthenticationMethodPolicyAuthenticator "AADAuthenticationMethodPolicyAuthenticator-Example"
        {
            Ensure                = "Present";
            ExcludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyAuthenticatorExcludeTarget{
                    Id         = 'Executives' # Updated Property
                    TargetType = 'group'
                }
            );
            FeatureSettings       = MSFT_MicrosoftGraphmicrosoftAuthenticatorFeatureSettings{
                DisplayLocationInformationRequiredState = MSFT_MicrosoftGraphAuthenticationMethodFeatureConfiguration{
                    IncludeTarget = MSFT_AADAuthenticationMethodPolicyAuthenticatorFeatureTarget{
                        Id         = 'all_users'
                        TargetType = 'group'
                    }
                    State         = 'default'
                }
                CompanionAppAllowedState                = MSFT_MicrosoftGraphAuthenticationMethodFeatureConfiguration{
                    IncludeTarget = MSFT_AADAuthenticationMethodPolicyAuthenticatorFeatureTarget{
                        Id         = 'all_users'
                        TargetType = 'group'
                    }
                    State         = 'default'
                }
                DisplayAppInformationRequiredState      = MSFT_MicrosoftGraphAuthenticationMethodFeatureConfiguration{
                    IncludeTarget = MSFT_AADAuthenticationMethodPolicyAuthenticatorFeatureTarget{
                        Id         = 'all_users'
                        TargetType = 'group'
                    }
                    State         = 'default'
                }
            };
            Id                    = "MicrosoftAuthenticator";
            IncludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyAuthenticatorIncludeTarget{
                    Id         = 'Finance Team'
                    TargetType = 'group'
                }
                MSFT_AADAuthenticationMethodPolicyAuthenticatorIncludeTarget{
                    Id         = 'Northwind Traders'
                    TargetType = 'group'
                }
            );
            IsSoftwareOathEnabled = $False;
            State                 = "enabled";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
