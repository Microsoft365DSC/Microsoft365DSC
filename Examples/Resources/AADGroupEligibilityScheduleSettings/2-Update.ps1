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
        AADGroupEligibilityScheduleSettings 'AADGroupEligibilityScheduleSettings-Example'
        {
            expirationRule        = MSFT_AADRoleManagementPolicyExpirationRule{
                isExpirationRequired = $False
                maximumDuration      = "PT8H"
            };
            groupDisplayName      = "sg-Retail";
            id                    = "Expiration_EndUser_Assignment";
            PIMGroupRole          = "member";
            ruleType              = "#microsoft.graph.unifiedRoleManagementPolicyExpirationRule";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
