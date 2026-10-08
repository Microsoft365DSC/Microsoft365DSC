using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPAdminDLPPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Creates the policy with the input display name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the policy.')]
    [System.String] $PolicyName

    [DscProperty()]
    [System.ComponentModel.Description('Comma separated string list used as input environments to either include or exclude, depending on the FilterType.')]
    [System.String[]] $Environments

    [DscProperty()]
    [System.ComponentModel.Description('Identifies which filter type the policy will have, none, include, or exclude.')]
    [System.String] $FilterType

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

    [PPAdminDLPPolicy] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPAdminDLPPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Power Platform Admin DLP Policy with DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.properties.displayName -ne $this.DisplayName)
            {
                $null = $this.Connect('PowerPlatformREST')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                    '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

                $policies = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'

                $instance = $null
                foreach ($policyInfo in $policies.value)
                {
                    if ($policyInfo.properties.displayName -eq $this.DisplayName)
                    {
                        $instance = $policyInfo
                    }
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                DisplayName           = $instance.properties.displayName
                PolicyName            = $instance.name
                Environments          = [array]$instance.properties.definition.constraints.environmentFilter1.parameters.environments.name
                FilterType            = $instance.properties.definition.constraints.environmentFilter1.parameters.filterType
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
        $type = $null
        $hbiApis = $null
        $newPolicy = $null
        $lbiDescription = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Power Platform Admin DLP Policy with DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $schema = 'https://schema.management.azure.com/providers/Microsoft.BusinessAppPlatform/schemas/2016-10-01-preview/apiPolicyDefinition.json#'
        $constraints = @{}
        if ($null -ne $this.Environments -and $this.Environments.Length -gt 0)
        {
            $environmentInfo = @()
            foreach ($environment in $this.Environments)
            {
                $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                    "/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/$($environment)?`$expand=permissions&api-version=2016-11-01"

                Write-Verbose -Message "Creating new policy with body:`r`n$(ConvertTo-Json $newPolicy -Depth 20)"
                $environmentInfo += Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET'
            }

            $constraints = @{
                environmentFilter1 = @{
                    parameters = @{
                        environments = $environmentInfo
                        filterType   = $this.FilterType
                    }
                    type       = 'environmentFilter'
                }
            }
        }
        $rules = @{
            dataFlowRule = @{
                actions    = @{
                    blockAction = @{
                        type = 'Block'
                    }
                }
                parameters = @{
                    destinationApiGroup = 'lbi'
                    sourceApiGroup      = 'hbi'
                }
                type       = 'DataFlowRestriction'
            }
        }
        $CreatedTime = Get-Date -Format 'o'
        $policyObject = @{
            id         = ''
            name       = ''
            type       = $type
            tags       = @{}
            properties = @{
                createdTime = $CreatedTime
                displayName = $this.DisplayName
                definition  = @{
                    "`$schema"      = $schema
                    defaultApiGroup = 'lbi'
                    constraints     = $constraints
                    apiGroups       = @{
                        hbi = @{
                            apis        = $hbiApis
                            description = 'Business data only'
                        }
                        lbi = @{
                            apis        = @()
                            description = $lbiDescription
                        }
                    }
                    rules           = $rules
                }
            }
        }

        # CREATE
        $needToUpdateNewInstance = $false
        $policyNameValue = $currentInstance.PolicyName
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Data Policy {$($this.DisplayName)}"
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

            Write-Verbose -Message "Creating new policy with body:`r`n$(ConvertTo-Json $newPolicy -Depth 20)"
            $policy = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'POST' -Body $policyObject
            $policyNameValue = $policy.name
        }
        if ($setParameters.ContainsKey('PolicyName'))
        {
            $setParameters.PolicyName = $policyNameValue
        }
        else
        {
            $setParameters.Add('PolicyName', $policyNameValue)
        }

        # UPDATE
        if (($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present') -or $needToUpdateNewInstance)
        {
            Write-Verbose -Message "Updating Data Policy {$($this.DisplayName)}"
            $setParameters.Remove('DisplayName') | Out-Null

            if ($null -ne $setParameters.Environments -and $setParameters.Environments.Count -gt 0)
            {
                $setParameters.Environments = ($setParameters.Environments -join ',')
            }
            Write-Verbose -Message "Updating Data Policy {$($this.DisplayName)} with values:`r`n$(Convert-M365DscHashtableToString -Hashtable $setParameters)"
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/$($policyNameValue)?api-version=2016-11-01"

            $policy = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'PUT' -Body $policyObject
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Data Policy {$($this.DisplayName)}"
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies/$($policyNameValue)?api-version=2016-11-01"

            $policy = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'DELETE'
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

        $ConnectionMode = $this.Connect('PowerPlatformREST')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                '/providers/Microsoft.BusinessAppPlatform/scopes/admin/apiPolicies?api-version=2016-11-01'

            [array] $exportedInstances = (Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET').value

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($exportedInstances.Count -eq 0)
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

                $displayedKey = $config.properties.displayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.properties.displayName
                    PolicyName            = $config.name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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

    hidden [PPAdminDLPPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPAdminDLPPolicy])
        {
            return $Values
        }

        $result = [PPAdminDLPPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
