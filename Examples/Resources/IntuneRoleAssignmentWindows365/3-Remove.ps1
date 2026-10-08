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
        IntuneRoleAssignmentWindows365 "IntuneRoleAssignmentWindows365-Example"
        {
            DisplayName           = "IntuneRoleAssignmentWindows365_1";
            RoleDefinition        = "IntuneRoleDefinitionWindows365_1";
            Ensure                = "Absent";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
