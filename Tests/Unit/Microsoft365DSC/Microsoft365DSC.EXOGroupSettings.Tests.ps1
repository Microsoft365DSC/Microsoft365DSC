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
    -DscResource 'EXOGroupSettings' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-Recipient -MockWith {
                return @(
                    @{
                        Name = "12345678-1234-1234-1234-123456789012";
                        PrimarySmtpAddress = "TestUser@contoso.com"
                    }
                )
            }

            Mock -CommandName Get-UnifiedGroup -MockWith {
                return @{
                    Id                                     = "12345-12345-12345-12345-12345";
                    DisplayName                            = "Test Group";
                    AccessType                             = "Public";
                    AcceptMessagesOnlyFromSendersOrMembersWithDisplayNames = @("TestUser@contoso.com");
                    GrantSendOnBehalfToWithDisplayNames    = @("TestUser@contoso.com");
                    AlwaysSubscribeMembersToCalendarEvents = $False;
                    AuditLogAgeLimit                       = "90.00:00:00";
                    AutoSubscribeNewMembers                = $False;
                    CalendarMemberReadOnly                 = $False;
                    ConnectorsEnabled                      = $True;
                    EmailAddresses                         = @("SMTP:TestGroup@contoso.com","SPO:SPO_eff656f4-6163-44b5-8410-139ac8658c5d@SPO_e7a80bcf-696e-40ca-8775-a7f85fbb3ebc");
                    HiddenFromAddressListsEnabled          = $True;
                    HiddenFromExchangeClientsEnabled       = $True;
                    InformationBarrierMode                 = "Open";
                    Language                               = @{Name = "en-US"};
                    MaxReceiveSize                         = "36 MB (37,748,736 bytes)";
                    MaxSendSize                            = "35 MB (36,700,160 bytes)";
                    ModerationEnabled                      = $False;
                    Notes                                  = "My Notes";
                    PrimarySmtpAddress                     = "TestGroup@contoso.com";
                    RequireSenderAuthenticationEnabled     = $True;
                    SubscriptionEnabled                    = $False;
                    WelcomeMessageEnabled                  = $True;
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Set-UnifiedGroup -MockWith {
            }
        }

        Context -Name "The Specified Group doesn't Exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                            = "Test Group";
                    AccessType                             = "Public";
                    AcceptMessagesOnlyFromSendersOrMembers = @("TestUser@contoso.com");
                    AlwaysSubscribeMembersToCalendarEvents = $False;
                    AuditLogAgeLimit                       = "90.00:00:00";
                    AutoSubscribeNewMembers                = $False;
                    CalendarMemberReadOnly                 = $False;
                    ConnectorsEnabled                      = $True;
                    Credential                             = $Credential;
                    HiddenFromAddressListsEnabled          = $True;
                    HiddenFromExchangeClientsEnabled       = $True;
                    GrantSendOnBehalfTo                    = @("12345678-1234-1234-1234-123456789012");
                    InformationBarrierMode                 = "Open";
                    Language                               = "en-US";
                    MaxReceiveSize                         = "36 MB (37,748,736 bytes)";
                    MaxSendSize                            = "35 MB (36,700,160 bytes)";
                    ModerationEnabled                      = $False;
                    Notes                                  = "My Notes";
                    PrimarySmtpAddress                     = "TestGroup@contoso.com";
                    RequireSenderAuthenticationEnabled     = $True;
                    SubscriptionEnabled                    = $False;
                    WelcomeMessageEnabled                  = $True;
                }

                Mock -CommandName Get-UnifiedGroup -MockWith {
                    return $null
                }
            }

            It 'Should return the current Language as null from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Get().ToHashtable()).Language | Should -Be $null
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Test() | Should -Be $False
            }

            It 'Should call New-UnifiedGroup from the Set() method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-UnifiedGroup' -Exactly 1
            }
        }

        Context -Name "The Resource is already in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                            = "Test Group";
                    AccessType                             = "Public";
                    AcceptMessagesOnlyFromSendersOrMembers = @("TestUser@contoso.com");
                    AlwaysSubscribeMembersToCalendarEvents = $False;
                    AuditLogAgeLimit                       = "90.00:00:00";
                    AutoSubscribeNewMembers                = $False;
                    CalendarMemberReadOnly                 = $False;
                    ConnectorsEnabled                      = $True;
                    Credential                             = $Credential;
                    HiddenFromAddressListsEnabled          = $True;
                    HiddenFromExchangeClientsEnabled       = $True;
                    GrantSendOnBehalfTo                    = @("12345678-1234-1234-1234-123456789012");
                    InformationBarrierMode                 = "Open";
                    Language                               = "en-US";
                    MaxReceiveSize                         = "36 MB (37,748,736 bytes)";
                    MaxSendSize                            = "35 MB (36,700,160 bytes)";
                    ModerationEnabled                      = $False;
                    Notes                                  = "My Notes";
                    PrimarySmtpAddress                     = "TestGroup@contoso.com";
                    RequireSenderAuthenticationEnabled     = $True;
                    SubscriptionEnabled                    = $False;
                    WelcomeMessageEnabled                  = $True;
                }
            }

            It 'Should return the current Language as en-US from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Get().ToHashtable()).Language | Should -Be 'en-US'
            }

            It 'Should return True from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Test() | Should -Be $True
            }
        }
        Context -Name "The Resource is not in the Desired State" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                            = "Test Group";
                    AccessType                             = "Public";
                    AcceptMessagesOnlyFromSendersOrMembers = @("TestUser@contoso.com");
                    AlwaysSubscribeMembersToCalendarEvents = $False;
                    AuditLogAgeLimit                       = "90.00:00:00";
                    AutoSubscribeNewMembers                = $False;
                    CalendarMemberReadOnly                 = $False;
                    ConnectorsEnabled                      = $True;
                    Credential                             = $Credential;HiddenFromAddressListsEnabled          = $True;
                    HiddenFromExchangeClientsEnabled       = $True;
                    GrantSendOnBehalfTo                    = @("12345678-1234-1234-1234-123456789012");
                    InformationBarrierMode                 = "Open";
                    Language                               = "en-US";
                    MaxReceiveSize                         = "36 MB (37,748,736 bytes)";
                    MaxSendSize                            = "35 MB (36,700,160 bytes)";
                    ModerationEnabled                      = $true; # Drift
                    Notes                                  = "My Notes";
                    PrimarySmtpAddress                     = "TestGroup@contoso.com";
                    RequireSenderAuthenticationEnabled     = $True;
                    SubscriptionEnabled                    = $False;
                    WelcomeMessageEnabled                  = $True;
                }
            }

            It 'Should return False from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Test() | Should -Be $False
            }
            It 'Should call Set-UnifiedGroup from the Set() method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOGroupSettings' -Property $testParams).Set()
                Should -Invoke -CommandName 'Set-UnifiedGroup' -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOGroupSettings' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
