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
        EXOQuarantinePolicy 'EXOQuarantinePolicy-Example'
        {
            EndUserQuarantinePermissionsValue        = 87;
            ESNEnabled                               = $False;
            Identity                                 = "$TenantId\CorporateQuarantinePolicy";
            QuarantinePolicyType                     = "PolicyQuarantineTag";
            Ensure                                   = "Present"
            ApplicationId                            = $ApplicationId
            TenantId                                 = $TenantId
            CertificateThumbprint                    = $CertificateThumbprint
        }
    }
}
