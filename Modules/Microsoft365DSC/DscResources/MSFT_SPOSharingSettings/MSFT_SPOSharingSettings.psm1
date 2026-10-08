using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSharingSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AllowGuestUserShareToUsersNotInSiteCollection settings (defaulted to false) will allow guests to share to users not in the site.')]
    [System.Nullable[System.Boolean]] $AllowGuestUserShareToUsersNotInSiteCollection

    [DscProperty()]
    [System.ComponentModel.Description('Controls whether sharing SharePoint sites and their content is allowed with users and groups who are not allowed as per the Restricted access control policy.')]
    [System.Nullable[System.Boolean]] $AllowSharingOutsideRestrictedAccessControlGroups

    [DscProperty()]
    [System.ComponentModel.Description('Sets the default sharing link role for SharePoint sites. It replaces the DefaultLinkPermission. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $CoreDefaultShareLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('Sets the default sharing link scope for SharePoint sites. It replaces the DefaultSharingLinkType. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $CoreDefaultShareLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('Configures sharing capability for SharePoint')]
    [ValidateSet('ExistingExternalUserSharingOnly', 'ExternalUserAndGuestSharing', 'Disabled', 'ExternalUserSharingOnly')]
    [System.String] $SharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Configures sharing capability for mysite (onedrive)')]
    [ValidateSet('ExistingExternalUserSharingOnly', 'ExternalUserAndGuestSharing', 'Disabled', 'ExternalUserSharingOnly')]
    [System.String] $MySiteSharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Enables the administrator to hide the Everyone claim in the People Picker.')]
    [System.Nullable[System.Boolean]] $ShowEveryoneClaim

    [DscProperty()]
    [System.ComponentModel.Description('Enables the administrator to hide the All Users claim groups in People Picker.')]
    [System.Nullable[System.Boolean]] $ShowAllUsersClaim

    [DscProperty()]
    [System.ComponentModel.Description('Enables the administrator to hide the Everyone except external users claim in the People Picker.')]
    [System.Nullable[System.Boolean]] $ShowEveryoneExceptExternalUsersClaim

    [DscProperty()]
    [System.ComponentModel.Description('Creates a Shared with Everyone folder in every user''s new OneDrive for Business document library.')]
    [System.Nullable[System.Boolean]] $ProvisionSharedWithEveryoneFolder

    [DscProperty()]
    [System.ComponentModel.Description('Accelerates guest-enabled site collections as well as member-only site collections when the SignInAccelerationDomain parameter is set.')]
    [System.Nullable[System.Boolean]] $EnableGuestSignInAcceleration

    [DscProperty()]
    [System.ComponentModel.Description('Sets the guest sharing group allow list in the tenant by principal identity.')]
    [System.String[]] $GuestSharingGroupAllowListInTenantByPrincipalIdentity

    [DscProperty()]
    [System.ComponentModel.Description('When sharing a whiteboard in a Teams meeting, Whiteboard creates a sharing link that''s accessible by anyone within the organization and automatically shares the whiteboard with any in-tenant users in the meeting. The valid values are: ExternalUserAndGuestSharing, Disabled, ExternalUserSharingOnly, ExistingExternalUserSharingOnly')]
    [ValidateSet('ExistingExternalUserSharingOnly', 'ExternalUserAndGuestSharing', 'Disabled', 'ExternalUserSharingOnly')]
    [System.String] $OneDriveLoopSharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets default share link scope for fluid on OneDrive sites. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $OneDriveLoopDefaultSharingLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets default share link role for fluid on OneDrive sites. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $OneDriveLoopDefaultSharingLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets collaboration type for fluid on core partition. The valid values are: ExternalUserAndGuestSharing, Disabled, ExternalUserSharingOnly, ExistingExternalUserSharingOnly')]
    [ValidateSet('ExistingExternalUserSharingOnly', 'ExternalUserAndGuestSharing', 'Disabled', 'ExternalUserSharingOnly')]
    [System.String] $CoreLoopSharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets default share link scope for fluid on SharePoint sites. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $CoreLoopDefaultSharingLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets default share link role for fluid on SharePoint sites. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $CoreLoopDefaultSharingLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets default share link to existing access on core partition.')]
    [System.Nullable[System.Boolean]] $CoreDefaultLinkToExistingAccess

    [DscProperty()]
    [System.ComponentModel.Description('Sets the default sharing link scope for OneDrive. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $OneDriveDefaultShareLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('Sets the default sharing link role for OneDrive. It replaces the DefaultSharingLinkType. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $OneDriveDefaultShareLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('Sets whether OneDrive default links should grant access to existing users. It replaces the DefaultLinkPermission.')]
    [System.Nullable[System.Boolean]] $OneDriveDefaultLinkToExistingAccess

    [DscProperty()]
    [System.ComponentModel.Description('Sets a value to handle the tenant who can share settings.')]
    [System.String[]] $WhoCanShareAllowListInTenant

    [DscProperty()]
    [System.ComponentModel.Description('Principal identities allowed to share content at the tenant level.')]
    [System.String[]] $WhoCanShareAllowListInTenantByPrincipalIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum number of days before organization sharing links expire for all OneDrive sites. This is a tenant wide setting, and all geos will inherit the policy. The value can be from 7 to 720 days. To remove the expiration requirement, set the value to zero (0).')]
    [ValidateRange(0, 720)]
    [System.Nullable[System.Int32]] $OneDriveOrganizationSharingLinkMaxExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the recommended number of days before organization sharing links expire for all OneDrive sites. This setting provides a suggested expiration period to users when they create sharing links. This is a tenant wide setting, and all geos will inherit the policy. The value can be from 7 to 720 days and must be less than or equal to the maximum expiration value set by `OneDriveOrganizationSharingLinkMaxExpirationInDays`. When set to 0, the default value will be `OneDriveOrganizationSharingLinkMaxExpirationInDays`.')]
    [ValidateRange(0, 720)]
    [System.Nullable[System.Int32]] $OneDriveOrganizationSharingLinkRecommendedExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Sets the list of agentic identities that are restricted from sharing content to external users. Pass the full set of GUIDs that should remain restricted, or `@()` to clear the list.')]
    [System.String[]] $RestrictExternalSharing

    [DscProperty()]
    [System.ComponentModel.Description('When the feature is enabled, all external sharing invitations that are sent will blind copy the e-mail messages listed in the BccExternalSharingsInvitationList.')]
    [System.Nullable[System.Boolean]] $BccExternalSharingInvitations

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of e-mail addresses to be BCC''d when the BCC for External Sharing feature is enabled.Multiple addresses can be specified by creating a comma separated list with no spaces.')]
    [System.String] $BccExternalSharingInvitationsList

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the maximum number of days that organization sharing links can remain active before they expire for all SharePoint sites (not including OneDrive sites). This is a tenant wide setting, and all geos will inherit the policy. The valid values : - can be from 7 to 730 days. - 0 (default) - No maximum expiration limit is enforced.')]
    [System.Nullable[System.Int32]] $CoreOrganizationSharingLinkMaxExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the recommended number of days before organization sharing links expire in SharePoint sites (not including OneDrive sites). Users can still choose a different expiration period if permitted by policy, but this value is presented as the recommended default. This is a tenant wide setting, and all geos will inherit the policy. The valid values : - Can be from 7 to 730 days and must be less than or equal to the maximum expiration value set by CoreOrganizationSharingLinkMaxExpirationInDays. - When set to 0 (default), the default value will be CoreOrganizationSharingLinkMaxExpirationInDays.')]
    [System.Nullable[System.Int32]] $CoreOrganizationSharingLinkRecommendedExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('This parameter controls whether external sharing is restricted for agents. The valid values are: - False (default) - Agents can share content externally according to existing sharing policies. - True - External sharing for agents is restricted.')]
    [System.Nullable[System.Boolean]] $RestrictExternalSharingForAgents

    [DscProperty()]
    [System.ComponentModel.Description('Specifies all anonymous links that have been created (or will be created) will expire after the set number of days.')]
    [System.Nullable[System.Int32]] $RequireAnonymousLinksExpireInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of email domains that is allowed for sharing with the external collaborators. Entry values as an array of domains.')]
    [System.String[]] $SharingAllowedDomainList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of email domains that is blocked or prohibited for sharing with the external collaborators. Entry values as an array of domains.')]
    [System.String[]] $SharingBlockedDomainList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the external sharing mode for domains.')]
    [ValidateSet('None', 'AllowList', 'BlockList')]
    [System.String] $SharingDomainRestrictionMode

    [DscProperty()]
    [System.ComponentModel.Description('Lets administrators choose what type of link appears is selected in the ''Get a link'' sharing dialog box in OneDrive for Business and SharePoint Online')]
    [ValidateSet('None', 'Direct', 'Internal', 'AnonymousAccess')]
    [System.String] $DefaultSharingLinkType

    [DscProperty()]
    [System.ComponentModel.Description('Allow or deny external users re-sharing')]
    [System.Nullable[System.Boolean]] $PreventExternalUsersFromResharing

    [DscProperty()]
    [System.ComponentModel.Description('Enables the administrator to hide the guest users claim in the People Picker.')]
    [System.Nullable[System.Boolean]] $ShowPeoplePickerSuggestionsForGuestUsers

    [DscProperty()]
    [System.ComponentModel.Description('Configures anonymous link types for files')]
    [ValidateSet('View', 'Edit')]
    [System.String] $FileAnonymousLinkType

    [DscProperty()]
    [System.ComponentModel.Description('Configures anonymous link types for folders')]
    [ValidateSet('View', 'Edit')]
    [System.String] $FolderAnonymousLinkType

    [DscProperty()]
    [System.ComponentModel.Description('When this parameter is set to $true and another user re-shares a document from a user''s OneDrive for Business, the OneDrive for Business owner is notified by e-mail.')]
    [System.Nullable[System.Boolean]] $NotifyOwnersWhenItemsReshared

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the link permission on the tenant level. Valid values to set are View and Edit. A value of None will be set to Edit as its the default value.')]
    [ValidateSet('None', 'View', 'Edit')]
    [System.String] $DefaultLinkPermission

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Enable Guest access to a site or Onedrive to expire after')]
    [System.Nullable[System.Boolean]] $ExternalUserExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Specifies Number of days for Guest Access links to expire.')]
    [System.Nullable[System.Int32]] $ExternalUserExpireInDays

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [SPOSharingSettings] Get()
    {
        $blockDomains = $null
        $SPOSharingSettings = $null
        $allowDomains = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSharingSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for SPO Sharing settings'

        try
        {
            if (-not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')
            }

            if ($null -eq $this.ResourceCache['SPOSharingSettings'])
            {
                $this.ResourceCache['SPOSharingSettings'] = Get-PnPTenant -ErrorAction Stop
            }
            $SPOSharingSettings = $this.ResourceCache['SPOSharingSettings']

            # Resolve the My Site Host directly at its deterministic URL
            # (https://<tenant>-my.<spo-domain>/) instead of enumerating every site
            # collection in the tenant just to read its SharingCapability.
            # Derive host from the active connection URL, which may be the
            # root URL (app/cert/managed-identity auth) or the -admin URL (credential auth)
            $MySite = $null
            $MySiteHostUrl = $null
            try
            {
                $connectionUrl = (Get-PnPConnection).Url
                if (-not [System.String]::IsNullOrEmpty($connectionUrl))
                {
                    $spoHost = ([System.Uri]$connectionUrl).Host
                    $hostParts = $spoHost.Split('.')
                    $tenantLabel = $hostParts[0] -replace '-admin$', ''
                    $domainSuffix = ($hostParts[1..($hostParts.Length - 1)]) -join '.'
                    $MySiteHostUrl = 'https://{0}-my.{1}/' -f $tenantLabel, $domainSuffix
                }
            }
            catch
            {
                $MySiteHostUrl = $null
            }

            # Track whether the direct lookup resolved the My Site Host
            $resolvedFromDirectLookup = $false
            $mySiteSharingCapabilityValue = $null
            if (-not [System.String]::IsNullOrEmpty($MySiteHostUrl))
            {
                $directSite = Get-PnPTenantSite -Identity $MySiteHostUrl -ErrorAction SilentlyContinue
                if ($null -ne $directSite -and $directSite.Template -match '^SPSMSITEHOST#')
                {
                    $mySiteSharingCapabilityValue = $directSite.SharingCapability
                    $resolvedFromDirectLookup = $true
                }
            }

            # Fallback to the original enumeration when the direct lookup didn't resolve.
            # Local filtering because server side filtering intermittently fails.
            if (-not $resolvedFromDirectLookup)
            {
                $MySite = Get-PnPTenantSite -Filter "Url -like '-my.sharepoint.'" | Where-Object -FilterScript { $_.Template -match '^SPSMSITEHOST#' }

                if ($null -ne $MySite)
                {
                    $mySiteSharingCapabilityValue = (Get-PnPTenantSite -Identity $MySite.Url).SharingCapability
                }
            }

            if ($null -ne $SPOSharingSettings.SharingAllowedDomainList)
            {
                $allowDomains = $SPOSharingSettings.SharingAllowedDomainList.Split(' ')
            }

            if ($null -ne $SPOSharingSettings.SharingBlockedDomainList)
            {
                $blockDomains = $SPOSharingSettings.SharingBlockedDomainList.Split(' ')
            }

            $defaultLinkPermissionValue = $null
            if ($SPOSharingSettings.DefaultLinkPermission -eq 'None')
            {
                $defaultLinkPermissionValue = 'Edit'
            }
            else
            {
                $defaultLinkPermissionValue = $SPOSharingSettings.DefaultLinkPermission
            }
            $results = @{
                IsSingleInstance                                           = 'Yes'
                AllowGuestUserShareToUsersNotInSiteCollection              = $SPOSharingSettings.AllowGuestUserShareToUsersNotInSiteCollection
                AllowSharingOutsideRestrictedAccessControlGroups           = $SPOSharingSettings.AllowSharingOutsideRestrictedAccessControlGroups
                CoreDefaultShareLinkRole                                   = $SPOSharingSettings.CoreDefaultShareLinkRole
                CoreDefaultShareLinkScope                                  = $SPOSharingSettings.CoreDefaultShareLinkScope
                CoreOrganizationSharingLinkMaxExpirationInDays             = $SPOSharingSettings.CoreOrganizationSharingLinkMaxExpirationInDays
                CoreOrganizationSharingLinkRecommendedExpirationInDays     = $SPOSharingSettings.CoreOrganizationSharingLinkRecommendedExpirationInDays
                SharingCapability                                          = $SPOSharingSettings.SharingCapability
                ShowEveryoneClaim                                          = $SPOSharingSettings.ShowEveryoneClaim
                ShowAllUsersClaim                                          = $SPOSharingSettings.ShowAllUsersClaim
                ShowEveryoneExceptExternalUsersClaim                       = $SPOSharingSettings.ShowEveryoneExceptExternalUsersClaim
                ProvisionSharedWithEveryoneFolder                          = $SPOSharingSettings.ProvisionSharedWithEveryoneFolder
                EnableGuestSignInAcceleration                              = $SPOSharingSettings.EnableGuestSignInAcceleration
                BccExternalSharingInvitations                              = $SPOSharingSettings.BccExternalSharingInvitations
                BccExternalSharingInvitationsList                          = $SPOSharingSettings.BccExternalSharingInvitationsList
                RequireAnonymousLinksExpireInDays                          = $SPOSharingSettings.RequireAnonymousLinksExpireInDays
                ExternalUserExpireInDays                                   = $SPOSharingSettings.ExternalUserExpireInDays
                ExternalUserExpirationRequired                             = $SPOSharingSettings.ExternalUserExpirationRequired
                # TODO: Look up the principal id
                GuestSharingGroupAllowListInTenantByPrincipalIdentity      = Get-M365DSCArrayFromProperty -PropertyValue $SPOSharingSettings.GuestSharingGroupAllowListInTenantByPrincipalIdentity -ElementType ([System.String])
                OneDriveDefaultLinkToExistingAccess                        = $SPOSharingSettings.OneDriveDefaultLinkToExistingAccess
                OneDriveDefaultShareLinkRole                               = $SPOSharingSettings.OneDriveDefaultShareLinkRole
                OneDriveDefaultShareLinkScope                              = $SPOSharingSettings.OneDriveDefaultShareLinkScope
                OneDriveLoopSharingCapability                              = $SPOSharingSettings.OneDriveLoopSharingCapability
                OneDriveLoopDefaultSharingLinkScope                        = $SPOSharingSettings.OneDriveLoopDefaultSharingLinkScope
                OneDriveLoopDefaultSharingLinkRole                         = $SPOSharingSettings.OneDriveLoopDefaultSharingLinkRole
                OneDriveOrganizationSharingLinkMaxExpirationInDays         = $SPOSharingSettings.OneDriveOrganizationSharingLinkMaxExpirationInDays
                OneDriveOrganizationSharingLinkRecommendedExpirationInDays = $SPOSharingSettings.OneDriveOrganizationSharingLinkRecommendedExpirationInDays
                CoreLoopSharingCapability                                  = $SPOSharingSettings.CoreLoopSharingCapability
                CoreLoopDefaultSharingLinkScope                            = $SPOSharingSettings.CoreLoopDefaultSharingLinkScope
                CoreLoopDefaultSharingLinkRole                             = $SPOSharingSettings.CoreLoopDefaultSharingLinkRole
                CoreDefaultLinkToExistingAccess                            = $SPOSharingSettings.CoreDefaultLinkToExistingAccess
                RestrictExternalSharing                                    = Get-M365DSCArrayFromProperty -PropertyValue $SPOSharingSettings.RestrictExternalSharing -ElementType ([System.String])
                RestrictExternalSharingForAgents                           = $SPOSharingSettings.RestrictExternalSharingForAgents
                SharingAllowedDomainList                                   = $allowDomains
                SharingBlockedDomainList                                   = $blockDomains
                SharingDomainRestrictionMode                               = $SPOSharingSettings.SharingDomainRestrictionMode
                DefaultSharingLinkType                                     = $SPOSharingSettings.DefaultSharingLinkType
                PreventExternalUsersFromResharing                          = $SPOSharingSettings.PreventExternalUsersFromResharing
                ShowPeoplePickerSuggestionsForGuestUsers                   = $SPOSharingSettings.ShowPeoplePickerSuggestionsForGuestUsers
                FileAnonymousLinkType                                      = $SPOSharingSettings.FileAnonymousLinkType
                FolderAnonymousLinkType                                    = $SPOSharingSettings.FolderAnonymousLinkType
                NotifyOwnersWhenItemsReshared                              = $SPOSharingSettings.NotifyOwnersWhenItemsReshared
                DefaultLinkPermission                                      = $defaultLinkPermissionValue
                # TODO: Look up the principal id
                WhoCanShareAllowListInTenant                               = Get-M365DSCArrayFromProperty -PropertyValue $SPOSharingSettings.WhoCanShareAllowListInTenant -ElementType ([System.String])
                WhoCanShareAllowListInTenantByPrincipalIdentity            = Get-M365DSCArrayFromProperty -PropertyValue $SPOSharingSettings.WhoCanShareAllowListInTenantByPrincipalIdentity -ElementType ([System.String])
                Credential                                                 = $this.Credential
                ApplicationId                                              = $this.ApplicationId
                TenantId                                                   = $this.TenantId
                ApplicationSecret                                          = $this.ApplicationSecret
                CertificateThumbprint                                      = $this.CertificateThumbprint
                CertificatePath                                            = $this.CertificatePath
                CertificatePassword                                        = $this.CertificatePassword
                ManagedIdentity                                            = $this.ManagedIdentity
                AccessTokens                                               = $this.AccessTokens
            }

            if (-not [System.String]::IsNullOrEmpty($mySiteSharingCapabilityValue))
            {
                $results.Add('MySiteSharingCapability', $mySiteSharingCapabilityValue)
            }
            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $SignInAccelerationDomain = $null
        $allowed = $null
        $blocked = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration for SPO Sharing settings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PnP')

        $CurrentParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $CurrentParameters.Remove('IsSingleInstance') | Out-Null

        [bool]$SetMySharingCapability = $false
        if ($null -ne $CurrentParameters['MySiteSharingCapability'])
        {
            $SetMySharingCapability = $true
        }
        $CurrentParameters.Remove('MySiteSharingCapability') | Out-Null

        if ($null -eq $SignInAccelerationDomain)
        {
            $CurrentParameters.Remove('SignInAccelerationDomain') | Out-Null
            $CurrentParameters.Remove('EnableGuestSignInAcceleration') | Out-Null #removing EnableGuestSignInAcceleration since it can only be configured with a configured SignINAccerlation domain
        }
        if ($this.SharingCapability -ne 'ExternalUserAndGuestSharing')
        {
            Write-Warning -Message 'The sharing capabilities for the tenant are not configured to be ExternalUserAndGuestSharing for that the RequireAnonymousLinksExpireInDays property cannot be configured'
            $CurrentParameters.Remove('RequireAnonymousLinksExpireInDays') | Out-Null
        }
        if ($this.ExternalUserExpireInDays -and $this.ExternalUserExpirationRequired -eq $false)
        {
            Write-Warning -Message 'ExternalUserExpirationRequired is set to be false. For that the ExternalUserExpireInDays property cannot be configured'
            $CurrentParameters.Remove('ExternalUserExpireInDays') | Out-Null
        }
        if ($this.SharingCapability -ne 'ExternalUserAndGuestSharing' -and ($null -ne $this.FileAnonymousLinkType -or $null -ne $this.FolderAnonymousLinkType))
        {
            Write-Warning -Message 'If anonymous file or folder links are set, SharingCapability must be set to ExternalUserAndGuestSharing '
            $CurrentParameters.Remove('FolderAnonymousLinkType') | Out-Null
            $CurrentParameters.Remove('FileAnonymousLinkType') | Out-Null
        }

        if ($this.SharingDomainRestrictionMode -eq 'None')
        {
            Write-Warning -Message 'SharingDomainRestrictionMode is set to None. For that SharingAllowedDomainList / SharingBlockedDomainList cannot be configured'
            $CurrentParameters.Remove('SharingAllowedDomainList') | Out-Null
            $CurrentParameters.Remove('SharingBlockedDomainList') | Out-Null
        }
        elseif ($this.SharingDomainRestrictionMode -eq 'AllowList')
        {
            Write-Verbose -Message 'SharingDomainRestrictionMode is set to AllowList. For that SharingBlockedDomainList cannot be configured'
            $CurrentParameters.Remove('SharingBlockedDomainList') | Out-Null
        }
        elseif ($this.SharingDomainRestrictionMode -eq 'BlockList')
        {
            Write-Warning -Message 'SharingDomainRestrictionMode is set to BlockList. For that SharingAllowedDomainList cannot be configured'
            $CurrentParameters.Remove('SharingAllowedDomainList') | Out-Null
        }

        if ($null -ne $CurrentParameters['SharingAllowedDomainList'])
        {
            foreach ($allowedDomain in $this.SharingAllowedDomainList)
            {
                $allowed += $allowedDomain
                $allowed += ' '
            }
            $CurrentParameters['SharingAllowedDomainList'] = $allowed.Trim()
        }

        if ($null -ne $CurrentParameters['SharingBlockedDomainList'])
        {
            foreach ($blockedDomain in $this.SharingBlockedDomainList)
            {
                $blocked += $blockedDomain
                $blocked += ' '
            }
            $CurrentParameters['SharingBlockedDomainList'] = $blocked.Trim()
        }

        foreach ($listParameter in @('WhoCanShareAllowListInTenant', 'WhoCanShareAllowListInTenantByPrincipalIdentity'))
        {
            if ($null -ne $CurrentParameters[$listParameter])
            {
                $CurrentParameters[$listParameter] = [System.String]::Join(',', $CurrentParameters[$listParameter])
            }
        }

        if ($this.DefaultLinkPermission -eq 'None')
        {
            Write-Verbose -Message 'Valid values to set are View and Edit. A value of None will be set to Edit as its the default value.'
            $CurrentParameters['DefaultLinkPermission'] = 'Edit'
        }

        Set-PnPTenant @CurrentParameters -Force | Out-Null
        if ($SetMySharingCapability)
        {
            $mysite = Get-PnPTenantSite -Filter "Url -like '-my.sharepoint.'" | Where-Object -FilterScript { $_.Template -notmatch '^RedirectSite#' }
            Set-PnPTenantSite -Identity $mysite.Url -SharingCapability $this.MySiteSharingCapability
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        try
        {
            $ConnectionMode = $this.Connect('PNP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $this.ResourceCache['ExportMode'] = $true
            $dscContent = [System.Text.StringBuilder]::new()
            $Params = @{
                IsSingleInstance      = 'Yes'
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                Credential            = $this.Credential
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            if (-1 -eq $Results.RequireAnonymousLinksExpireInDays)
            {
                $Results.Remove('RequireAnonymousLinksExpireInDays') | Out-Null
            }
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.DefaultLinkPermission -eq 'None')
                {
                    Write-Verbose -Message 'Valid values to set are View and Edit. A value of None will be set to Edit as its the default value.'
                    $DesiredValues.DefaultLinkPermission = 'Edit'
                    $ValuesToCheck.DefaultLinkPermission = 'Edit'
                }

                if ([System.String]::IsNullOrEmpty($DesiredValues.SignInAccelerationDomain))
                {
                    $DesiredValues.Remove('SignInAccelerationDomain') | Out-Null
                    $ValuesToCheck.Remove('SignInAccelerationDomain') | Out-Null
                    $DesiredValues.Remove('EnableGuestSignInAcceleration') | Out-Null #removing EnableGuestSignInAcceleration since it can only be configured with a configured SignINAccerlation domain
                    $ValuesToCheck.Remove('EnableGuestSignInAcceleration') | Out-Null
                }

                if ($DesiredValues.SharingCapability -ne 'ExternalUserAndGuestSharing')
                {
                    Write-Warning -Message 'The sharing capabilities for the tenant are not configured to be ExternalUserAndGuestSharing for that the RequireAnonymousLinksExpireInDays property cannot be configured'
                    $DesiredValues.Remove('RequireAnonymousLinksExpireInDays') | Out-Null
                    $ValuesToCheck.Remove('RequireAnonymousLinksExpireInDays') | Out-Null
                }

                if ($DesiredValues.ExternalUserExpireInDays -and $DesiredValues.ExternalUserExpirationRequired -eq $false)
                {
                    Write-Warning -Message 'ExternalUserExpirationRequired is set to be false. For that the ExternalUserExpireInDays property cannot be configured'
                    $DesiredValues.Remove('ExternalUserExpireInDays') | Out-Null
                    $ValuesToCheck.Remove('ExternalUserExpireInDays') | Out-Null
                }

                if ($DesiredValues.SharingCapability -ne 'ExternalUserAndGuestSharing' -and ($null -ne $DesiredValues.FileAnonymousLinkType -or $null -ne $DesiredValues.FolderAnonymousLinkType))
                {
                    Write-Warning -Message 'If anonymous file or folder links are set, SharingCapability must be set to ExternalUserAndGuestSharing '
                    $DesiredValues.Remove('FolderAnonymousLinkType') | Out-Null
                    $ValuesToCheck.Remove('FolderAnonymousLinkType') | Out-Null
                    $DesiredValues.Remove('FileAnonymousLinkType') | Out-Null
                    $ValuesToCheck.Remove('FileAnonymousLinkType') | Out-Null
                }

                if ($DesiredValues.SharingDomainRestrictionMode -eq 'None')
                {
                    Write-Warning -Message 'SharingDomainRestrictionMode is set to None. For that SharingAllowedDomainList / SharingBlockedDomainList cannot be configured'
                    $DesiredValues.Remove('SharingAllowedDomainList') | Out-Null
                    $ValuesToCheck.Remove('SharingAllowedDomainList') | Out-Null
                    $DesiredValues.Remove('SharingBlockedDomainList') | Out-Null
                    $ValuesToCheck.Remove('SharingBlockedDomainList') | Out-Null
                }
                elseif ($DesiredValues.SharingDomainRestrictionMode -eq 'AllowList')
                {
                    Write-Verbose -Message 'SharingDomainRestrictionMode is set to AllowList. For that SharingBlockedDomainList cannot be configured'
                    $DesiredValues.Remove('SharingBlockedDomainList') | Out-Null
                    $ValuesToCheck.Remove('SharingBlockedDomainList') | Out-Null
                }
                elseif ($DesiredValues.SharingDomainRestrictionMode -eq 'BlockList')
                {
                    Write-Warning -Message 'SharingDomainRestrictionMode is set to BlockList. For that SharingAllowedDomainList cannot be configured'
                    $DesiredValues.Remove('SharingAllowedDomainList') | Out-Null
                    $ValuesToCheck.Remove('SharingAllowedDomainList') | Out-Null
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [SPOSharingSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSharingSettings])
        {
            return $Values
        }

        $result = [SPOSharingSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
