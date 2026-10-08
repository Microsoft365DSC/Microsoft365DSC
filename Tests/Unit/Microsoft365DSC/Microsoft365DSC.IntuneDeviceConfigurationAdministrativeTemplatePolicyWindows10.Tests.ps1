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
    -DscResource 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString (New-GUID).ToString() -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin@onmicrosoft.com', $secpasswd)

            Mock -ModuleName M365DSCUtil -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-MSCloudLoginConnectionProfile -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Write-M365DSCHost -MockWith {
            }

            Mock -CommandName Update-MgBetaDeviceManagementGroupPolicyConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementGroupPolicyConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfiguration -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.GroupPolicyConfiguration'
                    Description                      = 'FakeStringValue'
                    DisplayName                      = 'FakeStringValue'
                    Id                               = 'FakeStringValue'
                    PolicyConfigurationIngestionType = 'unknown'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValue -MockWith {
                return @(
                    @{
                        ConfigurationType                = 'policy'
                        Enabled                          = $true
                        Id                               = 'fakeDefinitionValueId'
                        PolicyConfigurationIngestionType = 'unknown'
                    }
                )
            }

            Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValueDefinition -MockWith {
                return @{
                    Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                    DisplayName  = 'Configure allowed app/extension types'
                    CategoryPath = '\Google\Google Chrome\Extensions'
                    PolicyType   = 'admxIngested'
                    SupportedOn  = 'Microsoft Windows 7 or later'
                    ClassType    = 'machine'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValuePresentationValue -MockWith {
                return @{
                    '@odata.type' = '#microsoft.graph.groupPolicyPresentationValueList'
                    values        = @(
                        @{
                            name = "`"hosted_app`""
                        }
                    )
                    Id                               = 'fakePresentationId'
                    Presentation                     = @{
                        Id    = 'fakePresentationDefinitionId'
                        Label = 'fakePresentationLabel'
                    }
                    PolicyConfigurationIngestionType = 'unknown'
                }
            }

            Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfigurationAssignment -MockWith {
                return @(@{
                        target = @{
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            '@odata.type'                              = '#microsoft.graph.allDevicesAssignmentTarget'
                        }
                    })
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Invoke-M365DSCGraphRequest -MockWith {
            }

            $Script:exportedInstance = $null
            $Script:ExportMode = $false
        }
        # Test contexts
        Context -Name 'The IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                      = 'FakeStringValue'
                    DisplayName                      = 'FakeStringValue'
                    Id                               = 'FakeStringValue'
                    PolicyConfigurationIngestionType = 'unknown'
                    Ensure                           = 'Present'
                    Credential                       = $Credential
                    Assignments                      = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                        })
                    )
                    DefinitionValues                 = @(
                        ([MSFT_IntuneGroupPolicyDefinitionValue] @{
                            ConfigurationType  = 'policy'
                            PresentationValues = @(
                                ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValue] @{
                                    presentationDefinitionId    = '98210829-af9b-4020-8d96-3e4108557a95'
                                    presentationDefinitionLabel = 'Types of extensions/apps that are allowed to be installed'
                                    KeyValuePairValues          = @(
                                        ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair] @{
                                            Name = 'hosted_app'
                                        })
                                    )
                                    Id                          = '7312a452-e087-4290-9b9f-3f14a304c18d'
                                    odataType                   = '#microsoft.graph.groupPolicyPresentationValueList'
                                })
                            )
                            Id                 = 'f3047f6a-550e-4b5e-b3da-48fc951b72fc'
                            Definition         = ([MSFT_IntuneGroupPolicyDefinitionValueDefinition] @{
                                    Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                                    DisplayName  = 'Configure allowed app/extension types'
                                    CategoryPath = '\Google\Google Chrome\Extensions'
                                    PolicyType   = 'admxIngested'
                                    SupportedOn  = 'Microsoft Windows 7 or later'
                                    ClassType    = 'machine'
                                })
                            Enabled            = $True
                        })
                    )
                }

                Mock -CommandName Get-MgBetaDeviceManagementGroupPolicyConfiguration -MockWith {
                    return $null
                }

                Mock -CommandName New-MgBetaDeviceManagementGroupPolicyConfiguration -MockWith {
                    return @{
                        id          = 'fakeNewId'
                        displayName = 'fakeNewDisplayName'
                    }
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementGroupPolicyConfiguration -Exactly 1
                Should -Invoke -CommandName Update-DeviceConfigurationPolicyAssignment -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                      = 'FakeStringValue'
                    DisplayName                      = 'FakeStringValue'
                    Id                               = 'FakeStringValue'
                    PolicyConfigurationIngestionType = 'unknown'
                    Ensure                           = 'Absent'
                    Credential                       = $Credential
                    Assignments                      = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                        })
                    )
                    DefinitionValues                 = @(
                        ([MSFT_IntuneGroupPolicyDefinitionValue] @{
                            ConfigurationType  = 'policy'
                            PresentationValues = @(
                                ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValue] @{
                                    presentationDefinitionId    = '98210829-af9b-4020-8d96-3e4108557a95'
                                    presentationDefinitionLabel = 'Types of extensions/apps that are allowed to be installed'
                                    KeyValuePairValues          = @(
                                        ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair] @{
                                            Name = 'hosted_app'
                                        })
                                    )
                                    Id                          = '7312a452-e087-4290-9b9f-3f14a304c18d'
                                    odataType                   = '#microsoft.graph.groupPolicyPresentationValueList'
                                })
                            )
                            Id                 = 'f3047f6a-550e-4b5e-b3da-48fc951b72fc'
                            Definition         = ([MSFT_IntuneGroupPolicyDefinitionValueDefinition] @{
                                    Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                                    DisplayName  = 'Configure allowed app/extension types'
                                    CategoryPath = '\Google\Google Chrome\Extensions'
                                    PolicyType   = 'admxIngested'
                                    SupportedOn  = 'Microsoft Windows 7 or later'
                                    ClassType    = 'machine'
                                })
                            Enabled            = $True
                        })
                    )
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementGroupPolicyConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                      = 'FakeStringValue'
                    DisplayName                      = 'FakeStringValue'
                    Id                               = 'FakeStringValue'
                    PolicyConfigurationIngestionType = 'unknown'
                    Ensure                           = 'Present'
                    Credential                       = $Credential
                    Assignments                      = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                        })
                    )
                    DefinitionValues                 = @(
                        ([MSFT_IntuneGroupPolicyDefinitionValue] @{
                            ConfigurationType  = 'policy'
                            PresentationValues = @(
                                ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValue] @{
                                    presentationDefinitionId    = 'fakePresentationDefinitionId'
                                    presentationDefinitionLabel = 'fakePresentationDefinitionLabel'
                                    KeyValuePairValues          = @(
                                        ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair] @{
                                            Name = 'hosted_app'
                                        })
                                    )
                                    Id                          = 'fakePresentationId'
                                    odataType                   = '#microsoft.graph.groupPolicyPresentationValueList'
                                })
                            )
                            Id                 = 'fakeDefinitionValueId'
                            Definition         = ([MSFT_IntuneGroupPolicyDefinitionValueDefinition] @{
                                    Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                                    DisplayName  = 'Configure allowed app/extension types'
                                    CategoryPath = '\Google\Google Chrome\Extensions'
                                    PolicyType   = 'admxIngested'
                                    SupportedOn  = 'Microsoft Windows 7 or later'
                                    ClassType    = 'machine'
                                })
                            Enabled            = $True
                        })
                    )
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description                      = 'FakeStringValue'
                    DisplayName                      = 'FakeStringValue'
                    Id                               = 'FakeStringValue'
                    PolicyConfigurationIngestionType = 'unknown'
                    Ensure                           = 'Present'
                    Credential                       = $Credential
                    Assignments                      = @(
                        ([MSFT_DeviceManagementConfigurationPolicyAssignments] @{
                            deviceAndAppManagementAssignmentFilterType = 'none'
                            dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                        })
                    )
                    DefinitionValues                 = @(
                        ([MSFT_IntuneGroupPolicyDefinitionValue] @{
                            ConfigurationType  = 'policy'
                            PresentationValues = @(
                                ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValue] @{
                                    presentationDefinitionId    = 'fakePresentationDefinitionId'
                                    presentationDefinitionLabel = 'fakePresentationDefinitionLabel'
                                    KeyValuePairValues          = @(
                                        ([MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair] @{
                                            Name = 'hosted_app_new' # Updated property
                                        })
                                    )
                                    Id                          = 'fakePresentationId'
                                    odataType                   = '#microsoft.graph.groupPolicyPresentationValueList'
                                })
                            )
                            Id                 = 'fakeDefinitionValueId'
                            Definition         = ([MSFT_IntuneGroupPolicyDefinitionValueDefinition] @{
                                    Id           = '37ab8b81-47d7-46d8-8b99-81d9cecdcce9'
                                    DisplayName  = 'Configure allowed app/extension types'
                                    CategoryPath = '\Google\Google Chrome\Extensions'
                                    PolicyType   = 'admxIngested'
                                    SupportedOn  = 'Microsoft Windows 7 or later'
                                    ClassType    = 'machine'
                                })
                            Enabled            = $True
                        })
                    )
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-MgBetaDeviceManagementGroupPolicyConfiguration -Exactly 1
                Should -Invoke -CommandName Update-DeviceConfigurationPolicyAssignment -Exactly 1
                Should -Invoke -CommandName Invoke-M365DSCGraphRequest -Exactly 1
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
