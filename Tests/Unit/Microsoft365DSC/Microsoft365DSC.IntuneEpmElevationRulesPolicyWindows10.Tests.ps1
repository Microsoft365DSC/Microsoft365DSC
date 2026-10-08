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
    -DscResource "IntuneEpmElevationRulesPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    Name = "FakeStringValue"
                    Platforms = "windows10"
                    RoleScopeTagIds = @("FakeStringValue")
                    Technologies = "mdm,endpointPrivilegeManagement"
                    TemplateReference = @{
                        templateId = "e7dcaba4-959b-46ed-88f0-16ba39b14fd8_1"
                    }
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                Name = 'ElevationRuleName'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                minimumCount = 1
                                maximumCount = 100
                                childIds = @(
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_name'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filename'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filepath'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_ruletype'
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filename'
                                Name = 'FileName'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/FileName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_name'
                                Name = 'Name'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/Name'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filepath'
                                Name = 'FilePath'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/FilePath'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_ruletype'
                                Name = 'ElevationType'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/RuleType'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                rootDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_automatic'
                                        name = 'Automatic'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                            value = 'Automatic'
                                        }
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                                parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                            }
                                        )
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'ee3d2e5f-6b3d-4cb1-af9b-37b02d3dbae2'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filename'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'file.exe'
                                            }
                                        }
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filepath'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'C:\Temp'
                                            }
                                        }
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_name'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'Rule Name'
                                            }
                                        }
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_ruletype'
                                            choiceSettingValue = @{
                                                children = @()
                                                value = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_automatic'
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -MockWith {
                return @(
                    @{
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                Name = 'ElevationRuleName'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                minimumCount = 1
                                maximumCount = 100
                                childIds = @(
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_name'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filename'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filepath'
                                    'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_ruletype'
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filename'
                                Name = 'FileName'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/FileName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_name'
                                Name = 'Name'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/Name'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_filepath'
                                Name = 'FilePath'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/FilePath'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                        parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_ruletype'
                                Name = 'ElevationType'
                                OffsetUri = '/PrivilegeManagement/ElevationRules/{0}/RuleType'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                rootDefinitionId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}_automatic'
                                        name = 'Automatic'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                            value = 'Automatic'
                                        }
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                                parentSettingId = 'device_vendor_msft_policy_privilegemanagement_elevationrules_{elevationrulename}'
                                            }
                                        )
                                    }
                                )
                            }
                        )
                    }
                )
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Exclude'
                }
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

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
        Context -Name "The IntuneEpmElevationRulesPolicyWindows10 should exist but it DOES NOT" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    ElevationRuleName = @(
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName] @{
                            FileName = "file.exe"
                            Name = "Rule Name"
                            FilePath = "C:\Temp"
                            ElevationType = 'automatic'
                        }
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneEpmElevationRulesPolicyWindows10 exists but it SHOULD NOT" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    ElevationRuleName = @(
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName] @{
                            FileName = "file.exe"
                            Name = "Rule Name"
                            FilePath = "C:\Temp"
                            ElevationType = 'automatic'
                        }
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneEpmElevationRulesPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    ElevationRuleName = @(
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName] @{
                            FileName = "file.exe"
                            Name = "Rule Name"
                            FilePath = "C:\Temp"
                            ElevationType = 'automatic'
                        }
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneEpmElevationRulesPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    ElevationRuleName = @(
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName] @{
                            FileName = "file_2.exe" # Drift
                            Name = "Rule Name"
                            FilePath = "C:\Temp"
                            ElevationType = 'automatic'
                        }
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneEpmElevationRulesPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
