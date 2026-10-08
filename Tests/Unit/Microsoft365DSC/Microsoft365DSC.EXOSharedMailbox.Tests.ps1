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
    -DscResource 'EXOSharedMailbox' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Remove-Mailbox -MockWith {
            }

            Mock -CommandName New-Mailbox -MockWith {
            }

            Mock -CommandName Set-Mailbox -MockWith {
            }

            Mock -CommandName Get-Mailbox -MockWith {
                return @{
                    Identity                          = 'Test Shared Mailbox'
                    Name                              = 'Test Shared Mailbox'
                    DisplayName                       = 'Test Shared Mailbox'
                    RecipientTypeDetails              = 'SharedMailbox'
                    Alias                             = 'test'
                    EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                    PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                    AuditEnabled                      = $true
                    MessageCopyForSendOnBehalfEnabled = $false
                    MessageCopyForSentAsEnabled       = $false
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances = $null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Mailbox doesn't exist and it should" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Testh@contoso.onmicrosoft.com'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should create the Shared Mailbox in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
            }
        }

        Context -Name "Mailbox doesn't exist and should be created with Alias" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Testh@contoso.onmicrosoft.com'
                    Alias              = 'testshared'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should create the Shared Mailbox with Alias via New-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
            }
        }

        Context -Name "Mailbox doesn't exist and should be created with AuditEnabled" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Testh@contoso.onmicrosoft.com'
                    AuditEnabled       = $true
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should create the mailbox and then call Set-Mailbox for AuditEnabled' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
                Should -Invoke -CommandName Set-Mailbox -Exactly 1
            }
        }

        Context -Name "Mailbox doesn't exist and should be created with EmailAddresses" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Testh@contoso.onmicrosoft.com'
                    EmailAddresses     = @('alias1@contoso.onmicrosoft.com')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should create the mailbox and then call Set-Mailbox for EmailAddresses' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
                Should -Invoke -CommandName Set-Mailbox -Exactly 1
            }
        }

        Context -Name "Mailbox doesn't exist and should be created with MessageCopyForSendOnBehalfEnabled" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                       = 'Test Shared Mailbox'
                    PrimarySMTPAddress                = 'Testh@contoso.onmicrosoft.com'
                    MessageCopyForSendOnBehalfEnabled = $true
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should create the mailbox and then call Set-Mailbox for MessageCopyForSendOnBehalfEnabled' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
                Should -Invoke -CommandName Set-Mailbox -Exactly 1
            }
        }

        Context -Name "Mailbox doesn't exist and should be created with MessageCopyForSentAsEnabled" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                 = 'Test Shared Mailbox'
                    PrimarySMTPAddress          = 'Testh@contoso.onmicrosoft.com'
                    MessageCopyForSentAsEnabled = $true
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return $null
                }
            }

            It 'Should create the mailbox and then call Set-Mailbox for MessageCopyForSentAsEnabled' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName New-Mailbox -Exactly 1
                Should -Invoke -CommandName Set-Mailbox -Exactly 1
            }
        }

        Context -Name 'Mailbox already exists and it should' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Test@contoso.onmicrosoft.com'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return True from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Test() | Should -Be $True
            }
            It 'Should return false from the Test method' {
                $testParams.PrimarySMTPAddress = 'test@contoso1.onmicrosoft.com'
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Test() | Should -Be $False
            }
        }

        Context -Name 'Get-TargetResource returns new properties' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'test@contoso.onmicrosoft.com'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $true
                        MessageCopyForSendOnBehalfEnabled = $true
                        MessageCopyForSentAsEnabled       = $true
                    }
                }
            }

            It 'Should return MessageCopyForSendOnBehalfEnabled from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.MessageCopyForSendOnBehalfEnabled | Should -Be $true
            }

            It 'Should return MessageCopyForSentAsEnabled from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.MessageCopyForSentAsEnabled | Should -Be $true
            }

            It 'Should return AuditEnabled from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.AuditEnabled | Should -Be $true
            }

            It 'Should return EmailAddresses filtering out PrimarySMTPAddress' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.EmailAddresses | Should -Not -Contain 'test@contoso.onmicrosoft.com'
                $result.EmailAddresses | Should -Contain 'user@contoso.onmicrosoft.com'
            }
        }

        Context -Name 'Get-TargetResource with Identity parameter' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    Identity           = 'TestIdentity'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'TestIdentity'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should return the mailbox using Identity' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.Identity | Should -Be 'TestIdentity'
            }
        }

        Context -Name 'Get-TargetResource email filtering without PrimarySMTPAddress param' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName = 'Test Shared Mailbox'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:secondary@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should return all parsed EmailAddresses when PrimarySMTPAddress param is not specified' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.EmailAddresses | Should -Contain 'secondary@contoso.onmicrosoft.com'
            }
        }

        Context -Name 'Get-TargetResource email filtering with explicit PrimarySMTPAddress param' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'test@contoso.onmicrosoft.com'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:secondary@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should filter out PrimarySMTPAddress from EmailAddresses when PrimarySMTPAddress is explicitly provided' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Get().ToHashtable()
                $result.EmailAddresses | Should -Not -Contain 'test@contoso.onmicrosoft.com'
                $result.EmailAddresses | Should -Contain 'secondary@contoso.onmicrosoft.com'
            }
        }

        Context -Name 'Alias is Contained in the PrimarySMTP Address' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Test@contoso.onmicrosoft.com'
                    EmailAddresses     = @('Test@contoso.onmicrosoft.com')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                It 'Should throw an error from the Set method' {
                    { (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set() } | Should Throw 'You cannot have the EmailAddresses list contain the PrimarySMTPAddress'
                }
            }
        }

        Context -Name 'Mailbox exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Test@contoso.onmicrosoft.com'
                    EmailAddresses     = @('User1@contoso.onmicrosoft.com')
                    Ensure             = 'Absent'
                    Credential         = $Credential
                }
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-Mailbox -Times 1
            }
        }

        Context -Name 'EmailAddresses are specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Test@contoso.onmicrosoft.com'
                    EmailAddresses     = @('User1@contoso.onmicrosoft.com')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
            }
        }

        Context -Name 'Primary Smtp Address different' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'Test@contoso1.onmicrosoft.com' # Drift
                    Alias              = 'test'
                    EmailAddresses     = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
            }
        }

        Context -Name 'Update existing mailbox - PrimarySMTPAddress drift' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'newemail@contoso.onmicrosoft.com'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update PrimarySMTPAddress via Set-Mailbox with WindowsEmailAddress' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 2
            }
        }

        Context -Name 'Update existing mailbox - Alias drift' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'test@contoso.onmicrosoft.com'
                    Alias              = 'newalias'
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update Alias via Set-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - AuditEnabled drift' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'test@contoso.onmicrosoft.com'
                    AuditEnabled       = $true
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update AuditEnabled via Set-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - MessageCopyForSendOnBehalfEnabled drift' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                       = 'Test Shared Mailbox'
                    PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                    MessageCopyForSendOnBehalfEnabled = $true
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update MessageCopyForSendOnBehalfEnabled via Set-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - MessageCopyForSentAsEnabled drift' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                 = 'Test Shared Mailbox'
                    PrimarySMTPAddress          = 'test@contoso.onmicrosoft.com'
                    MessageCopyForSentAsEnabled = $true
                    Ensure                      = 'Present'
                    Credential                  = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update MessageCopyForSentAsEnabled via Set-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - EmailAddresses add and remove' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName        = 'Test Shared Mailbox'
                    PrimarySMTPAddress = 'test@contoso.onmicrosoft.com'
                    EmailAddresses     = @('newaddress@contoso.onmicrosoft.com')
                    Ensure             = 'Present'
                    Credential         = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:oldaddress@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should update EmailAddresses with add and remove via Set-Mailbox' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - EmailAddresses with no PrimarySMTPAddress param' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName    = 'Test Shared Mailbox'
                    EmailAddresses = @('newaddress@contoso.onmicrosoft.com')
                    Ensure         = 'Present'
                    Credential     = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:oldaddress@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should handle EmailAddresses update when PrimarySMTPAddress is not specified' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'Update existing mailbox - no drift on properties that match' -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName                       = 'Test Shared Mailbox'
                    PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                    Alias                             = 'test'
                    AuditEnabled                      = $false
                    MessageCopyForSendOnBehalfEnabled = $false
                    MessageCopyForSentAsEnabled       = $false
                    Ensure                            = 'Present'
                    Credential                        = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @{
                        Identity                          = 'Test Shared Mailbox'
                        Name                              = 'Test Shared Mailbox'
                        DisplayName                       = 'Test Shared Mailbox'
                        RecipientTypeDetails              = 'SharedMailbox'
                        Alias                             = 'test'
                        EmailAddresses                    = @('smtp:user@contoso.onmicrosoft.com', 'SMTP:test@contoso.onmicrosoft.com')
                        PrimarySMTPAddress                = 'test@contoso.onmicrosoft.com'
                        AuditEnabled                      = $false
                        MessageCopyForSendOnBehalfEnabled = $false
                        MessageCopyForSentAsEnabled       = $false
                    }
                }
            }

            It 'Should call Set-Mailbox only once with just Identity when nothing drifted' {
                (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox' -Property $testParams).Set()
                Should -Invoke -CommandName Set-Mailbox -Times 1
            }
        }

        Context -Name 'GetCompareParameters returns correct structure' -Fixture {
            It 'Should return a hashtable with IncludedProperties' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOSharedMailbox').GetCompareParameters()
                $result | Should -BeOfType [System.Collections.Hashtable]
                $result.IncludedProperties | Should -Contain 'DisplayName'
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSharedMailbox' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }

        Context -Name 'Export with empty mailbox list' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-Mailbox -MockWith {
                    return @()
                }
            }

            It 'Should return empty string when no shared mailboxes exist' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOSharedMailbox' -MethodName 'Export' -Parameters $testParams
                $result | Should -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
