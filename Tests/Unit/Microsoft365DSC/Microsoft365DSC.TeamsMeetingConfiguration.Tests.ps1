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
    -DscResource 'TeamsMeetingConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsMeetingConfiguration -MockWith {
                return @{
                    ClientAppSharingPort                 = 50040
                    ClientAppSharingPortRange            = 20
                    ClientAudioPort                      = 50000
                    ClientAudioPortRange                 = 20
                    ClientMediaPortRangeEnabled          = $True
                    ClientVideoPort                      = 50020
                    ClientVideoPortRange                 = 20
                    CustomFooterText                     = $null
                    DisableAnonymousJoin                 = $False
                    EnableAttributedTranscripts          = $False
                    EnableGraphTranscriptAccess          = $False
                    EnableQoS                            = $False
                    HelpURL                              = $null
                    Identity                             = 'Global'
                    LegalURL                             = $null
                    LogoURL                              = $null
                    PublishedEntraAuthenticationContexts = @(
                        @{
                            Id                   = 'c3'
                            PublishedName        = 'Confidential meetings'
                            PublishedDescription = 'Requires step-up authentication to join confidential meetings'
                            EntraName            = 'Confidential access'
                            EntraDescription     = 'Step-up authentication for confidential resources'
                            Published            = $True
                        }
                    )
                    ReportMeeting                        = 'Enabled'
                }
            }

            Mock -CommandName Set-CsTeamsMeetingConfiguration -MockWith {
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
                    ClientAppSharingPort                 = 50040
                    ClientAppSharingPortRange            = 20
                    ClientAudioPort                      = 50000
                    ClientAudioPortRange                 = 20
                    ClientMediaPortRangeEnabled          = $True
                    ClientVideoPort                      = 50020
                    ClientVideoPortRange                 = 20
                    CustomFooterText                     = $null
                    DisableAnonymousJoin                 = $False
                    EnableAttributedTranscripts          = $False
                    EnableGraphTranscriptAccess          = $False
                    EnableQoS                            = $False
                    Credential                           = $Credential
                    HelpURL                              = $null
                    IsSingleInstance                     = 'Yes'
                    LegalURL                             = $null
                    LogoURL                              = $null
                    PublishedEntraAuthenticationContexts = @(
                        [MSFT_TeamsPublishedEntraAuthenticationContext] @{
                            Id                   = 'c3'
                            PublishedName        = 'Confidential meetings'
                            PublishedDescription = 'Requires step-up authentication to join confidential meetings'
                        }
                    )
                    ReportMeeting                        = 'Enabled'
                }
            }

            It 'Should return 20 for the ClientVideoPortRange property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingConfiguration' -Property $testParams).Get().ToHashtable()).ClientVideoPortRange | Should -Be 20
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    ClientAppSharingPort                 = 50040
                    ClientAppSharingPortRange            = 20
                    ClientAudioPort                      = 50000
                    ClientAudioPortRange                 = 20
                    ClientMediaPortRangeEnabled          = $True
                    ClientVideoPort                      = 50020
                    ClientVideoPortRange                 = 21; # Drift
                    CustomFooterText                     = $null
                    DisableAnonymousJoin                 = $False
                    EnableAttributedTranscripts          = $False
                    EnableGraphTranscriptAccess          = $False
                    EnableQoS                            = $False
                    Credential                           = $Credential
                    HelpURL                              = $null
                    IsSingleInstance                     = 'Yes'
                    LegalURL                             = $null
                    LogoURL                              = $null
                    PublishedEntraAuthenticationContexts = @()
                    ReportMeeting                        = 'Enabled'
                }
            }

            It 'Should return 20 for the ClientVideoPortRange property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsMeetingConfiguration' -Property $testParams).Get().ToHashtable()).ClientVideoPortRange | Should -Be 20
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the Teams Client settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsMeetingConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsMeetingConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsMeetingConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
