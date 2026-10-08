using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneEpmElevationRulesPolicyWindows10 : M365DSCResourceBase
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
    [System.ComponentModel.Description('Elevation Rule Name')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName[]] $ElevationRuleName

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

    [IntuneEpmElevationRulesPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneEpmElevationRulesPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

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
            $rules = @()
            foreach ($rule in $policySettings.ElevationRuleName)
            {
                $complexElevationRuleName = [ordered]@{}
                $complexElevationRuleName.Add('ChildProcessBehavior', $rule.childProcessBehavior)
                $complexElevationRuleName.Add('FileName', $rule.fileName)
                $complexElevationRuleName.Add('Name', $rule.name)
                $complexElevationRuleName.Add('FilePath', $rule.filePath)
                $complexElevationRuleName.Add('ProductName', $rule.productName)
                $complexElevationRuleName.Add('AppliesTo', $rule.appliesTo)
                $complexElevationRuleName.Add('Description', $rule.description)
                $complexElevationRuleName.Add('FileVersion', $rule.fileVersion)
                $complexElevationRuleName.Add('InternalName', $rule.internalName)
                $complexElevationRuleName.Add('FileHash', $rule.fileHash)
                $complexElevationRuleName.Add('FileDescription', $rule.fileDescription)
                $complexElevationRuleName.Add('SignatureSource', [int]$rule.signatureSource)
                $complexElevationRuleName.Add('CertificateType', $rule.certificateType)
                if (-not [System.String]::IsNullOrEmpty($rule.certificatePayloadWithReusableSetting))
                {
                    $certificatePolicyId = $rule.certificatePayloadWithReusableSetting
                    $certificatePolicy = Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$certificatePolicyId" -Method GET -SkipHttpErrorCheck -ErrorAction SilentlyContinue
                    if ($certificatePolicy -is [hashtable] -and $certificatePolicy.ContainsKey('error'))
                    {
                        throw "Could not retrieve the certificate policy with id '$certificatePolicyId' as a reusable Setting for the Elevation Rule with DisplayName '$($rule.name)' in policy '$($getValue.Name)'."
                    }
                    $complexElevationRuleName.Add('CertificatePayloadWithReusableSetting', $certificatePolicy.displayName)
                }
                $complexElevationRuleName.Add('CertificateFileUpload', $rule.certificateFileUpload)
                $complexElevationRuleName.Add('Elevationtype', $rule.elevationtype)
                if ($rule.ContainsKey('UserConfirmedUserElevationTypeValidation'))
                {
                    $complexElevationRuleName.Add('UserConfirmedUserElevationTypeValidation', [int]$rule.userConfirmedUserElevationTypeValidation)
                }
                if ($rule.ContainsKey('ElevationTypeValidation'))
                {
                    $complexElevationRuleName.Add('ElevationTypeValidation', [int[]]$rule.elevationTypeValidation)
                }
                $complexElevationRuleName.Add('RestrictArguments', $rule.restrictArguments)
                $complexElevationRuleName.Add('ArgumentList', $rule.argumentList)
                if ($complexElevationRuleName.Values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $rules += $complexElevationRuleName
                }
            }
            $policySettings.Remove('ElevationRuleName') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                ElevationRuleName     = $rules
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

        Write-Verbose -Message "Setting configuration of the Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = 'cff02aad-51b1-498d-83ad-81161a393f56_1'
        $platforms = 'windows10'
        $technologies = 'endpointPrivilegeManagement'

        foreach ($rule in $boundParameters.ElevationRuleName)
        {
            # Resolve certificate policy display name back to id
            if (-not [System.String]::IsNullOrEmpty($rule.CertificatePayloadWithReusableSetting))
            {
                $certificatePolicy = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings?`$filter=displayName eq '$($rule.CertificatePayloadWithReusableSetting)'").value
                if ($null -eq $certificatePolicy -or $certificatePolicy.Count -eq 0)
                {
                    throw "Could not find a certificate policy with display name '$($rule.CertificatePayloadWithReusableSetting)'. Please create the certificate policy first and use its display name in the ElevationRuleName.CertificatePayloadWithReusableSetting property."
                }
                $rule.CertificatePayloadWithReusableSetting = $certificatePolicy.id
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Name {$($this.DisplayName)}"
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
            Write-Verbose -Message "Updating the Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($currentInstance.Id)}"
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
            Write-Verbose -Message "Removing the Intune Endpoint Privilege Management Elevation Rules Policy for Windows10 with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = 'cff02aad-51b1-498d-83ad-81161a393f56_1'
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

                if ($null -ne $Results.ElevationRuleName)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ElevationRuleName `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogElevationRuleName'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ElevationRuleName = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ElevationRuleName') | Out-Null
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
                    -NoEscape @('Assignments', 'ElevationRuleName') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            IncludedProperties = @('Elevationtype', 'FileName', 'Name')
        }
    }

    hidden [IntuneEpmElevationRulesPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneEpmElevationRulesPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneEpmElevationRulesPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogElevationRuleName
{
    [DscProperty()]
    [System.ComponentModel.Description('Child process behavior (allowrunelevated: AllowRunElevated, allowrunelevatedrulerequired: AllowRunElevatedRuleRequired, deny: Deny)')]
    [ValidateSet('allowrunelevated', 'allowrunelevatedrulerequired', 'deny')]
    [System.String] $ChildProcessBehavior

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('File name')]
    [System.String] $FileName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Rule name')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('File path')]
    [System.String] $FilePath

    [DscProperty()]
    [System.ComponentModel.Description('Product name')]
    [System.String] $ProductName

    [DscProperty()]
    [System.ComponentModel.Description('Applies to (allusers: Allusers)')]
    [ValidateSet('allusers')]
    [System.String] $AppliesTo

    [DscProperty()]
    [System.ComponentModel.Description('Description')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Minimum version')]
    [System.String] $FileVersion

    [DscProperty()]
    [System.ComponentModel.Description('Internal name')]
    [System.String] $InternalName

    [DscProperty()]
    [System.ComponentModel.Description('File hash. Required, if no certificate is used.')]
    [System.String] $FileHash

    [DscProperty()]
    [System.ComponentModel.Description('File description')]
    [System.String] $FileDescription

    [DscProperty()]
    [System.ComponentModel.Description('Signature source (0: ReusableCertificate, 1: NewCertificate)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SignatureSource

    [DscProperty()]
    [System.ComponentModel.Description('Certificate type (publisher: Publisher, issuingauthority: IssuingAuthority)')]
    [ValidateSet('publisher', 'issuingauthority')]
    [System.String] $CertificateType

    [DscProperty()]
    [System.ComponentModel.Description('Certificate')]
    [System.String] $CertificatePayloadWithReusableSetting

    [DscProperty()]
    [System.ComponentModel.Description('File upload')]
    [System.String] $CertificateFileUpload

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Elevation type (self: Userconfirmed, automatic: Automatic, deny: Deny, supportarbitrated: Supportapproved, userconfirmeduser: UserConfirmedUser)')]
    [ValidateSet('self', 'automatic', 'deny', 'supportarbitrated', 'userconfirmeduser')]
    [System.String] $Elevationtype

    [DscProperty()]
    [System.ComponentModel.Description('User Confirmed User Validation (2: Windows Authentication)')]
    [ValidateSet('2')]
    [System.Int32[]] $UserConfirmedUserElevationTypeValidation

    [DscProperty()]
    [System.ComponentModel.Description('Validation (1: Business Justification, 2: Windows Authentication)')]
    [ValidateSet('1', '2')]
    [System.Int32[]] $ElevationTypeValidation

    [DscProperty()]
    [System.ComponentModel.Description('Restrict Arguments (allow: Allow)')]
    [ValidateSet('allow')]
    [System.String] $RestrictArguments

    [DscProperty()]
    [System.ComponentModel.Description('Argument List')]
    [System.String[]] $ArgumentList
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
