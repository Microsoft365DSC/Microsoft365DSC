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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Update-MgBetaNetworkAccessFilteringPolicyRule -MockWith{}
            Mock -CommandName New-MgBetaNetworkAccessFilteringPolicyRule -MockWith{}
            Mock -CommandName Remove-MgBetaNetworkAccessFilteringPolicyRule -MockWith{}
            Mock -COmmandName Get-MgBetaNetworkAccessFilteringPolicy -MockWith{
                return @{
                    Id = '12345-12345-12345-12345-12345'
                    Name = 'MyPolicy'
                }
            }

            Mock -CommandName Get-MgBetaNetworkAccessFilteringPolicyRule -MockWith {
                return @{
                    Name = 'MyFQDN'
                    Id   = '12345-12345-12345-12345-12345'
                    ruleType = 'fqdn'
                    destinations = @(
                        @{
                            value = 'Microsoft365DSC.com'
                        }
                    )
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Destinations          = @(
                        ([MSFT_AADFilteringPolicyRuleDestination] @{
                            value = 'Microsoft365DSC.com'
                        })
                    );
                    Name                  = "MyFQDN";
                    Policy                = "MyPolicy";
                    RuleType              = "fqdn";
                    Ensure                = 'Present'
                    Credential            = $Credential;
                }

                Mock -CommandName Get-MgBetaNetworkAccessFilteringPolicyRule -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaNetworkAccessFilteringPolicyRule -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Destinations          = @(
                        ([MSFT_AADFilteringPolicyRuleDestination] @{
                            value = 'Microsoft365DSC.com'
                        })
                    );
                    Name                  = "MyFQDN";
                    Policy                = "MyPolicy";
                    RuleType              = "fqdn";
                    Ensure                = 'Absent'
                    Credential            = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessFilteringPolicyRule -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Destinations          = @(
                        ([MSFT_AADFilteringPolicyRuleDestination] @{
                            value = 'Microsoft365DSC.com'
                        })
                    );
                    Name                  = "MyFQDN";
                    Policy                = "MyPolicy";
                    RuleType              = "fqdn";
                    Ensure                = 'Present'
                    Credential            = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Destinations          = @(
                        ([MSFT_AADFilteringPolicyRuleDestination] @{
                            value = 'contoso.com' #Drift
                        })
                    );
                    Name                  = "MyFQDN";
                    Policy                = "MyPolicy";
                    RuleType              = "fqdn";
                    Ensure                = 'Present'
                    Credential            = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADFilteringPolicyRule' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaNetworkAccessFilteringPolicyRule -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADFilteringPolicyRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
