<#
This example updates a new Intune Custom Configuration Policy for iOs devices
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

    Import-DscResource -ModuleName 'Microsoft365DSC'

    Node localhost
    {
        IntuneDeviceConfigurationCustomPolicyiOS "IntuneDeviceConfigurationCustomPolicyiOS-Example"
        {
            Assignments           = @(
                MSFT_DeviceManagementConfigurationPolicyAssignments{
                    dataType                                   = "#microsoft.graph.groupAssignmentTarget"
                    deviceAndAppManagementAssignmentFilterType = "none"
                    groupDisplayName                           = "Intune Pilot Devices"
                }
            );
            Description           = "Delivers the corporate Wi-Fi profile to company owned iPhones and iPads"; # Updated Property
            DisplayName           = "iOS Wi-Fi Payload";
            Ensure                = "Present";
            Payload               = "<base64-encoded-mobileconfig>";
            PayloadFileName       = "corporate-wifi.mobileconfig";
            PayloadName           = "Corporate Wi-Fi";
            RoleScopeTagIds       = @("0");
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
