<#
This example adds a new Teams Emergency Calling Policy.
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
        TeamsEmergencyCallingPolicy 'TeamsEmergencyCallingPolicy-Example'
        {
            Identity                           = "Headquarters Emergency Calling Policy"
            Description                        = "Notifies the security desk when an emergency call is placed"
            EnhancedEmergencyServiceDisclaimer = "Emergency calls are routed using the address registered for your location."
            ExtendedNotifications              = @(
                MSFT_TeamsEmergencyCallingExtendedNotification{
                    EmergencyDialString       = "112"
                    NotificationGroup         = @("security.desk@contoso.com", "facilities@contoso.com")
                    NotificationDialOutNumber = "+31205550142"
                    NotificationMode          = "ConferenceMuted"
                }
            )
            ExternalLocationLookupMode         = "Enabled"
            NotificationDialOutNumber          = "+31205550100"
            NotificationGroup                  = "security.desk@contoso.com"
            NotificationMode                   = "ConferenceMuted"
            Ensure                             = "Present"
            ApplicationId                      = $ApplicationId
            TenantId                           = $TenantId
            CertificateThumbprint              = $CertificateThumbprint
        }
    }
}
