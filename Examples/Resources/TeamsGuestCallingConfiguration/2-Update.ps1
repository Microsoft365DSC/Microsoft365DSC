<#
This example configures the Teams Guest Calling Configuration.
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
        TeamsGuestCallingConfiguration 'TeamsGuestCallingConfiguration-Example'
        {
            IsSingleInstance      = 'Yes';
            AllowPrivateCalling   = $True
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
