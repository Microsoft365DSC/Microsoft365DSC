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
    -DscResource 'TeamsComplianceRecordingPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-CsTeamsComplianceRecordingPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsComplianceRecordingPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsComplianceRecordingPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsComplianceRecordingApplication -MockWith {
            }

            Mock -CommandName Set-CsTeamsComplianceRecordingApplication -MockWith {
            }

            Mock -CommandName Remove-CsTeamsComplianceRecordingApplication -MockWith {
            }

            Mock -CommandName New-CsTeamsComplianceRecordingPairedApplication -MockWith {
                return @{
                    Id = $Id
                }
            }

            Mock -CommandName Get-CsTeamsComplianceRecordingPolicy -MockWith {
                return @{
                    WarnUserOnRemoval                                   = $True
                    Description                                         = 'FakeStringValue'
                    Enabled                                             = $True
                    DisableComplianceRecordingAudioNotificationForCalls = $True
                    ComplianceRecordingApplications                     = @(
                        @{
                            Id = '00000000-0000-0000-0000-000000000000'
                            ComplianceRecordingPairedApplications = @()
                            ConcurrentInvitationCount             = 1
                            RequiredDuringCall                    = $True
                            RequiredBeforeMeetingJoin             = $True
                            RequiredBeforeCallEstablishment       = $True
                            RequiredDuringMeeting                 = $True
                        }
                    )
                    Identity                                            = 'FakeStringValue'
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
        Context -Name 'The TeamsComplianceRecordingPolicy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    ComplianceRecordingApplications                     = @(
                        [MSFT_TeamsComplianceRecordingApplication] @{
                            Id                                    = '11111111-1111-1111-1111-111111111111'
                            ComplianceRecordingPairedApplications = @('22222222-2222-2222-2222-222222222222')
                            ConcurrentInvitationCount             = '1'
                            RequiredDuringCall                    = $True
                            RequiredBeforeMeetingJoin             = $True
                            RequiredBeforeCallEstablishment       = $True
                            RequiredDuringMeeting                 = $True
                        }
                    )
                    WarnUserOnRemoval                                   = $True
                    Description                                         = 'FakeStringValue'
                    Enabled                                             = $True
                    DisableComplianceRecordingAudioNotificationForCalls = $True
                    Identity                                            = 'FakeStringValue'
                    Ensure                                              = 'Present'
                    Credential                                          = $Credential
                }

                $Script:policyCreated = $false
                Mock -CommandName New-CsTeamsComplianceRecordingPolicy -MockWith {
                    $Script:policyCreated = $true
                }
                Mock -CommandName Get-CsTeamsComplianceRecordingPolicy -MockWith {
                    if ($Script:policyCreated)
                    {
                        return @{
                            Identity = 'Tag:FakeStringValue'
                        }
                    }
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsComplianceRecordingPolicy -Exactly 1 -ParameterFilter {
                    $null -eq $ComplianceRecordingApplications
                }
                Should -Invoke -CommandName New-CsTeamsComplianceRecordingApplication -Exactly 1 -ParameterFilter {
                    $Identity -eq 'Tag:FakeStringValue/11111111-1111-1111-1111-111111111111' -and
                    $ConcurrentInvitationCount -eq 1 -and
                    $ComplianceRecordingPairedApplications.Count -eq 1
                }
                Should -Invoke -CommandName New-CsTeamsComplianceRecordingPairedApplication -Exactly 1 -ParameterFilter {
                    $Id -eq '22222222-2222-2222-2222-222222222222'
                }
                Should -Invoke -CommandName Set-CsTeamsComplianceRecordingApplication -Exactly 0
            }
        }

        Context -Name 'The TeamsComplianceRecordingPolicy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    WarnUserOnRemoval                                   = $True
                    Description                                         = 'FakeStringValue'
                    Enabled                                             = $True
                    DisableComplianceRecordingAudioNotificationForCalls = $True
                    Identity                                            = 'FakeStringValue'
                    Ensure                                              = 'Absent'
                    Credential                                          = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                $Result = ((New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Get().ToHashtable())
                $Result.Ensure | Should -Be 'Present'
                $Result.ComplianceRecordingApplications.Length | Should -Be 1
                Should -Invoke -CommandName Get-CsTeamsComplianceRecordingPolicy -Exactly 1

            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsComplianceRecordingPolicy -Exactly 1
            }
        }

        Context -Name 'The TeamsComplianceRecordingPolicy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ComplianceRecordingApplications                     = @(
                        [MSFT_TeamsComplianceRecordingApplication] @{
                            Id                                    = '00000000-0000-0000-0000-000000000000'
                            ComplianceRecordingPairedApplications = @()
                            ConcurrentInvitationCount             = '1'
                            RequiredDuringCall                    = $True
                            RequiredBeforeMeetingJoin             = $True
                            RequiredBeforeCallEstablishment       = $True
                            RequiredDuringMeeting                 = $True
                        }
                    )
                    WarnUserOnRemoval                                   = $True
                    Description                                         = 'FakeStringValue'
                    Enabled                                             = $True
                    DisableComplianceRecordingAudioNotificationForCalls = $True
                    Identity                                            = 'FakeStringValue'
                    Ensure                                              = 'Present'
                    Credential                                          = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The TeamsComplianceRecordingPolicy exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    ComplianceRecordingApplications                     = @(
                        [MSFT_TeamsComplianceRecordingApplication] @{
                            Id                        = '33333333-3333-3333-3333-333333333333'
                            RequiredDuringCall        = $False
                            RequiredBeforeMeetingJoin = $False
                        }
                    )
                    WarnUserOnRemoval                                   = $False # Drift
                    Description                                         = 'FakeStringValue'
                    Enabled                                             = $True
                    DisableComplianceRecordingAudioNotificationForCalls = $True
                    Identity                                            = 'FakeStringValue'
                    Ensure                                              = 'Present'
                    Credential                                          = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsComplianceRecordingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsComplianceRecordingPolicy -Exactly 1 -ParameterFilter {
                    $null -eq $ComplianceRecordingApplications -and $WarnUserOnRemoval -eq $False
                }
                Should -Invoke -CommandName Remove-CsTeamsComplianceRecordingApplication -Exactly 1 -ParameterFilter {
                    $Identity -eq 'FakeStringValue/00000000-0000-0000-0000-000000000000'
                }
                Should -Invoke -CommandName New-CsTeamsComplianceRecordingApplication -Exactly 1 -ParameterFilter {
                    $Identity -eq 'FakeStringValue/33333333-3333-3333-3333-333333333333' -and
                    $RequiredDuringCall -eq $False -and
                    -not $PSBoundParameters.ContainsKey('ComplianceRecordingPairedApplications')
                }
                Should -Invoke -CommandName Set-CsTeamsComplianceRecordingApplication -Exactly 0
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsComplianceRecordingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
