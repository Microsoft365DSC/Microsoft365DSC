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
        AADAdministrativeUnit 'AADAdministrativeUnit-Example'
        {
            DisplayName                   = 'Amsterdam Office'
            Description                   = 'Users and devices based in the Amsterdam and Rotterdam offices' # Updated Property
            Visibility                    = 'Public'
            MembershipRule                = "(user.country -eq `"US`")" # Updated Property
            MembershipRuleProcessingState = 'On'
            MembershipType                = 'Dynamic'
            IsMemberManagementRestricted  = $False
            ScopedRoleMembers             = @(
                MSFT_MicrosoftGraphScopedRoleMembership
                {
                    RoleName       = 'User Administrator'
                    RoleMemberInfo = MSFT_MicrosoftGraphMember
                    {
                        Identity = "AdeleV@$TenantId" # Updated Property
                        Type     = "User"
                    }
                }
            )
            Ensure                        = 'Present'
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
