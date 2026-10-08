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
        IntuneAppProtectionPolicyWindows10 "IntuneAppProtectionPolicyWindows10-Example"
        {
            AllowedInboundDataTransferSources       = "allApps";
            AllowedOutboundClipboardSharingLevel    = "anyDestinationAnySource";
            AllowedOutboundDataTransferDestinations = "allApps";
            AppActionIfUnableToAuthenticateUser     = "wipe";
            Apps                                    = @("com.microsoft.edge");
            Assignments                             = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Users"
                }
            );
            Description                             = "Protects company data in the Windows apps used on personally owned laptops";
            DisplayName                             = "Windows App Protection Baseline";
            Ensure                                  = "Present";
            MaximumAllowedDeviceThreatLevel         = "secured";
            MaximumRequiredOsVersion                = "12.0.0.0";
            MaximumWarningOsVersion                 = "11.0.0.0";
            MaximumWipeOsVersion                    = "13.0.0.0";
            MinimumRequiredAppVersion               = "16.0.0.0";
            MinimumRequiredOsVersion                = "10.0.19041.0";
            MinimumRequiredSdkVersion               = "1.0.0.0";
            MinimumWarningAppVersion                = "16.5.0.0";
            MinimumWarningOsVersion                 = "10.0.22000.0";
            MinimumWipeAppVersion                   = "15.0.0.0";
            MinimumWipeOsVersion                    = "10.0.17763.0";
            MinimumWipeSdkVersion                   = "0.9.0.0";
            MobileThreatDefenseRemediationAction    = "block";
            PeriodOfflineBeforeAccessCheck          = "P1D";
            PeriodOfflineBeforeWipeIsEnforced       = "P180D"; # Updated Property
            PrintBlocked                            = $false;
            RoleScopeTagIds                         = @("0");
            ApplicationId                           = $ApplicationId;
            TenantId                                = $TenantId;
            CertificateThumbprint                   = $CertificateThumbprint;
        }
    }
}
