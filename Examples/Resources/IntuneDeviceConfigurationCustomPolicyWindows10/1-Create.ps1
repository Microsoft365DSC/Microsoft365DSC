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
        IntuneDeviceConfigurationCustomPolicyWindows10 'IntuneDeviceConfigurationCustomPolicyWindows10-Example'
        {
            Assignments                                 = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = '#microsoft.graph.groupAssignmentTarget'
                    deviceAndAppManagementAssignmentFilterType = 'none'
                    groupDisplayName                           = 'Intune Pilot Devices'
                }
            );
            Description                                 = "Hardens Bluetooth and trusts the internal certificate authority through OMA-URI settings";
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
                Name         = "Windows 10 22H2 through Windows 11 24H2"
                MinOSVersion = "10.0.19045.0"
                MaxOSVersion = "10.0.26100.9999"
                RuleType     = "include"
            };
            DisplayName                                 = "Windows OMA-URI Baseline";
            Ensure                                      = "Present";
            OmaSettings                                 = @(
                MSFT_MicrosoftGraphomaSetting{
                    Description = 'Limits Bluetooth to the audio and human interface services'
                    DisplayName = 'Bluetooth services allowed list'
                    IsEncrypted = $false
                    IsReadOnly  = $false
                    OmaUri      = './Device/Vendor/MSFT/Policy/Config/Bluetooth/ServicesAllowedList'
                    Value       = '{0000110b-0000-1000-8000-00805f9b34fb};{00001812-0000-1000-8000-00805f9b34fb}'
                    odataType   = '#microsoft.graph.omaSettingString'
                }
                MSFT_MicrosoftGraphomaSetting{
                    Description = 'Prevents devices from being discoverable over Bluetooth'
                    DisplayName = 'Bluetooth discoverable mode'
                    IsEncrypted = $false
                    IsReadOnly  = $false
                    OmaUri      = './Device/Vendor/MSFT/Policy/Config/Bluetooth/AllowDiscoverableMode'
                    Value       = 0
                    odataType   = '#microsoft.graph.omaSettingInteger'
                }
                MSFT_MicrosoftGraphomaSetting{
                    Description = 'Installs the internal issuing certificate authority in the device root store'
                    DisplayName = 'Internal root certificate'
                    FileName    = 'contoso-root-ca.cer'
                    IsEncrypted = $false
                    IsReadOnly  = $false
                    OmaUri      = './Device/Vendor/MSFT/RootCATrustedCertificates/Root/8f43288ad272f3103b6fb1428485ea3014c0bcfe/EncodedCertificate'
                    Value       = '<base64-encoded-root-certificate>'
                    odataType   = '#microsoft.graph.omaSettingBase64'
                }
            );
            RoleScopeTagIds                             = @("0");
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
