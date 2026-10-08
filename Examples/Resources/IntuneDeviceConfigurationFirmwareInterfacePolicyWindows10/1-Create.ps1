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
        IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10 'IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    dataType                                   = '#microsoft.graph.allDevicesAssignmentTarget'
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType         = '#microsoft.graph.exclusionGroupAssignmentTarget'
                    groupDisplayName = 'Intune Excluded Devices'
                }
            );
            Bluetooth                                   = "notConfigured";
            BootFromBuiltInNetworkAdapters              = "notConfigured";
            BootFromExternalMedia                       = "notConfigured";
            Cameras                                     = "enabled";
            ChangeUefiSettingsPermission                = "notConfiguredOnly";
            Description                                 = "Locks the firmware interface on corporate laptops so users cannot boot from external media";
            DeviceManagementApplicabilityRuleDeviceMode = MSFT_DeviceManagementApplicabilityRuleDeviceMode{
                Name       = "Standard configuration devices only"
                DeviceMode = "standardConfiguration"
                RuleType   = "include"
            };
            DeviceManagementApplicabilityRuleOsEdition  = MSFT_DeviceManagementApplicabilityRuleOsEdition{
                Name           = "Enterprise and Professional editions only"
                OsEditionTypes = @("windows10Enterprise", "windows10Professional")
                RuleType       = "include"
            };
            DeviceManagementApplicabilityRuleOsVersion  = MSFT_DeviceManagementApplicabilityRuleOsVersion{
                Name         = "Windows 10 1809 or later"
                MinOSVersion = "10.0.17763.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "Device Firmware Interface";
            Ensure                                      = "Present";
            FrontCamera                                 = "enabled";
            InfraredCamera                              = "enabled";
            Microphone                                  = "notConfigured";
            MicrophonesAndSpeakers                      = "enabled";
            NearFieldCommunication                      = "notConfigured";
            Radios                                      = "enabled";
            RearCamera                                  = "enabled";
            RoleScopeTagIds                             = @("0");
            SdCard                                      = "notConfigured";
            SimultaneousMultiThreading                  = "enabled";
            UsbTypeAPort                                = "notConfigured";
            VirtualizationOfCpuAndIO                    = "enabled";
            WakeOnLAN                                   = "notConfigured";
            WakeOnPower                                 = "notConfigured";
            WiFi                                        = "notConfigured";
            WindowsPlatformBinaryTable                  = "enabled";
            WirelessWideAreaNetwork                     = "notConfigured";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
