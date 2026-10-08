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
    -DscResource 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id    = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    Description = 'My Test Description'
                    Name        = 'My Test'
                    TemplateReference = @{
                        TemplateId = 'adc46e5a-f4aa-4ff6-aeff-4f27bc525796_1'
                    }
                }
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @{
                    Id                   = 0
                    SettingDefinitions   = @(
                        @{
                            Id = 'device_vendor_msft_laps_policies_backupdirectory'
                            Name = 'BackupDirectory'
                            OffsetUri = '/Policies/BackupDirectory'
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                            options = @(
                                @{
                                    itemId = 'device_vendor_msft_laps_policies_backupdirectory_1'
                                    name   = 'Backup the password to Azure AD only'
                                    optionValue = @{
                                        '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                        value = 1
                                    }
                                }
                            )
                        }
                    )
                    SettingInstance      = @{
                        SettingDefinitionId              = 'device_vendor_msft_laps_policies_backupdirectory'
                        SettingInstanceTemplateReference = @{
                            SettingInstanceTemplateId = 'a3270f64-e493-499d-8900-90290f61ed8a'
                        }
                        '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        choiceSettingValue = @{
                            children = @()
                            value = "device_vendor_msft_laps_policies_backupdirectory_1"
                        }
                    }
                }
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Exclude'
                }
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
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
                        ([MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Credential      = $Credential
                    Description     = 'My Test Description'
                    DisplayName     = 'My Test'
                    Ensure          = 'Present'
                    Identity        = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    BackupDirectory = '1'
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementConfigurationPolicy' -Exactly 1
            }
        }

        Context -Name 'When the instance already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    Credential      = $Credential
                    Description     = 'My Test Description'
                    DisplayName     = 'My Test'
                    Ensure          = 'Present'
                    Identity        = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                    BackupDirectory = '0' # Drift
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Set()
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
                        ([MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            groupDisplayName = 'Exclude'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                        })
                    )
                    BackupDirectory = '1'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the instance exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            groupDisplayName = 'Exclude'
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
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAccountProtectionLocalAdministratorPasswordSolutionPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
