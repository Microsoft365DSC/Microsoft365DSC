using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneDeviceEnrollmentScopeConfigurationMdm : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Only valid value is ''Yes''.')]
    [ValidateSet('Yes')]
    [System.String] $IsSingleInstance

    [DscProperty()]
    [System.ComponentModel.Description('Controls the option if users in an automatic enrollment configuration on Microsoft Entra registered devices are prompted to MDM enroll their device in the Entra account registration flow.')]
    [System.Nullable[System.Boolean]] $IsMdmEnrollmentDuringRegistrationDisabled

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the user scope of the mobility management policy. The possible values are: none, all, selected.')]
    [ValidateSet('none', 'all', 'selected')]
    [System.String] $AppliesTo

    [DscProperty()]
    [System.ComponentModel.Description('Compliance URL of the mobility management application.')]
    [System.String] $ComplianceUrl

    [DscProperty()]
    [System.ComponentModel.Description('Discovery URL of the mobility management application.')]
    [System.String] $DiscoveryUrl

    [DscProperty()]
    [System.ComponentModel.Description('Terms of Use URL of the mobility management application.')]
    [System.String] $TermsOfUseUrl

    [DscProperty()]
    [System.ComponentModel.Description('The group display names that are included if the scope is set to ''Selected''.')]
    [System.String[]] $IncludedGroups

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Admin')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Azure Active Directory tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Access token used for authentication.')]
    [System.String[]] $AccessTokens

    [IntuneDeviceEnrollmentScopeConfigurationMdm] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneDeviceEnrollmentScopeConfigurationMdm]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Device Enrollment Scope Configuration Mdm"

        try
        {
            if (-not $this.ExportedInstance)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $getValue = Get-MgBetaPolicyMobileDeviceManagementPolicy -ExpandProperty IncludedGroups -ErrorAction Stop
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "An Intune Device Enrollment Scope Configuration Mdm was found"

            #region resource generator code
            $enumAppliesTo = $null
            if ($null -ne $getValue.AppliesTo)
            {
                $enumAppliesTo = $getValue.AppliesTo
            }
            #endregion

            $includedGroupsValue = $null
            if ($enumAppliesTo -eq 'Selected')
            {
                $includedGroupsValue = @()
                foreach ($group in $getValue.IncludedGroups)
                {
                    $includedGroupsValue += $group.DisplayName
                }
            }

            $results = @{
                #region resource generator code
                IsSingleInstance                          = 'Yes'
                IsMdmEnrollmentDuringRegistrationDisabled = $getValue.isMdmEnrollmentDuringRegistrationDisabled
                AppliesTo                                 = $enumAppliesTo
                ComplianceUrl                             = $getValue.ComplianceUrl
                DiscoveryUrl                              = $getValue.DiscoveryUrl
                IncludedGroups                            = $includedGroupsValue
                TermsOfUseUrl                             = $getValue.TermsOfUseUrl
                Credential                                = $this.Credential
                TenantId                                  = $this.TenantId
                #endregion
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

        Write-Verbose -Message "Setting configuration of the Intune Device Enrollment Scope Configuration Mdm"

        if ($this.AppliesTo -eq 'Selected' -and $this.IncludedGroups.Count -eq 0)
        {
            throw "IncludedGroups cannot be empty when AppliesTo is set to 'Selected'. Please provide at least one group or change the AppliesTo value."
        }

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $updateParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $updateParameters = Rename-M365DSCCimInstanceParameter -Properties $updateParameters
        $updateParameters.Remove('IncludedGroups') | Out-Null
        $updateParameters.Remove('IsSingleInstance') | Out-Null

        $urlProps = $updateParameters.Clone()
        $urlProps.Remove('AppliesTo') | Out-Null
        foreach ($prop in ($updateParameters.Keys | Where-Object { $urlProps.ContainsKey($_) }))
        {
            if ([System.String]::IsNullOrEmpty($urlProps[$prop]))
            {
                $urlProps[$prop] = $null
            }
        }

        $nonUrlProps = $updateParameters.Clone()
        foreach ($key in $urlProps.Keys)
        {
            $nonUrlProps.Remove($key) | Out-Null
        }

        if ($nonUrlProps.ContainsKey('AppliesTo') -and $nonUrlProps['AppliesTo'] -eq 'Selected')
        {
            $nonUrlProps.Remove('AppliesTo') | Out-Null
        }

        #region resource generator code
        Update-MgBetaPolicyMobileDeviceManagementPolicy -MobileDeviceManagementPolicyId '0000000a-0000-0000-c000-000000000000' `
            -BodyParameter $urlProps `
            -ErrorAction Stop

        if ($nonUrlProps.Keys.Count -gt 0)
        {
            Update-MgBetaPolicyMobileDeviceManagementPolicy -MobileDeviceManagementPolicyId '0000000a-0000-0000-c000-000000000000' `
                -BodyParameter $nonUrlProps `
                -ErrorAction Stop
        }

        if ($this.GetBoundParameters().ContainsKey('IncludedGroups') -and $this.AppliesTo -eq 'Selected')
        {
            $diffs = Compare-Object -ReferenceObject $this.IncludedGroups -DifferenceObject @($currentInstance.IncludedGroups | Where-Object { $null -ne $_ })
            if ($diffs.Count -eq 0)
            {
                Write-Verbose -Message 'Included groups are already in the desired state.'
                return
            }

            Write-Verbose -Message "Updating the IncludedGroups of the Intune Device Enrollment Scope Configuration Mdm"
            foreach ($diff in $diffs)
            {
                $group = Get-MgGroup -All -Filter "displayName eq '$($diff.InputObject)'" -Property id
                if ($null -eq $group)
                {
                    throw "Failed to find group '$($diff.InputObject)' in the tenant. Please make sure it exists."
                }
                $request = @{}
                if ($diff.SideIndicator -eq "=>")
                {
                    $request.Add('Method', 'DELETE')
                    $request.Add('Uri', "/beta/policies/mobileDeviceManagementPolicies/0000000a-0000-0000-c000-000000000000/includedGroups/$($group.Id)/`$ref")
                }
                elseif ($diff.SideIndicator -eq "<=")
                {
                    $request.Add('Method', 'POST')
                    $request.Add('Body', @{ "@odata.id" = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)odata/groups('$($group.Id)')" })
                    $request.Add('Uri', "/beta/policies/mobileDeviceManagementPolicies/0000000a-0000-0000-c000-000000000000/includedGroups/`$ref")
                }
                Invoke-M365DSCGraphRequest @request -ErrorAction Stop
            }
        }
        #endregion
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
            [array]$getValue = Get-MgBetaPolicyMobileDeviceManagementPolicy -ExpandProperty IncludedGroups -ErrorAction Stop
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
                if (-not [System.String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                elseif (-not [System.String]::IsNullOrEmpty($config.name))
                {
                    $displayedKey = $config.name
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $params = @{
                    IsSingleInstance      = 'Yes'
                    Credential            = $this.Credential
                    TenantId              = $this.TenantId
                    AccessTokens          = $this.AccessTokens
                }

                $this.ExportedInstance = $config
                $Results = $this.GetForExport($Params)

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential
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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.AppliesTo -ne 'Selected')
                {
                    $ValuesToCheck.Remove('IncludedGroups')
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [IntuneDeviceEnrollmentScopeConfigurationMdm] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneDeviceEnrollmentScopeConfigurationMdm])
        {
            return $Values
        }

        $result = [IntuneDeviceEnrollmentScopeConfigurationMdm]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
