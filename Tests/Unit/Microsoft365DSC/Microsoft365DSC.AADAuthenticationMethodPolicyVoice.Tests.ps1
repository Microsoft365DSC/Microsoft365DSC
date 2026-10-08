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
    -DscResource "AADAuthenticationMethodPolicyVoice" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                return @{
                    IncludeTargets        = @(
                        @{
                            TargetType = 'group'
                            Id         = '00000000-0000-0000-0000-000000000000'
                        }
                    )
                    '@odata.type' = "#microsoft.graph.voiceAuthenticationMethodConfiguration"
                    callerIdNumber = "+14255551234"
                    isOfficePhoneAllowed = $True
                    ExcludeTargets = @(
                        @{
                            TargetType = "group"
                            Id = "00000000-0000-0000-0000-000000000000"
                        }
                    )
                    Id = "Voice"
                    State = "enabled"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Get-MgGroup -ModuleName M365DSCUtil -MockWith {
                return @{
                    Id = "00000000-0000-0000-0000-000000000000"
                    DisplayName = "Fakegroup"
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADAuthenticationMethodPolicyVoice should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Voice"
                    CallerIdNumber = "+14255551234"
                    IsOfficePhoneAllowed = $True
                    State = "enabled"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyVoice exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceExcludeTarget] @{
                            TargetType = "group"
                            Id = "FakeStringValue"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Voice"
                    CallerIdNumber = "+14255551234"
                    IsOfficePhoneAllowed = $True
                    State = "enabled"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }
        Context -Name "The AADAuthenticationMethodPolicyVoice Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Voice"
                    CallerIdNumber = "+14255551234"
                    IsOfficePhoneAllowed = $True
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyVoice exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyVoiceIncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Voice"
                    CallerIdNumber = "+14255551234"
                    IsOfficePhoneAllowed = $false # Drift
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyVoice' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthenticationMethodPolicyVoice' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
