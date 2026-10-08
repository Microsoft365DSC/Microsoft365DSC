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
    -DscResource "AADCrossTenantAccessPolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyCrossTenantAccessPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicy -MockWith {
                return @{
                    AllowedCloudEndpoints = @("microsoftonline.us");
                    DisplayName           = "MyXTAPPolicy";
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
        Context -Name "The policy is already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedCloudEndpoints = @("microsoftonline.us");
                    Credential            = $Credential;
                    DisplayName           = "MyXTAPPolicy";
                    Ensure                = "Present";
                    IsSingleInstance      = "Yes";
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCrossTenantAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantAccessPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The policy is NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowedCloudEndpoints = @("microsoftonline.com"); # Drift
                    Credential            = $Credential;
                    DisplayName           = "MyXTAPPolicy";
                    Ensure                = "Present";
                    IsSingleInstance      = "Yes";
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCrossTenantAccessPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantAccessPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantAccessPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaPolicyCrossTenantAccessPolicy' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADCrossTenantAccessPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
