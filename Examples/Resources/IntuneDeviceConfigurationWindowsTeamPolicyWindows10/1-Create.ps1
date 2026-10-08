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
        IntuneDeviceConfigurationWindowsTeamPolicyWindows10 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10-Example'
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
            AzureOperationalInsightsBlockTelemetry      = $True;
            AzureOperationalInsightsWorkspaceId         = "<log-analytics-workspace-id>";
            AzureOperationalInsightsWorkspaceKey        = "<log-analytics-workspace-key>";
            ConnectAppBlockAutoLaunch                   = $True;
            Description                                 = "Meeting room restrictions applied to the Surface Hub devices in shared spaces";
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration Surface Hubs"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Skip desktop editions"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "exclude"
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Surface Hub 20H2 or later"
                MinOSVersion = "10.0.19042.0"
                MaxOSVersion = "10.0.19045.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "Device restrictions (Windows 10 Team)";
            Ensure                                      = "Present";
            MaintenanceWindowBlocked                    = $False;
            MaintenanceWindowDurationInHours            = 1;
            MaintenanceWindowStartTime                  = "00:00:00";
            MiracastBlocked                             = $True;
            MiracastChannel                             = "oneHundredFortyNine";
            MiracastRequirePin                          = $True;
            RoleScopeTagIds                             = @("0");
            SettingsBlockMyMeetingsAndFiles             = $True;
            SettingsBlockSessionResume                  = $True;
            SettingsBlockSigninSuggestions              = $True;
            SettingsDefaultVolume                       = 45;
            SettingsScreenTimeoutInMinutes              = 10;
            SettingsSessionTimeoutInMinutes             = 5;
            SettingsSleepTimeoutInMinutes               = 20;
            WelcomeScreenBackgroundImageUrl             = "https://www.contoso.com/branding/meeting-room-welcome.png";
            WelcomeScreenBlockAutomaticWakeUp           = $True;
            WelcomeScreenMeetingInformation             = "showOrganizerAndTimeOnly";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
