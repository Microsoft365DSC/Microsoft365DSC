using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAccessReviewDefinition : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the access review series. Supports $select and $orderby. Required on create.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Defines the list of additional users or group members to be notified of the access review progress.')]
    [MSFT_AADAccessReviewDefinitionReviewer[]] $AdditionalNotificationRecipients

    [DscProperty()]
    [System.ComponentModel.Description('Description provided by review creators to provide more context of the review to admins. Supports $select.')]
    [System.String] $DescriptionForAdmins

    [DscProperty()]
    [System.ComponentModel.Description('Description provided  by review creators to provide more context of the review to reviewers. Reviewers see this description in the email sent to them requesting their review. Email notifications support up to 256 characters. Supports $select.')]
    [System.String] $DescriptionForReviewers

    [DscProperty()]
    [System.ComponentModel.Description('The fallback reviewers of the access review.')]
    [MSFT_AADAccessReviewDefinitionReviewer[]] $FallbackReviewers

    [DscProperty()]
    [System.ComponentModel.Description('In the case of an all groups review, this determines the scope of which groups will be reviewed.')]
    [MSFT_MicrosoftGraphAccessReviewScope2] $InstanceEnumerationScope

    [DscProperty()]
    [System.ComponentModel.Description('The reviewers of the access review.')]
    [MSFT_AADAccessReviewDefinitionReviewer[]] $Reviewers

    [DscProperty()]
    [System.ComponentModel.Description('Defines the entities whose access is reviewed. For supported scopes, see accessReviewScope. Required on create. Supports $select and $filter (contains only). For examples of options for configuring scope, see Configure the scope of your access review definition using the Microsoft Graph API.')]
    [MSFT_MicrosoftGraphaccessReviewScope] $ScopeValue

    [DscProperty()]
    [System.ComponentModel.Description('The settings for an access review series, see type definition below. Supports $select. Required on create.')]
    [MSFT_MicrosoftGraphaccessReviewScheduleSettings] $Settings

    [DscProperty()]
    [System.ComponentModel.Description('Required only for a multi-stage access review to define the stages and their settings. You can break down each review instance into up to three sequential stages, where each stage can have a different set of reviewers, fallback reviewers, and settings. Stages are created sequentially based on the dependsOn property. Optional.  When this property is defined, its settings are used instead of the corresponding settings in the accessReviewScheduleDefinition object and its settings, reviewers, and fallbackReviewers properties.')]
    [MSFT_MicrosoftGraphaccessReviewStageSettings[]] $StageSettings

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

    [AADAccessReviewDefinition] Get()
    {
        $batchResponses = $null
        $reviewerType = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAccessReviewDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Access Review Definition '$($this.DisplayName)'"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaIdentityGovernanceAccessReviewDefinition -AccessReviewScheduleDefinitionId $this.Id `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Access Review Definition with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaIdentityGovernanceAccessReviewDefinition `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Access Review Definition with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Access Review Definition with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexScope = [ordered]@{}
            $complexScope.Add('Query', $getValue.Scope.query)
            $complexScope.Add('QueryRoot', $getValue.Scope.queryRoot)
            $complexScope.Add('QueryType', $getValue.Scope.queryType)

            if ($null -ne $getValue.Scope.'@odata.type')
            {
                $complexScope.Add('odataType', $getValue.Scope.'@odata.type')
            }

            if ($complexScope.odataType -ne '#microsoft.graph.accessReviewQueryScope')
            {
                $complexPrincipalScopes = @()
                foreach ($currentPrincipalScopes in $getValue.Scope.principalScopes)
                {
                    $myPrincipalScopes = [ordered]@{}
                    $myPrincipalScopes.Add('Query', $currentPrincipalScopes.query)
                    $myPrincipalScopes.Add('QueryRoot', $currentPrincipalScopes.queryRoot)
                    $myPrincipalScopes.Add('QueryType', $currentPrincipalScopes.queryType)
                    $myPrincipalScopes.Add('ScopeType', $currentPrincipalScopes.scopeType)
                    if ($null -ne $currentPrincipalScopes.'@odata.type')
                    {
                        $myPrincipalScopes.Add('odataType', $currentPrincipalScopes.'@odata.type')
                    }
                    if ($myPrincipalScopes.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexPrincipalScopes += $myPrincipalScopes
                    }
                }
                $complexScope.Add('PrincipalScopes', $complexPrincipalScopes)
                $complexResourceScopes = @()
                foreach ($currentResourceScopes in $getValue.Scope.resourceScopes)
                {
                    $myResourceScopes = [ordered]@{}
                    $myResourceScopes.Add('Query', $currentResourceScopes.query)
                    $myResourceScopes.Add('QueryRoot', $currentResourceScopes.queryRoot)
                    $myResourceScopes.Add('QueryType', $currentResourceScopes.queryType)
                    $myResourceScopes.Add('DisplayName', $currentResourceScopes.displayName)
                    $myResourceScopes.Add('ResourceScopeId', $currentResourceScopes.resourceId)
                    $myResourceScopes.Add('ScopeType', $currentResourceScopes.scopeType)
                    if ($null -ne $currentResourceScopes.'@odata.type')
                    {
                        $myResourceScopes.Add('odataType', $currentResourceScopes.'@odata.type')
                    }
                    if ($myResourceScopes.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexResourceScopes += $myResourceScopes
                    }
                }
                $complexScope.Add('ResourceScopes', $complexResourceScopes)
            }

            if ($complexScope.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexScope = $null
            }

            $complexInstanceEnumerationScope = $null
            if ($null -ne $getValue.InstanceEnumerationScope)
            {
                $complexInstanceEnumerationScope = [ordered]@{}
                $complexInstanceEnumerationScope.Add('Query', (($getValue.InstanceEnumerationScope.query -replace '\/v1.0', '') -replace '&\$count=true', ''))
                $complexInstanceEnumerationScope.Add('QueryType', $getValue.InstanceEnumerationScope.queryType)
            }

            $complexSettings = [ordered]@{}
            $complexApplyActions = @()
            foreach ($currentApplyActions in $getValue.Settings.applyActions)
            {
                $myApplyActions = [ordered]@{}
                if ($null -ne $currentApplyActions.'@odata.type')
                {
                    $myApplyActions.Add('odataType', $currentApplyActions.'@odata.type')
                }
                if ($myApplyActions.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexApplyActions += $myApplyActions
                }
            }
            $complexSettings.Add('ApplyActions', $complexApplyActions)
            $complexSettings.Add('AutoApplyDecisionsEnabled', $getValue.Settings.autoApplyDecisionsEnabled)
            $complexSettings.Add('DecisionHistoriesForReviewersEnabled', $getValue.Settings.decisionHistoriesForReviewersEnabled)
            $complexSettings.Add('DefaultDecision', $getValue.Settings.defaultDecision)
            $complexSettings.Add('DefaultDecisionEnabled', $getValue.Settings.defaultDecisionEnabled)
            $complexSettings.Add('InstanceDurationInDays', $getValue.Settings.instanceDurationInDays)
            $complexSettings.Add('JustificationRequiredOnApproval', $getValue.Settings.justificationRequiredOnApproval)
            $complexSettings.Add('MailNotificationsEnabled', $getValue.Settings.mailNotificationsEnabled)
            $complexRecommendationInsightSettings = @()
            foreach ($currentRecommendationInsightSettings in $getValue.Settings.recommendationInsightSettings)
            {
                $myRecommendationInsightSettings = [ordered]@{}
                $myRecommendationInsightSettings.Add('RecommendationLookBackDuration', $currentRecommendationInsightSettings.recommendationLookBackDuration)
                if ($null -ne $currentRecommendationInsightSettings.signInScope)
                {
                    $myRecommendationInsightSettings.Add('SignInScope', $currentRecommendationInsightSettings.signInScope)
                }
                if ($null -ne $currentRecommendationInsightSettings.'@odata.type')
                {
                    $myRecommendationInsightSettings.Add('odataType', $currentRecommendationInsightSettings.'@odata.type')
                }
                if ($myRecommendationInsightSettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexRecommendationInsightSettings += $myRecommendationInsightSettings
                }
            }
            $complexSettings.Add('RecommendationInsightSettings', $complexRecommendationInsightSettings)

            if ($null -ne $getValue.Settings.recommendationLookBackDuration)
            {
                $complexSettings.Add('RecommendationLookBackDuration', $getValue.Settings.recommendationLookBackDuration.ToString())
            }
            $complexSettings.Add('RecommendationsEnabled', $getValue.Settings.recommendationsEnabled)
            $complexRecurrence = [ordered]@{}
            $complexPattern = [ordered]@{}
            if ($getValue.settings.recurrence.pattern.type -in @('absoluteMonthly', 'absoluteYearly') -and $getValue.settings.recurrence.pattern.dayOfMonth -gt 0)
            {
                $complexPattern.Add('DayOfMonth', $getValue.settings.recurrence.pattern.dayOfMonth)
            }
            if ($null -ne $getValue.settings.recurrence.pattern.daysOfWeek -and $getValue.settings.recurrence.pattern.type -in @('weekly', 'relativeMonthly', 'relativeYearly'))
            {
                $complexPattern.Add('DaysOfWeek', $getValue.settings.recurrence.pattern.daysOfWeek)
            }
            if ($null -ne $getValue.settings.recurrence.pattern.firstDayOfWeek -and $getValue.settings.recurrence.pattern.type -eq 'weekly')
            {
                $complexFirstDaysOfWeek = [String]::Join(', ', $getValue.settings.recurrence.pattern.firstDayOfWeek)
                $complexPattern.Add('FirstDayOfWeek', $complexFirstDaysOfWeek)
            }
            if ($null -ne $getValue.settings.recurrence.pattern.index -and $getValue.settings.recurrence.pattern.type -in @('relativeMonthly', 'relativeYearly'))
            {
                $complexPattern.Add('Index', $getValue.settings.recurrence.pattern.index)
            }
            $complexPattern.Add('Interval', $getValue.settings.recurrence.pattern.interval)
            if ($getValue.settings.recurrence.pattern.month -gt 0)
            {
                $complexPattern.Add('Month', $getValue.settings.recurrence.pattern.month)
            }
            if ($null -ne $getValue.settings.recurrence.pattern.type)
            {
                $complexPattern.Add('Type', $getValue.settings.recurrence.pattern.type)
            }
            if ($complexPattern.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexPattern = $null
            }
            $complexRecurrence.Add('Pattern', $complexPattern)
            $complexRange = [ordered]@{}
            if ($null -ne $getValue.settings.recurrence.range.endDate -and $getValue.settings.recurrence.range.type -eq 'endDate')
            {
                $complexRange.Add('EndDate', ([DateTime]$getValue.settings.recurrence.range.endDate).ToString('o'))
            }
            $complexRange.Add('NumberOfOccurrences', $getValue.settings.recurrence.range.numberOfOccurrences)
            $complexRange.Add('RecurrenceTimeZone', $getValue.settings.recurrence.range.recurrenceTimeZone)
            if ($null -ne $getValue.settings.recurrence.range.startDate)
            {
                $complexRange.Add('StartDate', ([DateTime]$getValue.settings.recurrence.range.startDate).ToString('o') + 'Z')
            }
            if ($null -ne $getValue.settings.recurrence.range.type)
            {
                $complexRange.Add('Type', $getValue.settings.recurrence.range.type)
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
            $complexSettings.Add('Recurrence', $complexRecurrence)
            $complexSettings.Add('ReminderNotificationsEnabled', $getValue.Settings.reminderNotificationsEnabled)
            if ($complexSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexSettings = $null
            }

            $complexStageSettings = @()
            foreach ($currentStageSettings in $getValue.stageSettings)
            {
                $myStageSettings = [ordered]@{}
                $myStageSettings.Add('DecisionsThatWillMoveToNextStage', $currentStageSettings.decisionsThatWillMoveToNextStage)
                $myStageSettings.Add('DependsOnValue', $currentStageSettings.dependsOn)
                $myStageSettings.Add('DurationInDays', $currentStageSettings.durationInDays)
                $complexRecommendationInsightSettings = @()
                foreach ($currentRecommendationInsightSettings in $currentStageSettings.recommendationInsightSettings)
                {
                    $myRecommendationInsightSettings = [ordered]@{}
                    if ($null -ne $currentRecommendationInsightSettings.recommendationLookBackDuration)
                    {
                        $myRecommendationInsightSettings.Add('RecommendationLookBackDuration', $currentRecommendationInsightSettings.recommendationLookBackDuration.ToString())
                    }
                    if ($null -ne $currentRecommendationInsightSettings.signInScope)
                    {
                        $myRecommendationInsightSettings.Add('SignInScope', $currentRecommendationInsightSettings.signInScope)
                    }
                    if ($null -ne $currentRecommendationInsightSettings.'@odata.type')
                    {
                        $myRecommendationInsightSettings.Add('odataType', $currentRecommendationInsightSettings.'@odata.type')
                    }
                    if ($myRecommendationInsightSettings.values.Where({ $null -ne $_ }).Count -gt 0)
                    {
                        $complexRecommendationInsightSettings += $myRecommendationInsightSettings
                    }
                }
                $myStageSettings.Add('RecommendationInsightSettings', $complexRecommendationInsightSettings)
                $myStageSettings.Add('RecommendationLookBackDuration', $currentStageSettings.recommendationLookBackDuration)
                $myStageSettings.Add('RecommendationsEnabled', $currentStageSettings.recommendationsEnabled)
                $myStageSettings.Add('StageId', $currentStageSettings.stageId)
                if ($myStageSettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexStageSettings += $myStageSettings
                }
            }

            $complexFallbackReviewers = @()
            if ($getValue.FallbackReviewers.Count -gt 0)
            {
                $allQueries = $getValue.FallbackReviewers.Query
                if ($allQueries.Count -gt 0)
                {
                    $batchRequests = @()
                    foreach ($query in $allQueries)
                    {
                        $batchRequests += @{
                            id     = $query
                            method = 'GET'
                            url    = $query.Replace('/v1.0', '').Replace('transitiveMembers/microsoft.graph.user', '')
                        }
                    }
                    Write-Verbose -Message "Invoking BATCH request to resolve Fallback Reviewers from Get(): $(ConvertTo-Json $batchRequests -Depth 10)"
                    $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
                }

                foreach ($currentFallbackReviewer in $getValue.FallbackReviewers)
                {
                    $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentFallbackReviewer.Query }
                    switch ($currentFallbackReviewer.Query)
                    {
                        { $_ -like '*users*' }
                        {
                            $reviewerType = 'User'
                        }
                        { $_ -like '*groups*' }
                        {
                            $reviewerType = 'Group'
                        }
                    }
                    $myFallbackReviewer = [ordered]@{}
                    $myFallbackReviewer.Add('DisplayName', $currentQuery.body.displayName)
                    $myFallbackReviewer.Add('ScopeType', $currentFallbackReviewer.scopeType)
                    $myFallbackReviewer.Add('Type', $reviewerType)
                    $complexFallbackReviewers += $myFallbackReviewer
                }
            }

            $complexAdditionalNotificationRecipients = @()
            if ($getValue.AdditionalNotificationRecipients.Count -gt 0)
            {
                $allQueries = $getValue.AdditionalNotificationRecipients.NotificationRecipientScope.Query
                if ($allQueries.Count -gt 0)
                {
                    $batchRequests = @()
                    foreach ($query in $allQueries)
                    {
                        $batchRequests += @{
                            id     = $query
                            method = 'GET'
                            url    = $query.Replace('/v1.0', '').Replace('transitiveMembers/microsoft.graph.user', '')
                        }
                    }
                    Write-Verbose -Message "Invoking BATCH request to resolve Additional Notification Recipients from Get(): $(ConvertTo-Json $batchRequests -Depth 10)"
                    $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
                }

                foreach ($currentAdditionalNotificationRecipient in $getValue.AdditionalNotificationRecipients)
                {
                    $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentAdditionalNotificationRecipient.NotificationRecipientScope.Query }
                    switch ($currentAdditionalNotificationRecipient.NotificationRecipientScope.Query)
                    {
                        { $_ -like '*users*' }
                        {
                            $reviewerType = 'User'
                        }
                        { $_ -like '*groups*' }
                        {
                            $reviewerType = 'Group'
                        }
                    }
                    $myAdditionalNotificationRecipient = [ordered]@{}
                    $myAdditionalNotificationRecipient.Add('DisplayName', $currentQuery.body.displayName)
                    $myAdditionalNotificationRecipient.Add('Type', $reviewerType)
                    $complexAdditionalNotificationRecipients += $myAdditionalNotificationRecipient
                }
            }

            $complexReviewers = @()
            $allQueries = $getValue.Reviewers.Query
            $batchRequests = @()
            foreach ($query in $($allQueries | Where-Object { $_ -notlike "*manager*" -and -not [System.String]::IsNullOrEmpty($_) }))
            {
                if ($query -like '*manager*')
                {
                    continue
                }
                $batchRequests += @{
                    id     = $query
                    method = 'GET'
                    url    = $query.Replace('/v1.0', '').Replace('transitiveMembers/microsoft.graph.user', '').Replace('owners', '')
                }
            }
            if ($batchRequests.Count -gt 0)
            {
                Write-Verbose -Message "Invoking BATCH request to resolve Reviewers from Get(): $(ConvertTo-Json $batchRequests -Depth 10)"
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }

            foreach ($currentReviewer in $getValue.Reviewers)
            {
                $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentReviewer.Query }
                switch ($currentReviewer.Query)
                {
                    { $_ -like '*manager*' }
                    {
                        $reviewerType = 'Manager'
                    }
                    { $_ -like '*users*' }
                    {
                        $reviewerType = 'User'
                    }
                    { $_ -like '*groups*' }
                    {
                        $reviewerType = 'Group'
                    }
                    { $_ -like '*/owners' }
                    {
                        $reviewerType = 'Owner'
                    }
                }
                $myReviewer = [ordered]@{}
                $myReviewer.Add('DisplayName', $currentQuery.body.displayName)
                $myReviewer.Add('ScopeType', $currentReviewer.scopeType)
                $myReviewer.Add('Type', $reviewerType)
                $complexReviewers += $myReviewer
            }
            #endregion

            $results = @{
                AdditionalNotificationRecipients = $complexAdditionalNotificationRecipients
                DescriptionForAdmins             = $getValue.DescriptionForAdmins
                DescriptionForReviewers          = $getValue.DescriptionForReviewers
                DisplayName                      = $getValue.DisplayName
                FallbackReviewers                = $complexFallbackReviewers
                InstanceEnumerationScope         = $complexInstanceEnumerationScope
                Reviewers                        = $complexReviewers
                ScopeValue                       = $complexScope
                Settings                         = $complexSettings
                StageSettings                    = $complexStageSettings
                Id                               = $getValue.Id
                Ensure                           = 'Present'
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                TenantId                         = $this.TenantId
                ApplicationSecret                = $this.ApplicationSecret
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                AccessTokens                     = $this.AccessTokens
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
        $reviewerType = $null
        $batchResponses = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Access Review Definition '$($this.DisplayName)'"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('AdditionalNotificationRecipients'))
        {
            $batchRequests = @()
            foreach ($currentRecipient in $this.AdditionalNotificationRecipients)
            {
                if ($currentRecipient.Type -eq 'User')
                {
                    $reviewerType = 'users'
                }
                elseif ($currentRecipient.Type -eq 'Group')
                {
                    $reviewerType = 'groups'
                }
                $filterValue = "displayName eq '$($currentRecipient.DisplayName -replace "'", "''")'"
                $batchRequests += @{
                    id     = $currentRecipient.DisplayName
                    method = 'GET'
                    url    = "/$($reviewerType)?`$filter=$($filterValue)"
                }
            }
            if ($batchRequests.Count -gt 0)
            {
                Write-Verbose -Message "Invoking BATCH request to resolve AdditionalNotificationRecipients: $(ConvertTo-Json $batchRequests -Depth 10)"
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }
            $newAdditionalNotificationRecipients = @()
            foreach ($currentRecipient in $this.AdditionalNotificationRecipients)
            {
                $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentRecipient.DisplayName }
                if ($currentRecipient.Type -eq 'User')
                {
                    $reviewerType = 'users'
                }
                elseif ($currentRecipient.Type -eq 'Group')
                {
                    $reviewerType = 'groups'
                }
                if ($null -ne $currentQuery)
                {
                    $append = $null
                    if ($reviewerType -eq 'groups')
                    {
                        $append = '/transitiveMembers'
                    }
                    $myAdditionalRecipient = @{
                        notificationRecipientScope = @{
                            '@odata.type' = '#microsoft.graph.accessReviewNotificationRecipientQueryScope'
                            query         = "/$reviewerType/$($currentQuery.body.value.id)$append"
                            queryType     = 'MicrosoftGraph'
                        }
                        notificationTemplateType = 'CompletedAdditionalRecipients'
                    }
                    $newAdditionalNotificationRecipients += $myAdditionalRecipient
                }
            }
            $boundParameters.Remove('AdditionalNotificationRecipients') | Out-Null
            $boundParameters.Add('additionalNotificationRecipients', $newAdditionalNotificationRecipients)
        }

        if ($boundParameters.ContainsKey('FallbackReviewers'))
        {
            $batchRequests = @()
            foreach ($currentFallbackReviewer in $this.FallbackReviewers)
            {
                if ($currentFallbackReviewer.Type -eq 'User')
                {
                    $reviewerType = 'users'
                }
                elseif ($currentFallbackReviewer.Type -eq 'Group')
                {
                    $reviewerType = 'groups'
                }
                $filterValue = "displayName eq '$($currentFallbackReviewer.DisplayName -replace "'", "''")'"
                $batchRequests += @{
                    id     = $currentFallbackReviewer.DisplayName
                    method = 'GET'
                    url    = "/$($reviewerType)?`$filter=$($filterValue)"
                }
            }
            if ($batchRequests.Count -gt 0)
            {
                Write-Verbose -Message "Invoking BATCH request to resolve FallbackReviewers: $(ConvertTo-Json $batchRequests -Depth 10)"
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }
            $newFallbackReviewers = @()
            foreach ($currentFallbackReviewer in $this.FallbackReviewers)
            {
                $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentFallbackReviewer.DisplayName }
                if ($currentFallbackReviewer.Type -eq 'User')
                {
                    $reviewerType = 'users'
                }
                elseif ($currentFallbackReviewer.Type -eq 'Group')
                {
                    $reviewerType = 'groups'
                }
                if ($null -ne $currentQuery)
                {
                    $append = $null
                    if ($reviewerType -eq 'groups')
                    {
                        $append = '/transitiveMembers'
                    }
                    $myFallbackReviewer = @{
                        query     = "/$reviewerType/$($currentQuery.body.value.id)$append"
                        queryType = 'MicrosoftGraph'
                    }
                    $newFallbackReviewers += $myFallbackReviewer
                }
            }
            $boundParameters.Remove('FallbackReviewers') | Out-Null
            $boundParameters.Add('fallbackReviewers', $newFallbackReviewers)
        }

        if ($boundParameters.ContainsKey('Reviewers'))
        {
            $batchRequests = @()
            foreach ($currentReviewer in $this.Reviewers)
            {
                if ($currentReviewer.Type -eq 'Manager' -or $currentReviewer.ScopeType -in @('Manager', 'ResourceOwner'))
                {
                    continue
                }

                switch ($currentReviewer.Type)
                {
                    'User'
                    {
                        $reviewerType = 'users'
                    }
                    'Group'
                    {
                        $reviewerType = 'groups'
                    }
                    'Owner'
                    {
                        $reviewerType = 'groups'
                    }
                }
                if (-not [System.String]::IsNullOrEmpty($currentReviewer.DisplayName))
                {
                    $filterValue = "displayName eq '$($currentReviewer.DisplayName -replace "'", "''")'"
                    $batchRequests += @{
                        id     = $currentReviewer.DisplayName
                        method = 'GET'
                        url    = "/$($reviewerType)?`$filter=$($filterValue)"
                    }
                }
            }
            if ($batchRequests.Count -gt 0)
            {
                Write-Verbose -Message "Invoking BATCH request to resolve Reviewers: $(ConvertTo-Json $batchRequests -Depth 10)"
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            }
            $newReviewers = @()
            foreach ($currentReviewer in $this.Reviewers)
            {
                Write-Verbose "Checking reviewer $($currentReviewer.DisplayName) of type $($currentReviewer.Type) with scope type $($currentReviewer.ScopeType)"
                $currentQuery = $batchResponses | Where-Object { $_.id -eq $currentReviewer.DisplayName }
                switch ($currentReviewer.Type)
                {
                    'User'
                    {
                        $reviewerType = 'users'
                    }
                    'Group'
                    {
                        $reviewerType = 'groups'
                    }
                    'Owner'
                    {
                        $reviewerType = 'groups'
                    }
                }
                if ($null -ne $currentQuery)
                {
                    $append = $null
                    if ($reviewerType -eq 'groups')
                    {
                        $append = '/transitiveMembers/microsoft.graph.user'
                    }
                    elseif ($currentReviewer.Type -eq 'Owner')
                    {
                        $append = '/owners'
                    }
                    $myReviewer = @{
                        query     = "/v1.0/$reviewerType/$($currentQuery.body.value.id)$append"
                        queryType = 'MicrosoftGraph'
                    }
                    $newReviewers += $myReviewer
                }
                else
                {
                    if ($currentReviewer.Type -eq 'Manager')
                    {
                        $myReviewer = @{
                            queryType = 'MicrosoftGraph'
                            query = './manager'
                            queryRoot = 'decisions'
                        }
                        $newReviewers += $myReviewer
                    }
                }
            }
            $boundParameters.Remove('Reviewers') | Out-Null
            $boundParameters.Add('reviewers', $newReviewers)
        }

        if ($boundParameters.ScopeValue.odataType -eq '#microsoft.graph.accessReviewQueryScope')
        {
            $boundParameters.ScopeValue = @{
                '@odata.type' = '#microsoft.graph.accessReviewQueryScope'
                query     = $boundParameters.ScopeValue.Query
                queryType = $boundParameters.ScopeValue.QueryType
            }
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters
        $boundParameters.Remove('Id') | Out-Null

        foreach ($scope in $boundParameters.ScopeValue.ResourceScopes)
        {
            if ($scope.ContainsKey('ResourceScopeId'))
            {
                $scope.Add('resourceId', $scope.ResourceScopeId)
                $scope.Remove('ResourceScopeId') | Out-Null
            }
        }
        $boundParameters.Add('scope', $boundParameters.ScopeValue)
        $boundParameters.Remove('ScopeValue') | Out-Null

        $settingsPayload = $boundParameters.Settings
        $boundParameters.Remove('Settings') | Out-Null
        $boundParameters.Add('settings', $settingsPayload)

        if ($null -ne $this.StageSettings)
        {
            Write-Verbose -Message 'StageSettings cannot be updated after creation of access review definition.'

            if ($currentInstance.Ensure -ne 'Absent')
            {
                Write-Verbose -Message "Removing the Azure AD Access Review Definition with Id {$($currentInstance.Id)}"
                Remove-MgBetaIdentityGovernanceAccessReviewDefinition -AccessReviewScheduleDefinitionId $currentInstance.Id
            }

            Write-Verbose -Message "Creating an Azure AD Access Review Definition with DisplayName {$($this.DisplayName)}"

            $createParameters = ([Hashtable]$boundParameters).Clone()
            foreach ($hashtable in $createParameters.StageSettings)
            {
                $propertyToRemove = 'DependsOnValue'
                $newProperty = 'dependsOn'
                if ($hashtable.ContainsKey($propertyToRemove))
                {
                    $value = $hashtable[$propertyToRemove]
                    $hashtable[$newProperty] = $value
                    $hashtable.Remove($propertyToRemove)
                }
            }

            foreach ($hashtable in $createParameters.StageSettings)
            {
                $keys = (([Hashtable]$hashtable).Clone()).Keys
                foreach ($key in $keys)
                {
                    $value = $hashtable.$key
                    $hashtable.Remove($key)
                    $hashtable.Add($key.Substring(0, 1).ToLower() + $key.Substring(1), $value)
                }
            }

            #$createParameters.Add('@odata.type', '#microsoft.graph.AccessReviewScheduleDefinition')
            Write-Verbose -Message "Creating an Azure AD Access Review Definition with: $(ConvertTo-Json $createParameters -Depth 10)"
            $policy = New-MgBetaIdentityGovernanceAccessReviewDefinition -BodyParameter $createParameters
            return
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Access Review Definition with DisplayName {$($this.DisplayName)}"

            $createParameters = ([Hashtable]$boundParameters).Clone()
            foreach ($hashtable in $createParameters.StageSettings)
            {
                $propertyToRemove = 'DependsOnValue'
                $newProperty = 'dependsOn'
                if ($hashtable.ContainsKey($propertyToRemove))
                {
                    $value = $hashtable[$propertyToRemove]
                    $hashtable[$newProperty] = $value
                    $hashtable.Remove($propertyToRemove)
                }
            }

            foreach ($hashtable in $createParameters.StageSettings)
            {
                $keys = (([Hashtable]$hashtable).Clone()).Keys
                foreach ($key in $keys)
                {
                    $value = $hashtable.$key
                    $hashtable.Remove($key)
                    $hashtable.Add($key.Substring(0, 1).ToLower() + $key.Substring(1), $value)
                }
            }

            #region resource generator code
            #$createParameters.Add('@odata.type', '#microsoft.graph.AccessReviewScheduleDefinition')
            Write-Verbose -Message "Creating an Azure AD Access Review Definition with: $(ConvertTo-Json $createParameters -Depth 10)"
            $policy = New-MgBetaIdentityGovernanceAccessReviewDefinition -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Access Review Definition with Id {$($currentInstance.Id)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()

            #region resource generator code
            #$updateParameters.Add('@odata.type', '#microsoft.graph.AccessReviewScheduleDefinition')
            Write-Verbose -Message "Updating Azure AD Access Review Definition {$($currentInstance.Id)} with: $(ConvertTo-Json $updateParameters -Depth 10)"
            Set-MgBetaIdentityGovernanceAccessReviewDefinition `
                -AccessReviewScheduleDefinitionId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Access Review Definition with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaIdentityGovernanceAccessReviewDefinition -AccessReviewScheduleDefinitionId $currentInstance.Id
            #endregion
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

        try
        {
            #region resource generator code
            [array]$getValue = Get-MgBetaIdentityGovernanceAccessReviewDefinition `
                -Filter $this.Filter `
                -All `
                -Top 100 `
                -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
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

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
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
                if ($null -ne $Results.ScopeValue)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ScopeValue'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'PrincipalScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewPrincipalScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ResourceScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewResourceScope'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ScopeValue `
                        -CIMInstanceName 'MicrosoftGraphaccessReviewScope' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ScopeValue = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ScopeValue') | Out-Null
                    }
                }
                if ($null -ne $Results.InstanceEnumerationScope)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'InstanceEnumerationScope'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.InstanceEnumerationScope `
                        -CIMInstanceName 'MicrosoftGraphAccessReviewScope2' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.InstanceEnumerationScope = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('InstanceEnumerationScope') | Out-Null
                    }
                }
                if ($null -ne $Results.Settings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Settings'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScheduleSettings'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ApplyActions'
                            CimInstanceName = 'MicrosoftGraphAccessReviewApplyAction'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RecommendationInsightSettings'
                            CimInstanceName = 'MicrosoftGraphAccessReviewRecommendationInsightSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Recurrence'
                            CimInstanceName = 'MicrosoftGraphPatternedRecurrence'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Pattern'
                            CimInstanceName = 'MicrosoftGraphRecurrencePattern'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Range'
                            CimInstanceName = 'MicrosoftGraphRecurrenceRange'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Settings `
                        -CIMInstanceName 'MicrosoftGraphAccessReviewScheduleSettings' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Settings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Settings') | Out-Null
                    }
                }
                if ($null -ne $Results.StageSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'StageSettings'
                            CimInstanceName = 'MicrosoftGraphAccessReviewStageSettings'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'PrincipalScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ResourceScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'RecommendationInsightSettings'
                            CimInstanceName = 'MicrosoftGraphAccessReviewRecommendationInsightSetting'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'PrincipalScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ResourceScopes'
                            CimInstanceName = 'MicrosoftGraphAccessReviewScope'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.StageSettings `
                        -CIMInstanceName 'MicrosoftGraphaccessReviewStageSettings' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.StageSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('StageSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.AdditionalNotificationRecipients)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AdditionalNotificationRecipients `
                        -CIMInstanceName 'AADAccessReviewDefinitionReviewer'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AdditionalNotificationRecipients = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AdditionalNotificationRecipients') | Out-Null
                    }
                }
                if ($null -ne $Results.FallbackReviewers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FallbackReviewers `
                        -CIMInstanceName 'AADAccessReviewDefinitionReviewer'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FallbackReviewers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FallbackReviewers') | Out-Null
                    }
                }
                if ($null -ne $Results.Reviewers)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Reviewers `
                        -CIMInstanceName 'AADAccessReviewDefinitionReviewer'

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Reviewers = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Reviewers') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ScopeValue', 'InstanceEnumerationScope', 'Settings', 'StageSettings', 'AdditionalNotificationRecipients', 'FallbackReviewers', 'Reviewers')

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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if (-not [System.String]::IsNullOrEmpty($DesiredValues.Settings.Recurrence.Range.StartDate))
                {
                    $parsedDesiredDate = [System.DateTime]::MinValue
                    $parseResultDesired = [System.DateTime]::TryParse($DesiredValues.Settings.Recurrence.Range.StartDate, [ref]$parsedDesiredDate)

                    $parsedCurrentDate = [System.DateTime]::MinValue
                    $parseResultCurrent = [System.DateTime]::TryParse($CurrentValues.Settings.Recurrence.Range.StartDate, [ref]$parsedCurrentDate)

                    if ($parseResultDesired -and $parseResultCurrent)
                    {
                        Write-Verbose -Message "Parsed Desired StartDateTime: $parsedDesiredDate, Parsed Current StartDateTime: $parsedCurrentDate"
                        if ($parsedDesiredDate -ne $parsedCurrentDate -and $parsedDesiredDate -lt [System.DateTime]::Now)
                        {
                            Write-Verbose -Message 'Ignoring StartDateTime in ScheduleInfo as it is in the past. StartDateTime cannot be set to a past date.'
                            Write-Verbose -Message 'Aligning the Desired and Current StartDateTime values for comparison.'
                            $DesiredValues.Settings.Recurrence.Range.StartDate = $CurrentValues.Settings.Recurrence.Range.StartDate
                        }
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [AADAccessReviewDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAccessReviewDefinition])
        {
            return $Values
        }

        $result = [AADAccessReviewDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADAccessReviewDefinitionReviewer
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicates the display name of the current reviewer, either of a group or of a user.')]
    [System.String] $DisplayName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Indicates the type of reviewer. Possible values: Manager, Owner, User, Group')]
    [ValidateSet('Manager', 'Owner', 'User', 'Group')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of reviewer. Possible values: User, Group, Self, Manager, Sponsor, ResourceOwner, ManagerOrSponsor')]
    [ValidateSet('User', 'Group', 'Self', 'Manager', 'Sponsor', 'ResourceOwner', 'ManagerOrSponsor')]
    [System.String] $ScopeType
}

class MSFT_MicrosoftGraphAccessReviewScope2
{
    [DscProperty()]
    [System.ComponentModel.Description('The query representing what will be reviewed in an access review.')]
    [System.String] $Query

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of query. Types include MicrosoftGraph and ARM.')]
    [System.String] $QueryType
}

class MSFT_MicrosoftGraphaccessReviewScope
{
    [DscProperty()]
    [System.ComponentModel.Description('The query representing what will be reviewed in an access review.')]
    [System.String] $Query

    [DscProperty()]
    [System.ComponentModel.Description('In the scenario where reviewers need to be specified dynamically, this property is used to indicate the relative source of the query. This property is only required if a relative query is specified. For example, ./manager.')]
    [System.String] $QueryRoot

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of query. Types include MicrosoftGraph and ARM.')]
    [System.String] $QueryType

    [DscProperty()]
    [System.ComponentModel.Description('Defines the scopes of the principals for which access to resources are reviewed in the access review.')]
    [MSFT_MicrosoftGraphAccessReviewPrincipalScope[]] $PrincipalScopes

    [DscProperty()]
    [System.ComponentModel.Description('Defines the scopes of the resources for which access is reviewed.')]
    [MSFT_MicrosoftGraphAccessReviewResourceScope[]] $ResourceScopes

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.accessReviewQueryScope', '#microsoft.graph.accessReviewReviewerScope', '#microsoft.graph.principalResourceMembershipsScope', '#microsoft.graph.accessReviewInactiveUsersQueryScope')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphaccessReviewScheduleSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Optional field. Describes the  actions to take once a review is complete. There are two types that are currently supported: removeAccessApplyAction (default) and disableAndDeleteUserApplyAction. Field only needs to be specified in the case of disableAndDeleteUserApplyAction.')]
    [MSFT_MicrosoftGraphAccessReviewApplyAction[]] $ApplyActions

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether decisions are automatically applied. When set to false, an admin must apply the decisions manually once the reviewer completes the access review. When set to true, decisions are applied automatically after the access review instance duration ends, whether or not the reviewers have responded. Default value is false.  CAUTION: If both autoApplyDecisionsEnabled and defaultDecisionEnabled are true, all access for the principals to the resource risks being revoked if the reviewers fail to respond.')]
    [System.Nullable[System.Boolean]] $AutoApplyDecisionsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether decisions on previous access review stages are available for reviewers on an accessReviewInstance with multiple subsequent stages. If not provided, the default is disabled (false).')]
    [System.Nullable[System.Boolean]] $DecisionHistoriesForReviewersEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Decision chosen if defaultDecisionEnabled is enabled. Can be one of Approve, Deny, or Recommendation.')]
    [System.String] $DefaultDecision

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether the default decision is enabled or disabled when reviewers do not respond. Default value is false.  CAUTION: If both autoApplyDecisionsEnabled and defaultDecisionEnabled are true, all access for the principals to the resource risks being revoked if the reviewers fail to respond.')]
    [System.Nullable[System.Boolean]] $DefaultDecisionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Duration of each recurrence of review (accessReviewInstance) in number of days. NOTE: If the stageSettings of the accessReviewScheduleDefinition object is defined, its durationInDays setting will be used instead of the value of this property.')]
    [System.Nullable[System.UInt32]] $InstanceDurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether reviewers are required to provide justification with their decision. Default value is false.')]
    [System.Nullable[System.Boolean]] $JustificationRequiredOnApproval

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether emails are enabled or disabled. Default value is false.')]
    [System.Nullable[System.Boolean]] $MailNotificationsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Optional. Describes the types of insights that aid reviewers to make access review decisions. NOTE: If the stageSettings of the accessReviewScheduleDefinition object is defined, its recommendationInsightSettings setting will be used instead of the value of this property.')]
    [MSFT_MicrosoftGraphAccessReviewRecommendationInsightSetting[]] $RecommendationInsightSettings

    [DscProperty()]
    [System.ComponentModel.Description('Optional field. Indicates the period of inactivity (with respect to the start date of the review instance) that recommendations will be configured from. The recommendation will be to deny if the user is inactive during the look-back duration. For reviews of groups and Microsoft Entra roles, any duration is accepted. For reviews of applications, 30 days is the maximum duration. If not specified, the duration is 30 days. NOTE: If the stageSettings of the accessReviewScheduleDefinition object is defined, its recommendationLookBackDuration setting will be used instead of the value of this property.')]
    [System.String] $RecommendationLookBackDuration

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether decision recommendations are enabled or disabled. NOTE: If the stageSettings of the accessReviewScheduleDefinition object is defined, its recommendationsEnabled setting will be used instead of the value of this property.')]
    [System.Nullable[System.Boolean]] $RecommendationsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Detailed settings for recurrence using the standard Outlook recurrence object. Note: Only dayOfMonth, interval, and type (weekly, absoluteMonthly) properties are supported. Use the property startDate on recurrenceRange to determine the day the review starts.')]
    [MSFT_MicrosoftGraphPatternedRecurrence] $Recurrence

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether reminders are enabled or disabled. Default value is false.')]
    [System.Nullable[System.Boolean]] $ReminderNotificationsEnabled
}

class MSFT_MicrosoftGraphaccessReviewStageSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('Indicate which decisions will go to the next stage. Can be a subset of Approve, Deny, Recommendation, or NotReviewed. If not provided, all decisions will go to the next stage. Optional.')]
    [System.String[]] $DecisionsThatWillMoveToNextStage

    [DscProperty()]
    [System.ComponentModel.Description('Defines the sequential or parallel order of the stages and depends on the stageId. Only sequential stages are currently supported. For example, if stageId is 2, then dependsOn must be 1. If stageId is 1, don''t specify dependsOn. Required if stageId isn''t 1.')]
    [System.String[]] $DependsOnValue

    [DscProperty()]
    [System.ComponentModel.Description('The duration of the stage. Required.  NOTE: The cumulative value of this property across all stages  1. Will override the instanceDurationInDays setting on the accessReviewScheduleDefinition object. 2. Can''t exceed the length of one recurrence. That is, if the review recurs weekly, the cumulative durationInDays can''t exceed 7.')]
    [System.Nullable[System.UInt32]] $DurationInDays

    [DscProperty()]
    [System.ComponentModel.Description('Recommendation Insights Settings')]
    [MSFT_MicrosoftGraphAccessReviewRecommendationInsightSetting[]] $RecommendationInsightSettings

    [DscProperty()]
    [System.ComponentModel.Description('Optional field. Indicates the time period of inactivity (with respect to the start date of the review instance) from which that recommendations will be configured. The recommendation is to deny if the user is inactive during the look back duration. For reviews of groups and Microsoft Entra roles, any duration is accepted. For reviews of applications, 30 days is the maximum duration. If not specified, the duration is 30 days. NOTE: The value of this property overrides the corresponding setting on the accessReviewScheduleDefinition object.')]
    [System.String] $RecommendationLookBackDuration

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Indicates whether showing recommendations to reviewers is enabled. Required. NOTE: The value of this property overrides the corresponding setting on the accessReviewScheduleDefinition object.')]
    [System.Nullable[System.Boolean]] $RecommendationsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the accessReviewStageSettings. The stageId is used in dependsOn property to indicate the stage relationship. Required.')]
    [System.String] $StageId
}

class MSFT_MicrosoftGraphAccessReviewPrincipalScope
{
    [DscProperty()]
    [System.ComponentModel.Description('The query representing what will be reviewed in an access review.')]
    [System.String] $Query

    [DscProperty()]
    [System.ComponentModel.Description('In the scenario where reviewers need to be specified dynamically, this property is used to indicate the relative source of the query. This property is only required if a relative query is specified. For example, ./manager.')]
    [System.String] $QueryRoot

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of query. Types include MicrosoftGraph and ARM.')]
    [System.String] $QueryType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.accessReviewPrincipalScope', '#microsoft.graph.accessReviewQueryScope')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of users to include in the review. The possible values are: allUsers, guestUsers, inactiveUsers, inactiveGuestUsers.')]
    [ValidateSet('allUsers', 'guestUsers', 'inactiveUsers', 'inactiveGuestUsers')]
    [System.String] $scopeType
}

class MSFT_MicrosoftGraphAccessReviewResourceScope
{
    [DscProperty()]
    [System.ComponentModel.Description('The query representing what will be reviewed in an access review.')]
    [System.String] $Query

    [DscProperty()]
    [System.ComponentModel.Description('In the scenario where reviewers need to be specified dynamically, this property is used to indicate the relative source of the query. This property is only required if a relative query is specified. For example, ./manager.')]
    [System.String] $QueryRoot

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the type of query. Types include MicrosoftGraph and ARM.')]
    [System.String] $QueryType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.accessReviewResourceScope', '#microsoft.graph.accessReviewQueryScope')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the resource.')]
    [System.String] $displayName

    [DscProperty()]
    [System.ComponentModel.Description('The identifier of the resource.')]
    [System.String] $resourceScopeId

    [DscProperty()]
    [System.ComponentModel.Description('The type of users to include in the review. The possible values are: group, catalog, servicePrincipal, directoryRole, accessPackageAssignmentPolicy.')]
    [ValidateSet('group', 'catalog', 'servicePrincipal', 'directoryRole', 'accessPackageAssignmentPolicy')]
    [System.String] $scopeType
}

class MSFT_MicrosoftGraphAccessReviewApplyAction
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.disableAndDeleteUserApplyAction', '#microsoft.graph.removeAccessApplyAction')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphAccessReviewRecommendationInsightSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Optional. Indicates the time period of inactivity (with respect to the start date of the review instance) that recommendations will be configured from. The recommendation will be to deny if the user is inactive during the look-back duration. For reviews of groups and Microsoft Entra roles, any duration is accepted. For reviews of applications, 30 days is the maximum duration. If not specified, the duration is 30 days.')]
    [System.String] $RecommendationLookBackDuration

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether inactivity is calculated based on the user''s inactivity in the tenant or in the application. The possible values are tenant, application, unknownFutureValue. application is only relevant when the access review is a review of an assignment to an application.')]
    [ValidateSet('tenant', 'application', 'unknownFutureValue')]
    [System.String] $SignInScope

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.groupPeerOutlierRecommendationInsightSettings', '#microsoft.graph.userLastSignInRecommendationInsightSetting')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphPatternedRecurrence
{
    [DscProperty()]
    [System.ComponentModel.Description('The frequency of an event. Do not specify for a one-time access review.  For access reviews: Do not specify this property for a one-time access review.   Only interval, dayOfMonth, and type (weekly, absoluteMonthly) properties of recurrencePattern are supported.')]
    [MSFT_MicrosoftGraphRecurrencePattern] $Pattern

    [DscProperty()]
    [System.ComponentModel.Description('The duration of an event.')]
    [MSFT_MicrosoftGraphRecurrenceRange] $Range
}

class MSFT_MicrosoftGraphRecurrencePattern
{
    [DscProperty()]
    [System.ComponentModel.Description('The day of the month on which the event occurs. Required if type is absoluteMonthly or absoluteYearly.')]
    [System.Nullable[System.UInt32]] $DayOfMonth

    [DscProperty()]
    [System.ComponentModel.Description('A collection of the days of the week on which the event occurs. The possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday. If type is relativeMonthly or relativeYearly, and daysOfWeek specifies more than one day, the event falls on the first day that satisfies the pattern.  Required if type is weekly, relativeMonthly, or relativeYearly.')]
    [System.String[]] $DaysOfWeek

    [DscProperty()]
    [System.ComponentModel.Description('The first day of the week. The possible values are: sunday, monday, tuesday, wednesday, thursday, friday, saturday. Default is sunday. Required if type is weekly.')]
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
