using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneFirewallRulesPolicyWindows10ConfigMgr : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Policy description')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Policy name')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Firewall Rules')]
    [MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName_IntuneFirewallRulesPolicyWindows10ConfigMgr[]] $FirewallRuleName

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

    [IntuneFirewallRulesPolicyWindows10ConfigMgr] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneFirewallRulesPolicyWindows10ConfigMgr]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Name -ne $this.DisplayName)
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
                    $getValue = Get-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $this.Id -ErrorAction SilentlyContinue `
                        -ExpandProperty 'settings($expand=settingDefinitions)'
                    $settings = $getValue.settings
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaDeviceManagementConfigurationPolicy `
                            -All `
                            -Filter "Name eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Firewall Rules Policy for Windows10 ConfigMgr with Name {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
                $settings = $getValue.settings
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($resolvedId)} and Name {$($this.DisplayName)} was found"

            # Retrieve policy specific settings
            if ($null -eq $settings)
            {
                [array]$settings = Get-MgBetaDeviceManagementConfigurationPolicySetting `
                    -DeviceManagementConfigurationPolicyId $resolvedId `
                    -ExpandProperty 'settingDefinitions' `
                    -All `
                    -ErrorAction Stop
            }

            $policySettings = @{}
            $policySettings = Export-IntuneSettingCatalogPolicySettings -Settings $settings -ReturnHashtable $policySettings

            #region resource generator code
            $complexFirewallRuleName = @()
            foreach ($currentFirewallRuleName in $policySettings.FirewallRuleName)
            {
                $myFirewallRuleName = [ordered]@{}
                foreach ($key in $currentFirewallRuleName.Keys)
                {
                    $myFirewallRuleName.Add($key, $currentFirewallRuleName.$key)
                }
                if ($myFirewallRuleName.values.Where({ $null -ne $_ }).Count -gt 0)
                {
                    $complexFirewallRuleName += $myFirewallRuleName
                }
            }
            $policySettings.Remove('FirewallRuleName') | Out-Null
            #endregion

            $results = @{
                #region resource generator code
                Description           = $getValue.Description
                DisplayName           = $getValue.Name
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Id                    = $getValue.Id
                FirewallRuleName      = $complexFirewallRuleName
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
            $results += $policySettings

            $assignmentsValues = Get-M365DSCIntuneExpandedAssignments -Instance $getValue
            if ($null -eq $assignmentsValues)
            {
                $assignmentsValues = Get-MgBetaDeviceManagementConfigurationPolicyAssignment -DeviceManagementConfigurationPolicyId $resolvedId
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

        Write-Verbose -Message "Setting configuration of the Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($this.Id)} and Name {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($boundParameters.ContainsKey('RoleScopeTagIds'))
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $this.RoleScopeTagIds
        }

        $templateReferenceId = '48da42ed-5df7-485e-8b9d-4844ed5a92bd_1'
        $platforms = 'windows10'
        $technologies = 'configManager'

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Firewall Rules Policy for Windows10 ConfigMgr with Name {$($this.DisplayName)}"
            $boundParameters.Remove('Assignments') | Out-Null

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

            #region resource generator code
            $policy = New-MgBetaDeviceManagementConfigurationPolicy -BodyParameter $createParameters

            if ($policy.Id)
            {
                $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
                Update-DeviceConfigurationPolicyAssignment `
                    -DeviceConfigurationPolicyId $policy.Id `
                    -Targets $assignmentsHash `
                    -Repository 'deviceManagement/configurationPolicies'
            }
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($currentInstance.Id)}"
            $boundParameters.Remove('Assignments') | Out-Null

            $settings = Get-IntuneSettingCatalogPolicySetting `
                -DSCParams ([System.Collections.Hashtable]$boundParameters) `
                -TemplateId $templateReferenceId

            Update-IntuneDeviceConfigurationPolicy `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Name $this.DisplayName `
                -Description $this.Description `
                -TemplateReferenceId $templateReferenceId `
                -Platforms $platforms `
                -Technologies $technologies `
                -Settings $settings `
                -RoleScopeTagIds $resolvedRoleScopeTagIds

            #region resource generator code
            $assignmentsHash = ConvertTo-IntunePolicyAssignment -IncludeDeviceFilter:$true -Assignments $this.Assignments
            Update-DeviceConfigurationPolicyAssignment `
                -DeviceConfigurationPolicyId $currentInstance.Id `
                -Targets $assignmentsHash `
                -Repository 'deviceManagement/configurationPolicies'
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Firewall Rules Policy for Windows10 ConfigMgr with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaDeviceManagementConfigurationPolicy -DeviceManagementConfigurationPolicyId $currentInstance.Id
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
            $policyTemplateID = '48da42ed-5df7-485e-8b9d-4844ed5a92bd_1'
            $baseFilter = "templateReference/templateId eq '$policyTemplateID'"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($($this.Filter)) and ($baseFilter)"
            }
            [array]$getValue = Get-M365DSCExportCachedConfigurationPolicies `
                -TemplateId $policyTemplateID `
                -Filter $mergedFilter
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
                    DisplayName           = $config.Name
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

                if ($null -ne $Results.FirewallRuleName)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.FirewallRuleName `
                        -CIMInstanceName 'MicrosoftGraphIntuneSettingsCatalogFirewallRuleName_IntuneFirewallRulesPolicyWindows10ConfigMgr'
                    if (-not [String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.FirewallRuleName = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('FirewallRuleName') | Out-Null
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
                    -NoEscape @('FirewallRuleName', 'Assignments') `
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

    [System.Collections.Hashtable] GetCompareParameters()
    {
        return $this.GetSettingsCatalogCompareParameters()
    }

    hidden [IntuneFirewallRulesPolicyWindows10ConfigMgr] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneFirewallRulesPolicyWindows10ConfigMgr])
        {
            return $Values
        }

        $result = [IntuneFirewallRulesPolicyWindows10ConfigMgr]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_MicrosoftGraphIntuneSettingsCatalogFirewallRuleName_IntuneFirewallRulesPolicyWindows10ConfigMgr
{
    [DscProperty()]
    [System.ComponentModel.Description('Enabled - Depends on FirewallRuleName (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $Enabled

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Name - Depends on FirewallRuleName')]
    [System.String] $Name

    [DscProperty()]
    [System.ComponentModel.Description('Interface Types - Depends on FirewallRuleName (RemoteAccess, Wireless, Lan, MobileBroadband, MBB, All)')]
    [ValidateSet('RemoteAccess', 'Wireless', 'Lan', 'MobileBroadband', 'MBB', 'All')]
    [System.String[]] $InterfaceTypes

    [DscProperty()]
    [System.ComponentModel.Description('File Path - Depends on FirewallRuleName')]
    [System.String] $FilePath

    [DscProperty()]
    [System.ComponentModel.Description('Remote Port Ranges - Depends on FirewallRuleName')]
    [System.String[]] $RemotePortRanges

    [DscProperty()]
    [System.ComponentModel.Description('Edge Traversal - Depends on FirewallRuleName (0: Disabled, 1: Enabled)')]
    [ValidateSet('0', '1')]
    [System.String] $EdgeTraversal

    [DscProperty()]
    [System.ComponentModel.Description('Local User Authorized List - Depends on FirewallRuleName')]
    [System.String[]] $LocalUserAuthorizedList

    [DscProperty()]
    [System.ComponentModel.Description('Network Types - Depends on FirewallRuleName (1: FW_PROFILE_TYPE_DOMAIN:  This value represents the profile for networks that are connected to domains., 2: FW_PROFILE_TYPE_STANDARD:  This value represents the standard profile for networks. These networks are classified as private by the administrators in the server host. The classification happens the first time the host connects to the network. Usually these networks are behind Network Address Translation (NAT) devices, routers, and other edge devices, and they are in a private location, such as a home or an office. AND FW_PROFILE_TYPE_PRIVATE:  This value represents the profile for private networks, which is represented by the same value as that used for FW_PROFILE_TYPE_STANDARD., 4: FW_PROFILE_TYPE_PUBLIC:  This value represents the profile for public networks. These networks are classified as public by the administrators in the server host. The classification happens the first time the host connects to the network. Usually these networks are those at airports, coffee shops, and other public places where the peers in the network or the network administrator are not trusted., 2147483647: FW_PROFILE_TYPE_ALL:  This value represents all these network sets and any future network sets., -2147483648: FW_PROFILE_TYPE_CURRENT:  This value represents the current profiles to which the firewall and advanced security components determine the host is connected at the moment of the call. This value can be specified only in method calls, and it cannot be combined with other flags.)')]
    [ValidateSet('1', '2', '4', '2147483647', '-2147483648')]
    [System.Int32[]] $Profiles

    [DscProperty()]
    [System.ComponentModel.Description('Local Port Ranges - Depends on FirewallRuleName')]
    [System.String[]] $LocalPortRanges

    [DscProperty()]
    [System.ComponentModel.Description('Description - Depends on FirewallRuleName')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Package Family Name - Depends on FirewallRuleName')]
    [System.String] $PackageFamilyName

    [DscProperty()]
    [System.ComponentModel.Description('Local Address Ranges - Depends on FirewallRuleName')]
    [System.String[]] $LocalAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('Direction - Depends on FirewallRuleName (IN: The rule applies to inbound traffic., OUT: The rule applies to outbound traffic.)')]
    [ValidateSet('IN', 'OUT')]
    [System.String] $Direction

    [DscProperty()]
    [System.ComponentModel.Description('Service Name - Depends on FirewallRuleName')]
    [System.String] $ServiceName

    [DscProperty()]
    [System.ComponentModel.Description('Remote Address Ranges - Depends on FirewallRuleName')]
    [System.String[]] $RemoteAddressRanges

    [DscProperty()]
    [System.ComponentModel.Description('Action - Depends on FirewallRuleName (0: Block, 1: Allow)')]
    [ValidateSet('0', '1')]
    [System.String] $Type

    [DscProperty()]
    [System.ComponentModel.Description('Protocol - Depends on FirewallRuleName')]
    [System.Nullable[System.Int32]] $Protocol
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
