using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class IntuneRoleAssignmentWindows365 : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Ids of the app specific scopes when the assignment scopes are app specific. The scopes of an assignment determine the set of resources for which the principal has access.')]
    [System.String[]] $AppScopeIds

    [DscProperty()]
    [System.ComponentModel.Description('Description of the role assignment.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Display Names of the groups that represent the scopes of the assignment.')]
    [System.String[]] $DirectoryScopes

    [DscProperty(Key)]
    [System.ComponentModel.Description('Name of the role assignment. Required.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('Display name of the principals to which the assignment is granted.')]
    [System.String[]] $Principals

    [DscProperty(Mandatory)]
    [System.ComponentModel.Description('Display name of the IntuneRoleDefinitionWindows365 the assignment is for.')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for an entity. Read-only.')]
    [System.String] $Id

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

    [IntuneRoleAssignmentWindows365] Get()
    {
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [IntuneRoleAssignmentWindows365]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration for the Intune Role Assignment Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

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
                    $getValue = Get-MgBetaRoleManagementCloudPcRoleAssignment -UnifiedRoleAssignmentMultipleId $this.Id  -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Role Assignment Windows365 with Id {$($this.Id)}"

                    if (-not [System.String]::IsNullOrEmpty($this.DisplayName))
                    {
                        $getValue = Get-MgBetaRoleManagementCloudPcRoleAssignment -All `
                            -Filter "DisplayName eq '$($this.DisplayName -replace "'", "''")'" `
                            -ErrorAction SilentlyContinue
                    }
                }
                #endregion
                if ($null -eq $getValue)
                {
                    Write-Verbose -Message "Could not find an Intune Role Assignment Windows365 with DisplayName {$($this.DisplayName)}."
                    return $this.AsResult($nullResult)
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }
            $resolvedId = $getValue.Id
            Write-Verbose -Message "An Intune Role Assignment Windows365 with Id {$($resolvedId)} and DisplayName {$($this.DisplayName)} was found"

            if ($getValue.DirectoryScopeIds -notcontains "0")
            {
                $batchRequests = @()
                foreach ($directoryScopeId in $getValue.DirectoryScopeIds)
                {
                    $batchRequests += @{
                        id      = $directoryScopeId
                        method = 'GET'
                        url    = "/groups/$($directoryScopeId)?`$select=id,displayName"
                    }
                }
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
                foreach ($response in $batchResponses)
                {
                    if ($response.status -ne 200)
                    {
                        Write-Warning -Message "The Directory Scope group with Id '$($response.id)' was not found for {$($this.DisplayName)}. It will be skipped for the current configuration."
                    }
                }
                $groupDisplayNames = @($batchResponses.body.displayName | Sort-Object)
            }
            else
            {
                $groupDisplayNames = @("All Users")
            }

            $batchRequests = @()
            foreach ($principalId in $getValue.PrincipalIds)
            {
                $batchRequests += @{
                    id      = $principalId
                    method = 'GET'
                    url    = "/groups/$($principalId)?`$select=id,displayName"
                }
            }
            $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests
            foreach ($response in $batchResponses)
            {
                if ($response.status -ne 200)
                {
                    Write-Warning -Message "The Principal group with Id '$($response.id)' was not found for {$($this.DisplayName)}. It will be skipped for the current configuration."
                }
            }
            $principalDisplayNames = @($batchResponses.body.displayName | Sort-Object)

            if ($null -eq $this.ResourceCache['RoleDefinitionsCache'])
            {
                $this.ResourceCache['RoleDefinitionsCache'] = @{}
            }

            if (-not $this.ResourceCache['RoleDefinitionsCache'].ContainsKey($getValue.RoleDefinitionId))
            {
                $roleDef = Get-MgBetaRoleManagementCloudPcRoleDefinition -UnifiedRoleDefinitionId $getValue.RoleDefinitionId
                $this.ResourceCache['RoleDefinitionsCache'].Add($getValue.RoleDefinitionId, $roleDef.DisplayName)
            }
            $roleDefinitionName = $this.ResourceCache['RoleDefinitionsCache'][$getValue.RoleDefinitionId]

            $results = @{
                #region resource generator code
                AppScopeIds           = $getValue.AppScopeIds # RoleScopeTagIds
                Description           = $getValue.Description
                DirectoryScopes       = $groupDisplayNames
                DisplayName           = $getValue.DisplayName
                Principals            = $principalDisplayNames
                RoleDefinition        = $roleDefinitionName
                Id                    = $getValue.Id
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

            return $this.AsResult($results)
        }
        catch
        {
            $this.LogError($_, 'Error retrieving data:')

            return $this.AsResult($nullResult)
        }
    }

    [void] Set()
    {
        if ($this.RequiresPowerShellCore())
        {
            $null = $this.InvokeInPowerShellCore('Set')
            return
        }

        Write-Verbose -Message "Setting configuration of the Intune Role Assignment Windows365 with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $boundParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        if ($boundParameters.ContainsKey('RoleDefinition'))
        {
            $roleDef = Get-MgBetaRoleManagementCloudPcRoleDefinition -All -Filter "DisplayName eq '$($this.RoleDefinition -replace "'", "''")'" -ErrorAction Stop
            if ($null -eq $roleDef)
            {
                throw "The IntuneRoleDefinitionWindows365 with name '$($this.RoleDefinition)' was not found for {$($this.DisplayName)}."
            }
            $boundParameters.RoleDefinitionId = $roleDef.Id
            $boundParameters.Remove('RoleDefinition') | Out-Null
        }

        if ($boundParameters.ContainsKey('DirectoryScopes'))
        {
            $directoryScopeIds = @()
            if ($this.DirectoryScopes -contains "All Users")
            {
                $directoryScopeIds += "0"
            }
            if ($this.DirectoryScopes.Count -gt 0 -and $this.DirectoryScopes -notcontains "All Users")
            {
                $batchRequests = @()
                foreach ($name in $this.DirectoryScopes)
                {
                    $batchRequests += @{
                        id     = $name
                        method = 'GET'
                        url    = "/groups?`$filter=displayName eq '$($name -replace "'", "''")'&`$select=id,displayName"
                    }
                }
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests

                foreach ($resp in $batchResponses)
                {
                    if ($resp.status -ne 200 -or $null -eq $resp.body.value -or $resp.body.value.Count -eq 0)
                    {
                        throw "The Directory Scope group with name '$($resp.id)' was not found for {$($this.DisplayName)}."
                    }
                    $directoryScopeIds += $resp.body.value[0].id
                }
            }

            $boundParameters.DirectoryScopeIds = $directoryScopeIds
            $boundParameters.Remove('DirectoryScopes') | Out-Null
        }

        if ($boundParameters.ContainsKey('Principals'))
        {
            $principalIds = @()
            if ($this.Principals.Count -gt 0)
            {
                $batchRequests = @()
                foreach ($name in $this.Principals)
                {
                    $batchRequests += @{
                        id     = $name
                        method = 'GET'
                        url    = "/groups?`$filter=displayName eq '$($name -replace "'", "''")'&`$select=id,displayName"
                    }
                }
                $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests

                foreach ($resp in $batchResponses)
                {
                    if ($resp.status -ne 200 -or $null -eq $resp.body.value -or $resp.body.value.Count -eq 0)
                    {
                        throw "The Principal group with name '$($resp.id)' was not found for {$($this.DisplayName)}."
                    }
                    $principalIds += $resp.body.value[0].id
                }
            }

            $boundParameters.PrincipalIds = $principalIds
            $boundParameters.Remove('Principals') | Out-Null
        }

        $boundParameters = Rename-M365DSCCimInstanceParameter -Properties $boundParameters

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Creating an Intune Role Assignment Windows365 with DisplayName {$($this.DisplayName)}"

            $createParameters = $boundParameters
            $createParameters.Remove('Id') | Out-Null

            #region resource generator code
            $policy = New-MgBetaRoleManagementCloudPcRoleAssignment -BodyParameter $createParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Updating the Intune Role Assignment Windows365 with Id {$($currentInstance.Id)}"

            $updateParameters = $boundParameters
            $updateParameters.Remove('Id') | Out-Null
            $updateParameters.Remove('RoleDefinitionId') | Out-Null

            #region resource generator code
            Update-MgBetaRoleManagementCloudPcRoleAssignment `
                -UnifiedRoleAssignmentMultipleId $currentInstance.Id `
                -BodyParameter $updateParameters
            #endregion
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing the Intune Role Assignment Windows365 with Id {$($currentInstance.Id)}"
            #region resource generator code
            Remove-MgBetaRoleManagementCloudPcRoleAssignment -UnifiedRoleAssignmentMultipleId $currentInstance.Id
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
            [array]$getValue = Get-MgBetaRoleManagementCloudPcRoleAssignment `
                -Filter $this.Filter `
                -All `
                -Top 50 `
                -ErrorAction Stop
            #endregion

            $i = 1
            $dscContent = [System.Text.StringBuilder]::new()
            if ($getValue.Count -eq 0)
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
                    Id                    = $config.Id
                    DisplayName           = $config.DisplayName
                    RoleDefinition        = $config.RoleDefinitionId
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX -CommitWrite

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    hidden [IntuneRoleAssignmentWindows365] AsResult([System.Object] $Values)
    {
        if ($Values -is [IntuneRoleAssignmentWindows365])
        {
            return $Values
        }

        $result = [IntuneRoleAssignmentWindows365]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
