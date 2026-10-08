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
    -DscResource 'TeamsMeetingBroadcastPolicy' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-CsTeamsMeetingBroadcastPolicy -MockWith {
                return @(
                    @{
                        AllowBroadcastScheduling        = $True
                        AllowBroadcastTranscription     = $False
                        BroadcastAttendeeVisibilityMode = 'EveryoneInCompany'
                        BroadcastRecordingMode          = 'AlwaysEnabled'
                        Identity                        = 'MyDemoPolicy'
                    }
                )
            }

            Mock -CommandName Set-CsTeamsMeetingBroadcastPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsMeetingBroadcastPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsMeetingBroadcastPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When settings are correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowBroadcastScheduling        = $True
                    AllowBroadcastTranscription     = $False
                    BroadcastAttendeeVisibilityMode = 'EveryoneInCompany'
                    BroadcastRecordingMode          = 'AlwaysEnabled'
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                    Identity                        = 'MyDemoPolicy'
                }
            }

            It 'Should return proper value from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Get().ToHashtable()).BroadcastAttendeeVisibilityMode | Should -Be 'EveryoneInCompany'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should update settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsMeetingBroadcastPolicy -Exactly 1
                Should -Invoke -CommandName New-CsTeamsMeetingBroadcastPolicy -Exactly 0
                Should -Invoke -CommandName Remove-CsTeamsMeetingBroadcastPolicy -Exactly 0
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowBroadcastScheduling        = $True
                    AllowBroadcastTranscription     = $False
                    BroadcastAttendeeVisibilityMode = 'EveryoneInCompany'
                    BroadcastRecordingMode          = 'AlwaysDisabled'; #Drifted
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                    Identity                        = 'MyDemoPolicy'
                }
            }

            It 'Should return proper value from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Get().ToHashtable()).BroadcastRecordingMode | Should -Be 'AlwaysEnabled'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsMeetingBroadcastPolicy
            }
        }

        Context -Name "When the Policy Doesn't Already Exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowBroadcastScheduling        = $True
                    AllowBroadcastTranscription     = $False
                    BroadcastAttendeeVisibilityMode = 'EveryoneInCompany'
                    BroadcastRecordingMode          = 'AlwaysDisabled'; #Drifted
                    Ensure                          = 'Present'
                    Credential                      = $Credential
                    Identity                        = 'MyDemoPolicy'
                }

                Mock -CommandName Get-CsTeamsMeetingBroadcastPolicy -MockWith {
                }
            }

            It 'Should return Ensure is Absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsMeetingBroadcastPolicy
            }
        }

        Context -Name "When the Policy Exists but Shouldn't" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowBroadcastScheduling        = $True
                    AllowBroadcastTranscription     = $False
                    BroadcastAttendeeVisibilityMode = 'EveryoneInCompany'
                    BroadcastRecordingMode          = 'AlwaysDisabled'; #Drifted
                    Ensure                          = 'Absent'
                    Credential                      = $Credential
                    Identity                        = 'MyDemoPolicy'
                }
            }

            It 'Should return Ensure is Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Delete the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsMeetingBroadcastPolicy
            }
        }

        Context -Name 'When the No Optional Parameters are Specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                    Identity   = 'MyDemoPolicy'
                }
            }

            It 'Should throw an error from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingBroadcastPolicy' -Property $testParams).Set() } | Should -Throw
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsMeetingBroadcastPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
