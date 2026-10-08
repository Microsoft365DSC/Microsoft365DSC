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
    -DscResource "IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-Guid | Out-String) -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Get-M365DSCExportCachedCollection -MockWith {
                return Get-MgBetaDeviceManagementDeviceConfiguration
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                return @{
                    '@odata.type' = "#microsoft.graph.windowsDefenderAdvancedThreatProtectionConfiguration"
                    advancedThreatProtectionOffboardingBlob = "FakeStringValue"
                    allowSampleSharing = $True
                    advancedThreatProtectionOffboardingFilename = "FakeStringValue"
                    enableExpeditedTelemetryReporting = $True
                    advancedThreatProtectionAutoPopulateOnboardingBlob = $True
                    advancedThreatProtectionOnboardingBlob = "FakeStringValue"
                    advancedThreatProtectionOnboardingFilename = "FakeStringValue"
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    Id = "FakeStringValue"

                }
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
            }

        }
        # Test contexts
        Context -Name "The IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10 should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedThreatProtectionAutoPopulateOnboardingBlob = $True
                    AdvancedThreatProtectionOffboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOffboardingFilename = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingFilename = "FakeStringValue"
                    AllowSampleSharing = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    EnableExpeditedTelemetryReporting = $True
                    Id = "FakeStringValue"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10 exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedThreatProtectionAutoPopulateOnboardingBlob = $True
                    AdvancedThreatProtectionOffboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOffboardingFilename = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingFilename = "FakeStringValue"
                    AllowSampleSharing = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    EnableExpeditedTelemetryReporting = $True
                    Id = "FakeStringValue"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedThreatProtectionAutoPopulateOnboardingBlob = $True
                    AdvancedThreatProtectionOffboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOffboardingFilename = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingFilename = "FakeStringValue"
                    AllowSampleSharing = $True
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "include"
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "include"
                    }
                    DisplayName = "FakeStringValue"
                    EnableExpeditedTelemetryReporting = $True
                    Id = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }


            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }

            It 'Should return only direct assignments from the Get method' {
                Mock -CommandName Get-MgBetaDeviceManagementDeviceConfigurationAssignment -MockWith {
                    return @(
                        @{
                            id     = 'FakeStringValue_12345'
                            source = 'direct'
                            target = @{
                                '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget'
                            }
                        }
                        @{
                            id     = 'FakeStringValue_12345_67890'
                            source = 'policySets'
                            target = @{
                                '@odata.type' = '#microsoft.graph.allDevicesAssignmentTarget'
                            }
                        }
                    )
                }

                $result = (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Get().ToHashtable()
                @($result.Assignments).Count | Should -Be 1
                $result.Assignments[0].dataType | Should -Be '#microsoft.graph.allDevicesAssignmentTarget'
            }
        }

        Context -Name "The IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AdvancedThreatProtectionAutoPopulateOnboardingBlob = $True
                    AdvancedThreatProtectionOffboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOffboardingFilename = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingBlob = "FakeStringValue"
                    AdvancedThreatProtectionOnboardingFilename = "FakeStringValue"
                    AllowSampleSharing = $False # Updated property
                    Description = "FakeStringValue"
                    DeviceManagementApplicabilityRuleDeviceMode = @{
                        Name = "FakeStringValue"
                        DeviceMode = "standardConfiguration"
                        RuleType = "exclude" # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsEdition = @{
                        Name = "FakeStringValue"
                        OsEditionTypes = @("windows10Enterprise")
                        RuleType = "exclude" # Updated property
                    }
                    DeviceManagementApplicabilityRuleOsVersion = @{
                        Name = "FakeStringValue"
                        MinOSVersion = "10.0.19045.0"
                        MaxOSVersion = "10.0.26100.9999"
                        RuleType = "exclude" # Updated property
                    }
                    DisplayName = "FakeStringValue"
                    EnableExpeditedTelemetryReporting = $True
                    Id = "FakeStringValue"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceConfiguration -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationDefenderOnboardingPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
