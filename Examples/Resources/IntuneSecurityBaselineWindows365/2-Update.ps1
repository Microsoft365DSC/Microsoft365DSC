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
        IntuneSecurityBaselineWindows365 'IntuneSecurityBaselineWindows365-Example'
        {
            DisplayName           = 'Windows 365 Security Baseline'
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            Description           = 'Baseline hardening for Cloud PCs used by remote and contract staff' # Updated Property
            DeviceSettings        = MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365
            {
                Pol_MSS_DisableIPSourceRoutingIPv6           = '1'
                DisableIPSourceRoutingIPv6                   = '0'
                HardenedUNCPaths_Pol_HardenedPaths           = '1'
                pol_hardenedPaths                            = @(
                    MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths{
                        Key   = '\\*\SYSVOL'
                        Value = 'RequireMutualAuthentication=1,RequireIntegrity=1'
                    }
                    MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths{
                        Key   = '\\*\NETLOGON'
                        Value = 'RequireMutualAuthentication=1,RequireIntegrity=1'
                    }
                )
                AllowProtectedCreds                          = '1'
                AppxRuntimeMicrosoftAccountsOptional         = '1'
                BlockExecutionOfPotentiallyObfuscatedScripts = 'block'
                CPL_Personalization_NoLockScreenCamera       = '1'
                CPL_Personalization_NoLockScreenSlideshow    = '1'
                DisableWebPnPDownload_2                      = '1'
                EnumerateAdministrators                      = '0'
                NC_ShowSharedAccessUI                        = '1'
                NoAutoplayfornonVolume                       = '1'
                NoDataExecutionPrevention                    = '0'
                NoHeapTerminationOnCorruption                = '0'
                Pol_MSS_EnableICMPRedirect                   = '0'
                Pol_MSS_NoNameReleaseOnDemand                = '1'
                Pol_SecGuide_0001_SMBv1_Server               = '0'
                Pol_SecGuide_0102_SEHOP                      = '1'
                Pol_SecGuide_0201_LATFP                      = '1'
                Pol_SecGuide_0202_WDigestAuthn               = '0'
                ShellPreventWPWDownload_2                    = '1'
                Turn_Off_Multicast                           = '1'
                WCM_BlockNonDomain                           = '1'
            }
            RoleScopeTagIds       = @('0')
            UserSettings          = MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365
            {
                AllowWindowsSpotlight                               = '1'
                AllowTailoredExperiencesWithDiagnosticData          = '0'
                AllowThirdPartySuggestionsInWindowsSpotlight        = '0'
                AllowWindowsConsumerFeatures                        = '0'
                AllowWindowsSpotlightOnActionCenter                 = '0'
                AllowWindowsSpotlightWindowsWelcomeExperience       = '0'
                AllowWindowsTips                                    = '0'
                ChkBox_PasswordAsk                                  = '0'
                ConfigureWindowsSpotlightOnLockScreen               = '0'
                DefaultPluginsSetting_DefaultPluginsSetting         = '2'
                edge_SSLVersionMin                                  = '1'
                MicrosoftEdge_ContentSettings_DefaultPluginsSetting = '1'
                NoLockScreenToastNotification                       = '1'
                RestrictFormSuggestPW                               = '1'
                SSLVersionMin_SSLVersionMin                         = 'tls1.2'
            }
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
