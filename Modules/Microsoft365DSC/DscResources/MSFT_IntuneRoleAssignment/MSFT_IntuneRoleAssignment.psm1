using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneRoleAssignment : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Role Assignment.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('The display or friendly name of the role Assignment.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of ids of role scope member security groups. These are IDs from Azure Active Directory. Ignored if ScopeType is not ''ResourceScope''')]
    [System.String[]] $ResourceScopes

    [DscProperty()]
    [System.ComponentModel.Description('List of DisplayName of role scope member security groups. These are Displayname from Azure Active Directory. Ignored if ScopeType is not ''ResourceScope''')]
    [System.String[]] $ResourceScopesDisplayNames

    [DscProperty()]
    [System.ComponentModel.Description('Specifies the type of scope for a Role Assignment. Default type ''ResourceScope'' allows assignment of ResourceScopes. Possible values are: resourceScope, allDevices, allLicensedUsers, allDevicesAndLicensedUsers.')]
    [System.String] $ScopeType

    [DscProperty()]
    [System.ComponentModel.Description('The list of ids of role member security groups. These are IDs from Azure Active Directory.')]
    [System.String[]] $Members

    [DscProperty()]
    [System.ComponentModel.Description('The list of Displaynames of role member security groups. These are Displaynamnes from Azure Active Directory.')]
    [System.String[]] $MembersDisplayNames

    [DscProperty()]
    [System.ComponentModel.Description('The Role Definition Id.')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('The Role Definition Displayname.')]
    [System.String] $RoleDefinitionDisplayName

    [DscProperty()]
    [System.ComponentModel.Description('List of Scope Tags for this Entity instance.')]
    [System.String[]] $RoleScopeTagIds

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the Role exists, absent ensures it is removed.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials of the Intune Admin')]
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

    [IntuneRoleAssignment] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneRoleAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Role Assignment with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaDeviceManagementRoleAssignment -DeviceAndAppManagementRoleAssignmentId $this.Id -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Role Assignment with Id {$($this.Id)}"

                    $getValue = Get-MgBetaDeviceManagementRoleAssignment `
                        -All `
                        -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Role Assignment with DisplayName {$($this.DisplayName)}"
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            Write-Verbose -Message "An Intune Role Assignment with Id {$($getValue.Id)} and DisplayName {$($this.DisplayName)} was found"

            # Get Roledefinition first, loop through all roledefinitions and find the assignment that matches the Id
            $currentRoleDefinitionId = $null
            $currentRoleDefinitionDisplayName = $null
            $tempRoleDefinitions = Get-MgDeviceManagementRoleDefinition
            foreach ($tempRoleDefinition in $tempRoleDefinitions)
            {
                $item = Get-MgDeviceManagementRoleDefinitionRoleAssignment -RoleDefinitionId $tempRoleDefinition.Id | Where-Object { $_.Id -eq $getValue.Id }
                if ($null -ne $item)
                {
                    $currentRoleDefinitionId = $tempRoleDefinition.Id
                    $currentRoleDefinitionDisplayName = $tempRoleDefinition.DisplayName
                    break
                }
            }

            $resourceScopesDisplayNamesValue = @()
            foreach ($resourceScope in $getValue.ResourceScopes)
            {
                $group = Get-M365DSCIntuneGroup -GroupId $resourceScope
                if ($null -eq $group)
                {
                    Write-Warning -Message "Could not find group with Id {$resourceScope} when retrieving resource scope display names"
                    continue
                }
                $resourceScopesDisplayNamesValue += $group.DisplayName
            }

            $membersDisplayNamesValue = @()
            foreach ($tempMember in $getValue.Members)
            {
                $group = Get-M365DSCIntuneGroup -GroupId $tempMember
                if ($null -eq $group)
                {
                    Write-Warning -Message "Could not find group with Id {$tempMember} when retrieving member display names"
                    continue
                }
                $membersDisplayNamesValue += $group.DisplayName
            }

            $scopeTypeValue = $null
            if (-not ([System.String]::IsNullOrEmpty($getValue.ScopeType)))
            {
                $scopeTypeValue = $getValue.ScopeType.ToString()
            }
            $results = @{
                Id                         = $getValue.Id
                Description                = $getValue.Description
                DisplayName                = $getValue.DisplayName
                ResourceScopes             = $getValue.ResourceScopes
                ResourceScopesDisplayNames = $resourceScopesDisplayNamesValue
                ScopeType                  = $scopeTypeValue
                Members                    = $getValue.Members
                MembersDisplayNames        = $membersDisplayNamesValue
                RoleDefinition             = $currentRoleDefinitionId
                RoleDefinitionDisplayName  = $currentRoleDefinitionDisplayName
                RoleScopeTagIds            = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
                Ensure                     = 'Present'
                Credential                 = $this.Credential
                ApplicationId              = $this.ApplicationId
                TenantId                   = $this.TenantId
                ApplicationSecret          = $this.ApplicationSecret
                CertificateThumbprint      = $this.CertificateThumbprint
                CertificatePath            = $this.CertificatePath
                CertificatePassword        = $this.CertificatePassword
                ManagedIdentity            = $this.ManagedIdentity
                AccessTokens               = $this.AccessTokens
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

        Write-Verbose -Message "Setting configuration of the Intune Role Assignment with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($null -ne $resolvedRoleScopeTagIds)
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $resolvedRoleScopeTagIds
        }

        $roleDefinitionValue = $this.RoleDefinition
        if ($this.Ensure -eq 'Present' -and
            ($roleDefinitionValue -notmatch '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$' -or $roleDefinitionValue -eq '00000000-0000-0000-0000-000000000000'))
        {
            $roleDefinitionFilter = "DisplayName eq '$($this.RoleDefinitionDisplayName -replace "'", "''")'"
            $roleDefinitionId = Get-MgDeviceManagementRoleDefinition -All -Filter $roleDefinitionFilter -ErrorAction SilentlyContinue
            if ($null -ne $roleDefinitionId)
            {
                $roleDefinitionValue = $roleDefinitionId.Id
            }
            else
            {
                throw "No role definition with DisplayName {$($this.RoleDefinitionDisplayName)} was found"
            }
        }

        [array]$membersValue = @()
        if ($this.GetBoundParameters().ContainsKey('MembersDisplayNames'))
        {
            foreach ($membersDisplayName in $this.MembersDisplayNames)
            {
                $memberFilter = "displayName eq '$($membersDisplayName -replace "'", "''")'"
                $memberId = Get-MgGroup -All -Filter $memberFilter -ErrorAction SilentlyContinue
                if ($null -ne $memberId)
                {
                    if ($membersValue -notcontains $memberId.Id)
                    {
                        $membersValue += $memberId.Id
                    }
                }
                else
                {
                    Write-Warning -Message "No member of type group with DisplayName {$membersDisplayName} was found"
                }
            }
        }
        else
        {
            $membersValue = $this.Members
        }

        [array]$resourceScopesValue = @()
        if ($this.GetBoundParameters().ContainsKey('ResourceScopesDisplayNames'))
        {
            foreach ($resourceScopesDisplayName in $this.ResourceScopesDisplayNames)
            {
                $resourceScopeFilter = "DisplayName eq '$($resourceScopesDisplayName -replace "'", "''")'"
                $resourceScopeId = Get-MgGroup -All -Filter $resourceScopeFilter -ErrorAction SilentlyContinue
                if ($null -ne $resourceScopeId)
                {
                    if ($resourceScopesValue -notcontains $resourceScopeId.Id)
                    {
                        $resourceScopesValue += $resourceScopeId.Id
                    }
                }
                else
                {
                    Write-Warning -Message "No resource scope of type group with DisplayName {$resourceScopesDisplayName} was found"
                }
            }
        }
        else
        {
            $resourceScopesValue = $this.ResourceScopes
        }

        $scopeTypeValue = $this.ScopeType
        if ($this.ScopeType -match 'AllDevices|AllLicensedUsers|AllDevicesAndLicensedUsers')
        {
            $resourceScopesValue = $null
        }
        else
        {
            $scopeTypeValue = 'resourceScope'
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Role Assignment with DisplayName {$($this.DisplayName)}"

            $createParameters = @{
                description                 = $this.Description
                displayName                 = $this.DisplayName
                scopeType                   = $scopeTypeValue
                members                     = $membersValue
                '@odata.type'               = '#microsoft.graph.deviceAndAppManagementRoleAssignment'
                'roleDefinition@odata.bind' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/roleDefinitions('$roleDefinitionValue')"
            }

            if ($null -ne $resourceScopesValue)
            {
                $createParameters['resourceScopes'] = $resourceScopesValue
            }

            if ($null -ne $resolvedRoleScopeTagIds)
            {
                $createParameters['roleScopeTagIds'] = $resolvedRoleScopeTagIds
            }

            $null = New-MgBetaDeviceManagementRoleAssignment -BodyParameter $createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Role Assignment with Id {$($currentInstance.Id)} and DisplayName {$($this.DisplayName)}"

            $updateParameters = @{
                description                 = $this.Description
                displayName                 = $this.DisplayName
                scopeType                   = $scopeTypeValue
                members                     = $membersValue
                '@odata.type'               = '#microsoft.graph.deviceAndAppManagementRoleAssignment'
                'roleDefinition@odata.bind' = "$((Get-MSCloudLoginConnectionProfile -Workload MicrosoftGraph).ResourceUrl)beta/deviceManagement/roleDefinitions('$roleDefinitionValue')"
            }

            if ($null -ne $resourceScopesValue)
            {
                $updateParameters['resourceScopes'] = $resourceScopesValue
            }

            if ($null -ne $resolvedRoleScopeTagIds)
            {
                $updateParameters['roleScopeTagIds'] = $resolvedRoleScopeTagIds
            }

            $null = Update-MgBetaDeviceManagementRoleAssignment `
                -BodyParameter $updateParameters `
                -DeviceAndAppManagementRoleAssignmentId $currentInstance.Id
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Role Assignment with Id {$($currentInstance.Id)} and DisplayName {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementRoleAssignment -DeviceAndAppManagementRoleAssignmentId $currentInstance.Id
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
            $baseFilter = "isof('microsoft.graph.deviceAndAppManagementRoleAssignment')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array]$getValue = Get-MgBetaDeviceManagementRoleAssignment -Filter $mergedFilter -All -ErrorAction Stop

            if (-not $getValue)
            {
                [array]$getValue = Get-MgBetaDeviceManagementRoleAssignment `
                    -ErrorAction Stop
            }

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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
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
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $ignore)
                if ($DesiredValues.ContainsKey('MembersDisplayNames'))
                {
                    $ValuesToCheck.Remove('Members') | Out-Null
                }
                if ($DesiredValues.ContainsKey('ResourceScopesDisplayNames'))
                {
                    $ValuesToCheck.Remove('ResourceScopes') | Out-Null
                }
                if ($DesiredValues.ContainsKey('RoleDefinitionDisplayName'))
                {
                    $ValuesToCheck.Remove('RoleDefinition') | Out-Null
                }
                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
        }
    }

    hidden [IntuneRoleAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneRoleAssignment])
        {
            return $Values
        }

        $result = [IntuneRoleAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
