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
    -DscResource 'SCFilePlanPropertyReferenceId' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-M365DSCLogEntry -ModuleName '_Shared' -MockWith {
            }

            Mock -CommandName Remove-FilePlanPropertyReferenceId -MockWith {
                return @{}
            }

            Mock -CommandName New-FilePlanPropertyReferenceId -MockWith {
                return @{}
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "ReferenceId doesn't already exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo ReferenceId'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-FilePlanPropertyReferenceId -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Set()
            }
        }

        Context -Name 'ReferenceId already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo ReferenceId'
                    Credential = $Credential
                    Ensure     = 'Present'
                }

                Mock -CommandName Get-FilePlanPropertyReferenceId -MockWith {
                    return @{
                        DisplayName = 'Demo ReferenceId'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should do nothing from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReferenceId should not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name       = 'Demo ReferenceId'
                    Credential = $Credential
                    Ensure     = 'Absent'
                }

                Mock -CommandName Get-FilePlanPropertyReferenceId -MockWith {
                    return @{
                        DisplayName = 'Demo ReferenceId'
                    }
                }
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should delete from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Set()
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'SCFilePlanPropertyReferenceId' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-FilePlanPropertyReferenceId -MockWith {
                    return @{
                        DisplayName = 'Demo ReferenceId'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'SCFilePlanPropertyReferenceId' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
