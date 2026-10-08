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
    -DscResource 'IntuneDeviceAndAppManagementAssignmentFilter' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Update-MgBetaDeviceManagementAssignmentFilter -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementAssignmentFilter -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementAssignmentFilter -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith {
                return @{
                    Description                    = 'Test'
                    DisplayName                    = 'Test Device Filter'
                    AssignmentFilterManagementType = 'devices'
                    Platform                       = 'windows10AndLater'
                    RoleScopeTags                  = @('0')
                    Rule                           = "(device.manufacturer -ne `"bibi`")"
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Filter doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'Test'
                    DisplayName = 'Test Device Filter'
                    Ensure      = 'Present'
                    AssignmentFilterManagementType = 'devices'
                    Platform    = 'windows10AndLater'
                    RoleScopeTags = @('0')
                    Rule        = "(device.manufacturer -ne `"bibi`")"
                    Credential  = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementAssignmentFilter -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Android Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaDeviceManagementAssignmentFilter' -Exactly 1
            }
        }

        Context -Name 'When the Filter already exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'Test'
                    DisplayName = 'Test Device Filter'
                    Ensure      = 'Present'
                    AssignmentFilterManagementType = 'devices'
                    Platform    = 'windows10AndLater'
                    RoleScopeTags = @('0', '1')
                    Rule        = "(device.manufacturer -ne `"test`")" # Updated property
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the Device and App Management Assignment Filter from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaDeviceManagementAssignmentFilter' -Exactly 1
            }
        }

        Context -Name 'When the filter already exists and IS in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'Test'
                    DisplayName = 'Test Device Filter'
                    Ensure      = 'Present'
                    AssignmentFilterManagementType = 'devices'
                    Platform    = 'windows10AndLater'
                    RoleScopeTags = @('0')
                    Rule        = "(device.manufacturer -ne `"bibi`")"
                    Credential  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When the filter exists and it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = 'Test'
                    DisplayName = 'Test Device Filter'
                    Ensure      = 'Absent'
                    AssignmentFilterManagementType = 'devices'
                    Platform    = 'windows10AndLater'
                    RoleScopeTags = @('0')
                    Rule        = "(device.manufacturer -ne `"bibi`")"
                    Credential  = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                    ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the iOS Device Compliance Policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaDeviceManagementAssignmentFilter' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceAndAppManagementAssignmentFilter' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
