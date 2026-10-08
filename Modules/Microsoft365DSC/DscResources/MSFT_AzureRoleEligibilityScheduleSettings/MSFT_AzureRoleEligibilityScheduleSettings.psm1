using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureRoleEligibilityScheduleSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the role definition being governed by this policy.')]
    [System.String] $RoleDefinitionDisplayName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The scope of the role management policy. Supports subscriptions/{id}, subscriptions/{id}/resourceGroups/{name}, and providers/Microsoft.Management/managementGroups/{name} scopes.')]
    [System.String] $ScopeId

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the internal Policy Id.')]
    [System.String] $PolicyId

    [DscProperty()]
    [System.ComponentModel.Description('Activation maximum duration (hours).')]
    [System.String] $ActivationMaxDuration

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on activation (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Require ticket information on activation (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationReqTicket

    [DscProperty()]
    [System.ComponentModel.Description('Require MFA on activation (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require approval to activate (True/False).')]
    [System.Nullable[System.Boolean]] $ApprovaltoActivate

    [DscProperty()]
    [System.ComponentModel.Description('List of approvers by name. Provide the UserPrincipalName for users (e.g., ''john@contoso.com'') or the DisplayName for groups (e.g., ''PIM Approvers''). The resource tries to resolve as a user first, then as a group.')]
    [System.String[]] $ActivateApprover

    [DscProperty()]
    [System.ComponentModel.Description('Require authentication context on activation (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationReqAuthContext

    [DscProperty()]
    [System.ComponentModel.Description('Authentication context claim value (Conditional Access policy id) for activation.')]
    [System.String] $ActivationAuthContextId

    [DscProperty()]
    [System.ComponentModel.Description('Allow permanent eligible assignment (True/False).')]
    [System.Nullable[System.Boolean]] $PermanentEligibleAssignmentisExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Expire eligible assignments after (Days).')]
    [System.String] $ExpireEligibleAssignment

    [DscProperty()]
    [System.ComponentModel.Description('Allow permanent active assignment (True/False).')]
    [System.Nullable[System.Boolean]] $PermanentActiveAssignmentisExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Expire active assignments after (Days).')]
    [System.String] $ExpireActiveAssignment

    [DscProperty()]
    [System.ComponentModel.Description('Require Azure Multi-Factor Authentication on active assignment (True/False).')]
    [System.Nullable[System.Boolean]] $AssignmentReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on active assignment (True/False).')]
    [System.Nullable[System.Boolean]] $AssignmentReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Require Azure Multi-Factor Authentication on eligible assignment (True/False).')]
    [System.Nullable[System.Boolean]] $EligibilityAssignmentReqMFA

    [DscProperty()]
    [System.ComponentModel.Description('Require justification on eligible assignment (True/False).')]
    [System.Nullable[System.Boolean]] $EligibilityAssignmentReqJustification

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Role assignment alert, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Role assignment alert, additional recipient (UPN).')]
    [System.String[]] $EligibleAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Role assignment alert, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Notification to the assigned user (assignee), default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Notification to the assigned user (assignee), additional recipient (UPN).')]
    [System.String[]] $EligibleAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Notification to the assigned user (assignee), only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Request to approve a role assignment renewal/extension, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleApproveNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Request to approve a role assignment renewal/extension, additional recipient (UPN).')]
    [System.String[]] $EligibleApproveNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as eligible to this role: Request to approve a role assignment renewal/extension, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $EligibleApproveNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Role assignment alert, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Role assignment alert, additional recipient (UPN).')]
    [System.String[]] $ActiveAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Role assignment alert, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Notification to the assigned user (assignee), default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Notification to the assigned user (assignee), additional recipient (UPN).')]
    [System.String[]] $ActiveAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Notification to the assigned user (assignee), only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Request to approve a role assignment renewal/extension, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveApproveNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Request to approve a role assignment renewal/extension, additional recipient (UPN).')]
    [System.String[]] $ActiveApproveNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when members are assigned as active to this role: Request to approve a role assignment renewal/extension, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActiveApproveNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Role activation alert, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationAlertNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Role activation alert, additional recipient (UPN).')]
    [System.String[]] $ActivationAlertNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Role activation alert, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationAlertNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to activated user (requestor), default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationAssigneeNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to activated user (requestor), additional recipient (UPN).')]
    [System.String[]] $ActivationAssigneeNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to activated user (requestor), only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationAssigneeNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to approvers, default recipient (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationApproveNotificationDefaultRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to approvers, additional recipient (UPN).')]
    [System.String[]] $ActivationApproveNotificationAdditionalRecipient

    [DscProperty()]
    [System.ComponentModel.Description('Send notifications when eligible members activate this role: Notification to approvers, only critical Email (True/False).')]
    [System.Nullable[System.Boolean]] $ActivationApproveNotificationOnlyCritical

    [DscProperty()]
    [System.ComponentModel.Description('The Azure subscription to connect to if the access is restricted on subscription level.')]
    [System.String] $SubscriptionId

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

    [AzureRoleEligibilityScheduleSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureRoleEligibilityScheduleSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Role Eligibility Schedule Settings for Role {$($this.RoleDefinitionDisplayName)} at Scope {$($this.ScopeId)}"

        if ($null -eq $this.ExportedInstance)
        {
            $null = $this.Connect('Azure')
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()

            $apiVersion = '2020-10-01'
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.ScopeId)/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=$apiVersion"
            $response = Invoke-AzRestMethod -Uri $uri -Method GET
            $assignments = (ConvertFrom-Json $response.Content).value

            if ($null -eq $assignments -or $assignments.Count -eq 0)
            {
                Write-Verbose -Message "No role management policy assignments found at scope {$($this.ScopeId)}."
                return $this.AsResult($nullReturn)
            }

            $assignment = $assignments | Where-Object {
                $_.properties.roleDefinitionDisplayName -eq $this.RoleDefinitionDisplayName -or
                $_.properties.policyAssignmentProperties.roleDefinition.displayName -eq $this.RoleDefinitionDisplayName
            }

            if ($null -eq $assignment)
            {
                $roleDefUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.ScopeId)/providers/Microsoft.Authorization/roleDefinitions?api-version=$apiVersion&`$filter=roleName eq '$($this.RoleDefinitionDisplayName)'"
                $roleDefResponse = Invoke-AzRestMethod -Uri $roleDefUri -Method GET
                $roleDefinitions = (ConvertFrom-Json $roleDefResponse.Content).value

                if ($null -ne $roleDefinitions -and $roleDefinitions.Count -gt 0)
                {
                    $roleDefId = $roleDefinitions[0].id
                    $assignment = $assignments | Where-Object {
                        $_.properties.roleDefinitionId -eq $roleDefId
                    }
                }
            }

            if ($null -eq $assignment)
            {
                Write-Verbose -Message "Could not find role management policy assignment for role {$($this.RoleDefinitionDisplayName)} at scope {$($this.ScopeId)}."
                return $this.AsResult($nullReturn)
            }

            $policyIdValue = $assignment.properties.policyId.Split('/')[-1]

            $policyUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.ScopeId)/providers/Microsoft.Authorization/roleManagementPolicies/$($policyIdValue)?api-version=$apiVersion"
            $policyResponse = Invoke-AzRestMethod -Uri $policyUri -Method GET
            $policy = ConvertFrom-Json $policyResponse.Content

            if ($null -eq $policy -or $null -eq $policy.properties -or $null -eq $policy.properties.rules)
            {
                Write-Verbose -Message "Could not retrieve role management policy {$policyIdValue} at scope {$($this.ScopeId)}."
                return $this.AsResult($nullReturn)
            }

            $rules = $policy.properties.rules
        }
        else
        {
            $rules = $this.ExportedInstance.rules
            $policyIdValue = $this.ExportedInstance.policyId
        }

        $nullReturn = $this.GetBoundParameters()

        if ($null -eq $rules -or $rules.Count -eq 0)
        {
            Write-Verbose -Message 'No Policy Rules found, returning null'
            return $this.AsResult($nullReturn)
        }

        try
        {
            # Extract activation settings
            $result = @{}
            $result.ActivationMaxDuration = ($rules | Where-Object { $_.id -eq 'Expiration_EndUser_Assignment' }).maximumDuration
            $result.ActivationReqJustification = (($rules | Where-Object { $_.id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'Justification'
            $result.ActivationReqTicket = (($rules | Where-Object { $_.id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'Ticketing'
            $result.ActivationReqMFA = (($rules | Where-Object { $_.id -eq 'Enablement_EndUser_Assignment' }).enabledRules) -contains 'MultiFactorAuthentication'
            $result.ApprovaltoActivate = ($rules | Where-Object { $_.id -eq 'Approval_EndUser_Assignment' }).setting.isApprovalRequired
            $result.ActivationReqAuthContext = ($rules | Where-Object { $_.id -eq 'AuthenticationContext_EndUser_Assignment' }).isEnabled
            $result.ActivationAuthContextId = ($rules | Where-Object { $_.id -eq 'AuthenticationContext_EndUser_Assignment' }).claimValue
            [string[]]$result.ActivateApprover = @()
            $approverEntries = ($rules | Where-Object { $_.id -eq 'Approval_EndUser_Assignment' }).setting.approvalStages
            if ($null -ne $approverEntries -and $approverEntries.Count -gt 0)
            {
                foreach ($approver in $approverEntries[0].primaryApprovers)
                {
                    if (-not [System.String]::IsNullOrEmpty($approver.id))
                    {
                        $directoryObject = Get-MgBetaDirectoryObjectById -Ids $approver.id -ErrorAction SilentlyContinue
                        if ($null -ne $directoryObject)
                        {
                            $odataType = $directoryObject['@odata.type']
                            if (-not [System.String]::IsNullOrEmpty($odataType) -and $odataType.Split('.').Count -ge 3)
                            {
                                $objectType = $odataType.Split('.')[2]
                                if ($objectType -eq 'user')
                                {
                                    $result.ActivateApprover += $directoryObject['userPrincipalName']
                                }
                                else
                                {
                                    $result.ActivateApprover += $directoryObject['displayName']
                                }
                            }
                            else
                            {
                                Write-Verbose -Message "Could not determine type for approver with Id {$($approver.id)}"
                            }
                        }
                        else
                        {
                            Write-Verbose -Message "Could not resolve approver with Id {$($approver.id)}"
                        }
                    }
                }
            }

            # Extract eligible assignment settings
            $result.PermanentEligibleAssignmentisExpirationRequired = ($rules | Where-Object { $_.id -eq 'Expiration_Admin_Eligibility' }).isExpirationRequired
            $result.ExpireEligibleAssignment = ($rules | Where-Object { $_.id -eq 'Expiration_Admin_Eligibility' }).maximumDuration

            # Extract active assignment settings
            $result.PermanentActiveAssignmentisExpirationRequired = ($rules | Where-Object { $_.id -eq 'Expiration_Admin_Assignment' }).isExpirationRequired
            $result.ExpireActiveAssignment = ($rules | Where-Object { $_.id -eq 'Expiration_Admin_Assignment' }).maximumDuration
            $result.AssignmentReqMFA = (($rules | Where-Object { $_.id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'MultiFactorAuthentication'
            $result.AssignmentReqJustification = (($rules | Where-Object { $_.id -eq 'Enablement_Admin_Assignment' }).enabledRules) -contains 'Justification'

            # Extract eligible assignment enablement settings
            $result.EligibilityAssignmentReqMFA = (($rules | Where-Object { $_.id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'MultiFactorAuthentication'
            $result.EligibilityAssignmentReqJustification = (($rules | Where-Object { $_.id -eq 'Enablement_Admin_Eligibility' }).enabledRules) -contains 'Justification'

            # Extract notification settings for eligible assignments
            $result.EligibleAlertNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$result.EligibleAlertNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Eligibility' }).notificationRecipients
            $result.EligibleAlertNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Eligibility' }).notificationLevel) -eq 'Critical'
            $result.EligibleAssigneeNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$result.EligibleAssigneeNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationRecipients
            $result.EligibleAssigneeNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Eligibility' }).notificationLevel) -eq 'Critical'
            $result.EligibleApproveNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Eligibility' }).isDefaultRecipientsEnabled
            [string[]]$result.EligibleApproveNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Eligibility' }).notificationRecipients
            $result.EligibleApproveNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Eligibility' }).notificationLevel) -eq 'Critical'

            # Extract notification settings for active assignments
            $result.ActiveAlertNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActiveAlertNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Assignment' }).notificationRecipients
            $result.ActiveAlertNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Admin_Admin_Assignment' }).notificationLevel) -eq 'Critical'
            $result.ActiveAssigneeNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActiveAssigneeNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Assignment' }).notificationRecipients
            $result.ActiveAssigneeNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Requestor_Admin_Assignment' }).notificationLevel) -eq 'Critical'
            $result.ActiveApproveNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActiveApproveNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Assignment' }).notificationRecipients
            $result.ActiveApproveNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Approver_Admin_Assignment' }).notificationLevel) -eq 'Critical'

            # Extract notification settings for activation
            $result.ActivationAlertNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActivationAlertNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Admin_EndUser_Assignment' }).notificationRecipients
            $result.ActivationAlertNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Admin_EndUser_Assignment' }).notificationLevel) -eq 'Critical'
            $result.ActivationAssigneeNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActivationAssigneeNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationRecipients
            $result.ActivationAssigneeNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Requestor_EndUser_Assignment' }).notificationLevel) -eq 'Critical'
            $result.ActivationApproveNotificationDefaultRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_EndUser_Assignment' }).isDefaultRecipientsEnabled
            [string[]]$result.ActivationApproveNotificationAdditionalRecipient = ($rules | Where-Object { $_.id -eq 'Notification_Approver_EndUser_Assignment' }).notificationRecipients
            $result.ActivationApproveNotificationOnlyCritical = (($rules | Where-Object { $_.id -eq 'Notification_Approver_EndUser_Assignment' }).notificationLevel) -eq 'Critical'

            Write-Verbose -Message "Found configuration for Role {$($this.RoleDefinitionDisplayName)} at Scope {$($this.ScopeId)}"
            $resultObj = @{
                RoleDefinitionDisplayName                                 = $this.RoleDefinitionDisplayName
                ScopeId                                                   = $this.ScopeId
                PolicyId                                                  = $policyIdValue
                ActivationMaxDuration                                     = $result.ActivationMaxDuration
                ActivationReqJustification                                = $result.ActivationReqJustification
                ActivationReqTicket                                       = $result.ActivationReqTicket
                ActivationReqMFA                                          = $result.ActivationReqMFA
                ApprovaltoActivate                                        = $result.ApprovaltoActivate
                ActivateApprover                                          = [System.String[]]$result.ActivateApprover
                ActivationReqAuthContext                                  = $result.ActivationReqAuthContext
                ActivationAuthContextId                                   = $result.ActivationAuthContextId
                PermanentEligibleAssignmentisExpirationRequired           = $result.PermanentEligibleAssignmentisExpirationRequired
                ExpireEligibleAssignment                                  = $result.ExpireEligibleAssignment
                PermanentActiveAssignmentisExpirationRequired             = $result.PermanentActiveAssignmentisExpirationRequired
                ExpireActiveAssignment                                    = $result.ExpireActiveAssignment
                AssignmentReqMFA                                          = $result.AssignmentReqMFA
                AssignmentReqJustification                                = $result.AssignmentReqJustification
                EligibilityAssignmentReqMFA                               = $result.EligibilityAssignmentReqMFA
                EligibilityAssignmentReqJustification                     = $result.EligibilityAssignmentReqJustification
                EligibleAlertNotificationDefaultRecipient                 = $result.EligibleAlertNotificationDefaultRecipient
                EligibleAlertNotificationAdditionalRecipient              = [System.String[]]$result.EligibleAlertNotificationAdditionalRecipient
                EligibleAlertNotificationOnlyCritical                     = $result.EligibleAlertNotificationOnlyCritical
                EligibleAssigneeNotificationDefaultRecipient              = $result.EligibleAssigneeNotificationDefaultRecipient
                EligibleAssigneeNotificationAdditionalRecipient           = [System.String[]]$result.EligibleAssigneeNotificationAdditionalRecipient
                EligibleAssigneeNotificationOnlyCritical                  = $result.EligibleAssigneeNotificationOnlyCritical
                EligibleApproveNotificationDefaultRecipient               = $result.EligibleApproveNotificationDefaultRecipient
                EligibleApproveNotificationAdditionalRecipient            = [System.String[]]$result.EligibleApproveNotificationAdditionalRecipient
                EligibleApproveNotificationOnlyCritical                   = $result.EligibleApproveNotificationOnlyCritical
                ActiveAlertNotificationDefaultRecipient                   = $result.ActiveAlertNotificationDefaultRecipient
                ActiveAlertNotificationAdditionalRecipient                = [System.String[]]$result.ActiveAlertNotificationAdditionalRecipient
                ActiveAlertNotificationOnlyCritical                       = $result.ActiveAlertNotificationOnlyCritical
                ActiveAssigneeNotificationDefaultRecipient                = $result.ActiveAssigneeNotificationDefaultRecipient
                ActiveAssigneeNotificationAdditionalRecipient             = [System.String[]]$result.ActiveAssigneeNotificationAdditionalRecipient
                ActiveAssigneeNotificationOnlyCritical                    = $result.ActiveAssigneeNotificationOnlyCritical
                ActiveApproveNotificationDefaultRecipient                 = $result.ActiveApproveNotificationDefaultRecipient
                ActiveApproveNotificationAdditionalRecipient              = [System.String[]]$result.ActiveApproveNotificationAdditionalRecipient
                ActiveApproveNotificationOnlyCritical                     = $result.ActiveApproveNotificationOnlyCritical
                ActivationAlertNotificationDefaultRecipient               = $result.ActivationAlertNotificationDefaultRecipient
                ActivationAlertNotificationAdditionalRecipient            = [System.String[]]$result.ActivationAlertNotificationAdditionalRecipient
                ActivationAlertNotificationOnlyCritical                   = $result.ActivationAlertNotificationOnlyCritical
                ActivationAssigneeNotificationDefaultRecipient            = $result.ActivationAssigneeNotificationDefaultRecipient
                ActivationAssigneeNotificationAdditionalRecipient         = [System.String[]]$result.ActivationAssigneeNotificationAdditionalRecipient
                ActivationAssigneeNotificationOnlyCritical                = $result.ActivationAssigneeNotificationOnlyCritical
                ActivationApproveNotificationDefaultRecipient             = $result.ActivationApproveNotificationDefaultRecipient
                ActivationApproveNotificationAdditionalRecipient          = [System.String[]]$result.ActivationApproveNotificationAdditionalRecipient
                ActivationApproveNotificationOnlyCritical                 = $result.ActivationApproveNotificationOnlyCritical
                ApplicationId                                             = $this.ApplicationId
                TenantId                                                  = $this.TenantId
                CertificateThumbprint                                     = $this.CertificateThumbprint
                ApplicationSecret                                         = $this.ApplicationSecret
                SubscriptionId                                            = $this.SubscriptionId
                Credential                                                = $this.Credential
                ManagedIdentity                                           = $this.ManagedIdentity
                AccessTokens                                              = $this.AccessTokens
            }
            return $this.AsResult($resultObj)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of Azure Role Eligibility Schedule Settings for Role {$($this.RoleDefinitionDisplayName)} at Scope {$($this.ScopeId)}"

        try
        {
            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Set')
            #endregion

            $currentInstance = $this.Get().ToHashtable()

            $policyIdValue = $currentInstance.PolicyId
            if ([System.String]::IsNullOrEmpty($policyIdValue))
            {
                throw "Could not find role management policy for role {$($this.RoleDefinitionDisplayName)} at scope {$($this.ScopeId)}"
            }

            # Get the full policy to retrieve all current rules
            $apiVersion = '2020-10-01'
            $policyUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.ScopeId)/providers/Microsoft.Authorization/roleManagementPolicies/$($policyIdValue)?api-version=$apiVersion"
            $policyResponse = Invoke-AzRestMethod -Uri $policyUri -Method GET
            $policy = ConvertFrom-Json $policyResponse.Content
            $rules = $policy.properties.rules
            $ruleModified = $false

            foreach ($currentRule in $rules)
            {
                $params = @{}

                if ($currentRule.id -eq 'Notification_Admin_Admin_Eligibility')
                {
                    if ($this.GetBoundParameters().ContainsKey('EligibleAlertNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleAlertNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleAlertNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Role assignment alert'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('EligibleAlertNotificationOnlyCritical')) { $this.EligibleAlertNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleAlertNotificationDefaultRecipient')) { $this.EligibleAlertNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleAlertNotificationAdditionalRecipient')) { @($this.EligibleAlertNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Admin'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Requestor_Admin_Eligibility')
                {
                    if ($this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Notification to the assigned user (assignee)'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationOnlyCritical')) { $this.EligibleAssigneeNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationDefaultRecipient')) { $this.EligibleAssigneeNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleAssigneeNotificationAdditionalRecipient')) { @($this.EligibleAssigneeNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Requestor'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Approver_Admin_Eligibility')
                {
                    if ($this.GetBoundParameters().ContainsKey('EligibleApproveNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleApproveNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('EligibleApproveNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as eligible to this role: Request to approve a role assignment renewal/extension'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('EligibleApproveNotificationOnlyCritical')) { $this.EligibleApproveNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleApproveNotificationDefaultRecipient')) { $this.EligibleApproveNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('EligibleApproveNotificationAdditionalRecipient')) { @($this.EligibleApproveNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Approver'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Admin_Admin_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActiveAlertNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveAlertNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveAlertNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Role assignment alert'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActiveAlertNotificationOnlyCritical')) { $this.ActiveAlertNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveAlertNotificationDefaultRecipient')) { $this.ActiveAlertNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveAlertNotificationAdditionalRecipient')) { @($this.ActiveAlertNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Admin'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Requestor_Admin_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Notification to the assigned user (assignee)'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationOnlyCritical')) { $this.ActiveAssigneeNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationDefaultRecipient')) { $this.ActiveAssigneeNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveAssigneeNotificationAdditionalRecipient')) { @($this.ActiveAssigneeNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Requestor'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Approver_Admin_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActiveApproveNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveApproveNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActiveApproveNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when members are assigned as active to this role: Request to approve a role assignment renewal/extension'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActiveApproveNotificationOnlyCritical')) { $this.ActiveApproveNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveApproveNotificationDefaultRecipient')) { $this.ActiveApproveNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActiveApproveNotificationAdditionalRecipient')) { @($this.ActiveApproveNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Approver'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Admin_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationAlertNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationAlertNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationAlertNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when eligible members activate this role: Role activation alert'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActivationAlertNotificationOnlyCritical')) { $this.ActivationAlertNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationAlertNotificationDefaultRecipient')) { $this.ActivationAlertNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationAlertNotificationAdditionalRecipient')) { @($this.ActivationAlertNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Admin'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Requestor_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when eligible members activate this role: Notification to activated user (requestor)'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationOnlyCritical')) { $this.ActivationAssigneeNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationDefaultRecipient')) { $this.ActivationAssigneeNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationAssigneeNotificationAdditionalRecipient')) { @($this.ActivationAssigneeNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Requestor'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Notification_Approver_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationApproveNotificationOnlyCritical') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationApproveNotificationDefaultRecipient') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationApproveNotificationAdditionalRecipient'))
                    {
                        Write-Verbose -Message 'Handle Send notifications when eligible members activate this role: Notification to approvers'
                        $onlyCritical = if ($this.GetBoundParameters().ContainsKey('ActivationApproveNotificationOnlyCritical')) { $this.ActivationApproveNotificationOnlyCritical } else { $currentRule.notificationLevel -eq 'Critical' }
                        $defaultRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationApproveNotificationDefaultRecipient')) { $this.ActivationApproveNotificationDefaultRecipient } else { $currentRule.isDefaultRecipientsEnabled }
                        $additionalRecipient = if ($this.GetBoundParameters().ContainsKey('ActivationApproveNotificationAdditionalRecipient')) { @($this.ActivationApproveNotificationAdditionalRecipient) } else { @($currentRule.notificationRecipients) }
                        $notificationLevel = if ($onlyCritical)
                        {
                            'Critical'
                        }
                        else
                        {
                            'All'
                        }
                        $params = @{
                            ruleType                 = $currentRule.ruleType
                            id                       = $currentRule.id
                            notificationType         = 'Email'
                            recipientType            = 'Approver'
                            notificationLevel        = $notificationLevel
                            isDefaultRecipientsEnabled = $defaultRecipient
                            notificationRecipients   = [System.Collections.ArrayList]@($additionalRecipient)
                            target                   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Expiration_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationMaxDuration'))
                    {
                        Write-Verbose -Message 'Handle Activation: Activation maximum duration (hours)'
                        $params = @{
                            ruleType        = $currentRule.ruleType
                            id              = $currentRule.id
                            maximumDuration = $this.ActivationMaxDuration
                            target          = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Enablement_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationReqJustification') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationReqTicket') `
                            -or $this.GetBoundParameters().ContainsKey('ActivationReqMFA'))
                    {
                        Write-Verbose -Message 'Handle Activation: Require justification / ticket / MFA on activation'
                        $reqJustification = if ($this.GetBoundParameters().ContainsKey('ActivationReqJustification')) { $this.ActivationReqJustification } else { ($currentRule.enabledRules) -contains 'Justification' }
                        $reqTicket = if ($this.GetBoundParameters().ContainsKey('ActivationReqTicket')) { $this.ActivationReqTicket } else { ($currentRule.enabledRules) -contains 'Ticketing' }
                        $reqMFA = if ($this.GetBoundParameters().ContainsKey('ActivationReqMFA')) { $this.ActivationReqMFA } else { ($currentRule.enabledRules) -contains 'MultiFactorAuthentication' }
                        [String[]]$enabledrules = @()
                        if ($reqJustification)
                        {
                            $enabledrules += 'Justification'
                        }
                        if ($reqTicket)
                        {
                            $enabledrules += 'Ticketing'
                        }
                        if ($reqMFA)
                        {
                            $enabledrules += 'MultiFactorAuthentication'
                        }
                        $params = @{
                            ruleType     = $currentRule.ruleType
                            id           = $currentRule.id
                            enabledRules = [System.Collections.ArrayList]@($enabledrules)
                            target       = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Approval_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ApprovaltoActivate') `
                            -and $this.GetBoundParameters().ContainsKey('ActivateApprover'))
                    {
                        Write-Verbose -Message 'Handle Activation: Require approval to activate / Approvers'
                        $primaryApprovers = @()
                        if ($this.ActivateApprover.Count -gt 0)
                        {
                            foreach ($item in $this.ActivateApprover)
                            {
                                $userFilter = "UserPrincipalName eq '$($item -replace "'", "''")'"
                                $user = Get-MgUser -Filter $userFilter -ErrorAction SilentlyContinue
                                if ($null -ne $user)
                                {
                                    $primaryApprovers += @{
                                        id       = $user.Id
                                        userType = 'User'
                                        isBackup = $false
                                    }
                                }
                                else
                                {
                                    Write-Verbose -Message "User '$item' not found, trying with group"
                                    $groupFilter = "displayName eq '$($item -replace "'", "''")'"
                                    $group = Get-MgGroup -Filter $groupFilter -ErrorAction SilentlyContinue
                                    if ($null -ne $group)
                                    {
                                        $primaryApprovers += @{
                                            id       = $group.Id
                                            userType = 'Group'
                                            isBackup = $false
                                        }
                                    }
                                    else
                                    {
                                        throw "Approver '$item' not found as user or group. Cannot add as approver."
                                    }
                                }
                            }
                        }

                        $approvalStages = @{
                            approvalStageTimeOutInDays     = 1
                            isApproverJustificationRequired = $true
                            escalationTimeInMinutes        = 0
                            isEscalationEnabled            = $false
                            primaryApprovers               = [System.Collections.ArrayList]@($primaryApprovers)
                            escalationApprovers            = [System.Collections.ArrayList]@()
                        }

                        $setting = @{
                            isApprovalRequired              = $this.ApprovaltoActivate
                            isApprovalRequiredForExtension  = $false
                            isRequestorJustificationRequired = $true
                            approvalMode                    = 'SingleStage'
                            approvalStages                  = [System.Collections.ArrayList]@($approvalStages)
                        }

                        $params = @{
                            ruleType = $currentRule.ruleType
                            id       = $currentRule.id
                            setting  = $setting
                            target   = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Expiration_Admin_Eligibility')
                {
                    if ($this.GetBoundParameters().ContainsKey('PermanentEligibleAssignmentisExpirationRequired') `
                            -and $this.GetBoundParameters().ContainsKey('ExpireEligibleAssignment'))
                    {
                        Write-Verbose -Message 'Handle Assignment: Allow permanent eligible assignment / Expire eligible assignments after'
                        $params = @{
                            ruleType             = $currentRule.ruleType
                            id                   = $currentRule.id
                            isExpirationRequired = $this.PermanentEligibleAssignmentisExpirationRequired
                            maximumDuration      = $this.ExpireEligibleAssignment
                            target               = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Expiration_Admin_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('PermanentActiveAssignmentisExpirationRequired') `
                            -and $this.GetBoundParameters().ContainsKey('ExpireActiveAssignment'))
                    {
                        Write-Verbose -Message 'Handle Assignment: Allow permanent active assignment / Expire active assignments after'
                        $params = @{
                            ruleType             = $currentRule.ruleType
                            id                   = $currentRule.id
                            isExpirationRequired = $this.PermanentActiveAssignmentisExpirationRequired
                            maximumDuration      = $this.ExpireActiveAssignment
                            target               = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Enablement_Admin_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('AssignmentReqJustification') `
                            -or $this.GetBoundParameters().ContainsKey('AssignmentReqMFA'))
                    {
                        Write-Verbose -Message 'Handle Assignment: Require MFA / justification on active assignment'
                        $reqJustification = if ($this.GetBoundParameters().ContainsKey('AssignmentReqJustification')) { $this.AssignmentReqJustification } else { ($currentRule.enabledRules) -contains 'Justification' }
                        $reqMFA = if ($this.GetBoundParameters().ContainsKey('AssignmentReqMFA')) { $this.AssignmentReqMFA } else { ($currentRule.enabledRules) -contains 'MultiFactorAuthentication' }
                        [String[]]$enabledrules = @()
                        if ($reqJustification)
                        {
                            $enabledrules += 'Justification'
                        }
                        if ($reqMFA)
                        {
                            $enabledrules += 'MultiFactorAuthentication'
                        }
                        $params = @{
                            ruleType     = $currentRule.ruleType
                            id           = $currentRule.id
                            enabledRules = [System.Collections.ArrayList]@($enabledrules)
                            target       = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'Enablement_Admin_Eligibility')
                {
                    if ($this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqJustification') `
                            -or $this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqMFA'))
                    {
                        Write-Verbose -Message 'Handle Assignment: Require MFA / justification on eligible assignment'
                        $reqJustification = if ($this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqJustification')) { $this.EligibilityAssignmentReqJustification } else { ($currentRule.enabledRules) -contains 'Justification' }
                        $reqMFA = if ($this.GetBoundParameters().ContainsKey('EligibilityAssignmentReqMFA')) { $this.EligibilityAssignmentReqMFA } else { ($currentRule.enabledRules) -contains 'MultiFactorAuthentication' }
                        [String[]]$enabledrules = @()
                        if ($reqJustification)
                        {
                            $enabledrules += 'Justification'
                        }
                        if ($reqMFA)
                        {
                            $enabledrules += 'MultiFactorAuthentication'
                        }
                        $params = @{
                            ruleType     = $currentRule.ruleType
                            id           = $currentRule.id
                            enabledRules = [System.Collections.ArrayList]@($enabledrules)
                            target       = $currentRule.target
                        }
                    }
                }
                elseif ($currentRule.id -eq 'AuthenticationContext_EndUser_Assignment')
                {
                    if ($this.GetBoundParameters().ContainsKey('ActivationReqAuthContext'))
                    {
                        Write-Verbose -Message 'Handle Activation: Require authentication context'
                        $claimValue = $currentRule.claimValue
                        if ($this.GetBoundParameters().ContainsKey('ActivationAuthContextId'))
                        {
                            $claimValue = $this.ActivationAuthContextId
                        }
                        $params = @{
                            ruleType   = $currentRule.ruleType
                            id         = $currentRule.id
                            isEnabled  = $this.ActivationReqAuthContext
                            claimValue = $claimValue
                            target     = $currentRule.target
                        }
                    }
                }

                if ($params.Count -gt 0)
                {
                    # Replace the rule in the array with the updated version
                    for ($i = 0; $i -lt $policy.properties.rules.Count; $i++)
                    {
                        if ($policy.properties.rules[$i].id -eq $currentRule.id)
                        {
                            $policy.properties.rules[$i] = $params
                            $ruleModified = $true
                            break
                        }
                    }
                }
            }

            if ($ruleModified)
            {
                $updateBody = @{
                    properties = @{
                        rules = [System.Collections.ArrayList]@($policy.properties.rules)
                    }
                }

                $payload = ConvertTo-Json $updateBody -Depth 20 -Compress
                Write-Verbose -Message "Updating policy {$policyIdValue} at scope {$($this.ScopeId)}"
                $null = Invoke-AzRestMethod -Uri $policyUri -Method PATCH -Payload $payload
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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

        $ConnectionMode = $this.Connect('Azure')

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $apiVersion = '2020-10-01'

            if ($this.Filter -eq 'ModifiedOnly')
            {
                Write-Verbose -Message 'ModifiedOnly filter specified: only policies with lastModifiedDateTime set (customised from defaults) will be exported.'
            }
            else
            {
                Write-Verbose -Message 'No ModifiedOnly filter: all policies including unchanged defaults will be exported.'
            }

            # Collect all scopes to enumerate
            $scopes = @()

            # Add subscriptions
            $subUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)subscriptions?api-version=2022-12-01"
            $subResponse = Invoke-AzRestMethod -Uri $subUri -Method GET
            $subscriptions = (ConvertFrom-Json $subResponse.Content).value

            foreach ($sub in $subscriptions)
            {
                $scopes += @{
                    ScopeId     = "subscriptions/$($sub.subscriptionId)"
                    DisplayName = $sub.displayName
                    ScopeType   = 'Subscription'
                }

                # Add resource groups under each subscription
                $rgUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)subscriptions/$($sub.subscriptionId)/resourcegroups?api-version=2021-04-01"
                $rgResponse = Invoke-AzRestMethod -Uri $rgUri -Method GET
                $resourceGroups = (ConvertFrom-Json $rgResponse.Content).value

                foreach ($rg in $resourceGroups)
                {
                    $scopes += @{
                        ScopeId     = "subscriptions/$($sub.subscriptionId)/resourceGroups/$($rg.name)"
                        DisplayName = $rg.name
                        ScopeType   = 'ResourceGroup'
                    }
                }
            }

            # Add management groups
            $mgUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Management/managementGroups?api-version=2021-04-01"
            $mgResponse = Invoke-AzRestMethod -Uri $mgUri -Method GET
            $managementGroups = (ConvertFrom-Json $mgResponse.Content).value

            foreach ($mg in $managementGroups)
            {
                $scopes += @{
                    ScopeId     = "providers/Microsoft.Management/managementGroups/$($mg.name)"
                    DisplayName = $mg.properties.displayName
                    ScopeType   = 'ManagementGroup'
                }
            }

            [System.Collections.Generic.List[hashtable]] $exportedInstances = [System.Collections.Generic.List[hashtable]]::new()
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            $j = 1

            foreach ($scopeInfo in $scopes)
            {
                $currentScope = $scopeInfo.ScopeId
                Write-M365DSCHost -Message "    |---[$j/$($scopes.Count)] $($scopeInfo.ScopeType): $($scopeInfo.DisplayName)`r`n" -DeferWrite

                # Get role management policy assignments for this scope
                $assignUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$currentScope/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=$apiVersion"
                $assignResponse = Invoke-AzRestMethod -Uri $assignUri -Method GET
                $assignments = (ConvertFrom-Json $assignResponse.Content).value

                if ($null -eq $assignments -or $assignments.Count -eq 0)
                {
                    $j++
                    continue
                }

                # Bulk-fetch all role management policies for this scope in a single API call
                $bulkPolicyUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$currentScope/providers/Microsoft.Authorization/roleManagementPolicies?api-version=$apiVersion"
                $bulkPolicyResponse = Invoke-AzRestMethod -Uri $bulkPolicyUri -Method GET
                $allPolicies = $null
                if ($null -ne $bulkPolicyResponse -and -not [System.String]::IsNullOrEmpty($bulkPolicyResponse.Content))
                {
                    $allPolicies = (ConvertFrom-Json $bulkPolicyResponse.Content).value
                }

                if ($null -eq $allPolicies)
                {
                    Write-Verbose -Message "Could not retrieve role management policies at scope {$currentScope}. Skipping."
                    $j++
                    continue
                }

                # Build a lookup hashtable keyed by policy name for fast matching
                $policyLookup = @{}
                foreach ($pol in $allPolicies)
                {
                    $policyName = $pol.name
                    $policyLookup[$policyName] = $pol
                }

                # Phase 1: Collect valid (filtered) instances for this scope
                $scopeInstances = [System.Collections.Generic.List[hashtable]]::new()
                foreach ($assignment in $assignments)
                {
                    $roleDisplayName = $null
                    if ($null -ne $assignment.properties.policyAssignmentProperties -and
                        $null -ne $assignment.properties.policyAssignmentProperties.roleDefinition)
                    {
                        $roleDisplayName = $assignment.properties.policyAssignmentProperties.roleDefinition.displayName
                    }

                    if ([System.String]::IsNullOrEmpty($roleDisplayName))
                    {
                        $roleDefId = $assignment.properties.roleDefinitionId
                        if (-not [System.String]::IsNullOrEmpty($roleDefId))
                        {
                            $roleDefUri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$roleDefId`?api-version=$apiVersion"
                            $roleDefResponse = Invoke-AzRestMethod -Uri $roleDefUri -Method GET
                            $roleDef = ConvertFrom-Json $roleDefResponse.Content
                            $roleDisplayName = $roleDef.properties.roleName
                        }
                    }

                    if ([System.String]::IsNullOrEmpty($roleDisplayName))
                    {
                        continue
                    }

                    $assignmentPolicyId = $assignment.properties.policyId.Split('/')[-1]

                    # Look up policy from bulk-fetched results instead of individual API call
                    $policyContent = $policyLookup[$assignmentPolicyId]

                    if ($null -eq $policyContent -or $null -eq $policyContent.properties -or $null -eq $policyContent.properties.rules)
                    {
                        Write-Verbose -Message "Policy {$assignmentPolicyId} not found in bulk response for scope {$currentScope}. Skipping."
                        continue
                    }

                    # When the 'ModifiedOnly' sentinel filter is specified, skip policies that have
                    # not been customised from Azure defaults (lastModifiedDateTime is null).
                    # Without this filter, all policies (including default/unchanged) are exported.
                    $lastModifiedDateTime = $policyContent.properties.lastModifiedDateTime
                    if ($this.Filter -eq 'ModifiedOnly' -and $null -eq $lastModifiedDateTime)
                    {
                        Write-Verbose -Message "ModifiedOnly filter active: Policy {$assignmentPolicyId} has not been modified from Azure defaults. Skipping."
                        continue
                    }

                    $scopeInstances.Add(@{
                        RoleDisplayName = $roleDisplayName
                        PolicyId        = $assignmentPolicyId
                        Rules           = $policyContent.properties.rules
                    })
                }

                # Add scope instances to the global exported instances collection
                foreach ($inst in $scopeInstances)
                {
                    $exportedInstances.Add($inst)
                }

                # Phase 2: Export collected instances
                $i = 1
                foreach ($instance in $scopeInstances)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    Write-M365DSCHost -Message "        |---[$i/$($scopeInstances.Count)] $($instance.RoleDisplayName)" -DeferWrite

                    $Params = @{
                        RoleDefinitionDisplayName = $instance.RoleDisplayName
                        ScopeId                   = $currentScope
                        SubscriptionId            = $this.SubscriptionId
                        Credential                = $this.Credential
                        ApplicationId             = $this.ApplicationId
                        TenantId                  = $this.TenantId
                        ApplicationSecret         = $this.ApplicationSecret
                        CertificateThumbprint     = $this.CertificateThumbprint
                        CertificatePath           = $this.CertificatePath
                        CertificatePassword       = $this.CertificatePassword
                        ManagedIdentity           = $this.ManagedIdentity
                        AccessTokens              = $this.AccessTokens
                    }

                    $this.ExportedInstance = @{
                        rules    = $instance.Rules
                        policyId = $instance.PolicyId
                    }
                    $Results = $this.GetForExport($Params)

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SubscriptionId')
        }
    }

    hidden [AzureRoleEligibilityScheduleSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureRoleEligibilityScheduleSettings])
        {
            return $Values
        }

        $result = [AzureRoleEligibilityScheduleSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
