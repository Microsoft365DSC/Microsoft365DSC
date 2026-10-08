using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneSettingCatalogASRRulesPolicyWindows10 : M365DSCResourceBase
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
    [System.ComponentModel.Description('Assignments of the endpoint protection.')]
    [MSFT_DeviceManagementConfigurationPolicyAssignments[]] $Assignments

    [DscProperty()]
    [System.ComponentModel.Description('Exclude files and paths from attack surface reduction rules')]
    [System.String[]] $AttackSurfaceReductionOnlyExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents an application from writing a vulnerable signed driver to disk.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAbuseOfExploitedVulnerableSignedDrivers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAbuseOfExploitedVulnerableSignedDrivers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents attacks by blocking Adobe Reader from creating processes.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAdobeReaderFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockAdobeReaderFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks Office apps from creating child processes. Office apps include Word, Excel, PowerPoint, OneNote, and Access.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockAllOfficeApplicationsFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions (off: Off, block: Block, audit: Audit, warn: Warn)')]
    [System.String[]] $BlockAllOfficeApplicationsFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule helps prevent credential stealing by locking down Local Security Authority Subsystem Service (LSASS).')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockCredentialStealingFromWindowsLocalSecurityAuthoritySubsystem_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks the following file types from launching from email opened within the Microsoft Outlook application, or Outlook.com and other popular webmail providers.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableContentFromEmailClientAndWebmail

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableContentFromEmailClientAndWebmail_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks executable files that don''t meet a prevalence, age, or trusted list criteria, such as .exe, .dll, or .scr, from launching.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutableFilesRunningUnlessTheyMeetPrevalenceAgeTrustedListCriterion_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule detects suspicious properties within an obfuscated script.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockExecutionOfPotentiallyObfuscatedScripts

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockExecutionOfPotentiallyObfuscatedScripts_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents scripts from launching potentially malicious downloaded content.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockJavaScriptOrVBScriptFromLaunchingDownloadedExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents Office apps, including Word, Excel, and PowerPoint, from creating potentially malicious executable content, by blocking malicious code from being written to disk.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromCreatingExecutableContent

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromCreatingExecutableContent_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks code injection attempts from Office apps into other processes.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeApplicationsFromInjectingCodeIntoOtherProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents Outlook from creating child processes, while still allowing legitimate Outlook functions.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockOfficeCommunicationAppFromCreatingChildProcesses

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockOfficeCommunicationAppFromCreatingChildProcesses_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents malware from abusing WMI to attain persistence on a device.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockPersistenceThroughWMIEventSubscription

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks processes created through PsExec and WMI from running.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockProcessCreationsFromPSExecAndWMICommands

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockProcessCreationsFromPSExecAndWMICommands_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents the execution of commands to restart machines in Safe Mode.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockRebootingMachineInSafeMode

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockRebootingMachineInSafeMode_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('With this rule, admins can prevent unsigned or untrusted executable files from running from USB removable drives, including SD cards.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUntrustedUnsignedProcessesThatRunFromUSB

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUntrustedUnsignedProcessesThatRunFromUSB_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks the use of executable files that are identified as copies of Windows system tools. These files are either duplicates or impostors of the original system tools.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockUseOfCopiedOrImpersonatedSystemTools

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockUseOfCopiedOrImpersonatedSystemTools_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule blocks webshell creation for servers.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWebShellCreationForServers

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWebshellCreationForServers_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule prevents VBA macros from calling Win32 APIs.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $BlockWin32APICallsFromOfficeMacros

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $BlockWin32APICallsFromOfficeMacros_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('This rule provides an extra layer of protection against ransomware.')]
    [ValidateSet('off', 'block', 'audit', 'warn')]
    [System.String] $UseAdvancedProtectionAgainstRansomware

    [DscProperty()]
    [System.ComponentModel.Description('ASR Only Per Rule Exclusions')]
    [System.String[]] $UseAdvancedProtectionAgainstRansomware_ASROnlyPerRuleExclusions

    [DscProperty()]
    [System.ComponentModel.Description('List of additional folders that need to be protected')]
    [System.String[]] $ControlledFolderAccessProtectedFolders

    [DscProperty()]
    [System.ComponentModel.Description('List of apps that have access to protected folders.')]
    [System.String[]] $ControlledFolderAccessAllowedApplications

    [DscProperty()]
    [System.ComponentModel.Description('This rule enables Controlled folder access which protects your data by checking apps against a list of known, trusted apps. Possible values: 0=disable, 1=enable, 2=audit, 3=block disk modification only, 4=audit disk modification only')]
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

    [IntuneSettingCatalogASRRulesPolicyWindows10] Get()
    {
        $Id = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneSettingCatalogASRRulesPolicyWindows10]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Endpoint Protection Attack Surface Protection rules Policy with Id {$Id} and DisplayName {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'

                $templateReferenceId = 'e8c053d6-9f95-42b1-a7f1-ebfd71c67a4b_1'

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
                    Write-Verbose -Message "No Endpoint Protection Attack Surface Reduction Rules Policy {$($this.Identity)} was found"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $policy = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")' and templateReference/TemplateId eq '$templateReferenceId'" `
                            -ErrorAction SilentlyContinue

                        if ($policy.Length -gt 1)
                        {
                            throw "Duplicate Endpoint Protection Attack Surface Reduction Rules Policy named $($this.DisplayName) exist in tenant"
                        }
                    }
                }

                if ($null -eq $policy)
                {
                    Write-Verbose -Message "No Endpoint Protection Attack Surface Reduction Rules Policy {$($this.DisplayName)} was found"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $policy = $this.ExportedInstance
                $settings = $policy.settings
            }
            $resolvedId = $policy.Id
            Write-Verbose -Message "Found Endpoint Protection Attack Surface Reduction Rules Policy with Id {$($resolvedId)} and Name {$($this.DisplayName))}."

            #Retrieve policy specific settings
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
            $returnHashtable.Add('DisplayName', $policy.name)
            $returnHashtable.Add('Description', $policy.description)
            $returnHashtable.Add('RoleScopeTagIds', (Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $policy.roleScopeTagIds -DesiredValues $this.RoleScopeTagIds))

            $returnHashtable = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $returnHashtable

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $policy
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
            }
            $assignmentResult = @()
            if ($assignmentsValues.Count -gt 0)
            {
                $assignmentResult += ConvertFrom-IntunePolicyAssignment -Assignments $assignmentsValues -IncludeDeviceFilter $true
            }
            $returnHashtable.Add('Assignments', $assignmentResult)

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

        $templateReferenceId = 'e8c053d6-9f95-42b1-a7f1-ebfd71c67a4b_1'
        $platforms = 'windows10'
        $technologies = 'mdm,microsoftSense'

        if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating new Endpoint Protection Attack Surface Reduction Rules Policy {$($this.DisplayName)}"
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

            #region Assignments
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
            Write-Verbose -Message "Updating existing Endpoint Protection Attack Surface Reduction Rules Policy {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null
            $boundParameters.Remove('Identity') | Out-Null

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

            #region Assignments
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentPolicy.Identity `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Endpoint Protection Attack Surface Reduction Rules Policy {$($this.DisplayName)}"
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
            $policyTemplateId = 'e8c053d6-9f95-42b1-a7f1-ebfd71c67a4b_1'
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
                    Identity              = $policy.Id
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
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneSettingCatalogASRRulesPolicyWindows10] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneSettingCatalogASRRulesPolicyWindows10])
        {
            return $Values
        }

        $result = [IntuneSettingCatalogASRRulesPolicyWindows10]::new()
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
