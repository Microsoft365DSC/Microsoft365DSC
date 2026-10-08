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
        AzureBillingAccountScheduledAction "AzureBillingAccountScheduledAction-Example"
        {
            BillingAccount        = "<billing-account-id>";
            DisplayName           = "MyAction";
            Ensure                = "Present";
            Notification          = MSFT_AzureBillingAccountScheduledActionNotification{
                subject = 'Cost Alert'
                message = 'Weekly accumulated cost summary for the finance team.'
                to      = @('john.smith@contoso.com')
            };
            NotificationEmail     = "alert@contoso.com";
            Schedule              = MSFT_AzureBillingAccountScheduledActionSchedule{
                daysOfWeek = @('Wednesday')
                startDate  = '2026-11-04T13:00:00Z'
                endDate    = '2027-11-03T13:00:00Z'
                frequency  = 'Weekly'
                hourOfDay  = 13
            };
            Status                = "Enabled";
            SubscriptionId        = "<subscription-id>";
            View                  = "/providers/Microsoft.Billing/billingAccounts/<billing-account-id>/providers/Microsoft.CostManagement/views/ms:AccumulatedCosts";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
