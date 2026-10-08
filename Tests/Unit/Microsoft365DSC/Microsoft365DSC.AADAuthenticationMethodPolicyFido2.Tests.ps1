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
    -DscResource "AADAuthenticationMethodPolicyFido2" -GenericStubModule $GenericStubPath
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
                            Id         = 'Fakegroup'
                        }
                    )
                    isAttestationEnforced = $True
                    '@odata.type' = "#microsoft.graph.fido2AuthenticationMethodConfiguration"
                    isSelfServiceRegistrationAllowed = $True
                    keyRestrictions = @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    }
                    PasskeyProfiles = @(
                        @{
                            AttestationEnforcement = "registrationOnly"
                            Id = "00000000-0000-0000-0000-000000000001"
                            KeyRestrictions = @{
                                AaGuids = @(
                                    "90a3ccdf-635c-4729-a248-9b709135078f"
                                    "de1e552d-db1d-4423-a619-566b625cdc84"
                                )
                                EnforcementType = "block"
                                IsEnforced = $True
                            }
                            Name = "Default passkey profile"
                            PasskeyTypes = "deviceBound"
                        }
                    )
                    ExcludeTargets = @(
                        @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        }
                    )
                    Id = "Fido2"
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
        Context -Name "The AADAuthenticationMethodPolicyFido2 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "FakeStringValue"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = ([MSFT_MicrosoftGraphFido2KeyRestrictions] @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    })
                    PasskeyProfiles = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2PasskeyProfile] @{
                            AttestationEnforcement = "registrationOnly"
                            Id = "00000000-0000-0000-0000-000000000001"
                            KeyRestrictions = ([MSFT_MicrosoftGraphFido2KeyRestrictions] @{
                                AaGuids = @(
                                    "90a3ccdf-635c-4729-a248-9b709135078f"
                                    "de1e552d-db1d-4423-a619-566b625cdc84"
                                )
                                EnforcementType = "block"
                                IsEnforced = $True
                            })
                            Name = "Default passkey profile"
                            PasskeyTypes = "deviceBound"
                        })
                    )
                    State = "enabled"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyFido2 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Fido2"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = ([MSFT_MicrosoftGraphFido2KeyRestrictions] @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    })
                    State = "enabled"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }
        Context -Name "The AADAuthenticationMethodPolicyFido2 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Fido2"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $True
                    keyRestrictions = ([MSFT_MicrosoftGraphFido2KeyRestrictions] @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    })
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyFido2 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyFido2IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    Id = "Fido2"
                    IsAttestationEnforced = $True
                    IsSelfServiceRegistrationAllowed = $False # Drift
                    keyRestrictions = ([MSFT_MicrosoftGraphFido2KeyRestrictions] @{
                        aaGuids = @("FakeStringValue")
                        enforcementType = "allow"
                        isEnforced = $True
                    })
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyFido2' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthenticationMethodPolicyFido2' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
