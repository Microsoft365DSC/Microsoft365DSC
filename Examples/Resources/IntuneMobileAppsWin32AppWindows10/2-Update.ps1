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
        IntuneMobileAppsWin32AppWindows10 "IntuneMobileAppsWin32AppWindows10-Example"
        {
            AllowAvailableUninstall        = $True;
            AllowedArchitectures           = @("x86","x64","arm64");
            Assignments                    = @();
            Categories                     = @(
                MSFT_DeviceManagementMobileAppCategory{
                    Id          = "2185c6bf-1b3d-4daa-a0bc-79cb4fad9c87"
                    DisplayName = "App Category 1"
                }
            );
            Description                    = "IntuneWinAppUtil.exe";
            Rules                          = @(
                MSFT_MicrosoftGraphWin32LobAppRule{
                    Check32BitOn64System    = $False
                    ComparisonValue         = "1.0.0.0"
                    FileOrFolderName        = "asdf.exe"
                    FileSystemOperationType = "version"
                    Operator                = "equal"
                    Path                    = "C:\temp\Dev"
                    RuleType                = "detection"
                    OdataType               = "FileSystem"
                }
                MSFT_MicrosoftGraphWin32LobAppRule{
                    Check32BitOn64System  = $False
                    RegistryOperationType = "integer"
                    ComparisonValue       = "100"
                    Operator              = "greaterThanOrEqual"
                    OdataType             = "Registry"
                    RuleType              = "detection"
                    KeyPath               = "HKLM:\Software\Microsoft\Windows\CurrentVersion"
                }
                MSFT_MicrosoftGraphWin32LobAppRule{
                    ProductVersionOperator = "lessThan"
                    ProductVersion         = "2.0.0.0"
                    ProductCode            = "{00000000-0000-0000-0000-000000000000}"
                    OdataType              = "ProductCode"
                    RuleType               = "requirement"
                }
                MSFT_MicrosoftGraphWin32LobAppRule{
                    Script                        = "Write-Output 'Hello World'"
                    DisplayName                   = "PowerShell Script Rule.ps1"
                    Operator                      = "equal"
                    RunAs32Bit                    = $False
                    EnforceSignatureCheck         = $False
                    RunAsAccount                  = "system"
                    OdataType                     = "PowerShellScript"
                    RuleType                      = "requirement"
                    PowerShellScriptOperationType = "string"
                    ComparisonValue               = "Hello World"
                }
            );
            Developer                      = "";
            DisplayName                    = "Win32 App - IntuneWinAppUtil.exe";
            DisplayVersion                 = "1.0.0.0";
            Ensure                         = "Present";
            FileName                       = "IntuneWinAppUtil.intunewin";
            Id                             = "63271b78-0fa4-46b8-9ac0-d4b777555dde";
            InstallCommandLine             = "IntuneWinAppUtil.exe -s -t 0";
            InstallExperience              = MSFT_MicrosoftGraphWin32LobAppInstallExperience{
                DeviceRestartBehavior = "suppress"
                RunAsAccount          = "system"
                MaxRunTimeInMinutes   = 120 # Updated Property
            };
            IsFeatured                     = $False;
            MinimumCpuSpeedInMHz           = 2500;
            MinimumFreeDiskSpaceInMB       = 1;
            MinimumMemoryInMB              = 200;
            MinimumNumberOfProcessors      = 1;
            MinimumSupportedWindowsRelease = "1607";
            Notes                          = "";
            Owner                          = "";
            Publisher                      = "Microsoft";
            Relationships                  = @(
                MSFT_MicrosoftGraphMobileAppRelationship{
                    odataType         = "#microsoft.graph.mobileAppDependency"
                    targetDisplayName = "Visual C++ Redistributable 2015-2022"
                    dependencyType    = "autoInstall"
                }
            );
            ReturnCodes                    = @(
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 0
                    Type       = "success"
                }
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 1707
                    Type       = "success"
                }
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 3010
                    Type       = "softReboot"
                }
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 1641
                    Type       = "hardReboot"
                }
                MSFT_MicrosoftGraphWin32LobAppReturnCode{
                    ReturnCode = 1618
                    Type       = "retry"
                }
            );
            RoleScopeTagIds                = @("0");
            SetupFilePath                  = "IntuneWinAppUtil.exe";
            UninstallCommandLine           = "IntuneWinAppUtil.exe -t -s 0";
            ApplicationId                  = $ApplicationId;
            TenantId                       = $TenantId;
            CertificateThumbprint          = $CertificateThumbprint;
        }
    }
}
