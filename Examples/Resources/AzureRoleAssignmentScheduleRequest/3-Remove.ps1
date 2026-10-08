<#
This example removes an Azure PIM role assignment schedule.
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
        AzureRoleAssignmentScheduleRequest "AzureRoleAssignmentScheduleRequest-Example"
        {
            Principal             = "AdeleV@$TenantId"
            RoleDefinition        = "Owner"
            DirectoryScopeId      = "/subscriptions/<subscription-id>"
            Ensure                = "Absent"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
