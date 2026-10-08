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
    -DscResource 'EXOAuthenticationPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName New-AuthenticationPolicy {
            }

            Mock -CommandName Remove-AuthenticationPolicy {
            }

            Mock -CommandName Get-AuthenticationPolicy -MockWith {
                return @{
                    Identity                           = 'Contoso Auth Policy'
                    AllowBasicAuthActiveSync           = $False
                    AllowBasicAuthAutodiscover         = $False
                    AllowBasicAuthImap                 = $False
                    AllowBasicAuthMapi                 = $False
                    AllowBasicAuthOfflineAddressBook   = $False
                    AllowBasicAuthOutlookService       = $False
                    AllowBasicAuthPop                  = $False
                    AllowBasicAuthPowerShell           = $False
                    AllowBasicAuthReportingWebServices = $False
                    AllowBasicAuthRpc                  = $False
                    AllowBasicAuthSmtp                 = $False
                    AllowBasicAuthWebServices          = $False
                    Ensure                             = 'Present'
                    Credential                         = $Credential
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Authentication Policy should exist, but is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                           = 'Contoso Auth Policy'
                    AllowBasicAuthActiveSync           = $False
                    AllowBasicAuthAutodiscover         = $False
                    AllowBasicAuthImap                 = $False
                    AllowBasicAuthMapi                 = $False
                    AllowBasicAuthOfflineAddressBook   = $False
                    AllowBasicAuthOutlookService       = $False
                    AllowBasicAuthPop                  = $False
                    AllowBasicAuthPowerShell           = $False
                    AllowBasicAuthReportingWebServices = $False
                    AllowBasicAuthRpc                  = $False
                    AllowBasicAuthSmtp                 = $False
                    AllowBasicAuthWebServices          = $False
                    Ensure                             = 'Present'
                    Credential                         = $Credential
                }

                Mock -CommandName Get-AuthenticationPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-AuthenticationPolicy -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Authentication Policy should exist and it does. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                           = 'Contoso Auth Policy'
                    AllowBasicAuthActiveSync           = $False
                    AllowBasicAuthAutodiscover         = $False
                    AllowBasicAuthImap                 = $False
                    AllowBasicAuthMapi                 = $False
                    AllowBasicAuthOfflineAddressBook   = $False
                    AllowBasicAuthOutlookService       = $False
                    AllowBasicAuthPop                  = $False
                    AllowBasicAuthPowerShell           = $False
                    AllowBasicAuthReportingWebServices = $False
                    AllowBasicAuthRpc                  = $False
                    AllowBasicAuthSmtp                 = $False
                    AllowBasicAuthWebServices          = $False
                    Ensure                             = 'Present'
                    Credential                         = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Authentication Policy should exist and it does. Not in desired state. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                           = 'Contoso Auth Policy'
                    AllowBasicAuthActiveSync           = $True # Drift
                    AllowBasicAuthAutodiscover         = $False
                    AllowBasicAuthImap                 = $False
                    AllowBasicAuthMapi                 = $False
                    AllowBasicAuthOfflineAddressBook   = $False
                    AllowBasicAuthOutlookService       = $False
                    AllowBasicAuthPop                  = $False
                    AllowBasicAuthPowerShell           = $False
                    AllowBasicAuthReportingWebServices = $False
                    AllowBasicAuthRpc                  = $False
                    AllowBasicAuthSmtp                 = $False
                    AllowBasicAuthWebServices          = $False
                    Ensure                             = 'Present'
                    Credential                         = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AuthenticationPolicy -Exactly 1
                Should -Invoke -CommandName New-AuthenticationPolicy -Exactly 1
            }
        }

        Context -Name 'Authentication Policy should not exist, but it does.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity = 'Contoso Auth Policy'
                    Ensure   = 'Absent'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAuthenticationPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AuthenticationPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAuthenticationPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
