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
        EXOSecOpsOverrideRule "EXOSecOpsOverrideRule-Example"
        {
            Comment               = "Delivers unfiltered mail to the security operations mailbox for analysis"; # Updated Property
            Ensure                = "Present";
            IsSingleInstance      = "Yes";
            SentTo                = @("AlexW@$TenantId");
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
