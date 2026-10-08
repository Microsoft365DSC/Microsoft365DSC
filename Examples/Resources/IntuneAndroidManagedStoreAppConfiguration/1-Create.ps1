<#
This example creates a new Intune Mobile App Configuration Policy for iOs devices
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

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        IntuneAndroidManagedStoreAppConfiguration "IntuneAndroidManagedStoreAppConfiguration-Example"
        {
            Assignments                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Devices"
                }
            );
            Description                 = "Grants Microsoft Authenticator the camera access it needs to scan sign-in QR codes";
            RoleScopeTagIds             = @("0");
            DisplayName                 = "Microsoft Authenticator Permissions";
            Ensure                      = "Present";
            appSupportsOemConfig        = $False;
            connectedAppsEnabled        = $False;
            credentialProviderRoleState = "allowed";
            packageId                   = "app:com.azure.authenticator";
            payloadJson                 = "";
            permissionActions           = @(
                MSFT_androidPermissionAction{
                    action     = 'autoGrant'
                    permission = 'android.permission.CAMERA'
                }
                MSFT_androidPermissionAction{
                    action     = 'prompt'
                    permission = 'android.permission.ACCESS_FINE_LOCATION'
                }
            );
            profileApplicability        = "androidDeviceOwner";
            targetedMobileApps          = @("Microsoft Authenticator");
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
