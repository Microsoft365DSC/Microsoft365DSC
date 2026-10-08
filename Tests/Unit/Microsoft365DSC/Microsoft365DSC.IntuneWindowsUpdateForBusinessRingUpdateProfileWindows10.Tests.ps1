[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    postponeRebootUntilAfterDeadline            = $True
                    featureUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    businessReadyUpdatesOnly                    = 'userDefined'
                    updateWeeks                                 = 'userDefined'
                    qualityUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    skipChecksBeforeRestart                     = $True
                    deadlineForFeatureUpdatesInDays             = 25
                    featureUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    scheduleImminentRestartWarningInMinutes     = 25
                    featureUpdatesDeferralPeriodInDays          = 25
                    driversExcluded                             = $True
                    featureUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    deadlineForQualityUpdatesInDays             = 25
                    deliveryOptimizationMode                    = 'userDefined'
                    scheduleRestartWarningInHours               = 25
                    prereleaseFeatures                          = 'userDefined'
                    featureUpdatesPaused                        = $True
                    updateNotificationLevel                     = 'notConfigured'
                    automaticUpdateMode                         = 'userDefined'
                    allowWindows11Upgrade                       = $True
                    featureUpdatesRollbackWindowInDays          = 25
                    featureUpdatesWillBeRolledBack              = $True
                    engagedRestartTransitionScheduleInDays      = 25
                    engagedRestartDeadlineInDays                = 25
                    qualityUpdatesDeferralPeriodInDays          = 25
                    qualityUpdatesPaused                        = $True
                    deadlineGracePeriodInDays                   = 25
                    autoRestartNotificationDismissal            = 'notConfigured'
                    installationSchedule                        = @{
                        activeHoursStart     = '00:00:00'
                        scheduledInstallTime = '00:00:00'
                        scheduledInstallDay  = 'userDefined'
                        activeHoursEnd       = '00:00:00'
                        '@odata.type'        = '#microsoft.graph.windowsUpdateActiveHoursInstall'
                    }
                    engagedRestartSnoozeScheduleInDays          = 25
                    '@odata.type'                               = '#microsoft.graph.windowsUpdateForBusinessConfiguration'
                    qualityUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesWillBeRolledBack              = $True
                    userPauseAccess                             = 'notConfigured'
                    userWindowsUpdateScanAccess                 = 'notConfigured'
                    microsoftUpdateServiceAllowed               = $True
                    description                                 = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name       = 'FakeStringValue'
                        DeviceMode = 'standardConfiguration'
                        RuleType   = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsEdition  = @{
                        Name           = 'FakeStringValue'
                        OsEditionTypes = @('windows10Enterprise')
                        RuleType       = 'include'
                    }
                    DeviceManagementApplicabilityRuleOsVersion  = @{
                        Name         = 'FakeStringValue'
                        MinOSVersion = '10.0.19045.0'
                        MaxOSVersion = '10.0.26100.9999'
                        RuleType     = 'include'
                    }
                    displayName                                 = 'FakeStringValue'
                    id                                          = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowWindows11Upgrade                       = $True
                    AutomaticUpdateMode                         = 'userDefined'
                    AutoRestartNotificationDismissal            = 'notConfigured'
                    BusinessReadyUpdatesOnly                    = 'userDefined'
                    DeadlineForFeatureUpdatesInDays             = 25
                    DeadlineForQualityUpdatesInDays             = 25
                    DeadlineGracePeriodInDays                   = 25
                    DeliveryOptimizationMode                    = 'userDefined'
                    description                                 = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                            Name       = 'FakeStringValue'
                            DeviceMode = 'standardConfiguration'
                            RuleType   = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsEdition  = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                            Name           = 'FakeStringValue'
                            OsEditionTypes = @('windows10Enterprise')
                            RuleType       = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsVersion  = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                            Name         = 'FakeStringValue'
                            MinOSVersion = '10.0.19045.0'
                            MaxOSVersion = '10.0.26100.9999'
                            RuleType     = 'include'
                        })
                    displayName                                 = 'FakeStringValue'
                    DriversExcluded                             = $True
                    EngagedRestartDeadlineInDays                = 25
                    EngagedRestartSnoozeScheduleInDays          = 25
                    EngagedRestartTransitionScheduleInDays      = 25
                    FeatureUpdatesDeferralPeriodInDays          = 25
                    FeatureUpdatesPaused                        = $True
                    FeatureUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    FeatureUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesRollbackWindowInDays          = 25
                    FeatureUpdatesWillBeRolledBack              = $True
                    id                                          = 'FakeStringValue'
                    installationSchedule                        = ([MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType] @{
                            activeHoursStart     = '00:00:00'
                            scheduledInstallTime = '00:00:00'
                            scheduledInstallDay  = 'userDefined'
                            activeHoursEnd       = '00:00:00'
                            odataType            = '#microsoft.graph.windowsUpdateActiveHoursInstall'
                        })
                    microsoftUpdateServiceAllowed               = $True
                    postponeRebootUntilAfterDeadline            = $True
                    prereleaseFeatures                          = 'userDefined'
                    qualityUpdatesDeferralPeriodInDays          = 25
                    qualityUpdatesPaused                        = $True
                    qualityUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    qualityUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesWillBeRolledBack              = $True
                    scheduleImminentRestartWarningInMinutes     = 25
                    scheduleRestartWarningInHours               = 25
                    skipChecksBeforeRestart                     = $True
                    updateNotificationLevel                     = 'notConfigured'
                    updateWeeks                                 = 'userDefined'
                    userPauseAccess                             = 'notConfigured'
                    userWindowsUpdateScanAccess                 = 'notConfigured'
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowWindows11Upgrade                       = $True
                    AutomaticUpdateMode                         = 'userDefined'
                    AutoRestartNotificationDismissal            = 'notConfigured'
                    BusinessReadyUpdatesOnly                    = 'userDefined'
                    DeadlineForFeatureUpdatesInDays             = 25
                    DeadlineForQualityUpdatesInDays             = 25
                    DeadlineGracePeriodInDays                   = 25
                    DeliveryOptimizationMode                    = 'userDefined'
                    description                                 = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                            Name       = 'FakeStringValue'
                            DeviceMode = 'standardConfiguration'
                            RuleType   = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsEdition  = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                            Name           = 'FakeStringValue'
                            OsEditionTypes = @('windows10Enterprise')
                            RuleType       = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsVersion  = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                            Name         = 'FakeStringValue'
                            MinOSVersion = '10.0.19045.0'
                            MaxOSVersion = '10.0.26100.9999'
                            RuleType     = 'include'
                        })
                    displayName                                 = 'FakeStringValue'
                    DriversExcluded                             = $True
                    EngagedRestartDeadlineInDays                = 25
                    EngagedRestartSnoozeScheduleInDays          = 25
                    EngagedRestartTransitionScheduleInDays      = 25
                    FeatureUpdatesDeferralPeriodInDays          = 25
                    FeatureUpdatesPaused                        = $True
                    FeatureUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    FeatureUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesRollbackWindowInDays          = 25
                    FeatureUpdatesWillBeRolledBack              = $True
                    id                                          = 'FakeStringValue'
                    installationSchedule                        = ([MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType] @{
                            activeHoursStart     = '00:00:00'
                            scheduledInstallTime = '00:00:00'
                            scheduledInstallDay  = 'userDefined'
                            activeHoursEnd       = '00:00:00'
                            odataType            = '#microsoft.graph.windowsUpdateActiveHoursInstall'
                        })
                    microsoftUpdateServiceAllowed               = $True
                    postponeRebootUntilAfterDeadline            = $True
                    prereleaseFeatures                          = 'userDefined'
                    qualityUpdatesDeferralPeriodInDays          = 25
                    qualityUpdatesPaused                        = $True
                    qualityUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    qualityUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesWillBeRolledBack              = $True
                    scheduleImminentRestartWarningInMinutes     = 25
                    scheduleRestartWarningInHours               = 25
                    skipChecksBeforeRestart                     = $True
                    updateNotificationLevel                     = 'notConfigured'
                    updateWeeks                                 = 'userDefined'
                    userPauseAccess                             = 'notConfigured'
                    userWindowsUpdateScanAccess                 = 'notConfigured'
                    Ensure                                      = 'Absent'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowWindows11Upgrade                       = $True
                    AutomaticUpdateMode                         = 'userDefined'
                    AutoRestartNotificationDismissal            = 'notConfigured'
                    BusinessReadyUpdatesOnly                    = 'userDefined'
                    DeadlineForFeatureUpdatesInDays             = 25
                    DeadlineForQualityUpdatesInDays             = 25
                    DeadlineGracePeriodInDays                   = 25
                    DeliveryOptimizationMode                    = 'userDefined'
                    description                                 = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                            Name       = 'FakeStringValue'
                            DeviceMode = 'standardConfiguration'
                            RuleType   = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsEdition  = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                            Name           = 'FakeStringValue'
                            OsEditionTypes = @('windows10Enterprise')
                            RuleType       = 'include'
                        })
                    DeviceManagementApplicabilityRuleOsVersion  = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                            Name         = 'FakeStringValue'
                            MinOSVersion = '10.0.19045.0'
                            MaxOSVersion = '10.0.26100.9999'
                            RuleType     = 'include'
                        })
                    displayName                                 = 'FakeStringValue'
                    DriversExcluded                             = $True
                    EngagedRestartDeadlineInDays                = 25
                    EngagedRestartSnoozeScheduleInDays          = 25
                    EngagedRestartTransitionScheduleInDays      = 25
                    FeatureUpdatesDeferralPeriodInDays          = 25
                    FeatureUpdatesPaused                        = $True
                    FeatureUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    FeatureUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesRollbackWindowInDays          = 25
                    FeatureUpdatesWillBeRolledBack              = $True
                    id                                          = 'FakeStringValue'
                    installationSchedule                        = ([MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType] @{
                            activeHoursStart     = '00:00:00'
                            scheduledInstallTime = '00:00:00'
                            scheduledInstallDay  = 'userDefined'
                            activeHoursEnd       = '00:00:00'
                            odataType            = '#microsoft.graph.windowsUpdateActiveHoursInstall'
                        })
                    microsoftUpdateServiceAllowed               = $True
                    postponeRebootUntilAfterDeadline            = $True
                    prereleaseFeatures                          = 'userDefined'
                    qualityUpdatesDeferralPeriodInDays          = 25
                    qualityUpdatesPaused                        = $True
                    qualityUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    qualityUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesWillBeRolledBack              = $True
                    scheduleImminentRestartWarningInMinutes     = 25
                    scheduleRestartWarningInHours               = 25
                    skipChecksBeforeRestart                     = $True
                    updateNotificationLevel                     = 'notConfigured'
                    updateWeeks                                 = 'userDefined'
                    userPauseAccess                             = 'notConfigured'
                    userWindowsUpdateScanAccess                 = 'notConfigured'
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowWindows11Upgrade                       = $False # Updated property
                    AutomaticUpdateMode                         = 'userDefined'
                    AutoRestartNotificationDismissal            = 'notConfigured'
                    BusinessReadyUpdatesOnly                    = 'userDefined'
                    DeadlineForFeatureUpdatesInDays             = 25
                    DeadlineForQualityUpdatesInDays             = 25
                    DeadlineGracePeriodInDays                   = 25
                    DeliveryOptimizationMode                    = 'userDefined'
                    description                                 = 'FakeStringValue'
                    DeviceManagementApplicabilityRuleDeviceMode = ([MSFT_DeviceManagementApplicabilityRuleDeviceMode] @{
                            Name       = 'FakeStringValue'
                            DeviceMode = 'standardConfiguration'
                            RuleType   = 'exclude' # Updated property
                        })
                    DeviceManagementApplicabilityRuleOsEdition  = ([MSFT_DeviceManagementApplicabilityRuleOsEdition] @{
                            Name           = 'FakeStringValue'
                            OsEditionTypes = @('windows10Enterprise')
                            RuleType       = 'exclude' # Updated property
                        })
                    DeviceManagementApplicabilityRuleOsVersion  = ([MSFT_DeviceManagementApplicabilityRuleOsVersion] @{
                            Name         = 'FakeStringValue'
                            MinOSVersion = '10.0.19045.0'
                            MaxOSVersion = '10.0.26100.9999'
                            RuleType     = 'exclude' # Updated property
                        })
                    displayName                                 = 'FakeStringValue'
                    DriversExcluded                             = $True
                    EngagedRestartDeadlineInDays                = 25
                    EngagedRestartSnoozeScheduleInDays          = 25
                    EngagedRestartTransitionScheduleInDays      = 25
                    FeatureUpdatesDeferralPeriodInDays          = 25
                    FeatureUpdatesPaused                        = $True
                    FeatureUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    FeatureUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    FeatureUpdatesRollbackWindowInDays          = 25
                    FeatureUpdatesWillBeRolledBack              = $False # Updated property
                    id                                          = 'FakeStringValue'
                    installationSchedule                        = ([MSFT_MicrosoftGraphwindowsUpdateInstallScheduleType] @{
                            activeHoursStart     = '00:00:00'
                            scheduledInstallTime = '00:00:00'
                            scheduledInstallDay  = 'userDefined'
                            activeHoursEnd       = '00:00:00'
                            odataType            = '#microsoft.graph.windowsUpdateActiveHoursInstall'
                        })
                    microsoftUpdateServiceAllowed               = $True
                    postponeRebootUntilAfterDeadline            = $True
                    prereleaseFeatures                          = 'userDefined'
                    qualityUpdatesDeferralPeriodInDays          = 25
                    qualityUpdatesPaused                        = $True
                    qualityUpdatesPauseExpiryDateTime           = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesPauseStartDate                = '2023-01-01T00:00:00.0000000'
                    qualityUpdatesRollbackStartDateTime         = '2023-01-01T00:00:00.0000000+00:00'
                    qualityUpdatesWillBeRolledBack              = $False # Updated property
                    scheduleImminentRestartWarningInMinutes     = 25
                    scheduleRestartWarningInHours               = 25
                    skipChecksBeforeRestart                     = $True
                    updateNotificationLevel                     = 'notConfigured'
                    updateWeeks                                 = 'userDefined'
                    userPauseAccess                             = 'notConfigured'
                    userWindowsUpdateScanAccess                 = 'notConfigured'
                    Ensure                                      = 'Present'
                    Credential                                  = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsUpdateForBusinessRingUpdateProfileWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
