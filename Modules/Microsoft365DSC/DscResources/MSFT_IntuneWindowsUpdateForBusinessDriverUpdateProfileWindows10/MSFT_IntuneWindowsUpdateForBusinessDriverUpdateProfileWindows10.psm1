using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Id of the Intune policy.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the Intune policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Intune policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Driver update profile approval type. For example, manual or automatic approval. Possible values are: manual, automatic.')]
    [ValidateSet('manual', 'automatic')]
    [System.String] $ApprovalType

    [DscProperty()]
    [System.ComponentModel.Description('Deployment deferral settings in days, only applicable when ApprovalType is set to automatic approval.')]
    [System.Nullable[System.UInt32]] $DeploymentDeferralInDays

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for the Driver Update entity.')]
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

    [IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Windows Update For Business Driver Update Profile for Windows 10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $uri = "/beta/deviceManagement/windowsDriverUpdateProfiles/$($this.Id)"
                    $response = Invoke-M365DSCGraphRequest -Method GET -Uri $uri -SkipHttpErrorCheck
                    if (-not [System.String]::IsNullOrEmpty($response.id))
                    {
                        $getValue = $response
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Driver Update Profile for Windows 10 with Id {$($this.Id)}"

                    if (-not [string]::IsNullOrEmpty($this.DisplayName))
                    {
                        # Potentially add support for -All parameter (@odata.nextLink) if needed
                        $uri = '/beta/deviceManagement/windowsDriverUpdateProfiles'
                        $getValue = (Invoke-M365DSCGraphRequest -Method GET -Uri $uri).value | Where-Object -Property displayName -EQ $this.DisplayName
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Windows Update For Business Driver Update Profie for Windows 10 with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Windows Update For Business Driver Update Profile for Windows 10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $results = @{
                #region resource generator code
                ApprovalType             = $getValue.approvalType
                DeploymentDeferralInDays = $getValue.deploymentDeferralInDays
                RoleScopeTagIds          = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.roleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Description              = $getValue.description
                DisplayName              = $getValue.displayName
                Id                       = $resolvedId
                Ensure                   = 'Present'
                Credential               = $this.Credential
                ApplicationId            = $this.ApplicationId
                TenantId                 = $this.TenantId
                ApplicationSecret        = $this.ApplicationSecret
                CertificateThumbprint    = $this.CertificateThumbprint
                CertificatePath          = $this.CertificatePath
                CertificatePassword      = $this.CertificatePassword
                ManagedIdentity          = $this.ManagedIdentity
                AccessTokens             = $this.AccessTokens
                #endregion
            }

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $uri = "/beta/deviceManagement/windowsDriverUpdateProfiles/$($resolvedId)/assignments"
                $assignmentsValues = (Invoke-M365DSCGraphRequest -Method GET -Uri $uri).value
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
            Write-Verbose -Message "Creating an Intune Windows Update For Business Driver Update Profile for Windows 10 with DisplayName {$($this.DisplayName)}"
            $createParameters = $boundParameters
            $createParameters.Remove('Assignments') | Out-Null
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $uri = '/beta/deviceManagement/windowsDriverUpdateProfiles'
            $policy = Invoke-M365DSCGraphRequest -Method POST -Uri $uri -Body $($createParameters | ConvertTo-Json)
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments

            if ($policy.id)
            {
                Update-DeviceConfigurationPolicyAssignment -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/windowsDriverUpdateProfiles'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Windows Update For Business Driver Update Profile for Windows 10 with Id {$($currentInstance.Id)}"
            $updateParameters = $boundParameters
            $updateParameters.Remove('Assignments') | Out-Null
            $updateParameters.Remove('ApprovalType') | Out-Null
            $updateParameters.Remove('Id') | Out-Null

            #region resource generator code
            $uri = "/beta/deviceManagement/windowsDriverUpdateProfiles/$($currentInstance.Id)"
            Invoke-M365DSCGraphRequest -Method PATCH -Uri $uri -Body $($updateParameters | ConvertTo-Json)
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/windowsDriverUpdateProfiles'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Windows Update For Business Driver Update Profile for Windows 10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            $uri = "/beta/deviceManagement/windowsDriverUpdateProfiles/$($currentInstance.Id)"
            Invoke-M365DSCGraphRequest -Method DELETE -Uri $uri
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
            # Filter is currently not supported
            [array]$getValue = (Invoke-M365DSCGraphRequest -Method GET -Uri '/beta/deviceManagement/windowsDriverUpdateProfiles?$expand=assignments').value
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

    hidden [IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10])
        {
            return $Values
        }

        $result = [IntuneWindowsUpdateForBusinessDriverUpdateProfileWindows10]::new()
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
