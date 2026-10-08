using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class SCLabelPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The Name parameter specifies the unique name for the sensitivity label. The maximum length is 64 characters. If the value contains spaces, enclose the value in quotation marks.')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Specify if this label policy should exist or not.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('The Comment parameter specifies an optional comment.')]
    [System.String] $Comment

    [DscProperty()]
    [System.ComponentModel.Description('The AdvancedSettings parameter enables client-specific features and capabilities on the sensitivity label. The settings that you configure with this parameter only affect apps that are designed for the setting.')]
    [MSFT_SCLabelSetting[]] $AdvancedSettings

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocation parameter specifies the mailboxes to include in the policy.')]
    [System.String[]] $ExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The ExchangeLocationException parameter specifies the mailboxes to exclude when you use the value All for the ExchangeLocation parameter.')]
    [System.String[]] $ExchangeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The ModernGroupLocation parameter specifies the Microsoft 365 Groups to include in the policy.')]
    [System.String[]] $ModernGroupLocation

    [DscProperty()]
    [System.ComponentModel.Description('The ModernGroupLocationException parameter specifies the Microsoft 365 Groups to exclude when you''re using the value All for the ModernGroupLocation parameter.')]
    [System.String[]] $ModernGroupLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The Labels parameter specifies the sensitivity labels that are associated with the policy. You can use any value that uniquely identifies the label.')]
    [System.String[]] $Labels

    [DscProperty()]
    [System.ComponentModel.Description('The AddExchangeLocation parameter specifies the mailboxes to add in the existing policy.')]
    [System.String[]] $AddExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The AddExchangeLocationException parameter specifies the mailboxes to add to exclusions when you use the value All for the ExchangeLocation parameter.')]
    [System.String[]] $AddExchangeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The AddModernGroupLocation parameter specifies the Microsoft 365 Groups to add to include the policy.')]
    [System.String[]] $AddModernGroupLocation

    [DscProperty()]
    [System.ComponentModel.Description('The AddModernGroupLocationException parameter specifies the Microsoft 365 Groups to add to exclusions when you''re using the value All for the ModernGroupLocation parameter.')]
    [System.String[]] $AddModernGroupLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The AddLabels parameter specifies the sensitivity labels to add to the policy. You can use any value that uniquely identifies the label.')]
    [System.String[]] $AddLabels

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveExchangeLocation parameter specifies the mailboxes to remove from the policy.')]
    [System.String[]] $RemoveExchangeLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveExchangeLocationException parameter specifies the mailboxes to remove when you use the value All for the ExchangeLocation parameter.')]
    [System.String[]] $RemoveExchangeLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveModernGroupLocation parameter specifies the Microsoft 365 Groups to remove from the policy.')]
    [System.String[]] $RemoveModernGroupLocation

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveModernGroupLocationException parameter specifies the Microsoft 365 Groups to remove from excluded values when you''re using the value All for the ModernGroupLocation parameter.')]
    [System.String[]] $RemoveModernGroupLocationException

    [DscProperty()]
    [System.ComponentModel.Description('The RemoveLabels parameter specifies the sensitivity labels that are removed from the policy. You can use any value that uniquely identifies the label.')]
    [System.String[]] $RemoveLabels

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Exchange Global Admin')]
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

    [SCLabelPolicy] Get()
    {
        $advancedSettingsValue = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [SCLabelPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Sensitivity Label Policy for $($this.Name)"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.Name)
            {
                if ($this.GetBoundParameters().ContainsKey('Labels') -and `
                    ($this.GetBoundParameters().ContainsKey('AddLabels') -or $this.GetBoundParameters().ContainsKey('RemoveLabels')))
                {
                    throw 'You cannot use the Labels parameter and the AddLabels or RemoveLabels parameters at the same time.'
                }

                if ($this.GetBoundParameters().ContainsKey('AddLabels') -and $this.GetBoundParameters().ContainsKey('RemoveLabels'))
                {
                    # Check if AddLabels and RemoveLabels contain the same labels
                    [array]$diff = Compare-Object -ReferenceObject $this.AddLabels -DifferenceObject $this.RemoveLabels -ExcludeDifferent -IncludeEqual
                    if ($diff.Count -gt 0)
                    {
                        throw 'Parameters AddLabels and RemoveLabels cannot contain the same labels. Make sure labels are not present in both parameters.'
                    }
                }

                $null = $this.Connect('SecurityComplianceCenter')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullReturn = $this.GetBoundParameters()
                $nullReturn.Ensure = 'Absent'

                try
                {
                    $policy = Invoke-M365DSCCommand -ScriptBlock { Get-LabelPolicy -Identity $this.Name -ErrorAction Stop } -SuppressNotFoundError
                }
                catch
                {
                    throw $_
                }

                if ($null -eq $policy -or "$($policy.Mode)" -eq 'PendingDeletion')
                {
                    Write-Verbose -Message "Sensitivity label policy $($this.Name) does not exist."
                    return $this.AsResult($nullReturn)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
            }

            if ($null -ne $policy.Settings)
            {
                Write-Verbose -Message 'Converting Settings'
                $advancedSettingsValue = $this.ConvertStringToAdvancedSettings($policy.Settings)
            }

            Write-Verbose "Found existing Sensitivity Label policy $($this.Name)"
            $result = @{
                Name                         = $policy.Name
                Comment                      = $policy.Comment
                AdvancedSettings             = $advancedSettingsValue
                Credential                   = $this.Credential
                ApplicationId                = $this.ApplicationId
                TenantId                     = $this.TenantId
                CertificateThumbprint        = $this.CertificateThumbprint
                CertificatePath              = $this.CertificatePath
                CertificatePassword          = $this.CertificatePassword
                Ensure                       = 'Present'
                Labels                       = $policy.Labels
                ExchangeLocation             = Get-M365DSCArrayFromProperty -PropertyValue $policy.ExchangeLocation.Name -ElementType ([System.String])
                ExchangeLocationException    = Get-M365DSCArrayFromProperty -PropertyValue $policy.ExchangeLocationException.Name -ElementType ([System.String])
                ModernGroupLocation          = Get-M365DSCArrayFromProperty -PropertyValue $policy.ModernGroupLocation.Name -ElementType ([System.String])
                ModernGroupLocationException = Get-M365DSCArrayFromProperty -PropertyValue $policy.ModernGroupLocationException.Name -ElementType ([System.String])
                AccessTokens                 = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of Sensitivity label policy for $($this.Name)"

        if ($this.GetBoundParameters().ContainsKey('Labels') -and `
            ($this.GetBoundParameters().ContainsKey('AddLabels') -or $this.GetBoundParameters().ContainsKey('RemoveLabels')))
        {
            throw 'You cannot use the Labels parameter and the AddLabels or RemoveLabels parameters at the same time.'
        }

        if ($this.GetBoundParameters().ContainsKey('AddLabels') -and $this.GetBoundParameters().ContainsKey('RemoveLabels'))
        {
            # Check if AddLabels and RemoveLabels contain the same labels
            [array]$diff = Compare-Object -ReferenceObject $this.AddLabels -DifferenceObject $this.RemoveLabels -ExcludeDifferent -IncludeEqual
            if ($diff.Count -gt 0)
            {
                throw 'Parameters AddLabels and RemoveLabels cannot contain the same labels. Make sure labels are not present in both parameters.'
            }
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $CurrentPolicy = $this.Get().ToHashtable()
        $boundParams = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        foreach ($locationProperty in @('ModernGroupLocation', 'ModernGroupLocationException', 'ExchangeLocation', 'ExchangeLocationException'))
        {
            if ($CurrentPolicy.Ensure -ne 'Present' -or -not $this.GetBoundParameters().ContainsKey($locationProperty))
            {
                continue
            }

            $desiredLocations = $this.GetBoundParameters()[$locationProperty]
            $currentLocations = $CurrentPolicy.$locationProperty

            [array]$diffs = Compare-Object `
                -ReferenceObject @($currentLocations | Where-Object { $null -ne $_ }) `
                -DifferenceObject @($desiredLocations | Where-Object { $null -ne $_ })
            if ($diffs.Count -gt 0)
            {
                $add = @()
                $remove = @()
                foreach ($diff in $diffs)
                {
                    if ($diff.SideIndicator -eq '<=')
                    {
                        Write-Verbose "Removing $locationProperty $($diff.InputObject) from policy $($this.Name)."
                        $remove += $diff.InputObject
                    }
                    elseif ($diff.SideIndicator -eq '=>')
                    {
                        Write-Verbose "Adding $locationProperty $($diff.InputObject) to policy $($this.Name)."
                        $add += $diff.InputObject
                    }
                }

                if ($add.Count -gt 0)
                {
                    $boundParams["Add$locationProperty"] = $add
                }

                if ($remove.Count -gt 0)
                {
                    $boundParams["Remove$locationProperty"] = $remove
                }
            }
            $boundParams.Remove($locationProperty) | Out-Null
        }

        if ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose "Creating new Sensitivity label policy '$($this.Name)'."
            $CreationParams = $boundParams

            if ($this.GetBoundParameters().ContainsKey('AdvancedSettings'))
            {
                $advanced = $this.ConvertCIMToAdvancedSettings($this.AdvancedSettings)
                $CreationParams['AdvancedSettings'] = $advanced
            }

            if ($this.GetBoundParameters().ContainsKey('AddLabels'))
            {
                $CreationParams['Labels'] = $this.AddLabels
            }
            $CreationParams.Remove('AddLabels') | Out-Null
            $CreationParams.Remove('RemoveLabels') | Out-Null

            # Remove parameters not used in New-LabelPolicy
            $CreationParams.Remove('AddExchangeLocation') | Out-Null
            $CreationParams.Remove('AddExchangeLocationException') | Out-Null
            $CreationParams.Remove('AddModernGroupLocation') | Out-Null
            $CreationParams.Remove('AddModernGroupLocationException') | Out-Null
            $CreationParams.Remove('RemoveExchangeLocation') | Out-Null
            $CreationParams.Remove('RemoveExchangeLocationException') | Out-Null
            $CreationParams.Remove('RemoveModernGroupLocation') | Out-Null
            $CreationParams.Remove('RemoveModernGroupLocationException') | Out-Null

            try
            {
                New-LabelPolicy @CreationParams
            }
            catch
            {
                $this.LogError($_, "Error calling New-LabelPolicy for {$($this.Name)}:")
                throw
            }
            try
            {
                Start-Sleep 5
                Write-Verbose "Updating Sensitivity label policy '$($this.Name)' settings."
                $SetParams = $boundParams

                if ($this.GetBoundParameters().ContainsKey('AdvancedSettings'))
                {
                    $advanced = $this.ConvertCIMToAdvancedSettings($this.AdvancedSettings)
                    $SetParams['AdvancedSettings'] = $advanced
                }

                #Remove unused parameters for Set-Label cmdlet
                $SetParams.Remove('Name') | Out-Null
                $SetParams.Remove('ExchangeLocationException') | Out-Null
                $SetParams.Remove('ExchangeLocation') | Out-Null
                $SetParams.Remove('ModernGroupLocation') | Out-Null
                $SetParams.Remove('ModernGroupLocationException') | Out-Null

                # Labels are already set during creation, removing parameters
                $SetParams.Remove('Labels') | Out-Null
                $SetParams.Remove('AddLabels') | Out-Null
                $SetParams.Remove('RemoveLabels') | Out-Null

                Set-LabelPolicy @SetParams -Identity $this.Name
            }
            catch
            {
                $this.LogError($_, "Error calling Set-LabelPolicy for {$($this.Name)}:")
                throw
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose "Updating existing Sensitivity label policy '$($this.Name)'."
            $SetParams = $boundParams

            if ($this.GetBoundParameters().ContainsKey('AdvancedSettings'))
            {
                $advanced = $this.ConvertCIMToAdvancedSettings($this.AdvancedSettings)
                $SetParams['AdvancedSettings'] = $advanced
            }

            if ($this.GetBoundParameters().ContainsKey('Labels'))
            {
                [array]$diffs = Compare-Object -ReferenceObject $CurrentPolicy.Labels -DifferenceObject $this.Labels
                if ($diffs.Count -gt 0)
                {
                    $add = @()
                    $remove = @()
                    foreach ($diff in $diffs)
                    {
                        if ($diff.SideIndicator -eq '<=')
                        {
                            Write-Verbose "Removing label $($diff.InputObject) from policy $($this.Name)."
                            $remove += $diff.InputObject
                        }
                        elseif ($diff.SideIndicator -eq '=>')
                        {
                            Write-Verbose "Adding label $($diff.InputObject) to policy $($this.Name)."
                            $add += $diff.InputObject
                        }
                    }

                    if ($add.Count -gt 0)
                    {
                        $SetParams['AddLabels'] = $add
                    }

                    if ($remove.Count -gt 0)
                    {
                        $SetParams['RemoveLabels'] = $remove
                    }
                }
                $SetParams.Remove('Labels') | Out-Null
            }

            #Remove unused parameters for Set-Label cmdlet
            $SetParams.Remove('Name') | Out-Null
            $SetParams.Remove('ExchangeLocationException') | Out-Null
            $SetParams.Remove('ExchangeLocation') | Out-Null
            $SetParams.Remove('ModernGroupLocation') | Out-Null
            $SetParams.Remove('ModernGroupLocationException') | Out-Null

            try
            {
                Set-LabelPolicy @SetParams -Identity $this.Name
            }
            catch
            {
                $this.LogError($_, "Error calling Set-LabelPolicy for {$($this.Name)}:")
                throw
            }
        }
        elseif ($this.Ensure -eq 'Absent' -and $CurrentPolicy.Ensure -eq 'Present')
        {
            # If the label exists and it shouldn't, simply remove it;Need to force deletoion
            Write-Verbose -Message "Deleting Sensitivity label policy $($this.Name)."

            try
            {
                Remove-LabelPolicy -Identity $this.Name -Confirm:$false
            }
            catch
            {
                $this.LogError($_, "Error calling Remove-LabelPolicy for {$($this.Name)}:")
                throw
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

        $ConnectionMode = $this.Connect('SecurityComplianceCenter')

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Export')

        try
        {
            [array]$policies = Get-LabelPolicy -ErrorAction Stop -WarningAction Ignore

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1
            if ($policies.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }
            foreach ($policy in $policies)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($policies.Count)] $($policy.Name)" -DeferWrite

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport(@{ Name = $policy.Name })
                $rawResults = $Results.Clone()

                if ($null -ne $Results.AdvancedSettings)
                {
                    $complexMapping = @(
                        @{
                            Name            = 'AdvancedSettings'
                            CimInstanceName = 'MSFT_SCLabelSetting'
                            IsRequired      = $False
                        }
                    )
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.AdvancedSettings `
                        -CIMInstanceName 'MSFT_SCLabelSetting' `
                        -ComplexTypeMapping $complexMapping

                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.AdvancedSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('AdvancedSettings') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('AdvancedSettings') `
                    -RawResults $rawResults

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                [void]$dscContent.Append($currentDSCBlock)
                Save-M365DSCPartialExport -Content $currentDSCBlock `
                    -FileName $Global:PartialExportFileName
                $i++
            }
        }
        catch
        {
            $this.LogError($_, 'Error during Export:')

            throw
        }
        return $dscContent.ToString()
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return @{
            ExcludedProperties = @(
                'AddLabels',
                'AddExchangeLocation',
                'AddExchangeLocationException',
                'AddModernGroupLocation',
                'AddModernGroupLocationException',
                'RemoveLabels',
                'RemoveExchangeLocation',
                'RemoveExchangeLocationException',
                'RemoveModernGroupLocation',
                'RemoveModernGroupLocationException'
            )
            PostProcessing     = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)
                if ($null -ne $DesiredValues.AdvancedSettings)
                {
                    $TestAdvancedSettings = [SCLabelPolicy]::TestAdvancedSettings($DesiredValues.AdvancedSettings, $CurrentValues.AdvancedSettings)
                    if ($TestAdvancedSettings)
                    {
                        $ValuesToCheck.Remove('AdvancedSettings') | Out-Null
                    }
                    else
                    {
                        $DesiredValues['AdvancedSettings'] = @{ Drift = 'desired' }
                        $CurrentValues['AdvancedSettings'] = @{ Drift = 'current' }
                        $ValuesToCheck['AdvancedSettings'] = $DesiredValues['AdvancedSettings']
                    }
                }

                foreach ($deltaProperty in @('ModernGroupLocation', 'ModernGroupLocationException', 'ExchangeLocation', 'ExchangeLocationException', 'Labels'))
                {
                    $desired = $DesiredValues[$deltaProperty]
                    $added = $DesiredValues["Add$deltaProperty"]
                    $removed = $DesiredValues["Remove$deltaProperty"]
                    if ($null -eq $desired -and $null -eq $added -and $null -eq $removed)
                    {
                        continue
                    }

                    $configData = [SCLabelPolicy]::NewPolicyData($desired, $CurrentValues[$deltaProperty], $removed, $added)

                    if ($null -eq $configData -and $null -ne $CurrentValues[$deltaProperty] -and $null -ne $removed)
                    {
                        $DesiredValues[$deltaProperty] = "$deltaProperty drift detected"
                        $CurrentValues[$deltaProperty] = "$deltaProperty drift current"
                        $ValuesToCheck[$deltaProperty] = "$deltaProperty drift detected"
                        continue
                    }

                    $current = @($CurrentValues[$deltaProperty] | Where-Object { $null -ne $_ -and '' -ne $_ })
                    $expected = @($configData | Where-Object { $null -ne $_ -and '' -ne $_ })
                    $DesiredValues[$deltaProperty] = [System.String[]] $expected
                    $CurrentValues[$deltaProperty] = [System.String[]] $current
                    $ValuesToCheck[$deltaProperty] = [System.String[]] $expected
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [System.Object] ConvertCIMToAdvancedSettings([System.Object] $AdvancedSettings)
    {
        $entry = @{}
        foreach ($obj in $AdvancedSettings)
        {
            $settingsValues = ''
            if ($obj.Key -like '*defaultlabel*')
            {
                if ($obj.Value -ne 'None')
                {
                    $label = Get-Label | Where-Object -FilterScript { $_.DisplayName -eq $obj.Value }
                    if ($null -eq $label)
                    {
                        throw "Label {$($obj.value)} doesn't exist. Please define the Sensitivy label first before trying to assign it to a policy."
                    }
                    else
                    {
                        $settingsValues = $label.ImmutableId.ToString()
                    }
                }
                else
                {
                    $settingsValues = 'None'
                }
            }
            else
            {
                foreach ($objVal in $obj.Value)
                {
                    $settingsValues += $objVal
                    $settingsValues += ','
                }
            }
            $entry[$obj.Key] = $settingsValues.TrimEnd(',')
        }

        return $entry
    }

    hidden [System.Object[]] ConvertStringToAdvancedSettings([System.String[]] $AdvancedSettings)
    {
        $settings = @()
        $labelLookup = $null
        foreach ($setting in $AdvancedSettings)
        {
            Write-Verbose -Message "SETTING: $setting"
            $settingString = $setting.Replace('[', '').Replace(']', '')
            $settingKey = $settingString.Split(',')[0]

            if ($settingKey -ne 'displayname')
            {
                $startPos = $settingString.IndexOf(',', 0) + 1
                $valueString = $settingString.Substring($startPos, $settingString.Length - $startPos).Trim()
                        $values = $null
                if ($valueString -like '*,*')
                {
                    $values = $valueString -split ','
                }
                else
                {
                    $values = $valueString
                }

                if ($settingKey -like '*defaultlabel*')
                {
                    if ($values -ne 'None')
                    {
                        if ($null -eq $labelLookup)
                        {
                            $labelLookup = @{}
                            foreach ($lbl in (Get-Label -ErrorAction SilentlyContinue))
                            {
                                if ($null -ne $lbl.ImmutableId)
                                {
                                    $labelLookup[$lbl.ImmutableId.ToString()] = $lbl.DisplayName
                                }
                            }
                        }

                        $resolved = $labelLookup[$values.ToString()]
                        if (-not [System.String]::IsNullOrEmpty($resolved))
                        {
                            $values = $resolved
                        }
                    }
                }

                $entry = [ordered]@{
                    Key   = $settingKey
                    Value = $values
                }
                $settings += $entry
            }
        }

        return $settings
    }

    hidden static [System.Collections.ArrayList] NewPolicyData([System.Object] $ConfigData, [System.Object] $CurrentData, [System.Object] $RemovedData, [System.Object] $AdditionalData)
    {
        $desiredData = [System.Collections.ArrayList]::new()
        foreach ($currentItem in $CurrentData)
        {
            if (-not $desiredData.Contains($currentItem))
            {
                $desiredData.Add($currentItem) | Out-Null
            }
        }

        foreach ($currentItem in $ConfigData)
        {
            if (-not $desiredData.Contains("$currentItem"))
            {
                $desiredData.Add($currentItem) | Out-Null
            }
        }

        foreach ($currentItem in $RemovedData)
        {
            $desiredData.Remove($currentItem) | Out-Null
        }

        foreach ($currentItem in $AdditionalData)
        {
            if (-not $desiredData.Contains("$currentItem"))
            {
                $desiredData.Add($currentItem) | Out-Null
            }
        }

        return $desiredData
    }

    hidden static [System.Boolean] IsSettingValueEqual([System.Object] $DesiredValue, [System.Object] $CurrentValue)
    {
        $desiredTexts = [System.Collections.Generic.List[System.String]]::new()
        foreach ($entry in @($DesiredValue))
        {
            $text = [System.String] $entry
            if ($text.Length -gt 0)
            {
                $desiredTexts.Add($text)
            }
        }

        $currentTexts = [System.Collections.Generic.List[System.String]]::new()
        foreach ($entry in @($CurrentValue))
        {
            $text = [System.String] $entry
            if ($text.Length -gt 0)
            {
                $currentTexts.Add($text)
            }
        }

        if ($desiredTexts.Count -ne $currentTexts.Count)
        {
            return $false
        }

        if ($desiredTexts.Count -gt 1)
        {
            $desiredTexts.Sort([System.StringComparer]::OrdinalIgnoreCase)
            $currentTexts.Sort([System.StringComparer]::OrdinalIgnoreCase)
        }

        for ($index = 0; $index -lt $desiredTexts.Count; $index++)
        {
            if ($desiredTexts[$index] -ne $currentTexts[$index])
            {
                return $false
            }
        }

        return $true
    }

    hidden static [System.Collections.Hashtable] NewMemberLookup([System.Object] $Items, [System.String] $MemberName)
    {
        $lookup = @{}
        foreach ($item in @($Items))
        {
            if ($null -eq $item)
            {
                continue
            }

            $key = [System.String] $item.$MemberName
            if (-not $lookup.ContainsKey($key))
            {
                $lookup[$key] = $item
            }
        }

        return $lookup
    }

    hidden static [System.Boolean] TestAdvancedSettings([System.Object] $DesiredProperty, [System.Object] $CurrentProperty)
    {
        $foundSettings = $true
        $currentSettings = [SCLabelPolicy]::NewMemberLookup($CurrentProperty, 'Key')
        foreach ($desiredSetting in @($DesiredProperty))
        {
            if ($null -eq $desiredSetting)
            {
                continue
            }

            $currentSetting = $currentSettings[[System.String] $desiredSetting.Key]
            if ($null -eq $currentSetting)
            {
                continue
            }

            if (-not [SCLabelPolicy]::IsSettingValueEqual($desiredSetting.Value, $currentSetting.Value))
            {
                $foundSettings = $false
                break
            }
        }

        Write-Verbose -Message "Test AdvancedSettings returned {$foundSettings}"
        return $foundSettings
    }

    hidden [SCLabelPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [SCLabelPolicy])
        {
            return $Values
        }

        $result = [SCLabelPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_SCLabelSetting
{
    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Advanced settings key.')]
    [System.String] $Key

    [DscProperty()]
    [System.ComponentModel.Description('Advanced settings value.')]
    [System.String[]] $Value
}
