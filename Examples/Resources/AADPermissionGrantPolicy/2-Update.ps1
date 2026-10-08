<#
This example updates an existing Azure AD Permission Grant Policy by modifying its condition sets.
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
            Description                       = "Allows users to consent to low risk delegated permissions except application permissions" # Updated Property
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
                    Permissions                                 = @("User.Read", "User.ReadBasic.All", "openid", "profile") # Updated Property
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
                MSFT_AADPermissionGrantConditionSet {
                    Id                   = "exclude-application-permissions"
                    PermissionType       = "application"
                    ClientApplicationIds = @("all")
                    ResourceApplication  = "any"
                    Permissions          = @("all")
                }
            )
            IncludeAllPreApprovedApplications = $true # Updated Property
            ResourceScopeType                 = "tenant"
            Ensure                            = "Present"
            ApplicationId                     = $ApplicationId
            TenantId                          = $TenantId
            CertificateThumbprint             = $CertificateThumbprint
        }
    }
}
