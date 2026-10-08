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
        IntuneAntivirusPolicyLinux 'IntuneAntivirusPolicyLinux-Example'
        {
            allowedThreats                              = @("Trojan:Win32/Casdet!rfn");
            antivirusengine_enforcementLevel            = "0";
            antivirusengine_offlineDefinitionUpdate     = "Enabled";
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            automaticDefinitionUpdateEnabled            = "true";
            automaticSampleSubmissionConsent            = "safe";
            behaviorMonitoring                          = "1";
            cloudBlockLevel                             = "high";
            definitionUpdatesInterval                   = 3600;
            Description                                 = "Real-time protection and weekly full scans for Linux servers";
            diagnosticLevel                             = "1";
            disallowedThreatActions                     = @("allow", "restore");
            DisplayName                                 = "Linux Servers - Microsoft Defender Antivirus";
            enabled                                     = "true";
            enableFileHashComputation                   = "true";
            enableRealTimeProtection                    = "true";
            Ensure                                      = "Present";
            exclusions                                  = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions{
                    exclusions_item_isDirectory = "true"
                    exclusions_item_path        = "/var/lib/mysql"
                    exclusions_item_type        = "excludedPath"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions{
                    exclusions_item_extension = ".log"
                    exclusions_item_type      = "excludedFileExtension"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions{
                    exclusions_item_name = "mysqld"
                    exclusions_item_type = "excludedFileName"
                }
            );
            exclusionsMergePolicy                       = "0";
            maximumOnDemandScanThreads                  = 4;
            networkprotection_enforcementLevel          = "2";
            nonExecMountPolicy                          = "0";
            offlinedefinitionupdatefallbacktocloud      = "true";
            offlinedefinitionupdateurl                  = "https://mdatp-updates.contoso.com/linux";
            passiveMode                                 = "false";
            RoleScopeTagIds                             = @("0");
            scanAfterDefinitionUpdate                   = "true";
            scanArchives                                = "true";
            scanHistoryMaximumItems                     = 10000;
            scanResultsRetentionDays                    = 90;
            scheduledScan_checkForDefinitionsUpdate     = "true";
            scheduledScan_dailyConfiguration_timeOfDay  = 180;
            scheduledScan_dayOfWeek                     = "7";
            scheduledScan_ignoreExclusions              = "false";
            scheduledScan_interval                      = 24;
            scheduledScan_lowPriorityScheduledScan      = "true";
            scheduledScan_randomizeScanStartTime        = 2;
            scheduledScan_runScanWhenIdle               = "false";
            scheduledScan_scanType                      = "full";
            scheduledScan_weeklyConfiguration_timeOfDay = 120;
            threatTypeSettings                          = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings{
                    threatTypeSettings_item_key   = "potentially_unwanted_application"
                    threatTypeSettings_item_value = "audit"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings{
                    threatTypeSettings_item_key   = "archive_bomb"
                    threatTypeSettings_item_value = "block"
                }
            );
            threatTypeSettingsMergePolicy               = "0";
            unmonitoredFilesystems                      = @("nfs", "cifs");
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
