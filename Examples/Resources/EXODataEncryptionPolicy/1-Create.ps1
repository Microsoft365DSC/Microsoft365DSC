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
        EXODataEncryptionPolicy 'EXODataEncryptionPolicy-Example'
        {
            Identity              = 'US Mailboxes'
            Name                  = 'US Mailboxes'
            Description           = 'Customer key policy for mailboxes hosted in the United States'
            AzureKeyIDs           = @("<key-vault-key-uri>")
            Enabled               = $true
            Ensure                = "Present"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
