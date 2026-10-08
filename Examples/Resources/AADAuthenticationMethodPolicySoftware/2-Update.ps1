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
        AADAuthenticationMethodPolicySoftware "AADAuthenticationMethodPolicySoftware-Example"
        {
            Ensure                = "Present";
            ExcludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicySoftwareExcludeTarget{
                    Id         = 'Executives'
                    TargetType = 'group'
                }
                MSFT_AADAuthenticationMethodPolicySoftwareExcludeTarget{
                    Id         = 'Paralegals'
                    TargetType = 'group'
                }
            );
            Id                    = "SoftwareOath";
            IncludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicySoftwareIncludeTarget{
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
