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
    -DscResource 'AADSecurityDefaults' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy -MockWith {
                return @{
                    DisplayName = 'Security Defaults'
                    Id          = '000000000000'
                    Description = 'Security Defaults description'
                    IsEnabled   = $true
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The Defaults should be enabled but they are not' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    DisplayName      = 'Security Defaults'
                    Description      = 'Security Defaults description'
                    IsEnabled        = $false # Drift
                    Credential       = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADSecurityDefaults' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy' -Exactly 1
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADSecurityDefaults' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the Enable from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADSecurityDefaults' -Property $testParams).Set() |
                Should -Invoke -CommandName 'Update-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy' -Exactly 1
            }
        }
        Context -Name 'The Security Defaults are already in the desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance = 'Yes'
                    DisplayName      = 'Security Defaults'
                    Description      = 'Security Defaults description'
                    IsEnabled        = $True
                    Credential       = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADSecurityDefaults' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADSecurityDefaults' -Property $testParams).Test() | Should -Be $true
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
