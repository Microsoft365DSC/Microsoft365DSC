using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class DefenderSubscriptionPlan : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the subscription.')]
    [System.String] $SubscriptionName

    [DscProperty(Key)]
    [System.ComponentModel.Description('The Defender plan name, for the list all of possible Defender plans refer to Defender for Cloud documentation')]
    [System.String] $PlanName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier of the Azure subscription.')]
    [System.String] $SubscriptionId

    [DscProperty()]
    [System.ComponentModel.Description('The pricing tier (''Standard'' or ''Free'')')]
    [System.String] $PricingTier

    [DscProperty()]
    [System.ComponentModel.Description('The Defender sub plan name, for the list all of possible sub plans refer to Defender for Cloud documentation')]
    [System.String] $SubPlanName

    [DscProperty()]
    [System.ComponentModel.Description('The extensions offered under the plan, for more information refer to Defender for Cloud documentation')]
    [System.String] $Extensions

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the instance exists, absent ensures it is removed.')]
    [ValidateSet('Present')]
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

    [DefenderSubscriptionPlan] Get()
    {
        $Name = $null
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [DefenderSubscriptionPlan]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for Defender Device Authenticated Scan Definition with Name $Name"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.SubscriptionId -ne $this.SubscriptionId)
            {
                $null = $this.Connect('Azure')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $resolvedSubscriptionId = $this.SubscriptionId
                if ([System.String]::IsNullOrEmpty($resolvedSubscriptionId))
                {
                    $subscription = Get-AzSubscription -SubscriptionName $this.SubscriptionName

                    if ($null -ne $subscription)
                    {
                        $resolvedSubscriptionId = $subscription.Id
                    }
                }

                if (-not [System.String]::IsNullOrEmpty($resolvedSubscriptionId))
                {
                    Set-AzContext -Subscription $resolvedSubscriptionId -ErrorAction Stop
                    $instance = Get-AzSecurityPricing -Name $this.PlanName -ErrorAction Stop
                    $azContext = Get-AzContext
                    Add-Member -InputObject $instance -NotePropertyName 'SubscriptionName' -NotePropertyValue $azContext.Subscription.Name
                    Add-Member -InputObject $instance -NotePropertyName 'SubscriptionId' -NotePropertyValue $azContext.Subscription.Id
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                throw "No Microsoft Defender for Cloud subscription plan found for SubscriptionId $($this.SubscriptionId) and PlanName $($this.PlanName)"
            }

            $results = @{
                SubscriptionId        = $instance.SubscriptionId
                SubscriptionName      = $instance.SubscriptionName
                PlanName              = $this.PlanName
                PricingTier           = $instance.PricingTier
                SubPlanName           = $instance.SubPlan
                Extensions            = $instance.Extensions
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
        $Name = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration for Defender Device Authenticated Scan Definition with Name $Name"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        Set-AzContext -Subscription $currentInstance.SubscriptionId -ErrorAction Stop
        if ($this.Extensions)
        {
            Set-AzSecurityPricing -Name $this.PlanName -PricingTier $this.PricingTier -SubPlan $this.SubPlanName -Extension $this.Extensions -ErrorAction Stop
        }
        else
        {
            Set-AzSecurityPricing -Name $this.PlanName -PricingTier $this.PricingTier -SubPlan $this.SubPlanName -ErrorAction Stop
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
            [array] $this.ResourceCache['exportedInstances'] = $this.GetSubscriptionsDefenderPlansFromArg()

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
            foreach ($config in $this.ResourceCache['exportedInstances'])
            {
                $displayedKey = $config.Id
                Write-M365DSCHost -Message "    |---[$i/$($this.ResourceCache['exportedInstances'].Count)] $displayedKey" -DeferWrite
                $params = @{
                    SubscriptionName      = $config.SubscriptionName
                    SubscriptionId        = $config.SubscriptionId
                    PlanName              = $config.PlanName
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

    hidden [System.Object[]] GetSubscriptionsDefenderPlansFromArg()
    {
        try
        {
            $results = @()
            $argQuery = @'
securityresources | where type == "microsoft.security/pricings" | project Id=id, PlanName=name, SubscriptionId=subscriptionId, SubPlan=tostring(properties.subPlan), PricingTier=tostring(properties.pricingTier), Extensions=tostring(properties.extensions)
| join kind=inner (resourcecontainers | where type == "microsoft.resources/subscriptions" | project SubscriptionName = name, SubscriptionId = subscriptionId) on SubscriptionId | project-away SubscriptionId1
'@
            $queryResult = Search-AzGraph -Query $argQuery -First 1000 -UseTenantScope -ErrorAction Stop
            $results += $queryResult.Data

            while ($null -ne $queryResult.SkipToken)
            {
                $queryResult = Search-AzGraph -Query $argQuery -First 1000 -UseTenantScope -SkipToken $queryResult.SkipToken -ErrorAction Stop
                $results += $queryResult.Data
            }

            return $results
        }
        catch
        {
            throw $_
        }
    }

    hidden [DefenderSubscriptionPlan] AsResult([System.Object] $Values)
    {
        if ($Values -is [DefenderSubscriptionPlan])
        {
            return $Values
        }

        $result = [DefenderSubscriptionPlan]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
