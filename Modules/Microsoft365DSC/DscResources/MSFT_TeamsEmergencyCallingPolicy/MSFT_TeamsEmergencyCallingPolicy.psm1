using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class TeamsEmergencyCallingPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Identity of the Teams Emergency Calling Policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Teams Emergency Calling Policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Allows the tenant administrator to configure a text string, which is shown at the top of the Calls app.')]
    [System.String] $EnhancedEmergencyServiceDisclaimer

    [DscProperty()]
    [System.ComponentModel.Description('A list of one or more instances of TeamsEmergencyCallingExtendedNotification. Each TeamsEmergencyCallingExtendedNotification should use a unique EmergencyDialString. If an extended notification is found for an emergency phone number based on the EmergencyDialString parameter the extended notification will be controlling the notification. If no extended notification is found the notification settings on the policy instance itself will be used.')]
    [MSFT_TeamsEmergencyCallingExtendedNotification[]] $ExtendedNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Enables ExternalLocationLookupMode. This mode allows users to set Emergency addresses for remote locations.')]
    [ValidateSet('Disabled', 'Enabled')]
    [System.String] $ExternalLocationLookupMode

    [DscProperty()]
    [System.ComponentModel.Description('This parameter represents PSTN number which can be dialed out if NotificationMode is set to either of the two Conference values.')]
    [ValidatePattern('^(?:\+)?[0-9]*$')]
    [System.String] $NotificationDialOutNumber

    [DscProperty()]
    [System.ComponentModel.Description('NotificationGroup is a email list of users and groups to be notified of an emergency call.')]
    [System.String] $NotificationGroup

    [DscProperty()]
    [System.ComponentModel.Description('The type of conference experience for security desk notification.')]
    [ValidateSet('NotificationOnly', 'ConferenceMuted', 'ConferenceUnMuted')]
    [System.String] $NotificationMode

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Teams Global Admin.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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
    [System.String] $Filter = '*'

    [TeamsEmergencyCallingPolicy] Get()
    {
        $nullReturn = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [TeamsEmergencyCallingPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting the Teams Emergency Calling Policy {$($this.Identity)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {
                $null = $this.Connect('MicrosoftTeams')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $policy = Get-CsTeamsEmergencyCallingPolicy -Identity $this.Identity `
                    -ErrorAction 'SilentlyContinue'
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -eq $policy)
            {
                Write-Verbose -Message "Could not find Teams Emergency Calling Policy {$($this.Identity)}"
                return $this.AsResult($nullReturn)
            }

            $complexExtendedNotifications = @()
            foreach ($notification in $policy.ExtendedNotifications)
            {
                $complexExtendedNotification = [ordered]@{
                    EmergencyDialString = $notification.EmergencyDialString
                }
                if ($null -ne $notification.NotificationGroup)
                {
                    $complexExtendedNotification.Add('NotificationGroup', $notification.NotificationGroup.Split(';'))
                }
                if ($null -ne $notification.NotificationDialOutNumber)
                {
                    $complexExtendedNotification.Add('NotificationDialOutNumber', $notification.NotificationDialOutNumber)
                }
                if ($null -ne $notification.NotificationMode)
                {
                    $complexExtendedNotification.Add('NotificationMode', $notification.NotificationMode)
                }
                $complexExtendedNotifications += $complexExtendedNotification
            }

            $externalLocationLookupModeValue = $null
            if ($null -ne $policy.ExternalLocationLookupMode)
            {
                $externalLocationLookupModeValue = $policy.ExternalLocationLookupMode.ToString()
            }

            Write-Verbose -Message "Found Teams Emergency Calling Policy {$($this.Identity)}"
            $result = @{
                Identity                           = $this.Identity
                Description                        = $policy.Description
                EnhancedEmergencyServiceDisclaimer = $policy.EnhancedEmergencyServiceDisclaimer
                ExtendedNotifications              = $complexExtendedNotifications
                ExternalLocationLookupMode         = $externalLocationLookupModeValue
                NotificationDialOutNumber          = $policy.NotificationDialOutNumber
                NotificationGroup                  = $policy.NotificationGroup
                NotificationMode                   = [String]$policy.NotificationMode
                Ensure                             = 'Present'
                Credential                         = $this.Credential
                ApplicationId                      = $this.ApplicationId
                TenantId                           = $this.TenantId
                CertificateThumbprint              = $this.CertificateThumbprint
                CertificatePath                    = $this.CertificatePath
                CertificatePassword                = $this.CertificatePassword
                ManagedIdentity                    = $this.ManagedIdentity
                AccessTokens                       = $this.AccessTokens
            }

            if ([System.String]::IsNullOrEmpty($result.NotificationMode))
            {
                $result.Remove('NotificationMode') | Out-Null
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

        Write-Verbose -Message "Setting Teams Emergency Calling Policy {$($this.Identity)}"

        # Check that at least one optional parameter is specified
        $inputValues = @()
        foreach ($item in $this.GetBoundParameters().Keys)
        {
            if (-not [System.String]::IsNullOrEmpty($this.GetBoundParameters().$item) -and $item -ne 'Credential' `
                    -and $item -ne 'Identity' -and $item -ne 'Ensure')
            {
                $inputValues += $item
            }
        }

        if ($inputValues.Count -eq 0)
        {
            throw "You need to specify at least one optional parameter for the [TeamsEmergencyCallingPolicy] instance {$($this.Identity)}"
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentValues = $this.Get().ToHashtable()
        $SetParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        if ($SetParameters.ContainsKey('ExtendedNotifications'))
        {
            $extendedNotificationsValue = @()
            foreach ($notification in $this.ExtendedNotifications)
            {
                $notificationParameters = @{
                    EmergencyDialString = $notification.EmergencyDialString
                }

                if ($null -ne $notification.NotificationGroup -and $notification.NotificationGroup.Count -gt 0)
                {
                    $notificationParameters.NotificationGroup = $notification.NotificationGroup -join ';'
                }

                if (-not [System.String]::IsNullOrEmpty($notification.NotificationDialOutNumber))
                {
                    $notificationParameters.NotificationDialOutNumber = $notification.NotificationDialOutNumber
                }

                if (-not [System.String]::IsNullOrEmpty($notification.NotificationMode))
                {
                    $notificationParameters.NotificationMode = $notification.NotificationMode
                }

                $extendedNotificationsValue += New-CsTeamsEmergencyCallingExtendedNotification @notificationParameters
            }
            $SetParameters.ExtendedNotifications = $extendedNotificationsValue
        }

        if ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating a new Teams Emergency Calling Policy {$($this.Identity)}"
            New-CsTeamsEmergencyCallingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating settings for Teams Emergency Calling Policy {$($this.Identity)}"
            Set-CsTeamsEmergencyCallingPolicy @SetParameters
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentValues.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing Teams Emergency Calling Policy {$($this.Identity)}"
            Remove-CsTeamsEmergencyCallingPolicy -Identity $this.Identity
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

        $ConnectionMode = $this.Connect('MicrosoftTeams')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            $i = 1
            [array]$policies = Get-CsTeamsEmergencyCallingPolicy -Filter $this.Filter -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()
            Write-M365DSCHost -Message "`r`n" -DeferWrite
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Identity)" -DeferWrite
                $params = @{
                    Identity              = $policy.Identity
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePath       = $this.CertificatePath
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)

                if ($null -ne $Results.ExtendedNotifications)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ExtendedNotifications `
                        -CIMInstanceName 'TeamsEmergencyCallingExtendedNotification'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ExtendedNotifications = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ExtendedNotifications') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('ExtendedNotifications')
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

    hidden [TeamsEmergencyCallingPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [TeamsEmergencyCallingPolicy])
        {
            return $Values
        }

        $result = [TeamsEmergencyCallingPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_TeamsEmergencyCallingExtendedNotification
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The emergency dial string.')]
    [System.String] $EmergencyDialString

    [DscProperty()]
    [System.ComponentModel.Description('The email recipients of the notifications.')]
    [System.String[]] $NotificationGroup

    [DscProperty()]
    [System.ComponentModel.Description('The additional number to call when contacting an emergency number.')]
    [System.String] $NotificationDialOutNumber

    [DscProperty()]
    [System.ComponentModel.Description('The notification mode for the additional number. Possible values: ConferenceMuted - Join the emergency call muted. ConferenceUnMuted - Join the emergency call unmuted. NotificationOnly - Only receive a notification for an emergency call.')]
    [ValidateSet('ConferenceMuted', 'ConferenceUnMuted', 'NotificationOnly')]
    [System.String] $NotificationMode
}
