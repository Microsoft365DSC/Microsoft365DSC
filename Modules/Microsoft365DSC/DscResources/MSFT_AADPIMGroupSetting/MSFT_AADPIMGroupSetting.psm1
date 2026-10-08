using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADPIMGroupSetting : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('RuleDefinition DisplayName')]
    [System.String] $DisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The identifier of the membership or ownership eligibility to the group that is governed by PIM. Required. The possible values are: owner, member. Supports $filter (eq).')]
    [ValidateSet('owner', 'member')]
    [System.String] $RoleDefinitionId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the Group Policy Id.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Activation maximum duration (hours).')]
    [System.String] $ActivationMaxDuration

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on activation (True/False)')]
    [System.Nullable[System.Boolean]] $ActivationReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Require ticket information on activation (True/False)')]
    [System.Nullable[System.Boolean]] $ActivationReqTicket

    [DscProperty()]
    [System.ComponentModel.Description('Require MFA on activation (True/False)')]
    [System.Nullable[System.Boolean]] $ActivationReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require approval to activate (True/False)')]
    [System.Nullable[System.Boolean]] $ApprovaltoActivate

    [DscProperty()]
    [System.ComponentModel.Description('Approver User UPN and/or Group Displayname')]
    [System.String[]] $ActivateApprover

    [DscProperty()]
    [System.ComponentModel.Description('Allow permanent eligible assignment (True/False)')]
    [System.Nullable[System.Boolean]] $PermanentEligibleAssignmentisExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Expire eligible assignments after (Days)')]
    [System.String] $ExpireEligibleAssignment

    [DscProperty()]
    [System.ComponentModel.Description('Allow permanent active assignment (True/False)')]
    [System.Nullable[System.Boolean]] $PermanentActiveAssignmentisExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Expire active assignments after (Days)')]
    [System.String] $ExpireActiveAssignment

    [DscProperty()]
    [System.ComponentModel.Description('Require Azure Multi-Factor Authentication on active assignment (True/False)')]
    [System.Nullable[System.Boolean]] $AssignmentReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on active assignment (True/False)')]
    [System.Nullable[System.Boolean]] $AssignmentReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Require Azure Multi-Factor Authentication on eligible assignment (True/False)')]
    [System.Nullable[System.Boolean]] $EligibilityAssignmentReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on eligible assignment (True/False)')]
    [System.Nullable[System.Boolean]] $EligibilityAssignmentReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Group assignment alert, default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Group assignment alert, additional recipient (UPN)')]
    [System.String[]] $EligibleAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Group assignment alert, only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Notification to the assigned user (assignee), default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Notification to the assigned user (assignee), additional recipient (UPN)')]
    [System.String[]] $EligibleAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Notification to the assigned user (assignee), only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Request to approve a group assignment renewal/extension, default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleApproveNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Request to approve a group assignment renewal/extension, additional recipient (UPN)')]
    [System.String[]] $EligibleApproveNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this group: Request to approve a group assignment renewal/extension, only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleApproveNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Group assignment alert, default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Group assignment alert, additional recipient (UPN)')]
    [System.String[]] $ActiveAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Group assignment alert, only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Notification to the assigned user (assignee), default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Notification to the assigned user (assignee), additional recipient (UPN)')]
    [System.String[]] $ActiveAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Notification to the assigned user (assignee), only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Request to approve a group assignment renewal/extension, default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveApproveNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Request to approve a group assignment renewal/extension, additional recipient (UPN)')]
    [System.String[]] $ActiveApproveNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this group: Request to approve a group assignment renewal/extension, only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $ActiveApproveNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Group assignment alert, default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssignmentAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Group assignment alert, additional recipient (UPN)')]
    [System.String[]] $EligibleAssignmentAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Group assignment alert, only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssignmentAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Notification to activated user (requestor), default recipient (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssignmentAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Notification to activated user (requestor), additional recipient (UPN)')]
    [System.String[]] $EligibleAssignmentAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this group: Notification to activated user (requestor), only critical Email (True/False)')]
    [System.Nullable[System.Boolean]] $EligibleAssignmentAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Authorization context is required (True/False)')]
    [System.Nullable[System.Boolean]] $AuthenticationContextRequired

    [DscProperty()]
    [System.ComponentModel.Description('Descriptive name of associated authorization context')]
    [System.String] $AuthenticationContextName

    [DscProperty()]
    [System.ComponentModel.Description('Authorization context id')]
    [System.String] $AuthenticationContextId

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Azure AD group setting should exist or not.')]
    [ValidateSet('Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Azure Active Directory application''s authentication certificate to use for authentication.')]
    [System.String] $CertificateThumbprint

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AADPIMGroupSetting] Get()
    {
        $AuthenticationContextNameValue = $null
        $GroupId = $null
        $AuthenticationContextIdValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADPIMGroupSetting]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD PIM Group Setting with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $Policy = $null
            if ([System.String]::IsNullOrEmpty($GroupId))
            {
                Write-Verbose 'GroupID was NULL, looking up group'
                $groupFilter = "DisplayName eq '" + $($this.DisplayName -replace "'", "''") + "'"
                $GroupId = (Get-MgGroup -Filter $groupFilter).Id
            }

            $policyFilter = "scopeId eq '$groupId' and scopeType eq 'Group' and roleDefinitionId eq '$($this.RoleDefinitionId)'"
            $policyResponses = Invoke-M365DSCGraphBatchRequest -AsList -Requests @(@{
                    id     = $groupId
                    method = 'GET'
                    url    = "/policies/roleManagementPolicyAssignments?filter=$policyFilter&`$expand=policy(`$expand=rules)"
                })
            $Policy = @($policyResponses)[0].body.value | Select-Object -First 1
        }
        else
        {
            $Policy = $this.ExportedInstance
        }
        $nullReturn = $this.GetBoundParameters()

        if ($null -eq $Policy.policy.rules)
        {
            Write-Verbose 'No Policy Rules found, returning null'
            return $this.AsResult($nullReturn)
        }

        #Rules
        $role = $Policy.policy.rules

        $ActivationMaxDurationValue = ($role | Where-Object { $_.Id -eq 'Expiration_EndUser_Assignment' }).maximumDuration
        $ActivationReqJustificationValue = (($role | Where-Object { $_.Id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'Justification'
        $ActivationReqTicketValue = (($role | Where-Object { $_.Id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'Ticketing'
        $ActivationReqMFAValue = (($role | Where-Object { $_.Id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'MultiFactorAuthentication'
        $AuthenticationContextValue = ($role | Where-Object { $_.Id -eq 'AuthenticationContext_EndUser_Assignment' })
        $ApprovaltoActivateValue = (($role | Where-Object { $_.Id -eq 'Approval_EndUser_Assignment' }).setting.isApprovalRequired)
        [array]$ActivateApproversValue = (($role | Where-Object { $_.Id -eq 'Approval_EndUser_Assignment' }).setting.approvalStages.primaryApprovers)
        $AuthenticationContextRequiredValue = $AuthenticationContextValue.isEnabled
        if ($AuthenticationContextRequiredValue)
        {
            $AuthenticationContextIdValue = $AuthenticationContextValue.claimValue
            $AuthenticationContextNameValue = (Get-MgBetaIdentityConditionalAccessAuthenticationContextClassReference -AuthenticationContextClassReferenceId $AuthenticationContextIdValue).DisplayName
        }

        [string[]]$activateApproverValue = @()
        foreach ($Item in $ActivateApproversValue.id)
        {
            try
            {
                $user = Get-MgUser -UserId $Item -ErrorAction Stop
                $activateApproverValue += $user.UserPrincipalName
            }
            catch
            {
                try
                {
                    $group = Get-MgGroup -GroupId $Item -ErrorAction stop
                    $activateApproverValue += $group.DisplayName
                }
                catch
                {
                    Write-Verbose -Message "Error: $($Error[0])"
                }
            }
        }

        if ($this.ResourceCache['ExportMode'])
        {
            $PermanentEligibleAssignmentisExpirationRequiredValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Eligibility' }).isExpirationRequired
            $ExpireEligibleAssignmentValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Eligibility' }).maximumDuration
            $PermanentActiveAssignmentisExpirationRequiredValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Assignment' }).isExpirationRequired
            $ExpireActiveAssignmentValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Assignment' }).maximumDuration
            $AssignmentReqMFAValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'MultiFactorAuthentication'
            $AssignmentReqJustificationValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'Justification'
            $EligibilityAssignmentReqMFAValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'MultiFactorAuthentication'
            $EligibilityAssignmentReqJustificationValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'Justification'
            $EligibleAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).notificationRecipients
            $EligibleAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $EligibleAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationRecipients
            $EligibleAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $EligibleApproveNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleApproveNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).notificationRecipients
            $EligibleApproveNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $ActiveAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).notificationRecipients
            $ActiveAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $ActiveAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).notificationRecipients
            $ActiveAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $ActiveApproveNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveApproveNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).notificationRecipients
            $ActiveApproveNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $EligibleAssignmentAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssignmentAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).notificationRecipients
            $EligibleAssignmentAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).notificationLevel) -contains ('Critical')
            $EligibleAssignmentAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssignmentAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationRecipients
            $EligibleAssignmentAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationLevel) -contains ('Critical')
        }
        else
        {
            $PermanentEligibleAssignmentisExpirationRequiredValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Eligibility' }).isExpirationRequired
            $ExpireEligibleAssignmentValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Eligibility' }).maximumDuration
            $PermanentActiveAssignmentisExpirationRequiredValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Assignment' }).isExpirationRequired
            $ExpireActiveAssignmentValue = ($role | Where-Object { $_.Id -eq 'Expiration_Admin_Assignment' }).maximumDuration
            $AssignmentReqMFAValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'MultiFactorAuthentication'
            $AssignmentReqJustificationValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'Justification'
            $EligibilityAssignmentReqMFAValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'MultiFactorAuthentication'
            $EligibilityAssignmentReqJustificationValue = (($role | Where-Object { $_.Id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'Justification'
            $EligibleAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).notificationRecipients
            $EligibleAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $EligibleAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationRecipients
            $EligibleAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $EligibleApproveNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$EligibleApproveNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).notificationRecipients
            $EligibleApproveNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Eligibility' }).notificationLevel) -contains ('Critical')
            $ActiveAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).notificationRecipients
            $ActiveAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $ActiveAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).notificationRecipients
            $ActiveAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $ActiveApproveNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$ActiveApproveNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).notificationRecipients
            $ActiveApproveNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Approver_Admin_Assignment' }).notificationLevel) -contains ('Critical')
            $EligibleAssignmentAlertNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssignmentAlertNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).notificationRecipients
            $EligibleAssignmentAlertNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Admin_EndUser_Assignment' }).notificationLevel) -contains ('Critical')
            $EligibleAssignmentAssigneeNotificationDefaultRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$EligibleAssignmentAssigneeNotificationAdditionalRecipientValue = ($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationRecipients
            $EligibleAssignmentAssigneeNotificationOnlyCriticalValue = (($role | Where-Object { $_.Id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationLevel) -contains ('Critical')
        }

        try
        {
            Write-Verbose -Message "Found configuration of Rule $($this.DisplayName)"
            $result = @{
                Id                                                        = $Policy.Id
                DisplayName                                               = $this.DisplayName
                RoleDefinitionId                                          = $this.RoleDefinitionId
                ActivationMaxDuration                                     = $ActivationMaxDurationValue
                ActivationReqJustification                                = $ActivationReqJustificationValue
                ActivationReqTicket                                       = $ActivationReqTicketValue
                ActivationReqMFA                                          = $ActivationReqMFAValue
                ApprovaltoActivate                                        = $ApprovaltoActivateValue
                ActivateApprover                                          = [System.String[]]$activateApproverValue
                PermanentEligibleAssignmentisExpirationRequired           = $PermanentEligibleAssignmentisExpirationRequiredValue
                ExpireEligibleAssignment                                  = $ExpireEligibleAssignmentValue
                PermanentActiveAssignmentisExpirationRequired             = $PermanentActiveAssignmentisExpirationRequiredValue
                ExpireActiveAssignment                                    = $ExpireActiveAssignmentValue
                AssignmentReqMFA                                          = $AssignmentReqMFAValue
                AssignmentReqJustification                                = $AssignmentReqJustificationValue
                EligibilityAssignmentReqMFA                               = $EligibilityAssignmentReqMFAValue
                EligibilityAssignmentReqJustification                     = $EligibilityAssignmentReqJustificationValue
                EligibleAlertNotificationDefaultRecipient                 = $EligibleAlertNotificationDefaultRecipientValue
                EligibleAlertNotificationAdditionalRecipient              = [System.String[]]$EligibleAlertNotificationAdditionalRecipientValue
                EligibleAlertNotificationOnlyCritical                     = $EligibleAlertNotificationOnlyCriticalValue
                EligibleAssigneeNotificationDefaultRecipient              = $EligibleAssigneeNotificationDefaultRecipientValue
                EligibleAssigneeNotificationAdditionalRecipient           = [System.String[]]$EligibleAssigneeNotificationAdditionalRecipientValue
                EligibleAssigneeNotificationOnlyCritical                  = $EligibleAssigneeNotificationOnlyCriticalValue
                EligibleApproveNotificationDefaultRecipient               = $EligibleApproveNotificationDefaultRecipientValue
                EligibleApproveNotificationAdditionalRecipient            = [System.String[]]$EligibleApproveNotificationAdditionalRecipientValue
                EligibleApproveNotificationOnlyCritical                   = $EligibleApproveNotificationOnlyCriticalValue
                ActiveAlertNotificationDefaultRecipient                   = $ActiveAlertNotificationDefaultRecipientValue
                ActiveAlertNotificationAdditionalRecipient                = [System.String[]]$ActiveAlertNotificationAdditionalRecipientValue
                ActiveAlertNotificationOnlyCritical                       = $ActiveAlertNotificationOnlyCriticalValue
                ActiveAssigneeNotificationDefaultRecipient                = $ActiveAssigneeNotificationDefaultRecipientValue
                ActiveAssigneeNotificationAdditionalRecipient             = [System.String[]]$ActiveAssigneeNotificationAdditionalRecipientValue
                ActiveAssigneeNotificationOnlyCritical                    = $ActiveAssigneeNotificationOnlyCriticalValue
                ActiveApproveNotificationDefaultRecipient                 = $ActiveApproveNotificationDefaultRecipientValue
                ActiveApproveNotificationAdditionalRecipient              = [System.String[]]$ActiveApproveNotificationAdditionalRecipientValue
                ActiveApproveNotificationOnlyCritical                     = $ActiveApproveNotificationOnlyCriticalValue
                EligibleAssignmentAlertNotificationDefaultRecipient       = $EligibleAssignmentAlertNotificationDefaultRecipientValue
                EligibleAssignmentAlertNotificationAdditionalRecipient    = [System.String[]]$EligibleAssignmentAlertNotificationAdditionalRecipientValue
                EligibleAssignmentAlertNotificationOnlyCritical           = $EligibleAssignmentAlertNotificationOnlyCriticalValue
                EligibleAssignmentAssigneeNotificationDefaultRecipient    = $EligibleAssignmentAssigneeNotificationDefaultRecipientValue
                EligibleAssignmentAssigneeNotificationAdditionalRecipient = [System.String[]]$EligibleAssignmentAssigneeNotificationAdditionalRecipientValue
                EligibleAssignmentAssigneeNotificationOnlyCritical        = $EligibleAssignmentAssigneeNotificationOnlyCriticalValue
                AuthenticationContextRequired                             = $AuthenticationContextRequiredValue
                AuthenticationContextId                                   = $AuthenticationContextIdValue
                AuthenticationContextName                                 = $AuthenticationContextNameValue
                Ensure                                                    = 'Present'
                ApplicationId                                             = $this.ApplicationId
                TenantId                                                  = $this.TenantId
                CertificateThumbprint                                     = $this.CertificateThumbprint
                ApplicationSecret                                         = $this.ApplicationSecret
                Credential                                                = $this.Credential
                ManagedIdentity                                           = $this.ManagedIdentity
                AccessTokens                                              = $this.AccessTokens
            }
            return $this.AsResult($result)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $params = $null
        $primaryApprovers = $null
        $GroupId = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Azure AD PIM Group for group DisplayName {$($this.DisplayName)} and RoleDefinitionId {$($this.RoleDefinitionId)}"

        $null = $this.Connect('MicrosoftGraph')

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies
        #region Telemetry
        $this.AddTelemetry('Set')
        #endregion
        $Policy = $null

        if ([System.String]::IsNullOrEmpty($GroupId))
        {
            $groupFilter = "DisplayName eq '" + $this.DisplayName + "'"
            $GroupId = (Get-MgGroup -Filter $groupFilter).Id
        }

        $policyFilter = "scopeId eq '$groupId' and scopeType eq 'Group' and roleDefinitionId eq '$($this.RoleDefinitionId)'"
        $policyResponses = Invoke-M365DSCGraphBatchRequest -AsList -Requests @(@{
                id     = $groupId
                method = 'GET'
                url    = "/policies/roleManagementPolicyAssignments?filter=$policyFilter&`$expand=policy(`$expand=rules)"
            })
        $Policy = @($policyResponses)[0].body.value | Select-Object -First 1

        #Rules
        $roles = $Policy.policy.rules

        foreach ($role in $roles)
        {
            $odatatype = $role.'@odata.type'
            if ($role.id -match 'Notification_Admin_Admin_Eligibility')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibleAlertNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAlertNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAlertNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Role assignment alert'
                    $notificationLevel = if ($this.EligibleAlertNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.EligibleAlertNotificationDefaultRecipient
                    $notificationRecipients = @($this.EligibleAlertNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Admin'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Requestor_Admin_Eligibility')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Notification to the assigned user (assignee)'
                    $notificationLevel = if ($this.EligibleAssigneeNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.EligibleAssigneeNotificationDefaultRecipient
                    $notificationRecipients = @($this.EligibleAssigneeNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Requestor'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Approver_Admin_Eligibility')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibleApproveNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleApproveNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleApproveNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Request to approve a role assignment renewal/extension'
                    $notificationLevel = if ($this.EligibleApproveNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.EligibleApproveNotificationDefaultRecipient
                    $notificationRecipients = @($this.EligibleApproveNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Approver'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Admin_Admin_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ActiveAlertNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveAlertNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveAlertNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Role assignment alert'
                    $notificationLevel = if ($this.ActiveAlertNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.ActiveAlertNotificationDefaultRecipient
                    $notificationRecipients = @($this.ActiveAlertNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Admin'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Requestor_Admin_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Notification to the assigned user (assignee)'
                    $notificationLevel = if ($this.ActiveAssigneeNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.ActiveAssigneeNotificationDefaultRecipient
                    $notificationRecipients = @($this.ActiveAssigneeNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Requestor'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Approver_Admin_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ActiveApproveNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveApproveNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('ActiveApproveNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Request to approve a role assignment renewal/extension'
                    $notificationLevel = if ($this.ActiveApproveNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.ActiveApproveNotificationDefaultRecipient
                    $notificationRecipients = @($this.ActiveApproveNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Approver'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Admin_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibleAssignmentAlertNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssignmentAlertNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssignmentAlertNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when eligible members activate this role: Role activation alert'
                    $notificationLevel = if ($this.EligibleAssignmentAlertNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.EligibleAssignmentAlertNotificationDefaultRecipient
                    $notificationRecipients = @($this.EligibleAssignmentAlertNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Admin'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Notification_Requestor_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibleAssignmentAssigneeNotificationOnlyCritical') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssignmentAssigneeNotificationDefaultRecipient') `
                        -and $this.GetBoundParameters().ContainsKey('EligibleAssignmentAssigneeNotificationAdditionalRecipient'))
                {
                    Write-Verbose -Message 'Handle Send notifications when eligible members activate this role: Notification to activated user (requestor)'
                    $notificationLevel = if ($this.EligibleAssignmentAssigneeNotificationOnlyCritical -eq 'True')
                    {
                        'Critical'
                    }
                    else
                    {
                        'All'
                    }
                    $isDefaultRecipientsEnabled = $this.EligibleAssignmentAssigneeNotificationDefaultRecipient
                    $notificationRecipients = @($this.EligibleAssignmentAssigneeNotificationAdditionalRecipient)
                    $params = @{
                        '@odata.type'                = $odatatype
                        'recipientType'              = 'Requestor'
                        'notificationType'           = 'Email'
                        'notificationLevel'          = $notificationLevel
                        'isDefaultRecipientsEnabled' = $isDefaultRecipientsEnabled
                        'notificationRecipients'     = $notificationRecipients
                        target                       = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            elseif ($role.id -match 'Expiration_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ActivationMaxDuration'))
                {
                    Write-Verbose -Message 'Handle Activation: Activation maximum duration (hours)'
                    $params = @{
                        '@odata.type'     = $odatatype
                        'id'              = $role.Id
                        'maximumDuration' = $this.ActivationMaxDuration
                        target            = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Enablement_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ActivationReqJustification') `
                        -and $this.GetBoundParameters().ContainsKey('ActivationReqTicket') `
                        -and $this.GetBoundParameters().ContainsKey('ActivationReqMFA'))
                {
                    Write-Verbose -Message 'Handle Activation: Require justification on activation'
                    [String[]]$enabledrules = @()
                    if ($this.ActivationReqJustification)
                    {
                        $enabledrules += 'Justification'
                    }
                    if ($this.ActivationReqTicket)
                    {
                        $enabledrules += 'Ticketing'
                    }
                    if ($this.ActivationReqMFA)
                    {
                        $enabledrules += 'MultiFactorAuthentication'
                    }
                    $params = @{
                        '@odata.type'  = $odatatype
                        'id'           = $role.Id
                        'enabledRules' = $enabledrules
                        target         = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            elseif ($role.Id -match 'Approval_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('ApprovaltoActivate') `
                        -and $this.GetBoundParameters().ContainsKey('ActivateApprover'))
                {
                    Write-Verbose -Message 'Handle Activation: Require approval to activate / Approvers'
                    $isApprovalRequired = $this.ApprovaltoActivate
                    if ($this.ActivateApprover.Count -gt 0)
                    {
                        $primaryApprovers = @()
                        foreach ($item in $this.ActivateApprover)
                        {
                            #is not a guid try with user
                            $userFilter = "UserPrincipalName eq '" + $item + "'"
                            $user = Get-MgUser -Filter $userFilter
                            if ($null -ne $user)
                            {
                                $ActivateApprovers = @{}
                                $ActivateApprovers.Add('@odata.type', '#microsoft.graph.singleUser')
                                $ActivateApprovers.Add('userId', $user.Id)
                                $primaryApprovers += $ActivateApprovers
                                $user = $null
                            }
                            else
                            {
                                Write-Verbose -Message "User '$item' not found, trying with group"

                                $groupByNameFilter = "displayName eq '" + $item + "'"
                                $group = Get-MgGroup -Filter $groupByNameFilter
                                if ($null -ne $group)
                                {
                                    $ActivateApprovers = @{}
                                    $ActivateApprovers.Add('@odata.type', '#microsoft.graph.groupMembers')
                                    $ActivateApprovers.Add('groupId', $group.Id)
                                    $primaryApprovers += $ActivateApprovers
                                    $group = $null
                                }
                                else
                                {
                                    throw "Group '$item' not found. Cannot add as approver."
                                }
                            }
                        }
                    }
                    $approvalStages = @{}
                    $approvalStages.Add('approvalStageTimeOutInDays', '1')
                    $approvalStages.Add('isApproverJustificationRequired', 'true')
                    $approvalStages.Add('escalationTimeInMinutes', '0')
                    $approvalStages.Add('isEscalationEnabled', 'False')

                    if ($primaryApprovers.Count -gt 0)
                    {
                        $approvalStages.Add('primaryApprovers', @($primaryApprovers))
                    }
                    else
                    {
                        $approvalStages.Add('primaryApprovers', @())
                    }
                    $approvalStages.Add('escalationApprovers', @())

                    $setting = @{}
                    $setting.Add('isApprovalRequired', $isApprovalRequired)
                    $setting.Add('isApprovalRequiredForExtension', 'false')
                    $setting.Add('isRequestorJustificationRequired', 'true')
                    $setting.Add('approvalMode', 'SingleStage')
                    $setting.Add('approvalStages', @($approvalStages))

                    $params = @{
                        '@odata.type' = $odatatype
                        'id'          = $role.Id
                        'setting'     = $setting
                        target        = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            elseif ($role.id -match 'Expiration_Admin_Eligibility')
            {
                if ($this.GetBoundParameters().ContainsKey('PermanentEligibleAssignmentisExpirationRequired') `
                        -and $this.GetBoundParameters().ContainsKey('ExpireEligibleAssignment'))
                {
                    Write-Verbose -Message 'Handle Assignment: Allow permanent eligible assignment / Expire eligible assignments after'
                    $params = @{
                        '@odata.type'          = $odatatype
                        'id'                   = $role.Id
                        'isExpirationRequired' = $this.PermanentEligibleAssignmentisExpirationRequired
                        'maximumDuration'      = $this.ExpireEligibleAssignment
                        target                 = @{
                            '@odata.type' = 'microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            elseif ($role.id -match 'Expiration_Admin_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('PermanentActiveAssignmentisExpirationRequired') `
                        -and $this.GetBoundParameters().ContainsKey('ExpireActiveAssignment'))
                {
                    Write-Verbose -Message 'Handle Assignment: Allow permanent active assignment / Expire active assignments after'
                    $params = @{
                        '@odata.type'          = $odatatype
                        'id'                   = $role.Id
                        'isExpirationRequired' = $this.PermanentActiveAssignmentisExpirationRequired
                        'maximumDuration'      = $this.ExpireActiveAssignment
                        target                 = @{
                            '@odata.type' = 'microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            elseif ($role.id -match 'Enablement_Admin_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('AssignmentReqJustification') `
                        -and $this.GetBoundParameters().ContainsKey('AssignmentReqMFA'))
                {
                    Write-Verbose -Message 'Handle Assignment: Require Azure Multi-Factor Authentication on active assignment / Require justification on active assignment'
                    [String[]]$enabledrules = @()
                    if ($this.AssignmentReqJustification)
                    {
                        $enabledrules += 'Justification'
                    }
                    if ($this.AssignmentReqMFA)
                    {
                        $enabledrules += 'MultiFactorAuthentication'
                    }
                    $params = @{
                        '@odata.type'  = $odatatype
                        'id'           = $role.Id
                        'enabledRules' = $enabledrules
                        target         = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.id -match 'Enablement_Admin_Eligibility')
            {
                if ($this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqJustification') `
                        -and $this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqMFA'))
                {
                    Write-Verbose -Message 'Handle Assignment: Require Azure Multi-Factor Authentication on eligibility / Require justification on eligibility'
                    [String[]]$enabledrules = @()
                    if ($this.EligibilityAssignmentReqJustification)
                    {
                        $enabledrules += 'Justification'
                    }
                    if ($this.EligibilityAssignmentReqMFA)
                    {
                        $enabledrules += 'MultiFactorAuthentication'
                    }
                    $params = @{
                        '@odata.type'  = $odatatype
                        'id'           = $role.Id
                        'enabledRules' = $enabledrules
                        target         = @{
                            '@odata.type' = '#microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }
            elseif ($role.Id -match 'AuthenticationContext_EndUser_Assignment')
            {
                if ($this.GetBoundParameters().ContainsKey('AuthenticationContextRequired') `
                        -and $this.GetBoundParameters().ContainsKey('AuthenticationContextId'))
                {
                    $params = @{
                        '@odata.type' = $odatatype
                        'id'          = $role.Id
                        'isEnabled'   = (-not [System.String]::IsNullOrEmpty($this.AuthenticationContextId))
                        'claimValue'  = $this.AuthenticationContextId
                        target        = @{
                            '@odata.type' = 'microsoft.graph.unifiedRoleManagementPolicyRuleTarget'
                        }
                    }
                }
            }

            if ($params.Count -gt 0)
            {
                try
                {
                    Update-MgBetaPolicyRoleManagementPolicyRule `
                        -UnifiedRoleManagementPolicyId $Policy.Policyid `
                        -UnifiedRoleManagementPolicyRuleId $role.id `
                        -BodyParameter $params `
                        -ErrorAction Stop
                }
                catch
                {
                    throw $_
                }
                $params = @{}
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $mergedFilter = $this.Filter
        if ($this.Filter -notlike '*DynamicMembership*')
        {
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "$($this.Filter) and"
            }
            $mergedFilter = "$mergedFilter NOT(groupTypes/any(x:x eq 'DynamicMembership'))"
        }

        $ExportParameters = @{
            Filter           = $mergedFilter
            All              = [switch]$true
            Property         = 'displayname,Id'
            CountVariable    = 'CountVar'
            ConsistencyLevel = 'eventual'
            ErrorAction      = 'Stop'
            Sort             = 'displayname'
        }

        try
        {
            $this.ResourceCache['ExportMode'] = $true
            $pimGroupIds = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($pimGroup in (Get-M365DSCExportCachedCollection -Collection 'pimGroups'))
            {
                $null = $pimGroupIds.Add($pimGroup.Id)
            }

            [array] $this.ResourceCache['exportedGroups'] = Get-MgGroup @ExportParameters
            $this.ResourceCache['exportedGroups'] = $this.ResourceCache['exportedGroups'] | Where-Object -FilterScript {
                $pimGroupIds.Contains($_.Id) -and `
                    -not ($_.MailEnabled -and ($null -eq $_.GroupTypes -or $_.GroupTypes.Length -eq 0)) -and `
                    -not ($_.MailEnabled -and $_.SecurityEnabled)
            }

            $j = 1
            if ($this.ResourceCache['exportedGroups'].Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $batchRequests = @()
            foreach ($group in $this.ResourceCache['exportedGroups'])
            {
                $batchRequests += @{
                    id     = $group.Id
                    method = 'GET'
                    url    = "/policies/roleManagementPolicyAssignments?filter=scopeId eq '$($group.Id)' and scopeType eq 'Group'&`$expand=policy(`$expand=rules)"
                }
            }

            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests -AsList

            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($group in $this.ResourceCache['exportedGroups'])
            {
                $response = $batchResponses | Where-Object { $_.id -eq $group.Id }
                $getValue = $response.body.value
                Write-M365DSCHost -Message "    |---[$j/$($this.ResourceCache['exportedGroups'].Count)] $($group.DisplayName)" -DeferWrite

                $i = 1

                if ($getValue.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                foreach ($config in $getValue)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    Write-M365DSCHost -Message "        |---[$i/$($getValue.Count)] $($config.Id)" -DeferWrite

                    $Params = @{
                        Id                    = $config.Id
                        RoleDefinitionId      = $config.roleDefinitionId
                        DisplayName           = $group.DisplayName
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $this.TenantId
                        ApplicationSecret     = $this.ApplicationSecret
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $this.ExportedInstance = $config
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()
                    if ($Results.Ensure -eq 'Present')
                    {
                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -RawResults $rawResults
                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                    }
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
                }
                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADPIMGroupSetting] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADPIMGroupSetting])
        {
            return $Values
        }

        $result = [AADPIMGroupSetting]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
