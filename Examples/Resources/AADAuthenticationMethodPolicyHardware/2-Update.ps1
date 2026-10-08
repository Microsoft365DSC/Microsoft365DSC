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
        AADAuthenticationMethodPolicyHardware "AADAuthenticationMethodPolicyHardware-Example"
        {
            Ensure                = "Present";
            ExcludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyHardwareExcludeTarget{
                    Id         = 'Executives'
                    TargetType = 'group'
                }
                MSFT_AADAuthenticationMethodPolicyHardwareExcludeTarget{
                    Id         = 'Paralegals'
                    TargetType = 'group'
                }
            );
            Id                    = "HardwareOath";
            IncludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyHardwareIncludeTarget{
                    Id         = 'Legal Team'
                    TargetType = 'group'
                }
            );
            State                 = "enabled"; # Updated Property
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
