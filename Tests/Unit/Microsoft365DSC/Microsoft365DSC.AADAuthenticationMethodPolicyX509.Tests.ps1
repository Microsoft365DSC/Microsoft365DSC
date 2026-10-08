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
    -DscResource "AADAuthenticationMethodPolicyX509" -GenericStubModule $GenericStubPath
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
                    '@odata.type' = "#microsoft.graph.x509CertificateAuthenticationMethodConfiguration"
                    certificateAuthorityScopes = @(
                        @{
                            includeTargets = @(
                                @{
                                    targetType = 'group'
                                    id = '00000000-0000-0000-0000-000000000000'
                                }
                            )
                            publicKeyInfrastructureIdentifier = "FakeStringValue"
                            subjectKeyIdentifier = "FakeStringValue"
                        }
                    )
                    issuerHintsConfiguration = @{
                        state = "enabled"
                    }
                    certificateUserBindings = @(
                        @{
                            x509CertificateField = "FakeStringValue"
                            userProperty = "FakeStringValue"
                            priority = 25
                        }
                    )
                    authenticationModeConfiguration = @{
                        x509CertificateAuthenticationDefaultMode = "x509CertificateSingleFactor"
                        rules = @(
                            @{
                                x509CertificateRuleType = "issuerSubject"
                                identifier = "FakeStringValue"
                                x509CertificateAuthenticationMode = "x509CertificateSingleFactor"
                            }
                        )
                    }
                    ExcludeTargets = @(
                        @{
                            TargetType = "group"
                            Id = "00000000-0000-0000-0000-000000000000"
                        }
                    )
                    Id = "X509Certificate0"
                    State = "enabled"
                }
            }

            Mock -CommandName Get-MgGroup -ModuleName M365DSCUtil -MockWith {
                return @{
                    Id = "00000000-0000-0000-0000-000000000001"
                    DisplayName = "Fakegroup"
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADAuthenticationMethodPolicyX509 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    authenticationModeConfiguration = ([MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration] @{
                        x509CertificateAuthenticationDefaultMode = "x509CertificateSingleFactor"
                        rules = @(
                            ([MSFT_MicrosoftGraphX509CertificateRule] @{
                                x509CertificateRuleType = "issuerSubject"
                                identifier = "FakeStringValue"
                                x509CertificateAuthenticationMode = "x509CertificateSingleFactor"
                            })
                        )
                    })
                    CertificateAuthorityScopes = @(
                        ([MSFT_MicrosoftGraphx509CertificateAuthorityScope] @{
                            IncludeTargets = @(
                                ([MSFT_MicrosoftGraphIncludeTarget] @{
                                    TargetType = 'group'
                                    Id = '00000000-0000-0000-0000-000000000000'
                                })
                            )
                            PublicKeyInfrastructureIdentifier = "FakeStringValue"
                            SubjectKeyIdentifier = "FakeStringValue"
                        })
                    )
                    certificateUserBindings = @(
                        ([MSFT_MicrosoftGraphx509CertificateUserBinding] @{
                            x509CertificateField = "FakeStringValue"
                            userProperty = "FakeStringValue"
                            priority = 25
                        })
                    )
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget] @{
                            TargetType = "group"
                            Id = "00000000-0000-0000-0000-000000000000"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509IncludeTarget] @{
                            TargetType = 'group'
                            Id         = '00000000-0000-0000-0000-000000000000'
                        })
                    )
                    IssuerHintsConfiguration = ([MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration] @{
                        State = "enabled"
                    })
                    Id = "X509Certificate"
                    State = "enabled"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyX509 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    authenticationModeConfiguration = ([MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration] @{
                        x509CertificateAuthenticationDefaultMode = "x509CertificateSingleFactor"
                        rules = @(
                            ([MSFT_MicrosoftGraphX509CertificateRule] @{
                                x509CertificateRuleType = "issuerSubject"
                                identifier = "FakeStringValue"
                                x509CertificateAuthenticationMode = "x509CertificateSingleFactor"
                            })
                        )
                    })
                    CertificateAuthorityScopes = @(
                        ([MSFT_MicrosoftGraphx509CertificateAuthorityScope] @{
                            IncludeTargets = @(
                                ([MSFT_MicrosoftGraphIncludeTarget] @{
                                    TargetType = 'group'
                                    Id = 'Fakegroup'
                                })
                            )
                            PublicKeyInfrastructureIdentifier = "FakeStringValue"
                            SubjectKeyIdentifier = "FakeStringValue"
                        })
                    )
                    certificateUserBindings = @(
                        ([MSFT_MicrosoftGraphx509CertificateUserBinding] @{
                            x509CertificateField = "FakeStringValue"
                            userProperty = "FakeStringValue"
                            priority = 25
                        })
                    )
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget] @{
                            TargetType = "group"
                            Id = "00000000-0000-0000-0000-000000000000"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    IssuerHintsConfiguration = ([MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration] @{
                        State = "enabled"
                    })
                    Id = "X509Certificate"
                    State = "enabled"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyAuthenticationMethodPolicyAuthenticationMethodConfiguration -Exactly 1
            }
        }
        Context -Name "The AADAuthenticationMethodPolicyX509 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    authenticationModeConfiguration = ([MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration] @{
                        x509CertificateAuthenticationDefaultMode = "x509CertificateSingleFactor"
                        rules = @(
                            ([MSFT_MicrosoftGraphX509CertificateRule] @{
                                x509CertificateRuleType = "issuerSubject"
                                identifier = "FakeStringValue"
                                x509CertificateAuthenticationMode = "x509CertificateSingleFactor"
                            })
                        )
                    })
                    CertificateAuthorityScopes = @(
                        ([MSFT_MicrosoftGraphx509CertificateAuthorityScope] @{
                            IncludeTargets = @(
                                ([MSFT_MicrosoftGraphIncludeTarget] @{
                                    TargetType = 'group'
                                    Id = 'Fakegroup'
                                })
                            )
                            PublicKeyInfrastructureIdentifier = "FakeStringValue"
                            SubjectKeyIdentifier = "FakeStringValue"
                        })
                    )
                    certificateUserBindings = @(
                        ([MSFT_MicrosoftGraphx509CertificateUserBinding] @{
                            x509CertificateField = "FakeStringValue"
                            userProperty = "FakeStringValue"
                            priority = 25
                        })
                    )
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    IssuerHintsConfiguration = ([MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration] @{
                        State = "enabled"
                    })
                    Id = "X509Certificate"
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADAuthenticationMethodPolicyX509 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    authenticationModeConfiguration = ([MSFT_MicrosoftGraphx509CertificateAuthenticationModeConfiguration] @{
                        x509CertificateAuthenticationDefaultMode = "x509CertificateSingleFactor"
                        rules = @(
                            ([MSFT_MicrosoftGraphX509CertificateRule] @{
                                x509CertificateRuleType = "issuerSubject"
                                identifier = "FakeStringValue"
                                x509CertificateAuthenticationMode = "x509CertificateSingleFactor"
                            })
                        )
                    })
                    CertificateAuthorityScopes = @(
                        ([MSFT_MicrosoftGraphx509CertificateAuthorityScope] @{
                            IncludeTargets = @(
                                ([MSFT_MicrosoftGraphIncludeTarget] @{
                                    TargetType = 'group'
                                    Id = 'Fakegroup'
                                })
                            )
                            PublicKeyInfrastructureIdentifier = "FakeStringValue"
                            SubjectKeyIdentifier = "FakeStringValue2" # Drift
                        })
                    )
                    certificateUserBindings = @(
                        ([MSFT_MicrosoftGraphx509CertificateUserBinding] @{
                            x509CertificateField = "FakeStringValue"
                            userProperty = "FakeStringValue"
                            priority = 7 # Drift
                        })
                    )
                    ExcludeTargets = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509ExcludeTarget] @{
                            TargetType = "group"
                            Id = "Fakegroup2"
                        })
                    )
                    IncludeTargets        = @(
                        ([MSFT_AADAuthenticationMethodPolicyX509IncludeTarget] @{
                            TargetType = 'group'
                            Id         = 'Fakegroup'
                        })
                    )
                    IssuerHintsConfiguration = ([MSFT_MicrosoftGraphx509CertificateIssuerHintsConfiguration] @{
                        State = "disabled" # Drift
                    })
                    Id = "X509Certificate"
                    State = "enabled"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADAuthenticationMethodPolicyX509' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADAuthenticationMethodPolicyX509' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
