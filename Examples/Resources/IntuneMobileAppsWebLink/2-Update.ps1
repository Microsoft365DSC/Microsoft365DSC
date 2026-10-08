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
        IntuneMobileAppsWebLink "IntuneMobileAppsWebLink-Example"
        {
            TargetType            = "webApp";
            AppUrl                = "https://selfservice.contoso.com";
            UseManagedBrowser     = $true;
            Description           = "Contoso employee self-service portal";
            Developer             = "Contoso";
            DisplayName           = "Web App";
            Ensure                = "Present";
            InformationUrl        = "https://intranet.contoso.com/apps/self-service";
            IsFeatured            = $true; # Updated Property
            LargeIcon             = MSFT_MicrosoftGraphMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-app-icon>"
            };
            Notes                 = "Reviewed annually by the mobility team";
            Owner                 = "Human Resources";
            PrivacyInformationUrl = "https://www.contoso.com/privacy";
            Publisher             = "Contoso";
            RoleScopeTagIds       = @("0");
            Assignments           = @(
                MSFT_DeviceManagementMobileAppAssignment{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Users'
                    intent                                     = 'required'
                }
            );
            Categories            = @(
                MSFT_DeviceManagementMobileAppCategory{
                    DisplayName = "Business"
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
