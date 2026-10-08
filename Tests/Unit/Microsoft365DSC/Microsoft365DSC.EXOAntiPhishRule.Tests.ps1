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
    -DscResource 'EXOAntiPhishRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-AntiPhishRule -MockWith {
                return @{}
            }

            Mock -CommandName Set-AntiPhishRule -MockWith {
                return @{}
            }

            Mock -CommandName Enable-AntiPhishRule -MockWith {
            }

            Mock -CommandName Disable-AntiPhishRule -MockWith {
            }

            Mock -CommandName Remove-AntiPhishRule -MockWith {
                return @{}
            }

            Mock -CommandName Get-AntiPhishRule -MockWith {
                return @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    AntiPhishPolicy           = 'TestPolicy'
                    Priority                  = 0
                    ExceptIfRecipientDomainIs = @('dev.contoso.com')
                    ExceptIfSentTo            = @('test@contoso.com')
                    ExceptIfSentToMemberOf    = @('Special Group')
                    RecipientDomainIs         = @('contoso.com')
                    SentTo                    = @('someone@contoso.com')
                    SentToMemberOf            = @('Some Group', 'Some Other Group')
                    State                     = 'Enabled'
                }
            }

            Mock -CommandName Get-AntiPhishPolicy -MockWith {
                return @{
                    Identity = 'TestPolicy'
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
        Context -Name 'AntiPhishRule creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure          = 'Present'
                    Credential      = $Credential
                    Identity        = 'TestRule'
                    AntiPhishPolicy = 'TestPolicy'
                }

                Mock -CommandName Get-AntiPhishRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-AntiPhishRule -Exactly 1
                Should -Invoke -CommandName Get-AntiPhishPolicy -Exactly 2 -ParameterFilter { $Identity -eq 'TestPolicy' }
                Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
            }
        }

        Context -Name 'AntiPhishRule update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    Credential                = $Credential
                    AntiPhishPolicy           = 'TestPolicy'
                    Enabled                   = $true
                    Priority                  = 0
                    ExceptIfRecipientDomainIs = @('dev.contoso.com')
                    ExceptIfSentTo            = @('test@contoso.com')
                    ExceptIfSentToMemberOf    = @('Special Group')
                    RecipientDomainIs         = @('contoso.com')
                    SentTo                    = @('someone@contoso.com')
                    SentToMemberOf            = @('Some Group', 'Some Other Group')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'AntiPhishRule update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    Credential                = $Credential
                    AntiPhishPolicy           = 'TestPolicy'
                    Enabled                   = $false
                    Priority                  = 0
                    ExceptIfRecipientDomainIs = @('notdev.contoso.com') # Drift
                    ExceptIfSentTo            = @('test@contoso.com')
                    ExceptIfSentToMemberOf    = @('Special Group')
                    RecipientDomainIs         = @('contoso.com')
                    SentTo                    = @('someone@contoso.com')
                    SentToMemberOf            = @('Some Group', 'Some Other Group')
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-AntiPhishRule -Exactly 1
                Should -Invoke -CommandName Disable-AntiPhishRule -Exactly 1
                Should -Invoke -CommandName Get-AntiPhishPolicy -Exactly 2 -ParameterFilter { $Identity -eq 'TestPolicy' }
            }
        }

        Context -Name 'AntiPhishRule removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure          = 'Absent'
                    Credential      = $Credential
                    Identity        = 'TestRule'
                    AntiPhishPolicy = 'TestPolicy'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOAntiPhishRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-AntiPhishRule -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOAntiPhishRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
