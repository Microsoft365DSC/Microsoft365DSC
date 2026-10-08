using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SentinelAlertRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the indicator')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the resource group. The name is case insensitive.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('The name of the resource group. The name is case insensitive.')]
    [System.String] $ResourceGroupName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the workspace.')]
    [System.String] $WorkspaceName

    [DscProperty()]
    [System.ComponentModel.Description('The unique id of the indicator.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The name of the workspace.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The alerts'' productName on which the cases will be generated')]
    [System.String] $ProductFilter

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether this alert rule is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The severity for alerts created by this alert rule.')]
    [System.String] $Severity

    [DscProperty()]
    [System.ComponentModel.Description('The tactics of the alert rule')]
    [System.String[]] $Tactics

    [DscProperty()]
    [System.ComponentModel.Description('The techniques of the alert rule')]
    [System.String[]] $Techniques

    [DscProperty()]
    [System.ComponentModel.Description('The sub-techniques of the alert rule')]
    [System.String[]] $SubTechniques

    [DscProperty()]
    [System.ComponentModel.Description('The query that creates alerts for this rule.')]
    [System.String] $Query

    [DscProperty()]
    [System.ComponentModel.Description('The frequency (in ISO 8601 duration format) for this alert rule to run.')]
    [System.String] $QueryFrequency

    [DscProperty()]
    [System.ComponentModel.Description('The period (in ISO 8601 duration format) that this alert rule looks at.')]
    [System.String] $QueryPeriod

    [DscProperty()]
    [System.ComponentModel.Description('The operation against the threshold that triggers alert rule.')]
    [System.String] $TriggerOperator

    [DscProperty()]
    [System.ComponentModel.Description('The threshold triggers this alert rule.')]
    [System.Nullable[System.UInt32]] $TriggerThreshold

    [DscProperty()]
    [System.ComponentModel.Description('The suppression (in ISO 8601 duration format) to wait since last time this alert rule been triggered.')]
    [System.String] $SuppressionDuration

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether the suppression for this alert rule is enabled or disabled.')]
    [System.String] $SuppressionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The Name of the alert rule template used to create this rule.')]
    [System.String] $AlertRuleTemplateName

    [DscProperty()]
    [System.ComponentModel.Description('The alerts'' displayNames on which the cases will not be generated.')]
    [System.String[]] $DisplayNamesExcludeFilter

    [DscProperty()]
    [System.ComponentModel.Description('The alerts'' displayNames on which the cases will be generated.')]
    [System.String[]] $DisplayNamesFilter

    [DscProperty()]
    [System.ComponentModel.Description('The alerts'' severities on which the cases will be generated')]
    [System.String[]] $SeveritiesFilter

    [DscProperty()]
    [System.ComponentModel.Description('The event grouping settings.')]
    [MSFT_SentinelAlertRuleEventGroupingSettings] $EventGroupingSettings

    [DscProperty()]
    [System.ComponentModel.Description('Dictionary of string key-value pairs of columns to be attached to the alert')]
    [MSFT_SentinelAlertRuleCustomDetails[]] $CustomDetails

    [DscProperty()]
    [System.ComponentModel.Description('Array of the entity mappings of the alert rule')]
    [MSFT_SentinelAlertRuleEntityMapping[]] $EntityMappings

    [DscProperty()]
    [System.ComponentModel.Description('The alert details override settings')]
    [MSFT_SentinelAlertRuleAlertDetailsOverride] $AlertDetailsOverride

    [DscProperty()]
    [System.ComponentModel.Description('The settings of the incidents that created from alerts triggered by this analytics rule')]
    [MSFT_SentinelAlertRuleIncidentConfiguration] $IncidentConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('The kind of the alert rule')]
    [System.String] $Kind

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SentinelAlertRule] Get()
    {
        $IncidentConfigurationValue = $null
        $instance = $null
        $AlertDetailsOverrideValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SentinelAlertRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Sentinel Alert Rule configuration for $($this.DisplayName)"

        try
        {
            $null = $this.Connect('Azure')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $tenantIdValue = $this.TenantId
            if ([System.String]::IsNullOrEmpty($tenantIdValue) -and -not $null -eq $this.Credential)
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }

            if (-not [System.String]::IsNullOrEmpty($this.Id))
            {
                $instance = $this.GetAlertRule($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $this.Id)
            }
            if ($null -eq $instance)
            {
                $instances = $this.GetAlertRule($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $null)
                $instance = $instances | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            # EventGroupingSettings
            $EventGroupingValueSettingsValue = $null
            if ($null -ne $instance.properties.eventGroupingSettings)
            {
                $EventGroupingValueSettingsValue = @{
                    aggregationKind = $instance.properties.eventGroupingSettings.aggregationKind
                }
            }

            # CustomDetails
            $CustomDetailsValue = @()
            if ($null -ne $instance.properties.customDetails)
            {
                $detailAsHash = @{}
                $instance.properties.customDetails.psobject.properties | ForEach-Object { $detailAsHash[$_.Name] = $_.Value }
                foreach ($key in $detailAsHash.Keys)
                {
                    $CustomDetailsValue += @{
                        DetailKey   = $key
                        DetailValue = $detailAsHash.$key
                    }
                }
            }

            #EntityMappings
            $EntityMappingsValue = @()
            if ($null -ne $instance.properties.entityMappings)
            {
                foreach ($mapping in $instance.properties.entityMappings)
                {
                    $entity = @{
                        entityType    = $mapping.entityType
                        fieldMappings = @()
                    }

                    foreach ($fieldMapping in $mapping.fieldMappings)
                    {
                        $entity.fieldMappings += @{
                            identifier = $fieldMapping.identifier
                            columnName = $fieldMapping.columnName
                        }
                    }

                    $EntityMappingsValue += $entity
                }
            }

            #AlertDetailsOverride
            if ($null -ne $instance.properties.alertDetailsOverride)
            {
                $info = $instance.properties.alertDetailsOverride
                $AlertDetailsOverrideValue = @{
                    alertDisplayNameFormat = $info.alertDisplayNameFormat
                    alertDescriptionFormat = $info.alertDescriptionFormat
                    alertDynamicProperties = @()
                }

                foreach ($propertyEntry in $info.alertDynamicProperties)
                {
                    $AlertDetailsOverrideValue.alertDynamicProperties += @{
                        alertProperty      = $propertyEntry.alertProperty
                        alertPropertyValue = $propertyEntry.value
                    }
                }
            }

            #IncidentConfiguration
            if ($null -ne $instance.properties.incidentConfiguration)
            {
                $info = $instance.properties.incidentConfiguration
                $IncidentConfigurationValue = @{
                    createIncident        = [Boolean]::Parse($info.createIncident.ToString())
                    groupingConfiguration = @{
                        enabled              = $info.groupingConfiguration.enabled
                        reopenClosedIncident = $info.groupingConfiguration.reopenClosedIncident
                        lookbackDuration     = $info.groupingConfiguration.lookbackDuration
                        matchingMethod       = $info.groupingConfiguration.matchingMethod
                        groupByEntities      = $info.groupingConfiguration.groupByEntities
                        groupByAlertDetails  = $info.groupingConfiguration.groupByAlertDetails
                        groupByCustomDetails = $info.groupingConfiguration.groupByCustomDetails
                    }
                }
            }

            $results = @{
                ProductFilter             = $instance.properties.ProductFilter
                Enabled                   = $instance.properties.Enabled
                Severity                  = $instance.properties.Severity
                Tactics                   = $instance.properties.Tactics
                Techniques                = $instance.properties.Techniques
                SubTechniques             = $instance.properties.SubTechniques
                Query                     = $instance.properties.Query
                QueryFrequency            = $instance.properties.QueryFrequency
                QueryPeriod               = $instance.properties.QueryPeriod
                TriggerOperator           = $instance.properties.TriggerOperator
                TriggerThreshold          = $instance.properties.TriggerThreshold
                SuppressionDuration       = $instance.properties.SuppressionDuration
                SuppressionEnabled        = $instance.properties.SuppressionEnabled
                AlertRuleTemplateName     = $instance.properties.AlertRuleTemplateName
                DisplayNamesExcludeFilter = $instance.properties.DisplayNamesExcludeFilter
                DisplayNamesFilter        = $instance.properties.DisplayNamesFilter
                SeveritiesFilter          = $instance.properties.SeveritiesFilter
                DisplayName               = $instance.properties.displayName
                EventGroupingSettings     = $EventGroupingValueSettingsValue
                CustomDetails             = $CustomDetailsValue
                EntityMappings            = $EntityMappingsValue
                AlertDetailsOverride      = $AlertDetailsOverrideValue
                IncidentConfiguration     = $IncidentConfigurationValue
                SubscriptionId            = $this.SubscriptionId
                ResourceGroupName         = $this.ResourceGroupName
                WorkspaceName             = $this.WorkspaceName
                Id                        = $instance.name
                Kind                      = $instance.kind
                Description               = $instance.properties.description
                Ensure                    = 'Present'
                Credential                = $this.Credential
                ApplicationId             = $this.ApplicationId
                TenantId                  = $tenantIdValue
                CertificateThumbprint     = $this.CertificateThumbprint
                CertificatePath           = $this.CertificatePath
                CertificatePassword       = $this.CertificatePassword
                ManagedIdentity           = $this.ManagedIdentity
                AccessTokens              = $this.AccessTokens
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
        $AlertSeverity = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting Sentinel Alert Rule configuration for $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $tenantIdValue = $this.TenantId
        if ([System.String]::IsNullOrEmpty($tenantIdValue) -and -not $null -eq $this.Credential)
        {
            $tenantIdValue = $this.Credential.UserName.Split('@')[1]
        }

        $instance = @{}
        if ($this.Kind -eq 'Fusion')
        {
            $instance = @{
                kind       = $this.Kind
                properties = @{
                    alertRuleTemplateName = $this.AlertRuleTemplateName
                    enabled               = $this.Enabled
                }
            }
        }
        elseif ($this.Kind -eq 'MicrosoftSecurityIncidentCreation')
        {
            $instance = @{
                kind       = $this.Kind
                properties = @{
                    displayName               = $this.DisplayName
                    description               = $this.Description
                    productFilter             = $this.ProductFilter
                    displayNamesExcludeFilter = $this.DisplayNamesExcludeFilter
                    displayNamesFilter        = $this.DisplayNamesFilter
                    enabled                   = $this.Enabled
                    severitiesFilter          = $AlertSeverity
                }
            }
        }
        elseif ($this.Kind -eq 'Scheduled')
        {
            $instance = @{
                kind       = $this.Kind
                properties = @{
                    displayName               = $this.DisplayName
                    enabled                   = $this.Enabled
                    description               = $this.Description
                    query                     = $this.Query
                    queryFrequency            = $this.QueryFrequency
                    queryPeriod               = $this.QueryPeriod
                    severity                  = $this.Severity
                    suppressionDuration       = $this.SuppressionDuration
                    suppressionEnabled        = $this.SuppressionEnabled
                    triggerOperator           = $this.TriggerOperator
                    triggerThreshold          = $this.TriggerThreshold
                    eventGroupingSettings     = @{
                        aggregationKind = $this.EventGroupingSettings.aggregationKind
                    }
                    customDetails             = @{}
                    alertDetailsOverride      = @{
                        alertDisplayNameFormat = $this.AlertDetailsOverride.alertDisplayNameFormat
                        alertDescriptionFormat = $this.AlertDetailsOverride.alertDescriptionFormat
                        alertDynamicProperties = @()
                    }
                    entityMappings            = @()
                    incidentConfiguration     = @{
                        createIncident        = $this.IncidentConfiguration.createIncident
                        groupingConfiguration = @{
                            enabled              = $this.IncidentConfiguration.groupingConfiguration.enabled
                            reopenClosedIncident = $this.IncidentConfiguration.groupingConfiguration.reopenClosedIncident
                            lookbackDuration     = $this.IncidentConfiguration.groupingConfiguration.lookbackDuration
                            matchingMethod       = $this.IncidentConfiguration.groupingConfiguration.matchingMethod
                            groupByEntities      = $this.IncidentConfiguration.groupingConfiguration.groupByEntities
                            groupByAlertDetails  = $this.IncidentConfiguration.groupingConfiguration.groupByAlertDetails
                            groupByCustomDetails = $this.IncidentConfiguration.groupingConfiguration.groupByCustomDetails
                        }
                    }
                    productFilter             = $this.ProductFilter
                    displayNamesExcludeFilter = $this.DisplayNamesExcludeFilter
                    displayNamesFilter        = $this.DisplayNamesFilter
                    severitiesFilter          = $AlertSeverity
                }
            }

            if ($null -eq $this.EntityMappings -or $this.EntityMappings.Length -eq 0)
            {
                $instance.properties.Remove('entityMappings') | Out-Null
            }
            else
            {
                foreach ($entity in $this.EntityMappings)
                {
                    $entry = @{
                        entityType    = $entity.entityType
                        fieldMappings = @()
                    }

                    foreach ($field in $entity.fieldMappings)
                    {
                        $entry.fieldMappings += @{
                            identifier = $field.identifier
                            columnName = $field.columnName
                        }
                    }

                    $instance.properties.entityMappings += $entry
                }
            }

            foreach ($detail in $this.CustomDetails)
            {
                $instance.properties.customDetails.Add($detail.DetailKey, $detail.DetailValue)
            }

            foreach ($dynamicProp in $this.AlertDetailsOverride.alertDynamicProperties)
            {
                $instance.properties.alertDetailsOverride.alertDynamicProperties += @{
                    alertProperty = $dynamicProp.alertProperty
                    value         = $dynamicProp.alertPropertyValue
                }
            }
        }
        elseif ($this.Kind -eq 'NRT')
        {
            $instance = @{
                kind       = $this.Kind
                properties = @{
                    displayName           = $this.DisplayName
                    enabled               = $this.Enabled
                    description           = $this.Description
                    query                 = $this.Query
                    severity              = $this.Severity
                    suppressionDuration   = $this.SuppressionDuration
                    suppressionEnabled    = $this.SuppressionEnabled
                    eventGroupingSettings = @{
                        aggregationKind = $this.EventGroupingSettings.aggregationKind
                    }
                    alertDetailsOverride  = @{
                        alertDisplayNameFormat = $this.AlertDetailsOverride.alertDisplayNameFormat
                        alertDescriptionFormat = $this.AlertDetailsOverride.alertDescriptionFormat
                        alertDynamicProperties = @()
                    }
                    entityMappings        = @()
                    customDetails         = @{}
                    incidentConfiguration = @{
                        createIncident        = $this.IncidentConfiguration.createIncident
                        groupingConfiguration = @{
                            enabled              = $this.IncidentConfiguration.groupingConfiguration.enabled
                            reopenClosedIncident = $this.IncidentConfiguration.groupingConfiguration.reopenClosedIncident
                            lookbackDuration     = $this.IncidentConfiguration.groupingConfiguration.lookbackDuration
                            matchingMethod       = $this.IncidentConfiguration.groupingConfiguration.matchingMethod
                            groupByEntities      = $this.IncidentConfiguration.groupingConfiguration.groupByEntities
                            groupByAlertDetails  = $this.IncidentConfiguration.groupingConfiguration.groupByAlertDetails
                            groupByCustomDetails = $this.IncidentConfiguration.groupingConfiguration.groupByCustomDetails
                        }
                    }
                    techniques            = $this.Techniques
                    subTechniques         = $this.SubTechniques
                    tactics               = $this.Tactics
                }
            }

            if ($null -eq $this.EntityMappings -or $this.EntityMappings.Length -eq 0)
            {
                $instance.properties.Remove('entityMappings') | Out-Null
            }
            else
            {
                foreach ($entity in $this.EntityMappings)
                {
                    $entry = @{
                        entityType    = $entity.entityType
                        fieldMappings = @()
                    }

                    foreach ($field in $entity.fieldMappings)
                    {
                        $entry.fieldMappings += @{
                            identifier = $field.identifier
                            columnName = $field.columnName
                        }
                    }

                    $instance.properties.entityMappings += $entry
                }
            }

            foreach ($detail in $this.CustomDetails)
            {
                $instance.properties.customDetails.Add($detail.DetailKey, $detail.DetailValue)
            }

            foreach ($dynamicProp in $this.AlertDetailsOverride.alertDynamicProperties)
            {
                $instance.properties.alertDetailsOverride.alertDynamicProperties += @{
                    alertProperty = $dynamicProp.alertProperty
                    value         = $dynamicProp.alertPropertyValue
                }
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Alert Rule {$($this.DisplayName)}"
            $this.NewAlertRule($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $instance, $null)
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Alert Rule {$($this.DisplayName)}"
            $this.NewAlertRule($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $instance, $currentInstance.Id)
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Alert Rule {$($this.DisplayName)}"
            $this.RemoveAlertRule($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $currentInstance.Id)
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $sentinelInstances = Get-AzResource -ResourceType 'Microsoft.OperationsManagement/solutions'
            $sentinelNames = @()
            foreach ($instance in $sentinelInstances)
            {
                $sentinelNames += $instance.Name.Replace('SecurityInsights(', '').Replace(')', '')
            }
            $workspaces = Get-AzResource -ResourceType 'Microsoft.OperationalInsights/workspaces' | Where-Object Name -in $sentinelNames
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($workspaces.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $tenantIdValue = $this.TenantId
            if ([System.String]::IsNullOrEmpty($tenantIdValue) -and $null -ne $this.Credential)
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }
            foreach ($workspace in $workspaces)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($workspaces.Length)] $($workspace.Name)" -DeferWrite
                $subscriptionIdValue = $workspace.ResourceId.Split('/')[2]
                $resourceGroupNameValue = $workspace.ResourceGroupName
                $workspaceNameValue = $workspace.Name

                $rules = $this.GetAlertRule($subscriptionIdValue, $resourceGroupNameValue, $workspaceNameValue, $tenantIdValue, $null)

                $j = 1
                if ($rules.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                foreach ($rule in $rules)
                {
                    $displayedKey = $rule.properties.DisplayName
                    Write-M365DSCHost -Message "        |---[$j/$($rules.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        DisplayName           = $rule.properties.displayName
                        Id                    = $rule.name
                        SubscriptionId        = $subscriptionIdValue
                        ResourceGroupName     = $resourceGroupNameValue
                        WorkspaceName         = $workspaceNameValue
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $tenantIdValue
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $Results = $this.GetForExport($Params)

                    if ( $null -ne $Results.EventGroupingSettings)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'EventGroupingSettings'
                                CimInstanceName = 'SentinelAlertRuleEventGroupingSettings'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.EventGroupingSettings `
                            -CIMInstanceName 'SentinelAlertRuleEventGroupingSettings' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.EventGroupingSettings = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('EventGroupingSettings') | Out-Null
                        }
                    }

                    if ($null -ne $Results.CustomDetails)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'CustomDetails'
                                CimInstanceName = 'SentinelAlertRuleCustomDetails'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.CustomDetails `
                            -CIMInstanceName 'SentinelAlertRuleCustomDetails' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.CustomDetails = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('CustomDetails') | Out-Null
                        }
                    }

                    if ( $null -ne $Results.EntityMappings)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'EntityMappings'
                                CimInstanceName = 'SentinelAlertRuleEntityMapping'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'fieldMappings'
                                CimInstanceName = 'SentinelAlertRuleEntityMappingFieldMapping'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.EntityMappings `
                            -CIMInstanceName 'SentinelAlertRuleEntityMapping' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.EntityMappings = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('EntityMappings') | Out-Null
                        }
                    }

                    if ($null -ne $Results.AlertDetailsOverride)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'AlertDetailsOverride'
                                CimInstanceName = 'SentinelAlertRuleAlertDetailsOverride'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'alertDynamicProperties'
                                CimInstanceName = 'SentinelAlertRuleAlertDetailsOverrideAlertDynamicProperty'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.AlertDetailsOverride `
                            -CIMInstanceName 'SentinelAlertRuleAlertDetailsOverride' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.AlertDetailsOverride = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('AlertDetailsOverride') | Out-Null
                        }
                    }

                    if ($null -ne $Results.IncidentConfiguration)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'IncidentConfiguration'
                                CimInstanceName = 'SentinelAlertRuleIncidentConfiguration'
                                IsRequired      = $False
                            },
                            @{
                                Name            = 'groupingConfiguration'
                                CimInstanceName = 'SentinelAlertRuleIncidentConfigurationGroupingConfiguration'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.IncidentConfiguration `
                            -CIMInstanceName 'SentinelAlertRuleIncidentConfiguration' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.IncidentConfiguration = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('IncidentConfiguration') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('EventGroupingSettings', 'CustomDetails', 'EntityMappings', 'AlertDetailsOverride', 'IncidentConfiguration')

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $j++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
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

    hidden [void] NewAlertRule([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.Collections.Hashtable] $Body, [System.String] $Id)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"

            if ([System.String]::IsNullOrEmpty($Id))
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/alertrules/$((New-Guid).ToString())?api-version=2024-04-01-preview"
            }
            else
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/alertrules/$($Id)?api-version=2024-04-01-preview"
            }
            $payload = ConvertTo-Json $Body -Depth 10 -Compress
            Write-Verbose -Message "Creating new rule against URL:`r`n$($uri)`r`nWith payload:`r`n$payload"
            $response = Invoke-AzRestMethod -Uri $uri -Method 'PUT' -Payload $payload
            Write-Verbose -Message $response.Content
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [System.Object] GetAlertRule([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.String] $Id)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"
            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/alertrules/$($Id)?api-version=2023-12-01-preview"
                $response = Invoke-AzRestMethod -Uri $uri -Method 'GET'
                $result = ConvertFrom-Json $response.Content
                return $result
            }
            else
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/alertrules?api-version=2023-12-01-preview"
                $response = Invoke-AzRestMethod -Uri $uri -Method 'GET'
                $result = ConvertFrom-Json $response.Content
                return $result.value
            }
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [void] RemoveAlertRule([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.String] $Id)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"

            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/alertRules/$($Id)?api-version=2024-04-01-preview"
            $null = Invoke-AzRestMethod -Uri $uri -Method 'DELETE'
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [SentinelAlertRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SentinelAlertRule])
        {
            return $Values
        }

        $result = [SentinelAlertRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SentinelAlertRuleEventGroupingSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The event grouping aggregation kinds')]
    [System.String] $aggregationKind
}

class MSFT_SentinelAlertRuleCustomDetails
{
    [DscProperty()]
    [System.ComponentModel.Description('Key of the custom detail.')]
    [System.String] $DetailKey

    [DscProperty()]
    [System.ComponentModel.Description('Associated value with the custom detail.')]
    [System.String] $DetailValue
}

class MSFT_SentinelAlertRuleEntityMapping
{
    [DscProperty()]
    [System.ComponentModel.Description('Type of entity.')]
    [System.String] $entityType

    [DscProperty()]
    [System.ComponentModel.Description('List of field mappings.')]
    [MSFT_SentinelAlertRuleEntityMappingFieldMapping[]] $fieldMappings
}

class MSFT_SentinelAlertRuleAlertDetailsOverride
{
    [DscProperty()]
    [System.ComponentModel.Description('The format containing columns name(s) to override the alert description')]
    [System.String] $alertDescriptionFormat

    [DscProperty()]
    [System.ComponentModel.Description('The format containing columns name(s) to override the alert name')]
    [System.String] $alertDisplayNameFormat

    [DscProperty()]
    [System.ComponentModel.Description('The column name to take the alert severity from')]
    [System.String] $alertSeverityColumnName

    [DscProperty()]
    [System.ComponentModel.Description('The column name to take the alert tactics from')]
    [System.String] $alertTacticsColumnName

    [DscProperty()]
    [System.ComponentModel.Description('List of additional dynamic properties to override')]
    [MSFT_SentinelAlertRuleAlertDetailsOverrideAlertDynamicProperty[]] $alertDynamicProperties
}

class MSFT_SentinelAlertRuleIncidentConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Create incidents from alerts triggered by this analytics rule')]
    [System.Nullable[System.Boolean]] $createIncident

    [DscProperty()]
    [System.ComponentModel.Description('Set how the alerts that are triggered by this analytics rule, are grouped into incidents')]
    [MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration] $groupingConfiguration
}

class MSFT_SentinelAlertRuleEntityMappingFieldMapping
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the column')]
    [System.String] $columnName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Identifier of the associated field.')]
    [System.String] $identifier
}

class MSFT_SentinelAlertRuleAlertDetailsOverrideAlertDynamicProperty
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Dynamic property key.')]
    [System.String] $alertProperty

    [DscProperty()]
    [System.ComponentModel.Description('Dynamic property value.')]
    [System.String] $alertPropertyValue
}

class MSFT_SentinelAlertRuleIncidentConfigurationGroupingConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Grouping enabled')]
    [System.Nullable[System.Boolean]] $enabled

    [DscProperty()]
    [System.ComponentModel.Description('A list of alert details to group by (when matchingMethod is Selected)')]
    [ValidateSet('DisplayName', 'Severity')]
    [System.String[]] $groupByAlertDetails

    [DscProperty()]
    [System.ComponentModel.Description('A list of custom details keys to group by (when matchingMethod is Selected). Only keys defined in the current alert rule may be used.')]
    [System.String[]] $groupByCustomDetails

    [DscProperty()]
    [System.ComponentModel.Description('A list of entity types to group by (when matchingMethod is Selected). Only entities defined in the current alert rule may be used.')]
    [System.String[]] $groupByEntities

    [DscProperty()]
    [System.ComponentModel.Description('Limit the group to alerts created within the lookback duration (in ISO 8601 duration format)')]
    [System.String] $lookbackDuration

    [DscProperty()]
    [System.ComponentModel.Description('Grouping matching method. When method is Selected at least one of groupByEntities, groupByAlertDetails, groupByCustomDetails must be provided and not empty.')]
    [System.String] $matchingMethod

    [DscProperty()]
    [System.ComponentModel.Description('Re-open closed matching incidents')]
    [System.Nullable[System.Boolean]] $reopenClosedIncident
}
