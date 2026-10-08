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
    -DscResource "IntuneDeviceRemediation" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementDeviceHealthScript -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementDeviceHealthScript -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementDeviceHealthScript -MockWith {
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            Mock -CommandName Write-Warning -MockWith {
            }

            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementDeviceHealthScript -MockWith {
                return @{
                    Description = "FakeStringValue"
                    DetectionScriptContent = "VGVzdA==" # "Test"
                    DetectionScriptParameters = @(
                        @{
                            '@odata.type' = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            ApplyDefaultValueWhenNotAssigned = $True
                        }
                    )
                    DeviceHealthScriptType = "deviceHealthScript"
                    DisplayName = "FakeStringValue"
                    EnforceSignatureCheck = $True
                    Id = "FakeStringValue"
                    IsGlobalScript = $False
                    Publisher = "FakeStringValue"
                    RemediationScriptContent = "VGVzdA==" # "Test"
                    RemediationScriptParameters = @(
                        @{
                            '@odata.type' = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            ApplyDefaultValueWhenNotAssigned = $True
                        }
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementDeviceHealthScriptAssignment -MockWith {
                return @(
                    @{
                        Id = "FakeStringValue"
                        RunRemediationScript = $False
                        RunSchedule = @{
                            Interval = 1
                            '@odata.type' = "#microsoft.graph.deviceHealthScriptRunOnceSchedule"
                            useUtc = $false
                            time = "01:00:00.0000000"
                            date = "2024-01-01"
                        }
                        Target = @{
                            '@odata.type' = "#microsoft.graph.groupAssignmentTarget"
                            groupId = "FakeStringValue"
                            "DeviceAndAppManagementAssignmentFilterId" = "FakeStringValue"
                            "DeviceAndAppManagementAssignmentFilterType" = "none"
                        }
                    }
                )
            }
        }
        # Test contexts
        Context -Name "The IntuneDeviceRemediation should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneDeviceRemediationPolicyAssignments] @{
                            RunSchedule = [MSFT_IntuneDeviceRemediationRunSchedule] @{
                                Date = '2024-01-01'
                                Time = '01:00:00'
                                Interval = 1
                                DataType = '#microsoft.graph.deviceHealthScriptRunOnceSchedule'
                                UseUtc = $False
                            }
                            RunRemediationScript = $False
                            Assignment = [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                                deviceAndAppManagementAssignmentFilterId = 'FakeStringValue'
                                deviceAndAppManagementAssignmentFilterType = 'none'
                                dataType = '#microsoft.graph.groupAssignmentTarget'
                                groupId = 'FakeStringValue'
                            }
                        })
                    )
                    Description = "FakeStringValue"
                    DetectionScriptContent = "VGVzdA==" # "Test"
                    DetectionScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    DeviceHealthScriptType = "deviceHealthScript"
                    DisplayName = "FakeStringValue"
                    EnforceSignatureCheck = $True
                    Id = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RemediationScriptContent = "VGVzdA==" # "Test"
                    RemediationScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementDeviceHealthScript -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementDeviceHealthScript -Exactly 1
            }
        }

        Context -Name "The IntuneDeviceRemediation exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneDeviceRemediationPolicyAssignments] @{
                            RunSchedule = [MSFT_IntuneDeviceRemediationRunSchedule] @{
                                Date = '2024-01-01'
                                Time = '01:00:00'
                                Interval = 1
                                DataType = '#microsoft.graph.deviceHealthScriptRunOnceSchedule'
                                UseUtc = $False
                            }
                            RunRemediationScript = $False
                            Assignment = [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                                deviceAndAppManagementAssignmentFilterId = 'FakeStringValue'
                                deviceAndAppManagementAssignmentFilterType = 'none'
                                dataType = '#microsoft.graph.groupAssignmentTarget'
                                groupId = 'FakeStringValue'
                            }
                        })
                    )
                    Description = "FakeStringValue"
                    DetectionScriptContent = "VGVzdA==" # "Test"
                    DetectionScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    DeviceHealthScriptType = "deviceHealthScript"
                    DisplayName = "FakeStringValue"
                    EnforceSignatureCheck = $True
                    Id = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RemediationScriptContent = "VGVzdA==" # "Test"
                    RemediationScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    Ensure = 'Absent'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementDeviceHealthScript -Exactly 1
            }
        }
        Context -Name "The IntuneDeviceRemediation Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneDeviceRemediationPolicyAssignments] @{
                            RunSchedule = [MSFT_IntuneDeviceRemediationRunSchedule] @{
                                Date = '2024-01-01'
                                Time = '01:00:00'
                                Interval = 1
                                DataType = '#microsoft.graph.deviceHealthScriptRunOnceSchedule'
                                UseUtc = $False
                            }
                            RunRemediationScript = $False
                            Assignment = [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                                deviceAndAppManagementAssignmentFilterId = 'FakeStringValue'
                                deviceAndAppManagementAssignmentFilterType = 'none'
                                dataType = '#microsoft.graph.groupAssignmentTarget'
                                groupId = 'FakeStringValue'
                            }
                        })
                    )
                    Description = "FakeStringValue"
                    DetectionScriptContent = "VGVzdA==" # "Test"
                    DetectionScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    DeviceHealthScriptType = "deviceHealthScript"
                    DisplayName = "FakeStringValue"
                    EnforceSignatureCheck = $True
                    Id = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RemediationScriptContent = "VGVzdA==" # "Test"
                    RemediationScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneDeviceRemediation exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Assignments = @(
                        ([MSFT_IntuneDeviceRemediationPolicyAssignments] @{
                            RunSchedule = [MSFT_IntuneDeviceRemediationRunSchedule] @{
                                Date = '2024-01-01'
                                Time = '01:00:00'
                                Interval = 1
                                DataType = '#microsoft.graph.deviceHealthScriptRunOnceSchedule'
                                UseUtc = $False
                            }
                            RunRemediationScript = $False
                            Assignment = [MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                                deviceAndAppManagementAssignmentFilterId = 'FakeStringValue'
                                deviceAndAppManagementAssignmentFilterType = 'none'
                                dataType = '#microsoft.graph.groupAssignmentTarget'
                                groupId = 'FakeStringValue'
                            }
                        })
                    )
                    Description = "FakeStringValue"
                    DetectionScriptContent = "VGVzdA==" # "Test"
                    DetectionScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    DeviceHealthScriptType = "deviceHealthScript"
                    DisplayName = "FakeStringValue"
                    EnforceSignatureCheck = $False # Drift
                    Id = "FakeStringValue"
                    Publisher = "FakeStringValue"
                    RemediationScriptContent = "VGVzdA==" # "Test"
                    RemediationScriptParameters = @(
                        ([MSFT_MicrosoftGraphdeviceHealthScriptParameter] @{
                            DefaultValue = $True
                            IsRequired = $True
                            Description = "FakeStringValue"
                            Name = "FakeStringValue"
                            odataType = "#microsoft.graph.deviceHealthScriptBooleanParameter"
                            ApplyDefaultValueWhenNotAssigned = $True
                        })
                    )
                    RoleScopeTagIds = @("FakeStringValue")
                    RunAs32Bit = $True
                    RunAsAccount = "system"
                    Ensure = 'Present'
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceRemediation' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementDeviceHealthScript -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceRemediation' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
