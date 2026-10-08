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
    -DscResource "IntuneSecurityBaselineWindows365" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

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
                       TemplateId = 'b00e1a0f-19dd-41de-8243-e6733ca7b4ae_1'
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
                                    Id = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel'
                                    Name = 'Pol_MSS_DisableIPSourceRoutingIPv6'
                                    OffsetUri = '/Config/MSSLegacy/IPv6SourceRoutingProtectionLevel'
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                    options = @(
                                        @{
                                            name ='Enabled'
                                            itemId = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_1'
                                            optionValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = 1
                                            }
                                        }
                                    )
                                },
                                @{
                                    Id = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_disableipsourceroutingipv6'
                                    Name = 'DisableIPSourceRoutingIPv6'
                                    OffsetUri = '/Config/MSSLegacy/IPv6SourceRoutingProtectionLevel'
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                    options = @(
                                        @{
                                            name ='Highest protection, source routing is completely disabled'
                                            itemId = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_disableipsourceroutingipv6_2'
                                            dependentOn = @(
                                                @{
                                                    dependentOn = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_1'
                                                    parentSettingId = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel'
                                                }
                                            )
                                            optionValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = 2
                                            }
                                        }
                                    )
                                }
                            )
                            SettingInstance = @{
                                SettingDefinitionId = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel'
                                SettingInstanceTemplateReference = @{
                                    SettingInstanceTemplateId = 'da4ba0c4-1574-481c-bc7d-02204d84d7a8'
                                }
                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                choiceSettingValue = @{
                                    children = @(
                                        @{
                                            SettingDefinitionId = 'device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_disableipsourceroutingipv6'
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                            choiceSettingValue = @{
                                                children = @()
                                                value = "device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_disableipsourceroutingipv6_2"
                                            }
                                        }
                                    )
                                    value = "device_vendor_msft_policy_config_msslegacy_ipv6sourceroutingprotectionlevel_1"
                                }
                            }
                    }
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths'
                                Name = 'Pol_HardenedPaths'
                                OffsetUri = '/Config/Connectivity/HardenedUNCPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name ='Enabled'
                                        itemId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                Name = 'Pol_HardenedPaths'
                                OffsetUri = '/Config/Connectivity/HardenedUNCPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                maximumCount = 600
                                minimumCount = 1
                                childIds = @(
                                    'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_key',
                                    'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_value'
                                )
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_1'
                                        parentSettingId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths'
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_value'
                                Name = 'Pol_HardenedPaths'
                                OffsetUri = '/Config/Connectivity/HardenedUNCPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                        parentSettingId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_key'
                                Name = 'Pol_HardenedPaths'
                                OffsetUri = '/Config/Connectivity/HardenedUNCPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                        parentSettingId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'd91dd0cc-d856-48ca-817a-2f6e96013d30'
                            }
                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                             choiceSettingValue = @{
                                children = @(
                                    @{
                                        SettingDefinitionId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths'
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance"
                                        groupSettingCollectionValue = @(
                                            @{
                                                children = @(
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                        settingDefinitionId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_value'
                                                        simpleSettingValue = @{
                                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            value = 'RequireMutualAuthentication=1,RequireIntegrity=1'
                                                        }
                                                    },
                                                    @{
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                        settingDefinitionId = 'device_vendor_msft_policy_config_connectivity_hardeneduncpaths_pol_hardenedpaths_key'
                                                        simpleSettingValue = @{
                                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            value = '\\*\SYSVOL'
                                                        }
                                                    }
                                                )
                                            }
                                        )
                                    }
                                )
                                value = "device_vendor_msft_policy_config_connectivity_hardeneduncpaths_1"
                            }
                        }
                    }
                    @{
                        Id = '2'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses'
                                Name = 'DeviceInstall_Classes_Deny'
                                OffsetUri = '/Config/DeviceInstallation/PreventInstallationOfMatchingDeviceSetupClasses'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name ='Enabled'
                                        itemId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_list'
                                Name = 'DeviceInstall_Classes_Deny_List'
                                OffsetUri = '/Config/DeviceInstallation/PreventInstallationOfMatchingDeviceSetupClasses'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                maximumCount = 600
                                minimumCount = 1
                                dependentOn = @(
                                    @{
                                        dependentOn = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_1'
                                        parentSettingId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses'
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_retroactive'
                                Name = 'DeviceInstall_Classes_Deny_Retroactive'
                                OffsetUri = '/Config/DeviceInstallation/PreventInstallationOfMatchingDeviceSetupClasses'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'True'
                                        itemId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_retroactive_1'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses'
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
                            SettingDefinitionId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'e66778d2-c783-4359-8ddb-afeff7defa04'
                            }
                           '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                            choiceSettingValue = @{
                                children = @(
                                    @{
                                        SettingDefinitionId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_list'
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance"
                                        groupSettingCollectionValue = @{
                                            children = @(
                                                @{
                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                                    settingDefinitionId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_list'
                                                    simpleSettingCollectionValue = @{
                                                        value = '{d48179be-ec20-11d1-b6b8-00c04fa372a7}'
                                                    }
                                                },
                                                @{
                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                                    settingDefinitionId = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_retroactive'
                                                    choiceSettingValue = @{
                                                        children = @()
                                                        value = 'device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_deviceinstall_classes_deny_retroactive_1'
                                                    }
                                                }
                                            )
                                        }
                                    }
                                )
                                value = "device_vendor_msft_policy_config_deviceinstallation_preventinstallationofmatchingdevicesetupclasses_1"
                            }
                        }
                    }
                    @{
                        Id = '3'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry'
                                Name = 'CSE_Registry'
                                OffsetUri = '/Config/ADMX_GroupPolicy/CSE_Registry'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name ='Enabled'
                                        itemId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nobackground10'
                                Name = 'CSE_NOBACKGROUND10'
                                OffsetUri = '/Config/ADMX_GroupPolicy/CSE_Registry'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'False'
                                        itemId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nobackground10_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nochanges10'
                                Name = 'CSE_NOCHANGES10'
                                OffsetUri = '/Config/ADMX_GroupPolicy/CSE_Registry'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name ='True'
                                        itemId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nochanges10_1'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry'
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
                            SettingDefinitionId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '126e039f-ac4b-4854-8d05-06261efbcc59'
                            }
                           '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                            choiceSettingValue = @{
                                children = @(
                                    @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                        settingDefinitionId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nobackground10'
                                        choiceSettingValue = @{
                                            value = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nobackground10_0'
                                        }
                                    },
                                    @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                                        settingDefinitionId = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nochanges10'
                                        choiceSettingValue = @{
                                            value = 'device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_cse_nochanges10_1'
                                        }
                                    }
                                )
                                value = "device_vendor_msft_policy_config_admx_grouppolicy_cse_registry_1"
                            }
                        }
                    }
                    @{
                        Id = '4'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_userrights_createpagefile'
                                Name = 'CreatePageFile'
                                OffsetUri = '/Config/UserRights/CreatePageFile'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                maximumCount = 600
                                minimumCount = 0
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_userrights_createpagefile'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '37b58477-a9a4-41f6-902d-10802cbabd75'
                            }
                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
                            simpleSettingCollectionValue = @(
                                @{
                                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                    value = '*S-1-5-32-544'
                                }
                            )
                        }
                    },
                    @{
                        Id = '5'
                        SettingDefinitions = @(
                            @{
                                Id = 'user_vendor_msft_policy_config_experience_allowwindowsspotlight'
                                Name = 'AllowWindowsSpotlight'
                                OffsetUri = '/Config/Experience/AllowWindowsSpotlight'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Allowed.'
                                        itemId = 'user_vendor_msft_policy_config_experience_allowwindowsspotlight_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'user_vendor_msft_policy_config_experience_allowwindowsspotlight'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'e413c297-48d9-4906-af61-bc0063112e4a'
                            }
                           '@odata.type' = "#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance"
                            choiceSettingValue = @{
                                children = @()
                                value = "user_vendor_msft_policy_config_experience_allowwindowsspotlight_1"
                            }
                        }
                    }
                )
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
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
        Context -Name "The IntuneSecurityBaselineWindows365 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        })
                    )
                    Description = "My Test"
                    deviceSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365] @{
                        Pol_MSS_DisableIPSourceRoutingIPv6 = 1
                        DisableIPSourceRoutingIPv6 = 2
                        DeviceInstall_Classes_Deny = 1
                        DeviceInstall_Classes_Deny_List = @('{d48179be-ec20-11d1-b6b8-00c04fa372a7}')
                        DeviceInstall_Classes_Deny_Retroactive = 1
                        CSE_Registry = 1
                        CSE_NOBACKGROUND10 = 0
                        CSE_NOCHANGES10 = 1
                        CreatePageFile = @('*S-1-5-32-544')
                        HardenedUNCPaths_Pol_HardenedPaths = 1
                        pol_hardenedpaths = @(
                            ([MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths] @{
                                value = "RequireMutualAuthentication=1,RequireIntegrity=1"
                                key = "\\*\SYSVOL"
                            })
                        )
                    })
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    userSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365] @{
                        AllowWindowsSpotlight = 1
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneSecurityBaselineWindows365 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        })
                    )
                    Description = "My Test"
                    deviceSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365] @{
                        Pol_MSS_DisableIPSourceRoutingIPv6 = 1
                        DisableIPSourceRoutingIPv6 = 2
                        DeviceInstall_Classes_Deny = 1
                        DeviceInstall_Classes_Deny_List = @('{d48179be-ec20-11d1-b6b8-00c04fa372a7}')
                        DeviceInstall_Classes_Deny_Retroactive = 1
                        CSE_Registry = 1
                        CSE_NOBACKGROUND10 = 0
                        CSE_NOCHANGES10 = 1
                        CreatePageFile = @('*S-1-5-32-544')
                        HardenedUNCPaths_Pol_HardenedPaths = 1
                        pol_hardenedpaths = @(
                            ([MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths] @{
                                value = "RequireMutualAuthentication=1,RequireIntegrity=1"
                                key = "\\*\SYSVOL"
                            })
                        )
                    })
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    userSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365] @{
                        AllowWindowsSpotlight = 1
                    })
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneSecurityBaselineWindows365 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        })
                    )
                    Description = "My Test"
                    deviceSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365] @{
                        Pol_MSS_DisableIPSourceRoutingIPv6 = 1
                        DisableIPSourceRoutingIPv6 = 2
                        DeviceInstall_Classes_Deny = 1
                        DeviceInstall_Classes_Deny_List = @('{d48179be-ec20-11d1-b6b8-00c04fa372a7}')
                        DeviceInstall_Classes_Deny_Retroactive = 1
                        CSE_Registry = 1
                        CSE_NOBACKGROUND10 = 0
                        CSE_NOCHANGES10 = 1
                        CreatePageFile = @('*S-1-5-32-544')
                        HardenedUNCPaths_Pol_HardenedPaths = 1
                        pol_hardenedpaths = @(
                            ([MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths] @{
                                value = "RequireMutualAuthentication=1,RequireIntegrity=1"
                                key = "\\*\SYSVOL"
                            })
                        )
                    })
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    userSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365] @{
                        AllowWindowsSpotlight = 1
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneSecurityBaselineWindows365 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        })
                    )
                    Description = "My Test"
                    deviceSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineWindows365] @{
                        Pol_MSS_DisableIPSourceRoutingIPv6 = 1
                        DisableIPSourceRoutingIPv6 = 1 #drift
                        DeviceInstall_Classes_Deny = 1
                        DeviceInstall_Classes_Deny_List = @('{d48179be-ec20-11d1-b6b8-00c04fa372a7}')
                        DeviceInstall_Classes_Deny_Retroactive = 1
                        CSE_Registry = 1
                        CSE_NOBACKGROUND10 = 0
                        CSE_NOCHANGES10 = 1
                        CreatePageFile = @('*S-1-5-32-544')
                        HardenedUNCPaths_Pol_HardenedPaths = 1
                        pol_hardenedpaths = @(
                            ([MSFT_MicrosoftGraphIntuneSettingsCatalogpol_hardenedpaths] @{
                                value = "RequireMutualAuthentication=1,RequireIntegrity=1"
                                key = "\\*\SYSVOL"
                            })
                        )
                    })
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    userSettings = ([MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineWindows365] @{
                        AllowWindowsSpotlight = 1
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineWindows365' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneSecurityBaselineWindows365' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
