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
        SCRetentionCompliancePolicy 'SCRetentionCompliancePolicy-Example'
        {
            Name                  = "Finance Mailbox Retention";
            AdaptiveScopeLocation = @("Finance Zurich Users");
            Applications          = @("User:Exchange,OneDriveForBusiness");
            Comment               = "Keeps the mailboxes and OneDrive content of the finance department";
            Enabled               = $true;
            Ensure                = "Present";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
