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

            Mock -CommandName Set-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
            }

            Mock -CommandName Remove-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
            }


            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name "The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossTenantAccessPolicyConfigurationPartnerTenantId = "d8295cae-8bd0-4a7f-9288-933d2dc4573c";
                    DisplayName                                         = "IdentitySync";
                    Ensure                                              = "Present";
                    ExternalCloudAuthorizedApplicationId                = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47";
                    IsRoleEnabledGroupSyncAllowed                       = $true;
                    IsSyncAllowed                                       = $True;
                    Credential                                          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should create a new instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Set()
                Should -Invoke -CommandName Set-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -Exactly 1
            }
        }

        Context -Name "The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossTenantAccessPolicyConfigurationPartnerTenantId = "d8295cae-8bd0-4a7f-9288-933d2dc4573c";
                    DisplayName                                         = "IdentitySync";
                    Ensure                                              = "Absent";
                    ExternalCloudAuthorizedApplicationId                = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47";
                    IsRoleEnabledGroupSyncAllowed                       = $true;
                    IsSyncAllowed                                       = $True;
                    Credential                                          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
                    return @{
                        TenantID = "d8295cae-8bd0-4a7f-9288-933d2dc4573c"
                        DisplayName = "IdentitySync"
                        ExternalCloudAuthorizedApplicationId = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47"
                        UserSyncInbound = @{
                            IsSyncAllowed = $true
                        }
                        RoleEnabledGroupSyncInbound = @{
                            IsSyncAllowed = $true
                        }
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should remove the instance from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -Exactly 1
            }
        }

        Context -Name "The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossTenantAccessPolicyConfigurationPartnerTenantId = "d8295cae-8bd0-4a7f-9288-933d2dc4573c";
                    DisplayName                                         = "IdentitySync";
                    Ensure                                              = "Present";
                    ExternalCloudAuthorizedApplicationId                = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47";
                    IsRoleEnabledGroupSyncAllowed                       = $true;
                    IsSyncAllowed                                       = $True;
                    Credential                                          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
                    return @{
                        TenantID = "d8295cae-8bd0-4a7f-9288-933d2dc4573c"
                        DisplayName = "IdentitySync"
                        ExternalCloudAuthorizedApplicationId = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47"
                        UserSyncInbound = @{
                            IsSyncAllowed = $true
                        }
                        RoleEnabledGroupSyncInbound = @{
                            IsSyncAllowed = $true
                        }
                    }
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossTenantAccessPolicyConfigurationPartnerTenantId = "d8295cae-8bd0-4a7f-9288-933d2dc4573c";
                    DisplayName                                         = "IdentitySync";
                    Ensure                                              = "Present";
                    ExternalCloudAuthorizedApplicationId                = "0f4d9b1c-7a3e-4c8b-9d2a-5e6f3b8c1d47";
                    IsRoleEnabledGroupSyncAllowed                       = $true;
                    IsSyncAllowed                                       = $True;
                    Credential                                          = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
                    return @{
                        TenantID = "d8295cae-8bd0-4a7f-9288-933d2dc4573c"
                        DisplayName = "IdentitySync"
                        ExternalCloudAuthorizedApplicationId = "7c2e5a90-4b13-4f6d-8e51-2a9c6d0b3f84"
                        UserSyncInbound = @{
                            IsSyncAllowed = $false
                        }
                        RoleEnabledGroupSyncInbound = @{
                            IsSyncAllowed = $false
                        }
                    }
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -Property $testParams).Set()
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartner -MockWith {
                    return @{
                        TenantId = 'd8295cae-8bd0-4a7f-9288-933d2dc4573c'
                    }
                }

                Mock -CommandName Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -MockWith {
                    return @{
                        TenantID = "d8295cae-8bd0-4a7f-9288-933d2dc4573c"
                        DisplayName = "IdentitySync"
                        ExternalCloudAuthorizedApplicationId = "7c2e5a90-4b13-4f6d-8e51-2a9c6d0b3f84"
                        UserSyncInbound = @{
                            IsSyncAllowed = $false
                        }
                        RoleEnabledGroupSyncInbound = @{
                            IsSyncAllowed = $false
                        }
                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'AADCrossTenantIdentitySyncPolicyPartner' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
