using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneManagedInstallerPolicyWindows10 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Description of the Managed Installer Policy.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the Managed Installer Policy')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Indicates if Intune is considered a Managed Installer.')]
    [System.Nullable[System.Boolean]] $IsIntuneManagedInstaller

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tag IDs for the device health script')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneManagedInstallerPolicyWindows10] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneManagedInstallerPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Managed Installer Policy for Windows10 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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

            $getValue = $null
            #region resource generator code
            if (-not [string]::IsNullOrEmpty($this.Id))
            {
                $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $this.Id -ErrorAction SilentlyContinue
            }

            if ($null -eq $getValue)
            {
                if (-not [string]::IsNullOrEmpty($this.Id))
                {
                    Write-Verbose -Message "Could not find an Intune Managed Installer Policy for Windows10 with Id {$($this.Id)}"
                }

                if (-not [string]::IsNullOrEmpty($this.DisplayName))
                {
                    $matchingPolicies = Get-MgBetaDeviceManagementDeviceHealthScript `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")' and deviceHealthScriptType eq 'managedInstallerScript'" `
                        -ErrorAction SilentlyContinue

                    if ($null -ne $matchingPolicies)
                    {
                        if ($matchingPolicies -is [array] -and $matchingPolicies.Count -gt 1)
                        {
                            throw "Multiple Intune Managed Installer Policies with DisplayName '$($this.DisplayName)'. Please specify the Id parameter to identify which policy to manage. Found policies: $($matchingPolicies.Id -join ', ')"
                        }
                        $getValue = Get-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $matchingPolicies.Id
                    }
                }
            }
            #endregion
            if ($null -eq $getValue)
            {
                Write-Verbose -Message "Could not find an Intune Managed Installer Policy for Windows10 with DisplayName {$($this.DisplayName)}"
                return $this.AsResult($nullResult)
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Managed Installer Policy for Windows10 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found."

            $results = @{
                #region resource generator code
                Description              = $getValue.Description
                DisplayName              = $getValue.DisplayName
                IsIntuneManagedInstaller = $getValue.DetectionScriptParameters[0].defaultValue -eq 'true'
                RoleScopeTagIds          = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                       = $getValue.Id
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

            $assignmentsValues = Get-MgBetaDeviceManagementDeviceHealthScriptAssignment -DeviceHealthScriptId $resolvedId
            $assignmentResult = @()
            foreach ($assignment in $assignmentsValues)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignment
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

        $boundParameters.Remove('IsIntuneManagedInstaller') | Out-Null

        $isIntuneManagedInstallerValue = 'false'
        if ($this.IsIntuneManagedInstaller)
        {
            $isIntuneManagedInstallerValue = 'true'
        }
        $boundParameters.detectionScriptParameters = @(
            @{
                '@odata.type'                    = '#microsoft.graph.deviceHealthScriptStringParameter'
                applyDefaultValueWhenNotAssigned = $true
                defaultValue                     = $isIntuneManagedInstallerValue
                description                      = 'Enable Intune Managed Extension as Managed Installer'
                isRequired                       = $true
                name                             = 'Enabled'
            }
        )
        $boundParameters.enforceSignatureCheck = $true
        $boundParameters.detectionScriptContent = $null
        $boundParameters.remediationScriptContent = $null

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Managed Installer Policy for Windows10 with DisplayName {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $createParameters = ([Hashtable]$boundParameters).Clone()
            $createParameters.Remove('Id') | Out-Null
            $createParameters.deviceHealthScriptType = 'managedInstallerScript'
            $createParameters.detectionScriptContent = 'ZGV0ZWN0aW9uU2NyaXB0Q29udGVudA=='
            $createParameters.remediationScriptContent = 'cmVtZWRpYXRpb25TY3JpcHRDb250ZW50'
            $createParameters.isGlobalScript = $false
            $createParameters.'@odata.type' = '#microsoft.graph.deviceHealthScript'

            #region resource generator code
            $policy = New-MgBetaDeviceManagementDeviceHealthScript -BodyParameter $createParameters `
                -ErrorAction SilentlyContinue

            if ($null -eq $policy)
            {
                Write-Warning -Message 'Received an error while creating Intune Managed Installer Policy for Windows10.'
                Write-Verbose -Message 'Check if policy was created despite the error.'
                $policy = Get-MgBetaDeviceManagementDeviceHealthScript -All -Filter "displayName eq '$($this.DisplayName)' and deviceHealthScriptType eq 'managedInstallerScript'" -ErrorAction SilentlyContinue

                if ($null -eq $policy)
                {
                    throw "Failed to create Intune Managed Installer Policy for Windows10 with DisplayName {$($this.DisplayName)}."
                }
            }

            if ($policy.id)
            {
                $assignmentsHash = @()
                foreach ($assignment in $this.Assignments)
                {
                    $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment
                    $assignmentsHash += @{
                        runRemediationScript = $true
                        target               = $assignmentTarget.target
                    }
                }
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/deviceHealthScripts' `
                    -RootIdentifier 'deviceHealthScriptAssignments'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Managed Installer Policy for Windows10 with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $updateParameters = ([Hashtable]$boundParameters).Clone()

            #region resource generator code
            Update-MgBetaDeviceManagementDeviceHealthScript `
                -DeviceHealthScriptId $currentInstance.Id `
                -BodyParameter $updateParameters

            $assignmentsHash = @()
            foreach ($assignment in $this.Assignments)
            {
                $assignmentTarget = ConvertTo-IntunePolicyAssignment -Assignments $assignment
                $assignmentsHash += @{
                    runRemediationScript = $assignment.RunRemediationScript
                    target               = $assignmentTarget.target
                }
            }
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/deviceHealthScripts' `
                -RootIdentifier 'deviceHealthScriptAssignments'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Managed Installer Policy for Windows10 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementDeviceHealthScript -DeviceHealthScriptId $currentInstance.Id
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
            $baseFilter = "deviceHealthScriptType eq 'managedInstallerScript'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-MgBetaDeviceManagementDeviceHealthScript `
                -Filter $mergedFilter `
                -All `
                -ErrorAction Stop
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
                if (-not [String]::IsNullOrEmpty($config.DisplayName))
                {
                    $displayedKey = $config.DisplayName
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

                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($Results.Assignments)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString -ComplexObject $Results.Assignments -CIMInstanceName DeviceManagementConfigurationPolicyAssignments
                    if (-not [string]::IsNullOrEmpty($complexTypeStringResult))
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

    hidden [IntuneManagedInstallerPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneManagedInstallerPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneManagedInstallerPolicyWindows10]::new()
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
