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
    -DscResource "IntuneAntivirusPolicyWindows10ConfigMgr" -GenericStubModule $GenericStubPath
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
                    Id              = '12345-12345-12345-12345-12345'
                    Description     = 'My Test'
                    Name            = 'My Test'
                    RoleScopeTagIds = @("FakeStringValue")
                    CreationSource  = 'SccmAv'
                    Technologies    = 'configManager'
                }
            }

            Mock -CommandName Get-M365DSCExportCachedConfigurationPolicies -MockWith {
                return Get-MgBetaDeviceManagementConfigurationPolicy
            }

            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }

            Mock -CommandName Get-IntuneSettingCatalogPolicySetting -MockWith {
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
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicySetting -MockWith {
                return @(
                    @{
                        Id = 0
                        SettingDefinitions = @(
                            @{
                                Id = 'defender_disablerestorepoint'
                                Name = 'DisableRestorePoint'
                                OffsetUri = '/Defender/DisableRestorePoint'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'defender_disablerestorepoint_1'
                                        name = 'Yes'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 1
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'defender_disablerestorepoint'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'defender_disablerestorepoint_1'
                            }
                        }
                    },
                    @{
                        Id = 1
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_securityintelligencelocation'
                                Name = 'SecurityIntelligenceLocation'
                                OffsetUri = '/Config/Defender/SecurityIntelligenceLocation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_defender_securityintelligencelocation'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                            simpleSettingValue = @{
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                value = 'FakeStringValue'
                            }
                        }
                    },
                    @{
                        Id = 2
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_submitsamplesconsent'
                                Name = 'SubmitSamplesConsent'
                                OffsetUri = '/Config/Defender/SubmitSamplesConsent'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_2'
                                        name = 'Never send'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 2
                                        }
                                    }
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_3'
                                        name = 'Send all samples automatically'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 3
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                            choiceSettingValue = @{
                                children = @()
                                value = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_3'
                            }
                        }
                    },
                    @{
                        Id = 3
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_excludedpaths'
                                Name = 'ExcludedPaths'
                                OffsetUri = '/Config/Defender/ExcludedPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                maximumCount = 600
                                minimumCount = 0
                            }
                        )
                        SettingInstance = @{
                            SettingDefinitionId = 'device_vendor_msft_policy_config_defender_excludedpaths'
                            SettingInstanceTemplateReference = $null
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                            simpleSettingCollectionValue = @(
                                @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                    value = 'FakeStringValue'
                                }
                            )
                        }
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyTemplateSettingTemplate -MockWith {
                return @(
                    @{
                        Id = 0
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_securityintelligencelocation'
                                Name = 'SecurityIntelligenceLocation'
                                OffsetUri = '/Config/Defender/SecurityIntelligenceLocation'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingDefinition'
                            }
                        )
                        SettingInstance = @{
                            # Not necessary
                        }
                    },
                    @{
                        Id = 1
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_submitsamplesconsent'
                                Name = 'SubmitSamplesConsent'
                                OffsetUri = '/Config/Defender/SubmitSamplesConsent'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingDefinition'
                                options = @(
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_2'
                                        name = 'Never send'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 2
                                        }
                                    }
                                    @{
                                        itemId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_3'
                                        name = 'Send all samples automatically'
                                        optionValue = @{
                                            '@odata.type' = "#microsoft.graph.deviceManagementConfigurationIntegerSettingValue"
                                            value = 3
                                        }
                                    }
                                )
                            }
                        )
                        SettingInstance = @{
                            # Not necessary
                        }
                    },
                    @{
                        Id = 2
                        SettingDefinitions = @(
                            @{
                                Id = 'device_vendor_msft_policy_config_defender_excludedpaths'
                                Name = 'ExcludedPaths'
                                OffsetUri = '/Config/Defender/ExcludedPaths'
                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionDefinition'
                                maximumCount = 600
                                minimumCount = 0
                            }
                        )
                        SettingInstance = @{
                            # Not necessary
                        }
                    }
                    <# DisableRestorePoint is missing because it's not available in the template we use to fetch the settings #>
                )
            }
        }

        # Test contexts
        Context -Name "The IntuneAntivirusPolicyWindows10ConfigMgr should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    DisableRestorePoint = 1
                    SecurityIntelligenceLocation = "FakeStringValue"
                    SubmitSamplesConsent = 3
                    ExcludedPaths = @("FakeStringValue")
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAntivirusPolicyWindows10ConfigMgr exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    DisableRestorePoint = 1
                    SecurityIntelligenceLocation = "FakeStringValue"
                    SubmitSamplesConsent = 3
                    ExcludedPaths = @("FakeStringValue")
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Absent"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name "The IntuneAntivirusPolicyWindows10ConfigMgr Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    DisableRestorePoint = 1
                    SecurityIntelligenceLocation = "FakeStringValue"
                    SubmitSamplesConsent = 3
                    ExcludedPaths = @("FakeStringValue")
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name "The IntuneAntivirusPolicyWindows10ConfigMgr exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    Description = "My Test"
                    Id = "FakeStringValue"
                    DisplayName = "My Test"
                    DisableRestorePoint = 1
                    SecurityIntelligenceLocation = "FakeStringValue"
                    SubmitSamplesConsent = 2 # Drift
                    ExcludedPaths = @("FakeStringValue")
                    RoleScopeTagIds = @("FakeStringValue")
                    Ensure = "Present"
                    Credential = $Credential;
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -Property $testParams).Set()
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneAntivirusPolicyWindows10ConfigMgr' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
