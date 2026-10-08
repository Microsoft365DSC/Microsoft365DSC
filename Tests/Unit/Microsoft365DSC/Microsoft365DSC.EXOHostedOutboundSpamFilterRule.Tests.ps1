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
    -DscResource 'EXOHostedOutboundSpamFilterRule' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-HostedOutboundSpamFilterRule -MockWith {
            }

            Mock -CommandName Set-HostedOutboundSpamFilterRule -MockWith {
            }

            Mock -CommandName Enable-HostedOutboundSpamFilterRule -MockWith {
            }

            Mock -CommandName Disable-HostedOutboundSpamFilterRule -MockWith {
            }

            Mock -CommandName Remove-HostedOutboundSpamFilterRule -MockWith {
            }

            Mock -CommandName Get-HostedOutboundSpamFilterRule -MockWith {
                return @{
                    Ensure                         = 'Present'
                    Identity                       = 'TestRule'
                    HostedOutboundSpamFilterPolicy = 'TestPolicy'
                    Priority                       = 0
                    ExceptIfSenderDomainIs         = @('dev.contoso.com')
                    ExceptIfFrom                   = @('test@contoso.com')
                    ExceptIfFromMemberOf           = @('Special Group')
                    SenderDomainIs                 = @('contoso.com')
                    From                           = @('someone@contoso.com')
                    FromMemberOf                   = @('Some Group', 'Some Other Group')
                    State                          = 'Enabled'
                }
            }

            Mock -CommandName Get-HostedOutboundSpamFilterPolicy -MockWith {
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
        Context -Name 'HostedOutboundSpamFilterRule creation.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                         = 'Present'
                    Credential                     = $Credential
                    Identity                       = 'TestRule'
                    HostedOutboundSpamFilterPolicy = 'TestPolicy'
                }

                Mock -CommandName Get-HostedOutboundSpamFilterRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName New-HostedOutboundSpamFilterRule -Exactly 1
                Should -Invoke -CommandName Get-HostedOutboundSpamFilterPolicy -Exactly 2 -ParameterFilter { $Identity -eq 'TestPolicy' }
                Should -Invoke -CommandName Start-Sleep -ModuleName M365DSCErrorHandler -Exactly 0
            }
        }

        Context -Name 'HostedOutboundSpamFilterRule update not required.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                         = 'Present'
                    Identity                       = 'TestRule'
                    Credential                     = $Credential
                    HostedOutboundSpamFilterPolicy = 'TestPolicy'
                    Enabled                        = $true
                    Priority                       = 0
                    ExceptIfSenderDomainIs         = @('dev.contoso.com')
                    ExceptIfFrom                   = @('test@contoso.com')
                    ExceptIfFromMemberOf           = @('Special Group')
                    SenderDomainIs                 = @('contoso.com')
                    From                           = @('someone@contoso.com')
                    FromMemberOf                   = @('Some Group', 'Some Other Group')
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'HostedOutboundSpamFilterRule update needed.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                         = 'Present'
                    Identity                       = 'TestRule'
                    Credential                     = $Credential
                    HostedOutboundSpamFilterPolicy = 'TestPolicy'
                    Enabled                        = $false
                    Priority                       = 0
                    ExceptIfSenderDomainIs         = @('notdev.contoso.com') # Drift
                    ExceptIfFrom                   = @('test@contoso.com')
                    ExceptIfFromMemberOf           = @('Special Group')
                    SenderDomainIs                 = @('contoso.com')
                    From                           = @('someone@contoso.com')
                    FromMemberOf                   = @('Some Group', 'Some Other Group')
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName Set-HostedOutboundSpamFilterRule -Exactly 1
                Should -Invoke -CommandName Disable-HostedOutboundSpamFilterRule -Exactly 1
                Should -Invoke -CommandName Get-HostedOutboundSpamFilterPolicy -Exactly 2 -ParameterFilter { $Identity -eq 'TestPolicy' }
            }
        }

        Context -Name 'HostedOutboundSpamFilterRule removal.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Ensure                         = 'Absent'
                    Credential                     = $Credential
                    Identity                       = 'TestRule'
                    HostedOutboundSpamFilterPolicy = 'TestPolicy'
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOHostedOutboundSpamFilterRule' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-HostedOutboundSpamFilterRule -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-HostedOutboundSpamFilterRule -MockWith {
                    return @{
                        Identity                       = 'TestRule'
                        HostedOutboundSpamFilterPolicy = 'TestPolicy'
                    }
                }

                Mock -CommandName Get-HostedOutboundSpamFilterPolicy -MockWith {
                    return @{
                        Identity = 'TestPolicy'
                    }
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'EXOHostedOutboundSpamFilterRule' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
