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
    -DscResource 'EXORoleGroup' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-RoleGroup -MockWith {
                return [PSCustomObject]@{
                    Name        = 'Contoso Role Group'
                    Members     = 'Exchange Administrator'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                }
            }

            Mock -CommandName New-RoleGroup -MockWith {
            }

            Mock -CommandName Get-RoleGroupMember -MockWith {
            }

            Mock -Command Get-RoleGroupMember -ParameterFilter { $Identity -eq 'Contoso Role Group'}  -MockWith {
                return [PSCustomObject]@{
                    DisplayName = 'Exchange Administrator'
                    PrimarySmtpAddress = "ExchangeAdministrator@contoso.com"
                }
            }

            Mock -CommandName Update-RoleGroupMember -MockWith {
            }

            Mock -CommandName Set-RoleGroup -MockWith {
            }

            Mock -CommandName Remove-RoleGroup -MockWith {
            }

            Mock -CommandName Get-Group -MockWith {
            }

            Mock -CommandName Get-Group -ParameterFilter { $WindowsEmailAddress -eq 'ExchangeAdministrator@contoso.com' } -MockWith {
                return @{
                    WindowsEmailAddress = 'ExchangeAdministrator@contoso.com'
                }
            }

            Mock -CommandName Get-Group -ParameterFilter { $WindowsEmailAddress -eq 'DriftAdministrator@contoso.com' } -MockWith {
                return @{
                    WindowsEmailAddress = 'DriftAdministrator@contoso.com'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Role Group should exist. Role Group is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Members     = 'ExchangeAdministrator@contoso.com'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-RoleGroup -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName New-RoleGroup -Exactly 1
            }
        }

        Context -Name 'Role Group should exist. Role Group exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Members     = 'ExchangeAdministrator@contoso.com'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Role Group should exist. Role Group exists, Members mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Members     = 'DriftAdministrator@contoso.com' # Drift
                    Roles       = 'Address Lists'
                    Description = 'Manages address lists for the messaging team' # Drift
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should call the Update Members method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Update-RoleGroupMember -Exactly 1
                Should -Invoke -CommandName Set-RoleGroup -Exactly 1 -ParameterFilter { $Description -eq 'Manages address lists for the messaging team' }
            }
        }
        Context -Name 'Role Group exists and it SHOULD NOT.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name        = 'Contoso Role Group'
                    Members     = 'ExchangeAdministrator@contoso.com'
                    Roles       = 'Address Lists'
                    Description = 'This is the Contoso Role Group'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORoleGroup' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-RoleGroup -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXORoleGroup' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
