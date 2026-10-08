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
        SCAppRetentionComplianceRule 'SCAppRetentionComplianceRule-Example'
        {
            Name                         = "Teams Channel Messages Retention Rule";
            Policy                       = "Teams Channel Messages Retention";
            Comment                      = "Keeps channel messages for seven years, then deletes them";
            ExpirationDateOption         = "CreationAgeInDays";
            RetentionComplianceAction    = "KeepAndDelete";
            RetentionDuration            = "2555";
            RetentionDurationDisplayHint = "Days";
            Ensure                       = "Present";
            ApplicationId                = $ApplicationId;
            TenantId                     = $TenantId;
            CertificateThumbprint        = $CertificateThumbprint;
        }
    }
}
