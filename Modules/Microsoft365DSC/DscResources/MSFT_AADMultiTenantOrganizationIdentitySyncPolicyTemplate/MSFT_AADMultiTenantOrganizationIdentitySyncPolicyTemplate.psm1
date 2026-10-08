using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADMultiTenantOrganizationIdentitySyncPolicyTemplate : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the template will be applied to user synchronization settings of certain tenants. The possible values are: none, newPartners, existingPartners, unknownFutureValue. You can also specify multiple values like newPartners,existingPartners (default). none indicates the template is not applied to any new or existing partner tenants. newPartners indicates the template is applied to new partner tenants. existingPartners indicates the template is applied to existing partner tenants, those who already had partner-specific user synchronization settings in place.')]
    [System.String] $TemplateApplicationLevel

    [DscProperty()]
    [System.ComponentModel.Description('Determines whether users can be synchronized from the partner tenant. false causes any current user synchronization from the source tenant to the target tenant to stop. This property has no impact on existing users who have already been synchronized.')]
    [MSFT_AADMultiTenantOrganizationIdentitySyncPolicyTemplateUserSyncInbound] $UserSyncInbound

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

    [AADMultiTenantOrganizationIdentitySyncPolicyTemplate] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADMultiTenantOrganizationIdentitySyncPolicyTemplate]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for the AAD Multi Tenant Organization Identity Sync Policy Template'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-MgBetaPolicyCrossTenantAccessPolicyTemplateMultiTenantOrganizationIdentitySynchronization -ErrorAction SilentlyContinue

            if ($null -eq $instance)
            {
                throw 'There was an error retrieving values from the Get function in AADMultiTenantOrganizationIdentitySyncPolicyTemplate.'
            }

            $UserSyncInboundValue = @{
                isSyncAllowed = $instance.UserSyncInbound.isSyncAllowed
            }

            $results = @{
                IsSingleInstance         = 'Yes'
                TemplateApplicationLevel = $instance.TemplateApplicationLevel
                UserSyncInbound          = $UserSyncInboundValue
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
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

        Write-Verbose -Message 'Setting the AAD Multi Tenant Organization Identity Sync Policy Template'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = Get-MgBetaPolicyCrossTenantAccessPolicyTemplateMultiTenantOrganizationIdentitySynchronization
        $setParameters = @{
            Id                       = $currentInstance.Id
            TemplateApplicationLevel = $this.TemplateApplicationLevel
            UserSyncInbound          = @{
                isSyncAllowed = $this.UserSyncInbound.isSyncAllowed
            }
        }
        Update-MgBetaPolicyCrossTenantAccessPolicyTemplateMultiTenantOrganizationIdentitySynchronization -BodyParameter $setParameters
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                IsSingleInstance      = 'Yes'
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
            if ($null -ne $Results.UserSyncInbound)
            {
                $complexMapping = @(
                    @{
                        Name            = 'UserSyncInbound'
                        CimInstanceName = 'MSFT_AADMultiTenantOrganizationIdentitySyncPolicyTemplateUserSyncInbound'
                        IsRequired      = $False
                    }
                )
                $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                    -ComplexObject $Results.UserSyncInbound `
                    -CIMInstanceName 'MSFT_AADMultiTenantOrganizationIdentitySyncPolicyTemplateUserSyncInbound' `
                    -ComplexTypeMapping $complexMapping

                if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                {
                    $Results.UserSyncInbound = $complexTypeStringResult
                }
                else
                {
                    $Results.Remove('UserSyncInbound') | Out-Null
                }
            }
            $dscContent = [System.Text.StringBuilder]::new()
            $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                -ConnectionMode $ConnectionMode `
                -ModulePath $this.GetModulePath() `
                -Results $Results `
                -Credential $this.Credential `
                -NoEscape @('UserSyncInbound')
            [void]$dscContent.Append($currentDSCBlock)
            Save-M365DSCPartialExport -Content $currentDSCBlock `
                -FileName $Global:PartialExportFileName

            Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite

            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADMultiTenantOrganizationIdentitySyncPolicyTemplate] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADMultiTenantOrganizationIdentitySyncPolicyTemplate])
        {
            return $Values
        }

        $result = [AADMultiTenantOrganizationIdentitySyncPolicyTemplate]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADMultiTenantOrganizationIdentitySyncPolicyTemplateUserSyncInbound
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether user objects should be synchronized from the partner tenant. false causes any current user synchronization from the source tenant to the target tenant to stop. This property has no impact on existing users who have already been synchronized.')]
    [System.Nullable[System.Boolean]] $isSyncAllowed
}
