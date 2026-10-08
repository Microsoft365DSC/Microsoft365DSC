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
        TeamsClientConfiguration 'TeamsClientConfiguration-Example'
        {
            AllowBox                         = $True
            AllowDropBox                     = $True
            AllowEmailIntoChannel            = $True
            AllowGoogleDrive                 = $True
            AllowGuestUser                   = $True
            AllowOrganizationTab             = $True
            AllowResourceAccountSendMessage  = $True
            AllowScopedPeopleSearchandAccess = $False
            AllowShareFile                   = $True
            AllowSkypeBusinessInterop        = $True
            ContentPin                       = "RequiredOutsideScheduleMeeting"
            IsSingleInstance                 = 'Yes'
            ResourceAccountContentAccess     = "NoAccess"
            ApplicationId                    = $ApplicationId
            TenantId                         = $TenantId
            CertificateThumbprint            = $CertificateThumbprint
        }
    }
}
