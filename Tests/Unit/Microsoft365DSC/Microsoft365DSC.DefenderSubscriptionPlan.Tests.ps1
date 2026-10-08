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
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length - 1]
$ResourceName = $CurrentScriptName.Split('.')[1]
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
                return 'Credentials'
            }

            Mock -CommandName Set-AzSecurityPricing -MockWith {
            }

            Mock -CommandName Set-AzContext -MockWith {
            }

            Mock -CommandName Get-AzSubscription -MockWith {
                return @{
                    Id   = '2974ccf2-1e67-4b74-a102-2d921b595a89'
                    Name = 'MySubscription'
                }
            }

            Mock -CommandName Get-AzContext -MockWith {
                return @{
                    Subscription = @{
                        Id   = '2974ccf2-1e67-4b74-a102-2d921b595a89'
                        Name = 'MySubscription'
                    }
                }
            }

            Mock -CommandName Get-AzSecurityPricing -MockWith {
                return @{
                    Name        = 'VirtualMachines'
                    SubPlan     = 'P2'
                    PricingTier = 'Standard'
                    Extensions  = $null
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The instance exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    SubscriptionName = 'MySubscription'
                    PlanName         = 'VirtualMachines'
                    SubPlanName      = 'P2'
                    PricingTier      = 'Standard'
                    Ensure           = 'Present'
                    Credential       = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'DefenderSubscriptionPlan' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The instance exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    SubscriptionName = 'MySubscription'
                    PlanName         = 'VirtualMachines'
                    SubPlanName      = 'P2'
                    PricingTier      = 'Free' # Drift
                    Ensure           = 'Present'
                    Credential       = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'DefenderSubscriptionPlan' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'DefenderSubscriptionPlan' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'DefenderSubscriptionPlan' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AzSecurityPricing -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Search-AzGraph -MockWith {
                    return @{
                        Data = @(
                            @{
                                SubscriptionId   = '2974ccf2-1e67-4b74-a102-2d921b595a89'
                                SubscriptionName = 'MySubscription'
                                PlanName         = 'VirtualMachines'
                                SubPlanName      = 'P2'
                                PricingTier      = 'Standard'
                                Extensions       = $null
                            }
                        )
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'DefenderSubscriptionPlan' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
