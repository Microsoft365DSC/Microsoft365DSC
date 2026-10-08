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
        SCComplianceSearchAction 'SCComplianceSearchAction-Example1'
        {
            Action                              = "Export"
            ActionScope                         = "BothIndexedAndUnindexedItems"
            EnableDedupe                        = $True
            FileTypeExclusionsForUnindexedItems = @("exe", "dll", "iso")
            IncludeCredential                   = $False
            IncludeSharePointDocumentVersions   = $True
            RetryOnError                        = $False
            SearchName                          = "Budget Mailbox Search"
            Ensure                              = "Present"
            ApplicationId                       = $ApplicationId
            TenantId                            = $TenantId
            CertificateThumbprint               = $CertificateThumbprint
        }

        SCComplianceSearchAction 'SCComplianceSearchAction-Example2'
        {
            Action            = "Preview"
            IncludeCredential = $False
            RetryOnError      = $False
            SearchName        = "Budget Mailbox Search"
            Ensure            = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }

        SCComplianceSearchAction 'SCComplianceSearchAction-Example3'
        {
            Action                              = "Retention"
            ActionScope                         = "IndexedItemsOnly"
            EnableDedupe                        = $False
            FileTypeExclusionsForUnindexedItems = @("exe", "dll")
            IncludeCredential                   = $False
            IncludeSharePointDocumentVersions   = $False
            RetryOnError                        = $False
            SearchName                          = "Budget Mailbox Search"
            Ensure                              = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
