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
    -DscResource "IntuneAppControlForBusinessPolicyWindows10" -GenericStubModule $GenericStubPath
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
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    Description = 'My Test Description'
                    Name        = 'My Test'
                    RoleScopeTagIds = @('FakeStringValue')
                    TemplateReference = @{
                        TemplateId = 'd3849ba8-bf95-467c-9640-aa2334eae9e3_1'
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

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = 0
                    SettingDefinitions   = @(
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                            Name = 'ConfigureApplicationControlOptions'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_upload_xml_selected'
                                    name = 'XML upload'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 0
                                    }
                                }
                                @{
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                    name = 'Built-in controls'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 1
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_auditmode'
                            Name = 'ConfigureApplicationControlsAuditMode'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_auditmode_disabled'
                                    name = 'Disabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 0
                                    }
                                }
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_auditmode_enabled'
                                    name = 'Enabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 1
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappsfrommanagedinstaller'
                            Name = 'ConfigureApplicationControlsTrustAppsFromManagedInstaller'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappsfrommanagedinstaller_disabled'
                                    name = 'Disabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 0
                                    }
                                },
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappsfrommanagedinstaller_enabled'
                                    name = 'Enabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 1
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappswithgoodreputation'
                            Name = 'ConfigureApplicationControlsTrustAppsWithGoodReputation'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappswithgoodreputation_disabled'
                                    name = 'Disabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 0
                                    }
                                },
                                @{
                                    dependentOn = @(
                                        @{
                                            dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                                            parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                        }
                                    )
                                    itemId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappswithgoodreputation_enabled'
                                    name = 'Enabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 1
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_xmlupload'
                            Name = 'ConfigureApplicationControlsXMLUpload'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            dependentOn = @(
                                @{
                                    dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_upload_xml_selected'
                                    parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_policy_config_applicationcontrolv2_supplementalpolicy_buildoptions_{ruleid}_type_filehashdetails'
                            Name = 'ApplicationControlV2_SupplementalPolicy_Rule_FileHash'
                            OffsetUri = '/Policies/{PolicyGuid}/Policy/{0}'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            dependentOn = @(
                                @{
                                    dependentOn = 'device_vendor_msft_policy_config_applicationcontrolv2_supplementalpolicy_buildoptions_{ruleid}_type_filehash'
                                    parentSettingId = 'device_vendor_msft_policy_config_applicationcontrolv2_supplementalpolicy_buildoptions_{ruleid}_type'
                                }
                            )
                        }
                    )
                    SettingInstance      = @{
                        SettingDefinitionId              = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = 'abc5b8cd-63a0-4a1c-a34d-da84d9a93f62'
                        }
                        '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue = @{
                            children = @(
                                @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                    choiceSettingValue = @{
                                        children = @()
                                        value = 'device_vendor_msft_policy_config_applicationcontrolv2_auditmode_enabled'
                                    }
                                    settingDefinitionId = 'device_vendor_msft_policy_config_applicationcontrolv2_auditmode'
                                }
                                @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                    settingDefinitionId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappsfrommanagedinstaller'
                                    choiceSettingValue = @{
                                        children = @()
                                        value = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappsfrommanagedinstaller_enabled'
                                    }
                                }
                                @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                    settingDefinitionId = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappswithgoodreputation'
                                    choiceSettingValue = @{
                                        children = @()
                                        value = 'device_vendor_msft_policy_config_applicationcontrolv2_trustappswithgoodreputation_enabled'
                                    }
                                }
                            )
                            value = 'device_vendor_msft_policy_config_applicationcontrolv2_buildoptions_built_in_controls_selected'
                        }
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
        }

        # Test contexts
        Context -Name "The IntuneAppControlForBusinessPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test Description"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    ConfigureApplicationControlOptions = "1"
                    ConfigureApplicationControlsAuditMode = "1"
                    ConfigureApplicationControlsTrustAppsFromManagedInstaller = "1"
                    ConfigureApplicationControlsTrustAppsWithGoodReputation = "1"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAppControlForBusinessPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test Description"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    ConfigureApplicationControlOptions = "1"
                    ConfigureApplicationControlsAuditMode = "1"
                    ConfigureApplicationControlsTrustAppsFromManagedInstaller = "1"
                    ConfigureApplicationControlsTrustAppsWithGoodReputation = "1"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAppControlForBusinessPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test Description"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    ConfigureApplicationControlOptions = "1"
                    ConfigureApplicationControlsAuditMode = "1"
                    ConfigureApplicationControlsTrustAppsFromManagedInstaller = "1"
                    ConfigureApplicationControlsTrustAppsWithGoodReputation = "1"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAppControlForBusinessPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test Description"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    ConfigureApplicationControlOptions = "1"
                    ConfigureApplicationControlsAuditMode = "1"
                    ConfigureApplicationControlsTrustAppsFromManagedInstaller = "1"
                    ConfigureApplicationControlsTrustAppsWithGoodReputation = "0" # Drift
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppControlForBusinessPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
