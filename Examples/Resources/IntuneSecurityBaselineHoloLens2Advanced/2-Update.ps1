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
        IntuneSecurityBaselineHoloLens2Advanced 'IntuneSecurityBaselineHoloLens2Advanced-Example'
        {
            DisplayName                                                  = 'HoloLens 2 Advanced Baseline'
            Description                                                  = "Locks down shared HoloLens 2 headsets used by the field engineering and quality inspection teams" # Updated Property
            RoleScopeTagIds                                              = @("0")
            DeletionPolicy                                               = 2
            EnableProfileManager                                         = "true"
            ProfileInactivityThreshold                                   = 30
            StorageCapacityStartDeletion                                 = 90
            StorageCapacityStopDeletion                                  = 80
            AllowMicrosoftAccountConnection                              = 0
            VideoPowerDownTimeOutAC_2                                    = 1
            EnterVideoACPowerDownTimeOut                                 = 300
            AllowAutofill                                                = 0
            AllowCookies                                                 = 1
            AllowDoNotTrack                                              = 1
            AllowPasswordManager                                         = 0
            AllowPopups                                                  = 1
            AllowSearchSuggestionsinAddressBar                           = 0
            AllowSmartScreen                                             = 1
            AllowBluetooth                                               = 2
            AllowUSBConnection                                           = 0
            DevicePasswordEnabled                                        = 0
            DevicePasswordExpiration                                     = 90
            MinDevicePasswordLength                                      = 6
            AlphanumericDevicePasswordRequired                           = 0
            MaxDevicePasswordFailedAttempts                              = 10
            MinDevicePasswordComplexCharacters                           = 3
            MaxInactivityTimeDeviceLock                                  = 5
            DevicePasswordHistory                                        = 5
            AllowSimpleDevicePassword                                    = 0
            AllowManualMDMUnenrollment                                   = 0
            AllowAllTrustedApps                                          = 0
            AllowAppStoreAutoUpdate                                      = 1
            AllowDeveloperUnlock                                         = 0
            BlockThirdPartyCookies                                       = 1
            ConfigureDoNotTrack                                          = 1
            MicrosoftEdge_ContentSettings_DefaultPopupsSetting           = 1
            DefaultPopupsSetting_DefaultPopupsSetting                    = 2
            AutofillAddressEnabled                                       = 0
            AutofillCreditCardEnabled                                    = 0
            SearchSuggestEnabled                                         = 0
            ExtensionInstallBlocklist                                    = 1
            ExtensionInstallBlocklistDesc                                = @("*")
            MicrosoftEdge_PasswordManager_PrimaryPasswordSetting         = 1
            PrimaryPasswordSetting_PrimaryPasswordSetting                = 3
            PasswordManagerEnabled                                       = 0
            SmartScreenEnabled                                           = 1
            AADGroupMembershipCacheValidityInDays                        = 7
            LetAppsAccessAccountInfo                                     = 2
            LetAppsAccessAccountInfo_ForceAllowTheseApps                 = @("Microsoft.MicrosoftRemoteAssist_8wekyb3d8bbwe")
            LetAppsAccessBackgroundSpatialPerception                     = 1
            LetAppsAccessBackgroundSpatialPerception_ForceAllowTheseApps = @("Microsoft.MicrosoftRemoteAssist_8wekyb3d8bbwe")
            LetAppsAccessCamera                                          = 1
            LetAppsAccessCamera_ForceAllowTheseApps                      = @("Microsoft.MicrosoftRemoteAssist_8wekyb3d8bbwe")
            LetAppsAccessMicrophone                                      = 1
            LetAppsAccessMicrophone_ForceAllowTheseApps                  = @("Microsoft.MicrosoftRemoteAssist_8wekyb3d8bbwe")
            AllowSearchToUseLocation                                     = 0
            AllowAddProvisioningPackage                                  = 0
            AllowVPN                                                     = 0
            PageVisibilityList                                           = "hide:network-proxy;network-vpn;developers"
            AllowStorageCard                                             = 0
            AllowTelemetry                                               = 1
            AllowManualWiFiConfiguration                                 = 0
            EnablePinRecovery                                            = "true"
            TPM12                                                        = "false"
            Digits                                                       = 1
            Expiration                                                   = 0
            History                                                      = 5
            LowercaseLetters                                             = 2
            MaximumPINLength                                             = 12
            MinimumPINLength                                             = 6
            SpecialCharacters                                            = 2
            UppercaseLetters                                             = 2
            RequireSecurityDevice                                        = "true"
            UseCertificateForOnPremAuth                                  = "false"
            UseHelloCertificatesAsSmartCardCertificates                  = "false"
            UsePassportForWork                                           = "true"
            AllowUpdateService                                           = 1
            ManagePreviewBuilds                                          = 0
            RequireNetworkInOOBE                                         = "true"
            Assignments                                                  = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    groupDisplayName                           = "Intune Pilot Devices"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
            )
            Ensure                                                       = 'Present'
            ApplicationId                                                = $ApplicationId
            TenantId                                                     = $TenantId
            CertificateThumbprint                                        = $CertificateThumbprint
        }
    }
}
