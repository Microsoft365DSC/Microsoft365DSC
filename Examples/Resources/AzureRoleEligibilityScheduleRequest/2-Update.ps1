<#
This example updates an existing Azure PIM role eligibility schedule.
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
            DirectoryScopeId      = "/subscriptions/<subscription-id>"
            PrincipalType         = "User"
            Justification         = "Eligible owner access for the platform engineering team while the payment gateway rollout completes." # Updated Property
            Ensure                = "Present"
            ScheduleInfo          = MSFT_AzureRoleEligibilityScheduleRequestSchedule{
                startDateTime = '2026-09-01T08:00:00Z'
                expiration    = MSFT_AzureRoleEligibilityScheduleRequestScheduleExpiration{
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
