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
    -DscResource 'EXOMailContact' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-MailContact -MockWith {
            }

            Mock -CommandName Set-MailContact -MockWith {
            }

            Mock -CommandName Remove-MailContact -MockWith {
            }

            Mock -CommandName Set-Contact -MockWith {
            }

            Mock -CommandName Get-Contact -MockWith {
                return @{
                    Identity  = 'My Test Contact'
                    FirstName = 'Alberto'
                    Initials  = 'R'
                    LastName  = 'Pereira'
                }
            }

            Mock -CommandName Get-MailContact -MockWith {
                return @{
                    Identity                    = 'My Test Contact'
                    Alias                       = 'TestMailContact'
                    DisplayName                 = 'My Test Contact'
                    ExternalEmailAddress        = 'SMTP:test@tailspintoys.com'
                    MacAttachmentFormat         = 'BinHex'
                    MessageBodyFormat           = 'TextAndHtml'
                    MessageFormat               = 'Mime'
                    ModeratedBy                 = @()
                    ModerationEnabled           = $False
                    Name                        = 'My Test Contact'
                    OrganizationalUnit          = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/tailspintoys.com'
                    SendModerationNotifications = 'Always'
                    UsePreferMessageFormat      = $True
                }
            }

            Mock -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "Instance should exist but doesn't." -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                       = 'TestMailContact'
                    Credential                  = $Credential
                    DisplayName                 = 'My Test Contact'
                    Ensure                      = 'Present'
                    ExternalEmailAddress        = 'SMTP:test@tailspintoys.com'
                    MacAttachmentFormat         = 'BinHex'
                    MessageBodyFormat           = 'TextAndHtml'
                    MessageFormat               = 'Mime'
                    ModeratedBy                 = @()
                    ModerationEnabled           = $False
                    Name                        = 'My Test Contact'
                    OrganizationalUnit          = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/tailspintoys.com'
                    SendModerationNotifications = 'Always'
                    UsePreferMessageFormat      = $True
                }

                Mock -CommandName Get-MailContact -MockWith {
                    if ($Script:contactCreated)
                    {
                        return @{
                            Name = 'My Test Contact'
                        }
                    }
                    return $null
                }

                Mock -CommandName New-MailContact -MockWith {
                    $Script:contactCreated = $true
                }
            }

            BeforeEach {
                $Script:contactCreated = $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Set()
                Should -Invoke -CommandName New-MailContact -Exactly 1
                Should -Invoke -CommandName Get-MailContact -Exactly 3 -ParameterFilter { $Identity -eq 'My Test Contact' }
                Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
                Should -Invoke -CommandName Set-MailContact -Exactly 1 -ParameterFilter { $Identity -eq 'My Test Contact' }
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Instance already exists but is NOT in the desired state.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                       = 'TestMailContact'
                    Credential                  = $Credential
                    DisplayName                 = 'My Test Contact'
                    Ensure                      = 'Present'
                    ExternalEmailAddress        = 'SMTP:test@tailspintoys.com'
                    FirstName                   = 'Alberto'
                    LastName                    = 'Ferreira' # Drift
                    MacAttachmentFormat         = 'BinHex'
                    MessageBodyFormat           = 'Text' # Drift
                    MessageFormat               = 'Mime'
                    ModeratedBy                 = @()
                    ModerationEnabled           = $False
                    Name                        = 'My Test Contact'
                    OrganizationalUnit          = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/tailspintoys.com'
                    SendModerationNotifications = 'Always'
                    UsePreferMessageFormat      = $True
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should update from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MailContact -Exactly 1
                Should -Invoke -CommandName Set-Contact -Exactly 1 -ParameterFilter { $LastName -eq 'Ferreira' -and -not $PesterBoundParameters.ContainsKey('FirstName') }
            }
        }

        Context -Name 'Instance already exists and is in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                       = 'TestMailContact'
                    Credential                  = $Credential
                    DisplayName                 = 'My Test Contact'
                    Ensure                      = 'Present'
                    ExternalEmailAddress        = 'SMTP:test@tailspintoys.com'
                    MacAttachmentFormat         = 'BinHex'
                    MessageBodyFormat           = 'TextAndHtml'
                    MessageFormat               = 'Mime'
                    ModeratedBy                 = @()
                    ModerationEnabled           = $False
                    Name                        = 'My Test Contact'
                    OrganizationalUnit          = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/tailspintoys.com'
                    SendModerationNotifications = 'Always'
                    UsePreferMessageFormat      = $True
                    FirstName                   = 'Alberto'
                    Initials                    = 'R'
                    LastName                    = 'Pereira'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Get().ToHashtable()
                $result.Ensure | Should -Be 'Present'
                $result.LastName | Should -Be 'Pereira'
            }
        }

        Context -Name 'Instance should NOT exist but it does' -Fixture {
            BeforeAll {
                $testParams = @{
                    Alias                       = 'TestMailContact'
                    Credential                  = $Credential
                    DisplayName                 = 'My Test Contact'
                    Ensure                      = 'Absent'
                    ExternalEmailAddress        = 'SMTP:test@tailspintoys.com'
                    MacAttachmentFormat         = 'BinHex'
                    MessageBodyFormat           = 'TextAndHtml'
                    MessageFormat               = 'Mime'
                    ModeratedBy                 = @()
                    ModerationEnabled           = $False
                    Name                        = 'My Test Contact'
                    OrganizationalUnit          = 'nampr03a010.prod.outlook.com/Microsoft Exchange Hosted Organizations/tailspintoys.com'
                    SendModerationNotifications = 'Always'
                    UsePreferMessageFormat      = $True
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should remove from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOMailContact' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MailContact -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOMailContact' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
