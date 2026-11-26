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
        SCProtectionAlert 'SCProtectionAlert-Example'
        {
            AggregationType                 = "SimpleAggregation";
            AlertBy                         = @("User");
            Category                        = "ThreatManagement";
            Comment                         = "Notifies the security operations team when a user repeatedly sends suspicious messages to external recipients"; # Updated Property
            Disabled                        = $false;
            Ensure                          = "Present";
            Filter                          = "Activity.Operation -eq 'CompromisedWarningAccount'";
            Name                            = "Custom Suspicious email sending patterns detected";
            NotificationCulture             = "en-US";
            NotificationEnabled             = $true;
            NotifyUser                      = @("AdeleV@$TenantId");
            NotifyUserOnFilterMatch         = $false;
            NotifyUserSuppressionExpiryDate = "2026-12-31T00:00:00.0000000Z";
            NotifyUserThrottleThreshold     = 10;
            NotifyUserThrottleWindow        = 60;
            Operation                       = @("CompromisedWarningAccount");
            Severity                        = "Medium";
            ThreatType                      = "Activity";
            Threshold                       = 5;
            TimeWindow                      = 120;
            VolumeThreshold                 = 100;
            ApplicationId                   = $ApplicationId;
            TenantId                        = $TenantId;
            CertificateThumbprint           = $CertificateThumbprint;
        }
    }
}
