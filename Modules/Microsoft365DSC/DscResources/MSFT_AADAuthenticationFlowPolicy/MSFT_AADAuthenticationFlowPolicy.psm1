using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADAuthenticationFlowPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the Authentication Flow Policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the Authentication Flow Policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Authentication Flow Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Indicates whether self-service sign-up flow is enabled or disabled. The default value is false. This property isn''t a key. Required.')]
    [System.Nullable[System.Boolean]] $SelfServiceSignUpEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Azure Active Directory Admin')]
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

    [AADAuthenticationFlowPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADAuthenticationFlowPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Authentication Flow Policy'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $flowPolicy = Get-MgBetaPolicyAuthenticationFlowPolicy -ErrorAction 'SilentlyContinue'

            if ($null -eq $flowPolicy)
            {
                throw 'Could not retrieve Authentication Flow Policy'
            }
            else
            {
                Write-Verbose -Message 'Found existing Authentication Flow Policy'
                $result = @{
                    IsSingleInstance         = 'Yes'
                    Id                       = $flowPolicy.Id
                    DisplayName              = $flowPolicy.DisplayName
                    Description              = $flowPolicy.Description
                    SelfServiceSignUpEnabled = [Boolean]$flowPolicy.SelfServiceSignUp.IsEnabled
                    Credential               = $this.Credential
                    ApplicationId            = $this.ApplicationId
                    TenantId                 = $this.TenantId
                    ApplicationSecret        = $this.ApplicationSecret
                    CertificateThumbprint    = $this.CertificateThumbprint
                    ManagedIdentity          = $this.ManagedIdentity
                    AccessTokens             = $this.AccessTokens
                }
                return $this.AsResult($result)
            }
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

        Write-Verbose -Message 'Setting configuration of Authentication flow policy.'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $Params = @{
                selfServiceSignUp = @{
                    isEnabled = $this.SelfServiceSignUpEnabled
                }
            }
            Update-MgBetaPolicyAuthenticationFlowPolicy -BodyParameter $Params | Out-Null
        }
        catch
        {
            Write-Verbose -Message 'Cannot update the authentication flow policy.'
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()
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
                ApplicationSecret     = $this.ApplicationSecret
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            }

            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADAuthenticationFlowPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADAuthenticationFlowPolicy])
        {
            return $Values
        }

        $result = [AADAuthenticationFlowPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
