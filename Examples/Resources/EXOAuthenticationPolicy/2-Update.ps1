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
        EXOAuthenticationPolicy 'EXOAuthenticationPolicy-Example'
        {
            Identity                           = "Block Basic Auth"
            AllowBasicAuthActiveSync           = $False
            AllowBasicAuthAutodiscover         = $False
            AllowBasicAuthImap                 = $False
            AllowBasicAuthMapi                 = $True # Updated Property
            AllowBasicAuthOfflineAddressBook   = $False
            AllowBasicAuthOutlookService       = $False
            AllowBasicAuthPop                  = $False
            AllowBasicAuthPowerShell           = $False
            AllowBasicAuthReportingWebServices = $False
            AllowBasicAuthRpc                  = $False
            AllowBasicAuthSmtp                 = $False
            AllowBasicAuthWebServices          = $False
            Ensure                             = "Present"
            ApplicationId                      = $ApplicationId
            TenantId                           = $TenantId
            CertificateThumbprint              = $CertificateThumbprint
        }
    }
}
