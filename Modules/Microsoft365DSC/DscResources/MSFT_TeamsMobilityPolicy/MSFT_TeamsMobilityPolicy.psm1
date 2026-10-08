using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsMobilityPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specify the name of the Teams Mobility Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Enables administrators to provide explanatory text about the policy. For example, the Description might indicate the users the policy should be assigned to.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('When set to WifiOnly, prohibits the user from making and receiving calls or joining meetings using VoIP calls on the mobile device while on a cellular data connection. Possible values are: WifiOnly, AllNetworks.')]
    [ValidateSet('WifiOnly', 'AllNetworks')]
    [System.String] $IPAudioMobileMode

    [DscProperty()]
    [System.ComponentModel.Description('When set to WifiOnly, prohibits the user from making and receiving video calls or enabling video in meetings using VoIP calls on the mobile device while on a cellular data connection. Possible values are: WifiOnly, AllNetworks.')]
    [ValidateSet('WifiOnly', 'AllNetworks')]
    [System.String] $IPVideoMobileMode

    [DscProperty()]
    [System.ComponentModel.Description('Controls the availability of browser choice options in Teams Mobile. When set to OfferBrowserOptions, users get two browser choice experiences: (1) browser options in the Teams Mobile settings page for configuring default preferences, and (2) browser options in the upsell card when tapping links. When set to UseUserDefaults, links open using the user''s system default browser settings. Possible values are: OfferBrowserOptions, UseUserDefaults.')]
    [ValidateSet('OfferBrowserOptions', 'UseSystemDefaults')]
    [System.String] $LinksInTeams

    [DscProperty()]
    [System.ComponentModel.Description('Determines the mobile dialer preference, possible values are: Teams, Native, UserOverride.')]
    [ValidateSet('Teams', 'Native', 'UserOverride')]
    [System.String] $MobileDialerPreference

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

    [TeamsMobilityPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsMobilityPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Teams Mobility Policy $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-CsTeamsMobilityPolicy -Identity $this.Identity -ErrorAction SilentlyContinue
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
                Identity               = $instance.Identity
                Description            = $instance.Description
                IPAudioMobileMode      = $instance.IPAudioMobileMode
                IPVideoMobileMode      = $instance.IPVideoMobileMode
                LinksInTeams           = $instance.LinksInTeams
                MobileDialerPreference = $instance.MobileDialerPreference
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                CertificateThumbprint  = $this.CertificateThumbprint
                ManagedIdentity        = $this.ManagedIdentity
                AccessTokens           = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for Teams Mobility Policy $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a Teams Mobility Policy with Identity {$($this.Identity)}"
            $createParameters = $boundParameters
            New-CsTeamsMobilityPolicy @createParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Teams Mobility Policy with Identity {$($this.Identity)}"
            $updateParameters = $boundParameters
            Set-CsTeamsMobilityPolicy @updateParameters | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Teams Mobility Policy with Identity {$($this.Identity)}"
            Remove-CsTeamsMobilityPolicy -Identity $currentInstance.Identity
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
            [array]$getValue = Get-CsTeamsMobilityPolicy -Filter $this.Filter -ErrorAction Stop

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

    hidden [TeamsMobilityPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsMobilityPolicy])
        {
            return $Values
        }

        $result = [TeamsMobilityPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
