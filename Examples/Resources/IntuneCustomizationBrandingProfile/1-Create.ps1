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
        IntuneCustomizationBrandingProfile "IntuneCustomizationBrandingProfile-Example"
        {
            Assignments                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Users"
                }
            );
            CompanyPortalBlockedActions    = @(
                MSFT_MicrosoftGraphcompanyPortalBlockedAction{
                    Action    = "remove"
                    OwnerType = "company"
                    Platform  = "windows10AndLater"
                }
            );
            ContactITEmailAddress          = "servicedesk@contoso.com";
            ContactITName                  = "Contoso Service Desk";
            ContactITNotes                 = "Open Monday to Friday, 07:00 - 19:00 CET";
            ContactITPhoneNumber           = "+1 425 555 0134";
            CustomCanSeePrivacyMessage     = "**What Contoso IT can see** Device model, serial number and the apps installed by IT. Read the full [privacy notice](https://privacy.contoso.com).";
            CustomCantSeePrivacyMessage    = "**What Contoso IT cannot see** Your photos, browsing history, text messages and personal files. Read the full [privacy notice](https://privacy.contoso.com).";
            DisableDeviceCategorySelection = $false;
            DisplayName                    = "Contoso";
            EnrollmentAvailability         = "availableWithPrompts";
            Ensure                         = "Present";
            LandingPageCustomizedImage     = MSFT_MicrosoftGraphMimeContent{
                Type  = "image/jpeg"
                Value = "<base64-encoded-landing-page-image>"
            };
            LightBackgroundLogo            = MSFT_MicrosoftGraphMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-light-background-logo>"
            };
            OnlineSupportSiteName          = "Contoso Support";
            OnlineSupportSiteUrl           = "https://support.contoso.com";
            PrivacyUrl                     = "https://privacy.contoso.com";
            ProfileDescription             = "Company Portal branding shown to employees on their enrolled devices";
            ProfileName                    = "Contoso Company Portal";
            RoleScopeTagIds                = @("0");
            ShowAzureADEnterpriseApps      = $true;
            ShowConfigurationManagerApps   = $true;
            ShowDisplayNameNextToLogo      = $true;
            ShowLogo                       = $true;
            ShowOfficeWebApps              = $true;
            ThemeColor                     = MSFT_MicrosoftGraphRgbColor{
                B = 198
                G = 114
                R = 0
            };
            ThemeColorLogo                 = MSFT_MicrosoftGraphMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-theme-color-logo>"
            };
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
