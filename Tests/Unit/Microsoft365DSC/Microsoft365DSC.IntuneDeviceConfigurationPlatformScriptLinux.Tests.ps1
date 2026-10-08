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
    -DscResource "IntuneDeviceConfigurationPlatformScriptLinux" -GenericStubModule $GenericStubPath
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
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = '92439f26-2b30-4503-8429-6d40f7e172dd_1'
                    }
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

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'linux_customconfig_executioncontext'
                                Name = 'CustomConfigExecutionContext'
                                OffsetUri = 'CustomConfig/ExecutionContext'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Root'
                                        itemId = 'linux_customconfig_executioncontext_root'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'root'
                                        }
                                    }
                                    @{
                                        name = 'User'
                                        itemId = 'linux_customconfig_executioncontext_user'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'user'
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'linux_customconfig_executioncontext'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '2c59a6c5-e874-445b-ac5a-d53688ef838e'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'linux_customconfig_executioncontext_user'
                            }
                        }
                    }
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'linux_customconfig_executionfrequency'
                                Name = 'CustomConfigExecutionFrequency'
                                OffsetUri = 'CustomConfig/ExecutionFrequency'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Every 15 minutes'
                                        itemId = 'linux_customconfig_executionfrequency_15minutes'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 15
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'linux_customconfig_executionfrequency'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'f42b866f-ff2b-4d19-bef8-63e7c763d49b'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'linux_customconfig_executionfrequency_15minutes'
                            }
                        }
                    }
                    @{
                        Id = '2'
                        SettingDefinitions = @(
                            @{
                                Id = 'linux_customconfig_executionretries'
                                Name = 'CustomConfigExecutionRetries'
                                OffsetUri = 'CustomConfig/ExecutionRetries'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = '2 times'
                                        itemId = 'linux_customconfig_executionretries_2'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 2
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'linux_customconfig_executionretries'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'a3326517-152b-4b32-bc11-8772b5b4fe6a'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'linux_customconfig_executionretries_2'
                            }
                        }
                    }
                    @{
                        Id = '3'
                        SettingDefinitions = @(
                            @{
                                Id = 'linux_customconfig_script'
                                Name = 'CustomConfig_Script'
                                OffsetUri = '/CustomConfig/Script'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'linux_customconfig_script'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'add4347a-f9aa-4202-a497-34a4c178d013'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                            simpleSettingValue = @{
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                value = 'IyEvYmluL3NoDQoNCmVjaG8gYWJj'
                            }
                        }
                    }
                )
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
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
        Context -Name "The IntuneDeviceConfigurationPlatformScriptLinux should exist but it DOES NOT" -Fixture {
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
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    CustomConfig_Script            = "#!/bin/sh

echo abc";
                    CustomConfigExecutionContext   = "user";
                    CustomConfigExecutionFrequency = 15;
                    CustomConfigExecutionRetries   = 2;
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationPlatformScriptLinux exists but it SHOULD NOT" -Fixture {
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
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    CustomConfig_Script            = "#!/bin/sh

echo abc";
                    CustomConfigExecutionContext   = "user";
                    CustomConfigExecutionFrequency = 15;
                    CustomConfigExecutionRetries   = 2;
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationPlatformScriptLinux Exists and Values are already in the desired state" -Fixture {
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
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    CustomConfig_Script            = "#!/bin/sh

echo abc";
                    CustomConfigExecutionContext   = "user";
                    CustomConfigExecutionFrequency = 15;
                    CustomConfigExecutionRetries   = 2;
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceConfigurationPlatformScriptLinux exists and values are NOT in the desired state" -Fixture {
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
                    Id = "12345-12345-12345-12345-12345"
                    DisplayName = "My Test"
                    CustomConfig_Script            = "#!/bin/sh

echo abc";
                    CustomConfigExecutionContext   = "root"; # Drift
                    CustomConfigExecutionFrequency = 15;
                    CustomConfigExecutionRetries   = 2;
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationPlatformScriptLinux' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
