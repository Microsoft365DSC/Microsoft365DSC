<#
This example creates a new Device Enrollment Status Page.
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
        IntuneDeviceComplianceNotificationMessageTemplate 'IntuneDeviceComplianceNotificationMessageTemplate-Example'
        {
            BrandingOptions               = @("includeCompanyName","includeContactInformation","includeCompanyPortalLink");
            LocalizedNotificationMessages = @(
                MSFT_DeviceManagementNotificationMessageTemplate{
                    MessageTemplate = "Ihr Gerät erfüllt die Sicherheitsrichtlinien von Contoso nicht. Bitte wenden Sie sich an den Service Desk."
                    IsDefault       = $False # Updated Property
                    Subject         = "Ihr Gerät ist nicht konform"
                    Locale          = "de-de"
                }
                MSFT_DeviceManagementNotificationMessageTemplate{
                    MessageTemplate = "Your device does not meet the Contoso security policy. Please contact the Service Desk."
                    IsDefault       = $True # Updated Property
                    Subject         = "Your device is not compliant"
                    Locale          = "en-us"
                }
            );
            Description                   = "";
            DisplayName                   = "Non-compliance Notification";
            Ensure                        = "Present";
            RoleScopeTagIds               = @("0");
            ApplicationId                 = $ApplicationId;
            TenantId                      = $TenantId;
            CertificateThumbprint         = $CertificateThumbprint;
        }
    }
}
