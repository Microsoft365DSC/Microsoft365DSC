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
    -DscResource 'TeamsChannel' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Remove-TeamChannel -MockWith {
                return $null
            }

            Mock -CommandName Set-TeamChannel -MockWith {
            }

            Mock -CommandName New-TeamChannel -MockWith {
                return @{
                    GroupID = $null
                }
            }

            Mock -CommandName Get-TeamChannel -MockWith {
                return @{
                    GroupID     = '12345-12345-12345-12345-12345'
                    DisplayName = 'Test Channel'
                }
            }

            Mock -CommandName Get-Team -MockWith {
                return @{
                    DisplayName = 'TestTeam'
                    GroupID     = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Get-TeamByName -MockWith {
                return @{
                    DisplayName = 'TestTeam'
                    GroupID     = '12345-12345-12345-12345-12345'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When a channel doesn't exist" -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName    = 'TestTeam'
                    DisplayName = 'Test Channel'
                    Description = 'Test description'
                    Credential  = $Credential
                }

                Mock -CommandName Get-TeamChannel -MockWith {
                    return @{
                        DisplayName = 'Other Channel'
                        GroupID     = '12345-12345-12345-12345-12345'
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Creates the MS Team channel in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Set()
            }
        }

        Context -Name 'Channel already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName    = 'TestTeam'
                    DisplayName = 'Test Channel'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Rename existing channel' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName       = 'TestTeam'
                    DisplayName    = 'Test Channel'
                    Ensure         = 'Present'
                    NewDisplayName = 'Test Channel Updated'
                    Credential     = $Credential
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Renames existing channel in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Set()
                Should -Invoke -CommandName Set-TeamChannel -Exactly 1 -ParameterFilter {
                    $CurrentDisplayName -eq 'Test Channel' -and $NewDisplayName -eq 'Test Channel Updated'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Description of existing channel is not in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName    = 'TestTeam'
                    DisplayName = 'Test Channel'
                    Description = 'Updated description'
                    Ensure      = 'Present'
                    Credential  = $Credential
                }
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Test() | Should -Be $false
            }

            It 'Updates the description in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Set()
                Should -Invoke -CommandName Set-TeamChannel -Exactly 1 -ParameterFilter {
                    $CurrentDisplayName -eq 'Test Channel' -and $Description -eq 'Updated description'
                }
                Should -Invoke -CommandName New-TeamChannel -Exactly 0
            }
        }

        Context -Name 'Remove existing channel' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName    = 'TestTeam'
                    DisplayName = 'Test Channel'
                    Ensure      = 'Absent'
                    Credential  = $Credential
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Remove channel in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsChannel' -Property $testParams).Set()
                Should -Invoke -CommandName Set-TeamChannel -Exactly 1 -ParameterFilter {
                    $CurrentDisplayName -eq 'Test Channel' -and $NewDisplayName -like 'Deleted-*'
                }
                Should -Invoke -CommandName Remove-TeamChannel -Exactly 1 -ParameterFilter {
                    $DisplayName -like 'Deleted-*'
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsChannel' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
