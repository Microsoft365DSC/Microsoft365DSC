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
    -DscResource "IntuneDiskEncryptionFileVaultPolicyMacOS" -GenericStubModule $GenericStubPath
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
                        TemplateId = 'e688156f-6564-4c03-b34f-83b90fe6bb82_1'
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
                                Id = 'com.apple.mcx.filevault2_deferdontaskatuserlogout'
                                Name = 'DeferDontAskAtUserLogout'
                                OffsetUri = 'DeferDontAskAtUserLogout'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Disabled'
                                        itemId = 'com.apple.mcx.filevault2_deferdontaskatuserlogout_false'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                                parentSettingId = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'false'
                                        }
                                    }
                                    @{
                                        name = 'Enabled'
                                        itemId = 'com.apple.mcx.filevault2_deferdontaskatuserlogout_true'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                                parentSettingId = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'true'
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'com.apple.mcx.filevault2_deferforceatuserloginmaxbypassattempts'
                                Name = 'DeferForceAtUserLoginMaxBypassAttempts'
                                OffsetUri = 'DeferForceAtUserLoginMaxBypassAttempts'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                        parentSettingId = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                    }
                                )
                            },
                            @{
                                Id = 'com.apple.mcx.filevault2_defer'
                                Name = 'Defer'
                                OffsetUri = 'Defer'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        name = 'Enabled'
                                        itemId = 'com.apple.mcx.filevault2_defer_true'
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                                parentSettingId = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                            }
                                        )
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = 'true'
                                        }
                                    }
                                )
                            },
                            @{
                                Id = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                                Name = 'com.apple.MCX.FileVault2'
                                OffsetUri = 'com.apple.MCX.FileVault2'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 1
                                childIds = @(
                                    'com.apple.mcx.filevault2_defer'
                                    'com.apple.mcx.filevault2_deferdontaskatuserlogout'
                                    'com.apple.mcx.filevault2_deferforceatuserloginmaxbypassattempts'
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'com.apple.mcx.filevault2_com.apple.mcx.filevault2'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '0e20e909-e28a-41a1-8541-5aadd4714d7d'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'com.apple.mcx.filevault2_defer'
                                            choiceSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                children = @()
                                                value = 'com.apple.mcx.filevault2_defer_true'
                                            }
                                        }
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                            settingDefinitionId = 'com.apple.mcx.filevault2_deferdontaskatuserlogout'
                                            choiceSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                children = @()
                                                value = 'com.apple.mcx.filevault2_deferdontaskatuserlogout_false'
                                            }
                                        }
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'com.apple.mcx.filevault2_deferforceatuserloginmaxbypassattempts'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                                value = 5
                                            }
                                        }
                                    )
                                }
                            )
                        }
                    }
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'com.apple.security.fderecoverykeyescrow_com.apple.security.fderecoverykeyescrow'
                                Name = 'com.apple.security.FDERecoveryKeyEscrow'
                                OffsetUri = 'com.apple.security.FDERecoveryKeyEscrow'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 1
                                childIds = @(
                                    'com.apple.security.fderecoverykeyescrow_location'
                                    'com.apple.security.fderecoverykeyescrow_devicekey'
                                )
                            }
                            @{
                                Id = 'com.apple.security.fderecoverykeyescrow_location'
                                Name = 'Location'
                                OffsetUri = 'Location'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                                dependentOn = @(
                                    @{
                                        dependentOn = 'com.apple.security.fderecoverykeyescrow_com.apple.security.fderecoverykeyescrow'
                                        parentSettingId = 'com.apple.security.fderecoverykeyescrow_com.apple.security.fderecoverykeyescrow'
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'com.apple.security.fderecoverykeyescrow_com.apple.security.fderecoverykeyescrow'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '6f9cb7be-2e50-408a-b24b-6e1387a07fc7'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                            groupSettingCollectionValue = @(
                                @{
                                    children = @(
                                        @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingDefinitionId = 'com.apple.security.fderecoverykeyescrow_location'
                                            simpleSettingValue = @{
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                value = 'FakeStringValue'
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
        Context -Name "The IntuneDiskEncryptionFileVaultPolicyMacOS should exist but it DOES NOT" -Fixture {
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
                    Defer                                  = "true";
                    DeferDontAskAtUserLogout               = "false";
                    DeferForceAtUserLoginMaxBypassAttempts = 5;
                    Location                               = "FakeStringValue";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDiskEncryptionFileVaultPolicyMacOS exists but it SHOULD NOT" -Fixture {
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
                    Defer                                  = "true";
                    DeferDontAskAtUserLogout               = "false";
                    DeferForceAtUserLoginMaxBypassAttempts = 5;
                    Location                               = "FakeStringValue";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneDiskEncryptionFileVaultPolicyMacOS Exists and Values are already in the desired state" -Fixture {
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
                    Defer                                  = "true";
                    DeferDontAskAtUserLogout               = "false";
                    DeferForceAtUserLoginMaxBypassAttempts = 5;
                    Location                               = "FakeStringValue";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDiskEncryptionFileVaultPolicyMacOS exists and values are NOT in the desired state" -Fixture {
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
                    Defer                                  = "true";
                    DeferDontAskAtUserLogout               = "true"; # Drift
                    DeferForceAtUserLoginMaxBypassAttempts = 5;
                    Location                               = "FakeStringValue";
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDiskEncryptionFileVaultPolicyMacOS' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
