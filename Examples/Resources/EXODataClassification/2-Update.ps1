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
        EXODataClassification 'EXODataClassification-Example'
        {
            Description           = "Detects formatted and unformatted Canadian social insurance number.";
            Ensure                = "Present";
            Identity              = "a2f29c85-ecb8-4514-a610-364790c0773e";
            IsDefault             = $True;
            Locale                = "en-US";
            Name                  = "Canada Social Insurance Number";
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
