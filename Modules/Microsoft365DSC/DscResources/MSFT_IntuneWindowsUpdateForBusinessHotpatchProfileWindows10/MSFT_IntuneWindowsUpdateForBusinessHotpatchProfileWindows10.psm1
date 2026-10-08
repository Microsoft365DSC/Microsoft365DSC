using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsUpdateForBusinessHotpatchProfileWindows10 : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('Indicates the display name of the device cleanup rule.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Indicates the description for the device clean up rule.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if hotpatch is enabled.')]
    [System.Nullable[System.Boolean]] $HotpatchEnabled

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the approval settings for the Windows quality update policy.')]
    [MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting[]] $ApprovalSettings

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

    IntuneWindowsUpdateForBusinessHotpatchProfileWindows10() : base()
    {
        $this.ResourceCache['BaseUrl'] = '/beta/deviceManagement/windowsQualityUpdatePolicies'
    }

    [IntuneWindowsUpdateForBusinessHotpatchProfileWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsUpdateForBusinessHotpatchProfileWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Invoke-M365DSCGraphRequest -Method GET -Uri "$($this.ResourceCache['BaseUrl'])/$($this.Id)" -SkipHttpErrorCheck -ErrorAction SilentlyContinue
                    if ($getValue -is [hashtable] -and $getValue.ContainsKey('error'))
                    {
                        $getValue = $null
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = (Invoke-M365DSCGraphRequest -Method GET -Uri $this.ResourceCache['BaseUrl']).value | Where-Object -FilterScript {
                            $_.displayName -eq $($this.DisplayName -replace "'", "''")
                        }
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Hotpatch Profile for Windows10 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.id
            Write-Verbose -Message "An Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            #region resource generator code
            $complexApprovalSettings = @()
            foreach ($currentApprovalSettings in $getValue.approvalSettings)
            {
                $myApprovalSettings = @{}
                if ($null -ne $currentApprovalSettings.approvalMethodType)
                {
                    $myApprovalSettings.Add('ApprovalMethodType', $currentApprovalSettings.approvalMethodType)
                }
                $myApprovalSettings.Add('DeferredDeploymentInDay', $currentApprovalSettings.deferredDeploymentInDay)
                if ($null -ne $currentApprovalSettings.windowsQualityUpdateCadence)
                {
                    $myApprovalSettings.Add('WindowsQualityUpdateCadence', $currentApprovalSettings.windowsQualityUpdateCadence.ToString())
                }
                if ($null -ne $currentApprovalSettings.windowsQualityUpdateCategory)
                {
                    $myApprovalSettings.Add('WindowsQualityUpdateCategory', $currentApprovalSettings.windowsQualityUpdateCategory.ToString())
                }
                if ($myApprovalSettings.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexApprovalSettings += $myApprovalSettings
                }
            }
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.description
                DisplayName           = $getValue.displayName
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.roleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                ApprovalSettings      = $complexApprovalSettings
                HotpatchEnabled       = $getValue.hotpatchEnabled
                Id                    = $getValue.id
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

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = (Invoke-M365DSCGraphRequest -Uri "$($this.ResourceCache['BaseUrl'])/$($resolvedId)/assignments").value
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

        Write-Verbose -Message "Setting configuration of the Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $boundParameters.RoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $boundParameters.Remove('Assignments') | Out-Null

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Windows Update For Business Hotpatch Profile for Windows10 with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = Invoke-M365DSCGraphRequest -Method POST -Uri $this.ResourceCache['BaseUrl'] `
                -Body $($createParameters | ConvertTo-Json -Depth 10)

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/windowsQualityUpdatePolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            Invoke-M365DSCGraphRequest -Method PATCH -Uri "$($this.ResourceCache['BaseUrl'])/$($currentInstance.Id)" `
                -Body $($updateParameters | ConvertTo-Json -Depth 10)

            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/windowsQualityUpdatePolicies'

            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Update For Business Hotpatch Profile for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Invoke-M365DSCGraphRequest -Method DELETE -Uri "$($this.ResourceCache['BaseUrl'])/$($currentInstance.Id)"
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
            $filterQuery = "?`$expand=assignments"
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $filterQuery += "&`$filter=$($this.Filter)"
            }
            [array]$getValue = (Invoke-M365DSCGraphRequest -Method GET -Uri "/beta/deviceManagement/windowsQualityUpdatePolicies$filterQuery" -ErrorAction Stop).value
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

                if ($null -ne $Results.ApprovalSettings)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.ApprovalSettings `
                        -CIMInstanceName 'MicrosoftGraphWindowsQualityUpdateApprovalSetting'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.ApprovalSettings = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('ApprovalSettings') | Out-Null
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
                    -NoEscape @('Assignments', 'ApprovalSettings') `
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

    hidden [IntuneWindowsUpdateForBusinessHotpatchProfileWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsUpdateForBusinessHotpatchProfileWindows10])
        {
            return $Values
        }

        $result = [IntuneWindowsUpdateForBusinessHotpatchProfileWindows10]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphWindowsQualityUpdateApprovalSetting
{
    [DscProperty()]
    [System.ComponentModel.Description('The approval method of the Windows quality update policy. Possible values are: automatic, manual.')]
    [ValidateSet('automatic', 'manual')]
    [System.String] $ApprovalMethodType

    [DscProperty()]
    [System.ComponentModel.Description('The number of days to defer the deployment of the Windows quality update.')]
    [System.Nullable[System.UInt32]] $DeferredDeploymentInDay

    [DscProperty()]
    [System.ComponentModel.Description('The publishing cadence of the Windows quality update. Possible values are: monthly, outOfBand.')]
    [ValidateSet('monthly', 'outOfBand')]
    [System.String] $WindowsQualityUpdateCadence

    [DscProperty()]
    [System.ComponentModel.Description('The category of the Windows quality update. Possible values are: all, nonSecurity, quickMachineRecovery, security.')]
    [ValidateSet('all', 'nonSecurity', 'quickMachineRecovery', 'security')]
    [System.String] $WindowsQualityUpdateCategory
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
