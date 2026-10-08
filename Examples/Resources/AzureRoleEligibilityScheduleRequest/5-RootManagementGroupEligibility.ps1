<#
This example creates an Azure PIM role eligibility schedule at the root management group level.
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
        AzureRoleEligibilityScheduleRequest "AzureRoleEligibilityScheduleRequest-Example"
        {
            Principal             = "AdeleV@$TenantId"
            RoleDefinition        = "Owner"
            DirectoryScopeId      = "/providers/Microsoft.Management/managementGroups/rootGroup"
            PrincipalType         = "User"
            Ensure                = "Present"
            ScheduleInfo          = MSFT_AzureRoleEligibilityScheduleRequestSchedule {
                startDateTime = '2024-01-15T08:00:00Z'
                expiration    = MSFT_AzureRoleEligibilityScheduleRequestScheduleExpiration
                {
                    type = 'noExpiration'
                }
            }
            ApplicationId         = $ApplicationId
            TenantId              = $TenantId
            CertificateThumbprint = $CertificateThumbprint
        }
    }
}
