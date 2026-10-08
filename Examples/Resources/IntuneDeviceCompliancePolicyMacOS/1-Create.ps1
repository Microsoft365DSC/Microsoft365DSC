<#
This example creates a new Device Comliance Policy for MacOS.
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
        IntuneDeviceCompliancePolicyMacOS 'IntuneDeviceCompliancePolicyMacOS-Example'
        {
            DisplayName                                 = 'macOS Device Compliance'
            Description                                 = 'Baseline compliance requirements for corporate Macs'
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
            PasswordExpirationDays                      = 365
            PasswordMinimumLength                       = 6
            PasswordMinutesOfInactivityBeforeLock       = 5
            PasswordPreviousPasswordBlockCount          = 13
            PasswordMinimumCharacterSetCount            = 1
            PasswordRequiredType                        = 'DeviceDefault'
            OsMinimumVersion                            = '14.0'
            OsMaximumVersion                            = '26.0'
            OsMinimumBuildVersion                       = '23A344'
            OsMaximumBuildVersion                       = '25A354'
            SystemIntegrityProtectionEnabled            = $False
            DeviceThreatProtectionEnabled               = $False
            DeviceThreatProtectionRequiredSecurityLevel = 'Unavailable'
            AdvancedThreatProtectionRequiredSecurityLevel = 'Unavailable'
            StorageRequireEncryption                    = $False
            FirewallEnabled                             = $False
            FirewallBlockAllIncoming                    = $False
            FirewallEnableStealthMode                   = $False
            GatekeeperAllowedAppSource                  = 'macAppStoreAndIdentifiedDevelopers'
            ScheduledActionsForRule                     = @(
                MSFT_ScheduledActionConfigurations{
                    actionType       = 'block'
                    gracePeriodHours = 24
                }
            )
            Ensure                                      = 'Present'
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
