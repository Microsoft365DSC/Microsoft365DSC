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
    -DscResource 'TeamsEventsPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName New-CsTeamsEventsPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsEventsPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsEventsPolicy -MockWith {
            }

            Mock -CommandName Get-CsTeamsEventsPolicy -MockWith {
                return @{
                    Description                             = 'Desc'
                    Identity                                = 'TestPolicy'
                    EventAccessType                         = 'EveryoneInCompanyExcludingGuests'
                    AllowWebinars                           = 'Enabled';
                    AllowedQuestionTypesInRegistrationForm  = "AllQuestions";
                    AllowedTownhallTypesForRecordingPublish = "Everyone";
                    AllowedWebinarTypesForRecordingPublish  = "Everyone";
                    AllowEmailEditing                       = "Enabled";
                    AllowEngagementReport                   = "Enabled";
                    AllowEventIntegrations                  = $False;
                    AllowTownhalls                          = "Enabled";
                    BackroomChat                            = "Enabled";
                    BroadcastPremiumApps                    = "Enabled";
                    ExternalPresenterJoinVerification       = "eOTP";
                    ImmersiveEvents                         = "Enabled";
                    InfoShownInReportMode                   = "FullInformation";
                    RecordingForTownhall                    = "Enabled";
                    RecordingForWebinar                     = "Enabled";
                    Registration                            = "Enabled";
                    TownhallEventAttendeeAccess             = "Everyone";
                    TownhallMaxResolution                   = "Max720p";
                    TranscriptionForTownhall                = "Enabled";
                    TranscriptionForWebinar                 = "Enabled";
                    UseMicrosoftECDN                        = $True;
                    TownhallChatExperience                  = "Optimized";
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                             = 'Desc'
                    Ensure                                  = 'Present'
                    Credential                              = $Credential
                    Identity                                = 'TestPolicy'
                    EventAccessType                         = 'EveryoneInCompanyExcludingGuests'
                    AllowWebinars                           = 'Enabled'
                    AllowedQuestionTypesInRegistrationForm  = "AllQuestions";
                    AllowedTownhallTypesForRecordingPublish = "Everyone";
                    AllowedWebinarTypesForRecordingPublish  = "Everyone";
                    AllowEmailEditing                       = "Enabled";
                    AllowEngagementReport                   = "Enabled";
                    AllowEventIntegrations                  = $False;
                    AllowTownhalls                          = "Enabled";
                    BackroomChat                            = "Enabled";
                    BroadcastPremiumApps                    = "Enabled";
                    ExternalPresenterJoinVerification       = "eOTP";
                    ImmersiveEvents                         = "Enabled";
                    InfoShownInReportMode                   = "FullInformation";
                    RecordingForTownhall                    = "Enabled";
                    RecordingForWebinar                     = "Enabled";
                    Registration                            = "Enabled";
                    TownhallEventAttendeeAccess             = "Everyone";
                    TownhallMaxResolution                   = "Max720p";
                    TranscriptionForTownhall                = "Enabled";
                    TranscriptionForWebinar                 = "Enabled";
                    UseMicrosoftECDN                        = $True;
                    TownhallChatExperience                  = "Optimized";
                }

                Mock -CommandName Get-CsTeamsEventsPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsEventsPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                             = 'Desc'
                    Ensure                                  = 'Present'
                    Credential                              = $Credential
                    Identity                                = 'TestPolicy'
                    EventAccessType                         = 'EveryoneInCompanyExcludingGuests'
                    AllowWebinars                           = 'Disabled'; # Drift
                    AllowedQuestionTypesInRegistrationForm  = "AllQuestions";
                    AllowedTownhallTypesForRecordingPublish = "Everyone";
                    AllowedWebinarTypesForRecordingPublish  = "Everyone";
                    AllowEmailEditing                       = "Enabled";
                    AllowEngagementReport                   = "Enabled";
                    AllowEventIntegrations                  = $False;
                    AllowTownhalls                          = "Enabled";
                    BackroomChat                            = "Enabled";
                    BroadcastPremiumApps                    = "Enabled";
                    ExternalPresenterJoinVerification       = "eOTP";
                    ImmersiveEvents                         = "Enabled";
                    InfoShownInReportMode                   = "FullInformation";
                    RecordingForTownhall                    = "Enabled";
                    RecordingForWebinar                     = "Enabled";
                    Registration                            = "Enabled";
                    TownhallEventAttendeeAccess             = "Everyone";
                    TownhallMaxResolution                   = "Max720p";
                    TranscriptionForTownhall                = "Enabled";
                    TranscriptionForWebinar                 = "Enabled";
                    UseMicrosoftECDN                        = $True;
                    TownhallChatExperience                  = "Optimized";
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsEventsPolicy -Exactly 1
                Should -Invoke -CommandName New-CsTeamsEventsPolicy -Exactly 0
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                             = 'Desc'
                    Ensure                                  = 'Present'
                    Credential                              = $Credential
                    Identity                                = 'TestPolicy'
                    EventAccessType                         = 'EveryoneInCompanyExcludingGuests'
                    AllowWebinars                           = 'Enabled';
                    AllowedQuestionTypesInRegistrationForm  = "AllQuestions";
                    AllowedTownhallTypesForRecordingPublish = "Everyone";
                    AllowedWebinarTypesForRecordingPublish  = "Everyone";
                    AllowEmailEditing                       = "Enabled";
                    AllowEngagementReport                   = "Enabled";
                    AllowEventIntegrations                  = $False;
                    AllowTownhalls                          = "Enabled";
                    BackroomChat                            = "Enabled";
                    BroadcastPremiumApps                    = "Enabled";
                    ExternalPresenterJoinVerification       = "eOTP";
                    ImmersiveEvents                         = "Enabled";
                    InfoShownInReportMode                   = "FullInformation";
                    RecordingForTownhall                    = "Enabled";
                    RecordingForWebinar                     = "Enabled";
                    Registration                            = "Enabled";
                    TownhallEventAttendeeAccess             = "Everyone";
                    TownhallMaxResolution                   = "Max720p";
                    TranscriptionForTownhall                = "Enabled";
                    TranscriptionForWebinar                 = "Enabled";
                    UseMicrosoftECDN                        = $True;
                    TownhallChatExperience                  = "Optimized";
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                             = 'Desc'
                    Ensure                                  = 'Absent'
                    Credential                              = $Credential
                    Identity                                = 'TestPolicy'
                    EventAccessType                         = 'EveryoneInCompanyExcludingGuests'
                    AllowWebinars                           = 'Enabled';
                    AllowedQuestionTypesInRegistrationForm  = "AllQuestions";
                    AllowedTownhallTypesForRecordingPublish = "Everyone";
                    AllowedWebinarTypesForRecordingPublish  = "Everyone";
                    AllowEmailEditing                       = "Enabled";
                    AllowEngagementReport                   = "Enabled";
                    AllowEventIntegrations                  = $False;
                    AllowTownhalls                          = "Enabled";
                    BackroomChat                            = "Enabled";
                    BroadcastPremiumApps                    = "Enabled";
                    ExternalPresenterJoinVerification       = "eOTP";
                    ImmersiveEvents                         = "Enabled";
                    InfoShownInReportMode                   = "FullInformation";
                    RecordingForTownhall                    = "Enabled";
                    RecordingForWebinar                     = "Enabled";
                    Registration                            = "Enabled";
                    TownhallEventAttendeeAccess             = "Everyone";
                    TownhallMaxResolution                   = "Max720p";
                    TranscriptionForTownhall                = "Enabled";
                    TranscriptionForWebinar                 = "Enabled";
                    UseMicrosoftECDN                        = $True;
                    TownhallChatExperience                  = "Optimized";
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEventsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsEventsPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsEventsPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
