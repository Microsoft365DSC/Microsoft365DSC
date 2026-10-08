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
    -DscResource "IntuneEndpointDetectionAndResponsePolicyMacOS" -GenericStubModule $GenericStubPath
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
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = 0
                    SettingDefinitions   = @(
                        @{
                            Id = 'com.apple.managedclient.preferences_tags'
                            Name = 'tags'
                            OffsetUri = 'tags'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                            childIds = @(
                                'com.apple.managedclient.preferences_tags_item_value',
                                'com.apple.managedclient.preferences_tags_item_key'
                            )
                            minimumCount = 1
                            maximumCount = 1
                        },
                        @{
                            Id = 'com.apple.managedclient.preferences_tags_item_value'
                            Name = 'tags_item_value'
                            OffsetUri = 'tags/[{0}]/value'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                        },
                        @{
                            Id = 'com.apple.managedclient.preferences_tags_item_key'
                            Name = 'tags_item_key'
                            OffsetUri = 'tags/[{0}]/key'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'com.apple.managedclient.preferences_tags_item_key_0'
                                    name = 'GROUP'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        value = 'GROUP'
                                    }
                                }
                            )
                        }
                    )
                    SettingInstance      = @{
                        SettingDefinitionId              = 'com.apple.managedclient.preferences_tags'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = 'd0eb0a92-3807-4d9d-8432-6edd1aa108ce'
                        }
                        '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                        groupSettingCollectionValue = @(
                            @{
                                settingValueTemplateReference = $null
                                children                   = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        choiceSettingValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingInstance'
                                            children = @()
                                            value = 'com.apple.managedclient.preferences_tags_item_key_0'
                                        }
                                        settingDefinitionId = 'com.apple.managedclient.preferences_tags_item_key'
                                    },
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                        simpleSettingValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'tag'
                                        }
                                        settingDefinitionId = 'com.apple.managedclient.preferences_tags_item_value'
                                    }
                                )
                            }
                        )
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id                = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    Description       = 'My Test Description'
                    Name              = 'My Test'
                    TemplateReference = @{
                        TemplateId     = 'a6ff37f6-c841-4264-9249-1ecf793d94ef_1'
                        TemplateFamily = 'endpointSecurityEndpointDetectionAndResponse'
                    }
                    RoleScopeTagIds   = @("FakeStringValue")
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
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
        Context -Name "The IntuneEndpointDetectionAndResponsePolicyMacOS should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = 'My Test Description'
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    DisplayName = 'My Test'
                    tags_item_key = 'GROUP'
                    tags_item_value = 'tag'
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1 -ParameterFilter {
                    $null -ne $BodyParameter.roleScopeTagIds -and $BodyParameter.roleScopeTagIds.Count -eq 0
                }
            }
        }

        Context -Name "The IntuneEndpointDetectionAndResponsePolicyMacOS exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = 'My Test Description'
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    DisplayName = 'My Test'
                    tags_item_key = 'GROUP'
                    tags_item_value = 'tag'
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }
        Context -Name "The IntuneEndpointDetectionAndResponsePolicyMacOS Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = 'My Test Description'
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    DisplayName = 'My Test'
                    tags_item_key = 'GROUP'
                    tags_item_value = 'tag'
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneEndpointDetectionAndResponsePolicyMacOS exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = 'My Test Description'
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    DisplayName = 'My Test'
                    tags_item_key = 'GROUP'
                    tags_item_value = 'Updated Tag' # Drift
                    Ensure = 'Present'
                    Credential = $Credential;
                }

                Mock -CommandName Resolve-M365DSCIntuneRoleScopeTagIds -MockWith {
                    return $RoleScopeTagIds
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1 -ParameterFilter {
                    $RoleScopeTagIds -contains 'FakeStringValue'
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneEndpointDetectionAndResponsePolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
