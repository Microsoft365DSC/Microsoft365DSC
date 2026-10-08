using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADNetworkAccessForwardingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the forwarding policy')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('List of rules associated to this forwarding policy.')]
    [MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule[]] $PolicyRules

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
    [System.ComponentModel.Description('Secret of the Azure Active Directory tenant used for authentication.')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AADNetworkAccessForwardingPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADNetworkAccessForwardingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD Network Access Forwarding Policy with Name {$($this.Name)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $instance = Get-MgBetaNetworkAccessForwardingPolicy -Expand * -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $this.Name }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                throw "Could not retrieve the Forwarding Policy with name: $($this.Name)"
            }

            $complexPolicyRules = $this.GetMicrosoftGraphNetworkAccessForwardingPolicyRules($instance.PolicyRules)

            $results = @{
                Name                  = $instance.Name
                PolicyRules           = $complexPolicyRules
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
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

        Write-Verbose -Message "Setting the AAD Network Access Forwarding Policy with Name {$($this.Name)}"

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $currentPolicy = Get-MgBetaNetworkAccessForwardingPolicy -Expand * -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $setParameters.Name }
        if ($this.Name -eq 'Custom Bypass')
        {
            foreach ($rule in $currentPolicy.PolicyRules)
            {
                Remove-MgBetaNetworkAccessForwardingPolicyRule -ForwardingPolicyId $currentPolicy.Id -PolicyRuleId $rule.Id
            }

            foreach ($rule in $setParameters.PolicyRules)
            {
                $complexDestinations = @()
                foreach ($destination in $rule.Destinations)
                {
                    $complexDestinations += @{
                        '@odata.type' = '#microsoft.graph.networkaccess.' + $rule.RuleType
                        value         = $destination
                    }
                }
                $params = @{
                    '@odata.type' = '#microsoft.graph.networkaccess.internetAccessForwardingRule'
                    name          = $rule.Name
                    action        = $rule.ActionValue
                    ruleType      = $rule.RuleType
                    ports         = ($rule.Ports | ForEach-Object { $_.ToString() })
                    protocol      = $rule.Protocol
                    destinations  = $complexDestinations
                }

                New-MgBetaNetworkAccessForwardingPolicyRule -ForwardingPolicyId $currentPolicy.Id -BodyParameter $params
            }
        }
        elseif ($currentPolicy.TrafficForwardingType -eq 'm365')
        {
            $rulesParam = @()
            foreach ($desiredRule in $setParameters.PolicyRules)
            {
                $desiredRuleHashtable = Convert-M365DSCDRGComplexTypeToHashtable $desiredRule
                $desiredRuleHashtable.Remove('actionValue')
                $testResult = $false
                foreach ($currentRule in $currentPolicy.PolicyRules)
                {
                    $currentRuleHashtable = $this.GetMicrosoftGraphNetworkAccessForwardingPolicyRules(@($currentRule))
                    $currentRuleHashtable.Remove('ActionValue')
                    $testResult = Compare-M365DSCComplexObject `
                        -Source ($currentRuleHashtable) `
                        -Target ($desiredRuleHashtable) `
                        -PropertyName 'PolicyRules'
                    if ($testResult)
                    {
                        Write-Verbose "Updating: $($currentRule.Name), $($currentRule.Id)"
                        $rulesParam += @{
                            ruleId = $currentRule.Id
                            action = $desiredRule.ActionValue
                        }
                        break
                    }
                }
                if ($testResult -eq $false)
                {
                    Write-Verbose "Could not find rule with the given specification: $(Convert-M365DscHashtableToString -Hashtable $desiredRuleHashtable), skipping set for this."
                }
            }
            $updateParams = @{
                rules = $rulesParam
            }

            Invoke-M365DSCGraphRequest -Uri "/beta/networkAccess/forwardingPolicies/$($currentPolicy.ID)/updatePolicyRules" -Method Post -Body $updateParams
        }
        else
        {
            Write-Verbose "Can not modify the list of poilicy rules for the forwarding policy with name: $($setParameters.Name)"
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

        try
        {
            [array] $exportedInstances = Get-MgBetaNetworkAccessForwardingPolicy `
                -All `
                -ExpandProperty * `
                -Filter $this.Filter `
                -ErrorAction Stop

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
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    ApplicationSecret     = $this.ApplicationSecret
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.PolicyRules)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'PolicyRules'
                            CimInstanceName = 'MicrosoftGraphNetworkAccessForwardingPolicyRule'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PolicyRules `
                        -CIMInstanceName 'MicrosoftGraphNetworkAccessForwardingPolicyRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PolicyRules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PolicyRules') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('PolicyRules')

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

    hidden [System.Object[]] GetMicrosoftGraphNetworkAccessForwardingPolicyRules([System.Object[]] $PolicyRules)
    {
        $newPolicyRules = @()
        foreach ($rule in $PolicyRules)
        {
            [System.String[]]$destinations = @()
            foreach ($destination in $rule.destinations)
            {
                $destinations += $destination.value
            }
            $newPolicyRules += [ordered]@{
                Name         = $rule.Name
                ActionValue  = $rule.action
                RuleType     = $rule.ruleType
                Ports        = [System.String[]]$rule.ports
                Protocol     = $rule.protocol
                Destinations = $destinations
            }
        }

        return $newPolicyRules
    }

    hidden [AADNetworkAccessForwardingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADNetworkAccessForwardingPolicy])
        {
            return $Values
        }

        $result = [AADNetworkAccessForwardingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphNetworkAccessForwardingPolicyRule
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Policy Rule Name. Required')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Action value.')]
    [System.String] $ActionValue

    [DscProperty()]
    [System.ComponentModel.Description('Type of Rule')]
    [System.String] $RuleType

    [DscProperty()]
    [System.ComponentModel.Description('List of Ports.')]
    [System.String[]] $Ports

    [DscProperty()]
    [System.ComponentModel.Description('Protocol Value')]
    [System.String] $Protocol

    [DscProperty()]
    [System.ComponentModel.Description('List of destinations.')]
    [System.String[]] $Destinations
}
