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

        AADRoleManagementPolicyRule "AADRoleManagementPolicyRule-Example"
        {
            ExpirationRule        = MSFT_AADRoleManagementPolicyExpirationRule{
                isExpirationRequired = $False
                maximumDuration      = 'P180D'
            };
            Id                    = "Expiration_Admin_Eligibility";
            RoleDisplayName       = "Global Administrator";
            RuleType              = "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
