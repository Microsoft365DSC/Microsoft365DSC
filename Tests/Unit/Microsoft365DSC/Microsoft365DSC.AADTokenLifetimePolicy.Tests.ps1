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
    -DscResource 'AADTokenLifetimePolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaPolicyTokenLifetimePolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyTokenLifetimePolicy -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyTokenLifetimePolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyTokenLifetimePolicy -MockWith {
                return @{
                    DisplayName           = 'PolicyDisplayName'
                    ID                    = '78a80fa1-8ced-4019-94d8-2e0130644496'
                    Definition            = @('{"TokenIssuancePolicy":{"Version": 1,"SigningAlgorithm": "http://www.w3.org/2000/09/xmldsig#rsa-sha1","TokenResponseSigningPolicy": "TokenOnly","SamlTokenVersion": "2.0"}}')
                    isOrganizationDefault = $false
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
        Context -Name 'The Policy should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'PolicyDisplayName'
                    Definition            = @('{"TokenIssuancePolicy":{"Version": 1,"SigningAlgorithm": "http://www.w3.org/2000/09/xmldsig#rsa-sha1","TokenResponseSigningPolicy": "TokenOnly","SamlTokenVersion": "2.0"}}')
                    IsOrganizationDefault = $false
                    Ensure                = 'Present'
                    Credential            = $Credscredential
                }

                Mock -CommandName Get-MgBetaPolicyTokenLifetimePolicy -MockWith {
                    return $null
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
                Should -Invoke -CommandName 'Get-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }
            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should create the Policy from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'New-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }
        }
        Context -Name 'The Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'PolicyDisplayName'
                    Definition            = @('{"TokenIssuancePolicy":{"Version": 1,"SigningAlgorithm": "http://www.w3.org/2000/09/xmldsig#rsa-sha1","TokenResponseSigningPolicy": "TokenOnly","SamlTokenVersion": "2.0"}}')
                    IsOrganizationDefault = $false
                    Ensure                = 'Absent'
                    Credential            = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
                Should -Invoke -CommandName 'Get-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the app from the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Remove-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }
        }

        Context -Name 'The Policy exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'PolicyDisplayName'
                    Definition            = @('{"TokenIssuancePolicy":{"Version": 1,"SigningAlgorithm": "http://www.w3.org/2000/09/xmldsig#rsa-sha1","TokenResponseSigningPolicy": "TokenOnly","SamlTokenVersion": "2.0"}}')
                    IsOrganizationDefault = $false
                    Ensure                = 'Present'
                    Credential            = $Credscredential
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName           = 'PolicyDisplayName1'
                    Definition            = @('{"TokenIssuancePolicy":{"Version": 1,"SigningAlgorithm": "http://www.w3.org/2000/09/xmldsig#rsa-sha1","TokenResponseSigningPolicy": "TokenOnly","SamlTokenVersion": "2.0"}}')
                    IsOrganizationDefault = $true # Drift
                    Ensure                = 'Present'
                    Credential            = $Credscredential
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTokenLifetimePolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyTokenLifetimePolicy' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADTokenLifetimePolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
