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
        SPOSearchManagedProperty 'SPOSearchManagedProperty-Example'
        {
            Searchable                  = $True
            FullTextIndex               = ""
            MappedCrawledProperties     = @()
            LanguageNeutralTokenization = $True
            CompanyNameExtraction       = $False
            AllowMultipleValues         = $True
            Aliases                     = $True
            Queryable                   = $True
            Name                        = "ContosoDepartment"
            Safe                        = $True
            Description                 = "Description of item"
            FinerQueryTokenization      = $True
            Retrievable                 = $True
            Type                        = "Text"
            CompleteMatching            = $True
            FullTextContext             = 4
            Sortable                    = "Yes"
            Refinable                   = "Yes"
            TokenNormalization          = $True
            Ensure                      = "Present"
            ApplicationId               = $ApplicationId
            TenantId                    = $TenantId
            CertificateThumbprint       = $CertificateThumbprint
        }
    }
}
