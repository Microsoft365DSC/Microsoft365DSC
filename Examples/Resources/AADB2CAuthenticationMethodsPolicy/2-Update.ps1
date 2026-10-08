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
        AADB2CAuthenticationMethodsPolicy "AADB2CAuthenticationMethodsPolicy-Example"
        {
            IsEmailPasswordAuthenticationEnabled        = $True;
            IsPhoneOneTimePasswordAuthenticationEnabled = $True;
            IsSingleInstance                            = "Yes";
            IsUserNameAuthenticationEnabled             = $False;
            ApplicationId                               = $ApplicationId;
            TenantId                                    = $TenantId;
            CertificateThumbprint                       = $CertificateThumbprint;
        }
    }
}
