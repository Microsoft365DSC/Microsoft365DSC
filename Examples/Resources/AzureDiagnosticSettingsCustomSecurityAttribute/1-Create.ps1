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
        AzureDiagnosticSettingsCustomSecurityAttribute "AzureDiagnosticSettingsCustomSecurityAttribute-Example"
        {
            Categories                  = @(
                MSFT_AzureDiagnosticSettingsCustomSecurityAttributeCategory{
                    category = 'CustomSecurityAttributeAuditLogs'
                    enabled  = $True
                }
            );
            Ensure                      = "Present";
            EventHubAuthorizationRuleId = "<event-hub-authorization-rule-id>";
            EventHubName                = "custom-security-attribute-audit";
            Name                        = "Data Classification";
            ServiceBusRuleId            = "<service-bus-rule-id>";
            StorageAccountId            = "<storage-account-resource-id>";
            SubscriptionId              = "<subscription-id>";
            WorkspaceId                 = "<log-analytics-workspace-resource-id>";
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
