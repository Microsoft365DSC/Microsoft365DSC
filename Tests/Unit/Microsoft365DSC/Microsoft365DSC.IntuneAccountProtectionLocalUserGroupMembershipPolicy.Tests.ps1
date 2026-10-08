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
    -DscResource 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
                return @(@{
                    target = @{
                        deviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                        groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    Description = 'My Test Description'
                    Name        = 'My Test'
                    TemplateReference = @{
                        TemplateId = '22968f54-45fa-486c-848e-f8224aa69772_1'
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = 0
                    SettingDefinitions   = @(
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                            Name = 'desc'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition'
                            maximumCount = 100
                            minimumCount = 0
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc_administrators'
                                    name = 'administrators'
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                            parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                        }
                                    )
                                    optionValue = @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                        value = 'S-1-5-32-544'
                                    }
                                }
                            )
                        }
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action'
                            Name = 'action'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action_add_update'
                                    name = 'update'
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                            parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                        }
                                    )
                                    optionValue = @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                        value = 'AddUpdate'
                                    }
                                }
                            )
                        }
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                            Name = 'accessgroup'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                            childIds = @(
                                'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action'
                                'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                            )
                            dependentOn = @(
                                @{
                                    dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                                    parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                                }
                            )
                            maximumCount = 1
                            minimumCount = 1
                        }
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                            Name = 'userselectiontype'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype_users'
                                    name = 'users'
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                            parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                        }
                                    )
                                    optionValue = @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                        value = 'users'
                                    }
                                }
                            )
                        }
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_users'
                            Name = 'member'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                            maximumCount = 100
                            minimumCount = 0
                            dependentOn = @(
                                @{
                                    dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                    parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                }
                            )
                        }
                        @{
                            Id = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                            Name = 'GroupConfiguration'
                            OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                            childIds = @(
                                'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                            )
                            maximumCount = 100
                            minimumCount = 1
                        }
                    )
                    SettingInstance = @{
                        SettingDefinitionId              = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = 'de06bec1-4852-48a0-9799-cf7b85992d45'
                        }
                        '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                        groupSettingCollectionValue = @(
                            @{
                                children = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                                        'settingDefinitionId' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                        'groupSettingCollectionValue' = @(
                                            @{
                                                'children' = @(
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                                        'settingDefinitionId' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                                        'choiceSettingValue' = @{
                                                            'value' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype_users'
                                                            'children' = @(
                                                                @{
                                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                                                    'settingDefinitionId' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_users'
                                                                    'simpleSettingCollectionValue' = @(
                                                                        @{
                                                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                                            'value' = 'S-1-12-1-1167842105-1150511762-402702254-1917434032'
                                                                        }
                                                                    )
                                                                }
                                                            )
                                                        }
                                                    },
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                                        'settingDefinitionId' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action'
                                                        'choiceSettingValue' = @{
                                                            'value' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action_add_update'
                                                            'children' = @()
                                                        }
                                                    },
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance'
                                                        'settingDefinitionId' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                                        'choiceSettingCollectionValue' = @(
                                                            @{
                                                                'value' = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc_administrators'
                                                                'children' = @()
                                                            }
                                                        )
                                                    }
                                                )
                                            }
                                        )
                                    }
                                )
                            }
                        )
                    }
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -MockWith {
                return @(
                    @{
                        Id                 = 0
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                Name = 'desc'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition'
                                maximumCount = 100
                                minimumCount = 0
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc_administrators'
                                        name = 'administrators'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                                parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                            value = 'S-1-5-32-544'
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action'
                                Name = 'action'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action_add_update'
                                        name = 'update'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                                parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                            value = 'AddUpdate'
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                Name = 'accessgroup'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                childIds = @(
                                    'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                    'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_action'
                                    'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                )
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                                        parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                                    }
                                )
                                maximumCount = 1
                                minimumCount = 1
                            }
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                Name = 'userselectiontype'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype_users'
                                        name = 'users'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                                parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_desc'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                            value = 'users'
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_users'
                                Name = 'member'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                maximumCount = 100
                                minimumCount = 0
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                        parentSettingId = 'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup_userselectiontype'
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_config_localusersandgroups_configure'
                                Name = 'GroupConfiguration'
                                OffsetUri = '/Config/LocalUsersAndGroups/Configure'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                childIds = @(
                                    'device_vendor_msft_policy_config_localusersandgroups_configure_groupconfiguration_accessgroup'
                                )
                                maximumCount = 100
                                minimumCount = 1
                            }
                        )
                        SettingInstance = @{
                            # Not necessary
                        }
                    }
                )
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
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

        }

        # Test contexts
        Context -Name "When the instance doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            DeviceAndAppManagementAssignmentFilterType = 'none'
                            GroupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            GroupDisplayName = 'Exclude'
                        })
                    )
                    Credential    = $Credential
                    Description   = 'My Test Description'
                    DisplayName   = 'My Test'
                    Ensure        = 'Present'
                    Identity      = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    AccessGroup = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup] @{
                            desc = @('administrators')
                            member = @('S-1-12-1-1167842105-1150511762-402702254-1917434032')
                            action = 'AddUpdate'
                            userselectiontype = 'users'
                        })
                    )
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementConfigurationPolicy' -Exactly 1
            }
        }

        Context -Name 'When the instance already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            DeviceAndAppManagementAssignmentFilterType = 'none'
                            GroupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            GroupDisplayName = 'Exclude'
                        })
                    )
                    Credential    = $Credential
                    Description   = 'My Test Description'
                    DisplayName   = 'My Test'
                    Ensure        = 'Present'
                    Identity      = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    AccessGroup = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup] @{
                            desc = @('administrators')
                            member = @('S-1-12-1-1167842105-1150511762-402702254-1917434032')
                            action = 'AddRestrict' # Drift
                            userselectiontype = 'users'
                        })
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Set()
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
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            DeviceAndAppManagementAssignmentFilterType = 'none'
                            GroupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            GroupDisplayName = 'Exclude'
                        })
                    )
                    AccessGroup = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup] @{
                            desc = @('administrators')
                            member = @('S-1-12-1-1167842105-1150511762-402702254-1917434032')
                            action = 'AddUpdate'
                            userselectiontype = 'users'
                        })
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the instance exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalUserGroupMembershipPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            DeviceAndAppManagementAssignmentFilterType = 'none'
                            GroupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            GroupDisplayName = 'Exclude'
                        })
                    )
                    AccessGroup = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogAccessGroup] @{
                            desc = @('administrators')
                            member = @('S-1-12-1-1167842105-1150511762-402702254-1917434032')
                            action = 'AddUpdate'
                            userselectiontype = 'users'
                        })
                    )
                    Credential  = $Credential
                    Description = 'My Test Description'
                    DisplayName = 'My Test'
                    Ensure      = 'Absent'
                    Identity    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAccountProtectionLocalUserGroupMembershipPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
