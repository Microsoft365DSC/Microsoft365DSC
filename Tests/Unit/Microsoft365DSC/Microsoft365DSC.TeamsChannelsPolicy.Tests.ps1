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
    -DscResource 'TeamsChannelsPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsChannelsPolicy -MockWith {
                return @{
                    Identity                                      = 'Test Channels Policy'
                    Description                                   = 'Test Description'
                    AllowChannelSharingToExternalUser             = $True
                    AllowOrgWideTeamCreation                      = $True
                    AllowPrivateChannelCreation                   = $True
                    EnablePrivateTeamDiscovery                    = $True
                    AllowSharedChannelCreation                    = $True
                    AllowUserToParticipateInExternalSharedChannel = $True
                    AllowCreateChannel                            = 'Enabled'
                    AllowCreateClassicChannel                     = 'Enabled'
                    AllowCreatePrivateChannel                     = 'Enabled'
                    AllowCreateSharedChannel                      = 'Enabled'
                    CreateSharedChannelsByDefault                 = 'Disabled'
                    AllowUsersFromOutsideTeam                     = 'Enabled'
                    AllowGuestsFromOutsideTeam                    = 'Disabled'
                    AllowUsersFromOutsideTeamInPrivateChannel     = 'Enabled'
                    AllowGuestsFromOutsideTeamInPrivateChannel    = 'Disabled'
                    AllowSharingWithTeamInOrg                     = 'Enabled'
                    AllowSharingPrivateChannelWithTeamInOrg       = 'Unset'
                    DefaultChannelTypeOnCreation                  = 'Standard'
                }
            }

            Mock -CommandName New-CsTeamsChannelsPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsChannelsPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsChannelsPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Channel Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                      = 'Test Channels Policy'
                    Description                                   = 'Test Description'
                    AllowChannelSharingToExternalUser             = $True
                    AllowOrgWideTeamCreation                      = $True
                    AllowPrivateChannelCreation                   = $True
                    EnablePrivateTeamDiscovery                    = $True
                    AllowSharedChannelCreation                    = $True
                    AllowUserToParticipateInExternalSharedChannel = $True
                    AllowCreateChannel                            = 'Enabled'
                    AllowCreateClassicChannel                     = 'Enabled'
                    AllowCreatePrivateChannel                     = 'Enabled'
                    AllowCreateSharedChannel                      = 'Enabled'
                    CreateSharedChannelsByDefault                 = 'Disabled'
                    AllowUsersFromOutsideTeam                     = 'Enabled'
                    AllowGuestsFromOutsideTeam                    = 'Disabled'
                    AllowUsersFromOutsideTeamInPrivateChannel     = 'Enabled'
                    AllowGuestsFromOutsideTeamInPrivateChannel    = 'Disabled'
                    AllowSharingWithTeamInOrg                     = 'Enabled'
                    AllowSharingPrivateChannelWithTeamInOrg       = 'Unset'
                    DefaultChannelTypeOnCreation                  = 'Standard'
                    Ensure                                        = 'Present'
                    Credential                                    = $Credential
                }

                Mock -CommandName Get-CsTeamsChannelsPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsChannelsPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                      = 'Test Channels Policy'
                    Description                                   = 'Test Description'
                    AllowChannelSharingToExternalUser             = $True
                    AllowOrgWideTeamCreation                      = $True
                    AllowPrivateChannelCreation                   = $True
                    EnablePrivateTeamDiscovery                    = $False # Drift
                    AllowSharedChannelCreation                    = $True
                    AllowUserToParticipateInExternalSharedChannel = $True
                    AllowCreateChannel                            = 'Enabled'
                    AllowCreateClassicChannel                     = 'Enabled'
                    AllowCreatePrivateChannel                     = 'Enabled'
                    AllowCreateSharedChannel                      = 'Enabled'
                    CreateSharedChannelsByDefault                 = 'Disabled'
                    AllowUsersFromOutsideTeam                     = 'Enabled'
                    AllowGuestsFromOutsideTeam                    = 'Disabled'
                    AllowUsersFromOutsideTeamInPrivateChannel     = 'Enabled'
                    AllowGuestsFromOutsideTeamInPrivateChannel    = 'Disabled'
                    AllowSharingWithTeamInOrg                     = 'Enabled'
                    AllowSharingPrivateChannelWithTeamInOrg       = 'Unset'
                    DefaultChannelTypeOnCreation                  = 'Standard'
                    Ensure                                        = 'Present'
                    Credential                                    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsChannelsPolicy -Exactly 1
                Should -Invoke -CommandName New-CSTeamsChannelsPolicy -Exactly 0
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                      = 'Test Channels Policy'
                    Description                                   = 'Test Description'
                    AllowChannelSharingToExternalUser             = $True
                    AllowOrgWideTeamCreation                      = $True
                    AllowPrivateChannelCreation                   = $True
                    EnablePrivateTeamDiscovery                    = $True
                    AllowSharedChannelCreation                    = $True
                    AllowUserToParticipateInExternalSharedChannel = $True
                    AllowCreateChannel                            = 'Enabled'
                    AllowCreateClassicChannel                     = 'Enabled'
                    AllowCreatePrivateChannel                     = 'Enabled'
                    AllowCreateSharedChannel                      = 'Enabled'
                    CreateSharedChannelsByDefault                 = 'Disabled'
                    AllowUsersFromOutsideTeam                     = 'Enabled'
                    AllowGuestsFromOutsideTeam                    = 'Disabled'
                    AllowUsersFromOutsideTeamInPrivateChannel     = 'Enabled'
                    AllowGuestsFromOutsideTeamInPrivateChannel    = 'Disabled'
                    AllowSharingWithTeamInOrg                     = 'Enabled'
                    AllowSharingPrivateChannelWithTeamInOrg       = 'Unset'
                    DefaultChannelTypeOnCreation                  = 'Standard'
                    Ensure                                        = 'Present'
                    Credential                                    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity                                      = 'Test Channels Policy'
                    Description                                   = 'Test Description'
                    AllowChannelSharingToExternalUser             = $True
                    AllowOrgWideTeamCreation                      = $True
                    AllowPrivateChannelCreation                   = $True
                    EnablePrivateTeamDiscovery                     = $True
                    AllowSharedChannelCreation                    = $True
                    AllowUserToParticipateInExternalSharedChannel = $True
                    AllowCreateChannel                            = 'Enabled'
                    AllowCreateClassicChannel                     = 'Enabled'
                    AllowCreatePrivateChannel                     = 'Enabled'
                    AllowCreateSharedChannel                      = 'Enabled'
                    CreateSharedChannelsByDefault                 = 'Disabled'
                    AllowUsersFromOutsideTeam                     = 'Enabled'
                    AllowGuestsFromOutsideTeam                    = 'Disabled'
                    AllowUsersFromOutsideTeamInPrivateChannel     = 'Enabled'
                    AllowGuestsFromOutsideTeamInPrivateChannel    = 'Disabled'
                    AllowSharingWithTeamInOrg                     = 'Enabled'
                    AllowSharingPrivateChannelWithTeamInOrg       = 'Unset'
                    DefaultChannelTypeOnCreation                  = 'Standard'
                    Ensure                                        = 'Absent'
                    Credential                                    = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannelsPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsChannelsPolicy -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsChannelsPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
