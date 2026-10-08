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
    -DscResource 'EXOHostedContentFilterRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-HostedContentFilterRule -MockWith {
            }

            Mock -CommandName Set-HostedContentFilterRule -MockWith {
            }

            Mock -CommandName Enable-HostedContentFilterRule -MockWith {
            }

            Mock -CommandName Disable-HostedContentFilterRule -MockWith {
            }

            Mock -CommandName Remove-HostedContentFilterRule -MockWith {
            }

            Mock -CommandName Get-HostedContentFilterRule -MockWith {
                return @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    HostedContentFilterPolicy = 'TestPolicy'
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

            Mock -CommandName Get-HostedContentFilterPolicy -MockWith {
                return @{
                    Identity = 'TestPolicy'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'HostedContentFilterRule creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Identity                  = 'TestRule'
                    HostedContentFilterPolicy = 'TestPolicy'
                }

                Mock -CommandName Get-HostedContentFilterRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-HostedContentFilterRule -Exactly 1
            }
        }

        Context -Name 'HostedContentFilterRule update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    Credential                = $Credential
                    HostedContentFilterPolicy = 'TestPolicy'
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
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'HostedContentFilterRule update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Present'
                    Identity                  = 'TestRule'
                    Credential                = $Credential
                    HostedContentFilterPolicy = 'TestPolicy'
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
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-HostedContentFilterRule -Exactly 1
                Should -Invoke -CommandName Disable-HostedContentFilterRule -Exactly 1
            }
        }

        Context -Name 'HostedContentFilterRule removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                    = 'Absent'
                    Credential                = $Credential
                    Identity                  = 'TestRule'
                    HostedContentFilterPolicy = 'TestPolicy'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedContentFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-HostedContentFilterRule -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOHostedContentFilterRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
