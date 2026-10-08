using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDiskEncryptionWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Require Device Encryption (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $RequireDeviceEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Choose drive encryption method and cipher strength (Windows 10 [Version 1511] and later) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $EncryptionMethodWithXts_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for operating system drives: (3: AES-CBC 128-bit, 4: AES-CBC 256-bit, 6: XTS-AES 128-bit (default), 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsOsDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for fixed data drives: (3: AES-CBC 128-bit, 4: AES-CBC 256-bit, 6: XTS-AES 128-bit (default), 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsFdvDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption method for removable data drives: (3: AES-CBC 128-bit  (default), 4: AES-CBC 256-bit, 6: XTS-AES 128-bit, 7: XTS-AES 256-bit)')]
    [ValidateSet('3', '4', '6', '7')]
    [System.String] $EncryptionMethodWithXtsRdvDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Provide the unique identifiers for your organization (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $IdentificationField_Name

    [DscProperty()]
    [System.ComponentModel.Description('BitLocker identification field: (Device)')]
    [ValidateLength(0, 260)]
    [System.String] $IdentificationField

    [DscProperty()]
    [System.ComponentModel.Description('Allowed BitLocker identification field: (Device)')]
    [ValidateLength(0, 260)]
    [System.String] $SecIdentificationField

    [DscProperty()]
    [System.ComponentModel.Description('Allow Warning For Other Disk Encryption (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowWarningForOtherDiskEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Allow Standard User Encryption (0: This is the default, when the policy is not set. If current logged on user is a standard user, ''RequireDeviceEncryption'' policy will not try to enable encryption on any drive., 1: ''RequireDeviceEncryption'' policy will try to enable encryption on all fixed drives even if a current logged in user is standard user.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowStandardUserEncryption

    [DscProperty()]
    [System.ComponentModel.Description('Configure Recovery Password Rotation (0: Refresh off (default), 1: Refresh on for Azure AD-joined devices, 2: Refresh on for both Azure AD-joined and hybrid-joined devices)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $ConfigureRecoveryPasswordRotation

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on operating system drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $OSEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $OSEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Require additional authentication at startup (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $ConfigureAdvancedStartup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup key: (2: Allow startup key with TPM, 1: Require startup key with TPM, 0: Do not allow startup key with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMStartupKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup key and PIN: (2: Allow startup key and PIN with TPM, 1: Require startup key and PIN with TPM, 0: Do not allow startup key and PIN with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMPINKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup: (2: Allow TPM, 1: Require TPM, 0: Do not allow TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigureTPMUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow BitLocker without a compatible TPM (requires a password or a startup key on a USB flash drive) (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $ConfigureNonTPMStartupKeyUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure TPM startup PIN: (2: Allow startup PIN with TPM, 1: Require startup PIN with TPM, 0: Do not allow startup PIN with TPM)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $ConfigurePINUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure minimum PIN length for startup (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $MinimumPINLength_Name

    [DscProperty()]
    [System.ComponentModel.Description('Minimum characters:')]
    [ValidateRange(4, 20)]
    [System.Nullable[System.Int32]] $MinPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Allow enhanced PINs for startup (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $EnhancedPIN_Name

    [DscProperty()]
    [System.ComponentModel.Description('Disallow standard users from changing the PIN or password (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DisallowStandardUsersCanChangePIN_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow devices compliant with InstantGo or HSTI to opt out of pre-boot PIN. (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $EnablePreBootPinExceptionOnDECapableDevice_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enable use of BitLocker authentication requiring preboot keyboard input on slates (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $EnablePrebootInputProtectorsOnSlates_Name

    [DscProperty()]
    [System.ComponentModel.Description('Choose how BitLocker-protected operating system drives can be recovered (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $OSRecoveryUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not enable BitLocker until recovery information is stored to AD DS for operating system drives (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $OSRequireActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Save BitLocker recovery information to AD DS for operating system drives (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $OSActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure user storage of BitLocker recovery information: (2: Allow 48-digit recovery password, 1: Require 48-digit recovery password, 0: Do not allow 48-digit recovery password)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $OSRecoveryPasswordUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Omit recovery options from the BitLocker setup wizard (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $OSHideRecoveryPage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow data recovery agent (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $OSAllowDRA_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure OS recovery key usage: (2: Allow 256-bit recovery key, 1: Require 256-bit recovery key, 0: Do not allow 256-bit recovery key)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $OSRecoveryKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure storage of BitLocker recovery information to AD DS: (1: Store recovery passwords and key packages, 2: Store recovery passwords only)')]
    [ValidateSet('1', '2')]
    [System.String] $OSActiveDirectoryBackupDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure pre-boot recovery message and URL (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $PrebootRecoveryInfo_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select an option for the pre-boot recovery message: (0: , 1: Use default recovery message and URL, 2: Use custom recovery message, 3: Use custom recovery URL)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.String] $PrebootRecoveryInfoDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Custom recovery URL option:')]
    [ValidateLength(0, 500)]
    [System.String] $RecoveryUrl_Input

    [DscProperty()]
    [System.ComponentModel.Description('Custom recovery message option:')]
    [ValidateLength(0, 900)]
    [System.String] $RecoveryMessage_Input

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on fixed data drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $FDVEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Choose how BitLocker-protected fixed drives can be recovered (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVRecoveryUsage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Save BitLocker recovery information to AD DS for fixed data drives (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Omit recovery options from the BitLocker setup wizard (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVHideRecoveryPage_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure user storage of BitLocker recovery information: (2: Allow 48-digit recovery password, 1: Require 48-digit recovery password, 0: Do not allow 48-digit recovery password)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $FDVRecoveryPasswordUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not enable BitLocker until recovery information is stored to AD DS for fixed data drives (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVRequireActiveDirectoryBackup_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow data recovery agent (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVAllowDRA_Name

    [DscProperty()]
    [System.ComponentModel.Description('Configure storage of BitLocker recovery information to AD DS: (1: Backup recovery passwords and key packages, 2: Backup recovery passwords only)')]
    [ValidateSet('1', '2')]
    [System.String] $FDVActiveDirectoryBackupDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the fixed drive recovery key usage: (2: Allow 256-bit recovery key, 1: Require 256-bit recovery key, 0: Do not allow 256-bit recovery key)')]
    [ValidateSet('2', '1', '0')]
    [System.String] $FDVRecoveryKeyUsageDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Deny write access to fixed drives not protected by BitLocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $FDVDenyWriteAccess_Name

    [DscProperty()]
    [System.ComponentModel.Description('Control use of BitLocker on removable drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVConfigureBDE

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to apply BitLocker protection on removable data drives (Device) (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVAllowBDE_Name

    [DscProperty()]
    [System.ComponentModel.Description('Enforce drive encryption type on removable data drives (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVEncryptionType_Name

    [DscProperty()]
    [System.ComponentModel.Description('Select the encryption type: (Device) (0: Allow user to choose (default), 1: Full encryption, 2: Used Space Only encryption)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $RDVEncryptionTypeDropDown_Name

    [DscProperty()]
    [System.ComponentModel.Description('Allow users to suspend and decrypt BitLocker protection on removable data drives (Device) (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVDisableBDE_Name

    [DscProperty()]
    [System.ComponentModel.Description('Deny write access to removable drives not protected by BitLocker (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVDenyWriteAccess_Name

    [DscProperty()]
    [System.ComponentModel.Description('Do not allow write access to devices configured in another organization (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $RDVCrossOrg

    [DscProperty()]
    [System.ComponentModel.Description('Represents the assignment to the Intune policy.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
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

    [IntuneDiskEncryptionWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDiskEncryptionWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Disk Encryption PDE Policy for Windows10 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $templateReferenceId = '46ddfc50-d10f-4867-b852-9434254b3bff_1'
                $getValue = $null
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Disk Encryption for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/TemplateId eq '$templateReferenceId'" `
                            -ErrorAction SilentlyContinue

                        if ($getValue.Length -gt 1)
                        {
                            throw "Duplicate Intune Disk Encryption for Windows10 named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Disk Encryption for Windows10 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Disk Encryption for Windows10 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                Ensure                = 'Present'
                Credential            = $this.Credential
                ApplicationId         = $this.ApplicationId
                TenantId              = $this.TenantId
                ApplicationSecret     = $this.ApplicationSecret
                CertificateThumbprint = $this.CertificateThumbprint
                CertificatePath       = $this.CertificatePath
                CertificatePassword   = $this.CertificatePassword
                ManagedIdentity       = $this.ManagedIdentity
                #endregion
            }
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '46ddfc50-d10f-4867-b852-9434254b3bff_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Disk Encryption for Windows10 with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            $createParameters = @{
                name              = $this.DisplayName
                description       = $this.Description
                templateReference = @{ templateId = $templateReferenceId }
                platforms         = $platforms
                technologies      = $technologies
                settings          = $settings
                roleScopeTagIds   = $resolvedRoleScopeTagIds
            }

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Disk Encryption for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Disk Encryption for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
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
            $policyTemplateID = '46ddfc50-d10f-4867-b852-9434254b3bff_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
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
                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [string]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
                    DisplayName           = $config.Name
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
                    -NoEscape @('Assignments') `
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
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneDiskEncryptionWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDiskEncryptionWindows10])
        {
            return $Values
        }

        $result = [IntuneDiskEncryptionWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
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
