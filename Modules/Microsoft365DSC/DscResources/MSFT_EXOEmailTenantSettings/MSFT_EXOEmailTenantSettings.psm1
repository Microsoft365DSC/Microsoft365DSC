using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOEmailTenantSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Identity which indicates the organization name.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether priority account protection is enabled.')]
    [System.Nullable[System.Boolean]] $EnablePriorityAccountProtection

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the migration configuration is valid.')]
    [System.Nullable[System.Boolean]] $IsValid

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the state of the object.')]
    [System.String] $ObjectState

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the name of the object.')]
    [System.String] $Name

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
    [System.ComponentModel.Description('Path to certificate used in service principal usually a PFX file.')]
    [System.String] $CertificatePath

    [DscProperty()]
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword')]
    [System.Management.Automation.PSCredential] $CertificatePassword

    [DscProperty()]
    [System.ComponentModel.Description('Managed ID being used for authentication.')]
    [System.Nullable[System.Boolean]] $ManagedIdentity

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [EXOEmailTenantSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOEmailTenantSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting EXO Email Tenant Settings'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $EmailTenantSettings = Get-EmailTenantSettings -ErrorAction SilentlyContinue
                if ($null -eq $EmailTenantSettings)
                {
                    throw 'Could not find the Email Tenant Settings.'
                }
            }
            else
            {
                $EmailTenantSettings = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found Email Tenant Settings config '

            $result = @{
                IsSingleInstance                = 'Yes'
                Identity                        = $EmailTenantSettings.Identity
                EnablePriorityAccountProtection = $EmailTenantSettings.EnablePriorityAccountProtection
                Name                            = $EmailTenantSettings.Name
                IsValid                         = $EmailTenantSettings.IsValid
                ObjectState                     = $EmailTenantSettings.ObjectState
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePath                 = $this.CertificatePath
                CertificatePassword             = $this.CertificatePassword
                ManagedIdentity                 = $this.ManagedIdentity
                TenantId                        = $this.TenantId
                AccessTokens                    = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Email tenant setings'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $EmailTenantSettingsParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        #removing params that cannot be set.
        $EmailTenantSettingsParams.Remove('Name') | Out-Null
        $EmailTenantSettingsParams.Remove('IsValid') | Out-Null
        $EmailTenantSettingsParams.Remove('ObjectState') | Out-Null
        $EmailTenantSettingsParams.Remove('IsSingleInstance') | Out-Null

        if ($null -ne $EmailTenantSettingsParams)
        {
            Write-Verbose -Message "Setting Email tenant settings with values: $(Convert-M365DscHashtableToString -Hashtable $EmailTenantSettingsParams)"
            Set-EmailTenantSettings @EmailTenantSettingsParams

            Write-Verbose -Message 'Email tenant settings updated successfully'
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

            $EmailTenantSettings = Get-EmailTenantSettings -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite

            Write-M365DSCHost -Message "    |---[1/1] $($EmailTenantSettings.Identity)" -DeferWrite

            $Params = @{
                IsSingleInstance      = 'Yes'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePassword   = $this.CertificatePassword
                CertificatePath       = $this.CertificatePath
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }
            $this.ExportedInstance = $EmailTenantSettings
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

    hidden [EXOEmailTenantSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOEmailTenantSettings])
        {
            return $Values
        }

        $result = [EXOEmailTenantSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
