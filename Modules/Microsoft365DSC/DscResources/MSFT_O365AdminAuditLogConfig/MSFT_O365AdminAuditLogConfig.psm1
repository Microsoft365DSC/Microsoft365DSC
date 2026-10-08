using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class O365AdminAuditLogConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Determins if Unified Audit Log Ingestion is enabled')]
    [ValidateSet('Enabled', 'Disabled')]
    [System.String] $UnifiedAuditLogIngestionEnabled

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

    [O365AdminAuditLogConfig] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [O365AdminAuditLogConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for Office 365 Audit Log'

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullReturn = @{
                IsSingleInstance = $this.IsSingleInstance
            }

            $GetResults = Get-AdminAuditLogConfig -ErrorAction Stop
            if (-not $GetResults)
            {
                Write-Warning 'Unable to determine Unified Audit Log Ingestion State.'
                return $this.AsResult($nullReturn)
            }
            else
            {
                if ($GetResults.UnifiedAuditLogIngestionEnabled)
                {
                    $UnifiedAuditLogIngestionEnabledReturnValue = 'Enabled'
                }
                else
                {
                    $UnifiedAuditLogIngestionEnabledReturnValue = 'Disabled'
                }

                $Result = @{
                    IsSingleInstance                = $this.IsSingleInstance
                    Credential                      = $this.Credential
                    ApplicationId                   = $this.ApplicationId
                    TenantId                        = $this.TenantId
                    CertificateThumbprint           = $this.CertificateThumbprint
                    CertificatePath                 = $this.CertificatePath
                    CertificatePassword             = $this.CertificatePassword
                    ManagedIdentity                 = $this.ManagedIdentity
                    UnifiedAuditLogIngestionEnabled = $UnifiedAuditLogIngestionEnabledReturnValue
                    AccessTokens                    = $this.AccessTokens
                }
                return $this.AsResult($Result)
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
        $ErrorActionPreference = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message 'Setting configuration for Office 365 Audit Log'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $OldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        if ($this.UnifiedAuditLogIngestionEnabled -eq 'Enabled')
        {
            try
            {
                Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
            }
            catch
            {
                $Message = "Couldn't set the Audit Log Ingestion. Please run Enable-OrganizationCustomization first."
                $this.LogError($_, $Message)

                throw $Message
            }
        }
        else
        {
            try
            {
                Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $false
            }
            catch
            {
                $Message = "Couldn't set the Audit Log Ingestion. Please run Enable-OrganizationCustomization first."
                $this.LogError($_, $Message)

                throw $Message
            }
        }
        $ErrorActionPreference = $OldErrorActionPreference
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
            $O365AdminAuditLogConfig = Get-AdminAuditLogConfig -ErrorAction Stop
            $value = 'Disabled'
            if ($O365AdminAuditLogConfig.UnifiedAuditLogIngestionEnabled)
            {
                $value = 'Enabled'
            }

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $dscContent = [System.Text.StringBuilder]::new()
            $Params = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = $value
                Credential                      = $this.Credential
                ApplicationId                   = $this.ApplicationId
                TenantId                        = $this.TenantId
                CertificateThumbprint           = $this.CertificateThumbprint
                CertificatePassword             = $this.CertificatePassword
                CertificatePath                 = $this.CertificatePath
                ManagedIdentity                 = $this.ManagedIdentity
                AccessTokens                    = $this.AccessTokens
            }
            $Results = $this.GetForExport($Params)
            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
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

    hidden [O365AdminAuditLogConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [O365AdminAuditLogConfig])
        {
            return $Values
        }

        $result = [O365AdminAuditLogConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
