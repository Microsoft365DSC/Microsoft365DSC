using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGSATLSInspectionPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the TLS Inspection Policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Optional description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The default action to take when no rules match. Controls the fallback behavior for unmatched traffic.')]
    [ValidateSet('bypass', 'inspect', 'unknownFutureValue')]
    [System.String] $DefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('The rules that define the specific matching conditions and desired actions for TLS inspection.')]
    [MSFT_AADGSATLSInspectionPolicyRule[]] $Rules

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the workload''s Admin.')]
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
    [System.ComponentModel.Description('Username can be made up to anything but password will be used for CertificatePassword.')]
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

    [AADGSATLSInspectionPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGSATLSInspectionPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD GSA TLS Inspection Policy {$($this.Name)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            Confirm-M365DSCDependencies

            $this.AddTelemetry('Get')

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $instance = $null
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Retrieving TLS Inspection Policy by Id {$($this.Id)}"
                    $instance = Get-MgBetaNetworkAccessTlInspectionPolicy -TlsInspectionPolicyId $this.Id `
                        -ExpandProperty 'policyRules' `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Retrieving TLS Inspection Policy by Name {$($this.Name)}"
                    $instance = Get-MgBetaNetworkAccessTlInspectionPolicy -All `
                        -ExpandProperty 'policyRules' `
                        -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.Name -eq $this.Name }
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find AAD GSA TLS Inspection Policy {$($this.Name)}"
                return $this.AsResult($nullResult)
            }

            $rulesValue = @()
            if ($null -ne $instance.PolicyRules)
            {
                $rulesValue = [AADGSATLSInspectionPolicy]::GetRulesAsHashtable($instance.PolicyRules)
            }

            $results = @{
                Name          = $instance.Name
                Id            = $instance.Id
                Description   = $instance.Description
                DefaultAction = $instance.Settings.DefaultAction
                Rules         = $rulesValue
                Ensure        = 'Present'
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('MicrosoftGraph')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            name        = $this.Name
            description = $this.Description
            settings    = @{
                defaultAction = $this.DefaultAction
            }
        }

        $policyId = $currentInstance.Id

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new AAD GSA TLS Inspection Policy {$($this.Name)}"
            $newInstance = New-MgBetaNetworkAccessTlInspectionPolicy -BodyParameter $instanceParams
            $policyId = $newInstance.Id
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating AAD GSA TLS Inspection Policy {$($this.Name)} with Id {$($currentInstance.Id)}"
            Update-MgBetaNetworkAccessTlInspectionPolicy -TlsInspectionPolicyId $currentInstance.Id `
                -BodyParameter $instanceParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AAD GSA TLS Inspection Policy {$($this.Name)} with Id {$($currentInstance.Id)}"
            Remove-MgBetaNetworkAccessTlInspectionPolicy -TlsInspectionPolicyId $currentInstance.Id
        }

        if ($this.Ensure -eq 'Present' -and $null -ne $this.Rules)
        {
            $currentRules = @()
            if ($currentInstance.Ensure -eq 'Present' -and $null -ne $currentInstance.Rules)
            {
                $currentRules = $currentInstance.Rules
            }

            $matchedCurrentRuleIds = @()
            foreach ($desiredRule in $this.Rules)
            {
                $destinationsBody = @()
                foreach ($destination in $desiredRule.Destinations)
                {
                    $destinationsBody += @{
                        '@odata.type' = "#microsoft.graph.networkaccess.$($destination.Type)"
                        values        = $destination.Values
                    }
                }
                $ruleBody = @{
                    '@odata.type'      = '#microsoft.graph.networkaccess.tlsInspectionRule'
                    name               = $desiredRule.Name
                    priority           = $desiredRule.Priority
                    description        = $desiredRule.Description
                    action             = $desiredRule.Action
                    settings           = @{
                        status = $desiredRule.Status
                    }
                    matchingConditions = @{
                        destinations = $destinationsBody
                    }
                }

                $matchedRule = $currentRules | Where-Object -FilterScript { $_.Id -notin $matchedCurrentRuleIds -and $_.Name -eq $desiredRule.Name } | Select-Object -First 1

                if ($null -ne $matchedRule)
                {
                    $matchedCurrentRuleIds += $matchedRule.Id
                    Write-Verbose -Message "Updating TLS Inspection Rule {$($desiredRule.Name)} with Id {$($matchedRule.Id)}"
                    Update-MgBetaNetworkAccessTlInspectionPolicyRule -TlsInspectionPolicyId $policyId `
                        -PolicyRuleId $matchedRule.Id `
                        -BodyParameter $ruleBody
                }
                else
                {
                    Write-Verbose -Message "Creating new TLS Inspection Rule {$($desiredRule.Name)}"
                    New-MgBetaNetworkAccessTlInspectionPolicyRule -TlsInspectionPolicyId $policyId `
                        -BodyParameter $ruleBody
                }
            }

            foreach ($currentRule in $currentRules)
            {
                if ($currentRule.Id -notin $matchedCurrentRuleIds)
                {
                    Write-Verbose -Message "Removing TLS Inspection Rule {$($currentRule.Name)} with Id {$($currentRule.Id)}"
                    Remove-MgBetaNetworkAccessTlInspectionPolicyRule -TlsInspectionPolicyId $policyId `
                        -PolicyRuleId $currentRule.Id
                }
            }
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            CompareRules = @(
                @{ Type = 'IgnoreNested'; Paths = @('Rules[].Id') }
            )
        }
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
            [array] $exportedInstances = Get-MgBetaNetworkAccessTlInspectionPolicy -All -ExpandProperty 'policyRules' -ErrorAction Stop

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
                $Params = @{
                    Name = $config.Name
                    Id   = $config.Id
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.Rules -and $Results.Rules.Count -gt 0)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Rules'
                            CimInstanceName = 'AADGSATLSInspectionPolicyRule'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Destinations'
                            CimInstanceName = 'AADGSATLSInspectionPolicyRuleDestination'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Rules `
                        -CIMInstanceName 'AADGSATLSInspectionPolicyRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Rules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Rules') | Out-Null
                    }
                }
                else
                {
                    $Results.Remove('Rules') | Out-Null
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Rules')
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

    hidden static [System.Collections.Hashtable[]] GetRulesAsHashtable([System.Object[]] $PolicyRules)
    {
        $newPolicyRules = @()
        foreach ($rule in $PolicyRules)
        {
            # GSA auto-creates these two system rules on every policy; they are not user-managed.
            if ($rule.Description -like 'Auto-created*' -and ($rule.Priority -eq 50 -or $rule.Priority -eq 65000))
            {
                continue
            }

            $destinationsValue = @()
            foreach ($destination in $rule.MatchingConditions.Destinations)
            {
                $destinationsValue += @{
                    Type   = $destination.'@odata.type'.Replace('#microsoft.graph.networkaccess.', '')
                    Values = [System.String[]] $destination.Values
                }
            }
            $newPolicyRules += [ordered]@{
                Id           = $rule.Id
                Name         = $rule.Name
                Priority     = [System.UInt32] $rule.Priority
                Description  = $rule.Description
                Action       = $rule.Action
                Status       = $rule.Settings.Status
                Destinations = $destinationsValue
            }
        }

        return $newPolicyRules
    }
}

class MSFT_AADGSATLSInspectionPolicyRuleDestination
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the destination, for example tlsInspectionFqdnDestination or tlsInspectionWebCategoryDestination.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('The destination values, such as FQDNs or web category names.')]
    [System.String[]] $Values
}

class MSFT_AADGSATLSInspectionPolicyRule
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the rule.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the rule.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The priority of the rule. Rules are evaluated in ascending order of priority.')]
    [System.UInt32] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Optional description of the rule.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The action to take when traffic matches this rule.')]
    [ValidateSet('bypass', 'inspect', 'unknownFutureValue')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('The status of the rule.')]
    [ValidateSet('enabled', 'disabled', 'unknownFutureValue')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('The destinations that determine when this rule applies to traffic.')]
    [MSFT_AADGSATLSInspectionPolicyRuleDestination[]] $Destinations
}
