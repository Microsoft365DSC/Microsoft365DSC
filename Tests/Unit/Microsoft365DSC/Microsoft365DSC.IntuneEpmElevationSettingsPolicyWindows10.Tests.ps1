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
    -DscResource "IntuneEpmElevationSettingsPolicyWindows10" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '619bd4a4-3b3b-4441-bd6f-3f4c0c444870'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    Name = "FakeStringValue"
                    Platforms = "windows10"
                    RoleScopeTagIds = @("FakeStringValue")
                    Technologies = "mdm,endpointPrivilegeManagement"
                    TemplateReference = @{
                        templateId = "e7dcaba4-959b-46ed-88f0-16ba39b14fd8_1"
                    }
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse'
                                Name = 'DefaultElevationResponse'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/DefaultElevationResponse'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse_0'
                                        name = 'DenyAllRequests'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_allowelevationdetection'
                                Name = 'AllowElevationDetection'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/AllowElevationDetection'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_allowelevationdetection_0'
                                        name = 'No'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationclientsettings_defaultelevationresponse_validation'
                                Name = 'DefaultBehaviorValidation'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/DefaultBehaviorValidation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 100
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_privilegemanagement_elevationclientsettings_defaultelevationresponse_validation_0'
                                        name = 'Business Justification'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_senddata'
                                Name = 'SendDataToMicrosoft'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/SendData'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_senddata_1'
                                        name = 'Yes'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_reportingscope'
                                Name = 'ReportingScope'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/ReportingScope'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_senddata_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_senddata'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_reportingscope_1'
                                        name = 'DiagnosticDataAndManagedElevationsOnly'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                Name = 'EndpointPrivilegeManagement'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/EnableEPM'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                        name = 'Enabled'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '58a79a4b-ba9b-4923-a7a5-6dc1a9f638a4'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @(
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        choiceSettingValue = @{
                                            children = @()
                                            value = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse_0'
                                        }
                                        settingDefinitionId = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse'
                                    }
                                    @{
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                        choiceSettingValue = @{
                                            children = @(
                                                @{
                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                                    choiceSettingValue = @{
                                                        children = @()
                                                        value = 'device_vendor_msft_policy_elevationclientsettings_reportingscope_1'
                                                    }
                                                    settingDefinitionId = 'device_vendor_msft_policy_elevationclientsettings_reportingscope'
                                                }
                                            )
                                            value = 'device_vendor_msft_policy_elevationclientsettings_senddata_1'
                                        }
                                        settingDefinitionId = 'device_vendor_msft_policy_elevationclientsettings_senddata'
                                    }
                                )
                                value = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                            }
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -MockWith {
                return @(
                    @{
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse'
                                Name = 'DefaultElevationResponse'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/DefaultElevationResponse'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse_0'
                                        name = 'DenyAllRequests'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_allowelevationdetection'
                                Name = 'AllowElevationDetection'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/AllowElevationDetection'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_allowelevationdetection_0'
                                        name = 'No'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_privilegemanagement_elevationclientsettings_defaultelevationresponse_validation'
                                Name = 'DefaultBehaviorValidation'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/DefaultBehaviorValidation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 100
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_defaultelevationresponse'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_privilegemanagement_elevationclientsettings_defaultelevationresponse_validation_0'
                                        name = 'Business Justification'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_senddata'
                                Name = 'SendDataToMicrosoft'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/SendData'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_senddata_1'
                                        name = 'Yes'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_reportingscope'
                                Name = 'ReportingScope'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/ReportingScope'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        dependentOn = @(
                                            @{
                                                dependentOn = 'device_vendor_msft_policy_elevationclientsettings_senddata_1'
                                                parentSettingId = 'device_vendor_msft_policy_elevationclientsettings_senddata'
                                            }
                                        )
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_reportingscope_1'
                                        name = 'DiagnosticDataAndManagedElevationsOnly'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                            @{
                                Id = 'device_vendor_msft_policy_elevationclientsettings_enableepm'
                                Name = 'EndpointPrivilegeManagement'
                                OffsetUri = 'PrivilegeManagement/ElevationClientSettings/EnableEPM'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_elevationclientsettings_enableepm_1'
                                        name = 'Enabled'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                    }
                )
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Exclude'
                }
            }

            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
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
        Context -Name "The IntuneEpmElevationSettingsPolicyWindows10 should exist but it DOES NOT" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    DefaultElevationResponse = 0
                    EndpointPrivilegeManagement = 1
                    ReportingScope = 1
                    SendDataToMicrosoft = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the policy from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneEpmElevationSettingsPolicyWindows10 exists but it SHOULD NOT" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    DefaultElevationResponse = 0
                    EndpointPrivilegeManagement = 1
                    ReportingScope = 1
                    SendDataToMicrosoft = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneEpmElevationSettingsPolicyWindows10 Exists and Values are already in the desired state" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    DefaultElevationResponse = 0
                    EndpointPrivilegeManagement = 1
                    ReportingScope = 1
                    SendDataToMicrosoft = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneEpmElevationSettingsPolicyWindows10 exists and values are NOT in the desired state" -Fixture {
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
                    Description = "FakeStringValue"
                    Id = "619bd4a4-3b3b-4441-bd6f-3f4c0c444870"
                    DisplayName = "FakeStringValue"
                    DefaultElevationResponse = 0
                    EndpointPrivilegeManagement = 1
                    ReportingScope = 0 # Drift
                    SendDataToMicrosoft = 1
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneEpmElevationSettingsPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
