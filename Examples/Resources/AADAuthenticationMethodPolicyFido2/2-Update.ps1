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
        AADAuthenticationMethodPolicyFido2 "AADAuthenticationMethodPolicyFido2-Example"
        {
            Ensure                           = "Present";
            ExcludeTargets                   = @(
                MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget{
                    Id         = 'Paralegals'
                    TargetType = 'group'
                }
                MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget{
                    Id         = 'Executives'
                    TargetType = 'group'
                }
            );
            Id                               = "Fido2";
            IncludeTargets                   = @(
                MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget{
                    Id         = 'all_users'
                    TargetType = 'group'
                }
            );
            IsAttestationEnforced            = $False;
            IsSelfServiceRegistrationAllowed = $True;
            KeyRestrictions                  = MSFT_MicrosoftGraphFido2KeyRestrictions{
                IsEnforced      = $False
                EnforcementType = 'block'
                AaGuids         = @()
            };
            PasskeyProfiles                  = @(
                MSFT_AADAuthenticationMethodPolicyFido2PasskeyProfile{
                    AttestationEnforcement = "registrationOnly"
                    Id                     = "00000000-0000-0000-0000-000000000001"
                    KeyRestrictions        = MSFT_MicrosoftGraphFido2KeyRestrictions{
                        AaGuids         = @(
                            "90a3ccdf-635c-4729-a248-9b709135078f"
                            "de1e552d-db1d-4423-a619-566b625cdc84"
                        )
                        EnforcementType = "block"
                        IsEnforced      = $True
                    }
                    Name                   = "Default passkey profile"
                    PasskeyTypes           = "deviceBound"
                }
                MSFT_AADAuthenticationMethodPolicyFido2PasskeyProfile{
                    AttestationEnforcement = "disabled"
                    Id                     = "cdd85462-0de2-4642-99f8-3f6d70fa5125"
                    KeyRestrictions        = MSFT_MicrosoftGraphFido2KeyRestrictions{
                        AaGuids         = @(
                            "de1e552d-db1d-4423-a619-566b625cdc84"
                            "90a3ccdf-635c-4729-a248-9b709135078f"
                        )
                        EnforcementType = "block"
                        IsEnforced      = $True
                    }
                    Name                   = "SWCProfile"
                    PasskeyTypes           = "deviceBound"
                }
            );
            State                            = "enabled"; # Updated Property
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
