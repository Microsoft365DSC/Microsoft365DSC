using module ..\_Base\M365DSCResourceBase.psm1

[DscResource()]
class AADPermissionGrantPolicy : M365DSCResourceBase
{
    [DscProperty(Key)]
    [System.ComponentModel.Description('The unique identifier for the permission grant policy.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('The display name for the permission grant policy.')]
    [System.String] $DisplayName

    [DscProperty()]
    [System.ComponentModel.Description('The description for the permission grant policy.')]
    [System.String] $Description

    [DscProperty()]
    [System.ComponentModel.Description('Condition sets which are included in this permission grant policy. Automatically constructed as part of the permission grant policy.')]
    [MSFT_AADPermissionGrantConditionSet[]] $Includes

    [DscProperty()]
    [System.ComponentModel.Description('Condition sets which are excluded in this permission grant policy. Automatically constructed as part of the permission grant policy.')]
    [MSFT_AADPermissionGrantConditionSet[]] $Excludes

    [DscProperty()]
    [System.ComponentModel.Description('Set to true to create all pre-approval policies in the tenant.')]
    [System.Nullable[System.Boolean]] $IncludeAllPreApprovedApplications

    [DscProperty()]
    [System.ComponentModel.Description('The scope of the resource to which the pre-approval policy applies.')]
    [ValidateSet('chat', 'group', 'team', 'tenant')]
    [System.String] $ResourceScopeType

    [DscProperty()]
    [System.ComponentModel.Description('Specify if the policy should exist.')]
    [ValidateSet('Present', 'Absent')]
    [System.String] $Ensure

    [DscProperty()]
    [System.ComponentModel.Description('Credentials for the Microsoft Graph delegated permissions.')]
    [System.Management.Automation.PSCredential] $Credential

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID application to authenticate with.')]
    [System.String] $ApplicationId

    [DscProperty()]
    [System.ComponentModel.Description('Id of the Entra ID tenant used for authentication.')]
    [System.String] $TenantId

    [DscProperty()]
    [System.ComponentModel.Description('Secret of the Entra ID application to authenticate with.')]
    [System.Management.Automation.PSCredential] $ApplicationSecret

    [DscProperty()]
    [System.ComponentModel.Description('Thumbprint of the Entra ID application''s authentication certificate to use for authentication.')]
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

    [AADPermissionGrantPolicy] Get()
    {
        if ($this.RequiresPowerShellCore())
        {
            $remote = [AADPermissionGrantPolicy]::new()
            $remote.FromHashtable($this.InvokeInPowerShellCore('Get'))
            return $remote
        }

        Write-Verbose -Message "Getting configuration of Entra Permission Grant Policy {$($this.Id)}"

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

            if (-not $this.ExportedInstance -or $this.ExportedInstance.Id -ne $this.Id)
            {

                if (-not [System.String]::IsNullOrEmpty($this.Id))
                {
                    $getValue = Get-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id `
                        -ErrorAction SilentlyContinue
                }
                else
                {
                    $getValue = Get-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id `
                        -ErrorAction SilentlyContinue
                }
            }
            else
            {
                $getValue = $this.ExportedInstance
            }

            if ($null -eq $getValue)
            {
                Write-Verbose -Message "No Entra Permission Grant Policy with Id {$($this.Id)} was found"
                return $this.AsResult($nullResult)
            }

            Write-Verbose -Message "Found Entra Permission Grant Policy with Id {$($this.Id)}"

            # Convert Includes collection to hashtable array
            $includesArray = @()
            if ($null -ne $getValue.Includes)
            {
                foreach ($include in $getValue.Includes)
                {
                    $includesArray += [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($this.ResourceCache, $include)
                }
            }

            # Convert Excludes collection to hashtable array
            $excludesArray = @()
            if ($null -ne $getValue.Excludes)
            {
                foreach ($exclude in $getValue.Excludes)
                {
                    $excludesArray += [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($this.ResourceCache, $exclude)
                }
            }

            $result = @{
                Id                                = $getValue.Id
                DisplayName                       = $getValue.DisplayName
                Description                       = $getValue.Description
                Includes                          = [Array]$includesArray
                Excludes                          = [Array]$excludesArray
                IncludeAllPreApprovedApplications = $getValue.IncludeAllPreApprovedApplications
                ResourceScopeType                 = $getValue.ResourceScopeType
                Ensure                            = 'Present'
                Credential                        = $this.Credential
                ApplicationId                     = $this.ApplicationId
                TenantId                          = $this.TenantId
                ApplicationSecret                 = $this.ApplicationSecret
                CertificateThumbprint             = $this.CertificateThumbprint
                CertificatePath                   = $this.CertificatePath
                CertificatePassword               = $this.CertificatePassword
                ManagedIdentity                   = $this.ManagedIdentity
                AccessTokens                      = $this.AccessTokens
            }

            return $this.AsResult($result)
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

        Write-Verbose -Message "Setting configuration of Entra Permission Grant Policy {$($this.Id)}"

        Confirm-M365DSCDependencies

        $this.AddTelemetry('Set')

        try
        {
            # Clear the service principal cache for fresh lookups
            $null = [AADPermissionGrantPolicy]::GetServicePrincipalCache($this.ResourceCache, $true)

            $null = $this.Connect('MicrosoftGraph')

            $currentPolicy = $this.Get().ToHashtable()

            # CREATE
            if ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Absent')
            {
                Write-Verbose -Message "Creating new Entra Permission Grant Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

                $createParameters = @{
                    Id          = $this.Id
                    DisplayName = $this.DisplayName
                    Description = $this.Description
                }

                if ($this.GetBoundParameters().ContainsKey('IncludeAllPreApprovedApplications'))
                {
                    $createParameters.Add('IncludeAllPreApprovedApplications', $this.IncludeAllPreApprovedApplications)
                }

                if ($this.GetBoundParameters().ContainsKey('ResourceScopeType'))
                {
                    $createParameters.Add('ResourceScopeType', $this.ResourceScopeType)
                }

                New-MgBetaPolicyPermissionGrantPolicy -BodyParameter $createParameters | Out-Null

                # Add Includes
                if ($null -ne $this.Includes -and $this.Includes.Count -gt 0)
                {
                    foreach ($include in $this.Includes)
                    {
                        Write-Verbose -Message "Adding include condition set {$($include.Id)}"
                        $includeParams = $this.GetPermissionGrantConditionSetAsParameters($this.ResourceCache, $include)
                        $this.AddConditionSet('Include', $includeParams)
                    }
                }

                # Add Excludes
                if ($null -ne $this.Excludes -and $this.Excludes.Count -gt 0)
                {
                    foreach ($exclude in $this.Excludes)
                    {
                        Write-Verbose -Message "Adding exclude condition set {$($exclude.Id)}"
                        $excludeParams = $this.GetPermissionGrantConditionSetAsParameters($this.ResourceCache, $exclude)
                        $this.AddConditionSet('Exclude', $excludeParams)
                    }
                }
            }
            # UPDATE
            elseif ($this.Ensure -eq 'Present' -and $currentPolicy.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Updating Entra Permission Grant Policy with Id {$($this.Id)} and DisplayName {$($this.DisplayName)}"

                $updateParameters = @{}
                if ($this.GetBoundParameters().ContainsKey('DisplayName') -and $this.DisplayName -ne $currentPolicy.DisplayName)
                {
                    $updateParameters.Add('DisplayName', $this.DisplayName)
                }

                if ($this.GetBoundParameters().ContainsKey('Description') -and $this.Description -ne $currentPolicy.Description)
                {
                    $updateParameters.Add('Description', $this.Description)
                }

                if ($this.GetBoundParameters().ContainsKey('IncludeAllPreApprovedApplications') -and $this.IncludeAllPreApprovedApplications -ne $currentPolicy.IncludeAllPreApprovedApplications)
                {
                    $updateParameters.Add('IncludeAllPreApprovedApplications', $this.IncludeAllPreApprovedApplications)
                }

                if ($this.GetBoundParameters().ContainsKey('ResourceScopeType') -and $this.ResourceScopeType -ne $currentPolicy.ResourceScopeType)
                {
                    $updateParameters.Add('ResourceScopeType', $this.ResourceScopeType)
                }

                if ($updateParameters.Count -gt 0)
                {
                    Update-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id -BodyParameter $updateParameters | Out-Null
                    $this.WaitForPolicyProperties($updateParameters)
                }

                # Sync Includes - use content-based matching since desired state
                # condition sets may not have Id (auto-generated by Graph API)
                Write-Verbose -Message "Syncing Includes"
                if ($null -ne $this.Includes)
                {
                    $matchedCurrentIncludeIds = @()

                    # Find matches for each desired include by content
                    foreach ($desiredInclude in $this.Includes)
                    {
                        $matchFound = $false
                        foreach ($currentInclude in $currentPolicy.Includes)
                        {
                            if ($currentInclude.Id -notin $matchedCurrentIncludeIds -and
                                ($this.TestConditionSetsEqual($this.ResourceCache, $desiredInclude, $currentInclude)))
                            {
                                $matchedCurrentIncludeIds += $currentInclude.Id
                                $matchFound = $true
                                break
                            }
                        }

                        if (-not $matchFound)
                        {
                            Write-Verbose -Message "Adding include condition set"
                            $includeParams = $this.GetPermissionGrantConditionSetAsParameters($this.ResourceCache, $desiredInclude)
                            $this.AddConditionSet('Include', $includeParams)
                        }
                    }

                    # Remove current includes that were not matched to any desired include
                    foreach ($currentInclude in $currentPolicy.Includes)
                    {
                        if ($currentInclude.Id -notin $matchedCurrentIncludeIds)
                        {
                            Write-Verbose -Message "Removing include condition set {$($currentInclude.Id)}"
                            $this.RemoveConditionSet('Include', $currentInclude.Id)
                        }
                    }
                }

                # Sync Excludes - use content-based matching since desired state
                # condition sets may not have Id (auto-generated by Graph API)
                Write-Verbose -Message "Syncing Excludes"
                if ($null -ne $this.Excludes)
                {
                    $matchedCurrentExcludeIds = @()

                    # Find matches for each desired exclude by content
                    foreach ($desiredExclude in $this.Excludes)
                    {
                        $matchFound = $false
                        foreach ($currentExclude in $currentPolicy.Excludes)
                        {
                            if ($currentExclude.Id -notin $matchedCurrentExcludeIds -and
                                ($this.TestConditionSetsEqual($this.ResourceCache, $desiredExclude, $currentExclude)))
                            {
                                $matchedCurrentExcludeIds += $currentExclude.Id
                                $matchFound = $true
                                break
                            }
                        }

                        if (-not $matchFound)
                        {
                            Write-Verbose -Message "Adding exclude condition set"
                            $excludeParams = $this.GetPermissionGrantConditionSetAsParameters($this.ResourceCache, $desiredExclude)
                            $this.AddConditionSet('Exclude', $excludeParams)
                        }
                    }

                    # Remove current excludes that were not matched to any desired exclude
                    foreach ($currentExclude in $currentPolicy.Excludes)
                    {
                        if ($currentExclude.Id -notin $matchedCurrentExcludeIds)
                        {
                            Write-Verbose -Message "Removing exclude condition set {$($currentExclude.Id)}"
                            $this.RemoveConditionSet('Exclude', $currentExclude.Id)
                        }
                    }
                }
            }
            # REMOVE
            elseif ($this.Ensure -eq 'Absent' -and $currentPolicy.Ensure -eq 'Present')
            {
                Write-Verbose -Message "Removing Entra Permission Grant Policy {$($this.Id)}"
                Remove-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id | Out-Null
            }
        }
        catch
        {
            $this.LogError($_, 'Error updating data:')

            throw
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
            [array] $exportedInstances = Get-MgBetaPolicyPermissionGrantPolicy -All `
                -ErrorAction Stop

            $dscContent = [System.Text.StringBuilder]::new()
            $i = 1

            if ($exportedInstances.Length -eq 0)
            {
                Write-M365DSCHost -Message $Global:M365DSCEmojiGreenCheckMark -CommitWrite
            }
            else
            {
                Write-M365DSCHost -Message "`r`n" -DeferWrite
            }

            foreach ($policy in $exportedInstances)
            {
                if ($null -ne $Global:M365DSCExportResourceInstancesCount)
                {
                    $Global:M365DSCExportResourceInstancesCount++
                }

                Write-M365DSCHost -Message "    |---[$i/$($exportedInstances.Count)] $($policy.Id)" -DeferWrite

                $Params = @{
                    Id                    = $policy.Id
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

                if ($null -ne $Results.Includes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Includes `
                        -CIMInstanceName 'MSFT_AADPermissionGrantConditionSet'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Includes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Includes') | Out-Null
                    }
                }

                if ($null -ne $Results.Excludes)
                {
                    $complexTypeStringResult = Get-M365DSCDRGComplexTypeToString `
                        -ComplexObject $Results.Excludes `
                        -CIMInstanceName 'MSFT_AADPermissionGrantConditionSet'
                    if (-not [System.String]::IsNullOrWhiteSpace($complexTypeStringResult))
                    {
                        $Results.Excludes = $complexTypeStringResult
                    }
                    else
                    {
                        $Results.Remove('Excludes') | Out-Null
                    }
                }

                $currentDSCBlock = Get-M365DSCExportContentForResource -ResourceName $this.GetResourceName() `
                    -ConnectionMode $ConnectionMode `
                    -ModulePath $this.GetModulePath() `
                    -Results $Results `
                    -Credential $this.Credential `
                    -NoEscape @('Includes', 'Excludes')
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
            Write-M365DSCHost -Message $Global:M365DSCEmojiRedX

            $this.LogError($_, 'Error during Export:')

            throw
        }
    }

    [System.Collections.Hashtable] GetCompareParameters()
    {
        # Normalize condition sets so that permission names compare correctly against the current
        # values. Condition set ids are assigned by the service and Set matches sets by content,
        # so they are left out of the comparison.
        return @{
            PostProcessing = {
                param($DesiredValues, $CurrentValues, $ValuesToCheck, $PostProcessingArgs)

                foreach ($propertyName in @('Includes', 'Excludes'))
                {
                    if ($null -ne $ValuesToCheck[$propertyName])
                    {
                        $normalizedSets = @()
                        foreach ($conditionSet in $ValuesToCheck[$propertyName])
                        {
                            $normalizedSet = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($PostProcessingArgs[0], $conditionSet)
                            $normalizedSet.Remove('Id')
                            $normalizedSets += $normalizedSet
                        }
                        $ValuesToCheck[$propertyName] = [Array]$normalizedSets
                        $DesiredValues[$propertyName] = [Array]$normalizedSets
                    }

                    if ($null -ne $CurrentValues[$propertyName])
                    {
                        $currentSets = @()
                        foreach ($conditionSet in $CurrentValues[$propertyName])
                        {
                            $currentSet = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($PostProcessingArgs[0], $conditionSet)
                            $currentSet.Remove('Id')
                            $currentSets += $currentSet
                        }
                        $CurrentValues[$propertyName] = [Array]$currentSets
                    }
                }

                return [System.Tuple[Hashtable, Hashtable, Hashtable]]::new($DesiredValues, $CurrentValues, $ValuesToCheck)
            }
            PostProcessingArgs = @($this.ResourceCache)
        }
    }

    hidden [void] AddConditionSet([System.String] $Kind, [System.Collections.Hashtable] $Parameters)
    {
        $created = $null
        for ($attempt = 1; $attempt -le 6; $attempt++)
        {
            try
            {
                if ($Kind -eq 'Include')
                {
                    $created = New-MgBetaPolicyPermissionGrantPolicyInclude -PermissionGrantPolicyId $this.Id -BodyParameter $Parameters -ErrorAction Stop
                }
                else
                {
                    $created = New-MgBetaPolicyPermissionGrantPolicyExclude -PermissionGrantPolicyId $this.Id -BodyParameter $Parameters -ErrorAction Stop
                }
                break
            }
            catch
            {
                if ($attempt -ge 6 -or -not (Test-M365DSCNotFoundError -ErrorRecord $_))
                {
                    throw
                }
                Start-Sleep -Seconds 5
            }
        }

        $this.WaitForConditionSet($Kind, $created.Id, $true)
    }

    hidden [void] RemoveConditionSet([System.String] $Kind, [System.String] $ConditionSetId)
    {
        if ($Kind -eq 'Include')
        {
            Remove-MgBetaPolicyPermissionGrantPolicyInclude -PermissionGrantPolicyId $this.Id -PermissionGrantConditionSetId $ConditionSetId | Out-Null
        }
        else
        {
            Remove-MgBetaPolicyPermissionGrantPolicyExclude -PermissionGrantPolicyId $this.Id -PermissionGrantConditionSetId $ConditionSetId | Out-Null
        }

        $this.WaitForConditionSet($Kind, $ConditionSetId, $false)
    }

    hidden [void] WaitForConditionSet([System.String] $Kind, [System.String] $ConditionSetId, [System.Boolean] $Present)
    {
        if ([System.String]::IsNullOrEmpty($ConditionSetId))
        {
            return
        }

        $consecutiveReads = 0
        for ($attempt = 1; $attempt -le 6; $attempt++)
        {
            $policy = Get-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id -ErrorAction SilentlyContinue
            $conditionSets = $policy.Excludes
            if ($Kind -eq 'Include')
            {
                $conditionSets = $policy.Includes
            }

            if (($conditionSets.Id -contains $ConditionSetId) -eq $Present)
            {
                $consecutiveReads++
            }
            else
            {
                $consecutiveReads = 0
            }

            if ($consecutiveReads -ge 2)
            {
                return
            }

            Start-Sleep -Seconds 5
        }

        Write-Warning -Message "Timed out waiting for the $Kind condition set {$ConditionSetId} of permission grant policy {$($this.Id)} to replicate."
    }

    hidden [void] WaitForPolicyProperties([System.Collections.Hashtable] $Properties)
    {
        $consecutiveReads = 0
        for ($attempt = 1; $attempt -le 6; $attempt++)
        {
            $policy = Get-MgBetaPolicyPermissionGrantPolicy -PermissionGrantPolicyId $this.Id -ErrorAction SilentlyContinue
            $mismatch = $null -eq $policy
            foreach ($key in $Properties.Keys)
            {
                if ($policy.$key -ne $Properties[$key])
                {
                    $mismatch = $true
                }
            }

            if ($mismatch)
            {
                $consecutiveReads = 0
            }
            else
            {
                $consecutiveReads++
            }

            if ($consecutiveReads -ge 2)
            {
                return
            }

            Start-Sleep -Seconds 5
        }

        Write-Warning -Message "Timed out waiting for the updated properties of permission grant policy {$($this.Id)} to replicate."
    }

    hidden static [System.Collections.Hashtable] GetServicePrincipalCache([System.Collections.Hashtable] $Cache, [System.Boolean] $Reset)
    {
        if ($Reset -or $null -eq $Cache['ServicePrincipalCache'])
        {
            $Cache['ServicePrincipalCache'] = @{}
        }

        return $Cache['ServicePrincipalCache']
    }

    hidden [System.String] ResolveResourceApplicationName([System.Collections.Hashtable] $Cache, [System.String] $ResourceApplication)
    {
        # Pass through wildcard
        if ($ResourceApplication -eq 'any')
        {
            return $ResourceApplication
        }

        # If not a GUID, assume it is already a display name
        $guidResult = [System.Guid]::Empty
        if (-not [System.Guid]::TryParse($ResourceApplication, [ref]$guidResult))
        {
            return $ResourceApplication
        }

        try
        {
            $servicePrincipalCache = [AADPermissionGrantPolicy]::GetServicePrincipalCache($Cache, $false)
            $cacheKey = $guidResult.ToString()
            if ($servicePrincipalCache.ContainsKey($cacheKey))
            {
                $servicePrincipal = $servicePrincipalCache[$cacheKey]
            }
            else
            {
                $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$cacheKey'" -ErrorAction SilentlyContinue
                $servicePrincipalCache[$cacheKey] = $servicePrincipal
                if ($null -ne $servicePrincipal -and -not [System.String]::IsNullOrEmpty($servicePrincipal.DisplayName))
                {
                    $servicePrincipalCache[$servicePrincipal.DisplayName] = $servicePrincipal
                }
            }

            if ($null -ne $servicePrincipal)
            {
                Write-Verbose -Message "Resolved ResourceApplication '$ResourceApplication' to name '$($servicePrincipal.DisplayName)'."
                return $servicePrincipal.DisplayName
            }
        }
        catch
        {
            Write-Verbose -Message "Error resolving ResourceApplication '$ResourceApplication': $_"
        }

        return $ResourceApplication
    }

    hidden static [System.Collections.Hashtable] GetPermissionGrantConditionSetAsHashtable([System.Collections.Hashtable] $Cache, [System.Object] $ConditionSet)
    {
        $result = @{
            Id = $ConditionSet.Id
        }

        if ($null -ne $ConditionSet.CertifiedClientApplicationsOnly)
        {
            $result.Add('CertifiedClientApplicationsOnly', $ConditionSet.CertifiedClientApplicationsOnly)
        }

        if ($null -ne $ConditionSet.ClientApplicationIds)
        {
            $result.Add('ClientApplicationIds', [string[]]$ConditionSet.ClientApplicationIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationPublisherIds)
        {
            $result.Add('ClientApplicationPublisherIds', [string[]]$ConditionSet.ClientApplicationPublisherIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationTenantIds)
        {
            $result.Add('ClientApplicationTenantIds', [string[]]$ConditionSet.ClientApplicationTenantIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationsFromVerifiedPublisherOnly)
        {
            $result.Add('ClientApplicationsFromVerifiedPublisherOnly', $ConditionSet.ClientApplicationsFromVerifiedPublisherOnly)
        }

        if ($null -ne $ConditionSet.PermissionClassification)
        {
            $result.Add('PermissionClassification', $ConditionSet.PermissionClassification)
        }

        if ($null -ne $ConditionSet.PermissionType)
        {
            $result.Add('PermissionType', $ConditionSet.PermissionType)
        }

        if ($null -ne $ConditionSet.ResourceApplication)
        {
            $result.Add('ResourceApplication', $ConditionSet.ResourceApplication)
        }

        if ($null -ne $ConditionSet.Permissions)
        {
            $resolvedPermissions = @()
            foreach ($permission in $ConditionSet.Permissions)
            {
                $resolvedPermissions += [AADPermissionGrantPolicy]::ConvertToPermissionName($Cache, $permission, $ConditionSet.ResourceApplication, $ConditionSet.PermissionType)
            }
            $result.Add('Permissions', [string[]]$resolvedPermissions)
        }

        return $result
    }

    hidden [System.Boolean] TestConditionSetsEqual([System.Collections.Hashtable] $Cache, [System.Object] $ConditionSet1, [System.Object] $ConditionSet2)
    {
        # Convert both to hashtables for comparison
        $hash1 = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($Cache, $ConditionSet1)
        $hash2 = [AADPermissionGrantPolicy]::GetPermissionGrantConditionSetAsHashtable($Cache, $ConditionSet2)

        $serviceDefaults = @{
            CertifiedClientApplicationsOnly             = $false
            ClientApplicationIds                        = [System.String[]] @('all')
            ClientApplicationPublisherIds               = [System.String[]] @('all')
            ClientApplicationTenantIds                  = [System.String[]] @('all')
            ClientApplicationsFromVerifiedPublisherOnly = $false
            PermissionClassification                    = 'all'
            Permissions                                 = [System.String[]] @('all')
            ResourceApplication                         = 'any'
        }
        foreach ($hash in @($hash1, $hash2))
        {
            foreach ($key in $serviceDefaults.Keys)
            {
                if (-not $hash.ContainsKey($key))
                {
                    $hash.Add($key, $serviceDefaults[$key])
                }
            }
        }

        # Compare each property, skipping Id (auto-generated by Graph API)
        foreach ($key in $hash1.Keys)
        {
            if ($key -eq 'Id')
            {
                continue
            }

            if (-not $hash2.ContainsKey($key))
            {
                return $false
            }

            $value1 = $hash1[$key]
            $value2 = $hash2[$key]

            # Handle array comparison
            if ($value1 -is [Array] -and $value2 -is [Array])
            {
                if ($value1.Count -ne $value2.Count)
                {
                    return $false
                }

                $sorted1 = $value1 | Sort-Object
                $sorted2 = $value2 | Sort-Object

                for ($i = 0; $i -lt $sorted1.Count; $i++)
                {
                    if ($sorted1[$i] -ne $sorted2[$i])
                    {
                        return $false
                    }
                }
            }
            else
            {
                if ($value1 -ne $value2)
                {
                    return $false
                }
            }
        }

        # Check for keys in hash2 that are not in hash1 (excluding Id)
        foreach ($key in $hash2.Keys)
        {
            if ($key -eq 'Id')
            {
                continue
            }

            if (-not $hash1.ContainsKey($key))
            {
                return $false
            }
        }

        return $true
    }

    hidden static [System.String] ConvertToPermissionName([System.Collections.Hashtable] $Cache, [System.String] $PermissionId, [System.String] $ResourceApplicationId, [System.String] $PermissionType)
    {
        # Pass through wildcard values
        if ($PermissionId -eq 'all' -or $PermissionId -eq 'any')
        {
            return $PermissionId
        }

        # If not a GUID, assume it is already a display name
        $guidResult = [System.Guid]::Empty
        if (-not [System.Guid]::TryParse($PermissionId, [ref]$guidResult))
        {
            return $PermissionId
        }

        # Cannot resolve without a specific resource application
        if ([System.String]::IsNullOrEmpty($ResourceApplicationId) -or
            $ResourceApplicationId -eq 'any')
        {
            Write-Verbose -Message "Cannot resolve permission GUID '$PermissionId' without a specific ResourceApplication."
            return $PermissionId
        }

        # If ResourceApplicationId is not a GUID, try to resolve it as a service principal name
        $appIdGuid = [System.Guid]::Empty
        if (-not [System.Guid]::TryParse($ResourceApplicationId, [ref]$appIdGuid))
        {
            $resolvedId = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($Cache, $ResourceApplicationId)
            if (-not [System.Guid]::TryParse($resolvedId, [ref]$appIdGuid))
            {
                Write-Verbose -Message "ResourceApplication '$ResourceApplicationId' could not be resolved to a valid GUID."
                return $PermissionId
            }
            $ResourceApplicationId = $resolvedId
        }

        try
        {
            $servicePrincipalCache = [AADPermissionGrantPolicy]::GetServicePrincipalCache($Cache, $false)
            $cacheKey = $appIdGuid.ToString()
            if ($servicePrincipalCache.ContainsKey($cacheKey))
            {
                Write-Verbose -Message "Using cached service principal for ResourceApplication '$ResourceApplicationId'."
                $servicePrincipal = $servicePrincipalCache[$cacheKey]
            }
            else
            {
                $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$cacheKey'" -ErrorAction SilentlyContinue
                $servicePrincipalCache[$cacheKey] = $servicePrincipal
            }

            if ($null -eq $servicePrincipal)
            {
                Write-Verbose -Message "Service principal for ResourceApplication '$ResourceApplicationId' not found."
                return $PermissionId
            }

            if ($PermissionType -eq 'delegated')
            {
                $scope = $servicePrincipal.Oauth2PermissionScopes | Where-Object { $_.Id -eq $guidResult }
                if ($null -ne $scope)
                {
                    Write-Verbose -Message "Resolved delegated permission GUID '$PermissionId' to name '$($scope.Value)'."
                    return $scope.Value
                }
            }
            elseif ($PermissionType -eq 'application')
            {
                $role = $servicePrincipal.AppRoles | Where-Object { $_.Id -eq $guidResult }
                if ($null -ne $role)
                {
                    Write-Verbose -Message "Resolved application permission GUID '$PermissionId' to name '$($role.Value)'."
                    return $role.Value
                }
            }

            # Try both collections if PermissionType is not specified or not found
            $scope = $servicePrincipal.Oauth2PermissionScopes | Where-Object { $_.Id -eq $guidResult }
            if ($null -ne $scope)
            {
                Write-Verbose -Message "Resolved permission GUID '$PermissionId' to name '$($scope.Value)' from Oauth2PermissionScopes."
                return $scope.Value
            }

            $role = $servicePrincipal.AppRoles | Where-Object { $_.Id -eq $guidResult }
            if ($null -ne $role)
            {
                Write-Verbose -Message "Resolved permission GUID '$PermissionId' to name '$($role.Value)' from AppRoles."
                return $role.Value
            }

            Write-Verbose -Message "Permission GUID '$PermissionId' not found in service principal for '$ResourceApplicationId'."
        }
        catch
        {
            Write-Verbose -Message "Error resolving permission GUID '$PermissionId': $_"
        }

        return $PermissionId
    }

    hidden [System.Collections.Hashtable] GetPermissionGrantConditionSetAsParameters([System.Collections.Hashtable] $Cache, [System.Object] $ConditionSet)
    {
        $params = @{}

        if ($null -ne $ConditionSet.CertifiedClientApplicationsOnly)
        {
            $params.Add('CertifiedClientApplicationsOnly', [bool]$ConditionSet.CertifiedClientApplicationsOnly)
        }

        if ($null -ne $ConditionSet.ClientApplicationIds -and $ConditionSet.ClientApplicationIds.Count -gt 0)
        {
            $params.Add('ClientApplicationIds', [string[]]$ConditionSet.ClientApplicationIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationPublisherIds -and $ConditionSet.ClientApplicationPublisherIds.Count -gt 0)
        {
            $params.Add('ClientApplicationPublisherIds', [string[]]$ConditionSet.ClientApplicationPublisherIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationTenantIds -and $ConditionSet.ClientApplicationTenantIds.Count -gt 0)
        {
            $params.Add('ClientApplicationTenantIds', [string[]]$ConditionSet.ClientApplicationTenantIds)
        }

        if ($null -ne $ConditionSet.ClientApplicationsFromVerifiedPublisherOnly)
        {
            $params.Add('ClientApplicationsFromVerifiedPublisherOnly', [bool]$ConditionSet.ClientApplicationsFromVerifiedPublisherOnly)
        }

        if (-not [string]::IsNullOrEmpty($ConditionSet.PermissionClassification))
        {
            $params.Add('PermissionClassification', $ConditionSet.PermissionClassification)
        }

        # Pass through ResourceApplication as-is (expects GUID or 'any')
        if (-not [string]::IsNullOrEmpty($ConditionSet.ResourceApplication))
        {
            $params.Add('ResourceApplication', $ConditionSet.ResourceApplication)
        }

        if (-not [string]::IsNullOrEmpty($ConditionSet.PermissionType))
        {
            $params.Add('PermissionType', $ConditionSet.PermissionType)
        }

        # Convert permission names to GUIDs
        if ($null -ne $ConditionSet.Permissions -and $ConditionSet.Permissions.Count -gt 0)
        {
            $resourceAppValue = $ConditionSet.ResourceApplication

            $resolvedPermissions = @()
            foreach ($permission in $ConditionSet.Permissions)
            {
                $resolvedPermissions += $this.ConvertToPermissionGuid($Cache, $permission, $resourceAppValue, $ConditionSet.PermissionType)
            }
            $params.Add('Permissions', [string[]]$resolvedPermissions)
        }

        return $params
    }

    hidden [System.String] ConvertToPermissionGuid([System.Collections.Hashtable] $Cache, [System.String] $PermissionName, [System.String] $ResourceApplicationId, [System.String] $PermissionType)
    {
        # Pass through wildcard values
        if ($PermissionName -eq 'all' -or $PermissionName -eq 'any')
        {
            return 'all'
        }

        # Check if already a GUID
        if ([System.Guid]::TryParse($PermissionName, [ref][System.Guid]::Empty))
        {
            return $PermissionName
        }

        # Cannot resolve without a specific resource application
        if ([System.String]::IsNullOrEmpty($ResourceApplicationId) -or
            $ResourceApplicationId -eq 'any')
        {
            Write-Verbose -Message "Cannot resolve permission name '$PermissionName' without a specific ResourceApplication."
            return $PermissionName
        }

        # If ResourceApplicationId is not a GUID, try to resolve it as a service principal name
        $appIdGuid = [System.Guid]::Empty
        if (-not [System.Guid]::TryParse($ResourceApplicationId, [ref]$appIdGuid))
        {
            $resolvedId = [AADPermissionGrantPolicy]::ResolveResourceApplicationId($Cache, $ResourceApplicationId)
            if (-not [System.Guid]::TryParse($resolvedId, [ref]$appIdGuid))
            {
                Write-Verbose -Message "ResourceApplication '$ResourceApplicationId' could not be resolved to a valid GUID."
                return $PermissionName
            }
            $ResourceApplicationId = $resolvedId
        }

        try
        {
            $servicePrincipalCache = [AADPermissionGrantPolicy]::GetServicePrincipalCache($Cache, $false)
            $cacheKey = $appIdGuid.ToString()
            if ($servicePrincipalCache.ContainsKey($cacheKey))
            {
                Write-Verbose -Message "Using cached service principal for ResourceApplication '$ResourceApplicationId'."
                $servicePrincipal = $servicePrincipalCache[$cacheKey]
            }
            else
            {
                $servicePrincipal = Get-MgServicePrincipal -Filter "AppId eq '$cacheKey'" -ErrorAction SilentlyContinue
                $servicePrincipalCache[$cacheKey] = $servicePrincipal
                if ($null -ne $servicePrincipal -and -not [System.String]::IsNullOrEmpty($servicePrincipal.DisplayName))
                {
                    $servicePrincipalCache[$servicePrincipal.DisplayName] = $servicePrincipal
                }
            }

            if ($null -eq $servicePrincipal)
            {
                Write-Verbose -Message "Service principal for ResourceApplication '$ResourceApplicationId' not found."
                return $PermissionName
            }

            if ($PermissionType -eq 'delegated')
            {
                $scope = $servicePrincipal.Oauth2PermissionScopes | Where-Object { $_.Value -eq $PermissionName }
                if ($null -ne $scope)
                {
                    Write-Verbose -Message "Resolved delegated permission '$PermissionName' to GUID '$($scope.Id)'."
                    return $scope.Id.ToString()
                }
            }
            elseif ($PermissionType -eq 'application')
            {
                $role = $servicePrincipal.AppRoles | Where-Object { $_.Value -eq $PermissionName }
                if ($null -ne $role)
                {
                    Write-Verbose -Message "Resolved application permission '$PermissionName' to GUID '$($role.Id)'."
                    return $role.Id.ToString()
                }
            }

            # Try both collections if PermissionType is not specified or not found
            $scope = $servicePrincipal.Oauth2PermissionScopes | Where-Object { $_.Value -eq $PermissionName }
            if ($null -ne $scope)
            {
                Write-Verbose -Message "Resolved permission '$PermissionName' to GUID '$($scope.Id)' from Oauth2PermissionScopes."
                return $scope.Id.ToString()
            }

            $role = $servicePrincipal.AppRoles | Where-Object { $_.Value -eq $PermissionName }
            if ($null -ne $role)
            {
                Write-Verbose -Message "Resolved permission '$PermissionName' to GUID '$($role.Id)' from AppRoles."
                return $role.Id.ToString()
            }

            Write-Verbose -Message "Permission '$PermissionName' not found in service principal for '$ResourceApplicationId'."
        }
        catch
        {
            Write-Verbose -Message "Error resolving permission '$PermissionName': $_"
        }

        return $PermissionName
    }

    hidden static [System.String] ResolveResourceApplicationId([System.Collections.Hashtable] $Cache, [System.String] $ResourceApplication)
    {
        # Pass through wildcard
        if ($ResourceApplication -eq 'any')
        {
            return $ResourceApplication
        }

        # If already a GUID, return as-is
        $guidResult = [System.Guid]::Empty
        if ([System.Guid]::TryParse($ResourceApplication, [ref]$guidResult))
        {
            return $ResourceApplication
        }

        try
        {
            $servicePrincipalCache = [AADPermissionGrantPolicy]::GetServicePrincipalCache($Cache, $false)

            # Check if the display name is already in the cache
            if ($servicePrincipalCache.ContainsKey($ResourceApplication))
            {
                $servicePrincipal = $servicePrincipalCache[$ResourceApplication]
            }
            else
            {
                # Look up the service principal by display name
                $escapedName = $ResourceApplication -replace "'", "''"
                $servicePrincipal = Get-MgServicePrincipal -Filter "DisplayName eq '$escapedName'" -ErrorAction SilentlyContinue
            }

            if ($null -ne $servicePrincipal)
            {
                # Handle array result (multiple SPs with same name)
                if ($servicePrincipal -is [Array])
                {
                    Write-Verbose -Message "Multiple service principals found for DisplayName '$ResourceApplication'. Using the first match."
                    $servicePrincipal = $servicePrincipal[0]
                }

                $servicePrincipalCache[$servicePrincipal.AppId] = $servicePrincipal
                if (-not [System.String]::IsNullOrEmpty($servicePrincipal.DisplayName))
                {
                    $servicePrincipalCache[$servicePrincipal.DisplayName] = $servicePrincipal
                }
                Write-Verbose -Message "Resolved ResourceApplication name '$ResourceApplication' to AppId '$($servicePrincipal.AppId)'."
                return $servicePrincipal.AppId
            }
        }
        catch
        {
            Write-Verbose -Message "Error resolving ResourceApplication name '$ResourceApplication': $_"
        }

        Write-Verbose -Message "Could not resolve ResourceApplication name '$ResourceApplication' to an AppId."
        return $ResourceApplication
    }

    hidden [AADPermissionGrantPolicy] AsResult([System.Object] $Values)
    {
        if ($Values -is [AADPermissionGrantPolicy])
        {
            return $Values
        }

        $result = [AADPermissionGrantPolicy]::new()
        $result.ClearNonSchemaProperties()
        if ($Values -is [System.Collections.Hashtable])
        {
            $result.FromHashtable($Values)
        }

        return $result
    }
}

class MSFT_AADPermissionGrantConditionSet
{
    [DscProperty()]
    [System.ComponentModel.Description('The unique identifier for the condition set.')]
    [System.String] $Id

    [DscProperty()]
    [System.ComponentModel.Description('Set to true to only match on client applications that are from a Microsoft Partner Network verified publisher. Set to false to match on any client app.')]
    [System.Nullable[System.Boolean]] $CertifiedClientApplicationsOnly

    [DscProperty()]
    [System.ComponentModel.Description('A list of appId values for the client applications to match with, or a list with the single value all to match any client application.')]
    [System.String[]] $ClientApplicationIds

    [DscProperty()]
    [System.ComponentModel.Description('A list of Microsoft Partner Network (MPN) IDs for verified publishers of the client application, or a list with the single value all to match with client apps from any publisher.')]
    [System.String[]] $ClientApplicationPublisherIds

    [DscProperty()]
    [System.ComponentModel.Description('A list of Entra ID tenant IDs in which the client application is registered, or a list with the single value all to match with client apps registered in any tenant.')]
    [System.String[]] $ClientApplicationTenantIds

    [DscProperty()]
    [System.ComponentModel.Description('Set to true to only match on client applications with a verified publisher. Set to false to match on any client app. Default is false.')]
    [System.Nullable[System.Boolean]] $ClientApplicationsFromVerifiedPublisherOnly

    [DscProperty()]
    [System.ComponentModel.Description('The permission classification for the permission being granted, or all to match with any permission classification (including permissions which are not classified). Default is all.')]
    [System.String] $PermissionClassification

    [DscProperty()]
    [System.ComponentModel.Description('The list of permission display names to match with (e.g. ''User.Read'', ''Mail.Send''), or a list with the single value all to match with any permission. Do not use permission GUIDs.')]
    [System.String[]] $Permissions

    [DscProperty()]
    [System.ComponentModel.Description('The permission type of the permission being granted. Possible values: application for application permissions, or delegated for delegated permissions.')]
    [System.String] $PermissionType

    [DscProperty()]
    [System.ComponentModel.Description('The appId of the resource application (e.g. ''00000003-0000-0000-c000-000000000000'' for Microsoft Graph) for which a permission is being granted, or ''any'' to match any resource application. Use the AppId GUID, not the display name.')]
    [System.String] $ResourceApplication
}
