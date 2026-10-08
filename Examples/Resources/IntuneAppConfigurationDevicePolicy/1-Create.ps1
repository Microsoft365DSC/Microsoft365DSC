<#
This example creates a new App Configuration Device Policy.
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
        IntuneAppConfigurationDevicePolicy "IntuneAppConfigurationDevicePolicy-Example"
        {
            Assignments                 = @();
            Description                 = "";
            DisplayName                 = "Outlook for Android - Managed Configuration";
            Ensure                      = "Present";
            Id                          = "0000000-0000-0000-0000-000000000000";
            ConnectedAppsEnabled        = $true;
            CredentialProviderRoleState = "allowed";
            PackageId                   = "app:com.microsoft.office.outlook"
            PayloadJson                 = "Base64 encoded settings"
            PermissionActions           = @()
            ProfileApplicability        = "default"
            RoleScopeTagIds             = @("0");
            TargetedMobileApps          = @("<mobile-app-id>");
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
