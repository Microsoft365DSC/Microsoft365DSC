using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOPerimeterConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Use the GatewayIPAddresses parameter to create or modify a list of gateway server IP addresses to add to IP safelists.')]
    [System.String[]] $GatewayIPAddresses

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOPerimeterConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOPerimeterConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting Perimeter Configuration'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $PerimeterConfiguration = Get-PerimeterConfig -ErrorAction Stop
            }
            else
            {
                $PerimeterConfiguration = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found Perimeter Configuration'

            $result = @{
                IsSingleInstance      = 'Yes'
                GatewayIPAddresses    = $PerimeterConfiguration.GatewayIPAddresses
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
                AccessTokens          = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message 'Setting configuration of Perimeter Configuration'

        $null = $this.Connect('ExchangeOnline')

        $PerimeterConfigurationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $PerimeterConfigurationParams.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $PerimeterConfigurationParams)
        {
            Write-Verbose -Message "Setting Perimeter Configuration with values: $(Convert-M365DscHashtableToString -Hashtable $PerimeterConfigurationParams)"
            Set-PerimeterConfig @PerimeterConfigurationParams -Confirm:$false
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        #region Telemetry
        $this.AddTelemetry('Export')

        #endregion
        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $PerimeterConfiguration = Get-PerimeterConfig -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            Write-M365DSCHost -Message "    |---[1/1] $($PerimeterConfiguration.Identity)" -DeferWrite

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                CertificatePath       = $this.CertificatePath
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $PerimeterConfiguration
            $Results = $this.GetForExport($Params)
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
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

    hidden [EXOPerimeterConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOPerimeterConfiguration])
        {
            return $Values
        }

        $result = [EXOPerimeterConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
