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
        AADRoleEligibilityScheduleRequest "AADRoleEligibilityScheduleRequest-Example"
        {
            DirectoryScopeId      = "/";
            Ensure                = "Present";
            Principal             = "AdeleV@$TenantId";
            PrincipalType         = "User";
            RoleDefinition        = "Teams Communications Administrator";
            Justification         = "Making the principal eligible for the Teams Communications Administrator role";
            ScheduleInfo          = MSFT_AADRoleEligibilityScheduleRequestSchedule{
                expiration = MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration{
                    duration = "P180D" # Updated Property
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
