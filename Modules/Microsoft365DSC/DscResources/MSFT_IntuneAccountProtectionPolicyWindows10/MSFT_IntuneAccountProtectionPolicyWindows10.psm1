using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAccountProtectionPolicyWindows10 : M365DSCResourceBase
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
    [System.ComponentModel.Description('The policy settings for the device scope.')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10] $DeviceSettings

    [DscProperty()]
    [System.ComponentModel.Description('The policy settings for the user scope')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10] $UserSettings

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

    [IntuneAccountProtectionPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAccountProtectionPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Account Protection Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Account Protection Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if ($getValue.Length -gt 1)
                        {
                            throw "Duplicate Intune Account Protection Policy for Windows10 named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Account Protection Policy for Windows10 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }

            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Account Protection Policy for Windows10 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = [ordered]@{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings -ContainsDeviceAndUserSettings

            #region resource generator code
            $complexDeviceSettings = [ordered]@{}
            if ($null -ne $policySettings.DeviceSettings.lsaCfgFlags)
            {
                $complexDeviceSettings.Add('LsaCfgFlags', $policySettings.DeviceSettings.lsaCfgFlags)
            }
            if ($null -ne $policySettings.DeviceSettings.facialFeaturesUseEnhancedAntiSpoofing)
            {
                $complexDeviceSettings.Add('FacialFeaturesUseEnhancedAntiSpoofing', $policySettings.DeviceSettings.facialFeaturesUseEnhancedAntiSpoofing)
            }
            if ($null -ne $policySettings.DeviceSettings.enablePinRecovery)
            {
                $complexDeviceSettings.Add('EnablePinRecovery', $policySettings.DeviceSettings.enablePinRecovery)
            }
            if ($null -ne $policySettings.DeviceSettings.expiration)
            {
                $complexDeviceSettings.Add('Expiration', $policySettings.DeviceSettings.expiration)
            }
            if ($null -ne $policySettings.DeviceSettings.history)
            {
                $complexDeviceSettings.Add('History', $policySettings.DeviceSettings.history)
            }
            if ($null -ne $policySettings.DeviceSettings.lowercaseLetters)
            {
                $complexDeviceSettings.Add('LowercaseLetters', $policySettings.DeviceSettings.lowercaseLetters)
            }
            if ($null -ne $policySettings.DeviceSettings.maximumPINLength)
            {
                $complexDeviceSettings.Add('MaximumPINLength', $policySettings.DeviceSettings.maximumPINLength)
            }
            if ($null -ne $policySettings.DeviceSettings.minimumPINLength)
            {
                $complexDeviceSettings.Add('MinimumPINLength', $policySettings.DeviceSettings.minimumPINLength)
            }
            if ($null -ne $policySettings.DeviceSettings.specialCharacters)
            {
                $complexDeviceSettings.Add('SpecialCharacters', $policySettings.DeviceSettings.specialCharacters)
            }
            if ($null -ne $policySettings.DeviceSettings.uppercaseLetters)
            {
                $complexDeviceSettings.Add('UppercaseLetters', $policySettings.DeviceSettings.uppercaseLetters)
            }
            if ($null -ne $policySettings.DeviceSettings.requireSecurityDevice)
            {
                $complexDeviceSettings.Add('RequireSecurityDevice', $policySettings.DeviceSettings.requireSecurityDevice)
            }
            if ($null -ne $policySettings.DeviceSettings.useCertificateForOnPremAuth)
            {
                $complexDeviceSettings.Add('UseCertificateForOnPremAuth', $policySettings.DeviceSettings.useCertificateForOnPremAuth)
            }
            if ($null -ne $policySettings.DeviceSettings.usePassportForWork)
            {
                $complexDeviceSettings.Add('UsePassportForWork', $policySettings.DeviceSettings.usePassportForWork)
            }
            if ($complexDeviceSettings.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceSettings = $null
            }

            $complexUserSettings = [ordered]@{}
            if ($null -ne $policySettings.UserSettings.enablePinRecovery)
            {
                $complexUserSettings.Add('EnablePinRecovery', $policySettings.UserSettings.enablePinRecovery)
            }
            if ($null -ne $policySettings.UserSettings.expiration)
            {
                $complexUserSettings.Add('Expiration', $policySettings.UserSettings.expiration)
            }
            if ($null -ne $policySettings.UserSettings.history)
            {
                $complexUserSettings.Add('History', $policySettings.UserSettings.history)
            }
            if ($null -ne $policySettings.UserSettings.lowercaseLetters)
            {
                $complexUserSettings.Add('LowercaseLetters', $policySettings.UserSettings.lowercaseLetters)
            }
            if ($null -ne $policySettings.UserSettings.maximumPINLength)
            {
                $complexUserSettings.Add('MaximumPINLength', $policySettings.UserSettings.maximumPINLength)
            }
            if ($null -ne $policySettings.UserSettings.minimumPINLength)
            {
                $complexUserSettings.Add('MinimumPINLength', $policySettings.UserSettings.minimumPINLength)
            }
            if ($null -ne $policySettings.UserSettings.specialCharacters)
            {
                $complexUserSettings.Add('SpecialCharacters', $policySettings.UserSettings.specialCharacters)
            }
            if ($null -ne $policySettings.UserSettings.uppercaseLetters)
            {
                $complexUserSettings.Add('UppercaseLetters', $policySettings.UserSettings.uppercaseLetters)
            }
            if ($null -ne $policySettings.UserSettings.requireSecurityDevice)
            {
                $complexUserSettings.Add('RequireSecurityDevice', $policySettings.UserSettings.requireSecurityDevice)
            }
            if ($null -ne $policySettings.UserSettings.usePassportForWork)
            {
                $complexUserSettings.Add('UsePassportForWork', $policySettings.UserSettings.usePassportForWork)
            }
            if ($complexUserSettings.Values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexUserSettings = $null
            }

            $policySettings.Remove('DeviceSettings') | Out-Null
            $policySettings.Remove('UserSettings') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                DeviceSettings        = $complexDeviceSettings
                UserSettings          = $complexUserSettings
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

        $templateReferenceId = 'fcef01f2-439d-4c3f-9184-823fd6e97646_1'
        $platforms = 'windows10'
        $technologies = 'mdm'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Account Protection Policy for Windows10 with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

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
            Write-Verbose -Message "Updating the Intune Account Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId `
                -ContainsDeviceAndUserSettings

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
            Write-Verbose -Message "Removing the Intune Account Protection Policy for Windows10 with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = 'fcef01f2-439d-4c3f-9184-823fd6e97646_1'
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

                if ($null -ne $Results.DeviceSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.DeviceSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.DeviceSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceSettings') | Out-Null
                    }
                }
                if ($null -ne $Results.UserSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.UserSettings `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.UserSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('UserSettings') | Out-Null
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
                    -NoEscape @('DeviceSettings', 'UserSettings', 'Assignments') `
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

    hidden [IntuneAccountProtectionPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAccountProtectionPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneAccountProtectionPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogDeviceSettings_IntuneAccountProtectionPolicyWindows10
{
    [DscProperty()]
    [System.ComponentModel.Description('Credential Guard (0: (Disabled) Turns off Credential Guard remotely if configured previously without UEFI Lock., 1: (Enabled with UEFI lock) Turns on Credential Guard with UEFI lock., 2: (Enabled without lock) Turns on Credential Guard without UEFI lock.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $LsaCfgFlags

    [DscProperty()]
    [System.ComponentModel.Description('Facial Features Use Enhanced Anti Spoofing (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $FacialFeaturesUseEnhancedAntiSpoofing

    [DscProperty()]
    [System.ComponentModel.Description('Enable Pin Recovery (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $EnablePinRecovery

    [DscProperty()]
    [System.ComponentModel.Description('Expiration')]
    [System.Nullable[System.Int32]] $Expiration

    [DscProperty()]
    [System.ComponentModel.Description('PIN History')]
    [System.Nullable[System.Int32]] $History

    [DscProperty()]
    [System.ComponentModel.Description('Lowercase Letters (0: Allows the use of lowercase letters in PIN., 1: Requires the use of at least one lowercase letters in PIN., 2: Does not allow the use of lowercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $LowercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Maximum PIN Length')]
    [System.Nullable[System.Int32]] $MaximumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Minimum PIN Length')]
    [System.Nullable[System.Int32]] $MinimumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Special Characters (0: Allows the use of special characters in PIN., 1: Requires the use of at least one special characters in PIN., 2: Does not allow the use of special characters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $SpecialCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Uppercase Letters (0: Allows the use of uppercase letters in PIN., 1: Requires the use of at least one uppercase letters in PIN., 2: Does not allow the use of uppercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $UppercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Require Security Device (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $RequireSecurityDevice

    [DscProperty()]
    [System.ComponentModel.Description('Use Certificate For On Prem Auth (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UseCertificateForOnPremAuth

    [DscProperty()]
    [System.ComponentModel.Description('Use Windows Hello For Business (Device) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UsePassportForWork
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogUserSettings_IntuneAccountProtectionPolicyWindows10
{
    [DscProperty()]
    [System.ComponentModel.Description('Enable Pin Recovery (User) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $EnablePinRecovery

    [DscProperty()]
    [System.ComponentModel.Description('Expiration (User)')]
    [System.Nullable[System.Int32]] $Expiration

    [DscProperty()]
    [System.ComponentModel.Description('PIN History (User)')]
    [System.Nullable[System.Int32]] $History

    [DscProperty()]
    [System.ComponentModel.Description('Lowercase Letters (User) (0: Allows the use of lowercase letters in PIN., 1: Requires the use of at least one lowercase letters in PIN., 2: Does not allow the use of lowercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $LowercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Maximum PIN Length (User)')]
    [System.Nullable[System.Int32]] $MaximumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Minimum PIN Length (User)')]
    [System.Nullable[System.Int32]] $MinimumPINLength

    [DscProperty()]
    [System.ComponentModel.Description('Special Characters (User) (0: Allows the use of special characters in PIN., 1: Requires the use of at least one special characters in PIN., 2: Does not allow the use of special characters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $SpecialCharacters

    [DscProperty()]
    [System.ComponentModel.Description('Uppercase Letters (User) (0: Allows the use of uppercase letters in PIN., 1: Requires the use of at least one uppercase letters in PIN., 2: Does not allow the use of uppercase letters in PIN.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $UppercaseLetters

    [DscProperty()]
    [System.ComponentModel.Description('Require Security Device (User) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $RequireSecurityDevice

    [DscProperty()]
    [System.ComponentModel.Description('Use Windows Hello For Business (User) (false: Disabled, true: Enabled)')]
    [ValidateSet('false', 'true')]
    [System.String] $UsePassportForWork
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
