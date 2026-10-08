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
    -DscResource "AADVerifiedIdAuthorityContract" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -CommandName Invoke-WebRequest -MockWith {
                param ($Uri)
                $payload = & {
                    param ($Uri)
                switch ($Uri) {
                    "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities" {
                        return @{
                            value = @(
                                @{
                                    id = "FakeStringValue"
                                    name = "FakeStringValue"
                                    didModel = @{
                                        linkedDomainUrls = @("FakeStringValue")
                                        did = "did:FakeStringValue"
                                    }
                                    keyVaultMetadata = @{
                                        subscriptionId = "FakeStringValue"
                                        resourceGroup = "FakeStringValue"
                                        resourceName = "FakeStringValue"
                                        resourceUrl = "FakeStringValue"
                                    }

                                }
                            )
                        }
                    }
                    default {
                        return @{
                            value = @(
                                @{
                                    id = "FakeStringValue"
                                    authorityId = "FakeStringValue"
                                    name = "FakeStringValue"
                                    linkedDomainUrl = "FakeStringValue"
                                    displays = @(
                                        @{
                                            consent = @{
                                                instructions = "Verify your identity and workplace the easy way. Add this ID for online and in-person use."
                                                title = "Do you really want to accept the verified employee credential from Contoso."
                                            }
                                            card = @{
                                                description = "This verifiable credential is issued to all members of the Contoso org."
                                                issuedBy = "Contoso"
                                                backgroundColor = "#000000"
                                                textColor = "#FFFFFA"
                                                logo = @{
                                                    uri = "https://proddideussg1.z13.web.core.windows.net/systemgeneratedcontractlogo.png"
                                                    description = "Default verified employee logo"
                                                }
                                                title = "Verified Employee"
                                            }
                                            locale = "en-US"
                                            claims = @(
                                                @{
                                                    label = "Revocation id"
                                                    claim = "vc.credentialSubject.revocationId"
                                                    type = "String"
                                                }
                                            )
                                        }
                                    )
                                    rules = @{
                                        validityInterval = 15552000
                                        vc = @{
                                            type = @("VerifiedEmployee")
                                        }
                                        attestations = @{
                                            accessTokens = @(
                                                @{
                                                    mapping = @(
                                                        @{
                                                            inputClaim = "photo"
                                                            indexed = $False
                                                            outputClaim = "photo"
                                                            required = $False
                                                        }
                                                    )
                                                    required = $True
                                                }
                                            )
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                } $Uri
                return @{
                    Content = ($payload | ConvertTo-Json -Depth 30)
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Write-Warning -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADVerifiedIdAuthorityContract should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    id = "FakeStringValue"
                    authorityId = "FakeStringValue"
                    name = "FakeStringValue"
                    linkedDomainUrl = "FakeStringValue"
                    displays =  @(
                        ([MSFT_AADVerifiedIdAuthorityContractDisplayModel] @{
                            consent = ([MSFT_AADVerifiedIdAuthorityContractDisplayConsent] @{
                                instructions = "Verify your identity and workplace the easy way. Add this ID for online and in-person use."
                                title = "Do you really want to accept the verified employee credential from Contoso."
                            })
                            card = ([MSFT_AADVerifiedIdAuthorityContractDisplayCard] @{
                                description = "This verifiable credential is issued to all members of the Contoso org."
                                issuedBy = "Contoso"
                                backgroundColor = "#000000"
                                textColor = "#FFFFFA"
                                logo = ([MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo] @{
                                    uri = "https://proddideussg1.z13.web.core.windows.net/systemgeneratedcontractlogo.png"
                                    description = "Default verified employee logo"
                                })
                                title = "Verified Employee"
                            })
                            locale = "en-US"
                            claims =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractDisplayClaims] @{
                                    label = "Revocation id"
                                    claim = "vc.credentialSubject.revocationId"
                                    type = "String"
                                })
                            )
                        })
                    )
                    rules = ([MSFT_AADVerifiedIdAuthorityContractRulesModel] @{
                        validityInterval = 15552000
                        vc = ([MSFT_AADVerifiedIdAuthorityContractVcType] @{
                            type = @("VerifiedEmployee")
                        })
                        attestations = ([MSFT_AADVerifiedIdAuthorityContractAttestations] @{
                            accessTokens =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractAttestationValues] @{
                                    mapping =  @(
                                        ([MSFT_AADVerifiedIdAuthorityContractClaimMapping] @{
                                            inputClaim = "photo"
                                            indexed = $False
                                            outputClaim = "photo"
                                            required = $False
                                        })
                                    )
                                    required = $True
                                })
                            )
                        })
                    })
                    Ensure = 'Present'
                }

                Mock -CommandName Invoke-WebRequest -MockWith {
                    param ($Uri)
                    $payload = & {
                        param ($Uri)
                    switch ($Uri) {
                        "https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities" {
                            return @{
                                value = @(
                                    @{
                                        id = "FakeStringValue"
                                        name = "FakeStringValue"
                                        didModel = @{
                                            linkedDomainUrls = @("FakeStringValue")
                                            did = "did:FakeStringValue"
                                        }
                                        keyVaultMetadata = @{
                                            subscriptionId = "FakeStringValue"
                                            resourceGroup = "FakeStringValue"
                                            resourceName = "FakeStringValue"
                                            resourceUrl = "FakeStringValue"
                                        }

                                    }
                                )
                            }
                        }
                        default {
                            return @{
                                value = @()
                            }
                        }
                    }
                    } $Uri
                    return @{
                        Content = ($payload | ConvertTo-Json -Depth 30)
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the id from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 4
                Should -Invoke -CommandName Invoke-WebRequest -ParameterFilter {
                    $Method -eq 'POST' -and ($Body | ConvertFrom-Json).displays -is [System.Array]
                } -Exactly 1
            }
        }

        Context -Name "The AADVerifiedIdAuthorityContract exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    id = "FakeStringValue"
                    authorityId = "FakeStringValue"
                    name = "FakeStringValue"
                    linkedDomainUrl = "FakeStringValue"
                    displays =  @(
                            ([MSFT_AADVerifiedIdAuthorityContractDisplayModel] @{
                                consent = ([MSFT_AADVerifiedIdAuthorityContractDisplayConsent] @{
                                    instructions = "Verify your identity and workplace the easy way. Add this ID for online and in-person use."
                                    title = "Do you really want to accept the verified employee credential from Contoso."
                                })
                                card = ([MSFT_AADVerifiedIdAuthorityContractDisplayCard] @{
                                    description = "This verifiable credential is issued to all members of the Contoso org."
                                    issuedBy = "Contoso"
                                    backgroundColor = "#000000"
                                    textColor = "#FFFFFA"
                                    logo = ([MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo] @{
                                        uri = "https://proddideussg1.z13.web.core.windows.net/systemgeneratedcontractlogo.png"
                                        description = "Default verified employee logo"
                                    })
                                    title = "Verified Employee"
                                })
                                locale = "en-US"
                                claims =  @(
                                    ([MSFT_AADVerifiedIdAuthorityContractDisplayClaims] @{
                                        label = "Revocation id"
                                        claim = "vc.credentialSubject.revocationId"
                                        type = "String"
                                    })
                                )
                            })
                        )
                    rules = ([MSFT_AADVerifiedIdAuthorityContractRulesModel] @{
                            validityInterval = 15552000
                            vc = ([MSFT_AADVerifiedIdAuthorityContractVcType] @{
                                type = @("VerifiedEmployee")
                            })
                            attestations = ([MSFT_AADVerifiedIdAuthorityContractAttestations] @{
                                accessTokens =  @(
                                    ([MSFT_AADVerifiedIdAuthorityContractAttestationValues] @{
                                        mapping =  @(
                                            ([MSFT_AADVerifiedIdAuthorityContractClaimMapping] @{
                                                inputClaim = "photo"
                                                indexed = $False
                                                outputClaim = "photo"
                                                required = $False
                                            })
                                        )
                                        required = $True
                                    })
                                )
                            })
                        })
                    Ensure = 'Absent'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 2
            }
        }
        Context -Name "The AADVerifiedIdAuthorityContract Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    id = "FakeStringValue"
                    authorityId = "FakeStringValue"
                    name = "FakeStringValue"
                    linkedDomainUrl = "FakeStringValue"
                    displays =  @(
                        ([MSFT_AADVerifiedIdAuthorityContractDisplayModel] @{
                            consent = ([MSFT_AADVerifiedIdAuthorityContractDisplayConsent] @{
                                instructions = "Verify your identity and workplace the easy way. Add this ID for online and in-person use."
                                title = "Do you really want to accept the verified employee credential from Contoso."
                            })
                            card = ([MSFT_AADVerifiedIdAuthorityContractDisplayCard] @{
                                description = "This verifiable credential is issued to all members of the Contoso org."
                                issuedBy = "Contoso"
                                backgroundColor = "#000000"
                                textColor = "#FFFFFA"
                                logo = ([MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo] @{
                                    uri = "https://proddideussg1.z13.web.core.windows.net/systemgeneratedcontractlogo.png"
                                    description = "Default verified employee logo"
                                })
                                title = "Verified Employee"
                            })
                            locale = "en-US"
                            claims =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractDisplayClaims] @{
                                    label = "Revocation id"
                                    claim = "vc.credentialSubject.revocationId"
                                    type = "String"
                                })
                            )
                        })
                    )
                    rules = ([MSFT_AADVerifiedIdAuthorityContractRulesModel] @{
                        validityInterval = 15552000
                        vc = ([MSFT_AADVerifiedIdAuthorityContractVcType] @{
                            type = @("VerifiedEmployee")
                        })
                        attestations = ([MSFT_AADVerifiedIdAuthorityContractAttestations] @{
                            accessTokens =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractAttestationValues] @{
                                    mapping =  @(
                                        ([MSFT_AADVerifiedIdAuthorityContractClaimMapping] @{
                                            inputClaim = "photo"
                                            indexed = $False
                                            outputClaim = "photo"
                                            required = $False
                                        })
                                    )
                                    required = $True
                                })
                            )
                        })
                    })
                    Ensure = 'Present'
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADVerifiedIdAuthorityContract exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    id = "FakeStringValue"
                    authorityId = "FakeStringValue"
                    name = "FakeStringValue"
                    linkedDomainUrl = "FakeStringValue"
                    displays =  @(
                        ([MSFT_AADVerifiedIdAuthorityContractDisplayModel] @{
                            consent = ([MSFT_AADVerifiedIdAuthorityContractDisplayConsent] @{
                                instructions = "Verify your identity and workplace the easy way. Add this ID for online and in-person use."
                                title = "Do you want to accept the verified employee credential from Contoso." #drift
                            })
                            card = ([MSFT_AADVerifiedIdAuthorityContractDisplayCard] @{
                                description = "This verifiable credential is issued to all members of the Contoso org."
                                issuedBy = "Contoso"
                                backgroundColor = "#000000"
                                textColor = "#FFFFFA"
                                logo = ([MSFT_AADVerifiedIdAuthorityContractDisplayCredentialLogo] @{
                                    uri = "https://proddideussg1.z13.web.core.windows.net/systemgeneratedcontractlogo.png"
                                    description = "Default verified employee logo"
                                })
                                title = "Verified Employee"
                            })
                            locale = "en-US"
                            claims =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractDisplayClaims] @{
                                    label = "Revocation id"
                                    claim = "vc.credentialSubject.revocationId"
                                    type = "String"
                                })
                            )
                        })
                    )
                    rules = ([MSFT_AADVerifiedIdAuthorityContractRulesModel] @{
                        validityInterval = 15552000
                        vc = ([MSFT_AADVerifiedIdAuthorityContractVcType] @{
                            type = @("VerifiedEmployee")
                        })
                        attestations = ([MSFT_AADVerifiedIdAuthorityContractAttestations] @{
                            accessTokens =  @(
                                ([MSFT_AADVerifiedIdAuthorityContractAttestationValues] @{
                                    mapping =  @(
                                        ([MSFT_AADVerifiedIdAuthorityContractClaimMapping] @{
                                            inputClaim = "photo"
                                            indexed = $False
                                            outputClaim = "photo"
                                            required = $False
                                        })
                                    )
                                    required = $True
                                })
                            )
                        })
                    })
                    Ensure = 'Present'
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADVerifiedIdAuthorityContract' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-WebRequest -Exactly 3
                Should -Invoke -CommandName Invoke-WebRequest -ParameterFilter {
                    $Method -eq 'PATCH' -and $Uri -eq 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/FakeStringValue/contracts/FakeStringValue'
                } -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADVerifiedIdAuthorityContract' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
