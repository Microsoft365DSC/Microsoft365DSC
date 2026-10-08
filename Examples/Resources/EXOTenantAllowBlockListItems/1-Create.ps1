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
        EXOTenantAllowBlockListItems "EXOTenantAllowBlockListItems-Example"
        {
            Action                = "Block";
            Ensure                = "Present";
            ListSubType           = "Tenant";
            ListType              = "Sender";
            NoExpiration          = $true;
            Notes                 = "Blocked sender reported by the service desk";
            Value                 = "example.com";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
