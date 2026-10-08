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
        EXORetentionPolicy "EXORetentionPolicy-Example"
        {
            Name                        = "Standard Retention Policy";
            Identity                    = "Standard Retention Policy";
            IsDefault                   = $False;
            IsDefaultArbitrationMailbox = $False;
            RetentionPolicyTagLinks     = @("6 Month Delete","Personal 5 year move to archive","1 Month Delete","1 Week Delete","Personal never move to archive","Personal 1 year move to archive","Default 2 year move to archive","Deleted Items","Junk Email","Recoverable Items 14 days move to archive","Never Delete");
            Ensure                      = "Present";
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
