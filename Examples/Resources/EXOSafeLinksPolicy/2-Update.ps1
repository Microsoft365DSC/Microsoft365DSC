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
        EXOSafeLinksPolicy 'EXOSafeLinksPolicy-Example'
        {
            Identity                      = 'Marketing Block URL'
            AdminDisplayName              = 'Marketing Block URL'
            AllowClickThrough             = $False
            CustomNotificationText        = 'Blocked URLs for Marketing'
            DeliverMessageAfterScan       = $True
            DisableUrlRewrite             = $False
            DoNotRewriteUrls              = @("https://contoso.com/*")
            EnableForInternalSenders      = $True
            EnableOrganizationBranding    = $False # Updated Property
            EnableSafeLinksForEmail       = $True
            EnableSafeLinksForOffice      = $True
            EnableSafeLinksForTeams       = $True
            ScanUrls                      = $True
            TrackClicks                   = $True
            UseTranslatedNotificationText = $True
            Ensure                        = 'Present'
            ApplicationId                 = $ApplicationId
            TenantId                      = $TenantId
            CertificateThumbprint         = $CertificateThumbprint
        }
    }
}
