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
        SCAppRetentionCompliancePolicy 'SCAppRetentionCompliancePolicy-Example'
        {
            Name                      = "Teams Channel Messages Retention";
            Applications              = @("User:MicrosoftTeamsChannelMessages");
            Comment                   = "Retains the Teams channel messages of every user for ten years"; # Updated Property
            Enabled                   = $true;
            ExchangeLocation          = @("All");
            ExchangeLocationException = @("AdeleV@$TenantId");
            RestrictiveRetention      = $false;
            Ensure                    = "Present";
            ApplicationId             = $ApplicationId;
            TenantId                  = $TenantId;
            CertificateThumbprint     = $CertificateThumbprint;
        }
    }
}
