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
    -DscResource 'TeamsOnlineVoicemailPolicy' -GenericStubModule $GenericStubPath

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

            Mock -CommandName New-CsOnlineVoicemailPolicy -MockWith {
            }

            Mock -CommandName Set-CsOnlineVoicemailPolicy -MockWith {
            }

            Mock -CommandName Remove-CsOnlineVoicemailPolicy -MockWith {
            }

            Mock -CommandName Get-CsOnlineVoicemailPolicy -MockWith {
                return @{
                    EnableEditingCallAnswerRulesSetting = $True
                    EnableTranscription                 = $True
                    EnableTranscriptionProfanityMasking = $False
                    EnableTranscriptionTranslation      = $True
                    EnableVoicemailTriage               = $False
                    Identity                            = 'TestPolicy'
                    MaximumRecordingLength              = [timespan]'00:10:00'
                    ShareData                           = 'Defer'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }

        # Test contexts
        Context -Name "When the Policy doesn't exist but should" -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                          = $Credential
                    EnableEditingCallAnswerRulesSetting = $True
                    EnableTranscription                 = $True
                    EnableTranscriptionProfanityMasking = $False
                    EnableTranscriptionTranslation      = $True
                    EnableVoicemailTriage               = $False
                    Ensure                              = 'Present'
                    Identity                            = 'TestPolicy'
                    MaximumRecordingLength              = 600
                    ShareData                           = 'Defer'
                }

                Mock -CommandName Get-CsOnlineVoicemailPolicy -MockWith {
                    return $null
                }
            }

            It 'Should return absent from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create the policy in the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-CsOnlineVoicemailPolicy -Exactly 1
                Should -Invoke -CommandName New-CsOnlineVoicemailPolicy -Exactly 1 -ParameterFilter {
                    $MaximumRecordingLength -eq [TimeSpan]::FromSeconds(600)
                }
            }
        }

        Context -Name 'Policy exists but is not in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                          = $Credential
                    EnableEditingCallAnswerRulesSetting = $True
                    EnableTranscription                 = $True
                    EnableTranscriptionProfanityMasking = $False
                    EnableTranscriptionTranslation      = $True
                    EnableVoicemailTriage               = $False
                    Ensure                              = 'Present'
                    Identity                            = 'TestPolicy'
                    MaximumRecordingLength              = 300 # Drift
                    ShareData                           = 'Defer'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should update the settings from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Set-CsOnlineVoicemailPolicy -Exactly 1
                Should -Invoke -CommandName New-CsOnlineVoicemailPolicy -Exactly 0
                Should -Invoke -CommandName Set-CsOnlineVoicemailPolicy -Exactly 1 -ParameterFilter {
                    $MaximumRecordingLength -eq [TimeSpan]::FromSeconds(300)
                }
            }
        }

        Context -Name 'Policy exists and is already in the Desired State' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                          = $Credential
                    EnableEditingCallAnswerRulesSetting = $True
                    EnableTranscription                 = $True
                    EnableTranscriptionProfanityMasking = $False
                    EnableTranscriptionTranslation      = $True
                    EnableVoicemailTriage               = $False
                    Ensure                              = 'Present'
                    Identity                            = 'TestPolicy'
                    MaximumRecordingLength              = 600
                    ShareData                           = 'Defer'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'Policy exists but it should not' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential                          = $Credential
                    EnableEditingCallAnswerRulesSetting = $True
                    EnableTranscription                 = $True
                    EnableTranscriptionProfanityMasking = $False
                    EnableTranscriptionTranslation      = $True
                    EnableVoicemailTriage               = $False
                    Ensure                              = 'Absent'
                    Identity                            = 'TestPolicy'
                    MaximumRecordingLength              = 600
                    ShareData                           = 'Defer'
                }
            }

            It 'Should return Present from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'TeamsOnlineVoicemailPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-CsOnlineVoicemailPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'TeamsOnlineVoicemailPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
