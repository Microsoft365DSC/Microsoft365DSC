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
        AzureRoleEligibilityScheduleSettings "AzureRoleEligibilityScheduleSettings-Example"
        {
            RoleDefinitionDisplayName                         = "Owner"
            ScopeId                                           = "subscriptions/00000000-0000-0000-0000-000000000000"
            ActivationMaxDuration                             = "PT4H"
            ActivationReqJustification                        = $True
            ActivationReqTicket                               = $True
            ActivationReqMFA                                  = $False
            ApprovaltoActivate                                = $True
            ActivateApprover                                  = @()
            PermanentEligibleAssignmentisExpirationRequired   = $True
            ExpireEligibleAssignment                          = "P180D"
            PermanentActiveAssignmentisExpirationRequired     = $True
            ExpireActiveAssignment                            = "P90D"
            AssignmentReqMFA                                  = $False
            AssignmentReqJustification                        = $True
            EligibilityAssignmentReqMFA                       = $False
            EligibilityAssignmentReqJustification             = $False
            EligibleAlertNotificationDefaultRecipient         = $True
            EligibleAlertNotificationAdditionalRecipient      = @("eligibility-admin@contoso.com")
            EligibleAlertNotificationOnlyCritical             = $True
            EligibleAssigneeNotificationDefaultRecipient      = $True
            EligibleAssigneeNotificationAdditionalRecipient   = @()
            EligibleAssigneeNotificationOnlyCritical          = $False
            EligibleApproveNotificationDefaultRecipient       = $True
            EligibleApproveNotificationAdditionalRecipient    = @()
            EligibleApproveNotificationOnlyCritical           = $False
            ActiveAlertNotificationDefaultRecipient           = $True
            ActiveAlertNotificationAdditionalRecipient        = @("assignment-admin@contoso.com")
            ActiveAlertNotificationOnlyCritical               = $False
            ActiveAssigneeNotificationDefaultRecipient        = $True
            ActiveAssigneeNotificationAdditionalRecipient     = @()
            ActiveAssigneeNotificationOnlyCritical            = $False
            ActiveApproveNotificationDefaultRecipient         = $True
            ActiveApproveNotificationAdditionalRecipient      = @()
            ActiveApproveNotificationOnlyCritical             = $False
            ActivationAlertNotificationDefaultRecipient       = $True
            ActivationAlertNotificationAdditionalRecipient    = @("admin@contoso.com")
            ActivationAlertNotificationOnlyCritical           = $False
            ActivationAssigneeNotificationDefaultRecipient    = $True
            ActivationAssigneeNotificationAdditionalRecipient = @()
            ActivationAssigneeNotificationOnlyCritical        = $False
            ActivationApproveNotificationDefaultRecipient     = $True
            ActivationApproveNotificationAdditionalRecipient  = @()
            ActivationApproveNotificationOnlyCritical         = $False
            ApplicationId                                     = $ApplicationId
            TenantId                                          = $TenantId
            CertificateThumbprint                             = $CertificateThumbprint
        }
    }
}
