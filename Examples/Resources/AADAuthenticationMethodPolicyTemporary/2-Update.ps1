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
        AADAuthenticationMethodPolicyTemporary "AADAuthenticationMethodPolicyTemporary-Example"
        {
            DefaultLength            = 9; # Updated Property
            DefaultLifetimeInMinutes = 60;
            Ensure                   = "Present";
            ExcludeTargets           = @(
                MSFT_AADAuthenticationMethodPolicyTemporaryExcludeTarget{
                    Id         = 'All Company'
                    TargetType = 'group'
                }
            );
            Id                       = "TemporaryAccessPass";
            IncludeTargets           = @(
                MSFT_AADAuthenticationMethodPolicyTemporaryIncludeTarget{
                    Id         = 'Executives'
                    TargetType = 'group'
                }
            );
            IsUsableOnce             = $False;
            MaximumLifetimeInMinutes = 480;
            MinimumLifetimeInMinutes = 60;
            State                    = "enabled";
            ApplicationId            = $ApplicationId
            TenantId                 = $TenantId
            CertificateThumbprint    = $CertificateThumbprint
        }
    }
}
