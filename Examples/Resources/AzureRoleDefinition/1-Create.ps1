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
        AzureRoleDefinition "AzureRoleDefinition-Example"
        {
            Actions               = @("Microsoft.Compute/virtualMachines/read","Microsoft.Compute/virtualMachines/start/action","Microsoft.Compute/virtualMachines/restart/action");
            AssignableScopes      = @("<subscription-scope>");
            CustomRoleName        = "Virtual Machine Operator";
            DataActions           = @("Microsoft.Compute/virtualMachines/login/action");
            Description           = "Allows the platform team to start and restart virtual machines.";
            Ensure                = "Present";
            NotActions            = @("Microsoft.Compute/virtualMachines/delete", "Microsoft.Compute/virtualMachines/write");
            NotDataActions        = @("Microsoft.Compute/virtualMachines/loginAsAdmin/action");
            SubscriptionId        = "<subscription-id>";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
