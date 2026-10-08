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
    -DscResource 'SCDeviceConditionalAccessPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)


            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Import-PSSession -MockWith {
            }

            Mock -CommandName New-PSSession -MockWith {
            }

            Mock -CommandName Remove-DeviceConditionalAccessPolicy -MockWith {
                # This mock should not return anything. Remove-* are normally void methods without any return types
            }

            Mock -CommandName Set-DeviceConditionalAccessPolicy -MockWith {
            }

            Mock -CommandName New-DeviceConditionalAccessPolicy -MockWith {
                return @{
                    # This mock can simply return an empty object for the purpose of these tests.
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "The Conditional Device Access Policy doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestPolicy'
                    Comment    = 'This is a test comment'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-DeviceConditionalAccessPolicy -MockWith {
                    return $null # Policy Not found, therefore return null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Set()

                # Because the policy was not found, the set method should attempt to create it
                # Therefore we want to assess that the New-* method was called exactly once
                Should -Invoke -CommandName 'New-DeviceConditionalAccessPolicy' -Exactly 1
            }
        }

        Context -Name 'The Conditional Device Access Policy already exists and it is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestPolicy'
                    Comment    = 'This is a test comment'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-DeviceConditionalAccessPolicy -MockWith {
                    return @{
                        Name    = 'TestPolicy'
                        Comment = 'This is a test comment'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'The Conditional Device Access Policy already exists and it is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestPolicy'
                    Comment    = 'This is a test comment'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-DeviceConditionalAccessPolicy -MockWith {
                    return @{
                        Name    = 'TestPolicy'
                        # Returns a drift in the comments property because it needs to not be in desired state
                        Comment = 'This is a DRIFT'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should update the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-DeviceConditionalAccessPolicy' -Exactly 1
            }
        }

        Context -Name 'The Conditional Device Access Policy Exists but it Should NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'TestPolicy'
                    Comment    = 'This is a test comment'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-DeviceConditionalAccessPolicy -MockWith {
                    return @{
                        Name    = 'TestPolicy'
                        Comment = 'This is a test comment'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should Delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCDeviceConditionalAccessPolicy' -Property $testParams).Set()

                # Because the policy was not found, the set method should attempt to delete it
                # Therefore we want to assess that the Remove-* method was called exactly once
                Should -Invoke -CommandName 'Remove-DeviceConditionalAccessPolicy' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-DeviceConditionalAccessPolicy -MockWith {
                    return @{
                        Name    = 'TestPolicy'
                        Comment = 'This is a test comment'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCDeviceConditionalAccessPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
