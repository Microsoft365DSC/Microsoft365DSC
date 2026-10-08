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
        AADAuthenticationMethodPolicyX509 "AADAuthenticationMethodPolicyX509-Example"
        {
            AuthenticationModeConfiguration = MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration{
                X509CertificateAuthenticationDefaultMode = 'x509CertificateSingleFactor'
                Rules                                    = @()
            };
            CertificateAuthorityScopes      = @(
                MSFT_MicrosoftGraphx509CertificateAuthorityScope{
                    IncludeTargets                    = @(
                        MSFT_MicrosoftGraphIncludeTarget{
                            Id         = 'Certificate Based Auth Pilot'
                            TargetType = 'group'
                        }
                    )
                    PublicKeyInfrastructureIdentifier = '9b1a4f2e-7c33-4d51-8a0e-1f6d2b5c7e40'
                    SubjectKeyIdentifier              = 'a1b2c3d4e5f60718293a4b5c6d7e8f9012345678'
                }
            );
            CertificateUserBindings         = @(
                MSFT_MicrosoftGraphx509CertificateUserBinding{
                    Priority             = 1
                    UserProperty         = 'userPrincipalName'
                    X509CertificateField = 'PrincipalName'
                }
                MSFT_MicrosoftGraphx509CertificateUserBinding{
                    Priority             = 2
                    UserProperty         = 'userPrincipalName'
                    X509CertificateField = 'RFC822Name'
                }
                MSFT_MicrosoftGraphx509CertificateUserBinding{
                    Priority             = 3
                    UserProperty         = 'certificateUserIds'
                    X509CertificateField = 'SubjectKeyIdentifier'
                }
            );
            Ensure                          = "Present";
            ExcludeTargets                  = @(
                MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget{
                    Id         = 'Marketing Team'
                    TargetType = 'group'
                }
            );
            Id                              = "X509Certificate";
            IncludeTargets                  = @(
                MSFT_AADAuthenticationMethodPolicyX509IncludeTarget{
                    Id         = 'Finance Team'
                    TargetType = 'group'
                }
            );
            IssuerHintsConfiguration        = MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration{
                State = 'enabled'
            };
            State                           = "enabled";
            ApplicationId                   = $ApplicationId
            TenantId                        = $TenantId
            CertificateThumbprint           = $CertificateThumbprint
        }
    }
}
