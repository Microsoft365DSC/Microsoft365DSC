using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only accepted value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('If externalUserLifecycleAction is blockSignInAndDelete, the duration, typically many days, after an external user is blocked from sign in before their account is deleted.')]
    [System.Nullable[System.UInt32]] $DaysUntilExternalUserDeletedAfterBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Automatic action that the service should take when an external user''s last access package assignment is removed. The possible values are: none, blockSignIn, blockSignInAndDelete, unknownFutureValue.')]
    [System.String] $ExternalUserLifecycleAction

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

    [AADEntitlementManagementSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration for Entitlement Management Settings'

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $instance = Get-MgBetaEntitlementManagementSetting -ErrorAction Stop

            $results = @{
                IsSingleInstance                         = 'Yes'
                DaysUntilExternalUserDeletedAfterBlocked = $instance.DaysUntilExternalUserDeletedAfterBlocked
                ExternalUserLifecycleAction              = $instance.ExternalUserLifecycleAction
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
                ApplicationSecret                        = $this.ApplicationSecret
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePath                          = $this.CertificatePath
                CertificatePassword                      = $this.CertificatePassword
                ManagedIdentity                          = $this.ManagedIdentity
                AccessTokens                             = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration for Entitlement Management Settings'

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('IsSingleInstance') | Out-Null
        Write-Verbose -Message 'Updating Entitlement Management settings'
        Update-MgBetaEntitlementManagementSetting -BodyParameter $setParameters | Out-Null
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $i = $null
        if ($this.RequiresPowerShellCore())
        {
            return [string] $this.InvokeInPowerShellCore('Export')
        }

        $ConnectionMode = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $params = @{
                IsSIngleInstance      = 'Yes'
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }
            $Results = $this.GetForExport($Params)

            $dscContent = [System.Text.StringBuilder]::new()
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
            return $dscContent.ToString()
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [AADEntitlementManagementSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementSettings])
        {
            return $Values
        }

        $result = [AADEntitlementManagementSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
