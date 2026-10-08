using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOActiveSyncOrganizationSettings : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The AdminMailRecipients parameter specifies the email addresses of the administrators for reporting purposes.')]
    [System.String[]] $AdminMailRecipients

    [DscProperty()]
    [System.ComponentModel.Description('The AllowRMSSupportForUnenlightenedApps parameter specifies whether to allow Rights Management Services protected messages for ActiveSync clients that do not support RMS.')]
    [System.Nullable[System.Boolean]] $AllowRMSSupportForUnenlightenedApps

    [DscProperty()]
    [System.ComponentModel.Description('The DefaultAccessLevel parameter specifies the access level for new and existing device partnerships.')]
    [ValidateSet('Allow', 'Block', 'Quarantine')]
    [System.String] $DefaultAccessLevel

    [DscProperty()]
    [System.ComponentModel.Description('The EnableMobileMailboxPolicyWhenCAInplace parameter specifies whether the mobile mailbox policy applies when Conditional Access is in place.')]
    [System.Nullable[System.Boolean]] $EnableMobileMailboxPolicyWhenCAInplace

    [DscProperty()]
    [System.ComponentModel.Description('The OtaNotificationMailInsert parameter specifies the text to include in an email message that is sent to users who need to update their older devices.')]
    [System.String] $OtaNotificationMailInsert

    [DscProperty()]
    [System.ComponentModel.Description('The TenantAdminPreference parameter specifies the tenant administrator preference for ActiveSync organization settings.')]
    [System.String] $TenantAdminPreference

    [DscProperty()]
    [System.ComponentModel.Description('The UserMailInsert parameter specifies an informational footer that is added to the email message sent to users when their mobile device is quarantined.')]
    [System.String] $UserMailInsert

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
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

    [EXOActiveSyncOrganizationSettings] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOActiveSyncOrganizationSettings]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of EXO Active Sync Organization Settings"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('ExchangeOnline')

                #Ensure the proper dependencies are installed in the current environment.
                Confirm-M365DSCDependencies

                #region Telemetry
                $this.AddTelemetry('Get')
                #endregion

                $activeSyncOrganizationSettings = Get-ActiveSyncOrganizationSettings -ErrorAction SilentlyContinue

                if ($null -eq $activeSyncOrganizationSettings)
                {
                    throw 'Could not retrieve EXO Active Sync Organization Settings'
                }
            }
            else
            {
                $activeSyncOrganizationSettings = $this.ExportedInstance
            }

            Write-Verbose -Message 'Found existing EXO Active Sync Organization Settings'
            $result = @{
                IsSingleInstance                       = 'Yes'
                AdminMailRecipients                    = $activeSyncOrganizationSettings.AdminMailRecipients
                AllowRMSSupportForUnenlightenedApps    = $activeSyncOrganizationSettings.AllowRMSSupportForUnenlightenedApps
                DefaultAccessLevel                     = $activeSyncOrganizationSettings.DefaultAccessLevel
                EnableMobileMailboxPolicyWhenCAInplace = $activeSyncOrganizationSettings.EnableMobileMailboxPolicyWhenCAInplace
                OtaNotificationMailInsert              = $activeSyncOrganizationSettings.OtaNotificationMailInsert
                TenantAdminPreference                  = $activeSyncOrganizationSettings.TenantAdminPreference
                UserMailInsert                         = $activeSyncOrganizationSettings.UserMailInsert
                Credential                             = $this.Credential
                ApplicationId                          = $this.ApplicationId
                TenantId                               = $this.TenantId
                CertificateThumbprint                  = $this.CertificateThumbprint
                CertificatePassword                    = $this.CertificatePassword
                CertificatePath                        = $this.CertificatePath
                ManagedIdentity                        = $this.ManagedIdentity
                AccessTokens                           = $this.AccessTokens
            }
            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of EXO Active Sync Organization Settings"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            $null = $this.Connect('ExchangeOnline')

            $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

            Write-Verbose -Message "Updating EXO Active Sync Organization Settings"

            $updateParameters = $boundParameters
            $updateParameters.Remove('IsSingleInstance') | Out-Null

            Set-ActiveSyncOrganizationSettings @updateParameters | Out-Null
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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

        $ConnectionMode = $this.Connect('ExchangeOnline')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-ActiveSyncOrganizationSettings `
                -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($exportedInstance in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($exportedInstance.Identity)" -DeferWrite

                $Params = @{
                    IsSingleInstance      = 'Yes'
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    CertificatePath       = $this.CertificatePath
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $exportedInstance
                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }

            return $dscContent.ToString()
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOActiveSyncOrganizationSettings] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOActiveSyncOrganizationSettings])
        {
            return $Values
        }

        $result = [EXOActiveSyncOrganizationSettings]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
