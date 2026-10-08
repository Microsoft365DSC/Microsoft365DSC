using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPPowerAppPolicyUrlPatterns : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The policy name identifier.')]
    [System.String] $PolicyName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The tenant identifier.')]
    [System.String] $PPTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Set of custom connector pattern rules associated with the policy.')]
    [MSFT_PPPowerAppPolicyUrlPatternsRule[]] $RuleSet

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

    [PPPowerAppPolicyUrlPatterns] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPPowerAppPolicyUrlPatterns]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Power Platform DLP Policy Connector Configurations with PPTenantId {$($this.PPTenantId)} and PolicyName {$($this.PolicyName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.properties.displayName -ne $this.PolicyName)
            {
                $null = $this.Connect('PowerPlatformREST')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                    '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

                $policies = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'

                $policy = $null
                foreach ($policyInfo in $policies.value)
                {
                    if ($policyInfo.properties.displayName -eq $this.PolicyName)
                    {
                        $policy = $policyInfo
                    }
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                return $this.AsResult($nullResult)
            }

            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.name)/urlPatterns"

            $rules = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET' -ErrorAction SilentlyContinue
            $RulesValue = @()
            foreach ($rule in $rules.rules)
            {
                $RulesValue += @{
                    order                             = $rule.order
                    customConnectorRuleClassification = $rule.customConnectorRuleClassification
                    pattern                           = $rule.pattern
                }
            }

            $results = @{
                PPTenantId            = $this.PPTenantId
                PolicyName            = $this.PolicyName
                RuleSet               = $RulesValue
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
        $body = $null
        $PolicyNameValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Power Platform DLP Policy Connector Configurations with PPTenantId {$($this.PPTenantId)} and PolicyName {$($this.PolicyName)}"

        $null = $this.Connect('PowerPlatformREST')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
            '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

        $policies = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'

        $policy = $null
        foreach ($policyInfo in $policies.value)
        {
            if ($policyInfo.properties.displayName -eq $this.PolicyName)
            {
                $policy = $policyInfo
            }
        }
        # CREATE
        if ($this.Ensure -eq 'Present')
        {
            $body = @{
                rules = @()
            }

            foreach ($rule in $this.RuleSet)
            {
                $body.rules += @{
                    order                             = $rule.order
                    customConnectorRuleClassification = $rule.customConnectorRuleClassification
                    pattern                           = $rule.pattern
                }
            }
            $payload = $(ConvertTo-Json $body -Depth 9 -Compress)
            Write-Verbose -Message "Setting new Url Patterns for Policy {$($this.PolicyName)} with parameters:`r`n$payload"

            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.name)/urlPatterns"

            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST' -Body $body

        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing Url Patterns for Policy {$($PolicyNameValue)}"
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.name)/urlPatterns"

            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'DELETE' -Body $body
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $k = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('PowerPlatformREST')

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $tenantinfo = (Get-MgContext).TenantId
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

            [array]$policies = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'
            $policies = $policies.value | Where-Object -FilterScript { $_.type -eq 'Microsoft.BusinessAppPlatform/scopes/apiPolicies' }
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.properties.DisplayName)" -DeferWrite
                $params = @{
                    PPTenantId            = $tenantInfo
                    PolicyName            = $policy.properties.DisplayName
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($null -ne $Results.RuleSet)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RuleSet `
                        -CIMInstanceName 'PPPowerAppPolicyUrlPatternsRule'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.RuleSet = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RuleSet') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('RuleSet') `
                    -RawResults $rawResults
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $k++
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

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

    hidden [PPPowerAppPolicyUrlPatterns] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPPowerAppPolicyUrlPatterns])
        {
            return $Values
        }

        $result = [PPPowerAppPolicyUrlPatterns]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_PPPowerAppPolicyUrlPatternsRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Rule priority order.')]
    [System.Nullable[System.UInt32]] $order

    [DscProperty()]
    [System.ComponentModel.Description('Rule classification.')]
    [System.String] $customConnectorRuleClassification

    [DscProperty()]
    [System.ComponentModel.Description('Rule pattern.')]
    [System.String] $pattern
}
