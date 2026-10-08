using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SPOSite : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The URL of the site collection.')]
    [System.String] $Url

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The title of the site collection.')]
    [System.String] $Title

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies the owner of the site.')]
    [System.String] $Owner

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TimeZone ID of the site collection.')]
    [System.Nullable[System.UInt32]] $TimeZoneId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies with template of site to create.')]
    [System.String] $Template

    [DscProperty()]
    [System.ComponentModel.Description('The URL of the Hub site the site collection needs to get connected to.')]
    [System.String] $HubUrl

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables file-level archiving for the site. This setting only takes effect when the tenant-level `AllowFileArchive` setting is enabled. If the tenant-level setting is disabled, users will not be able to archive files on the site even when this parameter is set to `$true`.')]
    [System.Nullable[System.Boolean]] $AllowFileArchive

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables adding and updating web property bag values when the DenyAddAndCustomizePages is enabled.')]
    [System.Nullable[System.Boolean]] $AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('To set the default share link role. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $DefaultShareLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('To set the default sharing link scope. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $DefaultShareLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('Resets the site version policy to inherit the default version policy from the tenant.')]
    [System.Nullable[System.Boolean]] $InheritVersionPolicyFromTenant

    [DscProperty()]
    [System.ComponentModel.Description('To set the loop default sharing link role. Valid values are: None, View, Edit, Review, RestrictedView.')]
    [ValidateSet('None', 'View', 'Edit', 'Review', 'RestrictedView')]
    [System.String] $LoopDefaultSharingLinkRole

    [DscProperty()]
    [System.ComponentModel.Description('To set the loop default sharing link scope. The valid values are: Anyone, Organization, SpecificPeople, Uninitialized')]
    [ValidateSet('Anyone', 'Organization', 'SpecificPeople', 'Uninitialized')]
    [System.String] $LoopDefaultSharingLinkScope

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the maximum number of days that organization sharing links can remain active before they expire for the SharePoint site. The valid values : - can be from 7 to 730 days. - 0 (default) - No maximum expiration limit is enforced.')]
    [System.Nullable[System.Int32]] $OrganizationSharingLinkMaxExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('This parameter specifies the recommended number of days before organization sharing links expire in the SharePoint site. Users can still choose a different expiration period if permitted by policy, but this value is presented as the recommended default. The valid values : - Can be from 7 to 730 days and must be less than or equal to the maximum expiration value set by OrganizationSharingLinkMaxExpirationInDays. - When set to 0 (default), the default value will be OrganizationSharingLinkMaxExpirationInDays.')]
    [System.Nullable[System.Int32]] $OrganizationSharingLinkRecommendedExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to override the sharing capability for the site.')]
    [System.Nullable[System.Boolean]] $OverrideSharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Allows to set organization sharing link expiration policy for this SharePoint site, which will override the tenant-level policy when set to true. When this is set to true, you can configure the organization sharing link expiration policy for this site collection using the OrganizationSharingLinkRecommendedExpirationInDays and OrganizationSharingLinkMaxExpirationInDays parameters.')]
    [System.Nullable[System.Boolean]] $OverrideTenantOrganizationSharingLinkExpirationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the Request Files link on the site.')]
    [System.Nullable[System.Boolean]] $RequestFilesLinkEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allows hiding of the presence indicators of users simultaneously editing files.')]
    [System.Nullable[System.Boolean]] $HidePeoplePreviewingFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allows hiding of the presence indicators of users simultaneously working in lists.')]
    [System.Nullable[System.Boolean]] $HidePeopleWhoHaveListsOpen

    [DscProperty()]
    [System.ComponentModel.Description('Disables Microsoft Flow for this site.')]
    [System.Nullable[System.Boolean]] $DisableFlows

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what the sharing capabilities are for the site. Possible values: Disabled, ExternalUserSharingOnly, ExternalUserAndGuestSharing, ExistingExternalUserSharingOnly.')]
    [ValidateSet('Disabled', 'ExistingExternalUserSharingOnly', 'ExternalUserSharingOnly', 'ExternalUserAndGuestSharing')]
    [System.String] $SharingCapability

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the storage quota for this site collection in megabytes. This value must not exceed the company''s available quota.')]
    [System.Nullable[System.UInt32]] $StorageMaximumLevel

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the warning level for the storage quota in megabytes. This value must not exceed the values set for the StorageMaximumLevel parameter.')]
    [System.Nullable[System.UInt32]] $StorageWarningLevel

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if the site administrator can upgrade the site collection.')]
    [System.Nullable[System.Boolean]] $AllowSelfServiceUpgrade

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if comments on site pages are enabled or disabled.')]
    [System.Nullable[System.Boolean]] $CommentsOnSitePagesDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the default link permission for the site collection. None - Respect the organization default link permission. View - Sets the default link permission for the site to ''view'' permissions. Edit - Sets the default link permission for the site to ''edit'' permissions.')]
    [ValidateSet('None', 'View', 'Edit')]
    [System.String] $DefaultLinkPermission

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the default link type for the site collection. None - Respect the organization default sharing link type. AnonymousAccess - Sets the default sharing link for this site to an Anonymous Access or Anyone link. Internal - Sets the default sharing link for this site to the ''organization'' link or company shareable link. Direct - Sets the default sharing link for this site to the ''Specific people'' link.')]
    [ValidateSet('None', 'AnonymousAccess', 'Internal', 'Direct')]
    [System.String] $DefaultSharingLinkType

    [DscProperty()]
    [System.ComponentModel.Description('Disables App Views.')]
    [ValidateSet('Unknown', 'Disabled', 'NotDisabled')]
    [System.String] $DisableAppViews

    [DscProperty()]
    [System.ComponentModel.Description('Disables Company wide sharing links.')]
    [ValidateSet('Unknown', 'Disabled', 'NotDisabled')]
    [System.String] $DisableCompanyWideSharingLinks

    [DscProperty()]
    [System.ComponentModel.Description('Set a property on a site collection to make all lists always load with the site elements intact.')]
    [System.Nullable[System.Boolean]] $ListsShowHeaderAndNavigation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the language of the new site collection. Defaults to the current language of the web connected to.')]
    [System.Nullable[System.UInt32]] $LocaleId

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the Add And Customize Pages right is denied on the site collection. For more information about permission levels, see User permissions and permission levels in SharePoint.')]
    [System.Nullable[System.Boolean]] $DenyAddAndCustomizePages

    [DscProperty()]
    [System.ComponentModel.Description('To apply restricted access control to a group-connected or Teams-connected site.')]
    [System.Nullable[System.Boolean]] $RestrictedAccessControl

    [DscProperty()]
    [System.ComponentModel.Description('To edit a restricted access control group for a non-group site')]
    [System.String[]] $RestrictedAccessControlGroups

    [DscProperty()]
    [System.ComponentModel.Description('Defines geo-restriction settings for this site')]
    [ValidateSet('NoRestriction', 'BlockMoveOnly', 'BlockFull', 'Unknown')]
    [System.String] $RestrictedToRegion

    [DscProperty()]
    [System.ComponentModel.Description('To set the site as read-only for unmanaged devices.')]
    [System.Nullable[System.Boolean]] $ReadOnlyForUnmanagedDevices

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of days before a Request Files link expires for the site. The value can be from 0 to 730 days.')]
    [ValidateRange(0, 730)]
    [System.Nullable[System.Int32]] $RequestFilesLinkExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('To restrict content from being searchable organization-wide and Copilot.')]
    [System.Nullable[System.Boolean]] $RestrictContentOrgWideSearch

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of email domains that is allowed for sharing with the external collaborators. Use the space character as the delimiter.')]
    [System.String] $SharingAllowedDomainList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of email domains that is blocked for sharing with the external collaborators.')]
    [System.String] $SharingBlockedDomainList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the external sharing mode for domains.')]
    [ValidateSet('None', 'AllowList', 'BlockList')]
    [System.String] $SharingDomainRestrictionMode

    [DscProperty()]
    [System.ComponentModel.Description('To enable the option to search for existing guest users at Site Collection Level, set this parameter to $true.')]
    [System.Nullable[System.Boolean]] $ShowPeoplePickerSuggestionsForGuestUsers

    [DscProperty()]
    [System.ComponentModel.Description('Specifies that all anonymous/anyone links that have been created (or will be created) will expire after the set number of days. Only applies if OverrideTenantAnonymousLinkExpirationPolicy is set to true. To remove the expiration requirement, set the value to zero (0)')]
    [System.Nullable[System.UInt32]] $AnonymousLinkExpirationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Disables or enables the Social Bar for Site Collection.')]
    [System.Nullable[System.Boolean]] $SocialBarOnSitePagesDisabled

    [DscProperty()]
    [System.ComponentModel.Description('False - Respect the organization-level policy for anonymous or anyone link expiration. True - Override the organization-level policy for anonymous or anyone link expiration (can be more or less restrictive)')]
    [System.Nullable[System.Boolean]] $OverrideTenantAnonymousLinkExpirationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the site collection exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [SPOSite] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SPOSite]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for site collection $($this.Url)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Url -ne $this.Url)
            {
                $null = $this.Connect('PnP')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                Write-Verbose -Message "Getting site collection $($this.Url)"

                $site = Get-PnPTenantSite -Identity $this.Url -ErrorAction 'SilentlyContinue'
                if ($null -eq $site)
                {
                    Write-Verbose -Message "The specified Site Collection {$($this.Url)} doesn't exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $site = $this.ExportedInstance
            }

            if ($null -eq $this.ResourceCache['PnPWeb'])
            {
                $this.ResourceCache['PnPWeb'] = Get-PnPWeb -Includes RegionalSettings.TimeZone
            }

            $CurrentHubUrl = $null
            if ($null -ne $site.HubSiteId -and $site.HubSiteId -ne '00000000-0000-0000-0000-000000000000')
            {
                $hubId = $site.HubSiteId
                Write-Verbose -Message "Site {$($this.Url)} is associated with HubSite {$hubId}"
                if ($null -eq $this.ResourceCache['PnPHubSites'])
                {
                    $this.ResourceCache['PnPHubSites'] = Get-PnPHubSite
                }
                $hubSite = $this.ResourceCache['PnPHubSites'] | Where-Object -FilterScript { $_.ID -eq $hubId }

                if ($null -ne $hubSite)
                {
                    $CurrentHubUrl = $hubSite.SiteUrl
                    Write-Verbose -Message "Found {$($this.Url)} hub association with {$CurrentHubUrl}"
                }
                else
                {
                    Write-Warning "The site {$($this.Url)} is associated with Hub Site {$hubId} which no longer exists."
                }
            }

            $DisableFlowValue = $true
            if ($site.DisableFlows -eq 'NotDisabled')
            {
                $DisableFlowValue = $false
            }

            $DenyAddAndCustomizePagesValue = $site.DenyAddAndCustomizePages -eq 'Enabled'

            $RequestFilesLinkExpirationInDaysValue = $site.RequestFilesLinkExpirationInDays
            if ($RequestFilesLinkExpirationInDaysValue -eq -1)
            {
                $RequestFilesLinkExpirationInDaysValue = $null
            }

            $siteOwnerEmail = $site.OwnerEmail
            if ($null -eq $siteOwnerEmail)
            {
                $siteOwnerEmail = $site.Owner
            }

            return $this.AsResult(@{
                Url                                                            = $this.Url
                Title                                                          = $site.Title
                Template                                                       = $site.Template
                TimeZoneId                                                     = $this.ResourceCache['PnPWeb'].RegionalSettings.TimeZone.Id
                HubUrl                                                         = $CurrentHubUrl
                Classification                                                 = $site.Classification
                DisableFlows                                                   = $DisableFlowValue
                SharingCapability                                              = $site.SharingCapability
                StorageMaximumLevel                                            = $site.StorageQuota
                StorageWarningLevel                                            = $site.StorageQuotaWarningLevel
                AllowFileArchive                                               = $site.AllowFileArchive
                AllowSelfServiceUpgrade                                        = $site.AllowSelfServiceUpgrade
                AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled = $site.AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled
                Owner                                                          = $siteOwnerEmail
                CommentsOnSitePagesDisabled                                    = $site.CommentsOnSitePagesDisabled
                DefaultLinkPermission                                          = $site.DefaultLinkPermission
                DefaultShareLinkRole                                           = $site.DefaultShareLinkRole
                DefaultShareLinkScope                                          = $site.DefaultShareLinkScope
                DefaultSharingLinkType                                         = $site.DefaultSharingLinkType
                DisableAppViews                                                = $site.DisableAppViews
                DisableCompanyWideSharingLinks                                 = $site.DisableCompanyWideSharingLinks
                HidePeoplePreviewingFiles                                      = $site.HidePeoplePreviewingFiles
                HidePeopleWhoHaveListsOpen                                     = $site.HidePeopleWhoHaveListsOpen
                InheritVersionPolicyFromTenant                                 = $site.InheritVersionPolicyFromTenant
                ListsShowHeaderAndNavigation                                   = $site.ListsShowHeaderAndNavigation
                LoopDefaultSharingLinkRole                                     = $site.LoopDefaultSharingLinkRole
                LoopDefaultSharingLinkScope                                    = $site.LoopDefaultSharingLinkScope
                LocaleId                                                       = $site.LocaleId
                RestrictedToRegion                                             = $site.RestrictedToGeo
                SocialBarOnSitePagesDisabled                                   = $site.SocialBarOnSitePagesDisabled
                DenyAddAndCustomizePages                                       = $DenyAddAndCustomizePagesValue
                OrganizationSharingLinkMaxExpirationInDays                     = $site.OrganizationSharingLinkMaxExpirationInDays
                OrganizationSharingLinkRecommendedExpirationInDays             = $site.OrganizationSharingLinkRecommendedExpirationInDays
                OverrideSharingCapability                                      = $site.OverrideSharingCapability
                OverrideTenantOrganizationSharingLinkExpirationPolicy          = $site.OverrideTenantOrganizationSharingLinkExpirationPolicy
                ReadOnlyForUnmanagedDevices                                    = $site.ReadOnlyForUnmanagedDevices
                RequestFilesLinkEnabled                                        = $site.RequestFilesLinkEnabled
                RequestFilesLinkExpirationInDays                               = $RequestFilesLinkExpirationInDaysValue
                RestrictContentOrgWideSearch                                   = $site.RestrictContentOrgWideSearch
                RestrictedAccessControl                                        = $site.RestrictedAccessControl
                # TODO: Resolve Groups
                RestrictedAccessControlGroups                                  = Get-M365DSCArrayFromProperty -PropertyValue $site.RestrictedAccessControlGroups -ElementType ([System.String])
                SharingAllowedDomainList                                       = $site.SharingAllowedDomainList
                SharingBlockedDomainList                                       = $site.SharingBlockedDomainList
                SharingDomainRestrictionMode                                   = $site.SharingDomainRestrictionMode
                ShowPeoplePickerSuggestionsForGuestUsers                       = $site.ShowPeoplePickerSuggestionsForGuestUsers
                AnonymousLinkExpirationInDays                                  = $site.AnonymousLinkExpirationInDays
                OverrideTenantAnonymousLinkExpirationPolicy                    = $site.OverrideTenantAnonymousLinkExpirationPolicy
                Ensure                                                         = 'Present'
                Credential                                                     = $this.Credential
                ApplicationId                                                  = $this.ApplicationId
                TenantId                                                       = $this.TenantId
                ApplicationSecret                                              = $this.ApplicationSecret
                CertificateThumbprint                                          = $this.CertificateThumbprint
                CertificatePath                                                = $this.CertificatePath
                CertificatePassword                                            = $this.CertificatePassword
                ManagedIdentity                                                = $this.ManagedIdentity
                AccessTokens                                                   = $this.AccessTokens
            })
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $deny = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for site collection $($this.Url)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Site {$($this.Url)} doesn't exist. Creating it."

            $CreationParams = @{
                Title    = $this.Title
                Url      = $this.Url
                Template = $this.Template
                Owner    = $this.Owner
                Lcid     = $this.LocaleID
                TimeZone = $this.TimeZoneID
            }

            $supportedLanguages = (Get-PnPAvailableLanguage).Lcid
            if ($supportedLanguages -notcontains $CreationParams.Lcid)
            {
                Write-Verbose -Message ("Specified LocaleId {$($CreationParams.Lcid)} " + `
                        'is not supported. Creating the site collection in English {1033}')
                $CreationParams.Lcid = 1033
            }

            try
            {
                New-PnPTenantSite @CreationParams -ErrorAction Stop | Out-Null

                $site = $null
                $circuitBreaker = 0
                do
                {
                    Write-Verbose -Message 'Waiting for another 15 seconds for site to be ready.'
                    Start-Sleep -Seconds 15
                    try
                    {
                        $site = Get-PnPTenantSite -Identity $this.Url -ErrorAction Stop
                    }
                    catch
                    {
                        $site = @{Status = 'Creating' }
                    }
                    $circuitBreaker++
                } while ($site.Status -eq 'Creating' -and $circuitBreaker -lt 20)

                Write-Verbose -Message "Site {$($this.url)} has been successfully created and is {$($site.Status)}."
            }
            catch
            {
                $Message = "Creation of the site $($this.Url) failed: $($_.Exception.Message)"
                $this.LogError($_, $Message)

                throw $Message
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing site {$($this.Url)}"
            try
            {
                Remove-PnPTenantSite -Url $this.Url -SkipRecycleBin -Force
            }
            catch
            {
                if ($Error[0].Exception.Message -eq 'File Not Found')
                {
                    $Message = "The site $($this.Url) does not exist."
                    $this.LogError($_, $Message)
                    throw $Message
                }
                if ($Error[0].Exception.Message -eq 'This site belongs to a Microsoft 365 group. To delete the site, you must delete the group.')
                {
                    $Message = "This site $($this.Url) belongs to a Microsoft 365 group. To delete the site, you must delete the group."
                    $this.LogError($_, $Message)
                    throw $Message
                }
            }
        }
        if ($this.Ensure -ne 'Absent')
        {
            Write-Verbose -Message "Site {$($this.Url)} already exists, updating its settings"

            $DisableFlowsValue = 'NotDisabled'
            if ($this.DisableFlows)
            {
                $DisableFlowsValue = 'Disabled'
            }
            #region Ad-Hoc properties
            if (-not [System.String]::IsNullOrEmpty($this.DenyAddAndCustomizePages))
            {
                if ($this.DenyAddAndCustomizePages)
                {
                    $deny = $True
                }
                else
                {
                    $deny = $False
                }
            }
            $UpdateParams = @{
                Url                                         = $this.Url
                AllowFileArchive                            = $this.AllowFileArchive
                AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled = $this.AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled
                DisableFlows                                = $DisableFlowsValue
                InheritVersionPolicyFromTenant              = $this.InheritVersionPolicyFromTenant
                OrganizationSharingLinkMaxExpirationInDays  = $this.OrganizationSharingLinkMaxExpirationInDays
                OrganizationSharingLinkRecommendedExpirationInDays = $this.OrganizationSharingLinkRecommendedExpirationInDays
                OverrideSharingCapability                   = $this.OverrideSharingCapability
                OverrideTenantOrganizationSharingLinkExpirationPolicy = $this.OverrideTenantOrganizationSharingLinkExpirationPolicy
                ReadOnlyForUnmanagedDevices                 = $this.ReadOnlyForUnmanagedDevices
                RestrictContentOrgWideSearch                = $this.RestrictContentOrgWideSearch
                RestrictedAccessControl                     = $this.RestrictedAccessControl
                SharingCapability                           = $this.SharingCapability
                StorageMaximumLevel                         = $this.StorageMaximumLevel
                StorageWarningLevel                         = $this.StorageWarningLevel
                # Cannot be set, throws an error about Object not being in a valid state;
                #AllowSelfServiceUpgrade        = $AllowSelfServiceUpgrade
                Owners                                      = $this.Owner
                CommentsOnSitePagesDisabled                 = $this.CommentsOnSitePagesDisabled
                DefaultLinkPermission                       = $this.DefaultLinkPermission
                DefaultShareLinkRole                        = $this.DefaultShareLinkRole
                DefaultShareLinkScope                       = $this.DefaultShareLinkScope
                DefaultSharingLinkType                      = $this.DefaultSharingLinkType
                DisableAppViews                             = $this.DisableAppViews
                DisableCompanyWideSharingLinks              = $this.DisableCompanyWideSharingLinks
                ListsShowHeaderAndNavigation                = $this.ListsShowHeaderAndNavigation
                LoopDefaultSharingLinkRole                  = $this.LoopDefaultSharingLinkRole
                LoopDefaultSharingLinkScope                 = $this.LoopDefaultSharingLinkScope
                RequestFilesLinkEnabled                     = $this.RequestFilesLinkEnabled
                RequestFilesLinkExpirationInDays            = $this.RequestFilesLinkExpirationInDays
                #LCID Cannot be set after a Template has been applied;
                #LocaleId                       = $LocaleId
                RestrictedToGeo                             = $this.RestrictedToRegion
                #SocialBarOnSitePagesDisabled                = $SocialBarOnSitePagesDisabled
                SharingAllowedDomainList                    = $this.SharingAllowedDomainList
                SharingBlockedDomainList                    = $this.SharingBlockedDomainList
                SharingDomainRestrictionMode                = $this.SharingDomainRestrictionMode
                AnonymousLinkExpirationInDays               = $this.AnonymousLinkExpirationInDays
                OverrideTenantAnonymousLinkExpirationPolicy = $this.OverrideTenantAnonymousLinkExpirationPolicy
                DenyAddAndCustomizePages                    = $deny
                Title                                       = $this.Title
            }
            $UpdateParams = Remove-NullEntriesFromHashtable -Hash $UpdateParams

            if ($this.GetBoundParameters().ContainsKey('RestrictedAccessControlGroups'))
            {
                $diff = Compare-Object -ReferenceObject @($this.RestrictedAccessControlGroups) -DifferenceObject @($CurrentValues.RestrictedAccessControlGroups)
                $groupsToAdd = @()
                $groupsToRemove = @()
                foreach ($delta in $diff)
                {
                    if ($delta.SideIndicator -eq "<=")
                    {
                        $groupsToAdd += $delta.InputObject
                    }
                    elseif ($delta.SideIndicator -eq "=>")
                    {
                        $groupsToRemove += $delta.InputObject
                    }
                }

                if ($groupsToRemove.Count -gt 0)
                {
                    $UpdateParams.Add('RemoveRestrictedAccessControlGroups', $groupsToRemove)
                }
                if ($groupsToAdd.Count -gt 0)
                {
                    $UpdateParams.Add('AddRestrictedAccessControlGroups', $groupsToAdd)
                }
            }

            $UpdateParams.Add('StorageQuota', $this.StorageMaximumLevel)
            $UpdateParams.Remove('StorageMaximumLevel') | Out-Null
            $UpdateParams.Add('StorageQuotaWarningLevel', $this.StorageWarningLevel)
            $UpdateParams.Remove('StorageWarningLevel') | Out-Null
            $UpdateParams.Add('Identity', $this.Url)
            $UpdateParams.Remove('Url') | Out-Null

            Set-PnPTenantSite @UpdateParams -ErrorAction Stop

            $UpdateParams = @{
                HidePeoplePreviewingFiles    = $this.HidePeoplePreviewingFiles
                HidePeopleWhoHaveListsOpen   = $this.HidePeopleWhoHaveListsOpen
                SocialBarOnSitePagesDisabled = $this.SocialBarOnSitePagesDisabled
            }
            $UpdateParams = Remove-NullEntriesFromHashtable -Hash $UpdateParams

            if ($UpdateParams)
            {
                $null = $this.Connect('PnP', $this.Url)
                Write-Verbose -Message "Updating props via Set-PNPSite on $($this.Url) with parameters:`r`n$(Convert-M365DscHashtableToString -Hashtable $UpdateParams)"
                Set-PnPSite @UpdateParams -ErrorAction Stop
            }

            $site = Get-PnPTenantSite $this.Url

            if (-not [System.String]::IsNullOrEmpty($this.LocaleId) -and `
                    $this.GetBoundParameters().LocaleId -ne $site.Lcid)
            {
                Write-Verbose -Message "Updating LocaleId of RootWeb to $($this.GetBoundParameters().LocaleId)"
                $null = $this.Connect('PnP', $this.Url)

                $web = Get-PnPWeb
                $ctx = Get-PnPContext
                $ctx.Load($web.RegionalSettings)
                $ctx.ExecuteQuery()
                $web.RegionalSettings.LocaleId = $this.GetBoundParameters().LocaleId
                $web.Update()
                $ctx.ExecuteQuery()
            }

            Write-Verbose -Message 'Settings Updated'
            if ($this.GetBoundParameters().ContainsKey('HubUrl'))
            {
                if ($this.GetBoundParameters().HubUrl.TrimEnd('/') -ne $this.GetBoundParameters().Url.TrimEnd('/'))
                {
                    if ([System.String]::IsNullOrEmpty($this.HubUrl))
                    {
                        if ($site.HubSiteId -ne '00000000-0000-0000-0000-000000000000')
                        {
                            Write-Verbose -Message "Removing Hub Site Association for {$($this.Url)}"
                            Remove-PnPHubSiteAssociation -Site $this.Url
                        }
                    }
                    else
                    {
                        $hubSite = Get-PnPHubSite -Identity $this.HubUrl

                        if ($null -eq $hubSite)
                        {
                            throw ("Specified HubUrl ($($this.HubUrl)) is not a Hub site. Make sure you " + `
                                    'have promoted that to a Hub site first.')
                        }

                        if ($site.HubSiteId -ne $hubSite.Id)
                        {
                            Write-Verbose -Message "Adding Hub Association on {$($this.HubUrl)} for site {$($this.Url)}"
                            Add-PnPHubSiteAssociation -Site $this.Url -HubSite $this.HubUrl
                        }
                    }
                }
                else
                {
                    Write-Verbose -Message ('Ignoring the HubUrl parameter because it is equal to ' + `
                            'the site collection Url')
                }
            }
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
            $ConnectionMode = $this.Connect('PnP')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Export')
            #endregion

            $sites = Get-PnPTenantSite -ErrorAction Stop | Where-Object -FilterScript { $_.Template -ne 'SRCHCEN#0' -and $_.Template -ne 'SPSMSITEHOST#0' }
            $organization = ''
            $principal = '' # Principal represents the "NetBios" name of the tenant (e.g. the M365DSC part of M365DSC.onmicrosoft.com)
            if ($null -ne $this.Credential -and $this.Credential.UserName.Contains('@'))
            {
                $organization = $this.Credential.UserName.Split('@')[1]

                if ($organization.IndexOf('.') -gt 0)
                {
                    $principal = $organization.Split('.')[0]
                }
            }
            else
            {
                $organization = $this.TenantId
                $principal = $organization.Split('.')[0]
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($site in $sites)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    [$i/$($sites.Length)] $($site.Url)" -DeferWrite
                try
                {
                    $site = Get-PnPTenantSite -Identity $site.Url -ErrorAction Stop
                    $siteTitle = 'Null'
                    if (-not [System.String]::IsNullOrEmpty($site.Title))
                    {
                        $siteTitle = $site.Title
                    }

                    $Params = @{
                        Url                   = $site.Url
                        Template              = $site.Template
                        Owner                 = 'admin@contoso.com' # Passing in bogus value to bypass null owner error
                        Title                 = $siteTitle
                        TimeZoneId            = $site.TimeZoneID
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

                    $this.ExportedInstance = $site
                    $Results = $this.GetForExport($Params)
                    if ([System.String]::IsNullOrEmpty($Results.SharingDomainRestrictionMode))
                    {
                        $Results.Remove('SharingDomainRestrictionMode') | Out-Null
                    }
                    if ([System.String]::IsNullOrEmpty($Results.RestrictedToRegion))
                    {
                        $Results.Remove('RestrictedToRegion') | Out-Null
                    }
                    if ([System.String]::IsNullOrEmpty($Results.SharingAllowedDomainList))
                    {
                        $Results.Remove('SharingAllowedDomainList') | Out-Null
                    }
                    if ([System.String]::IsNullOrEmpty($Results.SharingBlockedDomainList))
                    {
                        $Results.Remove('SharingBlockedDomainList') | Out-Null
                    }
                    # Removing the HubUrl parameter if the value is equal to the Url parameter.
                    # This is to prevent issues if the site col has just been created and not yet
                    # configured as a hubsite.
                    if ([System.String]::IsNullOrEmpty($Results.HubUrl) -or `
                        ($Results.Url.TrimEnd('/') -eq $Results.HubUrl.TrimEnd('/')))
                    {
                        $Results.Remove('HubUrl') | Out-Null
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    if ($currentDSCBlock.ToLower().Contains($organization.ToLower()) -or `
                            $currentDSCBlock.ToLower().Contains($principal.ToLower()))
                    {
                        $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('https://' + $principal + '.sharepoint.com/'), "https://`$(`$OrganizationName.Split('.')[0]).sharepoint.com/"
                        $currentDSCBlock = $currentDSCBlock -ireplace [regex]::Escape('@' + $organization), "@`$(`$OrganizationName)"
                    }
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                catch
                {
                    Write-M365DSCHost -Message "$($Global:M365DSCEmojiYellowCircle) $_"
                }
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SPOSite] AsResult([System.Object] $Values)
    {
        if ($Values -is [SPOSite])
        {
            return $Values
        }

        $result = [SPOSite]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
