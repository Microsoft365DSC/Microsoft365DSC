using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADB2CAuthenticationMethodsPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The tenant admin can configure local accounts using email if the email and password authentication method is enabled.')]
    [System.Nullable[System.Boolean]] $IsEmailPasswordAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The tenant admin can configure local accounts using username if the username and password authentication method is enabled.')]
    [System.Nullable[System.Boolean]] $IsUserNameAuthenticationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The tenant admin can configure local accounts using phone number if the phone number and one-time password authentication method is enabled.')]
    [System.Nullable[System.Boolean]] $IsPhoneOneTimePasswordAuthenticationEnabled

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

    [AADB2CAuthenticationMethodsPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADB2CAuthenticationMethodsPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the Azure AD B2C Authentication Methods Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-MgBetaPolicyB2CAuthenticationMethodPolicy -ErrorAction SilentlyContinue

            if ($null -eq $instance)
            {
                throw 'There was an error retrieving values from the Get function in AADB2CAuthenticationMethodsPolicy.'
            }

            $results = @{
                IsSingleInstance                            = 'Yes'
                IsEmailPasswordAuthenticationEnabled        = $instance.IsEmailPasswordAuthenticationEnabled
                IsUserNameAuthenticationEnabled             = $instance.IsUserNameAuthenticationEnabled
                IsPhoneOneTimePasswordAuthenticationEnabled = $instance.IsPhoneOneTimePasswordAuthenticationEnabled
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
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

        Write-Verbose -Message 'Setting the Azure AD B2C Authentication Methods Policy'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('IsSingleInstance') | Out-Null
        Write-Verbose -Message 'Updating B2C Authentication Methods Policy'
        Update-MgBetaPolicyB2CAuthenticationMethodPolicy -BodyParameter $setParameters
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $i = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        #Ensure the proper dependencies are installed in the current environment.
        Confirm-M365DSCDependencies

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

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

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADB2CAuthenticationMethodsPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADB2CAuthenticationMethodsPolicy])
        {
            return $Values
        }

        $result = [AADB2CAuthenticationMethodsPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
