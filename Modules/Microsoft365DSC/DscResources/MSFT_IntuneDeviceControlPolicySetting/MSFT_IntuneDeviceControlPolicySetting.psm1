using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceControlPolicySetting : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The match type of the policy settings. Possible values: Any, All')]
    [ValidateSet('Any', 'All')]
    [System.String] $MatchType

    [DscProperty()]
    [System.ComponentModel.Description('The Printer Device Control policy settings.')]
    [MSFT_ReusablePrinterDeviceControlPolicySetting[]] $PrinterPolicySettings

    [DscProperty()]
    [System.ComponentModel.Description('The Storage Device Control policy settings.')]
    [MSFT_ReusableStorageDeviceControlPolicySetting[]] $StoragePolicySettings

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

    IntuneDeviceControlPolicySetting() : base()
    {
        $this.ResourceCache['PropertiesToRetrieve'] =  @('id', 'displayName', 'description', 'settingDefinitionId', 'settingInstance')
    }

    [IntuneDeviceControlPolicySetting] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceControlPolicySetting]::new()
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
                        $getValue = (Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings?`$filter=DisplayName eq '$($this.DisplayName -replace "'", "''")' and settingDefinitionId eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata'&select=$($this.ResourceCache['PropertiesToRetrieve'] -join ',')" `
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

            $groupObject = $getValue.settingInstance.groupSettingCollectionValue[0]
            $groupSettingsObject = $groupObject.children | Where-Object { $_.settingDefinitionId -like '*descriptoridlist' -or $_.settingDefinitionId -like '*printerdevicesidlist' }
            $matchObject = $groupObject.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_matchtype' }

            $storageReusableSettings = @()
            $printerReusableSettings = @()
            foreach ($groupSetting in $groupSettingsObject.groupSettingCollectionValue)
            {
                if ($groupSetting.children[0].settingDefinitionId -like '*descriptoridlist*')
                {
                    $serialNumberIdObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_serialnumberid' }
                    $deviceIdObject       = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_deviceid' }
                    $pidObject            = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_pid' }
                    $vidObject            = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_vid' }
                    $hardwareIdObject     = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_hardwareid' }
                    $instancePathIdObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_instancepathid' }
                    $friendlyNameIdObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_friendlynameid' }
                    $nameObject           = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_name' }
                    $busIdObject          = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_busid' }
                    $primaryIdObject      = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_primaryid' }
                    $vid_PidObject        = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_vid_pid' }

                    $policySetting = [ordered]@{
                        BusId          = $busIdObject.simpleSettingValue.value
                        DeviceId       = $deviceIdObject.simpleSettingValue.value
                        FriendlyNameId = $friendlyNameIdObject.simpleSettingValue.value
                        HardwareId     = $hardwareIdObject.simpleSettingValue.value
                        InstancePathId = $instancePathIdObject.simpleSettingValue.value
                        Name           = $nameObject.simpleSettingValue.value
                        PID            = $pidObject.simpleSettingValue.value
                        PrimaryId      = $primaryIdObject.simpleSettingValue.value
                        SerialNumberId = $serialNumberIdObject.simpleSettingValue.value
                        VID            = $vidObject.simpleSettingValue.value
                        VID_PID        = $vid_PidObject.simpleSettingValue.value
                    }
                    $policySetting.Keys.Clone().GetEnumerator() | ForEach-Object {
                        if ([System.String]::IsNullOrEmpty($policySetting.$_))
                        {
                            $policySetting.Remove($_) | Out-Null
                        }
                    }
                    $storageReusableSettings += $policySetting
                }
                else
                {
                    $friendlyNameIdObject      = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_friendlynameid' }
                    $nameObject                = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_name' }
                    $printerConnectionIdObject = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_printerconnectionid' }
                    $primaryIdObject           = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_primaryid' }
                    $vid_PidObject             = $groupSetting.children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_vid_pid' }

                    $policySetting = [ordered]@{
                        FriendlyNameId      = $friendlyNameIdObject.simpleSettingValue.value
                        Name                = $nameObject.simpleSettingValue.value
                        PrinterConnectionId = [System.Int32]::Parse($printerConnectionIdObject.choiceSettingValue.value.Split('_')[-1])
                        PrimaryId           = [System.Int32]::Parse($primaryIdObject.choiceSettingValue.value.Split('_')[-1])
                        VID_PID             = $vid_PidObject.simpleSettingValue.value
                    }
                    $policySetting.Keys.Clone().GetEnumerator() | ForEach-Object {
                        if ([System.String]::IsNullOrEmpty($policySetting.$_))
                        {
                            $policySetting.Remove($_) | Out-Null
                        }
                    }
                    $printerReusableSettings += $policySetting
                }
            }

            $results = @{
                #region resource generator code
                Description           = $getValue.description
                DisplayName           = $getValue.displayName
                Id                    = $getValue.id
                MatchType             = $matchObject.choiceSettingValue.value.Split('_')[-1].Replace('matcha', 'A')
                PrinterPolicySettings = $printerReusableSettings
                StoragePolicySettings = $storageReusableSettings
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

        if ($this.Ensure -eq 'Absent')
        {
            if ($currentInstance.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing the Intune Device Control Policy Setting with Id {$($currentInstance.Id)}"
                try
                {
                    Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method DELETE
                }
                catch
                {
                    $errorMessage = "Failed to remove the Intune Device Control Policy Setting with Id {$($currentInstance.Id)} and Name {$($currentInstance.DisplayName)}."
                    $errorMessage += ' Please make sure it is not referenced by a Device Control policy.'
                    throw $errorMessage
                }
            }
            return
        }

        $boundParameters = @{
            description         = "$($this.Description)"
            displayName         = "$($this.DisplayName)"
            id                  = $currentInstance.Id
            settingDefinitionId = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata'
            settingInstance     = @{
                '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
                settingDefinitionId         = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata'
                groupSettingCollectionValue = @(
                    @{
                        children = @(
                            @{
                                '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                                settingDefinitionId = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_matchtype'
                                choiceSettingValue  = @{
                                    '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue'
                                    value         = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_matchtype_match' + $this.MatchType.ToLower()
                                }
                            }
                        )
                    }
                )
            }
        }

        $storageSettings = @{
            '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
            settingDefinitionId         = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist'
            groupSettingCollectionValue = @()
        }
        $printerSettings = @{
            '@odata.type'               = '#microsoft.graph.deviceManagementConfigurationGroupSettingCollectionInstance'
            settingDefinitionId         = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist'
            groupSettingCollectionValue = @()
        }

        foreach ($policySetting in $this.PrinterPolicySettings)
        {
            $policySettingInitializer = @{
                children = @()
            }
            foreach ($property in $policySetting.PSObject.Properties.GetEnumerator())
            {
                if ($property.Name -in @('FriendlyNameId', 'Name', 'VID_PID'))
                {
                    $policySettingInitializer.children += @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                        settingDefinitionId = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_' + $property.Name.ToLower()
                        simpleSettingValue  = @{
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                            value         = $property.Value
                        }
                    }
                }
                else
                {
                    $policySettingInitializer.children += @{
                        '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationChoiceSettingInstance'
                        settingDefinitionId = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_' + $property.Name.ToLower()
                        choiceSettingValue  = @{
                            '@odata.type' = '#microsoft.graph.deviceManagementConfigurationChoiceSettingValue'
                            children      = @()
                            value         = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_printerdevicesidlist_' + $property.Name.ToLower() + '_' + $property.Value
                        }
                    }
                }
            }
            $printerSettings.groupSettingCollectionValue += $policySettingInitializer
        }

        foreach ($policySetting in $this.StoragePolicySettings)
        {
            $policySettingInitializer = @{
                children = @()
            }
            foreach ($property in $policySetting.PSObject.Properties.GetEnumerator())
            {
                $policySettingInitializer.children += @{
                    '@odata.type'       = '#microsoft.graph.deviceManagementConfigurationSimpleSettingInstance'
                    settingDefinitionId = 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_descriptoridlist_' + $property.Name.ToLower()
                    simpleSettingValue  = @{
                        '@odata.type' = '#microsoft.graph.deviceManagementConfigurationStringSettingValue'
                        value         = $property.Value
                    }
                }
            }
            $storageSettings.groupSettingCollectionValue += $policySettingInitializer
        }

        if ($storageSettings.groupSettingCollectionValue.Count -gt 0)
        {
            $boundParameters.settingInstance.groupSettingCollectionValue[0].children += $storageSettings
        }

        if ($printerSettings.groupSettingCollectionValue.Count -gt 0)
        {
            $boundParameters.settingInstance.groupSettingCollectionValue[0].children += $printerSettings
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Firewall Policy Setting with Name {$($this.DisplayName)}"
            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $null = Invoke-M365DSCGraphRequest -Uri '/beta/deviceManagement/reusablePolicySettings' -Method POST -Body $($createParameters | ConvertTo-Json -Depth 20)
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Firewall Policy Setting with Id {$($currentInstance.Id)}"
            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Invoke-M365DSCGraphRequest -Uri "/beta/deviceManagement/reusablePolicySettings/$($currentInstance.Id)" -Method PUT -Body $($updateParameters | ConvertTo-Json -Depth 20)
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
                -PropertyValue 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata' `
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
                $matchObject = $config.settingInstance.groupSettingCollectionValue[0].children | Where-Object { $_.settingDefinitionId -eq 'device_vendor_msft_defender_configuration_devicecontrol_policygroups_{groupid}_groupdata_matchtype' }
                $matchTypeValue = $matchObject.choiceSettingValue.value.Split('_')[-1].Replace('matcha', 'A')
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    MatchType             = $matchTypeValue
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

                if ($Results.PrinterPolicySettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.PrinterPolicySettings -CIMInstanceName ReusablePrinterDeviceControlPolicySetting -IsArray
                    if ($complexTypeStringResult)
                    {
                        $Results.PrinterPolicySettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PrinterPolicySettings') | Out-Null
                    }
                }

                if ($Results.StoragePolicySettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.StoragePolicySettings -CIMInstanceName ReusableStorageDeviceControlPolicySetting -IsArray
                    if ($complexTypeStringResult)
                    {
                        $Results.StoragePolicySettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('StoragePolicySettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('PrinterPolicySettings', 'StoragePolicySettings')
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
            IncludedProperties = @('MatchType', 'Name')
        }
    }

    hidden [IntuneDeviceControlPolicySetting] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceControlPolicySetting])
        {
            return $Values
        }

        $result = [IntuneDeviceControlPolicySetting]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_ReusablePrinterDeviceControlPolicySetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The Friendly Name of the device. Example is ''Generic Printer''.')]
    [System.String] $FriendlyNameId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The identifier of the reusable policy setting.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Primary ID of the device. Possible values are: 0: Printer Devices')]
    [ValidateSet('0')]
    [System.Nullable[System.Int32]] $PrimaryId

    [DscProperty()]
    [System.ComponentModel.Description('The Printer Connection Id. Possible values are: 0: USB, 1: Corporate, 2: Network, 3: Universal, 4: File, 5: Custom, 6: Local.')]
    [ValidateSet('0', '1', '2', '3', '4', '5', '6')]
    [System.Nullable[System.Int32]] $PrinterConnectionId

    [DscProperty()]
    [System.ComponentModel.Description('The combination of Vendor and Product ID. Example is ''0000_1111.')]
    [System.String] $VID_PID
}

class MSFT_ReusableStorageDeviceControlPolicySetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The Bus ID of the logical bus where the device is connected to. Examples are USB, SCSI.')]
    [System.String] $BusId

    [DscProperty()]
    [System.ComponentModel.Description('The Device ID of the device.')]
    [System.String] $DeviceId

    [DscProperty()]
    [System.ComponentModel.Description('The Friendly Name of the device. Example is ''Generic Flash Disk USB Device''.')]
    [System.String] $FriendlyNameId

    [DscProperty()]
    [System.ComponentModel.Description('The Hardware ID of the device. Example is ''USBSTOR\\DiskGeneric_Flash_Disk___8.07''.')]
    [System.String] $HardwareId

    [DscProperty()]
    [System.ComponentModel.Description('The Instance Path ID of the device. Uniquely identifies the device in the system. Example is ''USBSTOR\\DISK&VEN_GENERIC&PROD_FLASH_DISK&REV_8.07\\8735B611&0''.')]
    [System.String] $InstancePathId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The identifier of the reusable policy setting.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The Product ID of the device. Example is ''55E0''.')]
    [System.String] $PID

    [DscProperty()]
    [System.ComponentModel.Description('The Primary ID of the device. Possible values are: RemovableMediaDevices, CdRomDevices, WpdDevices, and PrinterDevices')]
    [ValidateSet('CdRomDevices', 'PrinterDevices', 'RemovableMediaDevices', 'WpdDevices')]
    [System.String] $PrimaryId

    [DscProperty()]
    [System.ComponentModel.Description('The Serial Number ID of the device. Example is ''03003324080520232521'', which corresponds to ''USBSTOR\\DISK&VEN__USB&PROD__SANDISK_3.2GEN1&REV_1.00\\03003324080520232521&0''.')]
    [System.String] $SerialNumberId

    [DscProperty()]
    [System.ComponentModel.Description('The Vendor ID of the device. Example is ''0751''.')]
    [System.String] $VID

    [DscProperty()]
    [System.ComponentModel.Description('The combination of Vendor and Product ID. Example is ''0000_1111.')]
    [System.String] $VID_PID
}
