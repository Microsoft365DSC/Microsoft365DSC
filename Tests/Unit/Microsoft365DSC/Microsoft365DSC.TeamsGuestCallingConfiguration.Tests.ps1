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
    -DscResource 'TeamsGuestCallingConfiguration' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsGuestCallingConfiguration -MockWith {
                return @{
                    Identity            = 'Global'
                    AllowPrivateCalling = $False
                }
            }

            Mock -CommandName Set-CsTeamsGuestCallingConfiguration -MockWith {
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
                    IsSingleInstance    = 'Yes'
                    AllowPrivateCalling = $False
                    Credential          = $Credential
                }
            }

            It 'Should return False for the AllowPrivateCalling property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Get().ToHashtable()).AllowPrivateCalling | Should -Be $False
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Test() | Should -Be $true
            }

            It 'Updates the settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsGuestCallingConfiguration -Exactly 0
            }
        }

        Context -Name 'When settings are NOT correctly set' -Fixture {
            BeforeAll {
                $testParams = @{
                    IsSingleInstance    = 'Yes'
                    AllowPrivateCalling = $True
                    Credential          = $Credential
                }
            }

            It 'Should return False for the AllowBox property from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Get().ToHashtable()).AllowPrivateCalling | Should -Be $False
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the Teams Client settings in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsGuestCallingConfiguration' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsGuestCallingConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsGuestCallingConfiguration' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
