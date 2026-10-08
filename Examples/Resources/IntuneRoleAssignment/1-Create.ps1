<#
This example creates a new Intune Role Assigment.
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
        IntuneRoleAssignment 'IntuneRoleAssignment-Example'
        {
            DisplayName                = 'Amsterdam Helpdesk Operators'
            Description                = 'Grants the Amsterdam helpdesk access to the Amsterdam device scope'
            MembersDisplayNames        = @('Intune Pilot Users')
            ResourceScopesDisplayNames = @('Intune Pilot Devices')
            ScopeType                  = 'resourceScope'
            RoleDefinition             = '9e0cc482-82df-4ab2-a24c-0c23a3f52e1e'
            RoleDefinitionDisplayName  = 'Help Desk Operator'
            RoleScopeTagIds            = @('0')
            Ensure                     = 'Present'
            ApplicationId              = $ApplicationId;
            TenantId                   = $TenantId;
            CertificateThumbprint      = $CertificateThumbprint;
        }
    }
}
