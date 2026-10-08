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
        AADAuthenticationMethodPolicyExternal "AADAuthenticationMethodPolicyExternal-Example"
        {
            AppId                 = "<application-id-updated>"; # Updated Property
            DisplayName           = "Cisco Duo";
            Ensure                = "Present";
            ExcludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyExternalExcludeTarget{
                    Id         = 'Design'
                    TargetType = 'group'
                }
            );
            IncludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyExternalIncludeTarget{
                    Id         = 'Contoso'
                    TargetType = 'group'
                }
            );
            OpenIdConnectSetting  = MSFT_AADAuthenticationMethodPolicyExternalOpenIdConnectSetting{
                discoveryUrl = 'https://graph.microsoft.com/'
                clientId     = '<client-id>'
            };
            State                 = "disabled";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
