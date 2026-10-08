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
    -DscResource 'EXOAuthenticationPolicyAssignment' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-User {
            }

            Mock -CommandName Get-User -MockWith {
                return @{
                    Name                 = 'John.Smith'
                    AuthenticationPolicy = 'Test Policy'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Policy is not assigned to the user' -Fixture {
            BeforeAll {
                $testParams = @{
                    UserName                 = 'John.Smith'
                    AuthenticationPolicyName = 'Test Policy'
                    Ensure                   = 'Present'
                    Credential               = $Credential
                }

                Mock -CommandName Get-User -MockWith {
                return @{
                    Name                 = 'John.Smith'
                    AuthenticationPolicy = $null
                }
            }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-User' -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Authentication Policy is correctly assigned' -Fixture {
            BeforeAll {
                $testParams = @{
                    UserName                 = 'John.Smith'
                    AuthenticationPolicyName = 'Test Policy'
                    Ensure                   = 'Present'
                    Credential               = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Authentication Policy should not be assigned.' -Fixture {
            BeforeAll {
                $testParams = @{
                    UserName                 = 'John.Smith'
                    AuthenticationPolicyName = 'Test Policy'
                    Ensure                   = 'Absent'
                    Credential               = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicyAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-User' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $AuthPolicy = @{
                    Identity = 'Test Policy'
                }
                Mock -CommandName Get-AuthenticationPolicy -MockWith {
                    return $AuthPolicy
                }
                Mock -CommandName Get-User -MockWith {
                    return @(
                        @{
                            Name                 = 'John.Smith'
                            AuthenticationPolicy = 'Test Policy'
                            UserPrincipalName    = 'john.smith@contoso.com'
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAuthenticationPolicyAssignment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match 'Test Policy'
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
