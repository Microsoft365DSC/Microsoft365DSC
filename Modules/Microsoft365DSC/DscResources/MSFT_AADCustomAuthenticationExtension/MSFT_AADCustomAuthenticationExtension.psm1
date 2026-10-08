using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCustomAuthenticationExtension : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the custom security attribute. Must be unique within an attribute set. Can be up to 32 characters long and include Unicode characters. Can''t contain spaces or special characters. Can''t be changed later. Case sensitive.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier of the Attribute Definition.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Defines the custom authentication extension type.')]
    [System.String] $CustomAuthenticationExtensionType

    [DscProperty()]
    [System.ComponentModel.Description('Description of the custom security attribute. Can be up to 128 characters long and include Unicode characters. Can''t contain spaces or special characters. Can be changed later. ')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Defines the authentication configuration type')]
    [System.String] $AuthenticationConfigurationType

    [DscProperty()]
    [System.ComponentModel.Description('Defines the authentication configuration resource id')]
    [System.String] $AuthenticationConfigurationResourceId

    [DscProperty()]
    [System.ComponentModel.Description('Defines the client configuration timeout in milliseconds')]
    [System.Nullable[System.UInt32]] $ClientConfigurationTimeoutInMilliseconds

    [DscProperty()]
    [System.ComponentModel.Description('Defines the client configuration max retries')]
    [System.Nullable[System.UInt32]] $ClientConfigurationMaximumRetries

    [DscProperty()]
    [System.ComponentModel.Description('Defines the endpoint configuration')]
    [MSFT_AADCustomAuthenticationExtensionEndPointConfiguration] $EndpointConfiguration

    [DscProperty()]
    [System.ComponentModel.Description('Defines the list of claims for token configurations')]
    [MSFT_AADCustomAuthenticationExtensionClaimForTokenConfiguration[]] $ClaimsForTokenConfiguration

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

    [AADCustomAuthenticationExtension] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCustomAuthenticationExtension]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Custom Authentication Extension for {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'
                Write-Verbose -Message 'Fetching result....'
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = Get-MgBetaIdentityCustomAuthenticationExtension -CustomAuthenticationExtensionId $this.Id `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    $instance = Get-MgBetaIdentityCustomAuthenticationExtension -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -NoPageSize `
                        -ErrorAction SilentlyContinue
                }
                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose 'Instance found for the resource. Calculating result....'

            $results = @{
                DisplayName           = $instance.DisplayName
                Id                    = $instance.Id
                Description           = $instance.Description
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

            if ($null -ne $instance)
            {
                $results.Add('CustomAuthenticationExtensionType', $instance['@odata.type'])
            }

            if ($null -ne $instance.AuthenticationConfiguration)
            {
                $results.Add('AuthenticationConfigurationType', $instance.AuthenticationConfiguration['@odata.type'])
                $results.Add('AuthenticationConfigurationResourceId', $instance.AuthenticationConfiguration['resourceId'])
            }

            if ($null -ne $instance.ClientConfiguration)
            {
                $results.Add('ClientConfigurationTimeoutInMilliseconds', $instance.ClientConfiguration.TimeoutInMilliseconds)
                $results.Add('ClientConfigurationMaximumRetries', $instance.ClientConfiguration.MaximumRetries)
            }

            $endpointConfigurationInstance = @{}
            if ($null -ne $instance.EndPointConfiguration -and $null -ne $instance.EndPointConfiguration)
            {
                $endpointConfigurationInstance.Add('EndpointType', $instance.EndPointConfiguration['@odata.type'])

                if ($endpointConfigurationInstance['EndpointType'] -eq '#microsoft.graph.httpRequestEndpoint')
                {
                    $endpointConfigurationInstance.Add('TargetUrl', $instance.EndPointConfiguration['targetUrl'])
                }

                if ($endpointConfigurationInstance['EndpointType'] -eq '#microsoft.graph.logicAppTriggerEndpointConfiguration')
                {
                    $endpointConfigurationInstance.Add('SubscriptionId', $instance.EndPointConfiguration['subscriptionId'])
                    $endpointConfigurationInstance.Add('ResourceGroupName', $instance.EndPointConfiguration['resourceGroupName'])
                    $endpointConfigurationInstance.Add('LogicAppWorkflowName', $instance.EndPointConfiguration['logicAppWorkflowName'])
                }
            }

            $ClaimsForTokenConfigurationInstance = @()
            if ($null -ne $instance -and $null -ne $instance['claimsForTokenConfiguration'])
            {
                foreach ($claim in $instance['claimsForTokenConfiguration'])
                {
                    $c = @{
                        ClaimIdInApiResponse = $claim.claimIdInApiResponse
                    }

                    $ClaimsForTokenConfigurationInstance += $c
                }
            }

            $results.Add('EndPointConfiguration', $endpointConfigurationInstance)
            $results.Add('ClaimsForTokenConfiguration', $ClaimsForTokenConfigurationInstance)

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

        Write-Verbose -Message "Setting configuration of AzureAD Custom Authentication Extension for {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $params = @{
            '@odata.type'               = $setParameters.CustomAuthenticationExtensionType
            displayName                 = $setParameters.DisplayName
            description                 = $setParameters.Description
            endpointConfiguration       = @{
                '@odata.type' = $setParameters.EndPointConfiguration.EndpointType
            }
            authenticationConfiguration = @{
                '@odata.type' = $setParameters.AuthenticationConfigurationType
                resourceId    = $setParameters.AuthenticationConfigurationResourceId
            }
            clientConfiguration         = @{
                timeoutInMilliseconds = $setParameters['ClientConfigurationTimeoutInMilliseconds']
                maximumRetries        = $setParameters['ClientConfigurationMaximumRetries']
            }
        }

        if ($params.endpointConfiguration['@odata.type'] -eq '#microsoft.graph.httpRequestEndpoint')
        {
            Write-Verbose -Message "{$setParameters.EndPointConfiguration.TargetUrl}"
            $params.endpointConfiguration['targetUrl'] = $setParameters.EndPointConfiguration.TargetUrl
        }

        if ($params.endpointConfiguration['@odata.type'] -eq '#microsoft.graph.logicAppTriggerEndpointConfiguration')
        {
            $params.endpointConfiguration['subscriptionId'] = $setParameters.EndPointConfiguration['SubscriptionId']
            $params.endpointConfiguration['resourceGroupName'] = $setParameters.EndPointConfiguration['ResourceGroupName']
            $params.endpointConfiguration['logicAppWorkflowName'] = $setParameters.EndPointConfiguration['LogicAppWorkflowName']
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $params.Add('claimsForTokenConfiguration', @())
            foreach ($claim in $setParameters.claimsForTokenConfiguration)
            {
                $val = $claim.claimIdInApiResponse
                Write-Verbose -Message "{$val}"
                $c = @{
                    'claimIdInApiResponse' = $claim.claimIdInApiResponse
                }
                $params.claimsForTokenConfiguration += $c
            }

            $params.Remove('Id') | Out-Null
            $type = $params['@odata.type']
            Write-Verbose -Message "Creating new Custom authentication extension with display name {$($this.DisplayName)} and type {$type}"
            New-MgBetaIdentityCustomAuthenticationExtension -BodyParameter $params
        }

        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $params.Remove('Id') | Out-Null

            $params.Add('claimsForTokenConfiguration', @())
            foreach ($claim in $setParameters['ClaimsForTokenConfiguration'])
            {
                $c = @{
                    'claimIdInApiResponse' = $claim.ClaimIdInApiResponse
                }
                $params['claimsForTokenConfiguration'] += $c
            }

            Write-Verbose -Message "Updating custom authentication extension {$($this.DisplayName)} with:`r`n$(ConvertTo-Json $params -Depth 10)"
            Update-MgBetaIdentityCustomAuthenticationExtension -CustomAuthenticationExtensionId $currentInstance.Id -BodyParameter $params
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing custom authentication extension {$($this.DisplayName)}."
            Remove-MgBetaIdentityCustomAuthenticationExtension -CustomAuthenticationExtensionId $currentInstance.Id
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
            [array] $exportedInstances = Get-MgBetaIdentityCustomAuthenticationExtension `
            -All `
            -Filter $this.Filter `
            -NoPageSize `
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

                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
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
                $endpointConfigurationCimString = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.EndpointConfiguration `
                    -CIMInstanceName 'MSFT_AADCustomAuthenticationExtensionEndPointConfiguration'

                $ClaimsForTokenConfigurationCimString = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.ClaimsForTokenConfiguration `
                    -CIMInstanceName 'MSFT_AADCustomAuthenticationExtensionClaimForTokenConfiguration'

                $Results.EndPointConfiguration = $endpointConfigurationCimString
                $Results.ClaimsForTokenConfiguration = $ClaimsForTokenConfigurationCimString

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('EndPointConfiguration', 'ClaimsForTokenConfiguration')

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

    hidden [AADCustomAuthenticationExtension] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCustomAuthenticationExtension])
        {
            return $Values
        }

        $result = [AADCustomAuthenticationExtension]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADCustomAuthenticationExtensionEndPointConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the type of the endpoint configuration')]
    [System.String] $EndpointType

    [DscProperty()]
    [System.ComponentModel.Description('Defines the workflow name for the logic app')]
    [System.String] $LogicAppWorkflowName

    [DscProperty()]
    [System.ComponentModel.Description('Defines the resource group name for the logic app')]
    [System.String] $ResourceGroupName

    [DscProperty()]
    [System.ComponentModel.Description('Defines the subscription id for the logic app')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('Defines the target url for the http endpoint')]
    [System.String] $TargetUrl
}

class MSFT_AADCustomAuthenticationExtensionClaimForTokenConfiguration
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines the claim id in api response.')]
    [System.String] $ClaimIdInApiResponse
}
