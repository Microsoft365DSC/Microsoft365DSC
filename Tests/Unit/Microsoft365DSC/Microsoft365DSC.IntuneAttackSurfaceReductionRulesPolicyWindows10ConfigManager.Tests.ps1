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
    -DscResource 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Update-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    Description = 'My Test Description'
                    Name        = 'My Test'
                    TemplateReference = @{
                        TemplateId = '5dd36540-eb22-4e7e-b19c-2a07772ba627_1'
                    }
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = 0
                    SettingDefinitions   = @(
                        @{
                            Id = 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_useadvancedprotectionagainstransomware'
                            Name = 'UseAdvancedProtectionAgainstRansomware'
                            OffsetUri = '/Config/Defender/AttackSurfaceReductionRules'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_useadvancedprotectionagainstransomware_block'
                                    name = 'Block'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        value = 'block'
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules'
                            Name = 'AttackSurfaceReductionRules'
                            OffsetUri = '/Config/Defender/AttackSurfaceReductionRules'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                            'childIds' = @(
                                'device_vendor_msft_policy_config_defender_attacksurfacereductionrules_useadvancedprotectionagainstransomware'
                            )
                            minimumCount = 0
                            maximumCount = 1
                        }
                    )
                    SettingInstance      = @{
                        SettingDefinitionId              = 'device_vendor_msft_policy_config_defender_attacksurfacereductionrules'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = 'd770fcd1-62cd-4217-9b20-9ee2a12062ff'
                        }
                        '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                        groupSettingCollectionValue = @(@{
                            children = @(
                                @{
                                    "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                    "settingDefinitionId" = "device_vendor_msft_policy_config_defender_attacksurfacereductionrules_useadvancedprotectionagainstransomware"
                                    "choiceSettingValue" = @{
                                        "@odata.type" = "#microsoft.graph.deviceManagementConfigurationChoiceSettingValue"
                                        "value" = "device_vendor_msft_policy_config_defender_attacksurfacereductionrules_useadvancedprotectionagainstransomware_block"
                                    }
                                }
                            )
                        })
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
                return @(@{
                    Id       = '12345-12345-12345-12345-12345'
                    Source   = 'direct'
                    SourceId = '12345-12345-12345-12345-12345'
                    Target   = @{
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                        collectionId  = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
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
        Context -Name "When the instance doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                            CollectionId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Credential  = $Credential
                    Description = 'My Test Description'
                    DisplayName = 'My Test'
                    Ensure      = 'Present'
                    Identity    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementConfigurationPolicy' -Exactly 1
            }
        }

        Context -Name 'When the instance already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                            CollectionId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Credential  = $Credential
                    Description = 'My Test Description'
                    DisplayName = 'My Test'
                    Ensure      = 'Present'
                    Identity    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    useadvancedprotectionagainstransomware = "audit"
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Set()
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1
            }
        }

        Context -Name 'When the instance already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential  = $Credential
                    Description = 'My Test Description'
                    DisplayName = 'My Test'
                    Ensure      = 'Present'
                    Identity    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    useadvancedprotectionagainstransomware = 'block'
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                            CollectionId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the instance exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.configurationManagerCollectionAssignmentTarget'
                            CollectionId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    useadvancedprotectionagainstransomware = 'block'
                    Credential  = $Credential
                    Description = 'My Test Description'
                    DisplayName = 'My Test'
                    Ensure      = 'Absent'
                    Identity    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
