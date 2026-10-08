using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADExternalIdentityPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Reserved for future use.')]
    [System.Nullable[System.Boolean]] $AllowDeletedIdentitiesDataRemoval

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Defines whether external users can leave the guest tenant. If set to false, self-service controls are disabled, and the admin of the guest tenant must manually remove the external user from the guest tenant. When the external user leaves the tenant, their data in the guest tenant is first soft-deleted then permanently deleted in 30 days.')]
    [System.Nullable[System.Boolean]] $AllowExternalIdentitiesToLeave

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Azure Active Directory application to authenticate with.')]
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

    [AADExternalIdentityPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADExternalIdentityPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of External Identity Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $Policy = Get-MgBetaPolicyExternalIdentityPolicy -ErrorAction Stop

            $result = @{
                IsSingleInstance                  = 'Yes'
                AllowDeletedIdentitiesDataRemoval = $Policy.allowDeletedIdentitiesDataRemoval
                AllowExternalIdentitiesToLeave    = $Policy.allowExternalIdentitiesToLeave
                Credential                        = $this.Credential
                ApplicationSecret                 = $this.ApplicationSecret
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
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
        $DisplayName = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration for External Identity Policy'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $desiredParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $desiredParameters.Remove('IsSingleInstance') | Out-Null

        try
        {
            Write-Verbose -Message "Updating existing authorization policy with values: $(Convert-M365DscHashtableToString -Hashtable $desiredParameters)"
            Update-MgBetaPolicyExternalIdentityPolicy -BodyParameter $desiredParameters -ErrorAction Stop | Out-Null
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')
            throw
        }
        Write-Verbose -Message "Set(): finished processing Policy $Displayname"
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $currentDSCBlock = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        try
        {
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                IsSingleInstance               = 'Yes'
                AllowExternalIdentitiesToLeave = $true
                Credential                     = $this.Credential
                ApplicationId                  = $this.ApplicationId
                TenantId                       = $this.TenantId
                ApplicationSecret              = $this.ApplicationSecret
                CertificateThumbprint          = $this.CertificateThumbprint
                CertificatePath                = $this.CertificatePath
                CertificatePassword            = $this.CertificatePassword
                ManagedIdentity                = $this.ManagedIdentity
                AccessTokens                   = $this.AccessTokens
            }
            $Results = $this.GetForExport($Params)

            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                Write-M365DSCHost -Message '    |---[1/1] External Identity Policy' -DeferWrite
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $results `
                    -Credential $this.Credential
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $currentDSCBlock
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADExternalIdentityPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADExternalIdentityPolicy])
        {
            return $Values
        }

        $result = [AADExternalIdentityPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
