[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]

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
    -DscResource 'EXOMobileDeviceMailboxPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-MobileDeviceMailboxPolicy -MockWith {
            }

            Mock -CommandName Remove-MobileDeviceMailboxPolicy -MockWith {
            }

            Mock -CommandName New-MobileDeviceMailboxPolicy -MockWith {
            }

            Mock -CommandName Get-MobileDeviceMailboxPolicy -MockWith {
                return @{
                    Name                         = 'Contoso Mobile Device Policy'
                    AllowBluetooth               = 'Allow'
                    IrmEnabled                   = $true
                    PasswordHistory              = '4'
                    RequireManualSyncWhenRoaming = $false
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Mobile Device Mailbox Policy should exist. Mobile Device Mailbox Policy is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Mobile Device Policy'
                    AllowBluetooth               = 'Allow'
                    IrmEnabled                   = $true
                    PasswordHistory              = '4'
                    RequireManualSyncWhenRoaming = $false
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-MobileDeviceMailboxPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MobileDeviceMailboxPolicy -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Mobile Device Mailbox Policy should exist. Mobile Device Mailbox Policy exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Mobile Device Policy'
                    AllowBluetooth               = 'Allow'
                    IrmEnabled                   = $true
                    PasswordHistory              = '4'
                    RequireManualSyncWhenRoaming = $false
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Mobile Device Mailbox Policy should exist. Mobile Device Mailbox Policy exists, PasswordHistory mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Mobile Device Policy'
                    AllowBluetooth               = 'Allow'
                    IrmEnabled                   = $true
                    PasswordHistory              = '2' # Drift
                    RequireManualSyncWhenRoaming = $false
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMobileDeviceMailboxPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MobileDeviceMailboxPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMobileDeviceMailboxPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
