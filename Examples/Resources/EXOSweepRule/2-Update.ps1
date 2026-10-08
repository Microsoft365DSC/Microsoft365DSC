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
        EXOSweepRule 'EXOSweepRule-Example'
        {
            Enabled               = $true;
            Ensure                = "Present";
            KeepLatest            = 13; # Updated Property
            Mailbox               = "AdeleV@$TenantId";
            Name                  = "From Michelle";
            Provider              = "Exchange16";
            SenderName            = "michelle@fabrikam.com";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
