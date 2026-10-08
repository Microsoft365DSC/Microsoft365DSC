using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365OrgCustomizationSetting : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the State of the configuration. Cannot be set to ''Absent'', must always be ''Present''.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $State

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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

    [O365OrgCustomizationSetting] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365OrgCustomizationSetting]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of the O365 Org Customization Setting'

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = @{
                IsSingleInstance = 'Yes'
                State            = 'Absent'
            }

            $orgConfig = Get-OrganizationConfig -ErrorAction Stop

            if ($null -eq $orgConfig)
            {
                throw 'Failed to retrieve the Organization Configuration. Please ensure that you have the necessary permissions to access this information.'
            }

            if ($orgConfig.IsDehydrated -eq $false)
            {
                return $this.AsResult(@{
                    IsSingleInstance      = 'Yes'
                    State                 = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                })
            }

            return $this.AsResult($nullReturn)
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

        Write-Verbose -Message 'Setting configuration of the O365 Org Customization Setting'

        if ($this.State -eq 'Absent')
        {
            Write-Warning -Message 'Organization customization cannot be disabled once it has been enabled. No change will be made.'
            return
        }

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        Write-Verbose -Message 'Configuration changes can take up to 24 hours to be applied.'
        Enable-OrganizationCustomization | Out-Null
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
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
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            $dscContent = [System.Text.StringBuilder]::new()
            if ($Results.State -eq 'Present')
            {
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
            }
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [O365OrgCustomizationSetting] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365OrgCustomizationSetting])
        {
            return $Values
        }

        $result = [O365OrgCustomizationSetting]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
