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
    -DscResource 'EXOOwaMailboxPolicy' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Set-OwaMailboxPolicy -MockWith {
            }

            Mock -CommandName New-OwaMailboxPolicy -MockWith {
            }

            Mock -CommandName Get-OwaMailboxPolicy -MockWith {
                return @{
                    Name                              = 'Contoso OWA Mailbox Policy'
                    InstantMessagingEnabled           = $true
                    AllowedOrganizationAccountDomains = @('contoso.com')
                    AttachmentsOfflineEnabledWin      = $true
                    BizBarEnabled                     = $true
                    BookingsMailboxDomain             = 'bookings.contoso.com'
                    DefaultClientLanguage             = 1033
                    EmptyStateEnabled                 = $true
                    HideClassicOutlookToggleOut       = $true
                    LinkedInEnabled                   = $true
                    MonthlyUpdatesEnabled             = $true
                    OfflineEnabledWeb                 = $true
                    OfflineEnabledWin                 = $true
                    OneDriveAttachmentsEnabled        = $true
                    OutlookDataFile                   = 'Allow'
                    OutlookNewslettersAccessLevel     = 'Undefined'
                    OutlookNewslettersReactions       = 'Undefined'
                    OutlookNewslettersShowMore        = 'Undefined'
                    PersonalBookingsDisabled          = $false
                    SMimeSuppressNameChecksEnabled    = $false
                    SpellCheckerEnabled               = $true
                    TasksEnabled                      = $true
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'OWA Mailbox Policy should exist. OWA Mailbox Policy is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                    = 'Contoso OWA Mailbox Policy'
                    InstantMessagingEnabled = $true
                    Ensure                  = 'Present'
                    Credential              = $Credential
                }

                Mock -CommandName Get-OwaMailboxPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-OwaMailboxPolicy -Exactly 1
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'OWA Mailbox Policy should exist. OWA Mailbox Policy exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                              = 'Contoso OWA Mailbox Policy'
                    InstantMessagingEnabled           = $true
                    AllowedOrganizationAccountDomains = @('contoso.com')
                    AttachmentsOfflineEnabledWin      = $true
                    BizBarEnabled                     = $true
                    BookingsMailboxDomain             = 'bookings.contoso.com'
                    DefaultClientLanguage             = 1033
                    EmptyStateEnabled                 = $true
                    HideClassicOutlookToggleOut       = $true
                    LinkedInEnabled                   = $true
                    MonthlyUpdatesEnabled             = $true
                    OfflineEnabledWeb                 = $true
                    OfflineEnabledWin                 = $true
                    OneDriveAttachmentsEnabled        = $true
                    OutlookDataFile                   = 'Allow'
                    OutlookNewslettersAccessLevel     = 'Undefined'
                    OutlookNewslettersReactions       = 'Undefined'
                    OutlookNewslettersShowMore        = 'Undefined'
                    PersonalBookingsDisabled          = $false
                    SMimeSuppressNameChecksEnabled    = $false
                    SpellCheckerEnabled               = $true
                    TasksEnabled                      = $true
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'OWA Mailbox Policy should exist. OWA Mailbox Policy exists, InstantMessagingEnabled mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                    = 'Contoso OWA Mailbox Policy'
                    InstantMessagingEnabled = $false # Drift
                    Ensure                  = 'Present'
                    Credential              = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOOwaMailboxPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-OwaMailboxPolicy -Exactly 1
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

            It 'Should Reverse Engineer resource from the Export method when single' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOOwaMailboxPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
