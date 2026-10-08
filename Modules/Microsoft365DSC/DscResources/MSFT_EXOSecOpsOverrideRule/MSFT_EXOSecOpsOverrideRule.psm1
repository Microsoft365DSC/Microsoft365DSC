using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOSecOpsOverrideRule : M365DSCResourceBase
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
    [System.ComponentModel.Description('The email addresses of the SecOps mailboxes. Distribution groups are not allowed. Managed on the SecOps override policy.')]
    [System.String[]] $SentTo

    [DscProperty()]
    [System.ComponentModel.Description('An optional comment for the override rule.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Ensures the presence or absence of the SecOps override rule.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [EXOSecOpsOverrideRule] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOSecOpsOverrideRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of the SecOps Override Rule'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = [EXOSecOpsOverrideRule]::GetActiveInstance('Get-ExoSecOpsOverrideRule')
                $this.ResourceCache['Rule'] = $instance
                if ($null -eq $instance)
                {
                    Write-Verbose -Message 'SecOps Override Rule not found'
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "Found SecOps Override Rule {$($instance.Identity)}"

            $policy = [EXOSecOpsOverrideRule]::GetActiveInstance('Get-SecOpsOverridePolicy')
            $this.ResourceCache['Policy'] = $policy
            $sentToValue = $instance.SentTo
            if ($null -ne $policy)
            {
                $sentToValue = $policy.SentTo
            }

            $results = @{
                IsSingleInstance      = 'Yes'
                SentTo                = [System.String[]] $sentToValue
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

        Write-Verbose -Message 'Setting configuration of the SecOps Override Rule'

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $rule = $this.ResourceCache['Rule']
        $boundParameters = $this.GetBoundParameters()

        $policy = $null
        if ($this.Ensure -eq 'Present')
        {
            $policy = $this.ResourceCache['Policy']
            if ($null -eq $policy)
            {
                $policy = [EXOSecOpsOverrideRule]::GetActiveInstance('Get-SecOpsOverridePolicy')
            }

            $desiredSentTo = [System.String[]] $this.SentTo
            if (-not $boundParameters.ContainsKey('SentTo') -and $null -ne $policy)
            {
                $desiredSentTo = [System.String[]] $policy.SentTo
            }

            if ($desiredSentTo.Count -eq 0)
            {
                throw "SentTo must contain at least one mailbox. Use Ensure = 'Absent' to remove the SecOps override."
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message 'Creating the SecOps Override Policy'
                $policy = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('New-SecOpsOverridePolicy', @{ Name = 'SecOpsOverridePolicy'; SentTo = $this.SentTo }) | Select-Object -First 1
            }
            elseif ($boundParameters.ContainsKey('SentTo'))
            {
                $policyParameters = @{
                    Identity = $policy.Identity
                }
                [EXOSecOpsOverrideRule]::AddDeltaParameters($policyParameters, 'SentTo', $this.SentTo, [System.String[]] $policy.SentTo)
                if ($policyParameters.Count -gt 1)
                {
                    Write-Verbose -Message 'Updating the SecOps mailboxes of the SecOps Override Policy'
                    $null = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('Set-SecOpsOverridePolicy', $policyParameters)
                }
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $newParameters = @{
                Policy = $policy.Identity
            }
            if ($boundParameters.ContainsKey('Comment'))
            {
                $newParameters.Comment = $this.Comment
            }

            Write-Verbose -Message 'Creating the SecOps Override Rule'
            $null = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('New-ExoSecOpsOverrideRule', $newParameters)
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($boundParameters.ContainsKey('Comment') -and $this.Comment -ne $currentInstance.Comment)
            {
                Write-Verbose -Message "Updating SecOps Override Rule {$($rule.Identity)}"
                $null = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('Set-ExoSecOpsOverrideRule', @{ Identity = $rule.Identity; Comment = $this.Comment })
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing SecOps Override Rule {$($rule.Identity)}"
            $null = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('Remove-ExoSecOpsOverrideRule', @{ Identity = $rule.Identity; Confirm = $false })

            $policy = $this.ResourceCache['Policy']
            if ($null -eq $policy)
            {
                $policy = [EXOSecOpsOverrideRule]::GetActiveInstance('Get-SecOpsOverridePolicy')
            }

            $currentSentTo = [System.String[]] $policy.SentTo
            if ($null -ne $policy -and $currentSentTo.Count -gt 0)
            {
                Write-Verbose -Message 'Removing the SecOps mailboxes from the SecOps Override Policy'
                $null = [EXOSecOpsOverrideRule]::InvokeExchangeCommand('Set-SecOpsOverridePolicy', @{ Identity = $policy.Identity; RemoveSentTo = $currentSentTo })
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
            $rule = [EXOSecOpsOverrideRule]::GetActiveInstance('Get-ExoSecOpsOverrideRule')
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
        $instances = [EXOSecOpsOverrideRule]::InvokeExchangeCommand($CommandName, @{})
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

    hidden [EXOSecOpsOverrideRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOSecOpsOverrideRule])
        {
            return $Values
        }

        $result = [EXOSecOpsOverrideRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
