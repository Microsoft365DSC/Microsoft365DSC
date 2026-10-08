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
        SPOSharingSettings 'SPOSharingSettings-Example'
        {
            IsSingleInstance                                           = "Yes"
            AllowGuestUserShareToUsersNotInSiteCollection              = $false
            AllowSharingOutsideRestrictedAccessControlGroups           = $true
            SharingCapability                                          = "ExternalUserSharingOnly"
            MySiteSharingCapability                                    = "ExistingExternalUserSharingOnly"
            CoreDefaultShareLinkScope                                  = "SpecificPeople"
            CoreDefaultShareLinkRole                                   = "View"
            CoreDefaultLinkToExistingAccess                            = $false
            CoreLoopSharingCapability                                  = "ExternalUserSharingOnly"
            CoreLoopDefaultSharingLinkScope                            = "SpecificPeople"
            CoreLoopDefaultSharingLinkRole                             = "View"
            CoreOrganizationSharingLinkMaxExpirationInDays             = 180
            CoreOrganizationSharingLinkRecommendedExpirationInDays     = 90
            OneDriveDefaultShareLinkScope                              = "SpecificPeople"
            OneDriveDefaultShareLinkRole                               = "View"
            OneDriveDefaultLinkToExistingAccess                        = $false
            OneDriveLoopSharingCapability                              = "ExternalUserSharingOnly"
            OneDriveLoopDefaultSharingLinkScope                        = "SpecificPeople"
            OneDriveLoopDefaultSharingLinkRole                         = "View"
            OneDriveOrganizationSharingLinkMaxExpirationInDays         = 180
            OneDriveOrganizationSharingLinkRecommendedExpirationInDays = 90
            ShowEveryoneClaim                                          = $false
            ShowAllUsersClaim                                          = $false
            ShowEveryoneExceptExternalUsersClaim                       = $true
            ProvisionSharedWithEveryoneFolder                          = $false
            EnableGuestSignInAcceleration                              = $false
            GuestSharingGroupAllowListInTenantByPrincipalIdentity      = @()
            WhoCanShareAllowListInTenant                               = @()
            WhoCanShareAllowListInTenantByPrincipalIdentity            = @()
            RestrictExternalSharing                                    = @()
            RestrictExternalSharingForAgents                           = $false
            BccExternalSharingInvitations                              = $true
            BccExternalSharingInvitationsList                          = "compliance@contoso.com"
            SharingDomainRestrictionMode                               = "None"
            DefaultSharingLinkType                                     = "Direct"
            DefaultLinkPermission                                      = "View"
            PreventExternalUsersFromResharing                          = $false
            ShowPeoplePickerSuggestionsForGuestUsers                   = $false
            NotifyOwnersWhenItemsReshared                              = $true
            ExternalUserExpirationRequired                             = $false
            ApplicationId                                              = $ApplicationId
            TenantId                                                   = $TenantId
            CertificateThumbprint                                      = $CertificateThumbprint
        }
    }
}
