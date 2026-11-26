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
        AADAuthenticationMethodPolicyVoice "AADAuthenticationMethodPolicyVoice-Example"
        {
            CallerIdNumber        = "+14255550100";
            Ensure                = "Present";
            ExcludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyVoiceExcludeTarget{
                    Id         = 'All Employees'
                    TargetType = 'group'
                }
            );
            Id                    = "Voice";
            IncludeTargets        = @(
                MSFT_AADAuthenticationMethodPolicyVoiceIncludeTarget{
                    Id         = 'all_users'
                    TargetType = 'group'
                }
            );
            IsOfficePhoneAllowed  = $true;
            State                 = "enabled"; # Updated Property
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
