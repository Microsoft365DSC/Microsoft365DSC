using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADVerifiedIdAuthority : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Name of the Verified ID Authority.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Verified ID Authority.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('URL of the linked domain.')]
    [System.String] $LinkedDomainUrl

    [DscProperty()]
    [System.ComponentModel.Description('DID method used by the Verified ID Authority.')]
    [System.String] $DidMethod

    [DscProperty()]
    [System.ComponentModel.Description('Key Vault metadata for the Verified ID Authority.')]
    [MSFT_AADVerifiedIdAuthorityKeyVaultMetadata] $KeyVaultMetadata

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

    [AADVerifiedIdAuthority] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADVerifiedIdAuthority]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the AAD VerifiedId Authority with LinkedDomainUrl {$($this.LinkedDomainUrl)}"

        try
        {
            $null = $this.Connect('AdminAPI')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                $instances = $this.ResourceCache['exportedInstances']
            }
            else
            {
                $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
                $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
                $instances = $response.value
            }
            if ($null -eq $instances)
            {
                return $this.AsResult($nullResult)
            }

            $instance = $this.GetVerifiedIdAuthorityObject(($instances | Where-Object -FilterScript { $_.didModel.linkedDomainUrls[0] -eq $this.LinkedDomainUrl }))
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                Id                    = $instance.Id
                Name                  = $instance.Name
                LinkedDomainUrl       = $instance.LinkedDomainUrl
                DidMethod             = $instance.DidMethod
                KeyVaultMetadata      = $instance.KeyVaultMetadata
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                CertificateThumbprint = $this.CertificateThumbprint
                ApplicationSecret     = $this.ApplicationSecret
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

        Write-Verbose -Message "Retrieved current instance: $($currentInstance.Name) with Id $($currentInstance.Id)"

        $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities/' + $currentInstance.Id

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an VerifiedId Authority with Name {$($this.Name)} and Id $($currentInstance.Id)"

            $body = @{
                name             = $this.Name
                linkedDomainUrl  = $this.LinkedDomainUrl
                didMethod        = $this.DidMethod
                keyVaultMetadata = @{
                    subscriptionId = $this.KeyVaultMetadata.SubscriptionId
                    resourceGroup  = $this.KeyVaultMetadata.ResourceGroup
                    resourceName   = $this.KeyVaultMetadata.ResourceName
                    resourceUrl    = $this.KeyVaultMetadata.ResourceUrl
                }
            }
            Write-Verbose -Message "Creating VerifiedId Authority with body $($body | ConvertTo-Json -Depth 5)"

            $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
            $null = $this.InvokeVerifiedIdWebRequest($uri, 'POST', $body)
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating an VerifiedId Authority with Name {$($this.Name)} and Id $($currentInstance.Id)"

            Write-Warning -Message 'You can only update Name of the VerifiedId Authority, if you want to update other properties, please delete and recreate the VerifiedId Authority.'
            $body = @{
                name = $this.Name
            }
            $null = $this.InvokeVerifiedIdWebRequest($uri, 'PATCH', $body)
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing VerifiedId Authority with Name {$($this.Name)} and Id $($currentInstance.Id)"

            $uri = 'https://verifiedid.did.msidentity.com/beta/verifiableCredentials/authorities/' + $currentInstance.Id
            $null = $this.InvokeVerifiedIdWebRequest($uri, 'DELETE')
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

        $ConnectionMode = $this.Connect('AdminAPI')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1
        Write-M365DSCHost -Message "`r`n" -DeferWrite
        try
        {
            $this.ResourceCache['ExportMode'] = $true
            $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
            $response = $this.InvokeVerifiedIdWebRequest($uri, 'GET')
            [array] $this.ResourceCache['exportedInstances'] = $response.value

            foreach ($authority in $this.ResourceCache['exportedInstances'])
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $($authority.didModel.linkedDomainUrls[0])" -DeferWrite
                $Params = @{
                    LinkedDomainUrl       = $authority.didModel.linkedDomainUrls[0]
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
                if ($Results.Ensure -eq 'Present')
                {

                    if ($null -ne $Results.KeyVaultMetadata)
                    {
                        $complexMapping = @(
                            @{
                                Name            = 'KeyVaultMetadata'
                                CimInstanceName = 'AADVerifiedIdAuthorityKeyVaultMetadata'
                                IsRequired      = $False
                            }
                        )
                        $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                            -ComplexObject $Results.KeyVaultMetadata `
                            -CIMInstanceName 'AADVerifiedIdAuthorityKeyVaultMetadata' `
                            -ComplexTypeMapping $complexMapping

                        if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                        {
                            $Results.KeyVaultMetadata = $complexTypeStringResult
                        }
                        else
                        {
                            $Results.Remove('KeyVaultMetadata') | Out-Null
                        }
                    }

                    $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                        -ConnectionMode $ConnectionMode `
                        -ModulePath $this.GetModulePath() `
                        -Results $Results `
                        -Credential $this.Credential `
                        -NoEscape @('KeyVaultMetadata')

                    [void]$dscContent.Append($currentDSCBlock)
                    Save-M365DSCPartialExport -Content $currentDSCBlock `
                        -FileName $Global:PartialExportFileName
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    $i++
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

    hidden [System.Collections.Hashtable] GetVerifiedIdAuthorityObject([System.Object] $Authority)
    {
        if ($null -eq $Authority)
        {
            return $null
        }

        Write-Verbose -Message "Retrieving values for authority {$($Authority.didModel.linkedDomainUrls[0])}"
        $did = ($Authority.didModel.did -split ':')[1]
        $values = @{
            Id              = $Authority.Id
            Name            = $Authority.Name
            LinkedDomainUrl = $Authority.didModel.linkedDomainUrls[0]
            DidMethod       = $did
        }
        if ($null -ne $Authority.KeyVaultMetadata)
        {
            $keyVaultMetadataValue = @{
                SubscriptionId = $Authority.KeyVaultMetadata.SubscriptionId
                ResourceGroup  = $Authority.KeyVaultMetadata.ResourceGroup
                ResourceName   = $Authority.KeyVaultMetadata.ResourceName
                ResourceUrl    = $Authority.KeyVaultMetadata.ResourceUrl
            }

            $values.Add('KeyVaultMetadata', $keyVaultMetadataValue)
        }
        return $values
    }

    hidden [System.Object] InvokeVerifiedIdWebRequest([System.String] $Uri, [System.String] $Method)
    {
        return $this.InvokeVerifiedIdWebRequest($Uri, $Method, $null)
    }

    hidden [System.Object] InvokeVerifiedIdWebRequest([System.String] $Uri, [System.String] $Method, [System.Collections.Hashtable] $Body)
    {
        $headers = @{
            Authorization  = (Get-MSCloudLoginConnectionProfile -Workload AdminAPI).AccessToken
            'Content-Type' = 'application/json'
        }

        if ($Method -eq 'PATCH' -or $Method -eq 'POST')
        {
            $BodyJson = $Body | ConvertTo-Json
            $response = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers -Body $BodyJson -UseBasicParsing
        }
        else
        {
            $response = Invoke-WebRequest -Method $Method -Uri $Uri -Headers $headers -UseBasicParsing
        }

        if ($Method -eq 'DELETE')
        {
            return $null
        }
        $result = ConvertFrom-Json $response.Content
        return $result
    }

    hidden [AADVerifiedIdAuthority] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADVerifiedIdAuthority])
        {
            return $Values
        }

        $result = [AADVerifiedIdAuthority]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADVerifiedIdAuthorityKeyVaultMetadata
{
    [DscProperty()]
    [System.ComponentModel.Description('Subscription ID of the Key Vault.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('Resource group of the Key Vault.')]
    [System.String] $ResourceGroup

    [DscProperty()]
    [System.ComponentModel.Description('Resource name of the Key Vault.')]
    [System.String] $ResourceName

    [DscProperty()]
    [System.ComponentModel.Description('Resource URL of the Key Vault.')]
    [System.String] $ResourceUrl
}
