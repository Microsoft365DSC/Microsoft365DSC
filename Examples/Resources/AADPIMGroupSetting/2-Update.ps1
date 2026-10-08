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
        AADPIMGroupSetting "AADPIMGroupSetting-Example"
        {
            ActivateApprover                                          = @();
            ActivationMaxDuration                                     = "PT8H";
            ActivationReqJustification                                = $True;
            ActivationReqMFA                                          = $False;
            ActivationReqTicket                                       = $false;
            ActiveAlertNotificationAdditionalRecipient                = @();
            ActiveAlertNotificationDefaultRecipient                   = $True;
            ActiveAlertNotificationOnlyCritical                       = $False;
            ActiveApproveNotificationAdditionalRecipient              = @("pim-approvers@contoso.com");
            ActiveApproveNotificationDefaultRecipient                 = $True;
            ActiveApproveNotificationOnlyCritical                     = $False;
            ActiveAssigneeNotificationAdditionalRecipient             = @();
            ActiveAssigneeNotificationDefaultRecipient                = $False;
            ActiveAssigneeNotificationOnlyCritical                    = $False;
            ApprovaltoActivate                                        = $True;
            AssignmentReqJustification                                = $True;
            AssignmentReqMFA                                          = $False;
            AuthenticationContextId                                   = "";
            AuthenticationContextRequired                             = $false;
            DisplayName                                               = "U.S. Sales";
            EligibilityAssignmentReqJustification                     = $False;
            EligibilityAssignmentReqMFA                               = $False;
            EligibleAlertNotificationAdditionalRecipient              = @();
            EligibleAlertNotificationDefaultRecipient                 = $True;
            EligibleAlertNotificationOnlyCritical                     = $False;
            EligibleApproveNotificationAdditionalRecipient            = @();
            EligibleApproveNotificationDefaultRecipient               = $True;
            EligibleApproveNotificationOnlyCritical                   = $False;
            EligibleAssigneeNotificationAdditionalRecipient           = @();
            EligibleAssigneeNotificationDefaultRecipient              = $False;
            EligibleAssigneeNotificationOnlyCritical                  = $False;
            EligibleAssignmentAlertNotificationAdditionalRecipient    = @();
            EligibleAssignmentAlertNotificationDefaultRecipient       = $True;
            EligibleAssignmentAlertNotificationOnlyCritical           = $False;
            EligibleAssignmentAssigneeNotificationAdditionalRecipient = @();
            EligibleAssignmentAssigneeNotificationDefaultRecipient    = $True;
            EligibleAssignmentAssigneeNotificationOnlyCritical        = $False;
            ExpireActiveAssignment                                    = "P180D";
            ExpireEligibleAssignment                                  = "P365D";
            PermanentActiveAssignmentisExpirationRequired             = $False;
            PermanentEligibleAssignmentisExpirationRequired           = $False;
            RoleDefinitionId                                          = "owner";
            Ensure                                                    = "Present";
            ApplicationId                                             = $ApplicationId
            TenantId                                                  = $TenantId
            CertificateThumbprint                                     = $CertificateThumbprint
        }
    }
}
