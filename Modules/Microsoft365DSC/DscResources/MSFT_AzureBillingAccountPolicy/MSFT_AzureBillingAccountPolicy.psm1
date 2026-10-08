using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AzureBillingAccountPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Unique identifier of the associated billing account.')]
    [System.String] $BillingAccount

    [DscProperty()]
    [System.ComponentModel.Description('Name of the policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The policies for Enterprise Agreement enrollments.')]
    [MSFT_AzureBillingAccountPolicyEnterpriseAgreementPolicy] $EnterpriseAgreementPolicies

    [DscProperty()]
    [System.ComponentModel.Description('The policy that controls whether Azure marketplace purchases are allowed.')]
    [System.String] $MarketplacePurchases

    [DscProperty()]
    [System.ComponentModel.Description('The policy that controls whether Azure reservation purchases are allowed.')]
    [System.String] $ReservationPurchases

    [DscProperty()]
    [System.ComponentModel.Description('The policy that controls whether users with Azure savings plan purchase are allowed.')]
    [System.String] $SavingsPlanPurchases

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

    [AzureBillingAccountPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AzureBillingAccountPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Azure Billing Account Policy for Billing Account $($this.BillingAccount)"

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

            $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($this.BillingAccount)/policies/default?api-version=2024-04-01"
            $response = Invoke-AzRestMethod -Uri $uri -Method GET
            $instance = (ConvertFrom-Json ($response.Content)).value

            if ($null -eq $instance)
            {
                return $this.AsResult($nullResult)
            }

            $EnterpriseAgreementPoliciesValue = $null
            if ($null -ne $this.EnterpriseAgreementPolicies)
            {
                $EnterpriseAgreementPoliciesValue = @{
                    accountOwnerViewCharges    = $instance.properties.enterpriseAgreementPolicies.accountOwnerViewCharges
                    authenticationType         = $instance.properties.enterpriseAgreementPolicies.authenticationType
                    departmentAdminViewCharges = $instance.properties.enterpriseAgreementPolicies.departmentAdminViewCharges
                }
            }

            $results = @{
                BillingAccount              = $this.BillingAccount
                Name                        = $instance.name
                EnterpriseAgreementPolicies = $EnterpriseAgreementPoliciesValue
                MarketplacePurchases        = $instance.properties.marketplacePurchases
                ReservationPurchases        = $instance.properties.reservationPurchases
                SavingsPlanPurchases        = $instance.properties.savingsPlanPurchases
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

        Write-Verbose -Message "Setting configuration of Azure Billing Account Policy for Billing Account $($this.BillingAccount)"

        $null = $this.Connect('Azure')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $instanceParams = @{
            properties = @{
                enterpriseAgreementPolicies = @{
                    accountOwnerViewCharges    = $this.EnterpriseAgreementPolicies.accountOwnerViewCharges
                    authenticationType         = $this.EnterpriseAgreementPolicies.authenticationType
                    departmentAdminViewCharges = $this.EnterpriseAgreementPolicies.departmentAdminViewCharges
                }
                marketplacePurchases        = $this.MarketplacePurchases
                reservationPurchases        = $this.ReservationPurchases
                savingsPlanPurchases        = $this.SavingsPlanPurchases
            }
        }
        $payload = ConvertTo-Json $instanceParams -Depth 5 -Compress
        Write-Verbose -Message "Updating billing account policy for {$($this.BillingAccount)} with payload:`r`n$($payload)"
        $uri = "$((Get-MSCloudLoginConnectionProfile -Workload Azure).ManagementUrl)providers/Microsoft.Billing/billingAccounts/$($this.BillingAccount)/policies/default?api-version=2024-04-01"
        $response = Invoke-AzRestMethod -Uri $uri -Method 'PUT' -Payload $payload
        if (-not [System.String]::IsNullOrEmpty($response.Error))
        {
            throw "Error: $($response.Error)"
        }
        Write-Verbose -Message "Response:`r`n$($response.Content)"
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
            # Get all billing account
            $accounts = Get-M365DSCAzureBillingAccount

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($accounts.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($account in $accounts.value)
            {
                $displayedKey = $account.properties.displayName
                Write-M365DSCHost -Message "    |---[$i/$($accounts.value.Length)] $displayedKey" -DeferWrite

                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }
                $params = @{
                    BillingAccount        = $account.name
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

                if ($Results.EnterpriseAgreementPolicies)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.EnterpriseAgreementPolicies -CIMInstanceName AzureBillingAccountPolicyEnterpriseAgreementPolicy
                    if ($complexTypeStringResult)
                    {
                        $Results.EnterpriseAgreementPolicies = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('EnterpriseAgreementPolicies') | Out-Null
                    }
                }
                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('EnterpriseAgreementPolicies')

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

    hidden [AzureBillingAccountPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AzureBillingAccountPolicy])
        {
            return $Values
        }

        $result = [AzureBillingAccountPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AzureBillingAccountPolicyEnterpriseAgreementPolicy
{
    [DscProperty()]
    [System.ComponentModel.Description('The policy that controls whether account owner can view charges.')]
    [System.String] $accountOwnerViewCharges

    [DscProperty()]
    [System.ComponentModel.Description('The state showing the enrollment auth level.')]
    [System.String] $authenticationType

    [DscProperty()]
    [System.ComponentModel.Description('The policy that controls whether department admin can view charges.')]
    [System.String] $departmentAdminViewCharges
}
