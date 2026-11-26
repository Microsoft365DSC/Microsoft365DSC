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
        TeamsFeedbackPolicy 'TeamsFeedbackPolicy-Example'
        {
            AllowEmailCollection      = $False;
            AllowLogCollection        = $False;
            AllowScreenshotCollection = $False;
            Ensure                    = "Present";
            Identity                  = "Frontline Feedback";
            ReceiveSurveysMode        = "Disabled"; # Updated Property
            UserInitiatedMode         = "Enabled";
            ApplicationId             = $ApplicationId;
            TenantId                  = $TenantId;
            CertificateThumbprint     = $CertificateThumbprint;
        }
    }
}
