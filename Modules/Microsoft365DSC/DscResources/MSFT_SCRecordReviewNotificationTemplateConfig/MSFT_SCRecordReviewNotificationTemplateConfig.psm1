using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCRecordReviewNotificationTemplateConfig : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the resource is a single instance, the value must be ''Yes''')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('The CustomizedNotificationDataString parameter specifies the customized review notification text to use. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomizedNotificationDataString

    [DscProperty()]
    [System.ComponentModel.Description('The CustomizedReminderDataString parameter specifies the customized review reminder text to use. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $CustomizedReminderDataString

    [DscProperty()]
    [System.ComponentModel.Description('The IsCustomizedNotificationTemplate switch specifies whether to use a customized review notification instead of the system default notification.')]
    [System.Nullable[System.Boolean]] $IsCustomizedNotificationTemplate

    [DscProperty()]
    [System.ComponentModel.Description('The IsCustomizedReminderTemplate switch specifies whether to use a customized review reminder instead of the system default reminder.')]
    [System.Nullable[System.Boolean]] $IsCustomizedReminderTemplate

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

    [SCRecordReviewNotificationTemplateConfig] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCRecordReviewNotificationTemplateConfig]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message 'Getting configuration of Record Management Disposition settings for Purview'

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $instance = Get-RecordReviewNotificationTemplateConfig -ErrorAction Stop
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            if ($null -eq $instance)
            {
                throw "Couldn't retrieve the Record Management Disposition settings"
            }

            $results = @{
                IsSingleInstance                 = 'Yes'
                IsCustomizedNotificationTemplate = $instance.IsCustomizedNotificationTemplate
                IsCustomizedReminderTemplate     = $instance.IsCustomizedReminderTemplate
                CustomizedNotificationDataString = $instance.CustomizedNotificationDataString
                CustomizedReminderDataString     = $instance.CustomizedReminderDataString
                Credential                       = $this.Credential
                ApplicationId                    = $this.ApplicationId
                TenantId                         = $this.TenantId
                CertificateThumbprint            = $this.CertificateThumbprint
                CertificatePath                  = $this.CertificatePath
                CertificatePassword              = $this.CertificatePassword
                ManagedIdentity                  = $this.ManagedIdentity
                AccessTokens                     = $this.AccessTokens
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

        Write-Verbose -Message 'Setting configuration of Record Management Disposition settings for Purview'

        $null = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        Write-Verbose -Message 'Updating the Records Management Disposition settings for Purview'
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('IsSingleInstance') | Out-Null
        Set-RecordReviewNotificationTemplateConfig @setParameters
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array] $exportedInstances = Get-RecordReviewNotificationTemplateConfig -ErrorAction Stop

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

    hidden [SCRecordReviewNotificationTemplateConfig] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCRecordReviewNotificationTemplateConfig])
        {
            return $Values
        }

        $result = [SCRecordReviewNotificationTemplateConfig]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
