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
    -DscResource "AADIdentityB2XUserFlow" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaIdentityB2XUserFlow -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityB2XUserFlow -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityB2XUserFlow -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityB2XUserFlowIdentityProviderBaseByRef -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityB2XUserFlowIdentityProviderByRef -MockWith {
            }

            Mock -CommandName Remove-MgBetaIdentityB2XUserFlowUserAttributeAssignment -MockWith {
            }

            Mock -CommandName Update-MgBetaIdentityB2XUserFlowUserAttributeAssignment -MockWith {
            }

            Mock -CommandName New-MgBetaIdentityB2XUserFlowUserAttributeAssignment -MockWith {
            }

            Mock -CommandName Set-MgBetaIdentityB2XUserFlowPostAttributeCollectionByRef -MockWith {
            }

            Mock -CommandName Set-MgBetaIdentityB2XUserFlowPostFederationSignupByRef -MockWith {
            }

            Mock -CommandName Get-MgBetaIdentityB2XUserFlow -MockWith {
                return @{
                    id = "FakeStringValue"
                }
            }

            Mock -CommandName Get-MgBetaIdentityApiConnector -MockWith {
                return @{
                    id = "FakeStringValue"
                }
            }

            Mock -CommandName Get-MgBetaIdentityB2XUserFlowIdentityProvider -MockWith {
                return @(
                    @{
                        id = "Provider1"
                    },
                    @{
                        id = "Provider2"
                    }
                )
            }

            Mock -CommandName Get-MgBetaIdentityB2XUserFlowApiConnectorConfiguration -MockWith {
                return @{
                    PostFederationSignup = [PSCustomObject]@{
                        DisplayName = "FakeConnector2"
                    }
                    PostAttributeCollection = [PSCustomObject]@{
                        DisplayName = "FakeConnector1"
                    }
                }
            }

            Mock -CommandName Get-MgBetaIdentityB2XUserFlowUserAttributeAssignment -MockWith {
                return @(
                    [PSCustomObject]@{
                        UserInputType = 'textBox'
                        IsOptional = $True
                        DisplayName = 'Email Address'
                        Id = 'emailReadonly'
                        UserAttributeValues = @(
                            [PSCustomObject]@{
                                IsDefault = $True
                                Name = 'S'
                                Value = '2'
                            }
                        )
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The AADIdentityB2XUserFlow should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApiConnectorConfiguration = ([MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration] @{
                        postAttributeCollectionConnectorName = 'FakeConnector1'
                        postFederationSignupConnectorName = 'FakeConnector2'
                    })
                    Id = "FakeStringValue"
                    IdentityProviders = @("Provider1", "Provider2")
                    UserAttributeAssignments = @(([MSFT_MicrosoftGraphuserFlowUserAttributeAssignment] @{
                        UserInputType = 'textBox'
                        IsOptional = $True
                        DisplayName = 'Email Address'
                        Id = 'emailReadonly'
                        UserAttributeValues = @(
                            [MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues] @{
                                IsDefault = $True
                                Name = 'S'
                                Value = '2'
                            }
                        )
                    }))
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaIdentityB2XUserFlow -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaIdentityApiConnector -MockWith {
                    return $null
                }

                Mock -CommandName Get-MgBetaIdentityB2XUserFlowUserAttributeAssignment -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityB2XUserFlow -Exactly 1
                Should -Invoke -CommandName Get-MgBetaIdentityApiConnector -Exactly 2
                Should -Invoke -CommandName New-MgBetaIdentityB2XUserFlowIdentityProviderByRef -Exactly 2
                Should -Invoke -CommandName Get-MgBetaIdentityB2XUserFlowUserAttributeAssignment -Exactly 1
                Should -Invoke -CommandName New-MgBetaIdentityB2XUserFlowUserAttributeAssignment -Exactly 1
            }
        }

        Context -Name "The AADIdentityB2XUserFlow exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApiConnectorConfiguration = ([MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration] @{
                        postAttributeCollectionConnectorName = 'FakeConnector1'
                        postFederationSignupConnectorName = 'FakeConnector2'
                    })
                    Id = "FakeStringValue"
                    IdentityProviders = @("Provider1", "Provider2")
                    UserAttributeAssignments = @(([MSFT_MicrosoftGraphuserFlowUserAttributeAssignment] @{
                        UserInputType = 'textBox'
                        IsOptional = $True
                        DisplayName = 'Email Address'
                        Id = 'emailReadonly'
                        UserAttributeValues = @(
                            [MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues] @{
                                IsDefault = $True
                                Name = 'S'
                                Value = '2'
                            }
                        )
                    }))
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaIdentityB2XUserFlow -Exactly 1
            }
        }
        Context -Name "The AADIdentityB2XUserFlow Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApiConnectorConfiguration = ([MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration] @{
                        postAttributeCollectionConnectorName = 'FakeConnector1'
                        postFederationSignupConnectorName = 'FakeConnector2'
                    })
                    Id = "FakeStringValue"
                    IdentityProviders = @("Provider1", "Provider2")
                    UserAttributeAssignments = @(([MSFT_MicrosoftGraphuserFlowUserAttributeAssignment] @{
                        UserInputType = 'textBox'
                        IsOptional = $True
                        DisplayName = 'Email Address'
                        Id = 'emailReadonly'
                        UserAttributeValues = @(
                            [MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues] @{
                                IsDefault = $True
                                Name = 'S'
                                Value = '2'
                            }
                        )
                    }))
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The AADIdentityB2XUserFlow exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    ApiConnectorConfiguration = ([MSFT_MicrosoftGraphuserFlowApiConnectorConfiguration] @{
                        postAttributeCollectionConnectorName = 'FakeConnector1'
                        postFederationSignupConnectorName = 'FakeConnector2'
                    })
                    Id = "FakeStringValue"
                    IdentityProviders = @("Provider1", "Provider2", "Provider3") # Drift
                    UserAttributeAssignments = @(([MSFT_MicrosoftGraphuserFlowUserAttributeAssignment] @{
                        UserInputType = 'dropdownSingleSelect'
                        IsOptional = $True
                        DisplayName = 'Email Address'
                        Id = 'emailReadonly'
                        UserAttributeValues = @(
                            [MSFT_MicrosoftGraphuserFlowUserAttributeAssignmentUserAttributeValues] @{
                                IsDefault = $True
                                Name = 'Z'
                                Value = '2'
                            }
                        )
                    }))
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADIdentityB2XUserFlow' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaIdentityB2XUserFlowIdentityProviderByRef -Exactly 1
                Should -Invoke -CommandName Set-MgBetaIdentityB2XUserFlowPostFederationSignupByRef -Exactly 1
                Should -Invoke -CommandName Set-MgBetaIdentityB2XUserFlowPostAttributeCollectionByRef -Exactly 1
                Should -Invoke -CommandName Update-MgBetaIdentityB2XUserFlowUserAttributeAssignment -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADIdentityB2XUserFlow' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
