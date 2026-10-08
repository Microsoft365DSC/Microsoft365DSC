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
        EXODataAtRestEncryptionPolicy "EXODataAtRestEncryptionPolicy-Example"
        {
            AzureKeyIDs           = @("<key-vault-key-uri>")
            Description           = "Tenant default policy 1";
            Enabled               = $True;
            Ensure                = "Present";
            Identity              = "Riyansh_Policy";
            Name                  = "Riyansh_Policy";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
