using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PlannerTask : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the Planner Plan which contains the Task.')]
    [System.String] $PlanId

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Title of the Planner Task.')]
    [System.String] $Title

    [DscProperty()]
    [System.ComponentModel.Description('List of categories assigned to the task.')]
    [System.String[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('List of users assigned to the tasks (ex: @(''john.smith@contoso.com'', ''bob.houle@contoso.com'')).')]
    [System.String[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('List of links to attachments assigned to the task.')]
    [MSFT_PlannerTaskAttachment[]] $Attachments

    [DscProperty()]
    [System.ComponentModel.Description('List checklist items associated with the task.')]
    [MSFT_PlannerTaskChecklistItem[]] $Checklist

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Task.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the bucket that contains the task.')]
    [System.String] $BucketId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Task, if known.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Date and Time for the start of the Task.')]
    [System.String] $StartDateTime

    [DscProperty()]
    [System.ComponentModel.Description('Date and Time for the task is due for completion.')]
    [System.String] $DueDateTime

    [DscProperty()]
    [System.ComponentModel.Description('Percentage completed of the Task. Value can only be between 0 and 100.')]
    [ValidateRange(0, 100)]
    [System.Nullable[System.UInt32]] $PercentComplete

    [DscProperty()]
    [System.ComponentModel.Description('Priority of the Task. Value can only be between 1 and 10.')]
    [ValidateRange(0, 10)]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Id of the group conversation thread associated with the comments section for this task.')]
    [System.String] $ConversationThreadId

    [DscProperty()]
    [System.ComponentModel.Description('This sets the type of preview that shows up on the task. The possible values are: automatic, noPreview, checklist, description, reference.')]
    [ValidateSet('automatic', 'noPreview', 'checklist', 'description', 'reference')]
    [System.String] $PreviewType

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Plan exists, absent ensures it is removed')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the account to authenticate with.')]
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

    [PlannerTask] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PlannerTask]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Planner Task {$($this.Title)}"

        try
        {
            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = $this.GetBoundParameters()
            $nullReturn.Ensure = 'Absent'

            $null = $this.Connect('MicrosoftGraph')

            # If no Id were passed, automatically assume that this is a new task;
            if ([System.String]::IsNullOrEmpty($this.Id))
            {
                return $this.AsResult($nullReturn)
            }

            $taskResponse = Get-MgPlannerTask -PlannerTaskId $this.Id
            $taskDetailsResponse = Get-MgPlannerTaskDetail -PlannerTaskId $taskResponse.Id

            #region Assignments
            $assignmentsValue = @()
            if ($null -ne $taskResponse.Assignments)
            {
                foreach ($assignmentKey in $taskResponse.Assignments.Keys)
                {
                    $assignedUser = Get-MgUser -UserId $assignmentKey -ErrorAction SilentlyContinue
                    if ($null -eq $assignedUser)
                    {
                        Write-Warning -Message "Skipping user with Id [$assignmentKey] because it could not be found."
                        continue
                    }
                    $assignmentsValue += $assignedUser.UserPrincipalName
                }
            }
            #endregion

            #region Attachments
            $attachmentsValue = @()
            if ($null -ne $taskDetailsResponse.References)
            {
                foreach ($attachment in $taskDetailsResponse.References.Keys)
                {
                    $entry = $taskDetailsResponse.References."$attachment"
                    $hashEntry = @{
                        Uri   = $attachment
                        Alias = $entry.alias
                        Type  = $entry.type
                    }
                    $attachmentsValue += $hashEntry
                }
            }
            #endregion

            #region Categories
            $categoriesValue = @()
            if ($null -ne $taskResponse.appliedCategories)
            {
                $categoryLabelsKey = "AppliedCategories_$($this.PlanId)"
                if (-not $this.ResourceCache.ContainsKey($categoryLabelsKey))
                {
                    $this.ResourceCache[$categoryLabelsKey] = (Get-MgPlannerPlanDetail -PlannerPlanId $this.PlanId).CategoryDescriptions
                }

                foreach ($category in $taskResponse.appliedCategories.Keys)
                {
                    $categoryValue = $this.ResourceCache[$categoryLabelsKey].$category
                    if ([String]::IsNullOrEmpty($categoryValue))
                    {
                        $categoryValue = $this.GetTaskColorNameByCategory($category)
                    }
                    $categoriesValue += $categoryValue
                }
            }
            #endregion

            #region Checklist
            $checklistValue = @()
            if ($null -ne $taskDetailsResponse.CheckList)
            {
                foreach ($checkListItem in $taskDetailsResponse.CheckList.Keys)
                {
                    $hashEntry = @{
                        Title     = $taskDetailsResponse.CheckList."$checkListItem".title
                        Completed = [bool]$taskDetailsResponse.CheckList."$checkListItem".isChecked
                    }
                    $checklistValue += $hashEntry
                }
            }
            #endregion

            if ($null -eq $taskResponse)
            {
                return $this.AsResult($nullReturn)
            }
            else
            {
                $NotesValue = ''
                if (-not [System.String]::IsNullOrEmpty($taskResponse))
                {
                    $NotesValue = $taskDetailsResponse.Description
                }

                $StartDateTimeValue = $null
                if ($null -ne $taskResponse.StartDateTime)
                {
                    $StartDateTimeValue = $taskResponse.StartDateTime
                }
                $DueDateTimeValue = $null
                if ($null -ne $taskResponse.DueDateTime)
                {
                    $DueDateTimeValue = $taskResponse.DueDateTime
                }
                $results = @{
                    PlanId                = $this.PlanId
                    Title                 = $this.Title
                    Assignments           = $assignmentsValue
                    Id                    = $taskResponse.Id
                    Categories            = $categoriesValue
                    Attachments           = $attachmentsValue
                    Checklist             = $checklistValue
                    BucketId              = $taskResponse.BucketId
                    Priority              = $taskResponse.Priority
                    ConversationThreadId  = $taskResponse.ConversationThreadId
                    PercentComplete       = $taskResponse.PercentComplete
                    StartDateTime         = $StartDateTimeValue
                    DueDateTime           = $DueDateTimeValue
                    Description           = $NotesValue
                    PreviewType           = $taskDetailsResponse.PreviewType
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

        Write-Verbose -Message "Setting configuration of Planner Task {$($this.Title)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentValues = $this.Get().ToHashtable()

        $setParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        #region Assignments
        Write-Verbose -Message 'Converting Assignments into the proper format'
        $assignmentsValue = @{}
        foreach ($assignment in $setParams.Assignments)
        {
            $user = Get-MgUser -UserId $assignment -ErrorAction SilentlyContinue

            if ($null -ne $user)
            {
                $assignmentsValue.Add($user.Id, @{
                        '@odata.type' = '#microsoft.graph.plannerAssignment'
                        orderHint     = ' !'
                    })
            }
        }
        $setParams.Assignments = $assignmentsValue
        #endregion

        $DetailsValue = @{
            id          = (New-Guid).ToString()
            checklist   = @()
            description = $this.Description
            references  = @()
        }

        #region CheckList
        $checklistValues = @{}
        foreach ($checkListItem in $setParams.Checklist)
        {
            $currentValue = @{
                '@odata.type' = '#microsoft.graph.plannerChecklistItem'
                isChecked     = $checkListItem.Completed
                title         = $checkListItem.Title
            }
            $checkListValues.Add((New-Guid).ToString(), $currentValue)
        }
        $DetailsValue.checklist = $checkListValues
        $setParams.Remove('Checklist') | Out-Null
        #endregion

        #region Attachments
        $attachmentsValues = @{}
        foreach ($attachment in $setParams.Attachments)
        {
            $currentValue = @{
                '@odata.type' = '#microsoft.graph.plannerExternalReference'
                alias         = $attachment.Alias
                type          = $attachment.Type
            }
            $attachmentsValues.Add($attachment.Uri, $currentValue)
        }
        $DetailsValue.references = $attachmentsValues
        $setParams.Remove('Attachments') | Out-Null
        #endregion

        #region PreviewType
        # The plannerTask body does not accept previewType, only the details entity does.
        if (-not [System.String]::IsNullOrEmpty($this.PreviewType))
        {
            $DetailsValue.Add('previewType', $this.PreviewType)
        }
        $setParams.Remove('PreviewType') | Out-Null
        #endregion

        $setParams.Remove('Description') | Out-Null
        $setParams.Add('Details', $DetailsValue)
        $setParams.Remove('Description') | Out-Null

        #region Categories
        $categoriesValue = @{
            category1  = $false
            category2  = $false
            category3  = $false
            category4  = $false
            category5  = $false
            category6  = $false
            category7  = $false
            category8  = $false
            category9  = $false
            category10 = $false
            category11 = $false
            category12 = $false
            category13 = $false
            category14 = $false
            category15 = $false
            category16 = $false
            category17 = $false
            category18 = $false
            category19 = $false
            category20 = $false
            category21 = $false
            category22 = $false
            category23 = $false
            category24 = $false
            category25 = $false
        }

        $planDetails = (Get-MgPlannerPlanDetail -PlannerPlanId $this.PlanId).CategoryDescriptions
        $appliedCategoriesInverse = $planDetails | ConvertTo-Json | ConvertFrom-Json # Convert to PSObject instead of Graph type
        foreach ($category in $setParams.Categories)
        {
            $categoryName = $appliedCategoriesInverse.PSObject.Properties | Where-Object { $_.Value -eq $category } | Select-Object -ExpandProperty Name
            if ([String]::IsNullOrEmpty($categoryName))
            {
                $categoryName = $this.GetTaskCategoryNameByColor($category)
            }
            $categoriesValue.$categoryName = $true
        }
        $setParams.Add('AppliedCategories', $categoriesValue)
        $setParams.Remove('Categories') | Out-Null
        #endregion

        $setParams = Rename-M365DSCCimInstanceParameter -Properties $setParams

        if ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Absent')
        {
            $setParams.Remove('Id') | Out-Null
            $details = $setParams.Details
            $setParams.Remove('Details') | Out-Null
            $setParams.Remove('Ensure') | Out-Null
            Write-Verbose -Message "Planner Task {$($this.Title)} doesn't already exist. Creating it with`r`n:$(Convert-M365DscHashtableToString -Hashtable $setParams)"
            $newTask = New-MgPlannerTask -BodyParameter $setParams

            $newTaskDetails = Get-MgPlannerTaskDetail -PlannerTaskId $newTask.Id
            $Headers = @{}
            $Headers.Add('If-Match', $newTaskDetails.'@odata.etag')
            $details.Remove('id') | Out-Null
            Write-Verbose -Message "Updating Task's details with:`r`n$(ConvertTo-Json $details)"
            Update-MgPlannerTaskDetail -PlannerTaskId $newTask.Id `
                -Headers $Headers `
                -BodyParameter $details
        }
        elseif ($this.Ensure -eq 'Present' -and $currentValues.Ensure -eq 'Present')
        {
            $taskIdValue = $currentValues.Id
            if ([System.String]::IsNullOrEmpty($taskIdValue))
            {
                $taskIdValue = $setParams.Id
            }
            $setParams.Remove('Id') | Out-Null
            $details = $setParams.Details
            $setParams.Remove('Details') | Out-Null
            $setParams.Remove('Verbose') | Out-Null

            $setParams.dueDateTime = [DateTime]::Parse($setParams.dueDateTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
            $setParams.Remove('PlanId') | Out-Null

            if ($null -ne $setParams.StartDateTime)
            {
                $startDateTimeValue = [DateTime]::Parse($setParams.StartDateTime).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffK')
                $setParams.Remove('StartDateTime') | Out-Null
                $setParams.Add('startDateTime', $startDateTimeValue)
            }

            Write-Verbose -Message "Planner Task {$($this.Title)} already exists, but is not in the `
            Desired State. Updating it."
            $currentTask = Get-MgPlannerTask -PlannerTaskId $taskIdValue
            $Headers = @{}
            $etag = $currentTask.'@odata.etag'

            $Headers.Add('If-Match', $etag)
            Write-Verbose -Message "Updating Task with:`r`n$(ConvertTo-Json $setParams)"
            Update-MgPlannerTask -PlannerTaskId $taskIdValue `
                -Headers $Headers `
                -BodyParameter $setParams

            # Update Details
            $Headers = @{}
            $currentTaskDetails = Get-MgPlannerTaskDetail -PlannerTaskId $taskIdValue
            $Headers.Add('If-Match', $currentTaskDetails.'@odata.etag')
            $details.Remove('id') | Out-Null
            Write-Verbose -Message "Updating Task's details with:`r`n$(ConvertTo-Json $details)"
            Update-MgPlannerTaskDetail -PlannerTaskId $taskIdValue `
                -Headers $Headers `
                -BodyParameter $details

            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Planner Task {$($this.Title)} exists, but is should not. `
            Removing it."
            Remove-MgPlannerTask -PlannerTaskId $setParams.Id
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $ConnectionMode = $this.Connect('MicrosoftGraph')

            [array]$groups = Get-MgGroup -All -ErrorAction Stop -Filter $this.filter

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($group in $groups)
            {
                Write-M365DSCHost -Message "    |---[$i/$($groups.Length)] $($group.DisplayName) - {$($group.Id)}"
                try
                {
                    [Array]$plans = Get-MgGroupPlannerPlan -GroupId $group.Id -ErrorAction 'SilentlyContinue'

                    $j = 1
                    foreach ($plan in $plans)
                    {
                        Write-M365DSCHost -Message "        |---[$j/$($plans.Length)] $($plan.Title)"

                        [Array]$tasks = Get-MgGroupPlannerPlanTask -GroupId $group.Id -PlannerPlanId $plan.Id -ErrorAction 'SilentlyContinue'

                        $k = 1
                        foreach ($task in $tasks)
                        {
                            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                            {
                                $Global:M365DSCExportResourceInstancesCount++
                            }

                            Write-M365DSCHost -Message "            |---[$k/$($tasks.Length)] $($task.Title)" -DeferWrite
                            $currentDSCBlock = ''

                            $params = @{
                                Id                    = $task.Id
                                PlanId                = $plan.Id
                                Title                 = $task.Title
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

                            $result = $this.GetForExport($params)

                            if ($result.Assignments.Count -eq 0)
                            {
                                $result.Remove('Assignments') | Out-Null
                            }

                            if ($result.Attachments)
                            {
                                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                    -ComplexObject $result.Attachments `
                                    -CIMInstanceName 'PlannerTaskAttachment'
                                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                                {
                                    $result.Attachments = $complexTypeStringResult
                                }
                                else
                                {
                                    $result.Remove('Attachments') | Out-Null
                                }
                            }

                            if ($result.Checklist)
                            {
                                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                                    -ComplexObject $result.Checklist `
                                    -CIMInstanceName 'PlannerTaskChecklistItem'
                                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                                {
                                    $result.Checklist = $complexTypeStringResult
                                }
                                else
                                {
                                    $result.Remove('Checklist') | Out-Null
                                }
                            }

                            # Fix Description which can have multiple lines
                            if (-not [System.String]::IsNullOrEmpty($result.Description))
                            {
                                $result.Description = $result.Description.Replace('"', '``"')
                                $result.Description = $result.Description.Replace('&', "``&")
                            }

                            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                                -ConnectionMode $ConnectionMode `
                                -ModulePath $this.GetModulePath() `
                                -Results $result `
                                -Credential $this.Credential `
                                -NoEscape @('Attachments', 'Checklist')

                            [void]$dscContent.Append($currentDSCBlock)
                            Save-M365DSCPartialExport -Content $currentDSCBlock `
                                -FileName $Global:PartialExportFileName
                            $k++
                            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                        }
                        $j++
                    }
                }
                catch
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

                    $this.LogError($_, 'Error during Export:')
                }
                $i++
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
                if ([System.String]::IsNullOrEmpty($DesiredValues.BucketId) -and
                    -not [System.String]::IsNullOrEmpty($CurrentValues.BucketId))
                {
                    if (-not $ValuesToCheck.ContainsKey('BucketId'))
                    {
                        $DesiredValues.BucketId = $null
                        $ValuesToCheck.Add('BucketId', $null)
                    }
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.String] GetTaskCategoryNameByColor([System.String] $ColorName)
    {
        switch ($ColorName)
        {
            'Pink'
            {
                return 'category1'
            }
            'Red'
            {
                return 'category2'
            }
            'Yellow'
            {
                return 'category3'
            }
            'Green'
            {
                return 'category4'
            }
            'Blue'
            {
                return 'category5'
            }
            'Purple'
            {
                return 'category6'
            }
            'Bronze'
            {
                return 'category7'
            }
            'Lime'
            {
                return 'category8'
            }
            'Aqua'
            {
                return 'category9'
            }
            'Gray'
            {
                return 'category10'
            }
            'Silver'
            {
                return 'category11'
            }
            'Brown'
            {
                return 'category12'
            }
            'Cranberry'
            {
                return 'category13'
            }
            'Orange'
            {
                return 'category14'
            }
            'Peach'
            {
                return 'category15'
            }
            'Marigold'
            {
                return 'category16'
            }
            'Light green'
            {
                return 'category17'
            }
            'Dark green'
            {
                return 'category18'
            }
            'Teal'
            {
                return 'category19'
            }
            'Light blue'
            {
                return 'category20'
            }
            'Dark blue'
            {
                return 'category21'
            }
            'Lavender'
            {
                return 'category22'
            }
            'Plum'
            {
                return 'category23'
            }
            'Light gray'
            {
                return 'category24'
            }
            'Dark gray'
            {
                return 'category25'
            }
        }
        return $null
    }

    hidden [System.String] GetTaskColorNameByCategory([System.String] $CategoryName)
    {
        switch ($CategoryName)
        {
            'category1'
            {
                return 'Pink'
            }
            'category2'
            {
                return 'Red'
            }
            'category3'
            {
                return 'Yellow'
            }
            'category4'
            {
                return 'Green'
            }
            'category5'
            {
                return 'Blue'
            }
            'category6'
            {
                return 'Purple'
            }
            'category7'
            {
                return 'Bronze'
            }
            'category8'
            {
                return 'Lime'
            }
            'category9'
            {
                return 'Aqua'
            }
            'category10'
            {
                return 'Gray'
            }
            'category11'
            {
                return 'Silver'
            }
            'category12'
            {
                return 'Brown'
            }
            'category13'
            {
                return 'Cranberry'
            }
            'category14'
            {
                return 'Orange'
            }
            'category15'
            {
                return 'Peach'
            }
            'category16'
            {
                return 'Marigold'
            }
            'category17'
            {
                return 'Light green'
            }
            'category18'
            {
                return 'Dark green'
            }
            'category19'
            {
                return 'Teal'
            }
            'category20'
            {
                return 'Light blue'
            }
            'category21'
            {
                return 'Dark blue'
            }
            'category22'
            {
                return 'Lavender'
            }
            'category23'
            {
                return 'Plum'
            }
            'category24'
            {
                return 'Light gray'
            }
            'category25'
            {
                return 'Dark gray'
            }
        }
        return $null
    }

    hidden [PlannerTask] AsResult([System.Object] $Values)
    {
        if ($Values -is [PlannerTask])
        {
            return $Values
        }

        $result = [PlannerTask]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_PlannerTaskAttachment
{
    [DscProperty()]
    [System.ComponentModel.Description('Alias of for the attachment.')]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('Uri of the link to the attachment.')]
    [System.String] $Uri

    [DscProperty()]
    [System.ComponentModel.Description('Type of attachment.')]
    [ValidateSet('PowerPoint', 'Word', 'Excel', 'Other')]
    [System.String] $Type
}

class MSFT_PlannerTaskChecklistItem
{
    [DscProperty()]
    [System.ComponentModel.Description('Title of the checklist item.')]
    [System.String] $Title

    [DscProperty()]
    [System.ComponentModel.Description('True if the item is completed, false otherwise.')]
    [System.String] $Completed
}
