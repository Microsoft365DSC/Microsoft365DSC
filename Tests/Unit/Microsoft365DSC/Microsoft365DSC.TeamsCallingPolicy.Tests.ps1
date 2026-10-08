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
    -DscResource 'TeamsCallingPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsCallingPolicy -MockWith {
                return @{
                    Identity                                   = 'Test Calling Policy'
                    AllowPrivateCalling                        = $false
                    AllowVoicemail                             = 'UserOverride'
                    AllowCallGroups                            = $true
                    AllowDelegation                            = $true
                    AllowCallForwardingToUser                  = $false
                    AllowCallForwardingToPhone                 = $true
                    PreventTollBypass                          = $true
                    BusyOnBusyEnabledType                      = 'Enabled'
                    ReportCall                                 = 'Enabled'
                    AllowMeetingKnowledgeGeneration            = $true
                    PreventComplianceRecording                 = 'None'
                    RecordingAndTranscriptionAudioNotification = 'Disabled'
                    VoicePhishingDetection                     = 'BannerAndAudio'
                }
            }

            Mock -CommandName New-CsTeamsCallingPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsCallingPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsCallingPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Calling Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                   = 'Test Calling Policy'
                    AllowPrivateCalling                        = $false
                    AllowVoicemail                             = 'UserOverride'
                    AllowCallGroups                            = $true
                    AllowDelegation                            = $true
                    AllowCallForwardingToUser                  = $false
                    AllowCallForwardingToPhone                 = $true
                    PreventTollBypass                          = $true
                    BusyOnBusyEnabledType                      = 'Enabled'
                    ReportCall                                 = 'Enabled'
                    AllowMeetingKnowledgeGeneration            = $true
                    PreventComplianceRecording                 = 'None'
                    RecordingAndTranscriptionAudioNotification = 'Disabled'
                    VoicePhishingDetection                     = 'BannerAndAudio'
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }

                Mock -CommandName Get-CsTeamsCallingPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsCallingPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                   = 'Test Calling Policy'
                    AllowPrivateCalling                        = $false
                    AllowVoicemail                             = 'UserOverride'
                    AllowCallGroups                            = $true
                    AllowDelegation                            = $true
                    AllowCallForwardingToUser                  = $false
                    AllowCallForwardingToPhone                 = $true
                    PreventTollBypass                          = $true
                    BusyOnBusyEnabledType                      = 'Disabled' # Drift
                    ReportCall                                 = 'Enabled'
                    AllowMeetingKnowledgeGeneration            = $true
                    PreventComplianceRecording                 = 'None'
                    RecordingAndTranscriptionAudioNotification = 'Disabled'
                    VoicePhishingDetection                     = 'BannerAndAudio'
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsCallingPolicy -Exactly 1
            }

            It 'Should only declare properties that New-CsTeamsCallingPolicy and Set-CsTeamsCallingPolicy accept' {
                $nonCmdletProperties = @('Ensure', 'Credential', 'ApplicationId', 'TenantId', 'CertificateThumbprint', 'CertificatePassword', 'CertificatePath', 'ManagedIdentity', 'AccessTokens')
                $resourceProperties = (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy').GetType().GetProperties() |
                    Where-Object -FilterScript { $_.IsDefined([System.Management.Automation.DscPropertyAttribute], $true) -and $_.Name -notin $nonCmdletProperties }
                foreach ($cmdletName in @('New-CsTeamsCallingPolicy', 'Set-CsTeamsCallingPolicy'))
                {
                    (@($resourceProperties.Name | Where-Object -FilterScript { $_ -notin (Get-Command -Name $cmdletName).Parameters.Keys }) -join ', ') | Should -BeNullOrEmpty -Because "$cmdletName must accept every resource property"
                }
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                   = 'Test Calling Policy'
                    AllowPrivateCalling                        = $false
                    AllowVoicemail                             = 'UserOverride'
                    AllowCallGroups                            = $true
                    AllowDelegation                            = $true
                    AllowCallForwardingToUser                  = $false
                    AllowCallForwardingToPhone                 = $true
                    PreventTollBypass                          = $true
                    BusyOnBusyEnabledType                      = 'Enabled'
                    ReportCall                                 = 'Enabled'
                    AllowMeetingKnowledgeGeneration            = $true
                    PreventComplianceRecording                 = 'None'
                    RecordingAndTranscriptionAudioNotification = 'Disabled'
                    VoicePhishingDetection                     = 'BannerAndAudio'
                    Ensure                                     = 'Present'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                   = 'Test Calling Policy'
                    AllowPrivateCalling                        = $false
                    AllowVoicemail                             = 'UserOverride'
                    AllowCallGroups                            = $true
                    AllowDelegation                            = $true
                    AllowCallForwardingToUser                  = $false
                    AllowCallForwardingToPhone                 = $true
                    PreventTollBypass                          = $true
                    BusyOnBusyEnabledType                      = 'Enabled'
                    ReportCall                                 = 'Enabled'
                    AllowMeetingKnowledgeGeneration            = $true
                    PreventComplianceRecording                 = 'None'
                    RecordingAndTranscriptionAudioNotification = 'Disabled'
                    VoicePhishingDetection                     = 'BannerAndAudio'
                    Ensure                                     = 'Absent'
                    Credential                                 = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Shouldremove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsCallingPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsCallingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
