using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Identity of the endpoint protection attack surface protection rules policy for Windows 10.')]
    [System.String] $Identity

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display name of the endpoint protection attack surface protection rules policy for Windows 10.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Description of the endpoint protection attack surface protection rules policy for Windows 10.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Assignments of the endpoint protection attack surface protection rules policy for Windows 10.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Exclude files and paths from attack surface reduction rules')]
    [System.String[]] $AttackSurfaceReductionOnlyExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents an application from writing a vulnerable signed driver to disk.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAbuseOfExploitedVulnerableSignedDrivers

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents attacks by blocking Adobe Reader from creating processes.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAdobeReaderFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks Office apps from creating child processes. Office apps include Word, Excel, PowerPoint, OneNote, and Access.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAllOfficeApplicationsFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('This rule helps prevent credential stealing by locking down Local Security Authority Subsystem Service (LSASS).')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks the following file types from launching from email opened within the Microsoft Outlook application, or Outlook.com and other popular webmail providers.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableContentFromEmailClientAndWebmail

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks executable files that don''t meet a prevalence, age, or trusted list criteria, such as .exe, .dll, or .scr, from launching.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion

    [DscProperty()]
    [System.ComponentModel.Description('This rule detects suspicious properties within an obfuscated script.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutionOfPotentiallyObfuscatedScripts

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents scripts from launching potentially malicious downloaded content.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents Office apps, including Word, Excel, and PowerPoint, from creating potentially malicious executable content, by blocking malicious code from being written to disk.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromCreatingExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks code injection attempts from Office apps into other processes.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents Outlook from creating child processes, while still allowing legitimate Outlook functions.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeCommunicationAppFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents malware from abusing WMI to attain persistence on a device.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockPersistenceThroughWMIEventSubscription

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks processes created through PsExec and WMI from running.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockProcessCreationsFromPSExecAndWMICommands

    [DscProperty()]
    [System.ComponentModel.Description('With this rule, admins can prevent unsigned or untrusted executable files from running from USB removable drives, including SD cards.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUntrustedUnsignedProcessesThatRunFromUSB

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents VBA macros from calling Win32 APIs.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWin32APICallsFromOfficeMacros

    [DscProperty()]
    [System.ComponentModel.Description('This rule provides an extra layer of protection against ransomware.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $UseAdvancedProtectionAgainstRansomware

    [DscProperty()]
    [System.ComponentModel.Description('List of additional folders that need to be protected')]
    [System.String[]] $ControlledFolderAccessProtectedFolders

    [DscProperty()]
    [System.ComponentModel.Description('List of apps that have access to protected folders.')]
    [System.String[]] $ControlledFolderAccessAllowedApplications

    [DscProperty()]
    [System.ComponentModel.Description('This rule enable Controlled folder access which protects your data by checking apps against a list of known, trusted apps.values 0:disable, 1:enable, 2:audit, 3: Block disk modification only, 4: Audit disk modification only')]
    [ValidateSet('0', '1', '2', '3', '4')]
    [System.String] $EnableControlledFolderAccess

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed')]
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

    [IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager with Id {$($this.Identity)} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $templateReferenceId = '5dd36540-eb22-4e7e-b19c-2a07772ba627_1'
                # Retrieve policy general settings
                $policy = $null
                if (-not [System.String]::IsNullOrEmpty($this.Identity))
                {
                    $policy = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Identity -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $policy.settings
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager with Id {$($this.Identity)} was found"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/TemplateId eq '$templateReferenceId'" `
                            -ErrorAction SilentlyContinue
                    }

                    if ($null -eq $policy)
                    {
                        Write-Verbose -Message "No Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager with Name {$($this.DisplayName)} was found"
                        return $this.AsResult($nullResult)
                    }
                }
            }
            else
            {
                $policy = $this.ExportedInstance
                $settings = $policy.settings
            }

            $resolvedId = $policy.Id

            Write-Verbose -Message "Found Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager with Id {$($resolvedId)} and Name {$($policy.Name)}"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $returnHashtable = @{}
            $returnHashtable.Add('Identity', $resolvedId)
            $returnHashtable.Add('DisplayName', $policy.Name)
            $returnHashtable.Add('Description', $policy.Description)
            $returnHashtable.Add('RoleScopeTagIds', (Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds))

            $returnHashtable = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $returnHashtable

            $returnAssignments = @()
            $graphAssignments = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $graphAssignments)
            {
                $graphAssignments = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            if ($graphAssignments.Count -gt 0)
            {
                $returnAssignments += ConvertFrom-IntunePolicyAssignment `
                    -IncludeDeviceFilter:$true `
                    -Assignments ($graphAssignments)
            }
            $returnHashtable.Add('Assignments', $returnAssignments)

            Write-Verbose -Message "Found Endpoint Protection Policy {$($policy.name)}"

            $returnHashtable.Add('Ensure', 'Present')
            $returnHashtable.Add('Credential', $this.Credential)
            $returnHashtable.Add('ApplicationId', $this.ApplicationId)
            $returnHashtable.Add('TenantId', $this.TenantId)
            $returnHashtable.Add('ApplicationSecret', $this.ApplicationSecret)
            $returnHashtable.Add('CertificateThumbprint', $this.CertificateThumbprint)
            $returnHashtable.Add('ManagedIdentity', $this.ManagedIdentity)
            $returnHashtable.Add('AccessTokens', $this.AccessTokens)

            return $this.AsResult($returnHashtable)
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

        $currentPolicy = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '5dd36540-eb22-4e7e-b19c-2a07772ba627_1'
        $platforms = 'windows10'
        $technologies = 'configManager'

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Identity') | Out-Null

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
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
        }
        elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating existing Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager {$($currentPolicy.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Identity') | Out-Null

            #format settings from PSBoundParameters for update
            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region update policy assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Intune Attack Surface Reduction Rules Policy for Windows10 Config Manager {$($currentPolicy.DisplayName)}"
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentPolicy.Identity
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

        $dscContent = [System.Text.StringBuilder]::new()
        $i = 1

        try
        {
            $policyTemplateID = '5dd36540-eb22-4e7e-b19c-2a07772ba627_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$policies = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter

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

                $params = @{
                    Identity              = $policy.id
                    DisplayName           = $policy.Name
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

                $this.ExportedInstance = $policy
                $Results = $this.GetForExport($Params)
                $rawResults = $Results.Clone()

                if ($Results.Assignments)
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

                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
                $i++
            }
            return $dscContent.ToString()
        }
        catch
        {
            if ($_.Exception -like '*401*' -or $_.ErrorDetails.Message -like "*`"ErrorCode`":`"Forbidden`"*" -or `
                    $_.Exception -like '*Unable to perform redirect as Location Header is not set in response*' -or `
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
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager])
        {
            return $Values
        }

        $result = [IntuneAttackSurfaceReductionRulesPolicyWindows10ConfigManager]::new()
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
