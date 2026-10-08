<#
This example creates a new Device Comliance Policy for Windows.
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
        IntuneDeviceCompliancePolicyWindows10 'IntuneDeviceCompliancePolicyWindows10-Example'
        {
            DisplayName                                 = 'Windows 10 Device Compliance'
            Description                                 = 'Baseline compliance requirements for corporate Windows 10 devices'
            RoleScopeTagIds                             = @('0')
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Excluded Devices'
                }
            )
            PasswordRequired                            = $False
            PasswordBlockSimple                         = $False
            PasswordRequiredToUnlockFromIdle            = $True
            PasswordMinutesOfInactivityBeforeLock       = 15
            PasswordExpirationDays                      = 365
            PasswordMinimumLength                       = 6
            PasswordPreviousPasswordBlockCount          = 13
            PasswordMinimumCharacterSetCount            = 1
            PasswordRequiredType                        = 'DeviceDefault'
            RequireHealthyDeviceReport                  = $True
            OsMinimumVersion                            = '10.0.19045.0'
            OsMaximumVersion                            = '10.0.26100.9999'
            MobileOsMinimumVersion                      = '10.0.19045.0'
            MobileOsMaximumVersion                      = '10.0.26100.9999'
            EarlyLaunchAntiMalwareDriverEnabled         = $False
            BitLockerEnabled                            = $False
            SecureBootEnabled                           = $True
            CodeIntegrityEnabled                        = $True
            FirmwareProtectionEnabled                   = $False
            KernelDmaProtectionEnabled                  = $False
            MemoryIntegrityEnabled                      = $False
            VirtualizationBasedSecurityEnabled          = $False
            StorageRequireEncryption                    = $True
            ActiveFirewallRequired                      = $True
            DefenderEnabled                             = $True
            DefenderVersion                             = '4.18.24080.9'
            SignatureOutOfDate                          = $True
            RtpEnabled                                  = $True
            AntivirusRequired                           = $True
            AntiSpywareRequired                         = $True
            DeviceThreatProtectionEnabled               = $True
            DeviceThreatProtectionRequiredSecurityLevel = 'Medium'
            ConfigurationManagerComplianceRequired      = $False
            TPMRequired                                 = $False
            ValidOperatingSystemBuildRanges             = @(
                MSFT_MicrosoftGraphOperatingSystemVersionRange{
                    Description    = 'Windows 11 24H2'
                    LowestVersion  = '10.0.26100.0'
                    HighestVersion = '10.0.26100.9999'
                }
            )
            WslDistributions                            = @(
                MSFT_MicrosoftGraphWslDistributionConfiguration{
                    Distribution     = 'Ubuntu'
                    MinimumOSVersion = '20.04'
                    MaximumOSVersion = '24.04'
                }
            )
            ScheduledActionsForRule                     = @(
                MSFT_MicrosoftGraphDeviceComplianceScheduledActionsForRuleConfiguration{
                    ActionType       = 'block'
                    GracePeriodHours = 0
                }
            )
            Ensure                                      = 'Present'
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
