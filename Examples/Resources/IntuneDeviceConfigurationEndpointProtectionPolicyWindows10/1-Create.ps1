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
        IntuneDeviceConfigurationEndpointProtectionPolicyWindows10 'IntuneDeviceConfigurationEndpointProtectionPolicyWindows10-Example'
        {
            ApplicationGuardAllowCameraMicrophoneRedirection                             = $false;
            ApplicationGuardAllowFileSaveOnHost                                          = $True;
            ApplicationGuardAllowPersistence                                             = $True;
            ApplicationGuardAllowPrintToLocalPrinters                                    = $True;
            ApplicationGuardAllowPrintToNetworkPrinters                                  = $True;
            ApplicationGuardAllowPrintToPDF                                              = $True;
            ApplicationGuardAllowPrintToXPS                                              = $True;
            ApplicationGuardAllowVirtualGPU                                              = $True;
            ApplicationGuardBlockClipboardSharing                                        = "blockContainerToHost";
            ApplicationGuardBlockFileTransfer                                            = "blockImageFile";
            ApplicationGuardBlockNonEnterpriseContent                                    = $True;
            ApplicationGuardCertificateThumbprints                                       = @("<root-certificate-thumbprint>");
            ApplicationGuardEnabled                                                      = $True;
            ApplicationGuardEnabledOptions                                               = "enabledForEdge";
            ApplicationGuardForceAuditing                                                = $True;
            AppLockerApplicationControl                                                  = "enforceComponentsStoreAppsAndSmartlocker";
            Assignments                                                                  = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            );
            BitLockerAllowStandardUserEncryption                                         = $True;
            BitLockerDisableWarningForOtherDiskEncryption                                = $True;
            BitLockerEnableStorageCardEncryptionOnMobile                                 = $True;
            BitLockerEncryptDevice                                                       = $True;
            BitLockerFixedDrivePolicy                                                    = MSFT_MicrosoftGraphbitLockerFixedDrivePolicy{
                RecoveryOptions                 = MSFT_MicrosoftGraphBitLockerRecoveryOptions{
                    RecoveryInformationToStore                     = 'passwordAndKey'
                    HideRecoveryOptions                            = $True
                    BlockDataRecoveryAgent                         = $True
                    RecoveryKeyUsage                               = 'allowed'
                    EnableBitLockerAfterRecoveryInformationToStore = $True
                    EnableRecoveryInformationSaveToStore           = $True
                    RecoveryPasswordUsage                          = 'allowed'
                }
                            RequireEncryptionForWriteAccess = $True
                EncryptionMethod                = 'xtsAes128'
            };
            BitLockerRecoveryPasswordRotation                                            = "notConfigured";
            BitLockerRemovableDrivePolicy                                                = MSFT_MicrosoftGraphbitLockerRemovableDrivePolicy{
                RequireEncryptionForWriteAccess   = $True
                BlockCrossOrganizationWriteAccess = $True
                EncryptionMethod                  = 'aesCbc128'
            };
            BitLockerSystemDrivePolicy                                                   = MSFT_MicrosoftGraphbitLockerSystemDrivePolicy{
                PrebootRecoveryEnableMessageAndUrl       = $True
                StartupAuthenticationTpmPinUsage         = 'allowed'
                EncryptionMethod                         = 'xtsAes128'
                StartupAuthenticationTpmPinAndKeyUsage   = 'allowed'
                StartupAuthenticationRequired            = $True
                RecoveryOptions                          = MSFT_MicrosoftGraphBitLockerRecoveryOptions{
                    RecoveryInformationToStore                     = 'passwordAndKey'
                    HideRecoveryOptions                            = $False
                    BlockDataRecoveryAgent                         = $True
                    RecoveryKeyUsage                               = 'allowed'
                    EnableBitLockerAfterRecoveryInformationToStore = $True
                    EnableRecoveryInformationSaveToStore           = $False
                    RecoveryPasswordUsage                          = 'allowed'
                }
                            StartupAuthenticationTpmUsage            = 'allowed'
                StartupAuthenticationTpmKeyUsage         = 'allowed'
                StartupAuthenticationBlockWithoutTpmChip = $False
            };
            DefenderAdditionalGuardedFolders                                             = @("C:\ProgramData\Contoso\Records");
            DefenderAdobeReaderLaunchChildProcess                                        = "notConfigured";
            DefenderAdvancedRansomewareProtectionType                                    = "notConfigured";
            DefenderAllowBehaviorMonitoring                                              = $true;
            DefenderAllowCloudProtection                                                 = $true;
            DefenderAllowEndUserAccess                                                   = $true;
            DefenderAllowIntrusionPreventionSystem                                       = $true;
            DefenderAllowOnAccessProtection                                              = $true;
            DefenderAllowRealTimeMonitoring                                              = $true;
            DefenderAllowScanArchiveFiles                                                = $true;
            DefenderAllowScanDownloads                                                   = $true;
            DefenderAllowScanNetworkFiles                                                = $true;
            DefenderAllowScanRemovableDrivesDuringFullScan                               = $true;
            DefenderAllowScanScriptsLoadedInInternetExplorer                             = $true;
            DefenderAttackSurfaceReductionExcludedPaths                                  = @("C:\Program Files\Contoso\LineOfBusiness");
            DefenderBlockPersistenceThroughWmiType                                       = "userDefined";
            DefenderDetectedMalwareActions                                               = MSFT_MicrosoftGraphdefenderDetectedMalwareActions{
                HighSeverity     = "quarantine"
                LowSeverity      = "clean"
                ModerateSeverity = "quarantine"
                SevereSeverity   = "remove"
            };
            DefenderEmailContentExecution                                                = "userDefined";
            DefenderEmailContentExecutionType                                            = "userDefined";
            DefenderExploitProtectionXml                                                 = "PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4NCjxNaXRpZ2F0aW9uUG9saWN5Pg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9IkFjcm9SZDMyLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJBY3JvUmQzMkluZm8uZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9ImNsdmlldy5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iY25mbm90MzIuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9ImV4Y2VsLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJleGNlbGNudi5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iRXh0RXhwb3J0LmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJncmFwaC5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iaWU0dWluaXQuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9ImllaW5zdGFsLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJpZWxvd3V0aWwuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9ImllVW5hdHQuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9ImlleHBsb3JlLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJseW5jLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJtc2FjY2Vzcy5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ibXNjb3JzdncuZXhlIj4NCiAgICA8RXh0ZW5zaW9uUG9pbnRzIERpc2FibGVFeHRlbnNpb25Qb2ludHM9InRydWUiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9Im1zZmVlZHNzeW5jLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJtc2h0YS5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ibXNvYWRmc2IuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9Im1zb2FzYi5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ibXNvaHRtZWQuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9Im1zb3NyZWMuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9Im1zb3htbGVkLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJtc3B1Yi5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ibXNxcnkzMi5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iTXNTZW5zZS5leGUiPg0KICAgIDxFeHRlbnNpb25Qb2ludHMgRGlzYWJsZUV4dGVuc2lvblBvaW50cz0idHJ1ZSIgLz4NCiAgICA8SW1hZ2VMb2FkIFByZWZlclN5c3RlbTMyPSJ0cnVlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJuZ2VuLmV4ZSI+DQogICAgPEV4dGVuc2lvblBvaW50cyBEaXNhYmxlRXh0ZW5zaW9uUG9pbnRzPSJ0cnVlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJuZ2VudGFzay5leGUiPg0KICAgIDxFeHRlbnNpb25Qb2ludHMgRGlzYWJsZUV4dGVuc2lvblBvaW50cz0idHJ1ZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ib25lbm90ZS5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ib25lbm90ZW0uZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9Im9yZ2NoYXJ0LmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJvdXRsb29rLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJwb3dlcnBudC5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iUHJlc2VudGF0aW9uSG9zdC5leGUiPg0KICAgIDxERVAgRW5hYmxlPSJ0cnVlIiBFbXVsYXRlQXRsVGh1bmtzPSJmYWxzZSIgLz4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIEJvdHRvbVVwPSJ0cnVlIiBIaWdoRW50cm9weT0idHJ1ZSIgLz4NCiAgICA8U0VIT1AgRW5hYmxlPSJ0cnVlIiBUZWxlbWV0cnlPbmx5PSJmYWxzZSIgLz4NCiAgICA8SGVhcCBUZXJtaW5hdGVPbkVycm9yPSJ0cnVlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJQcmludERpYWxvZy5leGUiPg0KICAgIDxFeHRlbnNpb25Qb2ludHMgRGlzYWJsZUV4dGVuc2lvblBvaW50cz0idHJ1ZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0iUmRyQ0VGLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJSZHJTZXJ2aWNlc1VwZGF0ZXIuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9InJ1bnRpbWVicm9rZXIuZXhlIj4NCiAgICA8RXh0ZW5zaW9uUG9pbnRzIERpc2FibGVFeHRlbnNpb25Qb2ludHM9InRydWUiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9InNjYW5vc3QuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9InNjYW5wc3QuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9InNkeGhlbHBlci5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQogIDxBcHBDb25maWcgRXhlY3V0YWJsZT0ic2VsZmNlcnQuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9InNldGxhbmcuZXhlIj4NCiAgICA8QVNMUiBGb3JjZVJlbG9jYXRlSW1hZ2VzPSJ0cnVlIiBSZXF1aXJlSW5mbz0iZmFsc2UiIC8+DQogIDwvQXBwQ29uZmlnPg0KICA8QXBwQ29uZmlnIEV4ZWN1dGFibGU9IlN5c3RlbVNldHRpbmdzLmV4ZSI+DQogICAgPEV4dGVuc2lvblBvaW50cyBEaXNhYmxlRXh0ZW5zaW9uUG9pbnRzPSJ0cnVlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJ3aW53b3JkLmV4ZSI+DQogICAgPEFTTFIgRm9yY2VSZWxvY2F0ZUltYWdlcz0idHJ1ZSIgUmVxdWlyZUluZm89ImZhbHNlIiAvPg0KICA8L0FwcENvbmZpZz4NCiAgPEFwcENvbmZpZyBFeGVjdXRhYmxlPSJ3b3JkY29udi5leGUiPg0KICAgIDxBU0xSIEZvcmNlUmVsb2NhdGVJbWFnZXM9InRydWUiIFJlcXVpcmVJbmZvPSJmYWxzZSIgLz4NCiAgPC9BcHBDb25maWc+DQo8L01pdGlnYXRpb25Qb2xpY3k+";
            DefenderExploitProtectionXmlFileName                                         = "Settings.xml";
            DefenderFileExtensionsToExclude                                              = @("mdb", "ldb");
            DefenderFilesAndFoldersToExclude                                             = @("C:\Program Files\Contoso\LineOfBusiness\Cache");
            DefenderGuardedFoldersAllowedAppPaths                                        = @("C:\Program Files\Contoso\LineOfBusiness\Contoso.Ledger.exe");
            DefenderGuardMyFoldersType                                                   = "auditMode";
            DefenderNetworkProtectionType                                                = "enable";
            DefenderOfficeAppsExecutableContentCreationOrLaunch                          = "userDefined";
            DefenderOfficeAppsExecutableContentCreationOrLaunchType                      = "userDefined";
            DefenderOfficeAppsLaunchChildProcess                                         = "userDefined";
            DefenderOfficeAppsLaunchChildProcessType                                     = "userDefined";
            DefenderOfficeAppsOtherProcessInjection                                      = "userDefined";
            DefenderOfficeAppsOtherProcessInjectionType                                  = "userDefined";
            DefenderOfficeCommunicationAppsLaunchChildProcess                            = "notConfigured";
            DefenderOfficeMacroCodeAllowWin32Imports                                     = "userDefined";
            DefenderOfficeMacroCodeAllowWin32ImportsType                                 = "userDefined";
            DefenderPreventCredentialStealingType                                        = "enable";
            DefenderProcessCreation                                                      = "userDefined";
            DefenderProcessCreationType                                                  = "userDefined";
            DefenderProcessesToExclude                                                   = @("ContosoLedgerSync.exe");
            DefenderScheduledQuickScanTime                                               = "12:00:00";
            DefenderScheduledScanTime                                                    = "02:00:00";
            DefenderScriptDownloadedPayloadExecution                                     = "userDefined";
            DefenderScriptDownloadedPayloadExecutionType                                 = "userDefined";
            DefenderScriptObfuscatedMacroCode                                            = "userDefined";
            DefenderScriptObfuscatedMacroCodeType                                        = "userDefined";
            DefenderSecurityCenterBlockExploitProtectionOverride                         = $False;
            DefenderSecurityCenterDisableAccountUI                                       = $False;
            DefenderSecurityCenterDisableAppBrowserUI                                    = $false;
            DefenderSecurityCenterDisableClearTpmUI                                      = $True;
            DefenderSecurityCenterDisableFamilyUI                                        = $False;
            DefenderSecurityCenterDisableHardwareUI                                      = $True;
            DefenderSecurityCenterDisableHealthUI                                        = $False;
            DefenderSecurityCenterDisableNetworkUI                                       = $False;
            DefenderSecurityCenterDisableNotificationAreaUI                              = $False;
            DefenderSecurityCenterDisableRansomwareUI                                    = $False;
            DefenderSecurityCenterDisableSecureBootUI                                    = $false;
            DefenderSecurityCenterDisableTroubleshootingUI                               = $false;
            DefenderSecurityCenterDisableVirusUI                                         = $False;
            DefenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI                   = $True;
            DefenderSecurityCenterHelpEmail                                              = "securityhelpdesk@contoso.com";
            DefenderSecurityCenterHelpPhone                                              = "+1 425 555 0143";
            DefenderSecurityCenterHelpURL                                                = "https://intranet.contoso.com/security/support";
            DefenderSecurityCenterITContactDisplay                                       = "displayInAppAndInNotifications";
            DefenderSecurityCenterNotificationsFromApp                                   = "blockNoncriticalNotifications";
            DefenderSecurityCenterOrganizationDisplayName                                = "Contoso IT Security";
            DefenderSignatureUpdateIntervalInHours                                       = 4;
            DefenderUntrustedExecutable                                                  = "userDefined";
            DefenderUntrustedExecutableType                                              = "userDefined";
            DefenderUntrustedUSBProcess                                                  = "userDefined";
            DefenderUntrustedUSBProcessType                                              = "userDefined";
            Description                                                                  = "Baseline endpoint protection for corporate Windows 10 workstations";
            DeviceGuardEnableSecureBootWithDMA                                           = $True;
            DeviceGuardEnableVirtualizationBasedSecurity                                 = $True;
            DeviceGuardLaunchSystemGuard                                                 = "notConfigured";
            DeviceGuardLocalSystemAuthorityCredentialGuardSettings                       = "enableWithoutUEFILock";
            DeviceGuardSecureBootWithDMA                                                 = "notConfigured";
            DeviceManagementApplicabilityRuleDeviceMode                                  = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition                                   = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Education editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Education")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion                                   = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 22H2 or later"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                                                  = "Endpoint Protection - Windows 10 Baseline";
            DmaGuardDeviceEnumerationPolicy                                              = "deviceDefault";
            Ensure                                                                       = "Present";
            FirewallBlockStatefulFTP                                                     = $true;
            FirewallCertificateRevocationListCheckMethod                                 = "deviceDefault";
            FirewallIdleTimeoutForSecurityAssociationInSeconds                           = 300;
            FirewallIPSecExemptionsAllowDHCP                                             = $False;
            FirewallIPSecExemptionsAllowICMP                                             = $False;
            FirewallIPSecExemptionsAllowNeighborDiscovery                                = $False;
            FirewallIPSecExemptionsAllowRouterDiscovery                                  = $False;
            FirewallIPSecExemptionsNone                                                  = $False;
            FirewallMergeKeyingModuleSettings                                            = $true;
            FirewallPacketQueueingMethod                                                 = "deviceDefault";
            FirewallPreSharedKeyEncodingMethod                                           = "deviceDefault";
            FirewallProfileDomain                                                        = MSFT_MicrosoftGraphwindowsFirewallNetworkProfile{
                PolicyRulesFromGroupPolicyNotMerged                = $False
                InboundNotificationsBlocked                        = $True
                OutboundConnectionsRequired                        = $True
                GlobalPortRulesFromGroupPolicyNotMerged            = $True
                ConnectionSecurityRulesFromGroupPolicyNotMerged    = $True
                UnicastResponsesToMulticastBroadcastsRequired      = $True
                PolicyRulesFromGroupPolicyMerged                   = $False
                UnicastResponsesToMulticastBroadcastsBlocked       = $False
                IncomingTrafficRequired                            = $False
                IncomingTrafficBlocked                             = $True
                ConnectionSecurityRulesFromGroupPolicyMerged       = $False
                StealthModeRequired                                = $False
                InboundNotificationsRequired                       = $False
                AuthorizedApplicationRulesFromGroupPolicyMerged    = $False
                InboundConnectionsBlocked                          = $True
                OutboundConnectionsBlocked                         = $False
                StealthModeBlocked                                 = $True
                GlobalPortRulesFromGroupPolicyMerged               = $False
                SecuredPacketExemptionBlocked                      = $False
                SecuredPacketExemptionAllowed                      = $False
                InboundConnectionsRequired                         = $False
                FirewallEnabled                                    = 'allowed'
                AuthorizedApplicationRulesFromGroupPolicyNotMerged = $True
            };
            FirewallProfilePrivate                                                       = MSFT_MicrosoftGraphwindowsFirewallNetworkProfile{
                AuthorizedApplicationRulesFromGroupPolicyMerged    = $false
                AuthorizedApplicationRulesFromGroupPolicyNotMerged = $true
                ConnectionSecurityRulesFromGroupPolicyMerged       = $false
                ConnectionSecurityRulesFromGroupPolicyNotMerged    = $true
                FirewallEnabled                                    = "allowed"
                GlobalPortRulesFromGroupPolicyMerged               = $false
                GlobalPortRulesFromGroupPolicyNotMerged            = $true
                InboundConnectionsBlocked                          = $true
                InboundConnectionsRequired                         = $false
                InboundNotificationsBlocked                        = $true
                InboundNotificationsRequired                       = $false
                IncomingTrafficBlocked                             = $true
                IncomingTrafficRequired                            = $false
                OutboundConnectionsBlocked                         = $false
                OutboundConnectionsRequired                        = $true
                PolicyRulesFromGroupPolicyMerged                   = $false
                PolicyRulesFromGroupPolicyNotMerged                = $true
                SecuredPacketExemptionAllowed                      = $true
                SecuredPacketExemptionBlocked                      = $false
                StealthModeBlocked                                 = $false
                StealthModeRequired                                = $true
                UnicastResponsesToMulticastBroadcastsBlocked       = $false
                UnicastResponsesToMulticastBroadcastsRequired      = $true
            };
            FirewallProfilePublic                                                        = MSFT_MicrosoftGraphwindowsFirewallNetworkProfile{
                AuthorizedApplicationRulesFromGroupPolicyMerged    = $false
                AuthorizedApplicationRulesFromGroupPolicyNotMerged = $true
                ConnectionSecurityRulesFromGroupPolicyMerged       = $false
                ConnectionSecurityRulesFromGroupPolicyNotMerged    = $true
                FirewallEnabled                                    = "allowed"
                GlobalPortRulesFromGroupPolicyMerged               = $false
                GlobalPortRulesFromGroupPolicyNotMerged            = $true
                InboundConnectionsBlocked                          = $true
                InboundConnectionsRequired                         = $false
                InboundNotificationsBlocked                        = $true
                InboundNotificationsRequired                       = $false
                IncomingTrafficBlocked                             = $true
                IncomingTrafficRequired                            = $false
                OutboundConnectionsBlocked                         = $false
                OutboundConnectionsRequired                        = $true
                PolicyRulesFromGroupPolicyMerged                   = $false
                PolicyRulesFromGroupPolicyNotMerged                = $true
                SecuredPacketExemptionAllowed                      = $false
                SecuredPacketExemptionBlocked                      = $true
                StealthModeBlocked                                 = $false
                StealthModeRequired                                = $true
                UnicastResponsesToMulticastBroadcastsBlocked       = $true
                UnicastResponsesToMulticastBroadcastsRequired      = $false
            };
            FirewallRules                                                                = @(
                MSFT_MicrosoftGraphwindowsFirewallRule{
                    Action           = 'allowed'
                    InterfaceTypes   = 'notConfigured'
                    DisplayName      = 'ICMP'
                    TrafficDirection = 'in'
                    ProfileTypes     = 'domain'
                    EdgeTraversal    = 'notConfigured'
                }
            );
            LanManagerAuthenticationLevel                                                = "lmNtlmAndNtlmV2";
            LanManagerWorkstationDisableInsecureGuestLogons                              = $False;
            LocalSecurityOptionsAdministratorAccountName                                 = "CorpAdmin";
            LocalSecurityOptionsAdministratorElevationPromptBehavior                     = "notConfigured";
            LocalSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares          = $False;
            LocalSecurityOptionsAllowPKU2UAuthenticationRequests                         = $False;
            LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManager                = "O:BAG:BAD:(A;;RC;;;BA)";
            LocalSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool      = $False;
            LocalSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn              = $True;
            LocalSecurityOptionsAllowUIAccessApplicationElevation                        = $False;
            LocalSecurityOptionsAllowUIAccessApplicationsForSecureLocations              = $False;
            LocalSecurityOptionsAllowUndockWithoutHavingToLogon                          = $True;
            LocalSecurityOptionsBlockMicrosoftAccounts                                   = $True;
            LocalSecurityOptionsBlockRemoteLogonWithBlankPassword                        = $True;
            LocalSecurityOptionsBlockRemoteOpticalDriveAccess                            = $True;
            LocalSecurityOptionsBlockUsersInstallingPrinterDrivers                       = $True;
            LocalSecurityOptionsClearVirtualMemoryPageFile                               = $True;
            LocalSecurityOptionsClientDigitallySignCommunicationsAlways                  = $False;
            LocalSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers      = $False;
            LocalSecurityOptionsDetectApplicationInstallationsAndPromptForElevation      = $False;
            LocalSecurityOptionsDisableAdministratorAccount                              = $True;
            LocalSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees   = $False;
            LocalSecurityOptionsDisableGuestAccount                                      = $True;
            LocalSecurityOptionsDisableServerDigitallySignCommunicationsAlways           = $False;
            LocalSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees   = $False;
            LocalSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts              = $True;
            LocalSecurityOptionsDoNotRequireCtrlAltDel                                   = $True;
            LocalSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange        = $False;
            LocalSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser                = "administrators";
            LocalSecurityOptionsGuestAccountName                                         = "CorpVisitor";
            LocalSecurityOptionsHideLastSignedInUser                                     = $False;
            LocalSecurityOptionsHideUsernameAtSignIn                                     = $False;
            LocalSecurityOptionsInformationDisplayedOnLockScreen                         = "notConfigured";
            LocalSecurityOptionsInformationShownOnLockScreen                             = "notConfigured";
            LocalSecurityOptionsLogOnMessageText                                         = "This device is provided for business use. Activity may be monitored in line with company policy.";
            LocalSecurityOptionsLogOnMessageTitle                                        = "Authorised use only";
            LocalSecurityOptionsMachineInactivityLimit                                   = 15;
            LocalSecurityOptionsMachineInactivityLimitInMinutes                          = 15;
            LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients             = "none";
            LocalSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers             = "none";
            LocalSecurityOptionsOnlyElevateSignedExecutables                             = $False;
            LocalSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares             = $True;
            LocalSecurityOptionsSmartCardRemovalBehavior                                 = "lockWorkstation";
            LocalSecurityOptionsStandardUserElevationPromptBehavior                      = "notConfigured";
            LocalSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation           = $False;
            LocalSecurityOptionsUseAdminApprovalMode                                     = $False;
            LocalSecurityOptionsUseAdminApprovalModeForAdministrators                    = $False;
            LocalSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations = $False;
            RoleScopeTagIds                                                              = @("0");
            SmartScreenBlockOverrideForFiles                                             = $True;
            SmartScreenEnableInShell                                                     = $True;
            UserRightsAccessCredentialManagerAsTrustedCaller                             = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = 'allowed'
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = 'NT AUTHORITY\Local service'
                        SecurityIdentifier = '*S-1-5-19'
                    }
                )
            };
            UserRightsActAsPartOfTheOperatingSystem                                      = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State = "allowed"
            };
            UserRightsAllowAccessFromNetwork                                             = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Authenticated Users"
                        SecurityIdentifier = "*S-1-5-11"
                    }
                )
            };
            UserRightsBackupData                                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Backup Operators"
                        SecurityIdentifier = "*S-1-5-32-551"
                    }
                )
            };
            UserRightsBlockAccessFromNetwork                                             = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "blocked"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Guests"
                        SecurityIdentifier = "*S-1-5-32-546"
                    }
                )
            };
            UserRightsChangeSystemTime                                                   = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Local service"
                        SecurityIdentifier = "*S-1-5-19"
                    }
                )
            };
            UserRightsCreateGlobalObjects                                                = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Service"
                        SecurityIdentifier = "*S-1-5-6"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Local service"
                        SecurityIdentifier = "*S-1-5-19"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Network service"
                        SecurityIdentifier = "*S-1-5-20"
                    }
                )
            };
            UserRightsCreatePageFile                                                     = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsCreatePermanentSharedObjects                                       = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State = "allowed"
            };
            UserRightsCreateSymbolicLinks                                                = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsCreateToken                                                        = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State = "allowed"
            };
            UserRightsDebugPrograms                                                      = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsDelegation                                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsDenyLocalLogOn                                                     = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "blocked"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Guests"
                        SecurityIdentifier = "*S-1-5-32-546"
                    }
                )
            };
            UserRightsGenerateSecurityAudits                                             = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Local service"
                        SecurityIdentifier = "*S-1-5-19"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Network service"
                        SecurityIdentifier = "*S-1-5-20"
                    }
                )
            };
            UserRightsImpersonateClient                                                  = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Service"
                        SecurityIdentifier = "*S-1-5-6"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Local service"
                        SecurityIdentifier = "*S-1-5-19"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "NT AUTHORITY\Network service"
                        SecurityIdentifier = "*S-1-5-20"
                    }
                )
            };
            UserRightsIncreaseSchedulingPriority                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsLoadUnloadDrivers                                                  = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsLocalLogOn                                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Users"
                        SecurityIdentifier = "*S-1-5-32-545"
                    }
                )
            };
            UserRightsLockMemory                                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State = "allowed"
            };
            UserRightsManageAuditingAndSecurityLogs                                      = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsManageVolumes                                                      = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsModifyFirmwareEnvironment                                          = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsModifyObjectLabels                                                 = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State = "allowed"
            };
            UserRightsProfileSingleProcess                                               = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsRemoteDesktopServicesLogOn                                         = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "blocked"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Guests"
                        SecurityIdentifier = "*S-1-5-32-546"
                    }
                )
            };
            UserRightsRemoteShutdown                                                     = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            UserRightsRestoreData                                                        = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Backup Operators"
                        SecurityIdentifier = "*S-1-5-32-551"
                    }
                )
            };
            UserRightsTakeOwnership                                                      = MSFT_MicrosoftGraphdeviceManagementUserRightsSetting{
                State              = "allowed"
                LocalUsersOrGroups = @(
                    MSFT_MicrosoftGraphDeviceManagementUserRightsLocalUserOrGroup{
                        Name               = "BUILTIN\Administrators"
                        SecurityIdentifier = "*S-1-5-32-544"
                    }
                )
            };
            WindowsDefenderTamperProtection                                              = "enable";
            XboxServicesAccessoryManagementServiceStartupMode                            = "manual";
            XboxServicesEnableXboxGameSaveTask                                           = $True;
            XboxServicesLiveAuthManagerServiceStartupMode                                = "manual";
            XboxServicesLiveGameSaveServiceStartupMode                                   = "manual";
            XboxServicesLiveNetworkingServiceStartupMode                                 = "manual";
            ApplicationId                                                                = $ApplicationId;
            TenantId                                                                     = $TenantId;
            CertificateThumbprint                                                        = $CertificateThumbprint;
        }
    }
}
