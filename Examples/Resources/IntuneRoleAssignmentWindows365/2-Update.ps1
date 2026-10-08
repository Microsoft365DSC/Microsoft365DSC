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
            AppScopeIds           = @("0");
            Description           = "";
            DirectoryScopes       = @("Intune Pilot Users");
            DisplayName           = "IntuneRoleAssignmentWindows365_1";
            Ensure                = "Present";
            Principals            = @("Intune Excluded Users"); # Updated Property
            RoleDefinition        = "IntuneRoleDefinitionWindows365_1";
            ApplicationId         = $ApplicationId;
            TenantId              = $TenantId;
            CertificateThumbprint = $CertificateThumbprint;
        }
    }
}
