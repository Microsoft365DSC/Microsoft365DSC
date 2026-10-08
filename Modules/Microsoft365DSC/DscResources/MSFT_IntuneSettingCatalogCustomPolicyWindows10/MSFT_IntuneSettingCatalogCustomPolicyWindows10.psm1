using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSettingCatalogCustomPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Platforms for this policy. Possible values are: none, android, iOS, macOS, windows10X, windows10, linux, unknownFutureValue.')]
    [ValidateSet('none', 'android', 'iOS', 'macOS', 'windows10X', 'windows10', 'linux', 'unknownFutureValue')]
    [System.String] $Platforms

    [DscProperty()]
    [System.ComponentModel.Description('Technologies for this policy. Possible values are: none, mdm, windows10XManagement, configManager, appleRemoteManagement, microsoftSense, exchangeOnline, edgeMAM, linuxMdm, enrollment, endpointPrivilegeManagement, unknownFutureValue.')]
    [ValidateSet('none', 'mdm', 'windows10XManagement', 'configManager', 'appleRemoteManagement', 'microsoftSense', 'exchangeOnline', 'linuxMdm', 'enrollment', 'endpointPrivilegeManagement', 'unknownFutureValue')]
    [System.String] $Technologies

    [DscProperty()]
    [System.ComponentModel.Description('Template reference information')]
    [MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference] $TemplateReference

    [DscProperty()]
    [System.ComponentModel.Description('Policy settings')]
    [MSFT_MicrosoftGraphdeviceManagementConfigurationSetting[]] $Settings

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneSettingCatalogCustomPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSettingCatalogCustomPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Setting Catalog Custom Policy for Windows10 with Id {$($this.Id)} and Name {$($this.Name)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            #region resource generator code
            if (-not [string]::IsNullOrEmpty($this.Id))
            {
                $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ExpandProperty 'settings' -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Setting Catalog Custom Policy for Windows10 with Id {$($this.Id)}"

                if (-not [string]::IsNullOrEmpty($this.Name))
                {
                    [array]$getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                        -All `
                        -Filter "Name eq '$($this.Name -replace "'", "''")' and Platforms eq 'windows10' and Technologies eq 'mdm' and TemplateReference/TemplateFamily eq 'none'" `
                        -ErrorAction SilentlyContinue

                    if ($getValue.Count -gt 1)
                    {
                        throw "Error: The displayName {$($this.Name)} is not unique in the tenant`r`nEnsure the display Name is unique for this type of resource."
                    }

                    if (-not [string]::IsNullOrEmpty($getValue.Id))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $getValue.Id -ExpandProperty 'settings' -ErrorAction SilentlyContinue
                    }
                }
            }
            #endregion
            if ([string]::IsNullOrEmpty($getValue.Id))
            {
                Write-Verbose -Message "Could not find an Intune Setting Catalog Custom Policy for Windows10 with Name {$($this.Name)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Setting Catalog Custom Policy for Windows10 with Id {$($resolvedId)} and Name {$($this.Name)} was found."

            $complexSettings = @()
            foreach ($currentSettings in $getValue.settings)
            {
                $complexSettingInstance = [hashtable]@{}
                if (-not([string]::IsNullOrEmpty($currentSettings.SettingInstance.'@odata.type')))
                {
                    $complexSettingInstance['odataType'] = $currentSettings.SettingInstance.'@odata.type'
                }
                if (-not([string]::IsNullOrEmpty($currentSettings.SettingInstance.settingDefinitionId)))
                {
                    $complexSettingInstance['SettingDefinitionId'] = $currentSettings.settingInstance.settingDefinitionId
                }
                if (-not([string]::IsNullOrEmpty($currentSettings.settingInstance.SettingInstanceTemplateReference.SettingInstanceTemplateId)))
                {
                    $complexSettingInstance['SettingInstanceTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                        'SettingInstanceTemplateId' = "$($currentSettings.settingInstance.SettingInstanceTemplateReference.SettingInstanceTemplateId)"
                    }
                }
                $valueName = $currentSettings.settingInstance.keys | Where-Object { @('ChoiceSettingCollectionValue', 'ChoiceSettingValue', 'GroupSettingCollectionValue', 'GroupSettingValue', 'SimpleSettingCollectionValue', 'SimpleSettingValue') -contains $_ }
                $rawValue = $currentSettings.settingInstance.$valueName
                $complexValue = $this.GetSettingValue($rawValue, $currentSettings.settingInstance.'@odata.type')
                $complexSettingInstance[$valueName] = $complexValue
                $complexSettings += [MSFT_MicrosoftGraphDeviceManagementConfigurationSetting] @{
                    'SettingInstance' = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] $complexSettingInstance
                }
            }

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                Name                  = $getValue.Name
                Platforms             = $getValue.Platforms
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Technologies          = $getValue.Technologies
                Settings              = $complexSettings
                Id                    = $getValue.Id
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
            $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $keysToRename = @{
            'odataType'   = '@odata.type'
            'StringValue' = 'value'
            'IntValue'    = 'value'
        }
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters -KeyMapping $keysToRename
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Setting Catalog Custom Policy for Windows10 with Name {$($this.Name)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.DeviceManagementConfigurationPolicy')
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.Id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Setting Catalog Custom Policy for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('TemplateReference') | Out-Null

            #region resource generator code
            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                @updateParameters

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Setting Catalog Custom Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('TemplateReference')
        }
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
            $baseFilter = "platforms eq 'windows10' and technologies eq 'mdm' and templateReference/templateFamily eq 'none'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                -Filter $mergedFilter `
                -All `
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
                if (-not [String]::IsNullOrEmpty($config.Name))
                {
                    $displayedKey = $config.Name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    Name                  = $config.Name
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

                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.Settings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'SettingInstance'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSettingInstance'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'SettingInstanceTemplateReference'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ChoiceSettingCollectionValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Children'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSettingInstance'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'SettingValueTemplateReference'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'ChoiceSettingValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'GroupSettingCollectionValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationGroupSettingValue'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'GroupSettingValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationGroupSettingValue'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'SimpleSettingCollectionValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'SimpleSettingValue'
                            CimInstanceName = 'MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Settings `
                        -CIMInstanceName 'MicrosoftGraphdeviceManagementConfigurationSetting' `
                        -ComplexTypeMapping $complexMapping `
                        -IsArray

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Settings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Settings') | Out-Null
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
                    -NoEscape @('Settings', 'Assignments') `
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

    hidden [System.Object] GetSettingValue([System.Object] $SettingValue, [System.String] $SettingValueType)
    {
        switch -Wildcard ($SettingValueType)
        {
            '*ChoiceSettingInstance'
            {
                $hash = [hashtable]@{}
                if ($SettingValue.Keys -contains '@odata.type' -and -not([string]::IsNullOrEmpty($SettingValue.'@odata.type')))
                {
                    $hash['odataType'] = $SettingValue.'@odata.type'
                }
                if ($SettingValue.Keys -contains 'value' -and -not([string]::IsNullOrEmpty($SettingValue.value)))
                {
                    $hash['Value'] = $SettingValue.value
                }
                if ($SettingValue.Keys -contains 'SettingValueTemplateReference')
                {
                    # MSFT_...SettingValueTemplateReference declares settingValueTemplateId, which is also
                    # the name Graph returns on a value. SettingInstanceTemplateId is the instance-side
                    # name and is not a member of that class, so the assignment threw.
                    if (-not [string]::IsNullOrEmpty($SettingValue.SettingValueTemplateReference.SettingValueTemplateId))
                    {
                        $hash['SettingValueTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                            'settingValueTemplateId' = "$($SettingValue.SettingValueTemplateReference.SettingValueTemplateId)"
                        }
                    }
                }
                if (-not [String]::IsNullOrEmpty($SettingValue.children))
                {
                    $children = @()
                    foreach ($child in $SettingValue.children)
                    {
                        $childHash = [hashtable]@{}
                        if (-not([string]::IsNullOrEmpty($child.'@odata.type')))
                        {
                            $childHash['odataType'] = $child.'@odata.type'
                        }
                        if (-not([string]::IsNullOrEmpty($child.settingDefinitionId)))
                        {
                            $childHash['SettingDefinitionId'] = $child.settingDefinitionId
                        }
                        # A child is a setting INSTANCE, so Graph gives it a
                        # settingInstanceTemplateReference/settingInstanceTemplateId pair. The value-side
                        # name is not a member of MSFT_...SettingInstance, so writing it here threw on the
                        # cast below the moment a child carried a template reference.
                        if (-not [string]::IsNullOrEmpty($child.SettingInstanceTemplateReference.SettingInstanceTemplateId))
                        {
                            $childHash['SettingInstanceTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                'SettingInstanceTemplateId' = "$($child.SettingInstanceTemplateReference.SettingInstanceTemplateId)"
                            }
                        }
                        $valueName = $child.keys | Where-Object { @('ChoiceSettingCollectionValue', 'ChoiceSettingValue', 'GroupSettingCollectionValue', 'GroupSettingValue', 'SimpleSettingCollectionValue', 'SimpleSettingValue') -contains $_ }
                        $rawValue = $child.$valueName
                        $childSettingValue = $this.GetSettingValue($rawValue, $child.'@odata.type')
                        # No per-value-name cast: every value property on the class below is already
                        # declared with its own type, so the hashtable-to-class conversion coerces a
                        # single instance or a collection to whatever that property expects.
                        $childHash.Add($valueName, $childSettingValue)
                        $complexChild = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] $childHash
                        $children += $complexChild
                    }
                    $hash['Children'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $children
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] $hash)
            }
            '*ChoiceSettingCollectionInstance'
            {
                $complexCollection = @()
                foreach ($item in $SettingValue)
                {
                    $complexCollection += $this.GetSettingValue($item, '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance')
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue[]] $complexCollection)
            }
            '*SimpleSettingInstance'
            {
                $hash = [hashtable]@{}
                if ($SettingValue.Keys -contains '@odata.type' -and -not([string]::IsNullOrEmpty($SettingValue.'@odata.type')))
                {
                    $hash['odataType'] = $SettingValue.'@odata.type'
                }
                if ($SettingValue.Keys -contains 'value' -and $null -ne $SettingValue.value)
                {
                    # Handle the case where the value is a string that only consists of whitespace characters
                    if ([System.String]::IsNullOrWhiteSpace($SettingValue.value))
                    {
                        $hash['StringValue'] = [string]$SettingValue.value
                    }
                    else
                    {
                        try
                        {
                            $hash['IntValue'] = [UInt32]($SettingValue.value)
                        }
                        catch
                        {
                            $hash['StringValue'] = [string]($SettingValue.value)
                        }
                    }
                }
                if ($SettingValue.Keys -contains 'ValueState' -and -not([string]::IsNullOrEmpty($SettingValue.ValueState)))
                {
                    $hash['ValueState'] = $SettingValue.ValueState
                }
                if ($SettingValue.Keys -contains 'SettingValueTemplateReference')
                {
                    # MSFT_...SettingValueTemplateReference declares settingValueTemplateId, which is also
                    # the name Graph returns on a value. SettingInstanceTemplateId is the instance-side
                    # name and is not a member of that class, so the assignment threw.
                    if (-not [string]::IsNullOrEmpty($SettingValue.SettingValueTemplateReference.SettingValueTemplateId))
                    {
                        $hash['SettingValueTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                            'settingValueTemplateId' = "$($SettingValue.SettingValueTemplateReference.SettingValueTemplateId)"
                        }
                    }
                }
                if (-not [String]::IsNullOrEmpty($SettingValue.children))
                {
                    $children = @()
                    foreach ($child in $SettingValue.children)
                    {
                        $childHash = [hashtable]@{}
                        if (-not([string]::IsNullOrEmpty($child.'@odata.type')))
                        {
                            $childHash['odataType'] = $child.'@odata.type'
                        }
                        if (-not([string]::IsNullOrEmpty($child.settingDefinitionId)))
                        {
                            $childHash['SettingDefinitionId'] = $child.settingDefinitionId
                        }
                        # A child is a setting INSTANCE, so Graph gives it a
                        # settingInstanceTemplateReference/settingInstanceTemplateId pair. The value-side
                        # name is not a member of MSFT_...SettingInstance, so writing it here threw on the
                        # cast below the moment a child carried a template reference.
                        if (-not [string]::IsNullOrEmpty($child.SettingInstanceTemplateReference.SettingInstanceTemplateId))
                        {
                            $childHash['SettingInstanceTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                'SettingInstanceTemplateId' = "$($child.SettingInstanceTemplateReference.SettingInstanceTemplateId)"
                            }
                        }
                        $valueName = $child.keys | Where-Object { @('ChoiceSettingCollectionValue', 'ChoiceSettingValue', 'GroupSettingCollectionValue', 'GroupSettingValue', 'SimpleSettingCollectionValue', 'SimpleSettingValue') -contains $_ }
                        $rawValue = $child.$valueName
                        $childSettingValue = $this.GetSettingValue($rawValue, $child.'@odata.type')
                        # No per-value-name cast: every value property on the class below is already
                        # declared with its own type, so the hashtable-to-class conversion coerces a
                        # single instance or a collection to whatever that property expects.
                        $childHash.Add($valueName, $childSettingValue)
                        $complexChild = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] $childHash
                        $children += $complexChild
                    }
                    $hash['Children'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $children
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] $hash)

            }
            '*SimpleSettingCollectionInstance'
            {
                $complexCollection = @()
                foreach ($item in $SettingValue)
                {
                    $complexCollection += $this.GetSettingValue($item, '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance')
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue[]] $complexCollection)
            }
            '*GroupSettingInstance'
            {
                $hash = [hashtable]@{}
                if ($SettingValue.Keys -contains '@odata.type' -and -not([string]::IsNullOrEmpty($SettingValue.'@odata.type')))
                {
                    $hash['odataType'] = $SettingValue.'@odata.type'
                }
                if ($SettingValue.Keys -contains 'value' -and -not([string]::IsNullOrEmpty($SettingValue.value)))
                {
                    $hash['Value'] = $SettingValue.value
                }
                if ($SettingValue.Keys -contains 'SettingValueTemplateReference')
                {
                    # MSFT_...SettingValueTemplateReference declares settingValueTemplateId, which is also
                    # the name Graph returns on a value. SettingInstanceTemplateId is the instance-side
                    # name and is not a member of that class, so the assignment threw.
                    if (-not [string]::IsNullOrEmpty($SettingValue.SettingValueTemplateReference.SettingValueTemplateId))
                    {
                        $hash['SettingValueTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] @{
                            'settingValueTemplateId' = "$($SettingValue.SettingValueTemplateReference.SettingValueTemplateId)"
                        }
                    }
                }
                if (-not [String]::IsNullOrEmpty($SettingValue.children))
                {
                    $children = @()
                    foreach ($child in $SettingValue.children)
                    {
                        $childHash = [hashtable]@{}
                        if (-not([string]::IsNullOrEmpty($child.'@odata.type')))
                        {
                            $childHash['odataType'] = $child.'@odata.type'
                        }
                        if (-not([string]::IsNullOrEmpty($child.settingDefinitionId)))
                        {
                            $childHash['SettingDefinitionId'] = $child.settingDefinitionId
                        }
                        # A child is a setting INSTANCE, so Graph gives it a
                        # settingInstanceTemplateReference/settingInstanceTemplateId pair. The value-side
                        # name is not a member of MSFT_...SettingInstance, so writing it here threw on the
                        # cast below the moment a child carried a template reference.
                        if (-not [string]::IsNullOrEmpty($child.SettingInstanceTemplateReference.SettingInstanceTemplateId))
                        {
                            $childHash['SettingInstanceTemplateReference'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] @{
                                'SettingInstanceTemplateId' = "$($child.SettingInstanceTemplateReference.SettingInstanceTemplateId)"
                            }
                        }
                        $valueName = $child.keys | Where-Object { @('ChoiceSettingCollectionValue', 'ChoiceSettingValue', 'GroupSettingCollectionValue', 'GroupSettingValue', 'SimpleSettingCollectionValue', 'SimpleSettingValue') -contains $_ }
                        $rawValue = $child.$valueName
                        $childSettingValue = $this.GetSettingValue($rawValue, $child.'@odata.type')
                        # No per-value-name cast: every value property on the class below is already
                        # declared with its own type, so the hashtable-to-class conversion coerces a
                        # single instance or a collection to whatever that property expects.
                        $childHash.Add($valueName, $childSettingValue)
                        $complexChild = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] $childHash
                        $children += $complexChild
                    }
                    $hash['Children'] = [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $children
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] $hash)

            }
            '*GroupSettingCollectionInstance'
            {
                $complexCollection = @()
                foreach ($item in $SettingValue)
                {
                    $complexCollection += $this.GetSettingValue($item, '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance')
                }
                return ([MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue[]] $complexCollection)
            }
        }

        return $null
    }

    hidden [IntuneSettingCatalogCustomPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSettingCatalogCustomPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneSettingCatalogCustomPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphdeviceManagementConfigurationPolicyTemplateReference
{
    [DscProperty()]
    [System.ComponentModel.Description('Template Display Name of the referenced template. This property is read-only.')]
    [System.String] $TemplateDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Template Display Version of the referenced Template. This property is read-only.')]
    [System.String] $TemplateDisplayVersion

    [DscProperty()]
    [System.ComponentModel.Description('Template Family of the referenced Template. This property is read-only. Possible values are: none, endpointSecurityAntivirus, endpointSecurityDiskEncryption, endpointSecurityFirewall, endpointSecurityEndpointDetectionAndResponse, endpointSecurityAttackSurfaceReduction, endpointSecurityAccountProtection, endpointSecurityApplicationControl, endpointSecurityEndpointPrivilegeManagement, enrollmentConfiguration, appQuietTime, baseline, unknownFutureValue, deviceConfigurationScripts.')]
    [ValidateSet('none', 'endpointSecurityAntivirus', 'endpointSecurityDiskEncryption', 'endpointSecurityFirewall', 'endpointSecurityEndpointDetectionAndResponse', 'endpointSecurityAttackSurfaceReduction', 'endpointSecurityAccountProtection', 'endpointSecurityApplicationControl', 'endpointSecurityEndpointPrivilegeManagement', 'enrollmentConfiguration', 'appQuietTime', 'baseline', 'unknownFutureValue', 'deviceConfigurationScripts')]
    [System.String] $TemplateFamily

    [DscProperty()]
    [System.ComponentModel.Description('Template id')]
    [System.String] $TemplateId
}

class MSFT_MicrosoftGraphdeviceManagementConfigurationSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('Setting Instance')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance] $SettingInstance

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id
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

class MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance
{
    [DscProperty()]
    [System.ComponentModel.Description('Setting Definition Id')]
    [System.String] $SettingDefinitionId

    [DscProperty()]
    [System.ComponentModel.Description('Setting Instance Template Reference')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference] $SettingInstanceTemplateReference

    [DscProperty()]
    [System.ComponentModel.Description('Choice setting collection value')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue[]] $ChoiceSettingCollectionValue

    [DscProperty()]
    [System.ComponentModel.Description('Choice setting value')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue] $ChoiceSettingValue

    [DscProperty()]
    [System.ComponentModel.Description('A collection of GroupSetting values')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue[]] $GroupSettingCollectionValue

    [DscProperty()]
    [System.ComponentModel.Description('GroupSetting value')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue] $GroupSettingValue

    [DscProperty()]
    [System.ComponentModel.Description('Simple setting collection instance value')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue[]] $SimpleSettingCollectionValue

    [DscProperty()]
    [System.ComponentModel.Description('Simple setting instance value')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue] $SimpleSettingValue

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.deviceManagementConfigurationChoiceSettingCollectionInstance', '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance', '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance', '#microsoft.graph.deviceManagementConfigurationGroupSettingInstance', '#microsoft.graph.deviceManagementConfigurationSettingGroupCollectionInstance', '#microsoft.graph.deviceManagementConfigurationSettingGroupInstance', '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance', '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstanceTemplateReference
{
    [DscProperty()]
    [System.ComponentModel.Description('Setting instance template id')]
    [System.String] $SettingInstanceTemplateId
}

class MSFT_MicrosoftGraphDeviceManagementConfigurationChoiceSettingValue
{
    [DscProperty()]
    [System.ComponentModel.Description('Child settings.')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $Children

    [DscProperty()]
    [System.ComponentModel.Description('Choice setting value: an OptionDefinition ItemId.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Setting value template reference')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] $SettingValueTemplateReference

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.deviceManagementConfigurationChoiceSettingValue', '#microsoft.graph.deviceManagementConfigurationGroupSettingValue', '#microsoft.graph.deviceManagementConfigurationSimpleSettingValue')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphDeviceManagementConfigurationGroupSettingValue
{
    [DscProperty()]
    [System.ComponentModel.Description('Collection of child setting instances contained within this GroupSetting')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $Children

    [DscProperty()]
    [System.ComponentModel.Description('Setting value template reference')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] $SettingValueTemplateReference

    [DscProperty()]
    [System.ComponentModel.Description('Choice setting value: an OptionDefinition ItemId.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.deviceManagementConfigurationChoiceSettingValue', '#microsoft.graph.deviceManagementConfigurationGroupSettingValue', '#microsoft.graph.deviceManagementConfigurationSimpleSettingValue')]
    [System.String] $odataType
}

class MSFT_MicrosoftGraphDeviceManagementConfigurationSimpleSettingValue
{
    [DscProperty()]
    [System.ComponentModel.Description('Value of the integer setting.')]
    [System.Nullable[System.UInt32]] $IntValue

    [DscProperty()]
    [System.ComponentModel.Description('Value of the string setting.')]
    [System.String] $StringValue

    [DscProperty()]
    [System.ComponentModel.Description('Gets or sets a value indicating the encryption state of the Value property. Possible values are: invalid, notEncrypted, encryptedValueToken.')]
    [ValidateSet('invalid', 'notEncrypted', 'encryptedValueToken')]
    [System.String] $ValueState

    [DscProperty()]
    [System.ComponentModel.Description('The type of the entity.')]
    [ValidateSet('#microsoft.graph.deviceManagementConfigurationIntegerSettingValue', '#microsoft.graph.deviceManagementConfigurationStringSettingValue', '#microsoft.graph.deviceManagementConfigurationSecretSettingValue')]
    [System.String] $odataType

    [DscProperty()]
    [System.ComponentModel.Description('Setting value template reference')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference] $SettingValueTemplateReference

    [DscProperty()]
    [System.ComponentModel.Description('Child settings.')]
    [MSFT_MicrosoftGraphDeviceManagementConfigurationSettingInstance[]] $Children
}

class MSFT_MicrosoftGraphDeviceManagementConfigurationSettingValueTemplateReference
{
    [DscProperty()]
    [System.ComponentModel.Description('Setting value template id')]
    [System.String] $settingValueTemplateId

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether to update policy setting value to match template setting default value')]
    [System.Nullable[System.Boolean]] $useTemplateDefault
}
