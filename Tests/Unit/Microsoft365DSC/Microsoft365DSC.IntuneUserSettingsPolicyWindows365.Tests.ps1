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
    -DscResource "IntuneUserSettingsPolicyWindows365" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Reset-MSCloudLoginConnectionProfileContext -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -MockWith {
                return @{
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                }
            }

            Mock -CommandName Update-MgBetaDeviceManagementVirtualEndpointUserSetting -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementVirtualEndpointUserSetting -MockWith {
                return @{
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementVirtualEndpointUserSetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointUserSetting -MockWith {
                return @{
                    CrossRegionDisasterRecoverySetting = @{
                        DisasterRecoveryNetworkSetting = @{
                            onPremisesConnectionId = "FakeStringValue"
                            '@odata.type' = "#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting"
                        }
                        disasterRecoveryType = "crossRegion"
                        userInitiatedDisasterRecoveryAllowed = $False
                        CrossRegionDisasterRecoveryEnabled = $True
                        MaintainCrossRegionRestorePointEnabled = $True
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalAdminEnabled = $True
                    NotificationSetting = @{
                        RestartPromptsDisabled = $True
                    }
                    ProvisioningSourceType = "image"
                    ResetEnabled = $True
                    RestorePointSetting = @{
                        UserRestoreEnabled = $True
                        FrequencyInHours = 24
                        FrequencyType = "twentyFourHours"
                    }
                    SelfServiceEnabled = $False
                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointUserSettingAssignment -MockWith {
            }
        }

        # Test contexts
        Context -Name "The IntuneUserSettingsPolicyWindows365 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossRegionDisasterRecoverySetting = ([MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting] @{
                        DisasterRecoveryNetworkSetting = ([MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting] @{
                            OnPremisesConnectionId = "FakeStringValue"
                            odataType = "#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting"
                        })
                        DisasterRecoveryType = "crossRegion"
                        MaintainCrossRegionRestorePointEnabled = $True
                        UserInitiatedDisasterRecoveryAllowed = $False
                    })
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalAdminEnabled = $True
                    NotificationSetting = ([MSFT_MicrosoftGraphcloudPcNotificationSetting] @{
                        RestartPromptsDisabled = $True
                    })
                    ProvisioningSourceType = "image"
                    ResetEnabled = $True
                    RestorePointSetting = ([MSFT_MicrosoftGraphcloudPcRestorePointSetting] @{
                        UserRestoreEnabled = $True
                        FrequencyType = "twentyFourHours"
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementVirtualEndpointUserSetting -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementVirtualEndpointUserSetting -Exactly 1
            }
        }

        Context -Name "The IntuneUserSettingsPolicyWindows365 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossRegionDisasterRecoverySetting = ([MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting] @{
                        DisasterRecoveryNetworkSetting = ([MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting] @{
                            OnPremisesConnectionId = "FakeStringValue"
                            odataType = "#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting"
                        })
                        DisasterRecoveryType = "crossRegion"
                        MaintainCrossRegionRestorePointEnabled = $True
                        UserInitiatedDisasterRecoveryAllowed = $False
                    })
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalAdminEnabled = $True
                    NotificationSetting = ([MSFT_MicrosoftGraphcloudPcNotificationSetting] @{
                        RestartPromptsDisabled = $True
                    })
                    ProvisioningSourceType = "image"
                    ResetEnabled = $True
                    RestorePointSetting = ([MSFT_MicrosoftGraphcloudPcRestorePointSetting] @{
                        UserRestoreEnabled = $True
                        FrequencyType = "twentyFourHours"
                    })
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementVirtualEndpointUserSetting -Exactly 1
            }
        }

        Context -Name "The IntuneUserSettingsPolicyWindows365 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossRegionDisasterRecoverySetting = ([MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting] @{
                        DisasterRecoveryNetworkSetting = ([MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting] @{
                            OnPremisesConnectionId = "FakeStringValue"
                            odataType = "#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting"
                        })
                        DisasterRecoveryType = "crossRegion"
                        MaintainCrossRegionRestorePointEnabled = $True
                        UserInitiatedDisasterRecoveryAllowed = $False
                    })
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalAdminEnabled = $True
                    NotificationSetting = ([MSFT_MicrosoftGraphcloudPcNotificationSetting] @{
                        RestartPromptsDisabled = $True
                    })
                    ProvisioningSourceType = "image"
                    ResetEnabled = $True
                    RestorePointSetting = ([MSFT_MicrosoftGraphcloudPcRestorePointSetting] @{
                        UserRestoreEnabled = $True
                        FrequencyType = "twentyFourHours"
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneUserSettingsPolicyWindows365 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    CrossRegionDisasterRecoverySetting = ([MSFT_MicrosoftGraphcloudPcCrossRegionDisasterRecoverySetting] @{
                        DisasterRecoveryNetworkSetting = ([MSFT_MicrosoftGraphCloudPcDisasterRecoveryNetworkSetting] @{
                            OnPremisesConnectionId = "FakeStringValue"
                            odataType = "#microsoft.graph.cloudPcDisasterRecoveryAzureConnectionSetting"
                        })
                        DisasterRecoveryType = "premium" # Drift
                        MaintainCrossRegionRestorePointEnabled = $True
                        UserInitiatedDisasterRecoveryAllowed = $False
                    })
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    LocalAdminEnabled = $True
                    NotificationSetting = ([MSFT_MicrosoftGraphcloudPcNotificationSetting] @{
                        RestartPromptsDisabled = $True
                    })
                    ProvisioningSourceType = "snapshot" # Drift
                    ResetEnabled = $True
                    RestorePointSetting = ([MSFT_MicrosoftGraphcloudPcRestorePointSetting] @{
                        UserRestoreEnabled = $True
                        FrequencyType = "twentyFourHours"
                    })
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneUserSettingsPolicyWindows365' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementVirtualEndpointUserSetting -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneUserSettingsPolicyWindows365' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
