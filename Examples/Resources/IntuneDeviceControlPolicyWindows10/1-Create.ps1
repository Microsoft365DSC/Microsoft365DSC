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
        IntuneDeviceControlPolicyWindows10 'IntuneDeviceControlPolicyWindows10-Example'
        {
            AllowAdvertising                            = "1";
            AllowBluetooth                              = "2";
            AllowDirectMemoryAccess                     = "0";
            AllowDiscoverableMode                       = "0";
            AllowFullScanRemovableDriveScanning         = "1";
            AllowPrepairing                             = "0";
            AllowPromptedProximalConnections            = "0";
            AllowStorageCard                            = "1";
            AllowUSBConnection                          = "1";
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
            DefaultEnforcement                          = "1";
            Description                                 = "Restricts removable storage and Bluetooth on managed workstations";
            DeviceControlEnabled                        = "1";
            DeviceEnumerationPolicy                     = "1";
            DeviceInstall_Allow_Deny_Layered            = "1";
            DeviceInstall_Classes_Allow                 = "1";
            DeviceInstall_Classes_Allow_List            = @("{4d36e967-e325-11ce-bfc1-08002be10318}");
            DeviceInstall_Classes_Deny                  = "1";
            DeviceInstall_Classes_Deny_List             = @("{36fc9e60-c465-11cf-8056-444553540000}");
            DeviceInstall_Classes_Deny_Retroactive      = "1";
            DeviceInstall_IDs_Allow                     = "1";
            DeviceInstall_IDs_Allow_List                = @("USB\VID_0951&PID_1666");
            DeviceInstall_IDs_Deny                      = "1";
            DeviceInstall_IDs_Deny_List                 = @("USB\VID_0781&PID_5583");
            DeviceInstall_IDs_Deny_Retroactive          = "1";
            DeviceInstall_Instance_IDs_Allow            = "1";
            DeviceInstall_Instance_IDs_Allow_List       = @("USB\VID_0951&PID_1666\0018F30CB8B5F0C0D9C50E5A");
            DeviceInstall_Instance_IDs_Deny             = "1";
            DeviceInstall_Instance_IDs_Deny_List        = @("USB\VID_0781&PID_5583\4C530001120523113144");
            DeviceInstall_Instance_IDs_Deny_Retroactive = "1";
            DeviceInstall_Removable_Deny                = "1";
            DeviceInstall_Unspecified_Deny              = "1";
            DisplayName                                 = 'Device Control';
            Ensure                                      = "Present";
            PolicyRule                                  = @(
                MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRule{
                    Name  = "Block write access to removable storage"
                    Entry = @(
                        MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRuleEntry{
                            AccessMask = @(
                                2
                                16
                            )
                            Type       = "deny"
                            Options    = "3"
                        }
                    )
                }
            );
            RemovableDiskDenyWriteAccess                = "1";
            RoleScopeTagIds                             = @("0");
            ServicesAllowedList                         = @("{0000110a-0000-1000-8000-00805f9b34fb}", "{0000111e-0000-1000-8000-00805f9b34fb}");
            WPDDevices_DenyRead_Access_1                = "1";
            WPDDevices_DenyRead_Access_2                = "1";
            WPDDevices_DenyWrite_Access_1               = "1";
            WPDDevices_DenyWrite_Access_2               = "1";
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
