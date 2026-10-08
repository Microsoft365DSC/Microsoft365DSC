using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class CommerceSelfServicePurchase : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique ID of the product.')]
    [System.String] $ProductId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the product')]
    [System.String] $ProductName

    [DscProperty()]
    [System.ComponentModel.Description('Can be Enabled or Disabled.')]
    [ValidateSet('Enabled', 'Disabled', 'OnlyTrialsWithoutPaymentMethod')]
    [System.String] $PolicyValue

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

    [CommerceSelfServicePurchase] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [CommerceSelfServicePurchase]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Self Service Purchase Policy for Product {$($this.ProductName)}"

        try
        {
            $null = $this.Connect('Licensing')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'

            if ($null -ne $this.ResourceCache['exportedInstances'] -and $this.ResourceCache['ExportMode'])
            {
                $instance = $this.ResourceCache['exportedInstances'].items | Where-Object -FilterScript { $_.ProductId -eq $this.ProductId }
            }
            else
            {
                $uri = (Get-MSCloudLoginConnectionProfile -Workload 'Licensing').HostUrl + "/v1/policies/AllowSelfServicePurchase/products/$($this.ProductId)"
                $instance = Invoke-M365DSCLicensingWebRequest -Uri $uri -Method 'GET'
            }

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                ProductId             = $instance.ProductId
                ProductName           = $instance.ProductName
                PolicyValue           = $instance.PolicyValue
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
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Self Service Purchase Policy for Product {$($this.ProductName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Absent')
        {
            throw 'Ensure cannot be absent. This resource can only update existing Self Service Purchase Policies.'
        }

        $uri = (Get-MSCloudLoginConnectionProfile -Workload 'Licensing').HostUrl + "/v1/policies/AllowSelfServicePurchase/products/$($this.ProductId)"
        $body = @{
            policyValue = $this.PolicyValue
        }
        Write-Verbose -Message "Updating Policy for {$($this.ProductName)} to value {$($this.PolicyValue)}"
        Invoke-M365DSCLicensingWebRequest -Uri $uri -Method 'PUT' -Body $body | Out-Null
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

        $ConnectionMode = $this.Connect('Licensing')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $this.ResourceCache['ExportMode'] = $true
            $uri = (Get-MSCloudLoginConnectionProfile -Workload 'Licensing').HostUrl + '/v1/policies/AllowSelfServicePurchase/products'
            [array] $this.ResourceCache['exportedInstances'] = Invoke-M365DSCLicensingWebRequest -Uri $uri -Method 'GET'

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
            foreach ($config in $this.ResourceCache['exportedInstances'].items)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.ProductName
                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].items.Count)] $displayedKey" -DeferWrite
                $params = @{
                    ProductId             = $config.productId
                    ProductName           = $config.productName
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

    hidden [CommerceSelfServicePurchase] AsResult([System.Object] $Values)
    {
        if ($Values -is [CommerceSelfServicePurchase])
        {
            return $Values
        }

        $result = [CommerceSelfServicePurchase]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
