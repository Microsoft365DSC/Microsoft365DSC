using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADSecurityDefaults : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the security defaults.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the security defaults.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Represents whether or not security defaults are enabled.')]
    [System.Nullable[System.Boolean]] $IsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Azure AD Admin')]
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

    [AADSecurityDefaults] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADSecurityDefaults]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for Azure AD Security Defaults'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $defaults = Get-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy -ErrorAction Stop

            $result = @{
                IsSingleInstance = 'Yes'
                DisplayName      = $defaults.DisplayName
                Description      = $defaults.Description
                IsEnabled        = $defaults.IsEnabled
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

        Write-Verbose -Message 'Setting configuration for Azure AD Security Defaults'
        $CurrentValues = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        if ($CurrentValues.DisplayName -ne $this.DisplayName)
        {
            Write-Verbose -Message 'The DisplayName property for the AADSecurityDefaults resource is read-only and cannot be changed.'
        }

        if ($CurrentValues.Description -ne $this.Description)
        {
            Write-Verbose -Message 'The Description property for the AADSecurityDefaults resource is read-only and cannot be changed.'
        }

        $updateParameters = @{
            id        = $this.DisplayName
            isEnabled = $this.IsEnabled
        }
        Update-MgBetaPolicyIdentitySecurityDefaultEnforcementPolicy -BodyParameter $updateParameters | Out-Null
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $Params = @{
                IsSingleInstance = 'Yes'
            }
            $dscContent = [System.Text.StringBuilder]::new()
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
}
