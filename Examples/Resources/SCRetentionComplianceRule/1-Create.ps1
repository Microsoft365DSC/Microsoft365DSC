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
        SCRetentionComplianceRule 'SCRetentionComplianceRule-Example'
        {
            Name                         = "Keep Finance Content"
            Policy                       = "Finance Records Retention"
            Comment                      = "Keeps finance records for seven years to meet audit obligations"
            RetentionComplianceAction    = "Keep"
            RetentionDuration            = "2555"
            RetentionDurationDisplayHint = "Years"
            ExpirationDateOption         = "CreationAgeInDays"
            ContentMatchQuery            = "Subject:Invoice OR Subject:Statement"
            ExcludedItemClasses          = @("IPM.Note.Microsoft.Conversation", "IPM.Note.Microsoft.Voicemail")
            Ensure                       = "Present"
            ApplicationId                = $ApplicationId
            TenantId                     = $TenantId
            CertificateThumbprint        = $CertificateThumbprint
        }
    }
}
