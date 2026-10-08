using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADCrossTenantIdentitySyncPolicyPartner : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the associated partner tenant ID.')]
    [System.String] $CrossTenantAccessPolicyConfigurationPartnerTenantId

    [DscProperty()]
    [System.ComponentModel.Description('Display name for the cross-tenant user synchronization policy. Use the name of the partner Microsoft Entra tenant to easily identify the policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether user objects should be synchronized from the partner tenant. False causes any current user synchronization from the source tenant to the target tenant to stop. This property has no impact on existing users who have already been synchronized.')]
    [System.Nullable[System.Boolean]] $IsSyncAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the authorized application in the external cloud.')]
    [System.String] $ExternalCloudAuthorizedApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether role enabled groups can be synchronized from the partner tenant.')]
    [System.Nullable[System.Boolean]] $IsRoleEnabledGroupSyncAllowed

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
    [System.String] $Filter

    # Export-only. Not part of the resource schema.
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [AADCrossTenantIdentitySyncPolicyPartner] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADCrossTenantIdentitySyncPolicyPartner]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Cross-Tenant Identity Sync Policy for Tenant {$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.TenantId -ne $this.CrossTenantAccessPolicyConfigurationPartnerTenantId)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization `
                    -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.CrossTenantAccessPolicyConfigurationPartnerTenantId `
                    -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "No AAD Cross Tenant Identity Sync Policy Partner for TenantId {$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)} found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            $roleEnabledGroupSyncAllowed = $null
            if ($null -ne $instance.roleEnabledGroupSyncInbound)
            {
                $roleEnabledGroupSyncAllowed = $instance.roleEnabledGroupSyncInbound.IsSyncAllowed
            }

            $results = @{
                DisplayName                                         = $instance.DisplayName
                CrossTenantAccessPolicyConfigurationPartnerTenantId = $instance.TenantId
                IsSyncAllowed                                       = $instance.userSyncInbound.IsSyncAllowed
                ExternalCloudAuthorizedApplicationId                = $instance.ExternalCloudAuthorizedApplicationId
                IsRoleEnabledGroupSyncAllowed                       = $roleEnabledGroupSyncAllowed
                Ensure                                              = 'Present'
                Credential                                          = $this.Credential
                ApplicationId                                       = $this.ApplicationId
                TenantId                                            = $this.TenantId
                CertificateThumbprint                               = $this.CertificateThumbprint
                CertificatePath                                     = $this.CertificatePath
                CertificatePassword                                 = $this.CertificatePassword
                ManagedIdentity                                     = $this.ManagedIdentity
                AccessTokens                                        = $this.AccessTokens
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
        $params = @{
            displayName     = $this.DisplayName
            userSyncInbound = @{
                isSyncAllowed = $this.IsSyncAllowed
            }
        }
        $this.AddOptionalSyncValues($params)

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating Cross-Tenant Identity Sync Policy for Tenant {$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)} with:`r`n$(ConvertTo-Json $params -Depth 10)"
            Set-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization -BodyParameter $params `
                -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.CrossTenantAccessPolicyConfigurationPartnerTenantId
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $body = $params | ConvertTo-Json -Depth 10
            Write-Verbose -Message "Updating Cross-Tenant Identity Sync Policy for Tenant {$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)} with:`r`n$body"
            Invoke-M365DSCGraphRequest -Method 'PATCH' `
                -Uri "/beta/policies/crossTenantAccessPolicy/partners/$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)/identitySynchronization" `
                -Body $body -ErrorAction Stop | Out-Null
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Cross-Tenant Identity Sync Policy for Tenant {$($this.CrossTenantAccessPolicyConfigurationPartnerTenantId)}"
            Remove-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization `
                -CrossTenantAccessPolicyConfigurationPartnerTenantId $this.CrossTenantAccessPolicyConfigurationPartnerTenantId -ErrorAction Stop
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
            $policyPartners = Get-MgBetaPolicyCrossTenantAccessPolicyPartner `
                -All `
                -Filter $this.Filter `
                -ExpandProperty 'identitySynchronization' `
                -ErrorAction Stop
            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policyPartners.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($partner in $policyPartners)
            {
                $config = $partner.IdentitySynchronization
                try
                {
                    if ($null -eq $config)
                    {
                        $config = Get-MgBetaPolicyCrossTenantAccessPolicyPartnerIdentitySynchronization `
                            -CrossTenantAccessPolicyConfigurationPartnerTenantId $partner.TenantId `
                            -ErrorAction Stop
                    }
                }
                catch
                {
                    Write-M365DSCHost -Message "    |---[$i/$($policyPartners.Count)] $($partner.TenantId)$Global:M365DSCEmojiRedX" -CommitWrite
                    $this.LogError($_, 'Error during Export:')
                    $i++
                    continue
                }

                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                $displayedKey = $config.DisplayName
                Write-M365DSCHost -Message "    |---[$i/$($policyPartners.Count)] $displayedKey" -DeferWrite
                $params = @{
                    DisplayName                                         = $config.DisplayName
                    CrossTenantAccessPolicyConfigurationPartnerTenantId = $partner.TenantId
                    Ensure                                              = 'Present'
                    Credential                                          = $this.Credential
                    ApplicationId                                       = $this.ApplicationId
                    TenantId                                            = $this.TenantId
                    CertificateThumbprint                               = $this.CertificateThumbprint
                    CertificatePath                                     = $this.CertificatePath
                    CertificatePassword                                 = $this.CertificatePassword
                    ManagedIdentity                                     = $this.ManagedIdentity
                    AccessTokens                                        = $this.AccessTokens
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

    hidden [void] AddOptionalSyncValues([System.Collections.Hashtable] $Params)
    {
        $bound = $this.GetBoundParameters()
        if ($bound.ContainsKey('ExternalCloudAuthorizedApplicationId'))
        {
            $Params.externalCloudAuthorizedApplicationId = $this.ExternalCloudAuthorizedApplicationId
        }

        # Graph rejects roleEnabledGroupSyncInbound unless group synchronization is already enabled
        # on the partner, which another resource owns.
        if ($bound.ContainsKey('IsRoleEnabledGroupSyncAllowed'))
        {
            $Params.roleEnabledGroupSyncInbound = @{
                isSyncAllowed = $this.IsRoleEnabledGroupSyncAllowed
            }
        }
    }

    hidden [AADCrossTenantIdentitySyncPolicyPartner] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADCrossTenantIdentitySyncPolicyPartner])
        {
            return $Values
        }

        $result = [AADCrossTenantIdentitySyncPolicyPartner]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
