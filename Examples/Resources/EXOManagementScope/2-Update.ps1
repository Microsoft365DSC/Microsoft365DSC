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
        EXOManagementScope "EXOManagementScope-Example"
        {
            Ensure                     = "Present";
            Exclusive                  = $False;
            Identity                   = "New Distribution Groups";
            Name                       = "New Distribution Groups";
            RecipientRestrictionFilter = "Name -like 'Marketing*'";
            ApplicationId              = $ApplicationId
            TenantId                   = $TenantId
            CertificateThumbprint      = $CertificateThumbprint
        }
    }
}
