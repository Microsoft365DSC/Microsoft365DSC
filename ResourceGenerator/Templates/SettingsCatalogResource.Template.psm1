using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class <ResourceName> : M365DSCResourceBase
{
<PropertyBlock>

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [<ResourceName>] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [<ResourceName>]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of <ResourceDescription> with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            $settings = $null
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                        -DeviceManagementConfigurationPolicyId $this.Id `
                        -ExpandProperty 'settings($expand=settingDefinitions)' `
                        -ErrorAction SilentlyContinue
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find a <ResourceDescription> with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find a <ResourceDescription> with Name {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "A <ResourceDescription> with Id {$resolvedId} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array] $settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings<ContainsDeviceAndUserSettingsFlag>

<SettingsConversionBlock>
            $result = @{
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = $getValue.RoleScopeTagIds
                Id                    = $getValue.Id
<SettingsComplexMappingBlock>
                Ensure                = 'Present'
<AuthResultBlock>
            }
            $result += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId -ErrorAction SilentlyContinue
            }
            $assignmentResult = @()
            if ($null -ne $assignmentsValues -and $assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            $result.Add('Assignments', $assignmentResult)

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of <ResourceDescription> with Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            $currentInstance = $this.Get().ToHashtable()
            $BoundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            $templateReferenceId = '<TemplateReferenceId>'
            $platforms = '<Platforms>'
            $technologies = '<Technologies>'

            if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating a <ResourceDescription> with Name {$($this.DisplayName)}"
                $BoundParameters.Remove('Assignments') | Out-Null

                $settings = Get-IntuneSettingCatalogPolicySetting `
                    -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
                    -TemplateId $templateReferenceId<ContainsDeviceAndUserSettingsFlag>

                $createParameters = @{
                    name              = $this.DisplayName
                    description       = $this.Description
                    templateReference = @{ templateId = $templateReferenceId }
                    platforms         = $platforms
                    technologies      = $technologies
                    settings          = $settings
                    roleScopeTagIds   = $this.RoleScopeTagIds
                }

                $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

                if ($policy.Id)
                {
                    $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                    Update-DeviceConfigurationPolicyAssignment `
                        -DeviceConfigurationPolicyId $policy.Id `
                        -Targets $assignmentsHash `
                        -Repository 'deviceManagement/configurationPolicies'
                }
            }
            elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating the <ResourceDescription> with Id {$($currentInstance.Id)}"
                $BoundParameters.Remove('Assignments') | Out-Null

                $settings = Get-IntuneSettingCatalogPolicySetting `
                    -DSCParams ([System.Collections.Hashtable]$BoundParameters) `
                    -TemplateId $templateReferenceId<ContainsDeviceAndUserSettingsFlag>

                Update-IntuneDeviceConfigurationPolicy `
                    -DeviceConfigurationPolicyId $currentInstance.Id `
                    -Name $this.DisplayName `
                    -Description $this.Description `
                    -TemplateReferenceId $templateReferenceId `
                    -Platforms $platforms `
                    -Technologies $technologies `
                    -Settings $settings `
                    -RoleScopeTagIds $this.RoleScopeTagIds

                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $currentInstance.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing the <ResourceDescription> with Id {$($currentInstance.Id)}"
                Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    # Settings-catalog properties compare through the shared base shim; base Test() splats this.
    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
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
            $policyTemplateID = '<TemplateReferenceId>'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array] $exportedInstances = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

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

                $displayedKey = $config.Id
                if (-not [System.String]::IsNullOrEmpty($config.Name))
                {
                    $displayedKey = $config.Name
                }
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite

                $Params = @{
                    Id          = $config.Id
                    DisplayName = $config.Name
<ExportAuthParameterBlock>
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

<ExportComplexToStringBlock>
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
                    -NoEscape @(<NoEscapeList>) `
                    -RawResults $rawResults
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [<ResourceName>] AsResult([System.Object] $Values)
    {
        if ($Values -is [<ResourceName>])
        {
            return $Values
        }

        $result = [<ResourceName>]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
<#IF CimInstanceClassBlock#>

<CimInstanceClassBlock>
<#ENDIF CimInstanceClassBlock#>
