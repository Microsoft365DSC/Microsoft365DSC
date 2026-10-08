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
    -DscResource "IntuneDeviceConfigurationWindowsTeamPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }
            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    settingsDefaultVolume = 25
                    welcomeScreenMeetingInformation = "userDefined"
                    settingsScreenTimeoutInMinutes = 25
                    settingsBlockMyMeetingsAndFiles = $True
                    '@odata.type' = "#microsoft.graph.windows10TeamGeneralConfiguration"
                    maintenanceWindowDurationInHours = 25
                    azureOperationalInsightsBlockTelemetry = $True
                    miracastChannel = "userDefined"
                    welcomeScreenBackgroundImageUrl = "FakeStringValue"
                    settingsBlockSessionResume = $True
                    settingsSessionTimeoutInMinutes = 25
                    azureOperationalInsightsWorkspaceKey = "FakeStringValue"
                    welcomeScreenBlockAutomaticWakeUp = $True
                    miracastRequirePin = $True
                    maintenanceWindowStartTime = "00:00:00"
                    settingsBlockSigninSuggestions = $True
                    maintenanceWindowBlocked = $True
                    miracastBlocked = $True
                    settingsSleepTimeoutInMinutes = 25
                    azureOperationalInsightsWorkspaceId = "FakeStringValue"
                    connectAppBlockAutoLaunch = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                }
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

        }
        # Test contexts
        Context -Name "The IntuneDeviceConfigurationWindowsTeamPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureOperationalInsightsBlockTelemetry = $True
                    AzureOperationalInsightsWorkspaceId = "FakeStringValue"
                    AzureOperationalInsightsWorkspaceKey = "FakeStringValue"
                    ConnectAppBlockAutoLaunch = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaintenanceWindowBlocked = $True
                    MaintenanceWindowDurationInHours = 25
                    MaintenanceWindowStartTime = "00:00:00"
                    MiracastBlocked = $True
                    MiracastChannel = "userDefined"
                    MiracastRequirePin = $True
                    SettingsBlockMyMeetingsAndFiles = $True
                    SettingsBlockSessionResume = $True
                    SettingsBlockSigninSuggestions = $True
                    SettingsDefaultVolume = 25
                    SettingsScreenTimeoutInMinutes = 25
                    SettingsSessionTimeoutInMinutes = 25
                    SettingsSleepTimeoutInMinutes = 25
                    WelcomeScreenBackgroundImageUrl = "FakeStringValue"
                    WelcomeScreenBlockAutomaticWakeUp = $True
                    WelcomeScreenMeetingInformation = "userDefined"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationWindowsTeamPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureOperationalInsightsBlockTelemetry = $True
                    AzureOperationalInsightsWorkspaceId = "FakeStringValue"
                    AzureOperationalInsightsWorkspaceKey = "FakeStringValue"
                    ConnectAppBlockAutoLaunch = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaintenanceWindowBlocked = $True
                    MaintenanceWindowDurationInHours = 25
                    MaintenanceWindowStartTime = "00:00:00"
                    MiracastBlocked = $True
                    MiracastChannel = "userDefined"
                    MiracastRequirePin = $True
                    SettingsBlockMyMeetingsAndFiles = $True
                    SettingsBlockSessionResume = $True
                    SettingsBlockSigninSuggestions = $True
                    SettingsDefaultVolume = 25
                    SettingsScreenTimeoutInMinutes = 25
                    SettingsSessionTimeoutInMinutes = 25
                    SettingsSleepTimeoutInMinutes = 25
                    WelcomeScreenBackgroundImageUrl = "FakeStringValue"
                    WelcomeScreenBlockAutomaticWakeUp = $True
                    WelcomeScreenMeetingInformation = "userDefined"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationWindowsTeamPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureOperationalInsightsBlockTelemetry = $True
                    AzureOperationalInsightsWorkspaceId = "FakeStringValue"
                    AzureOperationalInsightsWorkspaceKey = "FakeStringValue"
                    ConnectAppBlockAutoLaunch = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaintenanceWindowBlocked = $True
                    MaintenanceWindowDurationInHours = 25
                    MaintenanceWindowStartTime = "00:00:00"
                    MiracastBlocked = $True
                    MiracastChannel = "userDefined"
                    MiracastRequirePin = $True
                    SettingsBlockMyMeetingsAndFiles = $True
                    SettingsBlockSessionResume = $True
                    SettingsBlockSigninSuggestions = $True
                    SettingsDefaultVolume = 25
                    SettingsScreenTimeoutInMinutes = 25
                    SettingsSessionTimeoutInMinutes = 25
                    SettingsSleepTimeoutInMinutes = 25
                    WelcomeScreenBackgroundImageUrl = "FakeStringValue"
                    WelcomeScreenBlockAutomaticWakeUp = $True
                    WelcomeScreenMeetingInformation = "userDefined"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationWindowsTeamPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AzureOperationalInsightsBlockTelemetry = $True
                    AzureOperationalInsightsWorkspaceId = "FakeStringValue"
                    AzureOperationalInsightsWorkspaceKey = "FakeStringValue"
                    ConnectAppBlockAutoLaunch = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "sModeConfiguration" # Updated property
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Professional") # Updated property
                        RuleType = "exclude" # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.22631.9999" # Updated property
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaintenanceWindowBlocked = $True
                    MaintenanceWindowDurationInHours = 25
                    MaintenanceWindowStartTime = "00:00:00"
                    MiracastBlocked = $True
                    MiracastChannel = "userDefined"
                    MiracastRequirePin = $True
                    SettingsBlockMyMeetingsAndFiles = $True
                    SettingsBlockSessionResume = $True
                    SettingsBlockSigninSuggestions = $True
                    SettingsDefaultVolume = 7 # Updated property
                    SettingsScreenTimeoutInMinutes = 25
                    SettingsSessionTimeoutInMinutes = 25
                    SettingsSleepTimeoutInMinutes = 25
                    WelcomeScreenBackgroundImageUrl = "FakeStringValue"
                    WelcomeScreenBlockAutomaticWakeUp = $True
                    WelcomeScreenMeetingInformation = "userDefined"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationWindowsTeamPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
