using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneCorporateDeviceIdentifier : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Array of corporate device identifiers.')]
    [MSFT_IntuneDeviceIdentifier[]] $Devices

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the identifiers exist, absent ensures all are removed.')]
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

    [IntuneCorporateDeviceIdentifier] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneCorporateDeviceIdentifier]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Corporate Device Identifier"

        try
        {
            $null = $this.Connect('MicrosoftGraph')

            #Ensure the proper dependencies are installed in the current environment.
            Confirm-M365DSCDependencies

            #region Telemetry
            $this.AddTelemetry('Get')
            #endregion

            $nullResult = $this.GetBoundParameters()
            $nullResult.Ensure = 'Absent'
            $nullResult.Devices = @()

            $allDevices = @(Get-MgBetaDeviceManagementImportedDeviceIdentity -All)

            if ($allDevices.Count -eq 0)
            {
                Write-Verbose -Message 'No corporate device identifiers found in Intune'
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found $($allDevices.Count) corporate device identifiers in Intune"

            # Convert to CIM instances
            $deviceArray = @()
            foreach ($device in $allDevices)
            {
                $deviceHash = @{
                    Id                         = $device.id
                    importedDeviceIdentifier   = $device.importedDeviceIdentifier
                    importedDeviceIdentityType = $device.importedDeviceIdentityType
                    Description                = $device.description
                    Platform                   = if ($device.platform)
                    {
                        $device.platform.ToLower()
                    }
                    else
                    {
                        $null
                    }
                }
                $deviceArray += $deviceHash
            }

            $results = @{
                IsSingleInstance      = 'Yes'
                Devices               = $deviceArray
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

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            return $this.AsResult($nullResult)
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        $null = $this.Connect('MicrosoftGraph')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $desiredParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $desiredParameters.Remove('IsSingleInstance') | Out-Null

        # Get current state
        $currentInstance = $this.Get().ToHashtable()

        if ($this.Ensure -eq 'Present')
        {
            # Convert CIM instances to hashtables for comparison
            $desiredDevices = @()
            if ($null -ne $this.Devices)
            {
                foreach ($device in $this.Devices)
                {
                    $desiredDevices += @{
                        importedDeviceIdentifier   = if ($device.importedDeviceIdentifier) { $device.importedDeviceIdentifier.Trim() } else { $null }
                        importedDeviceIdentityType = if ($device.importedDeviceIdentityType) { $device.importedDeviceIdentityType } else { $null }
                        description                = $device.description
                        platform                   = if ($device.platform) { $device.platform.ToLower() } else { $null }
                    }
                }
            }

            $currentDevices = @()
            if ($null -ne $currentInstance.Devices)
            {
                foreach ($device in $currentInstance.Devices)
                {
                    $currentDevices += @{
                        Id                         = $device.Id
                        importedDeviceIdentifier   = if ($device.importedDeviceIdentifier) { $device.importedDeviceIdentifier.Trim() } else { $null }
                        importedDeviceIdentityType = if ($device.importedDeviceIdentityType) { $device.importedDeviceIdentityType } else { $null }
                        description                = $device.description
                        platform                   = if ($device.platform) { $device.platform.ToLower() } else { $null }
                    }
                }
            }

            # Find devices to ADD (in desired but not in current)
            $devicesToAdd = @()
            foreach ($desiredDevice in $desiredDevices)
            {
                $found = $false
                foreach ($currentDevice in $currentDevices)
                {
                    if ($this.CompareDeviceIdentifier($desiredDevice, $currentDevice))
                    {
                        $found = $true
                        break
                    }
                }
                if (-not $found)
                {
                    $devicesToAdd += $desiredDevice
                }
            }

            # Find devices to REMOVE (in current but not in desired)
            $devicesToRemove = @()
            foreach ($currentDevice in $currentDevices)
            {
                $found = $false
                foreach ($desiredDevice in $desiredDevices)
                {
                    if ($this.CompareDeviceIdentifier($currentDevice, $desiredDevice))
                    {
                        $found = $true
                        break
                    }
                }
                if (-not $found)
                {
                    $devicesToRemove += $currentDevice
                }
            }

            # Add new devices
            if ($devicesToAdd.Count -gt 0)
            {
                Write-Verbose -Message "Adding $($devicesToAdd.Count) device identifier(s) to Intune"

                $importList = @()
                foreach ($device in $devicesToAdd)
                {
                    $deviceToImport = @{}

                    if (-not [System.String]::IsNullOrEmpty($device.importedDeviceIdentifier))
                    {
                        $deviceToImport.importedDeviceIdentifier = $device.importedDeviceIdentifier
                    }
                    if (-not [System.String]::IsNullOrEmpty($device.importedDeviceIdentityType))
                    {
                        $deviceToImport.importedDeviceIdentityType = $device.importedDeviceIdentityType
                    }
                    if (-not [System.String]::IsNullOrEmpty($device.description))
                    {
                        $deviceToImport.description = $device.description
                    }
                    if (-not [System.String]::IsNullOrEmpty($device.platform))
                    {
                        $deviceToImport.platform = $device.platform
                    }

                    $importList += $deviceToImport
                }

                try
                {
                    Import-MgBetaDeviceManagementImportedDeviceIdentityList `
                        -OverwriteImportedDeviceIdentities:$false `
                        -ImportedDeviceIdentities $importList
                    Write-Verbose -Message "Successfully added $($devicesToAdd.Count) device identifier(s)"
                }
                catch
                {
                    Write-Verbose -Message "Error adding device identifiers: $($_.Exception.Message)"
                    throw
                }
            }

            # Remove devices not in desired state
            if ($devicesToRemove.Count -gt 0)
            {
                Write-Verbose -Message "Removing $($devicesToRemove.Count) device identifier(s) from Intune"

                foreach ($device in $devicesToRemove)
                {

                    try
                    {
                        Remove-MgBetaDeviceManagementImportedDeviceIdentity -ImportedDeviceIdentityId $device.Id
                        Write-Verbose -Message "Successfully removed device identifier with Id: $($device.Id)"
                    }
                    catch
                    {
                        Write-Verbose -Message "Error removing device identifier with Id $($device.Id): $($_.Exception.Message)"
                        throw
                    }
                }
            }

            if ($devicesToAdd.Count -eq 0 -and $devicesToRemove.Count -eq 0)
            {
                Write-Verbose -Message 'No changes needed - current state matches desired state'
            }
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            # Remove ALL identifiers
            if ($null -ne $currentInstance.Devices -and $currentInstance.Devices.Count -gt 0)
            {
                Write-Verbose -Message "Removing all $($currentInstance.Devices.Count) device identifier(s) from Intune"

                foreach ($device in $currentInstance.Devices)
                {
                    try
                    {
                        Remove-MgBetaDeviceManagementImportedDeviceIdentity -ImportedDeviceIdentityId $device.Id
                        Write-Verbose -Message "Successfully removed device identifier with Id: $($device.Id)"
                    }
                    catch
                    {
                        Write-Verbose -Message "Error removing device identifier with Id $($device.Id): $($_.Exception.Message)"
                        throw
                    }
                }
            }
            else
            {
                Write-Verbose -Message 'No device identifiers to remove'
            }
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
            if ($null -ne $Global:M365DSCExportResourceInstancesCount)
            {
                $Global:M365DSCExportResourceInstancesCount++
            }

            $params = @{
                IsSingleInstance      = 'Yes'
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

            $Results = $this.GetForExport($Params)

            if ($Results.Ensure -eq 'Present' -and $null -ne $Results.Devices -and $Results.Devices.Count -gt 0)
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
                Write-M365DSCHost -Message "    |---[1/1] Corporate Device Identifiers ($($Results.Devices.Count) devices)" -CommitWrite

                # Handle complex type conversion for Devices array
                if ($Results.Devices)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'Devices'
                            CimInstanceName = 'MSFT_IntuneDeviceIdentifier'
                            IsRequired      = $False
                        }
                    )

                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Devices `
                        -CIMInstanceName 'MSFT_IntuneDeviceIdentifier' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Devices = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Devices') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Devices')

                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return $currentDSCBlock
            }
            else
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                return ''
            }
        }
        catch
        {
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [System.Boolean] CompareDeviceIdentifier([System.Collections.Hashtable] $Device1, [System.Collections.Hashtable] $Device2)
    {
        # Match on importedDeviceIdentifier and importedDeviceIdentityType if both have them
        if (-not [System.String]::IsNullOrEmpty($Device1.importedDeviceIdentifier) -and
            -not [System.String]::IsNullOrEmpty($Device2.importedDeviceIdentifier))
        {
            # Case-insensitive comparison for device identifiers
            $identifierMatch = ($Device1.importedDeviceIdentifier.ToLower() -eq $Device2.importedDeviceIdentifier.ToLower())

            # Also check type if both have it
            if (-not [System.String]::IsNullOrEmpty($Device1.importedDeviceIdentityType) -and
                -not [System.String]::IsNullOrEmpty($Device2.importedDeviceIdentityType))
            {
                return ($identifierMatch -and ($Device1.importedDeviceIdentityType -eq $Device2.importedDeviceIdentityType))
            }

            return $identifierMatch
        }

        # If we can't determine a match, consider them different
        return $false
    }

    hidden [IntuneCorporateDeviceIdentifier] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneCorporateDeviceIdentifier])
        {
            return $Values
        }

        $result = [IntuneCorporateDeviceIdentifier]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_IntuneDeviceIdentifier
{
    [DscProperty()]
    [System.ComponentModel.Description('Unique identifier for the imported device identity.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Imported Device Identifier')]
    [System.String] $importedDeviceIdentifier

    [DscProperty()]
    [System.ComponentModel.Description('Type of Imported Device Identity. Possible values are: unknown, imei, serialNumber, manufacturerModelSerial.')]
    [ValidateSet('unknown', 'imei', 'serialNumber', 'manufacturerModelSerial')]
    [System.String] $importedDeviceIdentityType

    [DscProperty()]
    [System.ComponentModel.Description('Description for the device identity.')]
    [System.String] $description

    [DscProperty()]
    [System.ComponentModel.Description('Platform of the device (e.g., Windows, Android, iOS).')]
    [System.String] $platform
}
