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
    -DscResource 'EXOHostedOutboundSpamFilterPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-HostedOutboundSpamFilterPolicy -MockWith {
            }

            Mock -CommandName Set-HostedOutboundSpamFilterPolicy -MockWith {
            }

            Mock -CommandName Get-HostedOutboundSpamFilterPolicy -MockWith {
                return @{
                    Identity                                  = 'Default'
                    AdminDisplayName                          = 'Default Outbound Spam Filter Policy'
                    BccSuspiciousOutboundMail                 = $true
                    BccSuspiciousOutboundAdditionalRecipients = @()
                    NotifyOutboundSpam                        = $true
                    NotifyOutboundSpamRecipients              = @()
                    RecipientLimitInternalPerHour             = '0'
                    RecipientLimitPerDay                      = '0'
                    RecipientLimitExternalPerHour             = '0'
                    ActionWhenThresholdReached                = 'BlockUserForToday'
                    AutoForwardingMode                        = 'Off'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'HostedOutboundSpamFilterPolicy update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                                    = 'Present'
                    Identity                                  = 'Default'
                    Credential                                = $Credential
                    AdminDisplayName                          = 'Default Outbound Spam Filter Policy'
                    BccSuspiciousOutboundMail                 = $true
                    BccSuspiciousOutboundAdditionalRecipients = @()
                    NotifyOutboundSpam                        = $true
                    NotifyOutboundSpamRecipients              = @()
                    RecipientLimitInternalPerHour             = '0'
                    RecipientLimitPerDay                      = '0'
                    RecipientLimitExternalPerHour             = '0'
                    ActionWhenThresholdReached                = 'BlockUserForToday'
                    AutoForwardingMode                        = 'Off'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'HostedOutboundSpamFilterPolicy update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                                    = 'Present'
                    Identity                                  = 'Default'
                    Credential                                = $Credential
                    AdminDisplayName                          = 'Default Outbound Spam Filter Policy'
                    BccSuspiciousOutboundMail                 = $false # Drift
                    BccSuspiciousOutboundAdditionalRecipients = @('admin@contoso.com')
                    NotifyOutboundSpam                        = $true
                    NotifyOutboundSpamRecipients              = @('supervisor@contoso.com')
                    RecipientLimitInternalPerHour             = '15'
                    RecipientLimitPerDay                      = '100'
                    RecipientLimitExternalPerHour             = '25'
                    ActionWhenThresholdReached                = 'BlockUser'
                    AutoForwardingMode                        = 'On'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-HostedOutboundSpamFilterPolicy' -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOHostedOutboundSpamFilterPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
