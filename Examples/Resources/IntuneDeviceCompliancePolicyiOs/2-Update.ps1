<#
This example creates a new Device Compliance Policy for iOs devices
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
        IntuneDeviceCompliancePolicyiOs 'IntuneDeviceCompliancePolicyiOs-Example'
        {
            DisplayName                                    = 'iOS Device Compliance'
            Description                                    = 'Baseline compliance requirements for corporate iPhones and iPads'
            RoleScopeTagIds                                = @('0')
            Assignments                                    = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Excluded Devices'
                }
            )
            PasscodeBlockSimple                            = $True
            PasscodeExpirationDays                         = 365
            PasscodeMinimumLength                          = 8 # Updated Property
            PasscodeMinutesOfInactivityBeforeLock          = 5
            PasscodeMinutesOfInactivityBeforeScreenTimeout = 5
            PasscodePreviousPasscodeBlockCount             = 3
            PasscodeMinimumCharacterSetCount               = 2
            PasscodeRequiredType                           = 'alphanumeric'
            PasscodeRequired                               = $True
            OsMinimumVersion                               = '16.0'
            OsMaximumVersion                               = '18.5'
            OsMinimumBuildVersion                          = '20A362'
            OsMaximumBuildVersion                          = '22F76'
            ScheduledActionsForRule                        = @(
                MSFT_ScheduledActionConfigurations{
                    actionType       = 'block'
                    gracePeriodHours = 24
                }
            )
            SecurityBlockJailbrokenDevices                 = $True
            DeviceThreatProtectionEnabled                  = $True
            DeviceThreatProtectionRequiredSecurityLevel    = 'medium'
            AdvancedThreatProtectionRequiredSecurityLevel  = 'medium'
            ManagedEmailProfileRequired                    = $True
            RestrictedApps                                 = @(
                MSFT_appListItem{
                    name        = 'Facebook'
                    publisher   = 'Meta Platforms, Inc.'
                    appStoreUrl = 'https://apps.apple.com/app/facebook/id284882215'
                    appId       = 'com.facebook.Facebook'
                }
            )
            Ensure                                         = 'Present'
            ApplicationId                                  = $ApplicationId;
            TenantId                                       = $TenantId;
            CertificateThumbprint                          = $CertificateThumbprint;
        }
    }
}
