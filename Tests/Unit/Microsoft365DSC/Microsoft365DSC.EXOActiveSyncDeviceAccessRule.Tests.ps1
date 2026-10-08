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
    -DscResource 'EXOActiveSyncDeviceAccessRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-ActiveSyncDeviceAccessRule -MockWith {
            }

            Mock -CommandName Remove-ActiveSyncDeviceAccessRule -MockWith {
            }

            Mock -CommandName Get-ActiveSyncDeviceAccessRule -MockWith {
                return @{
                    Identity       = 'iOS 6.1 10B145 (DeviceOS)'
                    AccessLevel    = 'Allow'
                    Characteristic = 'DeviceOS'
                    QueryString    = 'iOS 6.1 10B145'
                }
            }

            Mock -CommandName Set-ActiveSyncDeviceAccessRule -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Active Sync Device Access Rule should exist. Active Sync Device Access Rule is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'iOS 6.1 10B145 (DeviceOS)'
                    AccessLevel    = 'Allow'
                    Characteristic = 'DeviceOS'
                    QueryString    = 'iOS 6.1 10B145'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }

                Mock -CommandName Get-ActiveSyncDeviceAccessRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-ActiveSyncDeviceAccessRule -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Active Sync Device Access Rule should exist. Active Sync Device Access Rule exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'iOS 6.1 10B145 (DeviceOS)'
                    AccessLevel    = 'Allow'
                    Characteristic = 'DeviceOS'
                    QueryString    = 'iOS 6.1 10B145'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Active Sync Device Access Rule should exist. Active Sync Device Access Rule exists, AccessLevel mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'iOS 6.1 10B145 (DeviceOS)'
                    AccessLevel    = 'Block' # Drift
                    Characteristic = 'DeviceOS'
                    QueryString    = 'iOS 6.1 10B145'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-ActiveSyncDeviceAccessRule -Exactly 1
            }
        }

        Context -Name 'Active Sync Device Access Rule exists and it SHOULD NOT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'iOS 6.1 10B145 (DeviceOS)'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the rule from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOActiveSyncDeviceAccessRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-ActiveSyncDeviceAccessRule -Exactly 1 -ParameterFilter { $Identity -eq 'iOS 6.1 10B145 (DeviceOS)' }
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

            It 'Should Reverse Engineer resource from the Export method when single' {

                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOActiveSyncDeviceAccessRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
