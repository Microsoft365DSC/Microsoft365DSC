using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneRoleDefinition : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Description of the Role definition.')]
    [System.String] $Description

    [DscProperty(Key)]
    [System.ComponentModel.Description('Display Name of the Role definition.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Type of Role. Set to True if it is built-in, or set to False if it is a custom role definition.')]
    [System.Nullable[System.Boolean]] $IsBuiltIn

    [DscProperty()]
    [System.ComponentModel.Description('List of allowed resource actions')]
    [System.String[]] $AllowedResourceActions

    [DscProperty()]
    [System.ComponentModel.Description('List of not allowed resource actions')]
    [System.String[]] $NotAllowedResourceActions

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Scope Tags to assign')]
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

    [IntuneRoleDefinition] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneRoleDefinition]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of the Intune Role Definition {$($this.DisplayName)}"

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
                if ($this.Id -match '^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
                {
                    $getValue = Get-MgBetaDeviceManagementRoleDefinition -RoleDefinitionId $this.Id -ErrorAction SilentlyContinue
                    if ($null -ne $getValue)
                    {
                        Write-Verbose -Message "Found an Intune Role Definition with Id {$($this.Id)}"
                    }
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "No Intune Role Definition with Id {$($this.Id)} was found"
                    $displayNameFilter = "DisplayName eq '$($this.DisplayName -replace "'", "''")'"
                    $getValue = Get-MgBetaDeviceManagementRoleDefinition -All -Filter $displayNameFilter -ErrorAction SilentlyContinue
                    if ($null -ne $getValue)
                    {
                        Write-Verbose -Message "Found an Intune Role Definition with displayname {$($this.DisplayName)}"
                    }
                    else
                    {
                        Write-Verbose -Message "No Intune Role Definition with displayname {$($this.DisplayName)} was found"
                        return $this.AsResult($nullResult)
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            $results = @{
                Id                    = $getValue.Id
                Description           = $getValue.Description
                DisplayName           = $getValue.DisplayName
                IsBuiltIn             = $getValue.IsBuiltIn
                Ensure                = 'Present'
                RoleScopeTagIds       = Resolve-M365DSCIntuneRoleScopeTagNames -CurrentValues $getValue.RoleScopeTagIds -DesiredValues $this.RoleScopeTagIds
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
            if ($getValue.RolePermissions)
            {
                $results.Add('AllowedResourceActions', $getValue.RolePermissions.ResourceActions.AllowedResourceActions)
                $results.Add('NotAllowedResourceActions', $getValue.RolePermissions.ResourceActions.NotAllowedResourceActions)
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
        $ScopeRoleTags = $null
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting the Intune Role Definition {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()

        $resolvedRoleScopeTagIds = $this.RoleScopeTagIds
        if ($null -ne $resolvedRoleScopeTagIds)
        {
            $resolvedRoleScopeTagIds = Resolve-M365DSCIntuneRoleScopeTagIds -RoleScopeTagIds $resolvedRoleScopeTagIds
        }

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating Role Definition {$($this.DisplayName)}"
            $ScopeRoleTags = @()
            foreach ($roleScopeTagId in $resolvedRoleScopeTagIds)
            {
                $Tag = Get-MgBetaDeviceManagementRoleScopeTag -RoleScopeTagId $roleScopeTagId -ErrorAction SilentlyContinue
                if ($null -ne $Tag)
                {
                    $ScopeRoleTags += $Tag.Id
                }
            }

            $resourceActions = @{
                '@odata.type'             = 'microsoft.graph.resourceAction'
            }

            if ($this.GetBoundParameters().ContainsKey('allowedResourceActions'))
            {
                $resourceActions.Add('allowedResourceActions', $this.allowedResourceActions)
            }

            if ($this.GetBoundParameters().ContainsKey('notAllowedResourceActions'))
            {
                $resourceActions.Add('notAllowedResourceActions', $this.notAllowedResourceActions)
            }

            $rolepermission = @{
                '@odata.type'   = 'microsoft.graph.rolePermission'
                resourceActions = @($resourceActions)
            }
            $createParameters = @{
                '@odata.type'   = '#microsoft.graph.roleDefinition'
                displayName     = $this.DisplayName
                description     = $this.Description
                rolePermissions = @($rolepermission)
            }

            if ($ScopeRoleTags.Count -gt 0)
            {
                $createParameters.Add('roleScopeTagIds', $ScopeRoleTags)
            }

            $policy = New-MgBetaDeviceManagementRoleDefinition -BodyParameter $createParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating Role Definition {$($this.DisplayName)}"
            $ScopeRoleTags = @()
            foreach ($roleScopeTagId in $resolvedRoleScopeTagIds)
            {
                $Tag = Get-MgBetaDeviceManagementRoleScopeTag -RoleScopeTagId $roleScopeTagId -ErrorAction SilentlyContinue
                if ($null -ne $Tag)
                {
                    $ScopeRoleTags += $Tag.Id
                }
            }

            $resourceActions = @{
                '@odata.type'             = 'microsoft.graph.resourceAction'
            }

            if ($this.GetBoundParameters().ContainsKey('allowedResourceActions'))
            {
                $resourceActions.Add('allowedResourceActions', $this.allowedResourceActions)
            }

            if ($this.GetBoundParameters().ContainsKey('notAllowedResourceActions'))
            {
                $resourceActions.Add('notAllowedResourceActions', $this.notAllowedResourceActions)
            }

            $rolepermission = @{
                '@odata.type'   = 'microsoft.graph.rolePermission'
                resourceActions = @($resourceActions)
            }
            $updateParameters = @{
                '@odata.type'   = '#microsoft.graph.roleDefinition'
                displayName     = $this.DisplayName
                description     = $this.Description
                rolePermissions = @($rolepermission)
            }

            if ($ScopeRoleTags.Count -gt 0)
            {
                $updateParameters.Add('roleScopeTagIds', $ScopeRoleTags)
            }

            Update-MgBetaDeviceManagementRoleDefinition -BodyParameter $updateParameters `
                -RoleDefinitionId $currentInstance.Id

        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing Role Definition {$($this.DisplayName)}"
            Remove-MgBetaDeviceManagementRoleDefinition -RoleDefinitionId $currentInstance.Id
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
            $baseFilter = "isof('microsoft.graph.deviceAndAppManagementRoleDefinition')"
            $mergedFilter = $baseFilter
            if (-not [System.String]::IsNullOrEmpty($this.Filter))
            {
                $mergedFilter = "($baseFilter) and ($($this.Filter))"
            }
            [array]$getValue = Get-MgBetaDeviceManagementRoleDefinition -Filter $mergedFilter -All -ErrorAction Stop

            if (-not $getValue)
            {
                [array]$getValue = Get-MgBetaDeviceManagementRoleDefinition -All -ErrorAction Stop
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

    hidden [IntuneRoleDefinition] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneRoleDefinition])
        {
            return $Values
        }

        $result = [IntuneRoleDefinition]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
