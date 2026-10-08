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
    -DscResource 'IntuneAppConfigurationPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Update-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
                return @{
                    DisplayName = 'Test App Configuration Policy Desire State'
                    Description = 'Test Definition'
                    Id          = 'A_19dbaff5-9aff-48b0-a60d-d0471ddaf141'
                    RoleScopeTagIds             = @("0")
                    TargetedAppManagementLevels = "unspecified"
                    AppGroupType                = "selectedPublicApps"
                    CustomSettings              = @(
                        @{
                            name  = 'FakeStringValue'
                            value = '1'
                        }
                    )
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementTargetedManagedAppConfigurationAssignment -MockWith {
                return @()
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Get-MgBetaDeviceAppManagementTargetedManagedAppConfigurationApp -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the App Configuration Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test App Configuration Policy'
                    Description = 'Test Definition'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Get().ToHashtable() ).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceAppManagementTargetedManagedAppConfiguration' -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test App Configuration Policy'
                    Description = 'Test Definition'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    RoleScopeTagIds             = @("0")
                    TargetedAppManagementLevels = "unspecified"
                    AppGroupType                = "selectedPublicApps"
                    CustomSettings              = @(
                        ([MSFT_IntuneAppConfigurationPolicyCustomSetting] @{
                            name  = 'FakeStringValue'
                            value = '2' # Updated property
                        })
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -Exactly 1
            }
        }

        Context -Name 'When the policy already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test App Configuration Policy Desire State'
                    Description = 'Test Definition'
                    Ensure      = 'Present'
                    Credential  = $Credential
                    RoleScopeTagIds             = @("0")
                    TargetedAppManagementLevels = "unspecified"
                    AppGroupType                = "selectedPublicApps"
                     CustomSettings             = @(
                        ([MSFT_IntuneAppConfigurationPolicyCustomSetting] @{
                            name  = 'FakeStringValue'
                            value = '1'
                        })
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the policy exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test App Configuration Policy'
                    Description = 'Test Definition'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                    RoleScopeTagIds             = @("0")
                    TargetedAppManagementLevels = "unspecified"
                    AppGroupType                = "selectedPublicApps"
                     CustomSettings              = @(
                        ([MSFT_IntuneAppConfigurationPolicyCustomSetting] @{
                            name  = 'FakeStringValue'
                            value = '1'
                        })
                    )
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the App Configuration Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppConfigurationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementTargetedManagedAppConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppConfigurationPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
