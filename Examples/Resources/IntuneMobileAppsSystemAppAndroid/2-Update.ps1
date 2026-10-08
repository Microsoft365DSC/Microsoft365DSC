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
        IntuneMobileAppsSystemAppAndroid "IntuneMobileAppsSystemAppAndroid-Example"
        {
            DisplayName           = "Office";
            Ensure                = "Present";
            AppIdentifier         = "com.microsoft.office";
            Publisher             = "Company"; # Updated Property
            Description           = "Microsoft Office system app preinstalled on corporate-owned Android devices";
            Developer             = "Microsoft Corporation";
            InformationUrl        = "https://intranet.contoso.com/apps/office-android";
            IsFeatured            = $true;
            LargeIcon             = MSFT_DeviceManagementMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-app-icon>"
            };
            Notes                 = "Reviewed annually by the mobility team";
            Owner                 = "Endpoint Management Team";
            PrivacyInformationUrl = "https://www.contoso.com/privacy";
            RoleScopeTagIds       = @("0")
            Assignments           = @(
                MSFT_DeviceManagementSystemMobileAppAssignment {
                    groupDisplayName                           = 'All devices'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    intent                                     = 'required'
                    assignmentSettings                         = MSFT_DeviceManagementSystemMobileAppAssignmentSettings{
                        odataType                      = "#microsoft.graph.androidManagedStoreAppAssignmentSettings"
                        androidManagedStoreAppTrackIds = @()
                        autoUpdateMode                 = "default"
                    }
                }
                MSFT_DeviceManagementSystemMobileAppAssignment{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                    intent           = 'required'
                }
            );
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
