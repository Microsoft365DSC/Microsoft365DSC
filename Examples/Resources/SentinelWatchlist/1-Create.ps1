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
        SentinelWatchlist "SentinelWatchlist-Example"
        {
            Alias                 = "HighValueAssets";
            DefaultDuration       = "P1DT3H";
            Description           = "Servers and service accounts that require elevated monitoring";
            DisplayName           = "High Value Assets";
            Ensure                = "Present";
            ItemsSearchKey        = "IPAddress";
            Name                  = "High Value Assets";
            NumberOfLinesToSkip   = 1;
            RawContent            = "High value assets reviewed by the security operations team`nIPAddress,AssetName,Owner`n10.10.20.15,Finance database server,Finance Operations`n10.10.20.16,Payroll application server,Human Resources";
            ResourceGroupName     = "<resource-group-name>";
            SourceType            = "Local file";
            SubscriptionId        = "<subscription-id>";
            WorkspaceName         = "<log-analytics-workspace-name>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
