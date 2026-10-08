using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, allows eligible Windows 10 devices to upgrade to Windows 11. When FALSE, implies the device stays on the existing operating system. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $AllowWindows11Upgrade

    [DscProperty()]
    [System.ComponentModel.Description('The Automatic Update Mode. Possible values are: UserDefined, NotifyDownload, AutoInstallAtMaintenanceTime, AutoInstallAndRebootAtMaintenanceTime, AutoInstallAndRebootAtScheduledTime, AutoInstallAndRebootWithoutEndUserControl, WindowsDefault. UserDefined is the default value, no intent. Returned by default. Query parameters are not supported. Possible values are: userDefined, notifyDownload, autoInstallAtMaintenanceTime, autoInstallAndRebootAtMaintenanceTime, autoInstallAndRebootAtScheduledTime, autoInstallAndRebootWithoutEndUserControl, windowsDefault.')]
    [ValidateSet('userDefined', 'notifyDownload', 'autoInstallAtMaintenanceTime', 'autoInstallAndRebootAtMaintenanceTime', 'autoInstallAndRebootAtScheduledTime', 'autoInstallAndRebootWithoutEndUserControl', 'windowsDefault')]
    [System.String] $AutomaticUpdateMode

    [DscProperty()]
    [System.ComponentModel.Description('Specify the method by which the auto-restart required notification is dismissed. Possible values are: NotConfigured, Automatic, User. Returned by default. Query parameters are not supported. Possible values are: notConfigured, automatic, user, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'automatic', 'user', 'unknownFutureValue')]
    [System.String] $AutoRestartNotificationDismissal

    [DscProperty()]
    [System.ComponentModel.Description('Determines which branch devices will receive their updates from. Possible values are: UserDefined, All, BusinessReadyOnly, WindowsInsiderBuildFast, WindowsInsiderBuildSlow, WindowsInsiderBuildRelease. Returned by default. Query parameters are not supported. Possible values are: userDefined, all, businessReadyOnly, windowsInsiderBuildFast, windowsInsiderBuildSlow, windowsInsiderBuildRelease.')]
    [ValidateSet('userDefined', 'all', 'businessReadyOnly', 'windowsInsiderBuildFast', 'windowsInsiderBuildSlow', 'windowsInsiderBuildRelease')]
    [System.String] $BusinessReadyUpdatesOnly

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before feature updates are installed automatically with valid range from 0 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $DeadlineForFeatureUpdatesInDays

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before quality updates are installed automatically with valid range from 0 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $DeadlineForQualityUpdatesInDays

    [DscProperty()]
    [System.ComponentModel.Description('Number of days after deadline until restarts occur automatically with valid range from 0 to 7 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $DeadlineGracePeriodInDays

    [DscProperty()]
    [System.ComponentModel.Description('The Delivery Optimization Mode. Possible values are: UserDefined, HttpOnly, HttpWithPeeringNat, HttpWithPeeringPrivateGroup, HttpWithInternetPeering, SimpleDownload, BypassMode. UserDefined allows the user to set. Returned by default. Query parameters are not supported. Possible values are: userDefined, httpOnly, httpWithPeeringNat, httpWithPeeringPrivateGroup, httpWithInternetPeering, simpleDownload, bypassMode.')]
    [ValidateSet('userDefined', 'httpOnly', 'httpWithPeeringNat', 'httpWithPeeringPrivateGroup', 'httpWithInternetPeering', 'simpleDownload', 'bypassMode')]
    [System.String] $DeliveryOptimizationMode

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, excludes Windows update Drivers. When FALSE, does not exclude Windows update Drivers. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $DriversExcluded

    [DscProperty()]
    [System.ComponentModel.Description('Deadline in days before automatically scheduling and executing a pending restart outside of active hours, with valid range from 2 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $EngagedRestartDeadlineInDays

    [DscProperty()]
    [System.ComponentModel.Description('Number of days a user can snooze Engaged Restart reminder notifications with valid range from 1 to 3 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $EngagedRestartSnoozeScheduleInDays

    [DscProperty()]
    [System.ComponentModel.Description('Number of days before transitioning from Auto Restarts scheduled outside of active hours to Engaged Restart, which requires the user to schedule, with valid range from 0 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $EngagedRestartTransitionScheduleInDays

    [DscProperty()]
    [System.ComponentModel.Description('Defer Feature Updates by these many days with valid range from 0 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $FeatureUpdatesDeferralPeriodInDays

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, assigned devices are paused from receiving feature updates for up to 35 days from the time you pause the ring. When FALSE, does not pause Feature Updates. Returned by default. Query parameters are not supported.s')]
    [System.Nullable[System.Boolean]] $FeatureUpdatesPaused

    [DscProperty()]
    [System.ComponentModel.Description('The Feature Updates Pause Expiry datetime. This value is 35 days from the time admin paused or extended the pause for the ring. Returned by default. Query parameters are not supported.')]
    [System.String] $FeatureUpdatesPauseExpiryDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The Feature Updates Pause start date. This value is the time when the admin paused or extended the pause for the ring. Returned by default. Query parameters are not supported. This property is read-only.')]
    [System.String] $FeatureUpdatesPauseStartDate

    [DscProperty()]
    [System.ComponentModel.Description('The Feature Updates Rollback Start datetime.This value is the time when the admin rolled back the Feature update for the ring.Returned by default.Query parameters are not supported.')]
    [System.String] $FeatureUpdatesRollbackStartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The number of days after a Feature Update for which a rollback is valid with valid range from 2 to 60 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $FeatureUpdatesRollbackWindowInDays

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, rollback Feature Updates on the next device check in. When FALSE, do not rollback Feature Updates on the next device check in. Returned by default.Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $FeatureUpdatesWillBeRolledBack

    [DscProperty()]
    [System.ComponentModel.Description('The Installation Schedule. Possible values are: ActiveHoursStart, ActiveHoursEnd, ScheduledInstallDay, ScheduledInstallTime. Returned by default. Query parameters are not supported.')]
    [MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType] $InstallationSchedule

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, allows Microsoft Update Service. When FALSE, does not allow Microsoft Update Service. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $MicrosoftUpdateServiceAllowed

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE the device should wait until deadline for rebooting outside of active hours. When FALSE the device should not wait until deadline for rebooting outside of active hours. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $PostponeRebootUntilAfterDeadline

    [DscProperty()]
    [System.ComponentModel.Description('The Pre-Release Features. Possible values are: UserDefined, SettingsOnly, SettingsAndExperimentations, NotAllowed. UserDefined is the default value, no intent. Returned by default. Query parameters are not supported. Possible values are: userDefined, settingsOnly, settingsAndExperimentations, notAllowed.')]
    [ValidateSet('userDefined', 'settingsOnly', 'settingsAndExperimentations', 'notAllowed')]
    [System.String] $PrereleaseFeatures

    [DscProperty()]
    [System.ComponentModel.Description('Defer Quality Updates by these many days with valid range from 0 to 30 days. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $QualityUpdatesDeferralPeriodInDays

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, assigned devices are paused from receiving quality updates for up to 35 days from the time you pause the ring. When FALSE, does not pause Quality Updates. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $QualityUpdatesPaused

    [DscProperty()]
    [System.ComponentModel.Description('The Quality Updates Pause Expiry datetime. This value is 35 days from the time admin paused or extended the pause for the ring. Returned by default. Query parameters are not supported.')]
    [System.String] $QualityUpdatesPauseExpiryDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The Quality Updates Pause start date. This value is the time when the admin paused or extended the pause for the ring. Returned by default. Query parameters are not supported. This property is read-only.')]
    [System.String] $QualityUpdatesPauseStartDate

    [DscProperty()]
    [System.ComponentModel.Description('The Quality Updates Rollback Start datetime. This value is the time when the admin rolled back the Quality update for the ring. Returned by default. Query parameters are not supported.')]
    [System.String] $QualityUpdatesRollbackStartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, rollback Quality Updates on the next device check in. When FALSE, do not rollback Quality Updates on the next device check in. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $QualityUpdatesWillBeRolledBack

    [DscProperty()]
    [System.ComponentModel.Description('Specify the period for auto-restart imminent warning notifications. Supported values: 15, 30 or 60 (minutes). Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $ScheduleImminentRestartWarningInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Specify the period for auto-restart warning reminder notifications. Supported values: 2, 4, 8, 12 or 24 (hours). Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.UInt32]] $ScheduleRestartWarningInHours

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, skips all checks before restart: Battery level = 40%, User presence, Display Needed, Presentation mode, Full screen mode, phone call state, game mode etc. When FALSE, does not skip all checks before restart. Returned by default. Query parameters are not supported.')]
    [System.Nullable[System.Boolean]] $SkipChecksBeforeRestart

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what Windows Update notifications users see. Possible values are: NotConfigured, DefaultNotifications, RestartWarningsOnly, DisableAllNotifications. Returned by default. Query parameters are not supported. Possible values are: notConfigured, defaultNotifications, restartWarningsOnly, disableAllNotifications, unknownFutureValue.')]
    [ValidateSet('notConfigured', 'defaultNotifications', 'restartWarningsOnly', 'disableAllNotifications', 'unknownFutureValue')]
    [System.String] $UpdateNotificationLevel

    [DscProperty()]
    [System.ComponentModel.Description('Schedule the update installation on the weeks of the month. Possible values are: UserDefined, FirstWeek, SecondWeek, ThirdWeek, FourthWeek, EveryWeek. Returned by default. Query parameters are not supported. Possible values are: userDefined, firstWeek, secondWeek, thirdWeek, fourthWeek, everyWeek, unknownFutureValue.')]
    [ValidateSet('userDefined', 'firstWeek', 'secondWeek', 'thirdWeek', 'fourthWeek', 'everyWeek', 'unknownFutureValue')]
    [System.String] $UpdateWeeks

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to enable end user''s access to pause software updates. Possible values are: NotConfigured, Enabled, Disabled. Returned by default. Query parameters are not supported. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $UserPauseAccess

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to disable user''s access to scan Windows Update. Possible values are: NotConfigured, Enabled, Disabled. Returned by default. Query parameters are not supported. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $UserWindowsUpdateScanAccess

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Window Update For Business Ring Update Profile for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Window Update For Business Ring Update Profile for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Window Update For Business Ring Update Profile for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Window Update For Business Ring Update Profile for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexInstallationSchedule = [ordered]@{}
            if ($null -ne $getValue.installationSchedule.activeHoursEnd)
            {
                $complexInstallationSchedule.Add('ActiveHoursEnd', ([TimeSpan]$getValue.installationSchedule.activeHoursEnd).ToString())
            }
            if ($null -ne $getValue.installationSchedule.activeHoursStart)
            {
                $complexInstallationSchedule.Add('ActiveHoursStart', ([TimeSpan]$getValue.installationSchedule.activeHoursStart).ToString())
            }
            if ($null -ne $getValue.installationSchedule.scheduledInstallDay)
            {
                $complexInstallationSchedule.Add('ScheduledInstallDay', $getValue.installationSchedule.scheduledInstallDay)
            }
            if ($null -ne $getValue.installationSchedule.scheduledInstallTime)
            {
                $complexInstallationSchedule.Add('ScheduledInstallTime', ([TimeSpan]$getValue.installationSchedule.scheduledInstallTime).ToString())
            }
            if ($null -ne $getValue.installationSchedule.'@odata.type')
            {
                $complexInstallationSchedule.Add('odataType', $getValue.installationSchedule.'@odata.type')
            }
            if ($complexInstallationSchedule.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexInstallationSchedule = $null
            }

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }
            #endregion

            #region resource generator code
            $dateFeatureUpdatesPauseExpiryDateTime = $null
            if ($null -ne $getValue.featureUpdatesPauseExpiryDateTime)
            {
                $dateFeatureUpdatesPauseExpiryDateTime = ([DateTimeOffset]$getValue.featureUpdatesPauseExpiryDateTime).ToString('o')
            }

            $dateFeatureUpdatesPauseStartDate = $null
            if ($null -ne $getValue.featureUpdatesPauseStartDate)
            {
                $dateFeatureUpdatesPauseStartDate = ([DateTime]$getValue.featureUpdatesPauseStartDate).ToString('o')
            }

            $dateFeatureUpdatesRollbackStartDateTime = $null
            if ($null -ne $getValue.featureUpdatesRollbackStartDateTime)
            {
                $dateFeatureUpdatesRollbackStartDateTime = ([DateTimeOffset]$getValue.featureUpdatesRollbackStartDateTime).ToString('o')
            }

            $dateQualityUpdatesPauseExpiryDateTime = $null
            if ($null -ne $getValue.qualityUpdatesPauseExpiryDateTime)
            {
                $dateQualityUpdatesPauseExpiryDateTime = ([DateTimeOffset]$getValue.qualityUpdatesPauseExpiryDateTime).ToString('o')
            }

            $dateQualityUpdatesPauseStartDate = $null
            if ($null -ne $getValue.qualityUpdatesPauseStartDate)
            {
                $dateQualityUpdatesPauseStartDate = ([DateTime]$getValue.qualityUpdatesPauseStartDate).ToString('o')
            }

            $dateQualityUpdatesRollbackStartDateTime = $null
            if ($null -ne $getValue.qualityUpdatesRollbackStartDateTime)
            {
                $dateQualityUpdatesRollbackStartDateTime = ([DateTimeOffset]$getValue.qualityUpdatesRollbackStartDateTime).ToString('o')
            }
            #endregion

            $results = @{
                #region resource generator code
                AllowWindows11Upgrade                       = $getValue.allowWindows11Upgrade
                AutomaticUpdateMode                         = $getValue.automaticUpdateMode
                AutoRestartNotificationDismissal            = $getValue.autoRestartNotificationDismissal
                BusinessReadyUpdatesOnly                    = $getValue.businessReadyUpdatesOnly
                DeadlineForFeatureUpdatesInDays             = $getValue.deadlineForFeatureUpdatesInDays
                DeadlineForQualityUpdatesInDays             = $getValue.deadlineForQualityUpdatesInDays
                DeadlineGracePeriodInDays                   = $getValue.deadlineGracePeriodInDays
                DeliveryOptimizationMode                    = $getValue.deliveryOptimizationMode
                DeviceManagementApplicabilityRuleDeviceMode = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition  = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion  = $complexDeviceManagementApplicabilityRuleOsVersion
                DriversExcluded                             = $getValue.driversExcluded
                EngagedRestartDeadlineInDays                = $getValue.engagedRestartDeadlineInDays
                EngagedRestartSnoozeScheduleInDays          = $getValue.engagedRestartSnoozeScheduleInDays
                EngagedRestartTransitionScheduleInDays      = $getValue.engagedRestartTransitionScheduleInDays
                FeatureUpdatesDeferralPeriodInDays          = $getValue.featureUpdatesDeferralPeriodInDays
                FeatureUpdatesPaused                        = $getValue.featureUpdatesPaused
                FeatureUpdatesPauseExpiryDateTime           = $dateFeatureUpdatesPauseExpiryDateTime
                FeatureUpdatesPauseStartDate                = $dateFeatureUpdatesPauseStartDate
                FeatureUpdatesRollbackStartDateTime         = $dateFeatureUpdatesRollbackStartDateTime
                FeatureUpdatesRollbackWindowInDays          = $getValue.featureUpdatesRollbackWindowInDays
                FeatureUpdatesWillBeRolledBack              = $getValue.featureUpdatesWillBeRolledBack
                InstallationSchedule                        = $complexInstallationSchedule
                MicrosoftUpdateServiceAllowed               = $getValue.microsoftUpdateServiceAllowed
                PostponeRebootUntilAfterDeadline            = $getValue.postponeRebootUntilAfterDeadline
                PrereleaseFeatures                          = $getValue.prereleaseFeatures
                QualityUpdatesDeferralPeriodInDays          = $getValue.qualityUpdatesDeferralPeriodInDays
                QualityUpdatesPaused                        = $getValue.qualityUpdatesPaused
                QualityUpdatesPauseExpiryDateTime           = $dateQualityUpdatesPauseExpiryDateTime
                QualityUpdatesPauseStartDate                = $dateQualityUpdatesPauseStartDate
                QualityUpdatesRollbackStartDateTime         = $dateQualityUpdatesRollbackStartDateTime
                QualityUpdatesWillBeRolledBack              = $getValue.qualityUpdatesWillBeRolledBack
                ScheduleImminentRestartWarningInMinutes     = $getValue.scheduleImminentRestartWarningInMinutes
                ScheduleRestartWarningInHours               = $getValue.scheduleRestartWarningInHours
                SkipChecksBeforeRestart                     = $getValue.skipChecksBeforeRestart
                UpdateNotificationLevel                     = $getValue.updateNotificationLevel
                UpdateWeeks                                 = $getValue.updateWeeks
                UserPauseAccess                             = $getValue.userPauseAccess
                UserWindowsUpdateScanAccess                 = $getValue.userWindowsUpdateScanAccess
                Description                                 = $getValue.Description
                DisplayName                                 = $getValue.DisplayName
                Id                                          = $getValue.Id
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
                #endregion
            }

            $rawAssignments = @()
            $rawAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $rawAssignments)
            {
                $rawAssignments = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId -All
            }
            $assignmentResult = @()
            if ($null -ne $rawAssignments -and $rawAssignments.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $rawAssignments
            }
            $results.Add('Assignments', $assignmentResult)
            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        $this.RemoveForeignSubtypeProperties($boundParameters, @{
                '#microsoft.graph.windowsUpdateActiveHoursInstall' = @('activeHoursEnd', 'activeHoursStart')
                '#microsoft.graph.windowsUpdateScheduledInstall'   = @('scheduledInstallDay', 'scheduledInstallTime')
            })

        $boundParameters.Remove('featureUpdatesWillBeRolledBack') | Out-Null
        $boundParameters.Remove('qualityUpdatesWillBeRolledBack') | Out-Null

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Window Update For Business Ring Update Profile for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windowsUpdateForBusinessConfiguration')
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            #endregion
            #region new Intune assignment management
            $intuneAssignments = @()
            if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
            {
                $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
            }
            foreach ($assignment in $intuneAssignments)
            {
                New-MgBetaDeviceManagementDeviceConfigurationAssignment `
                    -DeviceConfigurationId $policy.id `
                    -BodyParameter $assignment
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Window Update For Business Ring Update Profile for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windowsUpdateForBusinessConfiguration')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.id `
                -BodyParameter $updateParameters
            #endregion
            #region new Intune assignment management
            $currentAssignments = @()
            $currentAssignments += Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $currentInstance.id

            $intuneAssignments = @()
            if ($null -ne $this.Assignments -and $this.Assignments.Count -gt 0)
            {
                $intuneAssignments += ConvertTo-IntunePolicyAssignment -Assignments $this.Assignments
            }
            foreach ($assignment in $intuneAssignments)
            {
                if ( $null -eq ($currentAssignments | Where-Object { $_.Target.groupId -eq $assignment.Target.groupId -and $_.Target.'@odata.type' -eq $assignment.Target.'@odata.type' }))
                {
                    New-MgBetaDeviceManagementDeviceConfigurationAssignment `
                        -DeviceConfigurationId $currentInstance.id `
                        -BodyParameter $assignment
                }
                else
                {
                    $currentAssignments = $currentAssignments | Where-Object { -not($_.Target.groupId -eq $assignment.Target.groupId -and $_.Target.'@odata.type' -eq $assignment.Target.'@odata.type') }
                }
            }
            if ($currentAssignments.Count -gt 0)
            {
                foreach ($assignment in $currentAssignments)
                {
                    Remove-MgBetaDeviceManagementDeviceConfigurationAssignment `
                        -DeviceConfigurationId $currentInstance.Id `
                        -DeviceConfigurationAssignmentId $assignment.Id
                }
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Window Update For Business Ring Update Profile for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('FeatureUpdatesWillBeRolledBack', 'QualityUpdatesWillBeRolledBack')
        }
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.windowsUpdateForBusinessConfiguration' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.displayName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.InstallationSchedule)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.InstallationSchedule `
                        -CIMInstanceName 'MicrosoftGraphwindowsUpdateInstallScheduleType'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.InstallationSchedule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('InstallationSchedule') | Out-Null
                    }
                }

                if ($null -ne $Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleDeviceMode'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }

                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsEdition'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }

                if ($null -ne $Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion `
                        -CIMInstanceName 'DeviceManagementApplicabilityRuleOsVersion'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('InstallationSchedule', 'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion', 'Assignments') `
                    -RawResults $rawResults

                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10])
        {
            return $Values
        }

        $result = [IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule for device mode')]
    [ValidateSet('standardConfiguration', 'sModeConfiguration')]
    [System.String] $DeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsEdition
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule OS edition type')]
    [System.String[]] $OsEditionTypes

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsVersion
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version for Applicability Rule')]
    [System.String] $MinOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version for Applicability Rule')]
    [System.String] $MaxOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType
{
    [DscProperty()]
    [System.ComponentModel.Description('Active Hours End')]
    [System.String] $ActiveHoursEnd

    [DscProperty()]
    [System.ComponentModel.Description('Active Hours Start')]
    [System.String] $ActiveHoursStart

    [DscProperty()]
    [System.ComponentModel.Description('Scheduled Install Day in week. Possible values are: userDefined, everyday, sunday, monday, tuesday, wednesday, thursday, friday, saturday, noScheduledScan.')]
    [ValidateSet('userDefined', 'everyday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'noScheduledScan')]
    [System.String] $ScheduledInstallDay

    [DscProperty()]
    [System.ComponentModel.Description('Scheduled Install Time during day')]
    [System.String] $ScheduledInstallTime

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.windowsUpdateActiveHoursInstall', '#microsoft.graph.windowsUpdateScheduledInstall')]
    [System.String] $odataType
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}
