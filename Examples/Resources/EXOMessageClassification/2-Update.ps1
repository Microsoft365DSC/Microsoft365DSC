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
        EXOMessageClassification 'EXOMessageClassification-Example'
        {
            Identity                    = "Contoso Message Classification"
            Name                        = "Contoso Message Classification"
            DisplayName                 = "Contoso Message Classification"
            DisplayPrecedence           = "Highest"
            PermissionMenuVisible       = $True
            RecipientDescription        = "Shown to receipients"
            SenderDescription           = "Shown to senders"
            RetainClassificationEnabled = $False # Updated Property
            Ensure                      = "Present"
            ApplicationId               = $ApplicationId
            TenantId                    = $TenantId
            CertificateThumbprint       = $CertificateThumbprint
        }
    }
}
