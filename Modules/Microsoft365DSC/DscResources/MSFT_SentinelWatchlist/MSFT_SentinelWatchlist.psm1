using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SentinelWatchlist : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Tha name of the watchlist.')]
    [System.String] $Name

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
    [System.ComponentModel.Description('The id (a Guid) of the watchlist')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the watchlist.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The source of the watchlist. Only accepts ''Local file'' and ''Remote storage''. And it must included in the request.')]
    [System.String] $SourceType

    [DscProperty()]
    [System.ComponentModel.Description('The search key is used to optimize query performance when using watchlists for joins with other data. For example, enable a column with IP addresses to be the designated SearchKey field, then use this field as the key field when joining to other event data by IP address.')]
    [System.String] $ItemsSearchKey

    [DscProperty()]
    [System.ComponentModel.Description('A description of the watchlist')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The default duration of a watchlist (in ISO 8601 duration format)')]
    [System.String] $DefaultDuration

    [DscProperty()]
    [System.ComponentModel.Description('The watchlist alias')]
    [System.String] $Alias

    [DscProperty()]
    [System.ComponentModel.Description('The number of lines in a csv content to skip before the header')]
    [System.Nullable[System.UInt32]] $NumberOfLinesToSkip

    [DscProperty()]
    [System.ComponentModel.Description('The raw content that represents to watchlist items to create. Example : This line will be skipped header1,header2 value1,value2')]
    [System.String] $RawContent

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

    [SentinelWatchlist] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SentinelWatchlist]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Sentinel Watchlist with Name {$($this.Name)}"

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
            if ([System.String]::IsNullOrEmpty($tenantIdValue) -and $null -ne $this.Credential)
            {
                $tenantIdValue = $this.Credential.UserName.Split('@')[1]
            }

            Write-Verbose -Message "Retrieving watchlist {$($this.Name)}"
            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.properties.watchListId -eq $this.Id }
                }

                if ($null -eq $instance)
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.name -eq $this.Name }
                }
            }
            else
            {
                $watchLists = $this.GetWatchlists($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $tenantIdValue)

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = $watchLists | Where-Object -FilterScript { $_.properties.watchListId -eq $this.Id }
                }

                if ($null -eq $instance)
                {
                    $instance = $watchLists | Where-Object -FilterScript { $_.name -eq $this.Name }
                }
            }
            if ($null -eq $instance)
            {
                Write-Verbose -Message "Watchlist {$($this.Name)} was not found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found watchlist {$($this.Name)}"
            $results = @{
                SubscriptionId        = $this.SubscriptionId
                ResourceGroupName     = $this.ResourceGroupName
                WorkspaceName         = $this.WorkspaceName
                Name                  = $instance.Name
                Id                    = $instance.properties.watchlistId
                DisplayName           = $instance.properties.displayName
                SourceType            = $instance.properties.sourceType
                ItemsSearchKey        = $instance.properties.itemsSearchKey
                Description           = $instance.properties.description
                DefaultDuration       = $instance.properties.defaultDuration
                Alias                 = $instance.properties.watchListAlias
                NumberOfLinesToSkip   = $instance.properties.numberOfLinesToSkip
                RawContent            = $this.RawContent
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $tenantIdValue
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Sentinel Watchlist with Name {$($this.Name)}"

        $null = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $tenantIdValue = $this.TenantId
        if ([System.String]::IsNullOrEmpty($tenantIdValue) -and $null -ne $this.Credential)
        {
            $tenantIdValue = $this.Credential.UserName.Split('@')[1]
        }

        $aliasValue = $this.Alias
        if ([System.String]::IsNullOrEmpty($aliasValue))
        {
            $aliasValue = $this.Name
        }

        $body = @{
            properties = @{
                displayName         = $this.DisplayName
                provider            = 'Microsoft'
                itemsSearchKey      = $this.ItemsSearchKey
                sourceType          = $this.SourceType
                description         = $this.Description
                defaultDuration     = $this.defaultDuration
                numberOfLinesToSkip = $this.NumberOfLinesToSkip
                watchListAlias      = $aliasValue
            }
        }

        if ($null -ne $this.RawContent)
        {
            Write-Verbose -Message 'Adding rawContent and contentType to the payload'
            $body.properties.Add('rawContent', $this.RawContent)
            $body.properties.Add('contentType', 'text/csv')
        }

        # CREATE & UPDATE
        if ($this.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Configuring watchlist {$($this.Name)}"
            $this.SetWatchlist($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $aliasValue, $body, $tenantIdValue)
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing watchlist {$($this.Name)}"
            $this.RemoveWatchlist($this.SubscriptionId, $this.ResourceGroupName, $this.WorkspaceName, $aliasValue, $tenantIdValue)
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
            $this.ResourceCache['ExportMode'] = $true
            $sentinelInstances = Get-AzResource -ResourceType 'Microsoft.OperationsManagement/solutions'
            $sentinelNames = @()
            foreach ($instance in $sentinelInstances)
            {
                $sentinelNames += $instance.Name.Replace('SecurityInsights(', '').Replace(')', '')
            }
            $workspaces = Get-AzResource -ResourceType 'Microsoft.OperationalInsights/workspaces' | Where-Object Name -in $sentinelNames
            $this.ResourceCache['exportedInstances'] = @()
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
                Write-M365DSCHost -Message "    |---[$i/$($workspaces.Length)] $($workspace.Name)" -DeferWrite
                $subscriptionIdValue = $workspace.ResourceId.Split('/')[2]
                $resourceGroupNameValue = $workspace.ResourceGroupName
                $workspaceNameValue = $workspace.Name

                $currentWatchLists = $this.GetWatchlists($subscriptionIdValue, $resourceGroupNameValue, $workspaceNameValue, $tenantIdValue)

                $j = 1
                if ($currentWatchLists.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                foreach ($watchList in $currentWatchLists)
                {
                    $this.ResourceCache['exportedInstances'] += $watchList
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }

                    $displayedKey = $watchList.Name
                    Write-M365DSCHost -Message "        |---[$j/$($currentWatchLists.Length)] $displayedKey" -DeferWrite
                    $params = @{
                        SubscriptionId        = $subscriptionIdValue
                        ResourceGroupName     = $resourceGroupNameValue
                        WorkspaceName         = $workspaceNameValue
                        Name                  = $watchList.Name
                        Id                    = $watchlist.properties.watchlistId
                        Credential            = $this.Credential
                        ApplicationId         = $this.ApplicationId
                        TenantId              = $tenantIdValue
                        CertificateThumbprint = $this.CertificateThumbprint
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

    hidden [System.Object[]] GetWatchlists([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $TenantId)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"
            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/watchlists?api-version=2022-06-01-preview"
            $response = Invoke-AzRestMethod -Uri $uri -Method 'GET'
            $result = ConvertFrom-Json $response.Content
            return $result.value
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

    hidden [void] RemoveWatchlist([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $WatchListAlias, [System.String] $TenantId)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"
            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/watchlists/$($WatchListAlias)?api-version=2022-06-01-preview"
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

    hidden [void] SetWatchlist([System.String] $SubscriptionId, [System.String] $ResourceGroupName, [System.String] $WorkspaceName, [System.String] $WatchListAlias, [System.Collections.Hashtable] $Body, [System.String] $TenantId)
    {
        try
        {
            $hostUrl = Get-M365DSCAPIEndpoint -TenantId $TenantId
            $uri = $hostUrl.AzureManagement + "/subscriptions/$($SubscriptionId)/resourceGroups/$($ResourceGroupName)/"
            $uri += "providers/Microsoft.OperationalInsights/workspaces/$($WorkspaceName)/providers/Microsoft.SecurityInsights/watchlists/$($WatchListAlias)?api-version=2022-06-01-preview"
            $payload = ConvertTo-Json $Body -Depth 10 -Compress

            Write-Verbose -Message "Calling Url: {$($uri)}"
            Write-Verbose -Message "Payload: {$payload}"
            $response = Invoke-AzRestMethod -Uri $uri -Method 'PUT' -Payload $payload
            if ($response.StatusCode -ne 200 -and $response.StatusCode -ne 201)
            {
                Write-Verbose -Message $($response | Out-String)
                $content = ConvertFrom-Json $response.Content
                throw $content.error.message
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

    hidden [SentinelWatchlist] AsResult([System.Object] $Values)
    {
        if ($Values -is [SentinelWatchlist])
        {
            return $Values
        }

        $result = [SentinelWatchlist]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
