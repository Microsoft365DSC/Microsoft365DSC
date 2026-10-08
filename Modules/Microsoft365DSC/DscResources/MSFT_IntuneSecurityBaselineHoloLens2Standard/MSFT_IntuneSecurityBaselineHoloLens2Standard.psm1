using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSecurityBaselineHoloLens2Standard : M365DSCResourceBase
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
    [System.ComponentModel.Description('Allow Microsoft Account Connection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowMicrosoftAccountConnection

    [DscProperty()]
    [System.ComponentModel.Description('Turn off the display (plugged in) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $VideoPowerDownTimeOutAC_2

    [DscProperty()]
    [System.ComponentModel.Description('When plugged in, turn display off after (seconds) - Depends on VideoPowerDownTimeOutAC_2')]
    [ValidateRange(0, 4294967295)]
    [System.Nullable[System.Int32]] $EnterVideoACPowerDownTimeOut

    [DscProperty()]
    [System.ComponentModel.Description('Allow Cookies (0: Block all cookies from all sites, 1: Block only cookies from third party websites, 2: Allow all cookies from all sites)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AllowCookies

    [DscProperty()]
    [System.ComponentModel.Description('Allow Password Manager (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowPasswordManager

    [DscProperty()]
    [System.ComponentModel.Description('Allow Smart Screen (0: Turned off. Do not protect users from potential threats and prevent users from turning it on., 1: Turned on. Protect users from potential threats and prevent users from turning it off.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowSmartScreen

    [DscProperty()]
    [System.ComponentModel.Description('Allow USB Connection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowUSBConnection

    [DscProperty()]
    [System.ComponentModel.Description('Device Password Enabled (0: Enabled, 1: Disabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $DevicePasswordEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Device Password Expiration - Depends on DevicePasswordEnabled')]
    [ValidateRange(0, 730)]
    [System.Nullable[System.Int32]] $DevicePasswordExpiration

    [DscProperty()]
    [System.ComponentModel.Description('Min Device Password Length - Depends on DevicePasswordEnabled')]
    [ValidateRange(4, 16)]
    [System.Nullable[System.Int32]] $MinDevicePasswordLength

    [DscProperty()]
    [System.ComponentModel.Description('Alphanumeric Device Password Required - Depends on DevicePasswordEnabled (0: Password or Alphanumeric PIN required., 1: Password or Numeric PIN required., 2: Password, Numeric PIN, or Alphanumeric PIN required.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AlphanumericDevicePasswordRequired

    [DscProperty()]
    [System.ComponentModel.Description('Max Device Password Failed Attempts - Depends on DevicePasswordEnabled')]
    [ValidateRange(0, 999)]
    [System.Nullable[System.Int32]] $MaxDevicePasswordFailedAttempts

    [DscProperty()]
    [System.ComponentModel.Description('Min Device Password Complex Characters - Depends on DevicePasswordEnabled (1: Digits only, 2: Digits and lowercase letters are required, 3: Digits lowercase letters and uppercase letters are required. Not supported in desktop Microsoft accounts and domain accounts, 4: Digits lowercase letters uppercase letters and special characters are required. Not supported in desktop)')]
    [ValidateSet('1', '2', '3', '4')]
    [System.Nullable[System.Int32]] $MinDevicePasswordComplexCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Max Inactivity Time Device Lock - Depends on DevicePasswordEnabled')]
    [ValidateRange(0, 999)]
    [System.Nullable[System.Int32]] $MaxInactivityTimeDeviceLock

    [DscProperty()]
    [System.ComponentModel.Description('Device Password History - Depends on DevicePasswordEnabled')]
    [ValidateRange(0, 50)]
    [System.Nullable[System.Int32]] $DevicePasswordHistory

    [DscProperty()]
    [System.ComponentModel.Description('Allow Simple Device Password - Depends on DevicePasswordEnabled (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowSimpleDevicePassword

    [DscProperty()]
    [System.ComponentModel.Description('Allow Manual MDM Unenrollment (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowManualMDMUnenrollment

    [DscProperty()]
    [System.ComponentModel.Description('Allow All Trusted Apps (0: Explicit deny., 1: Explicit allow unlock., 65535: Not configured.)')]
    [ValidateSet('0', '1', '65535')]
    [System.Nullable[System.Int32]] $AllowAllTrustedApps

    [DscProperty()]
    [System.ComponentModel.Description('Allow apps from the Microsoft app store to auto update (0: Not allowed., 1: Allowed., 2: Not configured.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $AllowAppStoreAutoUpdate

    [DscProperty()]
    [System.ComponentModel.Description('Allow Developer Unlock (0: Explicit deny., 1: Explicit allow unlock., 65535: Not configured.)')]
    [ValidateSet('0', '1', '65535')]
    [System.Nullable[System.Int32]] $AllowDeveloperUnlock

    [DscProperty()]
    [System.ComponentModel.Description('Block third party cookies (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $BlockThirdPartyCookies

    [DscProperty()]
    [System.ComponentModel.Description('Control which extensions cannot be installed (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $ExtensionInstallBlocklist

    [DscProperty()]
    [System.ComponentModel.Description('Extension IDs the user should be prevented from installing (or * for all) (Device) - Depends on ExtensionInstallBlocklist')]
    [ValidateLength(0, 2048)]
    [System.String[]] $ExtensionInstallBlocklistDesc

    [DscProperty()]
    [System.ComponentModel.Description('Enable saving passwords to the password manager (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $PasswordManagerEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Configure Microsoft Defender SmartScreen (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $SmartScreenEnabled

    [DscProperty()]
    [System.ComponentModel.Description('AAD Group Membership Cache Validity In Days')]
    [ValidateRange(0, 60)]
    [System.Nullable[System.Int32]] $AADGroupMembershipCacheValidityInDays

    [DscProperty()]
    [System.ComponentModel.Description('Allow VPN (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowVPN

    [DscProperty()]
    [System.ComponentModel.Description('Page Visibility List')]
    [ValidateLength(0, 87516)]
    [System.String] $PageVisibilityList

    [DscProperty()]
    [System.ComponentModel.Description('Allow Storage Card (0: SD card use is not allowed and USB drives are disabled. This setting does not prevent programmatic access to the storage card., 1: Allow a storage card.)')]
    [ValidateSet('0', '1')]
    [System.Nullable[System.Int32]] $AllowStorageCard

    [DscProperty()]
    [System.ComponentModel.Description('Enable Pin Recovery - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $EnablePinRecovery

    [DscProperty()]
    [System.ComponentModel.Description('Restrict use of TPM 1.2 - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $TPM12

    [DscProperty()]
    [System.ComponentModel.Description('Digits - Depends on TenantId (0: Allows the use of digits in PIN., 1: Requires the use of at least one digits in PIN., 2: Does not allow the use of digits in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $Digits

    [DscProperty()]
    [System.ComponentModel.Description('Expiration - Depends on TenantId')]
    [ValidateRange(0, 730)]
    [System.Nullable[System.Int32]] $Expiration

    [DscProperty()]
    [System.ComponentModel.Description('PIN History - Depends on TenantId')]
    [ValidateRange(0, 50)]
    [System.Nullable[System.Int32]] $History

    [DscProperty()]
    [System.ComponentModel.Description('Lowercase Letters - Depends on TenantId (0: Allows the use of lowercase letters in PIN., 1: Requires the use of at least one lowercase letters in PIN., 2: Does not allow the use of lowercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $LowercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Maximum PIN Length - Depends on TenantId')]
    [ValidateRange(4, 127)]
    [System.Nullable[System.Int32]] $MaximumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Minimum PIN Length - Depends on TenantId')]
    [ValidateRange(4, 127)]
    [System.Nullable[System.Int32]] $MinimumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Special Characters - Depends on TenantId (0: Allows the use of special characters in PIN., 1: Requires the use of at least one special characters in PIN., 2: Does not allow the use of special characters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $SpecialCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Uppercase Letters - Depends on TenantId (0: Allows the use of uppercase letters in PIN., 1: Requires the use of at least one uppercase letters in PIN., 2: Does not allow the use of uppercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.Nullable[System.Int32]] $UppercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Require Security Device - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $RequireSecurityDevice

    [DscProperty()]
    [System.ComponentModel.Description('Use Certificate For On Prem Auth - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UseCertificateForOnPremAuth

    [DscProperty()]
    [System.ComponentModel.Description('Use Hello Certificates As Smart Card Certificates - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UseHelloCertificatesAsSmartCardCertificates

    [DscProperty()]
    [System.ComponentModel.Description('Use Windows Hello For Business (Device) - Depends on TenantId (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UsePassportForWork

    [DscProperty()]
    [System.ComponentModel.Description('Allow Update Service (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowUpdateService

    [DscProperty()]
    [System.ComponentModel.Description('Manage Preview Builds (0: Disable Preview builds, 1: Disable Preview builds once the next release is public, 2: Enable Preview builds, 3: Preview builds is left to user selection)')]
    [ValidateSet('0', '1', '2', '3')]
    [System.String] $ManagePreviewBuilds

    [DscProperty()]
    [System.ComponentModel.Description('Require Network In OOBE (Device) (true: true, false: false)')]
    [ValidateSet('true', 'false')]
    [System.String] $RequireNetworkInOOBE

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

    [IntuneSecurityBaselineHoloLens2Standard] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSecurityBaselineHoloLens2Standard]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Security Baseline HoloLens2 Standard with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {

                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

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
                    Write-Verbose -Message "Could not find an Intune Security Baseline HoloLens2 Standard with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Security Baseline HoloLens2 Standard with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Security Baseline HoloLens2 Standard with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

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

        Write-Verbose -Message "Setting configuration of the Intune Security Baseline HoloLens2 Standard with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '5d030c29-ea8d-4751-ba0d-5e3de7a84cd3_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Security Baseline HoloLens2 Standard with Name {$($this.DisplayName)}"
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
            Write-Verbose -Message "Updating the Intune Security Baseline HoloLens2 Standard with Id {$($currentInstance.Id)}"
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
            Write-Verbose -Message "Removing the Intune Security Baseline HoloLens2 Standard with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = '5d030c29-ea8d-4751-ba0d-5e3de7a84cd3_1'
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

    hidden [IntuneSecurityBaselineHoloLens2Standard] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSecurityBaselineHoloLens2Standard])
        {
            return $Values
        }

        $result = [IntuneSecurityBaselineHoloLens2Standard]::new()
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
