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
    -DscResource 'TeamsUpgradeConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsUpgradeConfiguration -MockWith {
                return @{
                    DownloadTeams    = $True
                    SfBMeetingJoinUx = 'NativeLimitedClient'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'When Settings are already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DownloadTeams    = $True
                    Credential       = $Credential
                    IsSingleInstance = 'Yes'
                    SfBMeetingJoinUx = 'NativeLimitedClient'
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Get().ToHashtable()).DownloadTeams | Should -Be $true
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Get().ToHashtable()).SfbMeetingJoinUx | Should -Be 'NativeLimitedClient'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'When Settings are NOT in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    DownloadTeams    = $False # Drift
                    Credential       = $Credential
                    IsSingleInstance = 'Yes'
                    SfBMeetingJoinUx = 'NativeLimitedClient'
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Get().ToHashtable()).DownloadTeams | Should -Be $true
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Get().ToHashtable()).SfbMeetingJoinUx | Should -Be 'NativeLimitedClient'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpgradeConfiguration' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsUpgradeConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
