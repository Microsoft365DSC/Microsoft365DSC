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
    -DscResource "AADClaimsMappingPolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgBetaPolicyClaimMappingPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaPolicyClaimMappingPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyClaimMappingPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaPolicyClaimMappingPolicy -MockWith {
                return @{
                    Definition = @("{`"ClaimsMappingPolicy`":{`"Version`":1,`"IncludeBasicClaimSet`":`"true`",`"ClaimsSchema`":[{`"Source`":`"user`",`"ID`":`"userprincipalname`",`"SamlClaimType`":`"http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier`"}],`"ClaimsTransformation`":[{`"ID`":`"CreateTermsOfService`",`"TransformationMethod`":`"CreateStringClaim`",`"InputParameters`":[{`"ID`":`"value`",`"DataType`":`"string`", `"Value`":`"sandbox`"}],`"OutputClaims`":[{`"ClaimTypeReferenceId`":`"TOS`",`"TransformationClaimType`":`"createdClaim`"}]}]}}")
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IsOrganizationDefault = $True
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
        Context -Name "The AADClaimsMappingPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADClaimsMappingPolicyDefinition] @{
                            ClaimsMappingPolicy = [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy] @{
                                ClaimsSchema = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema] @{
                                        SamlClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'
                                        Source = 'user'
                                        Id = 'userprincipalname'
                                    }
                                )
                                ClaimsTransformation = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation] @{
                                        OutputClaims = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims] @{
                                                ClaimTypeReferenceId = 'TOS'
                                                TransformationClaimType = 'createdClaim'
                                            }
                                        )
                                        Id = 'CreateTermsOfService'
                                        InputParameters = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter] @{
                                                DataType = 'string'
                                                Id = 'value'
                                                Value = 'sandbox'
                                            }
                                        )
                                        TransformationMethod = 'CreateStringClaim'
                                    }
                                )
                                IncludeBasicClaimSet = $True
                                Version = 1
                            }
                        }
                    );
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyClaimMappingPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaPolicyClaimMappingPolicy -Exactly 1 -ParameterFilter {
                    $BodyParameter.Definition -is [System.Array] -and $BodyParameter.Definition.Count -eq 1
                }
            }
        }

        Context -Name "The AADClaimsMappingPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADClaimsMappingPolicyDefinition] @{
                            ClaimsMappingPolicy = [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy] @{
                                ClaimsSchema = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema] @{
                                        SamlClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'
                                        Source = 'user'
                                        Id = 'userprincipalname'
                                    }
                                )
                                ClaimsTransformation = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation] @{
                                        OutputClaims = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims] @{
                                                ClaimTypeReferenceId = 'TOS'
                                                TransformationClaimType = 'createdClaim'
                                            }
                                        )
                                        Id = 'CreateTermsOfService'
                                        InputParameters = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter] @{
                                                DataType = 'string'
                                                Id = 'value'
                                                Value = 'sandbox'
                                            }
                                        )
                                        TransformationMethod = 'CreateStringClaim'
                                    }
                                )
                                IncludeBasicClaimSet = $True
                                Version = 1
                            }
                        }
                    );
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyClaimMappingPolicy -Exactly 1
            }
        }
        Context -Name "The AADClaimsMappingPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADClaimsMappingPolicyDefinition] @{
                            ClaimsMappingPolicy = [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy] @{
                                ClaimsSchema = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema] @{
                                        SamlClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'
                                        Source = 'user'
                                        Id = 'userprincipalname'
                                    }
                                )
                                ClaimsTransformation = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation] @{
                                        OutputClaims = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims] @{
                                                ClaimTypeReferenceId = 'TOS'
                                                TransformationClaimType = 'createdClaim'
                                            }
                                        )
                                        Id = 'CreateTermsOfService'
                                        InputParameters = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter] @{
                                                DataType = 'string'
                                                Id = 'value'
                                                Value = 'sandbox'
                                            }
                                        )
                                        TransformationMethod = 'CreateStringClaim'
                                    }
                                )
                                IncludeBasicClaimSet = $True
                                Version = 1
                            }
                        }
                    );
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADClaimsMappingPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Definition = @(
                        [MSFT_AADClaimsMappingPolicyDefinition] @{
                            ClaimsMappingPolicy = [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicy] @{
                                ClaimsSchema = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsSchema] @{
                                        SamlClaimType = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname' # Drift
                                        Source = 'user'
                                        Id = 'givenname' # Drift
                                    }
                                )
                                ClaimsTransformation = @(
                                    [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformation] @{
                                        OutputClaims = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationOutputClaims] @{
                                                ClaimTypeReferenceId = 'TOS'
                                                TransformationClaimType = 'createdClaim'
                                            }
                                        )
                                        Id = 'CreateTermsOfService'
                                        InputParameters = @(
                                            [MSFT_AADClaimsMappingPolicyDefinitionMappingPolicyClaimsTransformationInputParameter] @{
                                                DataType = 'string'
                                                Id = 'value'
                                                Value = 'sandbox'
                                            }
                                        )
                                        TransformationMethod = 'CreateStringClaim'
                                    }
                                )
                                IncludeBasicClaimSet = $True
                                Version = 1
                            }
                        }
                    );

                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    IsOrganizationDefault = $True
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADClaimsMappingPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyClaimMappingPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADClaimsMappingPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
