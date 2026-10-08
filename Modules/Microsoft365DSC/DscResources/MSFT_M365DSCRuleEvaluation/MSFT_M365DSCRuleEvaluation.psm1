using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class M365DSCRuleEvaluation : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the resource to monitor')]
    [System.String] $ResourceTypeName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specify the rules to monitor the resource for.')]
    [System.String] $RuleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Custom display name for the rule. This will show up in the logs on drift detection.')]
    [System.String] $RuleName

    [DscProperty()]
    [System.ComponentModel.Description('Query to check how many instances exist, using PowerShell format')]
    [System.String] $AfterRuleCountQuery

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a filter for the current resource type to be evaluated. This reduces the overall set of instances the rule will be evaluated against.')]
    [System.String] $Filter

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

    [M365DSCRuleEvaluation] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [M365DSCRuleEvaluation]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        return $this.AsResult($null)
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        # Not Implemented
    }

    [bool] Test()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [bool] $this.InvokeInPowerShellCore('Test')
        }

        #region Telemetry
        $CurrentResourceName = $this.GetResourceName() -replace 'MSFT_', ''
        $this.AddTelemetry('Test')
        #endregion

        $Global:PartialExportFileName = "$((New-Guid).ToString()).partial"
        $targetType = [M365DSCResourceBase]::Resolve($this.ResourceTypeName)
        if ($null -ne $targetType)
        {
            $boundParameters = $this.GetBoundParameters()
            $params = @{
                Credential            = $boundParameters.Credential
                ApplicationId         = $boundParameters.ApplicationId
                TenantId              = $boundParameters.TenantId
                CertificateThumbprint = $boundParameters.CertificateThumbprint
            }

            if ($null -ne $boundParameters.ApplicationSecret)
            {
                $params.Add('ApplicationSecret', $boundParameters.ApplicationSecret)
            }
            if ($null -ne $boundParameters.AccessTokens)
            {
                $params.Add('AccessTokens', $boundParameters.AccessTokens)
            }
            if ($null -ne $boundParameters.ManagedIdentity)
            {
                $params.Add('ManagedIdentity', $boundParameters.ManagedIdentity)
            }
            if ($null -ne $boundParameters.Filter)
            {
                $params.Add('Filter', $this.Filter)
            }
            Initialize-M365DSCResourcesDictionary

            Write-Verbose -Message "Exporting instances of {$($this.ResourceTypeName)}"
            [Array]$instances = Invoke-M365DSCResourceMethod -ResourceName $this.ResourceTypeName `
                -MethodName 'Export' `
                -Parameters $params

            $DSCStringContent = @"
        # Generated with Microsoft365DSC version 1.23.906.1
        # For additional information on how to use Microsoft365DSC, please visit https://aka.ms/M365DSC
        param
        (
        )

        Configuration M365TenantConfig
        {
            param
            (
            )

            `$OrganizationName = `$ConfigurationData.NonNodeData.OrganizationName

            Import-DscResource -ModuleName 'Microsoft365DSC'

            Node localhost
            {
                $instances
            }
        }

        M365TenantConfig -ConfigurationData .\ConfigurationData.psd1
"@
            Write-Verbose -Message 'Converting the retrieved instances into DSC Objects'
            $DSCConvertedInstances = ConvertTo-DSCObject -Content $DSCStringContent
            Write-Verbose -Message "Successfully converted {$($DSCConvertedInstances.Length)} DSC Objects."

            Write-Verbose -Message 'Querying DSC Objects for invalid instances based on the specified Rule Definition.'
            if ($this.RuleDefinition -eq '*')
            {
                [Array]$instances = $DSCConvertedInstances
                Write-Verbose -Message "Identified {$($instances.Length)} instances matching rule."
            }
            else
            {
                $queryBlock = [Scriptblock]::Create($this.RuleDefinition)
                [Array]$instances = $DSCConvertedInstances | Where-Object -FilterScript $queryBlock
                Write-Verbose -Message "Identified {$($instances.Length)} instances matching rule."
            }

            $result = ($instances.Length - $DSCConvertedInstances.Length) -eq 0

            $message = [System.Text.StringBuilder]::new()
            [void]$message.AppendLine('<M365DSCRuleEvaluation>')
            [void]$message.AppendLine("  <RuleName>$($this.RuleName)</RuleName>")
            [void]$message.AppendLine("  <ResourceName>$($this.ResourceTypeName)</ResourceName>")
            [void]$message.AppendLine("  <RuleDefinition>$($this.RuleDefinition)</RuleDefinition>")

            if (-not [System.String]::IsNullOrEmpty($this.AfterRuleCountQuery))
            {
                [void]$message.AppendLine('  <AfterRuleCount>')
                [void]$message.AppendLine("    <Query>$($this.AfterRuleCountQuery)</Query>")

                Write-Verbose -Message 'Checking the After Rule Count Query'
                $afterRuleCountQueryString = "`$instances.Length $($this.AfterRuleCountQuery)"
                $afterRuleCountQueryBlock = [Scriptblock]::Create($afterRuleCountQueryString)
                $result = [Boolean](Invoke-Command -ScriptBlock $afterRuleCountQueryBlock)
                [array]$validInstances = $instances.ResourceInstanceName
                [array]$invalidInstances = $DSCConvertedInstances.ResourceInstanceName | Where-Object -FilterScript { $_ -notin $validInstances }

                if (-not $result)
                {
                    [void]$message.AppendLine('    <MetQuery>False</MetQuery>')
                    [void]$message.AppendLine('  </AfterRuleCount>')
                    if ($validInstances.Count -gt 0)
                    {
                        [void]$message.AppendLine('  <Match>')
                        foreach ($validInstance in $validInstances)
                        {
                            [void]$message.AppendLine("    <ResourceInstanceName>[$($this.ResourceTypeName)]$validInstance</ResourceInstanceName>")
                        }
                        [void]$message.AppendLine('  </Match>')
                    }
                    else
                    {
                        [void]$message.AppendLine('  <Match></Match>')
                    }
                }
                else
                {
                    [void]$message.AppendLine('    <MetQuery>True</MetQuery>')
                    [void]$message.AppendLine('  </AfterRuleCount>')
                    [void]$message.AppendLine('  <Match>')
                    foreach ($validInstance in $validInstances)
                    {
                        [void]$message.AppendLine("    <ResourceInstanceName>[$($this.ResourceTypeName)]$validInstance</ResourceInstanceName>")
                    }
                    [void]$message.AppendLine('  </Match>')
                }
            }
            else
            {
                [void]$message.AppendLine('  <AfterRuleCount></AfterRuleCount>')

                $compareInstances = @()
                if ($DSCConvertedInstances.Length -gt 0)
                {
                    $compareInstances += Compare-Object -ReferenceObject $DSCConvertedInstances.ResourceInstanceName -DifferenceObject $instances.ResourceInstanceName -IncludeEqual
                }

                if ($compareInstances.Count -gt 0)
                {
                    [array]$validInstances = $($compareInstances | Where-Object -FilterScript { $_.SideIndicator -eq '==' }).InputObject
                    [array]$invalidInstances = $($compareInstances | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
                }
                else
                {
                    [array]$validInstances = @()
                    [array]$invalidInstances = [array]$DSCConvertedInstances.ResourceInstanceName
                }

                if ($validInstances.Count -gt 0)
                {
                    [void]$message.AppendLine('  <Match>')
                    foreach ($validInstance in $validInstances)
                    {
                        [void]$message.AppendLine("    <ResourceInstanceName>[$($this.ResourceTypeName)]$validInstance</ResourceInstanceName>")
                    }
                    [void]$message.AppendLine('  </Match>')
                }
                else
                {
                    [void]$message.AppendLine('  <Match></Match>')
                }
            }

            # Log drifts for each invalid instances found.
            if ($invalidInstances.Count -gt 0)
            {
                [void]$message.AppendLine('  <NotMatch>')
                foreach ($invalidInstance in $invalidInstances)
                {
                    [void]$message.AppendLine("    <ResourceInstanceName>[$($this.ResourceTypeName)]$invalidInstance</ResourceInstanceName>")
                }
                [void]$message.AppendLine('  </NotMatch>')
            }
            else
            {
                [void]$message.AppendLine('  <NotMatch></NotMatch>')
            }
            [void]$message.AppendLine('</M365DSCRuleEvaluation>')

            $Parameters = @{
                Message   = $message.ToString()
                EventType = 'RuleEvaluation'
                EventID   = 1
                Source    = $CurrentResourceName
            }
            if (-not $result)
            {
                $Parameters.Add('EntryType', 'Warning')
            }
            else
            {
                $Parameters.Add('EntryType', 'Information')
            }
            Add-M365DSCEvent @Parameters

            Write-Verbose -Message "Test() returned $result"

            $this.ExportedInstance = $null
            return $result
        }
        $this.ExportedInstance = $null

        # Every code path must return in a method with a declared return type.
        return $false
    }

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        Write-M365DSCHost -Message "`r`n" -DeferWrite
        return $null
    }

    hidden [M365DSCRuleEvaluation] AsResult([System.Object] $Values)
    {
        if ($Values -is [M365DSCRuleEvaluation])
        {
            return $Values
        }

        $result = [M365DSCRuleEvaluation]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
