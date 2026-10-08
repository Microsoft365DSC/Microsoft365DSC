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
        SentinelThreatIntelligenceIndicator "SentinelThreatIntelligenceIndicator-Example"
        {
            Confidence             = 80;
            Description            = "Command-and-control host observed in a credential phishing campaign against the finance department";
            DisplayName            = "Known phishing domain";
            Ensure                 = "Present";
            KillChainPhases        = @("Command and Control");
            Labels                 = @("Phishing", "Command and Control", "Under Investigation"); # Updated Property
            Pattern                = "[ipv6-addr:value = '2607:fa49:d340:f600:c8d5:6961:247f:a238']";
            PatternType            = "ipv6-addr";
            ResourceGroupName      = "<resource-group-name>";
            Revoked                = "false";
            Source                 = "Microsoft Sentinel";
            SubscriptionId         = "<subscription-id>";
            ThreatIntelligenceTags = @("Finance Phishing Campaign", "Reviewed By SOC");
            ThreatTypes            = @("malicious-activity");
            ValidFrom              = "2026-01-01T00:00:00.0000000Z";
            ValidUntil             = "2026-12-31T00:00:00.0000000Z";
            WorkspaceName          = "<log-analytics-workspace-name>";
            ApplicationId          = $ApplicationId;
            TenantId               = $TenantId;
            CertificateThumbprint  = $CertificateThumbprint;
        }
    }
}
