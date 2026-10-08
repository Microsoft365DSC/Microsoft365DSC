using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneFirewallPolicySetting : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The Firewall policy settings.')]
    [MSFT_ReusableFirewallPolicySetting[]] $PolicySettings

    [DscProperty()]
    [System.ComponentModel.Description('Description of the setting.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the setting.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    IntuneFirewallPolicySetting() : base()
    {
        $this.ResourceCache['PropertiesToRetrieve'] =  @('id', 'displayName', 'description', 'settingDefinitionId', 'settingInstance')
    }

    [IntuneFirewallPolicySetting] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneFirewallPolicySetting]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Firewall Policy Setting with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    $getValue = Invoke-M365DSCGraphRequest `
                        -Uri "/beta/deviceManagement/reusablePolicySettings/$($this.Id)?`$select=$($this.ResourceCache['PropertiesToRetrieve'] -join ',')" `
                        -Method GET `
                        -SkipHttpErrorCheck `
                        -ErrorAction SilentlyContinue
                    if ($getValue -is [hashtable] -and $getValue.ContainsKey('error'))
                    {
                        # Policy does not exist, set it to $null
                        $getValue = $null
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Policy Setting with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings?`$filter=DisplayName eq '$($this.DisplayName -replace "'", "''")' and settingDefinitionId eq 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}'&select=$($this.ResourceCache['PropertiesToRetrieve'] -join ',')" `
                            -Method GET `
                            -SkipHttpErrorCheck `
                            -ErrorAction SilentlyContinue).value
                        if ($getValue -is [array] -and $getValue.Count -eq 0)
                        {
                            $getValue = $null
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Policy Setting with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Firewall Policy Setting with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            $reusableSettings = @()
            foreach ($groupSetting in $getValue.settingInstance.groupSettingCollectionValue)
            {
                $autoResolveObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_autoresolve' }
                $autoResolveValue = [System.Boolean]::Parse($autoResolveObject.choiceSettingValue.value.Split('_')[-1])
                $keywordObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_keyword' }
                $policySetting = @{
                    AutoResolve = $autoResolveValue
                    Keyword     = $keywordObject.simpleSettingValue.value
                }

                if (-not $autoResolveValue)
                {
                    $addressObject = $autoResolveObject.choiceSettingValue.children.simpleSettingCollectionValue.value
                    $policySetting.Add('Addresses', $addressObject)
                }
                $reusableSettings += $policySetting
            }

            $results = @{
                #region resource generator code
                Description           = $getValue.description
                DisplayName           = $getValue.displayName
                Id                    = $getValue.id
                PolicySettings        = $reusableSettings
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

        Write-Verbose -Message "Setting configuration of the Intune Firewall Policy Setting with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = @{
            '@odata.type'       = '#microsoft.graph.deviceManagementReusablePolicySetting'
            description         = "$($this.Description)"
            displayName         = "$($this.DisplayName)"
            id                  = $currentInstance.Id
            settingDefinitionId = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}'
            settingInstance     = @{
                '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                settingDefinitionId         = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}'
                groupSettingCollectionValue = @()
            }
        }

        foreach ($policySetting in $this.PolicySettings)
        {
            $groupSettingCollectionChildren = @()

            $autoResolveChildren = @()
            if (-not $policySetting.AutoResolve)
            {
                $autoResolveChild += @{
                    '@odata.type'                = '#microsoft.graph.deviceManagementConfigurationSimpleSettingCollectionInstance'
                    settingDefinitionId          = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_addresses'
                    simpleSettingCollectionValue = @()
                }
                foreach ($address in $policySetting.Addresses)
                {
                    $autoResolveChild.simpleSettingCollectionValue += @{
                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                        value         = $address
                    }
                }
                $autoResolveChildren += $autoResolveChild
            }

            $autoResolveValue = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_autoresolve_' + $policySetting.AutoResolve.ToString().ToLower()
            $autoResolveObject = @{
                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                settingDefinitionId = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_autoresolve'
                choiceSettingValue  = @{
                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue'
                    value         = $autoResolveValue
                    children      = $autoResolveChildren
                }
            }
            $groupSettingCollectionChildren += $autoResolveObject

            $keywordObject = @{
                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                settingDefinitionId = 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}_keyword'
                simpleSettingValue  = @{
                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                    value         = $policySetting.Keyword
                }
            }
            $groupSettingCollectionChildren += $keywordObject

            $boundParameters.settingInstance.groupSettingCollectionValue += @{
                children = $groupSettingCollectionChildren
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Firewall Policy Setting with Name {$($this.DisplayName)}"

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $null = Invoke-M365DSCGraphRequest -Uri '/beta/deviceManagement/reusablePolicySettings' -Method POST -Body $($createParameters | ConvertTo-Json -Depth 10)
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Firewall Policy Setting with Id {$($currentInstance.Id)}"

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Id = $currentInstance.Id

            #region resource generator code
            Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method PUT -Body $($updateParameters | ConvertTo-Json -Depth 10)
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Firewall Policy Setting with Id {$($currentInstance.Id)}"
            #region resource generator code
            try
            {
                Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method DELETE
            }
            catch
            {
                $errorMessage = "Failed to remove the Intune Firewall Policy Setting with Id {$($currentInstance.Id)} and Name {$($currentInstance.DisplayName)}."
                $errorMessage += ' Please make sure it is not referenced by a Firewall policy.'
                throw $errorMessage
            }
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
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'reusablePolicySettings' `
                -PropertyName 'settingDefinitionId' `
                -PropertyValue 'vendor_msft_firewall_mdmstore_dynamickeywords_addresses_{id}' `
                -Filter $this.Filter
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

                if ($Results.PolicySettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.PolicySettings -CIMInstanceName ReusableFirewallPolicySetting
                    if ($complexTypeStringResult)
                    {
                        $Results.PolicySettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PolicySettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('PolicySettings')
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
            IncludedProperties = @('PolicySettings', 'Addresses', 'AutoResolve', 'Keyword')
        }
    }

    hidden [IntuneFirewallPolicySetting] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneFirewallPolicySetting])
        {
            return $Values
        }

        $result = [IntuneFirewallPolicySetting]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_ReusableFirewallPolicySetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The addresses to resolve. Required, if AutoResolve is set to ''False''.')]
    [System.String[]] $Addresses

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('If the Firewall service should automatically resolve the IP addresses.')]
    [System.Nullable[System.Boolean]] $AutoResolve

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The identifier of the reusable firewall policy setting.')]
    [System.String] $Keyword
}
