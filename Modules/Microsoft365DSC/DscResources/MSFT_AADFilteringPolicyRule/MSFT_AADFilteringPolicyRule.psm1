using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADFilteringPolicyRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the rule.')]
    [System.String] $Name

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the associated policy.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('Unique Id for the rule.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Type of rule.')]
    [System.String] $RuleType

    [DscProperty()]
    [System.ComponentModel.Description('List of associated destinations with the rule.')]
    [MSFT_AADFilteringPolicyRuleDestination[]] $Destinations

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

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

    [AADFilteringPolicyRule] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADFilteringPolicyRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Filtering Policy Rule with Id {$($this.Id)} and Name {$($this.Name)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $policyInstance = Get-MgBetaNetworkAccessFilteringPolicy | Where-Object -Filter { $_.Name -eq $this.Policy }
            if ($null -ne $policyInstance)
            {
                Write-Verbose -Message "Found existing Policy {$($this.Policy)}"

                $instance = $null
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Retrieving Filtering Policy Rule by Id {$($this.Id)}"
                    $instance = Get-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policyInstance.Id `
                        -PolicyRuleId $this.Id -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Retrieving Filtering Policy Rule by Name {$($this.Name)}"
                    $instance = Get-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policyInstance.Id | Where-Object -FilterScript { $_.Name -eq $this.Name }
                }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $DestinationsValue = @()
            foreach ($destination in $instance.destinations)
            {
                if ($instance.ruleType -eq 'fqdn')
                {
                    $DestinationsValue += @{
                        value = $destination.value
                    }
                }
                elseif ($instance.ruleType -eq 'webCategory')
                {
                    $DestinationsValue += @{
                        name = $destination.name
                    }
                }
            }

            $results = @{
                Name                  = $instance.Name
                Policy                = $this.Policy
                Id                    = $instance.Id
                RuleType              = $instance.ruleType
                Destinations          = $DestinationsValue
                Ensure                = 'Present'
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
        $instanceParams = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for the Azure AD Filtering Policy Rule with Id {$($this.Id)} and Name {$($this.Name)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $policyInstance = Get-MgBetaNetworkAccessFilteringPolicy | Where-Object -Filter { $_.Name -eq $this.Policy }

        if ($this.RuleType -eq 'webCategory')
        {
            $instanceParams = @{
                '@odata.type' = '#microsoft.graph.networkaccess.webCategoryFilteringRule'
                name          = $this.Name
                ruleType      = $this.RuleType
                destinations  = @()
            }

            foreach ($destination in $this.Destinations)
            {
                $instanceParams.destinations += @{
                    '@odata.type' = '#microsoft.graph.networkaccess.webCategory'
                    name          = $destination.name
                }
            }
        }
        elseif ($this.RuleType -eq 'fqdn')
        {
            $instanceParams = @{
                '@odata.type' = '#microsoft.graph.networkaccess.fqdnFilteringRule'
                name          = $this.Name
                ruleType      = $this.RuleType
                destinations  = @()
            }

            foreach ($destination in $this.Destinations)
            {
                $instanceParams.destinations += @{
                    '@odata.type' = '#microsoft.graph.networkaccess.fqdn'
                    value         = $destination.value
                }
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Filtering Policy Rule {$($this.Name)} with:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            New-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policyInstance.Id `
                -BodyParameter $instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $instanceParams.Remove('ruleType') | Out-Null
            Write-Verbose -Message "Updating Filtering Policy Rule {$($this.Name)} with:`r`n$(ConvertTo-Json $instanceParams -Depth 10)"
            Update-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policyInstance.Id `
                -PolicyRuleId $currentInstance.Id `
                -BodyParameter $instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Filtering Policy Rule {$($this.Name)}"
            Remove-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policyInstance.Id `
                -PolicyRuleId $currentInstance.Id
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
            [array]$policies = Get-MgBetaNetworkAccessFilteringPolicy -All -Filter $this.Filter -ExpandProperty 'policyRules' -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                $displayedKey = $policy.Name
                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $displayedKey" -DeferWrite
                [array]$rules = $this.ResolveExpandedNavigation($policy, 'PolicyRules')
                if ($null -eq $rules)
                {
                    [array]$rules = Get-MgBetaNetworkAccessFilteringPolicyRule -FilteringPolicyId $policy.Id `
                        -ErrorAction SilentlyContinue
                }
                if ($rules.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }
                $j = 1
                foreach ($rule in $rules)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $displayedKey = $rule.Name
                    Write-M365DSCHost -Message "        |---[$j/$($rules.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        Name                  = $rule.Name
                        Policy                = $policy.Name
                        Id                    = $rule.Id
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

                    $Results = $this.GetForExport($Params)
                    $rawResults = $Results.Clone()

                    if ($Results.Destinations)
                    {
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Destinations -CIMInstanceName 'AADFilteringPolicyRuleDestination'
                        if ($complexTypeStringResult)
                        {
                            $Results.Destinations = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('Destinations') | Out-Null
                        }
                    }
                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('Destinations') `
                        -RawResults $rawResults

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $j++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADFilteringPolicyRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADFilteringPolicyRule])
        {
            return $Values
        }

        $result = [AADFilteringPolicyRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADFilteringPolicyRuleDestination
{
    [DscProperty()]
    [System.ComponentModel.Description('Name of the destination.')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('FQDN value for the destination.')]
    [System.String] $value
}
