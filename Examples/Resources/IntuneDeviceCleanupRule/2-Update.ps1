<#
This example updates a device cleanup rule.
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
        IntuneDeviceCleanupRule 'IntuneDeviceCleanupRule-Example'
        {
            DisplayName                            = "iOS Inactive Device Cleanup";
            Description                            = "Removes iPhone and iPad devices that stopped checking in with Intune";
            DeviceCleanupRulePlatformType          = "ios";
            DeviceInactivityBeforeRetirementInDays = 120; # Updated Property
            Ensure                                 = 'Present';
            ApplicationId                          = $ApplicationId;
            TenantId                               = $TenantId;
            CertificateThumbprint                  = $CertificateThumbprint;
        }
    }
}
