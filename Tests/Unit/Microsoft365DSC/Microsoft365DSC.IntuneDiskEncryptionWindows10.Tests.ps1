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
    -DscResource "IntuneDiskEncryptionWindows10" -GenericStubModule $GenericStubPath
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
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = '46ddfc50-d10f-4867-b852-9434254b3bff_1'
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

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = '0'
                    SettingDefinitions   = @(
                        @{
                            Id = 'device_vendor_msft_bitlocker_identificationfield_identificationfield'
                            Name = 'IdentificationField'
                            OffsetUri = '/IdentificationField'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                        },
                        @{
                            Id = 'device_vendor_msft_bitlocker_identificationfield'
                            Name = 'IdentificationField_Name'
                            OffsetUri = '/IdentificationField'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_bitlocker_identificationfield_1'
                                    name = 'Enabled'
                                    optionValue = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        value = 1
                                    }
                                }
                            )
                        },
                        @{
                            Id = 'device_vendor_msft_bitlocker_identificationfield_secidentificationfield'
                            Name = 'SecIdentificationField'
                            OffsetUri = '/IdentificationField'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                        }
                    )
                    SettingInstance      = @{
                        SettingDefinitionId              = 'device_vendor_msft_bitlocker_identificationfield'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = '3aeb9145-2c02-4086-8886-44dbe09c2f62'
                        }
                        '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue = @{
                            children = @(
                                @{
                                    '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                    settingDefinitionId = 'device_vendor_msft_bitlocker_identificationfield_identificationfield'
                                    simpleSettingValue  = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        value = 'Field'
                                    }
                                },
                                @{
                                    '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                    settingDefinitionId = 'device_vendor_msft_bitlocker_identificationfield_secidentificationfield'
                                    simpleSettingValue  = @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        value = 'SecField'
                                    }
                                }
                            )
                            value = 'device_vendor_msft_bitlocker_identificationfield_1'
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
                        DeviceAndAppManagementAssignmentFilterId   = '12345-12345-12345-12345-12345'
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                        groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
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
        Context -Name "The IntuneDiskEncryptionWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IdentificationField_Name = "1"
                    IdentificationField = "Field"
                    SecIdentificationField = "SecField"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDiskEncryptionWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IdentificationField_Name = "1"
                    IdentificationField = "Field"
                    SecIdentificationField = "SecField"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }
        Context -Name "The IntuneDiskEncryptionWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IdentificationField_Name = "1"
                    IdentificationField = "Field"
                    SecIdentificationField = "SecField"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDiskEncryptionWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                        })
                    )
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    IdentificationField_Name = "1"
                    IdentificationField = "Field"
                    SecIdentificationField = "No - SecField" # Updated property
                    DisplayName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDiskEncryptionWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
