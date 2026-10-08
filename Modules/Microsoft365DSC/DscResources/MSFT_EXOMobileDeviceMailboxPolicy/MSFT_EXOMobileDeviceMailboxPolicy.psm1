using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class EXOMobileDeviceMailboxPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the friendly name of the mobile device mailbox policy.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('The AllowApplePushNotifications parameter specifies whether push notifications are allowed to Apple mobile devices.')]
    [System.Nullable[System.Boolean]] $AllowApplePushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBluetooth parameter specifies whether the Bluetooth capabilities are allowed on the mobile phone. The available options are Disable, HandsfreeOnly, and Allow. The default value is Allow.')]
    [ValidateSet('Disable', 'HandsfreeOnly', 'Allow')]
    [System.String] $AllowBluetooth

    [DscProperty()]
    [System.ComponentModel.Description('The AllowBrowser parameter indicates whether Microsoft Pocket Internet Explorer is allowed on the mobile phone. This parameter doesn''t affect third-party browsers.')]
    [System.Nullable[System.Boolean]] $AllowBrowser

    [DscProperty()]
    [System.ComponentModel.Description('The AllowCamera parameter specifies whether the mobile phone''s camera is allowed.')]
    [System.Nullable[System.Boolean]] $AllowCamera

    [DscProperty()]
    [System.ComponentModel.Description('The AllowConsumerEmail parameter specifies whether the mobile phone user can configure a personal email account on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowConsumerEmail

    [DscProperty()]
    [System.ComponentModel.Description('The AllowDesktopSync parameter specifies whether the mobile phone can synchronize with a desktop computer through a cable.')]
    [System.Nullable[System.Boolean]] $AllowDesktopSync

    [DscProperty()]
    [System.ComponentModel.Description('The AllowExternalDeviceManagement parameter specifies whether an external device management program is allowed to manage the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowExternalDeviceManagement

    [DscProperty()]
    [System.ComponentModel.Description('The AllowGooglePushNotifications parameter controls whether the user can receive push notifications from Google for Outlook on the web for devices.')]
    [System.Nullable[System.Boolean]] $AllowGooglePushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The AllowHTMLEmail parameter specifies whether HTML email is enabled on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowHTMLEmail

    [DscProperty()]
    [System.ComponentModel.Description('The AllowInternetSharing parameter specifies whether the mobile phone can be used as a modem to connect a computer to the Internet.')]
    [System.Nullable[System.Boolean]] $AllowInternetSharing

    [DscProperty()]
    [System.ComponentModel.Description('The AllowIrDA parameter specifies whether infrared connections are allowed to the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowIrDA

    [DscProperty()]
    [System.ComponentModel.Description('The AllowMobileOTAUpdate parameter specifies whether the Exchange ActiveSync mailbox policy can be sent to the mobile phone over a cellular data connection.')]
    [System.Nullable[System.Boolean]] $AllowMobileOTAUpdate

    [DscProperty()]
    [System.ComponentModel.Description('The AllowMicrosoftPushNotifications parameter specifies whether push notifications are enabled on the mobile device.')]
    [System.Nullable[System.Boolean]] $AllowMicrosoftPushNotifications

    [DscProperty()]
    [System.ComponentModel.Description('The AllowNonProvisionableDevices parameter specifies whether all mobile phones can synchronize with the server running Exchange.')]
    [System.Nullable[System.Boolean]] $AllowNonProvisionableDevices

    [DscProperty()]
    [System.ComponentModel.Description('The AllowPOPIMAPEmail parameter specifies whether the user can configure a POP3 or IMAP4 email account on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowPOPIMAPEmail

    [DscProperty()]
    [System.ComponentModel.Description('The AllowRemoteDesktop parameter specifies whether the mobile phone can initiate a remote desktop connection.')]
    [System.Nullable[System.Boolean]] $AllowRemoteDesktop

    [DscProperty()]
    [System.ComponentModel.Description('The AllowSimplePassword parameter specifies whether a simple device password is allowed. A simple device password is a password that has a specific pattern, such as 1111 or 1234.')]
    [System.Nullable[System.Boolean]] $AllowSimplePassword

    [DscProperty()]
    [System.ComponentModel.Description('The AllowSMIMEEncryptionAlgorithmNegotiation parameter specifies whether the messaging application on the mobile device can negotiate the encryption algorithm if a recipient''s certificate doesn''t support the specified encryption algorithm.')]
    [ValidateSet('AllowAnyAlgorithmNegotiation', 'BlockNegotiation', 'OnlyStrongAlgorithmNegotiation')]
    [System.String] $AllowSMIMEEncryptionAlgorithmNegotiation

    [DscProperty()]
    [System.ComponentModel.Description('The AllowSMIMESoftCerts parameter specifies whether S/MIME software certificates are allowed.')]
    [System.Nullable[System.Boolean]] $AllowSMIMESoftCerts

    [DscProperty()]
    [System.ComponentModel.Description('The AllowStorageCard parameter specifies whether the mobile phone can access information stored on a storage card.')]
    [System.Nullable[System.Boolean]] $AllowStorageCard

    [DscProperty()]
    [System.ComponentModel.Description('The AllowTextMessaging parameter specifies whether text messaging is allowed from the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowTextMessaging

    [DscProperty()]
    [System.ComponentModel.Description('The AllowUnsignedApplications parameter specifies whether unsigned applications can be installed on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowUnsignedApplications

    [DscProperty()]
    [System.ComponentModel.Description('The AllowUnsignedInstallationPackages parameter specifies whether unsigned installation packages can be executed on the mobile phone.')]
    [System.Nullable[System.Boolean]] $AllowUnsignedInstallationPackages

    [DscProperty()]
    [System.ComponentModel.Description('The AllowWiFi parameter specifies whether wireless Internet access is allowed on the mobile phone. ')]
    [System.Nullable[System.Boolean]] $AllowWiFi

    [DscProperty()]
    [System.ComponentModel.Description('The AlphanumericPasswordRequired parameter specifies whether the password for the mobile phone must be alphanumeric.')]
    [System.Nullable[System.Boolean]] $AlphanumericPasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('The ApprovedApplicationList parameter specifies a list of approved applications for the mobile phone.')]
    [System.String[]] $ApprovedApplicationList

    [DscProperty()]
    [System.ComponentModel.Description('The AttachmentsEnabled parameter specifies whether attachments can be downloaded.')]
    [System.Nullable[System.Boolean]] $AttachmentsEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DeviceEncryptionEnabled parameter specifies whether encryption is enabled.')]
    [System.Nullable[System.Boolean]] $DeviceEncryptionEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The DevicePolicyRefreshInterval parameter specifies how often the policy is sent from the server to the mobile phone.')]
    [System.String] $DevicePolicyRefreshInterval

    [DscProperty()]
    [System.ComponentModel.Description('The IrmEnabled parameter specifies whether Information Rights Management (IRM) is enabled for the mailbox policy.')]
    [System.Nullable[System.Boolean]] $IrmEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The IsDefault parameter specifies whether this policy is the default Mobile Device mailbox policy.')]
    [System.Nullable[System.Boolean]] $IsDefault

    [DscProperty()]
    [System.ComponentModel.Description('The MaxAttachmentSize parameter specifies the maximum size of attachments that can be downloaded to the mobile phone.')]
    [System.String] $MaxAttachmentSize

    [DscProperty()]
    [System.ComponentModel.Description('The MaxCalendarAgeFilter parameter specifies the maximum range of calendar days that can be synchronized to the device.')]
    [ValidateSet('All', 'TwoWeeks', 'OneMonth', 'ThreeMonths', 'SixMonths')]
    [System.String] $MaxCalendarAgeFilter

    [DscProperty()]
    [System.ComponentModel.Description('The MaxEmailAgeFilter parameter specifies the maximum number of days of email items to synchronize to the mobile phone.')]
    [ValidateSet('All', 'OneDay', 'ThreeDays', 'OneWeek', 'TwoWeeks', 'OneMonth')]
    [System.String] $MaxEmailAgeFilter

    [DscProperty()]
    [System.ComponentModel.Description('The MaxEmailBodyTruncationSize parameter specifies the maximum size at which email messages are truncated when synchronized to the mobile phone. The value is specified in kilobytes (KB).')]
    [System.String] $MaxEmailBodyTruncationSize

    [DscProperty()]
    [System.ComponentModel.Description('The MaxEmailHTMLBodyTruncationSize parameter specifies the maximum size at which HTML-formatted email messages are synchronized to the mobile phone. The value is specified in KB.')]
    [System.String] $MaxEmailHTMLBodyTruncationSize

    [DscProperty()]
    [System.ComponentModel.Description('The MaxInactivityTimeDeviceLock parameter specifies the length of time that the mobile phone can be inactive before the password is required to reactivate it.')]
    [System.String] $MaxInactivityTimeLock

    [DscProperty()]
    [System.ComponentModel.Description('The MaxPasswordFailedAttempts parameter specifies the number of attempts a user can make to enter the correct password for the mobile phone. You can enter any number from 4 through 16 or the value Unlimited.')]
    [System.String] $MaxPasswordFailedAttempts

    [DscProperty()]
    [System.ComponentModel.Description('The MinPasswordComplexCharacters parameter specifies the character sets that are required in the password of the mobile device.')]
    [System.Nullable[System.Int32]] $MinPasswordComplexCharacters

    [DscProperty()]
    [System.ComponentModel.Description('The MinPasswordLength parameter specifies the minimum number of characters in the mobile device password.')]
    [System.String] $MinPasswordLength

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordEnabled parameter specifies whether a password is required on the mobile device.')]
    [System.Nullable[System.Boolean]] $PasswordEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordExpiration parameter specifies how long a password can be used on a mobile device before the user is forced to change the password.')]
    [System.String] $PasswordExpiration

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordHistory parameter specifies the number of unique new passwords that need to be created on the mobile device before an old password can be reused.')]
    [System.Nullable[System.Int32]] $PasswordHistory

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordRecoveryEnabled parameter specifies whether the recovery password for the mobile device is stored in Exchange.')]
    [System.Nullable[System.Boolean]] $PasswordRecoveryEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The RequireDeviceEncryption parameter specifies whether encryption is required on the mobile device.')]
    [System.Nullable[System.Boolean]] $RequireDeviceEncryption

    [DscProperty()]
    [System.ComponentModel.Description('The RequireEncryptedSMIMEMessages parameter specifies whether the mobile device must send encrypted S/MIME messages.')]
    [System.Nullable[System.Boolean]] $RequireEncryptedSMIMEMessages

    [DscProperty()]
    [System.ComponentModel.Description('The RequireEncryptionSMIMEAlgorithm parameter specifies the algorithm that''s required to encrypt S/MIME messages on a mobile device.')]
    [ValidateSet('DES', 'TripleDES', 'RC240bit', 'RC264bit', 'RC2128bit')]
    [System.String] $RequireEncryptionSMIMEAlgorithm

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSignedSMIMEAlgorithm parameter specifies the algorithm that''s used to sign S/MIME messages on the mobile device.')]
    [System.Nullable[System.Boolean]] $RequireManualSyncWhenRoaming

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSignedSMIMEAlgorithm parameter specifies the algorithm that''s used to sign S/MIME messages on the mobile device.')]
    [ValidateSet('SHA1', 'MD5')]
    [System.String] $RequireSignedSMIMEAlgorithm

    [DscProperty()]
    [System.ComponentModel.Description('The RequireSignedSMIMEMessages parameter specifies whether the mobile device must send signed S/MIME messages.')]
    [System.Nullable[System.Boolean]] $RequireSignedSMIMEMessages

    [DscProperty()]
    [System.ComponentModel.Description('The RequireStorageCardEncryption parameter specifies whether storage card encryption is required on the mobile device.')]
    [System.Nullable[System.Boolean]] $RequireStorageCardEncryption

    [DscProperty()]
    [System.ComponentModel.Description('The UnapprovedInROMApplicationList parameter specifies a list of applications that can''t be run in ROM on the mobile device.')]
    [System.String[]] $UnapprovedInROMApplicationList

    [DscProperty()]
    [System.ComponentModel.Description('The UNCAccessEnabled parameter specifies whether access to Microsoft Windows file shares is enabled from the mobile device.')]
    [System.Nullable[System.Boolean]] $UNCAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WSSAccessEnabled parameter specifies whether access to Microsoft Windows SharePoint Services is enabled from the mobile device.')]
    [System.Nullable[System.Boolean]] $WSSAccessEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the Mobile Device Mailbox Policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [EXOMobileDeviceMailboxPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [EXOMobileDeviceMailboxPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting Mobile Device Mailbox Policy configuration for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('ExchangeOnline')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                $MobileDeviceMailboxPolicy = Get-MobileDeviceMailboxPolicy -Identity $this.Name -ErrorAction SilentlyContinue
                if ($null -eq $MobileDeviceMailboxPolicy)
                {
                    Write-Verbose -Message "Mobile Device Mailbox Policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $MobileDeviceMailboxPolicy = $this.ExportedInstance
            }

            Write-Verbose -Message "An EXO Mobile Device Mailbox Policy with Name $($MobileDeviceMailboxPolicy.Name) was found."

            $result = @{
                Name                                     = $MobileDeviceMailboxPolicy.Name
                AllowApplePushNotifications              = $MobileDeviceMailboxPolicy.AllowApplePushNotifications
                AllowGooglePushNotifications             = $MobileDeviceMailboxPolicy.AllowGooglePushNotifications
                AllowMicrosoftPushNotifications          = $MobileDeviceMailboxPolicy.AllowMicrosoftPushNotifications
                AllowBluetooth                           = $MobileDeviceMailboxPolicy.AllowBluetooth
                AllowBrowser                             = $MobileDeviceMailboxPolicy.AllowBrowser
                AllowCamera                              = $MobileDeviceMailboxPolicy.AllowCamera
                AllowConsumerEmail                       = $MobileDeviceMailboxPolicy.AllowConsumerEmail
                AllowDesktopSync                         = $MobileDeviceMailboxPolicy.AllowDesktopSync
                AllowExternalDeviceManagement            = $MobileDeviceMailboxPolicy.AllowExternalDeviceManagement
                AllowHTMLEmail                           = $MobileDeviceMailboxPolicy.AllowHTMLEmail
                AllowInternetSharing                     = $MobileDeviceMailboxPolicy.AllowInternetSharing
                AllowIrDA                                = $MobileDeviceMailboxPolicy.AllowIrDA
                AllowMobileOTAUpdate                     = $MobileDeviceMailboxPolicy.AllowMobileOTAUpdate
                AllowNonProvisionableDevices             = $MobileDeviceMailboxPolicy.AllowNonProvisionableDevices
                AllowPOPIMAPEmail                        = $MobileDeviceMailboxPolicy.AllowPOPIMAPEmail
                AllowRemoteDesktop                       = $MobileDeviceMailboxPolicy.AllowRemoteDesktop
                AllowSimplePassword                      = $MobileDeviceMailboxPolicy.AllowSimplePassword
                AllowSMIMEEncryptionAlgorithmNegotiation = $MobileDeviceMailboxPolicy.AllowSMIMEEncryptionAlgorithmNegotiation
                AllowSMIMESoftCerts                      = $MobileDeviceMailboxPolicy.AllowSMIMESoftCerts
                AllowStorageCard                         = $MobileDeviceMailboxPolicy.AllowStorageCard
                AllowTextMessaging                       = $MobileDeviceMailboxPolicy.AllowTextMessaging
                AllowUnsignedApplications                = $MobileDeviceMailboxPolicy.AllowUnsignedApplications
                AllowUnsignedInstallationPackages        = $MobileDeviceMailboxPolicy.AllowUnsignedInstallationPackages
                AllowWiFi                                = $MobileDeviceMailboxPolicy.AllowWiFi
                AlphanumericPasswordRequired             = $MobileDeviceMailboxPolicy.AlphanumericPasswordRequired
                ApprovedApplicationList                  = $MobileDeviceMailboxPolicy.ApprovedApplicationList
                AttachmentsEnabled                       = $MobileDeviceMailboxPolicy.AttachmentsEnabled
                DeviceEncryptionEnabled                  = $MobileDeviceMailboxPolicy.DeviceEncryptionEnabled
                DevicePolicyRefreshInterval              = $MobileDeviceMailboxPolicy.DevicePolicyRefreshInterval
                IrmEnabled                               = $MobileDeviceMailboxPolicy.IrmEnabled
                IsDefault                                = $MobileDeviceMailboxPolicy.IsDefault
                MaxAttachmentSize                        = $MobileDeviceMailboxPolicy.MaxAttachmentSize
                MaxCalendarAgeFilter                     = $MobileDeviceMailboxPolicy.MaxCalendarAgeFilter
                MaxEmailAgeFilter                        = $MobileDeviceMailboxPolicy.MaxEmailAgeFilter
                MaxEmailBodyTruncationSize               = $MobileDeviceMailboxPolicy.MaxEmailBodyTruncationSize
                MaxEmailHTMLBodyTruncationSize           = $MobileDeviceMailboxPolicy.MaxEmailHTMLBodyTruncationSize
                MaxInactivityTimeLock                    = $MobileDeviceMailboxPolicy.MaxInactivityTimeLock
                MaxPasswordFailedAttempts                = $MobileDeviceMailboxPolicy.MaxPasswordFailedAttempts
                MinPasswordComplexCharacters             = $MobileDeviceMailboxPolicy.MinPasswordComplexCharacters
                MinPasswordLength                        = $MobileDeviceMailboxPolicy.MinPasswordLength
                PasswordEnabled                          = $MobileDeviceMailboxPolicy.PasswordEnabled
                PasswordExpiration                       = $MobileDeviceMailboxPolicy.PasswordExpiration
                PasswordHistory                          = $MobileDeviceMailboxPolicy.PasswordHistory
                PasswordRecoveryEnabled                  = $MobileDeviceMailboxPolicy.PasswordRecoveryEnabled
                RequireDeviceEncryption                  = $MobileDeviceMailboxPolicy.RequireDeviceEncryption
                RequireEncryptedSMIMEMessages            = $MobileDeviceMailboxPolicy.RequireSignedSMIMEMessages
                RequireEncryptionSMIMEAlgorithm          = $MobileDeviceMailboxPolicy.RequireEncryptionSMIMEAlgorithm
                RequireManualSyncWhenRoaming             = $MobileDeviceMailboxPolicy.RequireManualSyncWhenRoaming
                RequireSignedSMIMEAlgorithm              = $MobileDeviceMailboxPolicy.RequireSignedSMIMEAlgorithm
                RequireSignedSMIMEMessages               = $MobileDeviceMailboxPolicy.RequireSignedSMIMEMessages
                RequireStorageCardEncryption             = $MobileDeviceMailboxPolicy.RequireStorageCardEncryption
                UnapprovedInROMApplicationList           = $MobileDeviceMailboxPolicy.UnapprovedInROMApplicationList
                UNCAccessEnabled                         = $MobileDeviceMailboxPolicy.UNCAccessEnabled
                WSSAccessEnabled                         = $MobileDeviceMailboxPolicy.WSSAccessEnabled
                Ensure                                   = 'Present'
                Credential                               = $this.Credential
                ApplicationId                            = $this.ApplicationId
                CertificateThumbprint                    = $this.CertificateThumbprint
                CertificatePath                          = $this.CertificatePath
                CertificatePassword                      = $this.CertificatePassword
                ManagedIdentity                          = $this.ManagedIdentity
                TenantId                                 = $this.TenantId
                AccessTokens                             = $this.AccessTokens
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

        Write-Verbose -Message "Setting Mobile Device Mailbox Policy configuration for $($this.Name)"

        $currentMobileDeviceMailboxPolicyConfig = $this.Get().ToHashtable()

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $null = $this.Connect('ExchangeOnline')

        $NewMobileDeviceMailboxPolicyParams = @{
            Name                                     = $this.Name
            AllowApplePushNotifications              = $this.AllowApplePushNotifications
            AllowGooglePushNotifications             = $this.AllowGooglePushNotifications
            AllowMicrosoftPushNotifications          = $this.AllowMicrosoftPushNotifications
            AllowBluetooth                           = $this.AllowBluetooth
            AllowBrowser                             = $this.AllowBrowser
            AllowCamera                              = $this.AllowCamera
            AllowConsumerEmail                       = $this.AllowConsumerEmail
            AllowDesktopSync                         = $this.AllowDesktopSync
            AllowExternalDeviceManagement            = $this.AllowExternalDeviceManagement
            AllowHTMLEmail                           = $this.AllowHTMLEmail
            AllowInternetSharing                     = $this.AllowInternetSharing
            AllowIrDA                                = $this.AllowIrDA
            AllowMobileOTAUpdate                     = $this.AllowMobileOTAUpdate
            AllowNonProvisionableDevices             = $this.AllowNonProvisionableDevices
            AllowPOPIMAPEmail                        = $this.AllowPOPIMAPEmail
            AllowRemoteDesktop                       = $this.AllowRemoteDesktop
            AllowSimplePassword                      = $this.AllowSimplePassword
            AllowSMIMEEncryptionAlgorithmNegotiation = $this.AllowSMIMEEncryptionAlgorithmNegotiation
            AllowSMIMESoftCerts                      = $this.AllowSMIMESoftCerts
            AllowStorageCard                         = $this.AllowStorageCard
            AllowTextMessaging                       = $this.AllowTextMessaging
            AllowUnsignedApplications                = $this.AllowUnsignedApplications
            AllowUnsignedInstallationPackages        = $this.AllowUnsignedInstallationPackages
            AllowWiFi                                = $this.AllowWiFi
            AlphanumericPasswordRequired             = $this.AlphanumericPasswordRequired
            ApprovedApplicationList                  = $this.ApprovedApplicationList
            AttachmentsEnabled                       = $this.AttachmentsEnabled
            DeviceEncryptionEnabled                  = $this.DeviceEncryptionEnabled
            DevicePolicyRefreshInterval              = $this.DevicePolicyRefreshInterval
            IrmEnabled                               = $this.IrmEnabled
            IsDefault                                = $this.IsDefault
            MaxAttachmentSize                        = $this.MaxAttachmentSize
            MaxCalendarAgeFilter                     = $this.MaxCalendarAgeFilter
            MaxEmailAgeFilter                        = $this.MaxEmailAgeFilter
            MaxEmailBodyTruncationSize               = $this.MaxEmailBodyTruncationSize
            MaxEmailHTMLBodyTruncationSize           = $this.MaxEmailHTMLBodyTruncationSize
            MaxInactivityTimeLock                    = $this.MaxInactivityTimeLock
            MaxPasswordFailedAttempts                = $this.MaxPasswordFailedAttempts
            MinPasswordComplexCharacters             = $this.MinPasswordComplexCharacters
            MinPasswordLength                        = $this.MinPasswordLength
            PasswordEnabled                          = $this.PasswordEnabled
            PasswordExpiration                       = $this.PasswordExpiration
            PasswordHistory                          = $this.PasswordHistory
            PasswordRecoveryEnabled                  = $this.PasswordRecoveryEnabled
            RequireDeviceEncryption                  = $this.RequireDeviceEncryption
            RequireEncryptedSMIMEMessages            = $this.RequireSignedSMIMEMessages
            RequireEncryptionSMIMEAlgorithm          = $this.RequireEncryptionSMIMEAlgorithm
            RequireManualSyncWhenRoaming             = $this.RequireManualSyncWhenRoaming
            RequireSignedSMIMEAlgorithm              = $this.RequireSignedSMIMEAlgorithm
            RequireSignedSMIMEMessages               = $this.RequireSignedSMIMEMessages
            RequireStorageCardEncryption             = $this.RequireStorageCardEncryption
            UnapprovedInROMApplicationList           = $this.UnapprovedInROMApplicationList
            UNCAccessEnabled                         = $this.UNCAccessEnabled
            WSSAccessEnabled                         = $this.WSSAccessEnabled
            Confirm                                  = $false
        }
        $NewMobileDeviceMailboxPolicyParams = Remove-NullEntriesFromHashtable -Hash $NewMobileDeviceMailboxPolicyParams

        $SetMobileDeviceMailboxPolicyParams = $NewMobileDeviceMailboxPolicyParams.Clone()
        $SetMobileDeviceMailboxPolicyParams.Add('Identity', $this.Name)

        # Remove the MinPasswordLength property if it is empty
        if ([System.String]::IsNullOrEmpty($this.MinPasswordLength))
        {
            $NewMobileDeviceMailboxPolicyParams.Remove('MinPasswordLength') | Out-Null
            $SetMobileDeviceMailboxPolicyParams.Remove('MinPasswordLength') | Out-Null
        }

        # CASE: Mobile Device Mailbox Policy doesn't exist but should;
        if ($this.Ensure -eq 'Present' -and $currentMobileDeviceMailboxPolicyConfig.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Mobile Device Mailbox Policy '$($this.Name)' does not exist but it should. Create and configure it."
            # Create Mobile Device Mailbox Policy
            New-MobileDeviceMailboxPolicy @NewMobileDeviceMailboxPolicyParams

        }
        # CASE: Mobile Device Mailbox Policy exists but it shouldn't;
        elseif ($this.Ensure -eq 'Absent' -and $currentMobileDeviceMailboxPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Mobile Device Mailbox Policy '$($this.Name)' exists but it shouldn't. Remove it."
            Remove-MobileDeviceMailboxPolicy -Identity $this.Name -Confirm:$false
        }
        # CASE: Mobile Device Mailbox Policy exists and it should, but has different values than the desired ones
        elseif ($this.Ensure -eq 'Present' -and $currentMobileDeviceMailboxPolicyConfig.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Mobile Device Mailbox Policy '$($this.Name)' already exists, but needs updating."
            Write-Verbose -Message "Setting Mobile Device Mailbox Policy $($this.Name) with values: $(Convert-M365DscHashtableToString -Hashtable $SetMobileDeviceMailboxPolicyParams)"
            Set-MobileDeviceMailboxPolicy @SetMobileDeviceMailboxPolicyParams
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
            [array]$AllMobileDeviceMailboxPolicies = Get-MobileDeviceMailboxPolicy -ErrorAction Stop
            $dscContent = [System.Text.StringBuilder]::new()

            if ($AllMobileDeviceMailboxPolicies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            $i = 1
            foreach ($MobileDeviceMailboxPolicy in $AllMobileDeviceMailboxPolicies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($AllMobileDeviceMailboxPolicies.Length)] $($MobileDeviceMailboxPolicy.Name)" -DeferWrite

                $Params = @{
                    Name                  = $MobileDeviceMailboxPolicy.Name
                    Credential            = $this.Credential
                    ApplicationId         = $this.ApplicationId
                    TenantId              = $this.TenantId
                    CertificateThumbprint = $this.CertificateThumbprint
                    CertificatePassword   = $this.CertificatePassword
                    ManagedIdentity       = $this.ManagedIdentity
                    CertificatePath       = $this.CertificatePath
                    AccessTokens          = $this.AccessTokens
                }
                $this.ExportedInstance = $MobileDeviceMailboxPolicy
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [EXOMobileDeviceMailboxPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [EXOMobileDeviceMailboxPolicy])
        {
            return $Values
        }

        $result = [EXOMobileDeviceMailboxPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
