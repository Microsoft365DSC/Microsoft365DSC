using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceEnrollmentPlatformRestriction : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Id of the device enrollment platform restriction.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the device enrollment platform restriction.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the device enrollment platform restriction.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Android for work restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $AndroidForWorkRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Android restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $AndroidRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Ios restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $IosRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Mac restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $MacOSRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Mac restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $MacRestriction

    [DscProperty()]
    [System.ComponentModel.Description('TV OS restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $TvosRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Vision OS restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $VisionOSRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Windows Home Sku restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $WindowsHomeSkuRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Windows mobile restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $WindowsMobileRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Windows restrictions based on platform, platform operating system version, and device ownership.')]
    [MSFT_DeviceEnrollmentPlatformRestriction] $WindowsRestriction

    [DscProperty()]
    [System.ComponentModel.Description('Support for Enrollment Configuration Type')]
    [ValidateSet('platformRestrictions', 'singlePlatformRestriction')]
    [System.String] $DeviceEnrollmentConfigurationType

    [DscProperty()]
    [System.ComponentModel.Description('Priority is used when a user exists in multiple groups that are assigned enrollment configuration. Users are subject only to the configuration with the lowest priority value.')]
    [System.Nullable[System.UInt32]] $Priority

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the policy.')]
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
    [System.ComponentModel.Description('Name of the Azure Active Directory tenant used for authentication. Format contoso.onmicrosoft.com')]
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

    [IntuneDeviceEnrollmentPlatformRestriction] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceEnrollmentPlatformRestriction]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Device Enrollment Restriction with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.DisplayName -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $PlatformType = ''
                $keys = (([Hashtable]$this.GetBoundParameters()).Clone()).Keys
                foreach ($key in $keys)
                {
                    if ($null -ne $this.GetBoundParameters().$key -and $key -like '*Restriction')
                    {
                        if ($this.DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction' )
                        {
                            $PlatformType = $key.Replace('Restriction', '')
                            break
                        }
                    }
                }

                $config = $null
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $config = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $config)
                {
                    Write-Verbose -Message "Could not find an Intune Device Enrollment Platform Restriction with Id {$($this.Id)}"
                    $config = Get-MgBetaDeviceManagementDeviceEnrollmentConfiguration -All -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue | Where-Object -FilterScript {
                            $_.'@odata.type' -in @('#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration', '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration') -and
                            ($null -eq $_.platformType -or $_.platformType -eq $PlatformType)
                    }

                    if ($null -eq $config)
                    {
                        Write-Verbose -Message "Could not find an Intune Device Enrollment Platform Restriction with DisplayName {$($this.DisplayName)}"
                        return $this.AsResult($nullResult)
                    }
                }
            }
            else
            {
                $config = $this.ExportedInstance
            }

            Write-Verbose -Message "Found Intune Device Enrollment Platform Restriction with Name {$($config.DisplayName)}"
            $results = @{
                Id                                = $config.Id
                DisplayName                       = $config.DisplayName
                Description                       = $config.Description
                RoleScopeTagIds                   = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $config.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                DeviceEnrollmentConfigurationType = $config.DeviceEnrollmentConfigurationType.ToString()
                Priority                          = $config.Priority
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                ApplicationSecret                 = $this.ApplicationSecret
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
            }

            $results += $this.GetDevicePlatformRestrictionSetting($config)

            if ($null -ne $results.WindowsMobileRestriction)
            {
                $results.Remove('WindowsMobileRestriction') | Out-Null
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $config
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementDeviceEnrollmentConfigurationAssignment -DeviceEnrollmentConfigurationId $config.Id
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

        Write-Verbose -Message "Setting configuration of the Intune Device Enrollment Platform Restriction with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        if ($this.Ensure -eq 'Absent' -and $this.Id -like '*_DefaultPlatformRestrictions')
        {
            throw 'Cannot delete the default platform restriction policy.'
        }

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('Id') | Out-Null
        $PriorityPresent = $false
        if ($boundParameters.Keys.Contains('Priority'))
        {
            $PriorityPresent = $true
            $boundParameters.Remove('Priority') | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Device Enrollment Platform Restriction with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null

            if ($createParameters.Keys.Contains('WindowsMobileRestriction'))
            {
                if ($this.WindowsMobileRestriction.platformBlocked -eq $false)
                {
                    Write-Verbose -Message 'Windows Mobile platform is deprecated and cannot be unblocked, reverting back to blocked'
                    $this.WindowsMobileRestriction.platformBlocked = $true
                }
            }

            $keys = (([Hashtable]$createParameters).Clone()).Keys
            foreach ($key in $keys)
            {
                if ($null -ne $createParameters.$key -and $key -like '*Restriction')
                {
                    if ($this.DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction')
                    {
                        $keyName = 'platformRestriction'
                        $createParameters.Add('platformType', ($key.Replace('Restriction', '')))
                        $createParameters.Add($keyName, $createParameters.$key)
                        $createParameters.Remove($key)
                    }
                }
            }

            $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
            if ($this.DeviceEnrollmentConfigurationType -eq 'platformRestrictions' )
            {
                $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration'
                $createParameters.Add('deviceEnrollmentConfigurationType', 'limit')
            }
            $createParameters.Add('@odata.type', $policyType)

            $policy = New-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
                -BodyParameter ([hashtable]$createParameters)

            # Assignments from DefaultPolicy are not editable and will raise an alert
            if ($policy.Id -notlike '*_DefaultPlatformRestrictions')
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceEnrollmentConfigurations' `
                    -RootIdentifier 'enrollmentConfigurationAssignments'

                if ($PriorityPresent -and $this.Priority -ne $policy.Priority)
                {
                    $Uri = '/beta/deviceManagement/deviceEnrollmentConfigurations/{0}/setPriority' -f $policy.Id
                    $Body = @{
                        priority = $this.Priority
                    }
                    Invoke-M365DSCGraphRequest -Method POST -Uri $Uri -Body $Body
                }
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Device Enrollment Platform Restriction with DisplayName {$($this.DisplayName)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null

            if ($updateParameters.Keys.Contains('WindowsMobileRestriction'))
            {
                if ($this.WindowsMobileRestriction.platformBlocked -eq $false)
                {
                    Write-Verbose -Message 'Windows Mobile platform is deprecated and cannot be unblocked, reverting back to blocked'
                    $this.WindowsMobileRestriction.platformBlocked = $true
                }
            }

            $keys = (([Hashtable]$updateParameters).Clone()).Keys
            foreach ($key in $keys)
            {
                if ($null -ne $updateParameters.$key -and $key -like '*Restriction')
                {
                    if ($this.DeviceEnrollmentConfigurationType -eq 'singlePlatformRestriction')
                    {
                        $keyName = 'platformRestriction'
                        $updateParameters.Add($keyName, $updateParameters.$key)
                        $updateParameters.Remove($key)
                    }
                }
            }

            $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration'
            if ($this.DeviceEnrollmentConfigurationType -eq 'platformRestrictions' )
            {
                $policyType = '#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration'
            }
            $updateParameters.Add('@odata.type', $policyType)

            Update-MgBetaDeviceManagementDeviceEnrollmentConfiguration `
                -DeviceEnrollmentConfigurationId $currentInstance.Id `
                -BodyParameter ([hashtable]$updateParameters)

            # Assignments from DefaultPolicy are not editable and will raise an alert
            if ($currentInstance.Id -notlike '*_DefaultPlatformRestrictions')
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $currentInstance.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceEnrollmentConfigurations' `
                    -RootIdentifier 'enrollmentConfigurationAssignments'

                if ($PriorityPresent -and $this.Priority -ne $currentInstance.Priority)
                {
                    $Uri = '/beta/deviceManagement/deviceEnrollmentConfigurations/{0}/setPriority' -f $currentInstance.Id
                    $Body = @{
                        priority = $this.Priority
                    }
                    Invoke-M365DSCGraphRequest -Method POST -Uri $Uri -Body $Body
                }
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Device Enrollment Platform Restriction with DisplayName {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementDeviceEnrollmentConfiguration -DeviceEnrollmentConfigurationId $currentInstance.Id
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
            [array]$configs = Get-M365DSCExportCachedCollection -Collection 'deviceEnrollmentConfigurations' `
                -ODataType @('microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration', 'microsoft.graph.deviceEnrollmentPlatformRestrictionConfiguration') `
                -Filter $this.Filter

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($configs.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($config in $configs)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($configs.Count)] $($config.displayName)" -DeferWrite
                $params = @{
                    Id                    = $config.id
                    DisplayName           = $config.displayName
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

                if ($null -ne $Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ([Array]$Results.Assignments) -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if ($complexTypeStringResult)
                    {
                        $Results.Assignments = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Assignments') | Out-Null
                    }
                }

                if ($null -ne $Results.IosRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.IosRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.IosRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('IosRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.WindowsRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.WindowsRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WindowsRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.WindowsHomeSkuRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsHomeSkuRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.WindowsHomeSkuRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WindowsHomeSkuRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.WindowsMobileRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.WindowsMobileRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.WindowsMobileRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('WindowsMobileRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.AndroidRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.AndroidRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.AndroidRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AndroidRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.AndroidForWorkRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.AndroidForWorkRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.AndroidForWorkRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AndroidForWorkRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.MacRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.MacRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.MacRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MacRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.MacOSRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.MacOSRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.MacOSRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('MacOSRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.TvosRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.TvosRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.TvosRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('TvosRestriction') | Out-Null
                    }
                }

                if ($null -ne $Results.VisionOSRestriction)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject ($Results.VisionOSRestriction) -CIMInstanceName DeviceEnrollmentPlatformRestriction
                    if ($complexTypeStringResult)
                    {
                        $Results.VisionOSRestriction = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('VisionOSRestriction') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Assignments', 'IosRestriction', 'WindowsRestriction', 'WindowsHomeSkuRestriction',
                    'WindowsMobileRestriction', 'AndroidRestriction', 'AndroidForWorkRestriction',
                    'MacRestriction', 'MacOSRestriction', 'TvosRestriction', 'VisionOSRestriction') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @('WindowsMobileRestriction')
        }
    }

    hidden [System.Collections.Hashtable] GetDevicePlatformRestrictionSetting([System.Collections.Hashtable] $Properties)
    {
        $results = @{}
        if ($null -ne $Properties.platformType)
        {
            $keyName = ($Properties.platformType).Substring(0, 1).ToUpper() + ($Properties.platformType).Substring(1, $Properties.platformType.length - 1) + 'Restriction'
            $keyValue = $Properties.platformRestriction
            $hash = @{}
            foreach ($key in $keyValue.Keys)
            {
                if ($null -ne $keyValue.$key)
                {
                    switch -Wildcard ($keyValue.$key.GetType().name)
                    {
                        '*[[\]]'
                        {
                            if ($keyValue.$key.Count -gt 0)
                            {
                                $hash.Add($key, $keyValue.$key)
                            }
                        }
                        'String'
                        {
                            if (-not [String]::IsNullOrEmpty($keyValue.$key))
                            {
                                $hash.Add($key, $keyValue.$key)
                            }
                        }
                        default
                        {
                            $hash.Add($key, $keyValue.$key)
                        }
                    }
                }
            }
            $results.Add($keyName, $hash)
        }
        else
        {
            $platformRestrictions = $Properties
            $platformRestrictions.Remove('@odata.type')
            $platformRestrictions.Remove('@odata.context')
            foreach ($key in $($platformRestrictions.Keys | Where-Object { $_ -like "*Restriction" }))
            {
                $keyName = $key.Substring(0, 1).ToUpper() + $key.Substring(1, $key.Length - 1)
                $keyValue = $platformRestrictions.$key
                if ($null -eq $keyValue)
                {
                    continue
                }
                $hash = @{}
                foreach ($key in $keyValue.Keys)
                {
                    if ($null -ne $keyValue.$key)
                    {
                        switch -Wildcard ($keyValue.$key.GetType().name)
                        {
                            '*[[\]]'
                            {
                                if ($keyValue.$key.Count -gt 0)
                                {
                                    $hash.Add($key, $keyValue.$key)
                                }
                            }
                            'String'
                            {
                                if (-not [String]::IsNullOrEmpty($keyValue.$key))
                                {
                                    $hash.Add($key, $keyValue.$key)
                                }
                            }
                            default
                            {
                                $hash.Add($key, $keyValue.$key)
                            }
                        }

                    }
                }
                $results.Add($keyName, $hash)
            }
        }

        return $results
    }

    hidden [IntuneDeviceEnrollmentPlatformRestriction] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceEnrollmentPlatformRestriction])
        {
            return $Values
        }

        $result = [IntuneDeviceEnrollmentPlatformRestriction]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_DeviceEnrollmentPlatformRestriction
{
    [DscProperty()]
    [System.ComponentModel.Description('Block the platform from enrolling.')]
    [System.Nullable[System.Boolean]] $PlatformBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Block personally owned devices from enrolling.')]
    [System.Nullable[System.Boolean]] $PersonalDeviceEnrollmentBlocked

    [DscProperty()]
    [System.ComponentModel.Description('Min OS version supported.')]
    [System.String] $OsMinimumVersion

    [DscProperty()]
    [System.ComponentModel.Description('Max OS version supported.')]
    [System.String] $OsMaximumVersion

    [DscProperty()]
    [System.ComponentModel.Description('Collection of blocked Manufacturers.')]
    [System.String[]] $BlockedManufacturers

    [DscProperty()]
    [System.ComponentModel.Description('Collection of blocked Skus.')]
    [System.String[]] $BlockedSkus
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
