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
        SCComplianceTag 'SCComplianceTag-Example'
        {
            Name                  = "Financial Records"
            Comment               = "Keeps financial records for 1025 days after modification"
            IsRecordLabel         = $False
            Notes                 = "Reviewed annually by the records management team and the external auditor" # Updated Property
            RetentionAction       = "Keep"
            RetentionDuration     = "1025"
            RetentionType         = "ModificationAgeInDays"
            FilePlanProperty      = MSFT_SCFilePlanProperty{
                FilePlanPropertyDepartment  = "Treasury"
                FilePlanPropertyCitation    = "Sarbanes-Oxley Act"
                FilePlanPropertyReferenceId = "FIN-1025"
                FilePlanPropertyAuthority   = "Audit Committee"
                FilePlanPropertyCategory    = "Financial Reporting"
                FilePlanPropertySubCategory = "Annual Statements"
            }
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
