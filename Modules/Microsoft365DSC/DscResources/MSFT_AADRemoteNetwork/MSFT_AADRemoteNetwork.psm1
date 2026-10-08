using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADRemoteNetwork : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the remote network.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the remote network')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Region')]
    [System.String] $Region

    [DscProperty()]
    [System.ComponentModel.Description('List of the forwarding profile names associated to this remote network')]
    [System.String[]] $ForwardingProfiles

    [DscProperty()]
    [System.ComponentModel.Description('Device Links associated to this remote network')]
    [MSFT_AADRemoteNetworkDeviceLink[]] $DeviceLinks

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

    [AADRemoteNetwork] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADRemoteNetwork]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Network Access Forwarding Profile with Id {$($this.Id)} and Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
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
                    $getValue = Get-MgBetaNetworkAccessConnectivityRemoteNetwork -RemoteNetworkId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Azure AD Remote Network with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.Name))
                    {
                        $getValue = Get-MgBetaNetworkAccessConnectivityRemoteNetwork -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $this.Name }
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Azure AD Remote Network with Name {$($this.Name)}."
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Azure AD Remote Network with Id {$($resolvedId)} and Name {$($this.Name)} was found"

            #region resource generator code
            $forwardingProfilesList = @()
            foreach ($forwardingProfile in $getValue.ForwardingProfiles)
            {
                $forwardingProfilesList += $forwardingProfile.Name
            }

            $complexDeviceLinks = $this.GetDeviceLinksHashtable($getValue.DeviceLinks)
            #endregion

            $results = @{
                Id                    = $getValue.Id
                Name                  = $getValue.Name
                Region                = $getValue.Region
                ForwardingProfiles    = [Array]$forwardingProfilesList
                DeviceLinks           = [Array]$complexDeviceLinks
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
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
        $deviceLinksItem = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # creating the device links property
        $deviceLinksHashtable = Rename-M365DSCCimInstanceParameter -Properties $boundParameters.DeviceLinks

        #creating the forwarding policies list by getting the ids
        $allForwardingProfiles = Get-MgBetaNetworkAccessForwardingProfile
        $forwardingProfilesList = @()
        foreach ($profileName in $boundParameters.ForwardingProfiles)
        {
            $matchedProfile = $allForwardingProfiles | Where-Object { $_.Name -eq $profileName }
            $forwardingProfilesList += @{
                id = $matchedProfile.Id
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Azure AD Remote Network with Name {$($this.Name)}"
            $createParameters = $boundParameters
            $params = @{
                name               = $createParameters.Name
                region             = $createParameters.Region
                deviceLinks        = [Array]$deviceLinksHashtable
                forwardingProfiles = [Array]$forwardingProfilesList
            }

            New-MgBetaNetworkAccessConnectivityRemoteNetwork -BodyParameter $params
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Azure AD Remote Network with Id {$($currentInstance.Id)}"
            $currentRemoteNetwork = Get-MgBetaNetworkAccessConnectivityRemoteNetwork -RemoteNetworkId $currentInstance.Id

            #removing the old device links
            foreach ($deviceLinkItem in $currentRemoteNetwork.DeviceLinks)
            {
                Remove-MgBetaNetworkAccessConnectivityRemoteNetworkDeviceLink -RemoteNetworkId $currentInstance.Id -DeviceLinkId $deviceLinkItem.Id
            }
            # updating the list of device links
            foreach ($deviceLinkItem in $deviceLinksHashtable)
            {
                Write-Verbose "Device Link Hashtable: $deviceLinksItem"
                New-MgBetaNetworkAccessConnectivityRemoteNetworkDeviceLink -RemoteNetworkId $currentInstance.Id -BodyParameter $deviceLinkItem
            }

            # removing forwarding profiles
            $params = @{
                '@context' = '#$delta'
                value      = @(@{})
            }
            Invoke-M365DSCGraphRequest -Uri "/beta/networkAccess/connectivity/remoteNetworks/$($currentInstance.Id)/forwardingProfiles" -Method Patch -Body $params

            #adding forwarding profiles if required
            if ($forwardingProfilesList.Count -gt 0)
            {
                $params = @{
                    '@context' = '#$delta'
                    value      = $forwardingProfilesList
                }
                Invoke-M365DSCGraphRequest -Uri "/beta/networkAccess/connectivity/remoteNetworks/$($currentInstance.Id)/forwardingProfiles" -Method Patch -Body $params
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Azure AD Remote Network with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaNetworkAccessConnectivityRemoteNetwork -RemoteNetworkId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaNetworkAccessConnectivityRemoteNetwork `
                -Filter $this.Filter `
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
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.DeviceLinks)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'DeviceLinks'
                            CimInstanceName = 'AADRemoteNetworkDeviceLink'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'BgpConfiguration'
                            CimInstanceName = 'AADRemoteNetworkDeviceLinkbgpConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'RedundancyConfiguration'
                            CimInstanceName = 'AADRemoteNetworkDeviceLinkRedundancyConfiguration'
                            IsRequired      = $False
                        },
                        @{
                            Name            = 'TunnelConfiguration'
                            CimInstanceName = 'AADRemoteNetworkDeviceLinkTunnelConfiguration'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceLinks `
                        -CIMInstanceName 'AADRemoteNetworkDeviceLink' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceLinks = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceLinks') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('DeviceLinks') `
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

    hidden [System.Object[]] GetDeviceLinksHashtable([System.Object] $DeviceLinks)
    {
        $newDeviceLinks = @()

        foreach ($deviceLink in $DeviceLinks)
        {
            $newDeviceLink = @{}

            # Add main properties only if they are not null
            if ($deviceLink.Name)
            {
                $newDeviceLink['Name'] = $deviceLink.Name
            }
            if ($deviceLink.IpAddress)
            {
                $newDeviceLink['IPAddress'] = $deviceLink.IpAddress
            }
            if ($deviceLink.BandwidthCapacityInMbps)
            {
                $newDeviceLink['BandwidthCapacityInMbps'] = $deviceLink.BandwidthCapacityInMbps
            }
            if ($deviceLink.DeviceVendor)
            {
                $newDeviceLink['DeviceVendor'] = $deviceLink.DeviceVendor
            }

            # BGP Configuration
            if ($deviceLink.BgpConfiguration)
            {
                $bgpConfig = @{}
                if ($deviceLink.BgpConfiguration.Asn)
                {
                    $bgpConfig['Asn'] = $deviceLink.BgpConfiguration.Asn
                }
                if ($deviceLink.BgpConfiguration.LocalIPAddress)
                {
                    $bgpConfig['LocalIPAddress'] = $deviceLink.BgpConfiguration.LocalIPAddress
                }
                if ($deviceLink.BgpConfiguration.PeerIPAddress)
                {
                    $bgpConfig['PeerIPAddress'] = $deviceLink.BgpConfiguration.PeerIPAddress
                }

                if ($bgpConfig.Count -gt 0)
                {
                    $newDeviceLink['BgpConfiguration'] = $bgpConfig
                }
            }

            # Redundancy Configuration
            if ($deviceLink.RedundancyConfiguration)
            {
                $redundancyConfig = @{}
                if ($deviceLink.RedundancyConfiguration.RedundancyTier)
                {
                    $redundancyConfig['RedundancyTier'] = $deviceLink.RedundancyConfiguration.RedundancyTier
                }
                if ($deviceLink.RedundancyConfiguration.ZoneLocalIPAddress)
                {
                    $redundancyConfig['ZoneLocalIPAddress'] = $deviceLink.RedundancyConfiguration.ZoneLocalIPAddress
                }

                if ($redundancyConfig.Count -gt 0)
                {
                    $newDeviceLink['RedundancyConfiguration'] = $redundancyConfig
                }
            }

            # Tunnel Configuration
            if ($deviceLink.TunnelConfiguration)
            {
                $tunnelConfig = @{}
                if ($deviceLink.TunnelConfiguration.PreSharedKey)
                {
                    $tunnelConfig['PreSharedKey'] = $deviceLink.TunnelConfiguration.PreSharedKey
                }
                if ($deviceLink.TunnelConfiguration.ZoneRedundancyPreSharedKey)
                {
                    $tunnelConfig['ZoneRedundancyPreSharedKey'] = $deviceLink.TunnelConfiguration.ZoneRedundancyPreSharedKey
                }

                # Additional Properties
                if ($deviceLink.TunnelConfiguration)
                {
                    if ($deviceLink.TunnelConfiguration.saLifeTimeSeconds)
                    {
                        $tunnelConfig['SaLifeTimeSeconds'] = $deviceLink.TunnelConfiguration.saLifeTimeSeconds
                    }
                    if ($deviceLink.TunnelConfiguration.ipSecEncryption)
                    {
                        $tunnelConfig['IPSecEncryption'] = $deviceLink.TunnelConfiguration.ipSecEncryption
                    }
                    if ($deviceLink.TunnelConfiguration.ipSecIntegrity)
                    {
                        $tunnelConfig['IPSecIntegrity'] = $deviceLink.TunnelConfiguration.ipSecIntegrity
                    }
                    if ($deviceLink.TunnelConfiguration.ikeEncryption)
                    {
                        $tunnelConfig['IKEEncryption'] = $deviceLink.TunnelConfiguration.ikeEncryption
                    }
                    if ($deviceLink.TunnelConfiguration.ikeIntegrity)
                    {
                        $tunnelConfig['IKEIntegrity'] = $deviceLink.TunnelConfiguration.ikeIntegrity
                    }
                    if ($deviceLink.TunnelConfiguration.dhGroup)
                    {
                        $tunnelConfig['DHGroup'] = $deviceLink.TunnelConfiguration.dhGroup
                    }
                    if ($deviceLink.TunnelConfiguration.pfsGroup)
                    {
                        $tunnelConfig['PFSGroup'] = $deviceLink.TunnelConfiguration.pfsGroup
                    }
                    if ($deviceLink.TunnelConfiguration['@odata.type'])
                    {
                        $tunnelConfig['ODataType'] = $deviceLink.TunnelConfiguration['@odata.type']
                    }
                }

                if ($tunnelConfig.Count -gt 0)
                {
                    $newDeviceLink['TunnelConfiguration'] = $tunnelConfig
                }
            }

            # Add the device link to the collection if it has any properties
            if ($newDeviceLink.Count -gt 0)
            {
                $newDeviceLinks += $newDeviceLink
            }
        }

        if ($newDeviceLinks.Count -eq 0)
        {
            return $null
        }

        return $newDeviceLinks
    }

    hidden [AADRemoteNetwork] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADRemoteNetwork])
        {
            return $Values
        }

        $result = [AADRemoteNetwork]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADRemoteNetworkDeviceLink
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the Device Link')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('IP Address')]
    [System.String] $IPAddress

    [DscProperty()]
    [System.ComponentModel.Description('Bandwidth Capacity in Mbps')]
    [System.String] $BandwidthCapacityInMbps

    [DscProperty()]
    [System.ComponentModel.Description('Device Vendor')]
    [System.String] $DeviceVendor

    [DscProperty()]
    [System.ComponentModel.Description('BgpConfiguration.')]
    [MSFT_AADRemoteNetworkDeviceLinkbgpConfiguration] $BgpConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('redundancyConfiguration.')]
    [MSFT_AADRemoteNetworkDeviceLinkRedundancyConfiguration] $RedundancyConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('tunnelConfiguration')]
    [MSFT_AADRemoteNetworkDeviceLinkTunnelConfiguration] $TunnelConfiguration
}

class MSFT_AADRemoteNetworkDeviceLinkbgpConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('LocalIpAddress.')]
    [System.String] $LocalIPAddress

    [DscProperty()]
    [System.ComponentModel.Description('PeerIpAddress.')]
    [System.String] $PeerIPAddress

    [DscProperty()]
    [System.ComponentModel.Description('Asn.')]
    [System.Nullable[System.UInt32]] $Asn
}

class MSFT_AADRemoteNetworkDeviceLinkRedundancyConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('ZoneLocalIpAddress.')]
    [System.String] $ZoneLocalIPAddress

    [DscProperty()]
    [System.ComponentModel.Description('RedundancyTier.')]
    [System.String] $RedundancyTier
}

class MSFT_AADRemoteNetworkDeviceLinkTunnelConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('PreSharedKey')]
    [System.String] $PreSharedKey

    [DscProperty()]
    [System.ComponentModel.Description('ZoneRedundancyPreSharedKey')]
    [System.String] $ZoneRedundancyPreSharedKey

    [DscProperty()]
    [System.ComponentModel.Description('SaLifeTimeSeconds')]
    [System.Nullable[System.UInt32]] $SaLifeTimeSeconds

    [DscProperty()]
    [System.ComponentModel.Description('IpSecEncryption')]
    [System.String] $IPSecEncryption

    [DscProperty()]
    [System.ComponentModel.Description('IpSecIntegrity')]
    [System.String] $IPSecIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('IkeEncryption')]
    [System.String] $IKEEncryption

    [DscProperty()]
    [System.ComponentModel.Description('IkeIntegrity')]
    [System.String] $IKEIntegrity

    [DscProperty()]
    [System.ComponentModel.Description('DhGroup')]
    [System.String] $DHGroup

    [DscProperty()]
    [System.ComponentModel.Description('PfsGroup')]
    [System.String] $PFSGroup

    [DscProperty()]
    [System.ComponentModel.Description('ODataType')]
    [System.String] $ODataType
}
