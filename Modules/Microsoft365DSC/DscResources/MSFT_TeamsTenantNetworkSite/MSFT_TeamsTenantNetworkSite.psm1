using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsTenantNetworkSite : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique identifier for the network site to be created.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Provide a description of the network site to identify purpose of creating it.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is used to assign a custom emergency calling policy to a network site')]
    [System.String] $EmergencyCallingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is used to assign a custom emergency call routing policy to a network site')]
    [System.String] $EmergencyCallRoutingPolicy

    [DscProperty()]
    [System.ComponentModel.Description('This parameter determines whether the current site is enabled for location based routing.')]
    [System.Nullable[System.Boolean]] $EnableLocationBasedRouting

    [DscProperty()]
    [System.ComponentModel.Description('LocationPolicy is the identifier for the location policy which the current network site is associating to.')]
    [System.String] $LocationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('NetworkRegionID is the identifier for the network region which the current network site is associating to.')]
    [System.String] $NetworkRegionID

    [DscProperty()]
    [System.ComponentModel.Description('NetworkRoamingPolicy is the identifier for the network roaming policy to which the network site will associate to.')]
    [System.String] $NetworkRoamingPolicy

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
    [System.String] $Filter = '*'

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [TeamsTenantNetworkSite] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsTenantNetworkSite]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams Tenant Network Site $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $boundParameters
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTenantNetworkSite -Identity $this.Identity -ErrorAction SilentlyContinue
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found an instance with Identity {$($this.Identity)}"
            $results = @{
                Identity                   = $instance.Identity
                Description                = $instance.Description
                EmergencyCallingPolicy     = $instance.EmergencyCallingPolicy
                EmergencyCallRoutingPolicy = $instance.EmergencyCallRoutingPolicy
                EnableLocationBasedRouting = $instance.EnableLocationBasedRouting
                LocationPolicy             = $instance.LocationPolicy
                NetworkRegionID            = $instance.NetworkRegionID
                NetworkRoamingPolicy       = $instance.NetworkRoamingPolicy
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                TenantId                   = $this.TenantId
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                AccessTokens               = $this.AccessTokens
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

        Write-Verbose -Message "Getting configuration for Teams Tenant Network Site $($this.Identity)"

        $boundParameters = $this.GetBoundParameters()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a Teams Tenant Network Site with Identity {$($this.Identity)}"
            $createParameters = $boundParameters
            New-CsTenantNetworkSite @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Tenant Network Site with Identity {$($this.Identity)}"
            $updateParameters = $boundParameters
            Set-CsTenantNetworkSite @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams Tenant Network Site with Identity {$($this.Identity)}"
            Remove-CsTenantNetworkSite -Identity $currentInstance.Identity
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$getValue = Get-CsTenantNetworkSite -Filter $this.Filter -ErrorAction Stop

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

                $displayedKey = $config.Identity
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Identity
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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

    hidden [TeamsTenantNetworkSite] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsTenantNetworkSite])
        {
            return $Values
        }

        $result = [TeamsTenantNetworkSite]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
