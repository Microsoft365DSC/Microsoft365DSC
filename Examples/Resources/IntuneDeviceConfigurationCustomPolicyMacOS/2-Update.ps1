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
        IntuneDeviceConfigurationCustomPolicyMacOS 'IntuneDeviceConfigurationCustomPolicyMacOS-Example'
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.allDevicesAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                }
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.exclusionGroupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Excluded Devices"
                }
            );
            DeploymentChannel     = "deviceChannel";
            Description           = "Pins the Safari homepage on managed Macs in the Zurich office"; # Updated Property
            DisplayName           = "macOS Safari Homepage";
            Payload               = '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadDisplayName</key>
            <string>Safari Homepage</string>
            <key>PayloadIdentifier</key>
            <string>com.contoso.safari.homepage</string>
            <key>PayloadType</key>
            <string>com.apple.Safari</string>
            <key>PayloadUUID</key>
            <string>2c9e2f0b-2b3a-4e45-9e6d-4f0f5f2d9a11</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>HomePage</key>
            <string>https://intranet.contoso.com</string>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>Contoso Safari Homepage</string>
    <key>PayloadIdentifier</key>
    <string>com.contoso.safari</string>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>8f4c1b6d-7b1e-4e7f-9c23-1d2b3a4c5d6e</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>';
            PayloadFileName       = "contoso-safari-homepage.mobileconfig";
            PayloadName           = "Contoso Safari Homepage";
            RoleScopeTagIds       = @("0");
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
