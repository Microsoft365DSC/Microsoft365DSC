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
    -DscResource "IntuneFirewallRulesPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = '19c8aa67-f286-4861-9aa0-f23541d31680_1'
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
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                Name = '{FirewallRuleName}'
                                OffsetUri = '/MdmStore/FirewallRules/{0}'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 150
                                childIds = @(
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_firewallrulename'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_servicename'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled'
                                    'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type'
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_firewallrulename'
                                Name = 'FirewallRuleName'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/FirewallRuleName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction'
                                Name = 'Direction'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/Direction'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out'
                                        name = 'The rule applies to outbound traffic.'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                                parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'OUT'
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes'
                                Name = 'InterfaceTypes'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/InterfaceTypes'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 100
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_lan'
                                        name = 'Lan'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                                parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'Lan'
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges'
                                Name = 'RemotePortRanges'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/RemotePortRanges'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 600
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name'
                                Name = 'Name'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/Name'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath'
                                Name = 'FilePath'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/App/FilePath'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol'
                                Name = 'Protocol'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/Protocol'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_servicename'
                                Name = 'ServiceName'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/App/ServiceName'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                        parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled'
                                Name = 'Enabled'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/Enabled'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1'
                                        name = 'Enabled'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                                parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type'
                                Name = 'Type'
                                OffsetUri = '/MdmStore/FirewallRules/{0}/Action/Type'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_1'
                                        name = 'Allow'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                                parentSettingId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '76c7a8be-67d2-44bf-81a5-38c94926b1a1'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled'
                                            choiceSettingValue = @{
                                                children = @()
                                                value = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_enabled_1'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_name'
                                            simpleSettingValue = @{
                                                value = '__Test'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes'
                                            choiceSettingCollectionValue = @(
                                                @{
                                                    children = @()
                                                    value = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_interfacetypes_lan'
                                                }
                                            )
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_filepath'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'C:\Temp\bla2'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_remoteportranges'
                                            simpleSettingCollectionValue = @(
                                                @{
                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                    value = '0-100'
                                                }
                                            )
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction'
                                            choiceSettingValue = @{
                                                children = @()
                                                value = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_direction_out'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_app_servicename'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'mysvc'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type'
                                            choiceSettingValue = @{
                                                children = @()
                                                value = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_action_type_1'
                                            }
                                        },
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'vendor_msft_firewall_mdmstore_firewallrules_{firewallrulename}_protocol'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = 80
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
        Context -Name "The IntuneFirewallRulesPolicyWindows10 should exist but it DOES NOT" -Fixture {
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
                    FirewallRuleName = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName] @{
                            Direction = 'out'
                            InterfaceTypes = @('lan')
                            RemotePortRanges = @('0-100')
                            Name = '__Test'
                            FilePath = 'C:\Temp\bla2'
                            Protocol = 80
                            ServiceName = 'mysvc'
                            Enabled = 1
                            Type = 1
                        })
                    )
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneFirewallRulesPolicyWindows10 exists but it SHOULD NOT" -Fixture {
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
                    FirewallRuleName = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName] @{
                            Direction = 'out'
                            InterfaceTypes = @('lan')
                            RemotePortRanges = @('0-100')
                            Name = '__Test'
                            FilePath = 'C:\Temp\bla2'
                            Protocol = 80
                            ServiceName = 'mysvc'
                            Enabled = 1
                            Type = 1
                        })
                    )
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneFirewallRulesPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
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
                    FirewallRuleName = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName] @{
                            Direction = 'out'
                            InterfaceTypes = @('lan')
                            RemotePortRanges = @('0-100')
                            Name = '__Test'
                            FilePath = 'C:\Temp\bla2'
                            Protocol = 80
                            ServiceName = 'mysvc'
                            Enabled = 1
                            Type = 1
                        })
                    )
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneFirewallRulesPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
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
                    FirewallRuleName = @(
                        ([MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName] @{
                            Direction = 'in' # Drift
                            InterfaceTypes = @('lan')
                            RemotePortRanges = @('0-100')
                            Name = '__Test'
                            FilePath = 'C:\Temp\bla2'
                            Protocol = 80
                            ServiceName = 'mysvc'
                            Enabled = 1
                            Type = 1
                        })
                    )
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneFirewallRulesPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneFirewallRulesPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
