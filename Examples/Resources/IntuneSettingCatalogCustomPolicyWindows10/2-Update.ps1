<#
This example is used to test new resources and showcase the usage of new resources being worked on.
It is not meant to use as a production baseline.
#>

Configuration Example
{
    param
    (
        [Parameter()]
        [System.String]
        $ApplicationId,

        [Parameter()]
        [System.String]
        $TenantId,

        [Parameter()]
        [System.String]
        $CertificateThumbprint
    )

    Import-DscResource -ModuleName Microsoft365DSC

    Node localhost
    {
        IntuneSettingCatalogCustomPolicyWindows10 'IntuneSettingCatalogCustomPolicyWindows10-Example'
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            Description           = "Baseline lockdown settings for shared Windows 11 devices in retail branches"; # Updated Property
            Ensure                = "Present";
            Name                  = "Windows 11 Device Lockdown";
            Platforms             = "windows10";
            RoleScopeTagIds       = @("0");
            Settings              = @(
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_abovelock_allowcortanaabovelock_1'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_abovelock_allowcortanaabovelock'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        SettingDefinitionId = 'device_vendor_msft_policy_config_applicationdefaults_defaultassociationsconfiguration'
                        simpleSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue{
                            odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                            StringValue = '<base64-encoded-default-associations>'
                        }
                        odataType           = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_applicationdefaults_enableappurihandlers_1'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_applicationdefaults_enableappurihandlers'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_defender_allowarchivescanning_1'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_defender_allowarchivescanning'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_defender_allowbehaviormonitoring_1'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_defender_allowbehaviormonitoring'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_defender_allowcloudprotection_1'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_defender_allowcloudprotection'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        SettingDefinitionId          = 'device_vendor_msft_policy_config_defender_excludedpaths'
                        simpleSettingCollectionValue = @(
                            MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue{
                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                StringValue = 'C:\Program Files\Contoso\Ledger'
                            }
                            MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue{
                                odataType   = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                                StringValue = 'D:\LineOfBusiness'
                            }
                        )
                        odataType                    = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                    }
                }
                MSFT_MicrosoftGraphdeviceManagementConfigurationSetting{
                    SettingInstance = MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance{
                        choiceSettingValue  = MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue{
                            Value = 'device_vendor_msft_policy_config_defender_submitsamplesconsent_3'
                        }
                        SettingDefinitionId = 'device_vendor_msft_policy_config_defender_submitsamplesconsent'
                        odataType           = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                    }
                }
            );
            Technologies          = "mdm";
            TemplateReference     = MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference{
                TemplateFamily = 'none'
            };
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
