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
        EXOJournalRule 'EXOJournalRule-Example'
        {
            Enabled               = $False # Updated Property
            JournalEmailAddress   = "journal@archive.fabrikam.com"
            Name                  = "Adele Vance Journal Archive"
            Recipient             = "AdeleV@$TenantId"
            RuleScope             = "Global"
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
