using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneMobileThreatDefenseConnector : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The DisplayName of the Mobile Threat Defense Connector partner. NOTE: Hard coded for convenience, not returned by the Graph API.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates the Mobile Threat Defense partner may collect metadata about installed applications from Intune for IOS devices. When FALSE, indicates the Mobile Threat Defense partner may not collect metadata about installed applications from Intune for IOS devices. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AllowPartnerToCollectIOSApplicationMetadata

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, allows the Mobile Threat Defense partner to request a list of installed certificates on iOS/iPadOS devices from Intune to use for threat analysis. This list of installed certificates will be sent from enrolled iOS/iPadOS devices and will include unmanaged certificates (certificates not deployed through Intune). When FALSE, indicates that metadata about installed certificates will not be collected. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AllowPartnerToCollectIosCertificateMetadata

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates the Mobile Threat Defense partner may collect metadata about personally installed applications from Intune for IOS devices. When FALSE, indicates the Mobile Threat Defense partner may not collect metadata about personally installed applications from Intune for IOS devices. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AllowPartnerToCollectIOSPersonalApplicationMetadata

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, allows the Mobile Threat Defense partner to request a list of installed certificates on personally owned iOS/iPadOS devices from Intune to use for threat analysis. This list of installed certificates will be sent from enrolled personally owned iOS/iPadOS devices and will include unmanaged certificates (certificates not deployed through Intune). When FALSE, no metadata for installed certificates is sent for personally owned iOS/iPadOS devices. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AllowPartnerToCollectIosPersonalCertificateMetadata

    [DscProperty()]
    [System.ComponentModel.Description('For Android, set whether Intune must receive data from the Mobile Threat Defense partner prior to marking a device compliant.')]
    [System.Nullable[System.Boolean]] $AndroidDeviceBlockedOnMissingPartnerData

    [DscProperty()]
    [System.ComponentModel.Description('For Android, set whether data from the Mobile Threat Defense partner should be used during compliance evaluations.')]
    [System.Nullable[System.Boolean]] $AndroidEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that data from the Mobile Threat Defense partner can be used during Mobile Application Management (MAM) evaluations for Android devices. When FALSE, indicates that data from the Mobile Threat Defense partner should not be used during Mobile Application Management (MAM) evaluations for Android devices. Only one partner per platform may be enabled for Mobile Application Management (MAM) evaluation. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $AndroidMobileApplicationManagementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the Mobile Threat Defense partner is granted the Mobile Threat Defense role on enrolled Android Corporate Owned Business Only and Corporate Owned Personally Enabled devices. When FALSE, indicates that the Mobile Threat Defense partner is not granted the Mobile Threat Defense role. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $GrantMobileThreatDefensePartnerRole

    [DscProperty()]
    [System.ComponentModel.Description('For IOS, set whether Intune must receive data from the Mobile Threat Defense partner prior to marking a device compliant.')]
    [System.Nullable[System.Boolean]] $IosDeviceBlockedOnMissingPartnerData

    [DscProperty()]
    [System.ComponentModel.Description('For IOS, get or set whether data from the Mobile Threat Defense partner should be used during compliance evaluations.')]
    [System.Nullable[System.Boolean]] $IosEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that data from the Mobile Threat Defense partner can be used during Mobile Application Management (MAM) evaluations for IOS devices. When FALSE, indicates that data from the Mobile Threat Defense partner should not be used during Mobile Application Management (MAM) evaluations for IOS devices. Only one partner per platform may be enabled for Mobile Application Management (MAM) evaluation. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $IosMobileApplicationManagementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('DateTime of last Heartbeat received from the Mobile Threat Defense partner.')]
    [System.Nullable[System.DateTime]] $LastHeartbeatDateTime

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that the Mobile Threat Defense partner will be automatically launched during Android Corporate Owned Business Only and Corporate Owned Personally Enabled device setup. When FALSE, indicates that the Mobile Threat Defense partner will not be automatically launched during setup. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $LaunchMobileThreatDefensePartnerOnSetupEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that Intune must receive data from the Mobile Threat Defense partner prior to marking a device compliant for Mac. When FALSE, indicates that Intune may make a device compliant without receiving data from the Mobile Threat Defense partner for Mac. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $MacDeviceBlockedOnMissingPartnerData

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that data from the Mobile Threat Defense partner can be used during compliance evaluations for Mac. When FALSE, it indicates that data from the Mobile Threat Defense partner should not be used during compliance evaluations for Mac. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $MacEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that configuration profile management via Microsoft Defender for Endpoint is enabled. When FALSE, inidicates that configuration profile management via Microsoft Defender for Endpoint is disabled. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $MicrosoftDefenderForEndpointAttachEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Partner state of this tenant.')]
    [System.String] $PartnerState

    [DscProperty()]
    [System.ComponentModel.Description('Get or Set days the per tenant tolerance to unresponsiveness for this partner integration.')]
    [System.Nullable[System.UInt32]] $PartnerUnresponsivenessThresholdInDays

    [DscProperty()]
    [System.ComponentModel.Description('Get or set whether to block devices on the enabled platforms that do not meet the minimum version requirements of the Mobile Threat Defense partner.')]
    [System.Nullable[System.Boolean]] $PartnerUnsupportedOsVersionBlocked

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that Intune must receive data from the Mobile Threat Defense partner prior to marking a device compliant for Windows. When FALSE, indicates that Intune may make a device compliant without receiving data from the Mobile Threat Defense partner for Windows. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $WindowsDeviceBlockedOnMissingPartnerData

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that data from the Mobile Threat Defense partner can be used during compliance evaluations for Windows. When FALSE, it indicates that data from the Mobile Threat Defense partner should not be used during compliance evaluations for Windows. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $WindowsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, indicates that data from the Mobile Threat Defense partner can be used during Mobile Application Management (MAM) evaluations for Windows devices. When FALSE, indicates that data from the Mobile Threat Defense partner should not be used during Mobile Application Management (MAM) evaluations for Windows devices. Only one partner per platform may be enabled for Mobile Application Management (MAM) evaluation. Default value is FALSE.')]
    [System.Nullable[System.Boolean]] $WindowsMobileApplicationManagementEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
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

    [IntuneMobileThreatDefenseConnector] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneMobileThreatDefenseConnector]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Mobile Threat Defense Connector with Id {$($this.Id)}."

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MgBetaDeviceManagementMobileThreatDefenseConnector -MobileThreatDefenseConnectorId $this.Id -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find MobileThreatDefenseConnector by Id: {$($this.Id)}."
                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    # There is no API which searches MobileThreatDefenseConnector by its DisplayName so the below code is commented out.
                    # $instance = Get-MgBetaDeviceManagementMobileThreatDefenseConnector -All `
                    #       -Filter "DisplayName eq '$($DisplayName -replace "'", "''")'" `

                    # The DisplayName property is not supported by the any API of this resource, hence hard-coded in below function for convenience.
                    $connectorId = $this.GetMobileThreatDefenseConnectorIdOrDisplayName($null, $this.DisplayName).Id
                    $instance = Get-MgBetaDeviceManagementMobileThreatDefenseConnector `
                        -MobileThreatDefenseConnectorId $connectorId `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Could not find MobileThreatDefenseConnector by DisplayName: {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }

            $displayNameValue = $this.DisplayName
            if ([string]::IsNullOrEmpty($displayNameValue))
            {
                $displayNameValue = $this.GetMobileThreatDefenseConnectorIdOrDisplayName($instance.Id, $null).DisplayName
            }

            $results = @{
                Id                                                  = $instance.Id
                DisplayName                                         = $displayNameValue
                AllowPartnerToCollectIOSApplicationMetadata         = $instance.AllowPartnerToCollectIOSApplicationMetadata
                AllowPartnerToCollectIosCertificateMetadata         = $instance.AllowPartnerToCollectIosCertificateMetadata
                AllowPartnerToCollectIOSPersonalApplicationMetadata = $instance.AllowPartnerToCollectIosPersonalApplicationMetadata
                AllowPartnerToCollectIosPersonalCertificateMetadata = $instance.AllowPartnerToCollectIosPersonalCertificateMetadata
                AndroidDeviceBlockedOnMissingPartnerData            = $instance.AndroidDeviceBlockedOnMissingPartnerData
                AndroidEnabled                                      = $instance.AndroidEnabled
                AndroidMobileApplicationManagementEnabled           = $instance.AndroidMobileApplicationManagementEnabled
                GrantMobileThreatDefensePartnerRole                 = $instance.GrantMobileThreatDefensePartnerRole
                IosDeviceBlockedOnMissingPartnerData                = $instance.IosDeviceBlockedOnMissingPartnerData
                IosEnabled                                          = $instance.IosEnabled
                IosMobileApplicationManagementEnabled               = $instance.IosMobileApplicationManagementEnabled
                LastHeartbeatDateTime                               = $instance.LastHeartbeatDateTime
                LaunchMobileThreatDefensePartnerOnSetupEnabled      = $instance.LaunchMobileThreatDefensePartnerOnSetupEnabled
                MacDeviceBlockedOnMissingPartnerData                = $instance.MacDeviceBlockedOnMissingPartnerData
                MacEnabled                                          = $instance.MacEnabled
                MicrosoftDefenderForEndpointAttachEnabled           = $instance.MicrosoftDefenderForEndpointAttachEnabled
                PartnerState                                        = $instance.PartnerState.ToString()
                PartnerUnresponsivenessThresholdInDays              = $instance.PartnerUnresponsivenessThresholdInDays
                PartnerUnsupportedOsVersionBlocked                  = $instance.PartnerUnsupportedOsVersionBlocked
                WindowsDeviceBlockedOnMissingPartnerData            = $instance.WindowsDeviceBlockedOnMissingPartnerData
                WindowsEnabled                                      = $instance.WindowsEnabled
                WindowsMobileApplicationManagementEnabled           = $instance.WindowsMobileApplicationManagementEnabled
                Ensure                                              = 'Present'
                Credential                                          = $this.Credential
                ApplicationId                                       = $this.ApplicationId
                TenantId                                            = $this.TenantId
                ApplicationSecret                                   = $this.ApplicationSecret
                CertificateThumbprint                               = $this.CertificateThumbprint
                CertificatePath                                     = $this.CertificatePath
                CertificatePassword                                 = $this.CertificatePassword
                ManagedIdentity                                     = $this.ManagedIdentity
                AccessTokens                                        = $this.AccessTokens
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
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $SetParameters = Rename-M365DSCCimInstanceParameter -Properties $SetParameters

        # Remove the DisplayName parameter as the Graph API does not support it
        $SetParameters.Remove('DisplayName') | Out-Null
        $SetParameters.Remove('Id') | Out-Null
        $SetParameters.Remove('LastHeartbeatDateTime') | Out-Null

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            New-MgBetaDeviceManagementMobileThreatDefenseConnector -BodyParameter $SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Update-MgBetaDeviceManagementMobileThreatDefenseConnector -MobileThreatDefenseConnectorId $currentInstance.Id -BodyParameter $SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-MgBetaDeviceManagementMobileThreatDefenseConnector -MobileThreatDefenseConnectorId $currentInstance.Id
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
            [array] $getValue = Get-MgBetaDeviceManagementMobileThreatDefenseConnector -All -Filter $this.Filter -ErrorAction Stop

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
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                                                  = $config.Id
                    DisplayName                                         = $config.DisplayName
                    Credential                                          = $this.Credential
                    ApplicationId                                       = $this.ApplicationId
                    TenantId                                            = $this.TenantId
                    ApplicationSecret                                   = $this.ApplicationSecret
                    CertificateThumbprint                               = $this.CertificateThumbprint
                    CertificatePath                                     = $this.CertificatePath
                    CertificatePassword                                 = $this.CertificatePassword
                    ManagedIdentity                                     = $this.ManagedIdentity
                    AccessTokens                                        = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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
            ExcludedProperties = @('LastHeartbeatDateTime')
        }
    }

    hidden [System.Collections.Hashtable] GetMobileThreatDefenseConnectorIdOrDisplayName([System.String] $ConnectorId, [System.String] $ConnectorDisplayName)
    {
        # Hashtable mapping IDs to Display Names
        $IdToDisplayNameMap = @{
            'fc780465-2017-40d4-a0c5-307022471b92' = 'Microsoft Defender for Endpoint'
            '860d3ab4-8fd1-45f5-89cd-ecf51e4f92e5' = 'BETTER Mobile Security'
            'd3ddeae8-441f-4681-b80f-aef644f7195a' = 'Check Point Harmony Mobile'
            '8d0ed095-8191-4bd3-8a41-953b22d51ff7' = 'Pradeo'
            '1f58d6d2-02cc-4c80-b008-1bfe7396a10a' = 'Jamf Trust'
            '4873197-ffec-4dfc-9816-db65f34c7cb9'  = 'Trellix Mobile Security'
            'a447eca6-a986-4d3f-9838-5862bf50776c' = 'CylancePROTECT Mobile'
            '4928f0f6-2660-4f69-b4c5-5170ec921f7b' = 'Trend Micro'
            'bb13fe25-ce1f-45aa-b278-cabbc6b9072e' = 'SentinelOne'
            'e6f777f8-e4c2-4a5b-be01-50b5c124bc7f' = 'Windows Security Center'
            '29ee2d98-e795-475f-a0f8-0802dc3384a9' = 'CrowdStrike Falcon for Mobile'
            '870b252b-0ef0-4707-8847-50fc571472b3' = 'Sophos'
            '2c7790de-8b02-4814-85cf-e0c59380dee8' = 'Lookout for Work'
            '28fd67fd-b179-4629-a8b0-dad420b697c7' = 'Symantec Endpoint Protection'
            '08a8455c-48dd-45ff-ad82-7211355354f3' = 'Zimperium'
        }

        # If Id is provided, look up the DisplayName
        if (-not [System.String]::IsNullOrEmpty($ConnectorId))
        {
            $ConnectorDisplayName = $IdToDisplayNameMap[$ConnectorId]
        }

        # If DisplayName is provided, look up the Id
        # Create a reverse lookup hashtable for DisplayName to Id
        $DisplayNameToIdMap = @{}
        foreach ($key in $IdToDisplayNameMap.Keys)
        {
            $DisplayNameToIdMap[$IdToDisplayNameMap[$key]] = $key
        }
        if (-not [System.String]::IsNullOrEmpty($ConnectorDisplayName))
        {
            $ConnectorId = $DisplayNameToIdMap[$ConnectorDisplayName]
            if (-not $ConnectorId)
            {
                Write-M365DSCHost -Message "Internal func: DisplayName '$ConnectorDisplayName' not found."
                return $null
            }
        }

        # Create the results tuple
        return @{
            Id          = $ConnectorId
            DisplayName = $ConnectorDisplayName
        }
    }

    hidden [IntuneMobileThreatDefenseConnector] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneMobileThreatDefenseConnector])
        {
            return $Values
        }

        $result = [IntuneMobileThreatDefenseConnector]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
