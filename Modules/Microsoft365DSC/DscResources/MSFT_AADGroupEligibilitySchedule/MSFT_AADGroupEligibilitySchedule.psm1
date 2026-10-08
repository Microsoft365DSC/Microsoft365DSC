using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGroupEligibilitySchedule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Displayname if the Principal is group, otherwise UserPrincipalName for user.')]
    [System.String] $Principal

    [DscProperty(Key)]
    [System.ComponentModel.Description('The identifier of the membership or ownership eligibility to the group that is governed by PIM. Required. The possible values are: owner, member. Supports $filter (eq).')]
    [ValidateSet('owner', 'member', 'unknownFutureValue')]
    [System.String] $AccessId

    [DscProperty(Key)]
    [System.ComponentModel.Description('Displayname of the group representing the scope of the membership or ownership eligibility through PIM for groups.')]
    [System.String] $GroupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The identifier of the group representing the scope of the membership or ownership eligibility through PIM for groups. Required. Supports $filter (eq).')]
    [System.String] $GroupId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the assignment is derived from a group assignment. It can further imply whether the caller can manage the schedule. Required. The possible values are: direct, group, unknownFutureValue. Supports $filter (eq).')]
    [ValidateSet('direct', 'group', 'unknownFutureValue')]
    [System.String] $MemberType

    [DscProperty()]
    [System.ComponentModel.Description('Principal type user or group')]
    [ValidateSet('user', 'group')]
    [System.String] $PrincipalType

    [DscProperty()]
    [System.ComponentModel.Description('Represents the period of the access assignment or eligibility. The scheduleInfo can represent a single occurrence or multiple recurring instances. Required.')]
    [MSFT_MicrosoftGraphrequestSchedule] $ScheduleInfo

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [AADGroupEligibilitySchedule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGroupEligibilitySchedule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Azure AD Group {$($this.GroupDisplayName)} Eligibility Schedule"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                $currentGroupId = $this.GroupId
                if ([System.String]::IsNullOrEmpty($this.GroupId))
                {
                    $groupFilter = "DisplayName eq '$($this.GroupDisplayName -replace "'", "''")'"
                    $this.ResourceCache['CurrentGroup'] = Get-MgGroup -Filter $groupFilter

                    if ([string]::IsNullOrEmpty($this.ResourceCache['CurrentGroup']))
                    {
                        Write-Verbose -Message "Could not find an valid Azure AD Group with name $($this.GroupDisplayName) "
                        return $this.AsResult($nullResult)
                    }

                    $currentGroupId = $this.ResourceCache['CurrentGroup'].Id
                }

                $getValue = Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule `
                        -PrivilegedAccessGroupEligibilityScheduleId $this.Id `
                        -ErrorAction SilentlyContinue
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Group Eligibility Schedule with Id {$($this.Id)}. Attempting to find an Azure AD Group Eligibility Schedule for group {$($this.GroupDisplayName)} and principal {$($this.Principal)}."
                    $schedules = Get-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilitySchedule `
                        -All `
                        -Filter "GroupId eq '$($currentGroupId)'" `
                        -ErrorAction SilentlyContinue

                    $PrincipalInstance = $this.GetPrincipalInstance()
                    $getValue = $($schedules | Where-Object { $_.accessid -eq $this.AccessId -and $_.principalId -eq $PrincipalInstance.id })
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Group Eligibility Schedule with {$($this.GroupDisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            Write-Verbose -Message "An Azure AD Group Eligibility Schedule with Id {$($getValue.Id)} and DisplayName {$($this.GroupDisplayName)} was found"

            #region resource generator code
            $complexScheduleInfo = [ordered]@{}
            $complexExpiration = [ordered]@{}
            $complexExpiration.Add('Duration', $getValue.scheduleInfo.expiration.duration)
            if ($null -ne $getValue.scheduleInfo.expiration.endDateTime)
            {
                $complexExpiration.Add('EndDateTime', [M365DSCResourceBase]::FormatDateTime($getValue.scheduleInfo.expiration.endDateTime))
            }
            if ($null -ne $getValue.scheduleInfo.expiration.type)
            {
                $complexExpiration.Add('Type', $getValue.scheduleInfo.expiration.type)
            }
            if ($complexExpiration.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexExpiration = $null
            }
            $complexScheduleInfo.Add('Expiration', $complexExpiration)
            $complexRecurrence = [ordered]@{}
            $complexPattern = [ordered]@{}
            $complexPattern.Add('DayOfMonth', $getValue.scheduleInfo.recurrence.pattern.dayOfMonth)
            if ($null -ne $getValue.scheduleInfo.recurrence.pattern.daysOfWeek)
            {
                $complexPattern.Add('DaysOfWeek', $getValue.scheduleInfo.recurrence.pattern.daysOfWeek)
            }
            if ($null -ne $getValue.scheduleInfo.recurrence.pattern.firstDayOfWeek)
            {
                $complexPattern.Add('FirstDayOfWeek', $getValue.scheduleInfo.recurrence.pattern.firstDayOfWeek)
            }
            if ($null -ne $getValue.scheduleInfo.recurrence.pattern.index)
            {
                $complexPattern.Add('Index', $getValue.scheduleInfo.recurrence.pattern.index)
            }
            $complexPattern.Add('Interval', $getValue.scheduleInfo.recurrence.pattern.interval)
            $complexPattern.Add('Month', $getValue.scheduleInfo.recurrence.pattern.month)
            if ($null -ne $getValue.scheduleInfo.recurrence.pattern.type)
            {
                $complexPattern.Add('Type', $getValue.scheduleInfo.recurrence.pattern.type)
            }
            if ($complexPattern.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexPattern = $null
            }
            $complexRecurrence.Add('Pattern', $complexPattern)
            $complexRange = [ordered]@{}
            if ($null -ne $getValue.scheduleInfo.recurrence.range.endDate)
            {
                $complexRange.Add('EndDate', ([DateTime]$getValue.scheduleInfo.recurrence.range.endDate).ToString(''))
            }
            $complexRange.Add('NumberOfOccurrences', $getValue.scheduleInfo.recurrence.range.numberOfOccurrences)
            $complexRange.Add('RecurrenceTimeZone', $getValue.scheduleInfo.recurrence.range.recurrenceTimeZone)
            if ($null -ne $getValue.scheduleInfo.recurrence.range.startDate)
            {
                $complexRange.Add('StartDate', ([DateTime]$getValue.scheduleInfo.recurrence.range.startDate).ToString(''))
            }
            if ($null -ne $getValue.scheduleInfo.recurrence.range.type)
            {
                $complexRange.Add('Type', $getValue.scheduleInfo.recurrence.range.type)
            }
            if ($complexRange.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRange = $null
            }
            $complexRecurrence.Add('Range', $complexRange)
            if ($complexRecurrence.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRecurrence = $null
            }
            $complexScheduleInfo.Add('Recurrence', $complexRecurrence)
            if ($null -ne $getValue.ScheduleInfo.startDateTime)
            {
                $complexScheduleInfo.Add('StartDateTime', [M365DSCResourceBase]::FormatDateTime($getValue.ScheduleInfo.startDateTime))
            }
            if ($complexScheduleInfo.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexScheduleInfo = $null
            }
            #endregion

            $PrincipalValue = $null
            $objectInfo = Get-MgBetaDirectoryObjectById -Ids $getvalue.PrincipalId -ErrorAction SilentlyContinue

            if (-not $getValue.ContainsKey('PrincipalType'))
            {
                $getValue.Add('PrincipalType', $objectInfo['@odata.type'].Split('.')[2])
            }
            else
            {
                $getValue.PrincipalType = $objectInfo['@odata.type'].Split('.')[2]
            }

            switch ($getValue.PrincipalType)
            {
           	    'user'
                {
                    $PrincipalValue = $objectInfo['userPrincipalName']
                }
           	    default
                {
                    $PrincipalValue = $objectInfo['displayName']
                }
            }

            Write-Verbose "PrincipalValue = $PrincipalValue"
            $results = @{
                #region resource generator code
                AccessId              = $getValue.accessId
                GroupDisplayName      = $this.ResourceCache['CurrentGroup'].DisplayName
                MemberType            = $getValue.memberType
                PrincipalType         = $getValue.PrincipalType
                Principal             = $PrincipalValue
                ScheduleInfo          = $complexScheduleInfo
                Id                    = $getValue.Id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
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
        $PrincipalId = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Azure AD Group Eligibility Schedule for group {$($this.GroupId)} and DisplayName {$($this.GroupDisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Group Eligibility Schedule for Group {$($this.GroupDisplayName)}"

            $createParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('PrincipalType') | Out-Null
            $createParameters.Remove('Principal') | Out-Null
            $createParameters.Remove('GroupDisplayName') | Out-Null
            $createParameters.Add('Action', 'adminAssign')

            $GroupFilter = "DisplayName eq '" + $this.GroupDisplayName + "'"
            $groupIdValue = (Get-MgGroup -Filter $GroupFilter).Id
            $createParameters.GroupId = $groupIdValue
            if ([string]::IsNullOrEmpty($groupIdValue))
            {
                throw "Failed to lookup group $($this.GroupDisplayName)"
            }
            if ($this.ScheduleInfo.Expiration.Type -eq 'noExpiration')
            {
                $p = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter $("scopeId eq '{0}' and scopeType eq 'Group' and RoleDefinitionId eq '{1}'" -f $groupIdValue, $this.accessid)
                $unifiedRoleManagementPolicyId = $p.PolicyId
                $unifiedRoleManagementPolicyRuleId = 'Expiration_Admin_Eligibility'
                $isExpirationRequired = (Get-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId).isExpirationRequired
                if ($isExpirationRequired)
                {
                    $params = @{
                        '@odata.type'        = '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule'
                        id                   = 'Expiration_Admin_Eligibility'
                        isExpirationRequired = $false
                        target               = @{
                            caller              = 'Admin'
                            operations          = @('All')
                            level               = 'Eligibility'
                            inheritableSettings = @()
                            enforcedSettings    = @()
                        }
                    }
                    Update-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId -BodyParameter $params
                }
            }
            elseif ($this.ScheduleInfo.Expiration.Type -match '^after')
            {
                $p = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter $("scopeId eq '{0}' and scopeType eq 'Group' and RoleDefinitionId eq '{1}'" -f $groupIdValue, $this.accessid)
                $unifiedRoleManagementPolicyId = $p.PolicyId
                $unifiedRoleManagementPolicyRuleId = 'Expiration_Admin_Eligibility'
                $isExpirationRequired = (Get-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId).isExpirationRequired
                if (-not $isExpirationRequired)
                {
                    $params = @{
                        '@odata.type'        = '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule'
                        id                   = 'Expiration_Admin_Eligibility'
                        isExpirationRequired = $true
                        maximumDuration      = 'P365D'
                        target               = @{
                            caller              = 'Admin'
                            operations          = @('All')
                            level               = 'Eligibility'
                            inheritableSettings = @()
                            enforcedSettings    = @()
                        }
                    }
                    Update-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId -BodyParameter $params
                }
            }

            $PrincipalId = $this.GetPrincipalInstance().Id
            $createParameters.Add('PrincipalId', $PrincipalId)

            #region resource generator code
            Write-Verbose -Message "Creating the Azure AD Group Eligibility Schedule with parameters:`r`n$(ConvertTo-Json $createParameters -Depth 10)"
            New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Group Eligibility Schedule with Id {$($currentInstance.Id)}"

            $scheduledStart = $currentInstance.ScheduleInfo.StartDateTime
            $scheduledEnd = $currentInstance.ScheduleInfo.Expiration.EndDateTime
            if ($scheduledStart -ne $this.ScheduleInfo.StartDateTime -or $scheduledEnd -ne $this.ScheduleInfo.Expiration.EndDateTime)
            {
                $Action = 'adminExtend'
            }
            else
            {
                $Action = 'adminUpdate'
            }
            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('PrincipalType') | Out-Null
            $updateParameters.Remove('Principal') | Out-Null
            $updateParameters.Remove('GroupDisplayName') | Out-Null
            $updateParameters.Add('Action', $Action)

            $GroupFilter = "DisplayName eq '" + $this.GroupDisplayName + "'"
            $groupIdValue = (Get-MgGroup -Filter $GroupFilter).Id
            if ($this.ScheduleInfo.Expiration.Type -eq 'noExpiration')
            {
                $p = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter $("scopeId eq '{0}' and scopeType eq 'Group' and RoleDefinitionId eq '{1}'" -f $groupIdValue, $this.accessid)
                $unifiedRoleManagementPolicyId = $p.PolicyId
                $unifiedRoleManagementPolicyRuleId = 'Expiration_Admin_Eligibility'
                $isExpirationRequired = (Get-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId).isExpirationRequired
                if ($isExpirationRequired)
                {
                    $params = @{
                        '@odata.type'        = '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule'
                        id                   = 'Expiration_Admin_Eligibility'
                        isExpirationRequired = $false
                        target               = @{
                            caller              = 'Admin'
                            operations          = @(
                                'All'
                            )
                            level               = 'Eligibility'
                            inheritableSettings = @(
                            )
                            enforcedSettings    = @(
                            )
                        }
                    }
                    Write-Verbose -Message "Updating the expiration policy for the group {$($this.GroupDisplayName)} with:`r`n$(ConvertTo-Json $params -Depth 10)"
                    Update-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId -BodyParameter $params
                }
            }
            elseif ($this.ScheduleInfo.Expiration.Type -match '^after')
            {
                $p = Get-MgBetaPolicyRoleManagementPolicyAssignment -Filter $("scopeId eq '{0}' and scopeType eq 'Group' and RoleDefinitionId eq '{1}'" -f $groupIdValue, $this.accessid)
                $unifiedRoleManagementPolicyId = $p.PolicyId
                $unifiedRoleManagementPolicyRuleId = 'Expiration_Admin_Eligibility'
                $isExpirationRequired = (Get-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId).isExpirationRequired
                if (-not $isExpirationRequired)
                {
                    $params = @{
                        '@odata.type'        = '#microsoft.graph.unifiedRoleManagementPolicyExpirationRule'
                        id                   = 'Expiration_Admin_Eligibility'
                        isExpirationRequired = $true
                        maximumDuration      = 'P365D'
                        target               = @{
                            caller              = 'Admin'
                            operations          = @(
                                'All'
                            )
                            level               = 'Eligibility'
                            inheritableSettings = @(
                            )
                            enforcedSettings    = @(
                            )
                        }
                    }
                    Write-Verbose -Message "Updating the expiration policy for the group {$($this.GroupDisplayName)}"
                    Update-MgBetaPolicyRoleManagementPolicyRule -UnifiedRoleManagementPolicyId $unifiedRoleManagementPolicyId -UnifiedRoleManagementPolicyRuleId $unifiedRoleManagementPolicyRuleId -BodyParameter $params
                }
            }
            $updateParameters.groupId = $groupIdValue
            $PrincipalId = $this.GetPrincipalInstance().Id

            $updateParameters.Add('PrincipalId', $PrincipalId)

            #region resource generator code
            New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Group Eligibility Schedule with Id {$($currentInstance.Id)}"

            $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('PrincipalType') | Out-Null
            $updateParameters.Remove('Principal') | Out-Null
            $updateParameters.Remove('GroupDisplayName') | Out-Null
            $updateParameters.Add('Action', 'adminRemove')

            $GroupFilter = "DisplayName eq '" + $this.GroupDisplayName + "'"
            $groupIdValue = (Get-MgGroup -Filter $GroupFilter).Id
            $updateParameters.groupId = $groupIdValue
            $PrincipalId = $this.GetPrincipalInstance().Id
            $updateParameters.Add('PrincipalId', $PrincipalId)

            #region resource generator code
            New-MgBetaIdentityGovernancePrivilegedAccessGroupEligibilityScheduleRequest -BodyParameter $updateParameters
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $group = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        # Filter out dynamic groups
        $mergedFilter = $this.Filter
        if ($this.Filter -notlike '*DynamicMembership*')
        {
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "$($this.Filter) and"
            }
            $mergedFilter = "$mergedFilter NOT(groupTypes/any(x:x eq 'DynamicMembership')) and not(mailEnabled eq true and securityEnabled eq true)"
        }

        $ExportParameters = @{
            Filter           = $mergedFilter
            All              = [switch]$true
            Property         = 'displayname,Id'
            CountVariable    = 'CountVar'
            ConsistencyLevel = 'eventual'
            ErrorAction      = 'Stop'
        }

        try
        {
            $pimGroupIds = [System.Collections.Generic.HashSet[System.String]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($pimGroup in (Get-M365DSCExportCachedCollection -Collection 'pimGroups'))
            {
                $null = $pimGroupIds.Add($pimGroup.Id)
            }

            Write-Verbose 'Calling Get-MgGroup with Export Parameters'
            [array] $this.ResourceCache['exportedGroups'] = Get-MgGroup @ExportParameters
            Write-Verbose "Got $($this.ResourceCache['exportedGroups'].Length) total unfiltered groups"
            Write-Verbose 'Filtering all groups to PIM enabled'
            $this.ResourceCache['exportedGroups'] = $this.ResourceCache['exportedGroups'] | Where-Object -FilterScript {
                $pimGroupIds.Contains($_.Id) -and `
                    -not ($_.MailEnabled -and ($null -eq $_.GroupTypes -or $_.GroupTypes.Length -eq 0))
            }
            Write-Verbose "Got $($this.ResourceCache['exportedGroups'].Length) PIM enabled groups"

            $j = 1
            if ($this.ResourceCache['exportedGroups'].Length -eq 0)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                Write-M365DSCHost -Message "    |---[$j/$($this.ResourceCache['exportedGroups'].Count)] $($group.DisplayName)" -DeferWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $dscContent = [System.Text.StringBuilder]::new()
            $batchRequests = @()

            foreach ($group in $this.ResourceCache['exportedGroups'])
            {
                $batchRequests += @{
                    id     = $group.Id
                    method = 'GET'
                    url    = "/identityGovernance/privilegedAccess/group/eligibilitySchedules?`$filter=groupId eq '$($group.Id)'"
                }
            }

            Write-Verbose 'Invoking Batch request'
            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests

            foreach ($group in $this.ResourceCache['exportedGroups'])
            {
                Write-Verbose "Processing Group $($group.DisplayName), Id $($group.id)"
                Write-M365DSCHost -Message "    |---[$j/$($this.ResourceCache['exportedGroups'].Length)] $($group.DisplayName)" -DeferWrite
                #region resource generator code
                $getValue = ($batchResponses | Where-Object { $_.id -eq $group.Id }).body.value
                Write-Verbose "GetValue set for schedule Id $($getValue.Id)"

                $this.ResourceCache['CurrentGroup'] = $group

                $i = 1

                if ($getValue.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                Write-Verbose "Got $($getValue.count) schedules on group $($group.DisplayName)"
                foreach ($config in $getValue)
                {
                    Write-Verbose "AccessId = $($config.accessId)"
                    Write-Verbose "Id = $($config.Id)"
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    Write-M365DSCHost -Message "        |---[$i/$($getValue.Count)] $($config.Id)" -DeferWrite

                    # Find the Principal Type
                    Write-Verbose "Looking up ObjectId $($config.PrincipalId)"
                    $PrincipalInfo = Get-MgBetaDirectoryObjectById -Ids $config.PrincipalId -ErrorAction SilentlyContinue
                    $principalTypeValue = $PrincipalInfo['@odata.type'].Split('.')[2]

                    Write-Verbose "Got PrincipalType $principalTypeValue back for ObjectID"
                    $PrincipalValue = if ($principalTypeValue -eq 'user' )
                    {
                        $PrincipalInfo['userPrincipalName']
                    }
                    else
                    {
                        $PrincipalInfo['displayName']
                    }
                    Write-Verbose "PrincipalValue for object is $PrincipalValue"

                    $params = @{
                        Id                    = $config.Id
                        GroupId               = $group.Id
                        GroupDisplayName      = $group.DisplayName
                        AccessId              = $config.accessId
                        Principal             = $PrincipalValue
                        Ensure                = 'Present'
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

                    if ($null -ne $Results.ScheduleInfo)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'ScheduleInfo'
                                CimInstanceName = 'MicrosoftGraphRequestSchedule'
                                IsRequired      = $True
                            }
                            @{
                                Name            = 'Expiration'
                                CimInstanceName = 'MicrosoftGraphExpirationPattern'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'Recurrence'
                                CimInstanceName = 'MicrosoftGraphPrivilegedAccessPatternedRecurrence'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'Pattern'
                                CimInstanceName = 'MicrosoftGraphPrivilegedAccessRecurrencePattern'
                                IsRequired      = $False
                            }
                            @{
                                Name            = 'Range'
                                CimInstanceName = 'MicrosoftGraphRecurrenceRange'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.ScheduleInfo `
                            -CIMInstanceName 'MicrosoftGraphrequestSchedule' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.ScheduleInfo = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('ScheduleInfo') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('ScheduleInfo') `
                        -RawResults $rawResults

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if (-not [System.String]::IsNullOrEmpty($DesiredValues.ScheduleInfo.StartDateTime))
                {
                    $parsedDesiredDate = [System.DateTime]::MinValue
                    $parseResultDesired = [System.DateTime]::TryParse($DesiredValues.ScheduleInfo.StartDateTime, [ref]$parsedDesiredDate)

                    $parsedCurrentDate = [System.DateTime]::MinValue
                    $parseResultCurrent = [System.DateTime]::TryParse($CurrentValues.ScheduleInfo.StartDateTime, [ref]$parsedCurrentDate)

                    if ($parseResultDesired -and $parseResultCurrent)
                    {
                        Write-Verbose -Message "Parsed Desired StartDateTime: $parsedDesiredDate, Parsed Current StartDateTime: $parsedCurrentDate"
                        if ($parsedDesiredDate -ne $parsedCurrentDate -and $parsedDesiredDate -lt [System.DateTime]::Now)
                        {
                            Write-Verbose -Message "Ignoring StartDateTime in ScheduleInfo as it is in the past. StartDateTime cannot be set to a past date."
                            Write-Verbose -Message "Aligning the Desired and Current StartDateTime values for comparison."
                            $DesiredValues.ScheduleInfo.StartDateTime = $CurrentValues.ScheduleInfo.StartDateTime
                        }
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.Object] GetPrincipalInstance()
    {
        if ($this.PrincipalType -ne 'group')
        {
            $user = Get-MgUser -Filter "UserPrincipalName eq '$($this.Principal)'" -ErrorAction SilentlyContinue
            if ($null -ne $user -or $this.PrincipalType -eq 'user')
            {
                return $user
            }
        }

        return Get-MgGroup -Filter "DisplayName eq '$($this.Principal -replace "'", "''")'" -ErrorAction SilentlyContinue
    }

    hidden [AADGroupEligibilitySchedule] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADGroupEligibilitySchedule])
        {
            return $Values
        }

        $result = [AADGroupEligibilitySchedule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphrequestSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('When the eligible or active assignment expires.')]
    [MSFT_MicrosoftGraphExpirationPattern] $Expiration

    [DscProperty()]
    [System.ComponentModel.Description('The frequency of the  eligible or active assignment. This property is currently unsupported in PIM.')]
    [MSFT_MicrosoftGraphPrivilegedAccessPatternedRecurrence] $Recurrence

    [DscProperty()]
    [System.ComponentModel.Description('When the  eligible or active assignment becomes active.')]
    [System.String] $StartDateTime
}

class MSFT_MicrosoftGraphExpirationPattern
{
    [DscProperty()]
    [System.ComponentModel.Description('The requestor''s desired duration of access represented in ISO 8601 format for durations. For example, PT3H refers to three hours.  If specified in a request, endDateTime should not be present and the type property should be set to afterDuration.')]
    [System.String] $Duration

    [DscProperty()]
    [System.ComponentModel.Description('Timestamp of date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z.')]
    [System.String] $EndDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The requestor''s desired expiration pattern type. The possible values are: notSpecified, noExpiration, afterDateTime, afterDuration.')]
    [ValidateSet('notSpecified', 'noExpiration', 'afterDateTime', 'afterDuration')]
    [System.String] $Type
}

class MSFT_MicrosoftGraphPrivilegedAccessPatternedRecurrence
{
    [DscProperty()]
    [System.ComponentModel.Description('The frequency of an event.  For access reviews: Do not specify this property for a one-time access review.  Only interval, dayOfMonth, and type (weekly, absoluteMonthly) properties of recurrencePattern are supported.')]
    [MSFT_MicrosoftGraphPrivilegedAccessRecurrencePattern] $Pattern

    [DscProperty()]
    [System.ComponentModel.Description('The duration of an event.')]
    [MSFT_MicrosoftGraphRecurrenceRange] $Range
}

class MSFT_MicrosoftGraphPrivilegedAccessRecurrencePattern
{
    [DscProperty()]
    [System.ComponentModel.Description('The day of the month on which the event occurs. Required if type is absoluteMonthly or absoluteYearly.')]
    [System.Nullable[System.UInt32]] $DayOfMonth

    [DscProperty()]
    [System.ComponentModel.Description('A collection of the days of the week on which the event occurs. The possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday. If type is relativeMonthly or relativeYearly, and daysOfWeek specifies more than one day, the event falls on the first day that satisfies the pattern.  Required if type is weekly, relativeMonthly, or relativeYearly.')]
    [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
    [System.String[]] $DaysOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('The first day of the week. The possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday. Default is sunday. Required if type is weekly.')]
    [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
    [System.String] $FirstDayOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('Specifies on which instance of the allowed days specified in daysOfWeek the event occurs, counted from the first instance in the month. The possible values are: first, second, third, fourth, last. Default is first. Optional and used if type is relativeMonthly or relativeYearly.')]
    [ValidateSet('first', 'second', 'third', 'fourth', 'last')]
    [System.String] $Index

    [DscProperty()]
    [System.ComponentModel.Description('The number of units between occurrences, where units can be in days, weeks, months, or years, depending on the type. Required.')]
    [System.Nullable[System.UInt32]] $Interval

    [DscProperty()]
    [System.ComponentModel.Description('The month in which the event occurs.  This is a number from 1 to 12.')]
    [System.Nullable[System.UInt32]] $Month

    [DscProperty()]
    [System.ComponentModel.Description('The recurrence pattern type: daily, weekly, absoluteMonthly, relativeMonthly, absoluteYearly, relativeYearly. Required. For more information, see values of type property.')]
    [ValidateSet('daily', 'weekly', 'absoluteMonthly', 'relativeMonthly', 'absoluteYearly', 'relativeYearly')]
    [System.String] $Type
}

class MSFT_MicrosoftGraphRecurrenceRange
{
    [DscProperty()]
    [System.ComponentModel.Description('The date to stop applying the recurrence pattern. Depending on the recurrence pattern of the event, the last occurrence of the meeting may not be this date. Required if type is endDate.')]
    [System.String] $EndDate

    [DscProperty()]
    [System.ComponentModel.Description('The number of times to repeat the event. Required and must be positive if type is numbered.')]
    [System.Nullable[System.UInt32]] $NumberOfOccurrences

    [DscProperty()]
    [System.ComponentModel.Description('Time zone for the startDate and endDate properties. Optional. If not specified, the time zone of the event is used.')]
    [System.String] $RecurrenceTimeZone

    [DscProperty()]
    [System.ComponentModel.Description('The date to start applying the recurrence pattern. The first occurrence of the meeting may be this date or later, depending on the recurrence pattern of the event. Must be the same value as the start property of the recurring event. Required.')]
    [System.String] $StartDate

    [DscProperty()]
    [System.ComponentModel.Description('The recurrence range. Possible values are: endDate, noEnd, numbered. Required.')]
    [ValidateSet('endDate', 'noEnd', 'numbered')]
    [System.String] $Type
}
