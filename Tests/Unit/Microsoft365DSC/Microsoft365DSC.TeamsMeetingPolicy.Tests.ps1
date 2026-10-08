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
    -DscResource 'TeamsMeetingPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsMeetingPolicy -MockWith {
                return @{
                    Identity                                     = 'Test Policy'
                    AllowAnonymousUsersToStartMeeting            = $False
                    AllowChannelMeetingScheduling                = $True
                    AllowCloudRecording                          = $True
                    AllowExternalNonTrustedMeetingChat           = $True
                    AllowExternalParticipantGiveRequestControl   = $False
                    AllowIntelligentRecap                        = $True
                    AllowIPVideo                                 = $True
                    AllowMeetingKnowledgeGeneration              = $True
                    AllowMeetNow                                 = $True
                    AllowMultipleScreenshare                     = $True
                    AllowOutlookAddIn                            = $True
                    AllowParticipantGiveRequestControl           = $True
                    AllowPowerPointSharing                       = $True
                    AllowPrivateMeetingScheduling                = $True
                    AllowSharedNotes                             = $True
                    AllowTranscription                           = $False
                    AllowWhiteboard                              = $True
                    AttendeeIdentityMasking                      = 'DisabledUserOverride'
                    AutoAdmittedUsers                            = 'Everyone'
                    AutomaticallyStartCopilot                    = 'Disabled'
                    AutoRecording                                = 'Enabled'
                    BackroomChat                                 = 'Disabled'
                    CaptchaVerificationForMeetingJoin            = 'NotRequired'
                    ChannelRecordingDownload                     = 'Allow'
                    ConditionalAccessAttendeeVerification        = $True
                    ConnectToMeetingControls                     = 'Enabled'
                    ContentSharingInExternalMeetings             = 'EnabledForAnyone'
                    Copilot                                      = 'EnabledWithTranscript'
                    CopyRestriction                              = $True
                    DetectSensitiveContentDuringScreenSharing    = $True
                    DisableAudioAnnouncementsForResourceAccounts = $False
                    EnableExternalRecordingDetection             = $False
                    EnablePreMeetingConsent                      = $False
                    ExternalBotAccessMode                        = 'RequireApprovalWhenDetected'
                    ExternalMeetingJoin                          = 'EnabledForAnyone'
                    Description                                  = $null
                    FilterProfanityInTranscript                  = 'Enabled'
                    IntelligentRecapDocxFileExpirationDays       = 120
                    MediaBitRateKb                               = 50000
                    MeetingKnowledgeExpirationDays               = 365
                    ParticipantNameChange                        = 'Enabled'
                    PasscodeComplexity                           = 'NumericOnly'
                    PreMeetingConsentContentIdentifier           = '6f1d2c3b-8a4e-4b7f-9c2d-1e5a7b3c9d04'
                    PreventComplianceRecording                   = 'None'
                    RecordingAndTranscriptionAudioNotification   = 'Disabled'
                    ScreenSharingMode                            = 'EntireScreen'
                    SetRecordingAndTranscriptOwnership           = 'Disabled'
                    SyntheticMediaDetection                      = 'Enabled'
                    SyntheticMediaDetectionAppId                 = 'b2d4f6a8-3c5e-4a7b-9d1f-2e4c6a8b0d13'
                    VoiceIsolation                               = 'Disabled'
                    WhoCanRegister                               = 'EveryoneInCompany'
                    RoomAttributeUserOverride                    = 'OFF'
                }
            }

            Mock -CommandName New-CsTeamsMeetingPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsMeetingPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsMeetingPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Meeting Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                     = 'Test Policy'
                    AllowAnonymousUsersToStartMeeting            = $False
                    AllowChannelMeetingScheduling                = $True
                    AllowCloudRecording                          = $True
                    AllowExternalParticipantGiveRequestControl   = $False
                    AllowIntelligentRecap                        = $True
                    AllowIPVideo                                 = $True
                    AllowMeetingKnowledgeGeneration              = $True
                    AllowMeetNow                                 = $True
                    AllowMultipleScreenshare                     = $True
                    AllowOutlookAddIn                            = $True
                    AllowParticipantGiveRequestControl           = $True
                    AllowPowerPointSharing                       = $True
                    AllowPrivateMeetingScheduling                = $True
                    AllowSharedNotes                             = $True
                    AllowTranscription                           = $False
                    AllowWhiteboard                              = $True
                    AutoAdmittedUsers                            = 'Everyone'
                    BackroomChat                                 = 'Disabled'
                    ConditionalAccessAttendeeVerification        = $True
                    Description                                  = $null
                    DisableAudioAnnouncementsForResourceAccounts = $False
                    EnableExternalRecordingDetection             = $False
                    EnablePreMeetingConsent                      = $False
                    ExternalBotAccessMode                        = 'RequireApprovalWhenDetected'
                    FilterProfanityInTranscript                  = 'Enabled'
                    IntelligentRecapDocxFileExpirationDays       = 120
                    MediaBitRateKb                               = 50000
                    MeetingKnowledgeExpirationDays               = 365
                    PasscodeComplexity                           = 'NumericOnly'
                    PreMeetingConsentContentIdentifier           = '6f1d2c3b-8a4e-4b7f-9c2d-1e5a7b3c9d04'
                    PreventComplianceRecording                   = 'None'
                    RecordingAndTranscriptionAudioNotification   = 'Disabled'
                    ScreenSharingMode                            = 'EntireScreen'
                    SetRecordingAndTranscriptOwnership           = 'Disabled'
                    SyntheticMediaDetection                      = 'Enabled'
                    SyntheticMediaDetectionAppId                 = 'b2d4f6a8-3c5e-4a7b-9d1f-2e4c6a8b0d13'
                    WhoCanRegister                               = 'EveryoneInCompany'
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential
                }

                Mock -CommandName Get-CsTeamsMeetingPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsMeetingPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                     = 'Test Policy'
                    AllowAnonymousUsersToStartMeeting            = $False
                    AllowChannelMeetingScheduling                = $True
                    AllowCloudRecording                          = $True
                    AllowExternalNonTrustedMeetingChat           = $True
                    AllowExternalParticipantGiveRequestControl   = $False
                    AllowIntelligentRecap                        = $True
                    AllowIPVideo                                 = $True
                    AllowMeetingKnowledgeGeneration              = $True
                    AllowMeetNow                                 = $True
                    AllowMultipleScreenshare                     = $True
                    AllowOutlookAddIn                            = $True
                    AllowParticipantGiveRequestControl           = $True
                    AllowPowerPointSharing                       = $True
                    AllowPrivateMeetingScheduling                = $True
                    AllowSharedNotes                             = $True
                    AllowTranscription                           = $False
                    AllowWhiteboard                              = $False # Drift
                    AttendeeIdentityMasking                      = 'DisabledUserOverride'
                    AutoAdmittedUsers                            = 'Everyone'
                    AutomaticallyStartCopilot                    = 'Disabled'
                    AutoRecording                                = 'Enabled'
                    BackroomChat                                 = 'Disabled'
                    CaptchaVerificationForMeetingJoin            = 'AnonymousUsersAndUntrustedOrganizations'
                    ChannelRecordingDownload                     = 'Allow'
                    ConditionalAccessAttendeeVerification        = $True
                    ConnectToMeetingControls                     = 'Enabled'
                    ContentSharingInExternalMeetings             = 'EnabledForAnyone'
                    Copilot                                      = 'EnabledWithTranscript'
                    CopyRestriction                              = $True
                    DetectSensitiveContentDuringScreenSharing    = $True
                    Description                                  = $null
                    DisableAudioAnnouncementsForResourceAccounts = $False
                    EnableExternalRecordingDetection             = $False
                    EnablePreMeetingConsent                      = $False
                    ExternalBotAccessMode                        = 'RequireApprovalWhenDetected'
                    ExternalMeetingJoin                          = 'EnabledForAnyone'
                    FilterProfanityInTranscript                  = 'Enabled'
                    IntelligentRecapDocxFileExpirationDays       = 120
                    MediaBitRateKb                               = 50000
                    MeetingKnowledgeExpirationDays               = 365
                    ParticipantNameChange                        = 'Disabled'
                    PasscodeComplexity                           = 'NumericOnly'
                    PreMeetingConsentContentIdentifier           = '6f1d2c3b-8a4e-4b7f-9c2d-1e5a7b3c9d04'
                    PreventComplianceRecording                   = 'None'
                    RecordingAndTranscriptionAudioNotification   = 'Disabled'
                    ScreenSharingMode                            = 'EntireScreen'
                    SetRecordingAndTranscriptOwnership           = 'Disabled'
                    SyntheticMediaDetection                      = 'Enabled'
                    SyntheticMediaDetectionAppId                 = 'b2d4f6a8-3c5e-4a7b-9d1f-2e4c6a8b0d13'
                    VoiceIsolation                               = 'Enabled'
                    WhoCanRegister                               = 'EveryoneInCompany'
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsMeetingPolicy -Exactly 1
                Should -Invoke -CommandName New-CSTeamsMeetingPolicy -Exactly 0
            }

            It 'Should reject a CaptchaVerificationForMeetingJoin value the service does not accept' {
                $invalidParams = $testParams.Clone()
                $invalidParams.CaptchaVerificationForMeetingJoin = 'AnonymousUsersOnly'
                { New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $invalidParams } | Should -Throw -ExpectedMessage "*not valid for property 'CaptchaVerificationForMeetingJoin'*"
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                     = 'Test Policy'
                    AllowAnonymousUsersToStartMeeting            = $False
                    AllowChannelMeetingScheduling                = $True
                    AllowCloudRecording                          = $True
                    AllowExternalParticipantGiveRequestControl   = $False
                    AllowIntelligentRecap                        = $True
                    AllowIPVideo                                 = $True
                    AllowMeetingKnowledgeGeneration              = $True
                    AllowMeetNow                                 = $True
                    AllowMultipleScreenshare                     = $True
                    AllowOutlookAddIn                            = $True
                    AllowParticipantGiveRequestControl           = $True
                    AllowPowerPointSharing                       = $True
                    AllowPrivateMeetingScheduling                = $True
                    AllowSharedNotes                             = $True
                    AllowTranscription                           = $False
                    AllowWhiteboard                              = $True
                    AutoAdmittedUsers                            = 'Everyone'
                    BackroomChat                                 = 'Disabled'
                    ConditionalAccessAttendeeVerification        = $True
                    Description                                  = $null
                    DisableAudioAnnouncementsForResourceAccounts = $False
                    EnableExternalRecordingDetection             = $False
                    EnablePreMeetingConsent                      = $False
                    ExternalBotAccessMode                        = 'RequireApprovalWhenDetected'
                    FilterProfanityInTranscript                  = 'Enabled'
                    IntelligentRecapDocxFileExpirationDays       = 120
                    MediaBitRateKb                               = 50000
                    MeetingKnowledgeExpirationDays               = 365
                    PreMeetingConsentContentIdentifier           = '6f1d2c3b-8a4e-4b7f-9c2d-1e5a7b3c9d04'
                    PreventComplianceRecording                   = 'None'
                    RecordingAndTranscriptionAudioNotification   = 'Disabled'
                    ScreenSharingMode                            = 'EntireScreen'
                    SetRecordingAndTranscriptOwnership           = 'Disabled'
                    SyntheticMediaDetection                      = 'Enabled'
                    SyntheticMediaDetectionAppId                 = 'b2d4f6a8-3c5e-4a7b-9d1f-2e4c6a8b0d13'
                    WhoCanRegister                               = 'EveryoneInCompany'
                    RoomAttributeUserOverride                    = 'OFF'
                    PasscodeComplexity                           = 'NumericOnly'
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                     = 'Test Policy'
                    AllowAnonymousUsersToStartMeeting            = $False
                    AllowChannelMeetingScheduling                = $True
                    AllowCloudRecording                          = $True
                    AllowExternalParticipantGiveRequestControl   = $False
                    AllowIntelligentRecap                        = $True
                    AllowIPVideo                                 = $True
                    AllowMeetingKnowledgeGeneration              = $True
                    AllowMeetNow                                 = $True
                    AllowMultipleScreenshare                     = $True
                    AllowOutlookAddIn                            = $True
                    AllowParticipantGiveRequestControl           = $True
                    AllowPowerPointSharing                       = $True
                    AllowPrivateMeetingScheduling                = $True
                    AllowSharedNotes                             = $True
                    AllowTranscription                           = $False
                    AllowWhiteboard                              = $True
                    AutoAdmittedUsers                            = 'Everyone'
                    BackroomChat                                 = 'Disabled'
                    ConditionalAccessAttendeeVerification        = $True
                    Description                                  = $null
                    DisableAudioAnnouncementsForResourceAccounts = $False
                    EnableExternalRecordingDetection             = $False
                    EnablePreMeetingConsent                      = $False
                    ExternalBotAccessMode                        = 'RequireApprovalWhenDetected'
                    FilterProfanityInTranscript                  = 'Enabled'
                    IntelligentRecapDocxFileExpirationDays       = 120
                    MediaBitRateKb                               = 50000
                    MeetingKnowledgeExpirationDays               = 365
                    PreMeetingConsentContentIdentifier           = '6f1d2c3b-8a4e-4b7f-9c2d-1e5a7b3c9d04'
                    PreventComplianceRecording                   = 'None'
                    RecordingAndTranscriptionAudioNotification   = 'Disabled'
                    ScreenSharingMode                            = 'EntireScreen'
                    SetRecordingAndTranscriptOwnership           = 'Disabled'
                    SyntheticMediaDetection                      = 'Enabled'
                    SyntheticMediaDetectionAppId                 = 'b2d4f6a8-3c5e-4a7b-9d1f-2e4c6a8b0d13'
                    WhoCanRegister                               = 'EveryoneInCompany'
                    PasscodeComplexity                           = 'NumericOnly'
                    Ensure                                       = 'Absent'
                    Credential                                   = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsMeetingPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsMeetingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
