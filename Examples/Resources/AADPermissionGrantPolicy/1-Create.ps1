<#
This example creates a new Azure AD Permission Grant Policy with include and exclude condition sets.
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
        AADPermissionGrantPolicy 'AADPermissionGrantPolicy-Example'
        {
            Id                                = "low-risk-delegated-consent"
            DisplayName                       = "Low Risk Delegated Consent"
            Description                       = "Allows users to consent to low risk delegated permissions"
            Includes                          = @(
                MSFT_AADPermissionGrantConditionSet {
                    Id                                          = "include-low-risk-delegated"
                    PermissionType                              = "delegated"
                    PermissionClassification                    = "low"
                    ClientApplicationIds                        = @("all")
                    ClientApplicationTenantIds                  = @("all")
                    ClientApplicationPublisherIds               = @("all")
                    ClientApplicationsFromVerifiedPublisherOnly = $false
                    ResourceApplication                         = "00000003-0000-0000-c000-000000000000"
                    Permissions                                 = @("User.Read", "openid", "profile")
                }
                MSFT_AADPermissionGrantConditionSet {
                    Id                                          = "include-verified-publishers"
                    PermissionType                              = "delegated"
                    ClientApplicationIds                        = @("all")
                    ClientApplicationsFromVerifiedPublisherOnly = $true
                    ResourceApplication                         = "any"
                    Permissions                                 = @("all")
                }
            )
            Excludes                          = @(
                MSFT_AADPermissionGrantConditionSet {
                    Id                       = "exclude-high-risk-permissions"
                    PermissionType           = "delegated"
                    PermissionClassification = "high"
                    ClientApplicationIds     = @("all")
                    ResourceApplication      = "any"
                    Permissions              = @("all")
                }
            )
            IncludeAllPreApprovedApplications = $false
            ResourceScopeType                 = "tenant"
            Ensure                            = "Present"
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            CertificateThumbprint             = $CertificateThumbprint
        }
    }
}
