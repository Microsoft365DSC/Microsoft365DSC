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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-MgBetaIdentityGovernanceAccessReviewDefinition -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityGovernanceAccessReviewDefinition -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityGovernanceAccessReviewDefinition -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityGovernanceAccessReviewDefinition -MockWith {
                return @{
                    DescriptionForAdmins = "FakeStringValue"
                    DescriptionForReviewers = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    Scope = @{
                        QueryType = "FakeStringValue"
                        QueryRoot = "FakeStringValue"
                        '@odata.type' = "#microsoft.graph.accessReviewQueryScope"
                        Query = "FakeStringValue"
                    }
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
        Context -Name "The AADAccessReviewDefinition should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DescriptionForAdmins = "FakeStringValue"
                    DescriptionForReviewers = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    ScopeValue = ([MSFT_MicrosoftGraphaccessReviewScope] @{
                        QueryRoot = "FakeStringValue"
                        odataType = "#microsoft.graph.accessReviewQueryScope"
                        Query = "FakeStringValue"
                        QueryType = "FakeStringValue"
                    })
                    Ensure = 'Present'
                }

                Mock -CommandName Get-MgBetaIdentityGovernanceAccessReviewDefinition -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityGovernanceAccessReviewDefinition -Exactly 1
            }
        }

        Context -Name "The AADAccessReviewDefinition exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    DescriptionForAdmins = "FakeStringValue"
                    DescriptionForReviewers = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    ScopeValue = ([MSFT_MicrosoftGraphaccessReviewScope] @{
                        QueryRoot = "FakeStringValue"
                        odataType = "#microsoft.graph.accessReviewQueryScope"
                        Query = "FakeStringValue"
                        QueryType = "FakeStringValue"
                    })
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityGovernanceAccessReviewDefinition -Exactly 1
            }
        }
        Context -Name "The AADAccessReviewDefinition Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DescriptionForAdmins = "FakeStringValue"
                    DescriptionForReviewers = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    ScopeValue = ([MSFT_MicrosoftGraphaccessReviewScope] @{
                         QueryRoot = "FakeStringValue"
                         odataType = "#microsoft.graph.accessReviewQueryScope"
                         Query = "FakeStringValue"
                         QueryType = "FakeStringValue"
                     })
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADAccessReviewDefinition exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DescriptionForAdmins = "FakeStringValue"
                    DescriptionForReviewers = "FakeStringValue2" # Drift
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    ScopeValue = ([MSFT_MicrosoftGraphaccessReviewScope] @{
                         QueryRoot = "FakeStringValue"
                         odataType = "#microsoft.graph.accessReviewQueryScope"
                         Query = "FakeStringValue"
                         QueryType = "FakeStringValue"
                     })
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAccessReviewDefinition' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MgBetaIdentityGovernanceAccessReviewDefinition -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAccessReviewDefinition' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
