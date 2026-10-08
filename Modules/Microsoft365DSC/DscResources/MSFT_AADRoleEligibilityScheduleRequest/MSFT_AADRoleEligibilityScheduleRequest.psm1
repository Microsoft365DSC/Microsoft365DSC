using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRoleEligibilityScheduleRequest : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('User Principal Name of the eligibility request.')]
    [System.String] $Principal

    [DscProperty(Key)]
    [System.ComponentModel.Description('Role associated with the eligibility request.')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Represented the type of principal to assign the request to. Accepted values are: Group and User.')]
    [ValidateSet('agentUser', 'Group', 'User', 'ServicePrincipal')]
    [System.String] $PrincipalType

    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier of the directory object representing the scope of the role eligibility. The scope of an role eligibility determines the set of resources for which the principal has been granted access. Directory scopes are shared scopes stored in the directory that are understood by multiple applications. Use / for tenant-wide scope. Use appScopeId to limit the scope to an application only. Either directoryScopeId or appScopeId is required.')]
    [System.String] $DirectoryScopeId

    [DscProperty()]
    [System.ComponentModel.Description('Identifier for the Role Eligibility Schedule Request.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the app-specific scope when the role eligibility is scoped to an app. The scope of a role eligibility determines the set of resources for which the principal is eligible to access. App scopes are scopes that are defined and understood by this application only. Use / for tenant-wide app scopes. Use directoryScopeId to limit the scope to particular directory objects, for example, administrative units. Either directoryScopeId or appScopeId is required.')]
    [System.String] $AppScopeId

    [DscProperty()]
    [System.ComponentModel.Description('A message provided by users and administrators when create they create the unifiedRoleEligibilityScheduleRequest object. Optional when action is adminRemove. Whether this property is required or optional is also dependent on the settings for the Azure AD role.')]
    [System.String] $Justification

    [DscProperty()]
    [System.ComponentModel.Description('The period of the role eligibility. Optional when action is adminRemove. The period of eligibility is dependent on the settings of the Azure AD role.')]
    [MSFT_AADRoleEligibilityScheduleRequestSchedule] $ScheduleInfo

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [AADRoleEligibilityScheduleRequest] Get()
    {
        $nullResult = $null
        $schedule = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADRoleEligibilityScheduleRequest]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the AAD Role Eligibility Schedule Request with Principal {$($this.Principal)}, RoleDefinition {$($this.RoleDefinition)}, PrincipalType {$($this.PrincipalType)} and DirectoryScopeId {$($this.DirectoryScopeId)}"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if ($null -eq $this.ResourceCache['AllSchedules'])
                {
                    Write-Verbose -Message 'Retrieving all role eligibility schedules'
                    $this.ResourceCache['AllSchedules'] = Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -All `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $this.ResourceCache['RoleDefinitions'])
                {
                    $this.ResourceCache['RoleDefinitions'] = [System.Collections.Generic.Dictionary[string, object]]::new()
                    $allRoleDefinitions = Get-MgBetaRoleManagementDirectoryRoleDefinition -All -ErrorAction SilentlyContinue
                    foreach ($singleRoleDefinition in $allRoleDefinitions)
                    {
                        $this.ResourceCache['RoleDefinitions'].Add($singleRoleDefinition.Id, $singleRoleDefinition)
                    }
                }

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Getting Role Eligibility by Id {$($this.Id)}"
                    $schedule = Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -UnifiedRoleEligibilityScheduleId $this.Id `
                        -ErrorAction SilentlyContinue
                }
            }
            else
            {
                $schedule = $this.ExportedInstance
                # To keep performance good, only assign the current instance
                $this.ResourceCache['AllSchedules'] = $this.ExportedInstance
            }

            Write-Verbose -Message 'Getting Role Eligibility by PrincipalId and RoleDefinitionId'
            $PrincipalInstance = $this.FindPrincipal() | Select-Object -First 1
            $PrincipalValue = $PrincipalInstance.UserPrincipalName
            if ([System.String]::IsNullOrEmpty($PrincipalValue))
            {
                $PrincipalValue = $PrincipalInstance.DisplayName
            }

            Write-Verbose -Message "Found Principal {$PrincipalValue}"
            $roleDefinitionId = $this.ResourceCache['RoleDefinitions'].GetEnumerator() | Where-Object { $_.Value.DisplayName -eq $this.RoleDefinition } | Select-Object -ExpandProperty Key
            Write-Verbose -Message "Retrieved role definition {$($this.RoleDefinition)} with ID {$roleDefinitionId}"

            if ($null -eq $schedule)
            {
                Write-Verbose -Message "Retrieving the request by PrincipalId {$($PrincipalInstance.Id)}, RoleDefinitionId {$($roleDefinitionId)} and DirectoryScopeId {$($this.DirectoryScopeId)}"
                [array]$requests = $this.ResourceCache['AllSchedules'] | Where-Object -FilterScript {
                    $_.PrincipalId -eq $PrincipalInstance.Id -and
                    $_.RoleDefinitionId -eq $roleDefinitionId -and
                    $_.DirectoryScopeId -eq $this.DirectoryScopeId
                }

                if ($requests.Count -eq 0)
                {
                    # Lookup in Graph - can be the case if a role was created in this configuration run
                    Write-Verbose -Message "No cached schedules found, fetching with principalId, roleDefinitionId and directoryScopeId"
                    $requests = Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$($PrincipalInstance.Id)' and roleDefinitionId eq '$($roleDefinitionId)' and directoryScopeId eq '$($this.DirectoryScopeId)'" -ErrorAction SilentlyContinue
                    if ($requests.Count -eq 0)
                    {
                        # We need to make sure we're not ending up here because the role is a custom role (which has a different id).
                        Write-Verbose -Message "No schedules found, testing for custom role definitions"
                        $roleEntry = $this.ResourceCache['RoleDefinitions'][$roleDefinitionId]
                        if ($null -eq $roleEntry)
                        {
                            $roleEntry = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $roleDefinitionId
                        }
                        if ($roleEntry.DisplayName -eq $this.RoleDefinition)
                        {
                            $roleDefinitionId = $roleEntry.Id
                            if (-not $this.ResourceCache['RoleDefinitions'].ContainsKey($roleDefinitionId))
                            {
                                $this.ResourceCache['RoleDefinitions'].Add($roleDefinitionId, $roleEntry)
                            }
                            # The TemplateId is the id of the custom role definition
                            Write-Verbose -Message "Fetching schedules for custom role definition with RoleDefinitionId {$roleDefinitionId}"
                            $requests = Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -Filter "principalId eq '$($PrincipalInstance.Id)' and roleDefinition/TemplateId eq '$($roleDefinitionId)' and directoryScopeId eq '$($this.DirectoryScopeId)'" -ErrorAction SilentlyContinue
                            if ($requests.Count -eq 0)
                            {
                                Write-Verbose -Message "No schedules found for custom role definition"
                                return $this.AsResult($nullResult)
                            }
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Adding schedule to cache"
                        $this.ResourceCache['AllSchedules'] += $requests[0]
                    }
                }

                if ($requests.Count -eq 0)
                {
                    return $this.AsResult($nullResult)
                }
                $schedule = $requests[0]
            }

            $ScheduleInfoValue = @{}
            if ($null -ne $schedule.ScheduleInfo.Expiration)
            {
                $expirationValue = [ordered]@{
                    duration = $schedule.ScheduleInfo.Expiration.Duration
                    type     = $schedule.ScheduleInfo.Expiration.Type
                }
                if ($null -ne $schedule.ScheduleInfo.Expiration.EndDateTime)
                {
                    $expirationValue.Add('endDateTime', $schedule.ScheduleInfo.Expiration.EndDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ'))
                }
                $ScheduleInfoValue.Add('expiration', $expirationValue)
            }
            if ($null -ne $schedule.ScheduleInfo.Recurrence)
            {
                if ($this.TestRecurrenceIsConfigured($schedule.ScheduleInfo.Recurrence))
                {
                    $recurrenceValue = [ordered]@{
                        pattern = [ordered]@{
                            dayOfMonth     = $schedule.ScheduleInfo.Recurrence.Pattern.dayOfMonth
                            daysOfWeek     = $schedule.ScheduleInfo.Recurrence.Pattern.daysOfWeek
                            firstDayOfWeek = $schedule.ScheduleInfo.Recurrence.Pattern.firstDayOfWeek
                            index          = $schedule.ScheduleInfo.Recurrence.Pattern.index
                            interval       = $schedule.ScheduleInfo.Recurrence.Pattern.interval
                            month          = $schedule.ScheduleInfo.Recurrence.Pattern.month
                            type           = $schedule.ScheduleInfo.Recurrence.Pattern.type
                        }
                        range   = [ordered]@{
                            endDate             = $schedule.ScheduleInfo.Recurrence.Range.endDate
                            numberOfOccurrences = $schedule.ScheduleInfo.Recurrence.Range.numberOfOccurrences
                            recurrenceTimeZone  = $schedule.ScheduleInfo.Recurrence.Range.recurrenceTimeZone
                            startDate           = $schedule.ScheduleInfo.Recurrence.Range.startDate
                            type                = $schedule.ScheduleInfo.Recurrence.Range.type
                        }
                    }
                    $ScheduleInfoValue.Add('Recurrence', $recurrenceValue)
                }
            }
            if ($null -ne $schedule.ScheduleInfo.StartDateTime)
            {
                $ScheduleInfoValue.Add('StartDateTime', $schedule.ScheduleInfo.StartDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ'))
            }

            $principalTypeValue = $this.PrincipalType
            $principalObject = Get-MgBetaDirectoryObjectById -Ids $schedule.PrincipalId -ErrorAction SilentlyContinue
            if ($null -ne $principalObject -and $null -ne $principalObject['@odata.type'])
            {
                $principalTypeValue = $principalObject['@odata.type'].Split('.')[2]
            }

            $results = @{
                Principal             = $PrincipalValue
                PrincipalType         = $principalTypeValue
                RoleDefinition        = $this.RoleDefinition
                DirectoryScopeId      = $schedule.DirectoryScopeId
                AppScopeId            = $schedule.AppScopeId
                Id                    = $schedule.Id
                Justification         = "Assignment of role eligibility '$($this.RoleDefinition)' to principal '$PrincipalValue' of type '$($this.PrincipalType)'."
                ScheduleInfo          = $ScheduleInfoValue
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

        $PrincipalId = $null
        $PrincipalId = ($this.FindPrincipal() | Select-Object -First 1).Id

        Write-Verbose -Message "Retrieving RoleDefinitionId from Set()"
        $roleDefinitionId = (Get-MgBetaRoleManagementDirectoryRoleDefinition -Filter "DisplayName eq '$($this.RoleDefinition -replace "'", "''")'").Id
        if ([System.String]::IsNullOrEmpty($roleDefinitionId))
        {
            throw "Couldn't find Role Definition {$($this.RoleDefinition)}"
        }

        $instanceParams = @{
            directoryScopeId = $this.DirectoryScopeId
            principalId      = $PrincipalId
            roleDefinitionId = $roleDefinitionId
            scheduleInfo     = @{
                expiration = @{
                    type        = $this.ScheduleInfo.Expiration.Type
                    duration    = $this.ScheduleInfo.Expiration.Duration
                    endDateTime = $this.ScheduleInfo.Expiration.EndDateTime
                }
                startDateTime = $this.ScheduleInfo.StartDateTime
            }
        }

        if (-not [System.String]::IsNullOrEmpty($this.AppScopeId))
        {
            $instanceParams.Add('appScopeId', $this.AppScopeId)
        }

        if ($null -eq $instanceParams.ScheduleInfo.Expiration.Duration)
        {
            $instanceParams.ScheduleInfo.Expiration.Remove('duration') | Out-Null
        }

        $RecurrenceInfo = @{}
        $foundRecurrenceItem = $false
        if ($null -ne $this.ScheduleInfo.Recurrence.Pattern.Type)
        {
            $Pattern = @{
                dayOfMonth     = $this.ScheduleInfo.Recurrence.Pattern.DayOfMonth
                daysOfWeek     = $this.ScheduleInfo.Recurrence.Pattern.DaysOfWeek
                firstDayOfWeek = $this.ScheduleInfo.Recurrence.Pattern.FirstDayOfWeek
                index          = $this.ScheduleInfo.Recurrence.Pattern.Index
                month          = $this.ScheduleInfo.Recurrence.Pattern.Month
                type           = $this.ScheduleInfo.Recurrence.Pattern.Type
            }
            $RecurrenceInfo.Add('pattern', $Pattern)
            $foundRecurrenceItem = $true
        }
        if ($null -ne $this.ScheduleInfo.Recurrence.Range.Type)
        {
            $Range = @{
                endDate             = $this.ScheduleInfo.Recurrence.Range.EndDate
                numberOfOccurrences = $this.ScheduleInfo.Recurrence.Range.NumberOfOccurrences
                recurrenceTimeZone  = $this.ScheduleInfo.Recurrence.Range.RecurrenceTimeZone
                startDate           = $this.ScheduleInfo.Recurrence.Range.StartDate
                type                = $this.ScheduleInfo.Recurrence.Range.Type
            }
            $RecurrenceInfo.Add('range', $Range)
            $foundRecurrenceItem = $true
        }
        if ($foundRecurrenceItem)
        {
            $instanceParams.Add('recurrence', $RecurrenceInfo)
        }

        if ([System.String]::IsNullOrEmpty($instanceParams.scheduleInfo.expiration.endDateTime))
        {
            $instanceParams.scheduleInfo.expiration.Remove('endDateTime') | Out-Null
        }
        if ([System.String]::IsNullOrEmpty($instanceParams.scheduleInfo.startDateTime))
        {
            $instanceParams.scheduleInfo.Remove('startDateTime') | Out-Null
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $instanceParams.Add('action', 'AdminAssign')
            $instanceParams.Add('justification', 'AdminAssign by Microsoft365DSC')
            Write-Verbose -Message "Creating new role eligibility Schedule with parameters:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Add('action', 'AdminUpdate')
            $instanceParams.Add('justification', 'AdminUpdate by Microsoft365DSC')
            Write-Verbose -Message "Updating role eligibility Schedule with parameters:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Add('action', 'AdminRemove')
            $instanceParams.Add('justification', 'AdminRemove by Microsoft365DSC')
            Write-Verbose -Message "Removing role eligibility Schedule with parameters:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            New-MgBetaRoleManagementDirectoryRoleEligibilityScheduleRequest -BodyParameter $instanceParams
            if ($this.ResourceCache['AllSchedules'].Count -gt 0)
            {
                # Remove the instance from the cached list to avoid re-processing
                $this.ResourceCache['AllSchedules'] = $this.ResourceCache['AllSchedules'] | Where-Object -FilterScript {
                    -not ($_.RoleDefinition -eq $this.RoleDefinition -and $_.Principal -eq $this.Principal -and $_.PrincipalType -eq $this.PrincipalType -and $_.DirectoryScopeId -eq $this.DirectoryScopeId)
                }
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $Params = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-MgBetaRoleManagementDirectoryRoleEligibilitySchedule -All -Filter $this.Filter `
                -ExpandProperty 'principal', 'roleDefinition' -ErrorAction SilentlyContinue

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            if ($null -eq $this.ResourceCache['RoleDefinitions'])
            {
                $this.ResourceCache['RoleDefinitions'] = [System.Collections.Generic.Dictionary[string, object]]::new()
                $roleDefinitions = Get-MgBetaRoleManagementDirectoryRoleDefinition -All -ErrorAction SilentlyContinue
                foreach ($currentRoleDefinition in $roleDefinitions)
                {
                    $this.ResourceCache['RoleDefinitions'].Add($currentRoleDefinition.Id, $currentRoleDefinition)
                }
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite

                # Find the Principal Type
                $principalTypeValue = 'User'
                $userInfo = $config.Principal
                if ($null -eq $userInfo)
                {
                    $userInfo = Get-MgBetaDirectoryObjectById -Ids $config.PrincipalId -ErrorAction SilentlyContinue
                }
                $principalTypeValue = $userInfo['@odata.type'].Split('.')[2]
                $PrincipalValue = if ($principalTypeValue -eq 'user' -or $principalTypeValue -eq 'agentUser')
                {
                    $userInfo['userPrincipalName']
                }
                else
                {
                    $userInfo['displayName']
                }

                if ($null -eq $PrincipalValue)
                {
                    $i++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    continue
                }

                $currentRoleDefinition = $config.RoleDefinition
                if ($null -eq $currentRoleDefinition)
                {
                    $currentRoleDefinition = $this.ResourceCache['RoleDefinitions'][$config.RoleDefinitionId]
                }
                if ($null -eq $currentRoleDefinition)
                {
                    $currentRoleDefinition = Get-MgBetaRoleManagementDirectoryRoleDefinition -UnifiedRoleDefinitionId $config.RoleDefinitionId `
                        -ErrorAction SilentlyContinue
                    $this.ResourceCache['RoleDefinitions'].Add($config.RoleDefinitionId, $currentRoleDefinition)
                }
                $params = @{
                    Id                    = $config.Id
                    Principal             = $PrincipalValue
                    PrincipalType         = $principalTypeValue
                    DirectoryScopeId      = $config.DirectoryScopeId
                    RoleDefinition        = $currentRoleDefinition.DisplayName
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

                if ($Results.ScheduleInfo)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'expiration'
                            CimInstanceName = 'AADRoleEligibilityScheduleRequestScheduleExpiration'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Recurrence'
                            CimInstanceName = 'AADRoleEligibilityScheduleRequestScheduleRecurrence'
                            IsRequired      = $False
                        }
                        @{
                            Name            = "range"
                            CimInstanceName = 'AADRoleEligibilityScheduleRequestScheduleRecurrenceRange'
                            IsRequired      = $False
                        }
                        @{
                            Name            = "pattern"
                            CimInstanceName = 'AADRoleEligibilityScheduleRequestScheduleRecurrencePattern'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.ScheduleInfo `
                            -CIMInstanceName 'AADRoleEligibilityScheduleRequestSchedule' `
                            -ComplexTypeMapping $complexMapping
                    if ($complexTypeStringResult)
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
                    -NoEscape @('ScheduleInfo')
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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
            ExcludedProperties = @('Justification')
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

                $desiredExpiration = $DesiredValues.ScheduleInfo.expiration
                $currentExpiration = $CurrentValues.ScheduleInfo.expiration
                if ($desiredExpiration.type -eq 'afterDuration' -and $currentExpiration.type -eq 'afterDateTime' -and
                    [M365DSCResourceBase]::IsSameDuration($desiredExpiration.duration, $CurrentValues.ScheduleInfo.startDateTime, $currentExpiration.endDateTime))
                {
                    Write-Verbose -Message "The schedule ends {$($desiredExpiration.duration)} after its start. Aligning the expiration for comparison."
                    $currentExpiration.type = $desiredExpiration.type
                    $currentExpiration.duration = $desiredExpiration.duration
                    $currentExpiration.endDateTime = $desiredExpiration.endDateTime
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.Object] FindPrincipal()
    {
        $principalTypes = @('User', 'Group', 'ServicePrincipal')
        if (-not [System.String]::IsNullOrEmpty($this.PrincipalType))
        {
            $principalTypes = @($this.PrincipalType)
        }

        $escapedPrincipal = $this.Principal -replace "'", "''"
        foreach ($principalType in $principalTypes)
        {
            if ($principalType -eq 'User' -or $principalType -eq 'agentUser')
            {
                Write-Verbose -Message "Retrieving Principal by UserPrincipalName {$($this.Principal)}"
                [Array] $principalMatches = Get-MgUser -Filter "UserPrincipalName eq '$escapedPrincipal'" -ErrorAction SilentlyContinue
            }
            elseif ($principalType -eq 'Group')
            {
                Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
                [Array] $principalMatches = Get-MgGroup -Filter "DisplayName eq '$escapedPrincipal'" -ErrorAction SilentlyContinue
            }
            else
            {
                Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
                [Array] $principalMatches = Get-MgServicePrincipal -Filter "DisplayName eq '$escapedPrincipal'" -ErrorAction SilentlyContinue
            }

            if ($principalMatches.Count -gt 0)
            {
                return $principalMatches
            }
        }

        return $null
    }

    hidden [System.Boolean] TestRecurrenceIsConfigured([System.Object] $RecurrenceSettings)
    {
        if ($null -eq $RecurrenceSettings.Pattern.DayOfMonth -and `
            $null -eq $RecurrenceSettings.Pattern.DayOfWeek -and `
            $null -eq $RecurrenceSettings.Pattern.FirstDayOfWeek -and `
            $null -eq $RecurrenceSettings.Pattern.Index -and `
            $null -eq $RecurrenceSettings.Pattern.Interval -and `
            $null -eq $RecurrenceSettings.Pattern.Month -and `
            $null -eq $RecurrenceSettings.Pattern.Type -and `
            $null -eq $RecurrenceSettings.Range.EndDate -and `
            $null -eq $RecurrenceSettings.Range.NumberOfOccurrences -and `
            $null -eq $RecurrenceSettings.Range.RecurrenceTimeZone -and `
            $null -eq $RecurrenceSettings.Range.StartDate -and `
            $null -eq $RecurrenceSettings.Range.Type)
        {
            return $false
        }

        return $true
    }

    hidden [AADRoleEligibilityScheduleRequest] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADRoleEligibilityScheduleRequest])
        {
            return $Values
        }

        $result = [AADRoleEligibilityScheduleRequest]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADRoleEligibilityScheduleRequestSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('When the eligible or active assignment expires.')]
    [MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration] $expiration

    [DscProperty()]
    [System.ComponentModel.Description('The frequency of the eligible or active assignment. This property is currently unsupported in PIM.')]
    [MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrence] $recurrence

    [DscProperty()]
    [System.ComponentModel.Description('When the eligible or active assignment becomes active.')]
    [System.String] $startDateTime
}

class MSFT_AADRoleEligibilityScheduleRequestScheduleExpiration
{
    [DscProperty()]
    [System.ComponentModel.Description('The requestor''s desired duration of access represented in ISO 8601 format for durations. For example, PT3H refers to three hours. If specified in a request, endDateTime should not be present and the type property should be set to afterDuration.')]
    [System.String] $duration

    [DscProperty()]
    [System.ComponentModel.Description('Timestamp of date and time information using ISO 8601 format and is always in UTC time. For example, midnight UTC on Jan 1, 2014 is 2014-01-01T00:00:00Z.')]
    [System.String] $endDateTime

    [DscProperty()]
    [System.ComponentModel.Description('The requestor''s desired expiration pattern type. The possible values are: notSpecified, noExpiration, afterDateTime, afterDuration.')]
    [ValidateSet('notSpecified', 'noExpiration', 'afterDateTime', 'afterDuration')]
    [System.String] $type
}

class MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrence
{
    [DscProperty()]
    [System.ComponentModel.Description('The frequency of an event.')]
    [MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrencePattern] $pattern

    [DscProperty()]
    [System.ComponentModel.Description('The duration of an event.')]
    [MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrenceRange] $range
}

class MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrencePattern
{
    [DscProperty()]
    [System.ComponentModel.Description('The day of the month on which the event occurs.')]
    [System.Nullable[System.UInt32]] $dayOfMonth

    [DscProperty()]
    [System.ComponentModel.Description('A collection of the days of the week on which the event occurs. The possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday')]
    [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
    [System.String[]] $daysOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('The first day of the week.')]
    [ValidateSet('sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday')]
    [System.String] $firstDayOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('Specifies on which instance of the allowed days specified in daysOfWeek the event occurs, counted from the first instance in the month. The possible values are: first, second, third, fourth, last.')]
    [ValidateSet('first', 'second', 'third', 'fourth', 'last')]
    [System.String] $index

    [DscProperty()]
    [System.ComponentModel.Description('The number of units between occurrences, where units can be in days, weeks, months, or years, depending on the type.')]
    [System.Nullable[System.UInt32]] $interval

    [DscProperty()]
    [System.ComponentModel.Description('The month in which the event occurs. This is a number from 1 to 12.')]
    [System.Nullable[System.UInt32]] $month

    [DscProperty()]
    [System.ComponentModel.Description('The recurrence pattern type: daily, weekly, absoluteMonthly, relativeMonthly, absoluteYearly, relativeYearly.')]
    [ValidateSet('daily', 'weekly', 'absoluteMonthly', 'relativeMonthly', 'absoluteYearly', 'relativeYearly')]
    [System.String] $type
}

class MSFT_AADRoleEligibilityScheduleRequestScheduleRecurrenceRange
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The date to stop applying the recurrence pattern. Depending on the recurrence pattern of the event, the last occurrence of the meeting may not be this date.')]
    [System.String] $endDate

    [DscProperty()]
    [System.ComponentModel.Description('The number of times to repeat the event. Required and must be positive if type is numbered.')]
    [System.Nullable[System.UInt32]] $numberOfOccurrences

    [DscProperty()]
    [System.ComponentModel.Description('Time zone for the startDate and endDate properties.')]
    [System.String] $recurrenceTimeZone

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The date to start applying the recurrence pattern. The first occurrence of the meeting may be this date or later, depending on the recurrence pattern of the event. Must be the same value as the start property of the recurring event.')]
    [System.String] $startDate

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The recurrence range. The possible values are: endDate, noEnd, numbered.')]
    [ValidateSet('endDate', 'noEnd', 'numbered')]
    [System.String] $type
}
