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
        SCUnifiedAuditLogRetentionPolicy 'SCUnifiedAuditLogRetentionPolicy-Example'
        {
            Ensure                = "Present"
            Name                  = "Seven Day Audit Retention"
            Description           = "Retains mailbox permission changes made for the finance and payroll leadership team" # Updated Property
            Operations            = @("Add-MailboxPermission", "Remove-MailboxPermission")
            RecordTypes           = @("ExchangeAdmin")
            UserIds               = @("AdeleV@$TenantId", "MeganB@$TenantId")
            Priority              = 1
            RetentionDuration     = "SevenDays"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
