using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the custom extension.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique Id of the extension.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the extension.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Client configuration for the extension')]
    [MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration] $ClientConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Endpoint configuration for the extension')]
    [MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration] $EndpointConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Callback configuration for the extension')]
    [MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration] $CallbackConfiguration

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
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension] Get()
    {
        $nullResult = $null
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Azure AD Identity Governance Lifecycle Workflow Custom Task Extension with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                try
                {
                    if (-not [System.String]::IsNullOrEmpty($this.Id))
                    {
                        $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $this.Id `
                            -ErrorAction Stop
                    }
                    if ($null -eq $instance)
                    {
                        $instance = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction Stop
                    }
                }
                catch
                {
                    if ($_.ErrorDetails.Message -like '*Insufficient license *')
                    {
                        Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                    }
                    else
                    {
                        $this.LogError($_, 'Error during Get:')
                        throw $_
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

            # Callback Configuration
            $CallbackConfigurationValue = $null
            if ($null -ne $instance.CallbackConfiguration.TimeoutDuration)
            {
                $CallbackConfigurationValue = @{
                    TimeoutDuration = "PT$($instance.CallbackConfiguration.TimeoutDuration.Minutes.ToString())M"
                    AuthorizedApps  = @()
                }

                foreach ($app in $instance.CallbackConfiguration.authorizedApps)
                {
                    $appInstance = Get-MgApplication -Filter "AppId eq '$($app['id'])'" -ErrorAction SilentlyContinue
                    if ($null -ne $appInstance)
                    {
                        $CallbackConfigurationValue.AuthorizedApps += $appInstance.DisplayName
                    }
                }
            }

            # Client Configuration
            $ClientConfigurationValue = @{
                MaximumRetries        = $instance.ClientConfiguration.MaximumRetries
                TimeoutInMilliseconds = $instance.ClientConfiguration.TimeoutInMilliseconds
            }

            # EndpointConfiguration
            $EndpointConfigurationValue = @{
                SubscriptionId       = $instance.EndpointConfiguration.subscriptionId
                resourceGroupName    = $instance.EndpointConfiguration.resourceGroupName
                logicAppWorkflowName = $instance.EndpointConfiguration.logicAppWorkflowName
                url                  = $instance.EndpointConfiguration.url
            }

            $results = @{
                DisplayName           = $this.DisplayName
                Id                    = $instance.Id
                Description           = $instance.Description
                CallbackConfiguration = $CallbackConfigurationValue
                ClientConfiguration   = $ClientConfigurationValue
                EndpointConfiguration = $EndpointConfigurationValue
                Ensure                = 'Present'
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

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            displayName                 = $this.DisplayName
            description                 = $this.Description
            endpointConfiguration       = @{
                '@odata.type'        = '#microsoft.graph.logicAppTriggerEndpointConfiguration'
                subscriptionId       = $this.EndpointConfiguration.subscriptionId
                resourceGroupName    = $this.EndpointConfiguration.resourceGroupName
                logicAppWorkflowName = $this.EndpointConfiguration.logicAppWorkflowName
                url                  = $this.EndpointConfiguration.url
            }
            clientConfiguration         = @{
                '@odata.type'         = '#microsoft.graph.customExtensionClientConfiguration'
                maximumRetries        = $this.clientConfiguration.maximumRetries
                timeoutInMilliseconds = $this.clientConfiguration.timeoutInMilliseconds
            }
            authenticationConfiguration = @{
                '@odata.type' = '#microsoft.graph.azureAdPopTokenAuthentication'
            }
        }

        if ($null -ne $this.CallbackConfiguration)
        {
            $instanceParams.Add('callbackConfiguration', @{
                    '@odata.type'   = '#microsoft.graph.identityGovernance.customTaskExtensionCallbackConfiguration'
                    timeoutDuration = $this.CallbackConfiguration.timeoutDuration
                })

            if ($null -ne $this.CallbackConfiguration.AuthorizedApps)
            {
                $appsValue = @()
                foreach ($app in $this.CallbackConfiguration.AuthorizedApps)
                {
                    $appInfo = Get-MgApplication -Filter "DisplayName eq '$($app -replace "'", "''")'" -ErrorAction SilentlyContinue
                    $currentApp = @{
                        '@odata.type' = 'microsoft.graph.application'
                    }
                    if ($null -ne $appInfo)
                    {
                        $currentApp.Add('id', $appInfo.Id)
                        $appsValue += $currentApp
                    }
                }
                $instanceParams.callbackConfiguration.Add('authorizedApps', $appsValue)
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            try
            {
                Write-Verbose -Message "Creating new Workflow Custom Task Extension with DisplayName {$($this.DisplayName)}"
                New-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -BodyParameter $instanceParams -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Create:')
                    throw $_
                }
            }
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            try
            {
                Write-Verbose -Message "Updating Workflow Custom Task Extension with DisplayName {$($this.DisplayName)}"
                Update-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $currentInstance.Id -BodyParameter $instanceParams -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Update:')
                    throw $_
                }
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            try
            {
                Write-Verbose -Message "Removing Workflow Custom Task Extension {$($this.DisplayName)}"
                Remove-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension -CustomTaskExtensionId $currentInstance.Id `
                    -ErrorAction Stop
            }
            catch
            {
                if ($_.ErrorDetails.Message -like '*Insufficient license *')
                {
                    Write-Warning -Message ' Insufficient license. You need the Entra ID Governance license.'
                }
                else
                {
                    $this.LogError($_, 'Error during Create:')
                    throw $_
                }
            }
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

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-MgBetaIdentityGovernanceLifecycleWorkflowCustomTaskExtension `
                -All `
                -Filter $this.Filter `
                -ErrorAction Stop

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

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName           = $config.DisplayName
                    Id                    = $config.Id
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                if ($null -ne $Results.EndpointConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.EndpointConfiguration `
                        -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.EndpointConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EndpointConfiguration') | Out-Null
                    }
                }

                if ($null -ne $Results.ClientConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ClientConfiguration `
                        -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ClientConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ClientConfiguration') | Out-Null
                    }
                }

                if ($null -ne $Results.CallbackConfiguration)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.CallbackConfiguration `
                        -CIMInstanceName 'AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.CallbackConfiguration = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CallbackConfiguration') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('EndpointConfiguration', 'ClientConfiguration', 'CallbackConfiguration')

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
            if ($_.ErrorDetails.Message -like 'Insufficient license *')
            {
                Write-M365DSCHost -Message "`r`n    " -DeferWrite
                Write-M365DSCHost -Message $Global:M365DSCEmojiYellowCircle -DeferWrite
                Write-M365DSCHost -Message ' Insufficient license. You need the Entra ID Governance license.' -CommitWrite
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension])
        {
            return $Values
        }

        $result = [AADIdentityGovernanceLifecycleWorkflowCustomTaskExtension]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionClientConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The max duration in milliseconds that Microsoft Entra ID waits for a response from the external app before it shuts down the connection. The valid range is between 200 and 2000 milliseconds. Default duration is 1000.')]
    [System.Nullable[System.UInt32]] $timeoutInMilliseconds

    [DscProperty()]
    [System.ComponentModel.Description('The max number of retries that Microsoft Entra ID makes to the external API. Values of 0 or 1 are supported. If null, the default for the service applies.')]
    [System.Nullable[System.UInt32]] $maximumRetries
}

class MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionEndpointConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('The name of the logic app.')]
    [System.String] $logicAppWorkflowName

    [DscProperty()]
    [System.ComponentModel.Description('The Azure resource group name for the logic app.')]
    [System.String] $resourceGroupName

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the Azure subscription for the logic app.')]
    [System.String] $subscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('Url of the logic app.')]
    [System.String] $url
}

class MSFT_AADIdentityGovernanceLifecycleWorkflowCustomTaskExtensionCallbackConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Callback time out in ISO 8601 time duration. Accepted time durations are between five minutes to three hours. For example, PT5M for five minutes and PT3H for three hours. Inherited from customExtensionCallbackConfiguration.')]
    [System.String] $timeoutDuration

    [DscProperty()]
    [System.ComponentModel.Description('List of apps names that are allowed to resume a task processing result.')]
    [System.String[]] $authorizedApps
}
