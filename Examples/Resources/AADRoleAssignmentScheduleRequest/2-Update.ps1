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
        AADRoleAssignmentScheduleRequest "AADRoleAssignmentScheduleRequest-Example"
        {
            DirectoryScopeId      = "/";
            Ensure                = "Present";
            Principal             = "AdeleV@$TenantId";
            PrincipalType         = "User";
            RoleDefinition        = "Teams Communications Administrator";
            Justification         = "Assigning the Teams Communications Administrator role";
            ScheduleInfo          = MSFT_AADRoleAssignmentScheduleRequestSchedule{
                expiration = MSFT_AADRoleAssignmentScheduleRequestScheduleExpiration{
                    duration = "P90D" # Updated Property
                    type     = "afterDuration"
                }
                startDateTime = "2026-01-01T00:00:00.0000000Z"
            };
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
