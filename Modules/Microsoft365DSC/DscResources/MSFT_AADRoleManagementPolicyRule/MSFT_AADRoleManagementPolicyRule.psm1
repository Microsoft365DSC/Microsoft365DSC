using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRoleManagementPolicyRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Role display name.')]
    [System.String] $RoleDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Rule Type.')]
    [System.String] $RuleType

    [DscProperty()]
    [System.ComponentModel.Description('Policy Id.')]
    [System.String] $PolicyId

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

    [AADRoleManagementPolicyRule] Get()
    {
        $DisplayName = $null
        $resolvedPolicyId = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADRoleManagementPolicyRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Role Management Policy Rule with Id {$($this.Id)} and Role DisplayName {$($this.RoleDisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()

                if ($null -eq $this.ResourceCache['allDirectoryRoles'])
                {
                    $this.ResourceCache['allDirectoryRoles'] = Get-MgBetaRoleManagementDirectoryRoleDefinition -All
                }

                if ($null -eq $this.ResourceCache['allPolicyAssignments'])
                {
                    $this.ResourceCache['allPolicyAssignments'] = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '/' and scopeType eq 'DirectoryRole'" -All -Property 'roleDefinitionId,policyId'
                }

                $getValue = $null
                $role = $this.ResourceCache['allDirectoryRoles'] | Where-Object { $_.DisplayName -eq $($this.RoleDisplayName -replace "'", "''") }
                if ($null -eq $role)
                {
                    Write-Verbose -Message "Could not find an Azure AD Role Management Definition with DisplayName {$($this.RoleDisplayName)}"
                    return $this.AsResult($nullResult)
                }

                $assignment = $this.ResourceCache['allPolicyAssignments'] | Where-Object { $_.RoleDefinitionId -eq $role.Id }
                if ($null -eq $assignment)
                {
                    Write-Verbose -Message "Could not find an Azure AD Role Management Policy Assignment with RoleDefinitionId {$role.Id}"
                    return $this.AsResult($nullResult)
                }

                $resolvedPolicyId = $assignment.PolicyId
                $getValue = Get-MgBetaPolicyRoleManagementPolicyRule `
                    -UnifiedRoleManagementPolicyId $resolvedPolicyId `
                    -UnifiedRoleManagementPolicyRuleId $this.id -ErrorAction SilentlyContinue

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Role Management Policy Rule with Id {$($this.id)} and PolicyId {$resolvedPolicyId}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $resolvedPolicyId = $this.ResourceCache['ResolvedPolicyId']
            }

            Write-Verbose -Message "An Azure AD Role Management Policy Rule with Id {$($this.id)} and PolicyId {$resolvedPolicyId} was found"

            $complexRule = [ordered]@{
                id       = $getValue.id
                ruleType = $getValue.'@odata.type'
            }

            if ($complexRule.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule')
            {
                $complexExpirationRule = [ordered]@{
                    isExpirationRequired = $getValue.isExpirationRequired
                    maximumDuration      = $getValue.maximumDuration
                }
                $complexRule.Add('ExpirationRule', $complexExpirationRule)
            }

            if ($complexRule.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyNotificationRule')
            {
                $complexNotificationRule = [ordered]@{
                    isDefaultRecipientsEnabled = $getValue.isDefaultRecipientsEnabled
                    notificationLevel          = $getValue.notificationLevel
                    notificationRecipients     = [array]$getValue.notificationRecipients
                    notificationType           = $getValue.notificationType
                    recipientType              = $getValue.recipientType
                }
                $complexRule.Add('NotificationRule', $complexNotificationRule)
            }

            if ($complexRule.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyEnablementRule')
            {
                $complexEnablementRule = @{
                    enabledRules = [array]$getValue.enabledRules
                }
                $complexRule.Add('EnablementRule', $complexEnablementRule)
            }

            if ($complexRule.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyApprovalRule')
            {
                $approvalStages = @()
                foreach ($stage in $getValue.setting.approvalStages)
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
                        escalationApprovers             = [array]$escalationApprovers
                        escalationTimeInMinutes         = $stage.escalationTimeInMinutes
                        isApproverJustificationRequired = $stage.isApproverJustificationRequired
                        isEscalationEnabled             = $stage.isEscalationEnabled
                        primaryApprovers                = [array]$primaryApprovers
                    }

                    $approvalStages += $approvalStage
                }
                $setting = [ordered]@{
                    approvalMode                     = $getValue.setting.approvalMode
                    approvalStages                   = [array]$approvalStages
                    isApprovalRequired               = $getValue.setting.isApprovalRequired
                    isApprovalRequiredForExtension   = $getValue.setting.isApprovalRequiredForExtension
                    isRequestorJustificationRequired = $getValue.setting.isRequestorJustificationRequired
                }
                $complexApprovalRule = @{
                    setting = $setting
                }
                $complexRule.Add('ApprovalRule', $complexApprovalRule)
            }

            if ($complexRule.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyAuthenticationContextRule')
            {
                $complexAuthenticationContextRule = [ordered]@{
                    claimValue = $getValue.claimValue
                    isEnabled  = $getValue.isEnabled
                }
                $complexRule.Add('AuthenticationContextRule', $complexAuthenticationContextRule)
            }

            $results = @{
                Id                        = $this.Id
                PolicyId                  = $resolvedPolicyId
                RoleDisplayName           = $this.RoleDisplayName
                RuleType                  = $complexRule.RuleType
                ExpirationRule            = $complexRule.ExpirationRule
                NotificationRule          = $complexRule.NotificationRule
                EnablementRule            = $complexRule.EnablementRule
                ApprovalRule              = $complexRule.ApprovalRule
                AuthenticationContextRule = $complexRule.AuthenticationContextRule
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        Write-Verbose -Message "Updating the Azure AD Role Management Policy Rule with Id {$($currentInstance.Id)}"
        $body = @{
            '@odata.type' = $this.ruleType
        }

        if ($this.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule')
        {
            $expirationRuleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.ExpirationRule
            # add all the properties to the body
            foreach ($key in $expirationRuleHashmap.Keys)
            {
                $body.Add($key, $expirationRuleHashmap.$key)
            }
        }

        if ($this.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyNotificationRule')
        {
            $notificationRuleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.NotificationRule
            $body += $notificationRuleHashmap
        }

        if ($this.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyEnablementRule')
        {
            $enablementRuleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.EnablementRule
            $body += $enablementRuleHashmap
        }

        if ($this.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyApprovalRule')
        {
            $approvalRuleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.ApprovalRule
            $body += $approvalRuleHashmap
        }

        if ($this.ruleType -eq '#microsoft.graph.unifiedRoleManagementPolicyAuthenticationContextRule')
        {
            $authenticationContextRuleHashmap = Convert-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.AuthenticationContextRule
            $body += $authenticationContextRuleHashmap
        }

        Update-MgBetaPolicyRoleManagementPolicyRule `
            -UnifiedRoleManagementPolicyId $currentInstance.policyId `
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

        $dscContent = [System.Text.StringBuilder]::new()
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        try
        {
            [array] $roles = Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter $this.Filter -All
            [array]$this.ResourceCache['allPolicyAssignments'] = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter "scopeId eq '/' and scopeType eq 'DirectoryRole'" -All -Property 'roleDefinitionId,policyId'

            $assignmentByRole = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
            foreach ($policyAssignment in $this.ResourceCache['allPolicyAssignments'])
            {
                $assignmentByRole[$policyAssignment.RoleDefinitionId] = $policyAssignment
            }
            $rulesByPolicy = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
            $allPolicies = Get-MgBetaPolicyRoleManagementPolicy -Filter "scopeId eq '/' and scopeType eq 'DirectoryRole'" -ExpandProperty 'rules' -Property 'Id,rules' -All
            foreach ($policy in $allPolicies)
            {
                $rulesByPolicy[$policy.Id] = $policy.Rules
            }

            $j = 1
            foreach ($role in $roles)
            {
                $assignment = $null
                $null = $assignmentByRole.TryGetValue($role.Id, [ref] $assignment)
                $exportPolicyId = $assignment.PolicyId
                $this.ResourceCache['ResolvedPolicyId'] = $exportPolicyId
                $rules = $null
                if ($null -ne $exportPolicyId)
                {
                    $null = $rulesByPolicy.TryGetValue($exportPolicyId, [ref] $rules)
                }

                Write-M365DSCHost -Message "    |---[$j/$($roles.Count)] $($role.displayName)"
                $i = 1
                foreach ($rule in $rules)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    Write-M365DSCHost -Message "        |---[$i/$($rules.Count)] $($role.DisplayName)_$($rule.Id)" -DeferWrite
                    $Params = @{
                        RoleDisplayName       = $role.DisplayName
                        Id                    = $rule.Id
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
                    $this.ResourceCache['currentAssignment'] = $assignment
                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()

                    if ($null -ne $Results.ExpirationRule)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'ExpirationRule'
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
                                Name            = 'NotificationRule'
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
                                Name            = 'EnablementRule'
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
                                Name            = 'AuthenticationContextRule'
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
                                Name            = 'ApprovalRule'
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
                            -ComplexObject $Results.ApprovalRule `
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
            ExcludedProperties = @('PolicyId')
        }
    }

    hidden [AADRoleManagementPolicyRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADRoleManagementPolicyRule])
        {
            return $Values
        }

        $result = [AADRoleManagementPolicyRule]::new()
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
