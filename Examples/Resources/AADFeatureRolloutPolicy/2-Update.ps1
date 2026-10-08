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
        AADFeatureRolloutPolicy "AADFeatureRolloutPolicy-Example"
        {
            AppliesTo               = @("AADGroup_1")
            Description             = "CertificateBasedAuthentication rollout policy";
            DisplayName             = "certificateBasedAuthentication rollout policy";
            Ensure                  = "Present";
            IsAppliedToOrganization = $False;
            IsEnabled               = $False; # Updated Property
            ApplicationId           = $ApplicationId
            TenantId                = $TenantId
            CertificateThumbprint   = $CertificateThumbprint
        }
    }
}
