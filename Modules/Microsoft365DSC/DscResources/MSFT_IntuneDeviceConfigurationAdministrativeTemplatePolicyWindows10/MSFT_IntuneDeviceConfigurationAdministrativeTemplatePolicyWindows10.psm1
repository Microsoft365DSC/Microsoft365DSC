using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('User provided description for the resource object.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('User provided name for the resource object.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Type of definitions configured for this policy. Possible values are: unknown, custom, builtIn, mixed, unknownFutureValue.')]
    [ValidateSet('unknown', 'custom', 'builtIn', 'mixed', 'unknownFutureValue')]
    [System.String] $PolicyConfigurationIngestionType

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The list of enabled or disabled group policy definition values for the configuration.')]
    [MSFT_IntuneGroupPolicyDefinitionValue[]] $DefinitionValues

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for this policy instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

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

    [IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Administrative Template Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaDeviceManagementGroupPolicyConfiguration -GroupPolicyConfigurationId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Administrative Template Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementGroupPolicyConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                        if ($null -eq $getValue)
                        {
                            Write-Verbose -Message "Could not find an Intune Device Configuration Administrative Template Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                            return $this.AsResult($nullResult)
                        }
                        if (([array]$getValue).Count -gt 1)
                        {
                            throw "A policy with a duplicated displayName {'$($this.DisplayName)'} was found - Ensure displayName is unique"
                        }
                    }
                }
                #endregion
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Administrative Template Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region
            $settings = Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValue `
                -GroupPolicyConfigurationId $resolvedId

            $complexDefinitionValues = @()
            foreach ($setting in $settings)
            {
                $definitionValue = @{}
                $definitionValue.Add('Id', $setting.Id)
                if ($null -ne $setting.ConfigurationType)
                {
                    $definitionValue.Add('ConfigurationType', $setting.ConfigurationType)
                }
                $definitionValue.Add('Enabled', $setting.Enabled)
                $definition = Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValueDefinition `
                    -GroupPolicyConfigurationId $resolvedId `
                    -GroupPolicyDefinitionValueId $setting.Id

                $complexDefinition = @{
                    CategoryPath = $definition.CategoryPath
                    ClassType    = $definition.ClassType
                    DisplayName  = $definition.DisplayName
                    PolicyType   = $definition.PolicyType
                    SupportedOn  = $definition.SupportedOn
                    Id           = $definition.Id
                }

                $definitionValue.Add('Definition', $complexDefinition)

                $presentationValues = Get-MgBetaDeviceManagementGroupPolicyConfigurationDefinitionValuePresentationValue `
                    -GroupPolicyConfigurationId $resolvedId `
                    -GroupPolicyDefinitionValueId $setting.Id `
                    -ExpandProperty 'presentation'

                $complexPresentationValues = @()
                foreach ($presentationValue in $presentationValues)
                {
                    $complexPresentationValue = [ordered]@{}
                    $complexPresentationValue.Add('odataType', $presentationValue.'@odata.type')
                    $complexPresentationValue.Add('Id', $presentationValue.Id)
                    $complexPresentationValue.Add('presentationDefinitionId', $presentationValue.Presentation.Id)
                    $complexPresentationValue.Add('presentationDefinitionLabel', $presentationValue.Presentation.Label)
                    switch -Wildcard ($presentationValue.'@odata.type')
                    {
                        '*.groupPolicyPresentationValueBoolean'
                        {
                            $complexPresentationValue.Add('BooleanValue', $presentationValue.value)
                        }
                        '*.groupPolicyPresentationValue*Decimal'
                        {
                            $complexPresentationValue.Add('DecimalValue', $presentationValue.value)
                        }
                        '*.groupPolicyPresentationValueList'
                        {
                            $complexKeyValuePairValues = @()
                            foreach ($value in $presentationValue.values)
                            {

                                $complexKeyValuePairValue = @{
                                    Name  = $(if ($null -ne $value.name)
                                    {
                                        $value.name.Replace('"', '')
                                    })
                                }
                                if ($null -ne $value.value)
                                {
                                    $complexKeyValuePairValue.Add('Value', $value.value.Replace('"', ''))
                                }
                                $complexKeyValuePairValues += $complexKeyValuePairValue
                            }
                            $complexPresentationValue.Add('KeyValuePairValues', $complexKeyValuePairValues)
                        }
                        '*.groupPolicyPresentationValueMultiText'
                        {
                            $complexPresentationValue.Add('StringValues', $presentationValue.values)
                        }
                        '*.groupPolicyPresentationValueText'
                        {
                            $complexPresentationValue.Add('StringValue', $presentationValue.value)
                        }
                    }
                    $complexPresentationValues += $complexPresentationValue
                }

                $definitionValue.Add('PresentationValues', $complexPresentationValues)
                $complexDefinitionValues += $definitionValue
            }
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                DefinitionValues      = $complexDefinitionValues
                Id                    = $getValue.Id
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
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
                #endregion
            }
            $returnAssignments = @()
            $graphAssignments = Get-MgBetaDeviceManagementGroupPolicyConfigurationAssignment -GroupPolicyConfigurationId $resolvedId
            if ($graphAssignments.Count -gt 0)
            {
                $returnAssignments += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($graphAssignments)
            }
            $results.Add('Assignments', $returnAssignments)

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

        $keyToRename = @{
            'odataType'          = '@odata.type'
            'BooleanValue'       = 'value'
            'StringValue'        = 'value'
            'DecimalValue'       = 'value'
            'KeyValuePairValues' = 'values'
            'StringValues'       = 'values'
        }

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters.Remove('Assignments') | Out-Null
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters -KeyMapping $keyToRename

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Administrative Template Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Remove('DefinitionValues') | Out-Null

            #region resource generator code
            $policy = New-MgBetaDeviceManagementGroupPolicyConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/groupPolicyConfigurations'
            }

            #Create DefinitionValues
            [Array]$targetDefinitionValues = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.DefinitionValues
            $formattedDefinitionValuesToAdd = @()
            foreach ($definitionValue in $targetDefinitionValues)
            {
                $definitionValue = Rename-M365DSCCimInstanceParameter -Properties $definitionValue -KeyMapping $keyToRename
                $complexPresentationValues = @()
                if ($null -ne $definitionValue.PresentationValues)
                {
                    foreach ($presentationValue in [Hashtable[]]$definitionValue.PresentationValues)
                    {
                        $value = $presentationValue.Clone()
                        $value = Rename-M365DSCCimInstanceParameter -Properties $value -KeyMapping $keyToRename
                        $this.RemoveForeignSubtypeProperties($value, @{
                                '#microsoft.graph.groupPolicyPresentationValueBoolean'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueDecimal'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueLongDecimal' = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueText'        = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueMultiText'   = @('values')
                                '#microsoft.graph.groupPolicyPresentationValueList'        = @('values')
                            })
                        $value.Add('presentation@odata.bind', (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')/presentations('$($presentationValue.presentationDefinitionId)')")
                        $value.Remove('PresentationDefinitionId')
                        $value.Remove('PresentationDefinitionLabel')
                        $value.Remove('id')
                        $complexPresentationValues += $value
                    }
                }
                $complexDefinitionValue = @{
                    'definition@odata.bind' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')"
                    enabled                 = $definitionValue.Enabled
                    presentationValues      = $complexPresentationValues
                }
                $formattedDefinitionValuesToAdd += $complexDefinitionValue
            }

            $this.UpdateGroupPolicyDefinitionValue($policy.Id, $formattedDefinitionValuesToAdd, @(), @())
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Configuration Administrative Template Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('DefinitionValues') | Out-Null

            #region resource generator code
            #Update Core policy
            $updateParameters.Add('@odata.type', '#microsoft.graph.GroupPolicyConfiguration')
            Update-MgBetaDeviceManagementGroupPolicyConfiguration `
                -GroupPolicyConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters

            #Update Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/groupPolicyConfigurations'
            #endregion

            #Update DefinitionValues
            $currentDefinitionValues = @()
            $currentDefinitionValuesIds = @()
            if ($null -ne $currentInstance.DefinitionValues -and $currentInstance.DefinitionValues.Count -gt 0 )
            {
                [Array]$currentDefinitionValues = $currentInstance.DefinitionValues
                [Array]$currentDefinitionValuesIds = $currentDefinitionValues.definition.id
            }
            $targetDefinitionValues = @()
            $targetDefinitionValuesIds = @()
            if ($null -ne $this.DefinitionValues -and $this.DefinitionValues.Count -gt 0)
            {
                [Array]$targetDefinitionValues = Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $this.DefinitionValues
                [Array]$targetDefinitionValuesIds = $targetDefinitionValues.Definition.Id
            }

            $comparedDefinitionValues = Compare-Object `
                -ReferenceObject ($currentDefinitionValuesIds) `
                -DifferenceObject ($targetDefinitionValuesIds) `
                -IncludeEqual

            $definitionValuesToAdd = ($comparedDefinitionValues | Where-Object -FilterScript { $_.SideIndicator -eq '=>' }).InputObject
            $definitionValuesToRemove = ($comparedDefinitionValues | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
            $definitionValuesToCheck = ($comparedDefinitionValues | Where-Object -FilterScript { $_.SideIndicator -eq '==' }).InputObject
            #Write-Verbose ("Add: $($definitionValuesToAdd.Count) - Remove: $($definitionValuesToRemove.Count) - Check: $($definitionValuesToCheck.Count)")

            $formattedDefinitionValuesToAdd = @()
            foreach ($definitionValueId in $definitionValuesToAdd)
            {
                $definitionValue = $targetDefinitionValues | Where-Object -FilterScript { $_.Definition.Id -eq $definitionValueId }
                $definitionValue = Rename-M365DSCCimInstanceParameter -Properties $definitionValue -KeyMapping $keyToRename
                $complexPresentationValues = @()
                if ($null -ne $definitionValue.PresentationValues)
                {
                    foreach ($presentationValue in [Hashtable[]]$definitionValue.PresentationValues)
                    {
                        $value = $presentationValue.Clone()
                        $value = Rename-M365DSCCimInstanceParameter -Properties $value -KeyMapping $keyToRename
                        $this.RemoveForeignSubtypeProperties($value, @{
                                '#microsoft.graph.groupPolicyPresentationValueBoolean'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueDecimal'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueLongDecimal' = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueText'        = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueMultiText'   = @('values')
                                '#microsoft.graph.groupPolicyPresentationValueList'        = @('values')
                            })
                        $value.Add('presentation@odata.bind', "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')/presentations('$($presentationValue.presentationDefinitionId)')")
                        $value.Remove('PresentationDefinitionId')
                        $value.Remove('PresentationDefinitionLabel')
                        $value.Remove('id')
                        $complexPresentationValues += $value
                    }
                }
                $complexDefinitionValue = @{
                    'definition@odata.bind' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')"
                    enabled                 = $definitionValue.Enabled
                    presentationValues      = $complexPresentationValues
                }
                $formattedDefinitionValuesToAdd += $complexDefinitionValue
            }

            $formattedDefinitionValuesToUpdate = @()
            foreach ($definitionValueId in $definitionValuesToCheck)
            {
                $definitionValue = $targetDefinitionValues | Where-Object -FilterScript { $_.Definition.Id -eq $definitionValueId }
                $currentDefinitionValue = $currentDefinitionValues | Where-Object -FilterScript { $_.definition.id -eq $definitionValueId }
                $definitionValue = Rename-M365DSCCimInstanceParameter -Properties $definitionValue -KeyMapping $keyToRename
                $complexPresentationValues = @()
                if ($null -ne $definitionValue.PresentationValues)
                {
                    foreach ($presentationValue in [Hashtable[]]$definitionValue.PresentationValues)
                    {
                        $currentPresentationValue = $currentDefinitionValue.PresentationValues | Where-Object { $_.PresentationDefinitionId -eq $presentationValue.presentationDefinitionId }
                        $value = $presentationValue.Clone()
                        $value = Rename-M365DSCCimInstanceParameter -Properties $value -KeyMapping $keyToRename
                        $this.RemoveForeignSubtypeProperties($value, @{
                                '#microsoft.graph.groupPolicyPresentationValueBoolean'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueDecimal'     = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueLongDecimal' = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueText'        = @('value')
                                '#microsoft.graph.groupPolicyPresentationValueMultiText'   = @('values')
                                '#microsoft.graph.groupPolicyPresentationValueList'        = @('values')
                            })
                        $value.Add('presentation@odata.bind', "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')/presentations('$($presentationValue.presentationDefinitionId)')")
                        $value.Remove('PresentationDefinitionId')
                        $value.Remove('PresentationDefinitionLabel')
                        $value.Remove('id')
                        $value.Add('id', $currentPresentationValue.Id)
                        $complexPresentationValues += $value
                    }
                }
                $complexDefinitionValue = @{
                    id                      = $currentDefinitionValue.Id
                    'definition@odata.bind' = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl + "beta/deviceManagement/groupPolicyDefinitions('$($definitionValue.Definition.Id)')"
                    enabled                 = $definitionValue.Enabled
                    presentationValues      = $complexPresentationValues
                }
                $formattedDefinitionValuesToUpdate += $complexDefinitionValue
            }

            $formattedDefinitionValuesToRemove = @()
            foreach ($definitionValueId in $definitionValuesToRemove)
            {
                $formattedDefinitionValuesToremove += ($currentDefinitionValues | Where-Object { $_.definition.id -eq $definitionValueId }).id
            }

            $this.UpdateGroupPolicyDefinitionValue($currentInstance.Id, $formattedDefinitionValuesToAdd, $formattedDefinitionValuesToUpdate, $formattedDefinitionValuesToRemove)

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Administrative Template Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementGroupPolicyConfiguration -GroupPolicyConfigurationId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaDeviceManagementGroupPolicyConfiguration -Filter $this.Filter -All -ErrorAction Stop
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
                $Results = $this.GetForExport($params)
                $rawResults = $Results.Clone()

                if ($Results.DefinitionValues)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Definition'
                            CimInstanceName = 'MSFT_IntuneGroupPolicyDefinitionValueDefinition'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'PresentationValues'
                            CimInstanceName = 'MSFT_IntuneGroupPolicyDefinitionValuePresentationValue'
                            IsRequired      = $false
                        }
                        @{
                            Name            = 'KeyValuePairValues'
                            CimInstanceName = 'MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair'
                            IsRequired      = $false
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DefinitionValues `
                        -CIMInstanceName IntuneGroupPolicyDefinitionValue `
                        -ComplexTypeMapping $complexMapping
                    if ($complexTypeStringResult)
                    {
                        $Results.DefinitionValues = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DefinitionValues') | Out-Null
                    }
                }
                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'DefinitionValues', 'PresentationValues', 'KeyValuePairValues') `
                    -RawResults $rawResults

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
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*' -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
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

    # DefinitionValues carry read-only (Definition, presentationDefinitionLabel) and random (Id) keys that must not be compared.
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Id', 'PolicyConfigurationIngestionType')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                foreach ($side in @($DesiredValues, $CurrentValues))
                {
                    if ($null -ne $side.DefinitionValues)
                    {
                        $definitionValues = @(Get-M365DSCDRGComplexTypeToHashtable -ComplexObject $side.DefinitionValues)
                        foreach ($definitionValue in $definitionValues)
                        {
                            $definitionValue.Remove('Definition') | Out-Null
                            $definitionValue.Remove('Id') | Out-Null
                            foreach ($presentationValue in $definitionValue.PresentationValues)
                            {
                                $presentationValue.Remove('presentationDefinitionLabel') | Out-Null
                                $presentationValue.Remove('Id') | Out-Null
                            }
                        }
                        $side.DefinitionValues = $definitionValues
                    }
                }
                if ($ValuesToCheck.ContainsKey('DefinitionValues'))
                {
                    $ValuesToCheck.DefinitionValues = $DesiredValues.DefinitionValues
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [void] UpdateGroupPolicyDefinitionValue([System.String] $DeviceConfigurationPolicyId, [Array] $DefinitionValueToAdd, [Array] $DefinitionValueToUpdate, [Array] $DefinitionValueToRemove)
    {
        try
        {
            $Uri = "/beta/deviceManagement/groupPolicyConfigurations/$DeviceConfigurationPolicyId/updateDefinitionValues"
            $body = @{}
            $DefinitionValueToRemoveIds = @()
            if ($null -ne $DefinitionValueToRemove -and $DefinitionValueToRemove.Count -gt 0)
            {
                $DefinitionValueToRemoveIds = $DefinitionValueToRemove
            }
            $body = @{
                'added'      = $DefinitionValueToAdd
                'updated'    = $DefinitionValueToUpdate
                'deletedIds' = $DefinitionValueToRemoveIds
            }
            Invoke-M365DSCGraphRequest -Method POST -Uri $Uri -Body ($body | ConvertTo-Json -Depth 20) -ErrorAction Stop 4> $null
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    hidden [IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationAdministrativeTemplatePolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_IntuneGroupPolicyDefinitionValue
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies how the value should be configured. This can be either as a Policy or as a Preference. Possible values are: policy, preference.')]
    [ValidateSet('policy', 'preference')]
    [System.String] $ConfigurationType

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the associated group policy definition.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The associated group policy definition with the value. Read-Only.')]
    [MSFT_IntuneGroupPolicyDefinitionValueDefinition] $Definition

    [DscProperty()]
    [System.ComponentModel.Description('The associated group policy presentation values with the definition value.')]
    [MSFT_IntuneGroupPolicyDefinitionValuePresentationValue[]] $PresentationValues
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}

class MSFT_IntuneGroupPolicyDefinitionValueDefinition
{
    [DscProperty()]
    [System.ComponentModel.Description('The localized full category path for the policy.')]
    [System.String] $CategoryPath

    [DscProperty()]
    [System.ComponentModel.Description('Identifies the type of groups the policy can be applied to. Possible values are: user, machine.')]
    [ValidateSet('user', 'machine')]
    [System.String] $ClassType

    [DscProperty()]
    [System.ComponentModel.Description('The localized policy name.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The localized explanation or help text associated with the policy. The default value is empty.')]
    [System.String] $ExplainText

    [DscProperty()]
    [System.ComponentModel.Description('The category id of the parent category')]
    [System.String] $GroupPolicyCategoryId

    [DscProperty()]
    [System.ComponentModel.Description('Signifies whether or not there are related definitions to this definition')]
    [System.Nullable[System.Boolean]] $HasRelatedDefinitions

    [DscProperty()]
    [System.ComponentModel.Description('Minimum required CSP version for device configuration in this definition')]
    [System.String] $MinDeviceCspVersion

    [DscProperty()]
    [System.ComponentModel.Description('Minimum required CSP version for user configuration in this definition')]
    [System.String] $MinUserCspVersion

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the type of group policy. Possible values are: admxBacked, admxIngested.')]
    [ValidateSet('admxBacked', 'admxIngested')]
    [System.String] $PolicyType

    [DscProperty()]
    [System.ComponentModel.Description('Localized string used to specify what operating system or application version is affected by the policy.')]
    [System.String] $SupportedOn

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id
}

class MSFT_IntuneGroupPolicyDefinitionValuePresentationValue
{
    [DscProperty()]
    [System.ComponentModel.Description('A value for the associated presentation.')]
    [System.Nullable[System.Boolean]] $BooleanValue

    [DscProperty()]
    [System.ComponentModel.Description('A value for the associated presentation.')]
    [System.Nullable[System.UInt64]] $DecimalValue

    [DscProperty()]
    [System.ComponentModel.Description('A value for the associated presentation.')]
    [System.String] $StringValue

    [DscProperty()]
    [System.ComponentModel.Description('A list of pairs for the associated presentation.')]
    [MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair[]] $KeyValuePairValues

    [DscProperty()]
    [System.ComponentModel.Description('A list of pairs for the associated presentation.')]
    [System.String[]] $StringValues

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for presentation definition. Read-only.')]
    [System.String] $PresentationDefinitionId

    [DscProperty()]
    [System.ComponentModel.Description('The label of the presentation definition. Read-only.')]
    [System.String] $PresentationDefinitionLabel

    [DscProperty()]
    [System.ComponentModel.Description('A value for the associated presentation.')]
    [ValidateSet('#microsoft.graph.groupPolicyPresentationValueBoolean', '#microsoft.graph.groupPolicyPresentationValueDecimal', '#microsoft.graph.groupPolicyPresentationValueList', '#microsoft.graph.groupPolicyPresentationValueLongDecimal', '#microsoft.graph.groupPolicyPresentationValueMultiText', '#microsoft.graph.groupPolicyPresentationValueText')]
    [System.String] $odataType
}

class MSFT_IntuneGroupPolicyDefinitionValuePresentationValueKeyValuePair
{
    [DscProperty()]
    [System.ComponentModel.Description('Value for this key-value pair.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Name for this key-value pair.')]
    [System.String] $Name
}
