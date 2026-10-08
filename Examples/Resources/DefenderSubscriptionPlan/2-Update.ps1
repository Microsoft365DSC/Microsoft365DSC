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
        DefenderSubscriptionPlan 'DefenderSubscriptionPlan-Example'
        {
            SubscriptionName      = 'Contoso Production'
            PlanName              = 'VirtualMachines'
            SubPlanName           = 'P2'
            PricingTier           = 'Standard'
            SubscriptionId        = '<subscription-id>'
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
