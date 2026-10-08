using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationPolicyMacOS : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('When TRUE, activation lock is allowed when the device is in supervised mode. When FALSE, activation lock is not allowed.')]
    [System.Nullable[System.Boolean]] $ActivationLockWhenSupervisedAllowed

    [DscProperty()]
    [System.ComponentModel.Description('Configures users from adding friends to Game Center. Available for devices running macOS versions 10.13 and later.')]
    [System.Nullable[System.Boolean]] $AddingGameCenterFriendsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to allow AirDrop.')]
    [System.Nullable[System.Boolean]] $AirDropBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocks users from unlocking their Mac with Apple Watch.')]
    [System.Nullable[System.Boolean]] $AppleWatchBlockAutoUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Blocks users from taking photographs and videos.')]
    [System.Nullable[System.Boolean]] $CameraBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocks AirPlay, screen sharing to other devices, and a Classroom app feature used by teachers to view their students'' screens. This setting isn''t available if you''ve blocked screenshots.')]
    [System.Nullable[System.Boolean]] $ClassroomAppBlockRemoteScreenObservation

    [DscProperty()]
    [System.ComponentModel.Description('Unprompted observation means that teachers can view screens without warning students first. This setting isn''t available if you''ve blocked screenshots.')]
    [System.Nullable[System.Boolean]] $ClassroomAppForceUnpromptedScreenObservation

    [DscProperty()]
    [System.ComponentModel.Description('Students can join a class without prompting the teacher.')]
    [System.Nullable[System.Boolean]] $ClassroomForceAutomaticallyJoinClasses

    [DscProperty()]
    [System.ComponentModel.Description('Students enrolled in an unmanaged Classroom course must get teacher consent to leave the course.')]
    [System.Nullable[System.Boolean]] $ClassroomForceRequestPermissionToLeaveClasses

    [DscProperty()]
    [System.ComponentModel.Description('Teachers can lock a student''s device or app without the student''s approval.')]
    [System.Nullable[System.Boolean]] $ClassroomForceUnpromptedAppAndDeviceLock

    [DscProperty()]
    [System.ComponentModel.Description('Device compliance can be viewed in the Restricted Apps Compliance report.')]
    [ValidateSet('none', 'appsInListCompliant', 'appsNotInListCompliant')]
    [System.String] $CompliantAppListType

    [DscProperty()]
    [System.ComponentModel.Description('List of apps in the compliance (either allow list or block list, controlled by CompliantAppListType).')]
    [MSFT_MicrosoftGraphapplistitemMacOS[]] $CompliantAppsList

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to allow content caching.')]
    [System.Nullable[System.Boolean]] $ContentCachingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block look up, a feature that looks up the definition of a highlighted word.')]
    [System.Nullable[System.Boolean]] $DefinitionLookupBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Emails that the user sends or receives which don''t match the domains you specify here will be marked as untrusted. ')]
    [System.String[]] $EmailInDomainSuffixes

    [DscProperty()]
    [System.ComponentModel.Description('Configures the reset option on supervised devices. Available for devices running macOS versions 12.0 and later.')]
    [System.Nullable[System.Boolean]] $EraseContentAndSettingsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configured if the Game Center icon is removed from the Home screen. Available for devices running macOS versions 10.13 and later.')]
    [System.Nullable[System.Boolean]] $GameCenterBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Handoff lets users start work on one MacOS device, and continue it on another MacOS or iOS device. Available for macOS 10.15 and later.')]
    [System.Nullable[System.Boolean]] $ICloudBlockActivityContinuation

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing contacts.')]
    [System.Nullable[System.Boolean]] $ICloudBlockAddressBook

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing bookmarks.')]
    [System.Nullable[System.Boolean]] $ICloudBlockBookmarks

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing calendars.')]
    [System.Nullable[System.Boolean]] $ICloudBlockCalendar

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing documents and data.')]
    [System.Nullable[System.Boolean]] $ICloudBlockDocumentSync

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing mail.')]
    [System.Nullable[System.Boolean]] $ICloudBlockMail

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing notes.')]
    [System.Nullable[System.Boolean]] $ICloudBlockNotes

    [DscProperty()]
    [System.ComponentModel.Description('Any photos not fully downloaded from iCloud Photo Library to device will be removed from local storage.')]
    [System.Nullable[System.Boolean]] $ICloudBlockPhotoLibrary

    [DscProperty()]
    [System.ComponentModel.Description('Blocks iCloud from syncing reminders.')]
    [System.Nullable[System.Boolean]] $ICloudBlockReminders

    [DscProperty()]
    [System.ComponentModel.Description('Configures if the synchronization of cloud desktop and documents is blocked. Available for devices running macOS 10.12.4 and later.')]
    [System.Nullable[System.Boolean]] $ICloudDesktopAndDocumentsBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures if iCloud private relay is blocked or not. Available for devices running macOS 12 and later.')]
    [System.Nullable[System.Boolean]] $ICloudPrivateRelayBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Blocks files from being transferred using iTunes.')]
    [System.Nullable[System.Boolean]] $ITunesBlockFileSharing

    [DscProperty()]
    [System.ComponentModel.Description('Configures  whether or not to block files from being transferred using iTunes.')]
    [System.Nullable[System.Boolean]] $ITunesBlockMusicService

    [DscProperty()]
    [System.ComponentModel.Description('Block dictation, which is a feature that converts the user''s voice to text.')]
    [System.Nullable[System.Boolean]] $KeyboardBlockDictation

    [DscProperty()]
    [System.ComponentModel.Description('Disables syncing credentials stored in the Keychain to iCloud')]
    [System.Nullable[System.Boolean]] $KeychainBlockCloudSync

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether multiplayer gaming when using Game Center is blocked. Available for devices running macOS versions 10.13 and later.')]
    [System.Nullable[System.Boolean]] $MultiplayerGamingBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to block sharing passwords with the AirDrop passwords feature.')]
    [System.Nullable[System.Boolean]] $PasswordBlockAirDropSharing

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to block the AutoFill Passwords feature.')]
    [System.Nullable[System.Boolean]] $PasswordBlockAutoFill

    [DscProperty()]
    [System.ComponentModel.Description('Requires user to set a non-biometric passcode or password to unlock the device.')]
    [System.Nullable[System.Boolean]] $PasswordBlockFingerprintUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Blocks user from changing the set passcode.')]
    [System.Nullable[System.Boolean]] $PasswordBlockModification

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to block requesting passwords from nearby devices.')]
    [System.Nullable[System.Boolean]] $PasswordBlockProximityRequests

    [DscProperty()]
    [System.ComponentModel.Description('Block simple password sequences, such as 1234 or 1111.')]
    [System.Nullable[System.Boolean]] $PasswordBlockSimple

    [DscProperty()]
    [System.ComponentModel.Description('Number of days until device password must be changed. (1-65535)')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('Configures the number of allowed failed attempts to enter the passcode at the device''s lock screen. Valid values 2 to 11')]
    [System.Nullable[System.UInt32]] $PasswordMaximumAttemptCount

    [DscProperty()]
    [System.ComponentModel.Description('Minimum number (0-4) of non-alphanumeric characters, such as #, %, !, etc., required in the password. The default value is 0.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumCharacterSetCount

    [DscProperty()]
    [System.ComponentModel.Description('Minimum number of digits or characters in password (4-16).')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('Set to 0 to require a password immediately. There is no maximum number of minutes, and this number overrides the number currently set on the device.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeLock

    [DscProperty()]
    [System.ComponentModel.Description('Set to 0 to use the device''s minimum possible value. This number (0-60 minutes) overrides the number currently set on the device.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesOfInactivityBeforeScreenTimeout

    [DscProperty()]
    [System.ComponentModel.Description('Configures the number of minutes before the login is reset after the maximum number of unsuccessful login attempts is reached.')]
    [System.Nullable[System.UInt32]] $PasswordMinutesUntilFailedLoginReset

    [DscProperty()]
    [System.ComponentModel.Description('Number of new passwords that must be used until an old one can be reused. (1-24)')]
    [System.Nullable[System.UInt32]] $PasswordPreviousPasswordBlockCount

    [DscProperty()]
    [System.ComponentModel.Description('Specify the type of password required.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('Specify the type of password required.')]
    [ValidateSet('deviceDefault', 'alphanumeric', 'numeric')]
    [System.String] $PasswordRequiredType

    [DscProperty()]
    [System.ComponentModel.Description('Configure an app''s access to specific data, folders, and apps on a device. These settings apply to devices running macOS Mojave 10.14 and later.')]
    [MSFT_MicrosoftGraphmacosprivacyaccesscontrolitem[]] $PrivacyAccessControls

    [DscProperty()]
    [System.ComponentModel.Description('Blocks Safari from remembering what users enter in web forms.')]
    [System.Nullable[System.Boolean]] $SafariBlockAutofill

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether or not to block the user from taking Screenshots.')]
    [System.Nullable[System.Boolean]] $ScreenCaptureBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of days (1-90) to delay visibility of major OS software updates. Available for devices running macOS versions 11.3 and later. Valid values 0 to 90')]
    [System.Nullable[System.UInt32]] $SoftwareUpdateMajorOSDeferredInstallDelayInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of days (1-90) to delay visibility of minor OS software updates. Available for devices running macOS versions 11.3 and later. Valid values 0 to 90')]
    [System.Nullable[System.UInt32]] $SoftwareUpdateMinorOSDeferredInstallDelayInDays

    [DscProperty()]
    [System.ComponentModel.Description('Specify the number of days (1-90) to delay visibility of non-OS software updates. Available for devices running macOS versions 11.3 and later. Valid values 0 to 90')]
    [System.Nullable[System.UInt32]] $SoftwareUpdateNonOSDeferredInstallDelayInDays

    [DscProperty()]
    [System.ComponentModel.Description('Delay the user''s software update for this many days. The maximum is 90 days. (1-90)')]
    [System.Nullable[System.UInt32]] $SoftwareUpdatesEnforcedDelayInDays

    [DscProperty()]
    [System.ComponentModel.Description('Blocks Spotlight from returning any results from an Internet search')]
    [System.Nullable[System.Boolean]] $SpotlightBlockInternetResults

    [DscProperty()]
    [System.ComponentModel.Description('Configures the maximum hours after which the user must enter their password to unlock the device instead of using Touch ID. Available for devices running macOS 12 and later. Valid values 0 to 2147483647')]
    [System.Nullable[System.UInt32]] $TouchIdTimeoutInHours

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether to delay OS and/or app updates for macOS.')]
    [ValidateSet('none', 'delayOSUpdateVisibility', 'delayAppUpdateVisibility', 'unknownFutureValue', 'delayMajorOsUpdateVisibility')]
    [System.String[]] $UpdateDelayPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Configures whether the wallpaper can be changed. Available for devices running macOS versions 10.13 and later.')]
    [System.Nullable[System.Boolean]] $WallpaperModificationBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    # Export-only. Not part of the resource schema.
    [System.String] $Filter

    [IntuneDeviceConfigurationPolicyMacOS] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationPolicyMacOS]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Policy for MacOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $getValue = $null
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -Filter "Id eq '$($this.Id)'" -All -ErrorAction SilentlyContinue
                }

                #region resource generator code
                if ($null -eq $getValue)
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "DisplayName eq '$($this.Displayname -replace "'", "''")' and isof('microsoft.graph.macOSGeneralDeviceConfiguration')" -ErrorAction SilentlyContinue
                }
                #endregion

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Nothing with id {$($this.Id)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $updateDelayPolicyValue = @()
            if (-not [System.String]::IsNullOrEmpty($getValue.updateDelayPolicy))
            {
                foreach ($policy in ($getValue.updateDelayPolicy -split "," | Where-Object { -not [System.String]::IsNullOrEmpty($_) }))
                {
                    $updateDelayPolicyValue += $policy
                }
            }

            Write-Verbose -Message "Found something with id {$($getValue.Id)}"
            $results = @{

                #region resource generator code
                Id                                              = $getValue.Id
                Description                                     = $getValue.Description
                DisplayName                                     = $getValue.DisplayName
                RoleScopeTagIds                                 = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                ActivationLockWhenSupervisedAllowed             = $getValue.activationLockWhenSupervisedAllowed
                AddingGameCenterFriendsBlocked                  = $getValue.addingGameCenterFriendsBlocked
                AirDropBlocked                                  = $getValue.airDropBlocked
                AppleWatchBlockAutoUnlock                       = $getValue.appleWatchBlockAutoUnlock
                CameraBlocked                                   = $getValue.cameraBlocked
                ClassroomAppBlockRemoteScreenObservation        = $getValue.classroomAppBlockRemoteScreenObservation
                ClassroomAppForceUnpromptedScreenObservation    = $getValue.classroomAppForceUnpromptedScreenObservation
                ClassroomForceAutomaticallyJoinClasses          = $getValue.classroomForceAutomaticallyJoinClasses
                ClassroomForceRequestPermissionToLeaveClasses   = $getValue.classroomForceRequestPermissionToLeaveClasses
                ClassroomForceUnpromptedAppAndDeviceLock        = $getValue.classroomForceUnpromptedAppAndDeviceLock
                CompliantAppListType                            = $getValue.compliantAppListType
                ContentCachingBlocked                           = $getValue.contentCachingBlocked
                DefinitionLookupBlocked                         = $getValue.definitionLookupBlocked
                EmailInDomainSuffixes                           = $getValue.emailInDomainSuffixes
                EraseContentAndSettingsBlocked                  = $getValue.eraseContentAndSettingsBlocked
                GameCenterBlocked                               = $getValue.gameCenterBlocked
                ICloudBlockActivityContinuation                 = $getValue.iCloudBlockActivityContinuation
                ICloudBlockAddressBook                          = $getValue.iCloudBlockAddressBook
                ICloudBlockBookmarks                            = $getValue.iCloudBlockBookmarks
                ICloudBlockCalendar                             = $getValue.iCloudBlockCalendar
                ICloudBlockDocumentSync                         = $getValue.iCloudBlockDocumentSync
                ICloudBlockMail                                 = $getValue.iCloudBlockMail
                ICloudBlockNotes                                = $getValue.iCloudBlockNotes
                ICloudBlockPhotoLibrary                         = $getValue.iCloudBlockPhotoLibrary
                ICloudBlockReminders                            = $getValue.iCloudBlockReminders
                ICloudDesktopAndDocumentsBlocked                = $getValue.iCloudDesktopAndDocumentsBlocked
                ICloudPrivateRelayBlocked                       = $getValue.iCloudPrivateRelayBlocked
                ITunesBlockFileSharing                          = $getValue.iTunesBlockFileSharing
                ITunesBlockMusicService                         = $getValue.iTunesBlockMusicService
                KeyboardBlockDictation                          = $getValue.keyboardBlockDictation
                KeychainBlockCloudSync                          = $getValue.keychainBlockCloudSync
                MultiplayerGamingBlocked                        = $getValue.multiplayerGamingBlocked
                PasswordBlockAirDropSharing                     = $getValue.passwordBlockAirDropSharing
                PasswordBlockAutoFill                           = $getValue.passwordBlockAutoFill
                PasswordBlockFingerprintUnlock                  = $getValue.passwordBlockFingerprintUnlock
                PasswordBlockModification                       = $getValue.passwordBlockModification
                PasswordBlockProximityRequests                  = $getValue.passwordBlockProximityRequests
                PasswordBlockSimple                             = $getValue.passwordBlockSimple
                PasswordExpirationDays                          = $getValue.passwordExpirationDays
                PasswordMaximumAttemptCount                     = $getValue.passwordMaximumAttemptCount
                PasswordMinimumCharacterSetCount                = $getValue.passwordMinimumCharacterSetCount
                PasswordMinimumLength                           = $getValue.passwordMinimumLength
                PasswordMinutesOfInactivityBeforeLock           = $getValue.passwordMinutesOfInactivityBeforeLock
                PasswordMinutesOfInactivityBeforeScreenTimeout  = $getValue.passwordMinutesOfInactivityBeforeScreenTimeout
                PasswordMinutesUntilFailedLoginReset            = $getValue.passwordMinutesUntilFailedLoginReset
                PasswordPreviousPasswordBlockCount              = $getValue.passwordPreviousPasswordBlockCount
                PasswordRequired                                = $getValue.passwordRequired
                PasswordRequiredType                            = $getValue.passwordRequiredType
                SafariBlockAutofill                             = $getValue.safariBlockAutofill
                ScreenCaptureBlocked                            = $getValue.screenCaptureBlocked
                SoftwareUpdateMajorOSDeferredInstallDelayInDays = $getValue.softwareUpdateMajorOSDeferredInstallDelayInDays
                SoftwareUpdateMinorOSDeferredInstallDelayInDays = $getValue.softwareUpdateMinorOSDeferredInstallDelayInDays
                SoftwareUpdateNonOSDeferredInstallDelayInDays   = $getValue.softwareUpdateNonOSDeferredInstallDelayInDays
                SoftwareUpdatesEnforcedDelayInDays              = $getValue.softwareUpdatesEnforcedDelayInDays
                SpotlightBlockInternetResults                   = $getValue.spotlightBlockInternetResults
                TouchIdTimeoutInHours                           = $getValue.touchIdTimeoutInHours
                UpdateDelayPolicy                               = $updateDelayPolicyValue
                WallpaperModificationBlocked                    = $getValue.wallpaperModificationBlocked
                Ensure                                          = 'Present'
                Credential                                      = $this.Credential
                ApplicationId                                   = $this.ApplicationId
                TenantId                                        = $this.TenantId
                ApplicationSecret                               = $this.ApplicationSecret
                CertificateThumbprint                           = $this.CertificateThumbprint
                CertificatePath                                 = $this.CertificatePath
                CertificatePassword                             = $this.CertificatePassword
                ManagedIdentity                                 = $this.ManagedIdentity
                AccessTokens                                    = $this.AccessTokens
            }
            if ($getValue.compliantAppsList)
            {
                $results.Add('CompliantAppsList', $getValue.compliantAppsList)
            }
            if ($getValue.privacyAccessControls)
            {
                $results.Add('PrivacyAccessControls', $getValue.privacyAccessControls)
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $getValue.Id
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($assignmentsValues)
            }
            $results.Add('Assignments', $assignmentResult)

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

        Write-Verbose -Message "Setting configuration of the Intune Device Configuration Policy for MacOS with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $boundParameters = $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($this.UpdateDelayPolicy.Count -gt 0)
        {
            $boundParameters.UpdateDelayPolicy = $this.UpdateDelayPolicy -join ','
        }
        else
        {
            $boundParameters.UpdateDelayPolicy = 'none'
        }

        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $boundParameters
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null
            $createParameters.Add('@odata.type', '#microsoft.graph.macOSGeneralDeviceConfiguration')

            #region resource generator code
            $policy = New-MgBetaDeviceManagementDeviceConfiguration -BodyParameter $createParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceConfigurations'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating {$($this.DisplayName)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Add('@odata.type', '#microsoft.graph.macOSGeneralDeviceConfiguration')

            #region resource generator code
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -BodyParameter $updateParameters `
                -DeviceConfigurationId $currentInstance.Id

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing {$($this.DisplayName)}"

            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceConfiguration -DeviceConfigurationId $currentInstance.Id
            #endregion
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
            #region resource generator code
            [array]$getValue = Get-M365DSCExportCachedCollection -Collection 'deviceConfigurations' `
                -ODataType 'microsoft.graph.macOSGeneralDeviceConfiguration' `
                -Filter $this.Filter
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $getValue)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $($config.DisplayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
                    DisplayName           = $config.DisplayName
                    Ensure                = 'Present'
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

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($Results.CompliantAppsList)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.CompliantAppsList -CIMInstanceName MicrosoftGraphapplistitemMacOS
                    if ($complexTypeStringResult)
                    {
                        $Results.CompliantAppsList = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('CompliantAppsList') | Out-Null
                    }
                }
                if ($Results.PrivacyAccessControls)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.PrivacyAccessControls -CIMInstanceName MicrosoftGraphmacosprivacyaccesscontrolitem
                    if ($complexTypeStringResult)
                    {
                        $Results.PrivacyAccessControls = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PrivacyAccessControls') | Out-Null
                    }
                }

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('CompliantAppsList', 'PrivacyAccessControls', 'Assignments') `
                    -RawResults $rawResults

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
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Request not applicable to target tenant*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) The current tenant is not registered for Intune."
            }
            else
            {
                $this.LogError($_, 'Error during Export:')

                throw
            }
        }

        # Every code path must return in a method with a declared return type.
        return ''
    }

    hidden [IntuneDeviceConfigurationPolicyMacOS] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationPolicyMacOS])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationPolicyMacOS]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphapplistitemMacOS
{
    [DscProperty()]
    [System.ComponentModel.Description('Specify the odataType')]
    [ValidateSet('#microsoft.graph.appleAppListItem')]
    [System.String] $odataType

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The application or bundle identifier of the application')]
    [System.String] $appId

    [DscProperty()]
    [System.ComponentModel.Description('The Store URL of the application')]
    [System.String] $appStoreUrl

    [DscProperty()]
    [System.ComponentModel.Description('The application name')]
    [System.String] $name

    [DscProperty()]
    [System.ComponentModel.Description('The publisher of the application')]
    [System.String] $publisher
}

class MSFT_MicrosoftGraphmacosprivacyaccesscontrolitem
{
    [DscProperty()]
    [System.ComponentModel.Description('Allow the app or process to control the Mac via the Accessibility subsystem.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $accessibility

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to contact information managed by Contacts.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $addressBook

    [DscProperty()]
    [System.ComponentModel.Description('Allow or deny the app or process to send a restricted Apple event to another app or process. You will need to know the identifier, identifier type, and code requirement of the receiving app or process.')]
    [MSFT_MicrosoftGraphmacosappleeventreceiver[]] $appleEventsAllowedReceivers

    [DscProperty()]
    [System.ComponentModel.Description('Block access to camera app.')]
    [System.Nullable[System.Boolean]] $blockCamera

    [DscProperty()]
    [System.ComponentModel.Description('Block the app or process from listening to events from input devices such as mouse, keyboard, and trackpad.Requires macOS 10.15 or later.')]
    [System.Nullable[System.Boolean]] $blockListenEvent

    [DscProperty()]
    [System.ComponentModel.Description('Block access to microphone.')]
    [System.Nullable[System.Boolean]] $blockMicrophone

    [DscProperty()]
    [System.ComponentModel.Description('Block app from capturing contents of system display. Requires macOS 10.15 or later.')]
    [System.Nullable[System.Boolean]] $blockScreenCapture

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to event information managed by Calendar.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $calendar

    [DscProperty()]
    [System.ComponentModel.Description('Enter the code requirement, which can be obtained with the command ''codesign -display -r -'' in the Terminal app. Include everything after ''=>''.')]
    [System.String] $codeRequirement

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the app, process, or executable.')]
    [System.String] $displayName

    [DscProperty()]
    [System.ComponentModel.Description('Allow the app or process to access files managed by another app''s file provider extension. Requires macOS 10.15 or later.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $fileProviderPresence

    [DscProperty()]
    [System.ComponentModel.Description('The bundle ID or path of the app, process, or executable.')]
    [System.String] $identifier

    [DscProperty()]
    [System.ComponentModel.Description('A bundle ID is used to identify an app. A path is used to identify a process or executable.')]
    [ValidateSet('bundleID', 'path')]
    [System.String] $identifierType

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to music and the media library.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $mediaLibrary

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to images managed by Photos.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $photos

    [DscProperty()]
    [System.ComponentModel.Description('Control access to CoreGraphics APIs, which are used to send CGEvents to the system event stream.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $postEvent

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to information managed by Reminders.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $reminders

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to system speech recognition facility.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $speechRecognition

    [DscProperty()]
    [System.ComponentModel.Description('Statically validates the code requirement. Use this setting if the process invalidates its dynamic code signature.')]
    [System.Nullable[System.Boolean]] $staticCodeValidation

    [DscProperty()]
    [System.ComponentModel.Description('Control access to all protected files on a device. Files might be in locations such as emails, messages, apps, and administrative settings. Apply this setting with caution.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyAllFiles

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to Desktop folder.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyDesktopFolder

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to Documents folder.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyDocumentsFolder

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to Downloads folder.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyDownloadsFolder

    [DscProperty()]
    [System.ComponentModel.Description('Allow or block access to network volumes. Requires macOS 10.15 or later.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyNetworkVolumes

    [DscProperty()]
    [System.ComponentModel.Description('Control access to removable volumes on the device, such as an external hard drive. Requires macOS 10.15 or later.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicyRemovableVolumes

    [DscProperty()]
    [System.ComponentModel.Description('Allow app or process to access files used in system administration.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $systemPolicySystemAdminFiles
}

class MSFT_DeviceManagementConfigurationPolicyAssignments
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('The type of the target assignment.')]
    [ValidateSet('#microsoft.graph.cloudPcManagementGroupAssignmentTarget', '#microsoft.graph.groupAssignmentTarget', '#microsoft.graph.allLicensedUsersAssignmentTarget', '#microsoft.graph.allDevicesAssignmentTarget', '#microsoft.graph.exclusionGroupAssignmentTarget', '#microsoft.graph.configurationManagerCollectionAssignmentTarget')]
    [System.String] $dataType

    [DscProperty()]
    [System.ComponentModel.Description('The type of filter of the target assignment i.e. Exclude or Include. Possible values are:none, include, exclude.')]
    [ValidateSet('none', 'include', 'exclude')]
    [System.String] $deviceAndAppManagementAssignmentFilterType

    [DscProperty()]
    [System.ComponentModel.Description('The Id of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterId

    [DscProperty()]
    [System.ComponentModel.Description('The display name of the filter for the target assignment.')]
    [System.String] $deviceAndAppManagementAssignmentFilterDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The group Id that is the target of the assignment.')]
    [System.String] $groupId

    [DscProperty()]
    [System.ComponentModel.Description('The group Display Name that is the target of the assignment.')]
    [System.String] $groupDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The collection Id that is the target of the assignment.(ConfigMgr)')]
    [System.String] $collectionId
}

class MSFT_MicrosoftGraphmacosappleeventreceiver
{
    [DscProperty()]
    [System.ComponentModel.Description('Allow or block this app from receiving Apple events.')]
    [System.Nullable[System.Boolean]] $allowed

    [DscProperty()]
    [System.ComponentModel.Description('Code requirement for the app or binary that receives the Apple Event.')]
    [System.String] $codeRequirement

    [DscProperty()]
    [System.ComponentModel.Description('Bundle ID of the app or file path of the process or executable that receives the Apple Event.')]
    [System.String] $identifier

    [DscProperty()]
    [System.ComponentModel.Description('Use bundle ID for an app or path for a process or executable that receives the Apple Event.')]
    [ValidateSet('bundleID', 'path')]
    [System.String] $identifierType
}
