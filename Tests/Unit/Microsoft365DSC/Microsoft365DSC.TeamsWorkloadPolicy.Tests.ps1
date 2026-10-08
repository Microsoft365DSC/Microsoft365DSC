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
    -DscResource 'TeamsWorkloadPolicy' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-CsTeamsWorkloadPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsWorkloadPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsWorkloadPolicy -MockWith {
            }

            Mock -CommandName Get-CsTeamsWorkloadPolicy -MockWith {
                return @{
                    AllowMessagingPinned = $True
                    Description          = 'FakeStringValue'
                    AllowCalling         = $True
                    AllowCallingPinned   = $True
                    AllowMessaging       = $True
                    Identity             = 'FakeStringValue'
                    AllowMeeting         = $True
                    AllowMeetingPinned   = $True
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name 'The TeamsWorkloadPolicy should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{AllowCalling = $True
                    AllowCallingPinned       = $True
                    AllowMeeting             = $True
                    AllowMeetingPinned       = $True
                    AllowMessaging           = $True
                    AllowMessagingPinned     = $True
                    Identity                 = 'test'
                    Ensure                   = 'Present'
                    Credential               = $Credential
                }

                Mock -CommandName Get-CsTeamsWorkloadPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsWorkloadPolicy -Exactly 1
            }
        }

        Context -Name 'The TeamsWorkloadPolicy exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCalling         = $True
                    AllowCallingPinned   = $True
                    AllowMeeting         = $True
                    AllowMeetingPinned   = $True
                    AllowMessaging       = $True
                    AllowMessagingPinned = $True
                    Identity             = 'FakeStringValue'
                    Ensure               = 'Absent'
                    Credential           = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsWorkloadPolicy -Exactly 1
            }
        }

        Context -Name 'The TeamsWorkloadPolicy Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCalling         = $True
                    AllowCallingPinned   = $True
                    AllowMeeting         = $True
                    AllowMeetingPinned   = $True
                    AllowMessaging       = $True
                    AllowMessagingPinned = $True
                    Identity             = 'FakeStringValue'
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The TeamsWorkloadPolicy exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCalling         = $False # Drift
                    AllowCallingPinned   = $True
                    AllowMeeting         = $True
                    AllowMeetingPinned   = $True
                    AllowMessaging       = $True
                    AllowMessagingPinned = $True
                    Identity             = 'FakeStringValue'
                    Ensure               = 'Present'
                    Credential           = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsWorkloadPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsWorkloadPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsWorkloadPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
