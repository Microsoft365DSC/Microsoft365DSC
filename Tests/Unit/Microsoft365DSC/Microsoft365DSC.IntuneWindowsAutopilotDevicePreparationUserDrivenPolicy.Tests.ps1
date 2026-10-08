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
    -DscResource "IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy" -GenericStubModule $GenericStubPath
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

            Mock -CommandName Update-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Id = '12345-12345-12345-12345-12345'
                }
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    Name = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    TemplateReference = @{
                       TemplateId = '80d33118-b7b4-40d8-b15f-81be745e053f_1'
                    }
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -MockWith {
                return @{
                    enrollmentTimeDeviceMembershipTargetValidationStatuses = @(
                        @{
                            targetId = '12345-12345-12345-12345-12345'
                            targetValidationErrorCode = 'unknown'
                            validationSucceeded = $true
                        }
                    )
                }
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -ParameterFilter { $GroupId -eq '12345-12345-12345-12345-12345' } -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                    displayName = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgGroup -ParameterFilter { $GroupId -eq '12345-12345-12345-12345-12345' } -MockWith {
                return @{
                    id = '12345-12345-12345-12345-12345'
                    displayName = 'FakeStringValue'
                }
            }

            Mock -CommandName Get-MgGroup -MockWith {
                return @(
                    @{
                        id = '12345-12345-12345-12345-12345'
                        displayName = 'FakeStringValue'
                    }
                )
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].id -like "*FakeStringValue_Script1*" } -MockWith {
                return @{
                    id = 'FakeStringValue_Script1'
                    body = @{
                        id = 'FakeStringValue_Script1'
                        displayName = 'IntuneDeviceConfigurationPlatformScriptWindows_1'
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].id -like "*IntuneDeviceConfigurationPlatformScriptWindows_1*" } -MockWith {
                return @{
                    id = 'FakeStringValue_Script1'
                    body = @{
                        value = @{
                            id = 'FakeStringValue_Script1'
                            displayName = 'IntuneDeviceConfigurationPlatformScriptWindows_1'
                        }
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].id -like "*FakeStringValue_App1*" } -MockWith {
                return @{
                    id = 'FakeStringValue_App1'
                    body = @{
                        id = 'FakeStringValue_App1'
                        displayName = 'IntuneMobileAppsWindowsOfficeSuiteApp_1'
                        '@odata.type' = '#microsoft.graph.officeSuiteApp'
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].id -like "*IntuneMobileAppsWindowsOfficeSuiteApp_1*" } -MockWith {
                return @{
                    id = 'FakeStringValue_App1'
                    body = @{
                        value = @{
                            id = 'FakeStringValue_App1'
                            displayName = 'IntuneMobileAppsWindowsOfficeSuiteApp_1'
                            '@odata.type' = '#microsoft.graph.officeSuiteApp'
                        }
                    }
                }
            }

            Mock -CommandName Invoke-M365DSCGraphBatchRequest -ParameterFilter { $Requests[0].id -like "*FakeStringValue_App2*" -or $Requests[0].id -like "*IntuneMobileAppsWindowsOfficeSuiteApp_2*" } -MockWith {
                return @{
                    id = 'FakeStringValue_App2'
                    body = @{
                        value = @{
                            id = 'FakeStringValue_App2'
                            displayName = 'IntuneMobileAppsWindowsOfficeSuiteApp_2'
                            '@odata.type' = '#microsoft.graph.officeSuiteApp'
                        }
                    }
                }
            }

            Mock -ModuleName M365DSCIntuneUtil -CommandName Get-MgGroup -MockWith {
                return @{
                    Id = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    DisplayName = 'Include'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = '0'
                        SettingDefinitions = @(
                            @{
                                Id = 'enrollment_autopilot_dpp_allowedappids'
                                Name = 'AllowedApplicationIds'
                                OffsetUri = '/AllowedAppIds'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 25
                                valueDefinition = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValueDefinition'
                                }
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'enrollment_autopilot_dpp_allowedappids'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'a9dedfd6-c3b2-46d9-ae39-91fd0dcb7a20'
                            }
                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
                            simpleSettingCollectionValue = @(
                                @{
                                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValue"
                                    value = '{"id":"FakeStringValue_App1","type":"#microsoft.graph.officeSuiteApp"}'
                                }
                            )
                        }
                    }
                    @{
                        Id = '1'
                        SettingDefinitions = @(
                            @{
                                Id = 'enrollment_autopilot_dpp_allowedscriptids'
                                Name = 'AllowedScriptIds'
                                OffsetUri = '/AllowedScriptIds'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                minimumCount = 0
                                maximumCount = 10
                                valueDefinition = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValueDefinition'
                                }
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'enrollment_autopilot_dpp_allowedscriptids'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'ff20a4a9-a2f4-4a2e-84e0-4cd1dc9bed31'
                            }
                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance"
                            simpleSettingCollectionValue = @(
                                @{
                                    '@odata.type' = "#microsoft.graph.deviceManagementConfigurationStringSettingValuee"
                                    value = 'FakeStringValue_Script1'
                                }
                            )
                        }
                    }
                    @{
                        Id = '2'
                        SettingDefinitions = @(
                            @{
                                Id = 'enrollment_autopilot_dpp_accountype'
                                Name = 'AccountType'
                                OffsetUri = '/DeploymentSettings/AccountType'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_accountype_0'
                                        name = 'Administrator'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 0
                                        }
                                    }
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_accountype_1'
                                        name = 'StandardUser'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'enrollment_autopilot_dpp_accountype'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'd4f2a840-86d5-4162-9a08-fa8cc608b94e'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                settingValueTemplateReference = @{
                                    settingValueTemplateId = 'bf13bb47-69ef-4e06-97c1-50c2859a49c2'
                                }
                                value = 'enrollment_autopilot_dpp_accountype_1'
                            }
                        }
                    }
                    @{
                        Id = '3'
                        SettingDefinitions = @(
                            @{
                                Id = 'enrollment_autopilot_dpp_allowdiagnostics'
                                Name = 'AllowDiagnostics'
                                OffsetUri = '/OobeSettings/AllowDiagnostics'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_allowdiagnostics_0'
                                        name = 'No'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = "false"
                                        }
                                    }
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_allowdiagnostics_1'
                                        name = 'Yes'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = "true"
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'enrollment_autopilot_dpp_allowdiagnostics'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = 'e2b7a81b-f243-4abd-bce3-c1856345f405'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                settingValueTemplateReference = @{
                                    settingValueTemplateId = 'c59d26fd-3460-4b26-b47a-f7e202e7d5a3'
                                }
                                value = 'enrollment_autopilot_dpp_allowdiagnostics_1'
                            }
                        }
                    }
                    @{
                        Id = '4'
                        SettingDefinitions = @(
                            @{
                                Id = 'enrollment_autopilot_dpp_allowskip'
                                Name = 'AllowSkip'
                                OffsetUri = '/OobeSettings/AllowSkip'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_allowskip_0'
                                        name = 'No'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = "false"
                                        }
                                    }
                                    @{
                                        itemId = 'enrollment_autopilot_dpp_allowskip_1'
                                        name = 'Yes'
                                        optionValue = @{
                                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            value = "true"
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'enrollment_autopilot_dpp_allowskip'
                            SettingInstanceTemplateReference = @{
                                SettingInstanceTemplateId = '2a71dc89-0f17-4ba9-bb27-af2521d34710'
                            }
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                settingValueTemplateReference = @{
                                    settingValueTemplateId = 'a2323e5e-ac56-4517-8847-b0a6fdb467e7'
                                }
                                value = 'enrollment_autopilot_dpp_allowskip_1'
                            }
                        }
                    }
                )
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return "Credentials"
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstance = $null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
                return @(@{
                    Id       = '12345-12345-12345-12345-12345'
                    Source   = 'direct'
                    SourceId = '12345-12345-12345-12345-12345'
                    Target   = @{
                        DeviceAndAppManagementAssignmentFilterId   = '12345-12345-12345-12345-12345'
                        DeviceAndAppManagementAssignmentFilterType = 'none'
                        '@odata.type' = '#microsoft.graph.groupAssignmentTarget'
                        groupId       = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                    }
                })
            }
        }

        # Test contexts
        Context -Name "The IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountType           = "1";
                    AllowDiagnostics      = "true";
                    AllowedApplications   = @("IntuneMobileAppsWindowsOfficeSuiteApp_1");
                    AllowedScripts        = @("IntuneDeviceConfigurationPlatformScriptWindows_1");
                    AllowSkip             = "true";
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.groupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Include'
                        })
                    )
                    AssignmentTarget = "FakeStringValue"
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
                Should -Invoke -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -ParameterFilter {
                    $Filter -like "*templateReference/templateId eq '80d33118-b7b4-40d8-b15f-81be745e053f_1'*"
                }

                Mock -CommandName Set-MgBetaDeviceManagementConfigurationPolicyEnrollmentTimeDeviceMembershipTarget -MockWith {
                    return @{
                        validationSucceeded                                    = $false
                        enrollmentTimeDeviceMembershipTargetValidationStatuses = @(
                            @{
                                targetId                  = '12345-12345-12345-12345-12345'
                                targetValidationErrorCode = 'securityGroupNotFound'
                                validationSucceeded       = $false
                            }
                        )
                    }
                }

                { (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Set() } | Should -Throw '*securityGroupNotFound*'
            }
        }

        Context -Name "The IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountType           = "1";
                    AllowDiagnostics      = "true";
                    AllowedApplications   = @("IntuneMobileAppsWindowsOfficeSuiteApp_1");
                    AllowedScripts        = @("IntuneDeviceConfigurationPlatformScriptWindows_1");
                    AllowSkip             = "true";
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.groupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Include'
                        })
                    )
                    AssignmentTarget = "FakeStringValue"
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountType           = "1";
                    AllowDiagnostics      = "true";
                    AllowedApplications   = @("IntuneMobileAppsWindowsOfficeSuiteApp_1");
                    AllowedScripts        = @("IntuneDeviceConfigurationPlatformScriptWindows_1");
                    AllowSkip             = "true";
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.groupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Include'
                        })
                    )
                    AssignmentTarget = "FakeStringValue"
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AccountType           = "1";
                    AllowDiagnostics      = "true";
                    AllowedApplications   = @("IntuneMobileAppsWindowsOfficeSuiteApp_1");
                    AllowedScripts        = @("IntuneDeviceConfigurationPlatformScriptWindows_1");
                    AllowSkip             = "false"; # Drift
                    Assignments = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            DataType = '#microsoft.graph.groupAssignmentTarget'
                            groupId = '26d60dd1-fab6-47bf-8656-358194c1a49d'
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            groupDisplayName = 'Include'
                        })
                    )
                    AssignmentTarget = "FakeStringValue"
                    Description = "FakeStringValue"
                    Id = "FakeStringValue"
                    DisplayName = "FakeStringValue"
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneWindowsAutopilotDevicePreparationUserDrivenPolicy' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
