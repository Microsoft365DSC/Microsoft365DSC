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
    -DscResource 'TeamsUserPolicyAssignment' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-MgUser -MockWith {
                return @(
                    @{
                        UserPrincipalName = 'john.smith@contoso.com'
                    }
                )
            }

            Mock -CommandName Grant-CsCallingLineIdentity -MockWith {
            }
            Mock -CommandName Grant-CsExternalAccessPolicy -MockWith {
            }
            Mock -CommandName Grant-CsOnlineVoicemailPolicy -MockWith {
            }
            Mock -CommandName Grant-CsOnlineVoiceRoutingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsAppPermissionPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsAppSetupPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsAudioConferencingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsCallHoldPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsCallingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsCallParkPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsChannelsPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsEmergencyCallingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsEmergencyCallRoutingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsEnhancedEncryptionPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsEventsPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsMeetingBroadcastPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsMeetingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsMessagingPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsMobilityPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsPersonalAttendantPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsUpdateManagementPolicy -MockWith {
            }
            Mock -CommandName Grant-CsTeamsUpgradePolicy -MockWith {
            }
            Mock -CommandName Grant-CsTenantDialPlan -MockWith {
            }

            Mock -CommandName  Get-CsUserPolicyAssignment -MockWith {
                    return @(
                        @{
                            PolicyType = "CallingLineIdentity"
                            PolicyName = "Test"
                        },
                        @{
                            PolicyType = "ExternalAccessPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "OnlineVoicemailPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "OnlineVoiceRoutingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsAppPermissionPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsAppSetupPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsAudioConferencingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsCallHoldPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsCallingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsCallParkPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsChannelsPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsEmergencyCallingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsEmergencyCallRoutingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsEnhancedEncryptionPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsEventsPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsMeetingBroadcastPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsMeetingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsMessagingPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsMobilityPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsPersonalAttendantPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsUpdateManagementPolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TeamsUpgradePolicy"
                            PolicyName = "Test";
                        },
                        @{
                            PolicyType = "TenantDialPlan"
                            PolicyName = "Test";
                        }
                    )
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Policy assignments are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                      = $Credential
                    CallingLineIdentity             = "Test";
                    ExternalAccessPolicy            = "Test";
                    OnlineVoicemailPolicy           = "Test";
                    OnlineVoiceRoutingPolicy        = "Test";
                    TeamsAppPermissionPolicy        = "Test";
                    TeamsAppSetupPolicy             = "Test";
                    TeamsAudioConferencingPolicy    = "Test";
                    TeamsCallHoldPolicy             = "Test";
                    TeamsCallingPolicy              = "Test";
                    TeamsCallParkPolicy             = "Test";
                    TeamsChannelsPolicy             = "Test";
                    TeamsEmergencyCallingPolicy     = "Test";
                    TeamsEmergencyCallRoutingPolicy = "Test";
                    TeamsEnhancedEncryptionPolicy   = "Test";
                    TeamsEventsPolicy               = "Test";
                    TeamsMeetingBroadcastPolicy     = "Test";
                    TeamsMeetingPolicy              = "Test";
                    TeamsMessagingPolicy            = "Test";
                    TeamsMobilityPolicy             = "Test";
                    TeamsPersonalAttendantPolicy    = "Test";
                    TeamsUpdateManagementPolicy     = "Test";
                    TeamsUpgradePolicy              = "Test";
                    TenantDialPlan                  = "Test";
                    User                            = "john.smith@contoso.com";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserPolicyAssignment' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return Global without assignments and nothing for a missing user from the Get method' {
                Mock -CommandName Get-CsUserPolicyAssignment -MockWith {
                }
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserPolicyAssignment' -Property $testParams).Get().ToHashtable().TeamsPersonalAttendantPolicy | Should -Be 'Global'

                Mock -CommandName Get-CsUserPolicyAssignment -MockWith {
                    Write-Error -Message 'User does not exist'
                }
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserPolicyAssignment' -Property $testParams).Get().ToHashtable().User | Should -BeNullOrEmpty
            }
        }

        Context -Name 'Policy assignemnts exists but are not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                      = $Credential
                    CallingLineIdentity             = "Test";
                    ExternalAccessPolicy            = "Test";
                    OnlineVoicemailPolicy           = "Test";
                    OnlineVoiceRoutingPolicy        = "Drift";
                    TeamsAppPermissionPolicy        = "Test";
                    TeamsAppSetupPolicy             = "Test";
                    TeamsAudioConferencingPolicy    = "Test";
                    TeamsCallHoldPolicy             = "Test";
                    TeamsCallingPolicy              = "Test";
                    TeamsCallParkPolicy             = "Test";
                    TeamsChannelsPolicy             = "Test";
                    TeamsEmergencyCallingPolicy     = "Test";
                    TeamsEmergencyCallRoutingPolicy = "Test";
                    TeamsEnhancedEncryptionPolicy   = "Test";
                    TeamsEventsPolicy               = "Test";
                    TeamsMeetingBroadcastPolicy     = "Test";
                    TeamsMeetingPolicy              = "Test";
                    TeamsMessagingPolicy            = "Test";
                    TeamsMobilityPolicy             = "Test";
                    TeamsPersonalAttendantPolicy    = "Test";
                    TeamsUpdateManagementPolicy     = "Test";
                    TeamsUpgradePolicy              = "Test";
                    TenantDialPlan                  = "DemTestPlan";
                    User                            = "john.smith@contoso.com";
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserPolicyAssignment' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUserPolicyAssignment' -Property $testParams).Set()
                Should -Invoke -CommandName Grant-CsOnlineVoiceRoutingPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsUserPolicyAssignment' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
