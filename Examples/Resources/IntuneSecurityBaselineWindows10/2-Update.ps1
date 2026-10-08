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
        IntuneSecurityBaselineWindows10 'IntuneSecurityBaselineWindows10-Example'
        {
            DisplayName           = 'Windows 10 Security Baseline'
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
            Description           = 'Baseline hardening for corporate Windows workstations, reviewed each quarter' # Updated Property
            DeviceSettings        = MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows10
            {
                Pol_MSS_DisableIPSourceRoutingIPv6           = '1'
                DisableIPSourceRoutingIPv6                   = '0'
                BlockExecutionOfPotentiallyObfuscatedScripts = 'block'
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
                ACPromptForPasswordOnResume_2                = '1'
                AllowCustomSSPsAPs                           = '0'
                AllowProtectedCreds                          = '1'
                AllowStandbyStatesAC_2                       = '0'
                AllowStandbyStatesDC_2                       = '0'
                AppxRuntimeMicrosoftAccountsOptional         = '1'
                CPL_Personalization_NoLockScreenCamera       = '1'
                CPL_Personalization_NoLockScreenSlideshow    = '1'
                DCPromptForPasswordOnResume_2                = '1'
                DisableWebPnPDownload_2                      = '1'
                EnumerateAdministrators                      = '0'
                FDVDenyWriteAccess_Name                      = '0'
                NC_ShowSharedAccessUI                        = '1'
                NoAutoplayfornonVolume                       = '1'
                NoDataExecutionPrevention                    = '0'
                NoHeapTerminationOnCorruption                = '0'
                Pol_MSS_EnableICMPRedirect                   = '0'
                Pol_MSS_NoNameReleaseOnDemand                = '1'
                Pol_SecGuide_0001_SMBv1_Server               = '0'
                Pol_SecGuide_0102_SEHOP                      = '1'
                Pol_SecGuide_0201_LATFP                      = '1'
                RestrictDriverInstallationToAdministrators   = '1'
                ShellPreventWPWDownload_2                    = '1'
                Turn_Off_Multicast                           = '1'
                WCM_BlockNonDomain                           = '1'
            }
            RoleScopeTagIds       = @('0')
            UserSettings          = MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows10
            {
                AllowWindowsSpotlight                         = '1'
                AllowTailoredExperiencesWithDiagnosticData    = '0'
                AllowThirdPartySuggestionsInWindowsSpotlight  = '0'
                AllowWindowsConsumerFeatures                  = '0'
                AllowWindowsSpotlightOnActionCenter           = '0'
                AllowWindowsSpotlightWindowsWelcomeExperience = '0'
                AllowWindowsTips                              = '0'
                ChkBox_PasswordAsk                            = '0'
                ConfigureWindowsSpotlightOnLockScreen         = '0'
                NoLockScreenToastNotification                 = '1'
                RestrictFormSuggestPW                         = '1'
            }
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
