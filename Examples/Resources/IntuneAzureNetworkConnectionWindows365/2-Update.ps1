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
            AdDomainName          = "contoso.com";
            AdDomainUsername      = "username@contoso.com";
            AdDomainPassword      = "<domain-join-password>";
            ConnectionType        = "hybridAzureADJoin";
            DisplayName           = "IntuneWindows365AzureNetworkConnection_Hybrid";
            Ensure                = "Present";
            OrganizationalUnit    = "OU=CloudPCs,OU=Devices,DC=contoso,DC=com";
            ResourceGroupId       = "/subscriptions/subscription-name/resourceGroups/resource-group-name";
            ScopeIds              = @("0");
            SubnetId              = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name-2/subnets/default"; # Updated Property
            SubscriptionName      = "subscription-name";
            VirtualNetworkId      = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name-2"; # Updated Property
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
        IntuneAzureNetworkConnectionWindows365 "IntuneAzureNetworkConnectionWindows365-Example2"
        {
            ConnectionType        = "azureADJoin";
            DisplayName           = "IntuneWindows365AzureNetworkConnection_Entra_1";
            Ensure                = "Present";
            ResourceGroupId       = "/subscriptions/subscription-name/resourceGroups/resource-group-name";
            ScopeIds              = @("0");
            SubnetId              = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name-2/subnets/default"; # Updated Property
            SubscriptionName      = "subscription-name";
            VirtualNetworkId      = "/subscriptions/subscription-name/resourceGroups/resource-group-name/providers/Microsoft.Network/virtualNetworks/virtual-network-name-2"; # Updated Property
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
