using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADGSAWebContentFilteringPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the Web Content Filtering Policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Optional description of the policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The default action to take when no rules match.')]
    [ValidateSet('allow', 'block', 'unknownFutureValue')]
    [System.String] $DefaultAction

    [DscProperty()]
    [System.ComponentModel.Description('The rules that define the specific matching conditions and desired actions for web content filtering.')]
    [MSFT_AADGSAWebContentFilteringPolicyRule[]] $Rules

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

    [AADGSAWebContentFilteringPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADGSAWebContentFilteringPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AAD GSA Web Content Filtering Policy {$($this.Name)}"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            Confirm-M365DSCDependencies

            $this.AddTelemetry('Get')

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $instance = $null
            if (-not $this.ExportedInstance -or $this.ExportedInstance.name -ne $this.Name)
            {
                $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Retrieving Web Content Filtering Policy by Id {$($this.Id)}"
                    try
                    {
                        $instance = Invoke-MgGraphRequest -Method GET `
                            -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$($this.Id)?`$expand=policyRules") `
                            -ErrorAction Stop
                    }
                    catch
                    {
                        # Invoke-MgGraphRequest throws a terminating error on 404 even with -ErrorAction SilentlyContinue, so fall back to the Name lookup below.
                        $instance = $null
                    }
                }
                if ($null -eq $instance)
                {
                    Write-Verbose -Message "Retrieving Web Content Filtering Policy by Name {$($this.Name)}"
                    $allInstances = $this.GetAllGraphPages(($baseUrl + 'beta/networkAccess/webFilteringPolicies?$expand=policyRules'))
                    $instance = $allInstances | Where-Object -FilterScript { $_.name -eq $this.Name } | Select-Object -First 1
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                Write-Verbose -Message "Could not find AAD GSA Web Content Filtering Policy {$($this.Name)}"
                return $this.AsResult($nullResult)
            }

            $rulesValue = @()
            if ($null -ne $instance.policyRules)
            {
                $rulesValue = [AADGSAWebContentFilteringPolicy]::GetRulesAsHashtable($instance.policyRules)
            }

            $results = @{
                Name          = $instance.name
                Id            = $instance.id
                Description   = $instance.description
                DefaultAction = [AADGSAWebContentFilteringPolicy]::GetActionValue($instance.settings.defaultAction)
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

        $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            name        = $this.Name
            description = $this.Description
            settings    = @{
                defaultAction = [AADGSAWebContentFilteringPolicy]::GetActionBody($this.DefaultAction)
            }
        }

        $policyId = $currentInstance.Id

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new AAD GSA Web Content Filtering Policy {$($this.Name)}"
            $newInstance = Invoke-MgGraphRequest -Method POST `
                -Uri ($baseUrl + 'beta/networkAccess/webFilteringPolicies') `
                -Body $instanceParams
            $policyId = $newInstance.id
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating AAD GSA Web Content Filtering Policy {$($this.Name)} with Id {$($currentInstance.Id)}"
            Invoke-MgGraphRequest -Method PATCH `
                -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$($currentInstance.Id)") `
                -Body $instanceParams | Out-Null
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing AAD GSA Web Content Filtering Policy {$($this.Name)} with Id {$($currentInstance.Id)}"
            Invoke-MgGraphRequest -Method DELETE `
                -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$($currentInstance.Id)") | Out-Null
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
                    '@odata.type'      = '#microsoft.graph.networkaccess.webFilteringRule'
                    name               = $desiredRule.Name
                    priority           = $desiredRule.Priority
                    description        = $desiredRule.Description
                    action             = [AADGSAWebContentFilteringPolicy]::GetActionBody($desiredRule.Action)
                    settings           = @{
                        status = $desiredRule.Status
                    }
                    matchingConditions = @{
                        destinations = @{
                            targets           = $destinationsBody
                            httpRequestMethod = $desiredRule.HttpRequestMethod
                        }
                        sources      = @{
                            sessionType = $desiredRule.SessionType
                        }
                    }
                }

                $matchedRule = $currentRules | Where-Object -FilterScript { $_.Id -notin $matchedCurrentRuleIds -and $_.Name -eq $desiredRule.Name } | Select-Object -First 1

                if ($null -ne $matchedRule)
                {
                    $matchedCurrentRuleIds += $matchedRule.Id
                    Write-Verbose -Message "Updating Web Content Filtering Rule {$($desiredRule.Name)} with Id {$($matchedRule.Id)}"
                    Invoke-MgGraphRequest -Method PATCH `
                        -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$policyId/policyRules/$($matchedRule.Id)") `
                        -Body $ruleBody | Out-Null
                }
                else
                {
                    Write-Verbose -Message "Creating new Web Content Filtering Rule {$($desiredRule.Name)}"
                    Invoke-MgGraphRequest -Method POST `
                        -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$policyId/policyRules") `
                        -Body $ruleBody | Out-Null
                }
            }

            foreach ($currentRule in $currentRules)
            {
                if ($currentRule.Id -notin $matchedCurrentRuleIds)
                {
                    Write-Verbose -Message "Removing Web Content Filtering Rule {$($currentRule.Name)} with Id {$($currentRule.Id)}"
                    Invoke-MgGraphRequest -Method DELETE `
                        -Uri ($baseUrl + "beta/networkAccess/webFilteringPolicies/$policyId/policyRules/$($currentRule.Id)") | Out-Null
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
            $baseUrl = (Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl
            [array] $exportedInstances = $this.GetAllGraphPages(($baseUrl + 'beta/networkAccess/webFilteringPolicies?$expand=policyRules'))

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

                $displayedKey = $config.name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $Params = @{
                    Name = $config.name
                    Id   = $config.id
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.Rules -and $Results.Rules.Count -gt 0)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Rules'
                            CimInstanceName = 'AADGSAWebContentFilteringPolicyRule'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Destinations'
                            CimInstanceName = 'AADGSAWebContentFilteringPolicyRuleDestination'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Rules `
                        -CIMInstanceName 'AADGSAWebContentFilteringPolicyRule' `
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

    hidden [System.Object[]] GetAllGraphPages([System.String] $Uri)
    {
        $pageResults = @()
        $nextUri = $Uri
        while (-not [System.String]::IsNullOrEmpty($nextUri))
        {
            $response = Invoke-MgGraphRequest -Method GET -Uri $nextUri -ErrorAction Stop
            if ($null -ne $response -and $null -ne $response.value)
            {
                $pageResults += $response.value
            }
            $nextUri = $response.'@odata.nextLink'
        }
        return $pageResults
    }

    hidden static [System.Collections.Hashtable[]] GetRulesAsHashtable([System.Object[]] $PolicyRules)
    {
        $newPolicyRules = @()
        foreach ($rule in $PolicyRules)
        {
            $destinationsValue = @()
            foreach ($destination in $rule.MatchingConditions.Destinations.Targets)
            {
                $destinationsValue += @{
                    Type   = $destination.'@odata.type'.Replace('#microsoft.graph.networkaccess.', '')
                    Values = [System.String[]] $destination.Values
                }
            }
            $newPolicyRules += [ordered]@{
                Id                = $rule.Id
                Name              = $rule.Name
                Priority          = [System.UInt32] $rule.Priority
                Description       = $rule.Description
                Action            = [AADGSAWebContentFilteringPolicy]::GetActionValue($rule.Action)
                Status            = $rule.Settings.Status
                HttpRequestMethod = $rule.MatchingConditions.Destinations.HttpRequestMethod
                SessionType       = $rule.MatchingConditions.Sources.SessionType
                Destinations      = $destinationsValue
            }
        }

        return $newPolicyRules
    }

    hidden static [System.String] GetActionValue([System.Object] $Action)
    {
        if ($null -eq $Action -or [System.String]::IsNullOrEmpty($Action.'@odata.type'))
        {
            return $null
        }

        $actionTypeName = $Action.'@odata.type'.Replace('#microsoft.graph.networkaccess.webFilteringAction', '')
        return $actionTypeName.Substring(0, 1).ToLower() + $actionTypeName.Substring(1)
    }

    hidden static [System.Collections.Hashtable] GetActionBody([System.String] $Action)
    {
        $actionTypeName = $Action.Substring(0, 1).ToUpper() + $Action.Substring(1)
        return @{
            '@odata.type' = "#microsoft.graph.networkaccess.webFilteringAction$actionTypeName"
        }
    }
}

class MSFT_AADGSAWebContentFilteringPolicyRuleDestination
{
    [DscProperty()]
    [System.ComponentModel.Description('The type of the destination, for example webFilteringUrlDestination or webFilteringWebCategoryDestination.')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('The destination values, such as URLs or web category names.')]
    [System.String[]] $Values
}

class MSFT_AADGSAWebContentFilteringPolicyRule
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
    [ValidateSet('allow', 'block', 'unknownFutureValue')]
    [System.String] $Action

    [DscProperty()]
    [System.ComponentModel.Description('The status of the rule.')]
    [ValidateSet('enabled', 'disabled', 'unknownFutureValue')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('The HTTP request method to match, for example get.')]
    [System.String] $HttpRequestMethod

    [DscProperty()]
    [System.ComponentModel.Description('The type of session that must match for this rule, for example user.')]
    [System.String] $SessionType

    [DscProperty()]
    [System.ComponentModel.Description('The destinations that determine when this rule applies to traffic.')]
    [MSFT_AADGSAWebContentFilteringPolicyRuleDestination[]] $Destinations
}
