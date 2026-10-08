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
    -DscResource 'AADUserFlowAttribute' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaIdentityUserFlowAttribute -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityUserFlowAttribute -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityUserFlowAttribute -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityUserFlowAttribute -MockWith {
                return @{
                    Id = 'testIdSai'
                    DisplayName = 'saitest'
                    Description = 'sai test description'
                    DataType = 'string'
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The user flow attribute should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                 = "testIdSai"
                    DisplayName        = "saitest"
                    Description        = "sai test description"
                    DataType           = "string"
                    Ensure          = 'Present'
                    Credential      = $Credential
                }

                Mock -CommandName Get-MgBetaIdentityUserFlowAttribute -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaIdentityUserFlowAttribute' -Exactly 2
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the role definition from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaIdentityUserFlowAttribute' -Exactly 1
            }
        }

        Context -Name 'The user flow attribute exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "saitest"
                    Description        = "sai test description"
                    DataType           = "string"
                    Ensure          = 'Absent'
                    Credential      = $Credential
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaIdentityUserFlowAttribute' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaIdentityUserFlowAttribute' -Exactly 1 -ParameterFilter { $IdentityUserFlowAttributeId -eq 'testIdSai' }
            }
        }
        Context -Name 'The user flow attribute exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                 = "testIdSai"
                    DisplayName        = "saitest"
                    Description        = "sai test description"
                    DataType           = "string"
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaIdentityUserFlowAttribute' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = "saitest"
                    Description        = "sai test description changed" # Drift
                    DataType           = "string"
                    Ensure          = 'Present'
                    Credential      = $Credential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaIdentityUserFlowAttribute' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADUserFlowAttribute' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaIdentityUserFlowAttribute' -Exactly 1 -ParameterFilter { $IdentityUserFlowAttributeId -eq 'testIdSai' }
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADUserFlowAttribute' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
