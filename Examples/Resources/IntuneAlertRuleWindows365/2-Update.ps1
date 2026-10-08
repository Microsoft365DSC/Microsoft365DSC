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
        IntuneAlertRuleWindows365 "IntuneAlertRuleWindows365-Example"
        {
            AlertRuleTemplate     = "cloudPcProvisionScenario";
            Conditions            = @(
                MSFT_IntuneAlertRuleCondition{
                    Aggregation       = "affectedCloudPcCount"
                    ConditionCategory = "provisionFailures"
                    ThresholdValue    = "1"
                    RelationshipType  = "or"
                    Operator          = "greaterOrEqual"
                }
            );
            Enabled               = $True; # Updated Property
            NotificationChannels  = @(
                MSFT_IntuneAlertRuleNotificationChannel{
                    NotificationChannelType = "portal"
                }
            );
            Severity              = "warning";
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
