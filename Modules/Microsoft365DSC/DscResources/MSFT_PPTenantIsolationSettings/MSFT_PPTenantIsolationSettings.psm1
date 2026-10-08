using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class PPTenantIsolationSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Should be set to yes')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('When set to true this will enable the tenant isolation settings.')]
    [System.Nullable[System.Boolean]] $Enabled

    [DscProperty()]
    [System.ComponentModel.Description('The exact list of tenant rules to be configured.')]
    [MSFT_PPTenantRule[]] $Rules

    [DscProperty()]
    [System.ComponentModel.Description('A list of tenant rules that has to be added.')]
    [MSFT_PPTenantRule[]] $RulesToInclude

    [DscProperty()]
    [System.ComponentModel.Description('A list of tenant rules that is now allowed to be added.')]
    [MSFT_PPTenantRule[]] $RulesToExclude

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Power Platform Admin')]
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
    [System.ComponentModel.Description('Access tokens used for authentication in scenarios requiring multiple tokens.')]
    [System.String[]] $AccessTokens

    PPTenantIsolationSettings() : base()
    {
        $this.ResourceCache['TenantNameToGuidCache'] = @{}
    }

    [PPTenantIsolationSettings] Get()
    {
        $RequestBody = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [PPTenantIsolationSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting the Power Platform Tenant Isolation Settings Configuration'

        try
        {
            if ($this.GetBoundParameters().ContainsKey('Rules') -and `
                ($this.GetBoundParameters().ContainsKey('RulesToInclude') -or `
                        $this.GetBoundParameters().ContainsKey('RulesToExclude')))
            {
                $message = 'You cannot specify Rules and RulesToInclude/RulesToExclude.'
                Add-M365DSCEvent -Message $message -EntryType 'Error' `
                    -EventID 1 -Source $($this.GetResourceName())
                throw $message
            }

            $null = $this.Connect('MicrosoftGraph')

            $graphTenantId = (Get-MgContext).TenantId

            $null = $this.Connect('PowerPlatformREST')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
                "/providers/PowerPlatform.Governance/v1/tenants/$($graphTenantId)/tenantIsolationPolicy?api-version=2016-11-01"
            $tenantIsolationPolicy = Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'GET' -Body $RequestBody
            if ($tenantIsolationPolicy.StatusCode -eq 403)
            {
                throw 'Invalid permission for the application. If you are using a custom app registration to authenticate, make sure it is defined as a Power Platform admin management application. For additional information refer to https://learn.microsoft.com/en-us/power-platform/admin/powershell-create-service-principal#registering-an-admin-management-application'
            }

            [Array]$allowedTenants = $tenantIsolationPolicy.properties.allowedTenants | ForEach-Object {
                $directions = $_.direction
                if ($directions.inbound -eq $true)
                {
                    if ($directions.outbound -eq $true)
                    {
                        $direction = 'Both'
                    }
                    else
                    {
                        $direction = 'Inbound'
                    }
                }
                elseif ($directions.outbound -eq $true)
                {
                    $direction = 'Outbound'
                }
                else
                {
                    $direction = 'unknown'
                }

                return [MSFT_PPTenantRule] @{
                    TenantName = $_.tenantId
                    Direction  = $direction
                }
            }

            return $this.AsResult(@{
                IsSingleInstance      = 'Yes'
                Enabled               = ($tenantIsolationPolicy.properties.isDisabled -eq $false)
                Rules                 = $allowedTenants
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                AccessTokens          = $this.AccessTokens
            })
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

        Write-Verbose -Message 'Setting Power Platform Tenant Isolation Settings configuration'

        if ($this.GetBoundParameters().ContainsKey('Rules') -and `
            ($this.GetBoundParameters().ContainsKey('RulesToInclude') -or `
                    $this.GetBoundParameters().ContainsKey('RulesToExclude')))
        {
            $message = 'You cannot specify Rules and RulesToInclude/RulesToExclude.'
            Add-M365DSCEvent -Message $message -EntryType 'Error' `
                -EventID 1 -Source $($this.GetResourceName())
            throw $message
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('PowerPlatformREST')

        $null = $this.Connect('MicrosoftGraph')

        $tenantinfo = (Get-MgContext).TenantId

        $tenantIsolationPolicy = @{
            properties = @{
                tenantId       = $tenantinfo
                isDisabled     = $false
                allowedTenants = @()
            }
        }

        $tenantIsolationPolicy.Properties.isDisabled = -not $this.Enabled

        [Array]$existingAllowedRules = $tenantIsolationPolicy.Properties.allowedTenants

        if ($this.GetBoundParameters().ContainsKey('Rules'))
        {
            Write-Verbose 'Processing parameter Rules'
            foreach ($rule in $this.Rules)
            {
                # Check if Rules exist
                $ruleTenantId = $this.GetM365TenantId($rule.TenantName)

                $direction = @{
                    inbound  = $false
                    outbound = $false
                }

                $existingRule = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }
                if ($null -eq $existingRule)
                {
                    Write-Verbose "Rule for $($rule.TenantName) does not exist. Adding with direction $($rule.Direction)"
                    switch ($rule.Direction)
                    {
                        'Inbound'
                        {
                            $direction.inbound = $true
                        }
                        'Outbound'
                        {
                            $direction.outbound = $true
                        }
                        'Both'
                        {
                            $direction.inbound = $true
                            $direction.outbound = $true
                        }
                    }

                    $newRule = @{
                        tenantId  = $ruleTenantId
                        direction = $direction
                    }

                    $existingAllowedRules += $newRule
                }
                else
                {
                    Write-Verbose "Rule for $($rule.TenantName) exists. Setting specified direction."
                    switch ($rule.Direction)
                    {
                        'Inbound'
                        {
                            $existingRule.Direction.inbound = $true
                            $existingRule.Direction.outbound = $false
                        }
                        'Outbound'
                        {
                            $existingRule.Direction.inbound = $false
                            $existingRule.Direction.outbound = $true
                        }
                        'Both'
                        {
                            $existingRule.Direction.inbound = $true
                            $existingRule.Direction.outbound = $true
                        }
                    }
                }
            }

            # Resolved up front rather than inside the Where-Object below because $this does not resolve
            # inside a scriptblock nested in a class method.
            $desiredTenantIds = @()
            foreach ($rule in $this.Rules)
            {
                $desiredTenantIds += $this.GetM365TenantId($rule.TenantName)
            }

            $removeRules = @()
            foreach ($existingRule in $existingAllowedRules)
            {
                # Check if rules are not in the specified list
                if ($existingRule.tenantId -notin $desiredTenantIds)
                {
                    Write-Verbose "Rule for tenant id $($existingRule.tenantId) does not exist in the Rules parameter. Deleting rule."
                    $removeRules += $existingRule.tenantId
                }
            }
            [Array]$newRules = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -notin $removeRules }
            $tenantIsolationPolicy.Properties.allowedTenants = $newRules
        }

        if ($this.GetBoundParameters().ContainsKey('RulesToInclude'))
        {
            Write-Verbose 'Processing parameter RulesToInclude'
            foreach ($rule in $this.RulesToInclude)
            {
                Write-Verbose "Checking rule for TenantName $($rule.TenantName) with direction $($rule.Direction)"
                $ruleTenantId = $this.GetM365TenantId($rule.TenantName)
                Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

                $direction = @{
                    inbound  = $false
                    outbound = $false
                }

                $existingRule = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }
                if ($null -eq $existingRule)
                {
                    Write-Verbose "Rule does not exist. Adding with direction $($rule.Direction)"
                    # Rule does not exist, add rule
                    switch ($rule.Direction)
                    {
                        'Inbound'
                        {
                            $direction.inbound = $true
                        }
                        'Outbound'
                        {
                            $direction.outbound = $true
                        }
                        'Both'
                        {
                            $direction.inbound = $true
                            $direction.outbound = $true
                        }
                    }

                    $newRule = @{
                        tenantId          = $ruleTenantId
                        tenantDisplayName = ''
                        direction         = $direction
                    }

                    $existingAllowedRules += $newRule
                }
                else
                {
                    Write-Verbose 'Rule exists. Setting specified direction.'
                    switch ($rule.Direction)
                    {
                        'Inbound'
                        {
                            $existingRule.Direction.inbound = $true
                            $existingRule.Direction.outbound = $false
                        }
                        'Outbound'
                        {
                            $existingRule.Direction.inbound = $false
                            $existingRule.Direction.outbound = $true
                        }
                        'Both'
                        {
                            $existingRule.Direction.inbound = $true
                            $existingRule.Direction.outbound = $true
                        }
                    }
                }
            }
            $tenantIsolationPolicy.Properties.allowedTenants = $existingAllowedRules
        }

        if ($this.GetBoundParameters().ContainsKey('RulesToExclude'))
        {
            Write-Verbose 'Processing parameter RulesToExclude'
            foreach ($rule in $this.RulesToExclude)
            {
                Write-Verbose "Checking rule for TenantName $($rule.TenantName) RulesToExclude"
                $ruleTenantId = $this.GetM365TenantId($rule.TenantName)
                Write-Verbose -Message "Found TenantName {$($rule.TenantName)}"

                $removeRules = @()
                if ($null -ne ($existingAllowedRules | Where-Object -FilterScript { $_.tenantId -eq $ruleTenantId }))
                {
                    Write-Verbose "Rule for $($rule.TenantName) is currently configured in the rules. Deleting rule."
                    $removeRules += $ruleTenantId
                }
            }

            [Array]$newRules = $existingAllowedRules | Where-Object -FilterScript { $_.tenantId -notin $removeRules }
            $tenantIsolationPolicy.Properties.allowedTenants = $newRules
        }
        $uri = 'https://' + (Get-MSCloudLoginConnectionProfile -Workload 'PowerPlatformREST').BapEndpoint + `
            "/providers/PowerPlatform.Governance/v1/tenants/$($tenantinfo)/tenantIsolationPolicy?api-version=2020-06-01"
        Write-Verbose -Message "Updating with payload:`r`n$(ConvertTo-Json $tenantIsolationPolicy -Depth 20)"
        Invoke-M365DSCPowerPlatformRESTWebRequest -Uri $uri -Method 'PUT' -Body $tenantIsolationPolicy
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $ConnectionMode = $this.Connect('PowerPlatformREST')
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $dscContent = [System.Text.StringBuilder]::new()

            $Params = @{
                IsSingleInstance      = 'Yes'
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

            if ($Results -is [System.Collections.Hashtable] -and $Results.Count -gt 1)
            {
                if ($null -ne $Results.Rules)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Rules'
                            CimInstanceName = 'MSFT_PPTenantRule'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Rules `
                        -CIMInstanceName 'MSFT_PPTenantRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Rules = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Rules') | Out-Null
                    }
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite
            }

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        # Resolved up front because $this does not resolve inside the PostProcessing scriptblock.
        # TODO: Only do this if not doing a Report. It requires a connection to internet, which is not (always) available when doing a report.
        $tenantIdMap = @{}
        foreach ($rule in (@($this.Rules) + @($this.RulesToInclude) + @($this.RulesToExclude)))
        {
            if ($null -ne $rule -and -not $tenantIdMap.ContainsKey($rule.TenantName))
            {
                $tenantIdMap[$rule.TenantName] = $this.GetM365TenantId($rule.TenantName)
            }
        }

        return @{
            IncludedProperties = @('Enabled', 'Rules')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                $tenantIdMap = $PostProcessingArgs[0]
                if ($null -ne $DesiredValues['Rules'])
                {
                    $effectiveRules = @()
                    foreach ($rule in @($DesiredValues['Rules']))
                    {
                        $tenantId = if ($tenantIdMap.ContainsKey($rule.TenantName)) { $tenantIdMap[$rule.TenantName] } else { $rule.TenantName }
                        $effectiveRules += [MSFT_PPTenantRule] @{
                            TenantName = $tenantId
                            Direction  = $rule.Direction
                        }
                    }
                    $DesiredValues['Rules'] = $effectiveRules
                    $ValuesToCheck['Rules'] = $effectiveRules
                }
                elseif ($null -ne $DesiredValues['RulesToInclude'] -or $null -ne $DesiredValues['RulesToExclude'])
                {
                    $effectiveRules = [ordered]@{}
                    foreach ($rule in @($CurrentValues['Rules']))
                    {
                        if ($null -ne $rule)
                        {
                            $effectiveRules[$rule.TenantName] = [MSFT_PPTenantRule] @{
                                TenantName = $rule.TenantName
                                Direction  = $rule.Direction
                            }
                        }
                    }
                    foreach ($rule in @($DesiredValues['RulesToInclude']))
                    {
                        if ($null -ne $rule)
                        {
                            $tenantId = if ($tenantIdMap.ContainsKey($rule.TenantName)) { $tenantIdMap[$rule.TenantName] } else { $rule.TenantName }
                            $effectiveRules[$tenantId] = [MSFT_PPTenantRule] @{
                                TenantName = $tenantId
                                Direction  = $rule.Direction
                            }
                        }
                    }
                    foreach ($rule in @($DesiredValues['RulesToExclude']))
                    {
                        if ($null -ne $rule)
                        {
                            $tenantId = if ($tenantIdMap.ContainsKey($rule.TenantName)) { $tenantIdMap[$rule.TenantName] } else { $rule.TenantName }
                            $effectiveRules.Remove($tenantId)
                        }
                    }
                    $DesiredValues['Rules'] = @($effectiveRules.Values)
                    $ValuesToCheck['Rules'] = $DesiredValues['Rules']
                }
                foreach ($key in @('RulesToInclude', 'RulesToExclude'))
                {
                    $DesiredValues.Remove($key)
                    $CurrentValues.Remove($key)
                    $ValuesToCheck.Remove($key)
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            PostProcessingArgs = @(, $tenantIdMap)
        }
    }

    hidden [PPTenantIsolationSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [PPTenantIsolationSettings])
        {
            return $Values
        }

        $result = [PPTenantIsolationSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }

    <#
        Was the module-scope Get-M365TenantId, backed by a $Script: cache. Both had to go: every
        resource compiles into a shared Classes/Part<NN>.psm1, so script scope is one namespace
        across unrelated resources. The cache lives on the instance instead.
    #>
    hidden [System.String] GetM365TenantId([System.String] $TenantName)
    {
        if ($TenantName -eq '*')
        {
            return '*'
        }

        $cache = $this.ResourceCache['TenantNameToGuidCache']
        if ($cache.ContainsKey($TenantName))
        {
            return $cache[$TenantName]
        }

        $result = Invoke-WebRequest "https://login.windows.net/$TenantName/.well-known/openid-configuration" -UseBasicParsing
        $jsonResult = $result | ConvertFrom-Json
        $resolvedTenantId = $jsonResult.token_endpoint.Split('/')[3]
        $cache[$TenantName] = $resolvedTenantId
        return $resolvedTenantId
    }
}

class MSFT_PPTenantRule
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the trusted tenant.')]
    [System.String] $TenantName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Direction of tenant trust.')]
    [ValidateSet('Inbound', 'Outbound', 'Both')]
    [System.String] $Direction
}
