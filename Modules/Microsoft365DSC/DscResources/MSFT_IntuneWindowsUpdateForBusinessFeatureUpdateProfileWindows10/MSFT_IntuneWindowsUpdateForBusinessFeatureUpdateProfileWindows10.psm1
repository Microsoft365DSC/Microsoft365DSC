using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display name of the profile.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The description of the profile which is specified by the user.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The feature update version that will be deployed to the devices targeted by this profile. The version could be any supported version for example 1709, 1803 or 1809 and so on.')]
    [System.String] $FeatureUpdateVersion

    [DscProperty()]
    [System.ComponentModel.Description('If true, the Windows 11 update will become optional')]
    [System.Nullable[System.Boolean]] $InstallFeatureUpdatesOptional

    [DscProperty()]
    [System.ComponentModel.Description('If true, the latest Microsoft Windows 10 update will be installed on devices ineligible for Microsoft Windows 11. Cannot be changed after creation of the policy.')]
    [System.Nullable[System.Boolean]] $InstallLatestWindows10OnWindows11IneligibleDevice

    [DscProperty()]
    [System.ComponentModel.Description('The windows update rollout settings, including offer start date time, offer end date time, and days between each set of offers. For ''as soon as possible'' installation, set this setting to $null or do not configure it.')]
    [MSFT_MicrosoftGraphwindowsUpdateRolloutSettings] $RolloutSettings

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

    [IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Windows Update For Business Feature Update Profile for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -WindowsFeatureUpdateProfileId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Feature Update Profile for Windows10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile `
                            -All `
                            -Top 200 `
                            -ErrorAction SilentlyContinue | Where-Object `
                            -FilterScript {
                            $_.DisplayName -eq $this.DisplayName
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Feature Update Profile for Windows10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Windows Update For Business Feature Update Profile for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            #region resource generator code
            $complexRolloutSettings = [ordered]@{}
            if ($null -ne $getValue.RolloutSettings.offerEndDateTimeInUTC)
            {
                $complexRolloutSettings.Add('OfferEndDateTimeInUTC', ([DateTimeOffset]$getValue.RolloutSettings.offerEndDateTimeInUTC).ToString('o'))
            }
            $complexRolloutSettings.Add('OfferIntervalInDays', $getValue.RolloutSettings.offerIntervalInDays)
            if ($null -ne $getValue.RolloutSettings.offerStartDateTimeInUTC)
            {
                $complexRolloutSettings.Add('OfferStartDateTimeInUTC', ([DateTimeOffset]$getValue.RolloutSettings.offerStartDateTimeInUTC).ToString('o'))
            }
            if ($complexRolloutSettings.values.Where({ $null -ne $_ }).Count -eq 0)
            {
                $complexRolloutSettings = $null
            }
            #endregion

            $results = @{
                #region resource generator code
                Description                                       = $getValue.Description
                DisplayName                                       = $getValue.DisplayName
                RoleScopeTagIds                                   = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                FeatureUpdateVersion                              = $getValue.FeatureUpdateVersion
                InstallFeatureUpdatesOptional                     = $getValue.InstallFeatureUpdatesOptional
                InstallLatestWindows10OnWindows11IneligibleDevice = $getValue.InstallLatestWindows10OnWindows11IneligibleDevice
                RolloutSettings                                   = $complexRolloutSettings
                Id                                                = $getValue.Id
                Ensure                                            = 'Present'
                Credential                                        = $this.Credential
                ApplicationId                                     = $this.ApplicationId
                TenantId                                          = $this.TenantId
                ApplicationSecret                                 = $this.ApplicationSecret
                CertificateThumbprint                             = $this.CertificateThumbprint
                CertificatePath                                   = $this.CertificatePath
                CertificatePassword                               = $this.CertificatePassword
                ManagedIdentity                                   = $this.ManagedIdentity
                AccessTokens                                      = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-MgBetaDeviceManagementWindowsFeatureUpdateProfileAssignment -WindowsFeatureUpdateProfileId $resolvedId
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
        $offerStartDate = $null
        $currentTime = $null
        $offerEndDate = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        # Rollout is not "As soon as possible"
        if ($null -ne $this.RolloutSettings)
        {
            # Rollout is either "On a specific date" or "gradually"
            if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferStartDateTimeInUTC))
            {
                $currentTime = Get-Date
                $offerStartDate = [datetime]::Parse($this.RolloutSettings.OfferStartDateTimeInUTC)
                # Rollout is "On a specific date"
                if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferEndDateTimeInUTC))
                {
                    $offerEndDate = [datetime]::Parse($this.RolloutSettings.OfferEndDateTimeInUTC)
                    if ($offerEndDate -lt $offerStartDate.AddDays(1))
                    {
                        throw 'OfferEndDateTimeInUTC must be greater than OfferStartDateTimeInUTC + 1 day.'
                    }

                    if ($offerEndDate -le $currentTime)
                    {
                        throw 'OfferEndDateTimeInUTC must be greater than the current time.'
                    }
                }
            }
        }

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()
        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        if ($null -eq $this.RolloutSettings)
        {
            $boundParameters.rolloutSettings = @{
                offerStartDateTimeInUTC = $null
                offerEndDateTimeInUTC   = $null
                offerIntervalInDays     = $null
            }
        }

        foreach ($dateProperty in @('offerStartDateTimeInUTC', 'offerEndDateTimeInUTC'))
        {
            if ($boundParameters.rolloutSettings.$dateProperty -is [System.String] -and
                [System.String]::IsNullOrWhiteSpace($boundParameters.rolloutSettings.$dateProperty))
            {
                $boundParameters.rolloutSettings.$dateProperty = $null
            }
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Windows Update For Business Feature Update Profile for Windows10 with DisplayName {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            if ($null -ne $this.RolloutSettings)
            {
                if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferStartDateTimeInUTC))
                {
                    $minTimeForAvailable = $currentTime
                    $newOfferStartDate = $offerStartDate
                    if ($offerStartDate -lt $minTimeForAvailable)
                    {
                        $newOfferStartDate = $minTimeForAvailable
                        $boundParameters.rolloutSettings.offerStartDateTimeInUTC = $newOfferStartDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                    }

                    if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferEndDateTimeInUTC))
                    {
                        # If an end date is configured, then the start date must be at least the current time + 2 days
                        $minTimeForAvailable = $currentTime.AddDays(2)
                        if ($newOfferStartDate -lt $minTimeForAvailable)
                        {
                            Write-Verbose -Message 'OfferStartDateTimeInUTC must be at least the current time + 2 days, adjusting it...'
                            $newOfferStartDate = $minTimeForAvailable
                            $boundParameters.rolloutSettings.offerStartDateTimeInUTC = $newOfferStartDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                        }

                        if ($offerEndDate -lt $newOfferStartDate.AddDays(1))
                        {
                            throw 'OfferEndDateTimeInUTC must be greater than OfferStartDateTimeInUTC + 1 day.'
                        }

                        if ($this.RolloutSettings.OfferIntervalInDays -gt ($offerEndDate - $newOfferStartDate).Days)
                        {
                            throw 'OfferIntervalInDays must be less than or equal to the difference between OfferEndDateTimeInUTC and OfferStartDateTimeInUTC in days.'
                        }
                    }
                }
            }

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaDeviceManagementWindowsFeatureUpdateProfile -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/windowsFeatureUpdateProfiles'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Windows Update For Business Feature Update Profile for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('InstallLatestWindows10OnWindows11IneligibleDevice') | Out-Null

            if ($null -ne $this.RolloutSettings)
            {
                if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferStartDateTimeInUTC))
                {
                    $minTimeForAvailable = $currentTime
                    if (-not [string]::IsNullOrEmpty($currentInstance.RolloutSettings.OfferStartDateTimeInUTC))
                    {
                        $currentOfferDate = [datetime]::Parse($currentInstance.RolloutSettings.OfferStartDateTimeInUTC)
                    }
                    else
                    {
                        $currentOfferDate = [datetime]::MinValue
                    }
                    $newOfferStartDate = $offerStartDate

                    # If the configured start date is different from the current start date but less than the current time, we use the current start date
                    if ($offerStartDate -ne $currentOfferDate -and $offerStartDate -lt $minTimeForAvailable)
                    {
                        if ($currentOfferDate -eq [datetime]::MinValue)
                        {
                            $newOfferStartDate = $minTimeForAvailable
                            $currentOfferDate = $minTimeForAvailable
                        }
                        else
                        {
                            $newOfferStartDate = $currentOfferDate
                        }
                        $boundParameters.rolloutSettings.offerStartDateTimeInUTC = $newOfferStartDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                    }

                    if (-not [string]::IsNullOrEmpty($this.RolloutSettings.OfferEndDateTimeInUTC))
                    {
                        # If an end date is configured, then the start date must be at least the current time + 2 days
                        $offerEndDate = [datetime]::Parse($this.RolloutSettings.OfferEndDateTimeInUTC)
                        $minTimeForAvailable = $currentTime.AddDays(2)
                        if ($newOfferStartDate -lt $minTimeForAvailable)
                        {
                            Write-Verbose -Message 'OfferStartDateTimeInUTC must be at least the current time + 2 days, adjusting it...'
                            $newOfferStartDate = $minTimeForAvailable
                            $boundParameters.rolloutSettings.offerStartDateTimeInUTC = $newOfferStartDate.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
                        }

                        if ($offerEndDate -lt $newOfferStartDate.AddDays(1))
                        {
                            throw 'OfferEndDateTimeInUTC must be greater than OfferStartDateTimeInUTC + 1 day.'
                        }

                        if ($this.RolloutSettings.OfferIntervalInDays -gt ($offerEndDate - $newOfferStartDate).Days)
                        {
                            throw 'OfferIntervalInDays must be less than or equal to the difference between OfferEndDateTimeInUTC and OfferStartDateTimeInUTC in days.'
                        }
                    }

                    $payloadStartDate = [datetime]::MinValue
                    if ([datetime]::TryParse($boundParameters.rolloutSettings.offerStartDateTimeInUTC, [ref] $payloadStartDate) -and
                        $payloadStartDate -lt $currentTime)
                    {
                        $boundParameters.rolloutSettings.Remove('offerStartDateTimeInUTC') | Out-Null
                    }
                }
            }

            $updateParameters = ([Hashtable]$boundParameters).Clone()
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Update-MgBetaDeviceManagementWindowsFeatureUpdateProfile `
                -WindowsFeatureUpdateProfileId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $currentInstance.id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/windowsFeatureUpdateProfiles'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Update For Business Feature Update Profile for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementWindowsFeatureUpdateProfile -WindowsFeatureUpdateProfileId $currentInstance.Id
            #endregion
        }
    }

    [bool] Test()
    {
        #region Telemetry
        $this.AddTelemetry('Test')
        #endregion

        $currentValues = $this.Get().ToHashtable()

        if (($null -eq $this.RolloutSettings -and $null -ne $currentValues.RolloutSettings) -or `
            ($null -ne $this.RolloutSettings -and $null -eq $currentValues.RolloutSettings))
        {
            Write-Verbose -Message 'RolloutSettings is null in either the desired configuration or the current configuration.'
            Write-Verbose -Message "Test() returned $false"
            return $false
        }

        if ($currentValues.Ensure -ne $this.Ensure)
        {
            if ($this.Ensure -eq 'Present')
            {
                $currentTime = Get-Date
                [datetime]$offerStartDate = [datetime]::MinValue
                [datetime]$offerEndDate = [datetime]::MinValue
                [datetime]::TryParse($this.RolloutSettings.OfferStartDateTimeInUTC, [ref]$offerStartDate) | Out-Null
                [datetime]::TryParse($this.RolloutSettings.OfferEndDateTimeInUTC, [ref]$offerEndDate) | Out-Null
                if (($offerStartDate -ne [datetime]::MinValue -and $offerStartDate -lt $currentTime) `
                        -and ($offerEndDate -ne [datetime]::MinValue -and $offerEndDate -lt $currentTime))
                {
                    Write-Verbose -Message 'Start and end time are in the past, skip the configuration.'
                    Write-Verbose -Message "Test() returned $true"
                    return $true
                }
            }

            Write-Verbose -Message "Test() returned $false"
            return $false
        }

        $compareParameters = $this.GetCompareParameters()
        return (Test-M365DSCTargetResource -DesiredValues $this.GetBoundParameters() `
                -ResourceName $this.GetResourceName() `
                @compareParameters `
                -CurrentValues $currentValues)
    }


    [string] Export()
    {
        $complexFunctions = $null
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
            # Filter not supported on this resource
            # [array]$getValue = Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -Filter $Filter -All -ErrorAction Stop
            if (-not [string]::IsNullOrEmpty($this.Filter))
            {
                Write-Warning -Message 'Microsoft Graph filter is not supported on this resource. Only best-effort filtering using startswith, endswith and contains is supported.'
                $complexFunctions = Get-ComplexFunctionsFromFilterQuery -FilterQuery $this.Filter
            }
            [array]$getValue = Get-MgBetaDeviceManagementWindowsFeatureUpdateProfile -All -Top 200 -ErrorAction Stop
            $getValue = Find-GraphDataUsingComplexFunctions -ComplexFunctions $complexFunctions -Policies $getValue
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

                if ( $null -ne $Results.RolloutSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.RolloutSettings `
                        -CIMInstanceName 'MicrosoftGraphWindowsUpdateRolloutSettings'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.RolloutSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('RolloutSettings') | Out-Null
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
                    -NoEscape @('RolloutSettings', 'Assignments') `
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
            ExcludedProperties = @('InstallLatestWindows10OnWindows11IneligibleDevice')
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                # RolloutSettings drift is evaluated with rollout-date rules instead of the generic compare.
                $desiredRollout = $DesiredValues.RolloutSettings
                $currentRollout = $CurrentValues.RolloutSettings
                $testResult = $true
                if ($null -eq $desiredRollout -or $null -eq $currentRollout)
                {
                    $testResult = ($null -eq $desiredRollout -and $null -eq $currentRollout)
                }
                else
                {
                    $currentTime = Get-Date
                    [datetime]$offerStartDate = [datetime]::MinValue
                    [datetime]$offerEndDate = [datetime]::MinValue
                    [datetime]$currentOfferStartDate = [datetime]::MinValue
                    [datetime]$currentOfferEndDate = [datetime]::MinValue
                    [datetime]::TryParse($desiredRollout.OfferStartDateTimeInUTC, [ref]$offerStartDate) | Out-Null
                    [datetime]::TryParse($desiredRollout.OfferEndDateTimeInUTC, [ref]$offerEndDate) | Out-Null
                    [datetime]::TryParse($currentRollout.OfferStartDateTimeInUTC, [ref]$currentOfferStartDate) | Out-Null
                    [datetime]::TryParse($currentRollout.OfferEndDateTimeInUTC, [ref]$currentOfferEndDate) | Out-Null

                    if (($offerEndDate -eq [datetime]::MinValue -and $currentOfferEndDate -ne [datetime]::MinValue) -or `
                        ($offerEndDate -ne [datetime]::MinValue -and $currentOfferEndDate -eq [datetime]::MinValue))
                    {
                        Write-Verbose -Message 'OfferEndDateTimeInUTC is null in either the desired configuration or the current configuration.'
                        $testResult = $false
                    }

                    if ($testResult -and $offerStartDate -ne [datetime]::MinValue -and $currentOfferStartDate -ne [datetime]::MinValue)
                    {
                        if ($offerStartDate -ne $currentOfferStartDate `
                                -and $offerStartDate -gt $currentTime)
                        {
                            Write-Verbose -Message 'OfferStartDateTimeInUTC is different from current.'
                            $testResult = $false
                        }

                        if ($testResult -and $offerEndDate -ne [datetime]::MinValue -and $currentOfferEndDate -ne [datetime]::MinValue)
                        {
                            if ($offerStartDate -ne $currentOfferStartDate `
                                    -and $offerStartDate -gt $currentTime `
                                    -and $offerStartDate -lt $currentTime.AddDays(2))
                            {
                                Write-Verbose -Message 'OfferStartDateTimeInUTC must be greater than the current time + 2 days to be changable if OfferEndDateTimeInUTC is specified, resetting testResult to true.'
                                $testResult = $true
                            }

                            if ($offerEndDate -ne $currentOfferEndDate `
                                    -and $offerEndDate -gt $currentTime `
                                    -and $offerEndDate -gt $offerStartDate)
                            {
                                Write-Verbose -Message 'OfferEndDateTimeInUTC is different from current.'
                                $testResult = $false
                            }

                            if ($testResult -and $desiredRollout.OfferIntervalInDays -ne $currentRollout.OfferIntervalInDays)
                            {
                                Write-Verbose -Message 'OfferIntervalInDays is different from current.'
                                $testResult = $false
                            }
                        }
                    }
                }

                if ($testResult)
                {
                    $ValuesToCheck.Remove('RolloutSettings') | Out-Null
                }
                else
                {
                    $DesiredValues['RolloutSettings'] = @{ Drift = 'desired' }
                    $CurrentValues['RolloutSettings'] = @{ Drift = 'current' }
                    $ValuesToCheck['RolloutSettings'] = $DesiredValues['RolloutSettings']
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10])
        {
            return $Values
        }

        $result = [IntuneWindowsUpdateForBusinessFeatureUpdateProfileWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphwindowsUpdateRolloutSettings
{
    [DscProperty()]
    [System.ComponentModel.Description('The feature update''s ending  of release date and time to be set, update, and displayed for a feature Update profile for example: 2020-06-09T10:00:00Z.')]
    [System.String] $OfferEndDateTimeInUTC

    [DscProperty()]
    [System.ComponentModel.Description('The number of day(s) between each set of offers to be set, updated, and displayed for a feature update profile, for example: if OfferStartDateTimeInUTC is 2020-06-09T10:00:00Z, and OfferIntervalInDays is 1, then the next two sets of offers will be made consecutively on 2020-06-10T10:00:00Z (next day at the same specified time) and 2020-06-11T10:00:00Z (next next day at the same specified time) with 1 day in between each set of offers.')]
    [System.Nullable[System.UInt32]] $OfferIntervalInDays

    [DscProperty()]
    [System.ComponentModel.Description('The feature update''s starting date and time to be set, update, and displayed for a feature Update profile for example: 2020-06-09T10:00:00Z.')]
    [System.String] $OfferStartDateTimeInUTC
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
