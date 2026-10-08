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
        IntuneDiskEncryptionWindows10 'IntuneDiskEncryptionWindows10-Example'
        {
            DisplayName                                     = 'Disk Encryption'
            Description                                     = 'BitLocker baseline for corporate Windows laptops'
            RoleScopeTagIds                                 = @('0')
            RequireDeviceEncryption                         = '1'
            AllowWarningForOtherDiskEncryption              = '0'
            AllowStandardUserEncryption                     = '1'
            ConfigureRecoveryPasswordRotation               = '1'
            EncryptionMethodWithXts_Name                    = '1'
            EncryptionMethodWithXtsOsDropDown_Name          = '7'
            EncryptionMethodWithXtsFdvDropDown_Name         = '7'
            EncryptionMethodWithXtsRdvDropDown_Name         = '4'
            IdentificationField_Name                        = '1'
            IdentificationField                             = 'Contoso'
            SecIdentificationField                          = 'Contoso Field Services'
            OSEncryptionType_Name                           = '1'
            OSEncryptionTypeDropDown_Name                   = '1'
            ConfigureAdvancedStartup_Name                   = '1'
            ConfigureNonTPMStartupKeyUsage_Name             = '0'
            ConfigureTPMStartupKeyUsageDropDown_Name        = '0'
            ConfigureTPMPINKeyUsageDropDown_Name            = '0'
            ConfigureTPMUsageDropDown_Name                  = '2'
            ConfigurePINUsageDropDown_Name                  = '2'
            MinimumPINLength_Name                           = '1'
            MinPINLength                                    = 8
            EnhancedPIN_Name                                = '1'
            DisallowStandardUsersCanChangePIN_Name          = '1'
            EnablePreBootPinExceptionOnDECapableDevice_Name = '0'
            EnablePrebootInputProtectorsOnSlates_Name       = '1'
            OSRecoveryUsage_Name                            = '1'
            OSAllowDRA_Name                                 = '1'
            OSRecoveryPasswordUsageDropDown_Name            = '1'
            OSRecoveryKeyUsageDropDown_Name                 = '0'
            OSHideRecoveryPage_Name                         = '1'
            OSActiveDirectoryBackup_Name                    = '1'
            OSActiveDirectoryBackupDropDown_Name            = '1'
            OSRequireActiveDirectoryBackup_Name             = '1'
            PrebootRecoveryInfo_Name                        = '1'
            PrebootRecoveryInfoDropDown_Name                = '2'
            RecoveryMessage_Input                           = 'Your device is protected by BitLocker. Call the Contoso service desk on +1 425 555 0100 for a recovery key.'
            RecoveryUrl_Input                               = 'https://servicedesk.contoso.com/bitlocker'
            FDVEncryptionType_Name                          = '1'
            FDVEncryptionTypeDropDown_Name                  = '1'
            FDVRecoveryUsage_Name                           = '1'
            FDVAllowDRA_Name                                = '1'
            FDVRecoveryPasswordUsageDropDown_Name           = '1'
            FDVRecoveryKeyUsageDropDown_Name                = '0'
            FDVHideRecoveryPage_Name                        = '1'
            FDVActiveDirectoryBackup_Name                   = '1'
            FDVActiveDirectoryBackupDropDown_Name           = '1'
            FDVRequireActiveDirectoryBackup_Name            = '1'
            FDVDenyWriteAccess_Name                         = '1'
            RDVConfigureBDE                                 = '1'
            RDVAllowBDE_Name                                = '1'
            RDVDisableBDE_Name                              = '1'
            RDVEncryptionType_Name                          = '1'
            RDVEncryptionTypeDropDown_Name                  = '1'
            RDVDenyWriteAccess_Name                         = '1'
            RDVCrossOrg                                     = '1'
            Assignments                                     = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            )
            Ensure                                          = 'Present'
            ApplicationId                                   = $ApplicationId;
            TenantId                                        = $TenantId;
            CertificateThumbprint                           = $CertificateThumbprint;
        }
    }
}
