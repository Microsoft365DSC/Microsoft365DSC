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

            Mock -CommandName Update-MgBetaIdentityGovernanceLifecycleWorkflow -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityGovernanceLifecycleWorkflow -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflow -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflowNewVersion -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflow -MockWith {
                return @{
                    Id                         = "random guid"
                    AdministrationScopeTargets = @(
                        @{
                            Id = "4f9dc456-0574-4122-9e55-8b4cc494b27d"
                        }
                    );
                    Category                   = "joiner";
                    Description                = "Description the onboard of prehire employee";
                    DisplayName                = "Onboard pre-hire employee updated version";
                    IsEnabled                  = $True;
                    IsSchedulingEnabled        = $False;
                }
            }

            Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflowTask -MockWith {
                return $null
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
                    AdministrationScopeTargets = @("4f9dc456-0574-4122-9e55-8b4cc494b27d");
                    Category                   = "joiner";
                    Description                = "Description the onboard of prehire employee";
                    DisplayName                = "Onboard pre-hire employee updated version";
                    IsEnabled                  = $True;
                    IsSchedulingEnabled        = $False;
                    Ensure                     = 'Present'
                    Credential                 = $Credential;
                }

                Mock -CommandName Get-MgBetaIdentityGovernanceLifecycleWorkflow -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflow -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdministrationScopeTargets = @("4f9dc456-0574-4122-9e55-8b4cc494b27d");
                    Category                   = "joiner";
                    Description                = "Description the onboard of prehire employee";
                    DisplayName                = "Onboard pre-hire employee updated version";
                    IsEnabled                  = $True;
                    IsSchedulingEnabled        = $False;
                    Ensure                     = 'Absent'
                    Credential                 = $Credential;
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityGovernanceLifecycleWorkflow -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdministrationScopeTargets = @("4f9dc456-0574-4122-9e55-8b4cc494b27d");
                    Category                   = "joiner";
                    Description                = "Description the onboard of prehire employee";
                    DisplayName                = "Onboard pre-hire employee updated version";
                    IsEnabled                  = $True;
                    IsSchedulingEnabled        = $False;
                    Tasks                      = $null
                    ExecutionConditions        = ([MSFT_IdentityGovernanceWorkflowExecutionConditions] @{
                    })
                    Ensure                     = 'Present'
                    Credential                 = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdministrationScopeTargets = @("8a0e2e6c-1e4f-4a26-9a71-6c1e5f2b3d47"); # Drift
                    Category                   = "joiner";
                    Description                = "Drifted Description the onboard of prehire employee"; # Drift
                    DisplayName                = "Onboard pre-hire employee updated version";
                    IsEnabled                  = $True;
                    IsSchedulingEnabled        = $False;
                    Ensure                     = 'Present'
                    Credential                 = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernanceLifecycleWorkflowNewVersion -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADIdentityGovernanceLifecycleWorkflow' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
