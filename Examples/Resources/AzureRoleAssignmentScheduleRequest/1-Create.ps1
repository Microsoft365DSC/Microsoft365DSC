<#
This example creates a new Azure PIM role assignment schedule at subscription level.
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
            PrincipalType         = "User"
            Justification         = "Owner access for the platform engineering team during the datacentre migration."
            Ensure                = "Present"
            ScheduleInfo          = MSFT_AzureRoleAssignmentScheduleRequestSchedule{
                startDateTime = '2026-09-01T08:00:00Z'
                expiration    = MSFT_AzureRoleAssignmentScheduleRequestScheduleExpiration{
                    type        = 'afterDateTime'
                    endDateTime = '2027-08-31T23:59:59Z'
                }
            }
            SubscriptionId        = "<subscription-id>"
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
