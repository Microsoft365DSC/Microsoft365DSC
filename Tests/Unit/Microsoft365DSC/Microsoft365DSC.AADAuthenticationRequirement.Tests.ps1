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

            Mock -CommandName Update-MgBetaUserAuthenticationRequirement -MockWith {
            }

            Mock -CommandName Get-MgBetaUserAuthenticationRequirement -MockWith {
                return @{
                    UserPrincipalName   = "user@test.com"
                    PerUserMfaState     = 'Enabled'
                    Credential          = $Credential;
                }
            }

            Mock -CommandName Get-MgUser -MockWith {
                return @{
                    Id                  = "98ceffcc-7c54-4227-8844-835af5a023ce"
                    UserPrincipalName   = "user@test.com"
                    Credential          = $Credential;
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -MockWith {
                return @(
                    @{
                        id     = "user@test.com"
                        status = 200
                        body   = @{
                            perUserMfaState = 'Enabled'
                        }
                    }
                )
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
        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    UserPrincipalName   = "user@test.com"
                    PerUserMfaState     = 'Enabled'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state - Enable" -Fixture {
            BeforeAll {
                $testParams = @{
                    UserPrincipalName   = "user@test.com"
                    PerUserMfaState     = 'Enabled'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaUserAuthenticationRequirement -MockWith {
                    return @{
                        UserPrincipalName   = "user@test.com"
                        PerUserMfaState     = 'Disabled'
                        Credential          = $Credential;
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Get().ToHashtable()).PerUserMfaState | Should -Be 'Disabled'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaUserAuthenticationRequirement -Exactly 1
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state - Disable" -Fixture {
            BeforeAll {
                $testParams = @{
                    UserPrincipalName   = "user@test.com"
                    PerUserMfaState     = 'Disabled' # Drift
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Get().ToHashtable()).PerUserMfaState | Should -Be 'Enabled'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationRequirement' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaUserAuthenticationRequirement -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthenticationRequirement' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
