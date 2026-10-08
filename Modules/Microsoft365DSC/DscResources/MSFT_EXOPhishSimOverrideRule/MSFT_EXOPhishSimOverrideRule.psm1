using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOPhishSimOverrideRule : M365DSCResourceBase
{
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

    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The email domains used by the non-Microsoft phishing simulation, either the 5321.MailFrom domain or the DKIM domain. Up to 20 values.')]
    [System.String[]] $Domains

    [DscProperty()]
    [System.ComponentModel.Description('The source IP addresses used by the non-Microsoft phishing simulation, as single IP addresses, IP address ranges or CIDR ranges. Up to 10 values.')]
    [System.String[]] $SenderIpRanges

    [DscProperty()]
    [System.ComponentModel.Description('An optional comment for the override rule.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Ensures the presence or absence of the configuration.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOPhishSimOverrideRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOPhishSimOverrideRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of the Phishing Simulation Override Rule'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = [EXOPhishSimOverrideRule]::GetActiveInstance('Get-ExoPhishSimOverrideRule')
                $this.ResourceCache['Rule'] = $instance
                if ($null -eq $instance)
                {
                    Write-Verbose -Message 'Phishing Simulation Override Rule not found'
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Phishing Simulation Override Rule {$($instance.Identity)}"

            $results = @{
                IsSingleInstance      = 'Yes'
                SenderIpRanges        = [System.String[]] $instance.SenderIpRanges
                Domains               = [System.String[]] $instance.Domains
                Comment               = $instance.Comment
                Ensure                = 'Present'
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

        Write-Verbose -Message 'Setting configuration of the Phishing Simulation Override Rule'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $rule = $this.ResourceCache['Rule']
        $boundParameters = $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $policy = [EXOPhishSimOverrideRule]::GetActiveInstance('Get-PhishSimOverridePolicy')
            if ($null -eq $policy)
            {
                Write-Verbose -Message 'Creating the Phishing Simulation Override Policy'
                $policy = [EXOPhishSimOverrideRule]::InvokeExchangeCommand('New-PhishSimOverridePolicy', @{ Name = 'PhishSimOverridePolicy' }) | Select-Object -First 1
            }

            $newParameters = @{
                Policy         = $policy.Identity
                SenderIpRanges = $this.SenderIpRanges
            }

            if ($boundParameters.ContainsKey('Domains'))
            {
                $newParameters.Domains = $this.Domains
            }

            if ($boundParameters.ContainsKey('Comment'))
            {
                $newParameters.Comment = $this.Comment
            }

            Write-Verbose -Message 'Creating the Phishing Simulation Override Rule'
            $null = [EXOPhishSimOverrideRule]::InvokeExchangeCommand('New-ExoPhishSimOverrideRule', $newParameters)
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $setParameters = @{
                Identity = $rule.Identity
            }

            if ($boundParameters.ContainsKey('Comment') -and $this.Comment -ne $currentInstance.Comment)
            {
                $setParameters.Comment = $this.Comment
            }

            if ($boundParameters.ContainsKey('Domains'))
            {
                [EXOPhishSimOverrideRule]::AddDeltaParameters($setParameters, 'Domains', $this.Domains, $currentInstance.Domains)
            }

            if ($boundParameters.ContainsKey('SenderIpRanges'))
            {
                [EXOPhishSimOverrideRule]::AddDeltaParameters($setParameters, 'SenderIpRanges', $this.SenderIpRanges, $currentInstance.SenderIpRanges)
            }

            if ($setParameters.Count -gt 1)
            {
                Write-Verbose -Message "Updating Phishing Simulation Override Rule {$($rule.Identity)}"
                $null = [EXOPhishSimOverrideRule]::InvokeExchangeCommand('Set-ExoPhishSimOverrideRule', $setParameters)
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Phishing Simulation Override Rule {$($rule.Identity)}"
            $null = [EXOPhishSimOverrideRule]::InvokeExchangeCommand('Remove-ExoPhishSimOverrideRule', @{ Identity = $rule.Identity; Confirm = $false })
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
            $rule = [EXOPhishSimOverrideRule]::GetActiveInstance('Get-ExoPhishSimOverrideRule')
            if ($null -eq $rule)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }

            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

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
            $this.ExportedInstance = $rule
            $Results = $this.GetForExport($params)
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName
            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            return $currentDSCBlock
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden static [System.Object[]] InvokeExchangeCommand([System.String] $CommandName, [System.Collections.Hashtable] $Parameters)
    {
        $commandErrors = $null
        $output = @(& $CommandName @Parameters -ErrorVariable commandErrors)
        if ($output.Count -eq 0 -and @($commandErrors).Count -gt 0)
        {
            throw $commandErrors[-1]
        }

        return $output
    }

    hidden static [System.Object] GetActiveInstance([System.String] $CommandName)
    {
        $instances = [EXOPhishSimOverrideRule]::InvokeExchangeCommand($CommandName, @{})
        return $instances | Where-Object -Property Mode -NE 'PendingDeletion' | Select-Object -First 1
    }

    hidden static [void] AddDeltaParameters([System.Collections.Hashtable] $Parameters, [System.String] $Name, [System.String[]] $Desired, [System.String[]] $Current)
    {
        $toAdd = @($Desired | Where-Object -FilterScript { $_ -notin $Current })
        $toRemove = @($Current | Where-Object -FilterScript { $_ -notin $Desired })
        if ($toAdd.Count -gt 0)
        {
            $Parameters["Add$Name"] = $toAdd
        }
        if ($toRemove.Count -gt 0)
        {
            $Parameters["Remove$Name"] = $toRemove
        }
    }

    hidden [EXOPhishSimOverrideRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOPhishSimOverrideRule])
        {
            return $Values
        }

        $result = [EXOPhishSimOverrideRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
