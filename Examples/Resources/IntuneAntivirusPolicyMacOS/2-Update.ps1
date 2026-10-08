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
        IntuneAntivirusPolicyMacOS 'IntuneAntivirusPolicyMacOS-Example'
        {
            allowedThreats                         = @("Trojan:Win32/Casdet!rfn");
            antivirusengine_enforcementLevel       = "2";
            Assignments                            = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    groupDisplayName = "Intune Excluded Devices"
                }
            );
            automaticDefinitionUpdateEnabled       = "true";
            automaticSampleSubmission              = "true";
            automaticSampleSubmissionConsent       = "safe";
            behaviorMonitoring                     = "enabled";
            checkForDefinitionsUpdate              = "true";
            consumerExperience                     = "1";
            dailyConfiguration_interval            = 24;
            dailyConfiguration_timeOfDay           = 180;
            definitionUpdateDue                    = 7;
            definitionUpdatesInterval              = 3600;
            Description                            = "Real-time protection and daily quick scans for managed Mac endpoints, with build output excluded"; # Updated Property
            diagnosticLevel                        = "1";
            disallowedThreatActions                = @("allow", "restore");
            DisplayName                            = "Mac Endpoints - Microsoft Defender Antivirus";
            enabled                                = "true";
            enableFileHashComputation              = "true";
            enableRealTimeProtection               = "true";
            enforcementLevel                       = "2";
            enforcementLevel_tamperProtection      = "2";
            Ensure                                 = "Present";
            exclusions                             = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogexclusions{
                    exclusions_item_isDirectory = "true"
                    exclusions_item_path        = "/Users/Shared/BuildOutput"
                    exclusions_item_type        = "excludedPath"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogexclusions{
                    exclusions_item_extension = ".dmg"
                    exclusions_item_type      = "excludedFileExtension"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogexclusions{
                    exclusions_item_name = "Xcode"
                    exclusions_item_type = "excludedFileName"
                }
            );
            exclusions_tamperProtection            = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions_tamperProtection{
                    exclusions_item_args_tamperProtection      = @("--daemon")
                    exclusions_item_path_tamperProtection      = "/usr/local/jamf/bin/jamf"
                    exclusions_item_signingId_tamperProtection = "com.jamf.management.Jamf"
                    exclusions_item_teamId_tamperProtection    = "483DWKW443"
                }
            );
            exclusionsMergePolicy                  = "0";
            groupIds                               = "Corporate Macs";
            hideStatusMenuIcon                     = "false";
            ignoreExclusions                       = "false";
            lowPriorityScheduledScan               = "true";
            maximumOnDemandScanThreads             = 4;
            offlineDefinitionUpdate                = "enabled";
            offlineDefinitionUpdateFallbackToCloud = "true";
            offlineDefinitionUpdateUrl             = "https://mdatp-updates.contoso.com/macos";
            offlineDefinitionUpdateVerifySig       = "enabled";
            passiveMode                            = "false";
            performanceProfiles                    = "enabled";
            randomizeScanStartTime                 = 2;
            RoleScopeTagIds                        = @("0");
            runScanWhenIdle                        = "false";
            scanAfterDefinitionUpdate              = "true";
            scanArchives                           = "true";
            scanHistoryMaximumItems                = 10000;
            scanResultsRetentionDays               = 90;
            scheduledScan                          = "enabled";
            threatTypeSettings                     = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings{
                    threatTypeSettings_item_key   = "potentially_unwanted_application"
                    threatTypeSettings_item_value = "audit"
                }
                MSFT_MicrosoftGraphIntuneSettingsCatalogthreatTypeSettings{
                    threatTypeSettings_item_key   = "archive_bomb"
                    threatTypeSettings_item_value = "block"
                }
            );
            threatTypeSettingsMergePolicy          = "0";
            userInitiatedFeedback                  = "0";
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
