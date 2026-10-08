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
        AzureBillingAccountsRoleAssignment "AzureBillingAccountsRoleAssignment-Example"
        {
            BillingAccount        = "Contoso Billing Account";
            Ensure                = "Present";
            PrincipalName         = "John.Smith@$TenantId";
            PrincipalType         = "User";
            PrincipalTenantId     = "1f4c7b28-59d0-4a63-9e15-3b8ad2c60f47"; # Updated Property
            RoleDefinition        = "Billing account owner";
            SubscriptionId        = "<subscription-id>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
