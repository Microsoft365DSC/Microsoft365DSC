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
    -DscResource "AADHomeRealmDiscoveryPolicy" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaPolicyHomeRealmDiscoveryPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyHomeRealmDiscoveryPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyHomeRealmDiscoveryPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyHomeRealmDiscoveryPolicy -MockWith {
                return @{
                    id         = "randomguid"
                    definition  = @(
                        '{"HomeRealmDiscoveryPolicy":{"PreferredDomain":"federated.example.edu","AlternateIdLogin":{"Enabled":true},"AccelerateToFederatedDomain":false}}'
                    )
                    displayName = "FakeStringValue"
                    isOrganizationDefault = $true
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADHomeRealmDiscoveryPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADHomeRealDiscoveryPolicyDefinition] @{
                            PreferredDomain       = 'federated.example.edu'
                            AccelerateToFederatedDomain         = $False
                            AlternateIdLogin      = [MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin] @{
                                    Enabled = $True
                                }
                        } )
                    DisplayName = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyHomeRealmDiscoveryPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaPolicyHomeRealmDiscoveryPolicy -Exactly 1
            }
        }

        Context -Name "The AADHomeRealmDiscoveryPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADHomeRealDiscoveryPolicyDefinition] @{
                            PreferredDomain       = 'federated.example.edu'
                            AccelerateToFederatedDomain         = $False
                            AlternateIdLogin      = [MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin] @{
                                    Enabled = $True
                                }
                        } )
                    DisplayName = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyHomeRealmDiscoveryPolicy -Exactly 1
            }
        }
        Context -Name "The AADHomeRealmDiscoveryPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADHomeRealDiscoveryPolicyDefinition] @{
                            PreferredDomain       = 'federated.example.edu'
                            AccelerateToFederatedDomain         = $False
                            AlternateIdLogin      = [MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin] @{
                                    Enabled = $True
                                }
                        } )
                    DisplayName = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADHomeRealmDiscoveryPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADHomeRealDiscoveryPolicyDefinition] @{
                            PreferredDomain       = 'federated.example.edu'
                            AccelerateToFederatedDomain         = $False
                            AlternateIdLogin      = [MSFT_AADHomeRealDiscoveryPolicyDefinitionAlternateIdLogin] @{
                                    Enabled = $false # Drift
                                }
                        } )
                    DisplayName = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADHomeRealmDiscoveryPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyHomeRealmDiscoveryPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADHomeRealmDiscoveryPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
