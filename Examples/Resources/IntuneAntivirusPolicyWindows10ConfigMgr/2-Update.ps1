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
        IntuneAntivirusPolicyWindows10ConfigMgr "IntuneAntivirusPolicyWindows10ConfigMgr-Example"
        {
            AllowArchiveScanning                = "1";
            AllowBehaviorMonitoring             = "1";
            AllowCloudProtection                = "1";
            AllowEmailScanning                  = "1";
            AllowFullScanOnMappedNetworkDrives  = "0";
            AllowFullScanRemovableDriveScanning = "1";
            AllowIntrusionPreventionSystem      = "1";
            AllowIOAVProtection                 = "1";
            AllowOnAccessProtection             = "1";
            AllowRealtimeMonitoring             = "1";
            AllowScanningNetworkFiles           = "1";
            AllowScriptScanning                 = "1";
            AllowUserUIAccess                   = "0"; # Updated Property
            Assignments                         = @();
            AvgCPULoadFactor                    = 50;
            CheckForSignaturesBeforeRunningScan = "1";
            CloudBlockLevel                     = "2";
            CloudExtendedTimeout                = 30;
            DaysToRetainCleanedMalware          = 30;
            Description                         = "";
            DisableCatchupFullScan              = "0";
            DisableCatchupQuickScan             = "0";
            DisablePrivacyMode                  = "1";
            DisableRestorePoint                 = "1";
            DisplayName                         = "Windows ConfigMgr - Microsoft Defender Antivirus";
            EnableLowCPUPriority                = "0";
            Ensure                              = "Present";
            ExcludedExtensions                  = @("asdf");
            ExcludedPaths                       = @("asdf");
            ExcludedProcesses                   = @("asdf");
            HighSeverityThreatDefaultAction     = "remove";
            LowSeverityThreatDefaultAction      = "quarantine";
            ModerateSeverityThreatDefaultAction = "quarantine";
            PUAProtection                       = "1";
            RandomizeScheduleTaskTimes          = "1";
            RealTimeScanDirection               = "0";
            RoleScopeTagIds                     = @("0");
            ScanParameter                       = "1";
            ScheduleQuickScanTime               = 60;
            ScheduleScanDay                     = "0";
            ScheduleScanTime                    = 120;
            SecurityIntelligenceLocation        = "Secure Intelligence Location";
            SevereThreatDefaultAction           = "quarantine";
            SignatureUpdateFallbackOrder        = @("asdf");
            SignatureUpdateFileSharesSources    = @("asdf");
            SignatureUpdateInterval             = 8;
            SubmitSamplesConsent                = "1";
            ApplicationId                       = $ApplicationId;
            TenantId                            = $TenantId;
            CertificateThumbprint               = $CertificateThumbprint;
        }
    }
}
