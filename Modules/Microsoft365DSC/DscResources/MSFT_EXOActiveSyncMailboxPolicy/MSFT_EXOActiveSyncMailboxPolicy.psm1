using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOActiveSyncMailboxPolicy : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Specifies the name of the policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether push notifications are allowed for Apple mobile devices.')]
    [System.Nullable[System.Boolean]] $AllowApplePushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the Bluetooth capabilities of the mobile phone are allowed.')]
    [ValidateSet('Disable', 'HandsfreeOnly', 'Allow')]
    [System.String] $AllowBluetooth

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether Microsoft Pocket Internet Explorer is allowed on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowBrowser

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the mobile phone''s camera is allowed.')]
    [System.Nullable[System.Boolean]] $AllowCamera

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the mobile phone user can configure a personal email account on the device.')]
    [System.Nullable[System.Boolean]] $AllowConsumerEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the mobile phone can synchronize with a desktop computer through a cable.')]
    [System.Nullable[System.Boolean]] $AllowDesktopSync

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether an external device management program is allowed to manage the device.')]
    [System.Nullable[System.Boolean]] $AllowExternalDeviceManagement

    [DscProperty()]
    [System.ComponentModel.Description('The AllowGooglePushNotifications parameter controls whether the user can receive push notifications from Google for Outlook on the web for devices. Valid input for this parameter is $true or $false. The default value is $true.')]
    [System.Nullable[System.Boolean]] $AllowGooglePushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether HTML email is enabled on the device.')]
    [System.Nullable[System.Boolean]] $AllowHTMLEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the mobile phone can be used as a modem to connect a computer to the Internet.')]
    [System.Nullable[System.Boolean]] $AllowInternetSharing

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether infrared connections are allowed to the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowIrDA

    [DscProperty()]
    [System.ComponentModel.Description('The AllowMicrosoftPushNotifications parameter specifies whether push notifications are enabled on the mobile device. Valid input for this parameter is $true or $false. The default value is $true.')]
    [System.Nullable[System.Boolean]] $AllowMicrosoftPushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether certain updates are seen by devices that implemented support for this restricting functionality.')]
    [System.Nullable[System.Boolean]] $AllowMobileOTAUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Enables all devices to synchronize with the computer running Exchange, regardless of whether the device can enforce all the specific settings established in the Mobile Device mailbox policy.')]
    [System.Nullable[System.Boolean]] $AllowNonProvisionableDevices

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the user can configure a POP3 or IMAP4 email account on the device.')]
    [System.Nullable[System.Boolean]] $AllowPOPIMAPEmail

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the mobile phone can initiate a remote desktop connection.')]
    [System.Nullable[System.Boolean]] $AllowRemoteDesktop

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether a simple device password is allowed.')]
    [System.Nullable[System.Boolean]] $AllowSimplePassword

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the messaging application on the device can negotiate the encryption algorithm in case a recipient''s certificate doesn''t support the specified encryption algorithm.')]
    [System.String] $AllowSMIMEEncryptionAlgorithmNegotiation

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether S/MIME software certificates are allowed.')]
    [System.Nullable[System.Boolean]] $AllowSMIMESoftCerts

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the device can access information stored on a storage card.')]
    [System.Nullable[System.Boolean]] $AllowStorageCard

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether text messaging is allowed from the device.')]
    [System.Nullable[System.Boolean]] $AllowTextMessaging

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether unsigned applications can be installed on the device.')]
    [System.Nullable[System.Boolean]] $AllowUnsignedApplications

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether unsigned installation packages can be run on the device.')]
    [System.Nullable[System.Boolean]] $AllowUnsignedInstallationPackages

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether wireless Internet access is allowed on the device.')]
    [System.Nullable[System.Boolean]] $AllowWiFi

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the device password must be alphanumeric.')]
    [System.Nullable[System.Boolean]] $AlphanumericPasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of approved applications for the device.')]
    [System.String[]] $ApprovedApplicationList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the user can download attachments.')]
    [System.Nullable[System.Boolean]] $AttachmentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Enables device encryption on the mobile phone.')]
    [System.Nullable[System.Boolean]] $DeviceEncryptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies that the user set a password for the device.')]
    [System.Nullable[System.Boolean]] $PasswordEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the length of time, in days, that a password can be used.')]
    [System.String] $PasswordExpiration

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of previously used passwords to store.')]
    [System.Nullable[System.Int32]] $PasswordHistory

    [DscProperty()]
    [System.ComponentModel.Description('Specifies how often the policy is sent from the server to the mobile phone')]
    [System.String] $DevicePolicyRefreshInterval

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether Information Rights Management (IRM) is enabled for the mailbox policy.')]
    [System.Nullable[System.Boolean]] $IrmEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether this policy is the default Mobile Device mailbox policy.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum size of attachments that can be downloaded to the mobile phone.')]
    [System.String] $MaxAttachmentSize

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum range of calendar days that can be synchronized to the device.')]
    [ValidateSet('All', 'TwoWeeks', 'OneMonth', 'ThreeMonths', 'SixMonths')]
    [System.String] $MaxCalendarAgeFilter

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the number of attempts a user can make to enter the correct password for the device.')]
    [System.String] $MaxPasswordFailedAttempts

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum number of days of email items to synchronize to the device.')]
    [ValidateSet('All', 'OneDay', 'ThreeDays', 'OneWeek', 'TwoWeeks', 'OneMonth', 'ThreeMonths', 'SixMonths')]
    [System.String] $MaxEmailAgeFilter

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum size at which email messages are truncated when synchronized to the device.')]
    [System.String] $MaxEmailBodyTruncationSize

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the maximum size at which HTML-formatted email messages are synchronized to the device.')]
    [System.String] $MaxEmailHTMLBodyTruncationSize

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the length of time that the device can be inactive before the password is required to reactivate the device.')]
    [System.String] $MaxInactivityTimeLock

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the minimum number of complex characters required in a device password.')]
    [System.Nullable[System.Int32]] $MinPasswordComplexCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the minimum number of characters in the device password.')]
    [System.Nullable[System.Int32]] $MinPasswordLength

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you can store the recovery password for the device on an Exchange server.')]
    [System.Nullable[System.Boolean]] $PasswordRecoveryEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether encryption is required on the device.')]
    [System.Nullable[System.Boolean]] $RequireDeviceEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether you must encrypt S/MIME messages.')]
    [System.Nullable[System.Boolean]] $RequireEncryptedSMIMEMessages

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what required algorithm must be used when encrypting a message.')]
    [System.String] $RequireEncryptionSMIMEAlgorithm

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the device must synchronize manually while roaming.')]
    [System.Nullable[System.Boolean]] $RequireManualSyncWhenRoaming

    [DscProperty()]
    [System.ComponentModel.Description('Specifies what required algorithm must be used when signing a message.')]
    [System.String] $RequireSignedSMIMEAlgorithm

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether the device must send signed S/MIME messages.')]
    [System.Nullable[System.Boolean]] $RequireSignedSMIMEMessages

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether encryption of a storage card is required.')]
    [System.Nullable[System.Boolean]] $RequireStorageCardEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Specifies a list of applications that can''t be run in ROM.')]
    [System.String[]] $UnapprovedInROMApplicationList

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether access to Microsoft Windows file shares is enabled.')]
    [System.Nullable[System.Boolean]] $UNCAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specifies whether access to Microsoft Windows SharePoint Services is enabled.')]
    [System.Nullable[System.Boolean]] $WSSAccessEnabled

    [DscProperty(Key)]
    [System.ComponentModel.Description('Specifies the Mobile Device mailbox policy.')]
    [System.String] $Identity

    [DscProperty()]
    [System.ComponentModel.Description('Specifies if this AddressList should exist.')]
    [ValidateSet('Present', 'Absent')]
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

    [EXOActiveSyncMailboxPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOActiveSyncMailboxPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for ActiveSync Mailbox Policy with Identity $($this.Identity)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Identity -ne $this.Identity)
            {

                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $instance = Get-MobileDeviceMailboxPolicy -Identity $this.Identity -ErrorAction SilentlyContinue

                if ($null -eq $instance)
                {
                    Write-Verbose -Message "An EXO ActiveSync Mailbox Policy with Identity $($this.Identity) was not found."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO ActiveSync Mailbox Policy with Identity $($this.Identity) was found."

            $results = @{
                Ensure                                   = 'Present'
                Name                                     = [System.String]$instance.Name
                AllowApplePushNotifications              = [System.Boolean]$instance.AllowApplePushNotifications
                AllowBluetooth                           = [System.String]$instance.AllowBluetooth
                AllowBrowser                             = [System.Boolean]$instance.AllowBrowser
                AllowCamera                              = [System.Boolean]$instance.AllowCamera
                AllowConsumerEmail                       = [System.Boolean]$instance.AllowConsumerEmail
                AllowDesktopSync                         = [System.Boolean]$instance.AllowDesktopSync
                AllowExternalDeviceManagement            = [System.Boolean]$instance.AllowExternalDeviceManagement
                AllowGooglePushNotifications             = [System.Boolean]$instance.AllowGooglePushNotifications
                AllowHTMLEmail                           = [System.Boolean]$instance.AllowHTMLEmail
                AllowInternetSharing                     = [System.Boolean]$instance.AllowInternetSharing
                AllowIrDA                                = [System.Boolean]$instance.AllowIrDA
                AllowMicrosoftPushNotifications          = [System.Boolean]$instance.AllowMicrosoftPushNotifications
                AllowMobileOTAUpdate                     = [System.Boolean]$instance.AllowMobileOTAUpdate
                AllowNonProvisionableDevices             = [System.Boolean]$instance.AllowNonProvisionableDevices
                AllowPOPIMAPEmail                        = [System.Boolean]$instance.AllowPOPIMAPEmail
                AllowRemoteDesktop                       = [System.Boolean]$instance.AllowRemoteDesktop
                AllowSimplePassword                      = [System.Boolean]$instance.AllowSimplePassword
                AllowSMIMEEncryptionAlgorithmNegotiation = [System.String]$instance.AllowSMIMEEncryptionAlgorithmNegotiation
                AllowSMIMESoftCerts                      = [System.Boolean]$instance.AllowSMIMESoftCerts
                AllowStorageCard                         = [System.Boolean]$instance.AllowStorageCard
                AllowTextMessaging                       = [System.Boolean]$instance.AllowTextMessaging
                AllowUnsignedApplications                = [System.Boolean]$instance.AllowUnsignedApplications
                AllowUnsignedInstallationPackages        = [System.Boolean]$instance.AllowUnsignedInstallationPackages
                AllowWiFi                                = [System.Boolean]$instance.AllowWiFi
                AlphanumericPasswordRequired             = [System.Boolean]$instance.AlphanumericPasswordRequired
                ApprovedApplicationList                  = [System.String[]]$instance.ApprovedApplicationList
                AttachmentsEnabled                       = [System.Boolean]$instance.AttachmentsEnabled
                DeviceEncryptionEnabled                  = [System.Boolean]$instance.DeviceEncryptionEnabled
                PasswordEnabled                          = [System.Boolean]$instance.PasswordEnabled
                PasswordExpiration                       = [System.String]$instance.PasswordExpiration
                PasswordHistory                          = [System.Int32]$instance.PasswordHistory
                DevicePolicyRefreshInterval              = [System.String]$instance.DevicePolicyRefreshInterval
                IrmEnabled                               = [System.Boolean]$instance.IrmEnabled
                IsDefault                                = [System.Boolean]$instance.IsDefault
                MaxAttachmentSize                        = [System.String]$instance.MaxAttachmentSize
                MaxCalendarAgeFilter                     = [System.String]$instance.MaxCalendarAgeFilter
                MaxPasswordFailedAttempts                = [System.String]$instance.MaxPasswordFailedAttempts
                MaxEmailAgeFilter                        = [System.String]$instance.MaxEmailAgeFilter
                MaxEmailBodyTruncationSize               = [System.String]$instance.MaxEmailBodyTruncationSize
                MaxEmailHTMLBodyTruncationSize           = [System.String]$instance.MaxEmailHTMLBodyTruncationSize
                MaxInactivityTimeLock                    = [System.String]$instance.MaxInactivityTimeLock
                MinPasswordComplexCharacters             = [System.Int32]$instance.MinPasswordComplexCharacters
                MinPasswordLength                        = [System.Int32]$instance.MinPasswordLength
                PasswordRecoveryEnabled                  = [System.Boolean]$instance.PasswordRecoveryEnabled
                RequireDeviceEncryption                  = [System.Boolean]$instance.RequireDeviceEncryption
                RequireEncryptedSMIMEMessages            = [System.Boolean]$instance.RequireEncryptedSMIMEMessages
                RequireEncryptionSMIMEAlgorithm          = [System.String]$instance.RequireEncryptionSMIMEAlgorithm
                RequireManualSyncWhenRoaming             = [System.Boolean]$instance.RequireManualSyncWhenRoaming
                RequireSignedSMIMEAlgorithm              = [System.String]$instance.RequireSignedSMIMEAlgorithm
                RequireSignedSMIMEMessages               = [System.Boolean]$instance.RequireSignedSMIMEMessages
                RequireStorageCardEncryption             = [System.Boolean]$instance.RequireStorageCardEncryption
                UnapprovedInROMApplicationList           = [System.String[]]$instance.UnapprovedInROMApplicationList
                UNCAccessEnabled                         = [System.Boolean]$instance.UNCAccessEnabled
                WSSAccessEnabled                         = [System.Boolean]$instance.WSSAccessEnabled
                Identity                                 = [System.String]$this.Identity
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                TenantId                                 = $this.TenantId
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

        Write-Verbose -Message "Setting configuration for ActiveSync Mailbox Policy with Identity $($this.Identity)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        foreach ($property in @('MinPasswordLength', 'MinPasswordComplexCharacters'))
        {
            if ($setParameters.ContainsKey($property) -and $setParameters.$property -eq 0)
            {
                $setParameters.$property = $null
            }
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $setParameters.Remove('Identity')
            if ([System.String]::IsNullOrEmpty($setParameters.Name))
            {
                $setParameters['Name'] = $this.Identity
            }
            New-MobileDeviceMailboxPolicy @SetParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Set-MobileDeviceMailboxPolicy @SetParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-MobileDeviceMailboxPolicy -Identity $this.Identity -Confirm:$false
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

        #region Telemetry
        $this.AddTelemetry('Export')
        #endregion

        try
        {
            [array]$policies = Get-MobileDeviceMailboxPolicy -ErrorAction Stop

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $policies)
            {
                $displayedKey = $config.Name
                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Identity              = $config.Name
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

    hidden [EXOActiveSyncMailboxPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOActiveSyncMailboxPolicy])
        {
            return $Values
        }

        $result = [EXOActiveSyncMailboxPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
