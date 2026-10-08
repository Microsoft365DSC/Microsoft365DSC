using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDefenderGlobalExclusionsPolicyLinux : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Global Exclusions')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2[]] $Exclusions

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

    [IntuneDefenderGlobalExclusionsPolicyLinux] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDefenderGlobalExclusionsPolicyLinux]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Defender Global Exclusions Policy for Linux with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
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
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Defender Global Exclusions Policy for Linux with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName)'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Defender Global Exclusions Policy for Linux with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Defender Global Exclusions Policy for Linux with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            #region resource generator code
            $complexExclusions = @()
            foreach ($exclusion in $policySettings.Exclusions)
            {
                $complexExclusion = [ordered]@{}
                $complexExclusion.Add('Exclusions_item_type', $exclusion.exclusions_item_type)
                $complexExclusion.Add('Exclusions_item_path', $exclusion.exclusions_item_path)
                $complexExclusion.Add('Exclusions_item_name', $exclusion.exclusions_item_name)
                $complexExclusion.Add('Exclusions_item_isDirectory', $exclusion.exclusions_item_isDirectory)
                $complexExclusions += $complexExclusion
            }
            $policySettings.Remove('Exclusions') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                Exclusions            = $complexExclusions
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
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            $results.Add('Assignments', $assignmentResult)

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

        Write-Verbose -Message "Setting configuration of the Intune Defender Global Exclusions Policy for Linux with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        # Convert MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2 to MSFT_MicrosoftGraphIntuneSettingsCatalogExclusions
        $convertedExclusions = @()
        foreach ($exclusion in $this.Exclusions)
        {
            $convertedExclusion = @{}
            if ($null -ne $exclusion.Exclusions_item_type)
            {
                $convertedExclusion.Add('Exclusions_item_type', $exclusion.Exclusions_item_type)
            }
            if ($null -ne $exclusion.Exclusions_item_path)
            {
                $convertedExclusion.Add('Exclusions_item_path', $exclusion.Exclusions_item_path)
            }
            if ($null -ne $exclusion.Exclusions_item_name)
            {
                $convertedExclusion.Add('Exclusions_item_name', $exclusion.Exclusions_item_name)
            }
            if ($null -ne $exclusion.Exclusions_item_isDirectory)
            {
                $convertedExclusion.Add('Exclusions_item_isDirectory', $exclusion.Exclusions_item_isDirectory)
            }
            $convertedExclusions += [MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2] $convertedExclusion
        }
        $boundParameters.Remove('Exclusions') | Out-Null
        $boundParameters.Add('Exclusions', $convertedExclusions)

        $templateReferenceId = 'dfa57610-d11d-4bf8-89d6-1f5cb1679506_1'
        $platforms = 'linux'
        $technologies = 'microsoftSense'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Defender Global Exclusions Policy for Linux with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Defender Global Exclusions Policy for Linux with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Defender Global Exclusions Policy for Linux with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
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
            $policyTemplateID = 'dfa57610-d11d-4bf8-89d6-1f5cb1679506_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
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
                    DisplayName           = $config.Name
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

                if ($null -ne $Results.Exclusions)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Exclusions `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogExclusionsV2'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Exclusions = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Exclusions') | Out-Null
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
                    -NoEscape @('Assignments', 'Exclusions') `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneDefenderGlobalExclusionsPolicyLinux] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDefenderGlobalExclusionsPolicyLinux])
        {
            return $Values
        }

        $result = [IntuneDefenderGlobalExclusionsPolicyLinux]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogExclusionsV2
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Type - (excludedPath: Path, excludedFileName: Process name)')]
    [ValidateSet('excludedPath', 'excludedFileName')]
    [System.String] $exclusions_item_type

    [DscProperty()]
    [System.ComponentModel.Description('Path')]
    [System.String] $exclusions_item_path

    [DscProperty()]
    [System.ComponentModel.Description('Process name')]
    [System.String] $exclusions_item_name

    [DscProperty()]
    [System.ComponentModel.Description('Is directory (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $exclusions_item_isDirectory
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
