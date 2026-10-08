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
        SPOSite 'SPOSite-Example'
        {
            Url                                                            = "https://contoso.sharepoint.com/sites/marketing"
            StorageMaximumLevel                                            = 26214400
            LocaleId                                                       = 1033
            Template                                                       = "STS#3"
            Owner                                                          = "AdeleV@$TenantId"
            Title                                                          = "Marketing Department" # Updated Property
            TimeZoneId                                                     = 13
            StorageWarningLevel                                            = 25574400
            SharingCapability                                              = "Disabled"
            CommentsOnSitePagesDisabled                                    = $false
            DisableAppViews                                                = "NotDisabled"
            DisableCompanyWideSharingLinks                                 = "NotDisabled"
            DisableFlows                                                   = $false
            DefaultSharingLinkType                                         = "None"
            DefaultLinkPermission                                          = "None"
            DefaultShareLinkScope                                          = "SpecificPeople"
            DefaultShareLinkRole                                           = "View"
            LoopDefaultSharingLinkScope                                    = "SpecificPeople"
            LoopDefaultSharingLinkRole                                     = "View"
            OverrideSharingCapability                                      = $true
            OverrideTenantOrganizationSharingLinkExpirationPolicy          = $true
            OrganizationSharingLinkMaxExpirationInDays                     = 180
            OrganizationSharingLinkRecommendedExpirationInDays             = 90
            OverrideTenantAnonymousLinkExpirationPolicy                    = $false
            SharingDomainRestrictionMode                                   = "None"
            ShowPeoplePickerSuggestionsForGuestUsers                       = $false
            RequestFilesLinkEnabled                                        = $false
            ReadOnlyForUnmanagedDevices                                    = $false
            RestrictedAccessControl                                        = $false
            RestrictContentOrgWideSearch                                   = $false
            RestrictedToRegion                                             = "NoRestriction"
            InheritVersionPolicyFromTenant                                 = $true
            AllowFileArchive                                               = $false
            AllowSelfServiceUpgrade                                        = $true
            DenyAddAndCustomizePages                                       = $true
            AllowWebPropertyBagUpdateWhenDenyAddAndCustomizePagesIsEnabled = $true
            ListsShowHeaderAndNavigation                                   = $false
            HidePeoplePreviewingFiles                                      = $false
            HidePeopleWhoHaveListsOpen                                     = $false
            SocialBarOnSitePagesDisabled                                   = $false
            Ensure                                                         = "Present"
            ApplicationId                                                  = $ApplicationId
            TenantId                                                       = $TenantId
            CertificateThumbprint                                          = $CertificateThumbprint
        }
    }
}
