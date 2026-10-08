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
        AADB2BManagementPolicy "AADB2BManagementPolicy-Example"
        {
            Definition            = @("{`"B2BManagementPolicy`":{`"InvitationsAllowedAndBlockedDomainsPolicy`":{`"BlockedDomains`":[]},`"AutoRedeemPolicy`":{`"AdminConsentedForUsersIntoTenantIds`":[],`"NoAADConsentForUsersFromTenantsIds`":[]}}}");
            IsSingleInstance      = "Yes";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
