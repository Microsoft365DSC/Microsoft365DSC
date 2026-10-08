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
    -DscResource 'TeamsEmergencyCallingPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName Get-CsTeamsEmergencyCallingPolicy -MockWith {
                return @{
                    Description               = 'Desc'
                    Identity                  = 'TestPolicy'
                    NotificationDialOutNumber = '+1234567890'
                    NotificationGroup         = 'john.smith@contoso.onmicrosoft.com'
                    NotificationMode          = 'NotificationOnly'
                }
            }

            Mock -CommandName New-CsTeamsEmergencyCallingPolicy -MockWith {
            }

            Mock -CommandName Set-CsTeamsEmergencyCallingPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsEmergencyCallingPolicy -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When Meeting Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description               = 'Desc'
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Identity                  = 'TestPolicy'
                    ExtendedNotifications     = @(
                        [MSFT_TeamsEmergencyCallingExtendedNotification] @{
                            EmergencyDialString       = '112'
                            NotificationGroup         = @('security.desk@contoso.com', 'facilities@contoso.com')
                            NotificationDialOutNumber = '+31205550142'
                            NotificationMode          = 'ConferenceMuted'
                        }
                    )
                    NotificationDialOutNumber = '+1234567890'
                    NotificationGroup         = 'john.smith@contoso.onmicrosoft.com'
                    NotificationMode          = 'NotificationOnly'
                }

                Mock -CommandName Get-CsTeamsEmergencyCallingPolicy -MockWith {
                    return $null
                }

                Mock -CommandName New-CsTeamsEmergencyCallingExtendedNotification -MockWith {
                    return [PSCustomObject] @{
                        EmergencyDialString = $EmergencyDialString
                        NotificationGroup   = $NotificationGroup
                    }
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsTeamsEmergencyCallingExtendedNotification -Exactly 1 -ParameterFilter {
                    $EmergencyDialString -eq '112' -and $NotificationGroup -eq 'security.desk@contoso.com;facilities@contoso.com'
                }
                Should -Invoke -CommandName New-CsTeamsEmergencyCallingPolicy -Exactly 1 -ParameterFilter {
                    $ExtendedNotifications.Count -eq 1 -and $ExtendedNotifications[0].EmergencyDialString -eq '112'
                }
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description               = 'Desc'
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Identity                  = 'TestPolicy'
                    NotificationDialOutNumber = '+34565432345'; #drift
                    NotificationGroup         = 'john.smith@contoso.onmicrosoft.com'
                    NotificationMode          = 'NotificationOnly'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsTeamsEmergencyCallingPolicy -Exactly 1
                Should -Invoke -CommandName New-CsTeamsEmergencyCallingPolicy -Exactly 0
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description               = 'Desc'
                    Ensure                    = 'Present'
                    Credential                = $Credential
                    Identity                  = 'TestPolicy'
                    NotificationDialOutNumber = '+1234567890'
                    NotificationGroup         = 'john.smith@contoso.onmicrosoft.com'
                    NotificationMode          = 'NotificationOnly'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description               = 'Desc'
                    Ensure                    = 'Absent'
                    Credential                = $Credential
                    Identity                  = 'TestPolicy'
                    NotificationDialOutNumber = '+1234567890'
                    NotificationGroup         = 'john.smith@contoso.onmicrosoft.com'
                    NotificationMode          = 'NotificationOnly'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsTeamsEmergencyCallingPolicy -Exactly 1
            }
        }

        Context -Name 'When the No Optional Parameters are Specified' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                    Identity   = 'TestPolicy'
                }
            }

            It 'Should throw an error from the Set method' {
                { (New-M365DSCResourceInstance -ResourceName 'TeamsEmergencyCallingPolicy' -Property $testParams).Set() } | Should -Throw
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsEmergencyCallingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
