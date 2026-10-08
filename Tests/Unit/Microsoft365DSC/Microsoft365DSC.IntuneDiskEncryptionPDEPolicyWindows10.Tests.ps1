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
    -DscResource "IntuneDiskEncryptionPDEPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                        TemplateId = '0b5708d9-9bc2-49a9-b4f7-ec463fcc41e0_1'
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
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'user_vendor_msft_pde_enablepersonaldataencryption'
                                Name = 'EnablePersonalDataEncryption'
                                OffsetUri = '/EnablePersonalDataEncryption'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Enable Personal Data Encryption.'
                                        itemId = 'user_vendor_msft_pde_enablepersonaldataencryption_1'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'user_vendor_msft_pde_protectfolders_protectdesktop'
                                Name = 'ProtectDesktop'
                                OffsetUri = '/ProtectFolders/ProtectDesktop'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Disable PDE on the folder. If the folder is currently protected by PDE, this will result in unprotecting the folder.'
                                        itemId = 'user_vendor_msft_pde_protectfolders_protectdesktop_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'user_vendor_msft_pde_enablepersonaldataencryption_1'
                                                parentSettingId = 'user_vendor_msft_pde_enablepersonaldataencryption'
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
                                Id = 'user_vendor_msft_pde_protectfolders_protectpictures'
                                Name = 'ProtectPictures'
                                OffsetUri = '/ProtectFolders/ProtectPictures'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Disable PDE on the folder. If the folder is currently protected by PDE, this will result in unprotecting the folder.'
                                        itemId = 'user_vendor_msft_pde_protectfolders_protectpictures_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'user_vendor_msft_pde_enablepersonaldataencryption_1'
                                                parentSettingId = 'user_vendor_msft_pde_enablepersonaldataencryption'
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
                                Id = 'user_vendor_msft_pde_protectfolders_protectdocuments'
                                Name = 'ProtectDocuments'
                                OffsetUri = '/ProtectFolders/ProtectDocuments'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Disable PDE on the folder. If the folder is currently protected by PDE, this will result in unprotecting the folder.'
                                        itemId = 'user_vendor_msft_pde_protectfolders_protectdocuments_0'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'user_vendor_msft_pde_enablepersonaldataencryption_1'
                                                parentSettingId = 'user_vendor_msft_pde_enablepersonaldataencryption'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'user_vendor_msft_pde_enablepersonaldataencryption'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '1ba5dce6-3ba0-40f3-bde3-811ed766c14a'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                value = 'user_vendor_msft_pde_enablepersonaldataencryption_1'
                                children = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'user_vendor_msft_pde_protectfolders_protectdesktop'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'user_vendor_msft_pde_protectfolders_protectdesktop_0'
                                        }
                                    },
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'user_vendor_msft_pde_protectfolders_protectpictures'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'user_vendor_msft_pde_protectfolders_protectpictures_0'
                                        }
                                    },
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        settingDefinitionId = 'user_vendor_msft_pde_protectfolders_protectdocuments'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'user_vendor_msft_pde_protectfolders_protectdocuments_0'
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
        Context -Name "The IntuneDiskEncryptionPDEPolicyWindows10 should exist but it DOES NOT" -Fixture {
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
                    EnablePersonalDataEncryption = "1";
                    ProtectDesktop               = "0";
                    ProtectDocuments             = "0";
                    ProtectPictures              = "0";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDiskEncryptionPDEPolicyWindows10 exists but it SHOULD NOT" -Fixture {
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
                    EnablePersonalDataEncryption = "1";
                    ProtectDesktop               = "0";
                    ProtectDocuments             = "0";
                    ProtectPictures              = "0";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDiskEncryptionPDEPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
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
                    EnablePersonalDataEncryption = "1";
                    ProtectDesktop               = "0";
                    ProtectDocuments             = "0";
                    ProtectPictures              = "0";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDiskEncryptionPDEPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
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
                    EnablePersonalDataEncryption = "1";
                    ProtectDesktop               = "0";
                    ProtectDocuments             = "1"; # Drift
                    ProtectPictures              = "0";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDiskEncryptionPDEPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
