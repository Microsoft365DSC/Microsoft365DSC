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
    -DscResource 'AADTenantDetails' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@contoso.onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaOrganization -MockWith {
            }

            Mock -CommandName Get-MgBetaOrganization -MockWith {
                return @{
                    BusinessPhones                       = '+1 425 555 0100'
                    City                                 = 'Redmond'
                    MarketingNotificationEmails          = 'exapmle@contoso.com'
                    PostalCode                           = '98052'
                    PreferredLanguage                    = 'en'
                    PrivacyProfile                       = @{
                        ContactEmail = 'privacy@contoso.com'
                        StatementUrl = 'https://www.contoso.com/privacy'
                    }
                    SecurityComplianceNotificationMails  = 'exapmle@contoso.com'
                    SecurityComplianceNotificationPhones = '+1123456789'
                    State                                = 'WA'
                    Street                               = '1 Contoso Plaza'
                    TechnicalNotificationMails           = 'exapmle@contoso.com'
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Values should exist but it does not' -Fixture {
            BeforeAll {
                $testParams = @{
                    TechnicalNotificationMails           = 'exapmle@contoso.com'
                    SecurityComplianceNotificationPhones = '+1123456789'
                    SecurityComplianceNotificationMails  = 'exapmle@contoso.com'
                    MarketingNotificationEmails          = 'exapmle@contoso.com'
                    BusinessPhones                       = '+1 425 555 0100'
                    City                                 = 'Redmond'
                    PostalCode                           = '98052'
                    PreferredLanguage                    = 'en'
                    PrivacyProfile                       = ([MSFT_privacyProfile] @{
                        ContactEmail = 'privacy@contoso.com'
                        StatementUrl = 'https://www.contoso.com/privacy'
                    })
                    State                                = 'WA'
                    Street                               = '1 Contoso Plaza'
                    Credential                           = $Credential
                    IsSingleInstance                     = 'Yes'
                }

                Mock -CommandName Get-MgBetaOrganization -MockWith {
                    return @{
                        BusinessPhones                       = ''
                        City                                 = ''
                        MarketingNotificationEmails          = ''
                        PostalCode                           = ''
                        PreferredLanguage                    = ''
                        SecurityComplianceNotificationMails  = ''
                        SecurityComplianceNotificationPhones = ''
                        State                                = ''
                        Street                               = ''
                        TechnicalNotificationMails           = ''
                    }
                }
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Values exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    TechnicalNotificationMails           = ''
                    SecurityComplianceNotificationPhones = ''
                    SecurityComplianceNotificationMails  = ''
                    BusinessPhones                       = ''
                    City                                 = ''
                    PostalCode                           = ''
                    PreferredLanguage                    = ''
                    State                                = ''
                    Street                               = ''
                    Credential                           = $Credential
                    IsSingleInstance                     = 'Yes'
                }
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Test() | Should -Be $false
            }
        }
        Context -Name 'Values exists and values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    TechnicalNotificationMails           = 'exapmle@contoso.com'
                    SecurityComplianceNotificationPhones = '+1123456789'
                    SecurityComplianceNotificationMails  = 'exapmle@contoso.com'
                    MarketingNotificationEmails          = 'exapmle@contoso.com'
                    BusinessPhones                       = '+1 425 555 0100'
                    City                                 = 'Redmond'
                    PostalCode                           = '98052'
                    PreferredLanguage                    = 'en'
                    PrivacyProfile                       = ([MSFT_privacyProfile] @{
                        ContactEmail = 'privacy@contoso.com'
                        StatementUrl = 'https://www.contoso.com/privacy'
                    })
                    State                                = 'WA'
                    Street                               = '1 Contoso Plaza'
                    Credential                           = $Credential
                    IsSingleInstance                     = 'Yes'
                }
            }

            It 'Should return Values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaOrganization' -Exactly 1
            }

            It 'Should return true from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Values are not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    TechnicalNotificationMails           = 'exapmle@contoso.com'
                    SecurityComplianceNotificationPhones = '+1123456789'
                    SecurityComplianceNotificationMails  = 'exapmle@contoso.com'
                    MarketingNotificationEmails          = 'NOTexapmle@contoso.com' #Drift
                    BusinessPhones                       = '+1 425 555 0199' #Drift
                    City                                 = 'Bellevue' #Drift
                    PostalCode                           = '98004' #Drift
                    PreferredLanguage                    = 'fr' #Drift
                    PrivacyProfile                       = ([MSFT_privacyProfile] @{
                        ContactEmail = 'legal@contoso.com'
                        StatementUrl = 'https://www.contoso.com/legal/privacy'
                    }) #Drift
                    State                                = 'OR' #Drift
                    Street                               = '2 Contoso Plaza' #Drift
                    Credential                           = $Credential
                    IsSingleInstance                     = 'Yes'
                }
            }

            It 'Should return values from the get method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Get().ToHashtable()
                Should -Invoke -CommandName 'Get-MgBetaOrganization' -Exactly 1
            }

            It 'Should return false from the test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantDetails' -Property $testParams).Set()
                Should -Invoke -CommandName 'Update-MgBetaOrganization' -Exactly 1
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

            It 'Should reverse engineer resource from the export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADTenantDetails' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope

