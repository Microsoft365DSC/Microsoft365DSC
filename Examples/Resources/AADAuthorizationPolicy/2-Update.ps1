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
        AADAuthorizationPolicy 'AADAuthorizationPolicy-Example'
        {
            IsSingleInstance                                  = 'Yes'
            DisplayName                                       = 'Authorization Policy'
            Description                                       = 'Used to manage authorization related settings across the company.'
            AllowEmailVerifiedUsersToJoinOrganization         = $true
            AllowInvitesFrom                                  = 'everyone'
            AllowedToSignUpEmailBasedSubscriptions            = $true
            AllowedToUseSspr                                  = $true
            BlockMsolPowerShell                               = $false
            DefaultUserRolePermissions                        = MSFT_DefaultUserRolePermissions{
                AllowedToCreateApps           = $true
                AllowedToCreateSecurityGroups = $true
                AllowedToReadOtherUsers       = $true
            }
            EnabledPreviewFeatures                            = @('assignGroupsToRoles')
            GuestUserRole                                     = 'Guest'
            PermissionGrantPolicyIdsAssignedToDefaultUserRole = @()
            Ensure                                            = 'Present'
            ApplicationId                                     = $ApplicationId
            TenantId                                          = $TenantId
            CertificateThumbprint                             = $CertificateThumbprint
        }
    }
}
