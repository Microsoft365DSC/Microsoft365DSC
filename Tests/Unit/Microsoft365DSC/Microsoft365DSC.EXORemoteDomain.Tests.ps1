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
    -DscResource 'EXORemoteDomain' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-RemoteDomain -MockWith {
            }

            Mock -CommandName Remove-RemoteDomain -MockWith {
            }

            Mock -CommandName Set-RemoteDomain -MockWith {
            }

            Mock -CommandName Start-Sleep -MockWith {
            }

            Mock -CommandName Get-RemoteDomain -MockWith {
                return @{
                    Identity       = 'Contoso'
                    DomainName     = 'contoso.com'
                    AllowedOOFType = 'External'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Remote Domain should exist. Remote Domain is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'Contoso'
                    DomainName     = 'contoso.com'
                    AllowedOOFType = 'External'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }

                Mock -CommandName Get-RemoteDomain -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Set()
                Should -Invoke -CommandName New-RemoteDomain -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Remote Domain should exist. Remote Domain exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'Contoso'
                    DomainName     = 'contoso.com'
                    AllowedOOFType = 'External'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Remote Domain should exist. Remote Domain exists, AllowedOOFType mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity       = 'Contoso'
                    DomainName     = 'contoso.com'
                    AllowedOOFType = 'InternalLegacy'
                    Ensure         = 'Present'
                    Credential     = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Set()
                Should -Invoke -CommandName Set-RemoteDomain -Exactly 1
            }
        }

        Context -Name 'Remote Domain should not exist. Remote Domain exists. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'Contoso'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the Remote Domain from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXORemoteDomain' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-RemoteDomain -Exactly 1 -ParameterFilter { $Identity -eq 'Contoso' }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXORemoteDomain' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
