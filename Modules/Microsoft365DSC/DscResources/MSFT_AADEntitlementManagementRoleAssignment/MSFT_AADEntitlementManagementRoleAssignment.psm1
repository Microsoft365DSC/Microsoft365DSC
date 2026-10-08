using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADEntitlementManagementRoleAssignment : M365DSCResourceBase
{
    [DscProperty()]
    [System.ComponentModel.Description('Unique Id of the role assignment.')]
    [System.String] $Id

    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier of the principal to which the assignment is granted.')]
    [System.String] $Principal

    [DscProperty(Key)]
    [System.ComponentModel.Description('Identifier of the unifiedRoleDefinition the assignment is for.')]
    [System.String] $RoleDefinition

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the app specific scope when the assignment scope is app specific. The scope of an assignment determines the set of resources for which the principal has been granted access. App scopes are scopes that are defined and understood by a resource application only.')]
    [System.String] $AppScopeId

    [DscProperty()]
    [System.ComponentModel.Description('Identifier of the directory object representing the scope of the assignment. The scope of an assignment determines the set of resources for which the principal has been granted access. Directory scopes are shared scopes stored in the directory that are understood by multiple applications, unlike app scopes that are defined and understood by a resource application only.')]
    [System.String] $DirectoryScopeId

    [DscProperty()]
    [System.ComponentModel.Description('Present ensures the policy exists, absent ensures it is removed.')]
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

    [AADEntitlementManagementRoleAssignment] Get()
    {
        $principalName = $null
        $nullResult = $null
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADEntitlementManagementRoleAssignment]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of AzureAD Entitlement Management Role Assignment for Principal {$($this.Principal)}"

        try
        {
            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {
                $null = $this.Connect('MicrosoftGraph')

                Confirm-M365DSCDependencies

                $this.AddTelemetry('Get')

                $nullResult = $this.GetBoundParameters()
                $nullResult.Ensure = 'Absent'
                $getValue = $null

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaRoleManagementEntitlementManagementRoleAssignment -UnifiedRoleAssignmentId $this.Id `
                        -ExpandProperty 'Principal' `
                        -ErrorAction SilentlyContinue
                }

                if ($null -eq $getValue)
                {
                    if ($null -eq $this.ResourceCache['AllRoleAssignments'])
                    {
                        $this.ResourceCache['AllRoleAssignments'] = Get-MgBetaRoleManagementEntitlementManagementRoleAssignment `
                            -ExpandProperty 'Principal' `
                            -All `
                            -Top 15
                    }
                    if ($null -eq $this.ResourceCache['AllRoleDefinitions'])
                    {
                        [array]$this.ResourceCache['AllRoleDefinitions'] = Get-MgBetaRoleManagementEntitlementManagementRoleDefinition -All -Top 50
                        $this.ResourceCache['AllRoleDefinitions'] += @{
                            Id          = 'e65cf63f-9cc2-4b48-8871-cb667e9d90fb'
                            DisplayName = 'Connected organization administrator'
                        }
                    }

                    Write-Verbose -Message "Getting role assignment for Principal {$($this.Principal)}"
                    $getValue = $this.ResourceCache['AllRoleAssignments'] | Where-Object {
                        ($_.Principal.displayName -eq $this.Principal -or $_.Principal.userPrincipalName -eq $this.Principal -or $_.Principal.Id -eq $this.Principal) `
                            -and ($_.RoleDefinitionId -eq $($this.ResourceCache['AllRoleDefinitions'] | Where-Object { $_.DisplayName -eq $this.RoleDefinition }).Id)
                    }
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message 'No existing assignments were found'
                return $this.AsResult($nullResult)
            }

            switch ($getValue.Principal.'@odata.type')
            {
                '#microsoft.graph.user'
                {
                    $principalName = $getValue.Principal.userPrincipalName
                }
                '#microsoft.graph.servicePrincipal'
                {
                    $principalName = $getValue.Principal.displayName
                }
                $null
                {
                    $principalName = (Get-MgGroup -GroupId $getValue.PrincipalId).displayName
                }
            }

            Write-Verbose -Message "Found existing role assignment with ID {$($getValue.id)}."

            $results = @{
                Id                    = $getValue.Id
                Principal             = $principalName
                RoleDefinition        = $this.RoleDefinition
                DisplayName           = $getValue.DisplayName
                AppScopeId            = $getValue.AppScopeId
                DirectoryScopeId      = $getValue.DirectoryScopeId
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

        Write-Verbose -Message "Setting configuration of AzureAD Entitlement Management Role Assignment for Principal {$($this.Principal)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        $currentInstance = $this.Get().ToHashtable()
        $setParameters = Remove-M365DSCAuthenticationParameter -BoundParameters $this.GetBoundParameters()

        $batchRequests = @(
            @{
                id     = 'user'
                method = 'GET'
                url    = "/users/$($this.Principal)?`$select=id,userPrincipalName,displayName"
            }
            @{
                id     = 'group'
                method = 'GET'
                url    = "/groups?`$filter=displayName eq '$($this.Principal -replace "'", "''")'&`$select=id,displayName"
            }
            @{
                id     = 'servicePrincipal'
                method = 'GET'
                url    = "/servicePrincipals?`$filter=displayName eq '$($this.Principal -replace "'", "''")'&`$select=id,displayName"
            }
        )
        $batchResponses = Invoke-M365DSCGraphBatchRequest -Requests $batchRequests

        $objectId = $null
        foreach ($response in $batchResponses)
        {
            if ($response.body.id)
            {
                # Direct GET response (user)
                $objectId = $response.body.id
                break
            }
            elseif ($response.body.value.Count -gt 0)
            {
                # Filter response (group/servicePrincipal)
                $objectId = $response.body.value[0].id
                break
            }
        }

        if ($null -eq $objectId)
        {
            throw "Principal '$($this.Principal)' not found. Ensure the Principal exists and is correctly specified."
        }
        if ($objectId -is [array] -and $objectId.Count -gt 1)
        {
            throw "Multiple objects found for Principal '$($this.Principal)'. Please specify a unique identifier."
        }

        $setParameters = Rename-M365DSCCimInstanceParameter -Properties $setParameters

        $roleInfo = Get-MgBetaRoleManagementEntitlementManagementRoleDefinition -Filter "DisplayName eq '$($this.RoleDefinition -replace "'", "''")'"
        $setParameters.Add('principalId', $objectId)
        $setParameters.Add('roleDefinitionId', $roleInfo.Id)
        $setParameters.Remove('Principal') | Out-Null
        $setParameters.Remove('RoleDefinition') | Out-Null

        if ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Absent')
        {
            $setParameters.Remove('Id') | Out-Null
            Write-Verbose -Message "Creating a new Entitlement Management Role Assignment for Principal {$($this.Principal)} with Role {$($this.RoleDefinition)}"
            New-MgBetaRoleManagementEntitlementManagementRoleAssignment -BodyParameter $setParameters
        }
        elseif ($this.Ensure -eq 'Present' -and $currentInstance.Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Entitlement Management Role Assignments cannot be updated.'
        }
        elseif ($this.Ensure -eq 'Absent' -and $currentInstance.Ensure -eq 'Present')
        {
            Remove-MgBetaRoleManagementEntitlementManagementRoleAssignment -UnifiedRoleAssignmentId $currentInstance.Id
        }
    }

    [bool] Test()
    {
        return ([M365DSCResourceBase] $this).Test()
    }

    [string] Export()
    {
        $principalName = $null
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
            [array]$getValue = Get-MgBetaRoleManagementEntitlementManagementRoleAssignment `
                -All `
                -ExpandProperty 'Principal' `
                -Filter $this.Filter `
                -Top 15 `
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

                if ($null -eq $this.ResourceCache['AllRoleDefinitions'])
                {
                    [array]$this.ResourceCache['AllRoleDefinitions'] = Get-MgBetaRoleManagementEntitlementManagementRoleDefinition -All -Top 50
                    $this.ResourceCache['AllRoleDefinitions'] += @{
                        Id          = 'e65cf63f-9cc2-4b48-8871-cb667e9d90fb'
                        DisplayName = 'Connected organization administrator'
                    }
                }

                $displayedKey = $config.id
                if (-not [String]::IsNullOrEmpty($config.displayName))
                {
                    $displayedKey = $config.displayName
                }
                Write-M365DSCHost -Message "    |---[$i/$($getValue.Count)] $displayedKey" -DeferWrite
                $roleInfo = $this.ResourceCache['AllRoleDefinitions'] | Where-Object { $_.Id -eq $config.RoleDefinitionId }
                switch ($config.Principal.'@odata.type')
                {
                    '#microsoft.graph.user'
                    {
                        $principalName = $config.Principal.userPrincipalName
                    }
                    '#microsoft.graph.servicePrincipal'
                    {
                        $principalName = $config.Principal.displayName
                    }
                    $null
                    {
                        $principalName = (Get-MgGroup -GroupId $config.PrincipalId).displayName
                    }
                }
                $params = @{
                    Id                    = $config.Id
                    Principal             = $principalName
                    RoleDefinition        = $roleInfo.DisplayName
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

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential

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
            if ($_.ErrorDetails.Message -like '*User is not authorized to perform the operation.*')
            {
                Write-M365DSCHost -Message "`r`n    $($Global:M365DSCEmojiYellowCircle) Tenant does not meet license requirement to extract this component or the user has not been granted the proper permissions."
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

    hidden [AADEntitlementManagementRoleAssignment] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADEntitlementManagementRoleAssignment])
        {
            return $Values
        }

        $result = [AADEntitlementManagementRoleAssignment]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}
