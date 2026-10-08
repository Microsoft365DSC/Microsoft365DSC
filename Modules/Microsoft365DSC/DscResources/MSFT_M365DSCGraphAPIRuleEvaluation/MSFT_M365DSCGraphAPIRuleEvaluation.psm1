using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class M365DSCGraphAPIRuleEvaluation : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Url of the REST Endpoint.')]
    [System.String] $APIUrl

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specify the rules to evaluate.')]
    [System.String] $RuleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Name of the parent property of the response, which contains the instances. Default is ''value''.')]
    [System.String] $InstancesProperty

    [DscProperty()]
    [System.ComponentModel.Description('For logging purposes only. This represents the unique identifier of instances returned by the Graph API call.')]
    [System.String] $InstanceIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Custom display name for the rule. This will show up in the logs on drift detection.')]
    [System.String] $RuleName

    [DscProperty()]
    [System.ComponentModel.Description('Query to check how many instances exist, using PowerShell format')]
    [System.String] $AfterRuleCountQuery

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

    M365DSCGraphAPIRuleEvaluation() : base()
    {
        $this._SetProperty('InstancesProperty', 'value')
    }

    [M365DSCGraphAPIRuleEvaluation] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [M365DSCGraphAPIRuleEvaluation]::new()
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
        $validInstances = $null
        $invalidInstances = $null
        if ($this.RequiresPowerShellCore())
        {
            return [bool] $this.InvokeInPowerShellCore('Test')
        }

        #region Telemetry
        $CurrentResourceName = $this.GetResourceName() -replace 'MSFT_', ''
        $this.AddTelemetry('Test')
        #endregion

        $ResourceTypeName = $CurrentResourceName
        $null = $this.Connect('MicrosoftGraph')

        Write-Verbose -Message "Invoking GET {$($this.APIUrl)}"
        $uri = $this.APIUrl
        $DSCConvertedInstances = @()
        do
        {
            # Make the API request
            $response = Invoke-M365DSCGraphRequest -Uri $uri -Method GET

            # Add the current page of results to the array
            $DSCConvertedInstances += $response.($this.InstancesProperty)

            # Check if there's a next page
            $uri = $response.'@odata.nextLink'
        } while ($uri)

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
        [void]$message.AppendLine('<M365DSCGraphAPIRuleEvaluation>')
        [void]$message.AppendLine("  <RuleName>$($this.RuleName)</RuleName>")
        [void]$message.AppendLine("  <ResourceName>$ResourceTypeName</ResourceName>")
        [void]$message.AppendLine("  <RuleDefinition>$($this.RuleDefinition)</RuleDefinition>")

        if (-not [System.String]::IsNullOrEmpty($this.AfterRuleCountQuery))
        {
            [void]$message.AppendLine('  <AfterRuleCount>')
            [void]$message.AppendLine("    <Query>$($this.AfterRuleCountQuery)</Query>")

            Write-Verbose -Message 'Checking the After Rule Count Query'
            $afterRuleCountQueryString = "`$instances.Length $($this.AfterRuleCountQuery)"
            $afterRuleCountQueryBlock = [Scriptblock]::Create($afterRuleCountQueryString)
            $result = [Boolean](Invoke-Command -ScriptBlock $afterRuleCountQueryBlock)

            if ($this.InstanceIdentifier)
            {
                [array]$validInstances = $instances.($this.InstanceIdentifier)
                [array]$invalidInstances = $DSCConvertedInstances.($this.InstanceIdentifier) | Where-Object -FilterScript { $_ -notin $validInstances }
            }

            if (-not $result)
            {
                [void]$message.AppendLine('    <MetQuery>False</MetQuery>')
                [void]$message.AppendLine('  </AfterRuleCount>')

                if ($validInstances.Count -gt 0)
                {
                    [void]$message.AppendLine('  <Match>')
                    foreach ($validInstance in $validInstances)
                    {
                        [void]$message.AppendLine("    <$($this.InstanceIdentifier)>$validInstance</$($this.InstanceIdentifier)>")
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
                    [void]$message.AppendLine("    <InstanceIdentifier>[$ResourceTypeName]$validInstance</InstanceIdentifier>")
                }
                [void]$message.AppendLine('  </Match>')
            }
        }
        else
        {
            [void]$message.AppendLine('  <AfterRuleCount></AfterRuleCount>')

            $compareInstances = @()
            if ($this.InstanceIdentifier -and $DSCConvertedInstances.Length -gt 0)
            {
                $compareInstances += Compare-Object -ReferenceObject $DSCConvertedInstances.($this.InstanceIdentifier) -DifferenceObject $instances.($this.InstanceIdentifier) -IncludeEqual
            }

            if ($compareInstances.Count -gt 0)
            {
                [array]$validInstances = $($compareInstances | Where-Object -FilterScript { $_.SideIndicator -eq '==' }).InputObject
                [array]$invalidInstances = $($compareInstances | Where-Object -FilterScript { $_.SideIndicator -eq '<=' }).InputObject
            }
            else
            {
                [array]$validInstances = @()
                [array]$invalidInstances = [array]$DSCConvertedInstances.($this.InstanceIdentifier)
            }

            if ($validInstances.Count -gt 0)
            {
                [void]$message.AppendLine('  <Match>')
                foreach ($validInstance in $validInstances)
                {
                    [void]$message.AppendLine("    <$($this.InstanceIdentifier)>$validInstance</$($this.InstanceIdentifier)>")
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
                [void]$message.AppendLine("    <$($this.InstanceIdentifier)>$invalidInstance</$($this.InstanceIdentifier)>")
            }
            [void]$message.AppendLine('  </NotMatch>')
        }
        else
        {
            [void]$message.AppendLine('  <NotMatch></NotMatch>')
        }
        [void]$message.AppendLine('</M365DSCGraphAPIRuleEvaluation>')

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

    [string] Export()
    {
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        Write-M365DSCHost -Message "`r`n" -DeferWrite
        return $null
    }

    hidden [M365DSCGraphAPIRuleEvaluation] AsResult([System.Object] $Values)
    {
        if ($Values -is [M365DSCGraphAPIRuleEvaluation])
        {
            return $Values
        }

        $result = [M365DSCGraphAPIRuleEvaluation]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
