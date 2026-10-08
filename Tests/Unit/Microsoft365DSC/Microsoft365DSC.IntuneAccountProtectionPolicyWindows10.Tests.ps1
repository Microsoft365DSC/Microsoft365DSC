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
    -DscResource "IntuneAccountProtectionPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = 'fcef01f2-439d-4c3f-9184-823fd6e97646_1'
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
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                Name = 'History'
                                OffsetUri = '/{0}/Policies/PINComplexity/History'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_passportforwork_{tenantid}'
                                        parentSettingId = 'device_vendor_msft_passportforwork_{tenantid}'
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_passportforwork_{tenantid}'
                                Name = '{TenantId}'
                                OffsetUri = '/{0}'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                childIds = @(
                                    'device_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                )
                                maximumCount = 1
                                minimumCount = 0
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_passportforwork_{tenantid}'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '0ece2bdc-57c1-4be9-93e9-ac9c395a9c94'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'device_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = '10'
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    },
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'user_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                Name = 'History'
                                OffsetUri = '/{0}/Policies/PINComplexity/History'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'user_vendor_msft_passportforwork_{tenantid}'
                                        parentSettingId = 'user_vendor_msft_passportforwork_{tenantid}'
                                    }
                                )
                            },
                            @{
                                Id = 'user_vendor_msft_passportforwork_{tenantid}'
                                Name = '{TenantId}'
                                OffsetUri = '/{0}'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                childIds = @(
                                    'user_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                )
                                maximumCount = 1
                                minimumCount = 0
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'user_vendor_msft_passportforwork_{tenantid}'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '0ece2bdc-57c1-4be9-93e9-ac9c395a9c94'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'user_vendor_msft_passportforwork_{tenantid}_policies_pincomplexity_history'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = '20'
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    }
                )
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Exclude'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Write-Warning -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
                return @(@{
                    Id       = '12345-12345-12345-12345-12345'
                    Source   = 'direct'
                    SourceId = '12345-12345-12345-12345-12345'
                    Target   = @{
                        DeviceAndAppManagementAssignmentFilterId   = '12345-12345-12345-12345-12345'
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                        groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
            }

        }
        # Test contexts
        Context -Name "The IntuneAccountProtectionPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Description = "My Test"
                    DeviceSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 10
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 20
                        }
                    )
                    Ensure = "Present"
                    Credential = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAccountProtectionPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Description = "My Test"
                    DeviceSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 10
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 20
                        }
                    )
                    Ensure = "Absent"
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }
        Context -Name "The IntuneAccountProtectionPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Description = "My Test"
                    DeviceSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 10
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 20
                        }
                    )
                    Ensure = "Present"
                    Credential = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAccountProtectionPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Description = "My Test"
                    DeviceSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 10
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10] @{
                            History = 30 # Drift
                        }
                    )
                    Ensure = "Present"
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAccountProtectionPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
