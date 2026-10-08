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
    -DscResource 'TeamsFederationConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTenantFederationConfiguration -MockWith {
                return @{
                    AllowFederatedUsers                                 = $True
                    AllowTeamsConsumer                                  = $False
                    AllowTeamsConsumerInbound                           = $False
                    AllowedTrialTenantDomains                           = @([PSCustomObject]@{ Domain = 'northwindtraders.onmicrosoft.com' })
                    BlockAllSubdomains                                  = $False
                    EnableExternalAccessRestrictionsForChatParticipants = $False
                    EnableMutualFederationForChatParticipants           = $False
                    Identity                                            = 'Global'
                    SecurityTeamAllowBlockListDelegation                = 'Disabled'
                }
            }

            Mock -CommandName Set-CsTenantFederationConfiguration -MockWith {
            }

            Mock -CommandName  New-CsEdgeAllowAllKnownDomains -MockWith {
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
                    AllowFederatedUsers                                 = $True
                    AllowTeamsConsumer                                  = $False
                    AllowTeamsConsumerInbound                           = $False
                    AllowedTrialTenantDomains                           = @('northwindtraders.onmicrosoft.com')
                    BlockAllSubdomains                                  = $False
                    EnableExternalAccessRestrictionsForChatParticipants = $False
                    EnableMutualFederationForChatParticipants           = $False
                    SecurityTeamAllowBlockListDelegation                = 'Disabled'
                    IsSingleInstance                                    = 'Yes'
                    Credential                                          = $Credential
                }
            }

            It 'Should return False for the AllowTeamsConsumer property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsFederationConfiguration' -Property $testParams).Get().ToHashtable()).AllowTeamsConsumer | Should -Be $false
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsFederationConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowFederatedUsers                                 = $True
                    AllowTeamsConsumer                                  = $True
                    AllowTeamsConsumerInbound                           = $True
                    AllowedTrialTenantDomains                           = @()
                    BlockAllSubdomains                                  = $False
                    EnableExternalAccessRestrictionsForChatParticipants = $True
                    EnableMutualFederationForChatParticipants           = $True
                    SecurityTeamAllowBlockListDelegation                = 'Enabled'
                    IsSingleInstance                                    = 'Yes'
                    Credential                                          = $Credential
                }
            }

            It 'Should return False for the AllowTeamsConsumer property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsFederationConfiguration' -Property $testParams).Get().ToHashtable()).AllowTeamsConsumer | Should -Be $false
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsFederationConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the Teams Federations settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsFederationConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTenantFederationConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsFederationConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
