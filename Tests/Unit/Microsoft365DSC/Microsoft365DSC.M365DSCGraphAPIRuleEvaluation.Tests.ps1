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
    -DscResource 'M365DSCGraphAPIRuleEvaluation' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                return @{
                    value = @{
                        appCategory = 'mdm'
                        appId       = '12345-12345-12345-12345-12345'
                    }
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }
        }

        # Test contexts
        Context -Name 'The Rules are successfully evaluated.' -Fixture {
            BeforeAll {
                $testParams = @{
                    APIUrl              = 'https://graph.microsoft.com/beta/serviceprincipals'
                    RuleDefinition      = "`$_.AppCategory -eq 'mdm'"
                    AfterRuleCountQuery = '-eq 1'
                    Credential          = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'M365DSCGraphAPIRuleEvaluation' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The Rules are NOT successfully evaluated.' -Fixture {
            BeforeAll {
                $testParams = @{
                    APIUrl              = 'https://graph.microsoft.com/beta/serviceprincipals'
                    RuleDefinition      = "`$_.AppCategory -eq 'mdm'"
                    AfterRuleCountQuery = '-eq 0'
                    Credential          = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'M365DSCGraphAPIRuleEvaluation' -Property $testParams).Test() | Should -Be $false
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
