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
    -DscResource 'TeamsUser' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Add-TeamUser -MockWith {
                return $null
            }

            Mock -CommandName Remove-TeamUser -MockWith {
                return $null
            }

            Mock -CommandName Get-TeamUser -MockWith {
                return @{
                    GroupID = '12345-12345-12345-12345-12345'
                    Role    = 'Member'
                    User    = 'JohnSmith@contoso.onmicrosoft.com'
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
        Context -Name 'When the Team user does not exist' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName   = 'TestTeam'
                    Role       = 'Member'
                    User       = 'JohnSmith@contoso.onmicrosoft.com'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-TeamUser -MockWith {
                    return @{
                        GroupID = '12345-12345-12345-12345-12345'
                        Role    = 'Member'
                        User    = 'AdeleV@contoso.onmicrosoft.com'
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Test() | Should -Be $false
            }

            It 'Adds user to MS Team in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Set()
                Should -Invoke -CommandName Add-TeamUser -Exactly 1
            }
        }

        Context -Name 'The user already exists' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName   = 'TestTeam'
                    User       = 'JohnSmith@contoso.onmicrosoft.com'
                    Role       = 'Member'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-TeamUser -MockWith {
                    return @{
                        GroupID = '12345-12345-12345-12345-12345'
                        Role    = 'Owner'
                        User    = 'JohnSmith@contoso.onmicrosoft.com'
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the owner role in set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-TeamUser -Exactly 1 -ParameterFilter { $Role -eq 'Owner' }
                Should -Invoke -CommandName Add-TeamUser -Exactly 0
            }
        }

        Context -Name 'Failed to get team' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName   = 'TestTeam'
                    User       = 'JohnSmith@contoso.onmicrosoft.com'
                    Role       = 'Owner'
                    Ensure     = 'Present'
                    Credential = $Credential
                }

                Mock -CommandName Get-TeamUser -MockWith {
                    return $null
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Test() | Should -Be $false
            }
        }

        Context -Name 'Remove existing user from team' -Fixture {
            BeforeAll {
                $testParams = @{
                    TeamName   = 'TestTeam'
                    User       = 'JohnSmith@contoso.onmicrosoft.com'
                    Role       = 'Member'
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                Mock -CommandName Get-TeamUser -MockWith {
                    return @{
                        GroupID = '12345-12345-12345-12345-12345'
                        Role    = 'Owner'
                        User    = 'JohnSmith@contoso.onmicrosoft.com'
                    }
                }
            }

            It 'Should return present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should remove user from Team in set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsUser' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-TeamUser -Exactly 1 -ParameterFilter { $null -eq $Role }
                Should -Invoke -CommandName Remove-TeamUser -Exactly 0 -ParameterFilter { $Role -eq 'Owner' }
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-Team -MockWith {
                    return @(
                        @{
                            DisplayName = 'TestTeam'
                            GroupID     = '12345-12345-12345-12345-12345'
                        }
                    )
                }
            }

            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsUser' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
