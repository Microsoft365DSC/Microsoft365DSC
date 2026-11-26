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
        IntuneMobileAppsWin32CatalogAppWindows10 'IntuneMobileAppsWin32CatalogAppWindows10-Example'
        {
            AllowAvailableUninstall        = $true;
            AllowedArchitectures           = "x64";
            Assignments                    = @(
                MSFT_DeviceManagementWin32CatalogMobileAppAssignment{
                    dataType = "#microsoft.graph.allLicensedUsersAssignmentTarget"
                    intent   = "available"
                }
            );
            Categories                     = @(
                MSFT_DeviceManagementMobileAppCategory{
                    DisplayName = "Productivity"
                }
            );
            Description                    = "A file archiver with a high compression ratio";
            Developer                      = "Igor Pavlov";
            DisplayName                    = "7-Zip (x64)";
            DisplayVersion                 = "26.03";
            FileName                       = "7z2603-x64.msi";
            InformationUrl                 = "https://www.7-zip.org";
            InstallCommandLine             = "msiexec.exe /i `"7z2603-x64.msi`" /qn";
            InstallExperience              = MSFT_MicrosoftGraphWin32LobAppInstallExperience1{
                DeviceRestartBehavior = "basedOnReturnCode"
                MaxRunTimeInMinutes   = 60
                RunAsAccount          = "system"
            };
            IsFeatured                     = $false;
            LargeIcon                      = MSFT_MicrosoftGraphMimeContent{
                Type  = "image/png"
                Value = "<base64-encoded-app-icon>"
            };
            MinimumCpuSpeedInMHz           = 1000;
            MinimumFreeDiskSpaceInMB       = 200;
            MinimumMemoryInMB              = 2048;
            MinimumNumberOfProcessors      = 1;
            MinimumSupportedWindowsRelease = "1607";
            MobileAppCatalogPackageId      = "eac00000-af3f-4678-b9a7-ca22b5db724d";
            MsiInformation                 = MSFT_MicrosoftGraphWin32LobAppMsiInformation{
                PackageType    = "perMachine"
                ProductCode    = "{23170F69-40C1-2702-2603-000001000000}"
                ProductName    = "7-Zip"
                ProductVersion = "26.03"
                Publisher      = "Igor Pavlov"
                RequiresReboot = $false
                UpgradeCode    = "{23170F69-40C1-2702-0000-000004000000}"
            };
            Notes                          = "Published from the Enterprise App Catalog";
            Owner                          = "Workplace Services";
            PrivacyInformationUrl          = "https://www.7-zip.org/faq.html";
            Publisher                      = "Igor Pavlov";
            ReturnCodes                    = @(
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 0
                    Type       = "success"
                }
            );
            RoleScopeTagIds                = @("0");
            Rules                          = @(
                MSFT_MicrosoftGraphWin32LobAppRule1{
                    Check32BitOn64System   = $false
                    ComparisonValue        = "26.03.00.0"
                    KeyPath                = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{23170F69-40C1-2702-2603-000001000000}"
                    ODataType              = "#microsoft.graph.win32LobAppRegistryRule"
                    OperationType          = "string"
                    Operator               = "equal"
                    RuleType               = "detection"
                    ValueName              = "DisplayVersion"
                }
            );
            SetupFilePath                  = "7z2603-x64.msi";
            UninstallCommandLine           = "msiexec.exe /x {23170F69-40C1-2702-2603-000001000000} /qn";
            Ensure                         = "Present";
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
