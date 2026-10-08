using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroupEligibilityScheduleSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Group display name.')]
    [System.String] $GroupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Rule Type.')]
    [System.String] $RuleType

    [DscProperty(Key)]
    [System.ComponentModel.Description('PIM Group Role.')]
    [ValidateSet('member', 'owner')]
    [System.String] $PIMGroupRole

    [DscProperty()]
    [System.ComponentModel.Description('Expiration Rule.')]
    [MSFT_AADRoleManagementPolicyExpirationRule] $ExpirationRule

    [DscProperty()]
    [System.ComponentModel.Description('Notification Rule.')]
    [MSFT_AADRoleManagementPolicyNotificationRule] $NotificationRule

    [DscProperty()]
    [System.ComponentModel.Description('Enablement Rule.')]
    [MSFT_AADRoleManagementPolicyEnablementRule] $EnablementRule

    [DscProperty()]
    [System.ComponentModel.Description('Approval Rule.')]
    [MSFT_AADRoleManagementPolicyApprovalRule] $ApprovalRule

    [DscProperty()]
    [System.ComponentModel.Description('Authentication Context Rule.')]
    [MSFT_AADRoleManagementPolicyAuthenticationContextRule] $AuthenticationContextRule

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
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

    [AADGroupEligibilityScheduleSettings] Get()
    {
        $policyId = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroupEligibilityScheduleSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Group Eligibility Schedule Settings with Id {$($this.Id)} and GroupDisplayName {$($this.GroupDisplayName)}"

        try
        {
            if ($null -eq $this.ExportedInstance)
            {

                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()

                #get groupId
                $groupFilter = "DisplayName eq '$($this.GroupDisplayName -replace "'", "''")'"
                [array]$Group = Get-MgGroup -Filter $groupFilter -ErrorAction Stop
                if ($Group.Count -gt 1)
                {
                    throw "Duplicate AzureAD Groups named $($this.GroupDisplayName) exist in tenant"
                }

                $getValue = $null

                $assignment = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '$($group.Id)' and scopeType eq 'Group' and RoleDefinitionId eq '$($this.PIMGroupRole)'"
                if ($null -eq $assignment)
                {
                    Write-Verbose -Message "Could not find an Azure AD PIM Group with DisplayName {$($this.GroupDisplayName)} and Id {$($this.id)}."
                    return $this.AsResult($nullResult)
                }

                $policyId = $assignment.PolicyId

                $getValue = Get-MgBetaPolicyRoleManagementPolicyRule `
                    -UnifiedRoleManagementPolicyId $policyId `
                    -UnifiedRoleManagementPolicyRuleId $this.Id -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Group PIM Policy Rule with Id {$($this.Id)} and PolicyId {$policyId}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $ruleId = $getValue.Id

            Write-Verbose -Message "An Azure AD Role Management Policy Rule with Id {$ruleId} and PolicyId {$policyId} was found"
            $rule = $this.GetRoleManagementPolicyRuleObject($getValue)

            $results = @{
                Id                        = $ruleId
                GroupDisplayName          = $this.groupDisplayName
                RuleType                  = $rule.ruleType
                PIMGroupRole              = $this.PIMGroupRole
                ExpirationRule            = $rule.expirationRule
                NotificationRule          = $rule.notificationRule
                EnablementRule            = $rule.enablementRule
                ApprovalRule              = $rule.approvalRule
                AuthenticationContextRule = $rule.authenticationContextRule
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $this.TenantId
                ApplicationSecret         = $this.ApplicationSecret
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
            }

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $ruleHashmap = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the AAD Group Eligibility Schedule Settings with Id {$($this.Id)} and GroupDisplayName {$($this.GroupDisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        Write-Verbose -Message "Updating the Azure AD PIM Group Management Policy Rule with Id {$($currentInstance.Id)}"
        $body = @{
            '@odata.type' = $this.ruleType
        }

        switch ($this.ruleType)
        {
            '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule'
            {
                $ruleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.expirationRule
            }
            '#microsoft.graph.unifiedRoleManagementPolicyNotificationRule'
            {
                $ruleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.notificationRule
            }
            '#microsoft.graph.unifiedRoleManagementPolicyEnablementRule'
            {
                $ruleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.enablementRule
            }
            '#microsoft.graph.unifiedRoleManagementPolicyApprovalRule'
            {
                $ruleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.approvalRule
            }
            '#microsoft.graph.unifiedRoleManagementPolicyAuthenticationContextRule'
            {
                $ruleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.authenticationContextRule
            }
        }

        foreach ($key in $ruleHashmap.Keys)
        {
            $body.Add($key, $ruleHashmap.$key)
        }

        $groupFilter = "DisplayName eq '$($this.GroupDisplayName -replace "'", "''")'"
        [array]$Group = Get-MgGroup -Filter $groupFilter -ErrorAction Stop
        if ($Group.Count -gt 1)
        {
            throw "Duplicate AzureAD Groups named $($this.GroupDisplayName) exist in tenant"
        }

        $assignment = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '$($group.Id)' and scopeType eq 'Group' and RoleDefinitionId eq '$($this.PIMGroupRole)'"
        if ($null -eq $assignment)
        {
            Write-Verbose -Message "Could not find an Azure AD PIM Group with DisplayName {$($this.GroupDisplayName)} and Id {$($this.id)}."
            return
        }

        $policyId = $assignment.PolicyId

        Update-MgBetaPolicyRoleManagementPolicyRule `
            -UnifiedRoleManagementPolicyId $policyId `
            -UnifiedRoleManagementPolicyRuleId $currentInstance.Id `
            -BodyParameter $body
        #endregion
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

        try
        {
            $this.ResourceCache['ExportMode'] = $true
            [array]$groups = Get-M365DSCExportCachedCollection -Collection 'pimGroups'

            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            $j = 1
            $pimGroupRoles = @('member', 'owner')

            $batchRequests = @()
            foreach ($group in $groups)
            {
                $batchRequests += @{
                    id     = $group.Id
                    method = 'GET'
                    url    = "/policies/roleManagementPolicyAssignments?filter=scopeId eq '$($group.Id)' and scopeType eq 'Group'&`$expand=policy(`$expand=rules)"
                }
            }

            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests

            foreach ($group in $groups)
            {
                foreach ($PIMRole in $pimGroupRoles)
                {
                    $assignment = ($batchResponses | Where-Object { $_.id -eq $group.Id }).body.value `
                    | Where-Object { $_.roleDefinitionId -eq $PIMRole }
                    $rules = $assignment.policy.rules

                    Write-M365DSCHost -Message "    |---[$j/$($groups.Count * 2)] $($group.displayName) ($PIMRole)`r`n" -DeferWrite
                    $i = 1
                    foreach ($rule in $rules)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }
                        Write-M365DSCHost -Message "        |---[$i/$($rules.Count)] $($group.DisplayName)_$($rule.Id)" -DeferWrite
                        $Params = @{
                            GroupDisplayName      = $group.DisplayName
                            Id                    = $rule.Id
                            PIMGroupRole          = $PIMRole
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

                        $this.ExportedInstance = $rule
                        $Results = $this.GetForExport($Params)
                        $rawResults = $Results.Clone()

                        if ($null -ne $Results.ExpirationRule)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'expirationRule'
                                    CimInstanceName = 'AADRoleManagementPolicyExpirationRule'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.ExpirationRule`
                                -CIMInstanceName 'AADRoleManagementPolicyExpirationRule' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.ExpirationRule = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('ExpirationRule') | Out-Null
                            }
                        }

                        if ($null -ne $Results.NotificationRule)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'notificationRule'
                                    CimInstanceName = 'AADRoleManagementPolicyNotificationRule'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.NotificationRule`
                                -CIMInstanceName 'AADRoleManagementPolicyNotificationRule' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.NotificationRule = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('NotificationRule') | Out-Null
                            }
                        }

                        if ($null -ne $Results.EnablementRule)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'enablementRule'
                                    CimInstanceName = 'AADRoleManagementPolicyEnablementRule'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.EnablementRule`
                                -CIMInstanceName 'AADRoleManagementPolicyEnablementRule' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.EnablementRule = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('EnablementRule') | Out-Null
                            }
                        }

                        if ($null -ne $Results.AuthenticationContextRule)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'authenticationContextRule'
                                    CimInstanceName = 'AADRoleManagementPolicyAuthenticationContextRule'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.AuthenticationContextRule`
                                -CIMInstanceName 'AADRoleManagementPolicyAuthenticationContextRule' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.AuthenticationContextRule = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('AuthenticationContextRule') | Out-Null
                            }
                        }

                        if ($null -ne $Results.ApprovalRule)
                        {
                            $complexMapping = @(
                                @{
                                    Name            = 'approvalRule'
                                    CimInstanceName = 'AADRoleManagementPolicyApprovalRule'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'setting'
                                    CimInstanceName = 'AADRoleManagementPolicyApprovalSettings'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'approvalStages'
                                    CimInstanceName = 'AADRoleManagementPolicyApprovalStage'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'escalationApprovers'
                                    CimInstanceName = 'AADRoleManagementPolicySubjectSet'
                                    IsRequired      = $False
                                }
                                @{
                                    Name            = 'primaryApprovers'
                                    CimInstanceName = 'AADRoleManagementPolicySubjectSet'
                                    IsRequired      = $False
                                }
                            )
                            $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                -ComplexObject $Results.ApprovalRule`
                                -CIMInstanceName 'AADRoleManagementPolicyApprovalRule' `
                                -ComplexTypeMapping $complexMapping

                            if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                            {
                                $Results.ApprovalRule = $complexTypeStringResult
                            }
                            else
                            {
                                $Results.Remove('ApprovalRule') | Out-Null
                            }
                        }

                        $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                            -ConnectionMode $ConnectionMode `
                            -ModulePath $this.GetModulePath() `
                            -Results $Results `
                            -Credential $this.Credential `
                            -NoEscape @('ExpirationRule', 'NotificationRule', 'EnablementRule', 'ApprovalRule', 'AuthenticationContextRule') `
                            -RawResults $rawResults

                        [void]$dscContent.Append($currentDSCBlock)
                        Save-M365DSCPartialExport -Content $currentDSCBlock `
                            -FileName $Global:PartialExportFileName
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        $i++
                    }
                    $j++
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Object] GetRoleManagementPolicyRuleObject([System.Object] $Rule)
    {
        if ($null -eq $Rule)
        {
            return $null
        }

        $values = [ordered]@{
            id       = $Rule.id
            ruleType = $Rule.'@odata.type'
        }

        if ($values.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule')
        {
            $expirationRuleValue = [ordered]@{
                isExpirationRequired = $Rule.isExpirationRequired
                maximumDuration      = $Rule.maximumDuration
            }

            $values.Add('expirationRule', $expirationRuleValue)
        }

        if ($values.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyNotificationRule')
        {
            $notificationRuleValue = [ordered]@{
                notificationType           = $Rule.notificationType
                recipientType              = $Rule.recipientType
                notificationLevel          = $Rule.notificationLevel
                isDefaultRecipientsEnabled = $Rule.isDefaultRecipientsEnabled
                notificationRecipients     = [array]$Rule.notificationRecipients
            }
            $values.Add('notificationRule', $notificationRuleValue)
        }

        if ($values.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyEnablementRule')
        {
            $enablementRuleValue = @{
                enabledRules = [array]$Rule.enabledRules
            }
            $values.Add('enablementRule', $enablementRuleValue)
        }

        if ($values.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyApprovalRule')
        {
            $approvalStages = @()
            foreach ($stage in $Rule.setting.approvalStages)
            {
                $primaryApprovers = @()
                foreach ($approver in $stage.primaryApprovers)
                {
                    $primaryApprover = @{
                        odataType = $approver.'@odata.type'
                    }
                    $primaryApprovers += $primaryApprover
                }

                $escalationApprovers = @()
                foreach ($approver in $stage.escalationApprovers)
                {
                    $escalationApprover = @{
                        odataType = $approver.'@odata.type'
                    }
                    $escalationApprovers += $escalationApprover
                }

                $approvalStage = [ordered]@{
                    approvalStageTimeOutInDays      = $stage.approvalStageTimeOutInDays
                    escalationTimeInMinutes         = $stage.escalationTimeInMinutes
                    isApproverJustificationRequired = $stage.isApproverJustificationRequired
                    isEscalationEnabled             = $stage.isEscalationEnabled
                    escalationApprovers             = [array]$escalationApprovers
                    primaryApprovers                = [array]$primaryApprovers
                }

                $approvalStages += $approvalStage
            }

            $setting = [ordered]@{
                approvalMode                     = $Rule.setting.approvalMode
                isApprovalRequired               = $Rule.setting.isApprovalRequired
                isApprovalRequiredForExtension   = $Rule.setting.isApprovalRequiredForExtension
                isRequestorJustificationRequired = $Rule.setting.isRequestorJustificationRequired
                approvalStages                   = [array]$approvalStages
            }
            $approvalRuleValue = @{
                setting = $setting
            }
            $values.Add('ApprovalRule', $approvalRuleValue)
        }

        if ($values.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyAuthenticationContextRule')
        {
            $authenticationContextRuleValue = [ordered]@{
                isEnabled  = $Rule.isEnabled
                claimValue = $Rule.claimValue
            }
            $values.Add('authenticationContextRule', $authenticationContextRuleValue)
        }

        return $values
    }

    hidden [AADGroupEligibilityScheduleSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroupEligibilityScheduleSettings])
        {
            return $Values
        }

        $result = [AADGroupEligibilityScheduleSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADRoleManagementPolicyExpirationRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies if expiration is required.')]
    [System.Nullable[System.Boolean]] $isExpirationRequired

    [DscProperty()]
    [System.ComponentModel.Description('The maximum duration for the expiration.')]
    [System.String] $maximumDuration
}

class MSFT_AADRoleManagementPolicyNotificationRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Notification type for the rule.')]
    [System.String] $notificationType

    [DscProperty()]
    [System.ComponentModel.Description('Type of the recipient for the notification.')]
    [System.String] $recipientType

    [DscProperty()]
    [System.ComponentModel.Description('Level of the notification.')]
    [System.String] $notificationLevel

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if default recipients are enabled.')]
    [System.Nullable[System.Boolean]] $isDefaultRecipientsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('List of notification recipients.')]
    [System.String[]] $notificationRecipients
}

class MSFT_AADRoleManagementPolicyEnablementRule
{
    [DscProperty()]
    [System.ComponentModel.Description('List of enabled rules.')]
    [System.String[]] $enabledRules
}

class MSFT_AADRoleManagementPolicyApprovalRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Settings for approval requirements.')]
    [MSFT_AADRoleManagementPolicyApprovalSettings] $setting
}

class MSFT_AADRoleManagementPolicyAuthenticationContextRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the authentication context rule is enabled.')]
    [System.Nullable[System.Boolean]] $isEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Claim value associated with the rule.')]
    [System.String] $claimValue
}

class MSFT_AADRoleManagementPolicyApprovalSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('One of SingleStage, Serial, Parallel, NoApproval (default). NoApproval is used when isApprovalRequired is false.')]
    [System.String] $approvalMode

    [DscProperty()]
    [System.ComponentModel.Description('If approval is required, the one or two elements of this collection define each of the stages of approval. An empty array if no approval is required.')]
    [MSFT_AADRoleManagementPolicyApprovalStage[]] $approvalStages

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether approval is required for requests in this policy.')]
    [System.Nullable[System.Boolean]] $isApprovalRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether approval is required for a user to extend their assignment.')]
    [System.Nullable[System.Boolean]] $isApprovalRequiredForExtension

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the requestor is required to supply a justification in their request.')]
    [System.Nullable[System.Boolean]] $isRequestorJustificationRequired
}

class MSFT_AADRoleManagementPolicyApprovalStage
{
    [DscProperty()]
    [System.ComponentModel.Description('The number of days that a request can be pending a response before it is automatically denied.')]
    [System.Nullable[System.UInt32]] $approvalStageTimeOutInDays

    [DscProperty()]
    [System.ComponentModel.Description('The time a request can be pending a response from a primary approver before it can be escalated to the escalation approvers.')]
    [System.Nullable[System.UInt32]] $escalationTimeInMinutes

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the approver must provide justification for their reponse.')]
    [System.Nullable[System.Boolean]] $isApproverJustificationRequired

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether escalation if enabled.')]
    [System.Nullable[System.Boolean]] $isEscalationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The escalation approvers for this stage when the primary approvers don''t respond.')]
    [MSFT_AADRoleManagementPolicySubjectSet[]] $escalationApprovers

    [DscProperty()]
    [System.ComponentModel.Description('The primary approvers of this stage.')]
    [MSFT_AADRoleManagementPolicySubjectSet[]] $primaryApprovers
}

class MSFT_AADRoleManagementPolicySubjectSet
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the subject set.')]
    [System.String] $odataType
}
