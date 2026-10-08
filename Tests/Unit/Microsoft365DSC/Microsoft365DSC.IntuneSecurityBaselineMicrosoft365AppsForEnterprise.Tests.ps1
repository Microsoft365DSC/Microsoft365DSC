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
    -DscResource "IntuneSecurityBaselineMicrosoft365AppsForEnterprise" -GenericStubModule $GenericStubPath
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
                        TemplateId = '90316f12-246d-44c6-a767-f87692e86083_2'
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
                                Id = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
                                Name = 'L_ProtectionFromZoneElevation'
                                OffsetUri = '/Config/office16v2~Policy~L_MicrosoftOfficemachine~L_SecuritySettingsMachine~L_IESecurity/L_ProtectionFromZoneElevation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                        name = 'Enabled'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_excelexe99'
                                Name = 'L_excelexe99'
                                OffsetUri = '/Config/office16v2~Policy~L_MicrosoftOfficemachine~L_SecuritySettingsMachine~L_IESecurity/L_ProtectionFromZoneElevation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'False'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_excelexe99_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    },
                                    @{
                                        name = 'True'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_excelexe99_1'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
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
                                Id = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_grooveexe98'
                                Name = 'L_grooveexe98'
                                OffsetUri = '/Config/office16v2~Policy~L_MicrosoftOfficemachine~L_SecuritySettingsMachine~L_IESecurity/L_ProtectionFromZoneElevation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'False'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_grooveexe98_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    },
                                    @{
                                        name = 'True'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_grooveexe98_1'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
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
                                Id = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_mspubexe100'
                                Name = 'L_mspubexe100'
                                OffsetUri = '/Config/office16v2~Policy~L_MicrosoftOfficemachine~L_SecuritySettingsMachine~L_IESecurity/L_ProtectionFromZoneElevation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'False'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_mspubexe100_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    },
                                    @{
                                        name = 'True'
                                        itemId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_mspubexe100_1'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                                parentSettingId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
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
                            SettingDefinitionId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '7f23a242-9f64-47a5-8a57-a4675ca74c2b'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                value = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_1'
                                children = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_grooveexe98'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_grooveexe98_1'
                                        }
                                    },
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_excelexe99'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_excelexe99_1'
                                        }
                                    },
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_mspubexe100'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'device_vendor_msft_policy_config_office16v2~policy~l_microsoftofficemachine~l_securitysettingsmachine~l_iesecurity_l_protectionfromzoneelevation_l_mspubexe100_1'
                                        }
                                    }
                                )
                            }
                        }
                    },
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates'
                                Name = 'L_Word2003BinaryDocumentsAndTemplates'
                                OffsetUri = '/Config/word16v2~Policy~L_MicrosoftOfficeWord~L_WordOptions~L_Security~L_TrustCenter~L_FileBlockSettings/L_Word2003BinaryDocumentsAndTemplates'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Enabled'
                                        itemId = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_l_word2003binarydocumentsandtemplatesdropid'
                                Name = 'L_Word2003BinaryDocumentsAndTemplatesDropID'
                                OffsetUri = '/Config/word16v2~Policy~L_MicrosoftOfficeWord~L_WordOptions~L_Security~L_TrustCenter~L_FileBlockSettings/L_Word2003BinaryDocumentsAndTemplates'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Open/Save blocked, use open policy'
                                        itemId = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_l_word2003binarydocumentsandtemplatesdropid_2'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_1'
                                                parentSettingId = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates'
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
                            SettingDefinitionId = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '23436aa2-f056-40bd-aca3-9bc84b2aeff0'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                value = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_1'
                                children = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_l_word2003binarydocumentsandtemplatesdropid'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'user_vendor_msft_policy_config_word16v2~policy~l_microsoftofficeword~l_wordoptions~l_security~l_trustcenter~l_fileblocksettings_l_word2003binarydocumentsandtemplates_l_word2003binarydocumentsandtemplatesdropid_2'
                                        }
                                    }
                                )
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
        Context -Name "The IntuneSecurityBaselineMicrosoft365AppsForEnterprise should exist but it DOES NOT" -Fixture {
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
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_ProtectionFromZoneElevation = 1
                            L_grooveexe98 = 1
                            L_excelexe99 = 1
                            L_mspubexe100 = 1
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_Word2003BinaryDocumentsAndTemplates = 1
                            L_Word2003BinaryDocumentsAndTemplatesDropID = 2
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
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneSecurityBaselineMicrosoft365AppsForEnterprise exists but it SHOULD NOT" -Fixture {
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
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_ProtectionFromZoneElevation = 1
                            L_grooveexe98 = 1
                            L_excelexe99 = 1
                            L_mspubexe100 = 1
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_Word2003BinaryDocumentsAndTemplates = 1
                            L_Word2003BinaryDocumentsAndTemplatesDropID = 2
                        }
                    )
                    Ensure = "Absent"
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }
        Context -Name "The IntuneSecurityBaselineMicrosoft365AppsForEnterprise Exists and Values are already in the desired state" -Fixture {
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
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_ProtectionFromZoneElevation = 1
                            L_grooveexe98 = 1
                            L_excelexe99 = 1
                            L_mspubexe100 = 1
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_Word2003BinaryDocumentsAndTemplates = 1
                            L_Word2003BinaryDocumentsAndTemplatesDropID = 2
                        }
                    )
                    Ensure = "Present"
                    Credential = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneSecurityBaselineMicrosoft365AppsForEnterprise exists and values are NOT in the desired state" -Fixture {
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
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_ProtectionFromZoneElevation = 1
                            L_grooveexe98 = 1
                            L_excelexe99 = 1
                            L_mspubexe100 = 0 # Drift
                        }
                    )
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    RoleScopeTagIds = @("FakeStringValue")
                    UserSettings = (
                        [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneSecurityBaselineMicrosoft365AppsForEnterprise] @{
                            L_Word2003BinaryDocumentsAndTemplates = 1
                            L_Word2003BinaryDocumentsAndTemplatesDropID = 2
                        }
                    )
                    Ensure = "Present"
                    Credential = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneSecurityBaselineMicrosoft365AppsForEnterprise' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
