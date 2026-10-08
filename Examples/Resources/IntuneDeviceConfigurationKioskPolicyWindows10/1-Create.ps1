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
        IntuneDeviceConfigurationKioskPolicyWindows10 'IntuneDeviceConfigurationKioskPolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            );
            Description                                 = "Locks shared reception PCs to the visitor sign-in portal in Microsoft Edge";
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10EnterpriseN")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "Shared Reception Kiosk";
            EdgeKioskEnablePublicBrowsing               = $False;
            Ensure                                      = "Present";
            KioskBrowserBlockedUrlExceptions            = @("https://visitors.contoso.com/*");
            KioskBrowserBlockedURLs                     = @("*");
            KioskBrowserDefaultUrl                      = "https://visitors.contoso.com";
            KioskBrowserEnableEndSessionButton          = $False;
            KioskBrowserEnableHomeButton                = $True;
            KioskBrowserEnableNavigationButtons         = $False;
            KioskBrowserRestartOnIdleTimeInMinutes      = 10;
            KioskProfiles                               = @(
                MSFT_MicrosoftGraphwindowsKioskProfile{
                    UserAccountsConfiguration = @(
                        MSFT_MicrosoftGraphWindowsKioskUser{
                            odataType = '#microsoft.graph.windowsKioskAutologon'
                        }
                    )
                    ProfileName               = "Reception kiosk"
                    AppConfiguration          = MSFT_MicrosoftGraphWindowsKioskAppConfiguration{
                        Win32App  = MSFT_MicrosoftGraphWindowsKioskWin32App{
                            EdgeNoFirstRun              = $True
                            EdgeKiosk                   = "https://visitors.contoso.com"
                            ClassicAppPath              = 'msedge.exe'
                            AutoLaunch                  = $False
                            StartLayoutTileSize         = 'hidden'
                            AppType                     = 'unknown'
                            EdgeKioskIdleTimeoutMinutes = 5
                            EdgeKioskType               = 'publicBrowsing'
                            Name                        = "Visitor sign-in"
                            odataType                   = '#microsoft.graph.windowsKioskWin32App'
                        }
                        odataType = '#microsoft.graph.windowsKioskSingleWin32App'
                    }
                }
            );
            RoleScopeTagIds                             = @("0");
            WindowsKioskForceUpdateSchedule             = MSFT_MicrosoftGraphwindowsKioskForceUpdateSchedule{
                RunImmediatelyIfAfterStartDateTime = $False
                StartDateTime                      = '2023-04-15T23:00:00.0000000+00:00'
                DayofMonth                         = 1
                Recurrence                         = 'daily'
                DayofWeek                          = 'sunday'
            };
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
