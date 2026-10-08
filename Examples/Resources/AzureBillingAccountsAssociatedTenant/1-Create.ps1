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
        AzureBillingAccountsAssociatedTenant "AzureBillingAccountsAssociatedTenant-Example"
        {
            AssociatedTenantId          = "7a575036-2dac-4713-8e23-2963cc2c5f37";
            BillingAccount              = "Contoso Enterprise Agreement";
            BillingManagementState      = "Active";
            DisplayName                 = "Contoso Manufacturing";
            Ensure                      = "Present";
            ProvisioningManagementState = "Pending";
            SubscriptionId              = "<subscription-id>";
            ApplicationId               = $ApplicationId;
            TenantId                    = $TenantId;
            CertificateThumbprint       = $CertificateThumbprint;
        }
    }
}
