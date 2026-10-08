using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOTeamsProtectionPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AdminDisplayName parameter specifies a description for the policy.')]
    [System.String] $AdminDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The HighConfidencePhishQuarantineTag parameter specifies the quarantine policy that''s used for messages that are quarantined as high confidence phishing by ZAP for Teams.')]
    [ValidateSet('AdminOnlyAccessPolicy', 'DefaultFullAccessPolicy', 'DefaultFullAccessWithNotificationPolicy')]
    [System.String] $HighConfidencePhishQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The MalwareQuarantineTag parameter specifies the quarantine policy that''s used for messages that are quarantined as malware by ZAP for Teams.')]
    [ValidateSet('AdminOnlyAccessPolicy', 'DefaultFullAccessPolicy', 'DefaultFullAccessWithNotificationPolicy')]
    [System.String] $MalwareQuarantineTag

    [DscProperty()]
    [System.ComponentModel.Description('The ZapEnabled parameter specifies whether to enable zero-hour auto purge (ZAP) for malware and high confidence phishing messages in Teams messages.')]
    [System.Nullable[System.Boolean]] $ZapEnabled

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

    [EXOTeamsProtectionPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOTeamsProtectionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of EXO Teams Protection Policy'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = @{
                    IsSingleInstance                 = 'Yes'
                    AdminDisplayName                 = $null
                    HighConfidencePhishQuarantineTag = $null
                    MalwareQuarantineTag             = $null
                    ZapEnabled                       = $null
                }

                $ProtectionPolicy = Get-TeamsProtectionPolicy -ErrorAction SilentlyContinue
                if ($null -eq $ProtectionPolicy)
                {
                    Write-Verbose -Message 'Teams Protection Policy does not exist.'
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $ProtectionPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message 'An EXO Teams Protection Policy was found.'
            $result = @{
                IsSingleInstance                 = 'Yes'
                AdminDisplayName                 = $ProtectionPolicy.AdminDisplayName
                HighConfidencePhishQuarantineTag = $ProtectionPolicy.HighConfidencePhishQuarantineTag
                MalwareQuarantineTag             = $ProtectionPolicy.MalwareQuarantineTag
                ZapEnabled                       = $ProtectionPolicy.ZapEnabled
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                TenantId                         = $this.TenantId
                AccessTokens                     = $this.AccessTokens
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
        Write-Verbose -Message 'Setting configuration of Teams Protection Policy'

        $currentValues = $this.Get().ToHashtable()

        if ($null -eq $currentValues.AdminDisplayName -and `
                $null -eq $currentValues.HighConfidencePhishQuarantineTag -and `
                $null -eq $currentValues.MalwareQuarantineTag -and `
                $null -eq $currentValues.ZapEnabled)
        {
            Write-Verbose -Message 'Teams Protection Policy does not exist, creating new policy'
            New-TeamsProtectionPolicy -Name 'Teams Protection Policy'
        }

        $params = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $params.Add('Identity', 'Teams Protection Policy')
        $params.Remove('IsSingleInstance')

        Set-TeamsProtectionPolicy @params
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

            $dscContent = [System.Text.StringBuilder]::new()

            [array]$teamsProtectionPolicy = Get-TeamsProtectionPolicy -ErrorAction Stop
            if ($null -ne $teamsProtectionPolicy)
            {
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
                $this.ExportedInstance = $teamsProtectionPolicy
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults

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

    hidden [EXOTeamsProtectionPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOTeamsProtectionPolicy])
        {
            return $Values
        }

        $result = [EXOTeamsProtectionPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
