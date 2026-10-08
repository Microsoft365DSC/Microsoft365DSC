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
    -DscResource "IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    CreationSource  = 'WindowsSecurity'
                    Technologies    = 'configManager'
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = 0
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_companyname'
                                Name = 'CompanyName'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/CompanyName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_companyname'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                            simpleSettingValue = @{
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                value = 'FakeStringValue'
                            }
                        }
                    },
                    @{
                        Id = 1
                        SettingDefinitions = @(
                            @{
                                Id = 'vendor_msft_defender_configuration_tamperprotection'
                                Name = 'TamperProtection'
                                OffsetUri = '/Configuration/TamperProtection'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_defender_configuration_tamperprotection_1'
                                        name = 'Offboarding'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'vendor_msft_defender_configuration_tamperprotection'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'vendor_msft_defender_configuration_tamperprotection_1'
                            }
                        }
                    },
                    @{
                        Id = 2
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning'
                                Name = 'DisableTpmFirmwareUpdateWarning'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/DisableTpmFirmwareUpdateWarning'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning_1'
                                        name = 'Offboarding'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning_1'
                            }
                        }
                    },
                    @{
                        Id = 3
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui'
                                Name = 'DisableAccountProtectionUI'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/DisableAccountProtectionUI'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui_0'
                                        name = 'Enable'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 0
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui_0'
                            }
                        }
                    },
                    @{
                        Id = 4
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disablenotifications'
                                Name = 'DisableNotifications'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/DisableNotifications'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disablenotifications'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disablenotifications_1'
                            }
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -MockWith {
                return @(
                    @{
                        Id = 0
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_companyname'
                                Name = 'CompanyName'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/CompanyName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            }
                        )
                    },
                    @{
                        Id = 1
                        SettingDefinitions = @(
                            @{
                                Id = 'vendor_msft_defender_configuration_tamperprotection'
                                Name = 'TamperProtection'
                                OffsetUri = '/Configuration/TamperProtection'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_defender_configuration_tamperprotection_1'
                                        name = 'Offboarding'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                    },
                    @{
                        Id = 2
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning'
                                Name = 'DisableTpmFirmwareUpdateWarning'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/DisableTpmFirmwareUpdateWarning'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disabletpmfirmwareupdatewarning_1'
                                        name = 'Offboarding'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                    },
                    @{
                        Id = 3
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui'
                                Name = 'DisableAccountProtectionUI'
                                OffsetUri = '/Config/WindowsDefenderSecurityCenter/DisableAccountProtectionUI'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_windowsdefendersecuritycenter_disableaccountprotectionui_0'
                                        name = 'Enable'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 0
                                        }
                                    }
                                )
                            }
                        )
                    }
                    <# DisableNotifications is missing because it's not available in the template we use to fetch the settings #>
                )
            }
        }

        # Test contexts
        Context -Name "The IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    CompanyName = "FakeStringValue"
                    TamperProtection = "1"
                    DisableTpmFirmwareUpdateWarning = 1
                    DisableAccountProtectionUI = 0
                    DisableNotifications = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    CompanyName = "FakeStringValue"
                    TamperProtection = "1"
                    DisableTpmFirmwareUpdateWarning = 1
                    DisableAccountProtectionUI = 0
                    DisableNotifications = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    CompanyName = "FakeStringValue"
                    TamperProtection = "1"
                    DisableTpmFirmwareUpdateWarning = 1
                    DisableAccountProtectionUI = 0
                    DisableNotifications = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    CompanyName = "FakeStringValue"
                    TamperProtection = "1"
                    DisableTpmFirmwareUpdateWarning = 0 # Drift
                    DisableAccountProtectionUI = 0
                    DisableNotifications = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -Property $testParams).Set()
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAntivirusPolicySecurityExperienceWindows10ConfigMgr' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
