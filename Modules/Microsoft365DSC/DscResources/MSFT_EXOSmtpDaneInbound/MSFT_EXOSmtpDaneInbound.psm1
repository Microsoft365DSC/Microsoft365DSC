using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSmtpDaneInbound : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the accepted domain in the Exchange Online organization where you want to enable SMTP DANE')]
    [System.String] $DomainName

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures SmtpDaneInbound is enabled, absent ensures it is disabled.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

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

    [EXOSmtpDaneInbound] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSmtpDaneInbound]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting SmtpDaneInbound configuration for {$($this.DomainName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DomainName -ne $this.DomainName)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-AcceptedDomain -Identity $this.DomainName -ErrorAction SilentlyContinue
                if ($null -eq $instance -or $instance.SmtpDaneStatus -ne 'Enabled')
                {
                    Write-Verbose -Message "No EXO SmtpDaneInbound found with DomainName {$($this.DomainName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found an EXO SmtpDaneInbound instance with DomainName {$($this.DomainName)}"

            $results = @{
                DomainName            = $instance.DomainName
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                TenantId              = $this.TenantId
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

        Write-Verbose -Message "Setting SmtpDaneInbound configuration for {$($this.DomainName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Enabling SmtpDaneInbound for {$($this.DomainName)}"
            try
            {
                $response = Enable-SmtpDaneInbound -DomainName $this.DomainName -ErrorAction Stop
                if ($response.Result -eq 'Error')
                {
                    throw $response.ErrorData
                }
            }
            catch
            {
                Write-Warning -Message "Cannot enable SmtpDaneInbound for DomainName $($this.DomainName) - check that DNSSEC is enabled"
                $this.LogError($_, "Error enabling SmtpDaneInbound for DomainName '$($this.DomainName)'")

                throw
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Disabling SmtpDaneInbound for {$($this.DomainName)}"
            $response = Disable-SmtpDaneInbound -DomainName $currentInstance.DomainName -ErrorAction Stop
            if ($response.Result -eq 'Error')
            {
                throw "Error disabling SmtpDaneInbound for DomainName '$($this.DomainName)': $($response.ErrorData)"
            }
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
            [array]$getValue = Get-AcceptedDomain -ResultSize Unlimited -ErrorAction Stop
            $getValue = $getValue | Where-Object { $_.SmtpDaneStatus -eq 'Enabled' }

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.DomainName
                if (-not [String]::IsNullOrEmpty($config.DisplayName))
                {
                    $displayedKey = $config.DisplayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DomainName            = $config.DomainName
                    Ensure                = 'Present'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    TenantId              = $this.TenantId
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $config
                $Results = $this.GetForExport($params)
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

    hidden [EXOSmtpDaneInbound] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSmtpDaneInbound])
        {
            return $Values
        }

        $result = [EXOSmtpDaneInbound]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
