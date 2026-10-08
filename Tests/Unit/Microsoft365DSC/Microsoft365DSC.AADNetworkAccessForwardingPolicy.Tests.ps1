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

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName New-MgBetaNetworkAccessForwardingPolicyrule -MockWith {
            }

            Mock -CommandName Remove-MgBetaNetworkAccessForwardingPolicyRule -MockWith {
            }

            Mock -CommandName Get-MgBetaNetworkAccessForwardingPolicy -MockWith {
                return @{
                    Name = "Custom Bypass"
                    PolicyRules = @(
                        @{
                            Name = "Custom policy internet rule"
                            ruleType = "fqdn"
                            action   = "bypass"
                            ports    = @('80','443')
                            protocol = "tcp"
                            destinations = @(
                                @{
                                    value = "www.google.com"
                                }
                            )
                        },
                        @{
                            Name = "Custom policy internet rule"
                            ruleType = "ipSubnet"
                            action   = "bypass"
                            ports    = @('80','443')
                            protocol = "tcp"
                            destinations = @(
                                @{
                                    value = "192.164.0.0/24"
                                }
                            )
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
        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = "Custom Bypass";
                    PolicyRules           = @(
                        [MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule] @{
                            Name           = 'Custom policy internet rule'
                            ActionValue    = 'bypass'
                            RuleType       = 'fqdn'
                            Protocol       = 'tcp'
                            Ports          = @('80', '443')
                            Destinations   = @('www.google.com')
                        }

                        [MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule] @{
                            Name           = 'Custom policy internet rule'
                            ActionValue    = 'bypass'
                            RuleType       = 'ipSubnet'
                            Protocol       = 'tcp'
                            Ports          = @('80', '443')
                            Destinations   = @('192.164.0.0/24')
                        }
                    )
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                  = "Custom Bypass";
                    PolicyRules           = @(
                        [MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule] @{
                            Name           = 'Custom policy internet rule'
                            ActionValue    = 'bypass'
                            RuleType       = 'fqdn'
                            Protocol       = 'tcp'
                            Ports          = @('80', '443')
                            Destinations   = @('www.google.com')
                        }
                        [MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule] @{
                            Name           = 'Custom policy internet rule'
                            ActionValue    = 'bypass'
                            RuleType       = 'ipSubnet'
                            Protocol       = 'tcp'
                            Ports          = @('80', '443')
                            Destinations   = @('192.164.0.0/28') # Drift
                        }
                    )
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingPolicy' -Property $testParams).Get().ToHashtable()).Name | Should -Be "Custom Bypass"
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADNetworkAccessForwardingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaNetworkAccessForwardingPolicyRule
                Should -Invoke -CommandName New-MgBetaNetworkAccessForwardingPolicyRule
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADNetworkAccessForwardingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
