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
    -DscResource 'IntuneSettingCatalogCustomPolicyWindows10' -GenericStubModule $GenericStubPath
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

            Mock -CommandName New-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -ModuleName '_Shared' -MockWith {
                return 'Credentials'
            }

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                return @{
                    Description  = 'FakeStringValue'
                    Id           = 'FakeStringValue'
                    Name         = 'FakeStringValue'
                    Platforms    = 'windows10'
                    Settings     = @(
                        @{
                            SettingInstance = @{
                                simpleSettingValue = @{
                                    value   = 'fakeValue'
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                }
                                '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                SettingDefinitionId  = 'stringSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                simpleSettingValue = @{
                                    valueState    = 'invalid'
                                    value   = 'fakeValue'
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                }
                                '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                SettingDefinitionId  = 'secretSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                simpleSettingValue = @{
                                    value      = 25
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                }
                                '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                SettingDefinitionId  = 'integerSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                choiceSettingValue = @{
                                    value    = 'choiceSettingValue'
                                    children = @()
                                }
                                '@odata.type'      = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                SettingDefinitionId  = 'choiceSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                '@odata.type'     = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                groupSettingValue = @{
                                    children = @(
                                        @{
                                            simpleSettingValue  = @{
                                                value   = 'fakeValue'
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            }
                                            SettingDefinitionId = 'stringSettingDefinitionId'
                                            '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                        }
                                        @{
                                            simpleSettingValue  = @{
                                                valueState    = 'invalid'
                                                value   = 'fakeValue'
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                            }
                                            SettingDefinitionId = 'secretSettingDefinitionId'
                                            '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                        }
                                    )
                                }
                                SettingDefinitionId  = 'groupSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                '@odata.type'                = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                simpleSettingCollectionValue = @(
                                    @{
                                        value   = 'firstValue'
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                    }
                                    @{
                                        value   = 'secondValue'
                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                    }
                                )
                                SettingDefinitionId  = 'simpleCollectionSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                '@odata.type'                = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance'
                                choiceSettingCollectionValue = @(
                                    @{
                                        value    = 'firstChoice'
                                        children = @()
                                    }
                                    @{
                                        value    = 'secondChoice'
                                        children = @()
                                    }
                                )
                                SettingDefinitionId  = 'choiceCollectionSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                                groupSettingCollectionValue = @(
                                    @{
                                        children = @(
                                            @{
                                                simpleSettingValue  = @{
                                                    value   = 'collectionChildValue'
                                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                }
                                                SettingDefinitionId = 'stringSettingDefinitionId'
                                                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            }
                                            @{
                                                simpleSettingCollectionValue = @(
                                                    @{
                                                        value   = 'childCollectionValue'
                                                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                    }
                                                )
                                                SettingDefinitionId = 'simpleCollectionSettingDefinitionId'
                                                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                            }
                                        )
                                    }
                                )
                                SettingDefinitionId  = 'groupCollectionSettingDefinitionId'
                            }
                        }
                        @{
                            SettingInstance = @{
                                '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                SettingDefinitionId              = 'templateRefSettingDefinitionId'
                                settingInstanceTemplateReference = @{
                                    settingInstanceTemplateId = 'instanceTemplateId'
                                }
                                groupSettingValue = @{
                                    settingValueTemplateReference = @{
                                        settingValueTemplateId = 'valueTemplateId'
                                    }
                                    children = @(
                                        @{
                                            SettingDefinitionId              = 'stringSettingDefinitionId'
                                            '@odata.type'                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                            settingInstanceTemplateReference = @{
                                                settingInstanceTemplateId = 'childInstanceTemplateId'
                                            }
                                            simpleSettingValue = @{
                                                value   = 'templatedValue'
                                                '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                settingValueTemplateReference = @{
                                                    settingValueTemplateId = 'childValueTemplateId'
                                                }
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    )
                    Technologies = 'mdm'
                    TemplateReference = @{
                        TemplateFamily = 'none'
                    }
                }
            }

            # Mock Write-M365DSCHost to hide output during the tests
            Mock -CommandName Write-M365DSCHost -MockWith {
            }
            $Script:exportedInstances =$null
            $Script:ExportMode = $false

            Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Update-DeviceConfigurationPolicyAssignment -MockWith {
            }
            Mock -CommandName Update-IntuneDeviceConfigurationPolicy -MockWith {
            }
        }
        # Test contexts
        Context -Name 'The IntuneSettingCatalogCustomPolicyWindows10 should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description  = 'FakeStringValue'
                    Id           = 'FakeStringValue'
                    Name         = 'FakeStringValue'
                    Platforms    = 'Windows10'
                    Settings     = @(
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            valueState  = 'invalid'
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            IntValue  = 25
                                            odataType = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    choiceSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                            value    = 'choiceSettingValue'
                                            children = @()
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingValue'
                                            children  = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            valueState  = 'invalid'
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                            )
                                        })
                                })
                        })
                    )
                    Technologies = 'mdm'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }

                Mock -CommandName Get-MgBetaDeviceManagementConfigurationPolicy -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName New-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name 'The IntuneSettingCatalogCustomPolicyWindows10 exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description  = 'FakeStringValue'
                    Id           = 'FakeStringValue'
                    Name         = 'FakeStringValue'
                    Platforms    = 'windows10'
                    Settings     = @(
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            valueState  = 'invalid'
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            IntValue  = 25
                                            odataType = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    choiceSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                            value    = 'choiceSettingValue'
                                            children = @()
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingValue'
                                            children  = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            valueState  = 'invalid'
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                            )
                                        })
                                })
                        })
                    )
                    Technologies = 'mdm'
                    Ensure       = 'Absent'
                    Credential   = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Remove-MgBetaDeviceManagementConfigurationPolicy -Exactly 1
            }
        }

        Context -Name 'The IntuneSettingCatalogCustomPolicyWindows10 Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description  = 'FakeStringValue'
                    Id           = 'FakeStringValue'
                    Name         = 'FakeStringValue'
                    Platforms    = 'windows10'
                    Settings     = @(
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            valueState  = 'invalid'
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                        })
                                    SettingDefinitionId = 'secretSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            IntValue  = 25
                                            odataType = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        })
                                    SettingDefinitionId = 'integerSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    choiceSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                            value    = 'choiceSettingValue'
                                            children = @()
                                        })
                                    SettingDefinitionId = 'choiceSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                    SettingDefinitionId = 'groupSettingDefinitionId'
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            #odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingValue'
                                            children  = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            valueState  = 'invalid'
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                                        })
                                                    SettingDefinitionId = 'secretSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                            )
                                        })
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                    SettingDefinitionId          = 'simpleCollectionSettingDefinitionId'
                                    simpleSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                StringValue = 'firstValue'
                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            })
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                StringValue = 'secondValue'
                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                    = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance'
                                    SettingDefinitionId          = 'choiceCollectionSettingDefinitionId'
                                    choiceSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                                value = 'firstChoice'
                                            })
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                                value = 'secondChoice'
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                   = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                                    SettingDefinitionId         = 'groupCollectionSettingDefinitionId'
                                    groupSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                                children = @(
                                                    ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                        simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                                StringValue = 'collectionChildValue'
                                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            })
                                                        SettingDefinitionId = 'stringSettingDefinitionId'
                                                        odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                    })
                                                    ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                        simpleSettingCollectionValue = @(
                                                            ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                                    StringValue = 'childCollectionValue'
                                                                    odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                                })
                                                        )
                                                        SettingDefinitionId = 'simpleCollectionSettingDefinitionId'
                                                        odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                                    })
                                                )
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                        = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                    SettingDefinitionId              = 'templateRefSettingDefinitionId'
                                    SettingInstanceTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                            SettingInstanceTemplateId = 'instanceTemplateId'
                                        })
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            SettingValueTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                                                    settingValueTemplateId = 'valueTemplateId'
                                                })
                                            children = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    SettingDefinitionId              = 'stringSettingDefinitionId'
                                                    odataType                        = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                    SettingInstanceTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                                            SettingInstanceTemplateId = 'childInstanceTemplateId'
                                                        })
                                                    simpleSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'templatedValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            SettingValueTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                                                                    settingValueTemplateId = 'childValueTemplateId'
                                                                })
                                                        })
                                                })
                                            )
                                        })
                                })
                        })
                    )
                    TemplateReference = [MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference] @{
                        TemplateFamily = 'none'
                    }
                    Technologies = 'mdm'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }
            }

            It 'Should return true from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $true
            }
        }

        Context -Name 'The IntuneSettingCatalogCustomPolicyWindows10 exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    Description  = 'FakeStringValue'
                    Id           = 'FakeStringValue'
                    Name         = 'FakeStringValue'
                    Platforms    = 'windows10'
                    Settings     = @(
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                        })
                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            valueState  = 'invalid'
                                            StringValue = 'fakeValue'
                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                        })
                                    SettingDefinitionId = 'secretSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                            IntValue  = 25
                                            odataType = '#microsoft.graph.deviceManagementConfigurationIntegerSettingValue'
                                        })
                                    SettingDefinitionId = 'integerSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    choiceSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                            value    = 'choiceSettingValue'
                                            children = @()
                                        })
                                    SettingDefinitionId = 'choiceSettingDefinitionId'
                                    odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                    SettingDefinitionId = 'groupSettingDefinitionId'
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            odataType = '#microsoft.graph.deviceManagementConfigurationGroupSettingValue'
                                            children  = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'fakeValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                        })
                                                    SettingDefinitionId = 'stringSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            valueState  = 'invalid'
                                                            StringValue = 'updatedValue' # Updated property
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationSecretSettingValue'
                                                        })
                                                    SettingDefinitionId = 'secretSettingDefinitionId'
                                                    odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                })
                                            )
                                        })
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                    SettingDefinitionId          = 'simpleCollectionSettingDefinitionId'
                                    simpleSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                StringValue = 'firstValue'
                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            })
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                StringValue = 'secondValue'
                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                    = '#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance'
                                    SettingDefinitionId          = 'choiceCollectionSettingDefinitionId'
                                    choiceSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                                value = 'firstChoice'
                                            })
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] @{
                                                value = 'secondChoice'
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                   = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                                    SettingDefinitionId         = 'groupCollectionSettingDefinitionId'
                                    groupSettingCollectionValue = @(
                                        ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                                children = @(
                                                    ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                        simpleSettingValue  = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                                StringValue = 'collectionChildValue'
                                                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            })
                                                        SettingDefinitionId = 'stringSettingDefinitionId'
                                                        odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                    })
                                                    ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                        simpleSettingCollectionValue = @(
                                                            ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                                    StringValue = 'childCollectionValue'
                                                                    odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                                })
                                                        )
                                                        SettingDefinitionId = 'simpleCollectionSettingDefinitionId'
                                                        odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                                                    })
                                                )
                                            })
                                    )
                                })
                        })
                        ([MSFT_MicrosoftGraphdeviceManagementConfigurationSetting] @{
                            SettingInstance = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                    odataType                        = '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance'
                                    SettingDefinitionId              = 'templateRefSettingDefinitionId'
                                    SettingInstanceTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                            SettingInstanceTemplateId = 'instanceTemplateId'
                                        })
                                    groupSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] @{
                                            SettingValueTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                                                    settingValueTemplateId = 'valueTemplateId'
                                                })
                                            children = @(
                                                ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] @{
                                                    SettingDefinitionId              = 'stringSettingDefinitionId'
                                                    odataType                        = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                                                    SettingInstanceTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                                            SettingInstanceTemplateId = 'childInstanceTemplateId'
                                                        })
                                                    simpleSettingValue = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] @{
                                                            StringValue = 'templatedValue'
                                                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                                            SettingValueTemplateReference = ([MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                                                                    settingValueTemplateId = 'childValueTemplateId'
                                                                })
                                                        })
                                                })
                                            )
                                        })
                                })
                        })
                    )
                    TemplateReference = [MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference] @{
                        TemplateFamily = 'none'
                    }
                    Technologies = 'mdm'
                    Ensure       = 'Present'
                    Credential   = $Credential
                }
            }

            It 'Should return Values from the Get method' {
                ((New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Get().ToHashtable()).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Test() | Should -Be $false
            }

            It 'Should call the Set method' {
                (New-M365DSCResourceInstance -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -Property $testParams).Set()
                Should -Invoke -CommandName Update-IntuneDeviceConfigurationPolicy -Exactly 1 -ParameterFilter {
                    [System.String]::IsNullOrEmpty($TemplateReferenceId)
                }
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
                $result = Invoke-M365DSCResourceMethod -ResourceName 'IntuneSettingCatalogCustomPolicyWindows10' -MethodName 'Export' -Parameters $testParams
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
