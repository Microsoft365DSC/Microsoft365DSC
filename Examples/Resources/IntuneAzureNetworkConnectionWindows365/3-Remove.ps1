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
        IntuneAzureNetworkConnectionWindows365 "IntuneAzureNetworkConnectionWindows365-Example1"
        {
            DisplayName           = "IntuneWindows365AzureNetworkConnection_Hybrid";
            Ensure                = "Absent";
            ResourceGroupId       = "/subscriptions/subscription-name/resourceGroups/resource-group-name";
            SubnetId              = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name/subnets/default";
            SubscriptionName      = "subscription-name";
            VirtualNetworkId      = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        IntuneAzureNetworkConnectionWindows365 "IntuneAzureNetworkConnectionWindows365-Example2"
        {
            ConnectionType        = "azureADJoin";
            DisplayName           = "IntuneWindows365AzureNetworkConnection_Entra_1";
            Ensure                = "Absent";
            ResourceGroupId       = "/subscriptions/subscription-name/resourceGroups/resource-group-name";
            SubnetId              = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name/subnets/default";
            SubscriptionName      = "subscription-name";
            VirtualNetworkId      = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
