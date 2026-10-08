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

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -Command Update-MgBetaPolicyDefaultAppManagementPolicy -MockWith {

            }

            Mock -Command Get-MgBetaPolicyDefaultAppManagementPolicy -MockWith {
                return @{
                    DisplayName = "MyPolicy"
                    IsEnabled = $true
                    Description = "MyDescription"
                    Id          = "12345-12345-12345-12345-12345"
                    ApplicationRestrictions = @{
                        passwordCredentials = @(
                            @{
                                restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                restrictionType = "passwordAddition"
                                state = "enabled"
                            },
                            @{
                                maxLifetime = "P90D"
                                restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                restrictionType = "passwordLifetime"
                                state = "enabled"
                            },
                            @{
                                restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                restrictionType = "symmetricKeyAddition"
                                state = "enabled"
                            },
                            @{
                                maxLifetime = "P90D"
                                restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                restrictionType = "symmetricKeyLifetime"
                                state = "enabled"
                            }
                        )
                    }
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
        }
        # Test contexts


        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName         = "MyPolicy"
                    Description         = "MyDescription"
                    IsEnabled           = $true
                    IsSingleInstance    = 'Yes'
                    Credential          = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "Get-TargetResource returns ApplicationRestrictions with maxLifetime converted to ISO 8601" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName      = "MyPolicy"
                    Description      = "MyDescription"
                    IsSingleInstance = 'Yes'
                    Credential       = $Credential;
                }
            }

            It 'Should return maxLifetime in ISO 8601 format from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Get().ToHashtable()
                $result.IsSingleInstance | Should -Be 'Yes'
                $result.ApplicationRestrictions.passwordCredentials | Should -HaveCount 4
                $lifetimeCred = $result.ApplicationRestrictions.passwordCredentials | Where-Object { $_.restrictionType -eq 'passwordLifetime' }
                $lifetimeCred | Should -Not -BeNullOrEmpty
                $lifetimeCred.maxLifetime | Should -Be 'P90D'
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName         = "MyPolicy"
                    Description         = "MyDescription"
                    IsEnabled           = $true
                    IsSingleInstance    = 'Yes'
                    ApplicationRestrictions          = ([MSFT_AADTenantAppManagementPolicyRestrictions] @{
                        passwordCredentials = @(
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                restrictForAppsCreatedAfterDateTime = "1/1/0001 5:00:00 AM"
                                restrictionType = "passwordAddition"
                                state = "enabled"
                            });
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                maxLifetime = "P90D"
                                restrictForAppsCreatedAfterDateTime = "1/1/0001 5:00:00 AM"
                                restrictionType = "passwordLifetime"
                                state = "enabled"
                            });
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                restrictForAppsCreatedAfterDateTime = "1/1/0001 5:00:00 AM"
                                restrictionType = "symmetricKeyAddition"
                                state = "enabled"
                            });
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                maxLifetime = "P90D"
                                restrictForAppsCreatedAfterDateTime = "1/1/0001 5:00:00 AM"
                                restrictionType = "symmetricKeyLifetime"
                                state = "enabled"
                            });
                        )
                    });
                    Credential          = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Get().ToHashtable()).IsSingleInstance | Should -Be 'Yes'

                Mock -CommandName Get-MgBetaPolicyDefaultAppManagementPolicy -MockWith {
                    return $null
                }
                { (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Get() } | Should -Throw '*Could not find the tenant app management policy.*'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaPolicyDefaultAppManagementPolicy -Exactly 1
            }
        }

        Context -Name "The instance exists with keyCredentials including trustedCertificateAuthority and values are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName         = "MyPolicy"
                    Description         = "MyDescription"
                    IsEnabled           = $true
                    ApplicationRestrictions = ([MSFT_AADTenantAppManagementPolicyRestrictions] @{
                        keyCredentials = @(
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                maxLifetime = "P30D"
                                restrictForAppsCreatedAfterDateTime = "0001-01-01T00:00:00.0000000"
                                restrictionType = "asymmetricKeyLifetime"
                                state = "enabled"
                            });
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                certificateBasedApplicationConfigurationIds = [System.String[]]@("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
                                restrictForAppsCreatedAfterDateTime = "0001-01-01T00:00:00.0000000"
                                restrictionType = "trustedCertificateAuthority"
                                state = "enabled"
                            });
                        )
                    });
                    IsSingleInstance = 'Yes'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyDefaultAppManagementPolicy -MockWith {
                    return @{
                        DisplayName  = "MyPolicy"
                        Description  = "MyDescription"
                        Id           = "12345-12345-12345-12345-12345"
                        IsEnabled    = $true
                        ApplicationRestrictions = @{
                            keyCredentials = @(
                                @{
                                    maxLifetime = "P30D"
                                    restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                    restrictionType = "asymmetricKeyLifetime"
                                    state = "enabled"
                                },
                                @{
                                    certificateBasedApplicationConfigurationIds = @("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
                                    restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                    restrictionType = "trustedCertificateAuthority"
                                    state = "enabled"
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Get().ToHashtable()
                $result.IsSingleInstance | Should -Be 'Yes'
                $result.ApplicationRestrictions.keyCredentials | Should -HaveCount 2
                $trustedCACred = $result.ApplicationRestrictions.keyCredentials | Where-Object { $_.restrictionType -eq 'trustedCertificateAuthority' }
                $trustedCACred | Should -Not -BeNullOrEmpty
                $trustedCACred.certificateBasedApplicationConfigurationIds | Should -Contain 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists with ServicePrincipalRestrictions and values are in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    DisplayName         = "MyPolicy"
                    Description         = "MyDescription"
                    IsEnabled           = $true
                    ServicePrincipalRestrictions = ([MSFT_AADTenantAppManagementPolicyRestrictions] @{
                        passwordCredentials = @(
                            ([MSFT_AADTenantAppManagementPolicyRestrictionsCredential] @{
                                restrictForAppsCreatedAfterDateTime = "0001-01-01T00:00:00.0000000"
                                restrictionType = "passwordAddition"
                                state = "enabled"
                            });
                        )
                    });
                    IsSingleInstance    = 'Yes'
                    Credential          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyDefaultAppManagementPolicy -MockWith {
                    return @{
                        DisplayName  = "MyPolicy"
                        Description  = "MyDescription"
                        Id           = "12345-12345-12345-12345-12345"
                        IsEnabled    = $true
                        ServicePrincipalRestrictions = @{
                            passwordCredentials = @(
                                @{
                                    restrictForAppsCreatedAfterDateTime = [DateTime]::Parse("1/1/0001 12:00:00 AM")
                                    restrictionType = "passwordAddition"
                                    state = "enabled"
                                }
                            )
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                $result = (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Get().ToHashtable()
                $result.IsSingleInstance | Should -Be 'Yes'
                $result.ServicePrincipalRestrictions.passwordCredentials | Should -HaveCount 1
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADTenantAppManagementPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADTenantAppManagementPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
