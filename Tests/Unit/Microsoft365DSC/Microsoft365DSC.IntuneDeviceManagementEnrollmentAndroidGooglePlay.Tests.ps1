[CmdletBinding()]
param()
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot -ChildPath '../../Unit' -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder -ChildPath 'Stubs/Microsoft365.psm1' -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder -ChildPath 'Stubs/Generic.psm1' -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder -ChildPath 'UnitTestHelper.psm1' -Resolve)

$CurrentScriptPath = $PSCommandPath.Split('\')
$CurrentScriptName = $CurrentScriptPath[$CurrentScriptPath.Length -1]
$ResourceName      = $CurrentScriptName.Split('.')[1]
$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule -DscResource $ResourceName -GenericStubModule $GenericStubPath

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {
            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {}
            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {}
            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith { return "Credentials" }

            Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {}
            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {}
            Mock -CommandName Remove-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {}
            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                @{ status = "Success" }
            }
            Mock -CommandName Get-M365DSCGroupDisplayNameById -MockWith { return 'Test Target Group' }
            # Hide Write-M365DSCHost output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {}

            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }

        # Context 1: Instance should exist but does not
        Context -Name "1. The instance should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                              = "androidManagedStoreAccountEnterpriseSettings"
                    BindStatus                                      = "notBound"
                    OwnerUserPrincipalName                          = "testuser@domain.com"
                    OwnerOrganizationName                           = "Test Organization"
                    EnrollmentTarget                                = "targetedAsEnrollmentRestrictions"
                    TargetGroups                                     = @("Test Target Group")
                    DeviceOwnerManagementEnabled                    = $False
                    AndroidDeviceOwnerFullyManagedEnrollmentEnabled = $False
                    ManagedGooglePlayInitialScopeTagIds             = @("0")
                    Ensure                                          = 'Present'
                    Credential                                      = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith { return $null }
            }

            It '1.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It '1.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Test() | Should -Be $false
            }
        }

        # Context 2: Instance exists but should not
        Context -Name "2. The instance exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id         = "androidManagedStoreAccountEnterpriseSettings"
                    Ensure     = 'Absent'
                    Credential = $Credential
                }

                # Mock to simulate a "boundAndValidated" state as a prerequisite for unbinding
                Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {
                    @(
                        @{
                            Id                                = "androidManagedStoreAccountEnterpriseSettings"
                            BindStatus                        = "boundAndValidated"  # Required for unbinding
                            LastAppSyncDateTime               = "2024-10-28T01:24:41.5529479Z"
                            LastAppSyncStatus                 = "success"
                            OwnerUserPrincipalName            = "admin@m365x22684512.onmicrosoft.com"
                            OwnerOrganizationName             = "Contoso"
                            LastModifiedDateTime              = "2024-10-28T01:24:39.1855089Z"
                            EnrollmentTarget                  = "targetedAsEnrollmentRestrictions"
                            TargetGroupIds                    = @("11111111-1111-1111-1111-111111111111")
                            DeviceOwnerManagementEnabled      = $true
                            AndroidDeviceOwnerFullyManagedEnrollmentEnabled = $false
                        }
                    )
                }

                # Retrieve current instance to verify bindStatus and ensure values
                $currentInstance = (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Get().ToHashtable()

                # Mock to simulate the unbind action with Invoke-M365DSCGraphRequest
                Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
                    @{ status = "Success" }
                }
            }

            It '2.1 Should confirm testParams Ensure is Absent' {
                # Verify that Ensure is set to 'Absent' in the test parameters
                $testParams.Ensure | Should -Be 'Absent'
            }

            It '2.2 Should confirm CurrentInstance Ensure is Present' {
                # Verify that Ensure is set to 'Present' in the current instance
                $currentInstance.Ensure | Should -Be 'Present'
            }

            It '2.3 Should confirm CurrentInstance BindStatus is boundAndValidated' {
                # Verify that bindStatus is 'boundAndValidated' in the current instance
                $currentInstance.BindStatus | Should -Be 'boundAndValidated'
            }

            It '2.4 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Test() | Should -Be $false
            }

            It '2.5 Should call Invoke-M365DSCGraphRequest to remove the instance from Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Set()

                # Verify if unbind was called
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 0
            }
        }

        # Context 3: Instance exists and values are already in the desired state
        Context -Name "3. The instance exists and values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                          = "androidManagedStoreAccountEnterpriseSettings"
                    BindStatus                                   = "bound"
                    # OwnerUserPrincipalName                       = "existingUser@domain.com"
                    TargetGroups                                  = @("Test Target Group")
                    ManagedGooglePlayInitialScopeTagIds          = @("0")
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {
                    return @{
                        Id                                        = "androidManagedStoreAccountEnterpriseSettings"
                        BindStatus                                = "bound"
                        # OwnerUserPrincipalName                    = "existingUser@domain.com"
                        TargetGroupIds                            = @("11111111-1111-1111-1111-111111111111")
                        ManagedGooglePlayInitialScopeTagIds       = @("0")
                        Ensure                                    = 'Present'
                    }
                }
            }

            It '3.0 Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Test() | Should -Be $true
            }
        }

        # Context 4: Instance exists, but values are not in the desired state
        Context -Name "4. The instance exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Id                                          = "androidManagedStoreAccountEnterpriseSettings"
                    BindStatus                                   = "notBound"
                    TargetGroups                                  = @("Test Target Group")
                    ManagedGooglePlayInitialScopeTagIds          = @("0")
                    Ensure                                       = 'Present'
                    Credential                                   = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {
                    return @{
                        Id                                        = "androidManagedStoreAccountEnterpriseSettings"
                        BindStatus                                = "bound"
                        OwnerUserPrincipalName                    = "existingUser@domain.com"
                        TargetGroupIds                            = @("11111111-1111-1111-1111-111111111111")
                        ManagedGooglePlayInitialScopeTagIds       = @("1")
                        Ensure                                    = 'Present'
                    }
                }
            }

            It '4.1 Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }
            It '4.2 Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -Property $testParams).Test() | Should -Be $false
            }
        }

        # Context 5: ReverseDSC Tests
        Context -Name '5. ReverseDSC Tests' -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $Global:PartialExportFileName = "$(New-Guid).partial.ps1"
                $testParams = @{
                    Credential  = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementAndroidManagedStoreAccountEnterpriseSetting -MockWith {
                    return @{
                        Id                                        = "androidManagedStoreAccountEnterpriseSettings"
                        BindStatus                                = "bound"
                        OwnerUserPrincipalName                    = "existingUser@domain.com"
                        TargetGroupIds                            = @("11111111-1111-1111-1111-111111111111")
                    }
                }
            }

            It '5.0 Should Reverse Engineer resource from the Export method' {
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceManagementEnrollmentAndroidGooglePlay' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
