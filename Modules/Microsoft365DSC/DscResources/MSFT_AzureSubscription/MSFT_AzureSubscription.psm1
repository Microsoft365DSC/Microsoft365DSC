using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureSubscription : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the subscription.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the subscription.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the invoice section associated with the subscription.')]
    [System.String] $InvoiceSectionId

    [DscProperty()]
    [System.ComponentModel.Description('Status of the subscription.')]
    [System.String] $Status

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
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

    [AzureSubscription] Get()
    {
        $instance = $null
        $Name = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureSubscription]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Azure Subscription with Name $Name"

        try
        {
            if ($null -eq $this.ResourceCache['exportedInstances'] -or -not $this.ResourceCache['ExportMode'])
            {
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.InvoiceSectionId.Trim('/'))/billingSubscriptions/$($this.Id)?api-version=2024-04-01"
                    $response = Invoke-AzRestMethod -Uri $uri -Method Get
                    $instance = (ConvertFrom-Json $response.Content).value
                }
                elseif ($null -eq $instance -and -not [System.String]::IsNullOrEmpty($this.DisplayName))
                {
                    $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)$($this.InvoiceSectionId.Trim('/'))/billingSubscriptions?api-version=2024-04-01"
                    $response = Invoke-AzRestMethod -Uri $uri -Method Get
                    $instances = (ConvertFrom-Json $response.Content).value
                    $instance = $instances | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName }
                }

                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.Name -eq $this.Id }
                }
                elseif ($null -eq $instance -and -not [System.String]::IsNullOrEmpty($Name))
                {
                    $instance = $this.ResourceCache['exportedInstances'] | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName -and `
                            $_.properties.invoiceSectionId -eq $this.InvoiceSectionId }
                }
            }

            $results = @{
                DisplayName           = $instance.properties.displayName
                Id                    = $instance.name
                InvoiceSectionId      = $instance.properties.invoiceSectionId
                Status                = $instance.properties.status
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
        $Enabled = $null
        $Name = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Azure Subscription with Name $($this.DisplayName)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Subscription/aliases/$((New-Guid).ToString())?api-version=2021-10-01"
            $params = @{
                properties = @{
                    billingScope = $this.InvoiceSectionId
                    DisplayName  = $this.DisplayName
                    Workload     = 'Production'
                }
            }
            $payload = ConvertTo-Json $params -Depth 10 -Compress
            Write-Verbose -Message "Creating new subscription {$($this.DisplayName)} with payload:`r`n$payload"
            $response = Invoke-AzRestMethod -Uri $uri -Method PUT -Payload $payload
            Write-Verbose -Message "Result: $($response.Content)"
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            if ($this.Status -eq 'Active')
            {
                Write-Verbose -Message "Enabling subscription {$Name}"
                Enable-AzSubscription -Id $currentInstance.Id | Out-Null
            }
            elseif (-not $Enabled)
            {
                Write-Verbose -Message "Disabling subscription {$Name}"
                Disable-AzSubscription -Id $currentInstance.Id | Out-Null
            }
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Deleting subscription {$Name}"
            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)subscriptions/$($currentInstance.Id)/providers/Microsoft.Subscription/cancel?api-version=2019-03-01-preview&ImmediateDelete=true"
            $response = Invoke-AzRestMethod -Uri $uri -Method POST
            Write-Verbose -Message "Response:`r`n$($response.Content)"
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $dscContent = $null
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

            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingaccounts/?api-version=2020-05-01"
            $response = Invoke-AzRestMethod -Uri $uri -Method Get
            $billingAccounts = (ConvertFrom-Json $response.Content).value

            if ($billingAccounts.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }

            foreach ($billingAccount in $billingAccounts)
            {
                $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingaccounts/$($billingAccount.Name)/billingprofiles/?api-version=2020-05-01"
                $response = Invoke-AzRestMethod -Uri $uri -Method Get
                $billingProfiles = (ConvertFrom-Json $response.Content).value

                foreach ($billingProfile in $billingProfiles)
                {
                    $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($billingAccount.name)/billingProfiles/$($billingProfile.name)/billingSubscriptions?api-version=2024-04-01"
                    $response = Invoke-AzRestMethod -Uri $uri -Method Get
                    $subscriptions = (ConvertFrom-Json $response.Content).value
                    [array] $this.ResourceCache['exportedInstances'] += $subscriptions

                    $i = 1
                    $dscContent = [System.Text.StringBuilder]::new()
                    if ($this.ResourceCache['exportedInstances'].Length -eq 0)
                    {
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
                    else
                    {
                        Write-M365DSCHost -Message "`r`n" -DeferWrite
                    }
                    foreach ($config in $subscriptions)
                    {
                        if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                        {
                            $Global:M365DSCExportResourceInstancesCount++
                        }
                        $displayedKey = $config.properties.displayName
                        Write-M365DSCHost -Message "    |---[$i/$($subscriptions.Count)] $displayedKey" -DeferWrite
                        $params = @{
                            DisplayName           = $config.properties.displayName
                            Id                    = $config.Name
                            InvoiceSectionId      = $config.properties.invoiceSectionId
                            Credential            = $this.Credential
                            ApplicationId         = $this.ApplicationId
                            TenantId              = $this.TenantId
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
                        $i++
                        Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                    }
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

    hidden [AzureSubscription] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureSubscription])
        {
            return $Values
        }

        $result = [AzureSubscription]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
