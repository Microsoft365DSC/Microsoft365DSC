<#
This example is used to configure the tenant's Guest Messaging settings for Teams
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
        TeamsGuestMessagingConfiguration 'TeamsGuestMessagingConfiguration-Example'
        {
            IsSingleInstance       = 'Yes'
            AllowGiphy             = $True
            AllowImmersiveReader   = $False
            AllowMemes             = $True
            AllowStickers          = $True
            AllowUserChat          = $True
            AllowUserDeleteMessage = $False
            AllowUserEditMessage   = $True
            GiphyRatingType        = "Moderate"
            ApplicationId          = $ApplicationId
            TenantId               = $TenantId
            CertificateThumbprint  = $CertificateThumbprint
        }
    }
}
