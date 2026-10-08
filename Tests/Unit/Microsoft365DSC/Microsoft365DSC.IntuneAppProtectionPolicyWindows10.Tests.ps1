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
    -DscResource "IntuneAppProtectionPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceAppManagementWindowsManagedAppProtection -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceAppManagementWindowsManagedAppProtection -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceAppManagementWindowsManagedAppProtection -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementWindowsManagedAppProtection -MockWith {
                return @{
                    mobileThreatDefenseRemediationAction = "block"
                    allowedInboundDataTransferSources = "allApps"
                    minimumWarningOsVersion = "FakeStringValue"
                    maximumWarningOsVersion = "FakeStringValue"
                    maximumAllowedDeviceThreatLevel = "notConfigured"
                    minimumWipeSdkVersion = "FakeStringValue"
                    allowedOutboundDataTransferDestinations = "allApps"
                    minimumWipeOsVersion = "FakeStringValue"
                    deployedAppCount = 25
                    appActionIfUnableToAuthenticateUser = "block"
                    maximumRequiredOsVersion = "FakeStringValue"
                    minimumRequiredOsVersion = "FakeStringValue"
                    minimumRequiredSdkVersion = "FakeStringValue"
                    minimumWipeAppVersion = "FakeStringValue"
                    maximumWipeOsVersion = "FakeStringValue"
                    minimumWarningAppVersion = "FakeStringValue"
                    allowedOutboundClipboardSharingLevel = "anyDestinationAnySource"
                    printBlocked = $True
                    minimumRequiredAppVersion = "FakeStringValue"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                }
            }

            Mock -CommandName Get-MgBetaDeviceAppManagementWindowsManagedAppProtectionApp -MockWith {
                return @(
                    @{
                        Id                  = 'com.microsoft.edge.windows'
                        MobileAppIdentifier = @{
                            '@odata.type' = '#microsoft.graph.windowsAppIdentifier'
                            windowsAppId  = 'com.microsoft.edge'
                        }
                    }
                )
            }

            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Exclude'
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false



            Mock -CommandName Get-MgBetaDeviceAppManagementWindowsManagedAppProtectionAssignment -MockWith {
                return @(@{
                    Id       = '12345-12345-12345-12345-12345'
                    Source   = 'direct'
                    SourceId = '12345-12345-12345-12345-12345'
                    Target   = @{
                        DeviceAndAppManagementAssignmentFilterId   = '12345-12345-12345-12345-12345'
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.exclusionGroupAssignmentTarget'
                        groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
            }

        }

        # Test contexts
        Context -Name "The IntuneAppProtectionPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    AllowedInboundDataTransferSources = "allApps"
                    AllowedOutboundClipboardSharingLevel = "anyDestinationAnySource"
                    AllowedOutboundDataTransferDestinations = "allApps"
                    Apps = @("com.microsoft.edge")
                    AppActionIfUnableToAuthenticateUser = "block"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaximumAllowedDeviceThreatLevel = "notConfigured"
                    MaximumRequiredOsVersion = "FakeStringValue"
                    MaximumWarningOsVersion = "FakeStringValue"
                    MaximumWipeOsVersion = "FakeStringValue"
                    MinimumRequiredAppVersion = "FakeStringValue"
                    MinimumRequiredOsVersion = "FakeStringValue"
                    MinimumRequiredSdkVersion = "FakeStringValue"
                    MinimumWarningAppVersion = "FakeStringValue"
                    MinimumWarningOsVersion = "FakeStringValue"
                    MinimumWipeAppVersion = "FakeStringValue"
                    MinimumWipeOsVersion = "FakeStringValue"
                    MinimumWipeSdkVersion = "FakeStringValue"
                    MobileThreatDefenseRemediationAction = "block"
                    PrintBlocked = $True
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceAppManagementWindowsManagedAppProtection -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceAppManagementWindowsManagedAppProtection -Exactly 1
            }
        }

        Context -Name "The IntuneAppProtectionPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    AllowedInboundDataTransferSources = "allApps"
                    AllowedOutboundClipboardSharingLevel = "anyDestinationAnySource"
                    AllowedOutboundDataTransferDestinations = "allApps"
                    Apps = @("com.microsoft.edge")
                    AppActionIfUnableToAuthenticateUser = "block"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaximumAllowedDeviceThreatLevel = "notConfigured"
                    MaximumRequiredOsVersion = "FakeStringValue"
                    MaximumWarningOsVersion = "FakeStringValue"
                    MaximumWipeOsVersion = "FakeStringValue"
                    MinimumRequiredAppVersion = "FakeStringValue"
                    MinimumRequiredOsVersion = "FakeStringValue"
                    MinimumRequiredSdkVersion = "FakeStringValue"
                    MinimumWarningAppVersion = "FakeStringValue"
                    MinimumWarningOsVersion = "FakeStringValue"
                    MinimumWipeAppVersion = "FakeStringValue"
                    MinimumWipeOsVersion = "FakeStringValue"
                    MinimumWipeSdkVersion = "FakeStringValue"
                    MobileThreatDefenseRemediationAction = "block"
                    PrintBlocked = $True
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceAppManagementWindowsManagedAppProtection -Exactly 1
            }
        }

        Context -Name "The IntuneAppProtectionPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    AllowedInboundDataTransferSources = "allApps"
                    AllowedOutboundClipboardSharingLevel = "anyDestinationAnySource"
                    AllowedOutboundDataTransferDestinations = "allApps"
                    Apps = @("com.microsoft.edge")
                    AppActionIfUnableToAuthenticateUser = "block"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaximumAllowedDeviceThreatLevel = "notConfigured"
                    MaximumRequiredOsVersion = "FakeStringValue"
                    MaximumWarningOsVersion = "FakeStringValue"
                    MaximumWipeOsVersion = "FakeStringValue"
                    MinimumRequiredAppVersion = "FakeStringValue"
                    MinimumRequiredOsVersion = "FakeStringValue"
                    MinimumRequiredSdkVersion = "FakeStringValue"
                    MinimumWarningAppVersion = "FakeStringValue"
                    MinimumWarningOsVersion = "FakeStringValue"
                    MinimumWipeAppVersion = "FakeStringValue"
                    MinimumWipeOsVersion = "FakeStringValue"
                    MinimumWipeSdkVersion = "FakeStringValue"
                    MobileThreatDefenseRemediationAction = "block"
                    PrintBlocked = $True
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAppProtectionPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType     = '#microsoft.graph.exclusionGroupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Exclude'
                        })
                    )
                    AllowedInboundDataTransferSources = "allApps"
                    AllowedOutboundClipboardSharingLevel = "anyDestinationAnySource"
                    AllowedOutboundDataTransferDestinations = "allApps"
                    Apps = @("com.microsoft.edge")
                    AppActionIfUnableToAuthenticateUser = "block"
                    Description = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"
                    MaximumAllowedDeviceThreatLevel = "notConfigured"
                    MaximumRequiredOsVersion = "FakeStringValue"
                    MaximumWarningOsVersion = "FakeStringValue"
                    MaximumWipeOsVersion = "FakeStringValue"
                    MinimumRequiredAppVersion = "FakeStringValue"
                    MinimumRequiredOsVersion = "FakeStringValue"
                    MinimumRequiredSdkVersion = "FakeStringValue"
                    MinimumWarningAppVersion = "FakeStringValue"
                    MinimumWarningOsVersion = "FakeStringValue"
                    MinimumWipeAppVersion = "FakeStringValue"
                    MinimumWipeOsVersion = "FakeStringValue"
                    MinimumWipeSdkVersion = "FakeStringValue"
                    MobileThreatDefenseRemediationAction = "block"
                    PrintBlocked = $False # Drift
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAppProtectionPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceAppManagementWindowsManagedAppProtection -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAppProtectionPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
