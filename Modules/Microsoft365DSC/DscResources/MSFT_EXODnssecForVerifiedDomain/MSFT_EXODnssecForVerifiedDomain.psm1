using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXODnssecForVerifiedDomain : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('DomainName parameter specifies the accepted domain in the Exchange Online organization where you want to view information about DNSSEC')]
    [System.String] $DomainName

    [DscProperty()]
    [System.ComponentModel.Description('Status of the DnsSec for the given Domain Name.')]
    [ValidateSet('Enabled', 'Disabled', 'Unknown')]
    [System.String] $DnssecFeatureStatus

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

    [EXODnssecForVerifiedDomain] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXODnssecForVerifiedDomain]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for DnssecForVerifiedDomain with DomainName $($this.DomainName)"

        try
        {
            $null = $this.Connect('ExchangeOnline')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.DnssecFeatureStatus = 'Unknown'

            $instance = Invoke-M365DSCCommand -ScriptBlock { Get-DnssecStatusForVerifiedDomain -DomainName $this.DomainName } -SuppressNotFoundError
            if ('Unknown' -eq $instance.DnssecFeatureStatus.ToString())
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                DomainName            = $this.DomainName
                DnssecFeatureStatus   = $instance.DnssecFeatureStatus.ToString()
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for DnssecForVerifiedDomain with DomainName $($this.DomainName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        # Enable
        if ($this.DnssecFeatureStatus -eq 'Enabled' -and $currentInstance.DnssecFeatureStatus -eq 'Disabled')
        {
            Enable-DnssecForVerifiedDomain -DomainName $setParameters.DomainName
        }
        # Disable
        elseif ($this.DnssecFeatureStatus -eq 'Disabled' -and $currentInstance.DnssecFeatureStatus -eq 'Enabled')
        {
            Disable-DnssecForVerifiedDomain -DomainName $setParameters.DomainName
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-AcceptedDomain -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $exportedInstances)
            {
                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DomainName            = $config.DomainName
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
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXODnssecForVerifiedDomain] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXODnssecForVerifiedDomain])
        {
            return $Values
        }

        $result = [EXODnssecForVerifiedDomain]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
