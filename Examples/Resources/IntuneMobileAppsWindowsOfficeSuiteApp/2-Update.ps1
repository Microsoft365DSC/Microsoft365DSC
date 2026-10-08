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
        IntuneMobileAppsWindowsOfficeSuiteApp "IntuneMobileAppsWindowsOfficeSuiteApp-Example"
        {
            Description                          = "Microsoft 365 desktop applications for Windows laptops and desktops"; # Updated Property
            DisplayName                          = "Microsoft 365 Apps for Windows 10 and later";
            Ensure                               = "Present";
            InformationUrl                       = "https://intranet.contoso.com/apps/microsoft-365-apps";
            IsFeatured                           = $true;
            Notes                                = "Reviewed annually by the workplace services team";
            PrivacyInformationUrl                = "https://www.contoso.com/privacy";
            RoleScopeTagIds                      = @("0");
            AutoAcceptEula                       = $true;
            ProductIds                           = @("o365ProPlusRetail");
            UseSharedComputerActivation          = $false;
            UpdateChannel                        = "current";
            OfficeSuiteAppDefaultFileFormat      = "officeOpenXMLFormat";
            OfficePlatformArchitecture           = "x64";
            LocalesToInstall                     = @("en-us", "fr-fr");
            InstallProgressDisplayLevel          = "none";
            ShouldUninstallOlderVersionsOfOffice = $true;
            TargetVersion                        = "16.0.17928.20216";
            UpdateVersion                        = "16.0.17928.20216";
            ExcludedApps                         = MSFT_DeviceManagementMobileAppExcludedApp{
                Access             = $true
                Bing               = $true
                Excel              = $false
                Groove             = $true
                InfoPath           = $true
                Lync               = $true
                OneDrive           = $false
                OneNote            = $false
                Outlook            = $false
                PowerPoint         = $false
                Publisher          = $true
                SharePointDesigner = $true
                Teams              = $true
                Visio              = $true
                Word               = $false
            };
            Assignments                          = @(
                MSFT_DeviceManagementMobileAppAssignment{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    groupDisplayName                           = 'Intune Pilot Devices'
                    intent                                     = 'required'
                }
            );
            Categories                           = @(
                MSFT_DeviceManagementMobileAppCategory{
                    DisplayName = "Productivity"
                }
            );
            ApplicationId                        = $ApplicationId;
            TenantId                             = $TenantId;
            CertificateThumbprint                = $CertificateThumbprint;
        }
    }
}
