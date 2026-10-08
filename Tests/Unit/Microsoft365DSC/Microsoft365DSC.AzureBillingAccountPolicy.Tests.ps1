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

            Mock -CommandName Get-M365DSCAzureBillingAccount -MockWith {
                return @{
                    value = @{
                        name = "1e5b9e50-a1ea-581e-fb3a-xxxxxxxxx:6487d5cf-0a7b-42e6-9549-xxxxxxx_2019-05-31"
                        properties = @{
                            displayName = "MyBillingAccount"
                        }
                    }
                }
            }

            Mock -CommandName Invoke-AzRestMethod -MockWith {
                return @{
                    Content = ConvertTo-Json @{
                        value = @(
                            @{
                                name = "default"
                                id   = "12345-12345-12345-12345-12345"
                                properties = @{
                                    enterpriseAgreementPolicies = @{
                                        authenticationType = "OrganizationalAccountOnly"
                                    }
                                    marketplacePurchases = "AllAllowed"
                                    reservationPurchases = "Allowed"
                                    savingsPlanPurchases = "NotAllowed"
                                }
                            }
                        )
                    } -Depth 10 -Compress
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
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-xxxxxxxxx:6487d5cf-0a7b-42e6-9549-xxxxxxx_2019-05-31";
                    Name                  = "default"
                    EnterpriseAgreementPolicies = ([MSFT_AzureBillingAccountPolicyEnterpriseAgreementPolicy] @{
                        authenticationType = "OrganizationalAccountOnly"
                    })
                    MarketplacePurchases = "AllAllowed"
                    ReservationPurchases = "Allowed"
                    SavingsPlanPurchases = "NotAllowed"
                    Ensure               = 'Present'
                    SubscriptionId       = "00000000-0000-0000-0000-000000000000"
                    Credential           = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    BillingAccount        = "1e5b9e50-a1ea-581e-fb3a-xxxxxxxxx:6487d5cf-0a7b-42e6-9549-xxxxxxx_2019-05-31";
                    Name                  = "default"
                    EnterpriseAgreementPolicies = ([MSFT_AzureBillingAccountPolicyEnterpriseAgreementPolicy] @{
                        authenticationType = "OrganizationalAccountOnly"
                    })
                    MarketplacePurchases = "AllAllowed"
                    ReservationPurchases = "Allowed"
                    SavingsPlanPurchases = "Allowed" #Drift
                    Ensure               = 'Present'
                    SubscriptionId       = "00000000-0000-0000-0000-000000000000"
                    Credential           = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AzureBillingAccountPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-AzRestMethod -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    SubscriptionId = "00000000-0000-0000-0000-000000000000"
                    Credential     = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AzureBillingAccountPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
