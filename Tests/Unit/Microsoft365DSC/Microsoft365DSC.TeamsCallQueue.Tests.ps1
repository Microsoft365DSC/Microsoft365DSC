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
    -DscResource 'TeamsCallQueue' -GenericStubModule $GenericStubPath
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

            Mock -CommandName Get-CsCallQueue -MockWith {
                return @{ Identity = "d0b1c6f2-3c1e-4a51-9a7e-6f0d2c8b4e17"; Name = "TestQueue EU" }, @{
                    Identity                                   = "5e3a575e-1faa-49ff-83c2-5cf1c36c0e01"
                    AgentAlertTime                             = 114;
                    AllowOptOut                                = $True;
                    AuthorizedUsers                            = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    CallbackEmailNotificationTarget            = @{Id = "4b1c8a3e-6f2d-4e9a-b7c5-2d8f1e0a9c63"}
                    ChannelId                                  = "19:Y6MG7XdME2Cf9IRmU8PUXNfA1OtqmjyBgCmCGBN2tzY1@thread.tacv2";
                    ConferenceMode                             = $True;
                    DistributionLists                          = @("36c88f29-faba-4f4a-89a7-e5af29e7095e");
                    EnableOverflowSharedVoicemailTranscription = $False;
                    EnableTimeoutSharedVoicemailTranscription  = $False;
                    LanguageId                                 = "fr-CA";
                    HideAuthorizedUsers                        = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    MusicOnHoldResourceId                      = "7d2e9f41-3a6b-4c8d-9e15-0b4a7c3f2d86"
                    Name                                       = "TestQueue";
                    OverflowAction                             = "Forward";
                    OverflowActionTarget                       = @{Id="9abce74d-d108-475f-a2cb-bbb82f484982"}
                    OverflowThreshold                          = 50;
                    PresenceBasedRouting                       = $True;
                    RoutingMethod                              = "RoundRobin";
                    SharedVoicemailTriageSettingsTemplateId    = "3a4b3d9b-91d8-4fbf-bcff-6907f325842c";
                    TextAnnouncementForCR                      = "FakeStringValue";
                    TextAnnouncementForCRFailure               = "FakeStringValue";
                    TimeoutAction                              = "Forward";
                    TimeoutActionTarget                        = @{Id = "9abce74d-d108-475f-a2cb-bbb82f484982"}
                    TimeoutThreshold                           = 1200;
                    UseDefaultMusicOnHold                      = $False;
                    WelcomeMusicResourceId                     = "e8a4c2b6-1d3f-4a7e-8c9b-5f6d0e2a1b47"
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }
            }

            Mock -CommandName Set-CsCallQueue -MockWith {
            }

            Mock -CommandName New-CsCallQueue -MockWith {
            }

            Mock -CommandName Remove-CsCallQueue -MockWith {
            }

            Mock -CommandName Get-CsOnlineUser -MockWith {
                return @{
                    Identity = "9abce74d-d108-475f-a2cb-bbb82f484982"
                    UserPrincipalName = "dummy@contoso.com"
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
        Context -Name 'The TeamsCallQueue should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AgentAlertTime                             = 114;
                    AllowOptOut                                = $True;
                    AuthorizedUsers                            = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    CallbackEmailNotificationTarget            = "4b1c8a3e-6f2d-4e9a-b7c5-2d8f1e0a9c63"
                    ChannelId                                  = "19:Y6MG7XdME2Cf9IRmU8PUXNfA1OtqmjyBgCmCGBN2tzY1@thread.tacv2";
                    ConferenceMode                             = $True;
                    DistributionLists                          = @("36c88f29-faba-4f4a-89a7-e5af29e7095e");
                    EnableOverflowSharedVoicemailTranscription = $False;
                    EnableTimeoutSharedVoicemailTranscription  = $False;
                    LanguageId                                 = "fr-CA";
                    HideAuthorizedUsers                        = @("dummy@contoso.com");
                    MusicOnHoldAudioFileId                     = "7d2e9f41-3a6b-4c8d-9e15-0b4a7c3f2d86"
                    Name                                       = "TestQueue";
                    OverflowAction                             = "Forward";
                    OverflowActionTarget                       = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    OverflowThreshold                          = 50;
                    PresenceBasedRouting                       = $True;
                    RoutingMethod                              = "RoundRobin";
                    SharedVoicemailTriageSettingsTemplateId    = "3a4b3d9b-91d8-4fbf-bcff-6907f325842c";
                    TextAnnouncementForCR                      = "FakeStringValue";
                    TextAnnouncementForCRFailure               = "FakeStringValue";
                    TimeoutAction                              = "Forward";
                    TimeoutActionTarget                        = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    TimeoutThreshold                           = 1200;
                    UseDefaultMusicOnHold                      = $False;
                    WelcomeMusicAudioFileId                    = "e8a4c2b6-1d3f-4a7e-8c9b-5f6d0e2a1b47"
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }

                Mock -CommandName Get-CsCallQueue -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsCallQueue -Exactly 1
            }
        }

        Context -Name 'The TeamsCallQueue exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    AgentAlertTime                             = 114;
                    AllowOptOut                                = $True;
                    AuthorizedUsers                            = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    CallbackEmailNotificationTarget            = "4b1c8a3e-6f2d-4e9a-b7c5-2d8f1e0a9c63"
                    ChannelId                                  = "19:Y6MG7XdME2Cf9IRmU8PUXNfA1OtqmjyBgCmCGBN2tzY1@thread.tacv2";
                    ConferenceMode                             = $True;
                    DistributionLists                          = @("36c88f29-faba-4f4a-89a7-e5af29e7095e");
                    EnableOverflowSharedVoicemailTranscription = $False;
                    EnableTimeoutSharedVoicemailTranscription  = $False;
                    LanguageId                                 = "fr-CA";
                    HideAuthorizedUsers                        = @("dummy@contoso.com");
                    MusicOnHoldAudioFileId                     = "7d2e9f41-3a6b-4c8d-9e15-0b4a7c3f2d86"
                    Name                                       = "TestQueue";
                    OverflowAction                             = "Forward";
                    OverflowActionTarget                       = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    OverflowThreshold                          = 50;
                    PresenceBasedRouting                       = $True;
                    RoutingMethod                              = "RoundRobin";
                    SharedVoicemailTriageSettingsTemplateId    = "3a4b3d9b-91d8-4fbf-bcff-6907f325842c";
                    TextAnnouncementForCR                      = "FakeStringValue";
                    TextAnnouncementForCRFailure               = "FakeStringValue";
                    TimeoutAction                              = "Forward";
                    TimeoutActionTarget                        = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    TimeoutThreshold                           = 1200;
                    UseDefaultMusicOnHold                      = $False;
                    WelcomeMusicAudioFileId                    = "e8a4c2b6-1d3f-4a7e-8c9b-5f6d0e2a1b47"
                    Ensure                                     = 'Absent'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the queue from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsCallQueue -Exactly 1 -ParameterFilter { $Identity -eq '5e3a575e-1faa-49ff-83c2-5cf1c36c0e01' }
            }
        }

        Context -Name 'The TeamsCallQueue is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AgentAlertTime                             = 114;
                    AllowOptOut                                = $True;
                    AuthorizedUsers                            = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    CallbackEmailNotificationTarget            = "4b1c8a3e-6f2d-4e9a-b7c5-2d8f1e0a9c63"
                    ChannelId                                  = "19:Y6MG7XdME2Cf9IRmU8PUXNfA1OtqmjyBgCmCGBN2tzY1@thread.tacv2";
                    ConferenceMode                             = $True;
                    DistributionLists                          = @("36c88f29-faba-4f4a-89a7-e5af29e7095e");
                    EnableOverflowSharedVoicemailTranscription = $False;
                    EnableTimeoutSharedVoicemailTranscription  = $False;
                    LanguageId                                 = "fr-CA";
                    HideAuthorizedUsers                        = @("dummy@contoso.com");
                    MusicOnHoldAudioFileId                     = "7d2e9f41-3a6b-4c8d-9e15-0b4a7c3f2d86"
                    Name                                       = "TestQueue";
                    OverflowAction                             = "Forward";
                    OverflowActionTarget                       = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    OverflowThreshold                          = 50;
                    PresenceBasedRouting                       = $True;
                    RoutingMethod                              = "RoundRobin";
                    SharedVoicemailTriageSettingsTemplateId    = "3a4b3d9b-91d8-4fbf-bcff-6907f325842c";
                    TextAnnouncementForCR                      = "FakeStringValue";
                    TextAnnouncementForCRFailure               = "FakeStringValue";
                    TimeoutAction                              = "Forward";
                    TimeoutActionTarget                        = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    TimeoutThreshold                           = 1200;
                    UseDefaultMusicOnHold                      = $False;
                    WelcomeMusicAudioFileId                    = "e8a4c2b6-1d3f-4a7e-8c9b-5f6d0e2a1b47"
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The TeamsCallQueue is NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AgentAlertTime                             = 120; # Drift
                    AllowOptOut                                = $True;
                    AuthorizedUsers                            = @("9abce74d-d108-475f-a2cb-bbb82f484982");
                    CallbackEmailNotificationTarget            = "4b1c8a3e-6f2d-4e9a-b7c5-2d8f1e0a9c63"
                    ChannelId                                  = "19:Y6MG7XdME2Cf9IRmU8PUXNfA1OtqmjyBgCmCGBN2tzY1@thread.tacv2";
                    ConferenceMode                             = $True;
                    DistributionLists                          = @("36c88f29-faba-4f4a-89a7-e5af29e7095e");
                    EnableOverflowSharedVoicemailTranscription = $False;
                    EnableTimeoutSharedVoicemailTranscription  = $False;
                    LanguageId                                 = "fr-CA";
                    HideAuthorizedUsers                        = @("dummy@contoso.com");
                    MusicOnHoldAudioFileId                     = "7d2e9f41-3a6b-4c8d-9e15-0b4a7c3f2d86"
                    Name                                       = "TestQueue";
                    OverflowAction                             = "Forward";
                    OverflowActionTarget                       = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    OverflowThreshold                          = 50;
                    PresenceBasedRouting                       = $True;
                    RoutingMethod                              = "RoundRobin";
                    SharedVoicemailTriageSettingsTemplateId    = "3a4b3d9b-91d8-4fbf-bcff-6907f325842c";
                    TextAnnouncementForCR                      = "FakeStringValue";
                    TextAnnouncementForCRFailure               = "FakeStringValue";
                    TimeoutAction                              = "Forward";
                    TimeoutActionTarget                        = "9abce74d-d108-475f-a2cb-bbb82f484982";
                    TimeoutThreshold                           = 1200;
                    UseDefaultMusicOnHold                      = $False;
                    WelcomeMusicAudioFileId                    = "e8a4c2b6-1d3f-4a7e-8c9b-5f6d0e2a1b47"
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Update the queue from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallQueue' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsCallQueue -Exactly 1 -ParameterFilter { $Identity -eq '5e3a575e-1faa-49ff-83c2-5cf1c36c0e01' }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsCallQueue' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
