using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADIdentityGovernanceLifecycleWorkflow : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the Display Name of the Workflow')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifiers of the administrative units that the workflow is scoped to.')]
    [System.String[]] $AdministrationScopeTargets

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Workflow')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Category of the Workflow')]
    [System.String] $Category

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the Workflow is enabled')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if scheduling is enabled for the Workflow')]
    [System.Nullable[System.Boolean]] $IsSchedulingEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Tasks associated with this workflow')]
    [MSFT_AADIdentityGovernanceTask[]] $Tasks

    [DscProperty()]
    [System.ComponentModel.Description('ExecutionConditions for this workflow')]
    [MSFT_IdentityGovernanceWorkflowExecutionConditions] $ExecutionConditions

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

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

    [AADIdentityGovernanceLifecycleWorkflow] Get()
    {
        $administrationScopeTargetsResults = @()
        $executionConditionsResults = $null
        $taskResults = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADIdentityGovernanceLifecycleWorkflow]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Identity Governance Lifecycle Workflow with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                    -ErrorAction Stop
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -WorkflowId $instance.Id -ExpandProperty 'administrationScopeTargets'
            if ($null -ne $instance)
            {
                $executionConditionsResults = $this.GetWorkflowExecutionConditions($instance.Id)
                $taskResults = $this.GetTasks($instance.Id)

                if ($null -ne $instance.AdministrationScopeTargets)
                {
                    $administrationScopeTargetsResults = [Array]($instance.AdministrationScopeTargets.Id)
                }
            }

            $results = @{
                DisplayName                = $this.DisplayName
                AdministrationScopeTargets = [Array]$administrationScopeTargetsResults
                Description                = $instance.Description
                Category                   = $instance.Category
                IsEnabled                  = $instance.IsEnabled
                IsSchedulingEnabled        = $instance.IsSchedulingEnabled
                Tasks                      = [Array]$taskResults
                ExecutionConditions        = $executionConditionsResults
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                TenantId                   = $this.TenantId
                ApplicationSecret          = $this.ApplicationSecret
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                AccessTokens               = $this.AccessTokens
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
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($null -ne $this.AdministrationScopeTargets)
        {
            [Array]$administrationScopeTargetsValue = @()

            foreach ($administrationScopeTarget in $this.AdministrationScopeTargets)
            {
                $administrationScopeTargetsValue += @{
                    '@odata.type' = '#microsoft.graph.administrativeUnit'
                    id            = $administrationScopeTarget
                }
            }

            $setParameters.Remove('AdministrationScopeTargets')
            $setParameters.Add('AdministrationScopeTargets', [Array]$administrationScopeTargetsValue)
        }

        if ($null -ne $this.ExecutionConditions)
        {
            $executionConditionsResult = @{
                Scope         = @{
                    Rule          = $this.ExecutionConditions.ScopeValue.Rule
                    '@odata.type' = $this.ExecutionConditions.ScopeValue.ODataType
                }
                Trigger       = @{
                    OffsetInDays       = $this.ExecutionConditions.TriggerValue.OffsetInDays
                    TimeBasedAttribute = $this.ExecutionConditions.TriggerValue.TimeBasedAttribute
                    '@odata.type'      = $this.ExecutionConditions.TriggerValue.ODataType
                }
                '@odata.type' = $this.ExecutionConditions.ODataType
            }

            $setParameters.Remove('ExecutionConditions')
            $setParameters.Add('executionConditions', $executionConditionsResult)
        }

        if ($null -ne $this.Tasks)
        {
            $taskList = @()

            # Loop through each task and create a hashtable
            foreach ($task in $this.Tasks)
            {
                [Array]$argumentsArray = @()

                if ($task.Arguments)
                {
                    foreach ($arg in $task.Arguments)
                    {
                        # Create a hashtable for each argument
                        $argumentsArray += @{
                            Name  = $arg.Name.ToString()
                            Value = $arg.Value.ToString()
                        }
                    }
                }
                $taskHashtable = @{
                    DisplayName       = $task.DisplayName.ToString()
                    Description       = $task.Description.ToString()
                    Category          = $task.Category.ToString()
                    IsEnabled         = $task.IsEnabled
                    ExecutionSequence = $task.ExecutionSequence
                    ContinueOnError   = $task.ContinueOnError
                    TaskDefinitionId  = $task.TaskDefinitionId

                    # If Arguments exist, populate the hashtable
                    Arguments         = [Array]$argumentsArray
                }

                # Add the task hashtable to the task list
                $taskList += $taskHashtable
            }

            $setParameters.Remove('Tasks')
            $setParameters.Add('Tasks', $taskList)
        }

        $updateParameters = ([Hashtable]$setParameters).Clone()

        $newParams = @{}
        $newParams.Add('workflow', $updateParameters)

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            try
            {
                New-MgBetaIdentityGovernanceLifecycleWorkflow -BodyParameter $SetParameters -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Create:')
                    throw $_
                }
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            try
            {
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -WorkflowId $instance.Id

                New-MgBetaIdentityGovernanceLifecycleWorkflowNewVersion -WorkflowId $instance.Id -BodyParameter $newParams -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Update:')
                    throw $_
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            try
            {
                $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
                Remove-MgBetaIdentityGovernanceLifecycleWorkflow -WorkflowId $instance.Id -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Remove:')
                    throw $_
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
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-MgBetaIdentityGovernanceLifecycleWorkflow -All -Filter $this.Filter -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
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
                if ($null -ne $Results.Tasks)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Tasks'
                            CimInstanceName = 'AADIdentityGovernanceTask'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'Arguments'
                            CimInstanceName = 'MSFT_AADIdentityGovernanceTaskArguments'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Tasks `
                        -CIMInstanceName 'AADIdentityGovernanceTask' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Tasks = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Tasks') | Out-Null
                    }
                }

                if ($null -ne $Results.ExecutionConditions)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'ExecutionConditions'
                            CimInstanceName = 'MSFT_IdentityGovernanceWorkflowExecutionConditions'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'ScopeValue'
                            CimInstanceName = 'MSFT_IdentityGovernanceScope'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'TriggerValue'
                            CimInstanceName = 'MSFT_IdentityGovernanceTrigger'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExecutionConditions `
                        -CIMInstanceName 'MSFT_IdentityGovernanceWorkflowExecutionConditions' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExecutionConditions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExecutionConditions') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Tasks', 'ExecutionConditions')

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
            if ($_.ErrorDetails.Message -like 'Insufficient license *')
            {
                Write-M365DSCHost -Message "`r`n    " -DeferWrite
                Write-M365DSCHost -Message $Global:M365DSCEmojiYellowCircle -DeferWrite
                Write-M365DSCHost -Message ' Insufficient license. You need the Entra ID Governance license.' -CommitWrite
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [System.Collections.Hashtable] GetWorkflowExecutionConditions([System.String] $WorkflowId)
    {
        $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflow -WorkflowId $WorkflowId
        $executionConditionsResult = @{}

        if ($null -ne $instance -and $null -ne $instance.ExecutionConditions)
        {
            $conditionsValue = $instance.ExecutionConditions
            $executionConditionsResult = @{
                ScopeValue   = @{
                    Rule      = $conditionsValue['scope']['rule']
                    OdataType = $conditionsValue['scope']['@odata.type']
                }
                TriggerValue = @{
                    OffsetInDays       = $conditionsValue['trigger']['offsetInDays']
                    TimeBasedAttribute = $conditionsValue['trigger']['timeBasedAttribute']
                    ODataType          = $conditionsValue['trigger']['@odata.type']
                }
                OdataType    = $conditionsValue['@odata.type']
            }
        }

        return $executionConditionsResult
    }

    hidden [System.Object[]] GetTasks([System.String] $WorkflowId)
    {
        $workflowTasks = Get-MgBetaIdentityGovernanceLifecycleWorkflowTask -WorkflowId $WorkflowId

        $taskList = @()

        if ($null -eq $workflowTasks)
        {
            return $taskList
        }

        foreach ($task in $workflowTasks)
        {
            [Array]$argumentsArray = @()

            if ($task.Arguments)
            {
                foreach ($arg in $task.Arguments)
                {
                    $argumentsArray += @{
                        Name  = $arg.Name.ToString()
                        Value = $arg.Value.ToString()
                    }
                }
            }
            $taskHashtable = @{
                DisplayName       = $task.DisplayName.ToString()
                Description       = $task.Description.ToString()
                Category          = $task.Category.ToString()
                IsEnabled         = $task.IsEnabled
                ExecutionSequence = $task.ExecutionSequence
                ContinueOnError   = $task.ContinueOnError
                TaskDefinitionId  = $task.TaskDefinitionId
                Arguments         = [Array]$argumentsArray
            }

            $taskList += $taskHashtable
        }

        return $taskList
    }

    hidden [AADIdentityGovernanceLifecycleWorkflow] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADIdentityGovernanceLifecycleWorkflow])
        {
            return $Values
        }

        $result = [AADIdentityGovernanceLifecycleWorkflow]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADIdentityGovernanceTask
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Specifies the display name of the Workflow Task')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Workflow Task')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Category of the Workflow Task')]
    [System.String] $Category

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if the Workflow Task is enabled or not')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The sequence in which the task is executed')]
    [System.Nullable[System.Int32]] $ExecutionSequence

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the task should continue on error')]
    [System.Nullable[System.Boolean]] $ContinueOnError

    [DscProperty()]
    [System.ComponentModel.Description('ID of the task definition associated with this Workflow Task')]
    [System.String] $TaskDefinitionId

    [DscProperty()]
    [System.ComponentModel.Description('Arguments for the Workflow Task')]
    [MSFT_AADIdentityGovernanceTaskArguments[]] $Arguments
}

class MSFT_IdentityGovernanceWorkflowExecutionConditions
{
    [DscProperty()]
    [System.ComponentModel.Description('The @odata.type for the Workflow Execution Conditions.')]
    [System.String] $OdataType

    [DscProperty()]
    [System.ComponentModel.Description('The scope for the Workflow Execution Conditions.')]
    [MSFT_IdentityGovernanceScope] $ScopeValue

    [DscProperty()]
    [System.ComponentModel.Description('The trigger for the Workflow Execution Conditions.')]
    [MSFT_IdentityGovernanceTrigger] $TriggerValue
}

class MSFT_AADIdentityGovernanceTaskArguments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the key')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The value associated with the key')]
    [System.String] $Value
}

class MSFT_IdentityGovernanceScope
{
    [DscProperty()]
    [System.ComponentModel.Description('The @odata.type for the Scope.')]
    [System.String] $OdataType

    [DscProperty()]
    [System.ComponentModel.Description('The rule associated with the Scope.')]
    [System.String] $Rule
}

class MSFT_IdentityGovernanceTrigger
{
    [DscProperty()]
    [System.ComponentModel.Description('The @odata.type for the Trigger.')]
    [System.String] $OdataType

    [DscProperty()]
    [System.ComponentModel.Description('The time-based attribute for the Trigger.')]
    [System.String] $TimeBasedAttribute

    [DscProperty()]
    [System.ComponentModel.Description('The offset in days for the Trigger.')]
    [System.Nullable[System.Int32]] $OffsetInDays
}
