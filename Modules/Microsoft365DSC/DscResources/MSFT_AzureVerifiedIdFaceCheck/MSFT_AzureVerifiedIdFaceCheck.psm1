using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureVerifiedIdFaceCheck : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the Azure subscription.')]
    [System.String] $SubscriptionId

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the associated resource group.')]
    [System.String] $ResourceGroupName

    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the verified ID authority.')]
    [System.String] $VerifiedIdAuthorityId

    [DscProperty()]
    [System.ComponentModel.Description('Represents whether or not FaceCheck is enabled for the authrotiy.')]
    [System.Nullable[System.Boolean]] $FaceCheckEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Location of the Verified ID Authority.')]
    [System.String] $VerifiedIdAuthorityLocation

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

    [AzureVerifiedIdFaceCheck] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureVerifiedIdFaceCheck]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Verified ID Face Check for Verified ID Authority {$($this.VerifiedIdAuthorityId)}"

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

            $resourceGroupInstance = Get-AzResourceGroup -Id "/subscriptions/$($this.SubscriptionId)/resourceGroups/$($this.ResourceGroupName)" -ErrorAction SilentlyContinue
            if ($null -eq $resourceGroupInstance)
            {
                return $this.AsResult($nullResult)
            }

            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($resourceGroupInstance.ResourceId)/providers/Microsoft.VerifiedId/authorities/$($this.VerifiedIdAuthorityId)?api-version=2024-01-26-preview"
            $response = Invoke-AzRestMethod -Uri $uri -Method Get
            $authorities = ConvertFrom-Json $response.Content

            $EnabledValue = $false
            if ($null -eq $authorities.error -and $null -ne $authorities.id)
            {
                $EnabledValue = $true
            }

            $results = @{
                SubscriptionId              = $this.SubscriptionId
                ResourceGroupName           = $this.ResourceGroupName
                VerifiedIdAuthorityId       = $this.VerifiedIdAuthorityId
                VerifiedIdAuthorityLocation = $authorities.location
                FaceCheckEnabled            = $EnabledValue
                Ensure                      = 'Present'
                Credential                  = $this.Credential
                ApplicationId               = $this.ApplicationId
                TenantId                    = $this.TenantId
                CertificateThumbprint       = $this.CertificateThumbprint
                CertificatePath             = $this.CertificatePath
                CertificatePassword         = $this.CertificatePassword
                ManagedIdentity             = $this.ManagedIdentity
                AccessTokens                = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Azure Verified ID Face Check for Verified ID Authority {$($this.VerifiedIdAuthorityId)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('Azure')
        if ($this.FaceCheckEnabled)
        {
            Write-Verbose -Message "Enabling FaceCheck on Verified ID Authority {$($this.VerifiedIDAuthorityId)}"
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)subscriptions/$($this.SubscriptionId)/resourceGroups/$($this.ResourceGroupName)/providers/Microsoft.VerifiedId/authorities/$($this.VerifiedIdAuthorityId)?api-version=2024-01-26-preview"
            $payload = '{"location": "' + $this.VerifiedIdAuthorityLocation + '"}'
            $response = Invoke-AzRestMethod -Uri $uri -Method Put -Payload $payload
        }
        else
        {
            Write-Verbose -Message "Disabling FaceCheck on Verified ID Authority {$($this.VerifiedIDAuthorityId)}"
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)subscriptions/$($this.SubscriptionId)/resourceGroups/$($this.ResourceGroupName)/providers/Microsoft.VerifiedId/authorities/$($this.VerifiedIdAuthorityId)?api-version=2024-01-26-preview"
            $payload = '{"location": null}'
            $response = Invoke-AzRestMethod -Uri $uri -Method DELETE
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
        $ConnectionMode = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $headers = @{
                Authorization = (Get-MSCloudLoginConnectionProfile -Workload AdminAPI).AccessToken
            }
            $uri = 'https://verifiedid.did.msidentity.com/v1.0/verifiableCredentials/authorities'
            $response = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers -UseBasicParsing
            $authorities = ConvertFrom-Json $response.Content

            $resourceGroups = Get-AzResourceGroup -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($resourceGroups.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $j = 1
            foreach ($resourceGroup in $resourceGroups)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                $displayedKey = $resourceGroup.ResourceGroupName
                Write-M365DSCHost -Message "    |---[$j/$($resourceGroups.Length)] $displayedKey" -DeferWrite

                if ($authorities.Length -eq 0)
                {
                    Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                }
                else
                {
                    Write-M365DSCHost -Message "`r`n" -DeferWrite
                }

                $i = 1
                foreach ($authority in $authorities.value)
                {
                    $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($resourceGroup.ResourceId)/providers/Microsoft.VerifiedId/authorities/$($authority.id)?api-version=2024-01-26-preview"
                    $response = Invoke-AzRestMethod -Uri $uri -Method Get

                    $Global:M365DSCExportResourceInstancesCount++

                    $displayedKey = $authority.name
                    Write-M365DSCHost -Message "        |---[$i/$($authorities.value.Length)] $displayedKey" -DeferWrite

                    $resourceIdParts = $resourceGroup.ResourceId.Split('/')

                    $params = @{
                        VerifiedIdAuthorityId = $authority.id
                        SubscriptionId        = $resourceIdParts[2]
                        ResourceGroupName     = $resourceGroup.ResourceGroupName
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
                $j++
            }
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AzureVerifiedIdFaceCheck] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureVerifiedIdFaceCheck])
        {
            return $Values
        }

        $result = [AzureVerifiedIdFaceCheck]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
