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
    -DscResource 'EXOQuarantinePolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-QuarantinePolicy -MockWith {
            }

            Mock -CommandName Set-QuarantinePolicy -MockWith {
            }

            Mock -CommandName Remove-QuarantinePolicy -MockWith {
            }

            Mock -CommandName Get-QuarantinePolicy -ParameterFilter { $QuarantinePolicyType -eq 'GlobalQuarantinePolicy' } -MockWith {
                return @{
                    Identity = 'DefaultGlobalPolicy'
                    Name     = 'TestQuarantinePolicy'
                }
            }

            Mock -CommandName Get-QuarantinePolicy -MockWith {
                return @{
                    Identity                    = 'TestQuarantinePolicy'
                    Name                        = 'TestQuarantinePolicy'
                    QuarantinePolicyType        = 'PolicyQuarantineTag'
                    OrganizationBrandingEnabled = $True
                    ESNEnabled                  = $False
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'QuarantinePolicy creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    Identity                    = 'contoso.onmicrosoft.com\TestQuarantinePolicy'
                    QuarantinePolicyType        = 'PolicyQuarantineTag'
                    OrganizationBrandingEnabled = $False
                    ESNEnabled                  = $False
                }

                Mock -CommandName Get-QuarantinePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-QuarantinePolicy -Exactly 1 -ParameterFilter { $Name -eq 'TestQuarantinePolicy' }
            }
        }

        Context -Name 'QuarantinePolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    Identity                    = 'TestQuarantinePolicy'
                    QuarantinePolicyType        = 'PolicyQuarantineTag'
                    OrganizationBrandingEnabled = $True
                    ESNEnabled                  = $False
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'QuarantinePolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    Identity                    = 'TestQuarantinePolicy'
                    OrganizationBrandingEnabled = $True
                    ESNEnabled                  = $True
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Successfully call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-QuarantinePolicy -Exactly 1
            }
        }

        Context -Name 'Global QuarantinePolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                    Identity                    = 'DefaultGlobalPolicy'
                    QuarantinePolicyType        = 'GlobalQuarantineTag'
                    OrganizationBrandingEnabled = $True
                }

                Mock -CommandName Get-QuarantinePolicy -ParameterFilter { $QuarantinePolicyType -eq 'GlobalQuarantinePolicy' } -MockWith {
                    return @{
                        Identity                    = 'contoso.onmicrosoft.com\DefaultGlobalPolicy'
                        Name                        = 'DefaultGlobalPolicy'
                        Guid                        = '00000000-0000-0000-0000-000000000000'
                        QuarantinePolicyType        = 'GlobalQuarantineTag'
                        OrganizationBrandingEnabled = $False
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the global settings when they were never saved' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-QuarantinePolicy -Exactly 1 -ParameterFilter { $QuarantinePolicyType -eq 'GlobalQuarantinePolicy' }
            }
        }

        Context -Name 'QuarantinePolicy removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Credential = $Credential
                    Identity   = 'TestQuarantinePolicy'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the Policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOQuarantinePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-QuarantinePolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOQuarantinePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
