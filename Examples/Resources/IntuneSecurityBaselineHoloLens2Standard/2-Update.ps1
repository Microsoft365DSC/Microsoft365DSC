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
        IntuneSecurityBaselineHoloLens2Standard 'IntuneSecurityBaselineHoloLens2Standard-Example'
        {
            DisplayName                                 = 'HoloLens 2 Standard Baseline'
            Description                                 = "Baseline settings for HoloLens 2 headsets shared by the training centre and the onboarding lab" # Updated Property
            RoleScopeTagIds                             = @("0")
            AllowMicrosoftAccountConnection             = 0
            VideoPowerDownTimeOutAC_2                   = 1
            EnterVideoACPowerDownTimeOut                = 300
            AllowCookies                                = 1
            AllowPasswordManager                        = 0
            AllowSmartScreen                            = 1
            AllowUSBConnection                          = 0
            DevicePasswordEnabled                       = 0
            DevicePasswordExpiration                    = 90
            MinDevicePasswordLength                     = 6
            AlphanumericDevicePasswordRequired          = 0
            MaxDevicePasswordFailedAttempts             = 10
            MinDevicePasswordComplexCharacters          = 3
            MaxInactivityTimeDeviceLock                 = 5
            DevicePasswordHistory                       = 5
            AllowSimpleDevicePassword                   = 0
            AllowManualMDMUnenrollment                  = 0
            AllowAllTrustedApps                         = 0
            AllowAppStoreAutoUpdate                     = 1
            AllowDeveloperUnlock                        = 0
            BlockThirdPartyCookies                      = 1
            ExtensionInstallBlocklist                   = 1
            ExtensionInstallBlocklistDesc               = @("*")
            PasswordManagerEnabled                      = 0
            SmartScreenEnabled                          = 1
            AADGroupMembershipCacheValidityInDays       = 7
            AllowVPN                                    = 0
            PageVisibilityList                          = "hide:network-proxy;network-vpn;developers"
            AllowStorageCard                            = 0
            EnablePinRecovery                           = "true"
            TPM12                                       = "false"
            Digits                                      = 1
            Expiration                                  = 0
            History                                     = 5
            LowercaseLetters                            = 2
            MaximumPINLength                            = 12
            MinimumPINLength                            = 6
            SpecialCharacters                           = 2
            UppercaseLetters                            = 2
            RequireSecurityDevice                       = "true"
            UseCertificateForOnPremAuth                 = "false"
            UseHelloCertificatesAsSmartCardCertificates = "false"
            UsePassportForWork                          = "true"
            AllowUpdateService                          = "1"
            ManagePreviewBuilds                         = "0"
            RequireNetworkInOOBE                        = "true"
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    groupDisplayName                           = "Intune Pilot Devices"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
            )
            Ensure                                      = 'Present'
            ApplicationId                               = $ApplicationId
            TenantId                                    = $TenantId
            CertificateThumbprint                       = $CertificateThumbprint
        }
    }
}
