<#
This example creates a new Defender Role Definition.
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
        DefenderRoleDefinition "DefenderRoleDefinition-Example"
        {
            Description           = "Grants the security operations team full XDR management rights";
            DisplayName           = "MyNewDefinition";
            Ensure                = "Present";
            RolePermissions       = @(
                MSFT_DefenderRoleDefinitionRolePermissions
                {
                    allowedResourceActions = @(
                        "microsoft.xdr/secops/*/manage"
                        "microsoft.xdr/securityposture/*/manage"
                        "microsoft.xdr/configuration/*/manage"
                    )
                }
            )
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
