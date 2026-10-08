using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAzureNetworkConnectionWindows365 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The fully qualified domain name (FQDN) of the Active Directory domain you want to join. Optional.')]
    [System.String] $AdDomainName

    [DscProperty()]
    [System.ComponentModel.Description('The password associated with adDomainUsername. Cannot be exported and must be manually added before deploying the network connection.')]
    [System.String] $AdDomainPassword

    [DscProperty()]
    [System.ComponentModel.Description('The username of an Active Directory account (user or service account) that has permissions to create computer objects in Active Directory. Required format: admincontoso.com. Optional.')]
    [System.String] $AdDomainUsername

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the method by which a provisioned Cloud PC is joined to Microsoft Entra. The azureADJoin option indicates the absence of an on-premises Active Directory (AD) in the current tenant that results in the Cloud PC device only joining to Microsoft Entra. The hybridAzureADJoin option indicates the presence of an on-premises AD in the current tenant and that the Cloud PC joins both the on-premises AD and Microsoft Entra. The selected option also determines the types of users who can be assigned and can sign into a Cloud PC. The azureADJoin option allows both cloud-only and hybrid users to be assigned and sign in, whereas hybridAzureADJoin is restricted to hybrid users only. The default value is hybridAzureADJoin. The possible values are: hybridAzureADJoin, azureADJoin.')]
    [ValidateSet('hybridAzureADJoin', 'azureADJoin')]
    [System.String] $ConnectionType

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name for the Azure network connection.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The organizational unit (OU) in which the computer account is created. If left null, the OU configured as the default (a well-known computer object container) in your Active Directory domain (OU) is used. Optional. Only applicable for the connection type ''hybridAzureADJoin''.')]
    [System.String] $OrganizationalUnit

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The ID of the target resource group. Required format: /subscriptions/{subscription-id}/resourceGroups/{resourceGroupName}.')]
    [System.String] $ResourceGroupId

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $ScopeIds

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The ID of the target subnet. Required format: /subscriptions/{subscription-id}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkId}/subnets/{subnetName}.')]
    [System.String] $SubnetId

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The name of the target Azure subscription.')]
    [System.String] $SubscriptionName

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The ID of the target virtual network. Required format: /subscriptions/{subscription-id}/{resourceGroups/resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}.')]
    [System.String] $VirtualNetworkId

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [IntuneAzureNetworkConnectionWindows365] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAzureNetworkConnectionWindows365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Azure Network Connection for Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null

                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -CloudPcOnPremisesConnectionId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Azure Network Connection for Windows365 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Azure Network Connection for Windows365 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Azure Network Connection for Windows365 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $enumConnectionType = $null
            if ($null -ne $getValue.ConnectionType)
            {
                $enumConnectionType = $getValue.ConnectionType
            }
            #endregion

            $results = @{
                #region resource generator code
                AdDomainName          = $getValue.AdDomainName
                AdDomainUsername      = $getValue.AdDomainUsername
                ConnectionType        = $enumConnectionType
                DisplayName           = $getValue.DisplayName
                OrganizationalUnit    = $getValue.OrganizationalUnit
                ResourceGroupId       = $getValue.ResourceGroupId.Replace("/subscriptions/$($getValue.SubscriptionId)/", "/subscriptions/$($getValue.SubscriptionName)/")
                ScopeIds              = $getValue.ScopeIds
                SubnetId              = $getValue.SubnetId.Replace("/subscriptions/$($getValue.SubscriptionId)/", "/subscriptions/$($getValue.SubscriptionName)/")
                SubscriptionName      = $getValue.SubscriptionName
                VirtualNetworkId      = $getValue.VirtualNetworkId.Replace("/subscriptions/$($getValue.SubscriptionId)/", "/subscriptions/$($getValue.SubscriptionName)/")
                Id                    = $getValue.Id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }

            if ($enumConnectionType -eq 'azureADJoin')
            {
                $results.Remove('AdDomainName')
                $results.Remove('AdDomainUsername')
                $results.Remove('OrganizationalUnit')
            }

            return $this.AsResult([System.Collections.Hashtable] $results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            throw
        }
    }

    [void] Set()
    {
        $Type = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Azure Network Connection for Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        if ($Type -eq 'hybridAzureADJoin' -and ($this.GetBoundParameters().ContainsKey('AdDomainName') -or $this.GetBoundParameters().ContainsKey('AdDomainPassword') -or $this.GetBoundParameters().ContainsKey('AdDomainUsername')))
        {
            throw 'AdDomainName, AdDomainPassword and AdDomainUsername are required for hybridAzureADJoin'
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $subscription = Get-AzSubscription -SubscriptionName $this.SubscriptionName -ErrorAction SilentlyContinue
        if ($null -eq $subscription)
        {
            throw "Could not find a subscription with name '$($this.SubscriptionName)'. Please verify the SubscriptionName is correct and that the identity has access to it."
        }
        $boundParameters.Remove('SubscriptionName') | Out-Null
        $boundParameters.Add('SubscriptionId', $subscription.Id)
        $boundParameters.ResourceGroupId = $boundParameters.ResourceGroupId.Replace("/subscriptions/$($this.SubscriptionName)/", "/subscriptions/$($subscription.Id)/")
        $boundParameters.SubnetId = $boundParameters.SubnetId.Replace("/subscriptions/$($this.SubscriptionName)/", "/subscriptions/$($subscription.Id)/")
        $boundParameters.VirtualNetworkId = $boundParameters.VirtualNetworkId.Replace("/subscriptions/$($this.SubscriptionName)/", "/subscriptions/$($subscription.Id)/")

        if ($Type -eq 'azureADJoin')
        {
            $boundParameters.Remove('AdDomainName') | Out-Null
            $boundParameters.Remove('AdDomainPassword') | Out-Null
            $boundParameters.Remove('AdDomainUsername') | Out-Null
            $boundParameters.Remove('OrganizationalUnit') | Out-Null
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Azure Network Connection for Windows365 with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('ManagedBy', 'windows365')

            #region resource generator code
            $null = New-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Azure Network Connection for Windows365 with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            try
            {
                Update-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection `
                    -CloudPcOnPremisesConnectionId $currentInstance.Id `
                    -BodyParameter $updateParameters `
                    -ErrorAction Stop
            }
            catch
            {
                throw "Failed to update the Intune Azure Network Connection for Windows365 with Id {$($currentInstance.Id)}. Please make sure it is not referenced by any Cloud Provisioning Policies or in checking state. Error: $($_.Exception.Message)"
            }

            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Azure Network Connection for Windows365 with Id {$($currentInstance.Id)}"
            #region resource generator code
            try
            {
                Remove-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection -CloudPcOnPremisesConnectionId $currentInstance.Id -ErrorAction Stop
            }
            catch
            {
                throw "Failed to remove the Intune Azure Network Connection for Windows365 with Id {$($currentInstance.Id)}. Please make sure it is not referenced by any Cloud Provisioning Policies or in checking state. Error: $($_.Exception.Message)"
            }
            #endregion
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
        $null = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            #region resource generator code
            [array]$getValue = Get-MgBetaDeviceManagementVirtualEndpointOnPremiseConnection `
                -Filter $this.Filter `
                -All `
                -Top 50 `
                -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    ConnectionType        = $config.ConnectionType
                    ResourceGroupId       = $config.ResourceGroupId
                    SubnetId              = $config.SubnetId
                    SubscriptionName      = $config.SubscriptionName
                    VirtualNetworkId      = $config.VirtualNetworkId
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -RawResults $rawResults
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SubscriptionName', 'AdDomainPassword')
            IncludedProperties = @('ResourceGroupId', 'SubnetId', 'SubscriptionName', 'VirtualNetworkId')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ConnectionType -eq 'azureADJoin')
                {
                    $ValuesToCheck.Remove('AdDomainName') | Out-Null
                    $ValuesToCheck.Remove('AdDomainUsername') | Out-Null
                    $ValuesToCheck.Remove('OrganizationalUnit') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [IntuneAzureNetworkConnectionWindows365] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAzureNetworkConnectionWindows365])
        {
            return $Values
        }

        $result = [IntuneAzureNetworkConnectionWindows365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
