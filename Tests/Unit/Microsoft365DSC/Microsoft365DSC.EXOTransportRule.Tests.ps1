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
    -DscResource 'EXOTransportRule' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Write-Warning -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'Transport Rule should exist. Transport Rule is missing. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Transport Rule'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Brokerage Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-TransportRule -MockWith {
                    return $null
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Test() | Should -Be $false
            }

            Mock -CommandName Set-TransportRule -MockWith {
                return @{
                    Name                         = 'Contoso Different Transport Rule'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Marketing Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Marketing departments are strictly prohibited.'
                    FreeBusyAccessLevel          = 'AvailabilityOnly'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Set()
            }

            It 'Should return Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
        }

        Context -Name 'Transport Rule should exist. Transport Rule exists. Test should pass.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Transport Rule'
                    ActivationDate               = '2030-01-01T00:00:00.0000000Z'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Brokerage Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    MessageSizeOver              = '10 mb'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-TransportRule -MockWith {
                    return @{
                        Name                         = 'Contoso Transport Rule'
                        ActivationDate               = [System.DateTime]::new(2030, 1, 1, 0, 0, 0, [System.DateTimeKind]::Utc)
                        BetweenMemberOf1             = 'Sales Department'
                        BetweenMemberOf2             = 'Brokerage Department'
                        ExceptIfSubjectContainsWords = 'Press Release'
                        MessageSizeOver              = '10 MB (10,485,760 bytes)'
                        RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Present from the Get Method' {
                ((New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
        }

        Context -Name 'Transport Rule should exist. Transport Rule exists, BetweenMemberOf1 mismatch. Test should fail.' -Fixture {
            BeforeAll {
                $testParams = @{
                    Name                         = 'Contoso Transport Rule'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Brokerage Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }

                Mock -CommandName Get-TransportRule -MockWith {
                    return @{
                        Name                         = 'Contoso Transport Rule'
                        BetweenMemberOf1             = 'Marketing Department'
                        BetweenMemberOf2             = 'Brokerage Department'
                        ExceptIfSubjectContainsWords = 'Press Release'
                        RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    }
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Test() | Should -Be $false
            }

            Mock -CommandName Set-TransportRule -MockWith {
                return @{
                    Name                         = 'Contoso Transport Rule'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Brokerage Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                    Ensure                       = 'Present'
                    Credential                   = $Credential
                }
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'EXOTransportRule' -Property $testParams).Set()
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                $TransportRule = @{
                    Name                         = 'Contoso Transport Rule'
                    BetweenMemberOf1             = 'Sales Department'
                    BetweenMemberOf2             = 'Brokerage Department'
                    ExceptIfSubjectContainsWords = 'Press Release'
                    RejectMessageReasonText      = 'Messages sent between the Sales and Brokerage departments are strictly prohibited.'
                }

                Mock -CommandName Get-TransportRule -MockWith {
                    return $TransportRule
                }
            }

            It 'Should Reverse Engineer resource from the Export method when single' {
                $exported = Invoke-M365DSCResourceMethod -ResourceName 'EXOTransportRule' -MethodName 'Export' -Parameters $testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
