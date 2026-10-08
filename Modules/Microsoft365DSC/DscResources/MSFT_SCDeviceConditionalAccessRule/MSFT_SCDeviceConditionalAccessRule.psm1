using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCDeviceConditionalAccessRule : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Name for the rule.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Name of the associated policy.')]
    [System.String] $Policy

    [DscProperty()]
    [System.ComponentModel.Description('The display names of the graoups targeted by the policy.')]
    [System.String[]] $TargetGroups

    [DscProperty()]
    [System.ComponentModel.Description('The AccountName parameter specifies the account name.')]
    [System.String] $AccountName

    [DscProperty()]
    [System.ComponentModel.Description('The AccountUserName parameter specifies the account user name.')]
    [System.String] $AccountUserName

    [DscProperty()]
    [System.ComponentModel.Description('The AllowAppStore parameter specifies whether to allow access to the app store on devices.')]
    [System.Nullable[System.Boolean]] $AllowAppStore

    [DscProperty()]
    [System.ComponentModel.Description('The AllowAssistantWhileLocked parameter specifies whether to allow the use of the voice assistant while devices are locked.')]
    [System.Nullable[System.Boolean]] $AllowAssistantWhileLocked

    [DscProperty()]
    [System.ComponentModel.Description('The AllowConvenienceLogon parameter specifies whether to allow convenience logons on devices.')]
    [System.Nullable[System.Boolean]] $AllowConvenienceLogon

    [DscProperty()]
    [System.ComponentModel.Description('The AllowDiagnosticSubmission parameter specifies whether to allow diagnostic submissions from devices.')]
    [System.Nullable[System.Boolean]] $AllowDiagnosticSubmission

    [DscProperty()]
    [System.ComponentModel.Description('The AllowiCloudBackup parameter specifies whether to allow Apple iCloud Backup from devices.')]
    [System.Nullable[System.Boolean]] $AllowiCloudBackup

    [DscProperty()]
    [System.ComponentModel.Description('The AllowiCloudDocSync parameter specifies whether to allow Apple iCloud Documents & Data sync on devices.')]
    [System.Nullable[System.Boolean]] $AllowiCloudDocSync

    [DscProperty()]
    [System.ComponentModel.Description('The AllowiCloudPhotoSync parameter specifies whether to allow Apple iCloud Photos sync on devices.')]
    [System.Nullable[System.Boolean]] $AllowiCloudPhotoSync

    [DscProperty()]
    [System.ComponentModel.Description('The AllowJailbroken parameter specifies whether to allow access to your organization by jailbroken or rooted devices.')]
    [System.Nullable[System.Boolean]] $AllowJailbroken

    [DscProperty()]
    [System.ComponentModel.Description('The AllowPassbookWhileLocked parameter specifies whether to allow the use of Apple Passbook while devices are locked.')]
    [System.Nullable[System.Boolean]] $AllowPassbookWhileLocked

    [DscProperty()]
    [System.ComponentModel.Description('The AllowScreenshot parameter specifies whether to allow screenshots on devices.')]
    [System.Nullable[System.Boolean]] $AllowScreenshot

    [DscProperty()]
    [System.ComponentModel.Description('The AllowSimplePassword parameter specifies whether to allow simple or non-complex passwords on devices.')]
    [System.Nullable[System.Boolean]] $AllowSimplePassword

    [DscProperty()]
    [System.ComponentModel.Description('The AllowVideoConferencing parameter specifies whether to allow video conferencing on devices. ')]
    [System.Nullable[System.Boolean]] $AllowVideoConferencing

    [DscProperty()]
    [System.ComponentModel.Description('The AllowVoiceAssistant parameter specifies whether to allow using the voice assistant on devices.')]
    [System.Nullable[System.Boolean]] $AllowVoiceAssistant

    [DscProperty()]
    [System.ComponentModel.Description('The AllowVoiceDialing parameter specifies whether to allow voice-activated telephone dialing.')]
    [System.Nullable[System.Boolean]] $AllowVoiceDialing

    [DscProperty()]
    [System.ComponentModel.Description('The AntiVirusSignatureStatus parameter specifies the antivirus signature status.')]
    [System.Nullable[System.UInt32]] $AntiVirusSignatureStatus

    [DscProperty()]
    [System.ComponentModel.Description('The AntiVirusStatus parameter specifies the antivirus status.')]
    [System.Nullable[System.UInt32]] $AntiVirusStatus

    [DscProperty()]
    [System.ComponentModel.Description('The AppsRating parameter species the maximum or most restrictive rating of apps that are allowed on devices.')]
    [System.String] $AppsRating

    [DscProperty()]
    [System.ComponentModel.Description('The AutoUpdateStatus parameter specifies the update settings for devices.')]
    [System.String] $AutoUpdateStatus

    [DscProperty()]
    [System.ComponentModel.Description('The BluetoothEnabled parameter specifies whether to enable or disable Bluetooth on devices.')]
    [System.Nullable[System.Boolean]] $BluetoothEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The BluetoothEnabled parameter specifies whether to enable or disable Bluetooth on devices.')]
    [System.Nullable[System.Boolean]] $CameraEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The EmailAddress parameter specifies the email address.')]
    [System.String] $EmailAddress

    [DscProperty()]
    [System.ComponentModel.Description('The EnableRemovableStorage parameter specifies whether removable storage can be used by devices.')]
    [System.Nullable[System.Boolean]] $EnableRemovableStorage

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeActiveSyncHost parameter specifies the Exchange ActiveSync host.')]
    [System.String] $ExchangeActiveSyncHost

    [DscProperty()]
    [System.ComponentModel.Description('The FirewallStatus parameter specifies the acceptable firewall status values on devices.')]
    [ValidateSet('Required')]
    [System.String] $FirewallStatus

    [DscProperty()]
    [System.ComponentModel.Description('The ForceAppStorePassword parameter specifies whether to require a password to use the app store on devices.')]
    [System.Nullable[System.Boolean]] $ForceAppStorePassword

    [DscProperty()]
    [System.ComponentModel.Description('The ForceEncryptedBackup parameter specifies whether to force encrypted backups for devices.')]
    [System.Nullable[System.Boolean]] $ForceEncryptedBackup

    [DscProperty()]
    [System.ComponentModel.Description('The MaxPasswordAttemptsBeforeWipe parameter specifies the number of incorrect password attempts that cause devices to be automatically wiped.')]
    [System.Nullable[System.UInt32]] $MaxPasswordAttemptsBeforeWipe

    [DscProperty()]
    [System.ComponentModel.Description('The MaxPasswordGracePeriod parameter specifies the length of time users are allowed to reset expired passwords on devices, as a time span dd.hh:mm:ss.')]
    [System.String] $MaxPasswordGracePeriod

    [DscProperty()]
    [System.ComponentModel.Description('The MoviesRating parameter species the maximum or most restrictive rating of movies that are allowed on devices. You specify the country/region rating system to use with the RegionRatings parameter.')]
    [System.String] $MoviesRating

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordComplexity parameter specifies the password complexity.')]
    [System.Nullable[System.UInt32]] $PasswordComplexity

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordExpirationDays parameter specifies the number of days that the same password can be used on devices before users are required to change their passwords.')]
    [System.Nullable[System.UInt32]] $PasswordExpirationDays

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordHistoryCount parameter specifies the minimum number of unique new passwords that are required on devices before an old password can be reused.')]
    [System.Nullable[System.UInt32]] $PasswordHistoryCount

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordMinComplexChars parameter specifies the minimum number of complex characters that are required for device passwords. A complex character isn''t a letter.')]
    [System.Nullable[System.UInt32]] $PasswordMinComplexChars

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordMinimumLength parameter specifies the minimum number of characters that are required for device passwords.')]
    [System.Nullable[System.UInt32]] $PasswordMinimumLength

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordQuality parameter specifies the minimum password quality rating that''s required for device passwords. Password quality is a numeric scale that indicates the security and complexity of the password. A higher quality value indicates a more secure password.')]
    [System.Nullable[System.UInt32]] $PasswordQuality

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordRequired parameter specifies whether a password is required to access devices.')]
    [System.Nullable[System.Boolean]] $PasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('The PasswordTimeout parameter specifies the length of time that devices can be inactive before a password is required to reactivate them.')]
    [System.String] $PasswordTimeout

    [DscProperty()]
    [System.ComponentModel.Description('The PhoneMemoryEncrypted parameter specifies whether to encrypt the memory on devices.')]
    [System.Nullable[System.Boolean]] $PhoneMemoryEncrypted

    [DscProperty()]
    [System.ComponentModel.Description('The RegionRatings parameter specifies the rating system (country/region) to use for movie and television ratings with the MoviesRating and TVShowsRating parameters.')]
    [System.String] $RegionRatings

    [DscProperty()]
    [System.ComponentModel.Description('The RequireEmailProfile parameter specifies whether an email profile is required on devices.')]
    [System.Nullable[System.Boolean]] $RequireEmailProfile

    [DscProperty()]
    [System.ComponentModel.Description('The SmartScreenEnabled parameter specifies whether to requireWindows SmartScreen on devices.')]
    [System.Nullable[System.Boolean]] $SmartScreenEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The SystemSecurityTLS parameter specifies whether TLS encryption is used on devices.')]
    [System.Nullable[System.Boolean]] $SystemSecurityTLS

    [DscProperty()]
    [System.ComponentModel.Description('The TVShowsRating parameter species the maximum or most restrictive rating of television shows that are allowed on devices. You specify the country/region rating system to use with the RegionRatings parameter.')]
    [System.String] $TVShowsRating

    [DscProperty()]
    [System.ComponentModel.Description('The UserAccountControlStatus parameter specifies how User Account Control messages are presented on devices.')]
    [System.String] $UserAccountControlStatus

    [DscProperty()]
    [System.ComponentModel.Description('The WLANEnabled parameter specifies whether Wi-Fi is enabled devices.')]
    [System.Nullable[System.Boolean]] $WLANEnabled

    [DscProperty()]
    [System.ComponentModel.Description('The WorkFoldersSyncUrl parameter specifies the URL that''s used to synchronize company data on devices.')]
    [System.String] $WorkFoldersSyncUrl

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
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [SCDeviceConditionalAccessRule] Get()
    {
        $instance = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCDeviceConditionalAccessRule]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Purview Device Conditional Access Rule for $($this.Name)"

        $policyName = $this.Policy
        if ([System.String]::IsNullOrEmpty($policyName))
        {
            $policyName = $this.Name.Split('{')[0]
        }

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                $null = $this.Connect('SecurityComplianceCenter')

                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $policyObj = Get-DeviceConditionalAccessPolicy | Where-Object -Property Name -EQ $policyName
                if ($null -ne $policyObj)
                {
                    Write-Verbose -Message "Found policy object {$policyName}"
                    $instance = Get-DeviceConditionalAccessRule | Where-Object -FilterScript { $_.Policy -eq $policyObj.ExchangeObjectId }
                }
                if ($null -eq $instance)
                {
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $instance = $this.ExportedInstance
                $policyObj = Get-DeviceConditionalAccessPolicy | Where-Object -Property Name -EQ $policyName
            }

            $groupNames = @()
            foreach ($group in $instance.TargetGroups)
            {
                $groupValue = Get-Group $group.Guid -ErrorAction SilentlyContinue | Where-Object -FilterScript { $_.GUID -eq $group.Guid }
                if ($null -ne $groupValue)
                {
                    $groupNames += $groupValue.Name
                }
                else
                {
                    $errorMessage = "Target Group {$group} defined in policy wasn't found"
                    $this.LogError($_, $errorMessage)
                }
            }

            $results = @{
                Name                          = $instance.Name
                Policy                        = $policyObj.Name
                TargetGroups                  = $groupNames
                AccountName                   = $instance.AccountName
                AccountUserName               = $instance.AccountUserName
                AllowAppStore                 = $instance.AllowAppStore
                AllowAssistantWhileLocked     = $instance.AllowAssistantWhileLocked
                AllowConvenienceLogon         = $instance.AllowConvenienceLogon
                AllowDiagnosticSubmission     = $instance.AllowDiagnosticSubmission
                AllowiCloudBackup             = $instance.AllowiCloudBackup
                AllowiCloudDocSync            = $instance.AllowiCloudDocSync
                AllowiCloudPhotoSync          = $instance.AllowiCloudPhotoSync
                AllowJailbroken               = $instance.AllowJailbroken
                AllowPassbookWhileLocked      = $instance.AllowPassbookWhileLocked
                AllowScreenshot               = $instance.AllowScreenshot
                AllowSimplePassword           = $instance.AllowSimplePassword
                AllowVideoConferencing        = $instance.AllowVideoConferencing
                AllowVoiceAssistant           = $instance.AllowVoiceAssistant
                AllowVoiceDialing             = $instance.AllowVoiceDialing
                AntiVirusSignatureStatus      = $instance.AntiVirusSignatureStatus
                AntiVirusStatus               = $instance.AntiVirusStatus
                AppsRating                    = $instance.AppsRating
                AutoUpdateStatus              = $instance.AutoUpdateStatus
                BluetoothEnabled              = $instance.BluetoothEnabled
                CameraEnabled                 = $instance.CameraEnabled
                EmailAddress                  = $instance.EmailAddress
                EnableRemovableStorage        = $instance.EnableRemovableStorage
                ExchangeActiveSyncHost        = $instance.ExchangeActiveSyncHost
                FirewallStatus                = $instance.FirewallStatus
                ForceAppStorePassword         = $instance.ForceAppStorePassword
                ForceEncryptedBackup          = $instance.ForceEncryptedBackup
                MaxPasswordAttemptsBeforeWipe = $instance.MaxPasswordAttemptsBeforeWipe
                MaxPasswordGracePeriod        = $instance.MaxPasswordGracePeriod
                MoviesRating                  = $instance.MoviesRating
                PasswordComplexity            = $instance.PasswordComplexity
                PasswordExpirationDays        = $instance.PasswordExpirationDays
                PasswordHistoryCount          = $instance.PasswordHistoryCount
                PasswordMinComplexChars       = $instance.PasswordMinComplexChars
                PasswordMinimumLength         = $instance.PasswordMinimumLength
                PasswordQuality               = $instance.PasswordQuality
                PasswordRequired              = $instance.PasswordRequired
                PasswordTimeout               = $instance.PasswordTimeout
                PhoneMemoryEncrypted          = $instance.PhoneMemoryEncrypted
                RegionRatings                 = $instance.RegionRatings
                RequireEmailProfile           = $instance.RequireEmailProfile
                SmartScreenEnabled            = $instance.SmartScreenEnabled
                SystemSecurityTLS             = $instance.SystemSecurityTLS
                TVShowsRating                 = $instance.TVShowsRating
                UserAccountControlStatus      = $instance.UserAccountControlStatus
                WLANEnabled                   = $instance.WLANEnabled
                WorkFoldersSyncUrl            = $instance.WorkFoldersSyncUrl
                Ensure                        = 'Present'
                Credential                    = $this.Credential
                ApplicationId                 = $this.ApplicationId
                TenantId                      = $this.TenantId
                CertificateThumbprint         = $this.CertificateThumbprint
                CertificatePath               = $this.CertificatePath
                CertificatePassword           = $this.CertificatePassword
                ManagedIdentity               = $this.ManagedIdentity
                AccessTokens                  = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of Purview Device Conditional Access Rule for $($this.Name)"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $setParameters.Remove('Name') | Out-Null

        if ($this.Ensure -eq 'Present' -and $null -ne $this.TargetGroups)
        {
            $targetGroupsValue = @()
            foreach ($group in $this.TargetGroups)
            {
                $entry = Get-Group $group -ErrorAction SilentlyContinue
                if ($null -ne $entry)
                {
                    $targetGroupsValue += $entry.Id
                }
            }
            $setParameters.TargetGroups = $targetGroupsValue
        }

        # CREATE
        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new device conditional access rule {$($this.Name)}"
            New-DeviceConditionalAccessRule @setParameters
        }
        # UPDATE
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            $setParameters.Remove('Policy') | Out-Null
            $setParameters.Add('Identity', $currentInstance.Name)
            Write-Verbose -Message "Updating device conditional access rule {$($this.Name)}"
            Set-DeviceConditionalAccessRule @setParameters
        }
        # REMOVE
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing device conditional access rule {$($this.Name)}"
            Remove-DeviceConditionalAccessRule -Identity $currentInstance.Name -Confirm:$false
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
            [array] $exportedInstances = Get-DeviceConditionalAccessRule -ErrorAction Stop

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
                    Name                  = $config.Name
                    Policy                = $config.Name.Split('{')[0]
                    TargetGroups          = $config.TargetGroups
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
                $rawResults = $Results.Clone()

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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
            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('Name')
        }
    }

    hidden [SCDeviceConditionalAccessRule] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCDeviceConditionalAccessRule])
        {
            return $Values
        }

        $result = [SCDeviceConditionalAccessRule]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
