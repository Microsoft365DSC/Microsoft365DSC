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
        IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10-Example'
        {
            DisplayName                                 = 'WUfB Ring'
            AllowWindows11Upgrade                       = $False
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments
                {
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allLicensedUsersAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments
                {
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Users'
                }
            )
            AutomaticUpdateMode                         = 'autoInstallAtMaintenanceTime'
            AutoRestartNotificationDismissal            = 'notConfigured'
            BusinessReadyUpdatesOnly                    = 'userDefined'
            DeadlineForFeatureUpdatesInDays             = 1
            DeadlineForQualityUpdatesInDays             = 2
            DeadlineGracePeriodInDays                   = 3
            DeliveryOptimizationMode                    = 'userDefined'
            Description                                 = ''
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = 'Standard mode devices only'
                DeviceMode = 'standardConfiguration'
                RuleType   = 'include'
            }
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = 'Enterprise and Professional editions only'
                OsEditionTypes = @('windows10Enterprise', 'windows10Professional')
                RuleType       = 'include'
            }
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = 'Windows 10 22H2 or later'
                MinOSVersion = '10.0.19045.0'
                MaxOSVersion = '10.0.26100.9999'
                RuleType     = 'include'
            }
            DriversExcluded                             = $False
            FeatureUpdatesDeferralPeriodInDays          = 0
            FeatureUpdatesPaused                        = $False
            FeatureUpdatesPauseExpiryDateTime           = '0001-01-01T00:00:00.0000000+00:00'
            FeatureUpdatesRollbackStartDateTime         = '0001-01-01T00:00:00.0000000+00:00'
            FeatureUpdatesRollbackWindowInDays          = 10
            FeatureUpdatesWillBeRolledBack              = $False
            InstallationSchedule                        = MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType {
                ActiveHoursStart = '08:00:00'
                ActiveHoursEnd   = '17:00:00'
                odataType        = '#microsoft.graph.windowsUpdateActiveHoursInstall'
            }
            MicrosoftUpdateServiceAllowed               = $True
            PostponeRebootUntilAfterDeadline            = $False
            PrereleaseFeatures                          = 'userDefined'
            QualityUpdatesDeferralPeriodInDays          = 0
            QualityUpdatesPaused                        = $False
            QualityUpdatesPauseExpiryDateTime           = '0001-01-01T00:00:00.0000000+00:00'
            QualityUpdatesRollbackStartDateTime         = '0001-01-01T00:00:00.0000000+00:00'
            QualityUpdatesWillBeRolledBack              = $False
            SkipChecksBeforeRestart                     = $False
            UpdateNotificationLevel                     = 'defaultNotifications'
            UserPauseAccess                             = 'enabled'
            UserWindowsUpdateScanAccess                 = 'enabled'
            Ensure                                      = 'Present'
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
