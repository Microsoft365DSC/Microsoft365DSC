using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCProtectionAlert : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies the scope for aggregated alert policies')]
    [System.String[]] $AlertBy

    [DscProperty()]
    [System.ComponentModel.Description('This parameter is reserved for internal Microsoft use')]
    [System.String[]] $AlertFor

    [DscProperty()]
    [System.ComponentModel.Description('Specifies how the alert policy triggers alerts for multiple occurrences of monitored activity')]
    [ValidateSet('None', 'SimpleAggregation', 'AnomalousAggregation', 'CustomAggregation')]
    [System.String] $AggregationType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a category for the alert policy')]
    [System.String] $Category

    [DscProperty()]
    [System.ComponentModel.Description('Specifies an optional comment')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('Enables or disables the alert policy')]
    [System.Nullable[System.Boolean]] $Disabled

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this alert should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Filter parameter uses OPATH syntax to filter the results by the specified properties and values')]
    [System.String] $Filter

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the unique name for the alert policy')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the language or locale that''s used for notifications. For example, da-DK for Danish')]
    [System.String] $NotificationCulture

    [DscProperty()]
    [System.ComponentModel.Description('NotificationEnabled true or false')]
    [System.Nullable[System.Boolean]] $NotificationEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to trigger an alert for a single event when the alert policy is configured for aggregated activity')]
    [System.Nullable[System.Boolean]] $NotifyUserOnFilterMatch

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether to temporarily suspend notifications for the alert policy. Until the specified date-time, no notifications are sent for detected activities.')]
    [System.Nullable[System.DateTime]] $NotifyUserSuppressionExpiryDate

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum number of notifications for the alert policy within the time period specified by the NotifyUserThrottleWindow parameter. Once the maximum number of notifications has been reached in the time period, no more notifications are sent for the alert.')]
    [System.Nullable[System.UInt32]] $NotifyUserThrottleThreshold

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time interval in minutes that''s used by the NotifyUserThrottleThreshold parameter')]
    [System.Nullable[System.UInt32]] $NotifyUserThrottleWindow

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the SMTP address of the user who receives notification messages for the alert policy. You can specify multiple values separated by commas')]
    [System.String[]] $NotifyUser

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the activities that are monitored by the alert policy')]
    [System.String[]] $Operation

    [DscProperty()]
    [System.ComponentModel.Description('PrivacyManagementScopedSensitiveInformationTypes')]
    [System.String[]] $PrivacyManagementScopedSensitiveInformationTypes

    [DscProperty()]
    [System.ComponentModel.Description('PrivacyManagementScopedSensitiveInformationTypesForCounting')]
    [System.String[]] $PrivacyManagementScopedSensitiveInformationTypesForCounting

    [DscProperty()]
    [System.ComponentModel.Description('PrivacyManagementScopedSensitiveInformationTypesThreshold')]
    [System.Nullable[System.UInt64]] $PrivacyManagementScopedSensitiveInformationTypesThreshold

    [DscProperty()]
    [System.ComponentModel.Description('specifies the severity of the detection')]
    [ValidateSet('Low', 'Medium', 'High', 'Informational')]
    [System.String] $Severity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the type of activities that are monitored by the alert policy')]
    [ValidateSet('Activity', 'Malware', 'Phish', 'Malicious', 'MaliciousUrlClick', 'MailFlow')]
    [System.String] $ThreatType

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of detections that trigger the alert policy within the time period specified by the TimeWindow parameter. A valid value is an integer that''s greater than or equal to 3.')]
    [ValidateRange(3, 2147483647)]
    [System.Nullable[System.UInt32]] $Threshold

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the time interval in minutes for number of detections specified by the Threshold parameter. A valid value is an integer that''s greater than 60 (one hour).')]
    [ValidateRange(60, 2147483647)]
    [System.Nullable[System.UInt32]] $TimeWindow

    [DscProperty()]
    [System.ComponentModel.Description('Volume Threshold')]
    [System.Nullable[System.UInt32]] $VolumeThreshold

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Global Admin')]
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

    [SCProtectionAlert] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCProtectionAlert]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of SCProtectionAlert for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $AlertObject = Invoke-M365DSCCommand -ScriptBlock { Get-ProtectionAlert -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError

                if ($null -eq $AlertObject)
                {
                    Write-Verbose -Message "SCProtectionAlert $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $AlertObject = $this.ExportedInstance
            }

            Write-Verbose "Found existing SCProtectionAlert $($this.Name)"

            $result = @{
                Ensure                                                      = 'Present'
                AlertBy                                                     = $AlertObject.AlertBy
                AlertFor                                                    = $AlertObject.AlertFor
                AggregationType                                             = $AlertObject.AggregationType
                Category                                                    = $AlertObject.Category
                Comment                                                     = $AlertObject.Comment
                Disabled                                                    = $AlertObject.Disabled
                Filter                                                      = $AlertObject.Filter
                Name                                                        = $AlertObject.Name
                NotificationCulture                                         = $AlertObject.NotificationCulture
                NotificationEnabled                                         = $AlertObject.NotificationEnabled
                NotifyUserOnFilterMatch                                     = $AlertObject.NotifyUserOnFilterMatch
                NotifyUserSuppressionExpiryDate                             = $AlertObject.NotifyUserSuppressionExpiryDate
                NotifyUserThrottleThreshold                                 = $AlertObject.NotifyUserThrottleThreshold
                NotifyUserThrottleWindow                                    = $AlertObject.NotifyUserThrottleWindow
                NotifyUser                                                  = $AlertObject.NotifyUser
                Operation                                                   = $AlertObject.Operation
                PrivacyManagementScopedSensitiveInformationTypes            = $AlertObject.PrivacyManagementScopedSensitiveInformationTypes
                PrivacyManagementScopedSensitiveInformationTypesForCounting = $AlertObject.PrivacyManagementScopedSensitiveInformationTypesForCounting
                PrivacyManagementScopedSensitiveInformationTypesThreshold   = $AlertObject.PrivacyManagementScopedSensitiveInformationTypesThreshold
                Severity                                                    = $AlertObject.Severity
                ThreatType                                                  = $AlertObject.ThreatType
                Threshold                                                   = $AlertObject.Threshold
                TimeWindow                                                  = $AlertObject.TimeWindow
                VolumeThreshold                                             = $AlertObject.VolumeThreshold
                Credential                                                  = $this.Credential
                ApplicationId                                               = $this.ApplicationId
                TenantId                                                    = $this.TenantId
                CertificateThumbprint                                       = $this.CertificateThumbprint
                CertificatePath                                             = $this.CertificatePath
                CertificatePassword                                         = $this.CertificatePassword
                ManagedIdentity                                             = $this.ManagedIdentity
                AccessTokens                                                = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of SCProtectionAlert for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentAlert = $this.Get().ToHashtable()

        $CreationParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($this.Ensure -eq 'Present' -and $CurrentAlert.Ensure -eq 'Absent')
        {
            New-ProtectionAlert @CreationParams
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentAlert.Ensure -eq 'Present')
        {
            $CreationParams.Remove('Name') | Out-Null
            $CreationParams.Remove('ThreatType') | Out-Null

            $Alert = Get-ProtectionAlert -Identity $this.Name
            $CreationParams.Add('Identity', $Alert.Name)

            Write-Verbose "Updating ProtectionAlert with values: $(Convert-M365DscHashtableToString -Hashtable $CreationParams)"
            Set-ProtectionAlert @CreationParams
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentAlert.Ensure -eq 'Present')
        {
            # If the Alert exists and it shouldn't, simply remove it;
            $Alert = Get-ProtectionAlert -Identity $this.Name
            Write-Verbose "Removing Protection alert $($this.Name)"
            Remove-ProtectionAlert -Identity $Alert.Identity -ForceDeletion -Confirm:$false
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')
        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$Alerts = Get-ProtectionAlert -ErrorAction Stop | Where-Object -FilterScript { -not $_.IsSystemRule }

            $totalAlerts = $Alerts.Length
            if ($null -eq $totalAlerts)
            {
                $totalAlerts = 1
            }
            $i = 1
            if ($totalAlerts.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $dscContent = [System.Text.StringBuilder]::new()
            foreach ($alert in $Alerts)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($totalAlerts)] $($alert.Name)" -DeferWrite
                $this.ExportedInstance = $alert
                $Results = $this.GetForExport(@{ Name = $Alert.Name })
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [SCProtectionAlert] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCProtectionAlert])
        {
            return $Values
        }

        $result = [SCProtectionAlert]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
