using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureBillingAccountsAssociatedTenant : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The ID that uniquely identifies a tenant.')]
    [System.String] $AssociatedTenantId

    [DscProperty()]
    [System.ComponentModel.Description('The name of the associated tenant.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Name of the billing account.')]
    [System.String] $BillingAccount

    [DscProperty()]
    [System.ComponentModel.Description('The state determines whether users from the associated tenant can be assigned roles for commerce activities like viewing and downloading invoices, managing payments, and making purchases.')]
    [System.String] $BillingManagementState

    [DscProperty()]
    [System.ComponentModel.Description('The state determines whether subscriptions and licenses can be provisioned in the associated tenant. It can be set to ''Pending'' to initiate a billing request.')]
    [System.String] $ProvisioningManagementState

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

    [AzureBillingAccountsAssociatedTenant] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureBillingAccountsAssociatedTenant]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Azure Billing Accounts Associated Tenant for Billing Account {$($this.BillingAccount)} and Display Name {$($this.DisplayName)}"

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

            $accounts = Get-M365DSCAzureBillingAccount
            $currentAccount = $accounts.value | Where-Object -FilterScript { $_.properties.displayName -eq $this.BillingAccount }

            if ($null -ne $currentAccount)
            {
                $instances = Get-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId $currentAccount.Name -ErrorAction Stop
                $instance = $instances.value | Where-Object -FilterScript { $_.properties.displayName -eq $this.DisplayName }
            }
            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $results = @{
                BillingAccount              = $this.BillingAccount
                DisplayName                 = $this.DisplayName
                AssociatedTenantId          = $instance.properties.tenantId
                BillingManagementState      = $instance.properties.billingManagementState
                ProvisioningManagementState = $instance.properties.provisioningManagementState
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

        Write-Verbose -Message "Setting configuration for Azure Billing Accounts Associated Tenant for Billing Account {$($this.BillingAccount)} and Display Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $billingAccounts = Get-M365DSCAzureBillingAccount
        $account = $billingAccounts.value | Where-Object -FilterScript { $_.properties.displayName -eq $this.BillingAccount }

        $instanceParams = @{
            properties = @{
                displayName                 = $this.DisplayName
                tenantId                    = $this.AssociatedTenantId
                billingManagementState      = $this.BillingManagementState
                provisioningManagementState = $this.ProvisioningManagementState
            }
        }
        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Adding associated tenant {$($this.AssociatedTenantId)}"
            New-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId $account.Name `
                -AssociatedTenantId $this.AssociatedTenantId `
                -Body $instanceParams
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating associated tenant {$($this.AssociatedTenantId)}"
            New-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId $account.Name `
                -AssociatedTenantId $this.AssociatedTenantId `
                -Body $instanceParams
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing associated tenant {$($this.AssociatedTenantId)}"
            Remove-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId $account.Name `
                -AssociatedTenantId $this.AssociatedTenantId
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
            #Get all billing account
            [array]$accounts = Get-M365DSCAzureBillingAccount

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Count -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $accounts.value)
            {
                $displayedKey = $config.properties.displayName
                Write-M365DSCHost -Message "    |---[$i/$($accounts.Count)] $displayedKey"

                [array]$associatedTenants = Get-M365DSCAzureBillingAccountsAssociatedTenant -BillingAccountId $config.name

                $j = 1
                foreach ($associatedTenant in $associatedTenants.value)
                {
                    if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                    {
                        $Global:M365DSCExportResourceInstancesCount++
                    }
                    Write-M365DSCHost -Message "        |---[$j/$($associatedTenants.value.Length)] $($associatedTenant.properties.DisplayName)" -DeferWrite
                    $params = @{
                        BillingAccount        = $config.properties.displayName
                        DisplayName           = $associatedTenant.properties.displayName
                        AssociatedTenantId    = $associatedTenant.properties.tenantId
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('SubscriptionId')
        }
    }

    hidden [AzureBillingAccountsAssociatedTenant] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureBillingAccountsAssociatedTenant])
        {
            return $Values
        }

        $result = [AzureBillingAccountsAssociatedTenant]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
