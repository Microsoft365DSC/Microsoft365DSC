using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCPolicyConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Accepted value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Default value is false. If set to false, then you cannot specify BandwidthLimitEnabled nor DailyBandwidthLimitInMb')]
    [System.Nullable[System.Boolean]] $AdvancedClassificationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Default value is false.')]
    [System.Nullable[System.Boolean]] $AuditFileActivity

    [DscProperty()]
    [System.ComponentModel.Description('Default value is true.')]
    [System.Nullable[System.Boolean]] $BandwidthLimitEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigBusinessJustificationList[]] $BusinessJustificationList

    [DscProperty()]
    [System.ComponentModel.Description('Default value is Off.')]
    [System.String] $CloudAppMode

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String[]] $CloudAppRestrictionList

    [DscProperty()]
    [System.ComponentModel.Description('Default value is 0. If set to 0, you cannot specify the BusinessJustificationList parameter as part of your configuration.')]
    [System.Nullable[System.UInt32]] $CustomBusinessJustificationNotification

    [DscProperty()]
    [System.ComponentModel.Description('Default value is 1000')]
    [System.Nullable[System.UInt32]] $DailyBandwidthLimitInMB

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPAppGroups[]] $DLPAppGroups

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPNetworkShareGroups[]] $DLPNetworkShareGroups

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPPrinterGroups[]] $DLPPrinterGroups

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPRemovableMediaGroups[]] $DLPRemovableMediaGroups

    [DscProperty()]
    [System.ComponentModel.Description('Default value is true.')]
    [System.Nullable[System.Boolean]] $IncludePredefinedUnallowedBluetoothApps

    [DscProperty()]
    [System.ComponentModel.Description('Default value is true.')]
    [System.Nullable[System.Boolean]] $MacDefaultPathExclusionsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String[]] $MacPathExclusion

    [DscProperty()]
    [System.ComponentModel.Description('Default value is false.')]
    [System.Nullable[System.Boolean]] $NetworkPathEnforcementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $NetworkPathExclusion

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String[]] $PathExclusion

    [DscProperty()]
    [System.ComponentModel.Description('Default value is false')]
    [System.Nullable[System.Boolean]] $serverDlpEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Default value is false')]
    [System.Nullable[System.Boolean]] $FileCopiedToCloudFullUrlEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigEvidenceStoreSettings] $EvidenceStoreSettings

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPSiteGroups[]] $SiteGroups

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigApp[]] $UnallowedApp

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigApp[]] $UnallowedCloudSyncApp

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigApp[]] $UnallowedBluetoothApp

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigApp[]] $UnallowedBrowser

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigQuarantineParameters] $QuarantineParameters

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String[]] $VPNSettings

    [DscProperty()]
    [System.ComponentModel.Description('The EnableLabelCoauth parameter enables or disables co-authoring support in Office desktop apps for the entire organization. Default value is false.')]
    [System.Nullable[System.Boolean]] $EnableLabelCoauth

    [DscProperty()]
    [System.ComponentModel.Description('The EnableSpoAipMigration parameter enables or disables built-in labeling for supported Office files in SharePoint and OneDrive.')]
    [System.Nullable[System.Boolean]] $EnableSpoAipMigration

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

    [SCPolicyConfig] Get()
    {
        $BusinessJustificationListValue = $null
        $EvidenceStoreSettingsValue = $null
        $Name = $null
        $VPNSettingsValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCPolicyConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCFilePlanPropertyReferenceId for $Name"

        try
        {
            $null = $this.Connect('SecurityComplianceCenter')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-PolicyConfig -ErrorAction Stop
            $EndpointDlpGlobalSettingsValue = ConvertFrom-Json $instance.EndpointDlpGlobalSettings
            $DlpPrinterGroupsObject = ConvertFrom-Json $instance.DlpPrinterGroups
            $DlpAppGroupsObject = ConvertFrom-Json $instance.DlpAppGroups
            $SiteGroupsObject = ConvertFrom-Json $instance.SiteGroups
            $DLPRemovableMediaGroupsObject = ConvertFrom-Json $instance.DLPRemovableMediaGroups
            $DlpNetworkShareGroupsObject = ConvertFrom-Json $instance.DlpNetworkShareGroups

            # AdvancedClassificationEnabled
            $AdvancedClassificationEnabledValue = $false # default value
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'AdvancedClassificationEnabled' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $AdvancedClassificationEnabledValue = [Boolean]::Parse($valueToParse)
            }

            # BandwidthLimitEnabled
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'BandwidthLimitEnabled' }).Value
            $BandwidthLimitEnabledValue = $true #default value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $BandwidthLimitEnabledValue = [Boolean]::Parse($valueToParse)
            }

            # DailyBandwidthLimitInMB
            $DailyBandwidthLimitInMBValue = 1000 # default value
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'DailyBandwidthLimitInMB' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $DailyBandwidthLimitInMBValue = [UInt32]::Parse($valueToParse)
            }

            # PathExclusion
            $PathExclusionValue = @()
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'PathExclusion' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $PathExclusionValue = [Array]($valueToParse)
            }

            # MacPathExclusion
            $MacPathExclusionValue = @()
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'MacPathExclusion' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $MacPathExclusionValue = [Array]($valueToParse)
            }

            # MacDefaultPathExclusionsEnabled
            $MacDefaultPathExclusionsEnabledValue = $true # default value
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'MacDefaultPathExclusionsEnabled' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $MacDefaultPathExclusionsEnabledValue = [Boolean]::Parse($valueToParse)
            }

            #EvidenceStoreSettings
            $entry = $EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'EvidenceStoreSettings' }
            if ($null -ne $entry)
            {
                $entry = ConvertFrom-Json $entry.Value
                $EvidenceStoreSettingsValue = [ordered]@{
                    FileEvidenceIsEnabled = $entry.FileEvidenceIsEnabled
                    NumberOfDaysToRetain  = [Uint32]$entry.NumberOfDaysToRetain
                    StorageAccounts       = [Array]$entry.StorageAccounts
                    Store                 = $entry.Store
                }
            }

            # NetworkPathEnforcementEnabled
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'NetworkPathEnforcementEnabled' }).Value
            $NetworkPathEnforcementEnabledValue = $false # default value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $NetworkPathEnforcementEnabledValue = [Boolean]::Parse($valueToParse)
            }

            # NetworkPathExclusion
            $NetworkPathExclusionValue = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'NetworkPathExclusion' }).Value

            # DlpAppGroups
            $DlpAppGroupsValue = @()
            foreach ($group in $DlpAppGroupsObject)
            {
                $entry = [ordered]@{
                    Name        = $group.Name
                    Id          = $group.Id
                    Description = $group.Description
                    Apps        = @()
                }

                foreach ($appEntry in $group.Apps)
                {
                    $app = [ordered]@{
                        ExecutableName = $appEntry.ExecutableName
                        Name           = $appEntry.Name
                        Quarantine     = [Boolean]::Parse($appEntry.Quarantine)
                    }
                    $entry.Apps += $app
                }
                $DlpAppGroupsValue += $entry
            }

            # UnallowedApp
            $entries = [Array]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'UnallowedApp' })
            $UnallowedAppValue = @()
            foreach ($entry in $entries)
            {
                $current = [ordered]@{
                    Value      = $entry.Value
                    Executable = $entry.Executable
                }
                $UnallowedAppValue += $current
            }

            # UnallowedCloudSyncApp
            $entries = [Array]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'UnallowedCloudSyncApp' })
            $UnallowedCloudSyncAppValue = @()
            foreach ($entry in $entries)
            {
                $current = [ordered]@{
                    Value      = $entry.Value
                    Executable = $entry.Executable
                }
                $UnallowedCloudSyncAppValue += $current
            }

            # IncludePredefinedUnallowedBluetoothApps
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'IncludePredefinedUnallowedBluetoothApps' }).Value
            $IncludePredefinedUnallowedBluetoothAppsValue = $true # default value
            if (-not [System.String]::IsNullOrEMpty($valueToParse))
            {
                $IncludePredefinedUnallowedBluetoothAppsValue = [Boolean]::Parse($valueToParse)
            }

            # UnallowedBluetoothApp
            $entries = [Array]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'UnallowedBluetoothApp' })
            $UnallowedBluetoothAppValue = @()
            foreach ($entry in $entries)
            {
                $current = [ordered]@{
                    Value      = $entry.Value
                    Executable = $entry.Executable
                }
                $UnallowedBluetoothAppValue += $current
            }

            # UnallowedBrowser
            $entries = [Array]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'UnallowedBrowser' })
            $UnallowedBrowserValue = @()
            foreach ($entry in $entries)
            {
                $current = [ordered]@{
                    Value      = $entry.Value
                    Executable = $entry.Executable
                }
                $UnallowedBrowserValue += $current
            }

            # CloudAppMode
            $CloudAppModeValue = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'CloudAppMode' }).Value

            # CloudAppRestrictionList
            $CloudAppRestrictionListValue = @()
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'CloudAppRestrictionList' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $CloudAppRestrictionListValue = [Array]($valueToParse)
            }

            # SiteGroups
            $SiteGroupsValue = @()
            foreach ($siteGroup in $SiteGroupsObject)
            {
                $entry = [ordered]@{
                    Id   = $siteGroup.Id
                    Name = $siteGroup.Name
                }

                $addresses = @()
                foreach ($address in $siteGroup.Addresses)
                {
                    $addresses += [ordered]@{
                        MatchType    = $address.MatchType
                        Url          = $address.Url
                        AddressLower = $address.AddressLower
                        AddressUpper = $address.AddressUpper
                    }
                }
                $entry.Add('Addresses', $addresses)
                $SiteGroupsValue += $entry
            }

            # CustomBusinessJustificationNotification
            $CustomBusinessJustificationNotificationValue = [Uint32]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'CustomBusinessJustificationNotification' }).Value

            if (-not [System.String]::IsNullOrEmpty($EndpointDlpGlobalSettingsValue.Setting))
            {
                $entities = $EndpointDlpGlobalSettingsValue | Where-Object -FilterScript { $_.Setting -eq 'BusinessJustificationList' }

                # BusinessJustificationList
                if ($null -ne $entities)
                {
                    $entities = ConvertFrom-Json ($entities.value)
                    $BusinessJustificationListValue = @()
                    foreach ($entity in $entities)
                    {
                        $current = [ordered]@{
                            Id                = $entity.Id
                            Enable            = [Boolean]$entity.Enable
                            justificationText = [System.String]($entity.justificationText | Select-Object -First 1) # Contains only one value
                        }
                        $BusinessJustificationListValue += $current
                    }
                }

                # serverDlpEnabled
                $serverDlpEnabledValue = $false #default value
                $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'serverDlpEnabled' }).Value
                if (-not [System.String]::IsNullOrEmpty($valueToParse))
                {
                    $serverDlpEnabledValue = [Boolean]::Parse($valueToParse)
                }

                # AuditFileActivity
                $AuditFileActivityValue = $false # default value
                $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'AuditFileActivity' }).Value
                if (-not [System.String]::IsNullOrEmpty($valueToParse))
                {
                    $AuditFileActivityValue = [Boolean]::Parse($valueToParse)
                }

                # VPNSettings
                $entity = $EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'VPNSettings' }
                if ($null -ne $entity)
                {
                    $entity = ConvertFrom-Json ($entity.value)
                    $VPNSettingsValue = [Array]$entity.serverAddress
                }
            }
            else
            {
                $BusinessJustificationListValue = @()
                $serverDlpEnabledValue = $false
                $AuditFileActivityValue = $false
                $VPNSettingsValue = @()
            }

            # DlpPrinterGroups
            $DlpPrinterGroupsValue = @()
            foreach ($group in $DlpPrinterGroupsObject.groups)
            {
                $entry = [ordered]@{
                    groupName = $group.groupName
                    groupId   = $group.groupId
                }

                $printers = @()
                foreach ($printer in $group.printers)
                {
                    $current = [ordered]@{
                        universalPrinter = [Boolean]$printer.universalPrinter
                        usbPrinter       = [Boolean]$printer.usbPrinter
                        usbPrinterId     = $printer.usbPrinterPID
                        name             = $printer.name
                        alias            = $printer.alias
                        usbPrinterVID    = $printer.usbPrinterVID
                        ipRange          = @{
                            fromAddress = $printer.ipRange.from
                            toAddress   = $printer.ipRange.to
                        }
                        corporatePrinter = [Boolean]$printer.CorporatePrinter
                        printToLocal     = [Boolean]$printer.printToLocal
                        printToFile      = [Boolean]$printer.printToFile
                    }

                    $printers += $current
                }
                $entry.Add('printers', $printers)
                $DlpPrinterGroupsValue += $entry
            }

            # DLPRemovableMediaGroups
            $DLPRemovableMediaGroupsValue = @()
            foreach ($group in $DLPRemovableMediaGroupsObject.groups)
            {
                $entry = [ordered]@{
                    groupName = $group.groupName
                }

                $medias = @()
                foreach ($media in $group.removableMedia)
                {
                    $current = [ordered]@{
                        deviceId          = $media.deviceId
                        removableMediaVID = $media.removableMediaVID
                        name              = $media.name
                        alias             = $media.alias
                        removableMediaPID = $media.removableMediaPID
                        instancePathId    = $media.instancePathId
                        serialNumberId    = $media.serialNumberId
                        hardwareId        = $media.hardwareId
                    }
                    $medias += $current
                }
                $entry.Add('removableMedia', $medias)

                $DLPRemovableMediaGroupsValue += $entry
            }

            # DlpNetworkShareGroups
            $DlpNetworkShareGroupsValue = @()
            foreach ($group in $DlpNetworkShareGroupsObject.groups)
            {
                $entry = [ordered]@{
                    groupName    = $group.groupName
                    groupId      = $group.groupId
                    networkPaths = [Array]$group.networkPaths
                }
                $DlpNetworkShareGroupsValue += $entry
            }

            $QuarantineParametersValue = $null
            if ($null -ne ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'QuarantineParameters' }))
            {
                $quarantineInfo = [Array]($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'QuarantineParameters' }).Value
                $quarantineInfo = ConvertFrom-Json $quarantineInfo[0]
                $QuarantineParametersValue = [ordered]@{
                    EnableQuarantineForCloudSyncApps = $quarantineInfo.EnableQuarantineForCloudSyncApps
                    QuarantinePath                   = $quarantineInfo.QuarantinePath
                    MacQuarantinePath                = $quarantineInfo.MacQuarantinePath
                    ShouldReplaceFile                = $quarantineInfo.ShouldReplaceFile
                    FileReplacementText              = $quarantineInfo.FileReplacementText
                }
            }

            #EnableLabelCoauthValue
            $EnableLabelCoauthValue = $false # default value
            if (-not [System.String]::IsNullOrEmpty($instance.EnableLabelCoauth))
            {
                $EnableLabelCoauthValue = $instance.EnableLabelCoauth
            }

            #FileCopiedToCloudFullUrlEnabledValue
            $FileCopiedToCloudFullUrlEnabledValue = $false
            $valueToParse = ($EndpointDlpGlobalSettingsValue | Where-Object { $_.Setting -eq 'FileCopiedToCloudFullUrlEnabled' }).Value
            if (-not [System.String]::IsNullOrEmpty($valueToParse))
            {
                $FileCopiedToCloudFullUrlEnabledValue = [Boolean]::Parse($valueToParse)
            }

            $results = @{
                IsSingleInstance                        = 'Yes'
                AdvancedClassificationEnabled           = $AdvancedClassificationEnabledValue
                BandwidthLimitEnabled                   = $BandwidthLimitEnabledValue
                FileCopiedToCloudFullUrlEnabled         = $FileCopiedToCloudFullUrlEnabledValue
                DailyBandwidthLimitInMB                 = $DailyBandwidthLimitInMBValue
                PathExclusion                           = $PathExclusionValue
                MacPathExclusion                        = $MacPathExclusionValue
                MacDefaultPathExclusionsEnabled         = $MacDefaultPathExclusionsEnabledValue
                EvidenceStoreSettings                   = $EvidenceStoreSettingsValue
                NetworkPathEnforcementEnabled           = $NetworkPathEnforcementEnabledValue
                NetworkPathExclusion                    = $NetworkPathExclusionValue
                DLPAppGroups                            = $DlpAppGroupsValue
                UnallowedApp                            = $UnallowedAppValue
                UnallowedCloudSyncApp                   = $UnallowedCloudSyncAppValue
                IncludePredefinedUnallowedBluetoothApps = $IncludePredefinedUnallowedBluetoothAppsValue
                UnallowedBluetoothApp                   = $UnallowedBluetoothAppValue
                UnallowedBrowser                        = $UnallowedBrowserValue
                CloudAppMode                            = $CloudAppModeValue
                CloudAppRestrictionList                 = $CloudAppRestrictionListValue
                SiteGroups                              = $SiteGroupsValue
                CustomBusinessJustificationNotification = $CustomBusinessJustificationNotificationValue
                BusinessJustificationList               = $BusinessJustificationListValue
                ServerDlpEnabled                        = $serverDlpEnabledValue
                AuditFileActivity                       = $AuditFileActivityValue
                DLPPrinterGroups                        = $DlpPrinterGroupsValue
                DLPRemovableMediaGroups                 = $DLPRemovableMediaGroupsValue
                DLPNetworkShareGroups                   = $DlpNetworkShareGroupsValue
                VPNSettings                             = $VPNSettingsValue
                EnableLabelCoauth                       = $EnableLabelCoauthValue
                EnableSpoAipMigration                   = $instance.EnableSpoAipMigration
                QuarantineParameters                    = $QuarantineParametersValue
                Credential                              = $this.Credential
                ApplicationId                           = $this.ApplicationId
                TenantId                                = $this.TenantId
                CertificateThumbprint                   = $this.CertificateThumbprint
                CertificatePath                         = $this.CertificatePath
                CertificatePassword                     = $this.CertificatePassword
                ManagedIdentity                         = $this.ManagedIdentity
                AccessTokens                            = $this.AccessTokens
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
        $Name = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of SCFilePlanPropertyReferenceId for $Name"

        $null = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $SiteGroupsValue = @()
        foreach ($site in $this.SiteGroups)
        {
            $entry = @{
                Name        = $site.Name
                Description = $site.Description
            }

            $addressesValue = @()
            foreach ($address in $site.Addresses)
            {
                $addressesValue += @{
                    MatchType    = $address.MatchType
                    Url          = $address.Url
                    AddressLower = $address.AddressLower
                    AddressUpper = $address.AddressUpper
                }
            }

            $entry.Add('Addresses', (ConvertTo-Json $addressesValue -Compress -Depth 10))
            $SiteGroupsValue += $entry
        }

        $EndpointDlpGlobalSettingsValue = @()
        if ($null -ne $this.AdvancedClassificationEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'AdvancedClassificationEnabled'
                Value   = "$($this.AdvancedClassificationEnabled.ToString().ToLower())"
            }
        }

        if ($null -ne $this.BandwidthLimitEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'BandwidthLimitEnabled'
                Value   = "$($this.BandwidthLimitEnabled.ToString().ToLower())"
            }
        }

        if ($null -ne $this.DailyBandwidthLimitInMB -and $this.BandwidthLimitEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'DailyBandwidthLimitInMB'
                Value   = "$($this.DailyBandwidthLimitInMB.ToString().ToLower())"
            }
        }

        if ($null -ne $this.EvidenceStoreSettings)
        {
            $entry += @{
                Setting = 'EvidenceStoreSettings'
                Value   = @{
                    FileEvidenceIsEnabled = $this.EvidenceStoreSettings.FileEvidenceIsEnabled
                    Store                 = $this.EvidenceStoreSettings.Store
                    NumberOfDaysToRetain  = $this.EvidenceStoreSettings.NumberOfDaysToRetain
                }
            }

            $StorageAccountsValue = @()
            foreach ($storageAccount in $this.EvidenceStoreSettings.StorageAccounts)
            {
                $StorageAccountsValue += @{
                    Name    = $storageAccount.Name
                    BlobUri = $storageAccount.BlobUri
                }
            }
            $entry.Value.Add('StorageAccounts', $StorageAccountsValue)
            $entry.Value = ConvertTo-Json $entry.Value -Depth 10 -Compress

            $EndpointDlpGlobalSettingsValue += $entry
        }

        if ($null -ne $this.MacDefaultPathExclusionsEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'MacDefaultPathExclusionsEnabled'
                Value   = "$($this.MacDefaultPathExclusionsEnabled.ToString().ToLower())"
            }
        }

        foreach ($path in $this.PathExclusion)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'PathExclusion'
                Value   = "$($path.ToString())"
            }
        }

        foreach ($path in $this.MacPathExclusion)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'MacPathExclusion'
                Value   = "$($path.ToString())"
            }
        }

        foreach ($app in $this.UnallowedApp)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting    = 'UnallowedApp'
                Value      = "$($app.Value.ToString())"
                Executable = "$($app.Executable.ToString())"
            }
        }

        foreach ($app in $this.UnallowedCloudSyncApp)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting    = 'UnallowedCloudSyncApp'
                Value      = "$($app.Value.ToString())"
                Executable = "$($app.Executable.ToString())"
            }
        }

        if ($null -ne $this.NetworkPathEnforcementEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'NetworkPathEnforcementEnabled'
                Value   = "$($this.NetworkPathEnforcementEnabled.ToString().ToLower())"
            }
        }

        if ($null -ne $this.NetworkPathExclusion)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'NetworkPathExclusion'
                Value   = "$($this.NetworkPathExclusion.ToString())"
            }
        }

        if ($null -ne $this.QuarantineParameters)
        {
            $entry = @{
                Setting = 'QuarantineParameters'
                Value   = @{
                    EnableQuarantineForCloudSyncApps = $this.QuarantineParameters.EnableQuarantineForCloudSyncApps
                    QuarantinePath                   = $this.QuarantineParameters.QuarantinePath
                    MacQuarantinePath                = $this.QuarantineParameters.MacQuarantinePath
                    ShouldReplaceFile                = $this.QuarantineParameters.ShouldReplaceFile
                    FileReplacementText              = $this.QuarantineParameters.FileReplacementText
                }
            }
            $entry.Value = (ConvertTo-Json $entry.Value -Depth 10 -Compress)
            $EndpointDlpGlobalSettingsValue += $entry
        }

        if ($null -ne $this.IncludePredefinedUnallowedBluetoothApps)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'IncludePredefinedUnallowedBluetoothApps'
                Value   = "$($this.IncludePredefinedUnallowedBluetoothApps.ToString())"
            }
        }

        foreach ($app in  $this.UnallowedBluetoothApp)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting    = 'UnallowedBluetoothApp'
                Value      = "$($app.Value.ToString())"
                Executable = "$($app.Executable.ToString())"
            }
        }

        foreach ($app in  $this.UnallowedBrowser)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting    = 'UnallowedBrowser'
                Value      = "$($app.Value.ToString())"
                Executable = "$($app.Executable.ToString())"
            }
        }

        foreach ($domain in  $this.CloudAppRestrictionList)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'CloudAppRestrictionList'
                Value   = "$($domain.ToString())"
            }
        }

        if (-not [System.String]::IsNullOrEmpty($this.CloudAppMode))
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'CloudAppMode'
                Value   = "$($this.CloudAppMode.ToString())"
            }
        }

        if ($null -ne $this.CustomBusinessJustificationNotification)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'CustomBusinessJustificationNotification'
                Value   = "$($this.CustomBusinessJustificationNotification.ToString())"
            }
        }

        if ($null -ne $this.BusinessJustificationList)
        {
            $valueEntry = @()
            foreach ($justification in $this.BusinessJustificationList)
            {
                $valueEntry += @{
                    Id                = $justification.Id
                    Enable            = $justification.Enable
                    justificationText = @($justification.justificationText)
                }
            }

            $entry = @{
                Setting = 'BusinessJustificationList'
                Value   = (ConvertTo-Json $valueEntry -Depth 10 -Compress)
            }
            $EndpointDlpGlobalSettingsValue += $entry
        }

        if ($null -ne $this.VPNSettings)
        {
            $entry = @{
                Setting = 'VPNSettings'
                Value   = @{
                    serverAddress = @()
                }
            }
            foreach ($vpnAddress in $this.VPNSettings)
            {
                $entry.Value.serverAddress += $vpnAddress
            }
            $EndpointDlpGlobalSettingsValue += $entry
        }

        if ($null -ne $this.serverDlpEnabled)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'serverDlpEnabled'
                Value   = "$($this.serverDlpEnabled.ToString().ToLower())"
            }
        }

        if ($null -ne $this.AuditFileActivity)
        {
            $EndpointDlpGlobalSettingsValue += @{
                Setting = 'AuditFileActivity'
                Value   = "$($this.AuditFileActivity.ToString().ToLower())"
            }
        }

        $DLPAppGroupsValue = @()
        foreach ($group in $this.DLPAppGroups)
        {
            $entry = @{
                Name        = "$($group.Name.ToString())"
                Description = "$($group.Description.ToString())"
            }

            $appsValues = @()
            foreach ($app in $group.Apps)
            {
                $appsValues += @{
                    Name           = $app.Name
                    ExecutableName = $app.ExecutableName
                    Quarantine     = $app.Quarantine
                }
            }
            $entry.Add('Apps', (ConvertTo-Json $appsValues -Depth 10 -Compress))
            $DLPAppGroupsValue += $entry
        }

        $DlpPrinterGroupsValue = @{
            groups = @()
        }
        $groupCount = 0
        foreach ($group in $this.DLPPrinterGroups)
        {
            $entry = @{
                groupName = "$($group.groupName.ToString())"
                printers  = @()
            }

            foreach ($printer in $group.printers)
            {
                $entry.printers += @{
                    alias            = $printer.alias
                    name             = $printer.name
                    usbPrinterPID    = $printer.usbPrinterId
                    usbPrinterVID    = $printer.usbPrinterVID
                    universalPrinter = "$($printer.universalPrinter.Tostring().ToLower())"
                    corporatePrinter = "$($printer.corporatePrinter.Tostring().ToLower())"
                    printToFile      = "$($printer.printToFile.Tostring().ToLower())"
                    printToLocal     = "$($printer.printToLocal.Tostring().ToLower())"
                    ipRange          = @(
                        @{
                            from = $printer.ipRange.fromAddress
                            to   = $printer.ipRange.toAddress
                        }
                    )
                }
            }
            $DlpPrinterGroupsValue.groups += $entry
            $groupCount++
        }
        if ($groupCount -eq 0)
        {
            $DlpPrinterGroupsValue = $null
        }

        $DLPRemovableMediaGroupsValue = @{
            groups = @()
        }
        $groupCount = 0
        foreach ($group in $this.DLPRemovableMediaGroups)
        {
            $entry = @{
                groupName      = $group.groupName
                removableMedia = @(
                )
            }

            foreach ($media in $group.removableMedia)
            {
                $entry.removableMedia += @{
                    alias             = $media.alias
                    name              = $media.name
                    removableMediaPID = $media.removableMediaPID
                    removableMediaVID = $media.removableMediaVID
                    serialNumberId    = $media.serialNumberId
                    deviceId          = $media.deviceId
                    instancePathId    = $media.instancePathId
                    hardwareId        = $media.hardwareId
                }
            }
            $DLPRemovableMediaGroupsValue.groups += $entry
            $groupCount++
        }
        if ($groupCount -eq 0)
        {
            $DLPRemovableMediaGroupsValue = $null
        }

        $params = @{
            SiteGroups                = $SiteGroupsValue
            EnableLabelCoauth         = $this.EnableLabelCoauth
            DlpAppGroups              = $DLPAppGroupsValue
            DlpPrinterGroups          = ConvertTo-Json $DlpPrinterGroupsValue -Depth 10 -Compress
            DLPRemovableMediaGroups   = ConvertTo-Json $DLPRemovableMediaGroupsValue -Depth 10 -Compress
            EndpointDlpGlobalSettings = $EndpointDlpGlobalSettingsValue
        }
        $CurrentPolicyConfig = $this.Get().ToHashtable()
        if ($this.EnableSpoAipMigration -ne $CurrentPolicyConfig.EnableSpoAipMigration)
        {
            $params.Add('EnableSpoAipMigration', $this.EnableSpoAipMigration)
        }
        Write-Verbose -Message "Updating policy config with values:`r`n$(Convert-M365DscHashtableToString -Hashtable $params)"
        Set-PolicyConfig @params
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $dscContent = [System.Text.StringBuilder]::new()
            $params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $Results = $this.GetForExport($Params)
            if ($null -ne $Results.BusinessJustificationList -and $Results.BusinessJustificationList.Length -gt 0)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.BusinessJustificationList `
                    -CIMInstanceName 'PolicyConfigBusinessJustificationList'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.BusinessJustificationList = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('BusinessJustificationList') | Out-Null
                }
            }

            if ($null -ne $Results.DLPAppGroups -and $Results.DLPAppGroups.Length -gt 0)
            {
                $complexTypeMapping = @(
                    @{
                        Name            = 'DLPAppGroups'
                        CimInstanceName = 'PolicyConfigDLPAppGroups'
                    },
                    @{
                        Name            = 'Apps'
                        CimInstanceName = 'PolicyConfigDLPApp'
                        IsArray         = $true
                    }
                )

                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.DLPAppGroups `
                    -CIMInstanceName 'PolicyConfigDLPAppGroups' `
                    -ComplexTypeMapping $complexTypeMapping
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.DLPAppGroups = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('DLPAppGroups') | Out-Null
                }
            }

            if ($null -ne $Results.DLPNetworkShareGroups -and $Results.DLPNetworkShareGroups.Length -gt 0)
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.DLPNetworkShareGroups `
                    -CIMInstanceName 'PolicyConfigDLPNetworkShareGroups'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.DLPNetworkShareGroups = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('DLPNetworkShareGroups') | Out-Null
                }
            }

            if ($null -ne $Results.DLPPrinterGroups -and $Results.DLPPrinterGroups.Length -gt 0)
            {
                $complexTypeMapping = @(
                    @{
                        Name            = 'DLPPrinterGroups'
                        CimInstanceName = 'PolicyConfigDLPPrinterGroups'
                    },
                    @{
                        Name            = 'printers'
                        CimInstanceName = 'PolicyConfigPrinter'
                        IsArray         = $true
                    },
                    @{
                        Name            = 'ipRange'
                        CimInstanceName = 'PolicyConfigIPRange'
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.DLPPrinterGroups `
                    -CIMInstanceName 'PolicyConfigDLPPrinterGroups' `
                    -ComplexTypeMapping $complexTypeMapping
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.DLPPrinterGroups = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('DLPPrinterGroups') | Out-Null
                }
            }

            if ($null -ne $Results.DLPRemovableMediaGroups -and $Results.DLPRemovableMediaGroups.Length -gt 0)
            {
                $complexTypeMapping = @(
                    @{
                        Name            = 'DLPRemovableMediaGroups'
                        CimInstanceName = 'PolicyConfigDLPRemovableMediaGroups'
                    },
                    @{
                        Name            = 'removableMedia'
                        CimInstanceName = 'PolicyConfigRemovableMedia'
                        IsArray         = $true
                    }
                )

                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.DLPRemovableMediaGroups `
                    -CIMInstanceName 'PolicyConfigDLPRemovableMediaGroups' `
                    -ComplexTypeMapping $complexTypeMapping
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.DLPRemovableMediaGroups = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('DLPRemovableMediaGroups') | Out-Null
                }
            }

            if ($null -ne $Results.EvidenceStoreSettings)
            {
                $complexTypeMapping = @(
                    @{
                        Name            = 'EvidenceStoreSettings'
                        CimInstanceName = 'PolicyConfigEvidenceStoreSettings'
                    },
                    @{
                        Name            = 'StorageAccounts'
                        CimInstanceName = 'PolicyConfigStorageAccount'
                        IsArray         = $true
                    }
                )

                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.EvidenceStoreSettings `
                    -CIMInstanceName 'PolicyConfigEvidenceStoreSettings' `
                    -ComplexTypeMapping $complexTypeMapping
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.EvidenceStoreSettings = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('EvidenceStoreSettings') | Out-Null
                }
            }

            if ($null -ne $Results.SiteGroups -and $Results.SiteGroups.Length -gt 0)
            {
                $complexTypeMapping = @(
                    @{
                        Name            = 'SiteGroups'
                        CimInstanceName = 'PolicyConfigDLPSiteGroups'
                    },
                    @{
                        Name            = 'Addresses'
                        CimInstanceName = 'PolicyConfigSiteGroupAddress'
                        IsArray         = $true
                    }
                )

                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.SiteGroups `
                    -CIMInstanceName 'PolicyConfigDLPSiteGroups' `
                    -ComplexTypeMapping $complexTypeMapping
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.SiteGroups = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('SiteGroups') | Out-Null
                }
            }

            if ($null -ne $Results.UnallowedApp -and -not [System.String]::IsNullOrEmpty($Results.UnallowedApp))
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.UnallowedApp `
                    -CIMInstanceName 'PolicyConfigApp'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.UnallowedApp = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('UnallowedApp') | Out-Null
                }
            }

            if ($null -ne $Results.UnallowedCloudSyncApp -and -not [System.String]::IsNullOrEmpty($Results.UnallowedCloudSyncApp))
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.UnallowedCloudSyncApp `
                    -CIMInstanceName 'PolicyConfigApp'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.UnallowedCloudSyncApp = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('UnallowedCloudSyncApp') | Out-Null
                }
            }

            if ($null -ne $Results.UnallowedBluetoothApp -and -not [System.String]::IsNullOrEmpty($Results.UnallowedBluetoothApp))
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.UnallowedBluetoothApp `
                    -CIMInstanceName 'PolicyConfigApp'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.UnallowedBluetoothApp = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('UnallowedBluetoothApp') | Out-Null
                }
            }

            if ($null -ne $Results.UnallowedBrowser -and -not [System.String]::IsNullOrEmpty($Results.UnallowedBrowser))
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.UnallowedBrowser `
                    -CIMInstanceName 'PolicyConfigApp'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.UnallowedBrowser = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('UnallowedBrowser') | Out-Null
                }
            }

            if ($null -ne $Results.QuarantineParameters -and -not [System.String]::IsNullOrEmpty($Results.QuarantineParameters))
            {
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.QuarantineParameters `
                    -CIMInstanceName 'PolicyConfigQuarantineParameters'
                if (-not [String]::IsNullOrEmpty($complexTypeStringResult))
                {
                    $Results.QuarantineParameters = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('QuarantineParameters') | Out-Null
                }
            }

            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential `
                -NoEscape @('QuarantineParameters', 'BusinessJustificationList', 'DLPAppGroups', 'DLPNetworkShareGroups',
                'DLPPrinterGroups', 'DLPRemovableMediaGroups', 'SiteGroups', 'UnallowedApp', 'UnallowedCloudSyncApp',
                'UnallowedBluetoothApp', 'UnallowedBrowser', 'EvidenceStoreSettings')

            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SCPolicyConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCPolicyConfig])
        {
            return $Values
        }

        $result = [SCPolicyConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_PolicyConfigBusinessJustificationList
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $justificationText

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $Enable
}

class MSFT_PolicyConfigDLPAppGroups
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Id

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigDLPApp[]] $Apps
}

class MSFT_PolicyConfigDLPNetworkShareGroups
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $groupName

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String[]] $networkPaths
}

class MSFT_PolicyConfigDLPPrinterGroups
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $groupName

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigPrinter[]] $printers
}

class MSFT_PolicyConfigDLPRemovableMediaGroups
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $groupName

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigRemovableMedia[]] $removableMedia
}

class MSFT_PolicyConfigEvidenceStoreSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $FileEvidenceIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.UInt32]] $NumberOfDaysToRetain

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigStorageAccount[]] $StorageAccounts

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Store
}

class MSFT_PolicyConfigDLPSiteGroups
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Id

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigSiteGroupAddress[]] $addresses
}

class MSFT_PolicyConfigApp
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the application.')]
    [System.String] $Value

    [DscProperty()]
    [System.ComponentModel.Description('Name of the executable file.')]
    [System.String] $Executable
}

class MSFT_PolicyConfigQuarantineParameters
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $EnableQuarantineForCloudSyncApps

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $QuarantinePath

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $MacQuarantinePath

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $ShouldReplaceFile

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $FileReplacementText
}

class MSFT_PolicyConfigDLPApp
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $ExecutableName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $Quarantine
}

class MSFT_PolicyConfigPrinter
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $universalPrinter

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $usbPrinter

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $usbPrinterId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $alias

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $usbPrinterVID

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [MSFT_PolicyConfigIPRange] $ipRange

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $corporatePrinter

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $printToLocal

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.Nullable[System.Boolean]] $printToFile
}

class MSFT_PolicyConfigRemovableMedia
{
    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $deviceId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $removableMediaVID

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $name

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $alias

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $removableMediaPID

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $instancePathId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $serialNumberId

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $hardwareId
}

class MSFT_PolicyConfigStorageAccount
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $BlobUri
}

class MSFT_PolicyConfigSiteGroupAddress
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The match type to perform. If UrlMatch is selected, then the Url property must be configured. If IPv4 or IPv6RangeMatch are selected, then AddressLower and AddressUpper must be configured.')]
    [ValidateSet('UrlMatch', 'IPv4RangeMatch', 'IPv6RangeMatch')]
    [System.String] $MatchType

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $Url

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $AddressLower

    [DscProperty()]
    [System.ComponentModel.Description('TBD')]
    [System.String] $AddressUpper
}

class MSFT_PolicyConfigIPRange
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $fromAddress

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('TBD')]
    [System.String] $toAddress
}
