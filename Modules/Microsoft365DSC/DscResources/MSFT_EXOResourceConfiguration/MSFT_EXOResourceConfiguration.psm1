using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOResourceConfiguration : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The ResourcePropertySchema parameter specifies the custom resource property that you want to make available to room or equipment mailboxes. This parameter uses the syntax Room/<Text> or Equipment/<Text> where the <Text> value doesn''t contain spaces. For example, Room/Whiteboard or Equipment/Van.')]
    [System.String[]] $ResourcePropertySchema

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

    [EXOResourceConfiguration] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOResourceConfiguration]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of the EXO Resource Configuration'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $ResourceConfiguration = Get-ResourceConfig -ErrorAction Stop
            }
            else
            {
                $ResourceConfiguration = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found ResourceConfiguration'

            $result = @{
                IsSingleInstance       = 'Yes'
                ResourcePropertySchema = $ResourceConfiguration.ResourcePropertySchema
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                TenantId               = $this.TenantId
                AccessTokens           = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Resource Configuration'

        $null = $this.Connect('ExchangeOnline')

        $ResourceConfigurationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $ResourceConfigurationParams.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $ResourceConfigurationParams)
        {
            Write-Verbose -Message "Setting Resource Configuration with values: $(Convert-M365DscHashtableToString -Hashtable $ResourceConfigurationParams)"
            Set-ResourceConfig @ResourceConfigurationParams -Confirm:$false
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
            $ResourceConfiguration = Get-ResourceConfig -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite

            Write-M365DSCHost -Message "    |---[1/1] $($ResourceConfiguration.Identity)" -DeferWrite

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

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
            $this.ExportedInstance = $ResourceConfiguration
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

    hidden [EXOResourceConfiguration] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOResourceConfiguration])
        {
            return $Values
        }

        $result = [EXOResourceConfiguration]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
