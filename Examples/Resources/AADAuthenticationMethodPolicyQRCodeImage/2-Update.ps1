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
        AADAuthenticationMethodPolicyQRCodeImage "AADAuthenticationMethodPolicyQRCodeImage-Example"
        {
            Ensure                       = "Present";
            Id                           = "QRCodePin";
            IncludeTargets               = @(
                MSFT_AADAuthenticationMethodPolicyQRCodeImageIncludeTarget{
                    Id         = "all_users"
                    TargetType = "group"
                }
            );
            PinLength                    = 9; # Updated Property
            StandardQRCodeLifetimeInDays = 365;
            State                        = "disabled";
            ApplicationId                = $ApplicationId;
            TenantId                     = $TenantId;
            CertificateThumbprint        = $CertificateThumbprint;
        }
    }
}
