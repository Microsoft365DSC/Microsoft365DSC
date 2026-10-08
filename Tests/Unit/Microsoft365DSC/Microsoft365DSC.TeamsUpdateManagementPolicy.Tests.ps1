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
    -DscResource 'TeamsUpdateManagementPolicy' -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        BeforeAll {
            $secpasswd = ConvertTo-SecureString ((New-Guid).ToString()) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)
            $DateTimeValue = [System.DateTime]::Parse("2022-12-08 6:00:00PM")
            $Global:PartialExportFileName = 'c:\TestPath'

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Save-M365DSCPartialExport -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName New-CsTeamsUpdateManagementPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsUpdateManagementPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsUpdateManagementPolicy -MockWith {
            }

            Mock -CommandName Get-CsTeamsUpdateManagementPolicy -MockWith {
                return @{
                    AllowManagedUpdates = $False
                    AllowPreview        = $False
                    AllowPublicPreview  = 'Enabled'
                    Description         = 'Test'
                    Identity            = 'Tag:TestPolicy'
                    UpdateDayOfWeek     = 1
                    UpdateTime          = '18:00'
                    UpdateTimeOfDay     = $DateTimeValue
                    UseNewTeamsClient   = 'MicrosoftChoice'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Update Management Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowManagedUpdates = $False
                    AllowPreview        = $False
                    AllowPublicPreview  = 'Enabled'
                    Description         = 'Test'
                    Identity            = 'Tag:TestPolicy'
                    UpdateDayOfWeek     = 1
                    UpdateTime          = '18:00'
                    UpdateTimeOfDay     = '6:00 PM'
                    UseNewTeamsClient   = 'MicrosoftChoice'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }

                Mock -CommandName Get-CsTeamsUpdateManagementPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsUpdateManagementPolicy -Exactly 1
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowManagedUpdates = $False
                    AllowPreview        = $False
                    AllowPublicPreview  = 'Enabled'
                    Description         = 'Test'
                    Identity            = 'TestPolicy'
                    UpdateDayOfWeek     = 3 # Drift
                    UpdateTime          = '18:00'
                    UpdateTimeOfDay     = '6:00 PM'
                    UseNewTeamsClient   = 'MicrosoftChoice'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsUpdateManagementPolicy -Exactly 1
                Should -Invoke -CommandName New-CsTeamsUpdateManagementPolicy -Exactly 0
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowManagedUpdates = $False
                    AllowPreview        = $False
                    AllowPublicPreview  = 'Enabled'
                    Description         = 'Test'
                    Identity            = 'Tag:TestPolicy'
                    UpdateDayOfWeek     = 1
                    UpdateTime          = '18:00'
                    UpdateTimeOfDay     = '6:00 PM'
                    UseNewTeamsClient   = 'MicrosoftChoice'
                    Ensure              = 'Present'
                    Credential          = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Identity   = 'Tag:TestPolicy'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUpdateManagementPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsUpdateManagementPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsUpdateManagementPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
