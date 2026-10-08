using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureRoleAssignmentScheduleRequest : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('User Principal Name of the Azure role assignment request.')]
    [System.String] $Principal

    [DscProperty(Key)]
    [System.ComponentModel.Description('Azure role associated with the assignment request (e.g., ''Owner'', ''Contributor'').')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Represented the type of principal to assign the request to. Accepted values are: Group, User and ServicePrincipal.')]
    [ValidateSet('Group', 'User', 'ServicePrincipal')]
    [System.String] $PrincipalType

    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier of the scope representing the Azure resource (e.g., /subscriptions/{id}, /providers/Microsoft.Management/managementGroups/{id}). The scope determines the set of Azure resources for which the principal has been granted access.')]
    [System.String] $DirectoryScopeId

    [DscProperty()]
    [System.ComponentModel.Description('Identifier for the Role Assignment Schedule Request.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the app-specific scope when the role assignment is scoped to an app. Not commonly used for Azure RBAC roles.')]
    [System.String] $AppScopeId

    [DscProperty()]
    [System.ComponentModel.Description('A message provided by users and administrators when they create the role assignment schedule request.')]
    [System.String] $Justification

    [DscProperty()]
    [System.ComponentModel.Description('The period of the role assignment. The period of assignment is dependent on the settings of the Azure role.')]
    [MSFT_AzureRoleAssignmentScheduleRequestSchedule] $ScheduleInfo

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Azure subscription to connect to if the access is restricted on subscription level.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin')]
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

    [AzureRoleAssignmentScheduleRequest] Get()
    {
        $requests = $null
        $schedule = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureRoleAssignmentScheduleRequest]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Role Assignment Schedule Request"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if ($null -eq $this.ResourceCache['AllSchedules'])
                {
                    Write-Verbose -Message "Retrieving all role assignment schedules in scope {$($this.DirectoryScopeId)}"
                    $this.ResourceCache['AllSchedules'] = Get-AzRoleAssignmentSchedule -Scope $this.DirectoryScopeId `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $this.ResourceCache['RoleDefinitions'])
                {
                    $this.ResourceCache['RoleDefinitions'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
                    $allRoleDefinitions = Get-AzRoleDefinition -ErrorAction SilentlyContinue
                    foreach ($singleRoleDefinition in $allRoleDefinitions)
                    {
                        $this.ResourceCache['RoleDefinitions'].Add($singleRoleDefinition.Id, $singleRoleDefinition)
                    }
                }

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Getting Role Assignment with scope {$($this.DirectoryScopeId)} and by Id {$($this.Id)}"
                    $schedule = $this.ResourceCache['AllSchedules'] | Where-Object -FilterScript {
                        $_.Name -eq $this.Id -and $_.Scope -eq $this.DirectoryScopeId
                    }
                }
            }
            else
            {
                $schedule = $this.ExportedInstance
                # To keep performance good, only assign the current instance
                $this.ResourceCache['AllSchedules'] = $this.ExportedInstance
            }

            Write-Verbose -Message "Getting Role Assignment by PrincipalId and RoleDefinitionId for Principal {$($this.Principal)}"
            if ($null -eq $this.ResourceCache['PrincipalByNameCache'])
            {
                $this.ResourceCache['PrincipalByNameCache'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
            }
            $cacheKey = "$($this.PrincipalType)|$($this.Principal)"
            $PrincipalValue = $null
            if ($this.ResourceCache['PrincipalByNameCache'].ContainsKey($cacheKey))
            {
                Write-Verbose -Message "Using cached principal for {$($this.Principal)}"
                $PrincipalInstance = $this.ResourceCache['PrincipalByNameCache'][$cacheKey]
            }
            else
            {
                if ($this.PrincipalType -eq 'User')
                {
                    Write-Verbose -Message "Retrieving Principal by UserPrincipalName {$($this.Principal)}"
                    $PrincipalInstance = Get-AzADUser -UserPrincipalName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue
                }
                elseif ($this.PrincipalType -eq 'Group')
                {
                    Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
                    $PrincipalInstance = Get-AzADGroup -DisplayName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue
                }
                else
                {
                    Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
                    $PrincipalInstance = Get-AzADServicePrincipal -DisplayName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue
                }
                if ($null -ne $PrincipalInstance)
                {
                    $this.ResourceCache['PrincipalByNameCache'][$cacheKey] = $PrincipalInstance
                }
            }
            if ($this.PrincipalType -eq 'User')
            {
                $PrincipalValue = $PrincipalInstance.UserPrincipalName
            }
            elseif ($null -ne $PrincipalInstance)
            {
                $PrincipalValue = $PrincipalInstance.DisplayName
            }

            if ([System.String]::IsNullOrEmpty($PrincipalValue)) {
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found Principal {$PrincipalValue}"
            $roleDefinitionId = $this.ResourceCache['RoleDefinitions'].GetEnumerator() | Where-Object { $_.Value.Name -eq $this.RoleDefinition } | Select-Object -ExpandProperty Key
            Write-Verbose -Message "Retrieved role definition {$($this.RoleDefinition)} with ID {$roleDefinitionId}"

            if ($null -eq $schedule)
            {
                Write-Verbose -Message "Retrieving the request by PrincipalId {$($PrincipalInstance.Id)}, RoleDefinitionId {$($roleDefinitionId)} and DirectoryScopeId {$($this.DirectoryScopeId)}"
                [array]$requests = $this.ResourceCache['AllSchedules'] | Where-Object -FilterScript {
                    $_.PrincipalId -eq $PrincipalInstance.Id -and
                    $null -ne $_.RoleDefinitionId -and
                    $_.RoleDefinitionId.Split('/')[-1] -eq $roleDefinitionId -and
                    $_.Scope -eq $this.DirectoryScopeId
                }

                if ($requests.Count -eq 0)
                {
                    # Lookup in Azure - can be the case if a role was created in this configuration run
                    Write-Verbose -Message "No cached schedules found, fetching with principalId, roleDefinitionId and directoryScopeId"
                    $requests = Get-AzRoleAssignmentSchedule -Scope $this.DirectoryScopeId -Filter "principalId eq '$($PrincipalInstance.Id)'" -ErrorAction SilentlyContinue
                    $requests = $requests | Where-Object -FilterScript {
                        $null -ne $_.RoleDefinitionId -and
                        $_.RoleDefinitionId.Split('/')[-1] -eq $roleDefinitionId -and
                        $_.Scope -eq $this.DirectoryScopeId
                    }
                    if ($requests.Count -eq 0)
                    {
                        # We need to make sure we're not ending up here because the role is a custom role (which has a different id).
                        Write-Verbose -Message "No schedules found, testing for custom role definitions"
                        if ($null -eq $roleDefinitionId)
                        {
                            Write-Verbose -Message "Role definition Id is null, returning null result"
                            return $this.AsResult($nullResult)
                        }
                        $roleEntry = $this.ResourceCache['RoleDefinitions'][$roleDefinitionId]
                        if ($null -eq $roleEntry)
                        {
                            $roleEntry = Get-AzRoleDefinition -Id $roleDefinitionId -ErrorAction SilentlyContinue
                        }
                        if ($roleEntry.Name -eq $this.RoleDefinition)
                        {
                            $roleDefinitionId = $roleEntry.Id
                            if (-not $this.ResourceCache['RoleDefinitions'].ContainsKey($roleDefinitionId))
                            {
                                $this.ResourceCache['RoleDefinitions'].Add($roleDefinitionId, $roleEntry)
                            }
                            # The TemplateId is the id of the custom role definition
                            Write-Verbose -Message "Fetching schedules for custom role definition with RoleDefinitionId {$roleDefinitionId}"
                            $requests = Get-AzRoleAssignmentSchedule -Scope $this.DirectoryScopeId -Filter "principalId eq '$($PrincipalInstance.Id)'" -ErrorAction SilentlyContinue
                            $requests = $requests | Where-Object -FilterScript {
                                $null -ne $_.RoleDefinitionId -and
                                $_.RoleDefinitionId.Split('/')[-1] -eq $roleDefinitionId -and
                                $_.Scope -eq $this.DirectoryScopeId
                            }
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
                else
                {
                    $schedule = $requests[0]
                }
            }

            if ($null -eq $schedule -and $null -ne $requests -and $requests.Count -gt 0)
            {
                $schedule = $requests[0]
            }

            if ($null -eq $schedule)
            {
                return $this.AsResult($nullResult)
            }

            $ScheduleInfoValue = @{}

            $expirationValue = [ordered]@{}
            if ($null -ne $schedule.EndDateTime)
            {
                $expirationValue.Add('endDateTime', $schedule.EndDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ'))
                $expirationValue.Add('type', 'afterDateTime')
            }
            else
            {
                $expirationValue.Add('type', 'noExpiration')
            }
            $ScheduleInfoValue.Add('expiration', $expirationValue)

            if ($null -ne $schedule.StartDateTime)
            {
                $ScheduleInfoValue.Add('StartDateTime', $schedule.StartDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ'))
            }

            $principalTypeValue = $this.PrincipalType
            if (-not [System.String]::IsNullOrEmpty($schedule.PrincipalType))
            {
                $principalTypeValue = $schedule.PrincipalType
            }

            $results = @{
                Principal             = $PrincipalValue
                PrincipalType         = $principalTypeValue
                RoleDefinition        = $this.RoleDefinition
                DirectoryScopeId      = $schedule.Scope
                Id                    = $schedule.Name
                Justification         = "Assignment of Azure role '$($this.RoleDefinition)' to principal '$PrincipalValue' of type '$($this.PrincipalType)'."
                ScheduleInfo          = $ScheduleInfoValue
                Ensure                = 'Present'
                SubscriptionId        = $this.SubscriptionId
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
        $PrincipalIdValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # Reset caches to ensure fresh data
        $this.ResourceCache['AllSchedules'] = $null
        $this.ResourceCache['RoleDefinitions'] = $null
        $this.ResourceCache['PrincipalByNameCache'] = $null
        $this.ResourceCache['PrincipalByIdCache'] = $null

        $currentInstance = $this.Get().ToHashtable()

        if ($this.PrincipalType -eq 'User')
        {
            Write-Verbose -Message "Retrieving Principal by UserPrincipalName {$($this.Principal)}"
            [Array]$PrincipalIdValue = (Get-AzADUser -UserPrincipalName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue).Id
        }
        elseif ($this.PrincipalType -eq 'Group')
        {
            Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
            [Array]$PrincipalIdValue = (Get-AzADGroup -DisplayName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue).Id
        }
        elseif ($this.PrincipalType -eq 'ServicePrincipal')
        {
            Write-Verbose -Message "Retrieving Principal by DisplayName {$($this.Principal)}"
            [Array]$PrincipalIdValue = (Get-AzADServicePrincipal -DisplayName ($this.Principal -replace "'", "''") -ErrorAction SilentlyContinue).Id
        }

        if ($null -eq $PrincipalIdValue)
        {
            throw "Couldn't find Principal {$($this.Principal)} of type {$($this.PrincipalType)}"
        }
        elseif ($PrincipalIdValue.Length -gt 1)
        {
            throw "Multiple Principal with ID {$($this.Principal)} of type {$($this.PrincipalType)} were found. Cannot create schedule."
        }

        $RoleDefinitionIdValue = (Get-AzRoleDefinition -Name ($this.RoleDefinition -replace "'", "''") -ErrorAction SilentlyContinue).Id
        if ($null -eq $RoleDefinitionIdValue)
        {
            throw "Couldn't find Role Definition {$($this.RoleDefinition)}"
        }

        $instanceParams = @{
            Name             = [guid]::NewGuid().ToString()
            Scope            = $this.DirectoryScopeId
            PrincipalId      = $PrincipalIdValue[0]
            RoleDefinitionId = "$($this.DirectoryScopeId)/providers/Microsoft.Authorization/roleDefinitions/$RoleDefinitionIdValue"
        }

        if ($null -ne $this.ScheduleInfo)
        {
            if (-not [System.String]::IsNullOrEmpty($this.ScheduleInfo.StartDateTime))
            {
                $instanceParams.Add('ScheduleInfoStartDateTime', $this.ScheduleInfo.StartDateTime)
            }
            if (-not [System.String]::IsNullOrEmpty($this.ScheduleInfo.Expiration.Type))
            {
                $instanceParams.Add('ExpirationType', $this.ScheduleInfo.Expiration.Type)
            }
            if (-not [System.String]::IsNullOrEmpty($this.ScheduleInfo.Expiration.Duration))
            {
                $instanceParams.Add('ExpirationDuration', $this.ScheduleInfo.Expiration.Duration)
            }
            if (-not [System.String]::IsNullOrEmpty($this.ScheduleInfo.Expiration.EndDateTime))
            {
                $instanceParams.Add('ExpirationEndDateTime', $this.ScheduleInfo.Expiration.EndDateTime)
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $instanceParams.Add('RequestType', 'AdminAssign')
            $instanceParams.Add('Justification', 'AdminAssign by Microsoft365DSC')
            Write-Verbose -Message "Creating a Role Assignment Schedule Request for principal {$($this.Principal)} and role {$($this.RoleDefinition)}"
            New-AzRoleAssignmentScheduleRequest @instanceParams
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Add('RequestType', 'AdminUpdate')
            $instanceParams.Add('Justification', 'AdminUpdate by Microsoft365DSC')
            Write-Verbose -Message "Updating the Role Assignment Schedule Request for principal {$($this.Principal)} and role {$($this.RoleDefinition)}"
            New-AzRoleAssignmentScheduleRequest @instanceParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Add('RequestType', 'AdminRemove')
            $instanceParams.Add('Justification', 'AdminRemove by Microsoft365DSC')
            Write-Verbose -Message "Removing the Role Assignment Schedule Request for principal {$($this.Principal)} and role {$($this.RoleDefinition)}"
            New-AzRoleAssignmentScheduleRequest @instanceParams
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

        $ConnectionMode = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            $AllSchedules = [System.Collections.Generic.List[System.Object]]::new()
            $SeenScheduleNames = [System.Collections.Generic.HashSet[System.String]]::new()

            # Root scope
            $ScopeSchedules = Get-AzRoleAssignmentSchedule -Scope '/' -Filter $this.Filter -ErrorAction SilentlyContinue
            foreach ($Schedule in $ScopeSchedules)
            {
                if ($SeenScheduleNames.Add($Schedule.Name))
                {
                    $AllSchedules.Add($Schedule)
                }
            }

            # Management Groups
            $ManagementGroups = Get-AzManagementGroup -ErrorAction SilentlyContinue
            foreach ($ManagementGroup in $ManagementGroups)
            {
                $MgScope = "/providers/Microsoft.Management/managementGroups/$($ManagementGroup.Name)"
                $ScopeSchedules = Get-AzRoleAssignmentSchedule -Scope $MgScope -Filter $this.Filter -ErrorAction SilentlyContinue
                foreach ($Schedule in $ScopeSchedules)
                {
                    if ($SeenScheduleNames.Add($Schedule.Name))
                    {
                        $AllSchedules.Add($Schedule)
                    }
                }
            }

            # Subscriptions and their Resource Groups
            $Subscriptions = Get-AzSubscription -ErrorAction SilentlyContinue
            foreach ($Subscription in $Subscriptions)
            {
                $SubScope = "/subscriptions/$($Subscription.Id)"
                $ScopeSchedules = Get-AzRoleAssignmentSchedule -Scope $SubScope -Filter $this.Filter -ErrorAction SilentlyContinue
                foreach ($Schedule in $ScopeSchedules)
                {
                    if ($SeenScheduleNames.Add($Schedule.Name))
                    {
                        $AllSchedules.Add($Schedule)
                    }
                }

                $response = Invoke-AzRestMethod -Path "$SubScope/resourcegroups?api-version=2021-04-01" -Method GET -ErrorAction SilentlyContinue
                while ($null -ne $response -and $response.StatusCode -eq 200)
                {
                    $page = ConvertFrom-Json -InputObject $response.Content
                    foreach ($ResourceGroup in $page.value)
                    {
                        $RgScope = "$SubScope/resourceGroups/$($ResourceGroup.name)"
                        $ScopeSchedules = Get-AzRoleAssignmentSchedule -Scope $RgScope -Filter $this.Filter -ErrorAction SilentlyContinue
                        foreach ($Schedule in $ScopeSchedules)
                        {
                            if ($SeenScheduleNames.Add($Schedule.Name))
                            {
                                $AllSchedules.Add($Schedule)
                            }
                        }
                    }
                    $response = $null
                    if (-not [System.String]::IsNullOrEmpty($page.nextLink))
                    {
                        $response = Invoke-AzRestMethod -Uri $page.nextLink -Method GET -ErrorAction SilentlyContinue
                    }
                }
            }

            [array] $exportedInstances = $AllSchedules

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
                $this.ResourceCache['RoleDefinitions'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
                $roleDefinitions = Get-AzRoleDefinition -ErrorAction SilentlyContinue
                foreach ($currentRoleDefinition in $roleDefinitions)
                {
                    $this.ResourceCache['RoleDefinitions'].Add($currentRoleDefinition.Id, $currentRoleDefinition)
                }
            }
            $this.ResourceCache['PrincipalByIdCache'] = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
            foreach ($request in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $request.Name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite

                # Find the Principal Type
                $requestPrincipalType = $request.PrincipalType
                $principalInfo = $null
                $PrincipalValue = $null
                if ($this.ResourceCache['PrincipalByIdCache'].ContainsKey($request.PrincipalId))
                {
                    $principalInfo = $this.ResourceCache['PrincipalByIdCache'][$request.PrincipalId]
                }
                else
                {
                    if ($requestPrincipalType -eq 'User')
                    {
                        $principalInfo = Get-AzADUser -ObjectId $request.PrincipalId -ErrorAction SilentlyContinue
                    }
                    elseif ($requestPrincipalType -eq 'Group')
                    {
                        $principalInfo = Get-AzADGroup -ObjectId $request.PrincipalId -ErrorAction SilentlyContinue
                    }
                    else
                    {
                        $principalInfo = Get-AzADServicePrincipal -ObjectId $request.PrincipalId -ErrorAction SilentlyContinue
                    }
                    if ($null -ne $principalInfo)
                    {
                        $this.ResourceCache['PrincipalByIdCache'][$request.PrincipalId] = $principalInfo
                    }
                }
                if ($requestPrincipalType -eq 'User')
                {
                    $PrincipalValue = $principalInfo.UserPrincipalName
                }
                elseif ($null -ne $principalInfo)
                {
                    $PrincipalValue = $principalInfo.DisplayName
                }

                if ([System.String]::IsNullOrEmpty($PrincipalValue))
                {
                    Write-M365DSCHost -Message "$($Global:M365DSCEmojiYellowCircle) Principal {$($request.PrincipalId)} of type {$requestPrincipalType} could not be resolved. Skipping." -CommitWrite
                    $i++
                    continue
                }

                $roleDefinitionGuid = $request.RoleDefinitionId.Split('/')[-1]
                $currentRoleDefinition = $this.ResourceCache['RoleDefinitions'][$roleDefinitionGuid]
                if ($null -eq $currentRoleDefinition)
                {
                    $currentRoleDefinition = Get-AzRoleDefinition -Id $roleDefinitionGuid -Scope $request.Scope `
                        -ErrorAction SilentlyContinue
                    $this.ResourceCache['RoleDefinitions'][$roleDefinitionGuid] = $currentRoleDefinition
                }
                $Params = @{
                    Id                    = $request.Name
                    Principal             = $PrincipalValue
                    PrincipalType         = $requestPrincipalType
                    DirectoryScopeId      = $request.Scope
                    RoleDefinition        = $currentRoleDefinition.Name
                    Ensure                = 'Present'
                    SubscriptionId        = $this.SubscriptionId
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

                $this.ExportedInstance = $request
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.ScheduleInfo)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ScheduleInfo'
                            CimInstanceName = 'MSFT_AzureRoleAssignmentScheduleRequestSchedule'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'expiration'
                            CimInstanceName = 'MSFT_AzureRoleAssignmentScheduleRequestScheduleExpiration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'recurrence'
                            CimInstanceName = 'MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrence'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'pattern'
                            CimInstanceName = 'MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrencePattern'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'range'
                            CimInstanceName = 'MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrenceRange'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ScheduleInfo `
                        -CIMInstanceName 'MSFT_AzureRoleAssignmentScheduleRequestSchedule' `
                        -ComplexTypeMapping $complexMapping

                    if (-Not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
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
            if ($_.ErrorDetails.Message -like '*The tenant needs an AAD Premium*' -or `
                    $_.ErrorDetails.Message -like '*[AadPremiumLicenseRequired]*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component."
                return ''
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Justification', 'SubscriptionId')
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($null -ne $DesiredValues.ScheduleInfo -and
                    -not [System.String]::IsNullOrEmpty($DesiredValues.ScheduleInfo.StartDateTime))
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

    hidden [AzureRoleAssignmentScheduleRequest] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureRoleAssignmentScheduleRequest])
        {
            return $Values
        }

        $result = [AzureRoleAssignmentScheduleRequest]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AzureRoleAssignmentScheduleRequestSchedule
{
    [DscProperty()]
    [System.ComponentModel.Description('When the eligible or active assignment expires.')]
    [MSFT_AzureRoleAssignmentScheduleRequestScheduleExpiration] $expiration

    [DscProperty()]
    [System.ComponentModel.Description('The frequency of the eligible or active assignment. This property is currently unsupported in PIM.')]
    [MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrence] $recurrence

    [DscProperty()]
    [System.ComponentModel.Description('When the eligible or active assignment becomes active.')]
    [System.String] $startDateTime
}

class MSFT_AzureRoleAssignmentScheduleRequestScheduleExpiration
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

class MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrence
{
    [DscProperty()]
    [System.ComponentModel.Description('The frequency of an event.')]
    [MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrencePattern] $pattern

    [DscProperty()]
    [System.ComponentModel.Description('The duration of an event.')]
    [MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrenceRange] $range
}

class MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrencePattern
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

class MSFT_AzureRoleAssignmentScheduleRequestScheduleRecurrenceRange
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
