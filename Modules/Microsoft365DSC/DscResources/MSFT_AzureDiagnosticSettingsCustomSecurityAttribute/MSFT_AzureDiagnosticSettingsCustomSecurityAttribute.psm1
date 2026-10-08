using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureDiagnosticSettingsCustomSecurityAttribute : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Diagnostic setting name.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('List of log categories.')]
    [MSFT_AzureDiagnosticSettingsCustomSecurityAttributeCategory[]] $Categories

    [DscProperty()]
    [System.ComponentModel.Description('Storage account id.')]
    [System.String] $StorageAccountId

    [DscProperty()]
    [System.ComponentModel.Description('Service bus id.')]
    [System.String] $ServiceBusRuleId

    [DscProperty()]
    [System.ComponentModel.Description('Event hub id.')]
    [System.String] $EventHubAuthorizationRuleId

    [DscProperty()]
    [System.ComponentModel.Description('Event hub name.')]
    [System.String] $EventHubName

    [DscProperty()]
    [System.ComponentModel.Description('Workspace id.')]
    [System.String] $WorkspaceId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Absent', 'Present')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Azure subscription to connect to if the access is restricted on subscription level.')]
    [System.String] $SubscriptionId

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

    [AzureDiagnosticSettingsCustomSecurityAttribute] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureDiagnosticSettingsCustomSecurityAttribute]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Azure Diagnostic Settings Custom Security Attribute for Name $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $response = Invoke-AzRestMethod -Uri "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/microsoft.AadCustomSecurityAttributesDiagnosticSettings/diagnosticsettings?api-version=2017-04-01-preview" `
                    -Method Get
                $instances = (ConvertFrom-Json $response.Content).value
                $instance = $instances | Where-Object -FilterScript { $_.name -eq $this.Name }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $CategoriesValue = @()
            foreach ($category in $instance.properties.logs)
            {
                $CategoriesValue += @{
                    category = $category.category
                    enabled  = $category.enabled
                }
            }

            $results = @{
                Name                        = $instance.Name
                StorageAccountId            = $instance.properties.storageAccountId
                ServiceBusRuleId            = $instance.properties.serviceBusRuleId
                EventHubAuthorizationRuleId = $instance.properties.eventHubAuthorizationRuleId
                EventHubName                = $instance.properties.eventHubName
                WorkspaceId                 = $instance.properties.workspaceId
                Categories                  = $CategoriesValue
                Ensure                      = 'Present'
                SubscriptionId              = $this.SubscriptionId
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

        Write-Verbose -Message "Setting configuration for Azure Diagnostic Settings Custom Security Attribute for Name $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $instanceParams = @{
            name       = $this.Name
            properties = @{
                logs = @()
            }
        }

        foreach ($category in $this.Categories)
        {
            $instanceParams.properties.logs += @{
                category = $category.category
                enabled  = $category.enabled
            }
        }

        if (-not [System.String]::IsNullOrEmpty($this.StorageAccountId))
        {
            $instanceParams.properties.Add('storageAccountId', $this.StorageAccountId)
        }
        if (-not [System.String]::IsNullOrEmpty($this.WorkspaceId))
        {
            $instanceParams.properties.Add('workspaceId', $this.WorkspaceId)
        }
        if (-not [System.String]::IsNullOrEmpty($this.ServiceBusRuleId))
        {
            $instanceParams.properties.Add('eventHubName', $this.EventHubName)
        }
        if (-not [System.String]::IsNullOrEmpty($this.EventHubName))
        {
            $instanceParams.properties.Add('workspaceId', $this.WorkspaceId)
        }
        if (-not [System.String]::IsNullOrEmpty($this.EventHubAuthorizationRuleId))
        {
            $instanceParams.properties.Add('eventHubAuthorizationRuleId', $this.EventHubAuthorizationRuleId)
        }
        $payload = ConvertTo-Json $instanceParams -Depth 10 -Compress

        # CREATE/UPDATE
        if ($this.Ensure -eq 'Present')
        {
            if ($currentInstance.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new diagnostic setting {$($this.Name)}"
            }
            else
            {
                Write-Verbose -Message "Updating diagnostic setting {$($this.Name)}"
            }
            $response = Invoke-AzRestMethod -Uri "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/microsoft.AadCustomSecurityAttributesDiagnosticSettings/diagnosticsettings/$($this.Name)?api-version=2017-04-01-preview" `
                -Method PUT `
                -Payload $payload
            Write-Verbose -Message "RESPONSE: $($response.Content)"
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing diagnostic setting {$($this.Name)}"
            $response = Invoke-AzRestMethod -Uri "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/microsoft.AadCustomSecurityAttributesDiagnosticSettings/diagnosticsettings/$($this.Name)?api-version=2017-04-01-preview" `
                -Method DELETE
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
            $response = Invoke-AzRestMethod -Uri "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/microsoft.AadCustomSecurityAttributesDiagnosticSettings/diagnosticsettings?api-version=2017-04-01-preview" `
                -Method Get
            [array] $exportedInstances = (ConvertFrom-Json $response.Content).value
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

                $displayedKey = $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Name                  = $config.Name
                    SubscriptionId        = $this.SubscriptionId
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                if ($Results.Categories)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Categories -CIMInstanceName AzureDiagnosticSettingsCustomSecurityAttributeCategory
                    if ($complexTypeStringResult)
                    {
                        $Results.Categories = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Categories') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Categories')
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
            ExcludedProperties = @('SubscriptionId')
        }
    }

    hidden [AzureDiagnosticSettingsCustomSecurityAttribute] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureDiagnosticSettingsCustomSecurityAttribute])
        {
            return $Values
        }

        $result = [AzureDiagnosticSettingsCustomSecurityAttribute]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AzureDiagnosticSettingsCustomSecurityAttributeCategory
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name of the category.')]
    [System.String] $Category

    [DscProperty()]
    [System.ComponentModel.Description('Is the log category enabled or not.')]
    [System.Nullable[System.Boolean]] $enabled
}
