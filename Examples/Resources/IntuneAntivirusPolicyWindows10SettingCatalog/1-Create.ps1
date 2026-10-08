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
        IntuneAntivirusPolicyWindows10SettingCatalog 'IntuneAntivirusPolicyWindows10SettingCatalog-Example'
        {
            DisplayName                         = 'Defender Antivirus Baseline'
            Assignments                         = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            Description                         = "Antivirus scanning and exclusion settings for the line of business file servers"
            RoleScopeTagIds                     = @("0")
            AllowArchiveScanning                = 1
            AllowBehaviorMonitoring             = 1
            AllowCloudProtection                = 1
            AllowDatagramProcessingOnWinServer  = 1
            AllowEmailScanning                  = 1
            AllowFullScanOnMappedNetworkDrives  = 0
            AllowFullScanRemovableDriveScanning = 1
            AllowIntrusionPreventionSystem      = 1
            AllowIOAVProtection                 = 1
            AllowNetworkProtectionDownLevel     = 1
            AllowRealtimeMonitoring             = 1
            AllowScanningNetworkFiles           = 1
            AllowScriptScanning                 = 1
            AllowUserUIAccess                   = 1
            AvgCPULoadFactor                    = 50
            ArchiveMaxDepth                     = 3
            ArchiveMaxSize                      = 20480
            CheckForSignaturesBeforeRunningScan = 1
            CloudBlockLevel                     = 2
            CloudExtendedTimeout                = 50
            DaysToRetainCleanedMalware          = 30
            DisableCatchupFullScan              = 0
            DisableCatchupQuickScan             = 0
            DisableCoreServiceECSIntegration    = @(0)
            DisableCoreServiceTelemetry         = @(0)
            DisableDnsOverTcpParsing            = 0
            DisableHttpParsing                  = 0
            DisableSshParsing                   = 0
            EnableLowCPUPriority                = 1
            EnableNetworkProtection             = 1
            ExcludedExtensions                  = @(".dbf", ".ldf")
            ExcludedPaths                       = @("C:\Program Files\Contoso Ledger\Data", "D:\LineOfBusiness\Spool")
            ExcludedProcesses                   = @("ContosoLedger.exe", "ContosoSync.exe")
            PUAProtection                       = 1
            EngineUpdatesChannel                = 4
            MeteredConnectionUpdates            = "0"
            PlatformUpdatesChannel              = 4
            SecurityIntelligenceUpdatesChannel  = 4
            RealTimeScanDirection               = 0
            ScanParameter                       = 1
            ScheduleQuickScanTime               = 120
            ScheduleScanDay                     = 1
            ScheduleScanTime                    = 180
            DisableTlsParsing                   = 0
            RandomizeScheduleTaskTimes          = 1
            SchedulerRandomizationTime          = 4
            SignatureUpdateFallbackOrder        = @("MicrosoftUpdateServer", "MMPC")
            SignatureUpdateFileSharesSources    = @("\\contoso.com\shares\DefenderDefinitions")
            SignatureUpdateInterval             = 4
            SubmitSamplesConsent                = 1
            DisableLocalAdminMerge              = 1
            AllowOnAccessProtection             = 1
            LowSeverityThreats                  = "quarantine"
            ModerateSeverityThreats             = "quarantine"
            SevereThreats                       = "remove"
            HighSeverityThreats                 = "quarantine"
            TemplateId                          = "804339ad-1553-4478-a742-138fb5807418_1"
            Ensure                              = 'Present'
            ApplicationId                       = $ApplicationId;
            TenantId                            = $TenantId;
            CertificateThumbprint               = $CertificateThumbprint;
        }
    }
}
