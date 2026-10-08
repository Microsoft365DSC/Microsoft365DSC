using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPDLPPolicyConnectorConfigurations : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The policy name identifier.')]
    [System.String] $PolicyName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The tenant identifier.')]
    [System.String] $PPTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Set of cnnector actions associated with the policy.')]
    [MSFT_PPDLPPolicyConnectorConfigurationsAction[]] $ConnectorActionConfigurations

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

    [PPDLPPolicyConnectorConfigurations] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPDLPPolicyConnectorConfigurations]::new()
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
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.Name)/policyconnectorconfigurations"

            $ActionList = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'
            $ActionsValue = @()
            foreach ($action in $ActionList.connectorActionConfigurations)
            {
                $entry = @{
                    connectorId                        = $action.connectorId
                    defaultConnectorActionRuleBehavior = $action.defaultConnectorActionRuleBehavior
                }

                $actionRulesValues = @()
                foreach ($rule in $action.actionRules)
                {
                    $actionRulesValues += @{
                        actionId = $rule.actionId
                        behavior = $rule.behavior
                    }
                }
                $entry.Add('actionRules', $actionRulesValues)
                $ActionsValue += $entry
            }

            $results = @{
                PPTenantId                    = $this.PPTenantId
                PolicyName                    = $this.PolicyName
                ConnectorActionConfigurations = $ActionsValue
                Ensure                        = 'Present'
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
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
        $PolicyNameValue = $null
        $actionRules = $null
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
                connectorActionConfigurations = @()
            }

            foreach ($action in $this.connectorActionConfigurations)
            {
                $entry = @{
                    connectorId                        = $action.connectorId
                    defaultConnectorActionRuleBehavior = $action.defaultConnectorActionRuleBehavior
                }

                $ruleValues = @()
                foreach ($rule in $actionRules)
                {
                    $ruleValues += @{
                        actionId = $rule.actionId
                        behavior = $rule.behavior
                    }
                }
                $entry.Add('actionRules', $ruleValues)
                $body.connectorActionConfigurations += $entry
            }
            $payload = $(ConvertTo-Json $body -Depth 9 -Compress)
            Write-Verbose -Message "Setting Connector Configuration for Policy {$($PolicyNameValue)} with parameters:`r`n$payload"

            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.Name)/policyconnectorconfigurations"

            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST' -Body $body
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing Connector Configuration for Policy {$($PolicyNameValue)}"
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($this.PPTenantId)/policies/$($policy.Name)/policyconnectorconfigurations"

            Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'DELETE'
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

            [array]$policies = (Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET').value
            $ConnectionMode = $this.Connect('MicrosoftGraph')
            $tenantinfo = (Get-MgContext)

            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Count -eq 0)
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
                    PPTenantId            = $tenantInfo.TenantId
                    PolicyName            = $policy.properties.displayName
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

                if ($null -ne $Results.ConnectorActionConfigurations)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'actionRules'
                            CimInstanceName = 'PPDLPPolicyConnectorConfigurationsActionRules'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ConnectorActionConfigurations `
                        -CIMInstanceName 'PPDLPPolicyConnectorConfigurationsAction' `
                        -ComplexTypeMapping $complexMapping
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ConnectorActionConfigurations = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ConnectorActionConfigurations') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ConnectorActionConfigurations') `
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

    hidden [PPDLPPolicyConnectorConfigurations] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPDLPPolicyConnectorConfigurations])
        {
            return $Values
        }

        $result = [PPDLPPolicyConnectorConfigurations]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_PPDLPPolicyConnectorConfigurationsAction
{
    [DscProperty()]
    [System.ComponentModel.Description('Unique id of the connector.')]
    [System.String] $connectorId

    [DscProperty()]
    [System.ComponentModel.Description('Default action behavior for to connector.')]
    [System.String] $defaultConnectorActionRuleBehavior

    [DscProperty()]
    [System.ComponentModel.Description('List of associated actions.')]
    [MSFT_PPDLPPolicyConnectorConfigurationsActionRules[]] $actionRules
}

class MSFT_PPDLPPolicyConnectorConfigurationsActionRules
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the action.')]
    [System.String] $actionId

    [DscProperty()]
    [System.ComponentModel.Description('Associated behavior.')]
    [System.String] $behavior
}
