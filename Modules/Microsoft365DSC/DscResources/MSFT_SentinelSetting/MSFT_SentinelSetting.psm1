using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SentinelSetting : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Resource Group Name')]
    [System.String] $ResourceGroupName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the workspace.')]
    [System.String] $WorkspaceName

    [DscProperty()]
    [System.ComponentModel.Description('Gets subscription credentials which uniquely identify Microsoft Azure subscription. The subscription ID forms part of the URI for every service call.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('Specififies if Anomaly detection should be enabled or not.')]
    [System.Nullable[System.Boolean]] $AnomaliesIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specififies if Entity Analyticsshould be enabled or not.')]
    [System.Nullable[System.Boolean]] $EntityAnalyticsIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specififies if Auditing and Health Monitoring should be enabled or not.')]
    [System.Nullable[System.Boolean]] $EyesOnIsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The list of Data sources associated with the UEBA.')]
    [System.String[]] $UebaDataSource

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

    [SentinelSetting] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SentinelSetting]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Sentinel Settings for Resource Group: $($this.ResourceGroupName), Workspace: $($this.WorkspaceName)"

        try
        {
            $null = $this.Connect('Azure')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $ResourceGroupNameValue = $this.ResourceGroupName
            $WorkspaceNameValue = $this.WorkspaceName
            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                $entry = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.Name -eq $this.WorkspaceName }
                $instance = Get-AzSentinelSetting -ResourceGroupName $entry.ResourceGroupName `
                    -WorkspaceName $entry.Name `
                    -SubscriptionId $this.SubscriptionId `
                    -ErrorAction SilentlyContinue
                $ResourceGroupNameValue = $entry.ResourceGroupName
                $WorkspaceNameValue = $entry.Name
            }
            else
            {
                Write-Verbose -Message "Retrieving Sentinel Settings for {$($this.WorkspaceName)}"
                $instance = Get-AzSentinelSetting -ResourceGroupName $this.ResourceGroupName `
                    -WorkspaceName $this.WorkspaceName `
                    -ErrorAction SilentlyContinue `
                    -SubscriptionId $this.SubscriptionId
            }

            if ($null -eq $instance)
            {
                throw "Failed to get configuration for Sentinel Workspace {$($this.WorkspaceName)} in Resource Group {$($this.ResourceGroupName)}"
            }

            Write-Verbose -Message "Found an instance of Sentinel Workspace {$($this.WorkspaceName)}"
            $Anomalies = $instance | Where-Object -FilterScript { $_.Name -eq 'Anomalies' }
            $AnomaliesIsEnabledValue = $false
            if ($null -ne $Anomalies)
            {
                Write-Verbose -Message 'Anomalies instance found.'
                $AnomaliesIsEnabledValue = $Anomalies.IsEnabled
            }

            $EntityAnalytics = $instance | Where-Object -FilterScript { $_.Name -eq 'EntityAnalytics' }
            $EntityAnalyticsIsEnabledValue = $false
            if ($null -ne $EntityAnalytics)
            {
                Write-Verbose -Message 'EntityAnalytics instance found.'
                $EntityAnalyticsIsEnabledValue = $EntityAnalytics.IsEnabled
            }

            $EyesOn = $instance | Where-Object -FilterScript { $_.Name -eq 'EyesOn' }
            $EyesOnIsEnabledValue = $false
            if ($null -ne $EyesOn)
            {
                Write-Verbose -Message 'EyesOn instance found.'
                $EyesOnIsEnabledValue = $EyesOn.IsEnabled
            }

            $Ueba = $instance | Where-Object -FilterScript { $_.Name -eq 'Ueba' }
            $UebaDataSourceValue = $null
            if ($null -ne $Ueba)
            {
                Write-Verbose -Message 'UEBA Data source instance found.'
                $UebaDataSourceValue = $Ueba.DataSource
            }

            $results = @{
                AnomaliesIsEnabled       = [Boolean]$AnomaliesIsEnabledValue
                EntityAnalyticsIsEnabled = [Boolean]$EntityAnalyticsIsEnabledValue
                EyesOnIsEnabled          = [Boolean]$EyesOnIsEnabledValue
                UebaDataSource           = $UebaDataSourceValue
                ResourceGroupName        = $ResourceGroupNameValue
                WorkspaceName            = $WorkspaceNameValue
                SubscriptionId           = $this.SubscriptionId
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration for Sentinel Settings for Resource Group: $($this.ResourceGroupName), Workspace: $($this.WorkspaceName)"

        $null = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        if ($this.GetBoundParameters().ContainsKey('AnomaliesIsEnabled'))
        {
            Write-Verbose -Message "Updating Anomalies IsEnabled value to {$($this.AnomaliesIsEnabled)}"
            Update-AzSentinelSetting -ResourceGroupName $this.ResourceGroupName `
                -WorkspaceName $this.WorkspaceName `
                -SettingsName 'Anomalies' `
                -Enabled $this.AnomaliesIsEnabled | Out-Null
        }
        if ($this.GetBoundParameters().ContainsKey('EntityAnalyticsIsEnabled'))
        {
            Write-Verbose -Message "Updating Entity Analytics IsEnabled value to {$($this.EntityAnalyticsIsEnabled)}"
            Update-AzSentinelSetting -ResourceGroupName $this.ResourceGroupName `
                -WorkspaceName $this.WorkspaceName `
                -SettingsName 'EntityAnalytics' `
                -Enabled $this.EntityAnalyticsIsEnabled | Out-Null
        }
        if ($this.GetBoundParameters().ContainsKey('EyesOnIsEnabled'))
        {
            Write-Verbose -Message "Updating Eyes On IsEnabled value to {$($this.EyesOnIsEnabled)}"
            Update-AzSentinelSetting -ResourceGroupName $this.ResourceGroupName `
                -WorkspaceName $this.WorkspaceName `
                -SettingsName 'EyesOn' `
                -Enabled $this.EyesOnIsEnabled | Out-Null
        }
        if ($this.GetBoundParameters().ContainsKey('UebaDataSource'))
        {
            Write-Verbose -Message "Updating UEBA Data Source value to {$($this.UebaDataSource)}"
            Update-AzSentinelSetting -ResourceGroupName $this.ResourceGroupName `
                -WorkspaceName $this.WorkspaceName `
                -SettingsName 'Ueba' `
                -DataSource $this.UebaDataSource | Out-Null
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
            [array] $this.ResourceCache['exportedInstances'] = Get-AzResource -ResourceType 'Microsoft.OperationalInsights/workspaces' | Where-Object Name -in $sentinelNames

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($this.ResourceCache['exportedInstances'].Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $this.ResourceCache['exportedInstances'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                $displayedKey = $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $displayedKey" -DeferWrite
                $subscriptionIdValue = $config.ResourceId.Split('/')[2]
                $params = @{
                    ResourceGroupName     = $config.ResourceGroupName
                    WorkspaceName         = $config.Name
                    SubscriptionId        = $subscriptionIdValue
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
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

    hidden [SentinelSetting] AsResult([System.Object] $Values)
    {
        if ($Values -is [SentinelSetting])
        {
            return $Values
        }

        $result = [SentinelSetting]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
