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
        AzureVerifiedIdFaceCheck "AzureVerifiedIdFaceCheck-Example"
        {
            Ensure                      = "Present";
            FaceCheckEnabled            = $True;
            ResourceGroupName           = "website";
            SubscriptionId              = "<subscription-id>";
            VerifiedIdAuthorityId       = "30961e04-9c35-42db-b80f-c1b6515eb4b2";
            VerifiedIdAuthorityLocation = "westus2";
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
