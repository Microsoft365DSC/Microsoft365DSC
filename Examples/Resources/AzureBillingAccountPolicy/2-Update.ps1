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
        AzureBillingAccountPolicy "AzureBillingAccountPolicy-Example"
        {
            BillingAccount              = "1e5b9e50-a1ea-581e-fb3a-xxxxxxxxx:6487d5cf-0a7b-42e6-9549-xxxxxxx_2019-05-31";
            Name                        = "default"
            EnterpriseAgreementPolicies = MSFT_AzureBillingAccountPolicyEnterpriseAgreementPolicy {
                authenticationType = "OrganizationalAccountOnly"
            }
            MarketplacePurchases        = "AllAllowed"
            ReservationPurchases        = "Allowed"
            SavingsPlanPurchases        = "NotAllowed"
            ApplicationId               = $ApplicationId
            TenantId                    = $TenantId
            CertificateThumbprint       = $CertificateThumbprint
        }
    }
}
