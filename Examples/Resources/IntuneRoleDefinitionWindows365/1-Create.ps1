<#
This example creates a new Intune Role Definition.
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
        IntuneRoleDefinitionWindows365 'IntuneRoleDefinitionWindows365-Example'
        {
            DisplayName           = 'IntuneRoleDefinitionWindows365_1'
            Description           = ''
            IsBuiltIn             = $False
            RolePermissions       = @(
                MSFT_MicrosoftGraphUnifiedRolePermission{
                    AllowedResourceActions = @(
                        "Microsoft.CloudPC/OnPremisesConnections/Create"
                        "Microsoft.CloudPC/OnPremisesConnections/Read"
                    )
                }
            );
            Ensure                = 'Present'
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
