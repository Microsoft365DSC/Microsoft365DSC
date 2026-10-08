using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsVoiceRoute : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Voice Route.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('BridgeSourcePhoneNumber is an E.164 formatted Operator Connect Conferencing phone number assigned to your Audio Conferencing Bridge. Using BridgeSourcePhoneNumber in an online voice route is mutually exclusive with using OnlinePstnGatewayList in the same online voice route. When using BridgeSourcePhoneNumber in an online voice route, the OnlinePstnUsages used in the online voice route should only be used in a corresponding OnlineAudioConferencingRoutingPolicy. The same OnlinePstnUsages should not be used in online voice routes that are not using BridgeSourcePhoneNumber.')]
    [System.String] $BridgeSourcePhoneNumber

    [DscProperty()]
    [System.ComponentModel.Description('A description of what this online voice route is for.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('A regular expression that specifies the phone numbers to which this route applies. Numbers matching this pattern will be routed according to the rest of the routing settings.')]
    [System.String] $NumberPattern

    [DscProperty()]
    [System.ComponentModel.Description('This parameter contains a list of online gateways associated with this online voice route.  Each member of this list must be the service Identity of the online PSTN gateway.')]
    [System.String[]] $OnlinePstnGatewayList

    [DscProperty()]
    [System.ComponentModel.Description('A list of online PSTN usages (such as Local, Long Distance, etc.) that can be applied to this online voice route. The PSTN usage must be an existing usage (PSTN usages can be retrieved by calling the Get-CsOnlinePstnUsage cmdlet).')]
    [System.String[]] $OnlinePstnUsages

    [DscProperty()]
    [System.ComponentModel.Description('A number could resolve to multiple online voice routes. The priority determines the order in which the routes will be applied if more than one route is possible.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the route exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [TeamsVoiceRoute] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsVoiceRoute]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Voice Route {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    Identity              = $this.Identity
                    Ensure                = 'Absent'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $route = Get-CsOnlineVoiceRoute -Identity $this.Identity -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $route = $this.ExportedInstance
            }

            if ($null -eq $route)
            {
                Write-Verbose -Message "Could not find Voice Route {$($this.Identity)}"
                return $this.AsResult($nullReturn)
            }

            Write-Verbose -Message "Found Voice Route {$($this.Identity)}"
            return $this.AsResult(@{
                Identity                = $this.Identity
                BridgeSourcePhoneNumber = $route.BridgeSourcePhoneNumber
                Description             = $route.Description
                NumberPattern           = $route.NumberPattern
                OnlinePstnGatewayList   = $route.OnlinePstnGatewayList
                OnlinePstnUsages        = $route.OnlinePstnUsages
                Priority                = $route.Priority
                Ensure                  = 'Present'
                Credential              = $this.Credential
                ApplicationId           = $this.ApplicationId
                TenantId                = $this.TenantId
                CertificateThumbprint   = $this.CertificateThumbprint
                CertificatePath         = $this.CertificatePath
                CertificatePassword     = $this.CertificatePassword
                ManagedIdentity         = $this.ManagedIdentity
                AccessTokens            = $this.AccessTokens
            })
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

        $null = $this.Connect('MicrosoftTeams')

        # Validate that the selected PSTN usages exist in the environment
        $existingUsages = Get-CsOnlinePstnUsage | Select-Object -ExpandProperty Usage
        $notFoundUsageList = @()
        foreach ($usage in $this.OnlinePstnUsages)
        {
            if (-not ($existingUsages -match $usage))
            {
                $notFoundUsageList += $usage
            }
        }

        if ($notFoundUsageList)
        {
            $notFoundUsages = $notFoundUsageList -join ','
            throw "Please create the PSTN Usage(s) ($notFoundUsages) using `"TeamsPstnUsage`""
        }

        # Validate that the selected PSTN gateway exists in the environment
        $existingGateways = Get-CsOnlinePSTNGateway | Select-Object -ExpandProperty Identity
        $notFoundGatewayList = @()
        foreach ($gateway in $this.OnlinePstnGatewayList)
        {
            if (-not ($existingGateways -match $gateway))
            {
                $notFoundGatewayList += $gateway
            }
        }

        if ($notFoundGatewayList)
        {
            $notFoundGateways = $notFoundGatewayList -join ','
            throw "Please create the Voice Gateway object(s) ($notFoundGateways) using cmdlet `"New-CsOnlinePSTNGateway`""
        }

        Write-Verbose -Message "Setting Voice Route {$($this.Identity)}"

        $CurrentValues = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Voice Route {$($this.Identity)}"
            $createParameters = $boundParameters
            New-CsOnlineVoiceRoute @createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Voice Route {$($this.Identity)}"
            $updateParameters = $boundParameters
            Set-CsOnlineVoiceRoute @updateParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Voice Route {$($this.Identity)}"
            Remove-CsOnlineVoiceRoute -Identity $this.Identity
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
            $i = 1
            [array]$routes = Get-CsOnlineVoiceRoute -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($route in $routes)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($routes.Count)] $($route.Identity)" -DeferWrite
                $params = @{
                    Identity              = $route.Identity
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

                $this.ExportedInstance = $route
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

    hidden [TeamsVoiceRoute] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsVoiceRoute])
        {
            return $Values
        }

        $result = [TeamsVoiceRoute]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
