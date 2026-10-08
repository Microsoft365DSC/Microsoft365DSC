using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Bluetooth. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $Bluetooth

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to boot from built-in network adapters. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $BootFromBuiltInNetworkAdapters

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to boot from external media. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $BootFromExternalMedia

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether built-in cameras are enabled. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $Cameras

    [DscProperty()]
    [System.ComponentModel.Description('Defines the permission level granted to users to change UEFI settings. Possible values are: notConfiguredOnly, none.')]
    [ValidateSet('notConfiguredOnly', 'none')]
    [System.String] $ChangeUefiSettingsPermission

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Front Camera. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $FrontCamera

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Infrared camera. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $InfraredCamera

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Microphone. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $Microphone

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether built-in microphones or speakers are enabled. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $MicrophonesAndSpeakers

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Near Field Communication. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $NearFieldCommunication

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether built-in radios e.g. WIFI, NFC, Bluetooth, are enabled. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $Radios

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable rear camera. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $RearCamera

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable SD Card Port. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $SdCard

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Simultaneous MultiThreading. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $SimultaneousMultiThreading

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable USB Type A Port. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $UsbTypeAPort

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether CPU and IO virtualization is enabled. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $VirtualizationOfCpuAndIO

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Wake on LAN. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $WakeOnLAN

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Wake On Power. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $WakeOnPower

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable WiFi. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $WiFi

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Windows Platform Binary Table. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $WindowsPlatformBinaryTable

    [DscProperty()]
    [System.ComponentModel.Description('Defines whether a user is allowed to enable Wireless Wide Area Network. Possible values are: notConfigured, enabled, disabled.')]
    [ValidateSet('notConfigured', 'enabled', 'disabled')]
    [System.String] $WirelessWideAreaNetwork

    [DscProperty()]
    [System.ComponentModel.Description('Admin provided description of the Device Configuration.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('The device mode applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleDeviceMode] $DeviceManagementApplicabilityRuleDeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('The OS edition applicability for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsEdition] $DeviceManagementApplicabilityRuleOsEdition

    [DscProperty()]
    [System.ComponentModel.Description('The OS version applicability rule for this Policy.')]
    [MSFT_DeviceManagementApplicabilityRuleOsVersion] $DeviceManagementApplicabilityRuleOsVersion

    [DscProperty(Key)]
    [System.ComponentModel.Description('Admin provided name of the device configuration.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

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

    [IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Configuration Firmware Interface Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                #region resource generator code
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementDeviceConfiguration -All -Filter "Id eq '$($this.Id)'" -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Firmware Interface Policy for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementDeviceConfiguration `
                            -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and isof('microsoft.graph.windows10DeviceFirmwareConfigurationInterface')" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Device Configuration Firmware Interface Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Device Configuration Firmware Interface Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $complexDeviceManagementApplicabilityRuleDeviceMode = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('DeviceMode', $getValue.DeviceManagementApplicabilityRuleDeviceMode.DeviceMode)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('Name', $getValue.DeviceManagementApplicabilityRuleDeviceMode.Name)
            $complexDeviceManagementApplicabilityRuleDeviceMode.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleDeviceMode.RuleType)
            if ($complexDeviceManagementApplicabilityRuleDeviceMode.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleDeviceMode = $null
            }

            $complexDeviceManagementApplicabilityRuleOsEdition = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSEdition.Name)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('OsEditionTypes', [string[]]$getValue.DeviceManagementApplicabilityRuleOSEdition.OsEditionTypes)
            $complexDeviceManagementApplicabilityRuleOsEdition.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSEdition.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsEdition.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsEdition = $null
            }

            $complexDeviceManagementApplicabilityRuleOsVersion = [ordered]@{}
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MaxOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MaxOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('MinOSVersion', $getValue.DeviceManagementApplicabilityRuleOSVersion.MinOSVersion)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('Name', $getValue.DeviceManagementApplicabilityRuleOSVersion.Name)
            $complexDeviceManagementApplicabilityRuleOsVersion.Add('RuleType', $getValue.DeviceManagementApplicabilityRuleOSVersion.RuleType)
            if ($complexDeviceManagementApplicabilityRuleOsVersion.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexDeviceManagementApplicabilityRuleOsVersion = $null
            }

            $results = @{
                #region resource generator code
                Bluetooth                                   = $getValue.bluetooth
                BootFromBuiltInNetworkAdapters              = $getValue.bootFromBuiltInNetworkAdapters
                BootFromExternalMedia                       = $getValue.bootFromExternalMedia
                Cameras                                     = $getValue.cameras
                ChangeUefiSettingsPermission                = $getValue.changeUefiSettingsPermission
                FrontCamera                                 = $getValue.frontCamera
                InfraredCamera                              = $getValue.infraredCamera
                Microphone                                  = $getValue.microphone
                MicrophonesAndSpeakers                      = $getValue.microphonesAndSpeakers
                NearFieldCommunication                      = $getValue.nearFieldCommunication
                Radios                                      = $getValue.radios
                RearCamera                                  = $getValue.rearCamera
                SdCard                                      = $getValue.sdCard
                SimultaneousMultiThreading                  = $getValue.simultaneousMultiThreading
                UsbTypeAPort                                = $getValue.usbTypeAPort
                VirtualizationOfCpuAndIO                    = $getValue.virtualizationOfCpuAndIO
                WakeOnLAN                                   = $getValue.wakeOnLAN
                WakeOnPower                                 = $getValue.wakeOnPower
                WiFi                                        = $getValue.wiFi
                WindowsPlatformBinaryTable                  = $getValue.windowsPlatformBinaryTable
                WirelessWideAreaNetwork                     = $getValue.wirelessWideAreaNetwork
                Description                                 = $getValue.Description
                DeviceManagementApplicabilityRuleDeviceMode = $complexDeviceManagementApplicabilityRuleDeviceMode
                DeviceManagementApplicabilityRuleOsEdition  = $complexDeviceManagementApplicabilityRuleOsEdition
                DeviceManagementApplicabilityRuleOsVersion  = $complexDeviceManagementApplicabilityRuleOsVersion
                DisplayName                                 = $getValue.DisplayName
                RoleScopeTagIds                             = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                                          = $getValue.Id
                Ensure                                      = 'Present'
                Credential                                  = $this.Credential
                ApplicationId                               = $this.ApplicationId
                TenantId                                    = $this.TenantId
                ApplicationSecret                           = $this.ApplicationSecret
                CertificateThumbprint                       = $this.CertificateThumbprint
                CertificatePath                             = $this.CertificatePath
                CertificatePassword                         = $this.CertificatePassword
                ManagedIdentity                             = $this.ManagedIdentity
                AccessTokens                                = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceConfigurationAssignment -DeviceConfigurationId $resolvedId
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

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Configuration Firmware Interface Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $createParameters.Add('@odata.type', '#microsoft.graph.windows10DeviceFirmwareConfigurationInterface')
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
            Write-Verbose -Message "Updating the Intune Device Configuration Firmware Interface Policy for Windows10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $updateParameters.Add('@odata.type', '#microsoft.graph.windows10DeviceFirmwareConfigurationInterface')
            Update-MgBetaDeviceManagementDeviceConfiguration `
                -DeviceConfigurationId $currentInstance.Id `
                -BodyParameter $updateParameters
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceConfigurations'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Configuration Firmware Interface Policy for Windows10 with Id {$($currentInstance.Id)}"
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
                -ODataType 'microsoft.graph.windows10DeviceFirmwareConfigurationInterface' `
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

                $displayedKey = $config.Id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    Id                    = $config.Id
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

                if ($Results.DeviceManagementApplicabilityRuleDeviceMode)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleDeviceMode -CIMInstanceName DeviceManagementApplicabilityRuleDeviceMode
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleDeviceMode = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleDeviceMode') | Out-Null
                    }
                }

                if ($Results.DeviceManagementApplicabilityRuleOsEdition)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsEdition -CIMInstanceName DeviceManagementApplicabilityRuleOsEdition
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsEdition = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsEdition') | Out-Null
                    }
                }

                if ($Results.DeviceManagementApplicabilityRuleOsVersion)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.DeviceManagementApplicabilityRuleOsVersion -CIMInstanceName DeviceManagementApplicabilityRuleOsVersion
                    if ($complexTypeStringResult)
                    {
                        $Results.DeviceManagementApplicabilityRuleOsVersion = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('DeviceManagementApplicabilityRuleOsVersion') | Out-Null
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
                    -NoEscape @('Assignments', 'DeviceManagementApplicabilityRuleDeviceMode', 'DeviceManagementApplicabilityRuleOsEdition', 'DeviceManagementApplicabilityRuleOsVersion') `
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

    hidden [IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneDeviceConfigurationFirmwareInterfacePolicyWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceManagementApplicabilityRuleDeviceMode
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule for device mode')]
    [ValidateSet('standardConfiguration', 'sModeConfiguration')]
    [System.String] $DeviceMode

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsEdition
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Applicability rule OS edition type')]
    [System.String[]] $OsEditionTypes

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
}

class MSFT_DeviceManagementApplicabilityRuleOsVersion
{
    [DscProperty()]
    [System.ComponentModel.Description('Name for object')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version for Applicability Rule')]
    [System.String] $MinOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version for Applicability Rule')]
    [System.String] $MaxOSVersion

    [DscProperty()]
    [System.ComponentModel.Description('Applicability Rule type')]
    [ValidateSet('include', 'exclude')]
    [System.String] $RuleType
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
