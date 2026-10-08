using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SentinelThreatIntelligenceIndicator : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the indicator')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the resource group. The name is case insensitive.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('The name of the resource group. The name is case insensitive.')]
    [System.String] $ResourceGroupName

    [DscProperty()]
    [System.ComponentModel.Description('The name of the workspace.')]
    [System.String] $WorkspaceName

    [DscProperty()]
    [System.ComponentModel.Description('The unique id of the indicator.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The name of the workspace.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Pattern type of a threat intelligence entity')]
    [System.String] $PatternType

    [DscProperty()]
    [System.ComponentModel.Description('Pattern of a threat intelligence entity')]
    [System.String] $Pattern

    [DscProperty()]
    [System.ComponentModel.Description('Is threat intelligence entity revoked')]
    [System.String] $Revoked

    [DscProperty()]
    [System.ComponentModel.Description('Valid from')]
    [System.String] $ValidFrom

    [DscProperty()]
    [System.ComponentModel.Description('Valid until')]
    [System.String] $ValidUntil

    [DscProperty()]
    [System.ComponentModel.Description('Source type.')]
    [System.String] $Source

    [DscProperty()]
    [System.ComponentModel.Description('Labels of threat intelligence entity')]
    [System.String[]] $Labels

    [DscProperty()]
    [System.ComponentModel.Description('List of tags')]
    [System.String[]] $ThreatIntelligenceTags

    [DscProperty()]
    [System.ComponentModel.Description('Threat types')]
    [System.String[]] $ThreatTypes

    [DscProperty()]
    [System.ComponentModel.Description('Kill chain phases')]
    [System.String[]] $KillChainPhases

    [DscProperty()]
    [System.ComponentModel.Description('Confidence of threat intelligence entity')]
    [System.Nullable[System.UInt32]] $Confidence

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

    [SentinelThreatIntelligenceIndicator] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SentinelThreatIntelligenceIndicator]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Sentinel Threat Intelligence Indicator configuration for $($this.DisplayName)"

        try
        {
            $null = $this.Connect('Azure')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            $tenantIdValue = $this.TenantId
            if ([System.String]::IsNullOrEmpty($tenantIdValue) -and -not $null -eq $this.Credential)
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }

            if (-not [System.String]::IsNullOrEmpty($this.Id))
            {
                Write-Verbose -Message "Retrieving indicator by id {$($this.Id)}"
                $instance = $this.GetIndicator($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $this.Id)
            }
            if ($null -eq $instance)
            {
                Write-Verbose -Message "Retrieving indicator by DisplayName {$($this.DisplayName)}"
                $instances = $this.GetIndicator($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $null)
                $instance = $instances | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                DisplayName            = $instance.properties.displayName
                SubscriptionId         = $this.SubscriptionId
                ResourceGroupName      = $this.ResourceGroupName
                WorkspaceName          = $this.WorkspaceName
                Id                     = $instance.name
                Description            = $instance.properties.description
                PatternType            = $instance.properties.patternType
                Pattern                = $instance.properties.pattern
                Revoked                = $instance.properties.revoked
                ValidFrom              = $instance.properties.validFrom
                ValidUntil             = $instance.properties.validUntil
                Labels                 = $instance.properties.labels
                ThreatIntelligenceTags = $instance.properties.threatIntelligenceTags
                ThreatTypes            = $instance.properties.threatTypes
                KillChainPhases        = $instance.properties.KillChainPhases.phaseName
                Confidence             = $instance.properties.confidence
                Source                 = $instance.properties.source
                Ensure                 = 'Present'
                Credential             = $this.Credential
                ApplicationId          = $this.ApplicationId
                TenantId               = $tenantIdValue
                CertificateThumbprint  = $this.CertificateThumbprint
                CertificatePath        = $this.CertificatePath
                CertificatePassword    = $this.CertificatePassword
                ManagedIdentity        = $this.ManagedIdentity
                AccessTokens           = $this.AccessTokens
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

        Write-Verbose -Message "Setting Sentinel Threat Intelligence Indicator configuration for $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParameters = @{
            kind       = 'indicator'
            properties = @{
                confidence             = $this.Confidence
                description            = $this.Description
                displayName            = $this.DisplayName
                labels                 = $this.Labels
                pattern                = $this.Pattern
                patternType            = $this.patternType
                revoked                = $this.revoked
                source                 = $this.Source
                threatIntelligenceTags = $this.ThreatIntelligenceTags
                threatTypes            = $this.ThreatTypes
                validFrom              = $this.ValidFrom
                validUntil             = $this.ValidUntil
            }
        }

        if ($null -ne $this.KillChainPhases)
        {
            $values = @()
            foreach ($phase in $this.KillChainPhases)
            {
                $values += @{
                    killChainName = 'lockheed-martin-cyber-kill-chain'
                    phaseName     = $phase
                }
            }
            $instanceParameters.properties.Add('KillChainPhases', $values)
        }

        $tenantIdValue = $this.TenantId
        if ([System.String]::IsNullOrEmpty($tenantIdValue) -and -not $null -eq $this.Credential)
        {
            $tenantIdValue = $this.Credential.UserName.Split('@')[1]
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new indicator {$($this.DisplayName)}"
            $this.NewIndicator($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $instanceParameters)
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating indicator {$($this.DisplayName)}"
            $this.SetIndicator($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $currentInstance.Id, $instanceParameters)
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing indicator {$($this.DisplayName)}"
            $this.RemoveIndicator($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue, $currentInstance.Id)
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

        $ConnectionMode = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $sentinelInstances = Get-AzResource -ResourceType 'Microsoft.OperationsManagement/solutions'
            $sentinelNames = @()
            foreach ($instance in $sentinelInstances)
            {
                $sentinelNames += $instance.Name.Replace('SecurityInsights(', '').Replace(')', '')
            }
            $workspaces = Get-AzResource -ResourceType 'Microsoft.OperationalInsights/workspaces' | Where-Object Name -in $sentinelNames
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($workspaces.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            $tenantIdValue = $this.TenantId
            if ([System.String]::IsNullOrEmpty($tenantIdValue) -and $null -ne $this.Credential)
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }
            foreach ($workspace in $workspaces)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($workspaces.Length)] $($workspace.Name)" -DeferWrite
                $subscriptionIdValue = $workspace.ResourceId.Split('/')[2]
                $resourceGroupNameValue = $workspace.ResourceGroupName
                $workspaceNameValue = $workspace.Name

                $indicators = $this.GetIndicator($subscriptionIdValue, $resourceGroupNameValue, $workspaceNameValue, $tenantIdValue, $null)

                $j = 1
                if ($indicators.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                foreach ($indicator in $indicators)
                {
                    $displayedKey = $indicator.properties.DisplayName
                    Write-M365DSCHost -Message "        |---[$j/$($indicators.Count)] $displayedKey" -DeferWrite
                    $params = @{
                        DisplayName           = $indicator.properties.displayName
                        Id                    = $indicator.name
                        SubscriptionId        = $subscriptionIdValue
                        ResourceGroupName     = $resourceGroupNameValue
                        WorkspaceName         = $workspaceNameValue
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $tenantIdValue
                        CertificateThumbprint = $this.CertificateThumbprint
                        CertificatePath       = $this.CertificatePath
                        CertificatePassword   = $this.CertificatePassword
                        ManagedIdentity       = $this.ManagedIdentity
                        AccessTokens          = $this.AccessTokens
                    }

                    $Results = $this.GetForExport($Params)

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential
                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    $j++
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Object] GetIndicator([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.String] $Id)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"
            if (-not [System.String]::IsNullOrEmpty($Id))
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/threatIntelligence/main/indicators/$($Id)?api-version=2024-03-01"
                $response = Invoke-AzRestMethod -Uri $uri -Method 'GET'
                $result = ConvertFrom-Json $response.Content
                return $result
            }
            else
            {
                $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/threatIntelligence/main/indicators?api-version=2024-03-01"
                $response = Invoke-AzRestMethod -Uri $uri -Method 'GET'
                $result = ConvertFrom-Json $response.Content
                return $result.value
            }
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [void] RemoveIndicator([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.String] $Id)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"

            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/threatIntelligence/main/indicators/$($Id)?api-version=2024-03-01"
            $null = Invoke-AzRestMethod -Uri $uri -Method 'DELETE'
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [void] NewIndicator([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.Collections.Hashtable] $Body)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"

            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/threatIntelligence/main/createIndicator?api-version=2024-03-01"
            $payload = ConvertTo-Json $Body -Depth 10 -Compress
            $null = Invoke-AzRestMethod -Uri $uri -Method 'POST' -Payload $payload
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [void] SetIndicator([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId, [System.String] $Id, [System.Collections.Hashtable] $Body)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"

            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/threatIntelligence/main/indicators/$($Id)?api-version=2024-03-01"
            $payload = ConvertTo-Json $Body -Depth 10 -Compress
            $null = Invoke-AzRestMethod -Uri $uri -Method 'PUT' -Payload $payload
        }
        catch
        {
            Write-Verbose -Message $_
            New-M365DSCLogEntry -Message 'Error retrieving data:' `
                -Exception $_ `
                -Source $this.GetResourceName() `
                -TenantId $TenantId
            throw $_
        }
    }

    hidden [SentinelThreatIntelligenceIndicator] AsResult([System.Object] $Values)
    {
        if ($Values -is [SentinelThreatIntelligenceIndicator])
        {
            return $Values
        }

        $result = [SentinelThreatIntelligenceIndicator]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
