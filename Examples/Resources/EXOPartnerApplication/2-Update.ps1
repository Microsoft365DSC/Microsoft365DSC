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
        EXOPartnerApplication 'EXOPartnerApplication-Example'
        {
            Name                                = "HRApp"
            ApplicationIdentifier               = "00000006-0000-0dd1-ac00-000000000000"
            AcceptSecurityIdentifierInformation = $False # Updated Property
            AccountType                         = "OrganizationalAccount"
            Enabled                             = $True
            Ensure                              = "Present"
            ApplicationId                       = $ApplicationId
            TenantId                            = $TenantId
            CertificateThumbprint               = $CertificateThumbprint
        }
    }
}
