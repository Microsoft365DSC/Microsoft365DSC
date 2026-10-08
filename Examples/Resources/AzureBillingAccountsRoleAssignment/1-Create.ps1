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
            PrincipalTenantId     = "9c888910-6b3b-4c17-8cff-844fefb026d4";
            RoleDefinition        = "Billing account owner";
            SubscriptionId        = "<subscription-id>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
