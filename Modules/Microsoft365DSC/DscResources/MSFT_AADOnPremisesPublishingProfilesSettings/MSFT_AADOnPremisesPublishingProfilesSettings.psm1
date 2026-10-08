using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADOnPremisesPublishingProfilesSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether default access for app proxy is enabled or disabled.')]
    [System.Nullable[System.Boolean]] $IsDefaultAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables of disables private net work connectors in Entra Id.')]
    [System.Nullable[System.Boolean]] $IsEnabled

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

    [AADOnPremisesPublishingProfilesSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADOnPremisesPublishingProfilesSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the AAD On-Premises Publishing Profiles Settings'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $uri = "/beta/onPremisesPublishingProfiles('applicationProxy')"
            $instance = Invoke-M365DSCGraphRequest -Uri $uri -Method Get

            $results = @{
                IsSingleInstance       = 'Yes'
                IsDefaultAccessEnabled = $instance.isDefaultAccessEnabled
                IsEnabled              = $instance.IsEnabled
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $this.TenantId
                ApplicationSecret      = $this.ApplicationSecret
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
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

        Write-Verbose -Message 'Setting the AAD On-Premises Publishing Profiles Settings'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $settings = @{}
        if ($null -ne $this.IsEnabled)
        {
            Write-Verbose -Message "Updating the IsEnabled setting to {$($this.IsEnabled.ToString())}"
            $settings.isEnabled = $this.IsEnabled
        }
        if ($null -ne $this.IsDefaultAccessEnabled)
        {
            Write-Verbose -Message "Updating the IsDefaultAccessEnabled setting to {$($this.IsDefaultAccessEnabled.ToString())}"
            $settings.isDefaultAccessEnabled = $this.IsDefaultAccessEnabled
        }
        $body = ConvertTo-Json $settings
        $uri = "/beta/onPremisesPublishingProfiles('applicationProxy')"
        Invoke-M365DSCGraphRequest -Uri $uri -Method PATCH -Body $Body | Out-Null
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
            $dscContent = [System.Text.StringBuilder]::new()
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                ISSingleInstance      = 'Yes'
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

    hidden [AADOnPremisesPublishingProfilesSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADOnPremisesPublishingProfilesSettings])
        {
            return $Values
        }

        $result = [AADOnPremisesPublishingProfilesSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
