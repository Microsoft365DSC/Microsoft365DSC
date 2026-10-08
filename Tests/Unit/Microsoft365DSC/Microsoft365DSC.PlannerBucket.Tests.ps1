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
    -DscResource 'PlannerBucket' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }
            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }
            Mock -CommandName Connect-Graph -MockWith {
            }

            Mock -CommandName New-MGPlannerBucket -MockWith {
            }

            Mock -CommandName Update-MGPlannerBucket -MockWith {
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
        Context -Name "When the Bucket doesn't exist but it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId     = '1234567890'
                    Name       = 'Contoso Bucket'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the Task in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Set()
                Should -Invoke -CommandName New-MGPlannerBucket -Exactly 1
            }
        }

        Context -Name 'Bucket exists and is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId     = '1234567890'
                    Name       = 'Contoso Bucket'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        PlanId = '1234567890'
                        Id     = '12345'
                        Name   = 'Contoso Bucket'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Task exists and is IN the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId     = '1234567890'
                    Name       = 'Contoso Bucket'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        PlanId = '1234567890'
                        Id     = '12345'
                        Name   = 'Contoso Bucket'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Task exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    PlanId     = '1234567890'
                    Name       = 'Contoso Bucket'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        PlanId = '1234567890'
                        Id     = '12345'
                        Name   = 'Contoso Bucket'
                    }
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'PlannerBucket' -Property $testParams).Test() | Should -Be $False
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgGroup -MockWith {
                    return @{
                        Id          = '12345'
                        DisplayName = 'Contoso Group'
                    }
                }

                Mock -CommandName Get-MgGroupPlannerPlan -MockWith {
                    return @{
                        Id    = '12345'
                        Title = 'Contoso Plan'
                    }
                }

                Mock -CommandName Get-MgPlannerPlanBucket -MockWith {
                    return @{
                        PlanId = '1234567890'
                        Id     = '12345'
                        Name   = 'Contoso Bucket'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'PlannerBucket' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
