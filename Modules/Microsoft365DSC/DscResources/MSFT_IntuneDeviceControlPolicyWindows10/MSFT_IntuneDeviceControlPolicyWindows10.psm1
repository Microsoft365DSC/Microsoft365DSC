using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceControlPolicyWindows10 : M365DSCResourceBase
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
    [System.ComponentModel.Description('The list of policy rules to apply.')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRule[]] $PolicyRule

    [DscProperty()]
    [System.ComponentModel.Description('Apply layered order of evaluation for Allow and Prevent device installation policies across all device match criteria (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Allow_Deny_Layered

    [DscProperty()]
    [System.ComponentModel.Description('Allow installation of devices that match any of these device IDs (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_IDs_Allow

    [DscProperty()]
    [System.ComponentModel.Description('Allowed device IDs')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_IDs_Allow_List

    [DscProperty()]
    [System.ComponentModel.Description('Allow installation of devices that match any of these device instance IDs (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Instance_IDs_Allow

    [DscProperty()]
    [System.ComponentModel.Description('Allowed Instance IDs')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_Instance_IDs_Allow_List

    [DscProperty()]
    [System.ComponentModel.Description('Allow installation of devices using drivers that match these device setup classes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Classes_Allow

    [DscProperty()]
    [System.ComponentModel.Description('Allowed classes')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_Classes_Allow_List

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices not described by other policy settings (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Unspecified_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices that match any of these device IDs (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_IDs_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Prevented device IDs')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_IDs_Deny_List

    [DscProperty()]
    [System.ComponentModel.Description('Also apply to matching devices that are already installed. (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_IDs_Deny_Retroactive

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices that match any of these device instance IDs (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Instance_IDs_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Also apply to matching devices that are already installed. (Device) (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Instance_IDs_Deny_Retroactive

    [DscProperty()]
    [System.ComponentModel.Description('Prevented Instance IDs')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_Instance_IDs_Deny_List

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of devices using drivers that match these device setup classes (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Classes_Deny

    [DscProperty()]
    [System.ComponentModel.Description('Prevented Classes')]
    [ValidateLength(0, 2048)]
    [System.String[]] $DeviceInstall_Classes_Deny_List

    [DscProperty()]
    [System.ComponentModel.Description('Also apply to matching devices that are already installed. (0: False, 1: True)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Classes_Deny_Retroactive

    [DscProperty()]
    [System.ComponentModel.Description('Prevent installation of removable devices (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceInstall_Removable_Deny

    [DscProperty()]
    [System.ComponentModel.Description('WPD Devices: Deny read access (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $WPDDevices_DenyRead_Access_2

    [DscProperty()]
    [System.ComponentModel.Description('WPD Devices: Deny read access (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $WPDDevices_DenyRead_Access_1

    [DscProperty()]
    [System.ComponentModel.Description('WPD Devices: Deny write access (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $WPDDevices_DenyWrite_Access_2

    [DscProperty()]
    [System.ComponentModel.Description('WPD Devices: Deny write access (User) (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $WPDDevices_DenyWrite_Access_1

    [DscProperty()]
    [System.ComponentModel.Description('Allow Full Scan Removable Drive Scanning (0: Not allowed. Turns off scanning on removable drives., 1: Allowed. Scans removable drives.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowFullScanRemovableDriveScanning

    [DscProperty()]
    [System.ComponentModel.Description('Default Enforcement (1: Default Allow Enforcement, 2: Default Deny Enforcement)')]
    [ValidateSet('1', '2')]
    [System.String] $DefaultEnforcement

    [DscProperty()]
    [System.ComponentModel.Description('Device Control Enabled (0: Device Control is disabled, 1: Device Control is enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $DeviceControlEnabled

    [DscProperty()]
    [System.ComponentModel.Description('Allow Direct Memory Access (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowDirectMemoryAccess

    [DscProperty()]
    [System.ComponentModel.Description('Device Enumeration Policy (0: Block all (Most restrictive), 1: Only after log in/screen unlock, 2: Allow all (Least restrictive))')]
    [ValidateSet('0', '1', '2')]
    [System.String] $DeviceEnumerationPolicy

    [DscProperty()]
    [System.ComponentModel.Description('Removable Disk Deny Write Access (0: Disabled., 1: Enabled.)')]
    [ValidateSet('0', '1')]
    [System.String] $RemovableDiskDenyWriteAccess

    [DscProperty()]
    [System.ComponentModel.Description('Allow USB Connection (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowUSBConnection

    [DscProperty()]
    [System.ComponentModel.Description('Allow Bluetooth (0: Disallow Bluetooth. If this is set to 0, the radio in the Bluetooth control panel will be grayed out and the user will not be able to turn Bluetooth on., 1: Reserved. If this is set to 1, the radio in the Bluetooth control panel will be functional and the user will be able to turn Bluetooth on., 2: Allow Bluetooth. If this is set to 2, the radio in the Bluetooth control panel will be functional and the user will be able to turn Bluetooth on.)')]
    [ValidateSet('0', '1', '2')]
    [System.String] $AllowBluetooth

    [DscProperty()]
    [System.ComponentModel.Description('Allow Advertising (0: Not allowed. When set to 0, the device will not send out advertisements. To verify, use any Bluetooth LE app and enable it to do advertising. Then, verify that the advertisement is not received by the peripheral., 1: Allowed. When set to 1, the device will send out advertisements. To verify, use any Bluetooth LE app and enable it to do advertising. Then, verify that the advertisement is received by the peripheral.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowAdvertising

    [DscProperty()]
    [System.ComponentModel.Description('Allow Discoverable Mode (0: Not allowed. When set to 0, other devices will not be able to detect the device. To verify, open the Bluetooth control panel on the device. Then, go to another Bluetooth-enabled device, open the Bluetooth control panel, and verify that you cannot see the name of the device., 1: Allowed. When set to 1, other devices will be able to detect the device. To verify, open the Bluetooth control panel on the device. Then, go to another Bluetooth-enabled device, open the Bluetooth control panel and verify that you can discover it.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowDiscoverableMode

    [DscProperty()]
    [System.ComponentModel.Description('Allow Prepairing (0: Not allowed., 1: Allowed.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowPrepairing

    [DscProperty()]
    [System.ComponentModel.Description('Allow Prompted Proximal Connections (0: Disallow. Block users on these managed devices from using Swift Pair and other proximity based scenarios, 1: Allow. Allow users on these managed devices to use Swift Pair and other proximity based scenarios)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowPromptedProximalConnections

    [DscProperty()]
    [System.ComponentModel.Description('Services Allowed List')]
    [ValidateLength(0, 87516)]
    [System.String[]] $ServicesAllowedList

    [DscProperty()]
    [System.ComponentModel.Description('Allow Storage Card (0: SD card use is not allowed and USB drives are disabled. This setting does not prevent programmatic access to the storage card., 1: Allow a storage card.)')]
    [ValidateSet('0', '1')]
    [System.String] $AllowStorageCard

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

    [IntuneDeviceControlPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceControlPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Control Policy for Windows10 with Id {$($this.Id)} and Name {$($this.DisplayName)}"

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
                    Write-Verbose -Message "Could not find an Intune Device Control Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue

                        if ($getValue.Length -gt 1)
                        {
                            throw "Duplicate Intune Device Control Policy for Windows10 named $($this.DisplayName) exist in tenant"
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Control Policy for Windows10 with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Control Policy for Windows10 with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

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
            Write-Verbose -Message 'Exporting Calatog Policy Settings'
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            #region resource generator code
            Write-Verbose -Message 'Processing complex PolicyRule property'
            $complexPolicyRule = @()
            foreach ($currentPolicyRule in $policySettings.policyRule)
            {
                $complexEntry = @()
                foreach ($currentEntry in $currentPolicyRule.entry)
                {
                    $complexEntry += @{
                        Type        = $currentEntry.Type
                        Options     = $currentEntry.Options
                        Sid         = $currentEntry.Sid
                        AccessMask  = $currentEntry.AccessMask
                        ComputerSid = $currentEntry.ComputerSid
                    }
                }
                $myPolicyRule = [ordered]@{}
                $myPolicyRule.Add('Entry', $complexEntry)
                $myPolicyRule.Add('Name', $currentPolicyRule.name)
                $myPolicyRule.Add('ExcludedIdList_GroupId', $currentPolicyRule.excludedIdList_GroupId)
                $myPolicyRule.Add('IncludedIdList_GroupId', $currentPolicyRule.includedIdList_GroupId)
                $complexPolicyRule += $myPolicyRule
            }
            $policySettings.Remove('PolicyRule') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                PolicyRule            = $complexPolicyRule
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

            Write-Verbose -Message 'Getting Assignments'
            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()

            Write-Verbose -Message 'Converting Asignments'
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            Write-Verbose -Message 'Assignments converted'
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

        $templateReferenceId = '0f2034c6-3cd6-4ee1-bd37-f3c0693e9548_1'
        $platforms = 'windows10'
        $technologies = 'mdm,microsoftSense'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Control Policy for Windows10 with Name {$($this.DisplayName)}"
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
            Write-Verbose -Message "Updating the Intune Device Control Policy for Windows10 with Id {$($currentInstance.Id)}"
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
            Write-Verbose -Message "Removing the Intune Device Control Policy for Windows10 with Id {$($currentInstance.Id)}"
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
            $policyTemplateID = '0f2034c6-3cd6-4ee1-bd37-f3c0693e9548_1'
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

                if ($null -ne $Results.PolicyRule)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'PolicyRule'
                            CimInstanceName = 'MicrosoftGraphIntuneSettingsCatalogPolicyRule'
                            IsRequired      = $False
                        }
                        @{
                            Name            = 'Entry'
                            CimInstanceName = 'MicrosoftGraphIntuneSettingsCatalogPolicyRuleEntry'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.PolicyRule `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogPolicyRule' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.PolicyRule = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('PolicyRule') | Out-Null
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
                    -NoEscape @('PolicyRule', 'Assignments') `
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

    hidden [IntuneDeviceControlPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceControlPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceControlPolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRule
{
    [DscProperty()]
    [System.ComponentModel.Description('Entry')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRuleEntry[]] $Entry

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Excluded ID')]
    [System.String[]] $ExcludedIdList_GroupId

    [DscProperty()]
    [System.ComponentModel.Description('Included ID')]
    [System.String[]] $IncludedIdList_GroupId
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

class MSFT_MicrosoftGraphIntuneSettingsCatalogPolicyRuleEntry
{
    [DscProperty()]
    [System.ComponentModel.Description('Type (allow: Allow, deny: Deny, auditallowed: AuditAllowed, auditdenied: AuditDenied)')]
    [ValidateSet('allow', 'deny', 'auditallowed', 'auditdenied')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Options (0: None, 1: ShowNotification, 2: SendEvent, 3: SendNotificationAndEvent, 4: Disable)')]
    [ValidateSet('0', '1', '2', '3', '4')]
    [System.String] $Options

    [DscProperty()]
    [System.ComponentModel.Description('Sid')]
    [System.String] $Sid

    [DscProperty()]
    [System.ComponentModel.Description('Access mask (1: WDD_READ_ACCESS, 2: WDD_WRITE_ACCESS, 4: WDD_EXECUTE_ACCESS, 8: WDD_FS_READ_ACCESS, 16: WDD_FS_WRITE_ACCESS, 32: WDD_FS_EXECUTE_ACCESS, 64: WDD_PRINT_ACCESS)')]
    [ValidateSet('1', '2', '4', '8', '16', '32', '64')]
    [System.Int32[]] $AccessMask

    [DscProperty()]
    [System.ComponentModel.Description('Computer Sid')]
    [System.String] $ComputerSid
}
