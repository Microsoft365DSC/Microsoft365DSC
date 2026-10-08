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
    -DscResource 'EXOAntiPhishPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-AntiPhishPolicy -MockWith {
            }

            Mock -CommandName Set-AntiPhishPolicy -MockWith {
            }

            Mock -CommandName Remove-AntiPhishPolicy -MockWith {
            }

            Mock -CommandName Get-AntiPhishPolicy -MockWith {
                return @{
                    Ensure                              = 'Present'
                    Identity                            = 'TestPolicy'
                    PhishThresholdLevel                 = '2'
                    AdminDisplayName                    = 'DSC Test Policy'
                    Enabled                             = $true
                    EnableFirstContactSafetyTips        = $false
                    EnableAuthenticationSafetyTip       = $true
                    EnableMailboxIntelligence           = $true
                    EnableOrganizationDomainsProtection = $false
                    EnableSimilarDomainsSafetyTips      = $false
                    EnableSimilarUsersSafetyTips        = $false
                    EnableTargetedDomainsProtection     = $false
                    EnableTargetedUserProtection        = $false
                    EnableUnusualCharactersSafetyTips   = $false
                    EnableViaTag                        = $false
                    IsDefault                           = $false
                    TreatSoftPassAsAuthenticated        = $true
                    AuthenticationFailAction            = 'Quarantine'
                    TargetedDomainActionRecipients      = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedUserProtectionAction        = 'BccMessage'
                    TargetedUserActionRecipients        = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedDomainsToProtect            = @('fabrikam.com', 'contoso.com')
                    TargetedUsersToProtect              = @('fabrikam.com', 'contoso.com')
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'AntiPhishPolicy creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Present'
                    Credential = $Credential
                    Identity   = 'TestPolicy'
                }

                Mock -CommandName Get-AntiPhishPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-AntiPhishPolicy -Exactly 1
            }
        }

        Context -Name 'AntiPhishPolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Credential                          = $Credential
                    Identity                            = 'TestPolicy'
                    PhishThresholdLevel                 = '2'
                    AdminDisplayName                    = 'DSC Test Policy'
                    Enabled                             = $true
                    EnableFirstContactSafetyTips        = $false
                    EnableMailboxIntelligence           = $true
                    EnableOrganizationDomainsProtection = $false
                    EnableSimilarDomainsSafetyTips      = $false
                    EnableSimilarUsersSafetyTips        = $false
                    EnableTargetedDomainsProtection     = $false
                    EnableTargetedUserProtection        = $false
                    EnableUnusualCharactersSafetyTips   = $false
                    EnableViaTag                        = $false
                    MakeDefault                         = $false
                    AuthenticationFailAction            = 'Quarantine'
                    TargetedDomainActionRecipients      = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedUserProtectionAction        = 'BccMessage'
                    TargetedUserActionRecipients        = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedDomainsToProtect            = @('fabrikam.com', 'contoso.com')
                    TargetedUsersToProtect              = @('fabrikam.com', 'contoso.com')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'AntiPhishPolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                              = 'Present'
                    Credential                          = $Credential
                    Identity                            = 'TestPolicy'
                    PhishThresholdLevel                 = '2'
                    AdminDisplayName                    = 'DSC Test Policy'
                    Enabled                             = $false # Drift
                    EnableFirstContactSafetyTips        = $false
                    EnableMailboxIntelligence           = $true
                    EnableOrganizationDomainsProtection = $false
                    EnableSimilarDomainsSafetyTips      = $false
                    EnableSimilarUsersSafetyTips        = $false
                    EnableTargetedDomainsProtection     = $false
                    EnableTargetedUserProtection        = $false
                    EnableUnusualCharactersSafetyTips   = $false
                    EnableViaTag                        = $false
                    MakeDefault                         = $false
                    AuthenticationFailAction            = 'Quarantine'
                    TargetedDomainActionRecipients      = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedUserProtectionAction        = 'BccMessage'
                    TargetedUserActionRecipients        = @('test@contoso.com', 'test@fabrikam.com')
                    TargetedDomainsToProtect            = @('fabrikam.com', 'contoso.com')
                    TargetedUsersToProtect              = @('fabrikam.com', 'contoso.com')
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Successfully call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Set()
            }

        }

        Context -Name 'AntiPhishPolicy removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure     = 'Absent'
                    Credential = $Credential
                    Identity   = 'TestPolicy'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the Policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AntiPhishPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAntiPhishPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
