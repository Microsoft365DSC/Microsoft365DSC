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
        SCRecordReviewNotificationTemplateConfig "SCRecordReviewNotificationTemplateConfig-Example"
        {
            CustomizedNotificationDataString = "This is my Notification Message";
            CustomizedReminderDataString     = "This is my reminder message";
            IsCustomizedNotificationTemplate = $True;
            IsCustomizedReminderTemplate     = $True;
            IsSingleInstance                 = "Yes";
            ApplicationId                    = $ApplicationId;
            TenantId                         = $TenantId;
            CertificateThumbprint            = $CertificateThumbprint;
        }
    }
}
